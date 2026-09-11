"""Majmu'at al-Saffar regular wardrobe on the accepted normal unit rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=2
TITLE="MAJMU'AT AL-SAFFAR"
PREFIX='saffar'
BLUE=('#788b74',)
TAN=('#b7a27d','#d4c19a','#807053')
DESCRIPTIONS={
'pistol':'Black aviators + trimmed beard / rolled cream linen / gold watch',
'smg':'Curly hair / burgundy striped track jacket / patterned neck scarf',
'shotgun':'Bald + graying beard / brown leather vest / rolled slate shirt',
'rifle':'Black wraparound shades / olive field jacket / compact brown rig',
'sniper':'Tan-black head wrap / brown field jacket / olive underlayer'}
NOTES={
'pistol':['Swept-back black hair / open collar','Dark brown trousers / brown loafers'],
'smg':['High black shoulder bag / black undershirt','Charcoal cargo pants / black-white runners'],
'shotgun':['Olive work trousers / brown lace-up boots','Weathered tan shell-loop belt'],
'rifle':['Sand shirt / charcoal utility trousers','Tan combat boots / fitted black gloves'],
'sniper':['Hood down / short scarf tail','Reinforced brown cargo pants / olive gloves']}
def costume(role,colors,head='combed',**kw):
 return base.costume(role,colors,head,saffar=True,role=role,**kw)
SPECS={
'pistol':costume('pistol',('#c8c0a9','#e4dcc5','#97907a'),watch=True,loafers=True),
'smg':costume('smg',('#67333d','#91525b','#40232c')),
'shotgun':costume('shotgun',('#47362c','#705541','#2b241f'),ankle_boots=True),
'rifle':costume('rifle',('#48543d','#6d7959','#2c382b'),gloves=True,ankle_boots=True),
'sniper':costume('sniper',('#69533e','#8d7454','#433a2e'),gloves=True,ankle_boots=True)}
SPECS['pistol']['sleeve']='short'
SPECS['shotgun']['sleeve']='short'
for role,p,ph,s,sh in [
('pistol','#43362c','#6a5742','#51392b','#7e5d41'),
('smg','#343c3e','#586164','#20282b','#d2d4c7'),
('shotgun','#4e573e','#73805a','#51412e','#7d6748'),
('rifle','#2c3438','#4e5a5f','#a58f67','#c6b28a'),
('sniper','#4b3d30','#726049','#62503a','#8b7452')]:
 SPECS[role].update(pants=p,pants_hi=ph,shoe=s,shoe_hi=sh)
EXTRA_PALETTE=base.EXTRA_PALETTE+list(TAN)+['#c8c0a9','#e4dcc5','#97907a','#67333d','#91525b','#40232c','#48543d','#6d7959','#69533e','#8d7454','#516774','#758a92','#4e573e','#73805a','#a58f67','#c6b28a']
def beard(g,side=False,gray=False,stubble=False):
 fill='#42463d' if stubble else '#20282a'
 shape='M-5 -39 L-3 -37 -1 -38 2 -37 5 -39 5 -35 2 -32 -2 -33 -5 -35Z'
 if side:shape='M1 -39 L3 -37 6 -38 7 -35 4 -32 1 -33 -1 -35Z'
 path(g,shape,fill,'none')
 path(g,'M-1 -36 L2 -36','none','#84785f',.5)
 if gray:
  path(g,'M-3 -34 L-1 -32 2 -32 4 -34','none','#858b80',1)
  path(g,'M-1 -33 L1 -32','none','#b1b5a5',.65)
def head(g,c,skin,hi,d='SE'):
 if not c.get('saffar'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 if role in ['shotgun','sniper']:
  path(g,'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z',skin,w=1.15)
  if not back:
   path(g,'M-3 -41 L-1 -41 M2 -41 L4 -41 M1 -39 L2 -37','none','#43392d',.6)
 else:base.head(g,c,skin,hi,d)
 if role=='smg':
  path(g,'M-6 -44 L-5 -46 5 -46 6 -43 5 -40 4 -42 4 -44 -4 -44 -4 -40 -6 -41Z','#42483f','none')
  path(g,'M-6 -46 Q-8 -49 -5 -49 Q-5 -52 -2 -50 Q0 -53 2 -50 Q5 -52 6 -48 Q9 -47 6 -44 L3 -45 0 -44 -3 -45Z','#192226','#11191c',.5)
  path(g,'M-4 -49 q2 -1 2 1 M1 -49 q2 -1 2 1 M4 -47 l1 1','none','#42494a',.6)
 if role!='sniper' and not back:beard(g,side,gray=role=='shotgun',stubble=role=='smg')
 if role in ['pistol','rifle'] and not back:
  lens=('M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z' if role=='pistol' else 'M-7 -42 Q0 -43 7 -42 L6 -38 2 -38 0 -40 -2 -38 -6 -38Z')
  if side:lens='M1 -42 L7 -42 6 -38 2 -38Z'
  path(g,lens,'#10191d','#080f12',.7)
  path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41','none','#080f12',.65)
 if role=='sniper':
  path(g,'M-7 -43 L-8 -47 Q-4 -52 2 -51 Q7 -50 8 -45 L7 -41 5 -42 4 -44 -4 -44 -5 -41Z',TAN[0],TAN[2],.65)
  if back:path(g,'M-7 -45 Q0 -47 7 -45 L7 -34 2 -32 -5 -34Z',TAN[0],TAN[2],.6)
  else:
   path(g,'M-6 -40 Q0 -38 6 -40 L7 -34 3 -31 -4 -32 -7 -35Z',TAN[0],TAN[2],.6)
   path(g,'M-4 -43 L-1 -42.7 M2 -42.7 L4 -43','none','#172125',.7)
  for y in [-48,-46]:
   path(g,f'M-5 {y} L5 {y+.7}','none','#33372c',.55)
  for x in [-5,-2,1,4]:
   path(g,f'M{x} -49 l1 5','none','#33372c',.45)
  for x,y in [(-4,-36),(0,-35),(4,-36)]:
   path(g,f'M{x-1} {y} l1 -1 1 1 -1 1Z','none','#33372c',.6)
  path(g,'M-5 -33 L-7 -35 M3 -33 L5 -35','none',TAN[1],.6)
def neck_scarf(t,back):
 path(t,'M-7 -33 Q0 -28 7 -33 L7 -28 3 -25 -3 -26 -8 -29Z',TAN[0],TAN[2],.6)
 for x in [-5,-2,1,4]:
  path(t,f'M{x} -30 l1 -1 1 1 -1 1Z','none','#33372c',.6)
 path(t,'M-6 -28 L4 -27','none','#33372c',.55)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('saffar'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];role=c['role'];back=d in ['N','NE','NW']
 if role=='sniper' and back:
  path(t,'M-7 -31 Q0 -27 7 -31 L5 -23 Q0 -20 -5 -23Z',c['shade'],c['lit'],.55)
 if not back:
  if role=='pistol':
   path(t,'M-4 -32 L0 -28 4 -32 2 -24 0 -27 -2 -24Z',c['lit'],c['shade'],.6)
   path(t,'M-2 -31 L2 -31 0 -26Z',skin,'none')
   path(t,'M0 -25 L0 -1','none',c['shade'],.6)
   for y in [-21,-14,-7]:path(t,f'M1 {y} L1 {y+.5}','none','#777766',.7)
  elif role in ['smg','shotgun','rifle','sniper']:
   inner={'smg':'#1e272b','shotgun':'#516774','rifle':'#b7a681','sniper':'#5a6649'}[role]
   path(t,'M-5 -32 L5 -32 5 0 -5 0Z',inner,c['shade'],.45)
   if role=='shotgun':
    path(t,'M-4 -32 Q0 -29 4 -32 M0 -29 L0 -22','none','#758a92',.6)
   elif role=='rifle':
    path(t,'M-4 -32 L0 -28 4 -32','none','#dac6a0',.7)
   else:path(t,'M-4 -31 Q0 -27 4 -31','none','#75806d' if role=='sniper' else '#46534f',.65)
   path(t,'M-6 -28 L-6 -2 M6 -28 L6 -2','none',c['lit'],.7)
   if role in ['rifle','sniper']:
    path(t,'M-7 -32 L-4 -34 -2 -29 -5 -25Z M4 -34 L8 -31 5 -25 2 -29Z',c['lit'],c['shade'],.6)
 if role=='smg':
  # High rib-side bag and shoulder strap, narrow enough to keep the silhouette.
  path(t,'M-7 -31 L8 -8','none','#151f23',1.7)
  if not back:
   path(t,'M5 -20 L11 -21 11 -9 5 -8Z','#202a2d','#0e171b',.65)
   path(t,'M6 -17 L10 -18','none','#58635d',.55)
  neck_scarf(t,back)
 if role=='shotgun':
  path(t,'M-11 -1 L11 -1','none','#a18a62',2.2)
  if not back:
   for x in [-7,-4,3,6]:
    path(t,f'M{x} -3 L{x} 1','none','#70543c',1.4)
    path(t,f'M{x} -3 L{x} -2.5','none','#c1aa72',1.4)
 if role=='rifle':
  path(t,'M-7 -31 L-5 -31 -4 -14 -7 -14Z M5 -31 L7 -31 7 -14 4 -14Z','#4e3c2c','#2d2a21',.5)
  if back:path(t,'M-6 -13 L6 -13','none','#4e3c2c',2)
  else:
   path(t,'M-8 -21 L8 -21 8 -8 -8 -8Z','#5f4b34','#342d23',.6)
   for x in [-5,0,5]:
    path(t,f'M{x-2} -19 L{x+2} -19 {x+2} -8 {x-2} -8Z','#705a3f','#352e24',.5)
    path(t,f'M{x-1} -16 L{x+1} -16','none','#9c8560',.6)
 if role=='sniper':
  # One short patterned scarf end rests over the left shoulder.
  path(t,'M-7 -33 L-3 -32 -4 -24 -5 -20 -8 -22Z',TAN[0],TAN[2],.5)
  for y in [-29,-26,-23]:path(t,f'M-7 {y} L-4 {y+.8}','none','#33372c',.55)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('saffar'):return base.arm(g,a,b,h,c,skin,hi)
 temp=c
 if c['role']=='shotgun':temp=dict(c,cloth='#516774',lit='#758a92',shade='#334a53',sleeve='short')
 base.arm(g,a,b,h,temp,skin,hi)
 if c['role']=='smg':
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
  path(g,f'M{xy(a+v*2+n)} L{xy(b-v+n)}','none','#d0c4a5',.65)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('saffar'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='shotgun':
  end=a+(b-a)*.35
  base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long',cloth='#516774',lit='#758a92',shade='#334a53'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none','#758a92',1.2)
 elif c['role']=='smg':path(g,f'M{xy(a+v+n)} L{xy(b-v*3+n)}','none','#d0c4a5',.6)
 elif c['role']=='pistol':path(g,f'M{xy(a-n*2.5)} L{xy(a+n*2.5)}','none',c['shade'],1.1)
 if c.get('gloves'):
  p=b-v*3;fill='#4b593d' if c['role']=='sniper' else '#131c20'
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',fill,'#10181c',.5)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 if role=='pistol':return root
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role in ['smg','rifle','sniper'] and radius>=3.5:
    p=a+(b-a)*.5
    path(detail,f'M{xy(p-n*2)} L{xy(p+n*2)} L{xy(p+n*2+v*4)} L{xy(p-n*2+v*4)}Z',c['pants'],c['pants_hi'],.5)
   if radius<3.5 and role in ['shotgun','rifle','sniper']:
    for step in [1.5,3,4.5]:
     p=b-v*step;path(detail,f'M{xy(p-n*1.2)} L{xy(p+v*.5+n*1.2)}','none',c['shoe_hi'],.55)
    if role=='sniper':
     p=a+v*1.5
     path(detail,f'M{xy(p-n*2.3)} L{xy(p+n*2.3)} L{xy(p+n*2+v*4)} L{xy(p-n*2+v*4)}Z','#594a35',c['pants_hi'],.5)
   if len(detail):parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
