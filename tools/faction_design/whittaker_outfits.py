"""Owner-directed Whittaker clothing on the accepted ordinary-unit anatomy."""
from pathlib import Path
import copy, re, sys, xml.etree.ElementTree as E
import numpy as np

sys.path.insert(0,str(Path(__file__).parent))
import eastex_outfits as shared
rig, outfits, directions, build = shared.rig, shared.outfits, shared.directions, shared.build
N, path, xy, BASE = shared.N, shared.path, shared.xy, shared.BASE
KIND=1
TITLE='WHITTAKER OIL & LAND CO.'
PREFIX='whittaker'
BLUE=('#93764d',)  # Review-sheet accent only; no faction-wide clothing recolor.
DESCRIPTIONS={
 'pistol':'Tan cowboy hat / rolled cream western shirt / blue jeans',
 'smg':'Backward red trucker cap / shaggy blonde hair / sleeveless tee',
 'shotgun':'Brown cowboy hat / mustache / canvas vest over green plaid',
 'rifle':'Olive cap / trimmed beard / rolled khaki shirt / utility pants',
 'sniper':'Woodland hunting hood and jacket / olive face cloth',
}
NOTES={
 'pistol':['Short brown hair / silver belt buckle','Blue jeans / brown cowboy boots'],
 'smg':['Blonde hair / tattooed bare arms','Faded jeans / scuffed brown work boots'],
 'shotgun':['Collar-length brown hair / mustache','Worn black jeans / heavy tan work boots'],
 'rifle':['Dark brown hair / magazine pouches','Dark brown pants / black work boots'],
 'sniper':['Mostly concealed sandy brown hair','Reinforced olive knees / muddy boots'],
}
CREAM=('#c5bca2','#ddd4ba','#9c957e')
CHARCOAL=('#2a2c2b','#444744','#171d1c')
GREEN=('#3b4a3b','#57604a','#25342b')
KHAKI=('#aaa083','#c4b99c','#80795f')
CAMO=('#69705a','#82866b','#454d3e')
CAMO_COLORS=['#8a7d60','#404e3c','#343c32','#969077']


def spec(top,colors,head,sleeve,**kw):
 return dict(top=top,cloth=colors[0],lit=colors[1],shade=colors[2],head=head,
             sleeve=sleeve,wide=BASE['wide'],new_unit=True,whittaker=True,
             pants='#3c5466',pants_hi='#657a86',shoe='#604630',shoe_hi='#8a6a48',
             boots=True,**kw)


SPECS={
 'pistol':spec('western',CREAM,'cowboy','rolled_elbow',hair='#634a33',hair_hi='#927051',hat='#aa8d60',hat_hi='#c6aa7d',hat_shade='#735d40',cowboy_boots=True),
 'smg':spec('sleeveless',CHARCOAL,'trucker','bare',hair='#aa8d51',hair_hi='#d0b574',hat='#935c50',hat_hi='#ad7967',hat_shade='#69433d',tattoo=True,scuffed=True),
 'shotgun':spec('workvest',GREEN,'cowboy','long',hair='#433328',hair_hi='#70533d',hat='#57412e',hat_hi='#806046',hat_shade='#352c24',long_hair=True,mustache=True),
 'rifle':spec('workshirt',KHAKI,'cap','rolled_forearm',hair='#3d3028',hair_hi='#67503c',hat='#586248',hat_hi='#7a8061',hat_shade='#394332',beard=True,pouches=True),
 'sniper':spec('hunting',CAMO,'hunting_hood','long',hair='#99774f',hair_hi='#b99a6b',jacket_camo=True,knee_pads=True),
}
SPECS['smg'].update(pants='#53687a',pants_hi='#7b8b95',shoe='#5f4c38',shoe_hi='#8c7452')
SPECS['shotgun'].update(pants='#292c29',pants_hi='#454a42',shoe='#a48652',shoe_hi='#c3a772')
SPECS['rifle'].update(pants='#463e32',pants_hi='#635b49',shoe='#1d2323',shoe_hi='#3e4542')
SPECS['sniper'].update(pants='#414b36',pants_hi='#606b4c',shoe='#534c36',shoe_hi='#807456')
EXTRA_PALETTE=list(CAMO_COLORS)+['#786248','#a28862','#554533','#303730','#88907a','#80785f','#b0aaa0','#ddd8c8','#52432c','#4b5844','#b9ae8e']
ORIGINAL_FOREARM=outfits.forearm


def blob(g,center,rx,ry,color):
 x,y=center
 path(g,f'M{x-rx} {y-ry*.5} Q{x-rx*.4} {y-ry*1.2} {x+rx*.2} {y-ry*.6} '
      f'L{x+rx} {y-ry*.25} Q{x+rx*.4} {y+ry*.2} {x+rx*.8} {y+ry*.8} '
      f'L{x-rx*.4} {y+ry} Q{x-rx*1.1} {y+ry*.3} {x-rx*.5} {y}Z',color,'none')


def head(g,c,skin,hi,d='SE'):
 if not c.get('whittaker'):return shared.head(g,c,skin,hi,d)
 back=d in ['N','NE','NW'];side=d in ['E','W'];h=c['head']
 shape=('M-6 -37 L-7 -44 Q-7 -50 0 -50 Q6 -50 7 -45 L8 -40 6 -34 1 -33 -5 -36Z'
        if side else 'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z')
 if h=='hunting_hood':
  temp=E.Element(N+'g')
  rig.head(temp,dict(c,head='hood',pocket_rag=True),skin,hi,d)
  for el in temp.iter():
   if el.get('fill')=='#202527':el.set('fill','#4b5844')
   if el.get('stroke')=='#42494a':el.set('stroke','#88907a')
  g.extend(list(temp))
  if back:
   for x,y,rx,ry,col in [(-3,-47,4,2,CAMO_COLORS[0]),(4,-44,3,3,CAMO_COLORS[1]),(-4,-39,3,3,CAMO_COLORS[2]),(1,-34,3,2,CAMO_COLORS[0])]:blob(g,(x,y),rx,ry,col)
  else:
   blob(g,(-3,-50.8),3,1.2,CAMO_COLORS[0]);blob(g,(-8.2,-41),1,3,CAMO_COLORS[1]);blob(g,(8,-39),1,2,CAMO_COLORS[2])
   path(g,'M-3.8 -43.3 Q-1 -45.2 2.6 -43.8 L3.5 -42.5 -1 -43 -3 -42.5Z',c['hair'],'none')
   path(g,'M-2 -43.7 L0 -44','none',c['hair_hi'],.6)
  return
 # Hair is drawn around the same head, without widening or moving the skull.
 if c.get('long_hair') or h=='trucker':
  hair_shape=('M-6 -45 Q0 -50 6 -45 L8 -36 7 -29 5 -31 3 -29 2 -31 -2 -29 -4 -31 -6 -30 -8 -33Z'
              if back else 'M-6 -45 Q0 -50 6 -45 L8 -36 7 -29 5 -31 4 -30 3.5 -35 -3.5 -35 -4 -30 -6 -31 -7 -30 -8 -33Z')
  path(g,hair_shape,c['hair'],'#252821',.7)
 path(g,shape,skin,w=1.15)
 if back:
  path(g,'M-6 -45 Q0 -49 6 -45 L6 -36 3 -34 -3 -35 -6 -38Z',c['hair'],w=.65)
 else:
  path(g,'M-6 -45 L-6 -38 -4 -36 -4 -43 Q1 -47 6 -42 L6 -45 Q0 -50 -6 -45Z',c['hair'],'none')
  path(g,('M3 -41 L5 -41 M4 -37 L6 -36' if side else 'M-3 -40.5 L-1 -40.5 M2 -40.5 L4 -40.5 M-1 -35.3 L2 -35.3'),'none','#49382e',.6)
  path(g,'M1 -39 L2 -37','none',hi,.6)
 if c.get('long_hair') or h=='trucker':
  for x in [-6,-4,5,7]:
   end=-30 if back else (-32 if x<0 else -34)
   path(g,f'M{x} -41 Q{x-1} -36 {x} {end}','none',c['hair_hi'],.7)
 if c.get('mustache') and not back:
  path(g,('M3 -37.6 Q5 -39 7 -37.3 L7 -35.5 5 -36.1 3 -36Z' if side else 'M-4 -37 Q-2 -38.7 .2 -37.5 Q2 -38.5 4.5 -36.8 L4 -35.2 1 -36 .1 -35.5 -1 -36 -4 -35.2Z'),c['hair'],'none')
 if c.get('beard') and not back:
  path(g,('M-5 -38 L-2 -36 3 -36 7 -38 6 -34 1 -33 -4 -35Z' if side else 'M-5 -38 L-3 -35.5 0 -35 4 -36 6 -38 5 -34.5 2 -32.9 -2 -34 -5 -36Z'),c['hair'],'none')
  path(g,'M-3 -36 L0 -35 M2 -35 L4 -36','none',c['hair_hi'],.6)
 if h=='cowboy':
  # Curled brim plus pinched crown; the actual head stays at its accepted size.
  path(g,'M-7 -45 L-6 -53 Q-4 -56 -1 -53.5 Q2 -56 6 -53 L8 -45 Q1 -42 -7 -45Z',c['hat'],c['hat_shade'],.85)
  path(g,'M-4 -52 Q0 -54 4 -51 M-5 -47 Q0 -45 6 -47','none',c['hat_hi'],.7)
  path(g,'M-7 -47 Q0 -44 7 -47 L8 -44 Q0 -42 -8 -44Z',c['hat_shade'],'none')
  brim=('M-13 -44 Q-11 -48 -7 -45 Q0 -42 9 -46 Q13 -48 17 -44 Q9 -40 0 -41 Q-9 -40 -13 -44Z'
        if side else 'M-15 -45 Q-11 -49 -7 -46 Q0 -42 7 -46 Q11 -49 15 -45 Q8 -40 0 -41 Q-9 -40 -15 -45Z')
  path(g,brim,c['hat'],c['hat_shade'],.85)
  path(g,'M-12 -44 Q-8 -42 -4 -43 M4 -43 Q9 -44 12 -46','none',c['hat_hi'],.7)
 elif h in ['trucker','cap']:
  path(g,'M-7 -44 L-7 -47 Q-4 -52 1 -51 Q6 -51 7 -46 L6 -43 Q0 -41 -7 -44Z',c['hat'],c['hat_shade'],.9)
  path(g,'M-5 -47 Q0 -50 4 -47','none',c['hat_hi'],.75)
  forward=h=='cap'
  if side:
   brim=('M4 -44 L13 -42 Q15 -40 6 -41Z' if forward else 'M-6 -45 L-13 -43 Q-14 -41 -6 -42Z')
   path(g,brim,c['hat'],c['hat_shade'],.7)
  elif back != forward:
   path(g,'M-7 -44 Q0 -42 7 -44 L10 -41 Q0 -38 -9 -41Z',c['hat'],c['hat_shade'],.7)
  else:
   path(g,'M-3 -44 L2 -44 2 -42 -3 -42Z',c['hair'],c['hat_hi'],.45)
  if h=='trucker' and not back:
   for x in [-4,-1,2]:path(g,f'M{x} -48 L{x-1} -45','none','#b0aaa0',.45)
 else:raise ValueError(h)


def torso(g,c,skin,hi,d='SE'):
 if not c.get('whittaker'):return rig.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d)
 t=list(g)[0];back=d in ['N','NE','NW'];side=d in ['E','W'];top=c['top']
 if top=='sleeveless':
  # Finished armholes only: shoulders remain skin and retain the same joints.
  path(t,'M-9 -30 Q-7 -26 -11 -22 M10 -30 Q7 -26 11 -22','none',c['shade'],.7)
 elif top=='workvest':
  if not back:
   for x in [-7,-2,3,8]:path(t,f'M{x} -29 L{x} -3','none','#1c3028',.9)
   for y in [-27,-21,-15,-9,-4]:path(t,f'M-9 {y} L10 {y}','none','#80785f',.5)
   path(t,'M-10 -30 L-6 -32 -5 -22 -4 -9 -5 0 -11 0 -12 -17Z','#786248','#554533',.7)
   path(t,'M6 -32 L11 -29 11 -17 12 0 6 1 4 -11 5 -24Z','#786248','#554533',.7)
   path(t,'M-9 -26 L-7 -28 M8 -27 L9 -24 M-10 -8 L-6 -8 M6 -8 L10 -8','none','#a28862',.65)
  else:
   for el in t.iter():
    for attr in ['fill','stroke']:
     if el.get(attr) in [c['cloth'],c['lit'],c['shade']]:el.set(attr,{c['cloth']:'#786248',c['lit']:'#a28862',c['shade']:'#554533'}[el.get(attr)])
   path(t,'M-8 -26 Q0 -24 8 -26 M0 -23 L0 -3','none','#554533',.65)
 elif top=='hunting':
  for x,y,rx,ry,col in [(-6,-26,3,3,CAMO_COLORS[0]),(4,-25,3,4,CAMO_COLORS[1]),(-2,-20,4,3,CAMO_COLORS[2]),(7,-15,2,3,CAMO_COLORS[0]),(-6,-12,3,3,CAMO_COLORS[1]),(2,-7,4,3,CAMO_COLORS[0])]:blob(t,(x,y),rx,ry,col)
  if not back:
   path(t,'M0 -30 L0 -2','none','#343c32',.8)
   path(t,'M-8 -8 L-3 -8 M3 -8 L8 -8','none',c['lit'],.6)
 else:
  if not back:
   x=3 if side else 0
   path(t,f'M{x-5} -32 L{x} -28 {x+5} -32 {x+3} -25 {x} -28 {x-3} -25Z',c['lit'],c['shade'],.55)
   path(t,f'M{x} -27 L{x} -3','none',c['shade'],.6)
   for y in [-23,-17,-11]:path(t,f'M{x+.6} {y} L{x+1} {y}','none','#ddd8c8',.75)
   path(t,'M-8 -22 L-3 -22 -3 -16 -7 -17Z M3 -22 L8 -22 7 -17 3 -16Z',c['cloth'],c['shade'],.5)
  if top=='western':path(t,'M-10 -28 L-5 -25 0 -27 5 -25 10 -28','none',c['shade'],.65)
 if top in ['western','workshirt']:
  belt='#52432c' if top=='western' else '#171d1c'
  path(t,'M-11 -2 Q0 1 12 -2 L12 1 Q0 4 -11 1Z',belt,'#252821',.5)
  if not back:path(t,'M-1.5 -1 L2 -1 2 2 -1.5 2Z','#b0aaa0' if top=='western' else '#454b44',belt,.6)
  if c.get('pouches'):
   for x in ([-8,5] if not side else [-6,2]):
    path(t,f'M{x} -5 L{x+3.8} -5 {x+4.1} 2 {x} 2Z','#1d2323','#090f12',.6)
    path(t,f'M{x+.5} -3 L{x+3.2} -3','none','#3e4542',.6)


def forearm(g,a,b,c,skin,hi,r=3.1):
 if not c.get('whittaker'):return ORIGINAL_FOREARM(g,a,b,c,skin,hi,r)
 a,b=np.array(a,float),np.array(b,float);v=b-a;length=np.linalg.norm(v);v/=max(.001,length);n=np.array([-v[1],v[0]])
 plain=dict(c,sleeve='long' if c['sleeve']=='long' else 'short')
 ORIGINAL_FOREARM(g,a,b,plain,skin,hi,r)
 if c['sleeve']=='rolled_forearm' and r>=3:
  end=a+(b-a)*.38
  ORIGINAL_FOREARM(g,a,end,dict(c,sleeve='long'),skin,hi,r)
  path(g,f'M{xy(end+n*2.6)} L{xy(end-n*2.6)}','none',c['lit'],1.7)
  path(g,f'M{xy(end+v+n*2.6)} L{xy(end+v-n*2.6)}','none',c['shade'],.5)
 if c['top']=='workvest' or c.get('jacket_camo'):
  if length<3:return
  if c['top']=='workvest':
   for t in [.25,.55,.8]:
    p=a+(b-a)*t;path(g,f'M{xy(p+n*2)} L{xy(p-n*2)}','none','#80785f',.55)
   path(g,f'M{xy(a+n*.3)} L{xy(b-v)}','none','#1c3028',.8)
  else:
   for t,col in [(.26,CAMO_COLORS[0]),(.60,CAMO_COLORS[2])]:
    p=a+(b-a)*t
    path(g,f'M{xy(p-v*2+n*1.8)} Q{xy(p-n*.4-v)} {xy(p+n*1.2+v*2)} L{xy(p-n*1.8+v*2)} Q{xy(p-n)} {xy(p-n*1.5-v*2)}Z',col,'none')


def arm(g,a,b,h,c,skin,hi):
 if not c.get('whittaker'):return shared.arm(g,a,b,h,c,skin,hi)
 a,b=np.array(a,float),np.array(b,float);v=(b-a)/np.linalg.norm(b-a);n=np.array([-v[1],v[0]])
 if c['sleeve']=='bare':
  rig.connected_arm(g,a,b,h,dict(c,cloth=skin,lit=hi,shade='#86664f',sleeve='short'),skin,hi)
  # Upper-arm ink complements the shared forearm tattoo pattern.
  for t in [.35,.55,.75]:
   p=a+(b-a)*t
   path(g,f'M{xy(p+n*2-v)} Q{xy(p-n)} {xy(p+n+v)} L{xy(p-n*2+v)}','none','#3c4948',.7)
  return
 rig.connected_arm(g,a,b,h,c,skin,hi)
 if c['sleeve']=='rolled_elbow':
  p=b-v*1.7
  path(g,f'M{xy(p+n*3.1)} Q{xy(p+v)} {xy(p-n*3.1)}','none',c['lit'],2)
  path(g,f'M{xy(p+v+n*3)} L{xy(p+v-n*3)}','none',c['shade'],.55)
 if c['top']=='workvest':
  for t in [.3,.6,.85]:
   p=a+(b-a)*t;path(g,f'M{xy(p+n*2.8)} L{xy(p-n*2.8)}','none','#80785f',.55)
  path(g,f'M{xy(a+v*4+n*.3)} L{xy(b-v)}','none','#1c3028',.9)
 if c.get('jacket_camo'):
  for t,col in [(.4,CAMO_COLORS[0]),(.72,CAMO_COLORS[2])]:
   p=a+(b-a)*t
   path(g,f'M{xy(p-v*2+n*2)} Q{xy(p-v)} {xy(p+n+v*2.5)} L{xy(p-n*2+v*1.8)} Q{xy(p-n)} {xy(p-n*1.5-v*2)}Z',col,'none')


def lower_details(root,c):
 shared.decorate_lower(root,dict(c,boots=False) if c.get('cowboy_boots') else c)
 for parent in list(root.iter()):
  for el in list(parent):
   d=el.get('d','')
   if el.get('fill')!=c['pants'] or re.search('[QCAqca]',d):continue
   nums=re.findall(r'-?\d+(?:\.\d+)?',d)
   if len(nums)!=12:continue
   ps=np.array(list(map(float,nums))).reshape(6,2)
   a,b=(ps[0]+ps[5])/2,(ps[2]+ps[3])/2
   v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
   radius=np.linalg.norm(ps[2]-ps[3])/2
   if c.get('cowboy_boots') and radius<3.5:
    detail=E.Element(N+'g',{'data-garment-detail':'true'})
    top=b-v*min(10,np.linalg.norm(b-a)*.45)
    path(detail,f'M{xy(top+n*radius)} Q{xy(top+v*1.2)} {xy(top-n*radius)} L{xy(b-n*radius)} Q{xy(b+v)} {xy(b+n*radius)}Z',c['shoe'],'none')
    path(detail,f'M{xy(top+v*2+n*1.5)} L{xy(top+v*5)} L{xy(top+v*2-n*1.5)}','none',c['shoe_hi'],.65)
    parent.insert(list(parent).index(el)+2,detail)
   if c.get('scuffed') and radius<3.5:
    detail=E.Element(N+'g',{'data-garment-detail':'true'})
    center=b-v*2
    path(detail,f'M{xy(center+n*1.8)} L{xy(center+n*.7-v*.4)} M{xy(center-n)} L{xy(center-n*1.7+v)}','none','#b9ae8e',.6)
    parent.insert(list(parent).index(el)+2,detail)
   if c.get('knee_pads') and radius<3.5:
    end=a+v*5
    detail=E.Element(N+'g',{'data-garment-detail':'true'})
    path(detail,f'M{xy(a-v+n*2.9)} L{xy(a-v-n*2.9)} L{xy(end-n*2.6)} Q{xy(end+v)} {xy(end+n*2.6)}Z','#303730','#606b4c',.55)
    parent.insert(list(parent).index(el)+2,detail)


def make(role,model,direction,**state):
 import build_art as art
 c=SPECS[role];w=model['art_base'];outfits.SPECS[(KIND,w)]=c
 _,definition=art.bind(model)
 if role=='sniper':definition['view_lengths']={'S':.80,'N':.72}
 root=directions.make(KIND,state.pop('q',1.25),direction,w,**state)
 before=rig.lower_signature(root)
 lower_details(root,c)
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
