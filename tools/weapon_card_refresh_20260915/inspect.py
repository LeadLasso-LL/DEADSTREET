from pathlib import Path
import json,collections,xml.etree.ElementTree as E
R=Path(__file__).resolve().parents[2];O=R/'tools/portrait_audit_20260914'
rows=json.loads((O/'inventory.json').read_text())
print('INVENTORY',len(rows),collections.Counter(x['group'] for x in rows))
print('JOBS',[(p.stem,len(json.loads(p.read_text())['rows'])) for p in (O/'jobs').glob('*.json')])
p=json.loads((O/'jobs/mercer.json').read_text())
for name,svg in p['jobs']:
 if name in ['0_pump_shotgun_SW_after','0_ak_rifle_SW_after','arsenal_0_aug_SW_after','0_pistol_SW_after']:
  root=E.fromstring(svg);parents={c:q for q in root.iter() for c in q};node=root.find(".//*[@id='muzzle_anchor']");g=parents[node]
  print(name,'GROUP',g.attrib,'CHILDREN',[(c.tag.split('}')[-1],c.attrib) for c in g if c.tag.endswith('circle') or c.tag.endswith('g')])
  print('TAIL',E.tostring(g,encoding='unicode')[-950:])
print('PORTRAIT_AUDIT_FILES',[p.name for p in O.iterdir() if p.is_file() and p.suffix in ['.md','.json'] and 'inventory' not in p.name])
