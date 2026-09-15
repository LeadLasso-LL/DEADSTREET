import json,subprocess,sys
from pathlib import Path
out=Path(__file__).resolve().parent;root=out.parents[1]
target=root/'gameplay/sandbox_menu_music.gd'
old=json.loads((out/'payload.json').read_text(encoding='utf-8-sig'))['files']['gameplay/sandbox_menu_music.gd']
assert target.read_text(encoding='utf-8')==old,'Concurrent music edit'
new=json.loads((out/'music_final.json').read_text(encoding='utf-8-sig'))['source']
target.write_text(new,encoding='utf-8',newline='\n')
subprocess.run([sys.executable,str(out/'run_native.py')],check=True)
