"""Lombardia regular outfits on the accepted normal unit rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=2
TITLE="L'ORDINE DI LOMBARDIA"
PREFIX='lombardia'
BLUE=('#8c856a',)
DESCRIPTIONS={
'pistol':'Black piped polo + aviators / light gray tailoring / gold jewelry',
'smg':'Brown leather bomber / white ribbed tank / goatee + gold jewelry',
'shotgun':'Black shades / charcoal car coat / burgundy knit / checked trousers',
'rifle':'Chocolate double-breasted suit / cream shirt + pocket square / black tie',
'sniper':'Brown flat cap / black scarf / mid-thigh olive tailored overcoat'}
NOTES={
'pistol':['Collar-length swept-back brown hair','Black leather loafers'],
'smg':['Sharp fade / tailored black trousers','Black Chelsea boots / gold bracelet'],
'shotgun':['Receding hair / salt-and-pepper mustache','Black gloves / sturdy ankle boots'],
'rifle':['Precise brown side part / clean-shaven','Black Oxfords / fitted black gloves'],
'sniper':['Wavy salt-and-pepper collar-length hair','Charcoal trousers / brown lace-up boots']}
def costume(role,colors,head,**kw):
 return base.costume(role,colors,head,lombardia=True,role=role,**kw)
SPECS={
'pistol':costume('pistol',('#202629','#404747','#111a1d'),'slicklong',watch=True,loafers=True),
'smg':costume('smg',('#48362b','#705441','#2a231e'),'combed',ankle_boots=True),
'shotgun':costume('shotgun',('#353c40','#555e62','#20282d'),'receding',glasses='wayfarer',gloves=True,ankle_boots=True),
'rifle':costume('rifle',('#3b2c25','#5e4738','#251e1b'),'sidepart',gloves=True),
'sniper':costume('sniper',('#414a36','#626d50','#293224'),'flat',gloves=True,ankle_boots=True)}
SPECS['pistol'].update(sleeve='short',pants='#a2a7a7',pants_hi='#c5c9c5')
SPECS['shotgun'].update(pants='#3c4347',pants_hi='#5b6469')
SPECS['rifle'].update(pants='#3b2c25',pants_hi='#5e4738')
SPECS['sniper'].update(pants='#30373b',pants_hi='#515b60',shoe='#3f3026',shoe_hi='#68513c')
EXTRA_PALETTE=base.EXTRA_PALETTE+['#414a36','#626d50','#293224','#3b2c25','#5e4738','#a2a7a7','#c5c9c5','#59303a','#824955','#d9d5c4','#eee6ce','#48362b','#705441']
def head(g,c,skin,hi,d='SE'):
 if not c.get('lombardia'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W'];start=len(g)
 if role=='sniper':
  path(g,'M-7 -43 Q0 -49 7 -43 L8 -34 6 -31 3 -33 0 -31 -4 -33 -7 -31Z','#515750','#232b28',.5)
  for x in [-6,-3,3,6]:path(g,f'M{x} -41 q-1 3 0 5 q1 2 0 4','none','#8f958b',.65)
 base.head(g,c,skin,hi,d)
 mapping=({'#1b2225':'#332b27','#42484a':'#5a4637'} if role=='pistol' else
 {'#30373a':'#443429','#50595e':'#705642','#4c5357':'#161e22','#6b7375':'#3c4648'} if role=='sniper' else {})
 for el in list(g)[start:]:
  for attr in ['fill','stroke']:
   if el.get(attr) in mapping:el.set(attr,mapping[el.get(attr)])
 if role=='smg':
  path(g,'M-6 -44 L-5 -47 Q0 -51 5 -47 L6 -43 5 -40 4 -42 4 -45 Q0 -48 -4 -44 L-4 -40 -6 -41Z','#171f23','none')
  if not back:
   path(g,'M-3 -37 Q0 -39 3 -37 L3 -36 1 -36 2 -34 -1 -33 -3 -34 -2 -36Z','#202629','none')
 if role=='shotgun':
  # Gray accents only on the mustache, retaining receding black hair.
  for el in list(g)[start:]:
   if el.get('fill')=='#332b27':el.set('fill','#1b2225')
  if not back:path(g,'M-3 -37 L-1 -36 M1 -37 L3 -36 M-2 -35 L0 -36','none','#a0a49a',.65)
 if role=='pistol' and not back:
  lens='M1 -42 L7 -42 Q8 -40 5 -38 Q2 -37 1 -42Z' if side else 'M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z'
  path(g,lens,'#11191d','#080f12',.7)
  path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41','none','#080f12',.6)
def coat_tail(t,c,back,length):
 if back:
  path(t,f'M-11 -5 L11 -5 11 {length} Q5 {length+1} 0 {length} Q-6 {length+1} -11 {length}Z',c['cloth'],'none')
  path(t,f'M-11 -3 L-11 {length} M11 -3 L11 {length} M0 3 L0 {length}','none',c['shade'],.7)
 else:
  path(t,f'M-11 -5 L-2 -5 -3 {length} -11 {length}Z M2 -5 L11 -5 11 {length} 3 {length}Z',c['cloth'],'none')
  path(t,f'M-11 -3 L-11 {length} -3 {length} -2 -3 M11 -3 L11 {length} 3 {length} 2 -3','none',c['shade'],.65)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('lombardia'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];role=c['role'];back=d in ['N','NE','NW']
 if role in ['shotgun','sniper']:coat_tail(t,c,back,9 if role=='shotgun' else 14)
 if back:
  path(t,'M-7 -29 Q0 -27 7 -29 M0 -25 L0 -3','none',c['shade'],.6)
  if role=='smg':path(t,'M-10 -2 L10 -2','none',c['shade'],1.5)
  return
 if role=='pistol':
  path(t,'M-4 -32 L0 -28 4 -32 2 -25 0 -27 -2 -25Z',c['cloth'],c['shade'],.6)
  path(t,'M-4 -31 L-2 -26 M4 -31 L2 -26','none','#d9d5c4',.65)
  path(t,'M0 -27 L0 -22','none',c['shade'],.65)
  path(t,'M-3 -31 Q0 -24 3 -31','none',base.GOLD[0],.7)
 elif role=='smg':
  path(t,'M-5 -32 Q0 -28 5 -32 L5 0 -5 0Z','#d9d5c4',c['shade'],.5)
  path(t,'M-4 -30 Q0 -25 4 -30','none','#a5a797',.65)
  for x in [-3,-1,1,3]:path(t,f'M{x} -24 L{x} -2','none','#b6b8aa',.35)
  path(t,'M-4 -31 Q0 -19 4 -31','none',base.GOLD[0],.8)
  path(t,'M-8 -31 L-5 -34 -3 -29 -5 -26Z M5 -34 L8 -31 5 -26 3 -29Z',c['lit'],c['shade'],.6)
  path(t,'M-5 -25 L-5 -2 M5 -25 L5 -2','none','#8a8974',.45)
  path(t,'M-11 -1 L-6 -1 M6 -1 L11 -1','none',c['shade'],1.6)
 elif role=='shotgun':
  path(t,'M-5 -35 L5 -35 5 0 -5 0Z','#59303a',c['shade'],.5)
  path(t,'M-4 -33 Q0 -31 4 -33 M-4 -30 Q0 -28 4 -30','none','#824955',.6)
  base.lapels(t,c)
 elif role=='rifle':
  path(t,'M-5 -33 L5 -33 4 -22 0 -16 -4 -22Z','#d9d5c4',c['shade'],.5)
  path(t,'M-4 -33 L0 -29 4 -33 2 -25 0 -28 -2 -25Z','#eee6ce','#9b9682',.5)
  path(t,'M-1 -29 L1 -29 1.3 -27 .6 -25 1.3 -18 0 -15 -1.3 -18 -.6 -25 -1.3 -27Z','#11191d','none')
  base.lapels(t,c)
  path(t,'M1 -23 L6 -15 6 0','none',c['shade'],.7)
  for x in [-3,5]:
   for y in [-14,-8,-2]:path(t,f'M{x} {y} L{x} {y+.5}','none','#8a7560',.9)
  path(t,'M5 -24 L5 -27 6 -26 7 -28 8 -25 9 -26 9 -24Z','#eee6ce','none')
  path(t,'M5 -23 L9 -23','none',c['shade'],.6)
 elif role=='sniper':
  path(t,'M-5 -34 L5 -34 4 -18 -4 -18Z','#171f23',c['shade'],.5)
  base.lapels(t,c)
  path(t,'M-10 -31 L-7 -36 -4 -33 M4 -33 L7 -36 10 -31','none',c['lit'],1)
  path(t,'M0 -17 L0 2','none',c['shade'],.6)
def arm(g,a,b,h,c,skin,hi):
 if c.get('lombardia') and c['role']=='pistol':return base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 return base.arm(g,a,b,h,c,skin,hi)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if c.get('lombardia') and c['role']=='smg' and (c.get('watch_arm') or r<3):
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);p=b-v*2
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)}','none',base.GOLD[0],1.1)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 if role not in ['shotgun','sniper']:return root
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role=='shotgun':
    end=b-v*5 if radius<3.5 else b-v
    for off in [-1.3,1.3]:path(detail,f'M{xy(a+v+n*off)} L{xy(end+n*off)}','none','#697075',.3)
    for f in [.25,.5,.75]:
     p=a+(end-a)*f;path(detail,f'M{xy(p-n*(radius-.6))} L{xy(p+n*(radius-.6))}','none','#697075',.3)
   elif radius<3.5:
    for step in [1.5,3,4.5]:
     p=b-v*step;path(detail,f'M{xy(p-n*1.2)} L{xy(p+v*.4+n*1.2)}','none',c['shoe_hi'],.55)
   if len(detail):parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
