"""Reproducible first opening review; original title pixels and real gameplay only."""
from pathlib import Path
import subprocess, json, math, hashlib, concurrent.futures, os
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parent
TITLE=ROOT/'approved_title.png'
SOURCES={
 'estate':Path('/workspace/scratch/6a4bd31e258d/Dead_Street_Whittaker_Estate_Mobile.mp4'),
 'bridge':Path('/workspace/scratch/5f2238267ccd/Dead_Street_Raiders_Victory_Final_Mobile.mp4'),
} if (ROOT/'local_source_paths.json').exists() else {
 'estate':ROOT.parent.parent/'tools/whittaker_estate/Dead_Street_Whittaker_Estate_Mobile.mp4',
 'bridge':ROOT.parent.parent/'tools/raiders_recording/Dead_Street_Raiders_Victory_Mobile.mp4',
}
W,H,FPS=1280,720,30
# Output frame counts are exact. Crop rectangles exclude all gameplay panels.
SHOTS=[
 ('bridge',5.0,206,0.8,(55,140,990,557),'RIVER CROSSING','CONVOY'),
 ('estate',5.2,206,0.85,(175,140,900,506),'WHITTAKER ESTATE','APPROACH'),
 ('bridge',8.8,206,0.45,(240,265,690,388),'RIVER CROSSING','ARRIVAL'),
 ('estate',25.5,103,0.7,(260,125,630,354),'WHITTAKER ESTATE','GROUND MOVEMENT'),
 ('bridge',31.0,103,0.65,(310,113,605,340),'RIVER CROSSING','CONTACT'),
 ('estate',39.0,206,0.65,(235,128,600,337),'WHITTAKER ESTATE','CONTACT'),
 ('bridge',46.0,206,0.65,(490,113,610,343),'RIVER CROSSING','TRAFFIC BLOCKADE'),
 ('estate',52.0,206,0.65,(300,134,605,340),'WHITTAKER ESTATE','GROUND MOVEMENT'),
 ('bridge',59.0,206,0.6,(430,113,610,343),'RIVER CROSSING','CONTACT'),
 ('estate',14.0,152,0.65,(310,125,735,413),'WHITTAKER ESTATE','PERIMETER'),
]
TOTAL=sum(s[2] for s in SHOTS); DURATION=TOTAL/FPS
(ROOT/'shots_final').mkdir(exist_ok=True);(ROOT/'qa').mkdir(exist_ok=True)

def run(args,log):
 args=args[:1]+['-nostdin','-xerror']+args[1:]
 p=subprocess.run(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 (ROOT/log).write_bytes(p.stderr)
 if p.returncode:raise RuntimeError(p.stderr.decode(errors='replace')[-4000:])
 return p

def shot(i,s):
 name,start,frames,speed,rect,sector,action=s
 x,y,w,h=rect
 # A small optical tracking drift rides over the existing recorded camera.
 drift_x=f'{x}+5*sin(t*0.38)';drift_y=f'{y}+2*sin(t*0.49)'
 vf=f'setpts=(PTS-STARTPTS)/{speed},crop={w}:{h}:{drift_x}:{drift_y},scale={W}:{H}:flags=neighbor,setsar=1,fps={FPS}'
 out=ROOT/'shots_final'/f'{i:02d}.mkv'
 run(['ffmpeg','-v','warning','-threads','2','-ss',str(start),'-i',str(SOURCES[name]),'-vf',vf,'-frames:v',str(frames),'-an','-c:v','libx264','-preset','fast','-crf','16','-pix_fmt','yuv420p','-threads','2','-y',str(out)],f'shots_final/{i:02d}.log')
 run(['ffmpeg','-v','error','-ss',str(frames/FPS/2),'-i',str(out),'-frames:v','1','-vf','scale=480:270','-y',str(ROOT/'qa'/f'shot_{i:02d}.png')],f'shots_final/{i:02d}_still.log')
 return out

def make_ui():
 # Only procedural camera/button UI is drawn here; the approved title is a
 # separate, unchanged image input to FFmpeg's screen compositor.
 im=Image.new('RGBA',(W,H));d=ImageDraw.Draw(im)
 font='/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
 f=ImageFont.truetype(font,14);small=ImageFont.truetype(font,11)
 button=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf',20)
 gray=(188,193,195,150);dim=(145,151,154,95)
 for x,y,sx,sy in [(30,30,1,1),(1250,30,-1,1),(30,690,1,-1),(1250,690,-1,-1)]:
  d.line([(x+sx*36,y),(x,y),(x,y+sy*23)],fill=gray,width=1)
 d.text((50,44),'NBPD  /  AIR 07',font=f,fill=(210,214,216,185))
 d.text((50,66),'NEW BRIARPORT',font=small,fill=dim)
 d.text((1121,44),'REC',font=f,fill=(213,215,217,190))
 d.text((50,652),'EO  /  STABILIZED',font=small,fill=dim)
 d.line((640,454,640,463),fill=dim);d.line((640,485,640,494),fill=dim)
 d.line((620,474,629,474),fill=dim);d.line((651,474,660,474),fill=dim)
 # Open Sandbox is the only menu action in this preview.
 im.save(ROOT/'camera_ui.png')
 im=Image.new('RGBA',(W,H));d=ImageDraw.Draw(im)
 box=(489,575,791,629);d.rectangle(box,fill=(5,7,9,215),outline=(192,196,198,170),width=1)
 text='Open Sandbox';b=d.textbbox((0,0),text,font=button)
 d.text((640-(b[2]-b[0])/2,586),text,font=button,fill=(238,239,240,255))
 im.save(ROOT/'button_ui.png')

def compose():
 meta=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','json',str(ROOT/'montage_final.mkv')]))
 assert abs(float(meta['format']['duration'])-DURATION)<0.04, 'Montage does not contain all shots'
 make_ui()
 font='/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
 # The title's black backdrop is removed by screen blending in video, with no
 # redesign, image generation or destructive edit of the approved source.
 graph=[]
 graph.append('[0:v]format=yuv420p,hue=s=0,eq=contrast=1.08:brightness=-0.015:gamma=0.96,colorchannelmixer=rr=0.53:gg=0.53:bb=0.53,vignette=angle=PI/5,noise=alls=1.4:allf=t,format=gbrp[footage]')
 graph.append('[1:v]scale=1056:-1:flags=neighbor,format=rgb24[title]')
 graph.append(f'color=c=black:s={W}x{H}:r={FPS}:d={DURATION},format=rgb24[black]')
 graph.append("[black][title]overlay=x=112:y='79+3*sin(2*PI*t/8.6)':format=rgb:shortest=1,format=gbrp[titlefield]")
 graph.append('[footage][titlefield]blend=all_mode=screen[brand]')
 graph.append("[brand][2:v]overlay=0:0:format=auto,fps=30,setpts=N/(30*TB)[camera]")
 graph.append("[camera][3:v]overlay=0:0:format=auto:enable='gte(t,5)'[ui]")
 graph.append("[ui]drawtext=fontfile="+font+":text='%{pts\\:hms}':fontsize=13:fontcolor=white@0.53:x=1078:y=67,drawbox=x=1106:y=49:w=5:h=5:color=white@0.65:t=fill:enable='lt(mod(t,2),1)'[timed]")
 prev='timed';offset=0
 for i,s in enumerate(SHOTS):
  end=offset+s[2]/FPS
  graph.append(f"[{prev}]drawtext=fontfile={font}:text='{s[5]}':fontsize=12:fontcolor=white@0.40:x=50:y=631:enable='between(t,{offset:.6f},{end:.6f})'[sector{i}]")
  prev=f'sector{i}';offset=end
 # Three short, widely separated horizontal interference sweeps.
 for j,t in enumerate([13.733,34.333,48.067]):
  graph.append(f"[{prev}]drawbox=x=132:y={238+j*19}:w=1016:h=2:color=white@0.35:t=fill:enable='between(t,{t},{t+0.10})',drawbox=x=170:y={320-j*11}:w=900:h=5:color=black@0.75:t=fill:enable='between(t,{t+0.033},{t+0.133})'[glitch{j}]")
  prev=f'glitch{j}'
 graph.append(f'[{prev}]fade=t=out:st={DURATION-1.3}:d=1.3,format=yuv420p,hue=s=0[v]')

 (ROOT/'composition.ffgraph').write_text(';\n'.join(graph))
 out=ROOT/'main_menu.mkv'
 run(['ffmpeg','-v','warning','-filter_complex_threads','2','-i',str(ROOT/'montage_final.mkv'),'-loop','1','-framerate',str(FPS),'-i',str(TITLE),'-loop','1','-framerate',str(FPS),'-i',str(ROOT/'camera_ui.png'),'-loop','1','-framerate',str(FPS),'-i',str(ROOT/'button_ui.png'),'-filter_complex_script',str(ROOT/'composition.ffgraph'),'-map','[v]','-an','-frames:v',str(TOTAL),'-t',str(DURATION),'-c:v','libx264','-preset','medium','-crf','20','-profile:v','high','-pix_fmt','yuv420p','-threads','3','-metadata','title=Dead Street — Opening Preview','-metadata','artist=B-22','-y',str(out)],'compose.log')
 return out

if __name__=='__main__':
 import sys
 if '--compose-only' not in sys.argv:
  for i,s in enumerate(SHOTS):
   shot(i,s);print('SHOT_READY',i,flush=True)
  (ROOT/'shots.txt').write_text(''.join(f"file 'shots_final/{i:02d}.mkv'\n" for i in range(len(SHOTS))))
  run(['ffmpeg','-v','warning','-f','concat','-safe','0','-i',str(ROOT/'shots.txt'),'-c','copy','-y',str(ROOT/'montage_final.mkv')],'concat.log')
  ims=[]
  for i in range(len(SHOTS)):
   im=Image.open(ROOT/'qa'/f'shot_{i:02d}.png').convert('RGB');ImageDraw.Draw(im).text((7,7),f'{i}: {SHOTS[i][5]}',fill='yellow',stroke_width=2,stroke_fill='black');ims.append(im)
  sheet=Image.new('RGB',(1440,1080))
  for i,im in enumerate(ims):sheet.paste(im,((i%3)*480,(i//3)*270))
  sheet.save(ROOT/'qa'/'selected_shots.jpg')
  print('SHOT_ASSEMBLY_COMPLETE',flush=True)
  if '--shots-only' in sys.argv:sys.exit(0)
 result=compose()
 manifest={'preview':str(result),'frames':TOTAL,'seconds':DURATION,'title_sha256':hashlib.sha256(TITLE.read_bytes()).hexdigest(),'source_hashes':{k:hashlib.sha256(p.read_bytes()).hexdigest() for k,p in SOURCES.items()},'shots':SHOTS,'scope':'edited video review; not live menu integration','audio_credit':'Dead Street — B-22','audio_gain_db':-4}
 (ROOT/'edit_manifest.json').write_text(json.dumps(manifest,indent=2))
 print('MAIN_MENU_RENDERED',str(result),result.stat().st_size,flush=True)
