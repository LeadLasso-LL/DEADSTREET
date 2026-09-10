"""Reproducible faction outfit/animation build using the existing SVG-native renderer."""
from pathlib import Path
import sys,json,xml.etree.ElementTree as E
R=Path(__file__).parent;sys.path.insert(0,str(R));sys.path.insert(0,str(R/'src'))
import directions,render,math,copy
repo=R.parent.parent;out=R/'showcase_svg';out.mkdir(exist_ok=True)
m=json.loads((repo/'assets/art/units/pixel_v1/manifest.json').read_text())
SOURCES={'reload':('reload',list(range(40))),'cover_popout':('cover_over',list(range(16,24))),'cover_tucked_idle':('cover_over',[15]),'cover_exposed_idle':('cover_over',[23]),'cover_fire':('cover_over',[24,25,26]),'cover_tuck':('cover_over',list(range(28,37))),'hit':('hit',list(range(16))),'wounded_idle':('injured_run',list(range(24))),'wounded_walk':('injured_run',list(range(24))),'death':('death',list(range(24))),'cover_edge':('cover_edge',[10,11,12,13,15,16,17,19,20])}
def state(clip,i,w):
 if clip=='death_back':
  t=i/31;u=max(0,min(1,(t-.1)/.55));fall=u*u*(3-2*u)
  impact=max(0,math.sin((t-.65)/.16*math.pi))*.045 if .65<t<.81 else 0
  return dict(q=1.25,settle=1,aim=.2,crouch=.85*fall-impact,fall=fall,backward=t+1e-6)
 if clip in SOURCES:
  source,indices=SOURCES[clip];st=render.state(source,indices[i],w)
 elif clip=='walk':st=dict(q=i/24)
 else:st=dict(q=1.25,settle=1,aim=.3 if clip=='idle' else 1,kick=([.8,.35,0][i] if clip=='fire' else 0))
 if clip=='wounded_idle':st['settle']=1
 st['flash']=False;st['kick']=st.get('kick',0)*{'pump_shotgun':4.5,'ak_rifle':1.8,'uzi_smg':.7,'pistol':1.3}.get(w,1)
 return st
def clothing_mask(node,surface=False):
 surface=surface or node.get('id')=='stain_surface'
 for attr in ['fill','stroke']:
  value=node.get(attr)
  if value is not None and value!='none':node.set(attr,'#ffffff' if surface and attr=='fill' else '#000000')
 for child in node:clothing_mask(child,surface)
if __name__=='__main__':
 sample='--sample' in sys.argv;death_only='--death-only' in sys.argv;jobs=[]
 m['clips']['death_back']=dict(start=0,count=32,fps=24,loop=False,atlas='death_back')
 variants=[f'{k}_{w}' for k in range(3 if death_only else 2) for w in ['uzi_smg','ak_rifle','pistol','pump_shotgun']]
 for arg in sys.argv:
  if arg.startswith('--variant='):variants=[v for v in variants if v==arg.split('=',1)[1]]
 assert variants, 'No matching variant'
 for v in variants:
  k,w=v.split('_',1);k=int(k)
  for d,dirname in enumerate(m['directions']):
   for clip,info in m['clips'].items():
    if death_only and clip!='death_back':continue
    if sample and clip not in ['idle','aim','walk','wounded_walk','death_back']:continue
    for i in ([0,5,10,15,22,31] if sample and clip=='death_back' else ([0] if sample else range(info['count']))):
     st=state(clip,i,w);root=directions.make(k,st.pop('q'),dirname.upper(),w,**st)
     if clip=='death_back':
      # Keep the extended feet/arms inside the established 128px animation cell.
      group=E.Element('{http://www.w3.org/2000/svg}g',{'transform':f'translate(0,{-6*st["fall"]:.3f})'})
      for child in list(root):root.remove(child);group.append(child)
      root.append(group)
     E.register_namespace('', 'http://www.w3.org/2000/svg')
     name=f'{v}_{d}_{clip}_{i}';(out/(name+'.svg')).write_bytes(E.tostring(root))
     jobs.append([name,v+'__death_back' if clip=='death_back' else v,i*128 if clip=='death_back' else (info['start']+i)%32*128,d*128 if clip=='death_back' else (d*m['rows_per_direction']+(info['start']+i)//32)*128])
     if not sample and clip in ['wounded_idle','wounded_walk']:
      mask=copy.deepcopy(root);clothing_mask(mask);(out/(name+'_mask.svg')).write_bytes(E.tostring(mask))
      jobs.append([name+'_mask',v+'__blood_mask',(info['start']+i)%32*128,(d*m['rows_per_direction']+(info['start']+i)//32)*128])
 jobs.sort(key=lambda j:j[1])
 (R/'showcase_manifest.json').write_text(json.dumps(m,indent=2))
 (R/'showcase_jobs.json').write_text(json.dumps(dict(sample=sample,rows=m['rows_per_direction'],jobs=jobs)))
 print('SHOWCASE_SVG',len(jobs),flush=True)
