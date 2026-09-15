from pathlib import Path
import json,sys,subprocess,concurrent.futures,zipfile,io
from PIL import Image,ImageDraw,ImageFont
import numpy as np
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
sys.path.insert(0,str(R/'tools/faction_roster'));from build_roster import finish_exact
rows=json.loads((O/'inventory_before.json').read_text());profiles=list(dict.fromkeys(('specialist' if x['group']=='specialist' else 'mercer_sniper' if x['variant'].startswith('mercer_') else 'orlov_sniper' if x['variant'].startswith('faction_orlov_sniper_') else x['faction']) for x in rows))
for d in ['renders','candidates','review']:(O/d).mkdir(exist_ok=True)
def build(profile):
 p=subprocess.run([sys.executable,str(O/'worker.py'),profile],cwd=R,capture_output=True,text=True)
 if p.returncode:raise RuntimeError(p.stdout+p.stderr)
 job=O/'jobs'/(profile+'.json');data=json.loads(job.read_text())
 p=subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe','--headless','--path',str(R),'--script',str(O/'render.gd'),'--',str(job),str(O/'renders')],capture_output=True,text=True)
 if p.returncode:raise RuntimeError(p.stdout+p.stderr)
 palette=np.array(data['palette'],dtype=np.int32);pal=Image.new('P',(1,1));pal.putpalette((palette.astype('uint8').reshape(-1).tolist()+[0]*768)[:768])
 by_variant={x['variant']:x for x in data['rows']}
 for name,svg in data['jobs']:
  path=O/'renders'/(name+'.png');v=name.rsplit('_',2)[0];row=by_variant[v]
  if profile in ['mercer','orlov'] and row['group']=='arsenal':
   im=Image.open(path).convert('RGBA');alpha=im.getchannel('A').point(lambda x:255 if x>=128 else 0);rgb=im.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE).convert('RGBA');rgb.putalpha(alpha);rgb.save(path)
  else:finish_exact(path,palette)
 print('PROFILE_READY',profile,len(data['rows']),flush=True)
 return data
if '--reuse' in sys.argv:data=[json.loads((O/'jobs'/(p+'.json')).read_text()) for p in profiles]
else:
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:data=list(pool.map(build,profiles))
report=[]
def arr(im):
 a=np.array(im.convert('RGBA'));a[a[:,:,3]==0]=0;return a
for row in rows:
 v=row['variant'];source=Image.open(R/row['portrait']).convert('RGBA');crop=(18,12,108,92) if row['group'] in ['base','arsenal'] else (18,6,108,86)
 baseline=Image.open(O/'renders'/(v+'_SW_before.png')).convert('RGBA');candidate=Image.open(O/'renders'/(v+'_SW_after.png')).convert('RGBA')
 original_crop=(32,30,96,80) if row['group']=='base' else crop
 a=arr(baseline.crop(original_crop));b=arr(source)
 mismatch=int(np.any(a!=b,axis=2).sum())
 out=candidate.crop(crop);out.save(O/'candidates'/(v+'.png'))
 for direction in ['SE','SW']:
  Image.open(O/'renders'/(v+'_'+direction+'_after.png')).crop(crop).save(O/'review'/(v+'_'+direction+'.png'))
 report.append(dict(row,baseline_mismatch=mismatch,candidate_size=out.size))
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',13)
for faction in dict.fromkeys(x['faction'] for x in rows):
 subset=[x for x in rows if x['faction']==faction]
 for page in range((len(subset)+14)//15):
  shown=subset[page*15:page*15+15];board=Image.new('RGB',(1350,((len(shown)+4)//5)*250),'#29363a');d=ImageDraw.Draw(board)
  for i,row in enumerate(shown):
   x=i%5*270;y=i//5*250;d.text((x+5,y+5),faction+' / '+row['model'],font=font,fill='white')
   for j,direction in enumerate(['SW','SE']):
    im=Image.open(O/'review'/(row['variant']+'_'+direction+'.png')).convert('RGBA');im=im.resize((135,120),Image.Resampling.NEAREST);board.paste(im,(x+j*135,y+28),im)
   im=Image.open(O/'candidates'/(row['variant']+'.png')).convert('RGBA');board.paste(im,(x+90,y+162),im)
  board.save(O/'review'/(faction+'_'+str(page)+'.png'))
(O/'build_validation.json').write_text(json.dumps({'rows':report,'structural_checks':sum(len(x['checks']) for x in data),'baseline_mismatches':[(x['variant'],x['baseline_mismatch']) for x in report if x['baseline_mismatch']]},indent=2))
print('BUILD_READY',len(report),'MISMATCHES',[(x['variant'],x['baseline_mismatch']) for x in report if x['baseline_mismatch']],flush=True)
