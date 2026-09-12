"""Phone sheets and silhouette audit from canonical game sprites, never concept substitutes."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'docs/vehicle_fleet';ART=ROOT/'assets/art/vehicles/fleet'
DATA=json.loads((ROOT/'assets/data/vehicle_models.json').read_text(encoding='utf-8'))
MODELS=DATA['models'];NEW=set(['pulse','cinder','aurelia','solstice','mistral','kestrel','halcyon','torque','dunecat','obsidian','lastlight','dustchapel','relay','concierge'])
REG=next(p for p in [Path('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),Path('C:/Windows/Fonts/arial.ttf')] if p.exists())
BOLD=next(p for p in [Path('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'),Path('C:/Windows/Fonts/arialbd.ttf')] if p.exists())
BG='#142229';PANEL='#25363f';INK='#455a63';FG='#eee8d9';MUTED='#afc2c7';GOLD='#d2b981'
def font(n,bold=False):return ImageFont.truetype(str(BOLD if bold else REG),n)
def fit(text,size,width,bold=False):
    while font(size,bold).getlength(text)>width:size-=1
    return font(size,bold)
def lines(text,width,size=18):
    result=[];line='';f=font(size)
    for word in text.split():
        trial=(line+' '+word).strip()
        if line and f.getlength(trial)>width:result.append(line);line=word
        else:line=trial
    return result+[line]
def sprite(id,facing='se',phase=0):
    im=Image.open(ART/'sprites'/f'{id}_{facing}_{phase}.png').convert('RGBA')
    return im.crop(im.getbbox())
def place(im,art,box,scale_max=4):
    x,y,w,h=box;scale=min(scale_max,w/art.width,h/art.height)
    art=art.resize((round(art.width*scale),round(art.height*scale)),Image.Resampling.NEAREST)
    im.paste(art,(round(x+(w-art.width)/2),round(y+(h-art.height)/2)),art)
def board(filename,title,subtitle,ids):
    rows=(len(ids)+1)//2;im=Image.new('RGB',(1200,177+rows*434+54),BG);d=ImageDraw.Draw(im)
    d.text((36,25),'DEAD STREET  /  2034 MOTOR POOL',font=font(21,True),fill=GOLD)
    d.text((36,63),title,font=fit(title,39,1110,True),fill=FG)
    d.text((36,121),subtitle,font=fit(subtitle,21,1120),fill=MUTED)
    for i,id in enumerate(ids):
        m=MODELS[id];x=30+(i%2)*585;y=177+(i//2)*434
        d.rounded_rectangle((x,y,x+555,y+414),radius=10,fill=PANEL,outline=INK,width=2)
        name=m['name'];d.text((x+19,y+17),name,font=fit(name,27,440,True),fill=FG)
        if id in NEW:d.text((x+482,y+24),'NEW',font=font(16,True),fill=GOLD)
        bike=m['vehicle_class']=='two_wheelers'
        place(im,sprite(id,'e' if bike else 'se'),(x+18,y+63,519,215),5 if bike else 3)
        d.text((x+19,y+290),f"${m['price']:,}  /  {m['unit_capacity']} seats  /  {m['movement_per_turn']:.1f} move",font=font(22,True),fill=GOLD)
        small=f"${m['upkeep_per_turn']}/turn upkeep"
        if m['resource_capacity']:small+=f"  /  {m['resource_capacity']} resource slots"
        d.text((x+19,y+324),small,font=font(18),fill=MUTED)
        desc=lines(m['description'],515,17)
        if len(desc)>2:
            desc=lines(m['description'],515,16);desc=desc[:3];dy=18
        else:dy=22
        for n,line in enumerate(desc):d.text((x+19,y+354+n*dy),line,font=font(16 if dy==18 else 17),fill=MUTED)
    d.text((36,im.height-37),'Seats include the driver. Movement = campaign road distance per turn. All models unlocked.',font=font(18),fill=MUTED)
    im.save(OUT/filename)

def raider_sheet():
    im=Image.new('RGB',(1200,1810),BG);d=ImageDraw.Draw(im)
    d.text((36,26),'DEAD STREET  /  RAIDERS OF THE SAND',font=font(22,True),fill=GOLD)
    d.text((36,72),'SCAVENGED HEAVY TRANSPORT',font=fit('SCAVENGED HEAVY TRANSPORT',41,1120,True),fill=FG)
    d.text((36,132),'Two dedicated builds with proper travel seats and separate freight space.',font=font(22),fill=MUTED)
    for index,id in enumerate(['lastlight','dustchapel']):
        y=200+index*780;m=MODELS[id]
        d.rounded_rectangle((30,y,1170,y+748),radius=12,fill=PANEL,outline=INK,width=2)
        d.text((57,y+24),m['name'].upper(),font=font(37,True),fill=FG)
        place(im,sprite(id,'se'),(55,y+84,1090,390),4)
        place(im,sprite(id,'nw'),(685,y+444,455,236),2)
        d.text((58,y+479),f"${m['price']:,}  /  {m['unit_capacity']} units",font=font(29,True),fill=GOLD)
        d.text((58,y+525),f"{m['resource_capacity']} resource slots  /  {m['movement_per_turn']:.1f} movement",font=font(24),fill=FG)
        for n,line in enumerate(lines(m['description'],580,21)):
            d.text((58,y+576+n*28),line,font=font(21),fill=MUTED)
        d.text((58,y+700),'Front and rear views from the playable asset',font=font(19),fill=MUTED)
    d.text((36,1780),'Only Heavy Transports carry campaign resources. All seats include the driver.',font=font(19),fill=MUTED)
    im.save(OUT/'Fleet_2034_Raiders.png')

def build():
    groups=[
      ('01','TWO-WHEELERS / STREET & CITY',['yardbird','putter','vesper','switchblade','nightjar','pulse']),
      ('02','TWO-WHEELERS / CLUB & DUTY',['badlands','ironhorse','longhaul','cinder','outrider','marshal']),
      ('03','CARS / EVERYDAY & HERITAGE',['rattleback','bayou','civicline','cabrillo','belvedere','kensei','kestrel']),
      ('04','CARS / EXECUTIVE & RESPONSE',['blackwater','monarch','regent','mistral','vigil','interceptor']),
      ('05','CARS / PERFORMANCE & ELECTRIC',['volta','specter','veloce','aurelia','solstice','halcyon']),
      ('06','UTILITY / WORK & EXPEDITION',['workhorse','mesa','backcountry','taiga','outlander','torque','dunecat']),
      ('07','UTILITY / CIVILIAN & AUTHORITY',['rancher','sentinel','crossway','obsidian','watchdog','warden']),
      ('08','HEAVY / COMMERCIAL TRANSPORT',['courier','shuttle','meridian','shortbox','stepmaster','harbor']),
      ('09','HEAVY / DUTY & PRIVATE TRANSPORT',['bastion','uralek','aegis','bulwark','relay','concierge']),
      ('10','HEAVY / THE SCAVENGED FLEET',['wayfarer','pilgrim','lastlight','dustchapel'])]
    seen=[]
    for n,title,ids in groups:
        board(f'Fleet_2034_{n}.png',title,'Revised proportions, authentic faction character, and fourteen new models.',ids);seen+=ids
    assert len(seen)==len(set(seen))==len(MODELS) and set(seen)==set(MODELS)
    board('Fleet_2034_Authorities.png','TRC & NBPD / 2034 RESPONSE','Lower cabins, fuller hoods, visible wheels and current vehicle silhouettes.', ['vigil','interceptor','watchdog','warden','aegis','bulwark'])
    raider_sheet()
    (OUT/'sheets_2034.json').write_text(json.dumps({'models':60,'new_models':sorted(NEW),'sheets':[{"path":f'Fleet_2034_{n}.png',"models":ids} for n,_,ids in groups]},indent=2)+'\n')
    print('FLEET_2034_BOARDS 10 complete-fleet sheets plus authority and raider close-ups')

if __name__=='__main__':build()
