from pathlib import Path
import subprocess,shutil,json,hashlib,time,re,wave
import imageio_ffmpeg,numpy as np
from PIL import Image
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent;ff=imageio_ffmpeg.get_ffmpeg_exe()
project=o/'capture_project';project.mkdir(exist_ok=True)
for folder in ['battle','campaign','core','gameplay','world','validation']:
 shutil.copytree(r/folder,project/folder,dirs_exist_ok=True)
def junction(link,target):
 if not link.exists():subprocess.run(['cmd','/c','mklink','/J',str(link),str(target)],check=True,capture_output=True)
junction(project/'assets',r/'assets')
(project/'.godot').mkdir(exist_ok=True)
junction(project/'.godot/imported',r/'.godot/imported')
shutil.copy2(r/'.godot/global_script_class_cache.cfg',project/'.godot/global_script_class_cache.cfg')
config=(r/'project.godot').read_text(encoding='utf-8')
settings={'window/size/viewport_width':'1280','window/size/viewport_height':'720','window/size/window_width_override':'1280','window/size/window_height_override':'720'}
for key,value in settings.items():
 pattern=r'^'+re.escape(key)+r'=.*$'
 if re.search(pattern,config,re.M):config=re.sub(pattern,key+'='+value,config,flags=re.M)
 else:config=config.replace('[display]','[display]\n'+key+'='+value)
# Separate capture user data prevents any persistent preference writes.
config=re.sub(r'^config/name=.*$', 'config/name="DeadStreetIntroReview915"',config,flags=re.M)
(project/'project.godot').write_text(config,encoding='utf-8')
script=project/'tools/caution_impacts_20260915/review.gd';script.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(o/'review.gd',script)
hash_paths=[r/'gameplay/sandbox_opening.gd',r/'gameplay/sandbox_caution.gd',r/'assets/menu/opening/startup.ogv',r/'assets/menu/opening/caution_clean.png',r/'assets/menu/opening/montage.ogv',r/'assets/menu/opening/approved_title.png',r/'gameplay/sandbox_menu_music.gd']
hashes={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in hash_paths}
(o/'capture_hashes.json').write_text(json.dumps(hashes,indent=2))
frames=o/'lossless';frames.mkdir(exist_ok=True)
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
args=[godot,'--path',str(project),'--resolution','1280x720','--position','0,0','--fixed-fps','30','--disable-vsync','--write-movie',str(frames/'frame.png'),'--log-file',str(o/'native_engine.log'),'--script','res://tools/caution_impacts_20260915/review.gd']
(o/'capture_command.json').write_text(json.dumps(args,indent=2))
with (o/'capture.log').open('wb') as log:
 p=subprocess.Popen(args,cwd=project,stdout=log,stderr=subprocess.STDOUT);print('CAPTURE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  content=(o/'capture.log').read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in content or time.monotonic()-start>420:
   p.kill();p.wait();raise RuntimeError('Owned intro capture failed: '+content[-3500:])
assert p.returncode==0,p.returncode
review=json.loads((o/'native_review.json').read_text());assert review['status']=='PASS',review
pngs=sorted(frames.glob('*.png'));wavs=list(frames.glob('*.wav'));assert pngs and len(wavs)==1
assert Image.open(pngs[0]).size==(1280,720)
m=re.fullmatch(r'(.*?)(\d+)\.png',pngs[0].name);pattern=str(frames/(m[1]+'%0'+str(len(m[2]))+'d.png'))
final=o/'DEAD_STREET_Revised_Intro.mp4'
subprocess.run([ff,'-y','-v','warning','-framerate','30','-start_number',str(int(m[2])),'-i',pattern,'-i',str(wavs[0]),'-map','0:v:0','-map','1:a:0','-c:v','libx264','-preset','fast','-crf','19','-pix_fmt','yuv420p','-r','30','-threads','3','-c:a','aac','-b:a','192k','-movflags','+faststart','-shortest',str(final)],check=True,timeout=180)
subprocess.run([ff,'-v','error','-xerror','-i',str(final),'-f','null','NUL'],check=True,timeout=90)
audio=subprocess.run([ff,'-v','error','-i',str(final),'-vn','-ac','2','-ar','44100','-f','f32le','-'],capture_output=True,check=True).stdout
samples=np.frombuffer(audio,dtype='<f4');assert np.isfinite(samples).all() and np.max(abs(samples))<1.0
unchanged=all(hashlib.sha256((r/name).read_bytes()).hexdigest()==digest for name,digest in hashes.items())
assert unchanged,'Capture source changed'
report={'file':str(final),'bytes':final.stat().st_size,'sha256':hashlib.sha256(final.read_bytes()).hexdigest(),'seconds':len(pngs)/30,'frames':len(pngs),'width':1280,'height':720,'fps':30,'full_decode':'PASS','audio_peak':float(np.max(abs(samples))),'audio_rms':float(np.sqrt(np.mean(samples*samples))),'source_hashes_unchanged':unchanged,'native':review}
(o/'delivery.json').write_text(json.dumps(report,indent=2));print('DELIVERY',json.dumps(report),flush=True)
