from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).parent;repo=R.parent.parent
PAL=np.array([tuple(bytes.fromhex(c)) for c in ['111819','202527','353b3d','42494a','555c59','67716c','795139','a67550','b28f79','d0b49a','aa8060','c39b77','d6d5c9','eeeee2','a7ada4','707572','959991','515956','686e6b','868d87','282d30','484e50','181e21','3b2c25','65503c','88603e','a98538','d2b15d','090f12','555c63','959fa5','899399']],dtype=np.int32)
for path in (R/'review_atlases').glob('*.png'):
 a=np.array(Image.open(path).convert('RGBA'))
 # Only quantize occupied pixels, preserving full native sprite resolution.
 mask=a[:,:,3]>=128;rgb=a[:,:,:3][mask].astype(np.int32);result=np.empty_like(rgb,dtype=np.uint8)
 for start in range(0,len(rgb),20000):
  part=rgb[start:start+20000]
  result[start:start+20000]=PAL[((part[:,None,:]-PAL)**2).sum(2).argmin(1)]
 a[:,:,:3][mask]=result;a[:,:,3]=np.where(mask,255,0);a[~mask]=0
 Image.fromarray(a).save(path)
 print('FINISHED',path.name,flush=True)
board=Image.new('RGB',(1024,720),'#303938');draw=ImageDraw.Draw(board)
for row,variant in enumerate(['0_uzi_smg','1_uzi_smg','0_ak_rifle']):
 old=Image.open(repo/'assets/art/units/pixel_v1'/f'{variant}.png').convert('RGBA')
 new=Image.open(R/'review_atlases'/f'{variant}.png').convert('RGBA')
 for col,(atlas,d) in enumerate([(old,0),(new,0),(old,1),(new,1)]):
  cell=atlas.crop((25*128,d*768,26*128,d*768+128))
  cell=cell.resize((256,256),Image.Resampling.NEAREST)
  board.paste(cell,(col*256,row*240),cell)
  draw.text((col*256+8,row*240+8),variant+(' BEFORE' if col%2==0 else ' AFTER'),fill='white')
board.save(R/'arms_review.png')
