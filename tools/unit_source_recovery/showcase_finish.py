from pathlib import Path
import sys,numpy as np
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).parent;sys.path.insert(0,str(R/'src'));import outfits
base=['111819','202527','353b3d','42494a','555c59','67716c','795139','a67550','b28f79','d0b49a','aa8060','c39b77','d6d5c9','eeeee2','a7ada4','707572','959991','515956','686e6b','868d87','282d30','484e50','181e21','3b2c25','65503c','88603e','a98538','d2b15d','090f12','555c63','959fa5','899399']
PAL=np.array([tuple(bytes.fromhex(c)) for c in base+outfits.palette()],dtype=np.int32)
def finish(path):
 a=np.array(Image.open(path).convert('RGBA'));valid=a[:,:,3]>=128;pixels=a[:,:,:3][valid].astype(np.int32);result=np.empty_like(pixels,dtype=np.uint8)
 for start in range(0,len(pixels),12000):
  part=pixels[start:start+12000];result[start:start+12000]=PAL[((part[:,None,:]-PAL)**2).sum(2).argmin(1)]
 a[:,:,:3][valid]=result;a[:,:,3]=np.where(valid,255,0);a[~valid]=0;Image.fromarray(a).save(path)
if __name__=='__main__':
 sample='--sample' in sys.argv;folder=R/('showcase_samples' if sample else 'showcase_atlases')
 for path in folder.glob('*.png'):
  variants=[arg.split('=',1)[1] for arg in sys.argv if arg.startswith('--variant=')]
  if variants and not any(path.stem==v or path.stem.startswith(v+'__') for v in variants):continue
  if not path.stem.endswith('__blood_mask'):finish(path)
  print('FINISHED',path.name,flush=True)
 if sample:
  font=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',18);small=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',14)
  board=Image.new('RGB',(1152,680),'#252d30');dr=ImageDraw.Draw(board)
  for k,faction in enumerate(['MERCER SAINTS','ORLOV BRATVA']):
   for col,w in enumerate(['uzi_smg','ak_rifle','pistol','pump_shotgun']):
    x=col*288;y=k*340;dr.text((x+22,y+14),faction,fill='#d5c9ac',font=font);dr.text((x+22,y+41),['SMG 1','RIFLE 1','PISTOL 1','SHOTGUN 1'][col],fill='#9daaa8',font=small)
    sp=Image.open(folder/f'{k}_{w}_3_idle_0.png').resize((256,256),Image.Resampling.NEAREST);board.paste(sp,(x+16,y+67),sp)
  board.save(R/'showcase_lineup.png')
