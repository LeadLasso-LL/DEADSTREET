import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const root=path.dirname(fileURLToPath(import.meta.url));
const source='https://soundcloud.com/brandonharb-1/track-22/s-eO7fL';
async function get(u){const r=await fetch(u,{signal:AbortSignal.timeout(25000)});if(!r.ok)throw Error('HTTP '+r.status);return r;}
const html=await(await get(source)).text();
const track=JSON.parse(html.match(/window.__sc_hydration\s*=\s*(\[.*?\]);/s)[1]).find(x=>x.hydratable==='sound').data;
console.log(JSON.stringify({title:track.title,artist:track.user.username,duration_ms:track.duration}));
const scripts=[...html.matchAll(/<script[^>]+src="([^"]+)"/g)].map(x=>x[1]).filter(x=>x.includes('sndcdn.com')).reverse();
let client;
for(const url of scripts){const body=await(await get(url)).text();client=body.match(/client_id\s*:\s*"([a-zA-Z0-9]{32})"/)?.[1];if(client)break;}
if(!client)throw Error('Public playback client identifier not found');
const transcode=track.media.transcodings.find(x=>x.format.protocol==='progressive');
const endpoint=new URL(transcode.url);endpoint.searchParams.set('client_id',client);
if(track.track_authorization)endpoint.searchParams.set('track_authorization',track.track_authorization);
const resolved=await(await get(endpoint)).json();
const bytes=Buffer.from(await(await get(resolved.url)).arrayBuffer());
if(bytes.length<100000)throw Error('Unexpectedly short audio file');
const output=path.join(root,'B-22_Track_22.mp3');await fs.writeFile(output,bytes);
const manifest={title:track.title,source_artist:track.user.username,artist:'B-22',source_url:source,track_id:track.id,duration_ms:track.duration,role:'signature_intro_and_shuffle',exclude_first_shuffle:true,source_format:transcode.preset,bytes:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),file:output,verified_decode:false};
await fs.writeFile(path.join(root,'track_22.json'),JSON.stringify(manifest,null,2));console.log(JSON.stringify(manifest));
