from pathlib import Path
import sys,json,xml.etree.ElementTree as E
R=Path(__file__).parent;repo=R.parent.parent
sys.path.insert(0,str(R));sys.path.insert(0,str(R/'src'))
import directions,render
E.register_namespace('','http://www.w3.org/2000/svg')
m=json.loads((repo/'assets/art/units/pixel_v1/manifest.json').read_text())
out=R/'mask_svg';out.mkdir(exist_ok=True);jobs=[]
def mask(node,surface=False):
 surface=surface or node.get('id')=='stain_surface'
 for attr in ['fill','stroke']:
  value=node.get(attr)
  if value is not None and value!='none':node.set(attr,'#ffffff' if surface and attr=='fill' else '#000000')
 for child in node:mask(child,surface)
for v in m['variants']:
 k,w=v.split('_',1)
 for d,dname in enumerate(m['directions']):
  for clip in ['wounded_idle','wounded_walk']:
   for i in range(24):
    st=render.state('injured_run',i,w)
    if clip=='wounded_idle':st['settle']=1
    root=directions.make(int(k),st.pop('q'),dname.upper(),w,**st);mask(root)
    name=f'{v}_{d}_{clip}_{i}';(out/(name+'.svg')).write_bytes(E.tostring(root))
    f=m['clips'][clip]['start']+i;jobs.append([name,v,f%32*128,(d*6+f//32)*128])
(R/'mask_jobs.json').write_text(json.dumps(jobs));print(len(jobs),'occlusion masks exported',flush=True)
