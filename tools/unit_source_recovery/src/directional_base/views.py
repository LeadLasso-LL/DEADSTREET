import gait
from pathlib import Path
import math, copy, xml.etree.ElementTree as E
import numpy as np
from lower_body import NS,path,poly,limb
R=Path(__file__).parent
# Angled tactical camera; genuine world-space leg swing, authored upper silhouettes.
EL=math.radians(50)
def project(v):return np.array([64+v[0],110+v[2]*math.sin(EL)-v[1]*math.cos(EL)])
def xy(p):return f'{p[0]:.3f} {p[1]:.3f}'
def lower(q,yaw,still=False,settle=0,crouch=0,fall=0,wounded=0):
 f=np.array([math.cos(yaw),0,math.sin(yaw)]);rt=np.array([f[2],0,-f[0]])
 h=52.5 if still else gait.height(q,52.5);hip=project([0,h,0]);g=E.Element(NS+'g');joins=[];legs=[]
 front=abs(yaw-math.pi/2)<.01
 sway=0 if still or not front else .65*math.sin(2*math.pi*q)
 if front:
  h=51.5 if still else gait.height(q,51.5)
  hip=project([sway,h,0])
 h=h*(1-settle)+(51.5 if front else 52)*settle-30*crouch-12*fall;sway*=1-settle;hip=project([sway,h,0])
 for side in [-1,1]:
  p=(q+(0 if side==-1 else .5))%1
  if still:along=3 if side==-1 else -4;lift=0;pitch=0
  else:along,lift,pitch,_=(gait.foot(p) if not wounded else gait.wounded_foot(p,side))
  along=along*(1-settle)+(5 if side==-1 else -6)*settle;lift*=1-settle;pitch*=1-settle
  foot=rt*side*6.7+f*along+[0,lift,0];fall_sign=-1 if f[0]<-.1 else 1;foot=foot*(1-fall)+np.array([-40.*fall_sign,0.,side*4.])*fall;a3=rt*side*6.2+[sway,h,0];ank=foot+[0,6.5,0]
  v=ank-a3;dist=np.linalg.norm(v);u=v/dist;bend=f-u*np.dot(f,u);bend/=np.linalg.norm(bend)
  k=(26.5**2-29.5**2+dist**2)/(2*dist);b3=a3+u*k+bend*math.sqrt(max(0,26.5**2-k*k));b3=b3*(1-fall)+np.array([-19.*fall_sign,3.,side*8.])*fall;a,b,c=map(project,[a3,b3,ank]);joins.append((a,b));leg=E.Element(NS+'g')
  width=1.14 if abs(math.cos(yaw))>.1 else 1.0
  limb(leg,a,b,4.8*width,3.5*width,'#252c2e');limb(leg,b,c,3.65*width,2.6*width,'#252c2e')
  u=(b-a)/np.linalg.norm(b-a);v=(c-b)/np.linalg.norm(c-b);n=np.array([-u[1],u[0]]);nv=np.array([-v[1],v[0]])
  path(leg,f'M{xy(b-u*4+n*3.6)} Q{xy(b+n*4)} {xy(b+v*4+nv*3.5)} L{xy(b+v*4-nv*3.5)} Q{xy(b-n*4)} {xy(b-u*4-n*3.6)}Z','#252c2e','none')
  path(leg,f'M{xy(b-n*2)} Q{xy(b+v)} {xy(b+n*2)}','none','#545c58',.55)
  # Rounded footprint and raised instep; toe direction follows travel, never screen rotation.
  angle=math.radians(pitch)
  def bp(lat,lng,ht):
   lat*=1.12;lng*=1.12
   if front:lng*=.8
   return xy(project(foot+rt*lat+f*(lng*math.cos(angle)-ht*math.sin(angle))+[0,lng*math.sin(angle)+ht*math.cos(angle),0]))
  contour=[('M',(-2.7,-3.6)),('Q',(0,-4.5),(2.7,-3.6)),('L',(3.2,4)),('Q',(3.5,8.8),(1,10)),('Q',(-2.6,10.8),(-3.2,7)),('L',(-2.7,-3.6))]
  def outline(raised):
   return ' '.join(cmd+' '.join(bp(x,z,max(1.3,5.8-.45*max(0,z)) if raised else .5) for x,z in pts) for cmd,*pts in contour)+'Z'
  path(leg,outline(False),'#111819','#111819',.75);path(leg,outline(True),'#5c5d43','#1c2425',.7)
  path(leg,f'M{bp(-1.8,0,5.7)} Q{bp(0,1,5.3)} {bp(1.8,0,5.7)} M{bp(-1.6,5,3.5)} Q{bp(0,7,2.7)} {bp(1.6,5,3.5)}','none','#73796c',.65)
  legs.append((float(foot[2]),leg))
 for _,leg in sorted(legs,key=lambda v:v[0]):g.append(leg)
 for a,b in joins:
  v=b-a;n=np.array([-v[1],v[0]])/np.linalg.norm(v);end=a+.40*v
  path(g,f'M{xy(hip+[-7,-4])} L{xy(hip+[7,-4])} Q{xy(a-n*4.8)} {xy(end-n*4.5)} L{xy(end+n*4.5)} Q{xy(a+n*4.8)} {xy(hip+[-7,-4])}Z','#293233','none')
 w=8.5+abs(f[2])*2
 path(g,f'M{xy(hip+[-w,-5])} Q{xy(hip+[-w-1,1])} {xy(hip+[-w+2,6])} Q{xy(hip+[0,10])} {xy(hip+[w-2,6])} Q{xy(hip+[w+1,1])} {xy(hip+[w,-5])}Z','#293233','none')
 if f[2]<0:
  path(g,f'M{xy(hip+[-7,1])} L{xy(hip+[-3,2])} L{xy(hip+[-4,5])} M{xy(hip+[3,2])} L{xy(hip+[7,1])} L{xy(hip+[6,4])}','none','#545c58',.6)
 return g,hip

def upper(q,back=False,diag=False,still=False):
 g=E.Element(NS+'g');s=0 if still else math.sin(2*math.pi*(q-.12));bob=0 if still else .5*math.sin(4*math.pi*(q-.08))
 # Each view has its own shoulder, neck, vest and head contours. No folded image planes.
 cx=4 if diag else 0
 lean=4 if diag else 0
 wrap=E.SubElement(g,NS+'g',{'transform':f'rotate({lean+s*1.1})'})
 shL=np.array([-11.,-26.]);shR=np.array([11.,-27.]);
 if diag:shL=np.array([-7.,-27.]);shR=np.array([8.,-25.])
 # Rifle points away in rear views, toward viewer in front views.
 grip=np.array([4.,-19.+bob]);support=np.array([11. if diag else -1.,-23.+bob if back else -13.+bob])
 muzzle=np.array([25. if diag else -5.,-32.+bob if back else -3.+bob])
 if not back:grip=np.array([-4.,-18.+bob]);support=np.array([7. if diag else 1.,-13.+bob]);muzzle=np.array([24. if diag else 8.,7.+bob])
 if not back:
  # The same rifle artwork as the accepted views, foreshortened toward camera.
  theta=math.radians(61+.7*s)
  gun_matrix=np.array([[math.cos(theta),-math.sin(theta)],[math.sin(theta),math.cos(theta)]])@np.diag([.57,.72])
  gun_origin=np.array([-3.,-29.+bob])
  grip=gun_origin+gun_matrix@np.array([18.,9.])
  support=gun_origin+gun_matrix@np.array([37.,7.])
 def arm(a,b,c,far=False):
  limb(wrap,a,b,3.1,2.4,'#545c58');limb(wrap,b,c,2.5,1.8,'#79583c' if not far else '#59412f')
  path(wrap,f'M{xy(a+[-2,-2])} Q{xy(a+[0,-4])} {xy(a+[3,-1])} L{xy(a+[2,4])} L{xy(a+[-2,4])}Z','#73796c','none')
 def gun():
  if not back:
   weapon=copy.deepcopy(E.parse(R/'source/approved_v5.svg').getroot().find(".//*[@id='weapon']"))
   a,b=gun_matrix[0];c,d=gun_matrix[1]
   transform=f'matrix({a} {c} {b} {d} {gun_origin[0]} {gun_origin[1]})'
   weapon.set('transform',transform);wrap.append(weapon)
   hands=E.SubElement(wrap,NS+'g',{'transform':transform})
   path(hands,'M15 7 Q18 6 21 8 L21 11 L18 13 L15 11Z','#79583c','#382b22',.6)
   path(hands,'M17 8 L22 8 L22 9 L19 9 M16 10 L20 11','none','#b29568',.6)
   path(hands,'M34 5 Q37 4 40 6 L40 9 L37 10 L34 8Z','#79583c','#382b22',.6)
   path(hands,'M34 2.5 L42 2.5 L42 4 L34 4Z','#111819','none')
   return
  v=muzzle-grip;v/=np.linalg.norm(v);n=np.array([-v[1],v[0]])
  poly(wrap,[grip-v*8+n*2.7,grip-v*8-n*2.7,grip+v*4-n*2.2,grip+v*4+n*2.2],'#302325','#111819',.8)
  poly(wrap,[grip+n*2,grip-n*2,support-n*2,support+n*2],'#293233','#111819',.9)
  poly(wrap,[support+n*1.3,support-n*1.3,muzzle-n*.8,muzzle+n*.8],'#111819','none')
  path(wrap,f'M{xy(grip+[0,1])} L{xy(grip+[1,6])} L{xy(grip+[4,6])} L{xy(grip+[3,1])}Z','#111819','none')
  for hand in [grip,support]:
   path(wrap,f'M{xy(hand+[-2,0])} Q{xy(hand+[0,-1])} {xy(hand+[2,1])} L{xy(hand+[2,3])} Q{xy(hand+[0,4])} {xy(hand+[-2,2])}Z','#9b7750','#382b22',.6)
  path(wrap,f'M{xy(support-v*2-n*.5)} L{xy(support+v*3-n*.5)}','none','#111819',1)
 if back:
  arm(shL,np.array([-12+s*.4,-13+s*.4]),support,True)
  arm(shR,np.array([12+s*.5,-12+s*.4]),grip)
  gun()
 # Slim sloped shoulders and integrated collar.
 path(wrap,'M-4 -33 Q-9 -32 -11 -27 L-10 -17 L-8 -4 Q0 0 8 -4 L10 -17 L11 -26 Q8 -32 4 -33Z','#293233','#111819',.9)
 if back:
  path(wrap,'M-5 -31 Q0 -34 5 -31 L7 -21 L6 -8 Q0 -5 -6 -8 L-7 -21Z','#3b4443','none')
  path(wrap,'M-7 -28 L-5 -30 L-3 -21 L-5 -10 L-7 -10Z M5 -30 L8 -27 L7 -10 L5 -10 L4 -20Z','#4b2a2d','none')
  path(wrap,'M-3 -23 L3 -23 L4 -16 L-3 -15Z','#293233','#1c2425',.6)
  path(wrap,'M-4 -8 L4 -8 M-2 -26 L2 -26 M-5 -18 L-4 -12','none','#545c58',.6)
 else:
  path(wrap,'M-5 -31 L-8 -27 L-6 -15 L-2 -13 L-2 -28Z M4 -31 L8 -27 L6 -15 L2 -13 L2 -28Z','#4b2a2d','none')
  path(wrap,'M-5 -24 L-1 -23 L-1 -17 L-5 -18Z M2 -23 L6 -24 L6 -18 L2 -17Z','#1c2425','none')
  path(wrap,'M-7 -12 L-1 -12 L-1 -6 L-7 -7Z M1 -12 L7 -12 L7 -7 L1 -6Z','#222b24','#111819',.6)
  path(wrap,'M-6 -10 L-2 -10 M2 -10 L6 -10','none','#697460',.6)
 # Small cloth folds and worn vest edges retain the approved restrained palette.
 path(wrap,'M-8 -23 L-7 -19 M7 -25 L8 -21 M-6 -5 L-3 -4 M3 -5 L6 -6','none','#73796c',.55)
 path(wrap,'M-4 -29 L-3 -26 M4 -29 L5 -26','none','#84514a',.55)
 # Neck extends into torso, cap sits on head rather than floating.
 path(wrap,f'M{cx-3} -36 L{cx+4} -36 L{cx+5} -29 Q{cx} -27 {cx-4} -30Z','#59412f','#302325',.5)
 head=E.SubElement(wrap,NS+'g',{'transform':f'translate({cx} 1) scale(.88 1)'})
 if back:
  path(head,'M-6 -43 Q0 -47 6 -43 L6 -36 Q4 -32 0 -32 Q-5 -33 -6 -37Z','#59412f','#382b22',.7)
  path(head,'M-5 -38 L5 -38 L4 -33 Q0 -31 -4 -34Z','#382b22','none')
  if diag:path(head,'M5 -40 L7 -39 L7 -36 L5 -35Z','#9b7750','#59412f',.5)
 else:
  path(head,'M-6 -43 Q0 -46 6 -42 L6 -36 L3 -32 L-3 -33 L-6 -37Z','#79583c','#382b22',.7)
  path(head,'M-3 -40 L3 -40 L4 -36 L1 -35 L-2 -36Z','#b29568','none')
  path(head,'M-5 -37 L-2 -35 L2 -35 L5 -37 L3 -32 L-2 -32 L-5 -35Z','#382b22','none')
  path(head,'M-4 -40 L-2 -40 M2 -40 L4 -40','none','#111819',.65)
 path(head,'M-7 -41 L-7 -46 Q-5 -51 0 -51 Q6 -51 7 -46 L7 -41 Q0 -38 -7 -41Z','#673b3b','#302325',.8)
 path(head,'M-5 -46 Q-1 -49 3 -48 L5 -45 L0 -44 L-5 -44Z','#84514a','none')
 path(head,'M-7 -42 Q0 -39 7 -42 L7 -40 Q0 -37 -7 -40Z','#4b2a2d','#302325',.45)
 path(head,'M-4 -47 L-4 -44 M0 -49 L0 -45 M4 -46 L4 -43','none','#84514a',.55)
 # Arms stay long enough to reach the actual grip; elbows bend below the shoulders.
 if not back:
  arm(shL,np.array([-9+s*.4,-12+s*.4]),grip,True)
  arm(shR,np.array([10+s*.5,-10+s*.4]),support)
  # Blend sleeves into the shoulders, rather than exposing square caps.
  for sign in [-1,1]:
   sleeve=E.SubElement(wrap,NS+'g',{'transform':f'scale({sign} 1)'})
   path(sleeve,'M7 -29 Q10 -31 12 -27 Q14 -24 12 -21 L9 -22 L7 -25Z','#545c58','#293233',.65)
   path(sleeve,'M8 -28 Q10 -29 11 -26 L11 -23 L9 -24Z','#73796c','none')
  gun()
 return g

def make(q,name,still=False):
 angles={'S':90,'N':270,'NE':293.578,'NW':246.422}
 yaw=math.radians(angles[name]);g,hip=lower(q,yaw,still)
 root=E.Element(NS+'svg',{'width':'128','height':'128','viewBox':'0 0 128 128'});root.append(g)
 up=upper(q,back=name!='S',diag=name in ['NE','NW'],still=still)
 if name=='NW':up.set('transform',f'translate({hip[0]} {hip[1]}) scale(-1.12 .92)')
 else:up.set('transform',f'translate({hip[0]} {hip[1]}) scale({1.12 if name in ["NE","NW"] else 1.28} {.86 if name=="S" else .92})')
 root.append(up);return root
