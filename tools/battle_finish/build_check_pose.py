"""Generate only the aftermath kneel clip from the approved outfit/rig sources."""
from pathlib import Path
import sys,json,xml.etree.ElementTree as E
R=Path(__file__).resolve().parents[2];source=R/'tools/unit_source_recovery'
sys.path.insert(0,str(source));sys.path.insert(0,str(source/'src'))
import directions
folder=Path(__file__).parent/'pose_svg';folder.mkdir(exist_ok=True)
manifest_path=R/'assets/art/units/pixel_v1/manifest.json';m=json.loads(manifest_path.read_text())
m['clips']['check_comrade']={'start':0,'count':10,'fps':10,'loop':False,'atlas':'check_comrade'}
jobs=[]
for variant in m['variants']:
 k,w=variant.split('_',1)
 for d,direction in enumerate(m['directions']):
  for i in range(10):
   t=i/9;u=t*t*(3-2*t)
   root=directions.make(int(k),1.25,direction.upper(),w,settle=1,aim=.2*(1-u),crouch=.97*u,lean=8*u)
   E.register_namespace('','http://www.w3.org/2000/svg')
   name=f'{variant}_{d}_{i}';(folder/(name+'.svg')).write_bytes(E.tostring(root));jobs.append([name,variant,i*128,d*128])
(folder/'jobs.json').write_text(json.dumps(jobs));manifest_path.write_text(json.dumps(m,indent=2)+'\n')
print('CHECK_POSE_SVG',len(jobs))
