"""Editable vector vehicle construction, projected consistently into eight views.

Extends the game's code-authored street/vehicle art. No generated photographs,
rotated flat side sprites, or changes to the soldier rig. Python geometry is the editable art master; the depth-buffer renderer
produces the canonical transparent PNG sprites.
"""
from pathlib import Path
import math,json,random,sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
import numpy as np
from vehicle_detail_geometry import motorcycle,exotic,armored,shell,canopy,badge
from PIL import Image,ImageDraw,ImageColor
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/art/vehicles/fleet'
PPU=40
W,H=640,480
ORIGIN=(320,330)
ANGLES={'e':0,'se':45,'s':90,'sw':135,'w':180,'nw':225,'n':270,'ne':315}
INK='#171c1e';RUBBER='#1c2022';GLASS='#293f48';CHROME='#a3a8a3'
def shade(c,m):
 rgb=ImageColor.getrgb(c)
 return '#'+''.join(f'{max(0,min(255,round(v*m))):02x}' for v in rgb)
def mix(a,b,t):return tuple(a[i]+(b[i]-a[i])*t for i in range(len(a)))
class Drawing:
 def __init__(self,angle):self.a=math.radians(angle);self.faces=[]
 def rotate(self,p):
  x,y,z=p;c,s=math.cos(self.a),math.sin(self.a)
  return (x*c-y*s,x*s+y*c,z)
 def project(self,p):
  x,y,z=self.rotate(p)
  return (ORIGIN[0]+x*PPU,ORIGIN[1]+(y*.75-z*.85)*PPU)
 def poly(self,points,color,outline=INK,width=1,priority=0):
  depth=sum(self.rotate(p)[1]*.85+p[2]*.75 for p in points)/len(points)+priority
  self.faces.append((depth,points,color,outline,width))
 def line(self,points,color=CHROME,width=1,priority=.012):self.poly(points,None,color,width,priority)
 def box(self,x0,x1,y0,y1,z0,z1,color):
  self.poly([(x0,y0,z0),(x1,y0,z0),(x1,y0,z1),(x0,y0,z1)],shade(color,.82))
  self.poly([(x1,y1,z0),(x0,y1,z0),(x0,y1,z1),(x1,y1,z1)],shade(color,.9))
  self.poly([(x1,y0,z0),(x1,y1,z0),(x1,y1,z1),(x1,y0,z1)],shade(color,.94))
  self.poly([(x0,y1,z0),(x0,y0,z0),(x0,y0,z1),(x0,y1,z1)],shade(color,.75))
  self.poly([(x0,y0,z1),(x1,y0,z1),(x1,y1,z1),(x0,y1,z1)],shade(color,1.14),priority=.005)
 def hull(self,sections,color):
  rings=[[(x,-w,z0),(x,w,z0),(x,w,z1),(x,-w,z1)] for x,w,z0,z1 in sections]
  self.poly(list(reversed(rings[0])),shade(color,.80))
  self.poly(rings[-1],shade(color,.97))
  for a,b in zip(rings,rings[1:]):
   for i,m in [(1,.87),(2,1.14),(3,.79)]:
    j=(i+1)%4
    self.poly([a[i],b[i],b[j],a[j]],shade(color,m))
 def cabin(self,x0,x1,y0,y1,z0,z1,color,slant=.25,windows=2):
  # Four sloped pillars and a roof; glass follows the exact body projection.
  top0=x0+slant;top1=x1-slant
  for side,y in [(-1,y0),(1,y1)]:
   roof_y=y*.85
   bottom=[(x0,y,z0),(x1,y,z0)];top=[(top0,roof_y,z1),(top1,roof_y,z1)]
   self.poly([bottom[0],bottom[1],top[1],top[0]],shade(color,.93 if side==1 else .83))
   for n in range(windows):
    a=(n+.08)/windows;b=(n+.92)/windows
    quad=[mix(mix(bottom[0],bottom[1],a),mix(top[0],top[1],a),.13),mix(mix(bottom[0],bottom[1],b),mix(top[0],top[1],b),.13),mix(mix(bottom[0],bottom[1],b),mix(top[0],top[1],b),.87),mix(mix(bottom[0],bottom[1],a),mix(top[0],top[1],a),.87)]
    self.poly(quad,GLASS,shade(color,1.2),1,.016)
    self.line([mix(quad[0],quad[3],.78),mix(quad[1],quad[2],.78)],'#667b80',1,.024)
  for end,x,tx in [('rear',x0,top0),('front',x1,top1)]:
   quad=[(x,y0,z0),(x,y1,z0),(tx,y1*.85,z1),(tx,y0*.85,z1)]
   self.poly(quad,color)
   center=tuple(sum(p[i] for p in quad)/4 for i in range(3))
   glass=[mix(center,p,.83) for p in quad]
   self.poly(glass,GLASS,shade(color,1.22),1,.019)
   self.line([mix(glass[0],glass[3],.8),mix(glass[1],glass[2],.8)],'#84969a',1,.022)
   if end=='front':
    self.line([mix(glass[0],glass[1],.2),mix(glass[0],glass[2],.30)],'#192629',1,.029)
    self.line([mix(glass[0],glass[1],.65),mix(glass[1],glass[3],.3)],'#192629',1,.029)
  self.poly([(top0,y0*.85,z1),(top1,y0*.85,z1),(top1,y1*.85,z1),(top0,y1*.85,z1)],shade(color,1.18),priority=.018)
 def marking(self,word,x,y,z,width,height,color):
  glyphs={'P':['11110','10001','10001','11110','10000','10000','10000'],'O':['01110','10001','10001','10001','10001','10001','01110'],'L':['10000','10000','10000','10000','10000','10000','11111'],'I':['11111','00100','00100','00100','00100','00100','11111'],'C':['01111','10000','10000','10000','10000','10000','01111'],'E':['11111','10000','10000','11110','10000','10000','11111'],'T':['11111','00100','00100','00100','00100','00100','00100'],'R':['11110','10001','10001','11110','10100','10010','10001']}
  glyphs.update({'S':['01111','10000','10000','01110','00001','00001','11110'],'W':['10001','10001','10001','10101','10101','11011','10001'],'A':['01110','10001','10001','11111','10001','10001','10001']})
  dx=width/(len(word)*6-1);dz=height/7;direction=1 if y>0 else -1
  for n,char in enumerate(word):
   for row,bits in enumerate(glyphs[char]):
    for col,bit in enumerate(bits):
     if bit!='1':continue
     xx=x+direction*((n*6+col)*dx-width/2);zz=z+(6-row)*dz
     self.poly([(xx,y,zz),(xx+dx*direction,y,zz),(xx+dx*direction,y,zz+dz),(xx,y,zz+dz)],color,None,priority=.13)
 def wheel(self,x,y,r=.34,width=.19,chrome=False,spokes=5,rim_color=None):
  # Cylindrical wheel, not a floating circle pasted onto the body.
  for k in range(16):
   a=k*math.tau/16;b=(k+1)*math.tau/16
   self.poly([(x+r*math.cos(a),y-width/2,r+r*math.sin(a)),(x+r*math.cos(b),y-width/2,r+r*math.sin(b)),(x+r*math.cos(b),y+width/2,r+r*math.sin(b)),(x+r*math.cos(a),y+width/2,r+r*math.sin(a))],RUBBER,RUBBER)
  for yy in [y-width/2,y+width/2]:
   self.poly([(x+r*math.cos(k*math.tau/16),yy,r+r*math.sin(k*math.tau/16)) for k in range(16)],RUBBER,INK,1,.003)
   ri=r*.53
   self.poly([(x+ri*math.cos(k*math.tau/12),yy,r+ri*math.sin(k*math.tau/12)) for k in range(12)],rim_color or ('#929991' if chrome else '#545d5e'),INK,1,.007)
   for k in range(spokes):
    a=k*math.tau/spokes
    self.line([(x,yy,r),(x+ri*.8*math.cos(a),yy,r+ri*.8*math.sin(a))],CHROME if chrome else '#9a9f96',1,.014)
 def export(self,path):
  rgba=np.zeros((H,W,4),dtype=np.uint8);depths=np.full((H,W),-np.inf,dtype=np.float32)
  def triangle(vertices,color):
   a,b,c=vertices
   x0=max(0,math.floor(min(a[0],b[0],c[0])));x1=min(W-1,math.ceil(max(a[0],b[0],c[0])))
   y0=max(0,math.floor(min(a[1],b[1],c[1])));y1=min(H-1,math.ceil(max(a[1],b[1],c[1])))
   if x1<x0 or y1<y0:return
   den=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
   if abs(den)<.0001:return
   yy,xx=np.mgrid[y0:y1+1,x0:x1+1];xx=xx+.5;yy=yy+.5
   w0=((b[1]-c[1])*(xx-c[0])+(c[0]-b[0])*(yy-c[1]))/den
   w1=((c[1]-a[1])*(xx-c[0])+(a[0]-c[0])*(yy-c[1]))/den;w2=1-w0-w1
   zz=w0*a[2]+w1*b[2]+w2*c[2]
   target=depths[y0:y1+1,x0:x1+1];mask=(w0>=-.0001)&(w1>=-.0001)&(w2>=-.0001)&(zz>=target)
   target[mask]=zz[mask];rgba[y0:y1+1,x0:x1+1][mask]=(*ImageColor.getrgb(color),255)
  def segment(a,b,color,width):
   steps=max(2,math.ceil(max(abs(a[0]-b[0]),abs(a[1]-b[1]))*2))
   t=np.linspace(0,1,steps);xx=np.rint(a[0]+(b[0]-a[0])*t).astype(int);yy=np.rint(a[1]+(b[1]-a[1])*t).astype(int);zz=a[2]+(b[2]-a[2])*t+.008
   radius=max(0,width//2)
   for dx in range(-radius,radius+1):
    for dy in range(-radius,radius+1):
     x=xx+dx;y=yy+dy;valid=(x>=0)&(x<W)&(y>=0)&(y<H);x=x[valid];y=y[valid];z=zz[valid]
     mask=z>=depths[y,x]-.022;x=x[mask];y=y[mask];z=z[mask]
     rgba[y,x]=(*ImageColor.getrgb(color),255);depths[y,x]=np.maximum(depths[y,x],z)
  projected=[]
  for order,points,color,outline,width in sorted(self.faces,key=lambda f:f[0]):
   xy=[self.project(p) for p in points]
   mean=sum(self.rotate(p)[1]*.85+p[2]*.75 for p in points)/len(points)
   vertices=[(xy[i][0],xy[i][1],self.rotate(p)[1]*.85+p[2]*.75+order-mean) for i,p in enumerate(points)]
   projected.append((vertices,color,outline,width))
   if color:
    for i in range(1,len(vertices)-1):triangle([vertices[0],vertices[i],vertices[i+1]],color)
  for vertices,color,outline,width in projected:
   if not outline:continue
   for a,b in zip(vertices,vertices[1:]+([vertices[0]] if color else [])):segment(a,b,outline,width)
  image=Image.fromarray(rgba)
  path.parent.mkdir(parents=True,exist_ok=True)
  image.save(path.with_suffix('.png'))
  return image
def bike(d,m):motorcycle(d,m)
def vehicle(d,m,door=0):
 if m['vehicle_class']=='two_wheelers':bike(d,m);return
 if m['body'] in ['sportcoupe','grandtourer','exotic_curved']:exotic(d,m,door);return
 if m['body'] in ['tactical_utility','armored_transport']:armored(d,m,door);return
 L=m['length'];Y=m['width']/2;h=m['height'];p=m['paint'];b=m['body']
 heavy=m['vehicle_class']=='heavy_transports';utility=m['vehicle_class']=='utility_vehicles'
 r=.41 if heavy else (.43 if b=='lifted_pickup' else (.36 if utility else .30))
 bottom=.45 if heavy else .34;cab_h=min(h,2.18) if b in ['boxtruck','cabover','military_truck','surplus_truck'] else h;belt=cab_h*.57
 front=L*.31;rear=-L*.32
 for x in [rear,front]+([-L*.12] if b=='surplus_truck' else []):
  for side in [-1,1]:d.wheel(x,side*(Y-.08),r,.24 if heavy else .20,b in ['luxury','towncar','lowrider','vintage','grandtourer'],6,'#a58a57' if b=='luxury_suv' else None)
 sports=b in ['sportcoupe','grandtourer']
 nose=.64 if sports else (.81 if b in ['compact','crossover','executive'] else .87)
 sections=[(-L*.49,Y*.78,bottom+.06,belt-.13),(-L*.44,Y*.92,bottom,belt-.025),(-L*.35,Y*.98,bottom,belt),(L*.24,Y*.98,bottom,belt),(L*.39,Y*.94,bottom,belt-.05),(L*.49,Y*nose,bottom+.06,belt-(.25 if sports else .12))]
 if b=='vintage':sections=[(-L*.49,Y*.68,bottom+.11,belt-.14),(-L*.43,Y*.9,bottom+.025,belt),(-L*.31,Y*.99,bottom,belt+.06),(L*.27,Y*.99,bottom,belt+.07),(L*.42,Y*.88,bottom+.05,belt-.02),(L*.49,Y*.66,bottom+.14,belt-.17)]
 rounded=b in ['luxury','towncar','executive','compact','crossover','luxury_suv','vintage']
 if rounded:shell(d,sections,p)
 else:d.hull(sections,p)
 # Long lower body facets, rocker trim, bumpers, and individual wheel arches.
 d.box(-L/2,L/2,-Y+.02,Y-.02,bottom+.02,bottom+.15,'#565d5b' if b in ['vintage','lowrider','towncar','luxury'] else '#2b3131')
 for side in [-1,1]:
  y=side*Y
  for x in [rear,front]+([-L*.12] if b=='surplus_truck' else []):
   pts=[(x+math.cos(a)*r*1.12,y,r+math.sin(a)*r*1.1) for a in [i*math.pi/12 for i in range(13)]]
   d.line(pts,shade(p,.67),3,.09)
  d.line([(-L*.46,y,belt-.06),(L*.46,y,belt-.06)],shade(p,1.33),1,.03)
 cab0=-L*.28;cab1=L*.22;slant=.35;windows=2
 if b in ['hatch','crossover','suv','luxury_suv','police_suv','offroad','surplus_utility','tactical_utility']:cab0=-L*.41;windows=3;slant=.20
 if b in ['sportcoupe','grandtourer','tuner']:cab0=-L*.26;cab1=L*.18;slant=.52;windows=1 if b!='tuner' else 2
 if b=='sportcoupe':cab0=-L*.12;cab1=L*.31;slant=.57
 if b=='grandtourer':cab0=-L*.31;cab1=L*.11;slant=.45
 if b=='vintage':cab0=-L*.24;cab1=L*.20;slant=.44
 if b in ['luxury','towncar','executive']:cab0=-L*.32;cab1=L*.21;slant=.29
 if b in ['pickup','crew_pickup','lifted_pickup']:
  cab0=-L*.04 if b=='pickup' else -L*.15;cab1=L*.29;slant=.15;windows=1 if b=='pickup' else 2
 if heavy:
  cab0=L*.19;cab1=L*.47;slant=.13;windows=1
  if b in ['panelvan','passengervan','highroof']:cab0=-L*.44;cab1=L*.36;slant=.17;windows=4 if b=='passengervan' else 1
  if b in ['bus','rv','stepvan']:cab0=-L*.47;cab1=L*.44;slant=.07;windows=7 if b=='bus' else (3 if b=='rv' else 1)
 if rounded:
  roof='#d3cfc0' if b=='luxury' else ('#5b2933' if b=='towncar' else ('#252c31' if b=='luxury_suv' else p))
  canopy(d,cab0,cab1,Y*.92,belt,cab_h,roof,slant,windows)
 else:d.cabin(cab0,cab1,-Y*(.88 if sports else .96),Y*(.88 if sports else .96),belt,cab_h,p,slant,windows)
 if b in ['panelvan','highroof']:
  # Opaque cargo side panels replace the broad rear glass region.
  for side in [-1,1]:
   y=side*Y*.96
   d.poly([(-L*.40,y,belt+.02),(L*.06,y,belt+.02),(L*.06,y*.85,h-.09),(-L*.40,y*.85,h-.09)],shade(p,.94),shade(p,1.1),1,.065)
   d.line([(-L*.18,y,belt+.04),(-L*.18,y*.85,h-.12)],shade(p,.64),1,.074)
 if b in ['boxtruck','cabover']:
  d.box(-L*.48,L*.15,-Y,Y,bottom+.30,h, '#d4c9ac' if b=='boxtruck' else '#a9ada4')
  for side in [-1,1]:
   y=side*(Y+.005)
   d.line([(-L*.45,y,bottom+.53),(L*.10,y,bottom+.53)],'#665d4d',2,.025)
   for x in [-L*.43,L*.1]:d.line([(x,y,bottom+.4),(x,y,h-.1)],'#8c9086',2,.024)
   if b=='boxtruck':d.poly([(-L*.44,y,h*.58),(L*.11,y,h*.58),(L*.11,y,h*.68),(-L*.44,y,h*.68)],'#a7733c',None,priority=.032)
  for z in [bottom+.5+i*.18 for i in range(int((h-bottom-.55)/.18))]:d.line([(-L*.485,-Y*.9,z),(-L*.485,Y*.9,z)],'#8a8c82',1,.08)
 if b in ['military_truck','surplus_truck']:
  d.box(-L*.47,L*.13,-Y,Y,bottom+.2,h*.52,shade(p,.85))
  d.cabin(-L*.47,L*.13,-Y,Y,h*.52,h,shade(p,1.12),.12,0)
  for side in [-1,1]:
   y=side*(Y+.015)
   for x in [-L*.4,-L*.22,-L*.04,L*.1]:d.line([(x,y,bottom+.3),(x,y,h*.51)],'#3e473b',2,.04)
   d.line([(-L*.43,y,h*.55),(L*.1,y,h*.55)],'#393f34',2,.04)
 if b in ['pickup','crew_pickup','lifted_pickup']:
  d.box(-L*.46,cab0-.06,-Y*.87,Y*.87,belt-.09,belt+.02,shade(p,.63))
  for side in [-1,1]:d.box(-L*.47,cab0-.05,side*Y*.94-.055,side*Y*.94+.055,belt-.02,belt+.18,p)
  d.box(-L*.47,-L*.44,-Y*.93,Y*.93,belt-.02,belt+.18,p)
  for y in [-Y*.6,-Y*.3,0,Y*.3,Y*.6]:d.line([(-L*.44,y,belt+.025),(cab0-.10,y,belt+.025)],shade(p,.8),1,.02)
 if b=='rv':
  for side in [-1,1]:
   y=side*Y*.96
   d.poly([(-L*.45,y,belt-.10),(L*.43,y,belt-.10),(L*.43,y,belt+.10),(-L*.45,y,belt+.10)],'#855642',None,priority=.035)
  d.box(-.8,.3,-.48,.48,h,h+.15,'#a6a698')
 if b=='bus':
  for side in [-1,1]:
   y=side*Y*.98
   for z in [belt-.28,belt-.12]:d.line([(-L*.47,y,z),(L*.44,y,z)],'#403e30',2,.04)
  d.box(L*.38,L*.44,-Y*.85,Y*.85,h-.17,h-.10,'#4c4937')
 if b=='lowrider':d.poly([(cab0+slant,-Y*.82,h+.014),(cab1-slant,-Y*.82,h+.014),(cab1-slant,Y*.82,h+.014),(cab0+slant,Y*.82,h+.014)],'#bbb4a0' if b=='lowrider' else '#383b35')
 # Grille, separated headlights, tail lights, plate and recessed bumper detail.
 xf=L*.493;xb=-L*.493
 d.poly([(xf,-Y*.56,bottom+.19),(xf,Y*.56,bottom+.19),(xf,Y*.56,belt-.10),(xf,-Y*.56,belt-.10)],'#283133',CHROME)
 for y in [-Y*.40,-Y*.20,0,Y*.20,Y*.40]:d.line([(xf+.008,y,bottom+.23),(xf+.008,y,belt-.14)],'#8c948f',1,.028)
 for side in [-1,1]:
  y=side*Y*.76
  d.poly([(xf,y-.16,belt-.26),(xf,y+.16,belt-.26),(xf,y+.16,belt-.08),(xf,y-.16,belt-.08)],'#dad5b9',INK,1,.045)
  d.poly([(xb,y-.13,belt-.22),(xb,y+.13,belt-.22),(xb,y+.13,belt-.08),(xb,y-.13,belt-.08)],'#944941',INK,1,.045)
 d.poly([(xf+.02,-.19,bottom+.13),(xf+.02,.19,bottom+.13),(xf+.02,.19,bottom+.23),(xf+.02,-.19,bottom+.23)],'#b5b29d',INK,1,.05)
 if sports:
  d.poly([(xf+.03,-Y*.66,bottom+.07),(xf+.03,Y*.66,bottom+.07),(xf+.03,Y*.66,belt-.08),(xf+.03,-Y*.66,belt-.08)],p,None,priority=.065)
  d.poly([(xf+.04,-Y*.4,bottom+.10),(xf+.04,Y*.4,bottom+.10),(xf+.04,Y*.32,bottom+.25),(xf+.04,-Y*.32,bottom+.25)],'#202a2e',INK,1,.07)
  for side in [-1,1]:
   y=side*Y*.58
   d.poly([(xf+.045,y-.18,belt-.13),(xf+.045,y+.18,belt-.13),(L*.40,y+.18,belt-.028),(L*.40,y-.18,belt-.028)],'#bdc9c6',INK,1,.08)
  if b=='sportcoupe':
   for x in [-L*.41,-L*.37,-L*.33,-L*.29]:d.line([(x,-Y*.5,belt+.025),(x,Y*.5,belt+.025)],'#303637',2,.11)
   for side in [-1,1]:d.poly([(-L*.21,side*Y*.99,bottom+.25),(-L*.06,side*Y*.99,bottom+.29),(-L*.03,side*Y*.99,belt-.03),(-L*.18,side*Y*.99,belt-.08)],'#243139',INK,1,.10)
 if b=='luxury':
  d.poly([(xf+.025,-Y*.34,bottom+.15),(xf+.025,Y*.34,bottom+.15),(xf+.025,Y*.34,belt+.10),(xf+.025,-Y*.34,belt+.10)],'#495152',CHROME,2,.08)
  for y in [-.5,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.5]:d.line([(xf+.04,y,bottom+.21),(xf+.04,y,belt+.03)],CHROME,1,.09)
 for side in [-1,1]:
  y=side*(Y+.025)
  for x in ([L*.09,-L*.17] if m['doors']==4 else [L*.22]):
   d.line([(x,y,bottom+.19),(x,y,belt-.03)],shade(p,.56),1,.05)
   d.line([(x-.2,y,belt-.12),(x-.04,y,belt-.12)],CHROME,2,.055)
  d.line([(cab1-.08,side*Y*.87,belt+.15),(cab1,side*(Y+.075),belt+.19)],'#252e30',2,.1)
  d.box(cab1-.08,cab1+.08,side*(Y+.075)-.075,side*(Y+.075)+.075,belt+.15,belt+.24,p)
 if b in ['police_sedan','police_suv']:
  d.box(-.12,.12,-Y*.67,Y*.67,h+.05,h+.16,'#4f6660')
  d.box(-.12,.12,-Y*.67,-.04,h+.10,h+.20,'#586c8b');d.box(-.12,.12,.04,Y*.67,h+.10,h+.20,'#98605b')
  for side in [-1,1]:
   y=side*(Y+.032)
   d.poly([(-L*.32,y,bottom+.20),(L*.30,y,bottom+.20),(L*.30,y,belt-.02),(-L*.32,y,belt-.02)],'#536b54',None,priority=.064)
   d.marking('POLICE',-.25,y,bottom+.23,1.30,.23,'#e4dfc8')
   badge(d,'nbpd',.66,y+.008*side,bottom+.38,.34)
  for yy in [-Y*.57,Y*.57]:d.line([(xf+.12,yy,bottom+.1),(xf+.12,yy,belt+.08)],'#242a2b',3,.10)
 if m.get('brand')=='trc':
  for side in [-1,1]:
   y=side*(Y+.06)
   d.poly([(-L*.30,y,bottom+.18),(L*.28,y,bottom+.18),(L*.28,y,belt-.06),(-L*.30,y,belt-.06)],'#284b3c',None,priority=.06)
   d.marking('TRC',-.26,y,bottom+.23,.75,.24,'#b6a770')
   badge(d,'trc',.55,y+.005*side,bottom+.37,.35)
 if b in ['offroad','luxury_suv','suv','tactical_utility','surplus_utility']:
  for side in [-1,1]:d.line([(cab0+.25,side*Y*.74,h+.06),(cab1-.25,side*Y*.74,h+.06)],'#343c3b',2,.02)
 if b=='surplus_utility':
  d.poly([(cab0+slant,-Y*.82,h+.026),(-L*.04,-Y*.82,h+.026),(-L*.04,Y*.82,h+.026),(cab0+slant,Y*.82,h+.026)],'#73725a',INK,1,.035)
  # Rear-mounted spare, oriented across the tailgate.
  for k in range(16):
   a=k*math.tau/16;aa=(k+1)*math.tau/16
   d.poly([(-L*.51,.36*math.cos(a),.9+.36*math.sin(a)),(-L*.51,.36*math.cos(aa),.9+.36*math.sin(aa)),(-L*.56,.36*math.cos(aa),.9+.36*math.sin(aa)),(-L*.56,.36*math.cos(a),.9+.36*math.sin(a))],RUBBER,RUBBER)
  d.poly([(-L*.565,.36*math.cos(k*math.tau/16),.9+.36*math.sin(k*math.tau/16)) for k in range(16)],RUBBER,INK)
  d.poly([(-L*.568,.17*math.cos(k*math.tau/12),.9+.17*math.sin(k*math.tau/12)) for k in range(12)],'#5c655b',INK)
 if b=='offroad':
  for x in [cab0+.3,cab0+.7,cab0+1.1,cab0+1.5]:d.line([(x,-Y*.76,h+.08),(x,Y*.76,h+.08)],'#303837',2,.03)
 if b=='tuner':d.box(-L*.44,-L*.30,-Y*.84,Y*.84,belt+.28,belt+.33,shade(p,.7))
 if b in ['sportcoupe','grandtourer']:
  for side in [-1,1]:d.line([(L*.20,side*Y*.5,belt+.017),(L*.41,side*Y*.5,belt+.017)],shade(p,.55),2,.04)
 # Localized dirt/scratches, consistent between angles and door states.
 rng=random.Random(m['id'])
 for _ in range(25 if m['price']<20000 else 9):
  x=rng.uniform(-L*.42,L*.42);y=Y*rng.choice([-1,1]);z=rng.uniform(bottom+.18,belt-.06)
  d.line([(x,y,z),(x+.10,y,z+.015)],shade(p,.76),1,.07)
 if door>0 and m['doors']:
  for door_x in m['door_rows']:
   x=L*door_x;width=.78
   for side in [-1,1]:
    hinge=(x,side*Y,bottom+.18);ang=door*math.pi*.42
    tip=(x-width*math.cos(ang),side*(Y+width*math.sin(ang)),bottom+.18)
    top0=(hinge[0],hinge[1],min(cab_h*.94,belt+.45));top1=(tip[0],tip[1],min(cab_h*.94,belt+.45))
    d.poly([hinge,tip,top1,top0],p,INK,1,.12)
    d.poly([mix(hinge,top0,.55),mix(tip,top1,.55),mix(tip,top1,.92),mix(hinge,top0,.92)],GLASS,shade(p,1.2),1,.13)
def build():
 data=json.loads((ROOT/'assets/data/vehicle_models.json').read_text())
 (OUT/'sprites').mkdir(parents=True,exist_ok=True);(OUT/'icons').mkdir(exist_ok=True)
 (OUT/'.gdignore').write_text('')
 manifest={'version':2,'pixels_per_unit':PPU,'size':[W,H],'origin':list(ORIGIN),'directions':list(ANGLES),'models':{}}
 for id,m in data['models'].items():
  frames=[]
  for facing,angle in ANGLES.items():
   for phase in ([0] if m['doors']==0 else [0,1,2]):
    drawing=Drawing(angle);vehicle(drawing,m,phase*.5)
    path=OUT/'sprites'/f'{id}_{facing}_{phase}.png'
    image=drawing.export(path);frames.append(path.name)
    if facing==('e' if m['vehicle_class']=='two_wheelers' else 'se') and phase==0:
     bounds=image.getbbox();cropped=image.crop(bounds)
     # Unscaled crop keeps crisp native pixels and model-specific proportions.
     cropped.save(OUT/'icons'/f'{id}.png')
  manifest['models'][id]={'frames':frames}
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print('FLEET_ART',len(manifest['models']),'models',sum(len(v['frames']) for v in manifest['models'].values()),'directional/door sprites')
if __name__=='__main__':build()
