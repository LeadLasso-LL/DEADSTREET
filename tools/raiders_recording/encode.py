from pathlib import Path
import subprocess,json,re,hashlib,base64
import imageio_ffmpeg
import numpy as np
from PIL import Image,ImageOps,ImageDraw
r=Path(__file__).parent; ff=imageio_ffmpeg.get_ffmpeg_exe()
report=json.loads((r/'record.json').read_text());src=r/'raiders_raw.avi';out=r/'Dead_Street_Raiders_Victory.mp4'
assert report['phase']=='resolved' and report['winner']=='attacker', 'Recording must resolve in the requested Raiders victory'
assert not report['arrival_route_errors'],report['arrival_route_errors']
assert not report['outro_errors'],report['outro_errors']
def info(p):return subprocess.run([ff,'-hide_banner','-i',str(p)],capture_output=True,text=True).stderr
meta=info(src);m=re.search(r'Duration: (\d+):(\d+):([\d.]+)',meta);assert m,meta
seconds=int(m[1])*3600+int(m[2])*60+float(m[3]);trim=report['trim_frames']/30;length=seconds-trim
subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-ss',str(trim),'-i',str(src),'-vf',f'fade=t=in:st=0:d=0.25,fade=t=out:st={length-.8}:d=0.8', '-af',f'afade=t=in:st=0:d=0.25,afade=t=out:st={length-.8}:d=0.8','-c:v','libx264','-preset','fast','-crf','23','-pix_fmt','yuv420p','-c:a','aac','-b:a','128k','-movflags','+faststart',str(out)],check=True,timeout=240)
subprocess.run([ff,'-hide_banner','-loglevel','error','-i',str(out),'-f','null','-'],check=True,timeout=90)
raw=subprocess.run([ff,'-hide_banner','-loglevel','error','-i',str(out),'-vn','-ac','2','-ar','22050','-f','f32le','-'],capture_output=True,check=True).stdout
a=np.frombuffer(raw,dtype='<f4');assert np.isfinite(a).all() and len(a)>22050
peak=float(np.max(np.abs(a)));rms=float(np.sqrt(np.mean(a*a)));assert peak>.01 and peak<=1.0,(peak,rms)
images=[]
for name,t in [('Arrival',6.5),('Advance',20.),('Contact',38.),('Middle',length*.58),('Aftermath',length-11),('Results',length-3)]:
 p=r/(name.lower()+'_review.png');subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-ss',str(max(0,t)),'-i',str(out),'-frames:v','1',str(p)],check=True)
 im=Image.open(p).convert('RGB');im.thumbnail((768,432));tile=Image.new('RGB',(768,456),'#11191b');tile.paste(im,(0,24));ImageDraw.Draw(tile).text((12,5),name,fill='white');images.append(tile)
board=Image.new('RGB',(1536,1368),'#11191b')
for i,im in enumerate(images):board.paste(im,((i%2)*768,(i//2)*456))
board.save(r/'review.jpg',quality=88)
data=out.read_bytes();transfer=r/'transfer';transfer.mkdir(exist_ok=True);parts=[]
for i,start in enumerate(range(0,len(data),524288)):
 chunk=data[start:start+524288];name=f'part_{i:03}.txt';(transfer/name).write_text(base64.b64encode(chunk).decode());parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
manifest={'filename':out.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'parts':parts,'seconds':length,'peak_dbfs':20*np.log10(peak),'rms_dbfs':20*np.log10(rms)}
(r/'video.json').write_text(json.dumps(manifest,indent=2));print('VIDEO_READY '+json.dumps(manifest),flush=True)
