"""Ventresca wardrobe on the accepted ordinary-unit body and animation rig."""
from pathlib import Path
import copy,re,sys,xml.etree.ElementTree as E
import numpy as np
sys.path.insert(0,str(Path(__file__).parent))
import eastex_outfits as shared
rig,outfits,directions,build=shared.rig,shared.outfits,shared.directions,shared.build
N,path,xy,BASE=shared.N,shared.path,shared.xy,shared.BASE
KIND=2
TITLE='VENTRESCA FAMILY'
PREFIX='ventresca'
BLUE=('#788067',)
BLACK=('#202629','#383f42','#12191c')
BROWN=('#49392f','#705744','#2e2722')
GRAY=('#454c50','#646d71','#2c3439')
WHITE=('#d6d5c9','#eeeee2','#929c9b')
GOLD=('#bc9a4e','#e0c783','#79632f')
DESCRIPTIONS={
 'pistol':'Side-parted hair / open black tracksuit / white tee / gold jewelry',
 'smg':'Slicked-back hair / black suit jacket / burgundy knit polo',
 'shotgun':'Receding hair / mustache / brown leather / cream turtleneck',
 'rifle':'Combed-back hair / gray suit / pale blue shirt / narrow black tie',
 'sniper':'Low flat cap / gray scarf / mid-thigh black wool coat / gloves',
}
NOTES={
 'pistol':['Gold chain and watch / matching tracksuit','White sneakers / clean-shaven'],
 'smg':['Longer hair at neck / thin gold chain','Tailored trousers / black loafers'],
 'shotgun':['Cream turtleneck / charcoal trousers','Brown leather ankle boots'],
 'rifle':['Matching gray trousers / black gloves','Black leather dress shoes'],
 'sniper':['Salt-and-pepper hair / charcoal knit','Black trousers / leather ankle boots'],
}
def costume(top,colors,head,**extra):
 return dict(top=top,cloth=colors[0],lit=colors[1],shade=colors[2],head=head,
             sleeve='long',wide=BASE['wide'],new_unit=True,ventresca=True,
             pants='#23292c',pants_hi='#41484b',shoe='#161c1f',shoe_hi='#3e474b',**extra)
SPECS={
 'pistol':costume('track',BLACK,'sidepart',watch=True,chain=True),
 'smg':costume('blazer',BLACK,'slicklong',chain=True,loafers=True),
 'shotgun':costume('leather',BROWN,'receding',ankle_boots=True),
 'rifle':costume('suit',GRAY,'combed',gloves=True),
 'sniper':costume('overcoat',BLACK,'flat',gloves=True,ankle_boots=True),
}
SPECS['pistol'].update(pants=BLACK[0],pants_hi=BLACK[1],shoe=WHITE[0],shoe_hi=WHITE[1])
SPECS['shotgun'].update(pants='#343a3d',pants_hi='#51595c',shoe='#4c392b',shoe_hi='#786047')
SPECS['rifle'].update(pants=GRAY[0],pants_hi=GRAY[1])
EXTRA_PALETTE=list(GOLD)+['#332b27','#5a4637','#1b2225','#42484a','#87908f','#a8aeaa',
 '#4c5357','#6b7375','#61373d','#815057','#42282f','#b6c9ce','#d4e1e2','#819aab',
 '#c7bfa5','#e0d8bf','#9d947d','#30373a','#50595e','#aa8060','#c39b77']
ORIGINAL_FOREARM=outfits.forearm

def head(g,c,skin,hi,d='SE'):
 if not c.get('ventresca'):return shared.head(g,c,skin,hi,d)
 back=d in ['N','NE','NW'];side=d in ['E','W'];h=c['head']
 shape=('M-6 -37 L-7 -44 Q-7 -50 0 -50 Q6 -50 7 -45 L8 -40 6 -34 1 -33 -5 -36Z'
        if side else 'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z')
 if h=='slicklong':
  path(g,'M-6 -45 Q0 -50 6 -45 L8 -38 7 -31 5 -33 3 -32 3 -36 -3 -36 -4 -32 -7 -33 -8 -37Z','#1b2225','#12191c',.6)
 path(g,shape,skin,w=1.15)
 hair='#332b27' if h in ['sidepart','receding'] else '#1b2225'
 light='#5a4637' if h in ['sidepart','receding'] else '#42484a'
 if h=='receding':
  if back:path(g,'M-6 -45 Q0 -50 6 -45 L6 -38 3 -35 -3 -35 -6 -38Z',hair,'none')
  else:
   path(g,'M-7 -44 L-6 -48 -3 -49 -4 -44 -4 -37 -6 -38Z M3 -49 L6 -47 7 -43 6 -37 4 -37 4 -43Z',hair,'none')
   path(g,'M-2 -49 Q0 -50 3 -48','none',light,.8)
 else:
  path(g,'M-6 -44 L-6 -47 Q-2 -52 4 -49 L7 -45 6 -38 4 -37 4 -44 Q0 -46 -4 -43 L-4 -37 -6 -38Z',hair,'none')
  if back:path(g,'M-6 -45 Q0 -50 6 -45 L6 -38 3 -35 -3 -35 -6 -38Z',hair,'none')
  if h=='sidepart':
   path(g,'M-2 -49 L-3 -44 M-1 -48 Q2 -50 5 -46 M-4 -47 L-5 -44','none',light,.7)
  elif h in ['combed','slicklong']:
   path(g,'M-4 -46 Q-2 -49 0 -49 M-1 -45 Q1 -48 3 -48 M2 -45 L5 -46','none',light,.65)
   if h=='slicklong' and back:path(g,'M-4 -38 L-4 -34 M0 -39 L0 -35 M4 -38 L4 -34','none',light,.6)
 if not back:
  path(g,('M3 -41 L5 -41 M3 -35 L5 -35' if side else 'M-3 -40.5 L-1 -40.5 M2 -40.5 L4 -40.5 M-1 -35 L2 -35'),'none','#332b27',.6)
  path(g,'M1 -39 L2 -37','none',hi,.65)
  if h=='receding':path(g,('M3 -38 Q5 -39 7 -37 L7 -35 4 -36 2 -35Z' if side else 'M-4 -37 Q-2 -39 0 -37.5 Q2 -39 4 -37 L4 -35 -1 -36 -4 -35Z'),hair,'none')
 if h=='flat':
  # Short graying side hair is visible below the low, shallow wool cap.
  for x in [-5.5,5.5]:
   path(g,f'M{x} -45 L{x} -38','none','#87908f',1.25)
   path(g,f'M{x-.4} -43 L{x+.3} -41 M{x} -39 L{x+.4} -38','none','#a8aeaa',.55)
  if back:path(g,'M-4 -38 Q0 -35 4 -38','none','#87908f',1)
  path(g,'M-8 -44 Q-9 -49 -2 -50 Q5 -51 8 -46 L9 -43 Q0 -40 -8 -44Z','#30373a','#12191c',.85)
  path(g,'M-6 -46 Q-2 -49 4 -47 M-2 -49 L1 -43','none','#50595e',.65)
  brim='M4 -44 L12 -43 Q13 -41 6 -41Z' if side else 'M-7 -43 Q1 -42 8 -44 L10 -42 Q1 -39 -7 -42Z'
  if not back:path(g,brim,'#30373a','#12191c',.6)
  path(g,'M-6 -40 Q0 -38 6 -40 L7 -34 4 -30 -4 -31 -7 -35Z','#4c5357','#202629',.6)
  path(g,'M-5 -36 Q0 -33 5 -36 M-3 -33 L2 -32','none','#6b7375',.65)

def lapels(t,c):
 path(t,'M-8 -32 L-4 -34 -1 -25 -5 -19 -4 -26 -7 -25Z',c['lit'],c['shade'],.6)
 path(t,'M4 -34 L9 -30 6 -25 4 -26 5 -18 1 -25Z',c['lit'],c['shade'],.6)
 path(t,'M-9 -9 L-5 -9 M5 -9 L9 -9','none',c['lit'],.65)

def torso(g,c,skin,hi,d='SE'):
 if not c.get('ventresca'):return rig.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d)
 t=list(g)[0];back=d in ['N','NE','NW'];top=c['top']
 if top=='overcoat':
  # Material extends below the existing torso; its silhouette and joints stay.
  if back:
   path(t,'M-11 -5 L11 -5 11 13 Q5 15 0 13 Q-6 15 -11 13Z',c['cloth'],'none')
   path(t,'M-11 -3 L-11 13 Q-5 15 0 13 Q5 15 11 13 L11 -3','none',c['shade'],.8)
   path(t,'M0 -26 L0 9 M0 9 L-1 13','none',c['shade'],.65)
  else:
   path(t,'M-11 -5 L-1 -5 -1 2 -3 14 Q-7 15 -11 13Z',c['cloth'],'none')
   path(t,'M1 -5 L11 -5 11 13 Q7 15 3 14 L1 2Z',c['cloth'],'none')
   path(t,'M-11 -3 L-11 13 Q-7 15 -3 14 L-1 2 M11 -3 L11 13 Q7 15 3 14 L1 2','none',c['shade'],.75)
   path(t,'M-8 1 L-8 11 M8 1 L8 11','none',c['lit'],.5)
 if back:
  if top=='track':path(t,'M-9 -2 Q0 1 10 -2','none',c['shade'],1.4)
  else:path(t,'M-7 -29 Q0 -27 7 -29 M0 -25 L0 -3','none',c['shade'],.6)
  return
 if top=='track':
  path(t,'M-5 -32 Q0 -29 5 -32 L5 -13 6 1 -6 1 -5 -13Z',WHITE[0],c['shade'],.6)
  path(t,'M-4 -29 Q0 -25 4 -29','none',WHITE[2],.6)
  path(t,'M-8 -31 L-5 -35 -3 -30 -4 -25 -7 -27Z M5 -35 L8 -31 7 -27 4 -25 3 -30Z',c['lit'],c['shade'],.65)
  path(t,'M-5 -25 L-5 -4 M5 -25 L5 -4','none','#87908f',.45)
  path(t,'M-11 -2 L-6 -1 M6 -1 L11 -2','none',c['shade'],1.5)
 elif top=='blazer':
  path(t,'M-5 -32 Q0 -29 5 -32 L5 0 -5 0Z','#61373d',c['shade'],.55)
  path(t,'M-4 -31 L0 -28 4 -31 2 -25 0 -27 -2 -25Z','#815057','#42282f',.55)
  path(t,'M0 -26 L0 -20','none','#42282f',.7)
  for y in [-19,-15,-11,-7]:path(t,f'M-3 {y} L3 {y}','none','#815057',.3)
  lapels(t,c)
 elif top=='leather':
  path(t,'M-5 -35 L5 -35 5 -29 4 -20 5 1 -5 1 -4 -20 -5 -29Z','#c7bfa5',c['shade'],.55)
  path(t,'M-4 -33 Q0 -31 4 -33 M-4 -30 Q0 -28 4 -30','none','#9d947d',.6)
  path(t,'M-2 -28 L-2 -3','none','#e0d8bf',.7)
  lapels(t,c)
  path(t,'M-10 -24 L-9 -16 M9 -24 L8 -17','none',c['lit'],1)
 elif top=='suit':
  path(t,'M-5 -33 L5 -33 5 -20 0 -9 -5 -20Z','#b6c9ce',c['shade'],.6)
  path(t,'M-4 -33 L0 -29 4 -33 2 -25 0 -28 -2 -25Z','#d4e1e2','#819aab',.5)
  path(t,'M-.9 -29 L.9 -29 1.4 -27 .7 -25 1.4 -14 0 -11 -1.4 -14 -.7 -25 -1.4 -27Z','#12191c','none')
  lapels(t,c)
  path(t,'M1 -10 L1 0','none',c['shade'],.7)
  path(t,'M2 -9 L2 -8','none',c['lit'],1)
 elif top=='overcoat':
  path(t,'M-5 -34 L5 -34 5 -26 3 -18 -3 -18 -5 -26Z','#30373a',c['shade'],.55)
  path(t,'M-4 -32 Q0 -30 4 -32','none','#50595e',.65)
  lapels(t,c)
  path(t,'M0 -17 L0 0','none',c['shade'],.7)
  for y in [-13,-6,0]:path(t,f'M2 {y} L2 {y+.5}','none',c['lit'],.9)
 if c.get('chain'):
  y=-32 if top=='track' else -32.5
  path(t,f'M-4 {y} Q0 {y+8 if top=="track" else y+5} 4 {y}','none',GOLD[0],.8 if top=='track' else .6)
  path(t,f'M-2 {y+3} Q0 {y+4} 2 {y+3}','none',GOLD[1],.45)

def forearm(g,a,b,c,skin,hi,r=3.1):
 ORIGINAL_FOREARM(g,a,b,c,skin,hi,r)
 if not c.get('ventresca'):return
 a,b=np.array(a,float),np.array(b,float);v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
 if c.get('watch') and (c.get('watch_arm') or r<3):
  p=b-v*2.7
  path(g,f'M{xy(p+n*2.3)} L{xy(p-n*2.3)}','none',GOLD[0],1.8)
  path(g,f'M{xy(p-v)} L{xy(p+n*1.1)} L{xy(p+v)} L{xy(p-n*1.1)}Z',GOLD[1],GOLD[2],.45)
 if c['top']=='track':
  p=b-v*3.8;path(g,f'M{xy(p+n*2.1)} L{xy(p-n*2.1)}','none',c['shade'],.7)
def arm(g,a,b,h,c,skin,hi):
 far=a[0]>(40 if a[1]>0 else 0)
 rig.connected_arm(g,a,b,h,dict(c,watch_arm=far),skin,hi)

def lower_details(root,c):
 # Smooth ankle-height leather shafts rather than laced work boots.
 if not c.get('ankle_boots'):return
 for parent in list(root.iter()):
  for el in list(parent):
   d=el.get('d','')
   if el.get('fill')!=c['pants'] or re.search('[QCAqca]',d):continue
   nums=re.findall(r'-?\d+(?:\.\d+)?',d)
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   radius=np.linalg.norm(ps[2]-ps[3])/2
   if radius>=3.5:continue
   v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);top=b-v*5
   detail=E.Element(N+'g',{'data-garment-detail':'true'})
   path(detail,f'M{xy(top+n*radius)} L{xy(top-n*radius)} L{xy(b-n*radius)} Q{xy(b+v)} {xy(b+n*radius)}Z',c['shoe'],'none')
   path(detail,f'M{xy(top+n*1.7)} L{xy(b+n*1.7)}','none',c['shoe_hi'],.55)
   parent.insert(list(parent).index(el)+2,detail)

def make(role,model,direction,**state):
 import build_art as art
 c=SPECS[role];w=model['art_base'];outfits.SPECS[(KIND,w)]=c
 _,definition=art.bind(model)
 if role=='sniper':
  definition['view_lengths']={'S':.80,'N':.72}
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
