from pathlib import Path
import sys,json,xml.etree.ElementTree as E
R=Path(__file__).parent;sys.path.insert(0,str(R));sys.path.insert(0,str(R/'src'))
import directions,render
repo=R.parent.parent;out=R/'svg_export';out.mkdir(exist_ok=True)
manifest=json.loads((repo/'assets/art/units/pixel_v1/manifest.json').read_text())
sources={'reload':('reload',list(range(40))),'cover_popout':('cover_over',list(range(16,24))),'cover_tucked_idle':('cover_over',[15]),'cover_exposed_idle':('cover_over',[23]),'cover_fire':('cover_over',[24,25,26]),'cover_tuck':('cover_over',list(range(28,37))),'hit':('hit',list(range(16))),'wounded_idle':('injured_run',list(range(24))),'wounded_walk':('injured_run',list(range(24))),'death':('death',list(range(24))),'cover_edge':('cover_edge',[10,11,12,13,15,16,17,19,20])}
jobs=[]
for variant in manifest['variants']:
 k,w=variant.split('_',1);k=int(k)
 for d,dirname in enumerate(manifest['directions']):
  for clip,info in manifest['clips'].items():
   for i in range(info['count']):
    if clip in sources:
     source,indices=sources[clip];st=render.state(source,indices[i],w)
    elif clip=='walk':st=dict(q=i/24)
    else:st=dict(q=1.25,settle=1,aim=.3 if clip=='idle' else 1,kick=([.8,.35,0][i] if clip=='fire' else 0))
    if clip=='wounded_idle':st['settle']=1
    # Muzzle flashes are a runtime effect, never baked twice.
    st['flash']=False
    st['kick']=st.get('kick',0)*({'pump_shotgun':4.5,'ak_rifle':1.8,'uzi_smg':.7,'pistol':1.3}.get(w,1))
    root=directions.make(k,st.pop('q'),dirname.upper(),w,**st)
    E.register_namespace('', 'http://www.w3.org/2000/svg')
    name=f'{variant}_{d}_{info["start"]+i}'
    (out/(name+'.svg')).write_bytes(E.tostring(root))
    jobs.append([name,variant,(info['start']+i)%32*128,(d*6+(info['start']+i)//32)*128])
(R/'jobs.json').write_text(json.dumps(jobs))
print(len(jobs),'SVG frames exported',flush=True)
