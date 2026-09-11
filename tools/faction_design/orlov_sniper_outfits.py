"""Orlov sniper only; the four existing Orlov outfits are preserved."""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).parent))
import ventresca_outfits as base
rig,outfits,directions,build=base.rig,base.outfits,base.directions,base.build
N,path,xy,BASE=base.N,base.path,base.xy,base.BASE
KIND=1
TITLE='ORLOV BRATVA / SNIPER'
PREFIX='orlov_sniper'
BLUE=('#66725a',)
SPECS={'sniper':base.costume('work',('#20272a','#3b4548','#121a1e'),'combed',orlov_sniper=True,gloves=True,ankle_boots=True)}
SPECS['sniper'].update(pants='#303d2d',pants_hi='#526049',shoe='#151c20',shoe_hi='#384348')
EXTRA_PALETTE=base.EXTRA_PALETTE+['#303d2d','#526049','#3b4548','#7c8785','#a8b0aa','#303638','#505958']
def head(g,c,skin,hi,d='SE'):
 if not c.get('orlov_sniper'):return base.head(g,c,skin,hi,d)
 base.head(g,c,skin,hi,d)
 back=d in ['N','NE','NW'];side=d in ['E','W']
 # Low crown, fur brow and lowered ear flaps, without enlarging the skull.
 path(g,'M-7 -45 L-7 -50 Q0 -52 7 -50 L8 -44Z','#20272a','#121a1e',.8)
 path(g,'M-8 -45 L-8 -36 Q-6 -33 -4 -36 L-4 -43Z M4 -43 L5 -35 Q8 -33 9 -36 L8 -45Z','#303638','#121a1e',.65)
 path(g,'M-8 -48 Q0 -50 8 -47 L8 -43 Q0 -42 -8 -44Z','#505958','#20272a',.65)
 for x in [-6,-3,0,3,6]:path(g,f'M{x} -47 L{x+.8} -45','none','#7c8785',.65)
 path(g,'M-7 -42 L-6 -37 M7 -42 L7 -37','none','#505958',.75)
 if back:
  path(g,'M-5 -44 Q0 -43 5 -44 L5 -37 Q0 -35 -5 -37Z','#20272a','#121a1e',.5)
 else:
  shape=('M-5 -39 Q1 -37 7 -39 L7 -35 3 -33 -4 -35Z' if side else 'M-5 -39 Q0 -37 5 -39 L5 -35 2 -33 -3 -34 -5 -36Z')
  path(g,shape,'#121a1e','#101619',.55)
  path(g,'M-3 -36 Q0 -35 3 -36','none','#303638',.5)
def torso(g,c,skin,hi,d='SE'):
 if not c.get('orlov_sniper'):return base.torso(g,c,skin,hi,d)
 rig.ORIGINAL_TORSO(g,c,skin,hi,d)
 t=list(g)[0];back=d in ['N','NE','NW']
 path(t,'M-10 -4 Q0 -2 11 -4 M-9 -26 L-8 -16 M8 -26 L7 -17','none',c['shade'],.65)
 if back:
  path(t,'M-8 -29 Q0 -27 8 -29 M0 -25 L0 -5','none',c['shade'],.6)
  return
 path(t,'M-6 -32 L-4 -35 0 -32 4 -35 7 -32 5 -28 0 -30 -5 -28Z',c['cloth'],c['shade'],.65)
 path(t,'M0 -31 L0 0','none',c['shade'],1.6)
 path(t,'M.3 -30 L.3 -1','none','#a8b0aa',.7)
 for y in range(-28,0,3):path(t,f'M-.7 {y} L.7 {y}','none','#7c8785',.5)
 path(t,'M.5 -28 L1.7 -28 1.7 -25 .5 -25Z','#a8b0aa',c['shade'],.4)
 path(t,'M-9 -13 L-5 -11 M5 -11 L9 -13 M-10 -6 L-6 -5 M6 -5 L10 -6','none',c['lit'],.65)
def make(role,model,direction,**state):
 assert role=='sniper'
 base.SPECS=SPECS;base.KIND=KIND
 root=base.make(role,model,direction,**state)
 for el in root.iter():
  for k in ['fill','stroke']:
   if el.get(k)=='#10181c':el.set(k,'#303d2d')
   elif el.get(k)=='#30383b':el.set(k,'#526049')
 return root
outfits.head=head
outfits.torso=torso
