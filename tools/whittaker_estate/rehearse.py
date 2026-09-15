from pathlib import Path
import subprocess,sys,json
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate';g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
for seed in [9146,9147,9148,9149]:
 p=subprocess.run([g,'--headless','--','--check=estate_probe','--seed='+str(seed)],cwd=r,capture_output=True,timeout=90)
 log=(p.stdout+p.stderr).decode('utf-8',errors='replace');(out/('probe_'+str(seed)+'.log')).write_text(log,encoding='utf-8')
 if p.returncode or 'SCRIPT ERROR' in log or 'RECORD_ERROR' in log:raise RuntimeError(log[-6000:])
 report=json.loads((out/'probe.json').read_text(encoding='utf-8'));print('REHEARSAL',seed,report['phase'],report['winner'],report['duration'],flush=True)
 if report['winner']=='defender':
  print('CHOSEN_SEED',seed,flush=True)
  for name in ['estate_director.gd','estate_record.gd','estate_preview.gd','estate_native.gd']:
   path=r/'tools/tactical_controls'/name;path.write_text(path.read_text(encoding='utf-8').replace('9146',str(seed)),encoding='utf-8')
  break
else:raise RuntimeError('No defensible complete showcase yet')
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
with (out/'estate_native.log').open('wb') as f:subprocess.run([g,'--disable-vsync','--','--check=estate_native'],cwd=r,stdout=f,stderr=subprocess.STDOUT,timeout=90)
print((out/'estate_native.log').read_text(encoding='utf-8')[-2000:],flush=True)
print('REHEARSAL_READY',flush=True)
