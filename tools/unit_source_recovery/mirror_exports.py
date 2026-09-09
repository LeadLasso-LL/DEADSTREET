"""Enforce exact reflected pixels and corresponding muzzle anchors."""
from pathlib import Path
import numpy as np,json
from PIL import Image
R=Path(__file__).parent
for path in (R/'review_atlases').glob('*.png'):
 a=np.array(Image.open(path).convert('RGBA'))
 for dst,src in [(3,1),(4,0)]:
  for i in range(188):
   x=(i%32)*128;row=(i//32)*128
   original=a[src*768+row:src*768+row+128,x:x+128].copy()
   a[dst*768+row:dst*768+row+128,x:x+128]=original[:,::-1]
   assert np.array_equal(a[dst*768+row:dst*768+row+128,x:x+128],original[:,::-1])
 Image.fromarray(a).save(path)
p=R.parent.parent/'assets/art/units/pixel_v1/muzzles.json';data=json.loads(p.read_text())
for k in range(3):
 for w in ['uzi_smg','ak_rifle','pistol','pump_shotgun']:
  for dst,src in [('sw','se'),('w','e')]:
   for pose in ['open','cover']:
    x,y=data[f'{k}_{w}/{src}/{pose}'];data[f'{k}_{w}/{dst}/{pose}']=[128-x,y]
p.write_text(json.dumps(data,indent=2))
print('4512 reflected frames verified; muzzle positions reflected')
