import json,subprocess
from pathlib import Path
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'test_payload.json').read_text(encoding='utf-8-sig'))
(out/'check_native.gd').write_text(p['script'],encoding='utf-8')
exe=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
r=subprocess.run([exe,'--path',str(root),'--script','res://tools/soundtrack_import_20260914/check_native.gd','--log-file',str(out/'native.log')],capture_output=True,timeout=70)
(out/'process.log').write_bytes(r.stdout+r.stderr)
print('RETURN',r.returncode,flush=True)
print((r.stdout+r.stderr).decode('utf-8',errors='replace')[-7000:],flush=True)
