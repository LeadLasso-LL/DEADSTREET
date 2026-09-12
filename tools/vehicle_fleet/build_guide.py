"""Illustrated fleet reference from the same catalog and sprites used by the game."""
from pathlib import Path
import json,math,textwrap
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor
from reportlab.lib.utils import ImageReader
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'docs/vehicle_fleet';OUT.mkdir(parents=True,exist_ok=True)
DATA=json.loads((ROOT/'assets/data/vehicle_models.json').read_text(encoding='utf-8'))
MODELS=DATA['models'];FACTIONS=json.loads((ROOT/'assets/data/faction_units.json').read_text(encoding='utf-8'))['factions']
ART=ROOT/'assets/art/vehicles/fleet/icons'
FONT=Path('/usr/share/fonts/truetype/dejavu')
if not FONT.exists():FONT=Path('C:/Windows/Fonts')
regular=FONT/('DejaVuSans.ttf' if (FONT/'DejaVuSans.ttf').exists() else 'arial.ttf')
bold=FONT/('DejaVuSans-Bold.ttf' if (FONT/'DejaVuSans-Bold.ttf').exists() else 'arialbd.ttf')
pdfmetrics.registerFont(TTFont('Body',str(regular)));pdfmetrics.registerFont(TTFont('Bold',str(bold)))
W,H=900,1260;BG='#172228';PANEL='#253239';FG='#e5e1d3';MUTED='#b6c5c7';GOLD='#cab37c';BORDER='#40525b'
c=canvas.Canvas(str(OUT/'Dead_Street_Vehicle_Fleet_Guide.pdf'),pagesize=(W,H));c.setTitle('Dead Street - Vehicle Fleet Guide');c.setAuthor('Dead Street')
page=0
RATIONALES={
'mercer':'Affordable street transport, older full-size cars, and a useful neighborhood van.',
'eastex':'Cheap compacts, a fast solo bike, and practical pickups as the faction grows.',
'calle_ocho':'Classic lowriders and old sedans alongside work pickups and delivery transport.',
'ventresca':'Traditional executive cars, discreet luxury SUVs, and ordinary commercial freight.',
'ravicci':'Conspicuous luxury: formal saloons, scarlet and lime exotics, and premium crew transport.',
'orlov':'Dark executive cars mixed with aged utility 4x4s and surplus heavy transport.',
'zangyaku':'Fast street motorcycles, tuned coupes, and restrained executive support vehicles.',
'bitian':'City scooters, clean compact cars, executive sedans, and commercial cargo vehicles.',
'stateline':'V-twin cruisers and tourers, backed by pickups and a passenger shuttle.',
'sierra_roja':'Flashier civilian vehicles, lifted pickups, luxury SUVs, and versatile crew vans.',
'whittaker':'Work trucks, trail bikes, weathered off-road wagons, and short box trucks.',
'mcallister':'Formal cars and expensive SUVs, with a high-roof van for practical transport.',
'trc':'Branded recon motorcycles, response sedans, black armored utility/transport trucks, and troop logistics.',
'nbpd':'Marked motor-patrol bikes, pursuit sedans, patrol SUVs, and a dedicated SWAT rescue transport.',
'mercer44':'Street bicycles and bikes, lowriders, tuned cars, and pooled SUV/van transport.',
'wm_corp':'McAllister executive vehicles serving alongside Whittaker work trucks and freight haulers.',
'union_sur':'Street-style cars and motorcycles backed by capable pickups and commercial transports.',
'lombardia':'Formal Italian-American luxury supported by unremarkable crew vans and cargo trucks.',
'sand_raiders':'Scavenged transport, including a dedicated prison bus and expedition motorhome with usable freight space.',
'saffar':'A mixture of luxury sedans, practical off-road wagons, SUVs, and commercial transport.',
'kurgan':'Surplus 4x4s, a six-wheel troop truck, trail bikes, and cheap practical support vehicles.',
'ashford_crane':'Ordinary-looking used vehicles and delivery vans suited to an inconspicuous fleet.',
'blacktop':'Cruisers and tourers first, with rough pickups and an old RV following the bikes.'}
def rect(x,y,w,h,color,stroke=None):
 c.setFillColor(HexColor(color));c.setStrokeColor(HexColor(stroke or color));c.rect(x,H-y-h,w,h,fill=1,stroke=bool(stroke))
def text(x,y,value,size=20,color=FG,font='Body'):
 c.setFont(font,size);c.setFillColor(HexColor(color));c.drawString(x,H-y-size,str(value))
def wrap(value,width,size=19,font='Body'):
 result=[];line=''
 for word in value.split():
  attempt=(line+' '+word).strip()
  if line and pdfmetrics.stringWidth(attempt,font,size)>width:result.append(line);line=word
  else:line=attempt
 if line:result.append(line)
 return result
def para(x,y,value,width,size=19,color=MUTED,lineheight=None,font='Body'):
 lines=wrap(value,width,size,font);lh=lineheight or size*1.42
 for i,line in enumerate(lines):text(x,y+i*lh,line,size,color,font)
 return y+len(lines)*lh
def image(id,x,y,w,h):
 im=Image.open(ART/f'{id}.png');factor=min(w/im.width,h/im.height);iw=im.width*factor;ih=im.height*factor
 c.drawImage(ImageReader(im),x+(w-iw)/2,H-y-(h+ih)/2,iw,ih,mask='auto')
def start(title,subtitle):
 global page
 page+=1;rect(0,0,W,H,BG);rect(34,34,7,80,GOLD)
 text(58,29,'DEAD STREET / FLEET GUIDE',14,GOLD,'Bold')
 text(58,53,title,34,FG,'Bold');para(58,101,subtitle,784,16,MUTED)
 rect(34,1190,832,1,BORDER);text(35,1210,'73 models / 4 classes / Fictional game specifications',13,MUTED)
 text(819,1208,f'{page:02d}',16,GOLD,'Bold')
def end():c.showPage()
start('The 2034 fleet','73 vehicles / Campaign transport and tactical arrivals.')
text(58,165,'FROM A $90 BICYCLE TO A TROOP TRANSPORT',21,GOLD,'Bold')
para(58,207,'Civilian vehicles do most of the work. Faction identity comes from the model, condition, and occasional official livery - with broad access in the test sandbox.',780,24,FG)
for id,x,y in [('yardbird',40,340),('halcyon',440,340),('lastlight',40,565),('aegis',440,565)]:
 image(id,x,y,380,190);text(x+18,y+192,MODELS[id]['name'],22,FG,'Bold')
for i,(key,title,n,cap) in enumerate([('two_wheelers','Two-Wheelers',15,'1-2'),('passenger_cars','Passenger Cars',22,'1-4'),('utility_vehicles','Utility Vehicles',15,'1-7'),('heavy_transports','Heavy Transports',21,'1-12')]):
 x=40+(i%2)*420;y=850+(i//2)*130;rect(x,y,402,112,PANEL,BORDER)
 text(x+17,y+13,title,22,GOLD,'Bold');text(x+17,y+52,f'{n} models / {cap} units',21)
para(58,1127,'Prices and upkeep are the first balance pass. Flagship abilities are explicit. Luxury prices do not grant hidden combat bonuses.',780,17)
end()
start('How the fleet works','Shared rules for every model in this guide.')
rules=[('Seats include the driver','A four-seat car moves four of your units in total. Every moving vehicle needs one actual unit to drive or ride it; no free extra driver is created.'),('Travel uses road distance per turn','The movement number is campaign distance, not real-world mph. A convoy moves at the pace of its slowest vehicle. Splitting a convoy can preserve the speed of its faster group.'),('Heavy Transports carry all freight','Only this class can load campaign resources. Cargo is counted in abstract resource slots. Passenger capacity and cargo capacity are separate, simultaneously usable limits. Independent cash trucks and prison carriers use dedicated manifests instead of general freight.'),('Real seats, realistic compromises','Pickup beds are not troop seats. The Shortbox 11 has two cab seats and 24 cargo slots. The Shuttle Twelve has twelve seats but just two cargo slots.'),('Parked vehicles and cover','These are arrival vehicles with parked physical footprints. Two-wheelers provide no vehicle cover. No turrets, mounted guns, hidden unit armor, or vehicle-driven outfit changes are added.'),('Everything is available in the sandbox','All 73 models are unlocked. The faction lists are suggestions, not restrictions. The current sandbox convoy builder carries the five attacking units; defenders occupy the existing objective.'),('2034, with intentional older vehicles','Modern vehicles have lower glass, sculpted bodywork and contemporary lighting. Heritage cars and scavenged transports remain where they suit the faction. Fuel, charging and repair interfaces are later systems. Flagship abilities are playable in Encounter Lab; campaign event generation is not connected yet.')]
y=163
for heading,body in rules:
 text(58,y,heading,22,GOLD,'Bold');y=para(58,y+34,body,783,18,FG,24)+20
end()
card_index=0
for key,info in DATA['classes'].items():
 group=[m for m in MODELS.values() if m['vehicle_class']==key]
 for offset in range(0,len(group),4):
  count=min(4,len(group)-offset)
  start(info['name'],f'Models {offset+1}-{offset+count} of {len(group)} / Movement = road distance per turn / Seats include driver')
  for j,m in enumerate(group[offset:offset+4]):
   top=160+j*249;rect(34,top,832,232,PANEL,BORDER);card_index+=1
   image(m['id'],46,top+17,294,167)
   text(54,top+198,f"{m['length']:.2f} x {m['width']:.2f} m footprint",15,MUTED)
   x=363;text(x,top+12,m['name'],min(25,440/max(1,pdfmetrics.stringWidth(m['name'],'Bold',1))),FG,'Bold')
   text(x,top+55,f"${m['price']:,} purchase",23,GOLD,'Bold')
   text(x+275,top+61,f"${m['upkeep_per_turn']}/turn",17,MUTED)
   text(x,top+93,f"{m['unit_capacity']} seats   |   {m['movement_per_turn']:.1f} movement",21,FG)
   text(x,top+128,f"{m['resource_capacity']} resource slots" if m['resource_capacity'] else 'No campaign freight',18,GOLD if m['resource_capacity'] else MUTED)
   para(x,top+163,m['description'],470,16,MUTED,21)
  if count<4:
   yy=160+count*249
   para(58,yy+18,'The illustrations are fitted to each card for readability. Tactical footprints use each model\'s listed length and width.',780,19)
  end()
keys=list(DATA['faction_preferences'])
for offset in range(0,len(keys),6):
 start('Faction motor pools',f'Suggested choices / {offset+1}-{min(offset+6,len(keys))} of 23 factions / Every model remains available')
 for i,key in enumerate(keys[offset:offset+6]):
  y=159+i*170;rect(34,y,832,155,PANEL,BORDER)
  text(50,y+10,FACTIONS[key]['name'],22,GOLD,'Bold')
  names=' / '.join(MODELS[id]['name'] for id in DATA['faction_preferences'][key])
  ny=para(50,y+47,names,796,18,FG,25)
  para(50,ny+8,RATIONALES[key],796,16,MUTED,22)
 end()
c.save()
# Searchable source tables and decisions, generated alongside the illustrations.
lines=['# Dead Street - Vehicle Fleet','', '73 fictional vehicle models across four classes. Initial balance values; all models unlocked in the battle sandbox.','', 'Seats include the driver. One unit is reserved to drive each vehicle. Only Heavy Transports carry campaign resources. Convoy road speed is its slowest vehicle.','']
for key,info in DATA['classes'].items():
 lines+=['## '+info['name'],'','| Model | Price | Upkeep / turn | Seats | Road units / turn | Cargo slots | Footprint (m) |','|---|---:|---:|---:|---:|---:|---|']
 for m in MODELS.values():
  if m['vehicle_class']==key:lines.append(f"| {m['name']} | ${m['price']:,} | ${m['upkeep_per_turn']} | {m['unit_capacity']} | {m['movement_per_turn']:.1f} | {m['resource_capacity']} | {m['length']:.2f} x {m['width']:.2f} |")
 lines.append('')
lines+=['## Suggested faction fleets','','| Faction | Suggested models | Reason |','|---|---|---|']
for key,ids in DATA['faction_preferences'].items():lines.append('| '+FACTIONS[key]['name']+' | '+', '.join(MODELS[id]['name'] for id in ids)+' | '+RATIONALES[key]+' |')
lines+=['','## Rules and boundaries','']
for heading,body in rules:lines+=['- **'+heading+':** '+body]
lines+=['','## Balance examples','','- Five units on five Yardbird bicycles: $450 total, zero upkeep, 1 road unit per turn.','- Five units in one Rancher Seven: $22,500, $61 per turn, 4.7 road units per turn, two spare seats.','- Twelve units in one Shuttle Twelve: $24,500, $76 per turn, 3.9 movement, two cargo slots.','- One Meridian Highroof and one Shortbox 11: ten seats, thirty cargo slots, $63,500 purchase and $184 per turn. Convoy movement is 3.2.','- A fast car escorting a slow freight truck inherits the truck\'s road pace while grouped.','','## Implementation status','','The catalog and artwork use the same model IDs as the sandbox fleet selector. Current validation results are recorded in tools/vehicle_fleet/validation.json, validation_mixed.json and native_review/report.json; see tools/vehicle_fleet/README.md for the reviewed milestone. Two-wheelers currently use parked tactical arrivals; riding, pedaling and mounted-passenger animations are not yet authored. Four-wheel vehicles use the existing arrival presentation with model-specific directional and door art. Repository history records commit and push status.','']
lines+=['## Endgame abilities','', 'Ten premium vehicles have encounter rules. The Encounter Lab is available from the fleet selector. Automatic campaign events and battle ability triggers remain future integration work.', '', '| Vehicle | Ability | Effect | Limits |', '|---|---|---|---|']
for m in MODELS.values():
 if m.get('endgame'):lines.append(f"| {m['name']} | {m['ability_name']} | {m['ability_summary']} | {m['ability_limits']} |")
lines+=['', 'Independent services: Sterling CIT-4 carries $75,000 with 3 crew; Sterling Bastion Reserve carries $300,000 with 4 crew; Custodian P8 carries 3 guards plus 8 prisoners. Cash debits source on dispatch and credits one destination or victorious captor exactly once. Prisoner rescue preserves original allegiance. These three are unlocked for sandbox encounters but excluded from faction purchasing.', '']
(OUT/'Fleet_Specifications.md').write_text('\n'.join(lines),encoding='utf-8')
# All-model overview, at one consistent physical scale (40 pixels per meter).
overview_models=list(MODELS.values())
overview_images={m['id']:Image.open(ART/f"{m['id']}.png") for m in overview_models}
row_heights=[max(overview_images[m['id']].height for m in overview_models[i:i+5])+95 for i in range(0,len(overview_models),5)]
poster=Image.new('RGB',(1800,150+sum(row_heights)+20),BG);draw=ImageDraw.Draw(poster)
f=lambda n:ImageFont.truetype(str(bold),n)
draw.text((45,30),'DEAD STREET / THE VEHICLE FLEET',fill=FG,font=f(42))
draw.text((47,88),'73 models - consistent illustration scale - 4 transport classes',fill=MUTED,font=ImageFont.truetype(str(regular),22))
for i,m in enumerate(overview_models):
 row=i//5;x=(i%5)*350+25;y=150+sum(row_heights[:row]);art_bottom=y+row_heights[row]-80
 im=overview_images[m['id']]
 poster.paste(im,(x+(340-im.width)//2,art_bottom-im.height),im)
 draw.text((x+10,art_bottom+10),m['name'],fill=FG,font=f(20))
 seats='seat' if m['unit_capacity']==1 else 'seats'
 draw.text((x+10,art_bottom+38),f"${m['price']:,} / {m['unit_capacity']} {seats} / {m['movement_per_turn']:.1f} move",fill=MUTED,font=ImageFont.truetype(str(regular),15))
poster.save(OUT/'Fleet_Overview.png')
print('GUIDE',page,'pages',card_index,'model cards',len(keys),'faction motor pools')
