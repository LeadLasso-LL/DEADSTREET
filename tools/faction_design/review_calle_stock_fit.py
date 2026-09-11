"""Inspect the limited SE/SW sniper carry-origin correction without resizing art."""
from pathlib import Path
import json,math,sys,subprocess,copy,xml.etree.ElementTree as E
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
import calle_ocho_outfits as style
import build_art as art
import review_eastex as review
from PIL import Image,ImageDraw

HERE=Path(__file__).parent
OUT=HERE/'calle_ocho'/'stock_fit'
FRAMES=OUT/'frames'

def main():
 FRAMES.mkdir(parents=True,exist_ok=True);(FRAMES/'.gdignore').touch()
 jobs=[];checks=[];models=[m for m in art.MODELS if m['weapon_class']=='sniper']
 for model in models:
  for direction in review.DIRECTIONS:
   for aimed in [0,1]:
    roots=[];definitions=[]
    for fit in [False,True]:
     style.STOCK_FIT=fit
     root=style.make('sniper',model,direction,q=1.25,settle=1,aim=aimed)
     definitions.append(copy.deepcopy(style.rig.equipment.DEFINITIONS[model['art_base']]))
     roots.append(root)
     if direction=='SE':
      packed=E.Element(style.N+'g',transform='translate(0 -6)')
      for child in list(root):root.remove(child);packed.append(child)
      root.append(packed)
      key=model['id']+'_'+str(aimed)+'_'+str(int(fit))
      art.save_svg(root,FRAMES/(key+'.svg'));jobs.append(key)
    assert style.rig.body_signature(roots[0])==style.rig.body_signature(roots[1])
    assert style.rig.lower_signature(roots[0])==style.rig.lower_signature(roots[1])
    for key in ['scale','right_grip','left_grip','muzzle','carry_angle']:
     assert definitions[0][key]==definitions[1][key],(model['id'],direction,key)
    if direction not in ['SE','SW']:assert E.tostring(roots[0])==E.tostring(roots[1])
  # Compare the stock's center with the existing near-shoulder attachment in
  # the ordinary SE aiming pose. Drawing dimensions and angle remain unchanged.
  old,new=definitions
  a=math.radians(15);rot=np.array([[math.cos(a),-math.sin(a)],[math.sin(a),math.cos(a)]])
  butt=np.array([-11 if model['id']=='awm' else -8,6.])
  shoulder=np.array([27.,32.5])
  distances=[float(np.linalg.norm(np.array(d['carry_origin'])+[4,-10]+rot@(butt*d['scale'])-shoulder)) for d in [old,new]]
  assert distances[1]<distances[0],(model['id'],distances)
  checks.append({'model':model['id'],'aiming_stock_to_shoulder_before':round(distances[0],3),'after':round(distances[1],3)})
 style.STOCK_FIT=True
 (OUT/'jobs.json').write_text(json.dumps(jobs))
 subprocess.run([sys.argv[1],'--headless','--path',str(HERE.parents[1]),'--script','res://tools/faction_design/render_eastex.gd','--','res://tools/faction_design/calle_ocho/stock_fit/'],check=True)
 import showcase_finish
 extras=[v[1:] for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]
 extras += [v[1:] for v in style.EXTRA_PALETTE]
 showcase_finish.PAL=np.vstack([showcase_finish.PAL,np.array([tuple(bytes.fromhex(v)) for v in extras])])
 for key in jobs:showcase_finish.finish(FRAMES/(key+'.png'))
 board=Image.new('RGB',(1024,1740),'#151c20');draw=ImageDraw.Draw(board)
 draw.text((24,16),'SNIPER STOCK FIT / SAME BODY AND WEAPON SCALE',font=review.font(23,True),fill='#efeadc')
 labels=['CARRY / BEFORE','CARRY / ADJUSTED','AIM / BEFORE','AIM / ADJUSTED']
 for col,label in enumerate(labels):draw.text((col*256+14,65),label,font=review.font(14,True),fill='#bbc3c3')
 for row,model in enumerate(models):
  y=105+row*270
  draw.text((16,y),model['id'].upper(),font=review.font(17,True),fill='#efeadc')
  for col,(aimed,fit) in enumerate([(0,0),(0,1),(1,0),(1,1)]):
   x=col*256;draw.rectangle((x+8,y+28,x+248,y+261),fill='#2a3335')
   im=Image.open(FRAMES/(model['id']+'_'+str(aimed)+'_'+str(fit)+'.png')).convert('RGBA').resize((256,256),Image.Resampling.NEAREST)
   board.paste(im,(x,y+8),im)
 board.save(OUT/'sniper_stock_comparison.png')
 report={'body_geometry_unchanged':True,'weapon_scale_grips_muzzle_and_angle_unchanged':True,
         'other_six_facings_byte_identical':True,'pose_pairs_checked':96,'comparison_frames':24,
         'scope':'Calle Ocho review sniper, SE and SW; live atlases and older faction art not rebuilt',
         'aiming_stock_center_checks':checks,'render':json.loads((OUT/'render_validation.json').read_text())}
 (OUT/'stock_fit_validation.json').write_text(json.dumps(report,indent=2)+'\n')
 print('STOCK_FIT_REVIEW_COMPLETE',json.dumps(report),flush=True)
if __name__=='__main__':main()
