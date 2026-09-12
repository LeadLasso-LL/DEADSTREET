"""Eleven model-specific silhouettes, built in the fleet's shared world coordinates."""
import math
from vehicle_detail_geometry import shell, motorcycle, bike_wheel, shade
from fleet_2034_geometry import greenhouse, wheel_body, lamps, trim, openings, passenger

INK='#152128';GLASS='#253d4a';SILVER='#a7b5bd';GOLD='#bb9b62'

def shield(d,x,y,z,color,size=.25):
 d.poly([(x-size*.4,y,z+size*.45),(x+size*.4,y,z+size*.45),(x+size*.34,y,z-size*.12),(x,y,z-size*.5),(x-size*.34,y,z-size*.12)],color,SILVER,1,.05)
 d.line([(x-size*.18,y,z+.035),(x+size*.18,y,z+.035)],'#c7d2d1',1,.06)

def two_wheeler(d,m):
 L=m['length'];p=m['paint'];wraith=m['id']=='wraith_zero'
 motorcycle(d,dict(m,body='sportbike' if wraith else 'cruiser',electric=wraith))
 if wraith:
  for side in [-1,1]:
   y=side*.268
   d.poly([(-.20,y,.46),(.06,y,.42),(.45,y,.75),(.30,y,.90),(.03,y,.77)],'#252b37',INK,1,.05)
   d.line([(-.13,y,.54),(.08,y,.55),(.32,y,.82)],'#9e7fc4',2,.07)
   d.poly([(.22,y,.88),(.46,side*.39,.83),(.44,side*.39,.79),(.16,y,.83)],'#55516d',INK,1,.08)
  shell(d,[(-.77,.06,.90,.98),(-.55,.10,.89,1.01),(-.36,.07,.84,.94)],'#39364b')
  d.box(-.61,-.44,-.07,.07,1.01,1.065,'#181e27')
  d.line([(-.47,-.054,1.067),(-.47,.054,1.067)],'#8976bd',1,.08)
 else:
  # A broader tire rather than a full-length exhaust slab.
  bike_wheel(d,-L*.34,.31,.30,True,False)
  shell(d,[(-.19,.12,.72,.89),(.0,.25,.69,.99),(.23,.21,.73,.98),(.37,.09,.78,.87)],p)
  for side in [-1,1]:
   y=side*.255
   d.line([(-.12,y,.85),(.09,y,.90),(.24,side*.20,.88)],'#c49e68',1,.055)
   d.poly([(-.70,side*.19,.71),(-.45,side*.25,.69),(-.25,side*.22,.72),(-.49,side*.19,.82)],p,INK,1,.025)
  d.line([(.37,-.08,1.02),(.17,-.41,1.12)],'#657079',2,.02)
  d.line([(.37,.08,1.02),(.17,.41,1.12)],'#657079',2,.02)

def asterion(d,m,door):
 L=m['length'];Y=m['width']/2;p=m['paint'];r=.355
 anchors=[(-L*.49,Y*.76,.29,.73),(-L*.40,Y*.94,.22,.84),(-L*.30,Y,.22,.91),(-L*.16,Y*.91,.22,.80),(L*.07,Y*.83,.20,.75),(L*.28,Y,.23,.88),(L*.41,Y*.91,.25,.71),(L*.49,Y*.63,.32,.53)]
 wheel_body(d,m,r,[-L*.32,L*.32],anchors)
 greenhouse(d,-L*.16,L*.275,Y*.72,.79,1.14,'#222e35',.62,.35,1,'#233038')
 for side in [-1,1]:
  y=side*(Y+.012)
  d.poly([(-L*.28,y,.40),(-L*.10,y*.93,.43),(-L*.02,y*.85,.74),(-L*.24,y,.79)],'#13232c',None,priority=.06)
  d.line([(-L*.24,y,.79),(-L*.08,y*.93,.70)],'#edc89c',1,.07)
  d.poly([(L*.455,side*Y*.50,.61),(L*.37,side*Y*.85,.74),(L*.26,side*Y*.80,.90),(L*.32,side*Y*.55,.82)],'#142832',None,priority=.05)
  d.line([(L*.45,side*Y*.52,.625),(L*.34,side*Y*.77,.81),(L*.275,side*Y*.78,.895)],'#dbf1f1',1,.08)
  d.line([(-L*.28,y,.28),(L*.27,y,.25)],'#2b3c43',2,.08)
  d.box(-L*.40,-L*.35,side*.66-.025,side*.66+.025,.87,1.03,'#24343a')
  d.poly([(-L*.47,side*.14,1.045),(-L*.35,side*.18,1.055),(-L*.32,side*Y*.94,1.04),(-L*.48,side*Y*.88,1.03)],'#304049',INK,1,.03)
  d.line([(-L*.492,side*.30,.67),(-L*.492,side*Y*.74,.67)],'#d56863',1,.03)
  d.line([(L*.12,side*.70,.91),(L*.13,side*.95,.94)],INK,2,.03)
 d.poly([(L*.495,-Y*.52,.34),(L*.495,Y*.52,.34),(L*.47,Y*.41,.47),(L*.47,-Y*.41,.47)],'#162930',None)
 for yy in [-.42,-.21,0,.21,.42]:d.line([(-L*.49,yy,.29),(-L*.42,yy,.47)],'#5e6a70',1,.05)
 for xx in [-L*.43,-L*.38,-L*.33]:d.line([(xx,-.46,.91),(xx,.46,.91)],'#283b43',2,.04)
 openings(d,m,door,.78,1.14)

def eidolon(d,m,door):
 passenger(d,dict(m,body='ev_fastback',roof_color='#1f2d39'),door)
 L=m['length'];Y=m['width']/2
 for side in [-1,1]:
  y=side*(Y+.026)
  d.poly([(-L*.32,y,.36),(L*.30,y,.36),(L*.21,y,.44),(-L*.25,y,.46)],'#71899a',None,priority=.04)
  d.line([(L*.27,side*.43,.948),(L*.41,side*.52,.908)],'#8eacc3',1,.04)
  d.poly([(-L*.25,y,.61),(-L*.18,y,.61),(-L*.17,y,.67),(-L*.23,y,.67)],'#1c2b37',None,priority=.04)
 d.poly([(-L*.12,-.034,1.35),(-L*.05,-.034,1.36),(-L*.08,0,1.435),(-L*.14,0,1.40)],'#516978',None)

def utility(d,m,door):
 L=m['length'];Y=m['width']/2;h=m['height'];p=m['paint'];nomad=m['id']=='nomad'
 r=.47 if nomad else .435;belt=h*.65
 axles=[-L*.35,-L*.12,L*.34] if nomad else [-L*.32,L*.34]
 wheel_body(d,m,r,axles,[(-L*.49,Y*.85,.40,belt-.08),(-L*.41,Y*.98,.32,belt+.02),(-L*.29,Y,.30,belt+.035),(L*.24,Y,.31,belt),(L*.41,Y*.94,.39,belt-.08),(L*.49,Y*.78,.49,belt-.14)])
 greenhouse(d,-L*.42,L*.22,Y*.90,belt,h,p,.55,.29,3,'#253931' if nomad else '#5b343b',opaque_until=None if nomad else -L*.08)
 lamps(d,L,Y,belt,p,'luxury' if nomad else 'modern')
 trim(d,m,belt,L*.22,h)
 for side in [-1,1]:
  y=side*(Y+.025)
  d.line([(-L*.40,y,.50),(L*.27,y,.50)],GOLD if nomad else '#7b3945',2,.05)
  d.line([(-L*.38,y,.43),(L*.24,y,.43)],'#677773',1,.045)
  if nomad:
   d.line([(-L*.35,side*Y*.68,h+.055),(L*.08,side*Y*.68,h+.055)],'#7e8975',2,.05)
   for xx in [-L*.27,-L*.06]:d.line([(xx,-Y*.67,h+.06),(xx,Y*.67,h+.06)],'#5a6d5f',2,.05)
   d.poly([(L*.49,side*.62,.78),(L*.49,side*.81,.78),(L*.49,side*.81,.97),(L*.49,side*.62,.97)],'#d2dcc9',INK,1,.05)
  else:
   # Abstract six-point medical star; no Red Cross emblem.
   x=-L*.21;z=belt+.21;yy=side*Y*.86
   d.poly([(x+math.cos(k*math.pi/6)*(.21 if k%2==0 else .085),yy,z+math.sin(k*math.pi/6)*(.21 if k%2==0 else .085)) for k in range(12)],'#9a4c58',None,priority=.11)
   d.line([(x,yy-.01*side,z-.12),(x,yy-.01*side,z+.12)],'#d9dfd9',1,.13)
   d.line([(-L*.35,y,.83),(-L*.04,y,.83)],'#7b3945',2,.04)
 if nomad:
  shell(d,[(-L*.26,.51,h+.05,h+.16),(-L*.08,.51,h+.05,h+.16)],'#394a40')
 else:
  d.box(-.20,.19,-.54,.54,h+.02,h+.095,'#74434b')
  for side in [-1,1]:d.line([(.20,side*.12,h+.105),(.20,side*.48,h+.105)],'#e6cda9',1,.04)
 openings(d,m,door,belt,h)

def heavy(d,m,door):
 L=m['length'];Y=m['width']/2;h=m['height'];p=m['paint'];id=m['id'];breach=id=='leviathan';vault=id=='palisade';prison=id=='custodian'
 r=.51 if breach or vault else .46;belt=1.42 if breach or vault else 1.30
 axles=[-L*.34,-L*.16,L*.34] if breach else [-L*.32,L*.34]
 wheel_body(d,m,r,axles,[(-L*.49,Y*.85,.46,belt-.1),(-L*.42,Y*.98,.36,belt),(-L*.3,Y,.36,belt),(L*.24,Y,.39,belt),(L*.42,Y*.91,.49,belt-.06),(L*.49,Y*.73,.59,belt-.20)])
 # Lower separate driving cab; sealed or compartmented rear capsule.
 cab_h=h*.87;greenhouse(d,L*.03,L*.30,Y*.90,belt,cab_h,p,.51,.20,1,p)
 rearpaint='#c0c5c0' if id=='sterling_reserve' else ('#76848f' if vault else p)
 shell(d,[(-L*.485,Y*.86,.64,h-.18),(-L*.44,Y*.96,.58,h),(-L*.04,Y*.96,.61,h),(L*.03,Y*.88,.65,h-.16)],rearpaint)
 for side in [-1,1]:
  y=side*(Y*.968)
  d.line([(-L*.43,y,.75),(-L*.035,y,.75)],'#37454c',2,.055)
  if breach:
   for xx in [-L*.34,-L*.19,-L*.055]:
    d.poly([(xx-.20,y,1.97),(xx+.20,y,1.97),(xx+.20,y,2.19),(xx-.20,y,2.19)],GLASS,'#91a6ab',1,.06)
    d.line([(xx-.26,y,.98),(xx-.26,y,2.38)],'#536771',1,.055)
  elif prison:
   for xx in [-L*.34,-L*.17]:
    d.poly([(xx-.32,y,1.88),(xx+.32,y,1.88),(xx+.32,y,2.20),(xx-.32,y,2.20)],GLASS,SILVER,1,.05)
    for a in [-.20,0,.20]:d.line([(xx+a,y,1.89),(xx+a,y,2.20)],'#9dabb0',1,.065)
   d.marking('CUSTODY',-L*.235,y+side*.015,1.48,1.50,.22,'#d3d9cc')
   d.line([(-L*.43,y,1.10),(-L*.04,y,1.10)],'#b7c1b9',2,.045)
  elif vault:
   d.poly([(-L*.42,y,1.08),(-L*.10,y,1.08),(-L*.06,y,2.41),(-L*.36,y,2.53)],'#515f6c',None,priority=.05)
   for xx in [-L*.37,-L*.28,-L*.19,-L*.10]:d.line([(xx,y,1.12),(xx+.035,y,2.37)],'#99a5aa',1,.065)
   d.line([(-L*.40,y,.94),(-L*.06,y,.94)],GOLD,2,.07)
   shield(d,-L*.23,y+side*.02,1.78,GOLD,.43)
  else:
   d.poly([(-L*.43,y,1.18),(-L*.04,y,1.18),(-L*.04,y,1.74),(-L*.43,y,1.74)],'#31574d' if id=='sterling_cit' else '#3f515b',None,priority=.06)
   d.marking('STERLING',-L*.24,y+side*.018,1.34,1.72,.24,'#d9ded5')
   shield(d,-L*.24,y+side*.02,2.09,'#4a675d',.42)
 lamps(d,L,Y,belt,p,'modern')
 # Heavy rear door locks read on rear facings without oversizing the body.
 xb=-L*.49
 for yy in [-Y*.48,Y*.48]:
  d.line([(xb,yy,.91),(xb,yy,h-.26)],'#b5bfbd' if vault else '#839294',2,.05)
  for zz in [1.14,h-.49]:d.line([(xb,yy-.14,zz),(xb,yy+.14,zz)],'#5b707c',2,.06)
 d.line([(xb,0,.84),(xb,0,h-.21)],'#394b56',1,.05)
 if breach:
  # Broad sloped ram plate: no weapons, spikes or implausible hood towers.
  xf=L*.51
  d.poly([(xf-.05,-Y*.91,1.09),(xf-.05,Y*.91,1.09),(xf+.25,Y*.77,.40),(xf+.25,-Y*.77,.40)],'#38464f',INK,1,.055)
  for yy in [-.75,-.25,.25,.75]:d.line([(xf-.02,yy,1.02),(xf+.23,yy,.43)],'#687985',2,.07)
  for side in [-1,1]:
   d.line([(L*.27,side*.56,belt+.07),(L*.44,side*.56,belt+.045),(xf,side*.73,1.04)],'#617483',2,.06)
  d.box(-L*.26,-L*.12,-.42,.42,h+.02,h+.14,'#2c3d46')
 else:
  for side in [-1,1]:d.line([(L*.49,side*.63,.48),(L*.49,side*.63,1.10)],'#596e79',2,.055)
 openings(d,m,door,belt,cab_h)

def render(d,m,door=0):
 if m['vehicle_class']=='two_wheelers':two_wheeler(d,m)
 elif m['id']=='asterion':asterion(d,m,door)
 elif m['id']=='eidolon':eidolon(d,m,door)
 elif m['vehicle_class']=='utility_vehicles':utility(d,m,door)
 else:heavy(d,m,door)
