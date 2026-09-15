from pathlib import Path
import json,subprocess,hashlib
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'native_payload.json').read_text(encoding='utf-8'))
(out/'check_native.gd').write_text(p['gd'],encoding='utf-8',newline='\n')
before=json.loads((out/'before_music_catalog.json').read_text(encoding='utf-8'));after=json.loads((root/'assets/data/music_catalog.json').read_text(encoding='utf-8'))
assert before['tracks']==after['tracks'] and before['signature_track']==after['signature_track']
for p,h in json.loads((out/'protected_hashes.json').read_text()).items():assert hashlib.sha256((root/p).read_bytes()).hexdigest()==h
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (out/'native.log').open('w',encoding='utf-8') as log:
    result=subprocess.run([godot,'--path',str(root),'--script','res://tools/faction_music_apply_20260915/check_native.gd'],stdout=log,stderr=subprocess.STDOUT,timeout=90)
print('RETURN',result.returncode,flush=True)
print((out/'native.log').read_text(encoding='utf-8')[-2200:],flush=True)
if result.returncode==0:
    paths=['assets/data/music_catalog.json','gameplay/tactical_convoy_audio.gd','gameplay/tactical_battle_audio.gd']
    (out/'source_hashes.json').write_text(json.dumps({p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf-8')
