"""Phone review sheets from the exact game sprites and data; no painted substitutes."""
from pathlib import Path
import json,textwrap
from PIL import Image,ImageDraw,ImageFont
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.utils import ImageReader
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'docs/vehicle_fleet/endgame';OUT.mkdir(parents=True,exist_ok=True)
MODELS=json.loads((ROOT/'assets/data/vehicle_models.json').read_text(encoding='utf-8'))['models']
SPRITES=ROOT/'assets/art/vehicles/fleet/sprites'
F=Path('/usr/share/fonts/truetype/dejavu');F=F if F.exists() else Path('C:/Windows/Fonts')
def font(n,bold=False):
 name=('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf') if (F/'DejaVuSans.ttf').exists() else ('arialbd.ttf' if bold else 'arial.ttf')
 return ImageFont.truetype(str(F/name),n)
BG='#111d24';FG='#ebe5d5';MUTED='#adc0c5';GOLD='#d0b77b';PANEL='#20313a'
GROUPS=[('01','TWO-WHEELERS',['wraith_zero','crownfire']),('02','PASSENGER CARS',['eidolon','asterion']),('03','UTILITY VEHICLES',['nomad','archangel']),('04','HEAVY TRANSPORTS',['leviathan','palisade']),('05','INDEPENDENT SERVICES',['sterling_cit','sterling_reserve','custodian'])]
pdf=Canvas(str(OUT/'Dead_Street_Endgame_Fleet.pdf'),pagesize=(600,1040));pdf.setTitle('Dead Street / Endgame Fleet and Independent Services')
coverage=[]
def wrapped(draw,txt,x,y,width,size=24,color=MUTED):
 line='';lines=[]
 for word in txt.split():
  test=(line+' '+word).strip()
  if draw.textlength(test,font=font(size))>width and line:lines.append(line);line=word
  else:line=test
 if line:lines.append(line)
 for line in lines:draw.text((x,y),line,font=font(size),fill=color);y+=int(size*1.35)
 return y
for number,title,ids in GROUPS:
 height=220+len(ids)*840+110
 im=Image.new('RGB',(1200,height),BG);d=ImageDraw.Draw(im)
 d.text((54,34),'DEAD STREET / 2034',font=font(25,True),fill=GOLD)
 d.text((54,78),title,font=font(43,True),fill=FG)
 d.text((54,141),'ENDGAME COLLECTION' if number!='05' else 'BANK RUNS & PRISONER TRANSFERS',font=font(23),fill=MUTED)
 for row,id in enumerate(ids):
  m=MODELS[id];coverage.append(id);y=220+row*840
  d.rounded_rectangle((36,y,1164,y+811),radius=12,fill=PANEL,outline='#3c5059',width=2)
  d.text((64,y+24),m['name'].upper(),font=font(35,True),fill=FG)
  d.text((64,y+77),f"${m['price']:,}  |  ${m['upkeep_per_turn']:,} upkeep / turn",font=font(25,True),fill=GOLD)
  for facing,x in [('se',68),('nw',620)]:
   source=Image.open(SPRITES/f'{id}_{facing}_0.png').convert('RGBA');source=source.crop(source.getbbox())
   scale=min(490/source.width,280/source.height);source=source.resize((int(source.width*scale),int(source.height*scale)),Image.Resampling.NEAREST)
   im.paste(source,(x+(490-source.width)//2,y+142+(290-source.height)//2),source)
  d.text((65,y+456),f"{m['unit_capacity']} {'GUARD SEATS' if id=='custodian' else 'SEATS'}    /    {m['movement_per_turn']:.1f} ROAD UNITS PER TURN",font=font(24,True),fill=FG)
  detail=f"{m['resource_capacity']} RESOURCE SLOTS" if m['resource_capacity'] else 'NO CAMPAIGN RESOURCE FREIGHT'
  if m.get('cash_capacity'):detail=f"${m['cash_capacity']:,} CASH CAPACITY  /  {m['unit_capacity']} SECURITY CREW"
  if id=='custodian':detail='8 SEPARATE PRISONER POSITIONS / 11 TOTAL OCCUPANTS'
  d.text((65,y+499),detail,font=font(23),fill=MUTED)
  if m.get('endgame'):
   d.text((65,y+551),m['ability_name'].upper(),font=font(29,True),fill=GOLD)
   yy=wrapped(d,m['ability_summary'],65,y+597,1060,25,FG)
   wrapped(d,m['ability_limits'],65,yy+14,1060,23,MUTED)
  else:
   d.text((65,y+551),'INDEPENDENT WORLD SERVICE',font=font(27,True),fill=GOLD)
   desc={'sterling_cit':'Urban cash collection truck. Bank funds move physically and can be stolen after a successful interception.','sterling_reserve':'High-value armored cash transport with a four-person security crew. Three hundred thousand dollars at risk in one shipment.','custodian':'Guard seats and prisoner cells are counted separately. Successful rescue frees surviving prisoners with their original allegiances.'}[id]
   yy=wrapped(d,desc,65,y+597,1060,25,FG)
   wrapped(d,'Sandbox selection enabled. Purchase price is reference value; independent services are not sold through faction purchasing.',65,yy+14,1060,22,MUTED)
 d.text((54,height-89),'Actual game sprites · All unlocked in the sandbox · Seats include drivers',font=font(21),fill=MUTED)
 d.text((54,height-53),'Ability rules playable in Encounter Lab; campaign event triggers pending.',font=font(21),fill=GOLD)
 target=OUT/f'{number}_{title.lower().replace(" ","_").replace("-","_")}.png';im.save(target)
 pdf.setPageSize((600,height/2));pdf.drawImage(ImageReader(im),0,0,600,height/2);pdf.showPage()
pdf.save()
assert len(coverage)==11 and len(set(coverage))==11
(OUT/'coverage.json').write_text(json.dumps({'models':coverage,'sheets':5},indent=2))
print('ENDGAME_BOARDS 5 sheets / 11 models')
