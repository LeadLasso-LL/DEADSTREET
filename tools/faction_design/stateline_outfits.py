"""Stateline Raiders MC regular outfit review on the accepted normal rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=2
TITLE='STATELINE RAIDERS MC'
PREFIX='stateline'
BLUE=('#9d8b68',)
BLACK=('#242a2c','#454d50','#12191c')
DENIM=('#526773','#788a92','#35454f')
OLIVE=('#404a36','#637054','#293222')
SILVER='#a4aaa4'
DESCRIPTIONS={'pistol':'Backward trucker cap / horseshoe mustache / leather vest / white tee',
'smg':'Blond hair + black headband / denim vest / tattoo sleeves',
'shotgun':'Bald / long red-brown beard / black leather jacket / harness boots',
'rifle':'Sideburns + beard / leather vest / rolled red-black plaid sleeves',
'sniper':'Beanie / long gray hair / face bandana / denim vest + olive hoodie'}
NOTES={'pistol':['Black aviators / tattooed forearms','Blue jeans / wallet chain / brown boots'],
'smg':['Charcoal tank / black jeans','Silver rings and bracelet / black boots'],
'shotgun':['Black wraparound shades / gray tee','Normal anatomy / fingerless gloves'],
'rifle':['Charcoal work pants / magazine belt','Black lace-up work boots'],
'sniper':['Hood down / charcoal jeans','Dark brown lace-up boots / black gloves']}
def costume(role,colors,**kw):
 return base.costume(role,colors,'combed',stateline=True,role=role,ankle_boots=True,**kw)
SPECS={'pistol':costume('pistol',BLACK,tattoo=True),
'smg':costume('smg',DENIM,tattoo=True),
'shotgun':costume('shotgun',BLACK),
'rifle':costume('rifle',BLACK),
'sniper':costume('sniper',('#2e3335','#50595b','#171e22'),gloves=True)}
SPECS['pistol'].update(sleeve='short',pants='#435b6e',pants_hi='#708494',shoe='#574132',shoe_hi='#7b614b')
SPECS['smg'].update(sleeve='short')
SPECS['shotgun'].update(pants='#304553',pants_hi='#516878')
SPECS['rifle'].update(pants='#3a4146',pants_hi='#59656b')
SPECS['sniper'].update(pants='#373d40',pants_hi='#576166',shoe='#45362d',shoe_hi='#685443')
EXTRA_PALETTE=base.EXTRA_PALETTE+list(DENIM)+list(OLIVE)+[SILVER,'#d0c4a4','#75624b','#aa9471','#78513b','#a27651','#d1d0c5','#73504d','#242326','#435b6e','#708494','#304553','#516878']
def head(g,c,skin,hi,d='SE'):
 if not c.get('stateline'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 hair={'pistol':'#493b2f','smg':'#75624b','shotgun':'#78513b','rifle':'#332b27','sniper':'#777e7b'}[role]
 light={'pistol':'#75604a','smg':'#aa9471','shotgun':'#a27651','rifle':'#55463a','sniper':'#abb0a8'}[role]
 if role in ['smg','sniper']:
  path(g,'M-6 -45 Q0 -51 6 -45 L9 -36 9 -26 6 -24 4 -28 -4 -28 -6 -24 -9 -27 -8 -37Z',hair,'#151c20',.65)
 base.head(g,dict(c,head='receding' if role=='shotgun' else 'combed'),skin,hi,d)
 # Recolor base hair without affecting the skin or costume.
 for el in g:
  for attr in ['fill','stroke']:
   if el.get(attr) in ['#1b2225','#332b27']:el.set(attr,hair)
   elif el.get(attr) in ['#42484a','#5a4637']:el.set(attr,light)
 if role=='shotgun':
  path(g,'M-6 -43 L-6 -46 Q-5 -50 0 -50 Q5 -50 6 -46 L6 -41 4 -42 4 -45 Q0 -47 -4 -45 L-4 -41Z',skin,'none')
  if back:path(g,'M-6 -44 Q0 -49 6 -44 L6 -38 3 -35 -3 -35 -6 -38Z',skin,'none')
  path(g,'M-4 -47 Q0 -49 3 -47','none',hi,.7)
 if role in ['smg','sniper']:
  for x in [-6,6]:
   path(g,f'M{x} -42 Q{x*1.25} -34 {x*1.15} -27','none',light,.8)
  if back:
   path(g,'M-6 -46 Q0 -49 6 -46 L7 -28 3 -25 0 -27 -4 -25 -7 -28Z',hair,'#151c20',.5)
   for x in [-4,0,4]:path(g,f'M{x} -44 Q{x+1} -35 {x} -28','none',light,.65)
 if role=='pistol':
  path(g,'M-7 -44 L-8 -39 -6 -40 -7 -35 -4 -37 -4 -42Z M6 -44 L8 -40 6 -40 8 -35 4 -37 4 -43Z',hair,'none')
  path(g,'M-7 -45 Q-7 -52 0 -52 Q7 -52 8 -45 L7 -43 -7 -43Z','#252c2f','#12191c',.7)
  path(g,'M-5 -48 L-5 -45 M-2 -50 L-2 -46 M1 -50 L1 -46 M4 -49 L4 -45','none','#485052',.45)
  if back:path(g,'M-7 -44 Q0 -43 7 -44 L10 -41 Q2 -40 -7 -42Z','#252c2f','#12191c',.6)
  else:
   path(g,'M-3 -45 Q0 -48 3 -45 L3 -43 -3 -43Z',hair,'#12191c',.5)
   if side:path(g,'M-7 -45 L-12 -43 -11 -41 -6 -42Z','#252c2f','#12191c',.5)
 if role=='smg':
  path(g,'M-7 -44 Q0 -46 7 -44 L7 -41 Q0 -43 -7 -41Z','#141b1e','#101619',.55)
  if back:path(g,'M-1 -42 L2 -42 5 -37 2 -38 1 -40 -1 -37 -3 -38Z','#141b1e','none')
 if role=='sniper':
  path(g,'M-7 -44 L-7 -48 Q-6 -53 0 -53 Q7 -53 8 -48 L8 -43Z','#343b3e','#151c20',.7)
  path(g,'M-7 -46 Q0 -45 8 -46 L8 -43 Q0 -42 -7 -43Z','#434b4d','#20282c',.5)
  for x in [-5,-2,1,4,6]:path(g,f'M{x} -45 L{x} -43','none','#666e6e',.4)
 if not back:
  if role=='pistol':
   path(g,'M-4 -37 Q0 -40 4 -37 L4 -32 2 -32 2 -36 -2 -36 -2 -32 -4 -32Z',hair,'none')
  elif role=='shotgun':
   path(g,'M-6 -38 L-4 -36 -2 -38 0 -37 2 -38 5 -36 6 -38 6 -32 4 -26 1 -23 -3 -26 -5 -31Z',hair,'#493627',.5)
   path(g,'M-3 -33 L-2 -27 M0 -34 L1 -26 M3 -32 L3 -28','none',light,.65)
  elif role=='rifle':
   path(g,'M-6 -42 L-4 -41 -4 -36 -1 -34 2 -34 5 -36 5 -41 7 -41 6 -34 3 -31 -2 -32 -6 -35Z',hair,'none')
  if role in ['pistol','shotgun']:
   if role=='pistol':
    shape='M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z'
   else:shape='M-7 -42 Q0 -43 7 -42 L6 -38 2 -38 0 -40 -2 -38 -6 -38Z'
   if side:shape='M1 -42 L7 -42 7 -39 3 -38 1 -39Z'
   path(g,shape,'#10171a','#080f12',.7)
   path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41','none','#080f12',.7)
  if role=='sniper':
   path(g,'M-6 -39 Q0 -37 6 -39 L6 -34 1 -30 -5 -33Z','#171f23','#101619',.55)
   path(g,'M-4 -35 L1 -33 4 -35','none','#394247',.6)
def patch(t):
 # Compact bison skull with swept horns and visibly broken chain beneath.
 path(t,'M-8 -25 Q0 -29 8 -25 L8 -9 Q0 -5 -8 -9Z','#171e21','#75624b',.7)
 path(t,'M-3 -21 Q-8 -20 -7 -25 Q-10 -21 -7 -18 L-3 -18 M3 -21 Q8 -20 7 -25 Q10 -21 7 -18 L3 -18','#d0c4a4','#75624b',.5)
 path(t,'M-4 -21 Q0 -24 4 -21 L3 -16 1 -12 -1 -12 -3 -16Z','#d0c4a4','#75624b',.5)
 path(t,'M-3 -20 L-1 -19 -2 -17Z M1 -19 L3 -20 2 -17Z M0 -16 L-1 -13 1 -13Z','#171e21','none')
 for x in [-5,-2,3,6]:
  path(t,f'M{x-1} -11 Q{x} -13 {x+1} -11 Q{x} -9 {x-1} -11Z','none','#a4aaa4',.55)
 path(t,'M-1 -11 L0 -10 M1 -12 L2 -13','none','#d0c4a4',.6)
 path(t,'M-5 -25 Q0 -27 5 -25 M-4 -8 L4 -8','none','#a4aaa4',.65)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('stateline'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0]
 role=c['role'];back=d in ['N','NE','NW']
 if back:
  patch(t)
  if role=='sniper':path(t,'M-6 -33 Q0 -29 6 -33 L5 -27 Q0 -23 -5 -27Z',OLIVE[0],OLIVE[2],.65)
  return
 fill={'pistol':'#d1d0c5','smg':'#333a3e','shotgun':'#777f7e','rifle':'#73504d','sniper':OLIVE[0]}[role]
 path(t,'M-5 -32 Q0 -28 5 -32 L5 0 -5 0Z',fill,'#182024',.5)
 path(t,'M-4 -30 Q0 -26 4 -30','none','#a4aaa4' if role in ['pistol','shotgun'] else '#242326',.7)
 if role=='rifle':
  for y in [-25,-18,-11,-4]:path(t,f'M-4 {y} L4 {y}','none','#242326',1.6)
  for x in [-2,2]:path(t,f'M{x} -27 L{x} -1','none','#242326',1.2)
 if role=='shotgun':
  base.lapels(t,c)
 else:
  path(t,'M-7 -31 L-5 -26 -5 -2 M7 -31 L5 -26 5 -2','none',c['lit'],.7)
  path(t,'M-8 -31 L-6 -34 -3 -29 -5 -24Z M6 -34 L8 -31 5 -24 3 -29Z',c['cloth'],c['shade'],.5)
 if role=='sniper':
  path(t,'M-7 -33 Q-4 -36 -3 -30 M7 -33 Q4 -36 3 -30','none',OLIVE[1],1.6)
  path(t,'M-3 -28 L-3 -20 M3 -28 L3 -20','none',OLIVE[1],.6)
 for x in [-8,8]:
  path(t,f'M{x-2.2} -23 L{x+2.2} -23 {x+2.2} -20 {x-2.2} -20Z','#171e21','#75624b',.45)
  path(t,f'M{x-1.3} -21.5 L{x+.7} -21.5','none','#a4aaa4',.55)
  path(t,f'M{x-1.6} -14 L{x+1.6} -14','none',c['lit'],.65)
 if role=='pistol':path(t,'M9 -2 Q14 7 7 10','none',SILVER,.75)
 if role=='rifle':
  path(t,'M-10 -1 L11 -1','none','#10181c',2)
  for x in [-7,7]:path(t,f'M{x-1.8} -5 L{x+1.8} -5 {x+1.8} 2 {x-1.8} 2Z','#20282c','#101619',.5)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('stateline'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 role=c['role']
 if role=='smg':
  p=b-v*2.5
  path(g,f'M{xy(p-n*2)} L{xy(p+n*2)}','none',SILVER,1.2)
  for k in [-.8,.8]:
   p=b-v*.5+n*k
   path(g,f'M{xy(p-v*.6)} L{xy(p+v*.6)}','none',SILVER,.65)
 if role=='shotgun' or c.get('gloves'):
  p=b-v*3
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z','#141c20','#090f12',.5)
  if role=='shotgun':path(g,f'M{xy(b-n*1.2)} L{xy(b+n*1.2)}','none',skin,1)
 if role=='rifle':
  p=a+v*1.4
  path(g,f'M{xy(p-n*2.8)} L{xy(p+n*2.8)}','none','#73504d',2.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('stateline'):return base.arm(g,a,b,h,c,skin,hi)
 role=c['role']
 if role=='pistol':
  return base.shared.arm(g,a,b,h,dict(c,eastex=True,cloth='#d1d0c5',lit='#eeeee2',shade='#929c9b'),skin,hi)
 if role in ['smg','rifle']:
  if role=='smg':
   base.shared.arm(g,a,b,h,dict(c,eastex=True,cloth=skin,lit=hi,shade='#8a6852'),skin,hi)
  else:
   rig.connected_arm(g,a,b,h,dict(c,sleeve='short',cloth='#73504d',lit='#96706a',shade='#242326'),skin,hi)
  a,b=np.array(a,float),np.array(b,float)
  v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
  if role=='smg':
   for f in [.16,.32,.48]:
    q=a+(b-a)*f
    path(g,f'M{xy(q+n*1.4-v*.7)} Q{xy(q-n*.4)} {xy(q+n*.8+v*.9)} Q{xy(q-n*1.2+v*.7)} {xy(q-n*1.4-v*.4)}','none','#3c4948',.65)
  else:
   for f in [.25,.5,.75]:
    q=a+(b-a)*f
    path(g,f'M{xy(q-n*2.3)} L{xy(q+n*2.3)}','none','#242326',1.1)
   path(g,f'M{xy(a+v*2+n*.8)} L{xy(b-v*1.5+n*.8)}','none','#242326',.85)
  return
 if role=='sniper':
  return rig.connected_arm(g,a,b,h,dict(c,cloth=OLIVE[0],lit=OLIVE[1],shade=OLIVE[2]),skin,hi)
 return base.arm(g,a,b,h,c,skin,hi)
def make(role,model,direction,**state):
 base.SPECS=SPECS
 root=base.make(role,model,direction,**state)
 c=SPECS[role]
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2)
   a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   if np.linalg.norm(ps[2]-ps[3])/2>=3.5:continue
   v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role in ['rifle','sniper']:
    for step in [1.5,3,4.5]:
     p=b-v*step
     path(detail,f'M{xy(p-n*1.2)} L{xy(p+v*.5+n*1.2)}','none',c['shoe_hi'],.6)
   else:
    p=b-v*3
    path(detail,f'M{xy(p-n*2.3)} L{xy(p+n*2.3)}','none',c['shoe_hi'],.8)
    if role=='shotgun':path(detail,f'M{xy(p-n*1.5-v*.8)} L{xy(p-n*.3-v*.8)} L{xy(p-n*.3+v*.8)} L{xy(p-n*1.5+v*.8)}Z','none',SILVER,.55)
   parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
