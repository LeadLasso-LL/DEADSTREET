from pathlib import Path
import subprocess,json,time,hashlib,base64,re,zipfile
import imageio_ffmpeg,numpy as np
from PIL import Image
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe'

validation=json.loads((o/'validation.json').read_text());assert not validation['errors'],validation
frames=o/'lossless';frames.mkdir(exist_ok=False)
paths=[p for folder in ['battle','campaign','core','gameplay'] for p in (r/folder).rglob('*.gd')]+[o/'showcase.gd',r/'project.godot',r/'assets/art/street_detail/unit_finish.gdshader']
hashes={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
with zipfile.ZipFile(o/'capture_source_snapshot.zip','w',zipfile.ZIP_DEFLATED) as z:
 for p in paths:z.write(p,str(p.relative_to(r)))
(o/'capture_source_hashes.json').write_text(json.dumps(hashes,indent=2))
args=[godot,'--path',str(o/'capture_project'),'--resolution','1920x1080','--position','0,0','--fixed-fps','30','--disable-vsync','--write-movie',str(frames/'frame.png'),'--log-file',str(o/'capture_godot.log'),'--script','res://tools/freight_clarity_20260915/showcase.gd','--','--record']
(o/'capture_command.json').write_text(json.dumps(args,indent=2))
with (o/'capture.log').open('wb') as log:
 p=subprocess.Popen(args,cwd=r,stdout=log,stderr=subprocess.STDOUT);print('CAPTURE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  s=(o/'capture.log').read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in s or time.monotonic()-start>900:
   p.kill();p.wait();raise RuntimeError('Owned capture failed: '+s[-3000:])
assert p.returncode==0,p.returncode
changed=[name for name,digest in hashes.items() if hashlib.sha256((r/name).read_bytes()).hexdigest()!=digest]
(o/'capture_concurrent_changes.json').write_text(json.dumps(changed,indent=2))
record=json.loads((o/'record.json').read_text());assert record['winner']=='attacker' and not record['errors'] and not record['arrival_errors'] and not record['outro_errors'] and record['camera_violations']==0,record
print('CAPTURE_PASSED',json.dumps({k:record[k] for k in ['winner','survivors','combat_seconds','seconds']}),flush=True)
pngs=sorted(frames.glob('*.png'));wav=list(frames.glob('*.wav'));assert pngs and len(wav)==1
assert Image.open(pngs[0]).size==(1920,1080),Image.open(pngs[0]).size
m=re.fullmatch(r'(.*?)(\d+)\.png',pngs[0].name);assert m,pngs[0]
pattern=str(frames/(m[1]+'%0'+str(len(m[2]))+'d.png'));trim=record['trim_frames']/30.;duration=record['seconds']
final=o/'DEAD_STREET_Eastex_Freight_Exchange_Clarity.mp4'
subprocess.run([ff,'-y','-v','warning','-framerate','30','-start_number',str(int(m[2])),'-i',pattern,'-i',str(wav[0]),'-ss',str(trim),'-t',str(duration),'-map','0:v:0','-map','1:a:0','-vf','setsar=1','-c:v','libx264','-preset','medium','-crf','23','-pix_fmt','yuv420p','-profile:v','high','-r','30','-c:a','aac','-b:a','160k','-movflags','+faststart',str(final)],check=True,timeout=300)
subprocess.run([ff,'-v','error','-i',str(final),'-f','null','NUL'],check=True,timeout=120)
audio=subprocess.run([ff,'-v','error','-i',str(final),'-vn','-ac','2','-ar','22050','-f','f32le','-'],capture_output=True,check=True).stdout
a=np.frombuffer(audio,dtype='<f4');assert len(a)>duration*22050*2*.98 and np.isfinite(a).all()
audio_stats={}
for name,start,end in [('arrival',4,12),('combat',25,45),('full',0,duration)]:
 chunk=a[int(start*22050*2):int(end*22050*2)];audio_stats[name]={'peak':float(np.max(abs(chunk))),'rms':float(np.sqrt(np.mean(chunk*chunk))),'clipped_fraction':float(np.mean(abs(chunk)>=1))}
for seconds,name in [(7,'arrival'),(30,'combat'),(max(0,duration-3),'results')]:
 subprocess.run([ff,'-y','-v','error','-ss',str(seconds),'-i',str(final),'-frames:v','1',str(o/('encoded_'+name+'.png'))],check=True,timeout=30)
data=final.read_bytes();folder=o/'transfer';folder.mkdir(exist_ok=True);parts=[]
for i,start in enumerate(range(0,len(data),1000000)):
 chunk=data[start:start+1000000];name='part_%03d.txt'%i;(folder/name).write_text(base64.b64encode(chunk).decode());parts.append({'name':name,'bytes':len(chunk),'sha256':hashlib.sha256(chunk).hexdigest()})
report={'file':str(final),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'seconds':duration,'width':1920,'height':1080,'fps':30,'decoded_to_end':True,'audio':audio_stats,'lossless_frames':len(pngs),'source_concurrent_changes':changed,'parts':parts}
(o/'delivery.json').write_text(json.dumps(report,indent=2));print('DELIVERY',json.dumps(report),flush=True)
