from pathlib import Path
import json,subprocess,hashlib
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'test.json').read_text(encoding='utf-8-sig'));(out/'check_native.gd').write_text(p['script'],encoding='utf-8',newline='\n')
paths=['gameplay/sandbox_menu_music.gd','gameplay/music_catalog.gd','gameplay/sandbox_opening.gd','assets/data/music_catalog.json']
(out/'source_hashes.json').write_text(json.dumps({p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf-8')
exe=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
r=subprocess.run([exe,'--path',str(root),'--script','res://tools/soundtrack_batch_20260915/check_native.gd','--log-file',str(out/'native.log')],capture_output=True,timeout=60)
(out/'process.log').write_bytes(r.stdout+r.stderr)
print('NATIVE_RETURN',r.returncode,flush=True)
print((r.stdout+r.stderr).decode('utf-8',errors='replace')[-6000:],flush=True)
