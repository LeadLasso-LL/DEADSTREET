"""Build card-only deltas. Does not overwrite installed portraits; use install.py after visual review."""
from pathlib import Path
import sys,json,subprocess,hashlib,concurrent.futures,zipfile,io
from PIL import Image,ImageDraw,ImageFont
import numpy as np
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
sys.path.insert(0,str(R/'tools/faction_roster'))
from build_roster import finish_exact
inventory=json.loads((O/'inventory.json').read_text())
rows=[x for x in inventory if x['group']!='mercer']
profiles=list(dict.fromkeys(x['faction'] for x in rows))
for folder in ['renders','candidates','review']:(O/folder).mkdir(exist_ok=True)
def build(profile):
 subprocess.run([sys.executable,str(O/'worker.py'),profile],cwd=R,check=True)
 job=O/'jobs'/(profile+'.json');data=json.loads(job.read_text())
 p=subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe','--headless','--path',str(R),'--script',str(O/'render.gd'),'--',str(job),str(O/'renders')],capture_output=True,text=True)
 assert p.returncode==0,p.stdout+p.stderr
 palette=np.array(data['palette'],dtype=np.int32)
 pal=Image.new('P',(1,1));pal.putpalette((palette.astype('uint8').reshape(-1).tolist()+[0]*768)[:768])
 for name,svg in data['jobs']:
  path=O/'renders'/(name+'.png')
  if profile in ['mercer','orlov'] and not name.startswith(('0_pistol','1_pistol')):
   im=Image.open(path).convert('RGBA');alpha=im.getchannel('A').point(lambda x:255 if x>=128 else 0)
   rgb=im.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(alpha);rgb.save(path)
  else:finish_exact(path,palette)
 return profile
if '--reuse' not in sys.argv:
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
  for profile in pool.map(build,profiles):print('FINISHED_PROFILE',profile,flush=True)
def array(im):
 a=np.array(im.convert('RGBA'));a[a[:,:,3]==0]=0;return a
def crop(row):
 return (32,30,96,80) if row['group']=='base' else ((18,12,108,92) if row['group']=='arsenal' else (18,6,108,86))
report=[]
with zipfile.ZipFile(O/'before_portraits.zip') as backup:
 for row in rows:
  v=row['variant'];source=R/row['portrait'];original=Image.open(io.BytesIO(backup.read(row['portrait']))).convert('RGBA')
  a=array(Image.open(O/'renders'/(v+'_SW_before.png')).crop(crop(row)))
  b=array(Image.open(O/'renders'/(v+'_SW_after.png')).crop(crop(row)))
  installed=array(original);assert installed.shape==a.shape
  assert np.array_equal(a,installed),(v,'source baseline changed; inspect before regeneration')
  changed=np.any(a!=b,axis=2);assert 0<changed.sum()<350,(v,int(changed.sum()))
  yy,xx=np.nonzero(changed)
  result=installed.copy();result[changed]=b[changed]
  assert np.array_equal(result[~changed],installed[~changed])
  candidate=O/'candidates'/(v+'.png');Image.fromarray(result).save(candidate)
  report.append(dict(variant=v,portrait=row['portrait'],dimensions=original.size,changed_pixels=int(changed.sum()),delta_bounds=[int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)],baseline_mismatch=int(np.any(a!=installed,axis=2).sum()),before_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),candidate_sha256=hashlib.sha256(candidate.read_bytes()).hexdigest()))
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',14)
for page in range((len(profiles)+3)//4):
 subset=profiles[page*4:page*4+4];board=Image.new('RGB',(1296,len(subset)*286),'#263033');d=ImageDraw.Draw(board)
 for y,profile in enumerate(subset):
  for x,row in enumerate([r for r in rows if r['faction']==profile]):
   v=row['variant'];px=x*216;py=y*286
   d.text((px+4,py+3),profile,font=font,fill='#e9e3d6');d.text((px+4,py+20),row['model']+'  SW / SE',font=font,fill='#c3ccc8')
   for col,direction in enumerate(['SW','SE']):
    actor=Image.open(O/'renders'/(v+'_'+direction+'_after.png')).convert('RGBA').crop((30,28,100,86)).resize((140,116),Image.Resampling.NEAREST)
    board.paste(actor,(px+col*105-17,py+40),actor)
   installed=Image.open(O/'candidates'/(v+'.png')).convert('RGBA')
   board.paste(installed,(px+62,py+180),installed)
 board.save(O/'review'/('all_models_'+str(page)+'.png'))
(O/'validation.json').write_text(json.dumps(dict(profiles=len(profiles),portraits=len(rows),directions_checked=len(rows)*2,items=report),indent=2)+'\n')
print('READY',len(rows),'BASELINE_MISMATCH',sum(x['baseline_mismatch'] for x in report),'CHANGED_PIXELS',sum(x['changed_pixels'] for x in report),flush=True)
print('MISMATCH_EXAMPLES',[(x['variant'],x['baseline_mismatch']) for x in report if x['baseline_mismatch']][:20])
