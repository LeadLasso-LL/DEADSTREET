import gait
from pathlib import Path
import math,copy,subprocess,xml.etree.ElementTree as E,json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).parent;NS='{http://www.w3.org/2000/svg}';base=E.parse(R/'source/approved_v5.svg').getroot();upper=base.find(".//*[@id='upper_pose']")
F=np.array([.4,0,math.sqrt(1-.4**2)]);F/=np.linalg.norm(F);RIGHT=np.array([F[2],0,-F[0]]);el=math.radians(50)
def proj(v):return np.array([64+v[0],110+v[2]*math.sin(el)-v[1]*math.cos(el)])
def path(g,d,fill,stroke='#14191a',w=1):E.SubElement(g,NS+'path',{'d':d,'fill':fill,'stroke':stroke,'stroke-width':str(w),'stroke-linejoin':'round','stroke-linecap':'round'})
def poly(g,ps,fill,stroke='#14191a',w=1):path(g,'M'+' L'.join(f'{x:.3f} {y:.3f}' for x,y in ps)+'Z',fill,stroke,w)
def limb(g,a,b,wa,wb,fill):
 v=b-a;n=np.array([-v[1],v[0]])/np.linalg.norm(v);m=a+.55*v
 poly(g,[a+n*wa,m+n*(wa*.75+wb*.25),b+n*wb,b-n*wb,m-n*(wa*.35+wb*.65),a-n*wa],fill)
 poly(g,[a+n*wa*.50,m+n*wa*.5,b+n*wb*.3,b-n*wb*.25,m-n*wb*.35], '#42494a','none')
def smooth(t):return t*t*(3-2*t)
def make(q,stop=None,aim=0,crouch=0,kick=0,settle=0,fall=0):
 # Contact, compression, toe-off, recovery, forward swing. Ground stance is linear.
 beat=(q*2)%1;h=gait.height(q,51);sway=1.0*math.sin(2*math.pi*q)
 if stop is not None:h=(51-2.4*math.cos(2*math.pi*(-.12)))*(1-smooth(stop))+52*smooth(stop)-1.4*math.sin(math.pi*stop);sway=0
 h=h*(1-settle)+51.8*settle;sway*=1-settle
 h-=30*crouch+12*fall
 hip=proj(np.array([sway,h,0]));g=E.Element(NS+'g');states=[];thighs={}
 for side in [1,-1]:
  p=(q+(0 if side==-1 else .5))%1
  along,lift,pitch,_=gait.foot(p)
  if stop is not None:
   root=40*(stop-.5*stop*stop)
   if side==-1:along=12-root;lift=0;pitch=0
   else:
    u=min(stop/.72,1);p0=(.5-.42)/.58;initial=-12+24*smooth(p0)
    along=initial+(26-initial)*smooth(u)-root
    lift=17*math.sin(math.pi*p0)**1.3*(1-u)+10*math.sin(math.pi*u);pitch=12*math.sin(math.pi*u)
  along=along*(1-settle)+(5 if side==-1 else -6)*settle;lift*=1-settle;pitch*=1-settle
  foot=RIGHT*side*7.3+F*along+np.array([0,lift,0]);foot=foot*(1-fall)+np.array([-40.,0.,side*4.])*fall;ank=foot+np.array([0,3,0]);hp=RIGHT*side*6.5+np.array([sway,h,0]);v=ank-hp;dist=np.linalg.norm(v);direction=v/dist;hint=F-direction*np.dot(F,direction);hint/=np.linalg.norm(hint)
  thigh_length,calf_length=26.5,29.5
  knee_distance=(thigh_length**2-calf_length**2+dist**2)/(2*dist)
  knee=hp+direction*knee_distance+hint*math.sqrt(max(0,thigh_length**2-knee_distance**2));knee=knee*(1-fall)+(np.array([-19.,3.,side*8.]))*fall;a,b,c=map(proj,[hp,knee,ank])
  thighs[side]=(a.copy(),b.copy())
  limb(g,a,b,5.8,4.5,'#252c2e');limb(g,b,c,4.65,3.1,'#252c2e')
  # Blend calf and thigh contours through a curved fabric-covered knee.
  u=(b-a)/np.linalg.norm(b-a);v=(c-b)/np.linalg.norm(c-b)
  nu=np.array([-u[1],u[0]]);nv=np.array([-v[1],v[0]]);nm=nu+nv;nm/=np.linalg.norm(nm)
  ka=b-u*4;kb=b+v*4
  def xy(p):return f'{p[0]:.3f} {p[1]:.3f}'
  path(g,f'M{xy(ka+nu*4.2)} Q{xy(b+nm*4.3)} {xy(kb+nv*3.9)} L{xy(kb-nv*3.9)} Q{xy(b-nm*4.3)} {xy(ka-nu*4.2)}Z','#252c2e','none')
  path(g,f'M{xy(ka+nu*4.2)} Q{xy(b+nm*4.3)} {xy(kb+nv*3.9)}','none','#192123',.7)
  path(g,f'M{xy(ka-nu*4.2)} Q{xy(b-nm*4.3)} {xy(kb-nv*3.9)}','none','#192123',.7)
  path(g,f'M{xy(b-nm*2.2-u)} Q{xy(b+v*1.3)} {xy(b+nm*2.1)}','none','#42494a',.75)
  # Rounded heel and toe, narrower waist and raised instep, projected with the foot.
  pivot=proj(foot);angle=math.radians(pitch);mat=np.array([[math.cos(angle),-math.sin(angle)],[math.sin(angle),math.cos(angle)]])
  def shoe_point(lateral,along,height=0):
   return pivot+mat@(proj(foot+RIGHT*(lateral*1.12)+F*(along*1.12)+np.array([0,height,0]))-pivot)
  contour=[('M',(-1.7,-2.8)),('Q',(0,-3.4),(1.8,-2.8)),('Q',(2.9,-1.8),(2.8,.5)),('L',(3,3.8)),('Q',(2.8,6.4),(.8,6.7)),('Q',(-1,7),(-2.1,5.8)),('Q',(-3,4.7),(-2.8,2.5)),('L',(-2.4,-1.5)),('Q',(-2.4,-2.5),(-1.7,-2.8))]
  def outline(raised=False,offset=0):
   return ' '.join(cmd+' '.join(xy(shoe_point(lat,lng,max(1.1,3.6-.38*lng) if raised else 0)+[0,offset]) for lat,lng in pts) for cmd,*pts in contour)+' Z'
  path(g,outline(False,1.1),'#171e1e','#121818',.8)
  path(g,outline(True),'#414337','#171e1e',.8)
  path(g,f'M{xy(shoe_point(-1.3,-.8,4))} Q{xy(shoe_point(0,1,3.2))} {xy(shoe_point(1.5,2.3,2.7))}','none','#666453',1.0)
  path(g,f'M{xy(shoe_point(-1.6,4.7,1.8))} Q{xy(shoe_point(0,5.5,1.4))} {xy(shoe_point(1.8,4.8,1.8))}','none','#555849',.6)
  states.append({'phase':p,'stance':p<.42,'foot':list(map(float,foot))})
 # A single trouser seat overlaps the thigh caps beneath the shirt hem.
 def join(side):
  a,b=thighs[side];v=b-a;n=np.array([-v[1],v[0]])/np.linalg.norm(v);c=a+.28*v
  return c+n*5.4,c-n*5.4
 lo,li=join(-1);ri,ro=join(1);wl=hip+[-11,-5];wr=hip+[11,-5]
 def pt(p):return f'{p[0]:.3f} {p[1]:.3f}'
 path(g,f'M{pt(wl)} Q{pt(hip+[-12,1])} {pt(lo)} L{pt(li)} Q{pt(hip+[0,8])} {pt(ri)} L{pt(ro)} Q{pt(hip+[12,1])} {pt(wr)} Z','#252c2e','none')
 path(g,f'M{pt(wl)} Q{pt(hip+[-12,1])} {pt(lo)}','none','#14191a',.8)
 path(g,f'M{pt(wr)} Q{pt(hip+[12,1])} {pt(ro)}','none','#14191a',.8)
 path(g,f'M{pt(hip+[-7,-2])} Q{pt(hip+[-8,2])} {pt(lo+[2,-1])}','none','#404749',1.2)
 path(g,f'M{pt(hip+[1,1])} Q{pt(hip+[0,4])} {pt(hip+[1,7])}','none','#1c2527',.8)
 up=copy.deepcopy(upper);lean=(13+2.0*math.sin(2*math.pi*(q-.1)))*(1-settle)+(8+3*aim-kick*.6)*settle+25*crouch;lean=lean*(1-fall)+90*fall;up.set('transform',f'translate({hip[0]-43} {hip[1]-55}) rotate({lean} 43 55) '+up.get('transform',''))
 if stop is not None:
  lean=13+(7-13)*smooth(stop)+6*aim+15*crouch-1.2*kick;up.set('transform',f'translate({hip[0]-43} {hip[1]-55}) rotate({lean} 43 55) '+upper.get('transform',''))
 head=up.find(".//*[@id='head']");head.set('transform',f'translate({3*aim} {3*aim}) rotate({-lean*.6} 43 28) '+head.get('transform',''))
 # Both hands follow the rifle exactly. Arms articulate from fixed shoulders.
 if stop is not None:q=0
 delta=-9+1.4*math.sin(4*math.pi*(q-.13));lift=-7+.9*math.sin(4*math.pi*(q-.08))
 delta=delta*(1-aim)-5*aim
 lift=lift*(1-aim)-14*aim-kick*.8
 dx=4*aim-1.5*kick
 def grip(p):
  ang=math.radians(8+delta);v=np.array(p)-[24,41]
  return np.array([24+dx,41+lift])+np.array([[math.cos(ang),-math.sin(ang)],[math.sin(ang),math.cos(ang)]])@v
 for name in ['weapon','hand_near','hand_far']:
  child=up.find(f".//*[@id='{name}']");child.set('transform',f'translate({dx} {lift}) rotate({delta} 24 41) '+child.get('transform',''))
 for name,shoulder,hand,bend,L in [('far',[55,34],[55,64],-1,15.4),('near',[27,34],[31.951448064247543,56.58122182890591],1,15)]:
  arm=up.find(f".//*[@id='arm_{name}']");arm.clear();a=np.array(shoulder,dtype=float);c=grip(hand);v=c-a;dist=np.linalg.norm(v)
  assert dist<2*L,(name,dist)
  n=np.array([-v[1],v[0]])/dist*bend;b=(a+c)/2+n*math.sqrt(L*L-dist*dist/4)
  if name=='far':b+=np.array([-2.8,2.0])
  limb(arm,a,b,3.7,2.6,'#646765')
  sleeve=list(arm)[1];sleeve.set('fill','#a3a497')
  # Rounded sleeve head overlaps the chest-side join and upper-arm cap.
  v=b-a;n=np.array([-v[1],v[0]])/np.linalg.norm(v)
  joint=a+.33*v
  inner=np.array([50.,29.]) if name=='far' else np.array([31.,29.])
  outer=a+(np.array([3.4,-3.0]) if name=='far' else np.array([-3.4,-3.0]))
  left=joint+n*3.3;right=joint-n*3.3
  def fmt(p):return f'{p[0]:.3f} {p[1]:.3f}'
  path(arm,f'M{fmt(inner)} Q{fmt(a+[0,-5])} {fmt(outer)} Q{fmt(a+v*.1+n*3.7)} {fmt(left)} L{fmt(right)} Q{fmt(a+v*.1-n*3.7)} {fmt(inner)}Z','#646765','none')
  path(arm,f'M{fmt(inner)} Q{fmt(a+[0,-5])} {fmt(outer)}','none','#242a29',.8)
  path(arm,f'M{fmt(a+[0,-2])} Q{fmt(a+v*.17+n*1.5)} {fmt(joint+n*1.5)}','none','#a3a497',1.2)
  limb(arm,b,c,2.7,2.0,'#71563e');list(arm)[-1].set('fill','#aa8960')
  poly(arm,[b+[-1.4,-.5],b+[1.7,.1],b+[1.2,1.4],b+[-1,1]],'#5b4935','none')
  states.append({'arm':name,'shoulder':list(a),'elbow':list(b),'grip':list(c),'upper_length':float(np.linalg.norm(b-a)),'forearm_length':float(np.linalg.norm(c-b))})
 # Expose the actual upper handguard edge above the supporting palm.
 edge=E.SubElement(up,NS+'g',{'transform':up.find(".//*[@id='weapon']").get('transform')})
 poly(edge,[[34,1],[43,1],[43,2.5],[34,2.5]],'#171d1c','none')
 path(edge,'M34 1.2 L43 1.2','none','#454c47',.45)
 # Muzzle and trajectory are derived from the same transforms as the rifle.
 def rotate(deg):
  a=math.radians(deg);return np.array([[math.cos(a),-math.sin(a)],[math.sin(a),math.cos(a)]])
 gm=rotate(lean-3)@np.diag([.88,1.])
 muzzle=hip+gm@(np.array([24+dx,41+lift])+rotate(40+delta)@np.array([68.,3.])-np.array([43.,55.]))
 direction=gm@rotate(40+delta)@np.array([1.,0.]);direction/=np.linalg.norm(direction)
 states.append({'muzzle':muzzle.tolist(),'direction':direction.tolist()})
 g.append(up)
 root=E.Element(NS+'svg',{'width':'128','height':'128','viewBox':'0 0 128 128'});root.append(g);return root,states
