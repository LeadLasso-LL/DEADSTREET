from pathlib import Path
import subprocess,sys
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate'
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
for mode in ['estate_probe','estate_preview','estate_native']:
 with (out/(mode+'.log')).open('wb') as f:
  p=subprocess.run([g]+(['--headless'] if mode=='estate_probe' else [])+['--','--check='+mode],cwd=r,stdout=f,stderr=subprocess.STDOUT,timeout=180)
 log=(out/(mode+'.log')).read_text(encoding='utf-8',errors='replace');print(log[-18000:],flush=True)
 if p.returncode or 'SCRIPT ERROR' in log or 'RECORD_ERROR' in log or 'ESTATE_FAIL' in log:raise RuntimeError(mode+' failed')
 if mode=='estate_bake':subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
print('ESTATE_FIRST_CHECK_COMPLETE',flush=True)