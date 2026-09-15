from pathlib import Path
import json,subprocess,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/caution_smooth_20260915';o.mkdir(exist_ok=True)
d=json.loads((r/'tools/caution_impacts_20260915/smooth_payload.json').read_text());p=r/'gameplay/sandbox_caution.gd'
assert p.read_text(encoding='utf-8').strip()==d['baseline'].strip(),'Caution source changed'
(o/'before_caution.gd').write_bytes(p.read_bytes())
note='\n\n## 20260915-caution-smooth-01 - Silent impacts and continuous zoom authorized\nBrandon rejected weak intro gunfire and the two-stage vertical zoom. Remove intro gunshot players entirely, preserve visual impacts. Replace clamped crop target with a single smooth path whose spray-paint focus moves continuously to screen center without reversal; slightly extend zoom from2.22s to2.85s (8.95-11.8), preserving title21/button27. Own sandbox_caution.gd and tools/caution_smooth_20260915 only; separate montage-action recut remains with its owner. Capture isolated menu assets so concurrent montage installation cannot corrupt the recording. Deliver local desktop MP4; no ChatGPT-only links. Status IN PROGRESS.\n'
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write(note)
with (r/'docs/DEAD_STREET_HIVE_MIND.md').open('a',encoding='utf-8') as f:f.write(note)
p.write_text(d['caution'],encoding='utf-8',newline='\n')
for name in ['capture','review']:(o/(name+('.py' if name=='capture' else '.gd'))).write_text(d[name],encoding='utf-8',newline='\n')
(o/'installed_hash.json').write_text(json.dumps({'caution':hashlib.sha256(p.read_bytes()).hexdigest()}))
with (o/'worker.log').open('wb') as log:
 worker=subprocess.Popen([r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe',str(o/'capture.py')],cwd=r,stdout=log,stderr=subprocess.STDOUT);print('SMOOTH_CAPTURE_PID',worker.pid)