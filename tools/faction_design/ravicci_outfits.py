"""Ravicci regular wardrobe, reusing the accepted body and garment rig."""
from pathlib import Path
import sys,copy
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE=base.N,base.path,base.xy,base.BASE
np=base.np
KIND=2
TITLE='RAVICCI FAMILY'
PREFIX='ravicci'
BLUE=('#a28b63',)
DESCRIPTIONS={
'pistol':'Gold aviators / chocolate blazer / cream polo / beige trousers',
'smg':'Black rectangular shades / navy suit / open black silk shirt',
'shotgun':'Amber glasses / camel overcoat / waistcoat / patterned tie',
'rifle':'Charcoal pinstripe three-piece / silver tie / white pocket square',
'sniper':'Black newsboy cap / charcoal scarf / high-collared black coat'}
NOTES={
'pistol':['Swept-back hair / gold wristwatch','Dark brown leather loafers'],
'smg':['Sharp side part / chain and pinky ring','Black Chelsea boots'],
'shotgun':['Graying hair / trimmed mustache','Brown gloves and leather boots'],
'rifle':['Neatly parted hair / black gloves','Polished black Oxford shoes'],
'sniper':['Gray temples and stubble / black knit','Charcoal trousers / black gloves']}
def costume(role,colors,head,**kw):
 return base.costume(role,colors,head,ravicci=True,role=role,**kw)
SPECS={
'pistol':costume('pistol',('#49372d','#705442','#2b2420'),'combed',watch=True,loafers=True),
'smg':costume('smg',('#202d40','#3e5069','#141d2b'),'sidepart',ankle_boots=True,ring=True),
'shotgun':costume('shotgun',('#aa865a','#cfaa78','#715638'),'receding',ankle_boots=True,gloves=True),
'rifle':costume('rifle',('#343b40','#545e65','#20272c'),'sidepart',gloves=True),
'sniper':costume('sniper',('#191f23','#353e44','#101619'),'combed',ankle_boots=True,gloves=True)}
SPECS['pistol'].update(pants='#b3a286',pants_hi='#d4c5a9',shoe='#352820',shoe_hi='#65503d')
SPECS['smg'].update(pants='#202d40',pants_hi='#3e5069')
SPECS['shotgun'].update(pants='#3f322b',pants_hi='#665144',shoe='#30251e',shoe_hi='#574333')
SPECS['rifle'].update(pants='#343b40',pants_hi='#545e65')
SPECS['sniper'].update(pants='#30363a',pants_hi='#50595f')
EXTRA_PALETTE=base.EXTRA_PALETTE+['#aa865a','#cfaa78','#715638','#b3a286','#d4c5a9','#202d40','#3e5069','#141d2b','#d8cfb8','#efe8d5','#635344','#b69a6c','#49372d','#705442','#343b40','#545e65','#8a949a','#c4c9c9','#413129','#8d683e']
def head(g,c,skin,hi,d='SE'):
 if not c.get('ravicci'):return base.head(g,c,skin,hi,d)
 start=len(g);base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 # Hair-only recoloring leaves skin and normal skull geometry intact.
 if role in ['pistol','smg','rifle','shotgun']:
  mapping=({'#1b2225':'#332b27','#42484a':'#5a4637'} if role=='pistol' else
           {'#332b27':'#1b2225','#5a4637':'#42484a'} if role in ['smg','rifle'] else
           {'#332b27':'#505552','#5a4637':'#8a9490'})
  for el in list(g)[start:]:
   for k in ['fill','stroke']:
    if el.get(k) in mapping:el.set(k,mapping[el.get(k)])
 if role=='shotgun':
  for x in [-5,5]:path(g,f'M{x} -46 L{x} -40','none','#a8aeaa',.65)
 if role in ['pistol','smg','shotgun'] and not back:
  frame=base.GOLD[0] if role=='pistol' else '#101619' if role=='smg' else '#413129'
  lens='#635344' if role=='pistol' else '#151e26' if role=='smg' else '#b69a6c'
  if side:
   shape='M1 -42 L6 -42 Q8 -41 6 -38 Q3 -36 2 -39Z' if role=='pistol' else 'M1 -42 L7 -42 7 -39 2 -39Z'
   path(g,shape,lens,frame,.75)
   path(g,'M-5 -42 L1 -41','none',frame,.8)
   path(g,'M3 -41 L5 -40','none','#8d683e' if role=='shotgun' else '#8a949a',.4)
  else:
   shape='M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z' if role=='pistol' else 'M-6 -42 L-1 -42 -1 -39 -6 -39Z M1 -42 L6 -42 6 -39 1 -39Z'
   path(g,shape,lens,frame,.8)
   path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41 M6 -41 L7 -42','none',frame,.7)
   if role=='shotgun':
    path(g,'M-5 -40.5 L-3 -40.5 M2 -40.5 L4 -40.5','none','#635344',.5)
    path(g,'M-6 -42 L-4 -42 M3 -42 L5 -42','none','#8d683e',.5)
 if role=='sniper':
  for x in [-5.5,5.5]:path(g,f'M{x} -45 L{x} -36','none','#8a949a',1.2)
  if not back:path(g,'M-5 -37 L-3 -34 M4 -37 L3 -34','none','#8a949a',.8)
  path(g,'M-8 -44 Q-10 -50 -3 -51 Q4 -53 8 -48 L9 -44 Q1 -41 -8 -44Z','#191f23','#101619',.8)
  path(g,'M-3 -50 L0 -44 M3 -50 L4 -44 M-6 -48 L-4 -44','none','#353e44',.65)
  if not back:
   path(g,('M4 -44 L11 -43 Q12 -41 6 -41Z' if side else 'M-7 -43 Q1 -42 8 -44 L10 -42 Q1 -40 -7 -42Z'),'#191f23','#101619',.6)
   path(g,'M-6 -39 Q0 -37 6 -39 L7 -34 4 -30 -4 -31 -7 -35Z','#30363a','#101619',.6)
   path(g,'M-5 -35 Q0 -33 5 -35','none','#50595f',.65)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('ravicci'):return base.torso(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW']
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0]
 if role in ['shotgun','sniper']:
  if role=='shotgun' and not back:
   path(t,'M-11 -5 L-2 -5 -3 7 -5 14 -11 13Z M2 -5 L11 -5 11 13 5 14 3 7Z',c['cloth'],'none')
   path(t,'M-2 -5 L-3 7 -5 14 M2 -5 L3 7 5 14','none',c['shade'],.65)
  else:path(t,'M-11 -5 L11 -5 11 13 Q5 15 0 13 Q-6 15 -11 13Z',c['cloth'],'none')
  path(t,('M-11 -3 L-11 13 -5 14 M5 14 L11 13 11 -3' if role=='shotgun' and not back else 'M-11 -3 L-11 13 Q-5 15 0 13 Q5 15 11 13 L11 -3'),'none',c['shade'],.8)
  if back or role=='sniper':path(t,'M0 4 L0 13','none',c['shade'],.6)
 if role=='rifle':
  for x in [-9,-6,-3,0,3,6,9]:
   path(t,f'M{x} -28 L{x} -2','none','#737d84',.35)
 if back:
  path(t,'M-7 -29 Q0 -27 7 -29 M0 -25 L0 -3','none',c['shade'],.6)
  return
 if role=='pistol':
  path(t,'M-5 -32 L5 -32 5 0 -5 0Z','#d8cfb8',c['shade'],.55)
  path(t,'M-4 -32 L0 -28 4 -32 2 -25 0 -27 -2 -25Z','#efe8d5','#a3987e',.5)
  path(t,'M0 -31 L0 -27','none',skin,1.4)
  for y in [-21,-17,-13,-9,-5]:path(t,f'M-3 {y} L3 {y}','none','#a3987e',.3)
 elif role=='smg':
  path(t,'M-5 -32 L5 -32 5 0 -5 0Z','#131a20',c['shade'],.55)
  path(t,'M-3 -33 L3 -33 0 -25Z',skin,'none')
  path(t,'M-4 -32 L-1 -26 -4 -24 M4 -32 L1 -26 4 -24','none','#42484a',.65)
  path(t,'M-3 -30 Q0 -23 3 -30','none',base.GOLD[0],.65)
  path(t,'M1 -22 Q3 -15 1 -5','none','#353e44',.6)
 elif role in ['shotgun','rifle']:
  vest='#49372d' if role=='shotgun' else '#454e54'
  path(t,'M-6 -32 L6 -32 6 -3 2 0 0 -2 -2 0 -6 -3Z',vest,c['shade'],.6)
  path(t,'M-4 -33 L4 -33 3 -24 0 -17 -3 -24Z','#efe8d5',c['shade'],.5)
  path(t,'M-4 -33 L0 -29 4 -33 2 -26 0 -28 -2 -26Z','#efe8d5','#b9bdb8',.45)
  tie='#302723' if role=='shotgun' else '#8a949a'
  path(t,'M-1 -29 L1 -29 1.4 -27 .7 -25 1.6 -17 0 -14 -1.6 -17 -.7 -25 -1.4 -27Z',tie,'none')
  if role=='shotgun':
   for y in [-25,-22,-19]:path(t,f'M-.5 {y} L.7 {y+1}','none','#b69a6c',.55)
  else:
   path(t,'M-.5 -25 L.4 -17','none','#c4c9c9',.6)
  for y in [-12,-8,-4]:path(t,f'M0 {y} L0 {y+.5}','none',c['lit'],.9)
 elif role=='sniper':
  path(t,'M-5 -35 L5 -35 5 -25 -5 -25Z','#101619',c['shade'],.5)
  path(t,'M-10 -31 L-7 -37 -4 -34 -3 -27Z M4 -34 L7 -37 10 -31 3 -27Z',c['cloth'],c['shade'],.65)
  path(t,'M1 -26 L1 10','none',c['shade'],.7)
  for y in [-22,-15,-8,-1,6]:path(t,f'M3 {y} L3 {y+.5}','none',c['lit'],.85)
 if role!='sniper':base.lapels(t,c)
 if role=='rifle':
  path(t,'M5 -24 L5 -27 6 -26 7 -28 8 -25 9 -26 9 -23Z','#efe8d5','none')
  path(t,'M5 -23 L9 -23','none',c['shade'],.65)
def forearm(g,a,b,c,skin,hi,r=3.1):
 start=len(g);base.forearm(g,a,b,c,skin,hi,r)
 if c.get('role')=='shotgun':
  for el in list(g)[start:]:
   for k in ['fill','stroke']:
    if el.get(k) in ['#171d22','#161c1f','#151b20','#111820','#101619','#11171b']:el.set(k,'#49372d')
 if c.get('ring') and c.get('watch_arm'):
  a,b=np.array(a,float),np.array(b,float);v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
  p=b+v*.8+n*1.5
  path(g,f'M{xy(p-v*.6)} L{xy(p+v*.6)}','none',base.GOLD[0],1)
def make(role,model,direction,**state):
 base.SPECS=SPECS
 root=base.make(role,model,direction,**state)
 if role=='shotgun':
  for el in root.iter():
   for k in ['fill','stroke']:
    if el.get(k)=='#10181c':el.set(k,'#49372d')
    elif el.get(k)=='#30383b':el.set(k,'#705442')
 if role=='rifle':
  before=rig.lower_signature(root)
  for parent in list(root.iter()):
   for el in list(parent):
    if el.get('fill')!=SPECS[role]['pants']:continue
    d=el.get('d','')
    if base.re.search('[QCAqca]',d):continue
    nums=base.re.findall(r'-?\d+(?:\.\d+)?',d)
    if len(nums)!=12:continue
    ps=np.array(list(map(float,nums))).reshape(6,2)
    a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
    v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
    detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
    for offset in [-1.1,1.1]:
     path(detail,f'M{xy(a+v+n*offset)} L{xy(b-v+n*offset)}','none','#737d84',.35)
    parent.insert(list(parent).index(el)+1,detail)
  clean=copy.deepcopy(root)
  for parent in clean.iter():
   for child in list(parent):
    if child.get('data-garment-detail'):parent.remove(child)
  original=copy.deepcopy(root)
  # The strip leaves the same pre-decoration geometry; boot details do not apply.
  assert rig.lower_signature(clean)==before
 return root
outfits.head=head
outfits.torso=torso
outfits.forearm=forearm
