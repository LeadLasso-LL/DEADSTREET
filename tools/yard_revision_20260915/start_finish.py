from pathlib import Path
import json,hashlib,shutil,subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_finish_20260915';o.mkdir(exist_ok=True)
assert not (o/'baseline.json').exists(),'Original finish baseline already exists'
files=['gameplay/doble_ocho_art.gd','gameplay/tactical_convoy_audio.gd']
for n in files:
 p=o/'before'/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(r/n,p)
(o/'before/.gdignore').write_text('');shutil.copy2(r/'assets/art/doble_ocho/ground.png',o/'before/ground.png')
data={n:(r/n).read_text(encoding='utf-8') for n in files};(o/'sources.json').write_text(json.dumps(data),encoding='utf-8')
hashes={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for folder in ['battle','campaign','core','gameplay'] for p in (r/folder).rglob('*.gd')}
head=subprocess.run(['git','rev-parse','HEAD'],cwd=r,capture_output=True,check=True).stdout.decode().strip();index=subprocess.run(['git','diff','--cached','--name-only'],cwd=r,capture_output=True,check=True).stdout.decode()
(o/'baseline.json').write_text(json.dumps({'head':head,'index':index,'sources':hashes},indent=2));print('BASELINE',head,'index',repr(index),'protected',len(hashes),flush=True)
entry='\n### 20260915-doble-ocho-10 — sidewalk and arrival mix correction\n- Owner requests gray sidewalks with visible spaced slab joints, and Ravicci music dominant during arrival. Previous +10% source gain did not account for trailing-vehicle distance versus nearby defender building. Scope only yard scenery and yard arrival radio presentation; keep the accepted Ravicci battle configuration, orders and outcome. Fresh exact backup tools/yard_finish_20260915/before, protected baseline.json. Next: native spatial audio check, bake gray sidewalks, recapture matching Ravicci victory MP4.\n'
for n in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md']:
 with (r/'docs'/n).open('a',encoding='utf-8') as f:f.write(entry)
