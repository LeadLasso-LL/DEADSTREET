from pathlib import Path
from PIL import Image,ImageDraw
import subprocess,io,json
R=Path(__file__).parent;repo=R.parent.parent
m=json.loads((repo/'assets/art/units/pixel_v1/manifest.json').read_text())
b=Image.new('RGB',(1024,768),'#303938');draw=ImageDraw.Draw(b)
for row,v in enumerate(['0_uzi_smg','1_ak_rifle','2_pistol']):
 old=Image.open(io.BytesIO(subprocess.check_output(['git','show','HEAD:assets/art/units/pixel_v1/'+v+'.png'],cwd=repo))).convert('RGBA')
 new=Image.open(R/'review_atlases'/f'{v}.png').convert('RGBA')
 for col,(a,d) in enumerate([(old,2),(new,2),(old,1),(new,1)]):
  f=m['clips']['idle']['start'];x=f%32*128;y=(d*6+f//32)*128
  c=a.crop((x,y,x+128,y+128)).resize((256,256),Image.Resampling.NEAREST)
  b.paste(c,(col*256,row*256),c)
  draw.text((col*256+5,row*256+5),('BEFORE' if col%2==0 else 'AFTER')+' / '+m['directions'][d],fill='white')
b.save(R/'internal_outline_review.png')
print('Outline comparison saved')
