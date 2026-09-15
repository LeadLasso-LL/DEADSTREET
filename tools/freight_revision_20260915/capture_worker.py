from pathlib import Path
import subprocess,json,time,hashlib,base64
import imageio_ffmpeg,numpy as np
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
rehearsal=json.loads((o/'rehearsal.json').read_text(encoding='utf-8'))
assert rehearsal['winner']=='attacker' and not rehearsal['errors'] and not rehearsal['arrival_errors'] and not rehearsal['outro_errors'] and rehearsal['camera_violations']==0,rehearsal
raw=o/'eastex_battle_raw.avi';assert not raw.exists(),'Preserve previous recording'
paths=[p for folder in ['battle','campaign','core','gameplay'] for p in (r/folder).rglob('*.gd')]+[o/'showcase.gd',r/'assets/art/freight_exchange/ground.png']
hashes={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(o/'capture_source_hashes.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
args=[r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--path',str(r),'--resolution','1280x720','--position','0,0','--fixed-fps','30','--disable-vsync','--write-movie',str(raw),'--log-file',str(o/'capture_godot.log'),'--script','res://tools/freight_revision_20260915/showcase.gd','--','--record']
(o/'capture_command.json').write_text(json.dumps(args,indent=2))
with (o/'capture.log').open('wb') as log:
 p=subprocess.Popen(args,cwd=r,stdout=log,stderr=subprocess.STDOUT);print('CAPTURE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  s=(o/'capture.log').read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in s or time.monotonic()-start>600:
   p.kill();p.wait();raise RuntimeError('Owned capture failed: '+s[-3000:])
assert p.returncode==0,p.returncode
changed=[name for name,digest in hashes.items() if hashlib.sha256((r/name).read_bytes()).hexdigest()!=digest]
assert not changed,changed
record=json.loads((o/'record.json').read_text());assert record['winner']=='attacker' and not record['errors'] and not record['arrival_errors'] and not record['outro_errors'] and record['camera_violations']==0,record
print('CAPTURE_PASSED',json.dumps({k:record[k] for k in ['winner','survivors','combat_seconds','seconds']}),flush=True)
trim=record['trim_frames']/30.;duration=record['seconds']
final=o/'DEAD_STREET_Eastex_Freight_Exchange_Battle.mp4'
subprocess.run([ff,'-y','-v','warning','-ss',str(trim),'-i',str(raw),'-t',str(duration),'-map','0:v:0','-map','0:a:0','-vf','scale=1280:720:flags=lanczos,setsar=1','-c:v','libx264','-preset','medium','-crf','25','-pix_fmt','yuv420p','-profile:v','high','-r','30','-c:a','aac','-b:a','128k','-movflags','+faststart',str(final)],check=True,timeout=240)
subprocess.run([ff,'-v','error','-i',str(final),'-f','null','NUL'],check=True,timeout=120)
audio=subprocess.run([ff,'-v','error','-i',str(final),'-vn','-ac','2','-ar','22050','-f','f32le','-'],capture_output=True,check=True).stdout
a=np.frombuffer(audio,dtype='<f4');assert len(a)>duration*22050*2*.98 and np.isfinite(a).all() and .005<float(np.max(abs(a)))<=1.
for seconds,name in [(7,'arrival'),(30,'combat'),(max(0,duration-3),'results')]:
 subprocess.run([ff,'-y','-v','error','-ss',str(seconds),'-i',str(final),'-frames:v','1',str(o/('encoded_'+name+'.png'))],check=True,timeout=30)
data=final.read_bytes();folder=o/'transfer';folder.mkdir(exist_ok=True);parts=[]
for i,start in enumerate(range(0,len(data),1000000)):
 chunk=data[start:start+1000000];name='part_%03d.txt'%i;(folder/name).write_text(base64.b64encode(chunk).decode());parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
report={'file':str(final),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'seconds':duration,'width':1280,'height':720,'fps':30,'decoded_to_end':True,'audio_peak':float(np.max(abs(a))),'audio_rms':float(np.sqrt(np.mean(a*a))),'parts':parts}
(o/'delivery.json').write_text(json.dumps(report,indent=2));print('DELIVERY',json.dumps(report),flush=True)
