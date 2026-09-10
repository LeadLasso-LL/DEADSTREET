"""Faction/role clothing over the accepted rig; SMG and Italian art stay unchanged."""
import math, xml.etree.ElementTree as E
import numpy as np
N='{http://www.w3.org/2000/svg}'
SPECS={
 (0,'ak_rifle'):dict(top='tee',cloth='#242829',lit='#404648',shade='#161d20',pants='#3c3029',pants_hi='#5c493a',shoe='#191e21',shoe_hi='#42484a',head='cap',sleeve='short',wide=1.10),
 (0,'pistol'):dict(top='hoodie',cloth='#77323a',lit='#a04649',shade='#4d252c',pants='#202527',pants_hi='#353b3d',shoe='#d6d5c9',shoe_hi='#eeeee2',head='hood',sleeve='long',wide=1.04),
 (0,'pump_shotgun'):dict(top='jersey',cloth='#9a343b',lit='#be4c4b',shade='#622b34',pants='#202527',pants_hi='#353b3d',shoe='#d6d5c9',shoe_hi='#eeeee2',head='mask',sleeve='short',wide=1.04),
 (1,'ak_rifle'):dict(top='quarter',cloth='#303638',lit='#505859',shade='#20282a',pants='#3b4334',pants_hi='#5a624a',shoe='#181e21',shoe_hi='#414749',head='beanie',sleeve='long',wide=1.0,gloves=True),
 (1,'pistol'):dict(top='tee',cloth='#202527',lit='#373e40',shade='#141b1f',pants='#3c3029',pants_hi='#5c493a',shoe='#191e21',shoe_hi='#42484a',head='gray_mask',sleeve='short',wide=.96,tattoo=True),
 (1,'pump_shotgun'):dict(top='bomber',cloth='#202729',lit='#3c4547',shade='#11191d',pants='#363b3e',pants_hi='#535b5e',shoe='#d6d5c9',shoe_hi='#eeeee2',head='mask',sleeve='long',wide=1.12),
}
def spec(k,w):return SPECS.get((k,w))
def path(g,d,c,s='#090f12',w=.9):
 return E.SubElement(g,N+'path',{'d':d,'fill':c,'stroke':s,'stroke-width':str(w),'stroke-linejoin':'round','stroke-linecap':'round'})
def xy(v):return f'{v[0]:.3f} {v[1]:.3f}'
def group(g,**kw):return E.SubElement(g,N+'g',kw)
def lower_colors(c):
 return {**{x:c['pants'] for x in ['#252c2e','#293233']},**{x:c['pants_hi'] for x in ['#42494a','#545c58','#404749']},**{x:c['shoe'] for x in ['#414337','#5c5d43','#50513c']},**{x:c['shoe_hi'] for x in ['#666453','#73796c','#555849']}}
def forearm(g,a,b,c,skin,hi,r=3.1):
 a,b=np.array(a,float),np.array(b,float);v=b-a;v/=max(.001,np.linalg.norm(v));n=np.array([-v[1],v[0]])
 fill=c['cloth'] if c['sleeve']=='long' else skin;light=c['lit'] if c['sleeve']=='long' else hi
 path(g,f'M{xy(a+n*r)} Q{xy(a+v*3+n*(r+.2))} {xy(b+n*2.1)} Q{xy(b+v)} {xy(b-n*2.1)} L{xy(a-n*r)}Z',fill,w=1.15)
 path(g,f'M{xy(a+n*.8)} L{xy(b-v*2+n*.5)}','none',light,.8)
 if c.get('tattoo'):
  ink='#3c4948'
  for t in [.15,.39,.65,.84]:
   p=a+(b-a)*t
   path(g,f'M{xy(p+n*1.7-v*1.4)} Q{xy(p-n*.2)} {xy(p+n*1.1+v*1.1)} Q{xy(p-n*1.3+v*.8)} {xy(p-n*1.7-v*.4)}','none',ink,.8)
  path(g,f'M{xy(a+n*.4)} Q{xy((a+b)/2-n)} {xy(b-v*3+n)}','none',ink,.6)
 if c['sleeve']=='long':
  p=b-v*2;path(g,f'M{xy(p+n*2.2)} L{xy(p-n*2.2)}','none',c['shade'],1)
def arm(g,a,b,h,c,skin,hi):
 a,b,h=map(lambda p:np.array(p,float),(a,b,h));v=b-a;v/=np.linalg.norm(v);n=np.array([-v[1],v[0]])
 short=c['sleeve']=='short';r=3.7*c['wide'];sleeve='#d6d5c9' if c['top']=='jersey' else c['cloth'];light='#eeeee2' if c['top']=='jersey' else c['lit']
 # Continuous skin arm beneath a rounded, properly overlapping short sleeve.
 if short:forearm(g,a+v*5,b,c,skin,hi,3.1)
 end=a+(b-a)*(.56 if short else 1.02)
 path(g,f'M{xy(a-v*2+n*1.6)} Q{xy(a+n*r-v*3)} {xy(a+n*r+v*2)} L{xy(end+n*(r-.5))} Q{xy(end+v*.9)} {xy(end-n*(r-.5))} L{xy(a-n*r+v*2)} Q{xy(a-n*r-v*2)} {xy(a-v*2+n*1.6)}Z',sleeve,w=1.3)
 path(g,f'M{xy(a+n*.9)} L{xy(end-v*2+n*.8)}','none',light,1.05)
 if short:path(g,f'M{xy(end+n*(r-.65))} Q{xy(end+v*.5)} {xy(end-n*(r-.65))}','none',c['shade'],.7)
 forearm(g,b,h,c,skin,hi)
def torso(g,c,skin,hi,d='SE'):
 side=d in ['E','W'];back=d in ['N','NE','NW'];wide=c['wide'];top=c['top']
 t=group(g,transform=f'scale({wide} 1)')
 shape=('M-3 -34 Q3 -36 7 -31 Q10 -26 9 -20 L7 -10 L7 1 Q0 5 -10 1 L-10 -11 Q-11 -22 -9 -28 Q-7 -33 -3 -34Z' if side else 'M-5 -33 Q-11 -32 -13 -27 L-12 -16 L-11 0 Q0 4 12 0 L11 -16 L13 -27 Q9 -32 5 -33Z')
 path(t,shape,c['cloth'],w=1.2)
 path(t,'M-8 -28 Q-10 -19 -7 -11 L-7 -1 -2 1 -3 -12 -4 -29Z',c['lit'],'none')
 path(t,'M8 -28 L10 -18 8 -2 3 1 5 -15Z',c['shade'],'none')
 if top=='jersey':
  # White crew-neck undershirt remains visible at collar and separate sleeve ends.
  path(t,'M-6 -33 Q0 -27 6 -33 L8 -29 Q0 -24 -8 -29Z','#d6d5c9','#eeeee2',.9)
  path(t,'M-10 -30 L-7 -32 Q-6 -22 -11 -21 M10 -30 L7 -32 Q6 -22 11 -21','none','#e6d6bf',1.65)
  path(t,'M-7 -31 Q0 -23 7 -31','none','#e6d6bf',1.45)
  path(t,'M-7 -30 Q0 -25 7 -30','none','#242829',.45)
  path(t,'M-9 -2 Q0 1 10 -2','none','#e6d6bf',.9)
 elif top in ['quarter','bomber']:
  if not back:
   x=4 if side else 1;end=-20 if top=='quarter' else 0
   path(t,f'M{x-4} -33 L{x-3} -37 L{x+2} -37 L{x+5} -33 L{x+2} -29Z',c['shade'],c['lit'],.65)
   path(t,f'M{x} -34 L{x} {end}','none','#0e161a',1.8)
   path(t,f'M{x+.35} -34 L{x+.35} {end}','none','#a4aba4',.6)
   path(t,f'M{x} -32 L{x+1.2} -32 L{x+1.2} -29 L{x} -29Z','#afb3aa','#191e21',.45)
  if top=='bomber':
   path(t,'M-10 -3 Q0 1 11 -3 L11 1 Q0 5 -10 1Z',c['shade'],w=.6)
   for x in range(-8,11,3):path(t,f'M{x} -1 L{x} 1','none',c['lit'],.45)
   path(t,'M-8 -13 L-4 -15 M5 -15 L9 -13','none',c['lit'],.7)
 elif top=='hoodie':
  if back:path(t,'M-7 -33 Q0 -24 7 -33 L6 -24 Q0 -19 -6 -25Z',c['shade'],c['lit'],.8)
  else:
   path(t,'M-6 -30 Q0 -25 6 -30 M-4 -28 L-5 -19 M5 -28 L5 -20','none',c['lit'],.85)
   path(t,'M-5 -12 L4 -12 7 -5 Q0 -3 -8 -5Z',c['shade'],c['lit'],.55)
 else:path(t,'M-5 -32 Q0 -27 5 -32','none',c['shade'],1.4)
 # Small material folds, not an all-over noise filter.
 path(t,'M-9 -14 L-6 -12 M5 -7 L8 -9 M-7 -3 L-3 -2','none',c['shade'],.65)
 if not back and top not in ['quarter','bomber']:
  path(t,'M-3 -36 L3 -36 L4 -31 Q0 -28 -4 -32Z',skin,w=.7)
  path(t,'M-4 -31 Q0 -28 4 -31','none',c['lit'],.9)
def head(g,c,skin,hi,d='SE'):
 side=d in ['E','W'];back=d in ['N','NE','NW'];h=c['head'];mask='#373e42' if h=='gray_mask' else '#202527';ml='#555d60' if h=='gray_mask' else '#42494a'
 shape='M-6 -37 L-7 -44 Q-7 -50 0 -50 Q6 -50 7 -45 L8 -40 6 -34 1 -33 -5 -36Z' if side else 'M-6 -37 L-7 -44 Q-6 -50 0 -50 Q6 -50 7 -44 L6 -37 3 -33 -3 -34Z'
 path(g,shape,skin,w=1.15)
 if h in ['mask','gray_mask']:
  path(g,shape,mask,w=1.15);path(g,'M-4 -46 Q0 -48 3 -46 M-4 -36 L0 -34','none',ml,.7)
  if not back:
   path(g,('M2 -43 L6 -43 7 -41 2 -41Z' if side else 'M-4 -42 L4 -42 4 -39.8 -4 -39.8Z'),skin,'#10181c',.5)
   path(g,('M3 -42 L5 -42' if side else 'M-3 -41 L-1.5 -41 M1.5 -41 L3 -41'),'none','#10181c',.6)
 elif h=='cap':
  path(g,'M-6 -41 Q0 -39 6 -41 L7 -35 4 -30 -3 -31 -7 -35Z','#202527',w=.8)
  path(g,'M-5 -35 Q0 -33 4 -35 M-4 -32 L1 -31','none','#42494a',.65)
  # Backward red crown and rear-facing projecting bill.
  path(g,'M-7 -44 L-7 -47 Q-4 -52 1 -51 Q6 -51 7 -46 L6 -43 Q0 -41 -7 -44Z','#953d43','#281e24',.9)
  path(g,'M-5 -47 Q0 -50 4 -47','none','#be5854',.8)
  if side:path(g,'M-6 -45 L-13 -43 Q-14 -41 -6 -42Z','#953d43','#281e24',.7)
  elif back:path(g,'M-7 -44 Q0 -42 7 -44 L10 -41 Q0 -38 -9 -41Z','#953d43','#281e24',.7)
  else:path(g,'M-3 -44 L2 -44 2 -42 -3 -42Z','#242829','#c0806d',.45)
  if not back:path(g,'M-3 -42 L-1 -42 M2 -42 L4 -42','none','#10181c',.65)
 elif h=='hood':
  path(g,'M-9 -35 L-10 -43 Q-9 -53 0 -53 Q9 -52 10 -44 L10 -33 5 -29 -5 -30Z',c['cloth'],c['shade'],1.2)
  path(g,'M-7 -37 L-7 -43 Q-6 -49 0 -49 Q6 -49 7 -43 L6 -35 2 -32 -4 -34Z',c['shade'],c['lit'],.85)
  if not back:
   path(g,'M-4 -43 Q0 -46 5 -42 L5 -37 1 -34 -4 -36Z',skin,w=.6)
   path(g,'M-5 -40 Q0 -39 5 -40 L5 -35 1 -32 -4 -35Z','#202527',w=.7)
   path(g,'M-3 -38 L1 -36 M-1 -35 L2 -35','none','#42494a',.6)
   path(g,'M-3 -42 L-1 -42 M2 -42 L4 -42','none','#10181c',.6)
  path(g,'M-8 -43 Q-8 -49 -2 -51 M8 -41 L8 -34','none',c['lit'],.8)
 elif h=='beanie':
  if back:path(g,'M-5 -36 Q0 -34 5 -37','none','#795b48',.7)
  else:
   path(g,'M-4 -41 L-2 -41 M2 -41 L4 -41 M-1 -36 L2 -36','none','#4c3930',.65)
  path(g,'M-7 -42 L-8 -46 Q-6 -53 0 -53 Q7 -52 8 -46 L7 -41Z','#202527',w=1)
  path(g,'M-7 -44 Q0 -42 7 -44 L7 -41 Q0 -39 -7 -42Z','#30383b','#141b1f',.6)
  for x in [-4,-1,2,5]:path(g,f'M{x} -49 L{x} -45','none','#42494a',.55)
def palette():
 return sorted({value.lstrip('#') for c in SPECS.values() for value in c.values() if isinstance(value,str) and value.startswith('#')}|{'733039','944147','b85852','3c4948','e6d6bf','afb3aa','10181c','c0806d','be5854','953d43','4c3930','795b48','30383b'})
