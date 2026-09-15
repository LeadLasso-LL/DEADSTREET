from pathlib import Path
import json,shutil,tempfile,subprocess,hashlib
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
ids=['ak47','rem700','sks','svd','ssg69','awm','psg1']
G=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
log_bytes=(O/'render_icons.log').read_bytes();log=log_bytes.decode('utf-16' if log_bytes.startswith(b'\xff\xfe') else 'utf-8-sig',errors='replace');assert 'ICONS_COMPLETE 30' in log
paths=['assets/art/weapons/arsenal/icons/'+id+'.png' for id in ids]
with tempfile.TemporaryDirectory(prefix='dead_street_precision_import_') as work:
 w=Path(work);(w/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Dead Street precision icons"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
 for rel in paths:
  p=w/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,p)
  if (R/(rel+'.import')).exists():shutil.copy2(R/(rel+'.import'),w/(rel+'.import'))
 result=subprocess.run([G,'--headless','--editor','--import','--path',str(w)],capture_output=True,text=True)
 (O/'import.log').write_text(result.stdout+result.stderr,encoding='utf-8');assert result.returncode==0
 textures=list((w/'.godot/imported').glob('*.ctex'));assert len(textures)==7
 for p in (w/'.godot/imported').glob('*'):shutil.copy2(p,R/'.godot/imported'/p.name)
models=json.loads((R/'assets/data/weapon_models.json').read_text())['models']
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',19)
board=Image.new('RGB',(1280,900),'#233238');draw=ImageDraw.Draw(board)
for i,id in enumerate(ids):
 x=(i%2)*640;y=(i//2)*225
 draw.text((x+16,y+12),models[id]['name'],font=font,fill='#e0e2d8')
 im=Image.open(R/paths[i]).convert('RGBA');im.thumbnail((610,160),Image.Resampling.LANCZOS);board.paste(im,(x+(640-im.width)//2,y+47+(160-im.height)//2),im)
board.save(O/'precision_guns.png')
# No accidental changes outside the requested seven icon outputs.
prior=json.loads((R/'tools/sandbox_finish_20260915/installed.json').read_text())['asset_hashes']
for rel,expected in prior.items():
 if rel in paths:continue
 assert hashlib.sha256((R/rel).read_bytes()).hexdigest()==expected,('Unrelated portrait/photo/icon changed',rel)
(O/'asset_validation.json').write_text(json.dumps({'imported_icons':7,'other_734_prior_assets_unchanged':True,'hashes':{p:hashlib.sha256((R/p).read_bytes()).hexdigest() for p in paths}},indent=2))
print('SEVEN ICONS IMPORTED; OTHER 734 ASSETS UNCHANGED; BOARD READY',flush=True)
