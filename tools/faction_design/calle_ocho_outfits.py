"""Calle Ocho owner-directed clothing; accepted anatomy and standard clips."""
from pathlib import Path
import copy,re,sys,xml.etree.ElementTree as E
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
import eastex_outfits as shared
rig,outfits,directions,build=shared.rig,shared.outfits,shared.directions,shared.build
N,path,xy,BASE=shared.N,shared.path,shared.xy,shared.BASE
KIND=2
TITLE='CALLE OCHO'
PREFIX='calle_ocho'
BLUE=('#b09147',)
WHITE=('#d6d5c9','#eeeee2','#929c9b')
BLACK=('#272c2d','#42484a','#171e20')
GOLD=('#a58a45','#c3a65e','#706035')
BROWN=('#715b46','#94785a','#483f35')
DESCRIPTIONS={
 'pistol':'Forehead bandana / slicked hair / white ribbed tank / tattoos',
 'smg':'Backward black cap / open mustard shirt over white tee',
 'shotgun':'Shaved head / goatee / sunglasses / brown plaid overshirt',
 'rifle':'Close fade / black face bandana / charcoal shirt / olive cargos',
 'sniper':'Faded black hood / dark gray face cloth / black gloves',
}
NOTES={
 'pistol':['Thin gold chain / charcoal work pants','White low-top sneakers'],
 'smg':['Short dark hair / faded black jeans','Black-and-white skate shoes'],
 'shotgun':['Top button only / black undershirt','Tan work pants / heavy black boots'],
 'rifle':['Short sleeves / black belt and pouches','Olive cargo pants / black boots'],
 'sniper':['Hair concealed / charcoal work pants','Black boots / conservative stock fit'],
}
def costume(top,colors,head,sleeve='short',**extra):
 return dict(top=top,cloth=colors[0],lit=colors[1],shade=colors[2],head=head,
             sleeve=sleeve,wide=BASE['wide'],new_unit=True,calle=True,
             pants='#303638',pants_hi='#50585a',shoe='#161d1e',shoe_hi='#3d4546',**extra)
SPECS={
 'pistol':costume('tank',WHITE,'forehead_band','bare',tattoo=True),
 'smg':costume('open_shirt',GOLD,'backward_cap'),
 'shotgun':costume('plaid',BROWN,'shaved','long',boots=True),
 'rifle':costume('workshirt',BLACK,'fade_bandana',boots=True,cargo=True,pouches=True),
 'sniper':costume('hoodie',BLACK,'hood','long',boots=True,gloves=True),
}
SPECS['pistol'].update(shoe=WHITE[0],shoe_hi=WHITE[1])
SPECS['smg'].update(pants='#2a2e30',pants_hi='#495052',shoe_hi=WHITE[0])
SPECS['shotgun'].update(pants='#9c8d6c',pants_hi='#b9aa86')
SPECS['rifle'].update(pants='#47503b',pants_hi='#687057')
EXTRA_PALETTE=['#b59a50','#ddc782','#202526','#393c38','#302c27','#181e20',
               '#b19874','#34342f','#a58c69','#41474a','#646a6b','#3c4948','#aa8060','#c39b77']
ORIGINAL_FOREARM=outfits.forearm
STOCK_FIT=True

def head(g,c,skin,hi,d='SE'):
 if not c.get('calle'):return shared.head(g,c,skin,hi,d)
 back=d in ['N','NE','NW'];side=d in ['E','W'];h=c['head']
 if h=='hood':
  temp=E.Element(N+'g');rig.head(temp,dict(c,pocket_rag=True),skin,hi,d)
  for el in temp.iter():
   if el.get('fill')=='#202527':el.set('fill','#41474a')
   if el.get('stroke')=='#42494a':el.set('stroke','#646a6b')
  g.extend(list(temp));return
 shape=('M-6 -37 L-7 -44 Q-7 -50 0 -50 Q6 -50 7 -45 L8 -40 6 -34 1 -33 -5 -36Z'
        if side else 'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z')
 path(g,shape,skin,w=1.15)
 if h!='shaved':
  path(g,'M-6 -44 L-6 -47 Q-1 -52 5 -48 L7 -44 6 -38 4 -37 4 -43 Q0 -45 -4 -42 L-4 -37 -6 -39Z','#181e20','none')
  if back:path(g,'M-6 -45 Q0 -50 6 -45 L6 -39 4 -36 -4 -36 -6 -39Z','#202526','none')
  if h=='fade_bandana':
   path(g,'M-5 -43 L-5 -39 M5 -43 L5 -39','none','#393c38',1)
   path(g,'M-4 -47 Q0 -49 4 -46','none','#393c38',.7)
  elif h=='forehead_band':
   path(g,'M-5 -47 Q-1 -50 3 -48 M-2 -46 Q2 -49 5 -46','none','#393c38',.6)
 if not back:
  path(g,('M3 -41 L5 -41 M3 -35 L5 -35' if side else 'M-3 -40.5 L-1 -40.5 M2 -40.5 L4 -40.5 M-1 -35 L2 -35'),'none','#302c27',.6)
  path(g,'M1 -39 L2 -37','none',hi,.65)
 if h=='forehead_band':
  path(g,'M-7 -45 Q0 -43 7 -45 L7 -42 Q0 -40 -7 -42Z','#181e20','#090f12',.6)
  path(g,'M-6 -43 Q0 -41 6 -43','none','#393c38',.55)
  if back:path(g,'M-2 -43 L2 -43 3 -40 1 -39 -2 -40Z M0 -40 L-3 -34 0 -35 2 -40Z','#181e20','#393c38',.5)
  elif side:path(g,'M-6 -43 L-9 -41 -8 -36 -6 -37Z','#181e20','#393c38',.5)
  if not back:path(g,('M3 -37 L6 -36.8' if side else 'M-3 -37 Q0 -38 3 -37'),'none','#202526',.9)
 elif h=='backward_cap':
  path(g,'M-7 -44 L-7 -47 Q-4 -52 1 -51 Q6 -51 7 -46 L6 -43 Q0 -41 -7 -44Z','#202526','#101619',.9)
  path(g,'M-5 -47 Q0 -50 4 -47','none','#41474a',.7)
  if side:path(g,'M-6 -45 L-13 -43 Q-14 -41 -6 -42Z','#202526','#101619',.7)
  elif back:path(g,'M-7 -44 Q0 -42 7 -44 L10 -41 Q0 -38 -9 -41Z','#202526','#101619',.7)
  else:path(g,'M-3 -44 L2 -44 2 -42 -3 -42Z','#181e20','#41474a',.45)
 elif h=='shaved':
  path(g,'M-4 -46 Q0 -49 4 -46','none',hi,.7)
  if not back:
   path(g,('M1 -43 L7 -42 7 -39 2 -39Z' if side else 'M-6 -43 L-1 -42 0 -41 1 -42 6 -42 5 -39 1 -39 0 -40 -1 -39 -5 -39Z'),'#101619','#090f12',.65)
   path(g,('M3 -38 L6 -38 7 -35 4 -32 2 -34Z' if side else 'M-3 -38 Q0 -39 3 -38 L3 -36 1 -36 1 -35 3 -35 2 -32 -2 -32 -3 -35 -1 -35 -1 -36 -3 -36Z'),'#202526','none')
 elif h=='fade_bandana':
  path(g,'M-6 -40 Q0 -38 6 -40 L6 -35 3 -31 -3 -32 -6 -35Z','#181e20','#090f12',.6)
  path(g,'M-4 -35 Q0 -33 4 -35 M-2 -33 L1 -32','none','#41474a',.6)

def torso(g,c,skin,hi,d='SE'):
 if not c.get('calle'):return rig.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d)
 t=list(g)[0];back=d in ['N','NE','NW'];top=c['top']
 if top=='tank':
  if not back:
   path(t,'M-6 -33 Q0 -30 6 -33 L5 -26 Q0 -21 -5 -26Z',skin,'none')
   path(t,'M-6 -32 L-5 -26 Q0 -21 5 -26 L6 -32','none',c['lit'],1.1)
   path(t,'M-5 -31 Q0 -23 5 -31','none','#b59a50',.8)
   path(t,'M-3 -28 Q0 -25 3 -28','none','#ddc782',.45)
  for x in [-8,-4,0,4,8]:path(t,f'M{x} -21 L{x-.3} -3','none',c['shade'],.35)
  path(t,'M-9 -30 Q-7 -25 -11 -21 M10 -30 Q7 -25 11 -21','none',c['shade'],.65)
 elif top in ['open_shirt','plaid']:
  if top=='plaid':
   for x in [-8,-3,2,7]:path(t,f'M{x} -29 L{x} -2','none','#34342f',1)
   for y in [-27,-21,-15,-9,-3]:path(t,f'M-10 {y} L10 {y}','none','#b19874',.55)
  if not back:
   if top=='open_shirt':
    path(t,'M-5 -31 Q0 -28 5 -31 L5 -15 6 1 -6 1 -5 -15Z',WHITE[0],c['shade'],.65)
    path(t,'M-4 -29 Q0 -25 4 -29','none',WHITE[2],.6)
    path(t,'M-9 -31 L-5 -33 -3 -27 -6 -25Z M5 -33 L9 -31 6 -25 3 -27Z',c['lit'],c['shade'],.6)
   else:
    path(t,'M-3 -31 Q0 -28 3 -31 L2 -24 4 -13 8 1 -8 1 -4 -13 -2 -24Z','#181e20',c['shade'],.65)
    path(t,'M-7 -32 L-3 -33 0 -27 -4 -25Z M3 -33 L7 -31 4 -25 0 -27Z',c['lit'],c['shade'],.6)
    path(t,'M0 -26 L0 -24','none','#b19874',.9)
 elif top=='workshirt':
  if not back:
   path(t,'M-6 -32 L0 -28 6 -32 3 -25 0 -28 -3 -25Z',c['lit'],c['shade'],.6)
   path(t,'M0 -27 L0 -3 M-8 -22 L-3 -22 -3 -16 -7 -17 M3 -22 L8 -22 7 -17 3 -16','none',c['shade'],.7)
   for y in [-21,-15,-9]:path(t,f'M.7 {y} L1 {y}','none',c['lit'],.7)
  path(t,'M-11 -2 Q0 1 12 -2 L12 1 Q0 4 -11 1Z','#101619','#090f12',.5)
  for x in [-8,5]:
   path(t,f'M{x} -5 L{x+3.8} -5 {x+4} 2 {x} 2Z','#181e20','#090f12',.6)
   path(t,f'M{x+.5} -3 L{x+3} -3','none','#41474a',.6)

def plaid_segment(g,a,b,r):
 a,b=np.array(a,float),np.array(b,float);v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
 for t in [.3,.6,.85]:
  p=a+(b-a)*t;path(g,f'M{xy(p+n*r)} L{xy(p-n*r)}','none','#b19874',.55)
 path(g,f'M{xy(a+v*2)} L{xy(b-v)}','none','#34342f',.8)
def forearm(g,a,b,c,skin,hi,r=3.1):
 ORIGINAL_FOREARM(g,a,b,c,skin,hi,r)
 if c.get('calle') and c['top']=='plaid':plaid_segment(g,a,b,min(2,r-.6))
def arm(g,a,b,h,c,skin,hi):
 if not c.get('calle'):return shared.arm(g,a,b,h,c,skin,hi)
 if c['sleeve']=='bare':
  rig.connected_arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade='#806044',sleeve='short'),skin,hi)
  a,b=np.array(a,float),np.array(b,float);v=(b-a)/np.linalg.norm(b-a);n=np.array([-v[1],v[0]])
  for t in [.2,.4,.65]:
   p=a+(b-a)*t;path(g,f'M{xy(p+n*2-v)} Q{xy(p-n)} {xy(p+n+v)} L{xy(p-n*2+v)}','none','#3c4948',.7)
 elif c['sleeve']=='short':shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 else:
  rig.connected_arm(g,a,b,h,c,skin,hi)
  if c['top']=='plaid':plaid_segment(g,a,b,2.7)

def lower_details(root,c):
 shared.decorate_lower(root,c)
 if not c.get('cargo'):return
 for parent in list(root.iter()):
  for el in list(parent):
   d=el.get('d','')
   if el.get('fill')!=c['pants'] or re.search('[QCAqca]',d):continue
   ns=re.findall(r'-?\d+(?:\.\d+)?',d)
   if len(ns)!=12:continue
   ps=np.array(list(map(float,ns))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2
   if radius<3.5:continue
   v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);p=a+(b-a)*.62
   detail=E.Element(N+'g',{'data-garment-detail':'true'})
   path(detail,f'M{xy(p+n*2.7-v*2)} L{xy(p-n*2.7-v*2)} L{xy(p-n*2.6+v*4)} L{xy(p+n*2.6+v*4)}Z','#3d4533',c['pants_hi'],.55)
   path(detail,f'M{xy(p+n*2.6)} L{xy(p-n*2.6)}','none',c['pants_hi'],.7)
   parent.insert(list(parent).index(el)+2,detail)

def make(role,model,direction,**state):
 import build_art as art
 c=SPECS[role];w=model['art_base'];outfits.SPECS[(KIND,w)]=c
 _,definition=art.bind(model)
 if role=='sniper':
  definition['view_lengths']={'S':.80,'N':.72}
  if STOCK_FIT:
   # SE and its SW reflection: gun and both grip anchors move together.
   # Existing angle, scale, drawing, shoulder joints and body remain intact.
   definition['carry_origin']=(np.array(definition['carry_origin'])+[6.,3.]).tolist()
 root=directions.make(KIND,state.pop('q',1.25),direction,w,**state)
 before=rig.lower_signature(root);lower_details(root,c)
 clean=copy.deepcopy(root)
 for parent in clean.iter():
  for child in list(parent):
   if child.get('data-garment-detail'):parent.remove(child)
 assert rig.lower_signature(clean)==before
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
