from pathlib import Path
import json, hashlib, zipfile
from PIL import Image, ImageDraw, ImageFont
R=Path(__file__).resolve().parents[2]
O=Path(__file__).parent; A=R/'tools/portrait_audit_20260914'
rows=json.loads((A/'build_validation.json').read_text(encoding='utf-8'))['rows']
out=O/'review';out.mkdir(exist_ok=True)
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',13)
for faction in dict.fromkeys(x['faction'] for x in rows):
    subset=[x for x in rows if x['faction']==faction]
    board=Image.new('RGB',(1260,((len(subset)+5)//6)*196),'#29363a');d=ImageDraw.Draw(board)
    for i,row in enumerate(subset):
        x=i%6*210;y=i//6*196
        d.text((x+6,y+5),row['model']+(' / DUAL' if row['group']=='specialist' else ''),font=font,fill='white')
        im=Image.open(A/'candidates'/(row['variant']+'.png')).convert('RGBA').resize((180,160),Image.Resampling.NEAREST)
        board.paste(im,(x+15,y+28),im)
    board.save(out/(faction+'.png'))
special=next(x for x in rows if x['group']=='specialist')
print('SPECIALIST',special)
board=Image.new('RGB',(720,320),'#29363a')
for i,p in enumerate([R/special['portrait'],A/'candidates'/(special['variant']+'.png')]):
    im=Image.open(p).convert('RGBA').resize((360,320),Image.Resampling.NEAREST);board.paste(im,(i*360,0),im)
board.save(out/'specialist_before_after.png')
print('REVIEW_READY',len(rows),flush=True)
