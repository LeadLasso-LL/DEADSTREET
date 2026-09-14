"""Create the smaller phone-sharing copy from the retained full-HD master."""
from pathlib import Path
import subprocess,json,hashlib,base64
import imageio_ffmpeg
r=Path(__file__).parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
src=r/'Dead_Street_Raiders_Victory.mp4';out=r/'Dead_Street_Raiders_Victory_Mobile.mp4'
subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-i',str(src),'-vf','scale=1280:720:flags=lanczos','-c:v','libx264','-preset','fast','-crf','25','-maxrate','2000k','-bufsize','4000k','-pix_fmt','yuv420p','-c:a','copy','-movflags','+faststart',str(out)],check=True,timeout=180)
subprocess.run([ff,'-hide_banner','-loglevel','error','-i',str(out),'-f','null','-'],check=True,timeout=60)
master=json.loads((r/'video.json').read_text());data=out.read_bytes();parts=[];folder=r/'transfer_mobile';folder.mkdir(exist_ok=True)
for i,start in enumerate(range(0,len(data),524288)):
 chunk=data[start:start+524288];name=f'part_{i:03}.txt';(folder/name).write_text(base64.b64encode(chunk).decode());parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
result={'filename':out.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'seconds':master['seconds'],'width':1280,'height':720,'fps':30,'master_sha256':master['sha256'],'audio':'AAC copied from verified master','parts':parts}
(r/'mobile.json').write_text(json.dumps(result,indent=2));print('MOBILE_READY',json.dumps({k:v for k,v in result.items()if k!='parts'}),flush=True)
