from pathlib import Path
import json,subprocess,tempfile,shutil,hashlib
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
G=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
result=subprocess.run([G,'--headless','--path',str(R),'--script','res://tools/arsenal_production/render_icons.gd'],capture_output=True,text=True)
(O/'render_icons.log').write_text(result.stdout+result.stderr,encoding='utf-8');assert result.returncode==0,result.stdout+result.stderr
assert 'ICONS_COMPLETE 30' in result.stdout;print('ICONS_RENDERED',flush=True)
models=json.loads((R/'assets/data/weapon_models.json').read_text(encoding='utf-8'))['models']
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',18)
for kind in ['pistol','smg','shotgun','rifle','sniper']:
    rows=[m for m in models.values() if m['weapon_class']==kind]
    board=Image.new('RGB',(1200,720),'#29363a');draw=ImageDraw.Draw(board)
    for i,m in enumerate(rows):
        x=i%2*600;y=i//2*240;draw.text((x+18,y+14),m['name']+' / $'+format(m['price'],','),font=font,fill='#dedfd1')
        im=Image.open(R/'assets/art/weapons/arsenal/icons'/(m['id']+'.png')).convert('RGBA');im.thumbnail((550,174),Image.Resampling.LANCZOS)
        board.paste(im,(x+(600-im.width)//2,y+52+(174-im.height)//2),im)
    board.save(O/'review'/('weapons_'+kind+'.png'))
rows=json.loads((R/'tools/portrait_audit_20260914/build_validation.json').read_text(encoding='utf-8'))['rows']
paths=[x['portrait'] for x in rows]+['assets/art/weapons/arsenal/icons/'+x+'.png' for x in models]
paths+=[x['path'] for x in json.loads((O/'leader_manifest.json').read_text(encoding='utf-8'))['leaders']]
with tempfile.TemporaryDirectory(prefix='dead_street_finish_imports_') as work:
    w=Path(work);(w/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Dead Street asset refresh"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',encoding='utf-8')
    for rel in paths:
        dest=w/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(R/rel,dest)
        if (R/(rel+'.import')).exists():shutil.copy2(R/(rel+'.import'),w/(rel+'.import'))
    run=subprocess.run([G,'--headless','--editor','--import','--path',str(w)],capture_output=True,text=True)
    (O/'import.log').write_text(run.stdout+run.stderr,encoding='utf-8');assert run.returncode==0,run.stdout+run.stderr
    files=list((w/'.godot/imported').glob('*'));textures=[x for x in files if x.suffix=='.ctex'];assert len(textures)==len(paths),(len(textures),len(paths))
    for p in files:shutil.copy2(p,R/'.godot/imported'/p.name)
    new_imports=[]
    for rel in paths:
        if not (R/(rel+'.import')).exists():shutil.copy2(w/(rel+'.import'),R/(rel+'.import'));new_imports.append(rel+'.import')
receipt=json.loads((O/'installed.json').read_text(encoding='utf-8'))
receipt['asset_paths']=paths;receipt['new_imports']=new_imports
receipt['after']={p:hashlib.sha256((R/p).read_bytes()).hexdigest() for p in receipt['changed']}
receipt['asset_hashes']={p:hashlib.sha256((R/p).read_bytes()).hexdigest() for p in paths}
(O/'installed.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
print('IMPORTED',len(paths),'TEXTURES',len(textures),flush=True)
