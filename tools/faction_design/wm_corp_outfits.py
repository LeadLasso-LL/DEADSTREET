"""Original W&M Corporation wardrobe, replacing the borrowed outfit set."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='WHITTAKER-MCALLISTER CORP.'
PREFIX='wm_corp'
BLUE=('#a29475',)
IVORY=('#d5cdb7','#eee6d1','#a59a82')
DENIM=('#587080','#7d92a0','#344d60')
BROWN=('#725239','#967253','#473729')
CAMO=('#645642','#89785a','#3e3c30')
GREEN=('#acbaa0','#d0d8bd','#7f9377')
DESCRIPTIONS={'pistol':'Chestnut hair + black shades / ivory knit polo / slate chinos',
'smg':'Forward tan cap + auburn mullet / sleeveless denim / white tank',
'shotgun':'Navy trucker cap + thick beard / tobacco chore coat / rust henley',
'rifle':'Blonde hair / brown quilted vest / rolled pale green shirt',
'sniper':'Brown hunting cap + sandy hair / brown woodland jacket + gaiter'}
NOTES={'pistol':['McAllister / gold watch / brown belt','Dark brown suede loafers'],
'smg':['Whittaker / tattooed bare arms','Charcoal jeans / tan work boots'],
'shotgun':['Whittaker / patched blue jeans','Dark brown steel-toe boots'],
'rifle':['McAllister / navy utility trousers','Magazine belt / brown boots / black gloves'],
'sniper':['Whittaker / olive pants + brown knees','Muddy dark brown boots / brown gloves']}
def spec(r,col,h='combed',**kw):
 return base.costume(r,col,h,wm=True,role=r,**kw)
SPECS={'pistol':spec('pistol',IVORY,'slicklong',watch=True,glasses='wayfarer'),
'smg':spec('smg',DENIM,'slicklong',tattoo=True,ankle_boots=True),
'shotgun':spec('shotgun',BROWN,'slicklong',ankle_boots=True),
'rifle':spec('rifle',GREEN,'sidepart',gloves=True,ankle_boots=True),
'sniper':spec('sniper',CAMO,'slicklong',gloves=True,ankle_boots=True)}
for r in ['pistol','smg','rifle']:SPECS[r]['sleeve']='short'
SPECS['pistol'].update(pants='#4b6275',pants_hi='#718598',shoe='#49372c',shoe_hi='#705946')
SPECS['smg'].update(pants='#363b3e',pants_hi='#565e63',shoe='#957346',shoe_hi='#b69968')
SPECS['shotgun'].update(pants='#425d73',pants_hi='#6b8396',shoe='#3b2e26',shoe_hi='#64503c')
SPECS['rifle'].update(pants='#26374a',pants_hi='#43576d',shoe='#423127',shoe_hi='#6d5440')
SPECS['sniper'].update(pants='#62684c',pants_hi='#868b69',shoe='#3c3329',shoe_hi='#655844')
EXTRA_PALETTE=base.EXTRA_PALETTE+list(IVORY)+list(DENIM)+list(BROWN)+list(CAMO)+list(GREEN)+['#80553d','#ab7852','#987d53','#bba177','#273e51','#4b6172','#873f2a','#a45d40','#443e32','#857052','#383b31','#9a8968']
def head(g,c,skin,hi,d='SE'):
 if not c.get('wm'):return base.head(g,c,skin,hi,d)
 r=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 hair,light={'pistol':('#593d2c','#80553d'),'smg':('#744530','#ab7852'),'shotgun':('#3a2d24','#624733'),'rifle':('#a18a51','#c5ae72'),'sniper':('#987d53','#bba177')}[r]
 if r=='sniper':
  path(g,'M-7 -44 Q0 -51 7 -44 L9 -32 7 -26 4 -29 1 -27 -3 -29 -7 -26 -9 -33Z',hair,'#3b3229',.6)
 temp=base.E.Element(N+'g');base.head(temp,c,skin,hi,d)
 for e in temp.iter():
  for a in ['fill','stroke']:
   if e.get(a) in ['#332b27','#1b2225']:e.set(a,hair)
   elif e.get(a) in ['#5a4637','#42484a']:e.set(a,light)
 g.extend(list(temp))
 if r=='rifle' and not back:
  path(g,'M3 -41 L5 -41 M3 -35 L5 -35' if side else 'M-3 -40.5 L-1 -40.5 M2 -40.5 L4 -40.5 M-1 -35 L2 -35','none','#49382e',.65)
 if r in ['smg','shotgun','sniper']:
  for x in [-6,6]:
   path(g,f'M{x} -42 L{x+(.5 if x>0 else -.5)} -32','none',light,.7)
  if not back:
   if r=='shotgun':
    path(g,'M-6 -39 L-4 -36 0 -37 5 -36 7 -40 6 -32 2 -28 -3 -30 -6 -34Z',hair,'none')
    path(g,'M-3 -34 L-2 -31 M1 -33 L2 -30 M4 -34 L4 -32','none',light,.65)
   else:path(g,'M-5 -37 L-2 -34 2 -34 6 -38 5 -33 1 -31 -4 -33Z',hair,'none')
  hat,lit,shade={'smg':('#9b855e','#bca780','#68583e'),'shotgun':('#273e51','#4b6172','#162a37'),'sniper':('#6b543a','#937756','#433928')}[r]
  path(g,'M-7 -45 Q-7 -52 0 -52 Q7 -52 8 -45 L7 -43 -7 -44Z',hat,shade,.7)
  path(g,'M-1 -51 L1 -45','none',lit,.65)
  if not back:path(g,'M-6 -44 Q0 -43 7 -45 L12 -42 Q4 -40 -5 -42Z',hat,shade,.65)
  if r=='shotgun':
   for x in [-5,-2,1,4]:path(g,f'M{x} -49 L{x+1} -45','none',lit,.4)
   path(g,'M-5 -47 L5 -47','none',lit,.35)
  if r=='sniper' and not back:
   path(g,'M-6 -39 Q0 -36 6 -39 L6 -33 1 -30 -5 -33Z','#6a5940','#3e3c30',.6)
   path(g,'M-4 -37 L-1 -38 1 -35 -1 -33 -4 -34Z','#443e32','none')
   path(g,'M2 -36 L5 -37 4 -33 2 -33Z','#9a8968','none')

def woodland(g):
 for x,y,col in [(-6,-26,'#857052'),(4,-24,'#383b31'),(-3,-18,'#443e32'),(7,-13,'#9a8968'),(-6,-9,'#383b31'),(2,-5,'#857052')]:
  path(g,f'M{x-2} {y-2} Q{x} {y-4} {x+3} {y-1} L{x+2} {y+2} {x-1} {y+3} {x-3} {y}Z',col,'none')
def torso(g,c,skin,hi,d='SE'):
 if not c.get('wm'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 if r=='pistol':
  if not back:
   path(t,'M-4 -32 L0 -28 4 -32 2 -25 0 -27 -2 -25Z',IVORY[1],'#49372c',.7)
   path(t,'M0 -26 L0 -20','none',IVORY[2],.6)
   for y in [-18,-14,-10,-6]:path(t,f'M-7 {y} L8 {y}','none',IVORY[2],.25)
  path(t,'M-10 -1 L11 -1','none','#513b2a',2)
 elif r in ['smg','shotgun']:
  if not back:
   fill='#deded0' if r=='smg' else '#873f2a'
   path(t,'M-5 -32 L5 -32 5 -1 -5 -1Z',fill,c['shade'],.5)
   path(t,'M-4 -31 Q0 -26 4 -31','none','#a6afa8' if r=='smg' else '#a45d40',.7)
   if r=='shotgun':
    path(t,'M0 -28 L0 -20','none','#56372b',.7)
    for y in [-26,-23]:path(t,f'M1 {y} L1 {y+.4}','none','#c09265',.7)
   path(t,'M-8 -32 L-5 -34 -3 -30 -5 -25Z M5 -34 L8 -31 5 -25 3 -30Z',c['lit'],c['shade'],.6)
   path(t,'M-5 -26 L-5 -1 M5 -26 L5 -1','none',c['lit'],.6)
   for x in [-8,8]:
    path(t,f'M{x-2} -19 L{x+2} -19 {x+2} -12 {x-2} -12Z',c['cloth'],c['shade'],.6)
   if r=='shotgun':
    for x in [-8,8]:path(t,f'M{x-2} -10 L{x+2} -10 {x+2} -3 {x-2} -3Z',c['cloth'],c['shade'],.6)
  else:path(t,'M-8 -28 Q0 -26 8 -28 M0 -25 L0 -2','none',c['shade'],.6)
 elif r=='rifle':
  path(t,'M-8 -31 L-5 -32 -3 -26 3 -26 5 -32 8 -31 10 -15 10 0 -10 0 -10 -15Z','#493a2d','#2e2822',.6)
  # Compact stitched diamonds contained within the vest.
  for y in [-22,-16,-10]:
   for x in [-6,0,6]:
    path(t,f'M{x} {y-3} L{x+2.5} {y} {x} {y+3} {x-2.5} {y}Z','none','#79624c',.45)
  if not back:
   path(t,'M-4 -33 L0 -29 4 -33 2 -25 0 -28 -2 -25Z',GREEN[1],GREEN[2],.55)
   path(t,'M0 -24 L0 -1','none','#2e2822',.8)
  path(t,'M-10 -1 L11 -1','none','#111819',2)
  for x in [-7,7]:path(t,f'M{x-1.7} -5 L{x+1.7} -5 {x+1.7} 2 {x-1.7} 2Z','#202629','#111819',.55)
 else:
  woodland(t)
  if not back:
   path(t,'M-9 -31 L-7 -36 -4 -35 -2 -27Z M4 -35 L7 -36 10 -31 2 -27Z',CAMO[1],CAMO[2],.6)
   path(t,'M0 -27 L0 -1','none',CAMO[2],.65)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('wm'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if c['role']=='rifle':
  end=a+(b-a)*.38;base.ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end-n*2.5)} L{xy(end+n*2.5)}','none',GREEN[1],1.5)
 if c.get('gloves'):
  p=b-v*3;fill='#513f2c' if c['role']=='sniper' else '#131c20'
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(b+n*2)} Q{xy(b+v*.6)} {xy(b-n*2)}Z',fill,'#171d1c',.5)
 if c['role']=='sniper':
  p=a+(b-a)*.5
  path(g,f'M{xy(p-v*2+n*2)} L{xy(p+v*2+n)} L{xy(p+v*3-n*2)} L{xy(p-v-n)}Z','#443e32','none')
def arm(g,a,b,h,c,skin,hi):
 if not c.get('wm'):return base.arm(g,a,b,h,c,skin,hi)
 r=c['role']
 if r=='pistol':base.shared.arm(g,a,b,h,dict(c,eastex=True),skin,hi)
 elif r=='smg':base.arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade=skin),skin,hi)
 else:base.arm(g,a,b,h,c,skin,hi)
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 if r=='smg':
  for f in [.25,.45,.65]:
   p=a+(b-a)*f;path(g,f'M{xy(p-n*2)} Q{xy(p+v)} {xy(p+n*2)}','none','#3c4948',.7)
 if r=='sniper':
  for f,col in [(.3,'#857052'),(.6,'#383b31')]:
   p=a+(b-a)*f;path(g,f'M{xy(p-v*2+n*2)} L{xy(p+v*2+n)} L{xy(p+v*3-n*2)} L{xy(p-v-n)}Z',col,'none')
def make(role,model,direction,**state):
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state);c=SPECS[role];patched=False
 if role in ['shotgun','sniper']:
  for parent in list(root.iter()):
   for el in list(parent):
    if el.get('fill')!=c['pants'] or base.re.search('[QCAqca]',el.get('d','')):continue
    nums=base.re.findall(r'-?\d+(?:\.\d+)?',el.get('d',''))
    if len(nums)!=12:continue
    ps=np.array(list(map(float,nums))).reshape(6,2)
    if np.linalg.norm(ps[2]-ps[3])/2>=3.5:continue
    if role=='shotgun' and patched:continue
    a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2;v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]]);end=a+v*5
    q=base.E.Element(N+'g',{'data-garment-detail':'true'})
    fill='#374a5a' if role=='shotgun' else '#67513a'
    path(q,f'M{xy(a-n*2.7)} L{xy(a+n*2.7)} L{xy(end+n*2.5)} L{xy(end-n*2.5)}Z',fill,'#9a8968',.45)
    parent.insert(list(parent).index(el)+2,q);patched=True
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
