"""Build model-specific art using the existing outfit and eight-direction rig."""
from pathlib import Path
import sys,json,copy,re,math,xml.etree.ElementTree as E
import numpy as np
R=Path(__file__).resolve().parents[2];SRC=R/'tools/unit_source_recovery';HERE=Path(__file__).parent
sys.path[:0]=[str(HERE),str(SRC),str(SRC/'src')]
import equipment,directions,showcase_build
from weapon_art import make,draw_art
N='{http://www.w3.org/2000/svg}'
MODELS=json.loads((R/'assets/data/weapon_models.json').read_text())['models'].values()
MANIFEST=json.loads((R/'assets/art/units/pixel_v1/manifest.json').read_text())
ORIGINAL=copy.deepcopy(equipment.DEFINITIONS);OLD_DRAW=equipment.draw
DEST=R/'assets/art/weapons/arsenal';DEST.mkdir(parents=True,exist_ok=True)
for folder in ['source','icons','portraits','units','death_back','check_comrade','anchors']:(DEST/folder).mkdir(exist_ok=True)

def transform(s):
 out=np.eye(3)
 for name,args in re.findall(r'(\w+)\(([^)]+)\)',s):
  a=[float(v) for v in re.findall(r'[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?',args)];m=np.eye(3)
  if name=='translate':m[:2,2]=[a[0],a[1] if len(a)>1 else 0]
  elif name=='scale':m[0,0]=a[0];m[1,1]=a[1] if len(a)>1 else a[0]
  elif name=='matrix':m=np.array([[a[0],a[2],a[4]],[a[1],a[3],a[5]],[0,0,1]])
  elif name=='rotate':
   t=math.radians(a[0]);m[:2,:2]=[[math.cos(t),-math.sin(t)],[math.sin(t),math.cos(t)]]
   if len(a)==3:m[:2,2]=np.array(a[1:])-m[:2,:2]@a[1:]
  out=out@m
 return out

def anchor(node,name,parent=None):
 m=(np.eye(3) if parent is None else parent)@transform(node.get('transform',''))
 if node.get('id')==name:return [round(float(v),3) for v in (m@np.array([float(node.get('cx')),float(node.get('cy')),1]))[:2]]
 for c in node:
  result=anchor(c,name,m)
  if result is not None:return result
 return None

def bind(model):
 art,definition=make(model,ORIGINAL);w=model['art_base'];equipment.DEFINITIONS[w]=definition
 def draw(parent,weapon_id,reload=0):
  if model['id'] in ['glock_17','uzi','ak47','rem870']:OLD_DRAW(parent,weapon_id,reload)
  else:draw_art(parent,art,reload)
  E.SubElement(parent,N+'circle',{'id':'muzzle_anchor','cx':str(definition['muzzle'][0]),'cy':str(definition['muzzle'][1]),'r':'0'})
 equipment.draw=draw
 return art,definition

def save_svg(root,path):
 E.register_namespace('',N[1:-1]);path.write_bytes(E.tostring(root))

def build(model,k,sample=False,only_clip=""):
 art,definition=bind(model);v=f'{k}_{model["id"]}';w=model['art_base']
 folder=HERE/'render_svg';folder.mkdir(exist_ok=True);(folder/'.gdignore').touch();jobs=[];muzzles={};abdomen={}
 icon=E.Element(N+'svg',{'width':'376','height':'160','viewBox':'-18 -12 94 40'});draw_art(icon,art)
 save_svg(icon,DEST/'source'/f'{model["id"]}.svg')
 (DEST/'source'/f'{model["id"]}.json').write_text(json.dumps(definition,indent=2)+'\n')
 for d,dirname in enumerate(MANIFEST['directions']):
  for clip,info in MANIFEST['clips'].items():
   if only_clip and clip!=only_clip:continue
   if sample and (clip not in ['idle','aim','wounded_walk','death_back'] or dirname not in ['sw','e','n']):continue
   frames=[info['count']-1 if clip=='death_back' else 0] if sample else range(info['count'])
   for i in frames:
    if clip=='check_comrade':
     u=(i/9)**2*(3-2*i/9);st=dict(q=1.25,settle=1,aim=.2*(1-u),crouch=.97*u,lean=8*u)
    else:st=showcase_build.state(clip,i,w)
    # Long barrels are carried flatter while kneeling beside a comrade.
    definition['carry_angle']=25-14*(i/9)**2*(3-2*i/9) if clip=='check_comrade' and model['weapon_class']=='sniper' else ORIGINAL[w]['carry_angle']
    root=directions.make(k,st.pop('q'),dirname.upper(),w,**st)
    if clip=='death_back':
     group=E.Element(N+'g',{'transform':f'translate(0,{-6*st["fall"]:.3f})'})
     for child in list(root):root.remove(child);group.append(child)
     root.append(group)
    name=f'{v}_{d}_{clip}_{i}';save_svg(root,folder/(name+'.svg'))
    extra=info.get('atlas','');target=extra if extra in ['death_back','check_comrade'] else 'units'
    cell=info['start']+i;x=i*128 if extra else cell%32*128;y=d*128 if extra else (d*MANIFEST['rows_per_direction']+cell//32)*128
    jobs.append([name,target,x,y])
    if clip in ['wounded_idle','wounded_walk']:
     key=f'{v}/{dirname}/{clip}/{i}';muzzles[key]=anchor(root,'muzzle_anchor');abdomen[key]=anchor(root,'abdomen_anchor')
  for pose,crouch in [('open',0),('cover',.15)]:
   root=directions.make(k,1.25,dirname.upper(),w,settle=1,aim=1,crouch=crouch,kick=.8*{'pump_shotgun':4.5,'ak_rifle':1.8,'uzi_smg':.7,'pistol':1.3}[w])
   muzzles[f'{v}/{dirname}/{pose}']=anchor(root,'muzzle_anchor')
 assert all(p is not None and all(math.isfinite(x) for x in p) for p in muzzles.values()),v
 if not only_clip:(DEST/'anchors'/f'{v}.json').write_text(json.dumps(dict(muzzles=muzzles,abdomen=abdomen)))
 (HERE/'jobs.json').write_text(json.dumps(dict(variant=v,sample=sample,jobs=jobs,rows=MANIFEST['rows_per_direction'])))
 print('SVG',v,len(jobs),flush=True)

if __name__=='__main__':
 model=next(m for m in MODELS if m['id']==sys.argv[1]);build(model,int(sys.argv[2]),'--sample' in sys.argv,next((a.split('=',1)[1] for a in sys.argv if a.startswith('--clip=')),''))
