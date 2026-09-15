from pathlib import Path
import json,hashlib,subprocess,re
r=Path(r"C:\Users\brand\OneDrive\Documents\dead-street"); out=r/'tools/sandbox_maps_20260915'
out.mkdir(exist_ok=True); (out/'before').mkdir(exist_ok=True); (out/'before/.gdignore').touch()
paths=[p for base in ['gameplay','battle','campaign'] for p in (r/base).rglob('*.gd')]
files={str(p.relative_to(r)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
baseline={'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip(),'branch':subprocess.check_output(['git','branch','--show-current'],cwd=r,text=True).strip(),'hashes':files,'index':subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True)}
assert not (out/'baseline.json').exists()
(out/'baseline.json').write_text(json.dumps(baseline,indent=2))
for p in paths:
 q=out/'before'/p.relative_to(r);q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
hits=[]
for p in paths:
 for n,line in enumerate(p.read_text(encoding='utf-8-sig').splitlines(),1):
  if re.search('Harold Avenue|Harold Apartments|River Suspension|RIVER BRIDGE|River Bridge|river_bridge|whittaker_estate',line) and (re.search('label|text|title|name|location|region|scenario|preset|config',line,re.I)):hits.append([str(p.relative_to(r)),n,line])
(out/'name_scan.json').write_text(json.dumps(hits))
entry="\n\n## 20260915-sandbox-maps-01 - Central map selection and canonical names approved\nOWNER-AUTHORIZED / IN PROGRESS. Brandon selects Calder River and Calder Memorial Bridge (supersedes suggested Crossing); Harold map display name Harold Ave. Widen Battle Setup to use dead side space; chosen map image between factions, dropdown above, image choices, automatic per-map unit presets and suitable transports. Increase selected faction emblems. Preserve all current roster/equipment editing, glossary/comparisons/opening/music and accepted battles. New audio commit35e0db1 is current; index empty; its separate push block is not this task. Baseline exact source backups/hashes in tools/sandbox_maps_20260915/. Next implement and native-validate layout at multiple window sizes, all map selections/presets/start/return, capture review screenshot. No battle rebalance or map geometry change.\n"
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 p=r/'docs'/name;t=p.read_text(encoding='utf-8');assert '20260915-sandbox-maps-01' not in t;p.write_text(t+entry,encoding='utf-8')
print(json.dumps({'baseline':baseline['head'],'sources':len(files),'instructions':[str(p.relative_to(r)) for b in ['gameplay','battle','tools'] for p in (r/b).rglob('AGENTS.md')],'names':hits},indent=2))
