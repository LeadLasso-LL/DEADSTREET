from pathlib import Path
import subprocess,sys,time
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_finish_20260915'
mode=sys.argv[1];script=sys.argv[2] if len(sys.argv)>2 else 'review.gd';log=o/(mode+'.log')
args=[r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--path',str(r),'--resolution','1440x900','--position','0,0','--log-file',str(o/(mode+'_godot.log')),'--script','res://tools/yard_finish_20260915/'+script]
if mode=='bake':args+=['--','--bake']
if mode=='audio':args+=['--fixed-fps','30','--write-movie',str(o/'audio_probe.avi')]
with log.open('wb') as f:
 p=subprocess.Popen(args,cwd=r,stdout=f,stderr=subprocess.STDOUT);print('OWNED_NATIVE_PID',p.pid,flush=True);start=time.monotonic()
 while p.poll() is None:
  try:p.wait(timeout=1)
  except subprocess.TimeoutExpired:pass
  s=log.read_text(encoding='utf-8',errors='replace')
  if 'SCRIPT ERROR' in s or time.monotonic()-start>240:
   p.kill();p.wait();print('Stopped owned failed/timeout native child',flush=True);break
print('EXIT',p.returncode,flush=True)
print(log.read_text(encoding='utf-8',errors='replace')[-5500:]);sys.exit(p.returncode)
