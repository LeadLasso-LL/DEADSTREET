from pathlib import Path
import json,hashlib
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
payload=json.loads((out/'payload.json').read_text(encoding='utf-8'));baseline=json.loads((out/'baseline.json').read_text())
for rel,text in payload.items():
 p=r/rel
 if rel in baseline['hashes']:assert hashlib.sha256(p.read_bytes()).hexdigest()==baseline['hashes'][rel],rel+' changed since baseline'
 else:assert not p.exists(),rel+' already exists'
for rel,text in payload.items():
 p=r/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding='utf-8')
(out/'installed.json').write_text(json.dumps({p:hashlib.sha256((r/p).read_bytes()).hexdigest() for p in payload},indent=2))
print('Installed guarded source files:',len(payload))
