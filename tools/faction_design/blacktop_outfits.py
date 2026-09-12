"""Blacktop Apostles MC regular leather outfits on the accepted human rig."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE,np=base.N,base.path,base.xy,base.BASE,base.np
KIND=1
TITLE='BLACKTOP APOSTLES MC'
PREFIX='blacktop'
BLACK=('#242b2e','#485154','#111a1e')
RUST=('#854a34','#aa6c4b','#533327')
IVORY='#c5b89a'
ORANGE='#a35e36'
SILVER='#a4ada9'
BLUE=(ORANGE,)
DESCRIPTIONS={
'pistol':'Slick brown hair + horseshoe mustache / aviators / leather + rust henley',
'smg':'Low red-brown ponytail / bare-chest leather vest / faded tattoos',
'shotgun':'Half-shell helmet + emblem / long hair + gray beard / leather jacket',
'rifle':'Orange forehead bandana / drooping mustache / vest + charcoal denim',
'sniper':'Black hood + long hair / charcoal face bandana / leather club jacket'}
NOTES={
'pistol':['Rolled sleeves / charcoal jeans / brown pointed boots','Tattooed forearms / silver chain bracelet'],
'smg':['Washed gray jeans / torn knee / heavy wallet chain','Black buckle boots / fingerless gloves'],
'shotgun':['Black wraparound shades / offset zip / ivory thermal','Faded black jeans / harness boots / gloves'],
'rifle':['Brown work trousers / black lace-up boots','Magazine pouches / silver rings / forearm tattoos'],
'sniper':['Half-zipped jacket / hood above back patch','Dark gray jeans / black side-buckle boots / gloves']}
SPECS={r:base.costume(r,BLACK,'slicklong' if r in ['pistol','shotgun'] else 'combed',apostles=True,role=r,ankle_boots=True) for r in DESCRIPTIONS}
for r in ['pistol','smg','rifle']:SPECS[r]['sleeve']='short'
for r,p,ph,s,sh in [
('pistol','#353d41','#576166','#493428','#70513b'),
('smg','#747977','#979f94','#1a2327','#3d494c'),
('shotgun','#2d363a','#515d60','#182125','#3e4b4e'),
('rifle','#473b2c','#6d5b46','#1b2427','#424d4d'),
('sniper','#353e42','#59656a','#192226','#3b484c')]:
 SPECS[r].update(pants=p,pants_hi=ph,shoe=s,shoe_hi=sh)
EXTRA_PALETTE=base.EXTRA_PALETTE+list(BLACK)+list(RUST)+[IVORY,ORANGE,SILVER,'#62432e','#946b47','#a89d7f','#d1c3a0','#3f4749','#636e6e']
GLYPHS={
'B':['110','101','110','101','110'],'L':['100','100','100','100','111'],
'A':['010','101','111','101','101'],'C':['111','100','100','100','111'],
'K':['101','101','110','101','101'],'T':['111','010','010','010','010'],
'O':['111','101','101','101','111'],'P':['110','101','110','100','100'],
'S':['111','100','111','001','111'],'E':['111','100','110','100','111'],
'M':['101','111','111','101','101']}
def letters(g,text,y,width,height):
 dx=width/(len(text)*4-1);dy=height/5
 for i,ch in enumerate(text):
  for row,bits in enumerate(GLYPHS[ch]):
   for col,bit in enumerate(bits):
    if bit=='1':
     x=-width/2+(i*4+col)*dx;yy=y+row*dy
     path(g,f'M{x} {yy} h{dx*.9} v{dy*.9} h{-dx*.9}Z',IVORY,'none')
def emblem(g,x=0,y=0,scale=1):
 t=base.E.SubElement(g,N+'g',{'transform':f'translate({x} {y}) scale({scale})','data-apostles-emblem':'hooded-skeleton-cracked-halo'})
 path(t,'M0 -8 A8 8 0 1 1 -.01 -8Z',BLACK[2],ORANGE,.65)
 # Broken halo around the hood, gaps are intentional.
 path(t,'M-4 -3 A4.9 4.9 0 0 1 -2 -7 M-.8 -7.6 A4.9 4.9 0 0 1 4.8 -3.5 M4.6 -2 L3.8 -.7','none',ORANGE,.8)
 path(t,'M-2.3 -7.2 L-1.9 -6.1 -.9 -6.8 M3.4 -6 L4.3 -5.6 3.7 -4.8','none',IVORY,.35)
 # Hood, ivory skull, skeletal hands on the bars and small round headlamp.
 path(t,'M-5 4 L-4 -1 Q-2 -5 0 -5 Q3 -4 4 -1 L5 4 2 3 0 5 -2 3Z','#30312c',ORANGE,.45)
 path(t,'M-2 -1 Q-2 -3 0 -3 Q2 -3 2 -1 L1.5 1 .8 2 -.8 2 -1.5 1Z',IVORY,'#70634b',.35)
 path(t,'M-1.5 -1 L-.3 -.6 -.7 .3 -1.4 -.1Z M.3 -.6 L1.5 -1 1.4 -.1 .7 .3Z M0 .3 L-.4 1 .4 1Z',BLACK[2],'none')
 path(t,'M-.9 1.4 L.9 1.4 M-.3 1.2 L-.3 1.9 M.3 1.2 L.3 1.9','none',BLACK[2],.3)
 path(t,'M-6 3 L-3 2 0 5 3 2 6 3 M-5 3 L-4 6 M5 3 L4 6','none',IVORY,.55)
 for x in [-5,5]:
  path(t,f'M{x-.8} 2 L{x-.8} 3 M{x} 1.8 L{x} 3 M{x+.8} 2 L{x+.8} 3','none',IVORY,.45)
 path(t,'M0 4 A1.6 1.6 0 1 1 -.01 4Z','#80775f',IVORY,.45)
 path(t,'M-2 7 L-3 5 M2 7 L3 5','none',ORANGE,.45)
def back_patch(t,d):
 # Inverse local mirror preserves lettering under the NW torso reflection.
 g=base.E.SubElement(t,N+'g',{'transform':'scale(-1 1)' if d=='NW' else 'scale(1 1)','data-apostles-back-patch':'true'})
 path(g,'M-9 -30 L9 -30 9 -23 -9 -23Z',BLACK[2],ORANGE,.45)
 letters(g,'BLACKTOP',-29,16,2.1)
 letters(g,'APOSTLES',-26,16,2.1)
 emblem(g,0,-14,.88)
 path(g,'M-3 -5 L3 -5 3 -1 -3 -1Z',BLACK[2],ORANGE,.4)
 letters(g,'MC',-4.4,4.6,2.8)
 # Sparse abrasion confined to patches, deterministic across poses.
 path(g,'M-8 -28 l1 .3 M6 -24 l1 -.3','none',BLACK[1],.4)
def chest_patches(t):
 for x in [-8,8]:
  path(t,f'M{x-2.2} -24 h4.4 v3 h-4.4Z',BLACK[2],ORANGE,.45)
  path(t,f'M{x-1.3} -22.7 h2.6','none',IVORY,.5)
 emblem(t,-8,-17,.28)
 path(t,'M6 -18 h4 v3 h-4Z',BLACK[2],ORANGE,.4)
 path(t,'M7 -17 h2','none',IVORY,.45)
def hair_recolor(tmp,hair,light):
 for el in tmp.iter():
  for a in ['fill','stroke']:
   if el.get(a) in ['#1b2225','#42484a']:
    el.set(a,{'#1b2225':hair,'#42484a':light}[el.get(a)])
def head(g,c,skin,hi,d='SE'):
 if not c.get('apostles'):return base.head(g,c,skin,hi,d)
 r=c['role'];back=d in ['N','NE','NW'];side=d in ['E','W']
 hair={'pistol':'#3c2e26','smg':'#62432e','shotgun':'#382e28','rifle':'#8d8064','sniper':'#161f23'}[r]
 light={'pistol':'#634934','smg':'#946b47','shotgun':'#67533d','rifle':'#b9ab87','sniper':'#3d494b'}[r]
 if r=='smg' and back:
  path(g,'M-2 -37 L2 -37 4 -30 2 -24 -1 -25 -2 -30Z',hair,BLACK[2],.5)
  path(g,'M0 -33 L1 -27','none',light,.6)
 if r=='shotgun':
  path(g,'M-7 -44 Q0 -49 7 -44 L8 -32 6 -26 3 -30 -4 -29 -7 -26 -9 -33Z',hair,BLACK[2],.6)
 tmp=base.E.Element(N+'g');base.head(tmp,c,skin,hi,d);hair_recolor(tmp,hair,light);g.extend(list(tmp))
 if r=='smg':
  path(g,'M-6 -45 Q0 -50 6 -45 M-5 -43 Q0 -48 5 -43','none',light,.65)
  if back:path(g,'M-3 -38 L3 -38','none',BLACK[2],1.3)
 if r=='rifle':
  path(g,'M-6 -45 L-6 -39 -4 -39 -4 -45Z M4 -45 L6 -45 6 -39 4 -39Z','#706b59','none')
  path(g,'M-6 -46 L-5 -50 -2 -49 0 -51 3 -49 5 -49 6 -46Z',hair,'none')
  path(g,'M-7 -45 Q0 -47 7 -45 L7 -42 Q0 -44 -7 -42Z',RUST[0],RUST[2],.5)
  path(g,'M-5 -44 L4 -44','none',RUST[1],.5)
  if back:path(g,'M0 -44 L3 -42 4 -37 1 -39 -2 -37 -3 -40Z',RUST[0],RUST[2],.4)
 if r=='shotgun':
  if back:
   path(g,'M-6 -40 L-7 -29 M-3 -39 L-4 -28 M4 -40 L5 -29','none',light,.65)
  path(g,'M-8 -43 L-8 -48 Q-5 -54 1 -54 Q8 -53 9 -47 L8 -43Z',BLACK[0],BLACK[2],.8)
  path(g,'M-5 -49 Q0 -52 5 -49 M-7 -45 L-5 -46 M5 -47 L7 -46','none','#68716b',.65)
  if not back:emblem(g,0,-48,.31)
  path(g,'M-7 -42 L-5 -35 M7 -42 L5 -35','none',BLACK[2],.7)
 if r=='sniper':
  path(g,'M-7 -34 L-9 -40 Q-10 -51 -3 -54 Q3 -56 8 -50 L10 -40 7 -32 -6 -32Z','#20282d',BLACK[2],.8)
  path(g,'M-7 -40 Q-9 -49 -3 -52 M7 -47 L8 -39','none','#454e50',.65)
  if back:
   path(g,'M0 -51 L1 -35','none',BLACK[2],.6)
   return
  path(g,'M-5 -44 Q0 -49 5 -44 L5 -35 -5 -35Z',skin,BLACK[2],.6)
  path(g,'M-6 -44 L-4 -44 -4 -28 -6 -26 -7 -33Z M4 -44 L6 -44 7 -32 6 -26 4 -28Z',hair,BLACK[2],.4)
  path(g,'M-5 -41 L-5 -29 M5 -41 L5 -29','none',light,.65)
  path(g,'M-3 -42 L-1 -42 M1 -42 L3 -42','none',BLACK[2],.65)
  path(g,'M-5 -39 Q0 -37 5 -39 L5 -34 1 -30 -5 -33Z','#3b4347',BLACK[2],.55)
  path(g,'M-3 -35 L1 -33 3 -35','none','#606a6c',.55)
 if not back:
  if r in ['pistol','rifle']:
   path(g,'M-4 -37 Q0 -40 4 -37 L4 -32 2 -31.5 2 -36 -2 -36 -2 -31.5 -4 -32Z',hair,'none')
  elif r in ['smg','shotgun']:
   path(g,'M-5 -39 L-3 -36 0 -37 3 -36 5 -39 5 -33 3 -29 0 -27 -3 -30 -5 -33Z',hair,'none')
   for x in [-3,0,3]:path(g,f'M{x} -34 L{x+.5} -30','none','#92958b' if r=='shotgun' else light,.7)
  if r in ['pistol','shotgun']:
   lens='M-6 -42 Q-3 -43 -1 -41 L-2 -38 Q-5 -36 -6 -40Z M1 -41 Q3 -43 6 -42 L6 -40 Q5 -36 2 -38Z' if r=='pistol' else 'M-7 -42 Q0 -43 7 -42 L6 -38 2 -38 0 -40 -2 -38 -6 -38Z'
   if side:lens='M1 -42 L7 -42 6 -38 2 -38Z'
   path(g,lens,'#10171a','#080f12',.7)
   path(g,'M-1 -41 L1 -41','none','#080f12',.6)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('apostles'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d);t=list(g)[0];r=c['role'];back=d in ['N','NE','NW']
 if back:
  back_patch(t,d)
  return
 fill={'pistol':RUST[0],'smg':skin,'shotgun':IVORY,'rifle':'#3f4749','sniper':'#171f24'}[r]
 path(t,'M-5 -32 Q0 -29 5 -32 L5 0 -5 0Z',fill,c['shade'],.5)
 if r=='pistol':
  path(t,'M-4 -31 Q0 -28 4 -31 M0 -29 L0 -21','none',RUST[2],.6)
  for y in [-27,-24]:path(t,f'M1 {y} L1 {y+.5}','none',RUST[1],.65)
 elif r=='smg':
  path(t,'M-4 -26 Q-1 -23 0 -26 Q2 -23 4 -26 M0 -22 L0 -16','none','#987c60',.5)
  path(t,'M-4 -24 l2 1 1 -2 M1 -24 l2 -1 1 2 M-3 -17 l2 -2 2 2 -2 1Z','none','#586056',.65)
 elif r=='shotgun':
  for x in [-3,0,3]:path(t,f'M{x} -29 L{x} -5','none','#9c9780',.3)
  for y in [-26,-22,-18,-14,-10,-6]:path(t,f'M-4 {y} L4 {y}','none','#9c9780',.3)
 elif r=='rifle':
  path(t,'M-4 -32 L0 -28 4 -32','none','#636e6e',.6)
  path(t,'M0 -27 L0 -1','none','#222e32',.6)
 else:
  # Half-zipped jacket with a small opening onto the lightweight hoodie.
  path(t,'M-5 -31 L0 -18 5 -31 3 0 -3 0Z',c['cloth'],c['shade'],.5)
  path(t,'M0 -18 L0 0','none','#86908b',.55)
  path(t,'M0 -18 L1 -17','none',SILVER,.7)
 if r=='shotgun':
  base.lapels(t,c)
  path(t,'M5 -23 L1 -1','none',SILVER,.65)
  path(t,'M4.6 -20 L5.6 -19','none',IVORY,.7)
 else:
  path(t,'M-7 -31 L-5 -26 -5 -2 M7 -31 L5 -26 5 -2','none',c['lit'],.7)
  path(t,'M-8 -31 L-6 -34 -3 -29 -5 -24Z M6 -34 L8 -31 5 -24 3 -29Z',c['cloth'],c['shade'],.5)
 chest_patches(t)
 path(t,'M-9 -6 l2 -.8 M7 -7 l2 1 M-10 -29 l1 1','none','#68706a',.4)
 if r=='smg':
  path(t,'M9 -1 Q14 7 7 11','none','#59615c',1.2)
  path(t,'M9 -1 Q14 7 7 11','none',SILVER,.65)
  for x,y in [(10,2),(11,5),(10,8)]:path(t,f'M{x-.5} {y} l1 .8','none',IVORY,.45)
 if r=='rifle':
  path(t,'M-10 -1 L10 -1','none',BLACK[2],2)
  for x in [-7,7]:path(t,f'M{x-2} -5 h4 v7 h-4Z',BLACK[0],BLACK[1],.5)
def tattoo(g,a,b):
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 for f in [.3,.6]:
  p=a+(b-a)*f
  path(g,f'M{xy(p-n*1.3-v)} Q{xy(p+n*1.4)} {xy(p+v*1.6)} L{xy(p-n*.8)}','none','#46524b',.65)
def arm(g,a,b,h,c,skin,hi):
 if not c.get('apostles'):return base.arm(g,a,b,h,c,skin,hi)
 r=c['role'];temp=c
 if r=='pistol':temp=dict(c,cloth=RUST[0],lit=RUST[1],shade=RUST[2])
 elif r=='rifle':temp=dict(c,cloth='#3f4749',lit='#636e6e',shade='#253136')
 elif r=='smg':temp=dict(c,cloth=skin,lit=hi,shade=skin)
 base.arm(g,a,b,h,temp,skin,hi)
 if r=='smg':tattoo(g,a,b)
def forearm(g,a,b,c,skin,hi,r=3.1):
 base.forearm(g,a,b,c,skin,hi,r)
 if not c.get('apostles'):return
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/max(.001,np.linalg.norm(b-a));n=np.array([-v[1],v[0]])
 role=c['role']
 if role in ['pistol','smg','rifle']:tattoo(g,a,b)
 if role in ['pistol','rifle']:
  col=RUST[1] if role=='pistol' else '#636e6e'
  path(g,f'M{xy(a-n*2.5)} L{xy(a+n*2.5)}','none',col,1.2)
 if role in ['smg','shotgun','sniper']:
  p=b-v*3;q=b-v*.7 if role=='smg' else b+v*.3
  path(g,f'M{xy(p-n*2.2)} L{xy(p+n*2.2)} L{xy(q+n*2)} Q{xy(q+v*.3)} {xy(q-n*2)}Z',BLACK[0],BLACK[2],.5)
 if role=='pistol' and c.get('watch_arm'):
  p=b-v*3
  path(g,f'M{xy(p-n*2.4)} L{xy(p+n*2.4)}','none',SILVER,1.3)
  for off in [-1,1]:path(g,f'M{xy(p+n*off-v*.5)} L{xy(p+n*off+v*.5)}','none',IVORY,.45)
 if role=='rifle':
  for off in [-.8,.8]:
   p=b+n*off
   path(g,f'M{xy(p-v*.5)} L{xy(p+v*.5)}','none',SILVER,.65)
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
   if radius>=3.5:continue
   q=base.E.Element(N+'g',{'data-garment-detail':'true'})
   p=b-v*3
   if role=='rifle':
    for step in [1.5,3,4.5]:
     p=b-v*step;path(q,f'M{xy(p-n*1.2)} L{xy(p+n*1.2+v*.4)}','none',c['shoe_hi'],.55)
   elif role in ['smg','shotgun','sniper']:
    path(q,f'M{xy(p-n*2.5)} L{xy(p+n*2.5)}','none',c['shoe_hi'],.85)
    path(q,f'M{xy(p-n*1.5-v*.8)} L{xy(p-n*.1-v*.8)} L{xy(p-n*.1+v*.8)} L{xy(p-n*1.5+v*.8)}Z','none',SILVER,.55)
   if role=='smg' and a[0]<40:
    p=a+v*1.5
    path(q,f'M{xy(p-n*2.2)} L{xy(p+n*2)} L{xy(p+n+v*1.6)} L{xy(p-n*1.4+v)}Z','#a98b6e',BLACK[2],.4)
    path(q,f'M{xy(p-n*2.3-v*.5)} L{xy(p+n*2.3-v*.5)}','none','#c3c6b9',.65)
   if len(q):parent.insert(list(parent).index(el)+3,q)
 return root
outfits.head=head
outfits.torso=torso
outfits.arm=arm
outfits.forearm=forearm
