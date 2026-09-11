"""Raiders of the Sand: five regular human-scale outfit reviews."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='RAIDERS OF THE SAND'
PREFIX='sand_raiders'
BLUE=('#a1916c',)
DUST='#a09271'
BLOOD='#683f32'
SAND=('#b7ab88','#d1c5a4','#7e785d')
DESCRIPTIONS={
'pistol':'Cracked smile mask / bare scarred torso + sand and dried blood / cord belt',
'smg':'Patchy shaved head / dirty tank / prison suit tied at waist',
'shotgun':'Repaired cloth sack / blue work shirt / blood-smeared apron',
'rifle':'Worn welding mask / bare-chest suit + crooked tie / camo trousers',
'sniper':'Faded floral curtain / gauze face wrap / ragged charcoal sweater'}
NOTES={
'pistol':['Greasy jaw-length hair / one bandaged forearm','Sandy trousers / battered white tennis shoes'],
'smg':['Sand neck cloth / one fingerless glove','Orange prison trousers / black institutional shoes'],
'shotgun':['Uneven eyeholes / uneven rolled sleeves','Dark brown trousers / battered black boots'],
'rifle':['Mismatched woodland trousers / tan boots','Scavenged belt pouches / stained cuffs'],
'sniper':['Tangled gray hair / short shoulder strips','Burlap knee patches / cloth-wrapped leather boots']}
def costume(role,colors,head='combed',**kw):
 return base.costume(role,colors,head,raider=True,role=role,**kw)
SPECS={
'pistol':costume('pistol',('#a57773','#c09588','#70514d'),'slicklong'),
'smg':costume('smg',('#b9b49e','#d8d0b7','#898775')),
'shotgun':costume('shotgun',('#536a73','#788c8e','#334a53'),ankle_boots=True),
'rifle':costume('rifle',('#40332b','#65513d','#28231f'),'receding'),
'sniper':costume('sniper',('#3b4040','#626860','#242e2d'),'slicklong',ankle_boots=True)}
for role in ['pistol','smg','shotgun']:SPECS[role]['sleeve']='short'
for role,p,ph,s,sh in [
('pistol','#77664a','#9b8867','#c1bba4','#ded4b9'),
('smg','#a36135','#c18450','#252b29','#50554b'),
('shotgun','#42372d','#695942','#202724','#505547'),
('rifle','#505a3d','#778164','#9b8359','#bda779'),
('sniper','#62533e','#887658','#4b3b2e','#746148')]:
 SPECS[role].update(pants=p,pants_hi=ph,shoe=s,shoe_hi=sh)
EXTRA_PALETTE=base.EXTRA_PALETTE+list(SAND)+[DUST,BLOOD,'#a57773','#c09588','#70514d','#a36135','#c18450','#536a73','#788c8e','#62533e','#887658','#6c4732','#9a714e']
def blot(g,x,y,col=BLOOD,size=1.5):
 path(g,f'M{x-size} {y} l{size*.8} {-size*.6} {size*.7} {size*.3} {size*.8} {size*.9} {-size*.6} {size*.8} {-size} {-size*.2}Z',col,'none')
def grime(g,spots):
 for x,y in spots:
  blot(g,x,y,DUST,1)
  path(g,f'M{x-1} {y+2} l2 -.4','none',DUST,.35)
def head(g,c,skin,hi,d='SE'):
 if not c.get('raider'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 if role in ['pistol','rifle']:
  start=len(g);base.head(g,c,skin,hi,d)
  if role=='rifle':
   for el in list(g)[start:]:
    for attr in ['fill','stroke']:
     if el.get(attr) in ['#332b27','#5a4637']:el.set(attr,{'#332b27':'#6c4732','#5a4637':'#9a714e'}[el.get(attr)])
   path(g,'M-4 -47 Q-1 -50 4 -47 M-3 -48 Q1 -50 5 -46','none','#9a714e',.65)
   if back:
    path(g,'M-7 -44 Q0 -42 7 -44 M-5 -47 Q0 -50 5 -47','none','#252c2b',1.7)
    path(g,'M6 -44 L8 -43 8 -38','none','#5e6257',1.1)
   else:
    path(g,'M-7 -48 Q0 -51 7 -48 L8 -38 5 -31 -4 -31 -8 -38Z','#3e4540','#182321',.8)
    path(g,'M-6 -47 L5 -48 6 -37 3 -33 -3 -33','none','#687064',.7)
    lens='M1 -44 L7 -44 7 -40 1 -40Z' if side else 'M-5 -44 L5 -44 5 -40 -5 -40Z'
    path(g,lens,'#132321','#92917a',.7)
    path(g,'M-4 -43 L3 -43','none','#3e5750',.55)
    path(g,'M-6 -38 L-4 -36 M3 -35 L5 -37','none',DUST,.6)
    blot(g,4,-47,'#796044',.8)
  elif not back:
   # Thin worn plastic faceplate, no larger skull or sculpted monster anatomy.
   path(g,'M-6 -44 Q0 -48 6 -44 L6 -37 3 -33 -2 -33 -6 -37Z','#c7bea3','#68644f',.65)
   path(g,'M-4 -42 L-2 -42 M2 -42 L4 -42','none','#292e2a',.9)
   path(g,'M-4 -38 Q0 -33 4 -38','none','#574d3d',.8)
   path(g,'M4 -44 L2 -41 4 -39 2 -36','none','#786d54',.55)
   blot(g,-4,-35,DUST,.7)
 elif role=='smg':
  path(g,'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z',skin,w=1.15)
  for x,y in [(-5,-45),(-2,-48),(3,-47),(5,-43),(0,-49)]:
   blot(g,x,y,'#3c3b30',1.2)
  if back:path(g,'M-5 -39 L-3 -36 M3 -41 L4 -37','none','#555443',1.3)
  else:
   path(g,'M-3 -41 L-1 -41 M2 -41 L4 -41 M-2 -35 L2 -35','none','#443b2e',.65)
 elif role=='shotgun':
  path(g,'M-7 -48 Q-3 -52 4 -50 L8 -47 8 -37 6 -32 1 -30 -6 -32 -8 -38Z','#c3baa0','#696751',.8)
  path(g,'M-5 -47 L-6 -38 -3 -33 M5 -46 L6 -38 3 -32','none','#928b6f',.7)
  path(g,'M-6 -32 Q0 -30 6 -32','none','#6a634c',.8)
  if not back:
   eyes='M2 -42 l3 -.7 .2 2 -2.6 .6Z' if side else 'M-5 -42 l3 -.8 .3 2.3 -2.7 .5Z M2 -42 l2.8 .5 -.6 1.8 -2.3 -.4Z'
   path(g,eyes,'#252b26','none')
  path(g,'M4 -48 L6 -44 M3.5 -47 L5.5 -47 M4 -45.5 L6 -45.5','none','#655b45',.65)
  grime(g,[(-4,-46),(4,-35)])
 else:
  # Tangled hair beneath a shallow draped curtain, kept close to the body.
  path(g,'M-7 -44 Q0 -50 7 -44 L8 -31 5 -33 3 -29 0 -32 -3 -30 -7 -32Z','#666b62','#303a34',.6)
  for x in [-6,-3,3,6]:path(g,f'M{x} -42 q-1 4 0 6 q1 3 0 6','none','#a2a498',.7)
  path(g,'M-5 -44 Q0 -48 5 -43 L5 -34 -4 -34Z',skin,'#303a34',.7)
  if not back:path(g,'M-3 -42 L-1 -42 M2 -42 L4 -42','none','#33392f',.75)
  path(g,'M-5 -40 L5 -39 5 -33 -4 -32 -6 -35Z','#b4ae93','#696a54',.6)
  for y in [-38,-36,-34]:path(g,f'M-4 {y} L4 {y+.7}','none','#85866f',.6)
  path(g,'M-9 -39 L-8 -48 Q-5 -52 1 -51 L7 -49 9 -41 8 -32 5 -34 4 -43 0 -47 -4 -44 -5 -34 -8 -31Z',SAND[0],SAND[2],.8)
  if back:path(g,'M-7 -46 Q0 -48 7 -45 L8 -33 4 -32 -1 -34 -6 -32Z',SAND[0],SAND[2],.5)
  path(g,'M-6 -48 L-7 -39 M5 -48 L7 -39','none',SAND[1],.6)
  for x,y in [(-6,-42),(4,-48),(6,-35)]:
   path(g,f'M{x-1} {y} q1 -2 2 0 q-1 2 -2 0Z','none','#99977a',.45)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('raider'):return base.torso(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW']
 body=dict(c,cloth=skin,lit=hi,shade='#8a7056') if role=='pistol' else c
 rig.ORIGINAL_TORSO(g,body,skin,hi,d);t=list(g)[0]
 if role=='pistol':
  path(t,'M-7 -26 L-4 -22 -3 -19 M4 -15 L6 -12 M-6 -8 L-2 -6','none','#895747',.8)
  path(t,'M-7 -25 L-4 -21 M4 -14 L6 -11','none','#c3a085',.4)
  blot(t,-5,-15,BLOOD,2.2);blot(t,6,-24,BLOOD,1.8)
  grime(t,[(-7,-28),(5,-18),(-3,-7),(7,-4)])
  if back:path(t,'M0 -27 L0 -10 M-6 -25 Q-2 -23 -3 -18 M6 -25 Q2 -23 3 -18','none','#9d8062',.6)
  else:path(t,'M-7 -27 Q-4 -24 -1 -26 M1 -26 Q4 -24 7 -27 M0 -22 L0 -16','none','#9d8062',.6)
 if role=='smg':
  # Peeled-down jumpsuit is worn at the waist, not on the back of the tank.
  path(t,'M-11 -4 Q0 -1 11 -4 L11 5 5 4 0 6 -6 4 -11 5Z','#a36135','#71472c',.6)
  path(t,'M-10 -2 Q-3 2 2 -1 L7 2 4 5 -1 3 -7 4Z','#c18450','#71472c',.6)
  if not back:
   path(t,'M-1 0 L2 1 5 8 2 7 -1 3 -5 7 -7 6Z','#a36135','#71472c',.5)
  else:
   # Tiny faded number strokes on the folded rear jumpsuit panel.
   path(t,'M-6 0 l2 0 -2 3 2 0 M-1 0 l2 0 -2 3 2 0 M4 0 l2 0 0 3 -2 0Z','none','#665441',.55)
  path(t,'M-7 -32 Q0 -27 7 -32 L5 -27 0 -25 -5 -28Z',SAND[0],SAND[2],.55)
 if role=='sniper':
  path(t,'M-7 -34 Q0 -30 7 -34 L11 -29 10 -24 7 -26 5 -23 2 -26 -2 -24 -5 -26 -9 -24 -11 -29Z',SAND[0],SAND[2],.6)
  for x in [-8,-4,5,9]:
   path(t,f'M{x-1} -28 L{x+1} -28 {x+.4} -20 {x-1} -23Z',SAND[0],SAND[2],.4)
  for x,y in [(-7,-29),(4,-28)]:
   path(t,f'M{x-1} {y} q1 -2 2 0 q-1 2 -2 0Z','none','#99977a',.45)
 if role=='shotgun':
  if back:
   path(t,'M-8 -30 L0 -12 8 -30 M-10 -6 L10 -6','none','#9c9272',1.5)
  else:
   path(t,'M-5 -30 L5 -30 6 -15 10 0 10 15 4 16 -2 15 -10 16 -10 0 -6 -15Z','#aa9d7c','#71694f',.6)
   path(t,'M-5 -30 L-7 -33 M5 -30 L7 -33','none','#d0c09c',1.4)
   path(t,'M-7 -4 L-7 12 M7 -1 L7 13','none','#c3b38d',.6)
   for x,y in [(-3,-14),(3,1)]:
    blot(t,x,y,BLOOD,2.3)
    for off,dy in [(-2,-3),(-.7,-4),(1,-3.5),(2,-2.5)]:
     path(t,f'M{x+off} {y} l-.6 {dy}','none',BLOOD,.7)
 if not back:
  if role=='pistol':
   path(t,'M-10 -1 Q0 2 10 -1 M1 0 L4 5 1 3 -1 6 -2 2Z','none','#292c27',1)
  elif role=='smg':
   for x in [-6,-3,0,3,6]:path(t,f'M{x} -23 L{x} -7','none','#999783',.35)
   for x,y in [(-4,-9),(0,-6),(4,-8)]:blot(t,x,y,BLOOD,2)
  elif role=='rifle':
   path(t,'M-5 -33 L5 -33 5 -17 1 -10 -5 -17Z',skin,c['shade'],.5)
   path(t,'M-3 -25 Q0 -23 3 -25 M0 -25 L0 -19','none','#917b5d',.6)
   base.lapels(t,c)
   path(t,'M-3 -32 L-1 -33 1 -29 0 -26 4 -16 2 -12 0 -15 -2 -26 -3 -28Z','#aca184','#716b54',.55)
   path(t,'M-11 -1 L11 -1','none','#312b21',2)
   for x in [-7,6]:
    path(t,f'M{x-2} -6 L{x+2} -6 {x+2} 1 {x-2} 1Z','#82775a','#4c4a36',.6)
   blot(t,-5,-26)
 grime(t,[(-8,-20),(7,-8),(-5,-3)])
 for x,y in ([(-7,-15),(6,-25)] if role!='shotgun' else [(5,-8)]):blot(t,x,y,BLOOD,1)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('raider'):return base.arm(g,a,b,h,c,skin,hi)
 role=c['role']
 if role in ['pistol','smg']:
  return base.arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade=skin,sleeve='short'),skin,hi)
 base.arm(g,a,b,h,c,skin,hi)
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 p=a+(b-a)*.55
 path(g,f'M{xy(p-n*1.5)} L{xy(p+n)}','none',DUST,.7)
 if role=='sniper':
  p=b-v*1.4
  path(g,f'M{xy(p-n*1.5-v)} L{xy(p+n*1.4)} L{xy(p+v*1.4)}Z',skin,'#242e2d',.55)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('raider'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 one=c.get('watch_arm',False)
 if c['role']=='pistol' and one:
  p=a+(b-a)*.2;q=a+(b-a)*.8
  path(g,f'M{xy(p-n*2.5)} L{xy(p+n*2.5)} L{xy(q+n*2.3)} L{xy(q-n*2.3)}Z','#bfb69a','#77745c',.5)
  for f in [.3,.5,.7]:
   p=a+(b-a)*f;path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2+v*.4)}','none','#92896d',.6)
  p=a+(b-a)*.5;blot(g,p[0],p[1],BLOOD,1.3)
 elif c['role']=='smg' and one:
  p=b-v*3;q=b-v*.3
  path(g,f'M{xy(p-n*2.1)} L{xy(p+n*2.1)} L{xy(q+n*2)} L{xy(q-n*2)}Z','#242b29','#111a1c',.5)
 elif c['role']=='shotgun':
  end=a+(b-a)*(.2 if one else .38)
  base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none',c['lit'],1.2)
 elif c['role'] in ['rifle','sniper']:
  p=b-v*4
  path(g,f'M{xy(p-n*1.5)} L{xy(p+n)}','none',BLOOD,.9)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 if role=='rifle':base.shared.decorate_lower(root,dict(c,camo=True,boots=True))
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   p=a+(b-a)*.7
   path(detail,f'M{xy(p-n*1.4)} L{xy(p+n)}','none',DUST,.7)
   p=a+(b-a)*.35;blot(detail,p[0],p[1],BLOOD,.7)
   if role=='sniper' and radius<3.5:
    p=a+v*2;col='#998967' if a[0]<40 else '#7d7759'
    path(detail,f'M{xy(p-n*2.2)} L{xy(p+n*2.1)} L{xy(p+n*2+v*4)} L{xy(p-n*2+v*5)}Z',col,'#514c38',.5)
    for off in [-1,1]:path(detail,f'M{xy(p+n*off)} L{xy(p+n*off+v*4)}','none','#b3a47f',.4)
    for step in [1.5,3,4.5]:
     q=b-v*step;path(detail,f'M{xy(q-n*2)} L{xy(q+n*2+v*.6)}','none','#a49c7c',1.1)
   parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
