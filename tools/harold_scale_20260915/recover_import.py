from pathlib import Path
import re,json,sys,subprocess
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1];cache=r/'.godot/global_script_class_cache.cfg'
original=cache.read_bytes();(out/'import_class_cache_before.cfg').write_bytes(original);text=original.decode('utf-8')
classes={}
for folder in ['battle','campaign','core','gameplay','world']:
 for p in (r/folder).rglob('*.gd'):
  match=re.search(r'^class_name\s+(\w+)',p.read_text(encoding='utf-8-sig'),re.M)
  if match:classes[match.group(1)]='res://'+p.relative_to(r).as_posix()
changed=[]
for block in re.findall(r'\{.*?\}',text,re.S):
 if 'res://tools/' not in block:continue
 old=re.search(r'"path": "([^"]+)"',block).group(1);name=re.search(r'"class":\s*&?"([^"]+)"',block).group(1);assert name in classes,name
 text=text.replace(block,block.replace(old,classes[name]));changed.append([name,old,classes[name]])
cache.write_text(text,encoding='utf-8')
folders=['tools/bridge_perf','tools/sandbox_finish_20260915/before','tools/selected_range_20260915','tools/selected_range_groups_20260915','tools/harold_scale_20260915/baseline']
for folder in folders:
 p=r/folder/'.gdignore'
 if not p.exists():p.write_text('# Archived development evidence; do not register backup scripts as runtime classes.\n')
(out/'import_recovery.json').write_text(json.dumps({'class_paths_repaired':changed,'ignored_evidence_folders':folders},indent=2))
print(json.dumps({'repaired':len(changed),'folders':folders}),flush=True)
note='\n\n## 20260915-harold-scale-03 - Import recovery\nInitial map bake caught/fixed a four-occurrence art-coordinate identifier typo; final ground bake succeeds. Whole-project import exceeded the original150-second wrapper limit while scanning archived review assets. Resumed import completed asset processing but exposed12 global classes pointing at archived tools/bridge_perf, sandbox_finish before-sources and selected-range before-view copies. Added .gdignore to evidence/backup folders (no backup deletion/source modification), repaired generated class-cache paths to canonical runtime scripts, and saved original cache plus exact repair manifest in tools/harold_scale_20260915/import_recovery.json. This is import hygiene, not gameplay logic. Initial failed native run retained; clean final rerun follows.\n'
for name in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
 with (r/name).open('a',encoding='utf-8') as f:f.write(note)