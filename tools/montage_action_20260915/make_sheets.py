from pathlib import Path
import subprocess,json,concurrent.futures
from PIL import Image,ImageDraw
import imageio_ffmpeg
r=Path(__file__).resolve().parents[2];d=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
sources=json.loads((d/'sources.json').read_text());times=json.loads((d/'times.json').read_text())
def make(name):
 sheet=Image.new('RGB',(1920,900))
 for i,t in enumerate(times[name]):
  out=d/(name+'_'+str(i)+'.jpg')
  subprocess.run([ff,'-nostdin','-v','error','-ss',str(t),'-i',str(r/sources[name]),'-frames:v','1','-vf','scale=480:270','-y',str(out)],check=True,capture_output=True)
  im=Image.open(out);sheet.paste(im,((i%4)*480,(i//4)*300))
  ImageDraw.Draw(sheet).text(((i%4)*480+8,(i//4)*300+276),name+' '+str(t)+'s',fill='white')
 sheet.save(d/(name+'_sheet.jpg'),quality=90)
 return name
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
 for result in pool.map(make,sources):print('SHEET',result,flush=True)
