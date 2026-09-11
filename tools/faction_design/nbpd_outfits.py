"""NBPD regular uniforms on the accepted ordinary-unit rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='NEW BRIARPORT POLICE DEPARTMENT'
PREFIX='nbpd'
GREEN=('#284c3b','#496b50','#173528')
GOLD='#b59a55'
BLACK=('#1d2528','#3a4649','#0e171b')
WHITE=('#d7ded9','#f0f0e5','#98aaa5')
BLUE=(GREEN[1],)
DESCRIPTIONS={'pistol':'Green peaked cap / black aviators / white short-sleeve uniform',
'smg':'Green police cap / rolled white sleeves / black bulletproof vest',
'shotgun':'Green cowboy hat / gray hair + mustache / green police bomber',
'rifle':'Sandy side part / black aviators / white shirt + tucked black tie',
'sniper':'Green police cap / raised bomber collar / communications earpiece'}
NOTES={r:['Green pants / thin gold outer stripes','Black boots / fully equipped police duty belt'] for r in DESCRIPTIONS}
def spec(r):
 return base.costume(r,GREEN if r in ['shotgun','sniper'] else WHITE,'receding' if r=='shotgun' else 'sidepart',nbpd=True,role=r,ankle_boots=True,gloves=r in ['smg','shotgun','sniper'])
SPECS={r:spec(r) for r in DESCRIPTIONS}
for r,c in SPECS.items():c.update(pants=GREEN[0],pants_hi=GREEN[1],shoe=BLACK[0],shoe_hi=BLACK[1])
SPECS['pistol']['sleeve']='short'
EXTRA_PALETTE=base.EXTRA_PALETTE+list(GREEN)+list(WHITE)+list(BLACK)+[GOLD,'#8b7854','#b3a17c']

def badge(g,x,y,s=1):
 t=base.E.SubElement(g,N+'g',{'transform':f'translate({x} {y}) scale({s})'})
 path(t,'M-1.8 -2 L1.8 -2 2 .2 0 2.5 -2 .2Z',GOLD,'#6c5b31',.4)
 path(t,'M0 -1 L0 1','none','#e3cf8a',.5)
def patch(g,x,y,s=1):
 t=base.E.SubElement(g,N+'g',{'transform':f'translate({x} {y}) scale({s})'})
 path(t,'M-2.4 -2.6 Q0 -3.5 2.4 -2.6 L2.4 1 0 3 -2.4 1Z',GREEN[0],GOLD,.5)
 path(t,'M-1.3 1 L-1.3 -.5 0 -1.5 1.3 -.5 1.3 1Z',WHITE[0],'none')
def head(g,c,skin,hi,d='SE'):
 if not c.get('nbpd'):return base.head(g,c,skin,hi,d)
 r=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 temp=base.E.Element(N+'g');base.head(temp,c,skin,hi,d)
 hair,light={'pistol':('#513e2e','#7e6147'),'smg':('#202326','#42484a'),'shotgun':('#73766b','#a0a293'),'rifle':('#8b7854','#b3a17c'),'sniper':('#332b27','#5a4637')}[r]
 for el in temp.iter():
  for a in ['fill','stroke']:
   if el.get(a) in ['#332b27','#1b2225']:el.set(a,hair)
   elif el.get(a) in ['#5a4637','#42484a']:el.set(a,light)
 g.extend(list(temp))
 if r in ['pistol','rifle'] and not back:
  lens='M1 -42 L7 -42 Q8 -40 5 -38 Q2 -37 1 -42Z' if side else 'M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z'
  path(g,lens,BLACK[2],'#080f12',.65)
  path(g,'M-1 -41 L1 -41','none',BLACK[2],.6)
 if r=='pistol':
  path(g,'M-8 -45 L-9 -49 Q0 -54 9 -49 L8 -45Z',GREEN[0],GREEN[2],.7)
  path(g,'M-7 -45 L7 -45 7 -43 -7 -43Z',BLACK[0],BLACK[2],.5)
  if not back:
   path(g,'M-7 -43 Q0 -42 7 -44 L10 -41 Q1 -39 -6 -41Z',BLACK[0],BLACK[2],.65)
   badge(g,1,-47,.65)
 elif r in ['smg','sniper']:
  path(g,'M-7 -45 Q-7 -52 0 -52 Q7 -52 8 -45 L7 -43 -7 -44Z',GREEN[0],GREEN[2],.7)
  path(g,'M0 -51 L0 -46','none',GREEN[1],.55)
  if not back:
   path(g,'M-6 -44 Q0 -43 7 -45 L11 -42 Q3 -40 -5 -42Z',GREEN[0],GREEN[2],.6)
   patch(g,1,-47,.55)
 elif r=='shotgun':
  path(g,'M-7 -46 L-6 -53 Q-3 -55 0 -52 Q3 -55 6 -53 L8 -46Z',GREEN[0],GREEN[2],.7)
  path(g,'M-7 -47 Q0 -45 7 -47','none',BLACK[2],1.6)
  path(g,'M-12 -46 Q-8 -42 0 -44 Q8 -42 12 -46 L12 -43 Q7 -39 0 -41 Q-8 -39 -12 -43Z',GREEN[0],GREEN[2],.7)
  if not back:badge(g,0,-48,.55)
 if r=='sniper' and not back:
  path(g,'M7 -40 L7 -36 5 -34','none',BLACK[2],1.2)
  path(g,'M7 -38 Q9 -31 7 -28','none',BLACK[2],.55)

def belt(t,r,back):
 path(t,'M-10 -1 L11 -1','none',BLACK[2],2.3)
 for x in [-8,6]:path(t,f'M{x-1.6} -3 L{x+1.6} -3 {x+1.6} 3 {x-1.6} 3Z',BLACK[0],BLACK[2],.5)
 # Holster, radio, cuff case, baton and utility pouches use the existing waist.
 path(t,'M8 0 L12 0 12 7 9 8 8 4Z',BLACK[0],BLACK[2],.6)
 path(t,'M-12 -5 L-9 -5 -9 2 -12 2Z',BLACK[0],BLACK[2],.5)
 path(t,'M-11 -8 L-11 -5','none',BLACK[2],.7)
 path(t,'M-10 2 L-10 11','none',BLACK[2],1.4)
 path(t,'M-9 3 L-7 3','none',BLACK[1],.8)
 path(t,'M-4 0 Q-6 3 -4 4 Q-2 3 -4 0 M-1 0 Q-3 3 -1 4 Q1 3 -1 0','none','#66716e',.65)
 if not back:path(t,'M1 -2 L4 -2 4 0 1 0Z','none','#88938a',.6)
 if r=='rifle':
  for x in [-7,7]:path(t,f'M{x-1.8} -6 L{x+1.8} -6 {x+1.8} 1 {x-1.8} 1Z',BLACK[0],BLACK[2],.6)

def torso(g,c,skin,hi,d='SE'):
 if not c.get('nbpd'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 if r in ['shotgun','sniper']:
  if not back:
   deep=-19 if r=='shotgun' else -29
   path(t,f'M-4 -33 L4 -33 1 {deep} -1 {deep}Z',WHITE[0],GREEN[2],.5)
   path(t,'M-9 -31 L-7 -35 -4 -34 -2 -27Z M4 -34 L7 -35 10 -31 2 -27Z',GREEN[1],GREEN[2],.6)
   path(t,f'M0 {deep} L0 -3','none','#86978b',.65)
   badge(t,6,-23,.8)
   for x in [-7,7]:path(t,f'M{x-1} -14 L{x+1} -8','none',GREEN[2],.75)
  else:path(t,'M-7 -29 Q0 -27 7 -29','none',GREEN[2],.65)
  path(t,'M-10 -3 L10 -3','none',GREEN[2],2.1)
  for x in range(-9,10,2):path(t,f'M{x} -4 L{x} -2','none',GREEN[1],.4)
 else:
  if not back:
   path(t,'M-4 -33 L0 -29 4 -33 2 -25 0 -28 -2 -25Z',WHITE[1],WHITE[2],.5)
   path(t,'M0 -25 L0 -3','none',WHITE[2],.5)
   for x in [-6,6]:
    path(t,f'M{x-2.5} -22 L{x+2.5} -22 {x+2.5} -16 {x-2.5} -16Z',WHITE[0],WHITE[2],.5)
   if r=='rifle':
    path(t,'M-1 -28 L1 -28 1.8 -19 0 -16 -1.8 -19Z',BLACK[2],'none')
    path(t,'M-8 -29 L-5 -29 -5 -24 -8 -24Z',BLACK[0],BLACK[2],.5)
    path(t,'M-7 -24 Q-10 -16 -7 -4','none',BLACK[2],.55)
   badge(t,6,-23,.75)
   path(t,'M-8 -24 L-4 -24','none',GOLD,.9)
  for x in [-8,8]:path(t,f'M{x-2} -31 L{x+2} -30','none',WHITE[2],1.1)
 if r=='smg':
  path(t,'M-8 -30 L-5 -31 -3 -25 3 -25 5 -31 8 -30 9 -18 9 -3 -9 -3 -9 -18Z',BLACK[0],BLACK[2],.6)
  path(t,'M-7 -18 L7 -18 M-7 -7 L7 -7','none',BLACK[1],.6)
  if not back:badge(t,5,-22,.8)
  else:
   # Small geometric lettering stays legible without an external font.
   letters={'P':[(0,0,0,4),(0,0,2,0),(2,0,2,2),(0,2,2,2)],
   'O':[(0,0,2,0),(0,0,0,4),(2,0,2,4),(0,4,2,4)],
   'L':[(0,0,0,4),(0,4,2,4)],'I':[(1,0,1,4)],
   'C':[(0,0,2,0),(0,0,0,4),(0,4,2,4)],
   'E':[(0,0,0,4),(0,0,2,0),(0,2,2,2),(0,4,2,4)]}
   for i,ch in enumerate('POLICE'):
    for x1,y1,x2,y2 in letters[ch]:path(t,f'M{-7.8+i*2.6+x1*.8} {-23+y1*.8} L{-7.8+i*2.6+x2*.8} {-23+y2*.8}','none',WHITE[1],.55)
 belt(t,r,back)

def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('nbpd'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role'] in ['shotgun','sniper','rifle']:
  p=b-v*2.5
  path(g,f'M{xy(p-n*2.5)} L{xy(p+n*2.5)}','none',c['shade'],1.4)
 if c.get('gloves'):
  p=b-v*3
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',BLACK[0],BLACK[2],.5)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('nbpd'):return base.arm(g,a,b,h,c,skin,hi)
 if c['role']=='pistol':base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 else:base.arm(g,a,b,h,dict(c,sleeve='short') if c['role']=='smg' else c,skin,hi)
 a,b=np.array(a,float),np.array(b,float)
 p=a+(b-a)*.36;patch(g,p[0],p[1],.65)
 if c['role']=='smg':
  v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
  p=b-v*1.5;path(g,f'M{xy(p-n*2.7)} L{xy(p+n*2.7)}','none',WHITE[1],1.6)
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role]
 for parent in list(root.iter()):
  for el in list(parent):
   if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
   nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
   radius=np.linalg.norm(ps[2]-ps[3])/2
   # Follow the outer cloth edge; lower stripes stop at the boot top.
   sign=-1 if a[0]<0 else 1
   off=sign*max(.6,radius-.7)
   end=b-v*(5 if radius<3.5 else 1)
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   path(detail,f'M{xy(a+v+n*off)} L{xy(end+n*off)}','none',GOLD,.65)
   parent.insert(list(parent).index(el)+2,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
