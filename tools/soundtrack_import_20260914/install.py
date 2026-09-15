from pathlib import Path
import json,subprocess
root=Path(__file__).resolve().parents[2]
out=root/'tools/soundtrack_import_20260914'
p=json.loads((out/'payload.json').read_text(encoding='utf-8-sig'))
source=root/'gameplay/sandbox_menu_music.gd'
before=source.read_text(encoding='utf-8')
assert before.rstrip('\n')==p['baseline'].rstrip('\n'), 'Concurrent Music source edit'
(out/'music.before.gd').write_bytes(source.read_bytes())
for name,data in p['files'].items():
    target=root/name
    assert not target.exists() or name=='gameplay/sandbox_menu_music.gd', 'Preserve existing '+name
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(data,encoding='utf-8',newline='\n')
subprocess.run([__import__('sys').executable,str(out/'build_assets.py')],check=True)
print('INSTALLED',flush=True)
