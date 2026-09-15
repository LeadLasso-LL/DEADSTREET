from pathlib import Path
import subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/freight_exchange_20260915';python=r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe'
p=subprocess.run([python,str(o/'run_native.py'),'capacity','review.gd'],cwd=r,capture_output=True,text=True)
(o/'capacity_worker.log').write_text(p.stdout+p.stderr,encoding='utf-8');print('CAPACITY',p.returncode,p.stdout[-1000:],flush=True)
if p.returncode==0:
 p=subprocess.run([python,str(o/'capture_worker.py')],cwd=r,capture_output=True,text=True)
 (o/'capture_worker.log').write_text(p.stdout+p.stderr,encoding='utf-8');print('CAPTURE',p.returncode,p.stdout[-1500:],p.stderr[-500:],flush=True)
