"""Verify only the rebuilt models; full clip coverage, geometry, PNG integrity and anchors."""
from pathlib import Path
import json,math
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
F=ROOT/'assets/art/units/factions'
A=ROOT/'assets/art/weapons/arsenal'
models={'g36c','m4a1'}
manifest=json.loads((F/'manifest.json').read_text())
variants=[v for v,d in manifest['variants'].items() if d['model'] in models]
assert len(variants)==42
sizes={'units':(4096,6144),'death_back':(4096,1024),'check_comrade':(4096,1024),'blood_masks':(4096,6144),'portraits':(90,80)}
for v in variants:
 report=json.loads((F/'validation'/f'{v}.json').read_text())
 assert report['frames']==1840 and report['clips']==17 and report['directions']==8
 assert report['body_checks']==40 and not report['borders'],report
 for folder,size in sizes.items():
  with Image.open(F/folder/f'{v}.png') as im:assert im.size==size;im.verify()
 anchors=json.loads((F/'anchors'/f'{v}.json').read_text())
 assert len(anchors['muzzles'])==400 and len(anchors['abdomen'])==384
 assert all(len(p)==2 and all(math.isfinite(x) for x in p) for table in anchors.values() for p in table.values())
for m in models:
 for k in range(3):
  for folder,size in sizes.items():
   if folder=='blood_masks':continue
   with Image.open(A/folder/f'{k}_{m}.png') as im:assert im.size==size;im.verify()
result={'sets':48,'frames':88320,'clips_per_set':17,'directions':8,'faction_body_checks':1680,'new_faction_border_contacts':0}
(ROOT/'tools/armor_equipment/rifle_validation.json').write_text(json.dumps(result,indent=2)+'\n')
print('REFINED_RIFLE_ASSETS',json.dumps(result))
