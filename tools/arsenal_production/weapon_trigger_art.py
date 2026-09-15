"""Readable trigger blades and open guards for shotgun, Mini-14 and AUG display art."""
import xml.etree.ElementTree as E
N='{http://www.w3.org/2000/svg}'
IDS={'rem870','moss500','spas12','benelli_m2','benelli_m4','saiga12','mini14','aug'}
def path(g,d,fill,stroke='#152126',width=.45,**kw):
 return E.SubElement(g,N+'path',dict(d=d,fill=fill,stroke=stroke,**{'stroke-width':str(width),'stroke-linejoin':'round','stroke-linecap':'round'},**kw))
def apply_trigger(g,id):
 if id not in IDS:return
 if id=='rem870':
  for parent in g.iter():
   for node in list(parent):
    if node.get('d')=='M14 7 Q20 6 19 10 Q16 12 12 10':parent.remove(node)
 # Open holes stay transparent; the curved trigger remains a separate visible part.
 x,y,w,h={'rem870':(13.9,6.9,5.8,4.4),'moss500':(15.1,6.4,6.1,4.8),
 'spas12':(13.8,6.15,6.3,4.3),'benelli_m2':(13.8,6.15,6.1,4.1),
 'benelli_m4':(15.1,6.4,6.1,4.4),'saiga12':(15.1,6.5,5.8,4.2),
 'mini14':(12.5,6.8,5.6,4.1),'aug':(16.,5.9,10.4,7.8)}[id]
 g=E.SubElement(g,N+'g',{'id':'trigger_assembly'})
 # The AUG has its characteristic roomy full-hand guard; the others have compact oval frames.
 wall=.85 if id=='aug' else .65
 outer=f'M{x} {y} H{x+w-.8} Q{x+w+1.1} {y+h*.45} {x+w-1.2} {y+h} H{x-.3} Q{x-1.2} {y+h*.6} {x} {y}Z'
 inner=f'M{x+wall} {y+wall} Q{x-.1} {y+h*.5} {x+wall*.5} {y+h-wall} H{x+w-1.5} Q{x+w-.1} {y+h*.5} {x+w-1.2} {y+wall}Z'
 path(g,outer+' '+inner,'#56676c',width=.4,**{'fill-rule':'evenodd'})
 tx=x+(2.1 if id=='aug' else 1.9);ty=y+.45;th=3.6 if id=='aug' else h-1.3
 path(g,f'M{tx} {ty}h.95 Q{tx+1.4} {ty+th*.6} {tx-.05} {ty+th}l-.6 -.48 Q{tx+.55} {ty+th*.5} {tx} {ty}Z','#acb8b6',width=.28)
 path(g,f'M{x+1.} {y+h-.4} H{x+w-1.8}','none','#899c9d',.28)
