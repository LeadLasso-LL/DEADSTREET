"""Original SVG-native weapon silhouettes, authored for the accepted unit rig.
Game art only; the coordinate system is the rig's attachment space.
"""
import copy,xml.etree.ElementTree as E
from pathlib import Path
N='{http://www.w3.org/2000/svg}'
DARK='#151d20';METAL='#353e42';HI='#8d979a';WOOD='#88603e'
def path(g,d,c=METAL,s=DARK,w=.7):
 return E.SubElement(g,N+'path',dict(d=d,fill=c,stroke=s,**{'stroke-width':str(w),'stroke-linejoin':'round','stroke-linecap':'round'}))
def box(g,x,y,w,h,c=METAL):return path(g,f'M{x} {y} h{w} v{h} h{-w}Z',c)
def line(g,d,c=HI,w=.6):return path(g,d,'none',c,w)
def stock(g,x=-4,y=1,wood=False,skeleton=False):
 if skeleton:
  path(g,f'M{x} {y} L8 {y} 10 {y+3} {x+1} {y+8} {x-1} {y+8}Z')
  path(g,f'M{x+2} {y+2} L5 {y+2} {x+2} {y+5}Z',DARK,'none')
 else:path(g,f'M{x} {y} L7 {y} 11 {y+4} 3 {y+6} {x} {y+10}Z',WOOD if wood else '#252e31')
 line(g,f'M{x+.5} {y+1} L5 {y+1}', '#ad7a50' if wood else HI)
def grip(g,x=11,y=7,c='#252d30'):path(g,f'M{x} {y} L{x+4} {y+1} {x+2} {y+9} {x-2} {y+8}Z',c)
def mag(g,x=21,y=7,curve=False,wide=4,length=10):
 path(g,f'M{x} {y} h{wide} q0 {length*.5} {3 if curve else 0} {length} l{-wide} 1 q{-2 if curve else 0} {-length*.5} -1 {-length+1}Z','#202a2d')
 line(g,f'M{x+1} {y+2} L{x+1+(2 if curve else 0)} {y+length-1}','#525e62',.5)
def rails(g,x,y,end):
 line(g,f'M{x} {y} H{end}',HI,.6)
 for i in range(int(x),int(end),2):box(g,i,y-1,.65,1,'#687175')
def scope(g,x=13,y=-4,length=18):
 box(g,x+4,y+2,1.5,4,DARK);box(g,x+length-5,y+2,1.5,4,DARK)
 path(g,f'M{x} {y} l4 -1 2 1 h{length-9} l3 -2 3 .5 v5 l-3 .5 -3 -1 H{x+5} l-1 1 h-4Z','#303a3e')
 line(g,f'M{x+1} {y+.3} H{x+length-1}');box(g,x+8,y-2,3,2,DARK)
def details(g,x=12,end=32):
 path(g,f'M{x+6} 2 h6 v2 h-6Z',DARK,'none');line(g,f'M{x} 1 H{end}')
 for i in [x+1,x+13]:box(g,i,5,.6,.6,HI)
def make(model,original):
 id=model['id'];kind=model['weapon_class'];base=model['art_base'];definition=copy.deepcopy(original[base])
 root=E.Element(N+'svg',{'viewBox':'-18 -12 94 40'});g=E.SubElement(root,N+'g')
 # Preserve the four approved in-game tier-one silhouettes, proportions and attachment anchors.
 preserved={'glock_17':'pistol','uzi':'uzi_smg','ak47':'ak_rifle','rem870':'pump_shotgun'}
 if id in preserved:
  art=E.parse(Path(__file__).resolve().parents[1]/'unit_source_recovery/src/weapons'/original[base]['art']).getroot()
  return copy.deepcopy(art),definition
 if kind=='pistol':
  length={'m1911':20,'usp':19,'cz75':21,'desert_eagle':25,'five_seven':20}[id]
  silver=id=='desert_eagle';color='#9ba3a4' if silver else METAL
  path(g,f'M0 -1 H{length-2} L{length} 1 V4 H6 L5 7 H0Z',color)
  path(g,'M0 4 H9 L8 8 H5 L4 15 -1 14 -1 6Z','#272f32')
  if id=='m1911':path(g,'M0 6 L4 7 3 13 0 13Z',WOOD)
  elif id=='cz75':path(g,'M0 5 Q-2 8 -2 13 L2 14 5 7Z','#283135')
  elif id=='desert_eagle':path(g,'M-1 5 L5 5 3 16 -3 16Z','#252d30')
  else:grip(g,1,5)
  path(g,'M5 5 H10 Q12 9 8 10 H4','none',DARK,.7)
  box(g,1,-2,1,1,DARK);box(g,length-2,-2,1,1,DARK)
  for x in range(1,5):line(g,f'M{x} 0 v2','#657276',.45)
  line(g,f'M1 -.2 H{length-1}', '#d6d5c9' if silver else HI)
  box(g,9,0,4,1.5,DARK);definition['muzzle']=[length,2]
  definition['scale']*=1.02 if id=='desert_eagle' else 1
 elif kind=='smg':
  if id=='mac10':
   path(g,'M10 0 H28 V8 H19 L18 10 H11Z');grip(g,13,7);mag(g,13,9,length=13)
   line(g,'M10 1 L5 1 5 9 7 9 7 3 10 3',HI,1)
   box(g,28,2,5,2,DARK);box(g,26,-2,1,2,DARK);details(g,10,27);definition['muzzle']=[33,3]
   definition['left_grip']=[24,6];definition['scale']=.73
  elif id in ['mp5','mp5k']:
   end=43 if id=='mp5' else 34
   path(g,f'M8 0 H{end-6} L{end-3} 2 V6 H20 L18 9 H10Z');grip(g,12,7);mag(g,22,7,True,length=13)
   if id=='mp5':stock(g,-4,1,skeleton=True)
   else:box(g,7,1,2,7,DARK);grip(g,29,5)
   box(g,29,1,end-29,5,'#242d30');box(g,end,2,4,2,DARK)
   box(g,end-2,-3,1.5,4,DARK);box(g,12,-2,2,2,DARK);details(g,10,27)
   definition.update(muzzle=[end+4,3],right_grip=[13,9],left_grip=[32 if id=='mp5' else 29,6],scale=.80 if id=='mp5' else .75)
  elif id=='vector':
   stock(g,-6,0,skeleton=True);path(g,'M8 0 H38 L40 3 37 7 H27 L24 19 H16 L19 7 H8Z')
   grip(g,12,6);mag(g,19,14,length=8);box(g,39,2,6,2,DARK);rails(g,10,-1,36)
   path(g,'M22 8 L27 7 24 17 21 17Z','#4a565a');details(g,10,35)
   definition.update(muzzle=[45,3],right_grip=[12,9],left_grip=[33,6],scale=.79)
  else:
   path(g,'M-2 0 Q-4 2 -3 12 L1 14 H18 Q23 12 23 7 H34 V0Z','#293336')
   path(g,'M5 7 Q3 12 9 12 Q16 11 16 7Z',DARK,'none')
   path(g,'M23 6 Q20 10 24 12 Q29 11 29 7Z',DARK,'none')
   box(g,1,-2,26,3,'#67533e');line(g,'M2 -1 H25','#a08c67')
   path(g,'M18 -3 L22 -7 31 -7 34 -2','none',METAL,2);box(g,34,2,6,2,DARK)
   definition.update(muzzle=[40,3],right_grip=[14,9],left_grip=[28,8],scale=.89)
 elif kind=='rifle':
  if id=='aug':
   path(g,'M-10 0 H31 V6 H18 L14 13 H8 L11 5 H-3 L-7 13 -11 12Z','#303a3d')
   mag(g,-1,6,True,5,10);grip(g,13,6);grip(g,31,5);box(g,31,1,22,2,DARK)
   rails(g,13,-3,33);path(g,'M13 -2 L17 -5 H31 V-2Z','#343f42');details(g,4,30)
   definition.update(right_grip=[13,10],left_grip=[32,8],muzzle=[53,2],scale=1.00)
  elif id=='m4a1':
   # Slim AR receiver, exposed buffer tube and compact telescoping stock.
   # Keep the established attachment anchors and muzzle position.
   box(g,-4,1,15,2,'#384347')
   path(g,'M-6 0 H1 L3 2 2 4 -3 5 -4 9 -6 9Z','#20292d')
   line(g,'M-5 1 H0 M-5 3 V7','#657075',.55)
   path(g,'M8 .2 H26 L29 1.5 V4.5 H23 L21 7 H17 L16 5 H10Z','#303b40')
   path(g,'M16 5 H21 V8 H16Z','none',DARK,.65)
   grip(g,11,6,'#202a2e');mag(g,22,5.5,True,3.8,11)
   box(g,29,.7,12,3.4,'#202a2e');rails(g,9,-.5,40)
   line(g,'M30 3 H40','#525f64',.55)
   for x in [31,34,37]:box(g,x,1.5,1.4,.8,DARK)
   box(g,41,1.7,9,1.5,DARK);box(g,50,1.3,2,2.4,'#30393d')
   path(g,'M40 2 L41.5 -2.8 43 2Z','none',METAL,.85)
   box(g,10,-2,1.4,1.2,DARK)
   path(g,'M17 1.1 H23 V2.6 H17Z',DARK,'none')
   line(g,'M9 1 H15 M23 4 H26','#6b797e',.5)
   definition.update(muzzle=[52,3],scale=1.10)
  else:
   end={'mini14':53,'g36c':44,'scar_h':55}[id]
   stock(g,-5,0,wood=id=='mini14',skeleton=id=='g36c')
   path(g,f'M8 0 H{end-17} L{end-12} 2 V6 H20 L18 8 H10Z')
   if id=='mini14':path(g,'M5 4 H37 V7 H13 L8 11 5 10Z',WOOD);box(g,33,0,7,4,WOOD)
   else:grip(g)
   mag(g,21,7,curve=id=='m4a1',wide=5 if id=='scar_h' else 4,length=11)
   box(g,32,1,end-39,5,'#293336');box(g,end-7,2,8,2,DARK)
   if id=='g36c':path(g,'M11 0 V-3 H31 L34 0','none',METAL,1.35)
   else:rails(g,10,-1,end-10)
   if id=='scar_h':box(g,10,-1,22,7,'#3c474b');rails(g,10,-2,42);details(g,10,31)
   for x in range(33,max(34,end-8),2):line(g,f'M{x} 2 v2','#697378',.5)
   details(g,10,30);definition.update(muzzle=[end+1,3],scale=1.03 if id=='g36c' else 1.06 if id=='scar_h' else 1.10)
 elif kind=='shotgun':
  end={'moss500':42,'spas12':54,'benelli_m2':56,'benelli_m4':55,'saiga12':53}[id]
  if id=='moss500':grip(g,11,5);definition.update(carry_origin=[31,38],scale=1.0)
  else:stock(g,-6,0,skeleton=id in ['spas12','benelli_m4','saiga12'])
  path(g,'M8 0 H29 L33 2 32 6 H13 L10 8 7 6Z');box(g,30,0,end-30,2,DARK);box(g,30,4,end-31,2,DARK)
  box(g,29,2,12,5,'#283337');details(g,11,28)
  if id in ['moss500','spas12']:
   for x in range(30,41,2):line(g,f'M{x} 3 v3','#667276',.6)
  if id=='spas12':
   box(g,27,-2,17,2,'#505a5d')
   for x in range(28,43,3):box(g,x,-2,1.5,1.5,DARK)
  if id=='saiga12':mag(g,22,7,True,6,13);grip(g);box(g,48,-3,1,4,DARK)
  if id=='benelli_m4':grip(g);rails(g,13,-2,28)
  definition.update(muzzle=[end,1],left_grip=[34 if id!='moss500' else 29,6])
 else:
  end={'sks':61,'svd':64,'ssg69':64,'awm':70,'psg1':68,'rem700':62}[id]
  wood=id in ['sks','svd','rem700'];green=id in ['ssg69','awm'];furniture=WOOD if wood else '#535e3f' if green else '#283337'
  if id=='svd':
   stock(g,-8,1,wood=True);path(g,'M-4 3 L4 3 5 5 -4 7Z',DARK,'none');grip(g,10,6,WOOD)
  elif id=='awm':
   path(g,'M-11 0 H30 L34 4 20 7 12 6 9 14 H5 V6 H-5 L-7 12 -11 12Z',furniture)
   path(g,'M0 4 Q-2 8 2 8 Q5 6 3 4Z',DARK,'none')
  else:stock(g,-8,1,wood=wood);path(g,'M-6 2 H35 L34 6 14 7 10 11 H7 L8 6 -6 8Z',furniture)
  path(g,'M8 0 H34 L38 2 V4 H12Z');box(g,36,1,end-36,2,DARK)
  if id in ['sks','svd']:box(g,30,0,13,5,WOOD)
  if id in ['svd','psg1']:mag(g,23,5,False,5,8)
  if id=='sks':path(g,'M20 5 H27 L26 10 20 9Z',DARK)
  if id=='psg1':grip(g,11,7,WOOD);box(g,30,0,17,6,'#252e31')
  if id in ['awm','psg1']:line(g,'M44 4 L42 8 H56',METAL,1.8)
  scope(g,12,-4,20 if id in ['awm','psg1'] else 17);details(g,12,32)
  if wood:line(g,'M-5 3 L3 4 M32 1 H41','#b08357',.6)
  definition.update(muzzle=[end,2],scale=.93 if id=="awm" else .96 if id=="psg1" else 1.02 if id in ['svd','ssg69'] else 1.06,carry_origin=[26,35],left_grip=[34,5])
 return root,definition

def draw_art(parent,art,reload=0):
 # No model-specific capacity mechanics. Existing role reload motion is retained.
 for child in art:parent.append(copy.deepcopy(child))
