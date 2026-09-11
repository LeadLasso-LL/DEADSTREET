"""Sierra Roja wardrobe review, preserving the accepted normal rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
import whittaker_outfits as western
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=2
TITLE='CARTEL DE SIERRA ROJA'
PREFIX='sierra_roja'
BLUE=('#986653',)
CAMO=['#85775a','#334633','#252f2b','#6c7654']
DESCRIPTIONS={'pistol':'Black aviators / cream chain-print silk / blue jeans / gold jewelry',
'smg':'Forward black cap / burgundy polo / high crossbody bag / tattoos',
'shotgun':'Tan cowboy hat / black mustache / brown leather vest / rolled sleeves',
'rifle':'Buzz cut + black shades / olive combat shirt / fitted tactical vest',
'sniper':'Woodland boonie + field shirt / olive face cloth / light camo strips'}
NOTES={'pistol':['Collar-length black hair / trimmed mustache','Brown pointed leather boots'],
'smg':['Light blue jeans / white leather sneakers','Open polo collar / faded sides'],
'shotgun':['Charcoal shirt / faded black jeans','Silver buckle / brown square-toe boots'],
'rifle':['Tan cargo pants / brown combat boots','Magazine pouches / black gloves'],
'sniper':['Dark olive cargo pants / brown lace-up boots','Neck hair / olive gloves']}
def costume(role,colors,head='combed',**kw):
 return base.costume(role,colors,head,sierra=True,role=role,**kw)
SPECS={'pistol':costume('pistol',('#c9bfa4','#e5dcc1','#9d9073'),'slicklong',watch=True,ankle_boots=True),
'smg':costume('smg',('#68373c','#93545a','#40282e'),cap=True,tattoo=True),
'shotgun':costume('shotgun',('#624633','#886447','#3e3027'),ankle_boots=True),
'rifle':costume('rifle',('#48533d','#697658','#2d392b'),gloves=True,ankle_boots=True),
'sniper':costume('sniper',('#566349','#788568','#354332'),'slicklong',gloves=True,ankle_boots=True)}
for role in ['pistol','smg']:SPECS[role]['sleeve']='short'
SPECS['pistol'].update(pants='#2b4256',pants_hi='#4f6577',shoe='#5b402d',shoe_hi='#896546')
SPECS['smg'].update(pants='#728d9f',pants_hi='#99adba',shoe='#d8dbd2',shoe_hi='#efeee2')
SPECS['shotgun'].update(pants='#31373a',pants_hi='#535d62',shoe='#58402e',shoe_hi='#826246')
SPECS['rifle'].update(pants='#998967',pants_hi='#b7a685',shoe='#58452f',shoe_hi='#81694a')
SPECS['sniper'].update(pants='#394632',pants_hi='#5b6a4b',shoe='#514331',shoe_hi='#7c6a4d')
EXTRA_PALETTE=base.EXTRA_PALETTE+CAMO+['#c9bfa4','#e5dcc1','#9d9073','#b49b62','#68373c','#93545a','#728d9f','#99adba','#998967','#b7a685','#566349','#788568','#a28b61','#c4ab80','#715a3e']
def head(g,c,skin,hi,d='SE'):
 if not c.get('sierra'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 if role=='shotgun':
  western.head(g,dict(c,whittaker=True,head='cowboy',hair='#182024',hair_hi='#3c4649',hat='#a28b61',hat_hi='#c4ab80',hat_shade='#59422e',mustache=True),skin,hi,d)
  return
 base.head(g,c,skin,hi,d)
 if role=='rifle':
  path(g,'M-6 -44 L-6 -47 Q0 -51 5 -48 L7 -45 6 -42 4 -43 4 -46 Q0 -48 -4 -45 L-4 -42Z','#1a2225','none')
  if not back:
   path(g,'M-5 -37 L-2 -35 2 -35 5 -37 4 -34 1 -33 -3 -34Z','#50534b','none')
 if role=='pistol' and not back:
  path(g,'M-3 -37 Q0 -39 4 -37 L4 -35 -1 -36 -3 -35Z','#182024','none')
 if role in ['pistol','rifle'] and not back:
  lens=('M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z' if role=='pistol' else 'M-7 -42 Q0 -43 7 -42 L6 -38 2 -38 0 -40 -2 -38 -6 -38Z')
  if side:lens='M1 -42 L7 -42 6 -38 2 -38Z'
  path(g,lens,'#10171a','#080f12',.7)
  path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41','none','#080f12',.7)
 if role=='sniper':
  path(g,'M-7 -45 L-6 -51 Q0 -53 6 -51 L8 -45Z','#566349','#354332',.7)
  path(g,'M-12 -45 Q-7 -47 -5 -45 Q0 -43 7 -46 L13 -44 Q10 -40 0 -41 Q-9 -40 -12 -45Z','#566349','#354332',.7)
  western.blob(g,(-3,-49),2.5,1.5,CAMO[0]);western.blob(g,(4,-47),2,1.3,CAMO[2])
  path(g,'M-6 -46 Q0 -44 7 -46','none','#354332',1)
  western.blob(g,(-7,-43),2,1,CAMO[2]);western.blob(g,(7,-43),2,1,CAMO[0])
  if not back:
   path(g,'M-6 -39 Q0 -37 6 -39 L6 -34 1 -31 -5 -33Z','#4b593d','#283526',.6)
   path(g,'M-4 -35 L1 -33 4 -35','none','#788568',.6)
def pattern(t):
 for x in [-7,6]:
  for y in [-25,-18,-11,-4]:
   path(t,f'M{x-1.5} {y} Q{x-2.5} {y-2} {x} {y-2} Q{x+2.5} {y-2} {x+1.5} {y} Q{x} {y+2} {x-1.5} {y}Z','none','#b49b62',.55)
   path(t,f'M{x} {y+1} L{x} {y+4}','none','#b49b62',.45)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('sierra'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0]
 role=c['role'];back=d in ['N','NE','NW']
 if role=='pistol':pattern(t)
 if role=='sniper':
  for x,y,k in [(-7,-26,0),(4,-27,1),(-2,-19,2),(7,-13,0),(-7,-9,1),(1,-5,0)]:
   western.blob(t,(x,y),2.7,2.6,CAMO[k])
  # Thin fabric tabs, never expanded anatomy or a bulky ghillie silhouette.
  for x,y in [(-9,-30),(-5,-32),(5,-32),(9,-30)]:
   path(t,f'M{x-1} {y} L{x+1.1} {y+.5} {x+.7} {y+7} {x-.7} {y+5} {x-1.4} {y+8}Z','#697654','#354332',.35)
 if role=='rifle':
  path(t,'M-8 -31 L-5 -32 -4 -26 4 -26 5 -32 9 -30 10 -16 10 0 -10 0 -10 -16Z','#1d2629','#0e171b',.65)
  path(t,'M-6 -24 L6 -24 7 -13 -7 -13Z','#2e3a3e','#121c20',.6)
  if back:path(t,'M-5 -21 L5 -21 M-6 -10 L6 -10','none','#4b5759',.7)
  else:
   for x in [-6,0,6]:
    path(t,f'M{x-2} -14 L{x+2} -14 {x+2} -3 {x-2} -3Z','#263236','#10191d',.55)
    path(t,f'M{x-1.5} -11 L{x+1.5} -11','none','#4b5759',.6)
  return
 if back:
  if role=='smg':path(t,'M-8 -30 L8 -4','none','#151e22',2.3)
  return
 if role in ['pistol','smg']:
  path(t,'M-4 -32 L0 -27 4 -32 2 -23 0 -25 -2 -23Z',c['lit'],c['shade'],.55)
  path(t,'M-2 -31 L2 -31 0 -26Z',skin,'none')
  path(t,'M0 -24 L0 -18','none',c['shade'],.65)
  if role=='pistol':
   path(t,'M-3 -31 Q0 -24 3 -31','none',base.GOLD[0],.8)
   path(t,'M0 -17 L0 -2','none',c['shade'],.5)
  else:
   path(t,'M-8 -30 L8 -3','none','#141d21',2.5)
   path(t,'M-5 -23 L5 -23 6 -13 -4 -12Z','#202a2f','#0e171b',.7)
   path(t,'M-3 -20 L4 -20 M4 -20 L4 -18','none','#647171',.6)
 elif role=='shotgun':
  path(t,'M-5 -32 L5 -32 5 0 -5 0Z','#333a3e','#182125',.5)
  path(t,'M-4 -32 L0 -28 4 -32 2 -25 0 -27 -2 -25Z','#535d62','#182125',.5)
  path(t,'M0 -26 L0 -2','none','#182125',.65)
  for y in [-22,-15,-8]:path(t,f'M1 {y} L1 {y+.4}','none','#929990',.7)
  path(t,'M-7 -30 L-5 -23 -5 -2 M7 -30 L5 -23 5 -2','none',c['lit'],.7)
  path(t,'M-10 -1 L11 -1','none','#302920',2)
  path(t,'M-2 -2 L2 -2 2 1 -2 1Z','#a4aaa4','#302920',.5)
 elif role=='sniper':
  path(t,'M0 -29 L0 -1','none','#283526',.7)
  path(t,'M-8 -21 L-3 -21 -3 -15 -8 -16Z M3 -21 L8 -21 8 -16 3 -15Z',c['cloth'],c['shade'],.5)
def camo_limb(g,a,b):
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 for f,col in [(.3,CAMO[0]),(.65,CAMO[2])]:
  p=a+(b-a)*f
  path(g,f'M{xy(p-v*1.5+n*1.7)} Q{xy(p-v)} {xy(p+n+v*2)} L{xy(p-n*1.7+v)} Q{xy(p-n)} {xy(p-n*1.3-v*1.5)}Z',col,'none')
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('sierra'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='rifle':
  end=a+(b-a)*.35
  base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none',c['lit'],1.4)
 if c['role']=='sniper':camo_limb(g,a,b)
 if c.get('gloves'):
  p=b-v*3
  fill='#414f35' if c['role']=='sniper' else '#131c20'
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',fill,'#10181c',.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('sierra'):return base.arm(g,a,b,h,c,skin,hi)
 role=c['role']
 if role in ['pistol','smg']:
  return base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 if role=='shotgun':
  temp=dict(c,sleeve='short',cloth='#333a3e',lit='#535d62',shade='#182125')
 elif role=='rifle':temp=dict(c,sleeve='short')
 else:temp=c
 rig.connected_arm(g,a,b,h,temp,skin,hi)
 if role=='sniper':camo_limb(g,a,b)
 if role=='shotgun':
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);p=b-v*1.3
  path(g,f'M{xy(p-n*2.7)} L{xy(p+n*2.7)}','none','#535d62',1.5)
def make(role,model,direction,**state):
 base.SPECS=SPECS
 root=base.make(role,model,direction,**state);c=SPECS[role]
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role in ['rifle','sniper']:
    if radius<3.5:
     for step in [1.5,3,4.5]:
      p=b-v*step;path(detail,f'M{xy(p-n*1.2)} L{xy(p+v*.5+n*1.2)}','none',c['shoe_hi'],.55)
    else:
     p=a+(b-a)*.48
     path(detail,f'M{xy(p-n*2)} L{xy(p+n*2)} L{xy(p+n*2+v*5)} L{xy(p-n*2+v*5)}Z',c['pants'],c['pants_hi'],.55)
   if len(detail):parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
