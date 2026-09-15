from pathlib import Path
R=Path(__file__).parent
p=R/'src/gait.py';s=p.read_text();s+="""
def wounded_foot(p,side):
 sore=side==1;stance=.52 if sore else .68
 reach=8 if sore else 10
 if p<stance:
  t=p/stance;roll=smooth((t-.8)/.2)
  return reach-2*reach*t,0,-7*roll,3*roll
 t=(p-stance)/(1-stance)
 return -reach+2*reach*smooth(t),(3 if sore else 6)*math.sin(math.pi*t),-7*(1-t),0
"""
p.write_text(s)
for rel in ['src/base_rig.py','src/directional_base/lower_body.py','src/directional_base/views.py']:
 p=R/rel;s=p.read_text()
 old="(gait.foot(p) if not wounded else tuple(v*f for v,f in zip(gait.foot(p),([.65,.25,.35,.3] if side==1 else [.85,.55,.5,.4]))))"
 assert old in s,rel
 p.write_text(s.replace(old,"(gait.foot(p) if not wounded else gait.wounded_foot(p,side))"))
