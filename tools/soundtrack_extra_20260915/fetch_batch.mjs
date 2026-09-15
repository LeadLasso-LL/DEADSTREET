import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const out=path.dirname(fileURLToPath(import.meta.url));
const manifest=JSON.parse((await fs.readFile(path.join(out,'manifest.json'),'utf8')).replace(/^\uFEFF/,''));
const cache=path.join(out,'downloads');await fs.mkdir(cache,{recursive:true});
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const results=[];
let clientPromise;
async function get(url){
  for(let attempt=0;attempt<3;attempt++){
    try{
      const r=await fetch(url,{signal:AbortSignal.timeout(25000)});
      if(r.ok)return r;
      const e=new Error('HTTP '+r.status+' at '+new URL(url).hostname);
      if(r.status!==429&&r.status<500)throw Object.assign(e,{terminal:true});
      throw e;
    }catch(e){if(e.terminal||attempt===2)throw e;await new Promise(resolve=>setTimeout(resolve,500*(attempt+1)));}
  }
}
async function discover(html){
  const scripts=[...html.matchAll(/<script[^>]+src="([^"]+)"/g)].map(x=>x[1]).filter(x=>x.includes('sndcdn.com')).reverse();
  for(const url of scripts){const body=await(await get(url)).text();const id=body.match(/client_id\s*:\s*"([a-zA-Z0-9]{32})"/)?.[1];if(id)return id;}
  throw new Error('Public playback client identifier unavailable');
}
async function one(item){
  const target=path.join(cache,item.basename+'.mp3'), metaFile=path.join(cache,item.id+'.json');
  try{
    try{
      const prior=JSON.parse(await fs.readFile(metaFile,'utf8'));
      const bytes=await fs.readFile(target);
      if(prior.source_url===item.source_url&&sha(bytes)===prior.sha256){results.push({...prior,status:'cached'});console.log('CACHED '+item.index+' '+item.id);return;}
    }catch{}
    const response=await get(item.source_url);const html=await response.text();
    const hydration=html.match(/window.__sc_hydration\s*=\s*(\[.*?\]);/s);
    if(!hydration)throw new Error('Track data not available on shared page');
    const track=JSON.parse(hydration[1]).find(x=>x.hydratable==='sound')?.data;
    if(!track)throw new Error('Shared URL did not resolve to a track');
    if((track.duration/1000)<item.start_seconds+item.duration_seconds)throw new Error('Track is shorter than requested excerpt');
    const transcoding=track.media?.transcodings?.find(x=>x.format.protocol==='progressive'&&!x.snipped);
    if(!transcoding)throw new Error('Full progressive playback unavailable with current settings');
    clientPromise??=discover(html);const client=await clientPromise;
    const endpoint=new URL(transcoding.url);endpoint.searchParams.set('client_id',client);
    if(track.track_authorization)endpoint.searchParams.set('track_authorization',track.track_authorization);
    const resolved=await(await get(endpoint)).json();
    if(!resolved.url)throw new Error('No audio URL returned by playback endpoint');
    const bytes=Buffer.from(await(await get(resolved.url)).arrayBuffer());
    if(bytes.length<100000)throw new Error('Unexpectedly short audio file');
    const meta={...item,status:'downloaded',source_title:track.title,source_artist:track.user?.username,source_track_id:track.id,canonical_url:track.permalink_url,source_duration_seconds:track.duration/1000,downloadable:track.downloadable,source_policy:track.policy,source_format:transcoding.preset,bytes:bytes.length,sha256:sha(bytes),settings_changed:false};
    await fs.writeFile(target+'.part',bytes);await fs.rename(target+'.part',target);
    await fs.writeFile(metaFile,JSON.stringify(meta,null,2));results.push(meta);
    console.log('DOWNLOADED '+item.index+'/3 '+item.artist+' '+item.title+' '+bytes.length+' bytes');
  }catch(e){const failure={...item,status:'failed',error:e.message};results.push(failure);await fs.writeFile(path.join(cache,item.id+'.error.json'),JSON.stringify(failure,null,2));console.log('FAILED '+item.id+' '+e.message);}
}
let cursor=0;
await Promise.all(Array.from({length:3},async()=>{while(cursor<manifest.tracks.length){const item=manifest.tracks[cursor++];await one(item);}}));
results.sort((a,b)=>a.index-b.index);
const report={count:results.length,successful:results.filter(x=>x.status!=='failed').length,failures:results.filter(x=>x.status==='failed'),tracks:results};
await fs.writeFile(path.join(out,'download_report.json'),JSON.stringify(report,null,2));
console.log('DOWNLOAD_COMPLETE '+report.successful+'/'+manifest.tracks.length);
if(report.failures.length)process.exitCode=1;
