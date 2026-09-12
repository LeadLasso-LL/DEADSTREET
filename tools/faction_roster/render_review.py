"""Contact sheets from the exact runtime atlases; never redraw accepted units."""
from pathlib import Path
import json
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'tools/faction_roster/review'
POSES=[('STAND SW','idle','sw',0),('STAND FRONT','idle','s',0),('STAND REAR','idle','n',0),('AIM FRONT','aim','s',1),('RELOAD','reload','sw',8),('WOUNDED','wounded_walk','sw',6),('CHECK COMRADE','check_comrade','sw',9),('FALL BACK','death_back','sw',8)]
MODELS={'pistol':'glock_17','smg':'uzi','shotgun':'remington870','rifle':'ak47','sniper':'awm'}
def run():
    OUT.mkdir(exist_ok=True)
    catalog=json.loads((ROOT/'assets/art/units/factions/manifest.json').read_text())
    schema=json.loads((ROOT/'assets/art/units/pixel_v1/manifest.json').read_text())
    factions=json.loads((ROOT/'assets/data/faction_units.json').read_text())['factions']
    mercer=json.loads((ROOT/'assets/art/units/mercer/manifest.json').read_text())
    arsenal=json.loads((ROOT/'assets/art/weapons/arsenal/manifest.json').read_text())
    weapons=json.loads((ROOT/'assets/data/weapon_models.json').read_text())['models']
    # Resolve exact model IDs from the source catalog.
    for role in MODELS:
        if MODELS[role] not in weapons:MODELS[role]=next(k for k,v in weapons.items() if v['weapon_class']==role)
    font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',20)
    titlefont=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',32)
    for faction,data in factions.items():
        target=OUT/(faction+'.png')
        if target.exists():continue
        variants=[catalog['models'][faction+':'+mid] for mid in MODELS.values()]
        if any(v.startswith('faction_') and not (ROOT/'assets/art/units/factions/validation'/(v+'.json')).exists() for v in variants):continue
        board=Image.new('RGB',(2048,1536),'#151d20');draw=ImageDraw.Draw(board)
        draw.text((22,14),data['name'],font=titlefont,fill='#e5e1d5')
        for col,(label,*_) in enumerate(POSES):draw.text((col*256+10,60),label,font=font,fill='#aaa998')
        for row,(role,mid) in enumerate(MODELS.items()):
            v=catalog['models'][faction+':'+mid]
            legacy=False; filename=v
            if v in catalog['variants']:base=ROOT/'assets/art/units/factions'
            elif v in mercer['variants']:base=ROOT/'assets/art/units/mercer'
            elif v in arsenal['variants']:
                base=ROOT/'assets/art/weapons/arsenal';filename=arsenal['variants'][v]['file']
            else:base=ROOT/'assets/art/units/pixel_v1';legacy=True
            atlases={}
            for col,(_,clip,direction,frame) in enumerate(POSES):
                spec=schema['clips'][clip];frame=min(frame,spec['count']-1)
                folder=spec.get('atlas') or 'units'
                if folder not in atlases:atlases[folder]=Image.open(base/('' if legacy and folder=='units' else folder)/(filename+'.png')).convert('RGBA')
                d=schema['directions'].index(direction)
                cell=spec['start']+frame
                x=frame*128 if spec.get('atlas') else cell%32*128
                y=d*128 if spec.get('atlas') else (d*6+cell//32)*128
                sprite=atlases[folder].crop((x,y,x+128,y+128)).resize((256,256),Image.Resampling.NEAREST)
                board.paste(sprite,(col*256,92+row*286),sprite)
                if col==0:draw.text((col*256+10,92+row*286+250),role.upper()+' / '+mid,font=font,fill='#ddd8ca')
        board.save(target)
        print('REVIEW',faction)
if __name__=='__main__':run()
