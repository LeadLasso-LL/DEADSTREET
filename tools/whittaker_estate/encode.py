"""Mobile export: full decode gate, fixed frame rate, front-loaded MP4 index, <8 MB."""
from pathlib import Path
import subprocess,json,hashlib,re,base64
import numpy as np
import imageio_ffmpeg
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate';ff=imageio_ffmpeg.get_ffmpeg_exe()
record=json.loads((out/'record.json').read_text(encoding='utf-8'))
assert record['phase']=='resolved' and record['winner']=='defender',record.get('winner')
assert not record['arrival_route_errors'] and not record['outro_errors']
assert all(x['matches'] for x in record['hud_weapon_models'])
trim=record['trim_frames']/30;raw=out/'estate_raw.avi'
assert raw.exists()
meta=subprocess.run([ff,'-hide_banner','-i',str(raw)],capture_output=True,text=True).stderr
m=re.search(r'Duration: (\d+):(\d+):([\d.]+)',meta);assert m and 'Audio:' in meta,meta
duration=int(m[1])*3600+int(m[2])*60+float(m[3])-trim
assert abs(duration-record['seconds'])<.25,(duration,record['seconds'])
video_rate=int((7_550_000*8/duration)-80_000-12_000)
assert video_rate>200_000,(duration,video_rate)
base=[ff,'-y','-v','warning','-ss',str(trim),'-i',str(raw),'-t',str(duration),'-map','0:v:0','-map','0:a:0','-vf',f'scale=1280:720:flags=lanczos,setsar=1,fade=t=in:st=0:d=0.25,fade=t=out:st={duration-.8}:d=0.8','-c:v','libx264','-preset','medium','-b:v',str(video_rate),'-pix_fmt','yuv420p','-profile:v','high','-r','30','-g','60','-passlogfile',str(out/'estate_mobile_pass')]
subprocess.run(base+['-pass','1','-an','-f','null','NUL'],check=True,timeout=180)
final=out/'Dead_Street_Whittaker_Estate_Mobile.mp4'
subprocess.run(base+['-pass','2','-af',f'afade=t=in:st=0:d=0.25,afade=t=out:st={duration-.8}:d=0.8','-c:a','aac','-b:a','80k','-movflags','+faststart',str(final)],check=True,timeout=180)
assert final.stat().st_size<8_000_000,final.stat().st_size
subprocess.run([ff,'-v','error','-i',str(final),'-f','null','NUL'],check=True,timeout=120)
audio=subprocess.run([ff,'-v','error','-i',str(final),'-vn','-ac','1','-ar','22050','-f','f32le','-'],capture_output=True,check=True).stdout
a=np.frombuffer(audio,dtype='<f4');assert len(a)>duration*22050*.99 and np.isfinite(a).all()
assert .005<float(np.max(np.abs(a)))<=1.0
summary={'file':str(final),'bytes':final.stat().st_size,'sha256':hashlib.sha256(final.read_bytes()).hexdigest(),'seconds':duration,'video_bitrate':video_rate,'decoded_to_end':True,'winner':record['winner']}
(out/'delivery.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('MOBILE_EXPORT',json.dumps(summary),flush=True)

data=final.read_bytes();folder=out/'transfer';folder.mkdir(exist_ok=True);parts=[]
for i,start in enumerate(range(0,len(data),1950000)):
 chunk=data[start:start+1950000];name='part_%03d.txt'%i;(folder/name).write_text(base64.b64encode(chunk).decode(),encoding='utf-8');parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
summary['parts']=parts;summary['audio_peak']=float(np.max(np.abs(a)));summary['audio_rms']=float(np.sqrt(np.mean(a*a)));summary['record']={'winner':record['winner'],'seed':record['seed'],'combat_seconds':record['combat_seconds'],'results':record['result_summaries'],'victory_audio':record['victory_audio_samples'],'commands':record['commands']}
(out/'transfer.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('TRANSFER_READY',json.dumps({k:v for k,v in summary.items() if k!='record'}),flush=True)
