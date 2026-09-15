from pathlib import Path
import json,hashlib,subprocess,sys,shutil
sys.stdout.reconfigure(encoding='utf-8')
r=Path("C:\\Users\\brand\\OneDrive\\Documents\\dead-street");o=r/'tools/yard_revision_20260915'
files=['battle/geometry/doble_ocho_catalog.gd','gameplay/doble_ocho_art.gd','gameplay/doble_ocho_setup.gd','gameplay/doble_ocho_scenario.gd','gameplay/tactical_convoy_audio.gd','gameplay/tactical_battle_presentation.gd','gameplay/arsenal_battle_fixture.gd','tools/fourth_map_20260915/showcase.gd','tools/fourth_map_20260915/review.gd','tools/fourth_map_20260915/record_worker.py','tools/fourth_map_20260915/encode.py']
assert not (o/'baseline.json').exists(),'Do not overwrite original baseline'
source={name:(r/name).read_text(encoding='utf-8') for name in files};(o/'sources.json').write_text(json.dumps(source),encoding='utf-8')
for name in files:
 p=o/'before'/name;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(r/name,p)
(o/'before/.gdignore').write_text('')
shutil.copy2(r/'assets/art/doble_ocho/ground.png',o/'before/ground.png')
state={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for folder in ['battle','campaign','core','gameplay'] for p in (r/folder).rglob('*.gd')}
def git(*args):return subprocess.run(['git',*args],cwd=r,capture_output=True,check=True).stdout.decode('utf-8')
status=git('status','--short','--untracked-files=normal');(o/'initial_status.txt').write_text(status,encoding='utf-8')
b={'head':git('rev-parse','HEAD').strip(),'branch':git('branch','--show-current').strip(),'index':git('diff','--cached','--name-only'),'sources':state};(o/'baseline.json').write_text(json.dumps(b,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in b.items() if k!='sources'}));print('Protected source count',len(state));print('Tracked modifications',git('diff','--name-only'))
for name,count in [('docs/DEAD_STREET_HIVE_MIND.md',32),('docs/DEAD_STREET_JOURNAL.md',22),('docs/DEAD_STREET_PROJECT_CONTROL.md',17)]:
 print(name);print('\n'.join((r/name).read_text(encoding='utf-8').splitlines()[-count:]))
