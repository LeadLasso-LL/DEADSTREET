from pathlib import Path
import json,collections,zipfile,io
from PIL import Image
import numpy as np
R=Path(__file__).resolve().parents[2];O=Path(__file__).resolve().parent
rows=json.loads((O/'inventory.json').read_text());bad=[]
for row in rows:
 v=row['variant'];crop=(18,12,108,92) if row['group'] in ['base','arsenal'] else (18,6,108,86)
 for side in ['SW','SE']:
  a=np.array(Image.open(O/'renders'/(v+'_'+side+'.png')).convert('RGBA'))[:,:,3]>0
  with zipfile.ZipFile(O/'accepted_baseline_renders.zip') as z:b=np.array(Image.open(io.BytesIO(z.read(v+'_'+side+'_after.png'))).convert('RGBA'))[:,:,3]>0
  outside=np.zeros_like(a);outside[:crop[3],:crop[0]]=True;outside[:crop[3],crop[2]:]=True
  n=int((a&outside).sum());old=int((b&outside).sum())
  if n>old:bad.append((v,side,n,old))
print('NEW_SIDE_CLIPPING',len(bad),collections.Counter(x[0].split('_')[-1] for x in bad))
print('EXAMPLES',bad[:12])

(O/'framing_validation.json').write_text(json.dumps({'directions_checked':len(rows)*2,'new_side_clipping':bad},indent=2),encoding='utf-8')
assert not bad
