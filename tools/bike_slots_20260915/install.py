from pathlib import Path
import json,hashlib
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
baseline=json.loads((out/'baseline.json').read_text());p=json.loads((out/'changes.json').read_text(encoding='utf-8'));files=p['files']
for rel,edits in p.get('replacements',{}).items():
 s=(r/rel).read_text(encoding='utf-8')
 for edit in edits:
  assert s.count(edit['old'])==1,rel;s=s.replace(edit['old'],edit['new'],1)
 files[rel]=s
for rel,s in files.items():assert hashlib.sha256((r/rel).read_bytes()).hexdigest()==baseline['hashes'][rel],rel+' changed concurrently'
for rel,s in files.items():(r/rel).write_text(s,encoding='utf-8')
(out/'installed.json').write_text(json.dumps({rel:hashlib.sha256((r/rel).read_bytes()).hexdigest() for rel in files},indent=2))
print('Installed',len(files),'guarded source edits')
