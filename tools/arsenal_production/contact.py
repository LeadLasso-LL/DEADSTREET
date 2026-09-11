from pathlib import Path
import json
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).resolve().parents[2];H=Path(__file__).parent
models=list(json.loads((R/'assets/data/weapon_models.json').read_text())['models'].values())
im=Image.new('RGB',(1728,1500),'#263135');d=ImageDraw.Draw(im);font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',19)
for i,m in enumerate(models):
 x=i%6*288;y=i//6*300
 d.text((x+12,y+12),m['name'],font=font,fill='#ded7c6')
 s=Image.open(H/'samples'/('0_'+m['id']+'_3_aim_0.png')).resize((256,256),Image.Resampling.NEAREST);im.paste(s,(x+16,y+36),s)
im.save(H/'arsenal_contact.png')
print('CONTACT_READY')
