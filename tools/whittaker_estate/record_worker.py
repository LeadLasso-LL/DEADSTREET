from pathlib import Path
import subprocess,sys,json,time,hashlib
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate';base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2');editor=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
probe=json.loads((out/'owner_feedback_20260914/record.json').read_text(encoding='utf-8'))
assert not probe['presentation_errors'] and not probe['outro_errors'] and probe['camera_safety_violations']==0
assert probe['voice_clips_loaded']==0 and not probe['voice_missing']
assert probe['phase']=='resolved' and probe['winner'] in ['attacker','defender'],probe
assert not (out/'estate_raw.avi').exists(),'Existing capture preserved; select a new output version'
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
stage=base/'tactical_controls';override=stage/'movie_override.cfg'
override.write_text('[display]\nwindow/size/viewport_width=1920\nwindow/size/viewport_height=1080\nwindow/size/window_width_override=1920\nwindow/size/window_height_override=1080\n')
manifest=stage/'manifest.json';rows=json.loads(manifest.read_text());rows.append({'path':'override.cfg','source':str(override)});manifest.write_text(json.dumps(rows))
subprocess.run([editor,'--headless','--path',str(r),'--script','res://tools/bridge_perf/headroom/build_probe.gd'],cwd=r,check=True,timeout=90)
files=[p for folder in ['gameplay','battle','tools/tactical_controls'] for p in (r/folder).rglob('*.gd')]
(out/'record_source_hashes.json').write_text(json.dumps({str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},indent=2))
try:
 with (out/'capture.log').open('wb')as log:
  p=subprocess.Popen([str(base/'godot.exe'),'--borderless','--position','0,0','--resolution','1920x1080','--fixed-fps','30','--disable-vsync','--write-movie',str(out/'estate_raw.avi'),'--','--check=estate_record'],cwd=r,stdout=log,stderr=subprocess.STDOUT)
  print('CAPTURE_PID',p.pid,flush=True);start=time.monotonic()
  while p.poll() is None:
   try:p.wait(timeout=1)
   except subprocess.TimeoutExpired:pass
   text=(out/'capture.log').read_text(encoding='utf-8',errors='replace')
   if 'SCRIPT ERROR' in text or 'RECORD_ERROR' in text or time.monotonic()-start>480:
    p.kill();p.wait();raise RuntimeError(text[-7000:])
 print('CAPTURE_EXIT',p.returncode,flush=True);assert p.returncode==0
 subprocess.run([sys.executable,str(out/'encode.py')],cwd=r,check=True,timeout=420)
finally:
 subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
print('ESTATE_RECORDING_COMPLETE',flush=True)
