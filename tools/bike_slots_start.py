from pathlib import Path
import json,hashlib,re,subprocess
from PIL import Image
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=r/'tools/bike_slots_20260915';out.mkdir(exist_ok=True)
paths=[p for folder in ['gameplay','battle','campaign'] for p in (r/folder).rglob('*.gd')]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
baseline={'head':subprocess.check_output(['git','-C',str(r),'rev-parse','HEAD'],text=True).strip(),'hashes':{str(p.relative_to(r)).replace('\\','/'):sha(p) for p in paths},'status':subprocess.check_output(['git','-C',str(r),'status','--short'],text=True)}
assert not (out/'baseline.json').exists(),'Existing task folder'
(out/'baseline.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
sources={str(p.relative_to(r)).replace('\\','/'):p.read_text(encoding='utf-8') for p in paths}
(out/'source_before.json').write_text(json.dumps(sources),encoding='utf-8')
matches={}
for rel,s in sources.items():
 rows=s.splitlines();hits=[i for i,line in enumerate(rows) if re.search(r'packs_motorcycles|Formation.slots|group.motorcycles|group.indices|motorcycle_count|motorcycle_limit',line)]
 if hits:matches[rel]=[{'line':i+1,'context':'\n'.join(rows[max(0,i-4):i+7])} for i in hits]
(out/'scan.json').write_text(json.dumps(matches,indent=2),encoding='utf-8')
f=json.loads((r/'assets/data/faction_units.json').read_text(encoding='utf-8'));print('FACTIONS',json.dumps({k:{x:v for x,v in row.items() if x not in ['units']} for k,row in f['factions'].items()}))
img=Image.open(r/'assets/menu/opening/approved_title.png');print('TITLE',img.size,img.mode,img.getextrema(),img.getbbox())
print('CALLERS',json.dumps({k:[x['line'] for x in v] for k,v in matches.items()}))
print('FACTION_FILES',json.dumps([str(p.relative_to(r)) for p in (r/'assets/data').glob('*faction*')]))
entry='\n\n## 20260915-bike-slots-01 — Revised packing and title header authorized\nOwner now requires up to two motorcycles per slot for every faction, four for biker, Asian and authority factions. Two-Wheelers picker gets one matching faction-dependent explanation. Replace top-left plain DEAD STREET menu text with existing approved title artwork. This supersedes sandbox-maps-04 three-bike exception; three convoy slots and16 units per side remain. Verify canonical faction membership, seat/driver accounting, four-bike arrival geometry and native UI. Preserve concurrent Eastex Freight revision and all mixed work. Scope tools/bike_slots_20260915 and guarded formation/picker/header/rules edits; no original title artwork changes. Status IN PROGRESS; next inspect shared formation callers then implement and validate.\n'
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 p=r/'docs'/name;t=p.read_text(encoding='utf-8')
 if '20260915-bike-slots-01' not in t:p.write_text(t+entry,encoding='utf-8')
