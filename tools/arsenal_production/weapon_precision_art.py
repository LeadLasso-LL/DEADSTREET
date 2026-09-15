"""Distinct SVG display illustrations. No unit-rig or combat geometry changes."""
import xml.etree.ElementTree as E
N='{http://www.w3.org/2000/svg}'
INK='#111c20';METAL='#34464c';EDGE='#73898e';WOOD='#936344';OLIVE='#59654b'
IDS={'ak47','rem700','sks','svd','ssg69','awm','psg1'}
def p(g,d,fill=METAL,stroke=INK,w=.6,**kw):
 return E.SubElement(g,N+'path',dict(d=d,fill=fill,stroke=stroke,**{'stroke-width':str(w),'stroke-linejoin':'round','stroke-linecap':'round'},**kw))
def line(g,d,c=EDGE,w=.35):return p(g,d,'none',c,w)
def box(g,x,y,w,h,c=METAL):return p(g,f'M{x} {y}h{w}v{h}h{-w}Z',c)
def dot(g,x,y,r=.24,c=EDGE):return E.SubElement(g,N+'circle',{'cx':str(x),'cy':str(y),'r':str(r),'fill':c})
def wood(g,d,grain):
 shape=p(g,d,WOOD);key='wood_'+str(len(list(g)))
 defs=E.SubElement(g,N+'defs');clip=E.SubElement(defs,N+'clipPath',{'id':key});p(clip,d,'white','none',0)
 detail=E.SubElement(g,N+'g',{'clip-path':f'url(#{key})'})
 line(detail,grain,'#c19263',.38)
 return shape
def guard(g,x,y,w=5,h=3.7):
 p(g,f'M{x} {y}H{x+w}Q{x+w+1} {y+2} {x+w-.7} {y+h}H{x-1}Z M{x+.3} {y+.7}L{x-.2} {y+h-.7}H{x+w-1.1}Q{x+w-.1} {y+1.5} {x+w-.5} {y+.7}Z',METAL,INK,.3,**{'fill-rule':'evenodd'})
 line(g,f'M{x+2.1} {y+.5}q.6 1.4 -.8 2.2','#a6b4b2',.45)
def scope(g,x=13,y=-4,length=22,bell=3.5,c=METAL):
 # Two separate mounting rings; tapered optical bells and a slim central tube.
 y+=1.4
 for xx in [x+6,x+length-7]:box(g,xx,y+.6,1.05,max(.8,.4-y-.6),'#27373d')
 p(g,f'M{x} {y-1.1}h3.5l2 .65h{length-12}l3 {-bell/2+.45}h3.5v{bell}h-3.5l-3 {-bell/2+.45}H{x+5.5}l-2 .65H{x}Z',c)
 line(g,f'M{x+.8} {y-.65}h2.2 M{x+6} {y-.15}H{x+length-5}', '#9dafac',.3)
 box(g,x+11,y-2.2,2,1.6,'#223238');line(g,f'M{x+11.3} {y-2}h1.4',EDGE,.25)
 box(g,x+5.8,y-.8,.7,2.2,'#56666a');box(g,x+length-7,y-.8,.7,2.2,'#56666a')
 line(g,f'M{x+length-.3} {y-bell/2+.5}v{bell-.6}','#486e72',.45)
def receiver(g,end=33):
 p(g,f'M10 .2H{end}l3 1v3H13l-3 -1Z',METAL)
 line(g,f'M11 .9H{end-1} M14 3.6H{end}',EDGE,.38)
 box(g,18,1.1,9,1.4,'#17282f');line(g,'M19 1.4h7','#8e9b97',.28)
 for x in [13,29]:dot(g,x,4.7)
def bolt(g,x=28):
 line(g,f'M{x} 2l2 1.4v2.1','#b5c0b9',.65);dot(g,x+2,5.5,.68,'#24363d');dot(g,x+1.85,5.2,.2,'#afbbb4')
def barrel(g,start,end=66,y=2,thick=1.35):
 box(g,start,y,end-start,thick,'#243339');line(g,f'M{start+.5} {y+.25}H{end-.8}',EDGE,.24)
def magazine(g,x=24,y=5,length=8,width=4.8,curve=False):
 bend=3 if curve else .2
 p(g,f'M{x} {y}h{width}q-.2 {length*.55} {bend} {length}l{-width} 1q{-bend-1} {-length*.6} -1 {-length+1}Z','#28383c')
 for offset in [1.3,3]:line(g,f'M{x+offset} {y+1.6}q-.1 {length*.45} {bend-.4} {length-2}', '#617278',.28)
def precision_art(g,id):
 if id not in IDS:return False
 g.clear();g.set('id','display_firearm')
 if id=='ak47':
  wood(g,'M-9 1L2 1 9 3 8 5 3 5 -6 10 -9 10Z','M-8 2.3Q-3 1.8 3 3 M-7 4Q-3 3.4 1 4.4 M-7 6l4 -1.2')
  p(g,'M-9 1h.9v9h-.9Z','#263238')
  p(g,'M8 .7Q10 -.2 15 0H29l2 1.6v4.7H21l-2 1.7h-7L8 5Z',METAL)
  p(g,'M11 6l4 .4 -2 8.4 -4 -1Z','#654b3a');line(g,'M11 8l2 .4 M10.7 10l2 .4','#a18565',.3)
  guard(g,16,6,5.2,4)
  magazine(g,23,6.2,13,5.4,True)
  barrel(g,40,58,2.7,1.5);box(g,56.8,2.2,2.5,2.3,'#314146')
  p(g,'M32 -.2H45l1.5 1.3v1H32Z','#34454a');line(g,'M33 .35H44',EDGE,.32)
  wood(g,'M30 2.1H41l1.5 1.2 -.8 3H31l-1 -1Z','M31 3Q35 2.5 40 3.1 M31.5 5Q35 4.5 40 5')
  for x in [33,36,39]:box(g,x,1.2,1.6,.8,INK)
  p(g,'M50 2.7L51 -1h1.7l1 3.7Z','#26383e');line(g,'M51.5 -1v-1',EDGE,.5)
  box(g,27,-1,2.3,1.4,'#2b3b40')
  line(g,'M10 1H27 M12 4H24',EDGE,.4);box(g,18,1.7,9,1.2,'#19292f')
  line(g,'M22 2.1H27.5l1 .8','#a4b4b2',.38)
  line(g,'M25 4.4l4 -.7','#869697',.45)
  for x,y in [(10,4.3),(14,4.5),(28,5.2)]:dot(g,x,y)
  return True
 if id=='rem700':
  wood(g,'M-10 1L4 1 11 4H38l2 1.5 -1 1.3H17l-5 5.2 -3 -.5 1 -5 -14 4 -6 .6Z','M-9 2.5Q-3 1.5 4 3.3 M-8 4.5Q-3 3.6 3 4.5 M-8 7l10 -2 M22 5.7H36')
  p(g,'M-10 1h1v10h-1Z','#29383a');guard(g,13,6,5,3.7)
  barrel(g,32,67,2,1.2);receiver(g,31);bolt(g,28);scope(g,12,-3.5,22,3.3)
  line(g,'M10 6l1.8 1.3 M10 7.4l1 .7','#513d32',.3)
 elif id=='sks':
  wood(g,'M-9 1H3l8 2H46v4H18l-6 5 -3 -.5 .5 -5L-7 11h-2Z','M-8 2.5Q-2 2 4 3.8 M-7 5l8 -.8 M25 5.8H44')
  p(g,'M-9 1h1v10h-1Z','#2c3636');guard(g,13,6.5,5,3.5)
  barrel(g,45,64,2.3,1.1);receiver(g,30)
  wood(g,'M33 .2H43l2 1.3V3H32Z','M34 1.1H42')
  p(g,'M22 6h6l1.5 5 -4 1 -4 -1Z','#26363b');line(g,'M23 7l.3 3 3 1',EDGE,.3)
  box(g,46,.6,8,1.1,'#435256');p(g,'M57 2.7l1 -3h1.4l.8 3Z','#29393c')
  scope(g,13,-3.4,17,2.7);line(g,'M29 1.4h3l1 1',EDGE,.5)
 elif id=='svd':
  wood(g,'M-10 1H4l7 3 -1 2 -6 1 -1.5 7h-3L1 7l-10 4h-1Z M-7 3v4.5L1 5l3 -.3L2 3Z','M-8 2.1H2 M-7 8.5l6 -2 M3 9l1 -.2').set('fill-rule','evenodd')
  # Match the wood clip's hole as well, so grain never bridges the thumb opening.
  for node in g.iter(N+'clipPath'):
   for child in node:child.set('fill-rule','evenodd');child.set('clip-rule','evenodd')
  p(g,'M-10 1h1v10h-1Z','#273539');receiver(g,32);guard(g,11,6,6,3.8)
  magazine(g,23,5.8,8.7,5.5,True);barrel(g,45,68,2.1,1.15)
  wood(g,'M31 .3H44l2 1.7 -1 4H32l-1 -1Z','M32 1.3H43 M33 5H44')
  for x in [33,36,39,42]:p(g,f'M{x} 2h1.8l-.3 1.4H{x-.2}Z',INK,'none',0)
  box(g,46,.5,7,1,'#394b50');p(g,'M61 2.3l1 -3h1.5l1.1 3Z','#304249')
  box(g,67,1.5,3.2,2.2,'#3b4d50');line(g,'M68 1.8v1.5 M69 1.8v1.5',INK,.32)
  scope(g,10,-3.6,20,3,'#485952');box(g,15,-.7,2.4,1.5,'#40534f')
 elif id=='ssg69':
  p(g,'M-10 1H3l8 2H40l1.5 2 -2 1H17l-5 6 -3 -.4 1 -5L-7 10.5h-3Z',OLIVE)
  p(g,'M-10 1h1.2v9.5H-10Z','#29363a');line(g,'M-7 2.4H2 M21 5.1H37','#94a081',.4)
  barrel(g,34,68,1.8,1.65);receiver(g,32);bolt(g,29);guard(g,13,6,5,3.5);scope(g,12,-3.8,24,3.8)
  for x in [9.6,10.5,11.4]:line(g,f'M{x} 7l1 .6','#3b4d39',.28)
  dot(g,25,5.3,.7,'#273732');line(g,'M23 6H28','#8c9982',.28)
 elif id=='awm':
  p(g,'M-11 1H3l4 2H34l4 2 -2 3H17l-3 7h-4l-.4 -7H3l-2 5h-9l-3 -1Z M-5 4l-1 5h5l1.5 -5Z',OLIVE,INK,.6,**{'fill-rule':'evenodd'})
  p(g,'M-11 1h1.2v11h-1.2Z','#24353b');p(g,'M-7 -.5H2l2 1.7v1.5H-7Z','#6e795d')
  line(g,'M-5 2H1 M17 6.3H32','#93a28b',.38);guard(g,15,6,5,4)
  magazine(g,25,6.8,6,6,False);barrel(g,35,65,1.6,1.9);receiver(g,33);bolt(g,29)
  box(g,65,.7,6.5,3.4,'#3b4c51')
  for x in [66.2,68.6]:box(g,x,1.2,1.2,2.3,INK)
  scope(g,12,-4,25,4.2);box(g,41,4.2,2,2,'#43585d')
  line(g,'M42 5l-3.5 9 M43 5l4 8.5','#273b42',1);line(g,'M39 12.6l-.6 2h-1.7 M46.3 12l1.2 2h1.5',EDGE,.4)
 elif id=='psg1':
  p(g,'M-11 .8H1l5 2 5 1.2 -1 2.5H1l-4 6h-7Z','#303f44');p(g,'M-11 .8h1.3v11.7H-11Z','#17272d')
  p(g,'M-8 -.4H1l3 1.2v2H-8Z','#536066');line(g,'M-7 .5H1 M-7 5l5 .4','#83938f',.36)
  receiver(g,34);guard(g,15,6,5.6,4)
  wood(g,'M10 6l5 .8 -1.5 8.5 -5 -.5 -.5 -2Z','M10.5 8l2.5 .6 M10 10l2.6 .6 M9.7 12l2.4 .5')
  p(g,'M8 14H14l.4 1.7H8Z','#78583f');magazine(g,23.8,6,6.5,5,False)
  barrel(g,47,69,2,1.6);p(g,'M33 .6H47l2 2 -1 4H33Z','#2c3e44');line(g,'M34 1.5H46 M34 5.1H46',EDGE,.4)
  for x in [35,38,41,44]:line(g,f'M{x} 3h1.4',INK,.6)
  scope(g,12,-3.3,24,3.7);box(g,31,1,1.2,1,'#708080')
 return True
