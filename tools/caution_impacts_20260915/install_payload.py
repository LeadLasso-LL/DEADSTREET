from pathlib import Path
import json,subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/caution_impacts_20260915'
payload=json.loads((o/'payload.json').read_text())
for name,content in payload['files'].items():
 assert name=='gameplay/sandbox_caution.gd' or name.startswith('tools/caution_impacts_20260915/')
 p=r/name
 assert not p.exists(),str(p)+' already exists'
 p.parent.mkdir(parents=True,exist_ok=True);p.write_text(content,encoding='utf-8',newline='\n')
with (o/'prepare_worker.log').open('wb') as log:
 p=subprocess.Popen([r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe',str(o/'prepare.py')],cwd=r,stdout=log,stderr=subprocess.STDOUT)
 print('PREPARE_PID',p.pid)