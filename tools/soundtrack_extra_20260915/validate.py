from pathlib import Path
import json,hashlib,subprocess
out=Path(__file__).resolve().parent;root=out.parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for p,h in json.loads((out/'protected_before.json').read_text()).items():assert sha(root/p)==h
before=json.loads((out/'catalog.before.json').read_text(encoding='utf-8'));after=json.loads((root/'assets/data/music_catalog.json').read_text(encoding='utf-8'))
new={t['id']:t for t in after['tracks']}
assert all(new[t['id']]==t for t in before['tracks'])
assert before['faction_tracks']==after['faction_tracks'] and len(new)==22
checks={'existing_19_entries_unchanged':True,'faction_mapping_unchanged':True,'music_consumers_unchanged':True,'unique_22_tracks':True}
(out/'integrity_validation.json').write_text(json.dumps(checks,indent=2)+'\n',encoding='utf-8')
payload=json.loads((out/'native_payload.json').read_text(encoding='utf-8'))
(out/'check_native.gd').write_text(payload['gd'],encoding='utf-8',newline='\n')
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (out/'native_process.log').open('w',encoding='utf-8') as f:
    p=subprocess.run([godot,'--path',str(root),'--script','res://tools/soundtrack_extra_20260915/check_native.gd','--log-file',str(out/'native_godot.log')],stdout=f,stderr=subprocess.STDOUT,timeout=60)
print('NATIVE_RETURN',p.returncode,flush=True)
if (out/'native_validation.json').exists():
    data=json.loads((out/'native_validation.json').read_text());print('CHECKS',len(data['checks']),'FAILURES',data['failures'],flush=True)
assert p.returncode==0
hashes=json.loads((out/'protected_before.json').read_text())
hashes['assets/data/music_catalog.json']=sha(root/'assets/data/music_catalog.json')
(out/'source_hashes.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
print('INTEGRITY_PASSED',flush=True)
