from pathlib import Path
import subprocess,json,hashlib,re,base64
import numpy as np
import imageio_ffmpeg
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_finish_20260915';ff=imageio_ffmpeg.get_ffmpeg_exe()
record=json.loads((o/'record.json').read_text(encoding='utf-8'))
assert record['phase']=='resolved' and not record['errors'] and not record['arrival_errors'] and not record['outro_errors'] and record['camera_violations']==0
for rows in record['results'].values():
 dead=False
 for row in rows:
  if row['state']=='DEAD':dead=True
  else:assert not dead,'Survivor below casualty'
assert sorted(v['count'] for v in record['manifest'])==[3,4]
raw=o/'yard_revision_raw.avi';trim=record['trim_frames']/30
meta=subprocess.run([ff,'-hide_banner','-i',str(raw)],capture_output=True,text=True).stderr
(o/'raw_metadata.txt').write_text(meta,encoding='utf-8')
m=re.search(r'Duration: (\d+):(\d+):([\d.]+)',meta);assert m and 'Audio:' in meta,meta
duration=int(m[1])*3600+int(m[2])*60+float(m[3])-trim
assert abs(duration-record['seconds'])<.25,(duration,record['seconds'])
rate=int(7_450_000*8/duration-80_000-12_000);assert rate>200_000
final=o/'DEAD_STREET_Ravicci_Raid_Final.mp4'
common=[ff,'-y','-v','warning','-ss',str(trim),'-i',str(raw),'-t',str(duration),'-map','0:v:0','-map','0:a:0','-vf',f'scale=1280:720:flags=lanczos,setsar=1,fade=t=in:st=0:d=0.25,fade=t=out:st={duration-.8}:d=0.8','-c:v','libx264','-preset','medium','-b:v',str(rate),'-pix_fmt','yuv420p','-profile:v','high','-r','30','-g','60','-passlogfile',str(o/'mobile_pass')]
subprocess.run(common+['-pass','1','-an','-f','null','NUL'],check=True,timeout=180)
subprocess.run(common+['-pass','2','-af',f'afade=t=in:st=0:d=0.25,afade=t=out:st={duration-.8}:d=0.8','-c:a','aac','-b:a','80k','-movflags','+faststart',str(final)],check=True,timeout=180)
assert final.stat().st_size<8_000_000
subprocess.run([ff,'-v','error','-i',str(final),'-f','null','NUL'],check=True,timeout=120)
audio=subprocess.run([ff,'-v','error','-i',str(final),'-vn','-ac','2','-ar','22050','-f','f32le','-'],capture_output=True,check=True).stdout
a=np.frombuffer(audio,dtype='<f4');assert len(a)>duration*22050*2*.99 and np.isfinite(a).all()
assert .005<float(np.max(np.abs(a)))<=1.0
for name,t in [('video_intro',3.),('video_approach',7.),('video_combat',(record['stages'].get('active',450)/30)+9.),('video_results',duration-3.)]:
 subprocess.run([ff,'-y','-v','error','-ss',str(t),'-i',str(final),'-frames:v','1',str(o/(name+'.png'))],check=True,timeout=30)
data=final.read_bytes();folder=o/'transfer';folder.mkdir(exist_ok=True);parts=[]
for i,start in enumerate(range(0,len(data),1_300_000)):
 chunk=data[start:start+1_300_000];name='part_%03d.txt'%i;(folder/name).write_text(base64.b64encode(chunk).decode(),encoding='utf-8');parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
summary={'file':str(final),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'seconds':duration,'width':1280,'height':720,'fps':30,'decoded_to_end':True,'audio_peak':float(np.max(np.abs(a))),'audio_rms':float(np.sqrt(np.mean(a*a))),'parts':parts,'winner':record['winner']}
(o/'delivery.json').write_text(json.dumps(summary,indent=2),encoding='utf-8');print('DELIVERY_READY',json.dumps(summary),flush=True)

