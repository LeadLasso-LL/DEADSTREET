from pathlib import Path
import json,subprocess,hashlib
r=Path(__file__).resolve().parents[2]
p=json.loads((Path(__file__).parent/'overlap_payload.json').read_text(encoding='utf-8'))
source=r/'gameplay/sandbox_caution.gd'
assert source.read_text(encoding='utf-8').strip()==p['baseline'].strip(),'Caution changed; reread before editing'
o=r/'tools/caution_overlap_20260915'
o.mkdir(exist_ok=False)
(o/'before_caution.gd').write_bytes(source.read_bytes())
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md']:
 with (r/'docs'/name).open('a',encoding='utf-8',newline='\n') as f:f.write(p['note'])
source.write_text(p['caution'],encoding='utf-8',newline='\n')
for name in ['capture','review']:
 (o/(name+('.py' if name=='capture' else '.gd'))).write_text(p[name],encoding='utf-8',newline='\n')
print('INSTALLED',hashlib.sha256(source.read_bytes()).hexdigest(),flush=True)
with (o/'worker.log').open('wb') as log:
 worker=subprocess.Popen([r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe',str(o/'capture.py')],stdout=log,stderr=subprocess.STDOUT,cwd=r)
print('WORKER_PID',worker.pid,flush=True)
