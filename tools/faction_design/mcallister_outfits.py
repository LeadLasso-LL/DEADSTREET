"""McAllister regular wardrobe on the accepted ordinary-unit rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='MCALLISTER HOLDINGS'
PREFIX='mcallister'
BLUE=('#7a8d90',)
DESCRIPTIONS={'pistol':'Sandy side-part / black shades / rolled pale blue shirt / tan chinos',
'smg':'Backward navy cap / beige Harrington / green polo / blue jeans',
'shotgun':'Sporting cap / olive shooting vest / checked shirt / brown corduroy',
'rifle':'Black aviators / navy quarter-zip / white collar / magazine belt',
'sniper':'Olive boonie / brown face cloth / waxed field jacket / camo pants'}
NOTES={'pistol':['Brown loafers and belt','Silver watch / open collar'],
'smg':['Wavy brown hair / clean white sneakers','Lightweight jacket / normal proportions'],
'shotgun':['Graying hair / trimmed mustache','Suede shoulder panels / brown field boots'],
'rifle':['Neat dark side part / clean-shaven','Charcoal utility trousers / black boots and gloves'],
'sniper':['Auburn hair / raised olive corduroy collar','Dark green sweater / olive gloves / brown boots']}
def spec(role,colors,head='sidepart',**kw):
 return base.costume(role,colors,head,mcallister=True,role=role,**kw)
SPECS={'pistol':spec('pistol',('#a0b9c2','#c5d8dc','#708c98'),watch=True,glasses='wayfarer'),
'smg':spec('smg',('#b6ab8c','#d6caae','#8a8067'),'slicklong'),
'shotgun':spec('shotgun',('#59634a','#7e8767','#394330'),'receding',ankle_boots=True),
'rifle':spec('rifle',('#263b50','#465c72','#142535'),gloves=True,ankle_boots=True),
'sniper':spec('sniper',('#4e3e2e','#756148','#30291f'),'slicklong',gloves=True,ankle_boots=True)}
SPECS['pistol'].update(pants='#a08c67',pants_hi='#bfaa84',shoe='#5b4231',shoe_hi='#84654a')
SPECS['smg'].update(pants='#30495e',pants_hi='#536d80',shoe='#d8dbd2',shoe_hi='#efeee2')
SPECS['shotgun'].update(pants='#45372b',pants_hi='#69533e',shoe='#503b2b',shoe_hi='#796046')
SPECS['rifle'].update(pants='#343e45',pants_hi='#55636c')
SPECS['sniper'].update(pants='#526049',pants_hi='#788368',shoe='#56432f',shoe_hi='#806748',camo=True)
EXTRA_PALETTE=base.EXTRA_PALETTE+['#a0b9c2','#c5d8dc','#708c98','#a08c67','#bfaa84','#b6ab8c','#d6caae','#8a8067','#263b50','#465c72','#59634a','#7e8767','#8b7854','#b3a17c','#9b6a45','#786244','#202923','#303d28','#7f7956']
def head(g,c,skin,hi,d='SE'):
 if not c.get('mcallister'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 temp=base.E.Element(N+'g');base.head(temp,c,skin,hi,d)
 hair,light={'pistol':('#8b7854','#b3a17c'),'smg':('#513e2e','#7e6147'),'shotgun':('#73766b','#a0a293'),'rifle':('#332b27','#5a4637'),'sniper':('#71472f','#9b6a45')}[role]
 for el in temp.iter():
  for a in ['fill','stroke']:
   if el.get(a) in ['#332b27','#1b2225']:el.set(a,hair)
   elif el.get(a) in ['#5a4637','#42484a']:el.set(a,light)
 g.extend(list(temp))
 if role=='rifle' and not back:
  lens='M1 -42 L7 -42 Q8 -40 5 -38 Q2 -37 1 -42Z' if side else 'M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z'
  path(g,lens,'#10171a','#080f12',.7)
  path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41','none','#080f12',.7)
 if role=='smg':
  path(g,'M-7 -43 L-8 -39 -6 -40 -7 -35 -4 -37 M6 -43 L8 -39 6 -39 7 -35 4 -37',hair,'none')
  path(g,'M-7 -45 Q-7 -52 0 -52 Q7 -52 8 -45 L7 -43 -7 -43Z','#263b50','#142535',.7)
  path(g,'M0 -51 L0 -46','none','#465c72',.6)
  if back:path(g,'M-7 -44 Q0 -43 7 -44 L10 -41 Q2 -40 -7 -42Z','#263b50','#142535',.6)
  else:
   path(g,'M-3 -45 Q0 -48 3 -45 L3 -43 -3 -43Z',hair,'#142535',.5)
   if side:path(g,'M-7 -45 L-12 -43 -11 -41 -6 -42Z','#263b50','#142535',.5)
 if role=='shotgun':
  path(g,'M-7 -45 Q-7 -51 0 -51 Q7 -51 8 -45 L7 -43 -7 -44Z','#66583f','#372e23',.7)
  path(g,'M-3 -50 L-2 -45 M2 -50 L3 -45','none','#918067',.55)
  if not back:
   path(g,'M-6 -44 Q0 -43 7 -45 L11 -42 Q3 -40 -5 -42Z','#493627','#2a241d',.6)
 if role=='sniper':
  path(g,'M-7 -45 L-6 -51 Q0 -53 6 -51 L8 -45Z','#48533b','#293425',.7)
  path(g,'M-10 -45 Q-4 -44 1 -45 L10 -45 11 -43 Q0 -40 -10 -43Z','#48533b','#293425',.65)
  path(g,'M-5 -47 Q0 -45 6 -47','none','#293425',1)
  if not back:
   path(g,'M-6 -39 Q0 -37 6 -39 L6 -34 1 -31 -5 -33Z','#65523d','#342b21',.6)
   path(g,'M-4 -35 L1 -33 4 -35','none','#8d7759',.6)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('mcallister'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];role=c['role'];back=d in ['N','NE','NW']
 if role=='shotgun':
  for x in [-8,8]:path(t,f'M{x-2} -31 L{x+2} -31 {x+2} -22 {x-2} -22Z','#71563c','#493927',.5)
 if back:
  if role in ['smg','sniper']:path(t,'M-7 -28 Q0 -26 7 -28 M0 -24 L0 -3','none',c['shade'],.6)
  return
 if role=='pistol':
  path(t,'M-4 -32 L0 -28 4 -32 2 -24 0 -27 -2 -24Z',c['lit'],c['shade'],.55)
  path(t,'M-2 -31 L2 -31 0 -27Z',skin,'none')
  path(t,'M0 -25 L0 -2','none',c['shade'],.55)
  for y in [-21,-14,-7]:path(t,f'M1 {y} L1 {y+.4}','none','#e4e7da',.75)
  path(t,'M-10 -1 L11 -1','none','#513b2a',2)
  path(t,'M-1 -2 L2 -2 2 0 -1 0Z','none','#a4aaa4',.6)
 elif role in ['smg','shotgun']:
  fill='#304e3e' if role=='smg' else '#c8bea2'
  path(t,'M-5 -32 L5 -32 5 0 -5 0Z',fill,c['shade'],.5)
  if role=='shotgun':
   for x in [-3,1,4]:path(t,f'M{x} -29 L{x} -1','none','#715a40',.65)
   for y in [-26,-21,-16,-11,-6]:path(t,f'M-4 {y} L4 {y}','none','#715a40',.65)
  path(t,'M-4 -32 L0 -28 4 -32 2 -24 0 -27 -2 -24Z','#56705a' if role=='smg' else '#e0d5b9',c['shade'],.5)
  path(t,'M-7 -32 L-5 -26 -5 -1 M7 -32 L5 -26 5 -1','none',c['lit'],.7)
  if role=='smg':
   path(t,'M-8 -31 L-6 -35 -3 -30 -5 -26Z M6 -35 L8 -31 5 -26 3 -30Z',c['cloth'],c['shade'],.55)
   path(t,'M-10 -2 L-6 -1 M6 -1 L10 -2','none',c['shade'],1.5)
  else:
   for x in [-8,8]:path(t,f'M{x-2} -13 L{x+2} -13 {x+2} -4 {x-2} -4Z',c['cloth'],c['shade'],.55)
 elif role=='rifle':
  path(t,'M-5 -33 L0 -28 5 -33 3 -25 0 -28 -3 -25Z','#d6ddd6','#8e9fa1',.55)
  path(t,'M-6 -33 L-4 -36 -2 -30 -3 -25 -6 -28Z M4 -36 L7 -32 6 -27 3 -25 2 -30Z',c['lit'],c['shade'],.55)
  path(t,'M0 -27 L0 -18','none','#a4aaa4',.65)
  path(t,'M0 -23 L1 -23 1 -21 0 -21Z','#a4aaa4','none')
  path(t,'M-10 -1 L11 -1','none','#10181c',2)
  for x in [-7,7]:path(t,f'M{x-1.8} -5 L{x+1.8} -5 {x+1.8} 2 {x-1.8} 2Z','#202a2f','#101619',.55)
 else:
  path(t,'M-4 -33 L4 -33 4 -21 -4 -21Z','#2e4433','#1c2c22',.5)
  path(t,'M-9 -31 L-7 -36 -4 -35 -3 -27Z M4 -35 L7 -36 10 -31 3 -27Z','#596044','#343c29',.6)
  for x in [-7,-5,5,7]:path(t,f'M{x} -34 L{x+1} -30','none','#858567',.45)
  path(t,'M0 -24 L0 -1','none',c['shade'],.7)
  for x in [-7,7]:path(t,f'M{x-2} -17 L{x+2} -17 {x+2} -6 {x-2} -6Z',c['cloth'],c['shade'],.5)
def forearm(g,a,b,c,skin,hi,r=3.1):
 start=len(g);base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('mcallister'):return
 if c.get('watch'):
  for el in list(g)[start:]:
   for attr in ['fill','stroke']:
    if el.get(attr) in base.GOLD:el.set(attr,'#b0b9b6')
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='shotgun':
  end=a+(b-a)*.35
  base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none','#e0d5b9',1.4)
 if c.get('gloves'):
  p=b-v*3;fill='#414f35' if c['role']=='sniper' else '#131c20'
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',fill,'#10181c',.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('mcallister'):return base.arm(g,a,b,h,c,skin,hi)
 role=c['role']
 temp=dict(c,sleeve='short') if role=='pistol' else dict(c,sleeve='short',cloth='#c8bea2',lit='#e0d5b9',shade='#715a40') if role=='shotgun' else c
 base.arm(g,a,b,h,temp,skin,hi)
 if role in ['pistol','shotgun']:
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
  if role=='pistol':
   p=b-v*1.5;path(g,f'M{xy(p-n*2.7)} L{xy(p+n*2.7)}','none',c['lit'],1.6)
  else:
   for f in [.2,.45,.7]:
    p=a+(b-a)*f;path(g,f'M{xy(p-n*2.3)} L{xy(p+n*2.3)}','none','#715a40',.65)
   path(g,f'M{xy(a+v*2+n*.7)} L{xy(b-v+n*.7)}','none','#715a40',.65)
def make(role,model,direction,**state):
 base.SPECS=SPECS; base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 if role=='sniper':base.shared.decorate_lower(root,dict(c,boots=False))
 if role=='shotgun':
  for parent in list(root.iter()):
   for el in list(parent):
    if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
    nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
    if len(nums)!=12:continue
    ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
    v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
    detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
    for x in [-1.2,0,1.2]:path(detail,f'M{xy(a+v*2+n*x)} L{xy(b-v*5+n*x)}','none',c['pants_hi'],.3)
    parent.insert(list(parent).index(el)+2,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
