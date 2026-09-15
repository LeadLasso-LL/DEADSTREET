from pathlib import Path
import subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/freight_exchange_20260915'
python=r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe'
for mode,script in [('night_overview','preview.gd'),('capacity','review.gd')]:
 p=subprocess.run([python,str(o/'run_native.py'),mode,script],cwd=r,capture_output=True,text=True)
 (o/(mode+'_worker.log')).write_text(p.stdout+'\n'+p.stderr,encoding='utf-8')
 print(mode,p.returncode,p.stdout[-3000:],flush=True)
 if p.returncode:break
