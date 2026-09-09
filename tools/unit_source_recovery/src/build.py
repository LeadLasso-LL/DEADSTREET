from pathlib import Path
import math, xml.etree.ElementTree as E, subprocess, concurrent.futures, zipfile
import numpy as np
from PIL import Image, ImageDraw
import base_rig as B
import equipment
R=Path(__file__).parent
N=B.NS
def group(parent,**attrs): return E.SubElement(parent,N+'g',attrs)
def p(g,d,c,s='#14191a',w=.8): B.path(g,d,c,s,w)
def make(kind,q,weapon_id=None,settle=0,aim=0,kick=0,flash=False,crouch=0,fall=0,lean=0,reload=0):
 weapon_id=weapon_id or equipment.DEFAULTS[kind]
 weapon=equipment.DEFINITIONS[weapon_id]
 root,_=B.make(q,aim=aim,kick=kick,settle=settle,crouch=crouch,fall=fall)
 up=root.find(".//*[@id='upper_pose']")
 up.set('transform',up.get('transform')+f' rotate({lean} 43 55)')
 headtf=up.find(".//*[@id='head']").get('transform')
 up[:]=[]
 skin,hi=('#795139','#a67550') if kind==0 else (('#b28f79','#d0b49a') if kind==1 else ('#aa8060','#c39b77'))
 cloth=('#d6d5c9','#707572','#282d30')[kind]
 shine=('#eeeee2','#959991','#484e50')[kind]
 # Keep all lower-body geometry and contact timing; change only fabric/footwear colors.
 cmap={'#252c2e':('#202527','#686e6b','#292e31')[kind], '#42494a':('#353b3d','#868d87','#42494a')[kind], '#414337':('#202527','#d6d5c9','#202527')[kind], '#666453':('#555c59','#eeeee2','#626765')[kind], '#555849':('#353b3d','#b4b9ac','#42494a')[kind]}
 for el in root.iter():
  for a in ['fill','stroke']:
   if el.get(a) in cmap:el.set(a,cmap[el.get(a)])
 # Outfit and equipment are independent; hands use equipment-local anchors.
 angle=weapon['carry_angle']+(1.2*math.sin(4*math.pi*q) if weapon_id!='pistol' else 0)
 origin=np.array(weapon['carry_origin'],float)+[0,.7*math.sin(4*math.pi*q)]
 angle+=18*__import__('math').sin(__import__('math').pi*reload)
 angle=angle*(1-aim)+(15 if weapon_id!='pistol' else 8)*aim-kick*2
 origin+=np.array([4*aim-1.4*kick,-10*aim-.6*kick])
 carry=1.5*math.sin(2*math.pi*(q-.12))*(1-settle)*(1-aim)*(1-fall)
 origin+=np.array([carry,.25*carry])
 rot=np.array([[math.cos(math.radians(angle)),-math.sin(math.radians(angle))],[math.sin(math.radians(angle)),math.cos(math.radians(angle))]])
 weapon_scale=weapon['scale']
 grips=[np.array(weapon[key])*weapon_scale for key in ['right_grip','left_grip']]
 left_world=equipment.support_target(reload,origin+rot@grips[1],origin,rot*weapon_scale,weapon_id,[47,53])
 grips[1]=rot.T@(left_world-origin)
 grips=[g*(1-fall)+rot.T@(np.array(target)-origin)*fall for g,target in zip(grips,[[30,50],[50,53]])]
 def arm(parent,a,b,c):
  a,b,c=map(lambda v:np.array(v,float),(a,b,c))
  # A continuous shoulder cap reaches inward under the neckline and
  # overlaps the upper arm. No flat transverse cut at the arm root.
  near=a[0]<40
  inner=np.array([32.,28.5]) if near else np.array([47.,28.5])
  outer=a+([-2.6,-1.5] if near else [2.6,-1.5])
  v=b-a; v=v/np.linalg.norm(v); n=np.array([-v[1],v[0]])
  left=b+n*3.15;right=b-n*3.15
  def xy(t):return f'{t[0]:.3f} {t[1]:.3f}'
  p(parent,f'M{xy(inner)} Q{xy(a+[0,-4])} {xy(outer)} Q{xy(a+v*6+n*3.7)} {xy(left)} Q{xy(b+v*1.2)} {xy(right)} L{xy(a+v*3-n*3.2)} Q{xy(a+[2 if near else -2,0])} {xy(inner)}Z',skin if kind==0 else cloth)
  p(parent,f'M{xy(a+[.2,-1])} Q{xy(a+v*4+n*.7)} {xy(b-v*2+n*.8)}','none',hi if kind==0 else shine,1.15)
  B.limb(parent,b,c,3.2,2.3,skin if kind==0 else cloth)
  list(parent)[-1].set('fill',hi if kind==0 else shine)
  E.SubElement(parent,N+'circle',{'cx':str(b[0]),'cy':str(b[1]),'r':'3.1','fill':skin if kind==0 else cloth})
 far=group(up);arm(far,[51.8,32.5],[56+2*aim,48-6*aim],origin+rot@grips[1])
 torso=group(up)
 p(torso,'M31 28 L38 26 48 27 53 31 52 43 55 55 Q43 61 30 56 L28 43Z',cloth)
 p(torso,'M32 34 L36 33 35 47 39 55 32 54Z',shine,'none')
 p(torso,'M48 34 L50 42 49 52 45 57 53 55 51 42Z',('#a7ada4','#515956','#181e21')[kind],'none')
 # Neck is joined into the collar; no floating head.
 p(torso,'M38 24 L46 24 47 30 43 33 37 29Z',skin)
 if kind==0:
  p(torso,'M32 28 L37 27 Q37 35 44 35 Q49 34 48 28 L51 30 Q51 39 44 39 Q34 37 32 28Z',shine,'none')
  p(torso,'M37 29 Q39 40 47 34','none','#a98538',1.1)
  p(torso,'M38 31 Q40 38 45 35','none','#d2b15d',.65)
 elif kind==1:
  p(torso,'M38 28 L42 34 45 29 M42 34 L43 56','none','#c5c8bd',.8)
  p(torso,'M31 29 L34 31 32 42 M49 29 L51 32 50 39','none','#d6d5c9',1.2)
  p(torso,'M33 48 L38 47 M47 48 L50 46','none','#363e3c',.8)
 else:
  p(torso,'M37 28 L43 33 47 28 45 46Z','#d6d5c9')
  p(torso,'M33 28 L37 28 42 43 36 38 37 34Z','#484e50')
  p(torso,'M48 28 L50 30 46 37 47 40 42 46Z','#484e50')
  p(torso,'M42 34 L44 35 44 44 42 47 41 43Z','#252a2c','none')
  p(torso,'M42 47 L42 57 M31 51 L37 51','none','#111819',.8)
 head=group(up,transform=headtf)
 p(head,'M36 14 Q42 10 49 15 L50 23 47 29 41 30 36 26 34 21Z',skin)
 p(head,'M37 18 L41 17 44 21 42 26 38 24Z',hi,'none')
 if kind==0:
  p(head,'M34 23 L34 14 Q34 7 42 7 Q50 7 51 15 L50 25 46 30 39 29Z','#202527')
  p(head,'M36 17 Q42 15 48 18 L47 21 36 20Z',skin,'#111819',.6)
  p(head,'M37 18 L39 18 M44 19 L46 19','none','#111819',.75)
  p(head,'M36 12 Q40 9 44 10 M36 24 L39 26','none','#42494a',.7)
 else:
  p(head,'M34 20 L34 13 Q37 5 45 8 Q51 9 51 17 L48 20 47 15 39 15 36 22Z','#3b2c25' if kind==1 else '#171d20')
  p(head,'M36 13 Q42 10 48 12','none','#65503c' if kind==1 else '#41494a',.8)
  if kind==1:
   p(head,'M35 19 L49 20 48 23 43 23 41 21 40 23 36 22Z','#111819')
   p(head,'M37 20 L39 20 M44 21 L47 21','none','#747f7b',.55)
  else:
   p(head,'M34 16 L36 22 35 27 38 29 36 18Z','#171d20','none')
   p(head,'M38 21 L40 21 M45 22 L47 22 M41 27 L45 27','none','#49382e',.65)
 near=group(up);arm(near,[27,32.5],[25+5*aim,49-5*aim],origin+rot@grips[0])
 # Bring the distal support forearm over the shirt edge into the palm.
 support_end=origin+rot@grips[1]
 support_elbow=np.array([56+2*aim,48-6*aim],float)
 sleeve_start=support_elbow*.55+support_end*.45
 B.limb(up,sleeve_start,support_end,2.8,2.3,skin if kind==0 else cloth)
 list(up)[-1].set('fill',hi if kind==0 else shine)
 gun=group(up,transform=f'translate({origin[0]} {origin[1]}) rotate({angle})')
 grip_parent=gun
 gun=group(grip_parent,transform=f'scale({weapon_scale})')
 if fall<.45:equipment.draw(gun,weapon_id,reload)
 gun=grip_parent
 for hand_index,(x,y) in enumerate(grips):
  if weapon_id=='ak_rifle' and hand_index==0 and fall==0:
   # Palm encloses the angled pistol grip below the receiver; index
   # finger reaches forward into the trigger area, away from magazine.
   p(gun,'M8.5 7.2 Q10 6.8 11.5 8 L13 9 Q14 10 12.9 12.3 L11.4 13 Q9.5 12.4 8.4 11Z',skin,'#382b25',.55)
   p(gun,'M10 8 Q11.7 7 13 7.6 L15 8.1 14.6 9.2 12.1 9.2Z',hi,'#65503c',.4)
   p(gun,'M9.5 10 L12 10.8 M9.5 11.4 L11.6 12','none','#65503c',.5)
   continue
  p(gun,f'M{x-2} {y-2} Q{x} {y-3} {x+2} {y-1} L{x+2} {y+2} Q{x} {y+3} {x-2} {y+1}Z',skin,'#382b25',.6)
  p(gun,f'M{x-1} {y-1} L{x+1} {y}','none',hi,.65)
 if weapon_id!='pistol':
  x,y=grips[1];p(gun,f'M{x-3} {y-3} L{x+3} {y-3}','none','#111819',1)
 if flash:
  x,y=np.array(weapon["muzzle"])*weapon_scale
  p(gun,f'M{x} {y} L{x+3} {y-2} {x+8} {y} {x+3} {y+2}Z',"#eeeee2","#d2b15d",.6)
 return root

def render(job):
 k,i,*selected=job;weapon_id=selected[0] if selected else None
 folder=R/'frames'/(str(k) if weapon_id is None else f'{k}_{weapon_id}');folder.mkdir(exist_ok=True)
 svg=folder/f'{i:02}.svg';png=folder/f'{i:02}.png'
 E.ElementTree(make(k,i/24,weapon_id)).write(svg)
 subprocess.run(['inkscape',str(svg),'--export-filename='+str(png),'--export-width=256'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True)
 im=Image.open(png).convert('RGBA').resize((128,128),Image.Resampling.LANCZOS)
 a=np.array(im);a[:,:,3]=np.where(a[:,:,3]>=128,255,0)
 # Quantized, restrained pixel palette; stable colors across animation frames.
 colors=['111819','202527','353b3d','42494a','555c59','67716c','795139','a67550','b28f79','d0b49a','aa8060','c39b77','d6d5c9','eeeee2','a7ada4','707572','959991','515956','686e6b','868d87','282d30','484e50','181e21','3b2c25','65503c','88603e','a98538','d2b15d']
 pal=np.array([tuple(bytes.fromhex(c)) for c in colors],dtype=np.int32)
 idx=((a[:,:,:3].astype(np.int32)[:,:,None,:]-pal)**2).sum(3).argmin(2);a[:,:,:3]=pal[idx]
 Image.fromarray(a).save(png)
 return str(png)
if __name__=='__main__':
 with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:list(pool.map(render,[(k,i) for k in range(3) for i in range(24)]))
 frames=[]
 for i in range(24):
  im=Image.new('RGB',(960,430),'#202526');d=ImageDraw.Draw(im)
  for k,label in enumerate(['STREET GANG / SMG','RUSSIAN MAFIA / AK','ITALIAN MOB / PISTOL']):
   x=k*320;d.rectangle((x+8,8,x+311,421),outline='#49514b');d.text((x+26,20),label,fill='#ddd9c6')
   sprite=Image.open(R/'frames'/str(k)/f'{i:02}.png').resize((384,384),Image.Resampling.NEAREST)
   im.paste(sprite,(x-32,35),sprite)
  frames.append(im)
 frames[0].save(R/'faction_lineup.png')
 frames[0].save(R/'faction_jog.gif',save_all=True,append_images=frames[1:],duration=[33,33,34]*8,loop=0,disposal=2)
 with zipfile.ZipFile(R/'faction_sources.zip','w',zipfile.ZIP_DEFLATED) as z:
  for f in R.rglob('*'):
   if f.is_file() and f.suffix in ['.py','.svg','.png','.md','.json'] and '__pycache__' not in str(f):z.write(f,f.relative_to(R))
