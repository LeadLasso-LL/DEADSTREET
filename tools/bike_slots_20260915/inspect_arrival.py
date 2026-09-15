from pathlib import Path
import re,json,hashlib
from PIL import Image,ImageChops
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');out=r/'tools/bike_slots_20260915'
rows={}
for folder in ['gameplay','battle','campaign']:
 for p in (r/folder).rglob('*.gd'):
  t=p.read_text(encoding='utf-8').splitlines();hits=[i for i,s in enumerate(t) if re.search(r'convoy_member|convoy_group_size',s)]
  if hits:rows[str(p.relative_to(r))]=['\n'.join(t[max(0,i-5):i+9]) for i in hits]
print(json.dumps(rows,indent=2))
p=r/'assets/menu/opening/approved_title.png';im=Image.open(p);b=im.convert('L').point(lambda v:255 if v>70 else 0).getbbox()
print('TITLE_BOUNDS',b,'SHA',hashlib.sha256(p.read_bytes()).hexdigest())
print('TWO_WHEELERS',json.dumps({k:{f:v for f,v in row.items() if f in ['name','body','unit_capacity']} for k,row in json.loads((r/'assets/data/vehicle_models.json').read_text())['models'].items() if row.get('vehicle_class')=='two_wheelers'}))
gloss=json.loads((r/'assets/data/faction_glossary.json').read_text(encoding='utf-8'))
(out/'faction_reference.json').write_text(json.dumps(gloss,indent=2),encoding='utf-8')
print('GLOSSARY_KEYS',list(gloss.keys()))
