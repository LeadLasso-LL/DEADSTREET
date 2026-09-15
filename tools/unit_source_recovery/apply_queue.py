from pathlib import Path
import json,hashlib
r=Path(__file__).resolve().parents[2];patch=json.loads((Path(__file__).parent/'queue-hunks.json').read_text())
for item in patch:
 p=r/item['path'];s=p.read_text(encoding='utf-8-sig') if p.exists() else ''
 assert hashlib.sha256(s.rstrip().encode()).hexdigest()==item['hash'],item['path']
for item in patch:
 p=r/item['path'];s=p.read_text(encoding='utf-8-sig') if p.exists() else '';lines=s.splitlines(True)
 for h in reversed(item['hunks']):lines[h['start']:h['end']]=h['lines']
 p.parent.mkdir(parents=True,exist_ok=True);p.write_text(''.join(lines),encoding='utf-8')
p=r/'assets/art/units/pixel_v1/manifest.json';m=json.loads(p.read_text())
for k in range(3):
 key=f'{k}_pump_shotgun'
 if key not in m['variants']:m['variants'].append(key)
info=m['clips']['wounded_idle']
if info['count']==1:
 for name,c in m['clips'].items():
  if c['start']>info['start']:c['start']+=23
 info['count']=24;info['fps']=12;info['loop']=True
p.write_text(json.dumps(m,indent=2))
print('Applied source changes and expanded manifest')
