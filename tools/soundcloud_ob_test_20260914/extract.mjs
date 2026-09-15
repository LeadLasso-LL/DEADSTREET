import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const dir=path.dirname(fileURLToPath(import.meta.url));
const html=await fs.readFile(path.join(dir,'page.html'),'utf8');
const track=JSON.parse(html.match(/window.__sc_hydration\s*=\s*(\[.*?\]);/s)[1]).find(x=>x.hydratable==='sound').data;
async function get(url){const r=await fetch(url,{signal:AbortSignal.timeout(25000)});if(!r.ok)throw Error('HTTP '+r.status+' at '+new URL(url).hostname);return r;}
const scripts=[...html.matchAll(/<script[^>]+src="([^"]+)"/g)].map(x=>x[1]).filter(x=>x.includes('sndcdn.com')).reverse();
let client;
for(const url of scripts){const body=await(await get(url)).text();client=body.match(/client_id\s*:\s*"([a-zA-Z0-9]{32})"/)?.[1];if(client)break;}
if(!client)throw Error('Public playback client identifier not found');
const transcode=track.media.transcodings.find(x=>x.format.protocol==='progressive'&&!x.snipped);
if(!transcode)throw Error('Full progressive playback is unavailable');
const endpoint=new URL(transcode.url);endpoint.searchParams.set('client_id',client);
if(track.track_authorization)endpoint.searchParams.set('track_authorization',track.track_authorization);
const resolved=await(await get(endpoint)).json();
if(!resolved.url)throw Error('Playback endpoint returned no audio URL');
const response=await get(resolved.url),bytes=Buffer.from(await response.arrayBuffer());
if(bytes.length<100000)throw Error('Unexpectedly short audio file');
const file='OB_Bond.mp3';await fs.writeFile(path.join(dir,file),bytes);
const manifest={title:track.title,source_title:track.title,artist:'OB',source_artist:track.user.username,source_url:'https://on.soundcloud.com/7xSTXKeQvsfhgntLOU',canonical_url:track.permalink_url,track_id:track.id,duration_ms:track.duration,downloadable:track.downloadable,method:'page-provided full progressive playback',settings_changed:false,playlist_installed:false,faction_assigned:false,source_format:transcode.preset,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),file,verified_decode:false};
await fs.writeFile(path.join(dir,'manifest.json'),JSON.stringify(manifest,null,2));
console.log(JSON.stringify(manifest));
