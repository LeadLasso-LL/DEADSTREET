"""Bitian regular outfits on the accepted normal rig."""
from pathlib import Path
import sys,copy
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE=base.N,base.path,base.xy,base.BASE
np=base.np
KIND=2
TITLE='B\u00ecti\u0101n'.upper()
PREFIX='bitian'
BLUE=('#518480',)
DESCRIPTIONS={'pistol':'Curtain hair / black shades / patterned cream shirt / white tank',
'smg':'Messy fringe / teal-charcoal windbreaker / blue jeans / white runners',
'shotgun':'Black flat-top / rectangular shades / leather jacket / burgundy polo',
'rifle':'Combed-back hair / brown suede jacket / beige polo / magazine belt',
'sniper':'Forward black cap / collar-length hair / olive field jacket / face cloth'}
NOTES={'pistol':['Black pleated trousers / leather loafers','Gold chain / muted geometric print'],
'smg':['White tee / silver wristwatch','Retro white running shoes'],
'shotgun':['Broad leather collar / gold ring','Charcoal jeans / black work boots'],
'rifle':['Waist-length jacket / tucked fine knit','Pleated charcoal trousers / black shoes'],
'sniper':['Raised collar / black crewneck','Gray utility pants / black boots and gloves']}
def outfit(role,colors,head='combed',**kw):
 return base.costume(role,colors,head,bitian=True,role=role,**kw)
SPECS={'pistol':outfit('pistol',('#c2b9a1','#e0d7be','#8b806c'),chain=True),
'smg':outfit('smg',('#2a6766','#508783','#193e42'),watch=True),
'shotgun':outfit('shotgun',('#21282c','#475155','#10191e'),ring=True,ankle_boots=True),
'rifle':outfit('rifle',('#49392e','#6b5542','#2c261f'),'slicklong'),
'sniper':outfit('sniper',('#3d4937','#606b50','#263024'),'slicklong',cap=True,gloves=True,ankle_boots=True)}
SPECS['pistol']['sleeve']='short'
SPECS['smg'].update(pants='#435d70',pants_hi='#708695',shoe='#d8dbd2',shoe_hi='#efeee2')
SPECS['shotgun'].update(pants='#343b3f',pants_hi='#535e65')
SPECS['rifle'].update(pants='#30383d',pants_hi='#505c62')
SPECS['sniper'].update(pants='#41494f',pants_hi='#636f77')
EXTRA_PALETTE=base.EXTRA_PALETTE+['#c2b9a1','#e0d7be','#8b806c','#2a6766','#508783','#193e42','#435d70','#708695','#d8dbd2','#efeee2','#3d4937','#606b50','#263024','#60363e','#85505b','#b7aa8c','#ded1af','#b8c3c4']
def head(g,c,skin,hi,d='SE'):
 if not c.get('bitian'):return base.head(g,c,skin,hi,d)
 role=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 base.head(g,c,skin,hi,d)
 if role=='pistol':
  # Center part and cheekbone-length curtains, open at the face.
  path(g,'M0 -49 Q-6 -52 -7 -46 L-7 -37 -4 -35 -4 -42 -1 -45Z M1 -49 Q7 -51 8 -45 L7 -36 4 -35 4 -42 2 -45Z','#161e22','#101619',.55)
  path(g,'M-1 -49 L-3 -44 -5 -38 M2 -48 L4 -43 5 -38','none','#424c50',.65)
  if back:path(g,'M-6 -44 L6 -44 5 -36 0 -34 -5 -36Z','#161e22','none')
 elif role=='smg':
  path(g,'M-7 -44 L-7 -48 -4 -50 -1 -49 2 -51 6 -48 7 -44 4 -43 3 -45 0 -42 -1 -44 -4 -42 -4 -44Z','#141c20','#101619',.5)
  path(g,'M-4 -47 L-2 -44 M1 -48 L0 -45 M4 -47 L3 -44','none','#424c50',.65)
 elif role=='shotgun':
  path(g,'M-6 -44 L-6 -50 L5 -50 7 -48 7 -44 4 -44 4 -46 -4 -46 -4 -44Z','#141c20','#101619',.55)
  path(g,'M-5 -49 L4 -49','none','#424c50',.6)
 if role in ['pistol','shotgun'] and not back:
  bottom=-40 if role=='pistol' else -38.5
  shape=f'M1 -42 L7 -42 6 {bottom} 2 {bottom}Z' if side else f'M-6 -42 L-1 -42 -1 {bottom} -6 {bottom}Z M1 -42 L6 -42 6 {bottom} 1 {bottom}Z'
  path(g,shape,'#101619','#080f13',.6 if role=='pistol' else 1)
  path(g,'M-1 -41 L1 -41 M-7 -42 L-6 -41 M6 -41 L7 -42','none','#080f13',.65)
 if role=='sniper' and not back:
  path(g,'M-6 -39 Q0 -37 6 -39 L6 -34 2 -31 -4 -33 -6 -36Z','#343d41','#10181c',.6)
  path(g,'M-4 -35 Q0 -33 4 -35','none','#535f65',.6)
def print_motif(g,x,y):
 path(g,f'M{x} {y-1.4} L{x+1.5} {y} {x} {y+1.4} {x-1.5} {y}Z','none','#8b806c',.5)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('bitian'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0]
 role=c['role'];back=d in ['N','NE','NW']
 if role=='pistol':
  for x in ([-7,-2,3,8] if back else [-8,8]):
   for y in [-26,-19,-12,-5]:print_motif(t,x,y)
 if role=='smg':
  path(t,'M-11 -29 Q0 -34 11 -29 L11 -22 Q0 -26 -11 -22Z','#303a41',c['shade'],.55)
  path(t,'M-10 -22 Q0 -26 10 -22','none','#b8c3c4',.65)
 if back:
  path(t,'M-7 -29 Q0 -27 7 -29 M0 -24 L0 -4','none',c['shade'],.6)
  return
 if role in ['pistol','smg']:
  path(t,'M-5 -32 Q0 -27 5 -32 L5 0 -5 0Z','#d8dbd2','#9ba6a2',.5)
  path(t,'M-4 -30 Q0 -25 4 -30','none','#efeee2',.65)
  if role=='pistol':
   for x in [-3,-1,1,3]:path(t,f'M{x} -23 L{x} -3','none','#b5bdb5',.35)
   path(t,'M-6 -32 L-2 -27 -5 -23 -8 -29Z M6 -32 L2 -27 5 -23 8 -29Z',c['lit'],c['shade'],.55)
   path(t,'M-3 -30 Q0 -23 3 -30','none',base.GOLD[0],.75)
  else:
   path(t,'M-7 -31 L-5 -23 -5 0 M7 -31 L5 -23 5 0','none','#b8c3c4',.55)
   path(t,'M-10 -2 L-6 -1 M6 -1 L10 -2','none',c['shade'],1.5)
 elif role in ['shotgun','rifle']:
  fill,light,shade=('#60363e','#85505b','#3d272e') if role=='shotgun' else ('#b7aa8c','#ded1af','#8b806c')
  path(t,'M-5 -32 L5 -32 5 0 -5 0Z',fill,shade,.55)
  path(t,'M-4 -32 L0 -28 4 -32 2 -25 0 -27 -2 -25Z',light,shade,.5)
  path(t,'M0 -26 L0 -21','none',shade,.65)
  if role=='rifle':
   for y in [-18,-14,-10,-6]:path(t,f'M-3 {y} L3 {y}','none',shade,.3)
  path(t,'M-8 -31 L-5 -35 -1 -26 -5 -21 -6 -27 -10 -26Z M5 -35 L9 -30 10 -26 6 -27 5 -21 1 -26Z',c['lit'],c['shade'],.65)
  path(t,'M-9 -12 L-6 -11 M6 -11 L9 -12','none',c['lit'],.6)
  if role=='rifle':
   path(t,'M-10 -2 Q0 0 11 -2','none','#11191d',2)
   for x in [-7,6]:path(t,f'M{x-1.7} -5 L{x+1.7} -5 {x+1.7} 1 {x-1.7} 1Z','#171f24','#080f13',.55)
 else:
  path(t,'M-5 -34 L5 -34 5 -23 -5 -23Z','#151d22','#101619',.5)
  path(t,'M-4 -32 Q0 -29 4 -32','none','#343d41',.7)
  path(t,'M-10 -31 L-7 -37 -4 -35 -3 -27Z M4 -35 L7 -37 10 -31 3 -27Z',c['cloth'],c['shade'],.65)
  path(t,'M0 -25 L0 0','none',c['shade'],.75)
  for x in [-7,7]:
   path(t,f'M{x-2.2} -23 L{x+2.2} -23 {x+2.2} -16 {x-2.2} -16Z',c['cloth'],c['shade'],.6)
   path(t,f'M{x-2} -21 L{x+2} -21','none',c['lit'],.6)
  for y in [-23,-16,-9,-2]:path(t,f'M1 {y} L1 {y+.4}','none',c['lit'],.8)
def forearm(g,a,b,c,skin,hi,r=3.1):
 start=len(g);base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('bitian'):return
 if c.get('watch'):
  for el in list(g)[start:]:
   for k in ['fill','stroke']:
    if el.get(k) in base.GOLD:el.set(k,'#b8c3c4')
 a,b=np.array(a,float),np.array(b,float);v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
 if c['role']=='smg':
  p=a+(b-a)*.35
  path(g,f'M{xy(p-n*2.5)} L{xy(p+n*2.5)}','none','#303a41',2)
 if c.get('ring') and c.get('watch_arm'):
  p=b+v*.5+n*1.3
  path(g,f'M{xy(p-v*.7)} L{xy(p+v*.7)}','none',base.GOLD[0],1)
def arm(g,a,b,h,c,skin,hi):
 if c.get('bitian') and c['sleeve']=='short':
  return base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
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
   ps=np.array(list(map(float,nums))).reshape(6,2);a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);radius=np.linalg.norm(ps[2]-ps[3])/2
   detail=base.E.Element(N+'g',{'data-garment-detail':'true'})
   if role in ['pistol','rifle']:
    path(detail,f'M{xy(a+v*2)} L{xy(b-v*2)}','none',c['pants_hi'],.55)
   if role=='sniper' and radius<3.5:
    for t in [2,3.5,5]:
     p=b-v*t
     path(detail,f'M{xy(p-n*1.2)} L{xy(p+v*.7+n*1.2)}','none','#77817e',.55)
   parent.insert(list(parent).index(el)+1,detail)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
