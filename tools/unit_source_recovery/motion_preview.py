from pathlib import Path
from PIL import Image,ImageDraw
R=Path(__file__).parent
atlas=Image.open(R/'review_atlases/0_uzi_smg.png').convert('RGBA')
def cell(d,i):
 return atlas.crop(((i%32)*128,(d*6+i//32)*128,(i%32+1)*128,(d*6+i//32+1)*128))
for clip,start in [('jog',0),('death',132)]:
 seq=[]
 for i in range(24):
  board=Image.new('RGB',(768,512),'#303938');draw=ImageDraw.Draw(board)
  for j,d in enumerate([0,1,3,4,6,7]):
   x=(j%3)*256;y=(j//3)*256
   sprite=cell(d,start+i).resize((256,256),Image.Resampling.NEAREST)
   board.paste(sprite,(x,y),sprite);draw.text((x+8,y+8),['E','SE','S','SW','W','NW','N','NE'][d],fill='white')
  seq.append(board)
 duration=42 if clip=='jog' else 62
 seq[0].save(R/(clip+'_review.gif'),save_all=True,append_images=seq[1:],duration=([duration]*23+[700] if clip=='death' else duration),loop=0,disposal=2)
 sheet=Image.new('RGB',(1024,512),'#303938')
 for row,d in enumerate([0,1]):
  for col,i in enumerate([0,3,6,9,12,15,18,23]):
   sprite=cell(d,start+i).resize((128,128),Image.Resampling.NEAREST)
   sheet.paste(sprite,(col*128,row*256+40),sprite)
 sheet.save(R/(clip+'_contact.png'))
print('Motion previews saved')
