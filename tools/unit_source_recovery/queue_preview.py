from pathlib import Path
import json
from PIL import Image,ImageDraw
R=Path(__file__).parent;m=json.loads((R.parent.parent/'assets/art/units/pixel_v1/manifest.json').read_text())
variants=['0_uzi_smg','1_ak_rifle','2_pump_shotgun']
a={v:Image.open(R/'review_atlases'/f'{v}.png').convert('RGBA') for v in variants}
for name,clip,ms in [('jog','walk',30),('wounded','wounded_walk',58),('wounded_breath','wounded_idle',85),('shotgun','fire',65)]:
 seq=[]
 for i in range(24):
  board=Image.new('RGB',(768,512),'#303938');draw=ImageDraw.Draw(board)
  for j,(v,d) in enumerate([(v,d) for d in [0,1] for v in variants]):
   count=m['clips'][clip]['count'];frame=i%count if clip!='fire' else min(i%12,2)
   f=m['clips'][clip]['start']+frame;x=f%32*128;y=(d*6+f//32)*128
   cell=a[v].crop((x,y,x+128,y+128)).resize((256,256),Image.Resampling.NEAREST)
   xx=j%3*256;yy=j//3*256;board.paste(cell,(xx,yy),cell);draw.text((xx+8,yy+8),v+' / '+name,fill='white')
  seq.append(board)
 seq[0].save(R/(name+'_queue.gif'),save_all=True,append_images=seq[1:],duration=ms,loop=0,disposal=2)
print('Queue motion previews saved')
