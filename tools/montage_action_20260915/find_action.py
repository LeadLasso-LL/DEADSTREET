from pathlib import Path
import subprocess,json,numpy as np
from PIL import Image,ImageDraw
import imageio_ffmpeg
r=Path(__file__).resolve().parents[2];d=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe();sources=json.loads((d/'sources.json').read_text())
reports={}
for name,start,seconds in [('freight',26,48),('estate',30,27)]:
 p=subprocess.Popen([ff,'-nostdin','-v','error','-ss',str(start),'-i',str(r/sources[name]),'-t',str(seconds),'-vf','scale=960:540:flags=neighbor','-pix_fmt','rgb24','-f','rawvideo','-'],stdout=subprocess.PIPE)
 prev=None;n=0;events=[]
 while True:
  raw=p.stdout.read(960*540*3)
  if len(raw)<960*540*3:break
  a=np.frombuffer(raw,dtype=np.uint8).reshape(540,960,3)
  mask=(a[:,:,0]>225)&(a[:,:,1]>145)&(a[:,:,2]<180)
  mask[:85]=False;mask[385:]=False
  new=mask if prev is None else mask&~prev
  count=int(new.sum())
  if count>=2:
   yy,xx=np.where(new);events.append({'t':round(start+n/30.,3),'count':count,'x':int(np.median(xx)),'y':int(np.median(yy))})
  prev=mask;n+=1
 p.wait()
 picks=[]
 for event in sorted(events,key=lambda x:x['count'],reverse=True):
  if all(abs(event['t']-z['t'])>1.8 for z in picks):picks.append(event)
  if len(picks)>=12:break
 picks.sort(key=lambda x:x['t']);reports[name]=picks
 sheet=Image.new('RGB',(1920,900))
 for i,event in enumerate(picks):
  path=d/(name+'_flash_%02d.jpg'%i)
  subprocess.run([ff,'-nostdin','-v','error','-ss',str(event['t']),'-i',str(r/sources[name]),'-frames:v','1','-vf','scale=480:270','-y',str(path)],capture_output=True,check=True)
  sheet.paste(Image.open(path),((i%4)*480,(i//4)*300))
  ImageDraw.Draw(sheet).text(((i%4)*480+8,(i//4)*300+276),str(event),fill='white')
 sheet.save(d/(name+'_flashes.jpg'),quality=94)
(d/'flash_events.json').write_text(json.dumps(reports,indent=2));print(json.dumps(reports),flush=True)
