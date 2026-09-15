"""Third opening review: deliberate redaction zoom, pixel assembly, action montage.

All imagery is the existing approved artwork/actual game recording. Pixel assembly
and hover are time-dependent compositing effects; the title source is unchanged.
"""
from pathlib import Path
import subprocess, json, math, hashlib, os, sys
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parent
ASSETS=ROOT.parent
FPS=30; W=1280; H=720
TITLE_START=13; TITLE_COMPLETE=21; BUTTON_TIME=27; SANDBOX_TIME=45; DURATION=57
SOURCES={
 'estate':Path('/workspace/scratch/6a4bd31e258d/Dead_Street_Whittaker_Estate_Mobile.mp4'),
 'bridge':Path('/workspace/scratch/5f2238267ccd/Dead_Street_Raiders_Victory_Final_Mobile.mp4'),
 'harold':ROOT/'sources/Dead Street/Dead_Street_Harold_Battle_Finish.mp4',
}
if not SOURCES['estate'].exists():
 SOURCES={'estate':ROOT.parents[1]/'whittaker_estate/Dead_Street_Whittaker_Estate_Mobile.mp4',
          'bridge':ROOT.parents[1]/'raiders_recording/Dead_Street_Raiders_Victory_Mobile.mp4',
          'harold':ROOT.parents[1]/'battle_finish/results/Dead_Street_Harold_Battle_Finish.mp4'}
# First shot is an active firefight. Convoy and dismount follow later.
# source, in-point, visible segment frames, crop x/y/w/h, shot description
SHOTS=[
 ('bridge',34.5,60,(345,104,530,298),'CROSSFIRE'),
 ('harold',12.5,60,(420,190,1024,576),'HAROLD STREET CROSSFIRE'),
 ('estate',6.2,90,(170,115,640,360),'TRC CONVOY ACROSS GRASS'),
 ('bridge',51.5,60,(340,104,580,326),'BRIDGE CASUALTY'),
 ('estate',9.0,90,(210,135,575,323),'TRC DISMOUNT'),
 ('harold',19.4,60,(600,260,896,504),'MERCER FRONTAGE FIREFIGHT'),
 ('bridge',54.6,60,(470,102,530,298),'BLOCKADE FIREFIGHT'),
 ('estate',55.0,60,(310,125,530,298),'GATE ASSAULT'),
 ('bridge',61.0,60,(520,101,530,298),'RAIDERS ADVANCE'),
 ('harold',30.8,60,(420,250,896,504),'ORLOV STREET ASSAULT'),
 ('bridge',69.0,60,(500,100,580,326),'FINAL CROSSFIRE'),
]
TIMELINE={'gloria_hold':[0,3],'godot_hold':[4,7],
 'caution_fade_in':[7.5,8.0],'caution_full_hold':[8.0,9.25],'caution_zoom':[9.25,11.5],'black_hold':[11.5,13],
 'pixel_title_assembly':[13,21],'title_complete_and_hover_start':21,
 'background_fade_in':[21,21.6],'open_sandbox_first_visible':27,
 'preview_sandbox_entry':45,'preview_music_docked':48.75,'preview_playlist_open':51,
 'music':'Dead Street — B-22; one uninterrupted stream from 0 through sandbox entry'}
(ROOT/'qa').mkdir(exist_ok=True)

def probe(path):
 p=subprocess.run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(path)],capture_output=True,text=True,check=True)
 if p.stderr.strip():raise RuntimeError(p.stderr)
 return json.loads(p.stdout)

def frames(path,expected):
 m=probe(path);v=next(s for s in m['streams'] if s['codec_type']=='video')
 assert int(v['nb_read_frames'])==expected,(path,v['nb_read_frames'],expected)
 return m

def run(args,name,expected=None):
 final=ROOT/name;temp=ROOT/(final.stem+'.rendering'+final.suffix)
 cmd=['ffmpeg','-nostdin','-xerror','-v','warning']+args+['-y',str(temp)]
 p=subprocess.run(cmd,capture_output=True)
 (ROOT/(name+'.log')).write_bytes(p.stderr)
 if p.returncode or b'ended prematurely' in p.stderr:raise RuntimeError(p.stderr.decode(errors='replace')[-3000:])
 if expected is not None:frames(temp,expected)
 os.replace(temp,final)
 print('READY',name,flush=True)
 return final

def enc():return ['-an','-c:v','libx264','-preset','fast','-crf','16','-pix_fmt','yuv420p','-threads','2']

def make_warning():
 for name,count,filter_text in [('gloria',105,'fade=t=out:st=3:d=0.5'),('godot',120,'fade=t=in:st=0:d=0.5,fade=t=out:st=3.5:d=0.5')]:
  target=ASSETS/f'startup_{name}.mkv'
  if not target.exists():
   run(['-loop','1','-framerate','30','-i',str(ASSETS/f'credit_{name}.png'),'-vf',filter_text,'-frames:v',str(count)]+enc(),f'startup_{name}.mkv',count)
 vf="scale=1280:720:flags=neighbor,zoompan=z='1+9*pow(max(0,(on-52.5)/66.5),2.2)':x='iw*0.5-iw/zoom/2':y='max(0,min(ih-ih/zoom,ih*0.70-ih/zoom/2))':d=1:s=1280x720:fps=30,fade=t=in:st=0:d=0.5,fade=t=out:st=3.8:d=0.1,hue=s=0,setsar=1"
 run(['-loop','1','-framerate','30','-i',str(ASSETS/'warning_sign_bullet_holes.png'),'-vf',vf,'-frames:v','120']+enc(),'warning_slow.mkv',120)
 run(['-f','lavfi','-i','color=black:s=1280x720:r=30:d=1.5','-frames:v','45']+enc(),'black_hold.mkv',45)

def make_title_motion():
 title=Image.open(ASSETS/'approved_title.png').convert('L').resize((1056,384),Image.Resampling.NEAREST)
 src=np.asarray(title).copy(); rng=np.random.default_rng(220926)
 cells=[];size=6
 for y in range(0,384,size):
  for x in range(0,1056,size):
   patch=src[y:y+size,x:x+size]
   if patch.max()>12:
    # Mix local clusters and individual grains; all settle into original pixels.
    start=float(rng.uniform(0,6.6));duration=float(rng.uniform(.8,1.4))
    if rng.random()<.055:start=6.65;duration=1.35
    dx=int(rng.integers(-70,71));dy=int(rng.integers(-45,46))
    cells.append((x,y,patch,start,duration,dx,dy))
 temp=ROOT/'title_motion.rendering.mkv';log=open(ROOT/'title_motion.log','wb')
 p=subprocess.Popen(['ffmpeg','-nostdin','-xerror','-v','warning','-f','rawvideo','-pix_fmt','gray','-s','1280x720','-r','30','-i','-',
       '-frames:v','960','-an','-c:v','ffv1','-level','3','-threads','2','-y',str(temp)],stdin=subprocess.PIPE,stderr=log)
 settled_counts=[];hover=[]
 for n in range(960):
  t=n/FPS; canvas=np.zeros((720,1280),np.uint8)
  if n>=240:
   u=t-8
   # Suspended, continuously oscillating float: tiny travel, much quicker cadence.
   off=round(2.2*math.sin(2*math.pi*u/1.35)+.55*math.sin(2*math.pi*u/.43))
   canvas[79+off:79+off+384,112:1168]=src;hover.append(off)
  else:
   settled=0
   for x,y,patch,start,duration,dx,dy in cells:
    if t<start:continue
    q=min(1,(t-start)/duration);e=1-(1-q)**3
    xx=112+x+round(dx*(1-e));yy=79+y+round(dy*(1-e))
    alpha=q
    if q>=1:settled+=1
    hh,ww=patch.shape
    tile=patch if alpha>=1 else (patch*alpha).astype(np.uint8)
    canvas[yy:yy+hh,xx:xx+ww]=np.maximum(canvas[yy:yy+hh,xx:xx+ww],tile)
   settled_counts.append(settled)
  if n in [0,30,90,150,210,239,240,250,260]:Image.fromarray(canvas).save(ROOT/'qa'/f'title_{n:03d}.png')
  p.stdin.write(canvas.tobytes())
 p.stdin.close();assert p.wait()==0;log.close();frames(temp,960);os.replace(temp,ROOT/'title_motion.mkv')
 (ROOT/'title_motion_evidence.json').write_text(json.dumps({'cells':len(cells),'settled_cells':settled_counts,'hover_offsets':hover,
      'full_title_frame_local':240,'full_title_frame_absolute':630,'original_sha256':hashlib.sha256((ASSETS/'approved_title.png').read_bytes()).hexdigest()},indent=2))
 print('READY title_motion.mkv',flush=True)

def make_action(indices=None):
 for i,(name,start,count,rect,label) in enumerate(SHOTS):
  if indices is not None and i not in indices:continue
  x,y,w,h=rect;num=count+(4 if i<len(SHOTS)-1 else 0)
  vf=f"setpts=PTS-STARTPTS,crop={w}:{h}:{x}+2*sin(t*0.8):{y}+sin(t*0.7),scale=1280:720:flags=neighbor,fps=30,setpts=N/(30*TB),setsar=1"
  run(['-ss',str(start),'-i',str(SOURCES[name]),'-vf',vf,'-frames:v',str(num)]+enc(),f'action_{i:02d}.mkv',num)
 args=[];graph=[]
 for i in range(len(SHOTS)):
  args+=['-i',str(ROOT/f'action_{i:02d}.mkv')]
  graph.append(f'[{i}:v]fps=30,settb=AVTB,setpts=PTS-STARTPTS,format=yuv420p[s{i}]')
 prev='s0';offset=0
 for i in range(1,len(SHOTS)):
  offset+=SHOTS[i-1][2]/FPS
  graph.append(f'[{prev}][s{i}]xfade=transition=fade:duration=0.1333333333:offset={offset}[x{i}]');prev=f'x{i}'
 graph.append(f'[{prev}]fps=30,setpts=N/(30*TB)[out]')
 (ROOT/'action.ffgraph').write_text(';\n'.join(graph))
 run(['-filter_complex_threads','2']+args+['-filter_complex_script',str(ROOT/'action.ffgraph'),'-map','[out]','-frames:v','720']+enc(),'action_montage.mkv',720)

def compose_main():
 font='/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
 graph=[
  '[0:v]fps=30,setpts=N/(30*TB),hue=s=0,eq=contrast=1.12:brightness=-0.008:gamma=0.99,colorchannelmixer=rr=0.64:gg=0.64:bb=0.64,vignette=angle=PI/5,noise=alls=1.1:allf=t,fade=t=in:st=0:d=0.6,tpad=start_duration=8:start_mode=add:color=black,format=gbrp[footage]',
  '[1:v]fps=30,setpts=N/(30*TB),format=gbrp[title]',
  '[footage][title]blend=all_mode=screen,format=rgb24[brand]',
  '[2:v]format=rgba,fade=t=in:st=8:d=0.6:alpha=1[camera]',
  '[brand][camera]overlay=0:0:format=auto,fps=30,setpts=N/(30*TB)[timed]',
  "[timed][3:v]overlay=0:0:format=auto:enable='gte(t,14)'[button]",
  "[button]drawtext=fontfile="+font+":text='%{pts\\:hms}':fontsize=13:fontcolor=white@0.5:x=1078:y=67:enable='gte(t,8.6)',drawbox=x=1106:y=49:w=5:h=5:color=white@0.65:t=fill:enable='gte(t,8.6)*lt(mod(t,2),1)'[clock]",
 ]
 prev='clock';offset=8
 for i,s in enumerate(SHOTS):
  end=offset+s[2]/FPS;sector={'bridge':'RIVER CROSSING','estate':'WHITTAKER ESTATE','harold':'HAROLD APARTMENTS'}[s[0]]
  graph.append(f"[{prev}]drawtext=fontfile={font}:text='{sector}':fontsize=12:fontcolor=white@0.42:x=50:y=631:enable='between(t,{offset+.15},{end})'[sector{i}]")
  prev=f'sector{i}';offset=end
 # Sparse brief interference; hover remains continuous underneath.
 for j,t in enumerate([18.4,27.6]):
  graph.append(f"[{prev}]drawbox=x=170:y={265+j*28}:w=900:h=2:color=white@0.22:t=fill:enable='between(t,{t},{t+.067})'[static{j}]");prev=f'static{j}'
 graph.append(f"[{prev}]drawbox=x=489:y=575:w=303:h=55:color=white@0.23:t=2:enable='between(t,31.15,31.6)',fade=t=out:st=31.7:d=0.3,format=yuv420p,hue=s=0[v]")
 (ROOT/'main.ffgraph').write_text(';\n'.join(graph))
 run(['-filter_complex_threads','2','-i',str(ROOT/'action_montage.mkv'),'-i',str(ROOT/'title_motion.mkv'),
      '-loop','1','-framerate','30','-i',str(ASSETS/'camera_ui.png'),'-loop','1','-framerate','30','-i',str(ASSETS/'button_ui.png'),
      '-filter_complex_script',str(ROOT/'main.ffgraph'),'-map','[v]','-frames:v','960']+enc(),'main_revision3.mkv',960)

def export():
 parts=[((ASSETS/'startup_gloria.mkv') if (ASSETS/'startup_gloria.mkv').exists() else ROOT/'startup_gloria.mkv',105),((ASSETS/'startup_godot.mkv') if (ASSETS/'startup_godot.mkv').exists() else ROOT/'startup_godot.mkv',120),(ROOT/'warning_slow.mkv',120),
        (ROOT/'black_hold.mkv',45),(ROOT/'main_revision3.mkv',960),(ROOT/'sandbox_smaller.mkv',360)]
 for path,num in parts:frames(path,num)
 (ROOT/'parts.txt').write_text(''.join(f"file '{path.as_posix()}'\n" for path,_ in parts))
 run(['-f','concat','-safe','0','-i',str(ROOT/'parts.txt'),'-i',str(ASSETS/'B-22_Dead_Street.mp3'),'-map','0:v:0','-map','1:a:0',
      '-vf','fps=30,setpts=N/(30*TB)','-frames:v','1710','-t','57','-c:v','libx264','-preset','medium','-crf','19','-profile:v','high','-pix_fmt','yuv420p','-threads','3',
      '-af','atrim=0:57,asetpts=PTS-STARTPTS,volume=-4dB,afade=t=in:st=0:d=0.03,afade=t=out:st=55.7:d=1.3',
      '-c:a','aac','-b:a','160k','-metadata','title=Dead Street — Opening Preview','-metadata','artist=B-22',
      '-metadata','comment=Godot logo copyright 2017 Andrea Calabro, CC BY 4.0 https://creativecommons.org/licenses/by/4.0/ ; https://godotengine.org/press/ ; Music UI is a design preview.',
      '-movflags','+faststart'],'Dead_Street_Opening_Preview.mp4',1710)
 (ROOT/'manifest.json').write_text(json.dumps({'timeline':TIMELINE,'shots':SHOTS,'duration':57,'frames':1710,
      'harold_library_id':'libfile_8999c66a893c8191b89b904c99decbbd','source_hashes':{k:hashlib.sha256(p.read_bytes()).hexdigest() for k,p in SOURCES.items()},
      'status':'Revised video preview, no native controller integration','title_source_sha256':hashlib.sha256((ASSETS/'approved_title.png').read_bytes()).hexdigest()},indent=2))

if __name__=='__main__':
 phase=sys.argv[1] if len(sys.argv)>1 else 'all'
 if phase in ['all','warning']:make_warning()
 if phase in ['all','title']:make_title_motion()
 if phase in ['all','action']:make_action()
 if phase=='action-recut':make_action([1,5,9])
 if phase in ['all','main']:compose_main()
 if phase in ['all','export']:export()
