from pathlib import Path
from PIL import Image
import numpy as np,json
root=Path(__file__).resolve().parents[2];base=root/'assets/art/units/pixel_v1';problems=[];cells=0;edge=[]
for p in (base/'death_back').glob('*.png'):
 with Image.open(p) as im:
  a=np.array(im.getchannel('A'))
  for d in range(8):
   for i in range(32):
    cell=a[d*128:(d+1)*128,i*128:(i+1)*128];cells+=1
    if not cell.any():problems.append(f'empty {p.stem}/{d}/{i}')
    if cell[0].any() or cell[-1].any() or cell[:,0].any() or cell[:,-1].any():edge.append(f'{p.stem}/{d}/{i}')
result=dict(death_cells=cells,empty_frames=problems,edge_contact=edge)
(root/'tools/battle_showcase/results/atlas_checks.json').write_text(json.dumps(result,indent=2))
print(json.dumps(dict(death_cells=cells,empty_frames=len(problems),edge_contact=len(edge))))
assert not problems
assert not edge, 'Animation reaches a cell edge; inspect source bounds before capture.'
