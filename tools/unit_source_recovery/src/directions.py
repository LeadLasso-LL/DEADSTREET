import gait
"""Direction-authored outfit silhouettes over the accepted world-space run rig."""
import sys,math,copy,xml.etree.ElementTree as E
from pathlib import Path
import numpy as np
import build,equipment
sys.path.insert(0,str(Path(__file__).parent/'directional_base'))
import views,lower_body
N=build.N;p=build.p;group=build.group
NAMES=['E','SE','S','SW','W','NW','N','NE']
def xy(v):return f'{v[0]:.3f} {v[1]:.3f}'
def recolor(g,k):
 colors={'#252c2e':('#202527','#686e6b','#292e31')[k],'#293233':('#202527','#686e6b','#292e31')[k],
 '#42494a':('#353b3d','#868d87','#42494a')[k],'#545c58':('#353b3d','#868d87','#42494a')[k],
 '#5c5d43':('#202527','#d6d5c9','#202527')[k],'#73796c':('#555c59','#eeeee2','#626765')[k],
 '#414337':('#202527','#d6d5c9','#202527')[k],'#50513c':('#202527','#d6d5c9','#202527')[k],'#666453':('#555c59','#eeeee2','#626765')[k]}
 for el in g.iter():
  for key in ['fill','stroke']:
   if el.get(key) in colors:el.set(key,colors[el.get(key)])
def upper(k,q,d,w,settle=0,aim=0,kick=0,flash=False,crouch=0,fall=0,lean=0,reload=0):
 back=d in ['N','NE','NW'];side=d in ['E','W'];diag=d in ['NE','NW']
 flip=d in ['W','NW','SW'];s=math.sin(2*math.pi*(q-.12));bob=.6*math.sin(4*math.pi*(q-.08))
 s*=1-settle;bob*=1-settle
 skin,hi=[('#795139','#a67550'),('#b28f79','#d0b49a'),('#aa8060','#c39b77')][k]
 cloth,lit,shade=[('#d6d5c9','#eeeee2','#a7ada4'),('#707572','#959991','#515956'),('#282d30','#484e50','#181e21')][k]
 out=E.Element(N+'g');angle=((11+s*.7) if side else (4+s*.7 if diag else s*.7))+(25 if side else 8 if diag else 4)*crouch+lean;angle=angle*(1-fall)+90*fall
 g=group(out,transform=f'rotate({angle}) scale(1 {1-.12*crouch*(1-fall)})')
 weapon=equipment.DEFINITIONS[w]
 # Project weapon length toward the viewing direction; thickness remains readable.
 theta=(-4 if side else (-24 if diag else -77)) if back or side else 62
 length=(.83 if side else (.64 if diag else .48))
 if d=='S':length=.56
 if d=='SW':theta=55;length=.80
 origin=np.array([-3.,-27.+bob]) if side else np.array([-4.,-27.+bob])
 if back:origin=np.array([-3.,(-20 if diag else -17)+bob])
 if w=='pistol':origin+=np.array([13 if side else 3,1])
 theta+=.7*s+18*math.sin(math.pi*reload)
 theta+=( (-9 if side else (-8 if diag else 0)) *aim)-kick*1.8
 origin+=np.array([3*aim-1.3*kick,-(5 if back else 8)*aim-.5*kick])
 if side and w!='ak_rifle':origin[0]+=(6 if w=='uzi_smg' else 5)*aim
 if diag and w!='ak_rifle':origin[0]+=4*aim
 if side or d=='SW':origin+=np.array([7.,5.])*(1-aim)*(1-fall)
 carry=1.5*math.sin(2*math.pi*(q-.12))*(1-settle)*(1-aim)*(1-fall)
 origin+=np.array([carry,.25*carry])
 a=math.radians(theta);rot=np.array([[math.cos(a),-math.sin(a)],[math.sin(a),math.cos(a)]])
 mat=rot@np.diag([length,.85])*weapon['scale']
 right=origin+mat@weapon['right_grip'];left=origin+mat@weapon['left_grip']
 left=equipment.support_target(reload,left,origin,mat,w,[6,-3])
 right=right*(1-fall)+np.array([-8.,-12.])*fall;left=left*(1-fall)+np.array([12.,-8.])*fall
 # Anatomical right/left are retained even when the completed view is mirrored.
 if side:
  sh_near=np.array([-4.,-29.]);sh_far=np.array([5.,-29.])
  wr_near,wr_far=(left,right) if flip else (right,left)
  en=np.array([(-4 if not flip else 6)+s*.45,-13+s*.4]);ef=np.array([(8 if not flip else -3)+s*.4,-14+s*.4])
 else:
  sh_near=np.array([-11.,-27.]);sh_far=np.array([11.,-27.])
  if diag:sh_near=np.array([-8.,-27.]);sh_far=np.array([9.,-27.])
  wr_near,wr_far=(left,right) if back else (right,left)
  if flip:wr_near,wr_far=wr_far,wr_near
  en=np.array([-12+s*.4,-13+s*.4]);ef=np.array([12+s*.4,-13+s*.4])
 if d=='W':en=np.array([3.+s*.45,-12.]);ef=np.array([7.+s*.3,-16.])
 if d=='SW':en=np.array([-7.+s*.4,-6.]);ef=np.array([10.+s*.4,-16.])
 en[0]+=.45*carry;ef[0]+=.45*carry
 en[1]+=2.0;ef[1]+=2.0
 en+=(wr_near-en)*(.10*aim);ef+=(wr_far-ef)*(.10*aim)
 def arm(parent,a,b,c):
  fill=skin if k==0 else cloth;light=hi if k==0 else lit
  v=(b-a)/np.linalg.norm(b-a);n=np.array([-v[1],v[0]])
  cap=a-v*2.5;end=b+v*.5
  p(parent,f'M{xy(cap+n*1.7)} Q{xy(a+n*3.9-v*2)} {xy(a+n*3.7+v*2)} L{xy(end+n*3.0)} Q{xy(end+v*2)} {xy(end-n*3.0)} L{xy(a-n*3.6+v*2)} Q{xy(a-n*3.6-v*2)} {xy(cap+n*1.7)}Z',fill)
  p(parent,f'M{xy(a+n*.8)} L{xy(b-v*2+n*.8)}','none',light,1)
  if k==1:p(parent,f'M{xy(a+n*1.8)} L{xy(b-v*2+n*1.6)}','none','#d6d5c9',.65)
  lower_body.limb(parent,b,c,3.15,2.15,fill);list(parent)[-1].set('fill',light)
  E.SubElement(parent,N+'circle',{'cx':str(b[0]),'cy':str(b[1]),'r':'3.0','fill':fill})
 def gun(parent):
  aa,bb=mat[0];cc,dd=mat[1]
  gg=group(parent,transform=f'matrix({aa} {cc} {bb} {dd} {origin[0]} {origin[1]})')
  if fall<.45:equipment.draw(gg,w,reload)
  if flash:
   x,y=weapon["muzzle"]
   p(gg,f"M{x} {y} L{x+3} {y-2} {x+9} {y} {x+3} {y+2}Z","#eeeee2","#d2b15d",.6)
  # Hands stay full-sized in pose space rather than shrinking with the weapon.
  for hand in [right,left]:
   p(parent,f'M{xy(hand+[-1.7,-1.1])} Q{xy(hand+[0,-2])} {xy(hand+[1.8,-.3])} L{xy(hand+[1.5,2])} Q{xy(hand+[-.5,2.4])} {xy(hand+[-1.8,1])}Z',skin,'#382b25',.5)
   p(parent,f'M{xy(hand+[-.7,-.4])} L{xy(hand+[.8,.3])}','none',hi,.65)
  # Expose dark fore-end immediately above the support palm.
  if w!='pistol':
   tangent=rot@np.array([1.,0.]);normal=rot@np.array([0.,-1.])
   p(parent,f'M{xy(left-tangent*2+normal*1.6)} L{xy(left+tangent*2+normal*1.6)}','none','#111819',.8)
 far=group(g);arm(far,sh_far,ef,wr_far)
 if back:
  reararm=group(g);arm(reararm,sh_near,en,wr_near);gun(g)
 # Authored torso silhouettes distinguish side, rear quarter, and front.
 torso=group(g)
 if side:shape='M-3 -35 Q3 -35 7 -31 Q10 -26 9 -20 L6 -9 L6 2 Q0 5 -9 2 L-9 -10 Q-11 -22 -9 -28 Q-7 -33 -3 -35Z'
 else:shape='M-4 -33 Q-10 -32 -11 -27 L-10 -18 L-8 -4 Q0 0 8 -4 L10 -18 L11 -27 Q8 -32 4 -33Z'
 p(torso,shape,cloth)
 if side:
  p(torso,'M-6 -29 Q-9 -20 -6 -12 L-5 1 -1 2 -1 -12 1 -25Z',lit,'none')
  p(torso,'M6 -28 L7 -21 4 -9 4 1 1 2 2 -15Z',shade,'none')
 else:
  p(torso,'M-7 -28 L-7 -12 -4 -5 0 -4 -2 -16 -3 -30Z',lit,'none')
  p(torso,'M7 -28 L8 -18 6 -5 2 -3 4 -16Z',shade,'none')
 # Neck, collar and costume-specific details.
 cx=5 if side else (3 if diag or d=='SW' else 0)
 p(torso,f'M{cx-3} -37 L{cx+3} -37 L{cx+4} -30 Q{cx} -28 {cx-3} -31Z',skin,'#382b25',.5)
 if k==0:
  if side:
   p(torso,'M-2 -34 L1 -34 Q2 -27 7 -28 L7 -25 Q0 -24 -2 -34Z',lit,'none')
  else:
   p(torso,'M-5 -32 Q0 -27 5 -32 L6 -29 Q0 -24 -6 -29Z',lit,'none')
  if not back:p(torso,('M2 -31 Q3 -23 7 -25' if side else 'M-4 -30 Q0 -22 5 -29'),'none','#d2b15d',.9)
 elif k==1:
  if side:p(torso,'M4 -31 L5 -15 3 1 M-6 -31 L-7 -24','none','#d6d5c9',.8)
  elif back:p(torso,'M-7 -30 L-9 -25 M7 -30 L9 -25','none','#d6d5c9',1)
  else:p(torso,'M-4 -31 L0 -27 4 -31 M0 -27 L0 -4','none','#d6d5c9',.8)
 elif side:
  p(torso,'M2 -32 L6 -30 5 -18 -1 -27 1 -28Z',lit)
  p(torso,'M4 -30 L6 -30 5 -22Z','#d6d5c9','none')
 elif back:
  p(torso,'M-4 -31 Q0 -33 4 -31 M0 -26 L0 -7 -1 -3','none','#111819',.65)
 else:
  p(torso,'M-4 -31 L0 -27 4 -31 1 -17Z','#d6d5c9')
  p(torso,'M-6 -31 L-1 -20 -6 -24 -4 -27Z M5 -31 L1 -20 6 -24 4 -27Z',lit)
 p(torso,'M-6 -9 L-3 -8 M3 -8 L5 -10','none',shade,.6)
 # Heads are individually drawn for profile/rear; eyes never appear on the back.
 head=group(g,transform=f'translate({cx} {1-.2*s}) translate(0 -34) scale(.88) translate(0 34)')
 if side:
  p(head,'M-5 -47 Q1 -50 6 -46 L7 -42 9 -40 7 -39 6 -35 2 -33 -4 -36 -6 -41Z',skin)
  p(head,'M1 -43 L5 -43 6 -40 4 -37 1 -36Z',hi,'none')
 else:
  p(head,'M-6 -45 Q0 -49 6 -45 L6 -37 3 -33 -3 -34 -6 -38Z',skin)
  if not back:p(head,'M-3 -42 L3 -42 4 -38 1 -36 -3 -38Z',hi,'none')
 if k==0:
  p(head,('M-6 -37 L-7 -44 Q-7 -50 0 -50 Q6 -50 7 -45 L8 -40 6 -34 1 -33 -5 -36Z' if side else 'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z'),'#202527')
  p(head,'M-4 -46 Q0 -48 3 -46','none','#42494a',.7)
  if side:p(head,'M2 -43 L6 -43 7 -41 2 -41Z',skin,'none')
  elif not back:
   p(head,'M-4 -42 L4 -42 4 -40 -4 -40Z',skin,'none')
  if diag:p(head,'M5 -42 L6 -41 6 -39 5 -39Z',skin,'none')
 else:
  hair='#3b2c25' if k==1 else '#111819'
  if back:
   p(head,'M-6 -36 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -36 3 -35 -3 -36Z',hair)
   p(head,'M-4 -46 Q0 -48 4 -46','none','#65503c' if k==1 else '#42494a',.7)
  else:
   p(head,'M-6 -39 L-7 -44 Q-5 -50 1 -49 Q6 -49 7 -45 L5 -43 1 -44 -4 -43 -4 -37Z',hair)
   p(head,'M-4 -45 Q0 -48 4 -46','none','#65503c' if k==1 else '#42494a',.7)
   if k==1:p(head,('M0 -42 L6 -42 6 -40 1 -40Z' if side else 'M-5 -42 L5 -42 4 -39 1 -39 0 -41 -1 -39 -4 -39Z'),'#111819')
   else:p(head,'M-5 -41 L-3 -38 -3 -35 -5 -36Z',hair,'none')
 # Rear torso occludes only the proximal arm; outer elbows remain visible.
 if not back:
  if side or d=='SW':
   # Far upper arm remains behind torso; only its forearm crosses in front.
   lower_body.limb(g,ef,wr_far,3.15,2.15,skin if k==0 else cloth)
  else:
   g.remove(far);g.append(far)
  near=group(g);arm(near,sh_near,en,wr_near);gun(g)
 if flip:out.set('transform','scale(-1 1)')
 return out

def make(k,q,d,w,settle=0,aim=0,kick=0,flash=False,crouch=0,fall=0,lean=0,reload=0):
 # User-approved handedness swap: these views are true reflections.
 if d in ['SW','W']:
  root=make(k,q,'SE' if d=='SW' else 'E',w,settle,aim,kick,flash,crouch,fall,lean,reload)
  reflected=E.Element(N+'g',{'transform':'translate(128 0) scale(-1 1)'})
  for child in list(root):root.remove(child);reflected.append(child)
  root.append(reflected)
  return root
 if d in ['SE','SW']:
  root=build.make(k,q,w,settle,aim,kick,flash,crouch,fall,lean,reload)
  if d=='SW':
   # Swap arm endpoints before reflecting; preserve right-hand trigger ownership.
   up=root.find(".//*[@id='upper_pose']")
   # Use authored front view for SW with the oblique weapon projection.
   low=list(root)[0];low.remove(up)
   hip=build.B.proj(np.array([math.sin(2*math.pi*q)*(1-settle),(gait.height(q,51))*(1-settle)+51.8*settle-30*crouch-12*fall,0]))
   wrap=group(root,transform=f'translate({hip[0]} {hip[1]}) scale(1.05 .92)')
   wrap.append(upper(k,q,'SW',w,settle,aim,kick,flash,crouch,fall,lean,reload))
   low.set('transform','translate(128 0) scale(-1 1)')
  return root
 if d in ['E','W']:
  low,_,hip=lower_body.make_lower(q,settle=settle,crouch=crouch,fall=fall)
  if d=='W':low.set('transform','translate(128 0) scale(-1 1)')
 else:
  yaw=math.radians({'S':90,'N':270,'NE':293.578,'NW':246.422}[d]);low,hip=views.lower(q,yaw,settle=settle,crouch=crouch,fall=fall)
 recolor(low,k)
 root=E.Element(N+'svg',{'width':'128','height':'128','viewBox':'0 0 128 128'});root.append(low)
 wrap=group(root,transform=f'translate({hip[0]} {hip[1]}) scale({.88 if d in ["E","W"] else 1.12} {.8 if d in ["E","W"] else .92})')
 wrap.append(upper(k,q,d,w,settle,aim,kick,flash,crouch,fall,lean,reload));return root
