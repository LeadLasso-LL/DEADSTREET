"""Kurgan regular wardrobe on the accepted human rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='THE KURGAN GROUP'
PREFIX='kurgan'
OLIVE=('#505a3d','#788263','#333b2b')
KHAKI=('#968567','#b4a382','#62583f')
BROWN=('#61503a','#877154','#3c3528')
BLUE=(OLIVE[1],)
DESCRIPTIONS={
'pistol':'Olive field cap / aviators / rolled khaki shirt + striped undershirt',
'smg':'Charcoal beanie + olive ski mask / green sweatshirt / canvas rig',
'shotgun':'Scratched olive helmet / thick beard / woodland jacket + shell vest',
'rifle':'Camo-covered helmet / olive face gaiter / tan carrier + olive pouches',
'sniper':'Khaki hood / olive face cloth / brown-khaki mountain smock'}
NOTES={
'pistol':['Dark olive trousers / black combat boots','Brown webbing belt / Kurgan sleeve patch'],
'smg':['Tan trousers / olive knee reinforcements','Brown boots / fingerless gloves / chest patch'],
'shotgun':['Dark brown trousers / heavy black boots','Tan gloves / Kurgan sleeve patch'],
'rifle':['Matching camouflage / dark green knees','Brown boots / olive gloves / sleeve patch'],
'sniper':['Sparse camouflage strips / olive webbing','Brown trousers / khaki knees / olive gloves']}
SPECS={r:base.costume(r, KHAKI if r in ['pistol','sniper'] else OLIVE,'combed',kurgan=True,role=r,ankle_boots=True) for r in DESCRIPTIONS}
for r,p,ph,s,sh in [
('pistol','#414c33','#697552','#1b2424','#414c47'),
('smg','#a08b68','#bfab86','#59472f','#856c4b'),
('shotgun','#453b2b','#70604a','#192123','#3e4849'),
('rifle','#505a3d','#788263','#655239','#917956'),
('sniper','#63513b','#8b7452','#574632','#7e694c')]:
 SPECS[r].update(pants=p,pants_hi=ph,shoe=s,shoe_hi=sh)
for r in ['pistol','smg']:SPECS[r]['sleeve']='short'
EXTRA_PALETTE=base.EXTRA_PALETTE+list(OLIVE)+list(KHAKI)+list(BROWN)+['#ba8045','#853e34','#263747','#d4d4bd','#34472e']
def patch(g,x,y,scale=.65):
 # Miniature of the established black/red circular snarling-tiger emblem.
 t=base.E.SubElement(g,N+'g',{'transform':f'translate({x} {y}) scale({scale})','data-kurgan-emblem':'tiger'})
 path(t,'M0 -3.8 A3.8 3.8 0 1 1 -.01 -3.8Z','#171d1d','#853e34',.7)
 path(t,'M-2 -1 L-2.5 -2.6 -.8 -2.2 0 -2.5 1 -2.2 2.5 -2.6 2 -1 2.6 .5 1.5 2 -.3 2.6 -2 1.4 -2.6 0Z','#ba8045','none')
 path(t,'M-1.8 -.8 L-.3 -.2 M1.8 -.8 L.3 -.2 M-2 .6 L-.8 1 M2 .6 L.8 1','none','#171d1d',.6)
 path(t,'M-1.2 1 L1.2 1 .6 2.1 -.6 2.1Z','#d1c6a5','#171d1d',.35)
 path(t,'M-.7 -3.2 L-.7 -2.5 M.4 -3.2 L-.7 -2.8 .4 -2.5','none','#853e34',.4)
def camo(g,points):
 for i,(x,y) in enumerate(points):
  path(g,f'M{x-2} {y} l1 -1.5 2 .5 1.5 -.3 .6 2 -2 .7 -1 -.8 -2 .3Z',['#303e2c','#837552','#3f4533'][i%3],'none')
def mask(g,c,skin,hi,d):
 tmp=base.E.Element(N+'g')
 rig.ORIGINAL_HEAD(tmp,dict(c,head='mask'),skin,hi,d)
 for el in tmp.iter():
  for attr in ['fill','stroke']:
   if el.get(attr) in ['#202527','#42494a']:el.set(attr,{'#202527':OLIVE[0],'#42494a':OLIVE[1]}[el.get(attr)])
 g.extend(list(tmp))
def head(g,c,skin,hi,d='SE'):
 if not c.get('kurgan'):return base.head(g,c,skin,hi,d)
 r=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 if r=='smg':mask(g,c,skin,hi,d)
 else:base.head(g,c,skin,hi,d)
 if not back and r in ['pistol','shotgun','sniper']:
  col={'pistol':'#847653','shotgun':'#302c25','sniper':'#94623e'}[r]
  path(g,'M-5 -39 L-3 -37 0 -38 3 -37 5 -39 5 -35 2 -32 -2 -33 -5 -35Z',col,'none')
  if r=='shotgun':path(g,'M-4 -35 L-3 -32 -1 -33 1 -31 3 -33 4 -35','none',col,1.2)
 if r=='pistol':
  path(g,'M-6 -45 L-6 -40 -4 -40 -4 -45Z M4 -45 L6 -45 6 -40 4 -40Z','#b19a69','none')
  path(g,'M-7 -44 L-7 -49 Q0 -52 7 -49 L8 -44Z',OLIVE[0],OLIVE[2],.7)
  path(g,'M-6 -48 L6 -48','none',OLIVE[1],.6)
  if not back:
   path(g,'M-7 -44 Q0 -43 7 -45 L10 -42 Q2 -40 -6 -42Z',OLIVE[0],OLIVE[2],.6)
   path(g,'M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z','#10191c','#080f12',.6)
   path(g,'M-1 -41 L1 -41','none','#080f12',.7)
 elif r=='smg':
  path(g,'M-7 -44 L-7 -48 Q0 -54 7 -48 L8 -43Z','#30383a','#171f23',.7)
  path(g,'M-7 -44 L7 -44','none','#555c59',1.6)
 elif r in ['shotgun','rifle']:
  path(g,'M-8 -42 L-8 -47 Q-7 -54 0 -54 Q8 -54 9 -47 L9 -42 Q0 -40 -8 -42Z',OLIVE[0],OLIVE[2],.8)
  if r=='rifle':camo(g,[(-4,-49),(2,-51),(5,-46),(-4,-44)])
  else:path(g,'M-4 -50 L-1 -49 M3 -46 L6 -47 M-6 -45 L-4 -45','none','#a39b79',.6)
  if not back and r=='rifle':
   path(g,'M-6 -39 L-4 -33 3 -32 6 -39','none','#111b1e',.8)
   path(g,'M-6 -38 Q0 -36 6 -38 L5 -32 -4 -32Z',OLIVE[0],OLIVE[2],.6)
 elif r=='sniper':
  path(g,'M-8 -34 L-9 -43 Q-9 -53 0 -55 Q9 -53 9 -43 L8 -33 5 -33 6 -44 Q0 -50 -5 -44 L-5 -34Z',KHAKI[0],KHAKI[2],.7)
  if back:path(g,'M-7 -45 Q0 -53 7 -45 L7 -34 -6 -34Z',KHAKI[0],KHAKI[2],.6)
  else:path(g,'M-6 -39 Q0 -37 6 -39 L5 -33 -4 -33Z',OLIVE[0],OLIVE[2],.6)
  for x,y in [(-7,-47),(5,-49),(7,-40)]:
   path(g,f'M{x-1} {y} L{x+1} {y} {x+.3} {y+4} {x-1} {y+3}Z','#70745a',OLIVE[2],.4)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('kurgan'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 if r in ['shotgun','rifle']:camo(t,[(-7,-27),(5,-26),(-5,-18),(7,-12),(-5,-5),(3,-3)])
 if r=='sniper':
  path(t,'M-10 -25 L10 -25 10 -1 -10 -1Z',BROWN[0],BROWN[2],.5)
  path(t,'M-10 -31 L-4 -32 -4 -26 -10 -25Z M4 -32 L10 -31 10 -25 4 -26Z','#34472e',OLIVE[2],.5)
  for x,y in [(-9,-31),(-6,-32),(6,-31),(9,-30)]:
   path(t,f'M{x-1} {y} L{x+1} {y} {x+.4} {y+5} {x-1} {y+3}Z','#70745a',OLIVE[2],.4)
 if r=='pistol' and not back:
  path(t,'M-4 -32 L4 -32 3 -17 -3 -17Z','#263747','none')
  for y in [-29,-26,-23,-20]:path(t,f'M-3 {y} L3 {y}','none','#d4d4bd',1.3)
  path(t,'M-5 -32 L-1 -29 -3 -22 -6 -28Z M5 -32 L1 -29 3 -22 6 -28Z',KHAKI[1],KHAKI[2],.5)
  path(t,'M0 -17 L0 -1','none',KHAKI[2],.6)
  for x in [-7,7]:path(t,f'M{x-2} -20 h4 v5 h-4Z',KHAKI[0],KHAKI[2],.5)
 if r in ['smg','sniper']:
  col=BROWN if r=='smg' else OLIVE
  path(t,'M-7 -31 L-5 -12 M7 -31 L5 -12','none',col[0],2)
  if not back:
   path(t,'M-8 -20 L8 -20 8 -10 -8 -10Z',col[0],col[2],.6)
   for x in [-5,0,5]:path(t,f'M{x-1.8} -18 h3.6 v7 h-3.6Z',col[1],col[2],.5)
   if r=='smg':patch(t,0,-15,.65)
 elif r in ['shotgun','rifle']:
  col=OLIVE if r=='shotgun' else KHAKI
  path(t,'M-8 -31 L-5 -32 -4 -26 4 -26 5 -32 9 -30 10 -17 10 -2 -10 -2 -10 -17Z',col[0],col[2],.6)
  path(t,'M-6 -24 L6 -24 7 -14 -7 -14Z',col[0],col[1],.5)
  if not back:
   for x in [-6,-3,0,3,6] if r=='shotgun' else [-5,0,5]:
    if r=='shotgun':
     path(t,f'M{x} -13 L{x} -6','none','#554637',1.7)
     path(t,f'M{x} -7 L{x} -5','none','#b7a076',1.7)
    else:path(t,f'M{x-2} -14 h4 v10 h-4Z',OLIVE[0],OLIVE[2],.5)
 path(t,'M-10 -1 L10 -1','none',BROWN[0],2)
 if r=='pistol' and not back:
  path(t,'M8 0 L12 0 12 7 8 6Z',BROWN[0],BROWN[2],.6)
  path(t,'M-9 -3 h4 v5 h-4Z',BROWN[0],BROWN[2],.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('kurgan'):return base.arm(g,a,b,h,c,skin,hi)
 base.arm(g,a,b,h,c,skin,hi)
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a))
 if c['role'] in ['shotgun','rifle']:
  p=a+(b-a)*.65;camo(g,[(p[0],p[1])])
 if c['role']=='sniper':
  p=a+v*2;q=a+v*6;n=np.array([-v[1],v[0]])
  path(g,f'M{xy(p-n*2.5)} L{xy(p+n*2.5)} L{xy(q+n*2.3)} L{xy(q-n*2.3)}Z','#34472e','none')
 if c['role']!='smg':
  p=a+(b-a)*.55;patch(g,p[0],p[1],.62)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('kurgan'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='smg':
  end=a+(b-a)*.35
  base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none',c['lit'],1.2)
 if c['role'] in ['shotgun','rifle','sniper']:
  fill=KHAKI[0] if c['role']=='shotgun' else OLIVE[0]
  p=b-v*3
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',fill,OLIVE[2],.5)
 elif c['role']=='smg':
  p=b-v*3;q=b-v*.8
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(q+n*2)} L{xy(q-n*2)}Z','#192124','#10191c',.5)
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
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role=='rifle':
    p=a+(b-a)*.5;camo(detail,[(p[0],p[1])])
   if radius<3.5:
    if role in ['smg','rifle','sniper']:
     p=a+v*1.5;col=KHAKI[0] if role=='sniper' else '#34472e'
     path(detail,f'M{xy(p-n*2.3)} L{xy(p+n*2.3)} L{xy(p+n*2+v*4)} L{xy(p-n*2+v*4)}Z',col,c['pants_hi'],.5)
    for step in [1.5,3,4.5]:
     p=b-v*step;path(detail,f'M{xy(p-n*1.2)} L{xy(p+v*.5+n*1.2)}','none',c['shoe_hi'],.55)
   if len(detail):parent.insert(list(parent).index(el)+3,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
