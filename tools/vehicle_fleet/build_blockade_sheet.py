"""Phone sheet composed from the actual eight-direction fleet artwork."""
from pathlib import Path
import json
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'docs/vehicle_fleet';DATA=json.loads((ROOT/'assets/data/vehicle_models.json').read_text())['models']
F=Path('/usr/share/fonts/truetype/dejavu');F=F if F.exists() else Path('C:/Windows/Fonts')
def font(n,b=False):return ImageFont.truetype(str(F/(('DejaVuSans-Bold.ttf' if b else 'DejaVuSans.ttf') if (F/'DejaVuSans.ttf').exists() else ('arialbd.ttf' if b else 'arial.ttf'))),n)
BG='#111d24';FG='#ebe5d5';GOLD='#d0b77b';MUTED='#b3c3c7'
im=Image.new('RGB',(1200,2380),BG);d=ImageDraw.Draw(im)
def txt(x,y,s,n=24,color=FG,b=False):d.text((x,y),s,font=font(n,b),fill=color)
def para(x,y,s,width=1050,n=25,color=MUTED):
 line=''
 for word in s.split():
  candidate=(line+' '+word).strip()
  if line and d.textlength(candidate,font=font(n))>width:txt(x,y,line,n,color);y+=int(n*1.4);line=word
  else:line=candidate
 if line:txt(x,y,line,n,color);y+=int(n*1.4)
 return y
for y,s,n,c,b in [(35,'DEAD STREET / 2034',26,GOLD,True),(82,'HOLD THE ROAD.',43,FG,True),(143,'Two premium blockade support vehicles',26,MUTED,False)]:txt(54,y,s,n,c,b)
for i,id in enumerate(['roadwarden','bloodhound']):
 m=DATA[id];y=220+i*1005
 d.rounded_rectangle((36,y,1164,y+976),radius=14,fill='#20313a',outline='#40525b',width=2)
 txt(64,y+28,m['name'].upper(),40,FG,True)
 txt(64,y+88,'HEAVY TRANSPORT / CHECKPOINT TRUCK' if i==0 else 'UTILITY VEHICLE / PURSUIT SUV',22,GOLD,True)
 for direction,x in [('se',65),('nw',615)]:
  a=Image.open(ROOT/f'assets/art/vehicles/fleet/sprites/{id}_{direction}_0.png');a=a.crop(a.getbbox());scale=min(490/a.width,310/a.height);a=a.resize((int(a.width*scale),int(a.height*scale)),Image.Resampling.NEAREST);im.paste(a,(x+(490-a.width)//2,y+145+(325-a.height)//2),a)
 txt(65,y+501,f"${m['price']:,}   /   ${m['upkeep_per_turn']:,} upkeep per turn",29,GOLD,True)
 txt(65,y+552,f"{m['unit_capacity']} SEATS  /  {m['movement_per_turn']:.1f} MOVEMENT  /  {m['resource_capacity']} CARGO SLOTS",23,FG,True)
 yy=para(65,y+598,m['description'],n=24)
 txt(65,yy+16,m['ability_name'].upper(),30,GOLD,True)
 yy=para(65,yy+61,m['ability_summary'],n=26,color=FG)
 yy=para(65,yy+14,m['ability_limits'],n=23)
 para(65,yy+14,'Stationing costs 1 movement. Minimum 2 actual crew. Withdrawing ends movement until the next turn.',n=22)
para(54,2241,'Both unlocked in the battle sandbox. Encounter Lab includes controlled battles. Automatic campaign encounter generation and outcome dispatch remain pending.',width=1090,n=23)
OUT.mkdir(parents=True,exist_ok=True);im.save(OUT/'Blockade_Support_Vehicles.png');print('BLOCKADE_SHEET 2 actual vehicles')
