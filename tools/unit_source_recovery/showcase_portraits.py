from pathlib import Path
from PIL import Image
import json
R=Path(__file__).parent;out=R.parent.parent/'assets/art/units/pixel_v1/portraits';out.mkdir(exist_ok=True)
m=json.loads((out.parent/'manifest.json').read_text());start=m['clips']['idle']['start'];x=start%32*128;y=(3*m['rows_per_direction']+start//32)*128
for k in range(3):
 for w in ['uzi_smg','ak_rifle','pistol','pump_shotgun']:
  v=f'{k}_{w}';im=Image.open(out.parent/(v+'.png')).convert('RGBA')
  im.crop((x+32,y+30,x+96,y+80)).save(out/(v+'.png'))
print('SW torso portraits saved from installed atlases.')
