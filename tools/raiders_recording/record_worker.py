from pathlib import Path
import subprocess,sys,json,time,shutil
sys.stdout.reconfigure(encoding='utf-8')
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=r/'tools/raiders_recording';base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
# Retain the earlier pickup-only deliverable while replacing its obsolete raw capture.
old=out/'Dead_Street_Stateline_Raiders_vs_NBPD.mp4'
if old.exists() and not (out/'pickup_only.mp4').exists():shutil.copy2(old,out/'pickup_only.mp4')
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
stage=base/'tactical_controls';override=stage/'movie_override.cfg'
override.write_text('[display]\nwindow/size/viewport_width=1920\nwindow/size/viewport_height=1080\nwindow/size/window_width_override=1920\nwindow/size/window_height_override=1080\n')
manifest=stage/'manifest.json';rows=json.loads(manifest.read_text());rows.append({'path':'override.cfg','source':str(override)});manifest.write_text(json.dumps(rows))
subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe','--headless','--path',str(r),'--script','res://tools/bridge_perf/headroom/build_probe.gd'],cwd=r,check=True,timeout=90)
with (out/'capture.log').open('wb')as log:
 p=subprocess.Popen([str(base/'godot.exe'),'--borderless','--position','0,0','--resolution','1920x1080','--fixed-fps','30','--disable-vsync','--write-movie',str(out/'raiders_raw.avi'),'--','--check=raiders_record'],cwd=r,stdout=log,stderr=subprocess.STDOUT)
 print('CAPTURE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  contents=(out/'capture.log').read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in contents or '\nERROR:' in contents or 'RECORD_ERROR' in contents or time.monotonic()-start>420:
   p.kill();p.wait();raise RuntimeError(contents[-4000:])
print('CAPTURE_EXIT',p.returncode,flush=True);assert p.returncode==0
subprocess.run([sys.executable,str(out/'encode.py')],cwd=r,check=True,timeout=300)
# Restore the normal preview launcher after MovieMaker, retaining the new audio overlay.
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
print('RECORDING_JOB_COMPLETE',flush=True)
