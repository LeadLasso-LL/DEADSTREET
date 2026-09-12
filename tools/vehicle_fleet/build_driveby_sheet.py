"""Review sheet of the actual drive-by game sprites with catalog specs."""
from pathlib import Path
import json
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'docs/vehicle_fleet';DATA=json.loads((ROOT/'assets/data/vehicle_models.json').read_text(encoding='utf-8'))['models']
F=Path('/usr/share/fonts/truetype/dejavu');F=F if F.exists() else Path('C:/Windows/Fonts')
def font(n,b=False):return ImageFont.truetype(str(F/(('DejaVuSans-Bold.ttf' if b else 'DejaVuSans.ttf') if (F/'DejaVuSans.ttf').exists() else ('arialbd.ttf' if b else 'arial.ttf'))),n)
BG='#111d24';FG='#ebe5d5';GOLD='#d0b77b';MUTED='#b3c3c7'
im=Image.new('RGB',(1200,2200),BG);d=ImageDraw.Draw(im)
def txt(x,y,s,n=24,color=FG,b=False):d.text((x,y),s,font=font(n,b),fill=color)
def para(x,y,s,width=1050,n=25,color=MUTED):
 words=s.split();line=''
 for word in words:
  candidate=(line+' '+word).strip()
  if line and d.textlength(candidate,font=font(n))>width:txt(x,y,line,n,color);y+=int(n*1.4);line=word
  else:line=candidate
 if line:txt(x,y,line,n,color);y+=int(n*1.4)
 return y
for y,s,n,c,b in [(35,'DEAD STREET / 2034',26,GOLD,True),(82,'HIT. RUIN. KEEP MOVING.',43,FG,True),(145,'Two premium Drive-By vehicles',26,MUTED,False)]:txt(54,y,s,n,c,b)
for i,id in enumerate(['revenant','nocturne']):
 m=DATA[id];y=220+i*915
 d.rounded_rectangle((36,y,1164,y+884),radius=14,fill='#20313a',outline='#40525b',width=2)
 txt(64,y+28,m['name'].upper(),43,FG,True)
 txt(64,y+88,'TWO-WHEELER / TANDEM STREETBIKE' if i==0 else 'PASSENGER CAR / PERFORMANCE SEDAN',22,GOLD,True)
 for direction,x in [('se',70),('nw',620)]:
  a=Image.open(ROOT/f'assets/art/vehicles/fleet/sprites/{id}_{direction}_0.png');a=a.crop(a.getbbox());scale=min(490/a.width,310/a.height);a=a.resize((int(a.width*scale),int(a.height*scale)),Image.Resampling.NEAREST);im.paste(a,(x+(490-a.width)//2,y+140+(340-a.height)//2),a)
 txt(65,y+505,f"${m['price']:,}   /   ${m['upkeep_per_turn']:,} upkeep per turn",29,GOLD,True)
 txt(65,y+556,f"{m['unit_capacity']} SEATS  /  {m['movement_per_turn']:.1f} MOVEMENT  /  NO RESOURCE CARGO",23,FG,True)
 yy=para(65,y+603,m['description'],n=24)
 txt(65,yy+14,'DRIVE-BY',30,GOLD,True)
 yy=para(65,yy+57,'Destroy an undefended roadside business or building, then continue using your remaining movement.',n=26,color=FG)
 para(65,yy+12,'Once per vehicle per turn. Requires a driver and passenger. +30 heat. Defended targets block it; no capture, loot or movement refill.',n=23)
para(54,2073,'All unlocked in the battle sandbox. Ability playable in Encounter Lab; automatic campaign encounter integration remains pending.',width=1090,n=23)
OUT.mkdir(parents=True,exist_ok=True);im.save(OUT/'Drive_By_Vehicles.png')
print('DRIVEBY_SHEET 2 vehicles / actual sprites')
