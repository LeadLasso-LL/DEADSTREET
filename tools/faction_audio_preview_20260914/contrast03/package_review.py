"""Create labeled review reel, embedded playlist, and delivery validation."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import json, subprocess, math, html, base64, hashlib
import numpy as np
from scipy.io import wavfile
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parent
PRE=ROOT/'previews'; OUT=ROOT/'review'; OUT.mkdir(exist_ok=True)
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
def f(size,bold=False): return ImageFont.truetype(BOLD if bold else FONT,size)
def run(args): return subprocess.run(args,capture_output=True,text=True,check=True)
rows=json.loads((ROOT/'manifest.json').read_text())
assert len(rows)==3 and {x['number'] for x in rows}==set(range(1,4))

def card(r):
    num=r['number']; accent=(171,120,104)
    im=Image.new('RGB',(1280,720),(16,18,20)); d=ImageDraw.Draw(im)
    d.rectangle((0,0,1279,7),fill=accent)
    d.text((65,49),'DEAD STREET',font=f(26,True),fill=(216,216,209))
    d.text((65,94),'FACTION AUDIO  /  CONTRAST TEST 03',font=f(17),fill=(143,146,140))
    d.text((1070,47),f'{num:02d} / 03',font=f(27,True),fill=accent)
    name=r['name']; lines=[]; line=''
    for word in name.split():
        trial=(line+' '+word).strip()
        if d.textlength(trial,font=f(48,True))>1110: lines.append(line); line=word
        else: line=trial
    lines.append(line)
    yy=200 if len(lines)>1 else 230
    for line in lines:
        d.text((65,yy),line,font=f(48,True),fill=(239,238,232)); yy+=64
    d.text((68,yy+24),r['vibe'],font=f(24),fill=accent)
    # Exact waveform from the rendered master, for orientation rather than fake animation.
    sr,x=wavfile.read(PRE/r['wav']); x=x.astype(np.float64)/32768
    bins=225; edges=np.linspace(0,len(x),bins+1,dtype=int)
    levels=np.array([np.sqrt(np.mean(x[a:b]**2)) for a,b in zip(edges[:-1],edges[1:])])
    levels/=max(.01,levels.max())
    for i,l in enumerate(levels):
        xx=68+i*5; h=5+int(30*l); d.rounded_rectangle((xx,505-h,xx+2,505+h),1,fill=(143,135,114))
    d.line((65,590,1215,590),fill=(52,55,53),width=1)
    d.text((65,616),f'{r["bpm"]} BPM    /    {r["meter"]}/4    /    {r["duration"]:.0f} SEC',font=f(19),fill=(152,156,150))
    d.text((65,657),'INSTRUMENTAL SKETCH — AWAITING YOUR REVIEW',font=f(16),fill=(122,128,123))
    png=OUT/f'{num:02d}_card.png'; im.save(png)
    clip=OUT/f'{num:02d}_clip.mp4'
    # Equal frame rate and ceil duration produce concatenation without truncated audio.
    duration=math.ceil(r['duration']*12)/12
    run(['ffmpeg','-v','error','-y','-loop','1','-framerate','12','-i',str(png),'-i',str(PRE/r['wav']),'-t',str(duration),'-c:v','libx264','-tune','stillimage','-preset','fast','-crf','24','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-af','apad','-ar','44100','-ac','2','-video_track_timescale','12000',str(clip)])
    r['reel_duration']=duration
    return clip

with ThreadPoolExecutor(max_workers=3) as pool: clips=list(pool.map(card,rows))
print('3 labeled video clips rendered',flush=True)
concat=OUT/'concat.txt'; concat.write_text(''.join("file '"+str(c)+"'\n" for c in clips))
meta=[';FFMETADATA1','title=DEAD STREET — Three Independent Contrast Tests','artist=DEAD STREET','comment=New dark compositions after rejected audition01. Tempos 20 percent lower. Preview only; pending owner approval.']
t=0
for r in rows:
    r['reel_start']=round(t,3)
    meta+=['[CHAPTER]','TIMEBASE=1/1000',f'START={round(t*1000)}',f'END={round((t+r["reel_duration"])*1000)}','title='+str(r['number']).zfill(2)+' — '+r['name']]
    t+=r['reel_duration']
metadata=OUT/'chapters.ffmeta'; metadata.write_text('\n'.join(meta))
video=OUT/'Dead_Street_Three_Contrasts.mp4'
run(['ffmpeg','-v','error','-y','-f','concat','-safe','0','-i',str(concat),'-i',str(metadata),'-map','0:v','-map','0:a','-map_metadata','1','-map_chapters','1','-c','copy','-movflags','+faststart',str(video)])
print('Combined listening reel rendered',flush=True)

cards=[]
for r in rows:
    src='data:audio/mpeg;base64,'+base64.b64encode((PRE/r['mp3']).read_bytes()).decode()
    cards.append('<article><div class="number">'+str(r['number']).zfill(2)+'</div><div><h2>'+html.escape(r['name'])+'</h2><p>'+html.escape(r['vibe'])+'</p><audio controls preload="none" src="'+src+'"></audio></div></article>')
page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>DEAD STREET — Faction Audio Previews</title><style>
*{box-sizing:border-box}body{margin:0;background:#101214;color:#eeeeea;font:16px system-ui,sans-serif}main{max-width:950px;margin:auto;padding:36px 22px}header{border-top:4px solid #c9ac77;padding:25px 0 22px}h1{font-size:36px;letter-spacing:1px;margin:0 0 8px}header p{color:#b7b7ae;line-height:1.5}article{display:grid;grid-template-columns:44px 1fr;gap:15px;border-top:1px solid #343734;padding:24px 0}.number{color:#c9ac77;font-size:24px;font-weight:800}h2{font-size:21px;margin:0 0 8px}p{margin:0 0 14px;color:#bdbbaF}audio{display:block;width:100%;max-width:690px}button{background:#c9ac77;color:#101214;border:0;border-radius:5px;padding:12px 18px;font-size:15px;font-weight:700;cursor:pointer;margin:5px 8px 12px 0}footer{color:#90978e;font-size:13px;line-height:1.6;padding:25px 0}a{color:#c9ac77}</style><main><header><h1>DEAD STREET</h1><p>Three separately written approaches: Eastex rap, Ravicci chamber music, Blacktop doom. Listen for distinct musical identity before expanding the set.</p><button id="all">Play all in order</button><button id="stop">Pause</button><p id="now" aria-live="polite"></p></header>'''+''.join(cards)+'''<footer>Original compositions and arrangements for these previews. Sampled instruments: GeneralUser GS by S. Christian Collins. Rendered with TinySoundFont; individual masters at −18 LUFS target. These previews have not been installed in the game.</footer></main><script>
const players=[...document.querySelectorAll('audio')];let continuous=false;const now=document.querySelector('#now');players.forEach((a,i)=>{a.addEventListener('play',()=>{players.forEach(b=>{if(b!==a)b.pause()});now.textContent=String(i+1).padStart(2,'0')+' — '+a.closest('article').querySelector('h2').textContent});a.addEventListener('ended',()=>{if(continuous&&i+1<players.length){players[i+1].currentTime=0;players[i+1].play().catch(()=>{now.textContent='Tap play on the next track to continue.'})}})});document.querySelector('#all').onclick=()=>{continuous=true;players[0].currentTime=0;players[0].play()};document.querySelector('#stop').onclick=()=>{continuous=false;players.forEach(a=>a.pause())};</script></html>'''
(OUT/'Dead_Street_Three_Contrasts_Player.html').write_text(page)

def verify(r):
    p=PRE/r['mp3']
    result=run(['ffmpeg','-hide_banner','-i',str(p),'-af','loudnorm=I=-18:TP=-2:LRA=9:print_format=json','-f','null','-'])
    st=json.loads(result.stderr[result.stderr.rfind('{'):])
    assert -20<float(st['input_i'])<-16, (r['id'],st)
    assert float(st['input_tp'])<-.8, (r['id'],st)
    return {'id':r['id'],'full_decode':'PASS','integrated_lufs':float(st['input_i']),'true_peak_dbtp':float(st['input_tp']),'sha256':r['sha256']}
with ThreadPoolExecutor(max_workers=3) as pool: checks=list(pool.map(verify,rows))
probe=json.loads(run(['ffprobe','-v','error','-show_streams','-show_chapters','-show_format','-of','json',str(video)]).stdout)
assert len(probe['chapters'])==3
assert abs(float(probe['format']['duration'])-t)<.2
run(['ffmpeg','-v','error','-i',str(video),'-f','null','-'])
validation={'files':checks,'reel_full_decode':'PASS','chapter_count':3,'duration':float(probe['format']['duration']),'sample_rate':44100,'channels':2,'auditory_review':'Not independently listened to; owner listening review pending. Machine checks establish decoding, loudness and absence of clipping, not artistic quality.','in_game_test':'Not run: no runtime integration or game change.','production_status':'PREVIEW ONLY — NOT APPROVED','reel_sha256':hashlib.sha256(video.read_bytes()).hexdigest()}
(ROOT/'validation.json').write_text(json.dumps(validation,ensure_ascii=False,indent=2))
(ROOT/'review_index.json').write_text(json.dumps([{k:v for k,v in r.items() if k!='score'} for r in rows],ensure_ascii=False,indent=2))
lines=['# DEAD STREET — three independent contrast tests','', 'Instrumental sketches for listening review. No runtime integration; no approved soundtrack assets.','', '| # | Faction | Reel start | Vibe |','|---|---|---|---|']
for r in rows:
    sec=round(r['reel_start']); stamp=f'{sec//60}:{sec%60:02d}'
    lines.append(f'| {r["number"]:02d} | {r["name"]} | {stamp} | {r["vibe"]} |')
(OUT/'LISTENING_GUIDE.md').write_text('\n'.join(lines)+'\n')
print(json.dumps({'status':'PASS','previews':len(checks),'reel_seconds':validation['duration'],'video_bytes':video.stat().st_size,'loudness_range':[min(x['integrated_lufs'] for x in checks),max(x['integrated_lufs'] for x in checks)]}),flush=True)
