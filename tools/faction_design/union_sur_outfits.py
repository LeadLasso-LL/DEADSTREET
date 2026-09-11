"""Union del Sur regular wardrobe on the accepted unit rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import sierra_roja_outfits as ref
base=ref.base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=2
TITLE='UNION DEL SUR'
PREFIX='union_sur'
BLUE=('#a0644d',)
CAMO=['#786b4e','#344334','#292f29','#65704c']
DESCRIPTIONS={
'pistol':'Black aviators / terracotta open shirt + white tank / gold jewelry',
'smg':'Backward cap + black ski mask / cream sleeveless tee / chest bag',
'shotgun':'Thick beard / tan canvas vest + black henley / shell loops',
'rifle':'Olive ski mask / rolled woodland shirt / light black chest rig',
'sniper':'Olive forward cap + black ski mask / brown-olive camo + sparse strips'}
NOTES={
'pistol':['Charcoal jeans / brown leather ankle boots','Brushed-back hair / thin mustache'],
'smg':['Tattooed arms / olive cargo pants','Black high-top sneakers'],
'shotgun':['Tattooed forearms / faded blue jeans','Brown square-toe work boots'],
'rifle':['Black cargo pants / tan combat boots','Black gloves / thin gold chain'],
'sniper':['Dark brown utility pants / tan hunting boots','Olive gloves / raised collar']}
def costume(role,colors,**kw):
 return base.costume(role,colors,'combed',union=True,role=role,**kw)
SPECS={
'pistol':costume('pistol',('#a0644d','#c08265','#6e4436'),watch=True,ankle_boots=True),
'smg':costume('smg',('#c9c5ad','#e6e0c9','#96957f'),tattoo=True),
'shotgun':costume('shotgun',('#a48b67','#c1aa82','#75634d'),tattoo=True,ankle_boots=True),
'rifle':costume('rifle',('#566348','#798466','#354132'),gloves=True,ankle_boots=True),
'sniper':costume('sniper',('#5c6147','#7d8260','#383e2e'),gloves=True,ankle_boots=True)}
for r in ['pistol','smg','shotgun','rifle']:SPECS[r]['sleeve']='short'
for r,p,ph,s,sh in [
('pistol','#303335','#525858','#584131','#876449'),
('smg','#4c583d','#718060','#171f23','#465052'),
('shotgun','#526e80','#7c95a5','#624833','#8c6b4b'),
('rifle','#20282b','#414b4e','#a58c60','#c1ab7d'),
('sniper','#493e32','#70604b','#9b8056','#bba175')]:
 SPECS[r].update(pants=p,pants_hi=ph,shoe=s,shoe_hi=sh)
EXTRA_PALETTE=base.EXTRA_PALETTE+CAMO+['#a0644d','#c08265','#6e4436','#c9c5ad','#e6e0c9','#a48b67','#c1aa82','#526e80','#7c95a5','#5c6147','#7d8260']
def head(g,c,skin,hi,d='SE'):
 if not c.get('union'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 if role in ['smg','rifle','sniper']:
  temp=base.E.Element(N+'g')
  rig.ORIGINAL_HEAD(temp,dict(c,head='mask'),skin,hi,d)
  if role=='rifle':
   for el in temp.iter():
    for attr in ['fill','stroke']:
     if el.get(attr) in ['#202527','#42494a']:el.set(attr,{'#202527':'#4b593d','#42494a':'#788568'}[el.get(attr)])
  g.extend(list(temp))
 else:
  base.head(g,c,skin,hi,d)
  if not back:
   if role=='pistol':
    path(g,'M-3 -37 Q0 -39 4 -37 L4 -36 -1 -37 -3 -36Z','#182024','none')
    lens='M1 -42 L7 -42 Q8 -40 5 -38 Q2 -37 1 -42Z' if side else 'M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z'
    path(g,lens,'#10171a','#080f12',.65)
    path(g,'M-1 -41 L1 -41','none','#080f12',.6)
   else:
    path(g,'M-6 -39 L-4 -37 -2 -38 2 -38 5 -39 6 -35 3 -31 -2 -31 -5 -34Z','#1b2224','#11191c',.5)
    path(g,'M-2 -36 L2 -36','none','#665c4b',.5)
 if role in ['smg','sniper']:
  hat,lit,shade=('#151e22','#3f494a','#0e161a') if role=='smg' else ('#596244','#7b8561','#35402e')
  path(g,'M-7 -45 Q-7 -52 0 -52 Q7 -52 8 -45 L7 -43 -7 -44Z',hat,shade,.7)
  path(g,'M0 -51 L0 -46','none',lit,.55)
  if role=='sniper':
   if not back:path(g,'M-6 -44 Q0 -43 7 -45 L11 -42 Q3 -40 -5 -42Z',hat,shade,.6)
  else:
   if back:path(g,'M-7 -44 Q0 -42 7 -44 L9 -41 Q0 -39 -9 -41Z',hat,shade,.6)
   elif side:path(g,'M-7 -45 L-12 -43 -6 -42Z',hat,shade,.6)
   else:
    path(g,'M-4 -45 L4 -45 4 -43 -4 -43Z',shade,'none')
    path(g,'M-2 -44 L2 -44','none',lit,.65)
def camo(t):
 for x,y,k in [(-7,-26,0),(4,-27,1),(-2,-19,2),(7,-13,0),(-7,-9,1),(1,-5,0)]:
  ref.western.blob(t,(x,y),2.7,2.6,CAMO[k])
def torso(g,c,skin,hi,d='SE'):
 if not c.get('union'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0]
 role=c['role'];back=d in ['N','NE','NW']
 if role in ['rifle','sniper']:camo(t)
 if role=='sniper':
  for x,y in [(-8,-30),(-4,-32),(5,-31),(9,-29)]:
   path(t,f'M{x-1} {y} L{x+1} {y} {x+.5} {y+6} {x-.6} {y+4} {x-1} {y+7}Z','#727954','#383e2e',.35)
 if role=='rifle':
  path(t,'M-7 -31 L-5 -31 -4 -10 -7 -10Z M5 -31 L7 -31 7 -10 4 -10Z','#172023','#0e171b',.5)
  if back:path(t,'M-6 -16 L6 -16','none','#172023',2)
  else:
   path(t,'M-8 -21 L8 -21 8 -9 -8 -9Z','#202b2d','#10191d',.6)
   for x in [-5,0,5]:
    path(t,f'M{x-2} -19 L{x+2} -19 {x+2} -9 {x-2} -9Z','#293638','#111a1e',.5)
    path(t,f'M{x-1} -16 L{x+1} -16','none','#53605d',.6)
 if back:
  if role=='smg':path(t,'M-8 -30 L8 -4','none','#151e22',2.3)
  return
 if role in ['pistol','shotgun']:
  inner='#dddccd' if role=='pistol' else '#20272a'
  path(t,'M-5 -32 L5 -32 5 -1 -5 -1Z',inner,'none')
  if role=='pistol':
   path(t,'M-4 -32 Q0 -24 4 -32','none','#a3a796',.65)
   path(t,'M-6 -32 L-3 -26 -6 -23 -7 -29Z M6 -32 L3 -26 6 -23 7 -29Z',c['lit'],c['shade'],.5)
   path(t,'M-3 -31 Q0 -23 3 -31','none',base.GOLD[0],.8)
  else:
   path(t,'M-3 -32 Q0 -28 3 -32 M0 -28 L0 -22','none','#58605c',.6)
   for y in [-26,-23]:path(t,f'M1 {y} L1 {y+.4}','none','#92988b',.7)
   for y in [-24,-19,-14]:
    path(t,f'M6 {y} L9 {y} 9 {y+3} 6 {y+3}Z','#695540','#3c3328',.5)
    path(t,f'M7 {y} L8 {y}','none','#bba16b',1)
  path(t,'M-6 -27 L-6 -2 M6 -27 L6 -2','none',c['lit'],.65)
 elif role=='smg':
  path(t,'M-4 -32 Q0 -27 4 -32','none',c['shade'],.65)
  path(t,'M-8 -30 L8 -3','none','#141d21',2.5)
  path(t,'M-5 -23 L5 -23 6 -13 -4 -12Z','#202a2f','#0e171b',.7)
  path(t,'M-3 -20 L4 -20 M4 -20 L4 -18','none','#647171',.6)
 elif role=='rifle':
  path(t,'M-4 -32 Q0 -25 4 -32','none',base.GOLD[0],.75)
 elif role=='sniper':
  path(t,'M-7 -32 L-5 -26 0 -29 5 -26 7 -32','none','#394331',1.5)
  path(t,'M0 -28 L0 -1','none','#2e372a',.7)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('union'):return base.arm(g,a,b,h,c,skin,hi)
 role=c['role']
 if role=='smg':
  base.arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade=skin,sleeve='short'),skin,hi)
  a,b=np.array(a,float),np.array(b,float)
  for f in [.35,.65]:
   p=a+(b-a)*f
   path(g,f'M{xy(p+[-1.5,-1])} q2 -1 3 1 q-2 2 -3 0','none','#51574b',.65)
  return
 if role in ['pistol','shotgun']:
  temp=dict(c,eastex=True)
  if role=='shotgun':temp.update(cloth='#20272a',lit='#46504e',shade='#121c20')
  return base.shared.arm(g,a,b,h,temp,skin,hi)
 base.arm(g,a,b,h,c,skin,hi)
 if role in ['rifle','sniper']:ref.camo_limb(g,a,b)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('union'):return
 if c['role']=='sniper':ref.camo_limb(g,a,b)
 if c.get('gloves'):
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);p=b-v*3
  fill='#4b593d' if c['role']=='sniper' else '#131c20'
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',fill,'#10181c',.5)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role in ['smg','rifle','sniper'] and radius>=3.5:
    p=a+(b-a)*.48
    path(detail,f'M{xy(p-n*2)} L{xy(p+n*2)} L{xy(p+n*2+v*5)} L{xy(p-n*2+v*5)}Z',c['pants'],c['pants_hi'],.55)
   if role=='smg' and radius<3.5:
    p=b-v*3
    path(detail,f'M{xy(p-n*2)} L{xy(p+n*2)} L{xy(b+n*2)} L{xy(b-n*2)}Z',c['shoe'],'none')
   if len(detail):parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
