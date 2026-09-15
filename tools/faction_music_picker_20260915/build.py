from pathlib import Path
import json,subprocess
out=Path(__file__).resolve().parent;root=out.parents[1]
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).strip()
p=json.loads((out/'payload.json').read_text(encoding='utf-8'))
(out/'picker.gd').write_text(p['gd'],encoding='utf-8',newline='\n')
godot=Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe')
with (out/'check.log').open('w',encoding='utf-8') as f:
    result=subprocess.run([str(godot),'--path',str(root),'--script','res://tools/faction_music_picker_20260915/picker.gd','--','--assignment-check'],stdout=f,stderr=subprocess.STDOUT,timeout=45)
print('PICKER_RETURN',result.returncode,flush=True)
print((out/'check.log').read_text(encoding='utf-8')[-2500:],flush=True)
