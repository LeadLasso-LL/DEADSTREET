"""Original SVG-native equipment art; freestanding garments, no bodies or mannequins."""
from pathlib import Path
import random,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[2]
DEST=ROOT/'assets/art/equipment/armor'
N='{http://www.w3.org/2000/svg}'
E.register_namespace('',N[1:-1])
def shape(g,d,fill,stroke='#10161d',width=1.5):
 return E.SubElement(g,N+'path',{'d':d,'fill':fill,'stroke':stroke,'stroke-width':str(width),'stroke-linejoin':'round'})
def rect(g,x,y,w,h,c):return E.SubElement(g,N+'rect',dict(x=str(x),y=str(y),width=str(w),height=str(h),fill=c))
def line(g,d,c='#68747d',w=1):return shape(g,d,'none',c,w)
def make(name,tier):
 root=E.Element(N+'svg',width='576',height='672',viewBox='0 0 192 224')
 # Back panel and shoulder straps are visible through the empty neck opening.
 shape(root,'M52 35 L66 27 H126 L140 35 149 175 Q97 195 43 175Z','#1d252e')
 shape(root,'M64 28 L79 26 76 58 60 63 51 37Z','#4c5863')
 shape(root,'M113 26 L128 28 141 37 132 63 116 58Z','#333f4c')
 shape(root,'M77 31 H115 L112 53 Q96 60 80 53Z','#131a23')
 # Neck cavity stays visibly hollow, with no skin-colored or mannequin interior.
 shape(root,'M80 25 H112 L111 43 Q96 48 81 43Z','#111923')
 # Side wings and adjustable cummerbund.
 shape(root,'M40 88 L61 73 68 177 45 185 30 175 29 103Z','#303b47')
 shape(root,'M132 73 L153 87 165 104 164 176 146 185 125 177Z','#222c38')
 for y in [111,132,153]:
  shape(root,f'M31 {y} L59 {y-5} 62 {y+8} 31 {y+13}Z','#414d59')
  shape(root,f'M134 {y-5} L164 {y} 163 {y+13} 132 {y+8}Z','#35404b')
 # Identical torso envelope across all three tiers.
 body='M62 53 L76 47 Q96 59 116 47 L130 53 141 86 138 183 Q96 198 54 183 L51 86Z'
 shape(root,body,'#3b4652' if tier==1 else '#35414e')
 shape(root,'M62 57 L74 52 69 87 62 175 55 181 55 86Z','#56616b','none')
 shape(root,'M118 52 L128 57 137 87 134 181 127 174 123 86Z','#25323e','none')
 line(root,'M63 63 L56 88 59 177 Q95 188 133 178 L135 89 127 63','#69757e',.8)
 # Shoulder material and stitched edges; only modest padding at higher tiers.
 for left in [True,False]:
  a=60 if left else 116
  shape(root,f'M{a} 32 l15 -3 -1 26 -15 4Z','#53606c' if tier==3 else '#46535e')
  line(root,f'M{a+3} 34 l8 -2 M{a+3} 37 l-1 14','#86919a',.7)
  if tier>=2:
   rect(root,a-1,49,16,8,'#141d27');rect(root,a+2,51,10,2,'#84919a')
 if tier==1:
  # Soft vest: smooth quilted wrap, broad hook-and-loop waist tabs.
  line(root,'M75 74 Q96 69 117 74 M72 83 Q96 78 120 83','#4d5b68')
  for x in [70,116]:
   shape(root,f'M{x} 128 h10 v29 h-10Z','#273440')
   for y in range(132,154,5):line(root,f'M{x+2} {y} h6','#52606b',.5)
  line(root,'M68 105 Q96 110 124 105 M66 170 Q96 177 126 170','#27313b',1.3)
 elif tier==2:
  # Plate pocket, restrained webbing; no bulky ammunition attached to product.
  shape(root,'M72 69 H120 L127 86 124 167 Q96 179 68 167 L65 86Z','#424f5c')
  line(root,'M76 74 H116 L122 88 120 163 Q96 171 72 163 L70 88Z','#697984',.7)
  for y in [102,118,134,150]:
   rect(root,73,y,46,5,'#2b3743');line(root,f'M73 {y+1} h46','#5b6974',.7)
   for x in [82,96,110]:line(root,f'M{x} {y} v5','#78858d',.6)
  shape(root,'M77 171 H116 L115 179 77 179Z','#27333f')
 else:
  # Reinforced carrier: beveled pocket and stitched padded cummerbund, torso only.
  shape(root,'M74 65 H118 L129 87 127 174 116 183 H76 L65 174 63 87Z','#283744')
  shape(root,'M77 72 H115 L122 89 120 166 113 172 H79 L72 166 70 89Z','#4a5763')
  line(root,'M78 76 H114 L118 89 M76 160 L81 166 H111 L117 160','#839098',.8)
  for y in [103,117,131,145]:
   rect(root,77,y,38,4,'#263542');line(root,f'M78 {y} h36','#667785',.7)
   for x in [85,97,109]:rect(root,x,y,1,4,'#89939a')
  for x in [40,144]:
   rect(root,x,109,8,49,'#18252f');line(root,f'M{x+3} 113 v40','#65717c',.8)
 # Small matching manufacturer's tab, individual model bars, stitch and worn nylon detail.
 rect(root,83,84,26,10,'#1c2732');line(root,'M86 87 h20 M86 90 h12','#8999a7',1)
 for i in range(tier):rect(root,89+i*5,94,3,2,'#b4bbc0')
 rng=random.Random(400+tier)
 for i in range(145):
  x=rng.randrange(60,131);y=rng.randrange(99,174)
  if (x-95)**2/1500+(y-130)**2/8000<1:
   E.SubElement(root,N+'rect',dict(x=str(x),y=str(y),width='1',height='1',fill='#bac3cb' if i%4==0 else '#111923',opacity='.10'))
 DEST.mkdir(parents=True,exist_ok=True)
 (DEST/(name+'.svg')).write_bytes(E.tostring(root))
for tier,name in enumerate(['patrol_vest','field_carrier','reinforced_carrier'],1):make(name,tier)
print('ARMOR_SOURCES_COMPLETE 3')
