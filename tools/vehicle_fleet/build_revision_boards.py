"""Phone-friendly revision cards built directly from the shipped sprites."""
from pathlib import Path
import json
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'docs/vehicle_fleet';ART=ROOT/'assets/art/vehicles/fleet'
MODELS=json.loads((ROOT/'assets/data/vehicle_models.json').read_text())['models']
regular=next(p for p in [Path('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),Path('C:/Windows/Fonts/arial.ttf')] if p.exists())
bold=next(p for p in [Path('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'),Path('C:/Windows/Fonts/arialbd.ttf')] if p.exists())
BG='#172228';PANEL='#253239';FG='#e5e1d3';MUTED='#b6c5c7';GOLD='#cab37c'
def font(n,strong=False):return ImageFont.truetype(str(bold if strong else regular),n)
def board(filename,title,subtitle,ids,notes,columns=None):
 rows=(len(ids)+1)//2;top=210 if columns else 172;cell=380
 im=Image.new('RGB',(1100,top+rows*cell+45),BG);d=ImageDraw.Draw(im)
 d.text((35,25),'DEAD STREET / FLEET UPDATE',font=font(19,True),fill=GOLD)
 d.text((35,64),title,font=font(36,True),fill=FG)
 d.text((35,118),subtitle,font=font(20),fill=MUTED)
 if columns:
  for c,label in enumerate(columns):d.text((40+c*535,167),label,font=font(24,True),fill=GOLD)
 for i,id in enumerate(ids):
  m=MODELS[id];x=30+(i%2)*535;y=top+(i//2)*cell
  d.rounded_rectangle((x,y,x+505,y+358),radius=8,fill=PANEL,outline='#42515a',width=2)
  d.text((x+18,y+15),m['name'],font=font(25,True),fill=FG)
  bike=m['vehicle_class']=='two_wheelers'
  sprite=Image.open(ART/'sprites'/f"{id}_{'e' if bike else 'se'}_0.png").convert('RGBA');sprite=sprite.crop(sprite.getbbox())
  scale=min(4 if bike else 3,450//sprite.width,200//sprite.height);scale=max(1,scale)
  sprite=sprite.resize((sprite.width*scale,sprite.height*scale),Image.Resampling.NEAREST)
  if sprite.height>200:sprite=sprite.resize((round(sprite.width*200/sprite.height),200),Image.Resampling.NEAREST)
  im.paste(sprite,(x+(505-sprite.width)//2,y+61+(191-sprite.height)//2),sprite)
  d.text((x+18,y+258),f"{m['unit_capacity']} {'seat' if m['unit_capacity']==1 else 'seats'}  /  ${m['price']:,}  /  {m['movement_per_turn']:.1f} move",font=font(20),fill=GOLD)
  for j,line in enumerate(notes[i]):d.text((x+18,y+293+j*24),line,font=font(18),fill=MUTED)
 d.text((35,im.height-29),'Seats include the driver. Movement is road distance per campaign turn.',font=font(16),fill=MUTED)
 im.save(OUT/filename)
board('Fleet_Motorcycles_Revision.png','MOTORCYCLES','Exposed wheels, compact exhausts, distinct riding layouts.',
 ['switchblade','nightjar','ironhorse','longhaul','outrider','marshal'],
 [['Cobalt solo sportbike','Low bars and a tapered tail'],['Scarlet superbike','Low bars, raised passenger pad'],['Black V-twin cruiser','Raked forks and a low saddle'],['Burgundy touring cruiser','Windshield and compact saddlebags'],['TRC reconnaissance bike','Black/green body, gold markings'],['NBPD motor-patrol bike','POLICE cases and emergency lights']])
board('Fleet_Exotics_Luxury_Revision.png','EXOTICS & LUXURY','Brighter paint, sculpted fenders, lower sporting silhouettes.',
 ['veloce','specter','volta','monarch','regent','sentinel'],
 [['Scarlet mid-engine exotic','Swept lamps and deep side intakes'],['Acid-lime supercar','Wide wedge body and black canopy'],['Azure grand tourer','Long hood and rearward cabin'],['Plum-and-ivory flagship','Formal chrome grille and luxury trim'],['Champagne chauffeur sedan','Burgundy roof and long rear doors'],['Pearl-white luxury SUV','Black roof and bronze wheels']])
board('Fleet_Authorities_Revision.png','OFFICIAL FLEETS','A dedicated branded vehicle in every class for both authorities.',
 ['outrider','marshal','vigil','interceptor','watchdog','warden','aegis','bulwark'],
 [['TWO-WHEELER','Gold TRC markings'],['TWO-WHEELER','Green/white police livery'],['PASSENGER CAR','Black response sedan'],['PASSENGER CAR','Pursuit sedan and roof lightbar'],['UTILITY VEHICLE','Black armored utility truck'],['UTILITY VEHICLE','Green/white patrol SUV'],['HEAVY TRANSPORT','10 seats plus 8 resource slots'],['HEAVY TRANSPORT','8 seats plus 6 resource slots']],['TEXAS RECOVERY COALITION','NEW BRIARPORT POLICE'])
print('FLEET_REVISION_BOARDS 3')
