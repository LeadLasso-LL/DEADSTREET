"""Install only successfully rendered and reviewed faction atlases."""
from pathlib import Path
import json,shutil
from PIL import Image
R=Path(__file__).parent;dest=R.parent.parent/'assets/art/units/pixel_v1'
variants=[f'{k}_{w}' for k in range(2) for w in ['uzi_smg','ak_rifle','pistol','pump_shotgun']]
for v in variants:
 for suffix,folder,expected in [('',dest,(4096,6144)),('__death_back',dest/'death_back',(4096,1024)),('__blood_mask',dest/'blood_masks',(4096,6144))]:
  p=R/'showcase_atlases'/f'{v}{suffix}.png'
  with Image.open(p) as im:assert im.size==expected and im.getbbox(),(p,im.size)
for v in variants:
 for suffix,folder in [('',dest),('__death_back',dest/'death_back'),('__blood_mask',dest/'blood_masks')]:
  folder.mkdir(exist_ok=True);shutil.copy2(R/'showcase_atlases'/f'{v}{suffix}.png',folder/(v+'.png'))
shutil.copy2(R/'showcase_manifest.json',dest/'manifest.json')
for p in (R/'showcase_atlases').glob('2_*__death_back.png'):
 with Image.open(p) as im:assert im.size==(4096,1024) and im.getbbox(),p
 shutil.copy2(p,dest/'death_back'/p.name.replace('__death_back',''))
print('INSTALLED eight full outfit atlases, backward deaths and eight clothing masks.')
