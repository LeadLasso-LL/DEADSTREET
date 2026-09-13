"""Two recognizable near-future silhouettes on the shared fleet renderer."""
from vehicle_detail_geometry import shell
from fleet_2034_geometry import wheel_body,greenhouse,lamps,openings
INK='#142027';GLASS='#273c47';STEEL='#879497';ORANGE='#c87536'
def roadwarden(d,m,door):
 L=m['length'];Y=m['width']/2;p=m['paint'];belt=1.27
 wheel_body(d,m,.54,[-L*.34,-L*.14,L*.33],[(-L*.49,Y*.84,.47,1.25),(-L*.40,Y,.35,1.32),(L*.26,Y,.36,1.32),(L*.42,Y*.91,.46,1.18),(L*.49,Y*.71,.57,1.03)])
 greenhouse(d,L*.02,L*.29,Y*.85,belt,2.02,p,.65,.18,1,'#27363b')
 shell(d,[(-L*.48,Y*.84,.64,2.05),(-L*.42,Y*.93,.56,2.25),(-L*.045,Y*.93,.57,2.25),(L*.02,Y*.82,.66,2.05)],p)
 lamps(d,L,Y,belt,p,'modern')
 for side in [-1,1]:
  y=side*(Y*.95)
  for xx in [-L*.34,-L*.18]:
   d.poly([(xx-.34,y,1.80),(xx+.28,y,1.80),(xx+.24,y,2.06),(xx-.29,y,2.06)],GLASS,STEEL,1,.07)
  # Folded portable steel screens: visible individual panels, not exhaust pipes.
  for x in [-L*.36,-L*.245,-L*.13]:
   yy=side*(Y+.02)
   d.poly([(x-.19,yy,.89),(x+.19,yy,.89),(x+.19,yy,1.57),(x-.19,yy,1.57)],'#27353b',STEEL,1,.075)
   d.line([(x-.13,yy,1.04),(x+.13,yy,1.42)],'#718185',2,.09)
   d.line([(x-.12,yy,1.46),(x+.12,yy,1.46)],'#d0ae65',1,.10)
  for x in [-L*.4,-L*.07]:d.line([(x,y,.62),(x,y,1.73)],'#4c5e65',2,.095)
  d.line([(L*.27,side*.52,1.32),(L*.42,side*.60,1.24)],'#819292',1,.06)
  d.poly([(L*.49,side*.15,.49),(L*.50,side*Y*.77,.52),(L*.48,side*Y*.80,.76),(L*.47,side*.15,.75)],'#243037',INK,1,.08)
  d.line([(L*.49,side*.39,.68),(L*.49,side*.75,.69)],'#b8a16d',2,.10)
 d.box(-.15,.26,-.55,.55,2.27,2.33,'#253238')
 for side in [-1,1]:d.line([(.27,side*.17,2.33),(.27,side*.49,2.33)],'#d3ac63',1,.11)
 d.line([(-L*.49,0,.75),(-L*.49,0,2.03)],STEEL,1,.07)
 openings(d,m,door,belt,2.02)
def bloodhound(d,m,door):
 L=m['length'];Y=m['width']/2;p=m['paint'];belt=1.0
 wheel_body(d,m,.41,[-L*.33,L*.34],[(-L*.49,Y*.78,.35,.94),(-L*.40,Y*.98,.27,1.05),(-L*.27,Y,.27,1.10),(L*.19,Y*.94,.26,1.02),(L*.32,Y,.28,1.07),(L*.44,Y*.88,.35,.90),(L*.49,Y*.66,.40,.74)])
 greenhouse(d,-L*.37,L*.24,Y*.82,belt,1.65,p,.63,.57,3,'#202b31')
 lamps(d,L,Y,belt,p,'modern')
 for side in [-1,1]:
  y=side*(Y+.014)
  d.poly([(-L*.31,y,.37),(L*.29,y,.36),(L*.22,y,.48),(-L*.25,y,.50)],'#2c393d',INK,1,.055)
  d.line([(-L*.29,y,.50),(L*.24,y,.47)],ORANGE,2,.085)
  d.poly([(L*.23,y,.72),(L*.29,y,.71),(L*.31,y,.91),(L*.23,y,.91)],'#101d23',None,priority=.07)
  d.line([(L*.235,y,.73),(L*.27,y,.88)],ORANGE,1,.085)
  d.poly([(-L*.44,side*.11,1.48),(-L*.33,side*.13,1.54),(-L*.33,side*Y*.81,1.55),(-L*.44,side*Y*.77,1.49)],'#324247',INK,1,.08)
  d.line([(L*.28,side*.32,1.11),(L*.43,side*.46,.94)],'#6e8085',1,.075)
  d.line([(L*.18,side*Y*.75,1.23),(L*.19,side*Y*1.035,1.18)],'#72838b',2,.07)
 d.box(-L*.11,L*.03,-.41,.41,1.66,1.715,'#303d43')
 d.line([(L*.035,-.34,1.717),(L*.035,.34,1.717)],'#d59a5f',1,.09)
 openings(d,m,door,belt,1.65)
def render(d,m,door=0):
 if m['id']=='roadwarden':roadwarden(d,m,door)
 else:bloodhound(d,m,door)
