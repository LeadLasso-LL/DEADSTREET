import gait
from pathlib import Path
import math,copy,subprocess,xml.etree.ElementTree as E,json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).parent;NS='{http://www.w3.org/2000/svg}';
F=np.array([1.,0.,0.]);F/=np.linalg.norm(F);RIGHT=np.array([F[2],0,-F[0]]);el=math.radians(50)
def proj(v):return np.array([64+v[0],110+v[2]*math.sin(el)-v[1]*math.cos(el)])
def path(g,d,fill,stroke='#14191a',w=1):E.SubElement(g,NS+'path',{'d':d,'fill':fill,'stroke':stroke,'stroke-width':str(w),'stroke-linejoin':'round','stroke-linecap':'round'})
def poly(g,ps,fill,stroke='#14191a',w=1):path(g,'M'+' L'.join(f'{x:.3f} {y:.3f}' for x,y in ps)+'Z',fill,stroke,w)
def limb(g,a,b,wa,wb,fill):
 v=b-a;n=np.array([-v[1],v[0]])/np.linalg.norm(v);m=a+.55*v
 poly(g,[a+n*wa,m+n*(wa*.75+wb*.25),b+n*wb,b-n*wb,m-n*(wa*.35+wb*.65),a-n*wa],fill)
 poly(g,[a+n*wa*.50,m+n*wa*.5,b+n*wb*.3,b-n*wb*.25,m-n*wb*.35], '#42494a','none')
def smooth(t):return t*t*(3-2*t)
def make_lower(q,stop=None,settle=0,crouch=0,fall=0):
 phase=(q*2)%1
 h=gait.height(q,54);hip=proj(np.array([0,h,0]));g=E.Element(NS+'g');states=[];thighs=[]
 if stop is not None:h=58.5;hip=proj(np.array([0,h,0]))
 h=h*(1-settle)+57.5*settle-30*crouch-12*fall;hip=proj(np.array([0,h,0]))
 for side in [1,-1]:
  p=(q+(0 if side==-1 else .5))%1
  if stop is not None:along=3 if side==-1 else -4;lift=0;pitch=0;toe_pivot=0
  else:along,lift,pitch,toe_pivot=gait.foot(p)
  along=along*(1-settle)+(5 if side==-1 else -6)*settle;lift*=1-settle;pitch*=1-settle;toe_pivot*=1-settle
  foot=RIGHT*side*6.7+F*along+np.array([0,lift,0]);foot=foot*(1-fall)+np.array([-40.,0.,side*4.])*fall;ang=math.radians(pitch)
  def boot_world(x,y):
   xx=x-toe_pivot
   return foot+F*(toe_pivot+xx*math.cos(ang)-y*math.sin(ang))+np.array([0,xx*math.sin(ang)+y*math.cos(ang),0])
  ank=boot_world(0,5.5);hp=RIGHT*side*6.2+np.array([0,h,0]);v=ank-hp;dist=np.linalg.norm(v);direction=v/dist;hint=F-direction*np.dot(F,direction);hint/=np.linalg.norm(hint)
  k=(26.5**2-29.5**2+dist**2)/(2*dist);knee=hp+direction*k+hint*math.sqrt(max(0,26.5**2-k*k));knee=knee*(1-fall)+np.array([-19.,3.,side*8.])*fall;a,b,c=map(proj,[hp,knee,ank]);thighs.append((a,b))
  limb(g,a,b,5.5,4.0,'#252c2e');limb(g,b,c,4.2,2.85,'#252c2e')
  u=(b-a)/np.linalg.norm(b-a);v2=(c-b)/np.linalg.norm(c-b);nu=np.array([-u[1],u[0]]);nv=np.array([-v2[1],v2[0]]);n=nu+nv;n/=np.linalg.norm(n)
  def xy(p):return f'{p[0]:.3f} {p[1]:.3f}'
  path(g,f'M{xy(b-u*4+nu*3.7)} Q{xy(b+n*4)} {xy(b+v2*4+nv*3.4)} L{xy(b+v2*4-nv*3.4)} Q{xy(b-n*4)} {xy(b-u*4-nu*3.7)}Z','#252c2e','none')
  path(g,f'M{xy(b-n*2)} Q{xy(b+v2)} {xy(b+n*2)}','none','#42494a',.6)
  # Side-specific boot: ankle shaft, heel, instep and a low rounded toe.
  def bp(x,y):return xy(proj(boot_world(x*1.34,y*1.24)))
  path(g,f'M{bp(-2,7)} L{bp(2,7)} L{bp(2.8,4.5)} Q{bp(5.5,3.8)} {bp(7.5,2.9)} Q{bp(8.9,1.5)} {bp(8.4,0)} L{bp(-3,0)} Q{bp(-4,.4)} {bp(-3.4,2.2)} L{bp(-3,5)}Z','#50513c','#171e1e',.75)
  path(g,f'M{bp(-3,.6)} L{bp(8.4,.6)}','none','#111819',.9)
  path(g,f'M{bp(-1,5.8)} L{bp(1.2,5.5)} M{bp(3,3.9)} Q{bp(5.7,3.3)} {bp(7,2.6)}','none','#666453',.6)
  states.append({'phase':p,'stance':p<.48,'foot':list(map(float,foot))})
 # Stable hip silhouette and separate overlapping thigh joins.
 # Each thigh blends to the pelvis independently; crossing legs cannot swap the seat edge.
 for a,b in thighs:
  v=b-a;n=np.array([-v[1],v[0]])/np.linalg.norm(v);end=a+.44*v
  path(g,f'M{xy(hip+[-5,-4])} L{xy(hip+[5,-4])} Q{xy(a-n*4.8)} {xy(end-n*4.4)} L{xy(end+n*4.4)} Q{xy(a+n*4.8)} {xy(hip+[-5,-4])}Z','#252c2e','none')
 path(g,f'M{xy(hip+[-6,-6])} L{xy(hip+[5,-6])} Q{xy(hip+[8,-1])} {xy(hip+[6,6])} Q{xy(hip+[2,10])} {xy(hip+[-3,9])} Q{xy(hip+[-10,8])} {xy(hip+[-10,3])} Q{xy(hip+[-10,-2])} {xy(hip+[-6,-6])}Z','#252c2e','none')
 path(g,f'M{xy(hip+[-6,-6])} Q{xy(hip+[-10,-2])} {xy(hip+[-10,3])} Q{xy(hip+[-10,6])} {xy(hip+[-7,7.5])}','none','#14191a',.7)
 path(g,f'M{xy(hip+[-6,0])} Q{xy(hip+[-7,3])} {xy(hip+[-4,5])}','none','#42494a',.7)
 return g,states,hip
