"""Encode the native Godot capture, inspect audio, and extract review frames."""
from pathlib import Path
import hashlib,json,subprocess,re
import imageio_ffmpeg
import numpy as np
R=Path(__file__).parent/'results';ff=imageio_ffmpeg.get_ffmpeg_exe()
src=R/'harold_4v4_raw.avi';out=R/'Dead_Street_Harold_Battle_Finish.mp4'
def info(path):return subprocess.run([ff,'-hide_banner','-i',str(path)],capture_output=True,text=True).stderr
def duration(text):
 m=re.search(r'Duration: (\d+):(\d+):([\d.]+)',text)
 if not m:raise RuntimeError('Missing media duration')
 return int(m[1])*3600+int(m[2])*60+float(m[3])
# Two startup frames precede scenario setup; retain every frame of the arrival.
trim=2/30;length=duration(info(src))-trim;fade=max(0,length-.75)
subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-ss',str(trim),'-i',str(src),
 '-vf',f'pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fade=t=in:st=0:d=0.2,fade=t=out:st={fade}:d=0.75',
 '-af',f'afade=t=in:st=0:d=0.2,afade=t=out:st={fade}:d=0.75',
 '-c:v','libx264','-preset','slow','-crf','18','-pix_fmt','yuv420p',
 '-c:a','aac','-b:a','160k','-movflags','+faststart',str(out)],check=True)
for label,t in [('opening',.6),('arrival',5.7),('deployment',9),('combat',16),('middle',length*.55),('aftermath',length-9),('results',length-4)]:
 subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-ss',str(t),'-i',str(out),'-frames:v','1',str(R/('video_'+label+'.png'))],check=True)
subprocess.run([ff,'-hide_banner','-loglevel','error','-i',str(out),'-f','null','-'],check=True)
metadata=info(out);(R/'video_info.txt').write_text(metadata)
raw=subprocess.run([ff,'-hide_banner','-loglevel','error','-i',str(out),'-vn','-ac','2','-ar','48000','-f','f32le','-'],capture_output=True,check=True).stdout
a=np.frombuffer(raw,dtype='<f4').reshape(-1,2)
assert len(a)>48000 and np.isfinite(a).all(),'Missing or invalid audio'
peak=float(np.max(abs(a)));rms=float(np.sqrt(np.mean(a*a)))
assert peak>0.01 and peak<1,'Silent or clipped mix'
audio={'peak_dbfs':float(20*np.log10(peak)),'rms_dbfs':float(20*np.log10(rms)),'seconds':len(a)/48000,'channels':2,'one_second_rms_dbfs':[float(20*np.log10(max(1e-9,np.sqrt(np.mean(a[i:i+48000]**2))))) for i in range(0,len(a),48000)]}
(R/'audio_mix_validation.json').write_text(json.dumps(audio,indent=2))
data=dict(filename=out.name,bytes=out.stat().st_size,sha256=hashlib.sha256(out.read_bytes()).hexdigest(),duration_seconds=length,audio_peak_dbfs=audio['peak_dbfs'])
(R/'video_integrity.json').write_text(json.dumps(data,indent=2));print(json.dumps(data));print(metadata)
