"""Zangyaku regular outfits on the accepted ordinary body."""
from pathlib import Path
import sys,copy
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE=base.N,base.path,base.xy,base.BASE
np=base.np
KIND=2
TITLE='ZANGYAKU'
PREFIX='zangyaku'
BLUE=('#b59a61',)
DESCRIPTIONS={'pistol':'Black ponytail / silver shades / open gray shirt / tattoos',
'smg':'Blonde spikes / black headband / satin bomber / white tank',
'shotgun':'Crew cut / square shades / tattoo sleeves / red parachute pants',
'rifle':'Parted hair / black sunglasses / white V-neck / gray trousers',
'sniper':'Black beanie / long straight hair / matte raincoat / hood down'}
NOTES={'pistol':['Open collar tattoos / silver watch','Black trousers / leather loafers'],
'smg':['Dark roots / tattooed forearms','Charcoal pants / black-white sneakers'],
'shotgun':['Normal leg proportions / gathered ankles','Black tank / leather boots'],
'rifle':['Tucked V-neck / fitted black gloves','Gray trousers / polished dress shoes'],
'sniper':['Hair past shoulders / charcoal face cloth','Mid-thigh coat / cargo pants / lace-up boots']}
def costume(role,colors,**kw):
 return base.costume(role,colors,'combed',zangyaku=True,role=role,**kw)
SPECS={'pistol':costume('pistol',('#b4b9b6','#d3d7cf','#7b8585'),tattoo=True,watch=True),
'smg':costume('smg',('#1d2529','#455258','#10181c'),tattoo=True),
'shotgun':costume('shotgun',('#171e22','#354047','#0d1519'),tattoo=True,ankle_boots=True),
'rifle':costume('rifle',('#d6d8d0','#eeeee2','#929d9c'),gloves=True),
'sniper':costume('overcoat',('#1b2327','#343f44','#10181c'),gloves=True,ankle_boots=True)}
for role in ['pistol','rifle']:SPECS[role]['sleeve']='short'
SPECS['smg']['sleeve']='short'
SPECS['shotgun']['sleeve']='short'
SPECS['shotgun'].update(pants='#873c3e',pants_hi='#ae5553')
SPECS['rifle'].update(pants='#626b70',pants_hi='#899296')
SPECS['sniper'].update(role='sniper',pants='#343d41',pants_hi='#535f65')
EXTRA_PALETTE=base.EXTRA_PALETTE+['#b4b9b6','#d3d7cf','#7b8585','#d4b768','#f0d58b','#8c793f','#1b2327','#343f44','#873c3e','#ae5553','#626b70','#899296','#b8c3c4','#eeeee2']
def head(g,c,skin,hi,d='SE'):
 if not c.get('zangyaku'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 # Long hair is drawn before the head, continuous to below the shoulder line.
 if role=='sniper':
  path(g,'M-7 -45 Q0 -50 7 -45 L9 -34 10 -22 7 -20 5 -23 3 -22 3 -36 -3 -36 -4 -22 -7 -20 -9 -24 -9 -35Z','#11191d','#0d1519',.65)
 if role=='pistol':
  if back:path(g,'M-2 -42 Q4 -44 4 -39 L5 -28 2 -24 0 -29 1 -38Z','#11191d','#0d1519',.65)
  else:path(g,'M-5 -43 L-9 -41 -11 -33 -9 -27 -6 -30 -7 -36 -4 -39Z','#11191d','#0d1519',.65)
 temp=base.E.Element(N+'g');base.head(temp,dict(c,head='sidepart' if role=='rifle' else 'combed',watch=False),skin,hi,d)
 # Ensure black, rather than brown, parted hair.
 for el in temp.iter():
  for k in ['fill','stroke']:
   if el.get(k)=='#332b27' and role=='rifle':el.set(k,'#1b2225')
   elif el.get(k)=='#5a4637' and role=='rifle':el.set(k,'#42484a')
 g.extend(list(temp))
 if role=='pistol':
  path(g,'M-6 -43 Q0 -48 6 -44 M-5 -46 Q0 -50 5 -47','none','#42484a',.55)
 if role=='smg':
  path(g,'M-7 -43 L-9 -48 -6 -47 -7 -51 -4 -50 -4 -55 -1 -52 1 -57 3 -52 7 -55 6 -50 10 -51 8 -47 9 -44 5 -42 3 -44 0 -43 -3 -44Z','#d4b768','#8c793f',.7)
  path(g,'M-5 -49 L-3 -45 M-2 -51 L0 -45 M2 -52 L1 -46 M6 -51 L4 -45 M7 -47 L5 -44','none','#f0d58b',.9)
  path(g,'M-6 -44 Q0 -48 6 -44','none','#1b2225',1.35)
  path(g,'M-7 -45 Q0 -44 7 -45 L7 -42 Q0 -41 -7 -43Z','#101619','#0d1519',.55)
  path(g,'M-6 -44 Q0 -43 6 -44','none','#343f44',.45)
  if back:
   path(g,'M-2 -44 L2 -44 3 -41 0 -40 -3 -42Z','#101619','#0d1519',.45)
   path(g,'M0 -41 L-2 -37 -3 -38 -2 -42Z M1 -41 L3 -38 4 -39 2 -42Z','#101619','#0d1519',.4)
  if not back:path(g,'M-6 -39 Q-9 -38 -7 -36 Q-5 -36 -6 -39','none','#b8c3c4',.7)
 if role=='shotgun':
  path(g,'M-6 -44 L-6 -48 Q0 -51 6 -48 L7 -43 5 -43 4 -46 -4 -46 -4 -43Z','#11191d','none')
  path(g,'M-6 -43 L-6 -37 -4 -36 -4 -42Z M4 -42 L4 -37 6 -37 6 -43Z','#11191d','none')
 if role in ['pistol','shotgun','rifle'] and not back:
  frame='#b8c3c4' if role=='pistol' else '#101619' if role=='shotgun' else '#101619'
  lens='#182229' if role!='rifle' else skin
  bottom=-40 if role=='pistol' else -38.5
  shape=f'M1 -42 L7 -42 6 {bottom} 2 {bottom}Z' if side else f'M-6 -42 L-1 -42 -1 {bottom} -6 {bottom}Z M1 -42 L6 -42 6 {bottom} 1 {bottom}Z'
  path(g,shape,'#182229',frame,.65 if role=='pistol' else .9)
  path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41 M6 -41 L7 -42','none',frame,.6)
 if role=='sniper':
  for x in [-7,-5,5,7]:path(g,f'M{x} -37 Q{x+.5} -29 {x} -23','none','#343f44',.6)
  path(g,'M-7 -44 L-7 -48 Q-5 -53 1 -52 Q7 -52 8 -47 L8 -43Z','#11191d','#0d1519',.7)
  path(g,'M-7 -46 Q0 -44 8 -46 L8 -43 Q0 -42 -7 -44Z','#303a3f','#10181c',.5)
  for x in [-5,-2,1,4,6]:path(g,f'M{x} -46 L{x} -44','none','#50595f',.45)
  if not back:
   path(g,'M-5 -39 Q0 -37 6 -39 L6 -34 2 -31 -4 -33 -6 -35Z','#343d41','#10181c',.6)
   path(g,'M-4 -35 Q0 -33 4 -35','none','#535f65',.55)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('zangyaku'):return base.torso(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW']
 if role=='sniper':
  base.torso(g,c,skin,hi,d);t=list(g)[0]
  if back:
   path(t,'M-8 -31 Q0 -24 8 -31 L7 -25 Q0 -18 -7 -25Z',c['cloth'],c['shade'],.7)
   path(t,'M-6 -28 Q0 -23 6 -28','none',c['lit'],.6)
  else:path(t,'M-8 -32 L-6 -27 M7 -32 L6 -27','none',c['lit'],.6)
  return
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0]
 if back:return
 if role=='pistol':
  path(t,'M-5 -33 L5 -33 0 -23Z',skin,'none')
  path(t,'M-3 -31 Q2 -32 2 -27 Q-2 -25 -1 -29 M1 -30 L-2 -27','none','#3c4948',.65)
  path(t,'M-5 -33 L-1 -27 -5 -25 -7 -30Z M5 -33 L1 -27 5 -25 7 -30Z',c['lit'],c['shade'],.55)
  path(t,'M0 -23 L0 0','none',c['shade'],.6)
  for y in [-20,-14,-8,-2]:path(t,f'M1 {y} L1 {y+.4}','none',c['lit'],.9)
 elif role=='smg':
  path(t,'M-5 -32 Q0 -27 5 -32 L6 0 -6 0Z','#d6d8d0','#929d9c',.5)
  path(t,'M-4 -30 Q0 -25 4 -30','none','#eeeee2',.75)
  path(t,'M-7 -31 L-5 -24 -6 0 M7 -31 L5 -24 6 0','none',c['lit'],.8)
  path(t,'M-10 -2 L-6 -1 M6 -1 L11 -2','none',c['shade'],1.4)
 elif role in ['shotgun','rifle']:
  shape='M-5 -33 Q0 -26 5 -33 L3 -28 Q0 -25 -3 -28Z' if role=='shotgun' else 'M-5 -33 L0 -25 5 -33Z'
  path(t,shape,skin,'none')
  path(t,('M-5 -32 Q0 -24 5 -32' if role=='shotgun' else 'M-5 -32 L0 -24 5 -32'),'none',c['lit'],.65)
def forearm(g,a,b,c,skin,hi,r=3.1):
 if not c.get('zangyaku'):return base.forearm(g,a,b,c,skin,hi,r)
 start=len(g);base.forearm(g,a,b,c,skin,hi,r)
 if c.get('watch'):
  for el in list(g)[start:]:
   for k in ['fill','stroke']:
    if el.get(k) in base.GOLD:el.set(k,'#b8c3c4' if el.get(k)!=base.GOLD[2] else '#667478')
 if c['role']=='smg':
  a,b=np.array(a,float),np.array(b,float);v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
  p=a+v*2
  path(g,f'M{xy(p+n*3)} L{xy(p-n*3)}','none',c['lit'],1.4)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('zangyaku'):return base.arm(g,a,b,h,c,skin,hi)
 if c['role']=='shotgun':
  # Exposed shoulder and full tattoo sleeve retain the connected arm geometry.
  return rig.connected_arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade='#3c4948',sleeve='short'),skin,hi)
 if c['sleeve']=='short':
  far=a[0]>(40 if a[1]>0 else 0)
  return base.shared.arm(g,a,b,h,dict(c,eastex=True,watch_arm=far),skin,hi)
 return base.arm(g,a,b,h,c,skin,hi)
def make(role,model,direction,**state):
 base.SPECS=SPECS
 root=base.make(role,model,direction,**state)
 # Decorations follow limb-local coordinates, never resize the legs.
 c=SPECS[role]
 if role in ['shotgun','sniper','smg']:
  for parent in list(root.iter()):
   for el in list(parent):
    if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
    nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
    if len(nums)!=12:continue
    ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
    radius=np.linalg.norm(ps[2]-ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
    detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
    if role=='shotgun':
     for t in [.25,.65,.85]:
      p=a+(b-a)*t;path(detail,f'M{xy(p-n*1.7)} L{xy(p+v+n*1.4)}','none',c['pants_hi'],.6)
     if radius<3.5:
      p=b-v*4;path(detail,f'M{xy(p-n*2.4)} L{xy(p+n*2.4)}','none','#59292f',1.1)
    elif role=='sniper' and radius>=3.5:
     p=(a+b)/2;path(detail,f'M{xy(p-n*2-v*2)} L{xy(p+n*2-v*2)} L{xy(p+n*2+v*3)} L{xy(p-n*2+v*3)}Z',c['pants'],c['pants_hi'],.55)
    elif role=='smg' and radius<3.5:
     p=b+v*2;path(detail,f'M{xy(p-n*2.5)} L{xy(p+n*2.5)}','none','#d6d8d0',1)
    parent.insert(list(parent).index(el)+1,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
