from pathlib import Path
import sys,math,json,hashlib,subprocess,concurrent.futures,xml.etree.ElementTree as E
import numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).parent;sys.path.insert(0,str(R/'src'))
import directions,equipment
OUT=R/'rendered';OUT.mkdir(exist_ok=True)
PAL=np.array([tuple(bytes.fromhex(c)) for c in ['111819','202527','353b3d','42494a','555c59','67716c','795139','a67550','b28f79','d0b49a','aa8060','c39b77','d6d5c9','eeeee2','a7ada4','707572','959991','515956','686e6b','868d87','282d30','484e50','181e21','3b2c25','65503c','88603e','a98538','d2b15d']],dtype=np.int32)
CLIPS={'cover_over':40,'cover_edge':32,'hit':16,'injured_run':24,'death':24,'reload':40};FPS=16

def smooth(t):t=min(1,max(0,t));return t*t*(3-2*t)
def state(clip,i,w):
 t=i/(CLIPS[clip]-1);st=dict(q=1.25,settle=1,aim=.8,kick=0,flash=False,crouch=0,fall=0,lean=0,reload=0)
 if clip=='cover_over':
  st['crouch']=smooth(t/.22) if t<.4 else (1-.85*smooth((t-.4)/.17) if t<.57 else (.15 if t<.72 else .15+.85*smooth((t-.72)/.18)))
  st['aim']=1;st['flash']=i in [24,27];st['kick']=.8 if st['flash'] else 0
 elif clip=='cover_edge':
  peek=smooth(t/.3)*(1-smooth((t-.65)/.25));st.update(crouch=.55,lean=-20*peek,aim=peek,flash=i in [14,18]);st['kick']=.6 if st['flash'] else 0
 elif clip=='hit':
  impact=math.sin(math.pi*min(1,t/.65))*math.exp(-t*1.4);st.update(lean=-14*impact,crouch=.2*impact,aim=.8-.4*impact,kick=impact*2)
 elif clip=='injured_run':st.update(q=i/24,settle=.35,crouch=.18+.04*math.sin(2*math.pi*t),lean=5,aim=.15)
 elif clip=='death':
  drop=max(0,min(1,(t-.10)/.45));fall=drop*drop
  settle_t=max(0,(t-.55)/.45)
  bounce=math.sin(min(1,settle_t)*math.pi*2)*math.exp(-settle_t*5) if t>.55 else 0
  buckle=.22*math.sin(math.pi*min(1,t/.32))*(1-fall)
  st.update(crouch=.9*fall+buckle-.06*max(0,bounce),fall=fall-.025*max(0,bounce),lean=-10*math.sin(math.pi*min(1,t/.28))*(1-fall),aim=.2,q=1.15)
 elif clip=='reload':st.update(aim=.1,reload=t,lean=2*math.sin(math.pi*t))
 return st

def generate(k,w,d,clip,i):
 st=state(clip,i,w);root=directions.make(k,st.pop('q'),d,w,**st)
 data=E.tostring(root);key=hashlib.sha256(data).hexdigest()[:20];return key,data

def batch(items):
 pending=[]
 for key,data in items:
  png=OUT/(key+'.png')
  if png.exists():continue
  svg=OUT/(key+'.svg');svg.write_bytes(data);pending.append((key,svg))
 if not pending:return
 commands='\n'.join(f'file-open:{svg.resolve()};export-filename:{(OUT/(key+".raw.png")).resolve()};export-width:256;export-do;file-close' for key,svg in pending)+'\n'
 subprocess.run(['inkscape','--shell'],input=commands,text=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True)
 for key,_ in pending:
  raw=OUT/(key+'.raw.png')
  with Image.open(raw) as im:a=np.array(im.convert('RGBA').resize((128,128),Image.Resampling.LANCZOS))
  idx=((a[:,:,:3].astype(np.int32)[:,:,None,:]-PAL)**2).sum(3).argmin(2);a[:,:,:3]=PAL[idx];a[:,:,3]=np.where(a[:,:,3]>=128,255,0)
  Image.fromarray(a).save(OUT/(key+'.png'));raw.unlink()

def tile(k,w,d,c,i):return Image.open(OUT/(generate(k,w,d,c,i)[0]+'.png')).convert('RGBA')
def board(k,w,c,i):
 im=Image.new('RGB',(1024,584),'#303938');dr=ImageDraw.Draw(im)
 for j,d in enumerate(directions.NAMES):
  x=j%4*256;y=j//4*292;dr.text((x+12,y+12),d+' / '+c.replace('_',' ').upper(),fill='#eeeee2');sp=tile(k,w,d,c,i).resize((256,256),Image.Resampling.NEAREST);im.paste(sp,(x,y+28),sp)
 return im
if __name__=='__main__':
 sample='--sample' in sys.argv
 tasks=[(k,w,d,c,i) for k in ([1] if sample else range(3)) for w in ([equipment.DEFAULTS[k]] if sample else equipment.DEFAULTS) for d in (['E','SE','SW','N'] if sample else directions.NAMES) for c,n in CLIPS.items() for i in ([0,n//3,2*n//3,n-1] if sample else range(n))]
 unique={};mapping={}
 for k,w,d,c,i in tasks:key,data=generate(k,w,d,c,i);unique[key]=data;mapping[f'{k}/{w}/{d}/{c}/{i}']=key
 print(len(tasks),'frames;',len(unique),'unique',flush=True)
 items=list(unique.items());chunks=[items[j:j+100] for j in range(0,len(items),100)]
 with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
  for j,_ in enumerate(pool.map(batch,chunks)):
   if j%10==0:print('Batches complete',j+1,'/',len(chunks),flush=True)
 if sample:
  im=Image.new('RGB',(1024,6*300),'#303938');dr=ImageDraw.Draw(im)
  for row,(c,n) in enumerate(CLIPS.items()):
   for col,d in enumerate(['E','SE','SW','N']):
    i=n-1 if c=='death' else (n//3 if c=='reload' else 2*n//3)
    sp=tile(1,'ak_rifle',d,c,i).resize((256,256),Image.Resampling.NEAREST);im.paste(sp,(col*256,row*300+28),sp);dr.text((col*256+12,row*300+10),c+' / '+d,fill='white')
  im.save(R/'sample.png')
 else:
  (R/'frames.json').write_text(json.dumps(mapping))
  for c,n in CLIPS.items():
   seq=[board(1,'ak_rifle',c,i) for i in range(n)];seq[0].save(R/(c+'.gif'),save_all=True,append_images=seq[1:],duration=63,loop=0,disposal=2)
 print('Done',flush=True)
