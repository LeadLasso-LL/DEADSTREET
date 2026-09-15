from pathlib import Path
import base64,json,hashlib,subprocess
import imageio_ffmpeg
p=Path(r'C:\Users\brand\OneDrive\Documents\dead-street\tools\caution_impacts_20260915');data=(p/'DEAD_STREET_Revised_Intro.mp4').read_bytes();d=p/'transfer';d.mkdir(exist_ok=True)
parts=[]
for i,start in enumerate(range(0,len(data),600000)):
 chunk=data[start:start+600000];name=f'part_{i:03d}.txt';(d/name).write_text(base64.b64encode(chunk).decode(),encoding='ascii');parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
(p/'transfer.json').write_text(json.dumps(parts,indent=2));print(json.dumps({'parts':len(parts),'bytes':len(data)}))
for at,name in [(2,'encoded_gloria'),(5,'encoded_godot'),(7.4,'encoded_clean'),(10,'encoded_shot'),(13,'encoded_black'),(23,'encoded_title'),(32,'encoded_sandbox')]:
 subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-y','-v','error','-ss',str(at),'-i',str(p/'DEAD_STREET_Revised_Intro.mp4'),'-frames:v','1',str(p/(name+'.png'))],check=True)