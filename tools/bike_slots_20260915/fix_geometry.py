from pathlib import Path
import json,hashlib
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
base=json.loads((out/'baseline.json').read_text());installed=json.loads((out/'installed.json').read_text());changes=json.loads((out/'geometry_fixes.json').read_text());revised={}
for rel,edits in changes.items():
 p=r/rel;assert hashlib.sha256(p.read_bytes()).hexdigest()==installed.get(rel,base['hashes'][rel]),rel+' changed concurrently'
 s=p.read_text(encoding='utf-8')
 for e in edits:assert s.count(e['old'])==1,rel;s=s.replace(e['old'],e['new'],1)
 revised[rel]=s
for name in ['check.log','check.json']:
 p=out/name
 if p.exists():(out/('initial_'+name)).write_bytes(p.read_bytes())
for rel,s in revised.items():(r/rel).write_text(s,encoding='utf-8');installed[rel]=hashlib.sha256((r/rel).read_bytes()).hexdigest()
(out/'installed.json').write_text(json.dumps(installed,indent=2))
entry='\n\n## 20260915-bike-slots-02 — UI pass and deployment limits found\nTwo/four packing and approved wordmark installed;18native mouse/UI checks pass. Baseline convoy tests found old estate five-position list rejects six/twelve-bike bodies, and bridge defending12bike convoy exhausts car-sized positions. Narrow corrections add grouped estate bike poses/independent arrival lanes and extra collision-checked bike blockade candidates; original non-bike poses and accepted estate battle preserved. All other maps, including concurrent Freight revision, passed tested2/4/12bike starts. Next rerun affected deployment cases, inspect final four-bike UI and retain initial failure logs.\n'
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 p=r/'docs'/name;t=p.read_text(encoding='utf-8')
 if '20260915-bike-slots-02' not in t:p.write_text(t+entry,encoding='utf-8')
print('Fixed estate bike formation and bridge bike blockade; initial failure evidence retained')
