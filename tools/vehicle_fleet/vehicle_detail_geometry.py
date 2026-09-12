"""Native geometry for readable motorcycles, sculpted cars and authority trucks."""
import math
from PIL import ImageColor
INK='#172026';CHROME='#aeb8b8';GLASS='#243a46';GOLD='#bba166';GREEN='#284b3c'
def shade(c,m):return '#'+''.join(f'{max(0,min(255,round(v*m))):02x}' for v in ImageColor.getrgb(c))
def shell(d,sections,color):
 # Beveled cross sections make shoulders and fenders curved at sprite scale.
 rings=[]
 for x,w,z0,z1 in sections:
  dz=min(.13,(z1-z0)*.3)
  rings.append([(x,-w*.84,z0),(x,-w,z0+dz),(x,-w,z1-dz),(x,-w*.73,z1),(x,0,z1+.035),(x,w*.73,z1),(x,w,z1-dz),(x,w,z0+dz),(x,w*.84,z0)])
 d.poly(list(reversed(rings[0])),shade(color,.80),INK)
 d.poly(rings[-1],shade(color,.99),INK)
 for a,b in zip(rings,rings[1:]):
  for i,m in enumerate([.74,.82,.97,1.10,1.15,1.01,.86,.73,.68]):
   j=(i+1)%len(a);d.poly([a[i],b[i],b[j],a[j]],shade(color,m),None)
 for side in [1,6]:d.line([r[side] for r in rings],shade(color,.56),1,.006)
def canopy(d,x0,x1,w,z0,z1,color,windshield=.36,windows=2):
 # Sloped front/rear glass and a narrower, gently crowned roof.
 tx0=x0+.30;tx1=x1-windshield
 for side in [-1,1]:
  y=side*w;roof=side*w*.81
  quad=[(x0,y,z0),(x1,y,z0),(tx1,roof,z1-.035),(tx0,roof,z1-.035)]
  d.poly(quad,color,INK)
  center=tuple(sum(v[i] for v in quad)/4 for i in range(3))
  glass=[tuple(center[i]+(v[i]-center[i])*.83 for i in range(3)) for v in quad]
  d.poly(glass,GLASS,shade(color,1.32),1,.015)
  if windows==2:
   d.line([((x0+x1)*.5,y,z0+.025),((tx0+tx1)*.5,roof,z1-.04)],color,2,.028)
  d.line([glass[3],glass[2]],'#819ba5',1,.026)
 for x,tx in [(x0,tx0),(x1,tx1)]:
  q=[(x,-w,z0),(x,w,z0),(tx,w*.81,z1-.035),(tx,-w*.81,z1-.035)]
  d.poly(q,color,INK)
  center=tuple(sum(v[i] for v in q)/4 for i in range(3))
  q=[tuple(center[i]+(v[i]-center[i])*.85 for i in range(3)) for v in q]
  d.poly(q,GLASS,shade(color,1.25),1,.012);d.line([q[2],q[3]],'#93a7ae',1,.025)
 d.poly([(tx0,-w*.81,z1-.035),(tx1,-w*.81,z1-.035),(tx1,-w*.45,z1+.015),(tx0,-w*.45,z1+.015)],shade(color,1.07),None)
 d.poly([(tx0,-w*.45,z1+.015),(tx1,-w*.45,z1+.015),(tx1,w*.45,z1+.015),(tx0,w*.45,z1+.015)],shade(color,1.17),None)
 d.poly([(tx0,w*.45,z1+.015),(tx1,w*.45,z1+.015),(tx1,w*.81,z1-.035),(tx0,w*.81,z1-.035)],shade(color,1.03),None)
def badge(d,brand,x,y,z,size=.37):
 def point(u,v):return (x+u*size,y,z+v*size)
 if brand=='trc':
  q=[point(math.sin(i*math.pi/5)*(.5 if i%2==0 else .22),math.cos(i*math.pi/5)*(.5 if i%2==0 else .22)) for i in range(10)]
  d.poly(q,GREEN,GOLD,1,.18)
  d.poly([point(-.20,0),point(0,.10),point(.20,0),point(0,-.10)],'#d2cbb4',None,priority=.19)
  d.line([point(0,-.045),point(0,.045)],INK,1,.20)
 else:
  d.poly([point(-.39,.45),point(.39,.45),point(.34,-.15),point(0,-.50),point(-.34,-.15)],GREEN,GOLD,1,.18)
  d.line([point(-.19,.1),point(.19,.1)],'#e4dfce',1,.20)
  d.line([point(-.12,-.14),point(.12,-.14)],GOLD,1,.20)
def bike_wheel(d,x,r,width,chrome=False,knobby=False):
 # Open spoke centers, separate sidewalls and tread: wheels stay visible in dark paint.
 for k in range(24):
  a=k*math.tau/24;b=(k+1)*math.tau/24
  def pt(ang,yy,rad=r):return (x+rad*math.cos(ang),yy,r+rad*math.sin(ang))
  col=['#30373b','#394145','#2b3238'][k%3] if knobby else shade('#353c40',.85+.25*max(0,math.sin(a)))
  d.poly([pt(a,-width/2),pt(b,-width/2),pt(b,width/2),pt(a,width/2)],col,None)
  for yy in [-width/2,width/2]:
   d.poly([pt(a,yy),pt(b,yy),pt(b,yy,r*.70),pt(a,yy,r*.70)],'#292f34',None,priority=.009)
   d.line([pt(a,yy,r*.70),pt(b,yy,r*.70)],CHROME if chrome else '#727e88',1,.019)
   if math.sin(a)>.0:d.line([pt(a,yy,r*.98),pt(b,yy,r*.98)],'#586368',1,.014)
 for yy in [-width/2,width/2]:
  for k in range(10 if chrome else 5):
   a=k*math.tau/(10 if chrome else 5)
   d.line([(x,yy,r),(x+r*.68*math.cos(a),yy,r+r*.68*math.sin(a))],CHROME if chrome else '#8c999f',1,.023)
  d.poly([(x+.065*math.cos(k*math.tau/12),yy,r+.065*math.sin(k*math.tau/12)) for k in range(12)],'#69757c',INK,1,.027)
def motorcycle(d,m):
 b=m['body'];L=m['length'];p=m['paint'];brand=m.get('brand','')
 pedal=b=='bicycle';sport=b in ['streetbike','sportbike'];cruiser=b in ['cruiser','tourer'];scooter=b in ['scooter','moped']
 r=.34 if pedal or b=='dualsport' else (.31 if cruiser else (.25 if scooter else .33))
 rear=-L*.34;front=L*.35
 bike_wheel(d,rear,r,.07 if pedal else (.21 if sport else .17),cruiser,b=='dualsport')
 bike_wheel(d,front,r,.07 if pedal else .13,cruiser,b=='dualsport')
 if pedal:
  for pts in [[(rear,0,r),(-.25,0,.95),(.43,0,.98),(.0,0,.34),(rear,0,r)],[(-.25,0,.95),(0,0,.34)],[(.43,0,.98),(front,0,r)]]:d.line(pts,p,2)
  d.line([(-.25,0,.91),(-.31,0,1.08)],CHROME,1);d.box(-.48,-.17,-.10,.10,1.055,1.105,'#343b3e')
  d.line([(front,0,r),(.43,0,1.13),(.39,-.29,1.15)],CHROME,2);d.line([(.43,0,1.13),(.39,.29,1.15)],CHROME,2)
  d.line([(-.04,-.12,.35),(.08,.14,.27),(.21,.14,.27)],CHROME,1)
  return
 # Frame and compact engine sit between wheels, leaving both tires exposed.
 d.line([(rear,0,r),(-.25,0,.49),(.31,0,.51),(.39,0,.91),(rear,0,r)],'#687477',2)
 d.line([(rear,.07,r),(-.14,.10,.43)],'#697474',2)
 engine='#687477' if cruiser else '#343e43'
 if cruiser:
  for slope in [-1,1]:
   d.poly([(-.08,-.15,.41),(.11,-.15,.44),(.12+slope*.13,-.15,.68),(-.06+slope*.13,-.15,.69)],engine,INK)
   d.poly([(-.08,.15,.41),(.11,.15,.44),(.12+slope*.13,.15,.68),(-.06+slope*.13,.15,.69)],engine,INK)
   for j in range(4):
    z=.47+j*.05
    for side in [-1,1]:d.line([(-.08+slope*(z-.43)*.5,side*.16,z),(.12+slope*(z-.43)*.5,side*.16,z)],'#26343b',1,.02)
 else:d.box(-.18,.18,-.13,.13,.39,.62,engine)
 # Exhaust is a short low silencer behind the engine, not a full-length silver slab.
 if not scooter and not m.get('electric'):
  d.line([(.10,.17,.44),(-.10,.23,.37),(-.48,.23,.40)],'#626c70' if cruiser else '#29343b',2)
  d.line([(-.48,.23,.40),(-.53,.23,.405)],'#929ca0',1)
 seat_z=.72 if cruiser else (.80 if not sport else .86)
 shell(d,[(rear*.85,.08,seat_z-.025,seat_z+.03),(-.35,.18,seat_z-.04,seat_z+.035),(-.11,.145,seat_z-.02,seat_z+.015)],'#22292d')
 if m['unit_capacity']==2:shell(d,[(rear*.94,.08,seat_z+.08,seat_z+.11),(rear*.57,.12,seat_z+.04,seat_z+.10)],'#30393e')
 if scooter:
  shell(d,[(rear-.06,.13,.52,.72),(-.24,.24,.46,.74),(.0,.17,.40,.61)],p)
  shell(d,[(.13,.11,.30,.65),(.34,.26,.37,.97),(.43,.22,.70,1.01)],p)
 else:
  shell(d,[(-.18,.10,seat_z-.04,seat_z+.08),(-.04,.20,seat_z-.09,seat_z+.18),(.19,.22,seat_z-.07,seat_z+.19),(.38,.10,seat_z+.01,seat_z+.10)],p)
  d.poly([(.08,-.045,seat_z+.20),(.17,-.045,seat_z+.20),(.17,.045,seat_z+.20),(.08,.045,seat_z+.20)],'#8c9595',INK)
 # Forks rake rearward up to the steering head. Low bars establish sport riding posture.
 top_x=front-(.22 if m.get('cafe_style') else (.37 if cruiser else .18));fork_top=.99 if m.get('cafe_style') else (1.02 if cruiser else (.96 if sport else 1.10))
 for side in [-1,1]:d.line([(front,side*.07,r),(top_x,side*.07,fork_top)],CHROME,2)
 bar_z=.96 if sport or m.get('cafe_style') else (1.14 if cruiser else 1.17)
 bar_x=top_x-.12 if sport else top_x-.10
 d.line([(top_x,0,fork_top),(bar_x,0,bar_z)],'#59646a',2)
 for side in [-1,1]:
  d.line([(bar_x,0,bar_z),(bar_x-.06,side*.34,bar_z+.025)],CHROME,2)
  d.line([(bar_x-.06,side*.28,bar_z+.025),(bar_x-.07,side*.39,bar_z+.025)],'#1d282c',2)
 # Compact arced mudguards never cover the tire centers.
 for x in [rear,front]:
  for side in [-1,1]:
   d.line([(x+math.cos(a)*(r+.055),side*.09,r+math.sin(a)*(r+.055)) for a in [math.pi*.18+i*math.pi*.064 for i in range(11)]],p,2)
 if sport:
  # Tapered body and raised tail; nose/fairing stays above the exposed front tire.
  for side in [-1,1]:
   y=side*.245
   d.poly([(-.14,y,.46),(.28,y,.42),(.48,y,.64),(.49,y,.91),(.34,y,1.02),(.12,y,.82)],p,INK)
   d.poly([(.0,y+side*.004,.58),(.30,y+side*.004,.57),(.37,y+side*.004,.72),(.14,y+side*.004,.69)],'#24323a',INK,1,.03)
   d.line([(-.07,y+side*.006,.77),(.25,y+side*.006,.82),(.39,y+side*.006,.93)],'#ece6d4' if m['id']=='nightjar' else '#9cd4e3',2,.04)
  shell(d,[(.37,.23,.86,1.03),(.53,.24,.88,1.12),(.68,.12,.90,1.04)],p)
  d.poly([(.39,-.18,1.04),(.39,.18,1.04),(.53,.12,1.17),(.53,-.12,1.17)],GLASS,'#6d9eaf')
  for side in [-1,1]:d.line([(.665,side*.03,1.015),(.59,side*.18,1.055)],'#dbecf2',2,.04)
  if m['unit_capacity']==1:shell(d,[(rear*.95,.07,.87,.94),(-.36,.15,.82,.90)],p)
 else:
  d.poly([(top_x+.045,.13,.89),(top_x+.045,-.13,.89),(top_x+.045,-.13,1.06),(top_x+.045,.13,1.06)],'#dedfc7',CHROME)
 if b=='dualsport':d.box(front-.28,front+.12,-.09,.09,.91,.95,GREEN if brand else p)
 if b=='tourer':
  for side in [-1,1]:
   y=side*.34
   d.box(rear-.08,rear+.47,y-.105,y+.105,.60,.85,GREEN if brand=='nbpd' else p)
   d.line([(rear-.05,y+side*.115,.78),(rear+.43,y+side*.115,.78)],CHROME,1,.03)
  shell(d,[(.28,.21,.91,1.08),(.47,.35,.94,1.18),(.56,.29,.95,1.12)],GREEN if brand else p)
  d.poly([(.38,-.31,1.12),(.38,.31,1.12),(.29,.25,1.49),(.29,-.25,1.49)],'#678995','#a4b8bb')
 for side in [-1,1]:
  if not sport:d.line([(bar_x,side*.30,bar_z), (bar_x-.04,side*.39,bar_z+.17)],CHROME,1)
 if brand:
  for side in [-1,1]:
   y=side*(.458 if b=='tourer' else .253)
   if b=='tourer':d.marking('POLICE',rear+.19,y,.66,.47,.13,'#e5dfcb')
   else:
    d.poly([(-.04,y,.73),(.32,y,.73),(.32,y,.96),(-.04,y,.96)],GREEN,INK)
    d.marking('TRC',.13,y+side*.01,.77,.28,.13,GOLD)
   badge(d,brand,.43,side*.355,1.055,.18) if b=='tourer' else None
  for side in [-1,1]:d.box(.47,.54,side*.30-.04,side*.30+.04,1.07,1.14,'#688bb3' if brand=='nbpd' else '#354a43')
 d.box(rear-.06,rear+.03,-.09,.09,seat_z+.04,seat_z+.085,'#bd463f')
def exotic(d,m,door=0):
 L=m['length'];Y=m['width']/2;p=m['paint'];mid=m['body']!='grandtourer';wedge=m['body']=='sportcoupe'
 rear=-L*.31;front=L*.32
 for x in [rear,front]:
  for side in [-1,1]:d.wheel(x,side*(Y-.01),.335,.20,False,5)
 sections=[(-L*.49,Y*.73,.31,.70),(-L*.42,Y*.94,.25,.82),(-L*.31,Y,.23,.91),(-L*.13,Y*.88,.23,.78),(L*.12,Y*.87,.23,.72),(L*.31,Y*.98,.23,.82),(L*.43,Y*.91,.27,.66),(L*.49,Y*.69,.33,.57)]
 if wedge:sections=[(-L*.49,Y*.79,.30,.73),(-L*.34,Y,.24,.87),(-L*.07,Y*.91,.21,.71),(L*.23,Y*.90,.22,.69),(L*.36,Y*.96,.25,.73),(L*.49,Y*.70,.30,.52)]
 shell(d,sections,p)
 cab0=-L*.13 if mid else -L*.29;cab1=L*.28 if mid else L*.12
 if not m.get('open_top'):canopy(d,cab0,cab1,Y*.75,.78,m['height'],'#222f37',.55,1)
 for side in [-1,1]:
  y=side*Y
  d.line([(-L*.27,y,.34),(L*.29,y,.32)],'#202b33',2,.07)
  for x in [rear,front]:d.line([(x+math.cos(a)*.37,y,.335+math.sin(a)*.37) for a in [i*math.pi/16 for i in range(17)]],shade(p,.59),1,.07)
  if mid:
   d.poly([(-L*.24,y,.42),(-L*.09,y,.44),(-L*.05,y,.76),(-L*.24,y,.79)],'#1b2e34',INK,1,.08)
   d.line([(-L*.24,y,.79),(-L*.05,y,.76)],shade(p,1.30),1,.09)
  # Separate flowing lamp blades set into the sloped hood.
  d.poly([(L*.465,side*Y*.43,.62),(L*.437,side*Y*.79,.68),(L*.30,side*Y*.76,.835),(L*.34,side*Y*.53,.805)],'#233239',INK,1,.09)
  d.line([(L*.443,side*Y*.47,.66),(L*.38,side*Y*.73,.75),(L*.31,side*Y*.73,.84)],'#d0e6ee',1,.11)
  d.poly([(-L*.495,side*Y*.3,.62),(-L*.495,side*Y*.75,.62),(-L*.495,side*Y*.75,.72),(-L*.495,side*Y*.3,.72)],'#bd3a35',INK,1,.10)
  d.line([(cab1-.13,side*Y*.69,.93),(cab1-.1,side*Y*.90,.96)],'#202a31',2,.06)
  d.box(cab1-.17,cab1-.01,side*Y*.91-.06,side*Y*.91+.06,.92,1.00,p)
  d.line([(-L*.04,side*Y*.89,.68),(L*.045,side*Y*.88,.68)],CHROME,1,.08)
 d.poly([(L*.495,-Y*.58,.32),(L*.495,Y*.58,.32),(L*.495,Y*.51,.50),(L*.495,-Y*.51,.50)],'#13262d',INK,1,.12)
 d.line([(L*.498,-Y*.65,.305),(L*.498,Y*.65,.305)],'#475662',2,.13)
 if mid:
  for x in [-L*.44,-L*.39,-L*.34,-L*.29]:d.line([(x,-Y*.48,.845),(x,Y*.48,.845)],'#273941',2,.12)
 if wedge:
  for side in [-1,1]:d.box(-L*.40,-L*.34,side*.62-.04,side*.62+.04,.79,.99,'#26363c')
  d.box(-L*.44,-L*.30,-Y*.88,Y*.88,.98,1.02,'#23323a')
 else:
  for side in [-1,1]:d.line([(L*.05,side*Y*.34,.81),(L*.28,side*Y*.36,.86)],shade(p,1.25),1,.08)
 if door:
  for side in [-1,1]:
   hinge=(L*.16,side*Y*.85,.31);tip=(L*.16-.85*math.cos(door*1.3),side*(Y*.85+.85*math.sin(door*1.3)),.31)
   d.poly([hinge,tip,(tip[0],tip[1],.90),(hinge[0],hinge[1],.96)],p,INK,1,.15)
def armored(d,m,door=0):
 L=m['length'];Y=m['width']/2;p=m['paint'];brand=m.get('brand','trc');heavy=m['vehicle_class']=='heavy_transports';h=m['height']
 rear=-L*.31;front=L*.32;r=.48 if heavy else .43;belt=1.12 if heavy else .98
 for x in [rear,front]:
  for side in [-1,1]:
   d.wheel(x,side*(Y-.04),r,.30,False,8)
   d.box(x-.52,x+.52,side*Y-.06,side*Y+.06,r*1.43,r*1.52,'#313c42')
 shell(d,[(-L*.49,Y*.81,.48,belt),(-L*.39,Y*.96,.39,belt+.10),(L*.21,Y*.98,.42,belt+.12),(L*.43,Y*.88,.47,belt-.04),(L*.49,Y*.67,.58,belt-.17)],p)
 cab0=-L*.42;cab1=L*.25
 canopy(d,cab0,cab1,Y*.94,belt,h,p,.28,2)
 # Closed protected personnel compartment, small individual armored windows.
 for side in [-1,1]:
  y=side*Y*.96;ry=side*Y*.81
  d.poly([(cab0,y,belt),(L*.02,y,belt),(L*.02,ry,h-.04),(cab0+.28,ry,h-.04)],shade(p,.9),INK,1,.06)
  for x in [-L*.29,-L*.13]:
   z=h-.57;wy=y+(ry-y)*(z-belt)/(h-belt)
   d.poly([(x-.24,wy,z),(x+.24,wy,z),(x+.24,wy+side*-.035,z+.26),(x-.24,wy+side*-.035,z+.26)],GLASS,'#87988d',1,.08)
  d.line([(-L*.35,y,belt+.07),(L*.15,y,belt+.07)],GREEN if brand=='trc' else '#bdb58c',2,.09)
  d.marking('TRC' if brand=='trc' else 'SWAT',-L*.20,y+side*.012,belt+.18,1.15 if heavy else .88,.28,GOLD if brand=='trc' else '#e4dfcc')
  badge(d,brand,L*.08,y+side*.02,belt+.38,.42)
  d.line([(-L*.40,y,.67),(L*.22,y,.67)],'#535f64',2,.08)
  for x in [-L*.38,-L*.1,L*.12]:
   for z in [belt+.12,h-.13]:
    yy=y+(ry-y)*(z-belt)/(h-belt)
    d.line([(x,yy,z),(x+.035,yy,z)],'#8a9694',1,.10)
  if brand=='nbpd':d.marking('POLICE',-L*.20,y+side*.015,belt-.14,1.06,.20,'#c7cdb9')
  d.box(-L*.15,L*.19,side*(Y+.10)-.05,side*(Y+.10)+.05,.36,.43,'#3d474e')
 xf=L*.493
 d.poly([(xf,-Y*.53,.61),(xf,Y*.53,.61),(xf,Y*.53,belt-.10),(xf,-Y*.53,belt-.10)],'#101b22',INK)
 for z in [.68,.76,.84]:d.line([(xf+.02,-Y*.52,z),(xf+.02,Y*.52,z)],'#68777b',1,.05)
 for side in [-1,1]:
  d.box(L*.46,L*.5,side*Y*.66-.16,side*Y*.66+.16,belt-.2,belt-.07,'#d3dfd7')
  d.line([(L*.51,side*.50,.46),(L*.51,side*.50,1.15)],'#4d5d63',3,.11)
 d.line([(L*.51,-Y*.83,.5),(L*.51,Y*.83,.5)],'#505d64',3,.12)
 d.box(L*.47,L*.55,-.24,.24,.48,.62,'#28343b')
 d.line([(-L*.12,Y*.3,h),(-L*.16,Y*.3,h+.24)],'#343e41',1)
 d.box(.0,.18,-Y*.61,Y*.61,h+.025,h+.105,'#37454c')
 if brand=='nbpd':
  d.box(.0,.18,-Y*.61,-.07,h+.09,h+.17,'#658cae');d.box(.0,.18,.07,Y*.61,h+.09,h+.17,'#ae4849')
 else:
  for side in [-1,1]:d.line([(.12,side*.13,h+.12),(.12,side*.60,h+.12)],'#a7b8ab',1,.04)
 if door:
  for row in m['door_rows']:
   for side in [-1,1]:
    x=L*row;tipx=x-.78*math.cos(door*1.3);tipy=side*(Y+.78*math.sin(door*1.3))
    d.poly([(x,side*Y,.57),(tipx,tipy,.57),(tipx,tipy,h-.18),(x,side*Y,h-.18)],p,INK,1,.14)
    d.poly([(x,side*Y,h-.65),(tipx,tipy,h-.65),(tipx,tipy,h-.28),(x,side*Y,h-.28)],GLASS,'#7e8d91',1,.15)
