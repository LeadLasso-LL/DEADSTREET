from pathlib import Path
import subprocess,json,hashlib
r=Path(__file__).resolve().parents[2]
def git(*args): return subprocess.check_output(['git','-C',str(r),*args],text=True).strip()
owned=['gameplay/tactical_battle_view.gd','gameplay/tactical_selection_range.gd','gameplay/tactical_selection_range.gdshader']
print(json.dumps({'head':git('rev-parse','HEAD'),'branch':git('branch','--show-current'),'origin':git('remote','get-url','origin'),'index':git('diff','--cached','--name-only'),'source_hashes':{p:hashlib.sha256((r/p).read_bytes()).hexdigest() for p in owned},'owned_files':[p.name for p in Path(__file__).parent.iterdir()]},indent=2))
print(git('diff','--','gameplay/tactical_battle_view.gd'))
