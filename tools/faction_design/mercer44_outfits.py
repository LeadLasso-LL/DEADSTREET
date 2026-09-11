"""Mercer 44s regular wardrobe; accepted Mercer/Eastex proportions."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=0
TITLE="MERCER 44'S"
PREFIX='mercer44'
PURPLE=('#65457c','#89639d','#392946')
BLUE=(PURPLE[1],)
BLACK=('#202527','#353b3d','#111819')
WHITE=base.shared.WHITE
DESCRIPTIONS={'pistol':'Purple durag / white ribbed tank / tattoo sleeves / gold chain',
'smg':'White ski mask / black jersey + purple trim / white M44 chest',
'shotgun':'Black ski mask / open charcoal hoodie / muted purple tee',
'rifle':'Backward black cap + twists / purple bandana / black M44 tee',
'sniper':'Black hood / charcoal ski mask / purple M44 sleeve emblem'}
NOTES={'pistol':['Faded black jeans / white sneakers','Thin gold chain / normal proportions'],
'smg':['Gray straight-leg jeans','Black-and-white basketball sneakers'],
'shotgun':['Woodland camouflage pants','Wheat work boots / hood down'],
'rifle':['Black cargo pants / black sneakers','Small white M44 chest emblem'],
'sniper':['Dark gray cargo pants / black boots','Black gloves / small purple sleeve emblem']}
def spec(r,col,h,**kw):
 return base.costume(r,col,h,eastex=True,m44=True,role=r,**kw)
SPECS={'pistol':spec('pistol',WHITE,'durag',tattoo=True),
'smg':spec('smg',BLACK,'white_mask'),
'shotgun':spec('shotgun',('#303539','#50575b','#1b2327'),'mask',camo=True,boots=True),
'rifle':spec('rifle',BLACK,'backward_cap'),
'sniper':spec('sniper',BLACK,'hood_white_mask',boots=True,gloves=True)}
for r in ['pistol','smg','rifle']:SPECS[r]['sleeve']='short'
SPECS['pistol'].update(pants='#303538',pants_hi='#50575b',shoe=WHITE[0],shoe_hi=WHITE[1])
SPECS['smg'].update(pants='#626a6e',pants_hi='#879094',shoe='#202527',shoe_hi=WHITE[0])
SPECS['shotgun'].update(pants='#485240',pants_hi='#66705a',shoe='#ad7e43',shoe_hi='#cba065')
SPECS['sniper'].update(pants='#3b4246',pants_hi='#5a646a')
EXTRA_PALETTE=base.EXTRA_PALETTE+list(PURPLE)+list(WHITE)+['#303539','#50575b','#1b2327']
def emblem(g,x,y,color,scale=1):
 t=base.E.SubElement(g,N+'g',{'transform':f'translate({x} {y}) scale({scale})'})
 path(t,'M-3 1 L-3 -3 -1 -1 1 -3 1 1','none',color,.7)
 path(t,'M2 -2 L1 0 3 0 M3 -2 L3 2 M5 -2 L4 0 6 0 M6 -2 L6 2','none',color,.6)
def head(g,c,skin,hi,d='SE'):
 if not c.get('m44'):return base.head(g,c,skin,hi,d)
 old=base.shared.BLUE;base.shared.BLUE=PURPLE
 temp=base.E.Element(N+'g')
 try:base.shared.head(temp,c,skin,hi,d)
 finally:base.shared.BLUE=old
 if c['role']=='sniper':
  for e in temp.iter():
   for a in ['fill','stroke']:
    if e.get(a)==WHITE[0]:e.set(a,'#353b3d')
    elif e.get(a)==WHITE[2]:e.set(a,'#555e62')
 g.extend(list(temp))
 if c['role']=='rifle':
  for x in [-6,-4,5,7]:
   path(g,f'M{x} -45 L{x+.4} -42 {x-.2} -40','none','#111819',1.1)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('m44'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 if r=='pistol':
  path(t,'M-4 -32 Q0 -25 4 -32','none',WHITE[2],.7)
  for x in [-7,-3,1,5,9]:path(t,f'M{x} -22 L{x} -3','none',WHITE[2],.3)
  if not back:path(t,'M-5 -32 Q0 -20 5 -32','none',base.GOLD[0],.75)
 elif r=='smg':
  path(t,'M-8 -31 L-5 -31 Q0 -25 5 -31 L8 -31 8 -4 -8 -4Z',BLACK[0],BLACK[2],.5)
  path(t,'M-5 -31 Q0 -25 5 -31 M-8 -30 L-8 -8 M8 -30 L8 -8','none',PURPLE[0],1.3)
  path(t,'M-8 -4 L8 -4','none',PURPLE[0],1)
  if not back:emblem(t,-2,-20,WHITE[0],.8)
 elif r=='shotgun':
  if not back:
   path(t,'M-4 -32 Q0 -29 4 -32 L4 -1 -4 -1Z',PURPLE[0],c['shade'],.5)
   path(t,'M-4 -30 Q0 -27 4 -30','none',PURPLE[2],.6)
   path(t,'M-5 -29 L-5 -1 M5 -29 L5 -1','none','#88908c',.5)
   path(t,'M-9 -30 L-5 -35 -3 -32 -5 -26Z M5 -35 L9 -30 5 -26 3 -32Z',c['lit'],c['shade'],.6)
  else:
   path(t,'M-8 -32 Q0 -26 8 -32 L6 -24 Q0 -21 -6 -24Z',c['cloth'],c['shade'],.7)
  path(t,'M-10 -2 L10 -2','none',c['shade'],1.3)
 elif r=='rifle' and not back:emblem(t,3,-24,WHITE[0],.65)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if c.get('m44') and c.get('gloves'):
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);p=b-v*3
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',BLACK[0],BLACK[2],.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('m44'):return base.arm(g,a,b,h,c,skin,hi)
 r=c['role'];cc=c
 if r=='pistol':cc=dict(c,cloth=skin,lit=hi,shade=skin)
 if r=='smg':cc=dict(c,top='jersey')
 base.shared.arm(g,a,b,h,cc,skin,hi)
 if r=='pistol':
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
  for f in [.16,.28,.4]:
   p=a+(b-a)*f;path(g,f'M{xy(p-n*1.4)} Q{xy(p+v*1.3)} {xy(p+n*1.5)}','none','#343b39',.55)
 if r=='sniper':
  p=np.array(a)+(np.array(b)-np.array(a))*.4;emblem(g,p[0]-1,p[1],PURPLE[1],.55)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 if c.get('camo') or c.get('boots'):base.shared.decorate_lower(root,c)
 if role in ['rifle','sniper']:
  for parent in list(root.iter()):
   for el in list(parent):
    if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
    nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
    if len(nums)!=12:continue
    ps=np.array(list(map(float,nums))).reshape(6,2)
    if np.linalg.norm(ps[2]-ps[3])/2<3.5:continue
    a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);p=a+(b-a)*.55
    q=base.E.Element(N+'g',{'data-garment-detail':'true'})
    path(q,f'M{xy(p-n*2)} L{xy(p+n*2)} L{xy(p+v*5+n*2)} L{xy(p+v*5-n*2)}Z',c['pants'],BLACK[2],.55)
    path(q,f'M{xy(p+v-n*2)} L{xy(p+v+n*2)}','none',c['pants_hi'],.55)
    parent.insert(list(parent).index(el)+2,q)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
