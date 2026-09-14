"""Refresh only the twelve edited legacy portrait imports in an isolated project."""
from pathlib import Path
import tempfile,subprocess,json,shutil
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
rows=[r for r in json.loads((O/'inventory.json').read_text()) if r['group'] in ['base','arsenal']]
with tempfile.TemporaryDirectory(prefix='dead_street_portraits_') as work:
 w=Path(work);(w/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Portrait imports"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
 for row in rows:
  target=w/row['portrait'];target.parent.mkdir(parents=True,exist_ok=True)
  shutil.copy2(R/row['portrait'],target)
  imported=R/(row['portrait']+'.import')
  assert imported.exists(),str(imported)
  shutil.copy2(imported,str(target)+'.import')
 p=subprocess.run([godot,'--headless','--editor','--import','--path',str(w)],capture_output=True,text=True)
 (O/'refresh_imports.log').write_text(p.stdout+p.stderr,encoding='utf-8')
 assert p.returncode==0,p.stdout+p.stderr
 files=list((w/'.godot/imported').glob('*'))
 assert len([p for p in files if p.suffix=='.ctex'])==12,len(files)
 for source in files:shutil.copy2(source,R/'.godot/imported'/source.name)
print('REFRESHED_LEGACY_IMPORTS',len(rows),flush=True)
p=subprocess.run([godot,'--headless','--path',str(R),'--script',str(O/'native_card_checks.gd')],capture_output=True,text=True)
(O/'native_card_checks.log').write_text(p.stdout+p.stderr,encoding='utf-8')
print(p.stdout+p.stderr)
raise SystemExit(p.returncode)
