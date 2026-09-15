"""Refresh card-only weapon layers from current Arsenal SVGs, preserving accepted anatomy."""
from pathlib import Path
import sys,json,copy,hashlib,zipfile,io,subprocess,xml.etree.ElementTree as E
import numpy as np
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).resolve().parents[2];O=Path(__file__).resolve().parent;N='{http://www.w3.org/2000/svg}'
sys.path.insert(0,str(R/'tools/faction_roster'));from build_roster import finish_exact
rows=json.loads((O/'inventory.json').read_text());byvariant={r['variant']:r for r in rows}
art={m:E.parse(R/f'assets/art/weapons/arsenal/source/{m}.svg').getroot() for m in {r['model'] for r in rows}}
art_hash={m:hashlib.sha256(E.tostring(a)).hexdigest() for m,a in art.items()}
def guns(root):
 parents={c:p for p in root.iter() for c in p}
 return [(n,parents[n]) for n in root.iter() if n.get('id') in ['muzzle_anchor','muzzle_left','muzzle_right']]
def naked(root):
 root=copy.deepcopy(root)
 for anchor,g in guns(root):
  for node in list(g):
   if node is not anchor:g.remove(node)
 return E.tostring(root)
E.register_namespace('',N[1:-1]);jobs=[];palettes={};structural=[]
with zipfile.ZipFile(O/'accepted_card_sources.zip') as z:
 for name in z.namelist():
  data=json.loads(z.read(name))
  for label,svg in data['jobs']:
   if not label.endswith('_after'):continue
   v,direction=label.rsplit('_',2)[:2];row=byvariant[v]
   root=E.fromstring(svg);baseline=naked(root);targets=guns(root)
   assert len(targets)==(2 if row['group']=='specialist' else 1),(v,len(targets))
   for anchor,g in targets:
    for node in list(g):
     if node is not anchor:g.remove(node)
    definition=json.loads((R/f"assets/art/weapons/arsenal/source/{row['model']}.json").read_text())
    sniper=row['model'] in ['rem700','sks','svd','ssg69','awm','psg1']
    gx,gy=definition['right_grip']
    wrapper=E.Element(N+'g',{'transform':f'translate({gx} {gy}) scale(0.9) translate({-gx} {-gy})'}) if sniper else E.Element(N+'g')
    for node in art[row['model']]:wrapper.append(copy.deepcopy(node))
    g.insert(0,wrapper)
   assert naked(root)==baseline,(v,'outside weapon changed')
   outname=v+'_'+direction
   jobs.append([outname,E.tostring(root,encoding='unicode')])
   palettes[v]=(data['palette'],name[:-5])
   structural.append({'variant':v,'direction':direction,'weapon_groups':len(targets),'outside_weapon_svg_identical':True,'weapon_source_sha256':art_hash[row['model']]})
(O/'card_jobs.json').write_text(json.dumps({'jobs':jobs}),encoding='utf-8')
(O/'structural_validation.json').write_text(json.dumps(structural,indent=2),encoding='utf-8')
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (O/'render.log').open('w',encoding='utf-8') as f:
 p=subprocess.run([godot,'--headless','--path',str(R),'--script','res://tools/weapon_card_refresh_20260915/render.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=90)
assert p.returncode==0,(O/'render.log').read_text()
def arr(im):
 a=np.array(im.convert('RGBA'));a[a[:,:,3]==0]=0;return a
report=[]
with zipfile.ZipFile(O/'before_portraits.zip') as backup:
 for row in rows:
  v=row['variant'];palette,profile=palettes[v];palette=np.array(palette,dtype=np.int32)
  crop=(18,12,108,92) if row['group'] in ['base','arsenal'] else (18,6,108,86)
  original=Image.open(io.BytesIO(backup.read(row['portrait']))).convert('RGBA')
  with zipfile.ZipFile(O/'accepted_baseline_renders.zip') as baseline_zip:baseline=Image.open(io.BytesIO(baseline_zip.read(v+'_SW_after.png'))).convert('RGBA').crop(crop)
  assert np.array_equal(arr(baseline),arr(original)),(v,'accepted source mismatch')
  for direction in ['SW','SE']:
   path=O/'renders'/(v+'_'+direction+'.png')
   if profile in ['mercer','orlov'] and row['group']=='arsenal':
    pal=Image.new('P',(1,1));pal.putpalette((palette.astype('uint8').reshape(-1).tolist()+[0]*768)[:768])
    im=Image.open(path).convert('RGBA');alpha=im.getchannel('A').point(lambda x:255 if x>=128 else 0)
    rgb=im.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(alpha);rgb.save(path)
   else:finish_exact(path,palette)
   candidate=Image.open(path).convert('RGBA').crop(crop)
   candidate.save(O/'review'/(v+'_'+direction+'.png'))
   if direction=='SW':
    assert candidate.size==original.size
    candidate.save(O/'candidates'/(v+'.png'))
    changed=np.any(arr(candidate)!=arr(original),axis=2)
    yy,xx=np.nonzero(changed)
    report.append(dict(row,changed_pixels=int(changed.sum()),bounds=[int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)] if len(xx) else [],before_sha256=hashlib.sha256(backup.read(row['portrait'])).hexdigest(),candidate_sha256=hashlib.sha256((O/'candidates'/(v+'.png')).read_bytes()).hexdigest()))
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',13)
# Three pages cover all thirty models for each faction; two angles are shown at readable size.
for page in range(3):
 shown=[r for r in rows if r['faction']=='mercer' and r['group']!='specialist'][page*10:page*10+10]
 board=Image.new('RGB',(1200,((len(shown)+3)//4)*270),'#263338');dr=ImageDraw.Draw(board)
 for i,row in enumerate(shown):
  x=i%4*300;y=i//4*270;dr.text((x+6,y+6),row['model'],font=font,fill='#e2d6bd')
  for j,direction in enumerate(['SW','SE']):
   im=Image.open(O/'review'/(row['variant']+'_'+direction+'.png')).convert('RGBA').resize((180,160),Image.Resampling.NEAREST)
   board.paste(im,(x+j*145-15,y+28),im)
  im=Image.open(O/'candidates'/(row['variant']+'.png')).convert('RGBA');board.paste(im,(x+102,y+197),im)
 board.save(O/'review'/('mercer_models_'+str(page)+'.png'))
# Every canonical faction/class glossary card on five class boards.
for role in ['pistol','smg','rifle','shotgun','sniper']:
 shown=[r for r in rows if r.get('glossary_role')==role]
 board=Image.new('RGB',(1200,((len(shown)+7)//8)*195),'#263338');dr=ImageDraw.Draw(board)
 for i,row in enumerate(shown):
  x=i%8*150;y=i//8*195;dr.text((x+3,y+3),row['faction'],font=font,fill='#e2d6bd');dr.text((x+3,y+21),row['model'],font=font,fill='#b8c7bf')
  im=Image.open(O/'candidates'/(row['variant']+'.png')).convert('RGBA').resize((144,128),Image.Resampling.NEAREST);board.paste(im,(x+3,y+47),im)
 board.save(O/'review'/('glossary_'+role+'.png'))
# Readable review of all eight trigger edits.
ids=json.loads((O/'icon_jobs.json').read_text())['jobs'];board=Image.new('RGB',(1200,4*220),'#263338');dr=ImageDraw.Draw(board)
for i,(id,_) in enumerate(ids):
 x=i%2*600;y=i//2*220;dr.text((x+12,y+8),id,font=font,fill='#e2d6bd')
 im=Image.open(O/'renders'/('icon_'+id+'.png')).convert('RGBA');im.thumbnail((570,165),Image.Resampling.LANCZOS);board.paste(im,(x+15,y+38),im)
board.save(O/'review/triggers.png')
(O/'asset_validation.json').write_text(json.dumps({'portraits':len(report),'directions':len(structural),'baseline_mismatches':0,'rows':report},indent=2),encoding='utf-8')
print('CARD_CANDIDATES',len(report),'CHANGED',sum(r['changed_pixels']>0 for r in report),'STRUCTURAL',len(structural),'BASELINE_MISMATCHES 0',flush=True)
