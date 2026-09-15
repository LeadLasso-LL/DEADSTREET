from pathlib import Path
import subprocess,sys,json
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
o=r/'tools/fourth_map_20260915'
paths=[]
for base in ['battle','gameplay']:
 paths += list((r/base).rglob('*.gd'))
paths += [p for p in (r/'docs').glob('*.md') if any(w in p.name for w in ['FACTION','DESIGN','BRIDGE','ATTACKER','WORKFLOW','HAROLD'])]
paths += [r/p for p in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md','docs/DEAD_STREET_PROJECT_CONTROL.md','assets/data/music_catalog.json']]
for base in ['tools/whittaker_estate','tools/bridge_map','tools/cover_interactions_20260915']:
 paths += [p for p in (r/base).glob('*') if p.suffix in ['.gd','.py']]
data={str(p.relative_to(r)).replace('\\','/'):p.read_text(encoding='utf-8-sig') for p in paths if p.is_file()}
(o/'source_export.json').write_text(json.dumps(data),encoding='utf-8')
status=subprocess.check_output(['git','-C',str(r),'status','--porcelain'],text=True,encoding='utf-8')
(o/'initial_status.txt').write_text(status,encoding='utf-8')
print('HEAD',subprocess.check_output(['git','-C',str(r),'rev-parse','HEAD'],text=True).strip())
print('TRACKED DIRTY', '\n'.join(x for x in status.splitlines() if not x.startswith('??')))
print('EXPORT',len(data),'files', (o/'source_export.json').stat().st_size)
print('DOCS', '\n'.join(p.name for p in (r/'docs').glob('*.md')))
print('ESTATE', '\n'.join(p.name for p in (r/'tools/whittaker_estate').glob('*') if p.is_file()))
