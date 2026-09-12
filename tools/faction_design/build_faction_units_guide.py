"""Render the existing finalized outfits with faction-specific arsenal selections."""
from pathlib import Path
import copy, importlib, json, subprocess, sys, xml.etree.ElementTree as E
HERE=Path(__file__).parent
ROOT=HERE.parents[1]
sys.path[:0]=[str(HERE),str(ROOT/'tools/arsenal_production'),str(ROOT/'tools/unit_source_recovery')]
OUT=HERE/'faction_units_guide'
FRAMES=OUT/'frames'
ROLES=['pistol','smg','shotgun','rifle','sniper']
LOADOUTS=[
('mercer',['glock_17','mac10','moss500','ak47','sks']),
('eastex',['m1911','uzi','rem870','mini14','rem700']),
('calle_ocho',['cz75','mac10','moss500','ak47','sks']),
('ventresca',['m1911','mp5k','spas12','mini14','ssg69']),
('ravicci',['usp','mp5','benelli_m4','aug','psg1']),
('orlov',['cz75','uzi','saiga12','ak47','svd']),
('zangyaku',['usp','mp5k','benelli_m2','g36c','ssg69']),
('bitian',['cz75','uzi','spas12','ak47','sks']),
('stateline',['m1911','mac10','rem870','mini14','rem700']),
('sierra_roja',['desert_eagle','mp5','saiga12','m4a1','svd']),
('whittaker',['m1911','uzi','rem870','mini14','rem700']),
('mcallister',['usp','mp5','benelli_m2','aug','ssg69']),
('trc',['five_seven','p90','benelli_m4','scar_h','awm']),
('nbpd',['glock_17','mp5','rem870','m4a1','psg1']),
('mercer44',['glock_17','mac10','moss500','m4a1','rem700']),
('wm_corp',['usp','uzi','benelli_m2','scar_h','rem700']),
('union_sur',['five_seven','uzi','saiga12','ak47','svd']),
('lombardia',['cz75','mp5k','benelli_m4','g36c','psg1']),
('sand_raiders',['m1911','mac10','moss500','ak47','sks']),
('saffar',['cz75','mp5','spas12','ak47','svd']),
('kurgan',['cz75','mp5k','saiga12','ak47','svd']),
('ashford_crane',['glock_17','mp5k','benelli_m2','g36c','ssg69']),
('blacktop',['desert_eagle','vector','spas12','m4a1','rem700'])]
POSES=[('standing','SE','idle'),('aiming','SE','aim'),('rear','NW','idle')]
def setup(name):
 import mercer_animation as anim
 originals=copy.deepcopy(anim.outfits.SPECS)
 import build_art as art
 import showcase_build,showcase_finish
 if name not in ['mercer','orlov']:
  style=importlib.import_module(name+'_outfits')
 else:style=None
 return anim,originals,art,showcase_build,showcase_finish,style
def worker(index,mode):
 name,ids=LOADOUTS[index]
 anim,originals,art,show,finish,style=setup(name)
 import numpy as np
 from PIL import Image
 FRAMES.mkdir(parents=True,exist_ok=True)
 (FRAMES/'.gdignore').touch()
 extra=[];jobs=[];metadata=[]
 if style:
  extra=[v[1:] for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]
  extra+=['244d92','3d6bb3','19335d','929c9b','786244','202923','303d28','7f7956','30302a']
  extra += [v.lstrip('#') for v in getattr(style,'EXTRA_PALETTE',[])]
 for role,mid in zip(ROLES,ids):
  model=next(m for m in art.MODELS if m['id']==mid)
  assert model['weapon_class']==role,(name,role,mid)
  if name=='orlov' and role=='sniper':
   style=importlib.import_module('orlov_sniper_outfits')
   extra += [v[1:] for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]
   extra += [v.lstrip('#') for v in style.EXTRA_PALETTE]
  metadata.append({'index':index*5+ROLES.index(role),'faction':name,'role':role,'weapon_id':mid,'weapon_name':model['name'],'weapon_tier':model.get('tier')})
  for pose,direction,clip in POSES:
   key=f'{index:02d}_{role}_{pose}'
   jobs.append(key)
   if mode!='generate':continue
   st=show.state(clip,0,model['art_base']);w=model['art_base']
   if style:
    root=style.make(role,model,direction,**st)
    kind=next((k[0] for k,v in style.outfits.SPECS.items() if v is style.SPECS[role]),getattr(style,'KIND',0))
    costume=style.outfits.SPECS[(kind,w)]
    style.outfits.SPECS[(kind,w)]=style.BASE
    ref=style.directions.make(kind,st['q'],direction,w,**{k:v for k,v in st.items() if k!='q'})
    assert style.rig.body_signature(root)==style.rig.body_signature(ref),(key,'body geometry')
    style.outfits.SPECS[(kind,w)]=costume
   else:
    kind=0 if name=='mercer' else 1
    if (kind,w) in originals:anim.outfits.SPECS[(kind,w)]=copy.deepcopy(originals[(kind,w)])
    else:anim.outfits.SPECS.pop((kind,w),None)
    _,definition=art.bind(model)
    if role=='sniper':
     anim.outfits.SPECS[(kind,w)]=anim.style.SNIPER
     definition['view_lengths']={'S':.80,'N':.72}
    root=anim.directions.make(kind,st['q'],direction,w,**{k:v for k,v in st.items() if k!='q'})
    ref=anim.directions.make(kind,st['q'],direction,w,**{k:v for k,v in st.items() if k!='q'})
    assert anim.style.body_signature(root)==anim.style.body_signature(ref)
   packed=E.Element(art.N+'g',transform='translate(0 -6)')
   for child in list(root):root.remove(child);packed.append(child)
   root.append(packed);art.save_svg(root,FRAMES/(key+'.svg'))
 if mode=='generate':
  (OUT/f'{index:02d}_jobs.json').write_text(json.dumps(jobs))
  (OUT/f'{index:02d}_metadata.json').write_text(json.dumps(metadata))
  (OUT/f'{index:02d}_palette.json').write_text(json.dumps(extra))
 else:
  extra=json.loads((OUT/f'{index:02d}_palette.json').read_text())
  if extra:finish.PAL=np.vstack([finish.PAL,np.array([tuple(bytes.fromhex(v)) for v in extra])])
  for key in jobs:finish.finish(FRAMES/(key+'.png'))
 print(name,mode,len(jobs),flush=True)
def run(mode):
 if mode in ['generate','finish']:
  for i in range(len(LOADOUTS)):subprocess.run([sys.executable,__file__,'worker',str(i),mode],check=True)
 if mode=='generate':
  jobs=sum([json.loads((OUT/f'{i:02d}_jobs.json').read_text()) for i in range(23)],[])
  (OUT/'jobs.json').write_text(json.dumps(jobs))
  metadata=sum([json.loads((OUT/f'{i:02d}_metadata.json').read_text()) for i in range(23)],[])
  assert len(metadata)==115 and len(jobs)==345
  (OUT/'manifest.json').write_text(json.dumps(metadata,indent=2))
 if mode=='finish':
  from PIL import Image
  for pose,_,_ in POSES:
   atlas=Image.new('RGBA',(1280,1536))
   for i in range(115):
    img=Image.open(FRAMES/f'{i//5:02d}_{ROLES[i%5]}_{pose}.png').convert('RGBA')
    assert img.getbbox() is not None
    atlas.paste(img,((i%10)*128,(i//10)*128))
   atlas.save(OUT/f'{pose}_atlas.png')
  print('GUIDE_ATLASES_READY 115 units / 23 factions / 345 poses',flush=True)
if __name__=='__main__':
 if sys.argv[1]=='worker':worker(int(sys.argv[2]),sys.argv[3])
 elif sys.argv[1]=='all':
  run('generate')
  subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe','--headless','--path',str(ROOT),'--script','res://tools/faction_design/render_eastex.gd','--','res://tools/faction_design/faction_units_guide/'],check=True)
  run('finish')
 else:run(sys.argv[1])
