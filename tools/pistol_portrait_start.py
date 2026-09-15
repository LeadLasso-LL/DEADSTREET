from pathlib import Path
import json,hashlib,subprocess,zipfile
from PIL import Image,ImageDraw,ImageFont
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/pistol_portrait_20260914';o.mkdir(exist_ok=True)
paths={'factions':'assets/art/units/factions','mercer':'assets/art/units/mercer','arsenal':'assets/art/weapons/arsenal','base':'assets/art/units/pixel_v1'};m={k:json.loads((r/v/'manifest.json').read_text(encoding='utf-8')) for k,v in paths.items()};models=json.loads((r/'assets/data/weapon_models.json').read_text())['models'];pistols=[k for k,v in models.items() if v['weapon_class']=='pistol'];rows=[]
for binding,variant in m['factions']['models'].items():
 faction,model=binding.split(':')
 if model not in pistols:continue
 group=next((g for g in ['factions','mercer','arsenal'] if variant in m[g]['variants']),'base');name=m[group]['variants'][variant].get('file',variant) if group!='base' else variant;root=r/paths[group]
 rows.append(dict(faction=faction,model=model,variant=variant,group=group,file=name,portrait=(root/'portraits'/(name+'.png')).relative_to(r).as_posix(),atlas=(root/('' if group=='base' else 'units')/(name+'.png')).relative_to(r).as_posix()))
rows.append(dict(faction='mercer_dual',model='dual_glock',variant='mercer_dual_glock',group='mercer',file='mercer_dual_glock',portrait='assets/art/units/mercer/portraits/mercer_dual_glock.png',atlas='assets/art/units/mercer/units/mercer_dual_glock.png'))
(o/'inventory.json').write_text(json.dumps(rows,indent=2),encoding='utf-8');assert all((r/x['portrait']).exists() and (r/x['atlas']).exists() for x in rows)
with zipfile.ZipFile(o/'before_portraits.zip','w') as z:
 for row in rows:z.write(r/row['portrait'],row['portrait'])
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',17);selected=[x for x in rows if x['model'] in ['glock_17','dual_glock']];dirs=m['base']['directions'];cell=m['base']['clips']['idle']['start'];print('INVENTORY',len(rows),'FACTIONS',len(set(x['faction'] for x in rows)),'DIRS',dirs,'CELL',cell,flush=True)
for page in range((len(selected)+11)//12):
 im=Image.new('RGB',(1080,930),'#263033');draw=ImageDraw.Draw(im)
 for i,row in enumerate(selected[page*12:(page+1)*12]):
  x=i%3*360;y=30+i//3*220;draw.text((x+12,y),row['faction']+' / SW             SE',font=font,fill='#e7e0ce');atlas=Image.open(r/row['atlas']).convert('RGBA')
  for col,direction in enumerate(['sw','se']):
   xx=cell%32*128;yy=(dirs.index(direction)*m['base']['rows_per_direction']+cell//32)*128;frame=atlas.crop((xx+18,yy+6,xx+108,yy+86)).resize((180,160),Image.Resampling.NEAREST);im.paste(frame,(x+col*180,y+28),frame)
 im.save(o/('before_roster_'+str(page)+'.png'))
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write('\n\n## 20260914-pistol-portrait-01 - Owner requests narrow anatomy correction\n\nBrandon requests all pistol-unit card artwork in SW/SE be inspected for missing right forearms and detached left shoulders, with the visible SW forearm repaired across the full unit stack and no new anatomy faults. Verified HEAD 54b1597, mixed working tree preserved. BUILD chat owns tools/pistol_portrait_20260914 and the required portrait generator/assets only; separate menu-title preview scope remains untouched. Shared cards load static portraits; SW is an intentional reflection of SE. Inventory and before images are being created from installed assets. Fix selection awaits visual inspection; no battle behavior or broad anatomy redesign authorized.\n')
p=r/'docs/DEAD_STREET_HIVE_MIND.md';s=p.read_text(encoding='utf-8');a=s.index('**Active objective:**');b=s.index('\n\n',a);s=s[:a]+'**Active objective:** BUILD chat auditing and repairing pistol-card SW/SE forearms and shoulder continuity across all installed faction/model variants. Preserve established anatomy, other unit art and accepted battle. See journal pistol-portrait-01.'+s[b:];a=s.index('**Immediate next task:**');b=s.index('\n\n',a);s=s[:a]+'**Immediate next task:** Inspect installed pistol portraits, identify the shared missing-arm cause, repair the narrow card-art source, regenerate affected portraits and visually verify both angles before scoped publication.'+s[b:];s=s.replace('Version-5 video 88.197s','Version-6 video 88.197s');p.write_text(s,encoding='utf-8')