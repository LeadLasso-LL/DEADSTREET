from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).parent;f=R/'showcase_samples';font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',14)
board=Image.new('RGB',(1152,8*210),'#283134');d=ImageDraw.Draw(board)
for row,direction in enumerate(['E','SE','S','SW','W','NW','N','NE']):
 for col,i in enumerate([0,5,10,15,22,31]):
  x=col*192;y=row*210;d.text((x+8,y+8),direction+' / '+str(i),font=font,fill='#d4d8c9')
  sp=Image.open(f/f'1_ak_rifle_{row}_death_back_{i}.png').resize((192,192),Image.Resampling.NEAREST);board.paste(sp,(x,y+18),sp)
board.save(R/'showcase_death_board.png')
board=Image.new('RGB',(1152,8*160),'#283134');d=ImageDraw.Draw(board)
for row,v in enumerate([f'{k}_{w}' for k in range(2) for w in ['uzi_smg','ak_rifle','pistol','pump_shotgun']]):
 for col,direction in enumerate([0,2,4,5,6,7]):
  x=col*192;y=row*160;d.text((x+6,y+6),v+' / '+str(direction),font=font,fill='#d4d8c9')
  sp=Image.open(f/f'{v}_{direction}_wounded_walk_0.png');board.paste(sp,(x+32,y+24),sp)
board.save(R/'showcase_wounded_board.png')
