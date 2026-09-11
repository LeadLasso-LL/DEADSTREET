"""Assemble a contact sheet from actual production sprites and catalog values."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont
R=Path(__file__).resolve().parents[2]
D=R/'assets/art/weapons/arsenal';H=Path(__file__).parent
M=json.loads((R/'assets/data/weapon_models.json').read_text())['models']
old=json.loads((R/'assets/art/units/pixel_v1/manifest.json').read_text())
mapping=json.loads((D/'manifest.json').read_text())['models']
F=Path('C:/Windows/Fonts')
def font(size,bold=False):return ImageFont.truetype(str(F/('arialbd.ttf' if bold else 'arial.ttf')),size)
im=Image.new('RGB',(1536,1318),'#111b20');draw=ImageDraw.Draw(im)
draw.text((28,22),'DEAD STREET  /  PRODUCTION ARSENAL',font=font(29,True),fill='#e0e1d3')
draw.text((28,65),'30 EQUIPPED MODELS  •  Actual game sprites  •  Provisional game balance',font=font(16),fill='#aebbab')
for row,kind in enumerate(['pistol','smg','rifle','shotgun','sniper']):
 y=111+row*234
 draw.text((28,y),kind.upper(),font=font(19,True),fill='#b4b18c')
 for col,m in enumerate(x for x in M.values() if x['weapon_class']==kind):
  x=28+col*248;cy=y+31
  draw.rounded_rectangle((x,cy,x+238,cy+192),radius=4,fill='#233136',outline='#465954')
  draw.text((x+10,cy+10),f'T{m["tier"]}  {m["name"]}',font=font(14,True),fill='#e0e1d3')
  icon=Image.open(D/'icons'/f'{m["id"]}.png').convert('RGBA');icon.thumbnail((128,63),Image.Resampling.NEAREST);im.paste(icon,(x+7,cy+56),icon)
  v=mapping['1_'+m['id']]
  p=D/'units'/f'1_{m["id"]}.png' if v.startswith('arsenal_') else R/'assets/art/units/pixel_v1/units'/f'{v}.png'
  if not p.exists():
   # Legacy atlas locations follow the original manifest.
   p=R/'assets/art/units/pixel_v1'/f'{v}.png'
  atlas=Image.open(p).convert('RGBA');cell=old['clips']['aim']['start'];d=old['directions'].index('sw');ax=cell%32*128;ay=(d*old['rows_per_direction']+cell//32)*128
  actor=atlas.crop((ax,ay,ax+128,ay+128));actor.thumbnail((104,104),Image.Resampling.NEAREST);im.paste(actor,(x+129,cy+27),actor)
  move=(m['movement_multiplier']-1)*100
  draw.text((x+10,cy+134),f'MOVE {move:+.0f}%     RANGE {m["max_range"]:g}',font=font(12,True),fill='#c4d0bc')
  draw.text((x+10,cy+155),f'SHOT {m["shots_per_second"]:g}/s   SOLID {m["solid_trauma"]:.2f}   CRIT {m["critical_trauma"]:.2f}',font=font(11),fill='#c0c9c7')
  draw.text((x+10,cy+174),f'AIM {m["acquire_seconds"]:.2f}s',font=font(11),fill='#9aacaa')
draw.text((28,1290),'Snipers use existing rifle outfits pending faction art direction. Range and trauma are game units.',font=font(14),fill='#aebbab')
im.save(H/'arsenal_production_board.png')
out=R/'docs/ARSENAL_MODEL_REFERENCE.md';out.parent.mkdir(exist_ok=True)
lines=['# Arsenal model reference','','Thirty models; five fixed unit classes; three weapon tiers; two models per tier. Values are provisional game balance, not manufacturer specifications. Maximum healthy vitality is 1.5. Range is measured in tactical units. Shot pace excludes aim, movement and existing class reload cycles. Movement is relative to existing unit base speed before the cover dash.','','| Class | Tier | Model | Move | Range | Shots/s | Solid trauma | Critical trauma | Initial aim (s) |','|---|---:|---|---:|---:|---:|---:|---:|---:|']
for m in M.values():lines.append(f'| {m["weapon_class"]} | {m["tier"]} | {m["name"]} | {(m["movement_multiplier"]-1)*100:+.0f}% | {m["max_range"]:g} | {m["shots_per_second"]:g} | {m["solid_trauma"]:.2f} | {m["critical_trauma"]:.2f} | {m["acquire_seconds"]:.2f} |')
lines+=['','The JSON catalog also controls hit-quality probabilities, recoil accumulation/recovery, graze trauma and reacquisition time. Weapon weight is a gameplay burden index; it is not a kilogram estimate. Higher tiers are general power bands with model-specific tradeoffs.','','No model-specific magazine capacity or finite tactical ammunition has been added. Existing reload presentation and cycling remain.','','Sniper hits use hit quality → trauma → vitality. A critical hit can kill a healthy unit; a second wound is never an automatic kill. Movement interrupts settled aim. Visible close threats override distant target preference; explicit player focus orders remain authoritative.','','All-black SCAR-H retained. Dedicated sniper outfits and campaign manufacturing/logistics are deferred.']
out.write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('PRODUCTION_BOARD_AND_REFERENCE_COMPLETE')
