import json,subprocess,sys
from pathlib import Path
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'final_payload.json').read_text(encoding='utf-8-sig'))
source=root/'gameplay/sandbox_menu_music.gd'
old=json.loads((out/'music_final.json').read_text(encoding='utf-8-sig'))['source']
assert source.read_text(encoding='utf-8')==old,'Concurrent music edit'
source.write_text(p['sandbox_menu_music.gd'],encoding='utf-8',newline='\n')
(out/'build_assets.py').write_text(p['build_assets.py'],encoding='utf-8')
(out/'test_payload.json').write_text(json.dumps({'script':p['check_native.gd']}),encoding='utf-8')
subprocess.run([sys.executable,str(out/'run_native.py')],check=True)
report=json.loads((out/'native_validation.json').read_text(encoding='utf-8'));assert not report['failures'],report['failures']
print('FINAL_VALIDATED',len(report['observations']),flush=True)
