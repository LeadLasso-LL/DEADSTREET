from pathlib import Path
import sys,json,re,math
import numpy as np
R=Path(__file__).parent;sys.path.insert(0,str(R/'src'))
import directions,equipment
old=equipment.draw
def mark(parent,w,reload=0):
 old(parent,w,reload);directions.E.SubElement(parent,directions.N+'circle',{'id':'muzzle_anchor','cx':str(equipment.DEFINITIONS[w]['muzzle'][0]),'cy':str(equipment.DEFINITIONS[w]['muzzle'][1])})
equipment.draw=mark
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
def find(node,parent):
 m=parent@transform(node.get('transform',''))
 if node.get('id')=='muzzle_anchor':return list((m@np.array([float(node.get('cx')),float(node.get('cy')),1]))[:2])
 for child in node:
  result=find(child,m)
  if result is not None:return result
p=R.parent.parent/'assets/art/units/pixel_v1/muzzles.json';data=json.loads(p.read_text())
for k in range(3):
 for w in equipment.DEFAULTS:
  for pose,crouch in [('open',0),('cover',.15)]:
   data[f'{k}_{w}/sw/{pose}']=find(directions.make(k,1.25,'SW',w,settle=1,aim=1,crouch=crouch),np.eye(3))
p.write_text(json.dumps(data,indent=2))
