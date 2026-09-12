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
from fleet_2034_geometry import render as render_2034
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
 return render_2034(d,m,door)

def build():
 data=json.loads((ROOT/'assets/data/vehicle_models.json').read_text())
 (OUT/'sprites').mkdir(parents=True,exist_ok=True);(OUT/'icons').mkdir(exist_ok=True)
 (OUT/'.gdignore').write_text('')
 manifest={'version':3,'pixels_per_unit':PPU,'size':[W,H],'origin':list(ORIGIN),'directions':list(ANGLES),'models':{}}
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
