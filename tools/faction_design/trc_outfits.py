"""TRC regular outfits: black and a shared emblem-green ramp."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='TEXAS RECOVERY COALITION'
PREFIX='trc'
GREEN=('#344c36','#526c4c','#203425')
BLACK=('#1d2528','#3a4649','#0e171b')
BLUE=(GREEN[1],)
DESCRIPTIONS={'pistol':'Black cap + shades / green ballistic vest / short black sleeves',
'smg':'High-cut helmet + headset / green ski mask / compact black carrier',
'shotgun':'Full helmet + black mask / green shirt / shoulder armor + shell loops',
'rifle':'Black full helmet + ski mask / green carrier + black pouches',
'sniper':'Green hood + black ski mask / light shoulder strips / slim chest rig'}
NOTES={'pistol':['Green tactical pants / duty belt + holster','TRC chest patch / black boots and gloves'],
'smg':['Rolled forearms / green pants + black knees','TRC helmet patch / black boots and gloves'],
'shotgun':['Black pants and knee pads','TRC sleeve patch / normal proportions'],
'rifle':['Black pants / green knee pads','TRC chest patch / black boots and gloves'],
'sniper':['Black pants / black reinforced knees','TRC sleeve patch / black boots and gloves']}
def spec(role,colors):
 return base.costume(role,colors,'combed',trc=True,role=role,ankle_boots=True,gloves=True)
SPECS={r:spec(r,GREEN if r in ['shotgun','sniper'] else BLACK) for r in DESCRIPTIONS}
for r in ['pistol','smg']:SPECS[r].update(pants=GREEN[0],pants_hi=GREEN[1])
for r in SPECS:SPECS[r].update(shoe=BLACK[0],shoe_hi=BLACK[1])
SPECS['pistol']['sleeve']='short'
SPECS['sniper'].update(pants=BLACK[0],pants_hi=BLACK[1])
EXTRA_PALETTE=base.EXTRA_PALETTE+list(GREEN)+list(BLACK)+['#aaa078']
def patch(g,x,y,scale=1):
 t=base.E.SubElement(g,N+'g',{'transform':f'translate({x} {y}) scale({scale})'})
 path(t,'M-3 -3 L3 -3 3 3 -3 3Z',BLACK[2],GREEN[1],.45)
 path(t,'M0 -2.5 L.7 -.7 2.6 -.7 1.1 .5 1.7 2.4 0 1.2 -1.7 2.4 -1.1 .5 -2.6 -.7 -.7 -.7Z',GREEN[0],'#aaa078',.35)
 path(t,'M-1.2 0 Q0 -1.1 1.2 0 Q0 1 -1.2 0Z','#aaa078','none')
 path(t,'M0 -.35 L0 .35','none',BLACK[2],.55)
def mask(g,c,skin,hi,d,green=False):
 temp=base.E.Element(N+'g');rig.ORIGINAL_HEAD(temp,dict(c,head='mask'),skin,hi,d)
 if green:
  for el in temp.iter():
   for a in ['fill','stroke']:
    if el.get(a) in ['#202527','#42494a']:el.set(a,{'#202527':GREEN[0],'#42494a':GREEN[1]}[el.get(a)])
 g.extend(list(temp))
def head(g,c,skin,hi,d='SE'):
 if not c.get('trc'):return base.head(g,c,skin,hi,d)
 r=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 if r=='rifle':return head(g,dict(c,role='shotgun'),skin,hi,d)
 if r in ['smg','shotgun','sniper']:mask(g,c,skin,hi,d,r=='smg')
 else:base.head(g,dict(c,cap=r=='pistol'),skin,hi,d)
 if r=='pistol' and not back:
  path(g,'M-6 -42 L6 -42 5 -38 2 -38 0 -40 -2 -38 -5 -38Z',BLACK[2],'#080f12',.7)
 if r=='sniper':
  # Hood border follows the existing head; the black mask remains visible.
  path(g,'M-7 -34 L-9 -40 Q-10 -51 -3 -54 Q3 -56 8 -50 L10 -40 7 -32 5 -33 6 -39 6 -46 Q0 -51 -5 -46 L-5 -39 -4 -33Z',GREEN[0],GREEN[2],.7)
  path(g,'M-7 -40 Q-9 -49 -3 -52 M7 -47 L8 -39','none',GREEN[1],.7)
  if back:path(g,'M-7 -45 Q0 -54 7 -45 L7 -35 Q0 -30 -7 -35Z',GREEN[0],GREEN[2],.6)
  return
 if r in ['smg','shotgun','rifle']:
  col=GREEN if r=='rifle' else BLACK
  shape='M-8 -42 L-8 -47 Q-7 -54 0 -54 Q8 -54 9 -47 L9 -39 6 -37 5 -44 -5 -44 -6 -37 -9 -39Z' if r=='shotgun' else 'M-8 -44 L-8 -48 Q-5 -54 1 -54 Q8 -53 9 -47 L8 -43 5 -43 4 -46 -4 -46 -5 -42 -8 -42Z'
  path(g,shape,col[0],col[2],.8)
  path(g,'M-5 -49 Q0 -53 5 -49','none',col[1],.8)
  if back:path(g,'M-7 -46 L7 -46 7 -40 -7 -40Z',col[0],col[2],.6)
  if r=='rifle' and not back:path(g,'M-6 -39 Q0 -37 6 -39 L5 -33 0 -31 -5 -34Z',BLACK[0],BLACK[2],.6)
  if r in ['smg','rifle']:
   for x in [-7,7]:
    path(g,f'M{x-1.2} -43 L{x+1.2} -43 {x+1.2} -37 {x-1.2} -37Z',BLACK[0],BLACK[2],.6)
   if not back:path(g,'M7 -39 L8 -35 3 -35','none',BLACK[1],.8)
   path(g,'M-5 -39 L-3 -34 3 -33 5 -39','none',BLACK[2],.7)
   if r=='smg':patch(g,6,-47,.55)

# Condensed block glyphs drawn as vectors, rasterized by the existing pixel pass.
PRINT_GOLD='#aaa078'
GLYPHS={
'T':['111','010','010','010','010'],'R':['110','101','110','101','101'],
'C':['111','100','100','100','111'],'E':['111','100','110','100','111'],
'X':['101','101','010','101','101'],'A':['010','101','111','101','101'],
'S':['111','100','111','001','111'],'O':['111','101','101','101','111'],
'V':['101','101','101','101','010'],'Y':['101','101','010','010','010'],
'L':['100','100','100','100','111'],'I':['111','010','010','010','111'],
'N':['101','111','111','111','101'],' ':['000']*5}
def print_line(g,text,y,width,height):
 cell=width/(len(text)*4-1);dy=height/5
 for i,ch in enumerate(text):
  for row,bits in enumerate(GLYPHS[ch]):
   for col,bit in enumerate(bits):
    if bit!='1':continue
    x=-width/2+(i*4+col)*cell;yy=y+row*dy
    path(g,f'M{x} {yy} h{cell*.94} v{dy*.94} h{-cell*.94}Z',PRINT_GOLD,'none')
def back_marking(t,d):
 # Parent is the animated, direction-transformed torso, not screen space.
 g=base.E.SubElement(t,N+'g',{'data-trc-back-marking':'true','transform':'scale(-1 1)' if d=='NW' else 'scale(1 1)'})
 print_line(g,'TRC',-26,16,5)
 # Established star-and-eye design, printed directly on the outer garment.
 e=base.E.SubElement(g,N+'g',{'transform':'translate(0 -15) scale(1.55)'})
 path(e,'M0 -2.5 L.7 -.7 2.6 -.7 1.1 .5 1.7 2.4 0 1.2 -1.7 2.4 -1.1 .5 -2.6 -.7 -.7 -.7Z',GREEN[0],PRINT_GOLD,.4)
 path(e,'M-1.2 0 Q0 -1.1 1.2 0 Q0 1 -1.2 0Z',PRINT_GOLD,'none')
 path(e,'M0 -.35 L0 .35','none',BLACK[2],.55)
 print_line(g,'TEXAS RECOVERY',-9,17,2.3)
 print_line(g,'COALITION',-5.8,12,2.3)
 # Tiny deterministic gaps resemble worn ink without adding a panel.
 for el in list(g):
  if el.tag!=N+'path':continue
  # Sparse missing ink cells, shared consistently by every outfit and pose.
  d=el.get('d','')
  if d.startswith('M-6.545454') or d.startswith('M4.363636'):el.set('opacity','.72')

def torso(g,c,skin,hi,d='SE'):
 if not c.get('trc'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 col=GREEN if r in ['pistol','rifle'] else BLACK
 if r=='sniper':
  for x,y in [(-10,-30),(-6,-32),(6,-32),(10,-30)]:
   path(t,f'M{x-1} {y} L{x+1} {y} {x+.7} {y+6} {x-.5} {y+4} {x-1.2} {y+7}Z',GREEN[1],GREEN[2],.4)
  if not back:
   path(t,'M-7 -30 L-5 -14 M7 -30 L5 -14','none',BLACK[0],1.8)
   path(t,'M-8 -20 L8 -20 8 -11 -8 -11Z',BLACK[0],BLACK[2],.6)
   for x in [-5,0,5]:path(t,f'M{x-1.6} -19 L{x+1.6} -19 {x+1.6} -12 {x-1.6} -12Z',BLACK[1],BLACK[2],.5)
 else:
  path(t,'M-8 -31 L-5 -32 -4 -26 4 -26 5 -32 9 -30 10 -17 10 0 -10 0 -10 -17Z',col[0],col[2],.6)
  path(t,'M-6 -24 L6 -24 7 -13 -7 -13Z',col[0],col[1],.6)
  if not back:
   if r in ['pistol','rifle']:patch(t,0,-20,.9)
   if r=='shotgun':
    for x in [-6,-3,0,3,6]:
     path(t,f'M{x-1} -16 L{x+1} -16 {x+1} -8 {x-1} -8Z',GREEN[0],BLACK[2],.5)
     path(t,f'M{x-1} -10 L{x+1} -10','none',GREEN[1],.8)
   else:
    for x in [-6,0,6]:
     path(t,f'M{x-1.8} -11 L{x+1.8} -11 {x+1.8} -3 {x-1.8} -3Z',BLACK[0],BLACK[2],.5)
     path(t,f'M{x-1} -9 L{x+1} -9','none',BLACK[1],.5)
 if back:back_marking(t,d)
 path(t,'M-10 -1 L11 -1','none',BLACK[2],2)
 if r=='pistol':path(t,'M8 0 L12 0 12 8 8 7Z',BLACK[0],BLACK[2],.6)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('trc'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='smg':
  end=a+(b-a)*.35
  base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none',BLACK[1],1.4)
 p=b-v*3
 path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',BLACK[0],BLACK[2],.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('trc'):return base.arm(g,a,b,h,c,skin,hi)
 r=c['role']
 if r=='pistol':base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 else:base.arm(g,a,b,h,dict(c,sleeve='short') if r=='smg' else c,skin,hi)
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if r=='shotgun':
  # Surface-mounted deltoid plate within the established arm silhouette.
  p=a+v*3;q=a+v*8
  path(g,f'M{xy(p-n*2.8)} Q{xy(a-v)} {xy(p+n*2.8)} L{xy(q+n*2.5)} Q{xy(q+v)} {xy(q-n*2.5)}Z',BLACK[0],BLACK[1],.6)
 if r in ['shotgun','sniper']:
  p=a+(b-a)*.5;patch(g,p[0],p[1],.65)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 if role!='pistol':
  for parent in list(root.iter()):
   for el in list(parent):
    if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
    nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
    if len(nums)!=12:continue
    ps=np.array(list(map(float,nums))).reshape(6,2)
    if np.linalg.norm(ps[2]-ps[3])/2>=3.5:continue
    a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);end=a+v*4.5
    col=GREEN if role=='rifle' else BLACK
    detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
    path(detail,f'M{xy(a+n*2.6)} L{xy(a-n*2.6)} L{xy(end-n*2.4)} Q{xy(end+v)} {xy(end+n*2.4)}Z',col[0],col[1],.55)
    parent.insert(list(parent).index(el)+2,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
