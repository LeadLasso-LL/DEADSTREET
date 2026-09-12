"""Native world-space artwork for the Revenant R2 and Nocturne RS."""
from vehicle_detail_geometry import motorcycle,shell
from fleet_2034_geometry import wheel_body,greenhouse,lamps,trim,openings
INK='#142128';CARBON='#202733';BRONZE='#b89a61';GLASS='#223b46'
def revenant(d,m):
 L=m['length'];p=m['paint']
 motorcycle(d,dict(m,body='sportbike',electric=False))
 # Two separate real saddles. Short fairings leave both wheels exposed.
 shell(d,[(-.82,.10,.79,.86),(-.60,.20,.78,.95),(-.37,.18,.80,.93)],CARBON)
 d.box(-.69,-.43,-.155,.155,.94,1.005,'#1a222c')
 d.box(-.33,-.06,-.14,.14,.84,.89,'#151d25')
 shell(d,[(-.10,.12,.68,.89),(.15,.26,.64,1.05),(.41,.22,.65,.99),(.59,.09,.67,.83)],p)
 for side in [-1,1]:
  y=side*.27
  d.poly([(.44,y,.80),(.19,y,.47),(-.09,y,.43),(-.22,y,.64),(.04,y,.90)],CARBON,INK,1,.06)
  d.poly([(.42,y,.88),(.18,y,.83),(.0,y,.52),(.14,y,.54)],'#27878a',INK,1,.07)
  d.line([(.39,y,.84),(.19,y,.77),(.05,y,.53)],'#c0a46d',1,.09)
  d.poly([(.47,side*.23,.93),(.50,side*.42,.81),(.33,side*.42,.76),(.21,side*.23,.83)],CARBON,INK,1,.08)
  # Passenger grab rail and peg: no mounted gun or decorative barrel/exhaust slab.
  d.line([(-.68,side*.205,.94),(-.46,side*.22,.96)],'#7d949b',1,.07)
  d.line([(-.43,side*.13,.47),(-.48,side*.34,.43)],'#89989b',2,.06)
  d.line([(.66,side*.07,.88),(.60,side*.23,.92)],'#e9d4a4',2,.11)
  d.line([(.34,side*.13,1.075),(.24,side*.35,1.09)],'#718287',2,.09)
 d.line([(-.84,-.11,.85),(-.84,.11,.85)],'#d26e73',2,.08)
def nocturne(d,m,door):
 L=m['length'];Y=m['width']/2;p=m['paint'];r=.365;belt=.86
 anchors=[(-L*.49,Y*.77,.31,.73),(-L*.40,Y*.94,.25,.89),(-L*.30,Y,.24,.94),(-L*.12,Y*.93,.23,.84),(L*.15,Y*.94,.23,.88),(L*.31,Y,.24,.94),(L*.43,Y*.91,.31,.79),(L*.49,Y*.72,.37,.65)]
 wheel_body(d,m,r,[-L*.33,L*.33],anchors)
 greenhouse(d,-L*.25,L*.23,Y*.80,belt,1.32,p,.68,.35,2,'#222733')
 lamps(d,L,Y,belt,p,'modern')
 for side in [-1,1]:
  y=side*(Y+.013)
  d.poly([(-L*.29,y,.37),(L*.29,y,.35),(L*.22,y,.44),(-L*.21,y,.46)],CARBON,INK,1,.06)
  d.line([(-L*.26,y,.45),(L*.25,y,.43)],BRONZE,1,.085)
  d.poly([(L*.28,y,.68),(L*.19,y,.66),(L*.17,y,.78),(L*.26,y,.79)],'#192b31',None,priority=.06)
  # Four frameless doors with slim handles, uninterrupted low roofline.
  for xx in [-L*.16,L*.07]:
   d.line([(xx-.05,side*Y*.91,.89),(xx+.10,side*Y*.91,.89)],'#93828a',1,.07)
  d.line([(L*.18,side*Y*.73,1.03),(L*.21,side*Y*1.04,1.01)],'#566972',2,.06)
  d.line([(L*.32,side*.30,.948),(L*.44,side*.41,.82)],'#8f5d7f',1,.065)
  # Small integrated rear spoiler follows the deck, never a roof tower.
  d.poly([(-L*.47,side*.08,.80),(-L*.39,side*.08,.82),(-L*.39,side*Y*.82,.89),(-L*.47,side*Y*.77,.87)],CARBON,INK,1,.075)
  d.line([(-L*.491,side*.23,.68),(-L*.491,side*Y*.73,.68)],'#e39084',1,.08)
 for yy in [-.47,-.30,.30,.47]:d.box(-L*.499,-L*.475,yy-.04,yy+.04,.30,.37,'#7c8788')
 d.poly([(L*.495,-Y*.57,.43),(L*.495,Y*.57,.43),(L*.484,Y*.51,.62),(L*.484,-Y*.51,.62)],'#17272f',INK,1,.06)
 for yy in [-.50,-.25,0,.25,.50]:d.line([(L*.497,yy,.46),(L*.49,yy,.59)],'#51616a',1,.07)
 openings(d,m,door,belt,1.32)
def render(d,m,door=0):
 if m['id']=='revenant':revenant(d,m)
 else:nocturne(d,m,door)
