from pathlib import Path
from PIL import Image,ImageDraw
import json
R=Path(__file__).parent
m=json.loads((R.parent.parent/'assets/art/units/pixel_v1/manifest.json').read_text())
a=Image.open(R/'review_atlases/0_uzi_smg.png').convert('RGBA')
board=Image.new('RGB',(1024,1024),'#303938');draw=ImageDraw.Draw(board)
for d in range(8):
 for j,i in enumerate([0,6,12,18]):
  f=m['clips']['wounded_walk']['start']+i;x=f%32*128;y=(d*6+f//32)*128
  cell=a.crop((x,y,x+128,y+128)).resize((256,256),Image.Resampling.NEAREST)
  xx=(d%4)*256;yy=(d//4)*512+j*128
  cell=cell.crop((0,80,256,208));board.paste(cell,(xx,yy),cell)
  draw.text((xx+3,yy+3),m['directions'][d]+str(i),fill='white')
board.save(R/'wound_review.png')
print('Wounded contact sheet saved')
