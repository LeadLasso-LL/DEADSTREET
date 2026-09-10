"""Encode the native Godot capture and extract review frames (no frame-rate conversion)."""
from pathlib import Path
import hashlib,json,subprocess
import imageio_ffmpeg
R=Path(__file__).parent/'results';ff=imageio_ffmpeg.get_ffmpeg_exe()
src=R/'harold_4v4_raw.avi';out=R/'Dead_Street_Harold_4v4.mp4'
# Remove the two startup frames before the recording scenario is ready.
subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-ss',str(2/30),'-i',str(src),
 '-c:v','libx264','-preset','slow','-crf','18','-pix_fmt','yuv420p',
 '-c:a','aac','-b:a','128k','-movflags','+faststart',str(out)],check=True)
for label,t in [('opening',0),('early',6),('middle',12),('late',20),('aftermath',25.5)]:
 subprocess.run([ff,'-hide_banner','-loglevel','error','-y','-ss',str(t),'-i',str(out),'-frames:v','1',str(R/('video_'+label+'.png'))],check=True)
subprocess.run([ff,'-hide_banner','-loglevel','error','-i',str(out),'-f','null','-'],check=True)
info=subprocess.run([ff,'-hide_banner','-i',str(out)],capture_output=True,text=True).stderr
(R/'video_info.txt').write_text(info)
data=dict(filename=out.name,bytes=out.stat().st_size,sha256=hashlib.sha256(out.read_bytes()).hexdigest())
(R/'video_integrity.json').write_text(json.dumps(data,indent=2));print(json.dumps(data));print(info)
