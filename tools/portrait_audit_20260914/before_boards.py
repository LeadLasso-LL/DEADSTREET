from pathlib import Path
import json,zipfile,hashlib
from PIL import Image,ImageDraw,ImageFont
r=Path(__file__).resolve().parents[2];o=Path(__file__).parent
rows=json.loads((o/'inventory.json').read_text());font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',13)
(o/'before').mkdir(exist_ok=True)
with zipfile.ZipFile(o/'before_portraits.zip','w',zipfile.ZIP_DEFLATED) as z:
 for row in rows:
  p=r/row['portrait'];z.write(p,row['portrait']);im=Image.open(p);row['dimensions']=list(im.size);row['sha256']=hashlib.sha256(p.read_bytes()).hexdigest()
for faction in dict.fromkeys(x['faction'] for x in rows):
 subset=[x for x in rows if x['faction']==faction];board=Image.new('RGB',(1320,((len(subset)+5)//6)*230),'#29363a');d=ImageDraw.Draw(board)
 for i,row in enumerate(subset):
  im=Image.open(r/row['portrait']).convert('RGBA');canvas=Image.new('RGBA',(90,80));canvas.paste(im,(14,18) if im.size==(64,50) else (0,0),im);x=(i%6)*220;y=(i//6)*230;large=canvas.resize((180,160),Image.Resampling.NEAREST);board.paste(large,(x+20,y+40),large);d.text((x+8,y+4),row['model'],font=font,fill='white');d.text((x+8,y+21),faction+' '+str(im.size),font=font,fill='#c5c5bb')
 board.save(o/'before'/(faction+'.png'))
(o/'inventory_before.json').write_text(json.dumps(rows,indent=2));print('BEFORE_BOARDS',len(rows),flush=True)
