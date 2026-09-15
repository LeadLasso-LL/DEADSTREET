from pathlib import Path
import subprocess,json,hashlib,concurrent.futures,os,re,base64
import imageio_ffmpeg
from PIL import Image,ImageDraw
r=Path(__file__).resolve().parents[2];d=Path(__file__).resolve().parent;assets=r/'assets/menu/opening';ff=imageio_ffmpeg.get_ffmpeg_exe()
sources=json.loads((d/'sources.json').read_text());shots=json.loads((d/'shots.json').read_text())
def run(args,name):
 if (name.startswith('shot_') or name=='encode_montage') and Path(args[-1]).exists():return None
 result=subprocess.run([ff,'-nostdin','-v','error','-xerror']+args,capture_output=True)
 (d/(name+'.log')).write_bytes(result.stderr)
 assert result.returncode==0,result.stderr[-3000:]
 return result
def shot(i):
 name,start,count,rect,label=shots[i];x,y,w,h=rect
 vf=f'crop={w}:{h}:{x}:{y},scale=1280:720:flags=neighbor,setsar=1,fps=30,setpts=N/(30*TB)'
 # Mask source status-label fragments exposed by the lower-action composition.
 hud_bottom={'harold':170,'bridge':112,'doble':112}.get(name,0)
 mask=max(0,int((hud_bottom-y)*720/h)+2) if y<hud_bottom else 0
 if mask:vf+=f',drawbox=x=0:y=0:w=iw:h={mask}:color=black:t=fill'
 if name=='freight':vf+=',eq=gamma=1.13:brightness=0.012'
 run(['-ss',str(start),'-i',str(r/sources[name]),'-vf',vf,'-frames:v',str(count),'-an','-c:v','libx264','-preset','fast','-crf','14','-threads','2','-pix_fmt','yuv420p','-y',str(d/f'shot_{i:02d}.mkv')],f'shot_{i:02d}')
 print('SHOT_READY',i,label,flush=True)
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:list(pool.map(shot,range(len(shots))))
(d/'cuts.txt').write_text(''.join("file 'shot_%02d.mkv'\n"%i for i in range(len(shots))).replace('\\n','\n'))
# Exact hard cuts retain the action frame at each cut and loop without a freeze pad.
args=[];graph=[]
for i in range(len(shots)):
 args+=['-i',str(d/f'shot_{i:02d}.mkv')]
 graph.append(f'[{i}:v]settb=AVTB,setpts=N/(30*TB)[c{i}]')
graph.append(''.join(f'[c{i}]' for i in range(len(shots)))+'concat=n=14:v=1:a=0,settb=AVTB,setpts=N/(30*TB),fps=30,hue=s=0,eq=contrast=1.12:brightness=-0.008:gamma=0.99,colorchannelmixer=rr=0.76:gg=0.76:bb=0.76,vignette=angle=PI/6[v]')
run(['-filter_complex_threads','2']+args+['-filter_complex',';'.join(graph),'-map','[v]','-frames:v','720','-an','-c:v','libtheora','-q:v','9','-pix_fmt','yuv420p','-r','30','-threads','2','-y',str(d/'montage_candidate.ogv')],'encode_montage')
check=run(['-i',str(d/'montage_candidate.ogv'),'-map','0:v:0','-an','-vf','fps=30','-progress','pipe:1','-f','null','NUL'],'decode_montage')
frames=int(re.findall(rb'frame=(\d+)',check.stdout)[-1]);assert frames==720,frames
# Review the exact candidate with the existing title, camera UI, button, and signature section.
title=Image.open(assets/'approved_title.png').convert('RGB').resize((1056,384),Image.Resampling.NEAREST)
alpha=title.convert('L');overlay=Image.new('RGBA',title.size,(255,255,255,255));overlay.putalpha(alpha);overlay.save(d/'preview_title.png')
graph=[
'[0:v]fade=t=in:st=0:d=0.6,format=rgb24[bg]',
'[1:v]format=rgba[title]',
"[bg][title]overlay=x=112:y='79+round(2.2*sin(2*PI*t/1.35)+0.55*sin(2*PI*t/0.43))':format=auto[brand]",
'[2:v]format=rgba,fade=t=in:st=0:d=0.6:alpha=1[camera]',
'[brand][camera]overlay=0:0:format=auto[ui]',
"[ui][3:v]overlay=489:575:format=auto:enable='gte(t,6)',format=yuv420p[v]",
'[4:a]volume=-4dB[a]']
run(['-filter_complex_threads','2','-i',str(d/'montage_candidate.ogv'),'-loop','1','-framerate','30','-i',str(d/'preview_title.png'),'-loop','1','-framerate','30','-i',str(assets/'camera_ui.png'),'-loop','1','-framerate','30','-i',str(assets/'open_button.png'),'-ss','21','-i',str(assets/'B-22_Dead_Street.mp3'),'-filter_complex',';'.join(graph),'-map','[v]','-map','[a]','-frames:v','720','-t','24','-c:v','libx264','-preset','fast','-crf','19','-pix_fmt','yuv420p','-c:a','aac','-b:a','160k','-movflags','+faststart','-y',str(d/'DEAD_STREET_Action_Montage_Final.mp4')],'review_preview')
run(['-i',str(d/'DEAD_STREET_Action_Montage_Final.mp4'),'-f','null','NUL'],'decode_preview')
sheet=Image.new('RGB',(1920,1440));offset=0
for i,s in enumerate(shots):
 t=offset+min(.8,s[2]/60.);out=d/f'preview_{i:02d}.jpg'
 run(['-ss',str(t),'-i',str(d/'DEAD_STREET_Action_Montage_Final.mp4'),'-frames:v','1','-vf','scale=480:270','-y',str(out)],f'preview_still_{i}')
 sheet.paste(Image.open(out),((i%4)*480,(i//4)*360));ImageDraw.Draw(sheet).text(((i%4)*480+8,(i//4)*360+275),str(i)+' '+s[4],fill='white')
 offset+=s[2]/30.
sheet.save(d/'final_review_sheet.jpg',quality=94)
data=(d/'DEAD_STREET_Action_Montage_Final.mp4').read_bytes();parts=d/'transfer';parts.mkdir(exist_ok=True);manifest=[]
for i,start in enumerate(range(0,len(data),1000000)):
 chunk=data[start:start+1000000];name=f'part_{i:03d}.txt';(parts/name).write_text(base64.b64encode(chunk).decode());manifest.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
report={'frames':frames,'seconds':24,'size':[1280,720],'maps':sorted(sources),'shots':shots,'candidate_sha256':hashlib.sha256((d/'montage_candidate.ogv').read_bytes()).hexdigest(),'source_hashes':{n:hashlib.sha256((r/p).read_bytes()).hexdigest() for n,p in sources.items()},'preview':str(d/'DEAD_STREET_Action_Montage_Final.mp4'),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'parts':manifest,'review_type':'Edited montage preview using exact candidate and existing native title/UI coordinates; not a full intro capture'}
(d/'render.json').write_text(json.dumps(report,indent=2));print('RENDER_COMPLETE',json.dumps({'frames':frames,'bytes':len(data),'parts':len(manifest)}),flush=True)
