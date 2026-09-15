from pathlib import Path
import subprocess,json,numpy as np,imageio_ffmpeg
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/whittaker_estate';ff=imageio_ffmpeg.get_ffmpeg_exe()
for name in ['estate_raw.avi','Dead_Street_Whittaker_Estate_Mobile.mp4']:
 p=subprocess.run([ff,'-v','error','-i',str(o/name),'-vn','-ac','2','-ar','48000','-f','f32le','-'],capture_output=True,check=True)
 a=np.frombuffer(p.stdout,dtype='<f4');print(name,json.dumps({'peak':float(np.abs(a).max()),'rms':float(np.sqrt(np.mean(a*a))),'near_full_scale':int(np.count_nonzero(np.abs(a)>=.999)),'over_full_scale':int(np.count_nonzero(np.abs(a)>1.)),'samples':len(a)}),flush=True)
