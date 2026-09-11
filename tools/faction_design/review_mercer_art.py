"""Review native game frames at one fixed scale; never auto-fit a character."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont
R=Path(__file__).resolve().parents[2]
D=R/'assets/art/units/mercer'; H=Path(__file__).parent
M=json.loads((R/'assets/art/units/pixel_v1/manifest.json').read_text())
M['clips'].update(json.loads((D/'manifest.json').read_text())['clips'])
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',17)
cache={}
def frame(model,direction,clip,index):
 spec=M['clips'][clip];folder=spec.get('atlas','units')
 key=(model,folder)
 if key not in cache:cache[key]=Image.open(D/folder/('mercer_'+model+'.png')).convert('RGBA')
 d=M['directions'].index(direction);cell=spec['start']+index
 x=index*128 if folder!='units' else cell%32*128
 y=d*128 if folder!='units' else (d*6+cell//32)*128
 return cache[key].crop((x,y,x+128,y+128))
def board(rows,name):
 im=Image.new('RGB',(2048,len(rows)*276),'#283235');draw=ImageDraw.Draw(im)
 for row,(model,clip,index) in enumerate(rows):
  for col,direction in enumerate(M['directions']):
   a=frame(model,direction,clip,index).resize((256,256),Image.Resampling.NEAREST)
   im.paste(a,(col*256,row*276+20),a)
   draw.text((col*256+5,row*276+3),f'{model} / {direction} / {clip}',font=font,fill='#eeead6')
 im.save(H/name)
board([(model,'idle',0) for model in ['dual_glock','rem700','sks','svd','ssg69','awm','psg1']], 'mercer_standing_review.png')
board([('dual_glock',clip,i) for clip,i in [('aim',0),('fire',0),('fire_left',0),('reload',9),('reload',29),('wounded_walk',6),('death_back',20)]], 'mercer_motion_review.png')
frames=[]
segments=[('idle',.8),('walk',1.6),('aim',.8),('alternating fire',1.8),('reload',3.),('cover_fire',.8),('wounded_walk',1.4),('death_back',1.4)]
for label,seconds in segments:
 for tick in range(round(seconds*20)):
  im=Image.new('RGB',(1152,626),'#1b2529');draw=ImageDraw.Draw(im)
  draw.text((20,12),'MERCER SAINTS  /  '+label.upper(),font=font,fill='#eeead6')
  for row,model in enumerate(['dual_glock','rem700']):
   for col,direction in enumerate(['sw','s','ne']):
    clip=label
    if label=='alternating fire':
     cycle=tick%12;clip='fire_left' if model=='dual_glock' and cycle>=6 else 'fire'
     index=min(2,cycle%6) if model=='dual_glock' else min(2,tick%40)
    else:
     spec=M['clips'][clip]
     index=int(tick/20*spec['fps'])
     if clip=='reload':index=min(39,int(tick/(seconds*20)*40))
     elif spec['loop']:index%=spec['count']
     else:index=min(index,spec['count']-1)
    a=frame(model,direction,clip,index).resize((256,256),Image.Resampling.NEAREST)
    im.paste(a,(col*384+64,48+row*284),a)
    draw.text((col*384+22,38+row*284),f'{model} / {direction.upper()}',font=font,fill='#b7c0b9')
  frames.append(im)
frames[0].save(H/'mercer_animation_review.gif',save_all=True,append_images=frames[1:],duration=50,loop=0,optimize=True)
print('REVIEW_ART_COMPLETE',len(frames),'animation frames')
