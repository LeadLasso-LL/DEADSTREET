from pathlib import Path
import subprocess,json,concurrent.futures
from PIL import Image,ImageDraw
import imageio_ffmpeg
r=Path(__file__).resolve().parents[2];d=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
sources=json.loads((d/'sources.json').read_text());shots=json.loads((d/'shots_candidate.json').read_text())
def make(i):
 name,start,count,rect,label=shots[i];x,y,w,h=rect
 ims=[]
 for j in range(6):
  t=start+j*(count-1)/150.
  out=d/('candidate_%02d_%d.jpg'%(i,j))
  subprocess.run([ff,'-nostdin','-v','error','-ss',str(t),'-i',str(r/sources[name]),'-frames:v','1','-vf',f'crop={w}:{h}:{x}:{y},scale=320:180:flags=neighbor','-y',str(out)],check=True,capture_output=True)
  im=Image.open(out).convert('RGB');ImageDraw.Draw(im).text((4,4),f'{i} {name} {t:.2f}s',fill='white',stroke_width=1,stroke_fill='black');ims.append(im)
 return i,ims
sheets=[Image.new('RGB',(1920,720)) for _ in range(3)]
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 for i,ims in pool.map(make,range(len(shots))):
  for j,im in enumerate(ims):sheets[i//4].paste(im,(j*320,(i%4)*180))
for i,sheet in enumerate(sheets):sheet.save(d/f'candidates_{i}.jpg',quality=93)
print('CANDIDATES_READY',flush=True)
