from pathlib import Path
import sys,json,importlib,copy,xml.etree.ElementTree as E
import numpy as np
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
sys.path[:0]=[str(R/'tools/faction_roster'),str(R/'tools/faction_design'),str(R/'tools/arsenal_production'),str(R/'tools/unit_source_recovery'),str(R/'tools/unit_source_recovery/src')]
import build_art as art,showcase_build as show,showcase_finish as finish
profile=sys.argv[1]
style=None if profile in ['mercer','orlov','mercer_sniper','specialist'] else importlib.import_module(profile+'_outfits')
import mercer_preview as rig
sys.path.insert(0,str(O));import portrait_anatomy as repair
inventory=json.loads((O/'inventory.json').read_text());models={m['id']:m for m in art.MODELS}
def profile_of(row):
 if row['group']=='specialist':return 'specialist'
 if row['variant'].startswith('mercer_'):return 'mercer_sniper'
 if row['variant'].startswith('faction_orlov_sniper_'):return 'orlov_sniper'
 return row['faction']
rows=[dict(x,role=models[x['model']]['weapon_class']) for x in inventory if profile_of(x)==profile]
extra=[] if style is None else [v[1:] for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]
extra+=['244d92','3d6bb3','19335d','929c9b','786244','202923','303d28','7f7956','30302a']
if style is not None:extra += [v.lstrip('#') for v in getattr(style,'EXTRA_PALETTE',[])]
palette=finish.PAL if style is None else np.vstack([finish.PAL,np.array([tuple(bytes.fromhex(v)) for v in extra],dtype=np.int32)])
E.register_namespace('',art.N[1:-1]);jobs=[];checks=[]
for row in rows:
 model=models[row['model']];role=model['weapon_class'];w=model['art_base']
 for direction in ['SW','SE']:
  def make():
   st=show.state('idle',0,w)
   if style is not None:return style.make(role,model,direction,**st)
   if profile=='specialist':
    import mercer_animation
    return mercer_animation.dual(direction,**st)
   art.bind(model)
   if profile=='mercer_sniper':rig.outfits.SPECS[(0,w)]=rig.SNIPER
   return art.directions.make(0 if row['faction']=='mercer' else 1,st.pop('q'),direction,w,**st)
  original=make()
  # Existing pistol cards already include the old portrait-only adapter.
  if role=='pistol' and profile!='specialist':
   with repair.corrected(profile in ['mercer','orlov']):baseline=make()
  else:baseline=original
  with repair.corrected(profile in ['mercer','orlov']):candidate=make()
  assert rig.body_signature(original)==rig.body_signature(candidate),(row['variant'],'torso')
  assert rig.lower_signature(original)==rig.lower_signature(candidate),(row['variant'],'lower')
  assert art.anchor(original,'muzzle_anchor')==art.anchor(candidate,'muzzle_anchor')
  if profile!='specialist':assert E.tostring(list(original.find(".//*[@id='upper_pose']"))[-1])==E.tostring(list(candidate.find(".//*[@id='upper_pose']"))[-1]),(row['variant'],'weapon hands')
  checks.append(dict(variant=row['variant'],direction=direction,body_unchanged=True,lower_unchanged=True,weapon_anchors_unchanged=True))
  for name,root in [('before',baseline),('after',candidate)]:
   if name=='before' and direction=='SE':continue
   if row['group'] in ['faction','mercer','specialist']:
    wrap=E.Element(art.N+'g',transform='translate(0 -6)')
    for child in list(root):root.remove(child);wrap.append(child)
    root.append(wrap)
   jobs.append([row['variant']+'_'+direction+'_'+name,E.tostring(root,encoding='unicode')])
(O/'jobs').mkdir(exist_ok=True);(O/'jobs'/(profile+'.json')).write_text(json.dumps({'rows':rows,'jobs':jobs,'palette':palette.tolist(),'checks':checks}),encoding='utf-8')
print('SVG_READY',profile,len(rows),len(jobs),flush=True)
