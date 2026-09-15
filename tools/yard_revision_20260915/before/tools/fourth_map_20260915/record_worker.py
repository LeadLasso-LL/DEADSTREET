from pathlib import Path
import subprocess,sys,time,json,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/fourth_map_20260915'
for filename in ['first_pass.json','approach_review.json','integration_review.json']:
 report=json.loads((o/filename).read_text(encoding='utf-8'));assert not report['errors'],report
raw=o/'yard_raw_v2.avi';assert not raw.exists(),'Existing capture preserved'
paths=[p for folder in ['battle','campaign','core','gameplay'] for p in (r/folder).rglob('*.gd')]+[o/'showcase.gd',r/'assets/art/doble_ocho/ground.png']
hashes={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(o/'capture_source_hashes.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')
args=[r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--path',str(r),'--resolution','1280x720','--position','0,0','--fixed-fps','30','--disable-vsync','--write-movie',str(raw),'--log-file',str(o/'capture_godot.log'),'--script','res://tools/fourth_map_20260915/showcase.gd','--','--record']
(o/'capture_command.json').write_text(json.dumps(args,indent=2),encoding='utf-8')
log=o/'capture.log'
with log.open('wb') as stream:
 p=subprocess.Popen(args,cwd=r,stdout=stream,stderr=subprocess.STDOUT);print('CAPTURE_NATIVE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  s=log.read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in s or time.monotonic()-start>600:
   p.kill();p.wait();raise RuntimeError('Owned capture failed/timed out: '+s[-5000:])
print('CAPTURE_EXIT',p.returncode,flush=True);assert p.returncode==0
changed=[name for name,digest in hashes.items() if hashlib.sha256((r/name).read_bytes()).hexdigest()!=digest]
assert not changed,changed
record=json.loads((o/'record.json').read_text(encoding='utf-8'))
assert record['phase']=='resolved' and not record['errors'] and not record['arrival_errors'] and not record['outro_errors'] and record['camera_violations']==0,record
print('CAPTURE_PASSED',json.dumps({k:record[k] for k in ['frames','seconds','combat_seconds','winner','survivors']}),flush=True)
subprocess.run([sys.executable,str(o/'encode.py')],cwd=r,check=True,timeout=420)
