from pathlib import Path
import subprocess,shutil,json,hashlib,time,re
import imageio_ffmpeg,numpy as np
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
project=o/'capture_project';project.mkdir(exist_ok=True)
for folder in ['battle','campaign','core','gameplay','world','validation']:shutil.copytree(r/folder,project/folder,dirs_exist_ok=True)
def junction(link,target):
 if not link.exists():subprocess.run(['cmd','/c','mklink','/J',str(link),str(target)],check=True,capture_output=True)
(project/'assets').mkdir(exist_ok=True)
for p in (r/'assets').iterdir():
 target=project/'assets'/p.name
 if p.name=='menu':shutil.copytree(p,target,dirs_exist_ok=True)
 elif p.is_dir():junction(target,p)
 else:shutil.copy2(p,target)
(project/'.godot').mkdir(exist_ok=True);junction(project/'.godot/imported',r/'.godot/imported')
shutil.copy2(r/'.godot/global_script_class_cache.cfg',project/'.godot/global_script_class_cache.cfg')
config=(r/'project.godot').read_text(encoding='utf-8')
for key,value in {'window/size/viewport_width':'1280','window/size/viewport_height':'720','window/size/window_width_override':'1280','window/size/window_height_override':'720'}.items():
 pattern=r'^'+re.escape(key)+r'=.*$'
 config=re.sub(pattern,key+'='+value,config,flags=re.M) if re.search(pattern,config,re.M) else config.replace('[display]','[display]\n'+key+'='+value)
config=re.sub(r'^config/name=.*$', 'config/name="DeadStreetIntroOverlap915"',config,flags=re.M)
config+='\n[editor]\nmovie_writer/mjpeg_quality=0.95\n'
(project/'project.godot').write_text(config,encoding='utf-8')
script=project/'tools/caution_overlap_20260915/review.gd';script.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(o/'review.gd',script)
names=['gameplay/sandbox_opening.gd','gameplay/sandbox_caution.gd','assets/menu/opening/startup.ogv','assets/menu/opening/caution_clean.png','assets/menu/opening/montage.ogv','assets/menu/opening/approved_title.png','gameplay/sandbox_menu_music.gd']
hashes={name:hashlib.sha256((project/name).read_bytes()).hexdigest() for name in names};(o/'capture_hashes.json').write_text(json.dumps(hashes,indent=2))
raw=o/'native_intro.avi';assert not raw.exists(),'Use a fresh capture directory'
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
args=[godot,'--path',str(project),'--resolution','1280x720','--position','0,0','--fixed-fps','60','--disable-vsync','--write-movie',str(raw),'--log-file',str(o/'native_engine.log'),'--script','res://tools/caution_overlap_20260915/review.gd']
(o/'capture_command.json').write_text(json.dumps(args,indent=2))
with (o/'capture.log').open('wb') as log:
 p=subprocess.Popen(args,cwd=project,stdout=log,stderr=subprocess.STDOUT);print('CAPTURE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  content=(o/'capture.log').read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in content or time.monotonic()-start>300:p.kill();p.wait();raise RuntimeError(content[-3500:])
assert p.returncode==0,p.returncode
review=json.loads((o/'native_review.json').read_text());assert review['status']=='PASS',review
final=o/'DEAD_STREET_Intro_Slower_Zoom.mp4'
subprocess.run([ff,'-y','-v','warning','-i',str(raw),'-map','0:v:0','-map','0:a:0','-c:v','libx264','-preset','fast','-crf','19','-pix_fmt','yuv420p','-r','60','-threads','3','-c:a','aac','-b:a','192k','-movflags','+faststart',str(final)],check=True,timeout=180)
decoded=subprocess.run([ff,'-v','error','-xerror','-i',str(final),'-progress','pipe:1','-f','null','NUL'],capture_output=True,text=True,check=True)
frames=int(re.findall(r'^frame=(\d+)',decoded.stdout,re.M)[-1]);seconds=frames/60
audio=subprocess.run([ff,'-v','error','-i',str(final),'-vn','-ac','2','-ar','44100','-f','f32le','-'],capture_output=True,check=True).stdout
samples=np.frombuffer(audio,dtype='<f4');assert np.isfinite(samples).all() and np.max(abs(samples))<1.0
changed=[name for name,digest in hashes.items() if hashlib.sha256((r/name).read_bytes()).hexdigest()!=digest]
assert all(name=='assets/menu/opening/montage.ogv' for name in changed),changed
report={'file':str(final),'bytes':final.stat().st_size,'sha256':hashlib.sha256(final.read_bytes()).hexdigest(),'seconds':seconds,'frames':frames,'width':1280,'height':720,'fps':60,'native_source':'MovieWriter MJPEG quality0.95 with PCM audio','full_decode':'PASS','audio_peak':float(np.max(abs(samples))),'audio_rms':float(np.sqrt(np.mean(samples*samples))),'concurrent_changes':changed,'native':review}
(o/'delivery.json').write_text(json.dumps(report,indent=2));print('DELIVERY',json.dumps(report),flush=True)
for at,name in [(10.4,'zoom_early'),(11.0,'zoom_mid'),(11.6,'zoom_late'),(12.1,'black')]:subprocess.run([ff,'-y','-v','error','-ss',str(at),'-i',str(final),'-frames:v','1',str(o/('encoded_'+name+'.png'))],check=True)
