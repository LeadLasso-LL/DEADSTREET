"""Ashford-Crane regular outfits, shared rig and five molded mask expressions."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='THE ASHFORD-CRANE COLLECTIVE'
PREFIX='ashford_crane'
BLUE=('#b0a890',)
IVORY=('#d8d1ba','#eee7d3','#a09882')
BLACK=('#1c2529','#3b464a','#10191d')
DESCRIPTIONS={
'pistol':'Crooked smirk mask / collar-length brown hair / burgundy shirt',
'smg':'Wide grin mask / messy bleached hair / white ribbed tank + tattoos',
'shotgun':'Deep frown mask / raised inner brows / hood-up washed plum hoodie',
'rifle':'Angry scowl mask / lowered brows / slate-blue quarter-zip',
'sniper':'Blank mask / forward black hood / zipped black rain jacket'}
NOTES={
'pistol':['Charcoal pleated trousers / black loafers','Thin black gloves / silver wristwatch'],
'smg':['Olive cargo pants / black-white high-tops','Fingerless gloves / compact rear sling bag'],
'shotgun':['Faded gray jeans / black work boots','Black leather gloves / normal proportions'],
'rifle':['Charcoal utility trousers / black lace-up boots','Black gloves / compact belt magazine pouches'],
'sniper':['Reinforced black cargo pants / black boots','Thin gloves / small black hip equipment bag']}
def costume(r,col,h='combed',**kw):
 return base.costume(r,col,h,collective=True,role=r,**kw)
SPECS={
'pistol':costume('pistol',('#70414c','#985d68','#472d38'),'slicklong',loafers=True),
'smg':costume('smg',('#c9c9b9','#e5e3d4','#949e95')),
'shotgun':costume('shotgun',('#675566','#897488','#443c4b'),ankle_boots=True),
'rifle':costume('rifle',('#4a6573','#6c8792','#304650'),ankle_boots=True),
'sniper':costume('sniper',BLACK,ankle_boots=True)}
for r in ['pistol','smg']:SPECS[r]['sleeve']='short'
for r,p,ph in [('pistol','#333b40','#555f62'),('smg','#414e35','#697657'),('shotgun','#646a69','#88918b'),('rifle','#2c353a','#4d5a60'),('sniper','#1c2529','#3b464a')]:
 SPECS[r].update(pants=p,pants_hi=ph,shoe=BLACK[0],shoe_hi=BLACK[1])
SPECS['smg'].update(shoe='#1c2529',shoe_hi='#e1e1d2',ankle_boots=True)
EXTRA_PALETTE=base.EXTRA_PALETTE+list(IVORY)+list(BLACK)+['#70414c','#985d68','#472d38','#c9c9b9','#e5e3d4','#949e95','#675566','#897488','#443c4b','#4a6573','#6c8792','#304650','#b9ac82','#dfd1a4','#6e4d37']
def head(g,c,skin,hi,d='SE'):
 if not c.get('collective'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W'];hood=role in ['shotgun','sniper']
 if not hood:
  tmp=base.E.Element(N+'g');base.head(tmp,c,skin,hi,d)
  if role=='pistol':
   for el in tmp.iter():
    for attr in ['fill','stroke']:
     if el.get(attr) in ['#1b2225','#42484a']:el.set(attr,{'#1b2225':'#4e352a','#42484a':'#78533b'}[el.get(attr)])
  g.extend(list(tmp))
  if role=='smg':
   path(g,'M-7 -45 L-8 -49 -5 -48 -4 -52 -1 -49 1 -53 3 -49 6 -51 6 -48 8 -47 6 -43 4 -44 1 -45 -2 -43 -4 -45Z','#b9ac82','#4a4434',.6)
   path(g,'M-5 -47 L-3 -48 -1 -46 2 -48 5 -46','none','#dfd1a4',1)
   path(g,'M-6 -44 L-3 -45 0 -44 3 -45 6 -44','none','#302c25',1.1)
  # Elastic wraps the actual head; no ivory plate painted on rear views.
  path(g,'M-7 -41 Q0 -39 7 -41','none','#10191d',1.4)
  if back:return
 else:
  path(g,'M-7 -34 L-9 -40 Q-10 -51 -3 -54 Q3 -56 8 -50 L10 -40 7 -32 -6 -32Z',c['cloth'],c['shade'],.8)
  path(g,'M-7 -40 Q-9 -49 -3 -52 M7 -47 L8 -39','none',c['lit'],.65)
  if back:
   path(g,'M0 -51 L1 -35','none',c['shade'],.6)
   return
  path(g,'M-6 -43 Q0 -50 6 -43 L6 -35 -5 -34Z',BLACK[2],'none')
 # Faceplate follows the head's directional transform, narrow in side profile.
 m=base.E.SubElement(g,N+'g',{'data-mask-expression':role,'transform':'translate(3 0) scale(.66 1)' if side else 'scale(1 1)'})
 path(m,'M-6 -44 Q-5 -48 0 -48 Q5 -48 6 -44 L6 -38 Q5 -34 2 -32 L-2 -32 Q-5 -34 -6 -38Z',IVORY[0],IVORY[2],.65)
 path(m,'M-4 -44 Q-4 -46 -1 -46 M4 -43 L4 -38','none',IVORY[1],.7)
 # Sculpted nose, cheek highlights, and restrained plastic scuffs.
 path(m,'M0 -42 L-1 -38 1 -38','none',IVORY[2],.55)
 path(m,'M-4 -39 L-3 -38 M3 -39 L4 -38','none',IVORY[1],.6)
 path(m,'M-5 -36 l1 .7 M3 -45 l1 .3','none','#b5ad96',.45)
 eyes={
 'pistol':'M-4.8 -42 L-1.7 -42 -2 -40.7 -4.5 -40.8Z M1.6 -42.4 L4.7 -42.8 4.4 -41.2 2 -41Z',
 'smg':'M-5 -42 Q-3 -44 -1.4 -41.6 L-1.8 -40.6 -4.5 -40.5Z M1.4 -41.6 Q3 -44 5 -42 L4.5 -40.5 1.8 -40.6Z',
 'shotgun':'M-5 -41.8 L-1.6 -42.6 -1.8 -41 -4.6 -40.6Z M1.6 -42.6 L5 -41.8 4.6 -40.6 1.8 -41Z',
 'rifle':'M-5 -42.5 L-1.4 -41.2 -1.8 -40 -4.6 -40.6Z M1.4 -41.2 L5 -42.5 4.6 -40.6 1.8 -40Z',
 'sniper':'M-4.6 -42 L-1.8 -42 -1.8 -40.8 -4.6 -40.8Z M1.8 -42 L4.6 -42 4.6 -40.8 1.8 -40.8Z'}
 path(m,eyes[role],'#20282b','none')
 if role=='pistol':
  path(m,'M-2.5 -36 Q.5 -34.8 3.5 -37','none','#615d50',.8)
 elif role=='smg':
  path(m,'M-4.5 -37.8 Q0 -35.5 4.5 -37.8 Q3 -32.6 0 -33.4 Q-3 -32.6 -4.5 -37.8Z','#4a473e','none')
  path(m,'M-3.5 -37 Q0 -35.4 3.5 -37','none',IVORY[1],.75)
 elif role=='shotgun':
  path(m,'M-5 -44 L-1.8 -45.4 M1.8 -45.4 L5 -44','none','#746d5b',.85)
  path(m,'M-3.8 -34.8 Q0 -39.2 3.8 -34.8','none','#625c50',1)
 elif role=='rifle':
  path(m,'M-5 -44.5 L-1.5 -42.8 M1.5 -42.8 L5 -44.5','none','#625c50',1)
  path(m,'M-3 -35.5 L-1 -36.3 1 -36.3 3 -35.5','none','#625c50',.8)
 else:path(m,'M-2 -35.8 L2 -35.8','none','#918975',.55)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('collective'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 if r=='smg':
  # Tank neckline and narrow shoulder straps, no changes to body dimensions.
  path(t,'M-6 -33 Q0 -24 6 -33 L3 -33 Q0 -29 -3 -33Z',skin,'none')
  for x in [-7,-4,-1,2,5,8]:path(t,f'M{x} -23 L{x} -3','none',c['shade'],.3)
  path(t,'M-7 -31 L8 -4','none',BLACK[2],1.8)
  if back:
   path(t,'M-4 -25 Q2 -29 7 -23 L9 -9 Q3 -5 -2 -10Z',BLACK[0],BLACK[2],.65)
   path(t,'M-1 -22 L5 -23 M1 -20 L5 -11','none',BLACK[1],.6)
 elif r=='pistol':
  if not back:
   path(t,'M-4 -32 L0 -27 4 -32 1 -22 -2 -24Z',skin,'none')
   path(t,'M-6 -32 L-2 -33 0 -28 -3 -25Z M2 -33 L6 -31 3 -25 0 -28Z',c['lit'],c['shade'],.55)
   path(t,'M0 -23 L0 -1','none',c['shade'],.6)
   for y in [-20,-14,-8]:path(t,f'M1 {y} L1 {y+.5}','none',c['lit'],.8)
 elif r=='shotgun':
  path(t,'M-6 -32 Q0 -29 6 -32','none',c['shade'],1)
  if not back:
   path(t,'M-4 -29 L-4 -23 M4 -29 L4 -23','none',c['lit'],.65)
   path(t,'M-7 -11 Q0 -13 7 -11 L8 -4 -8 -4Z',c['cloth'],c['shade'],.6)
  path(t,'M-10 -1 L10 -1','none',c['shade'],1.2)
 elif r=='rifle':
  if not back:
   path(t,'M-4 -33 L4 -33 2 -25 -2 -25Z',BLACK[2],'none')
   path(t,'M-6 -32 L-3 -34 0 -27 3 -34 6 -32 4 -25 0 -27 -4 -25Z',c['lit'],c['shade'],.5)
   path(t,'M0 -27 L0 -16','none','#a7b5b5',.55)
   path(t,'M0 -18 L1 -17','none','#c2cac2',.8)
  path(t,'M-10 -1 L10 -1','none',BLACK[2],2)
  if not back:
   for x in [-7,7]:path(t,f'M{x-2} -5 h4 v7 h-4Z',BLACK[0],BLACK[1],.5)
 else:
  path(t,'M-6 -32 Q0 -29 6 -32','none',c['shade'],1)
  if not back:
   path(t,'M0 -31 L0 0','none','#657172',.55)
   path(t,'M0 -28 L1 -27','none','#899291',.7)
   path(t,'M-8 -9 L-5 -12 M5 -12 L8 -9','none',c['lit'],.6)
  path(t,'M7 -1 L8 8','none',BLACK[2],1.2)
  path(t,'M6 2 L12 1 12 10 6 11Z',BLACK[0],BLACK[2],.6)
  path(t,'M7 4 L11 3','none',BLACK[1],.55)
def tattoo(g,a,b):
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 for f in [.35,.65]:
  p=a+(b-a)*f
  path(g,f'M{xy(p-n*1.2-v)} L{xy(p+n*1.3)} L{xy(p+v*1.7-n*.5)}','none','#3d4340',.65)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('collective'):return base.arm(g,a,b,h,c,skin,hi)
 if c['role']=='smg':
  base.arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade=skin,sleeve='short'),skin,hi)
  tattoo(g,a,b)
 elif c['role']=='pistol':base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 else:base.arm(g,a,b,h,c,skin,hi)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('collective'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='smg':tattoo(g,a,b)
 p=b-v*3;q=b-v*.7 if c['role']=='smg' else b+v*.3
 path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(q+n*2)} Q{xy(q+v*.3)} {xy(q-n*2)}Z',BLACK[0],BLACK[2],.5)
 if c['role']=='pistol' and c.get('watch_arm'):
  p=b-v*4
  path(g,f'M{xy(p-n*2.3)} L{xy(p+n*2.3)}','none','#9fa9a7',1.6)
  path(g,f'M{xy(p-v)} L{xy(p+n)} L{xy(p+v)} L{xy(p-n)}Z','#d5d8cd','#6c797b',.45)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2)
   a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   radius=np.linalg.norm(ps[2]-ps[3])/2
   q=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if radius>=3.5:
    p=a+(b-a)*.5
    if role in ['smg','sniper']:
     path(q,f'M{xy(p-n*2)} L{xy(p+n*2)} L{xy(p+n*2+v*4)} L{xy(p-n*2+v*4)}Z',c['pants'],c['pants_hi'],.5)
    elif role=='pistol':path(q,f'M{xy(a+v*2)} L{xy(b-v*2)}','none',c['pants_hi'],.4)
   else:
    if role=='sniper':
     p=a+v*1
     path(q,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(p+n*2+v*4)} L{xy(p-n*2+v*4)}Z','#293438',c['pants_hi'],.5)
    if role!='pistol':
     for step in [1.5,3,4.5]:
      p=b-v*step
      path(q,f'M{xy(p-n*1.2)} L{xy(p+n*1.2+v*.4)}','none',c['shoe_hi'],.55)
   if len(q):parent.insert(list(parent).index(el)+3,q)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
