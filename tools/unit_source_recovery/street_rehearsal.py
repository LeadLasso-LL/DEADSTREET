"""Scripted scenery/animation review only. No AI, damage or live game binding."""
import math,json,subprocess
from pathlib import Path
from PIL import Image,ImageDraw
import render
R=Path(__file__).parent;scene=R/'street_scene'
manifest=json.loads((scene/'scene_manifest.json').read_text())
objects=[o for o in manifest['objects'] if not o['id'].startswith('unit_')]
assets={o['id']:Image.open(scene/o['image']).convert('RGBA') for o in objects}
ground=Image.open(scene/'assets/ground.png').convert('RGB')
run_root=R/'stage_support/run';combat_root=R/'stage_support/combat';combat_map=json.loads((combat_root/'frames.json').read_text())
actors=[{'k':0,'w':'uzi_smg','start':[5,12],'end':[8.7,16.45],'face':'S'}, {'k':1,'w':'ak_rifle','start':[24,8],'end':[20.5,8.1],'face':'SW'}, {'k':2,'w':'pistol','start':[27.5,18],'end':[28,20.05],'face':'SW'}]
def project(p):return (42+28*p[0],96+28*p[1]*math.sin(math.radians(50)))
def frame(t):
 im=ground.copy();drawables=[(o['depth_key'],assets[o['id']],o['screen_top_left']) for o in objects]
 for a in actors:
  k,w=a['k'],a['w'];pos=a['end'].copy();d=a['face']
  if t<2:
   u=render.smooth(t/2);pos=[x+(y-x)*u for x,y in zip(a['start'],a['end'])]
   dx=a['end'][0]-a['start'][0];dz=a['end'][1]-a['start'][1];d=render.directions.NAMES[round(math.atan2(dz,dx)/(math.pi/4))%8]
   distance=math.dist(project(a['start']),project(pos));i=int(distance/28.6*24)%24;p=run_root/'frames'/str(k)/w/d/f'{i:02}.png'
  elif t<4.5:
   c='cover_over';i=min(39,int((t-2)*16));p=render.OUT/(render.generate(k,w,d,c,i)[0]+'.png')
  elif t<7:
   c='reload';i=min(39,int((t-4.5)*16));p=render.OUT/(render.generate(k,w,d,c,i)[0]+'.png')
  elif t<9:
   i=min(63,36+int((t-7)*20));p=combat_root/'rendered'/(combat_map[f'{k}/{w}/{d}/{i}']+'.png')
  else:
   c=['cover_edge','injured_run','death'][k];i=min(render.CLIPS[c]-1,int((t-9)*16)) if k==2 else int((t-9)*16)%render.CLIPS[c]
   if k==1:pos[0]-=min(3,(t-9)*.8);d='W'
   p=render.OUT/(render.generate(k,w,d,c,i)[0]+'.png')
  with Image.open(p) as sp:sp=sp.convert('RGBA').resize((83,83),Image.Resampling.NEAREST)
  x,y=project(pos);drawables.append((pos[1],sp,[round(x-64*.65),round(y-110*.65)]))
 for _,sprite,xy in sorted(drawables,key=lambda item:item[0]):im.paste(sprite,tuple(xy),sprite)
 dr=ImageDraw.Draw(im);dr.rectangle((0,0,1000,31),fill='#202727');label='MOVE TO POSITION' if t<2 else 'COVER' if t<4.5 else 'RELOAD' if t<7 else 'FIRE' if t<9 else 'REACTIONS / CASUALTY'
 dr.text((12,10),'DEAD STREET / SCRIPTED ANIMATION REHEARSAL / '+label,fill='#eeeee2')
 dr.rectangle((0,652,1000,680),fill='#202727');dr.text((12,661),'Visual preview only / live tactical simulation is not connected.',fill='#c5ccc2')
 return im
if __name__=='__main__':
 pipe=subprocess.Popen(['ffmpeg','-y','-f','rawvideo','-pix_fmt','rgb24','-s','1000x680','-r','16','-i','-','-an','-c:v','libx264','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(R/'street_rehearsal.mp4')],stdin=subprocess.PIPE,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 for i in range(208):pipe.stdin.write(frame(i/16).tobytes())
 pipe.stdin.close();assert pipe.wait()==0
 frame(3.55).save(R/'street_rehearsal.png');print('Scripted street rehearsal exported; no live game test claimed.')
