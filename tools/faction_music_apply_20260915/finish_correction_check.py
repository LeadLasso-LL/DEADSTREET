from pathlib import Path
import json,subprocess,hashlib,difflib
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'correction_payload.json').read_text(encoding='utf-8'))
p['gd']=p['gd'].replace('listener.global_position=p.global_position;p.play(29.85)\n\t\tawait create_timer(.38).timeout','listener.global_position=p.global_position\n\t\tawait physics_frame;await physics_frame\n\t\tp.play();await create_timer(.2).timeout\n\t\tp.play(29.85);await create_timer(.6).timeout\n\t\tprint(side," position=",p.get_playback_position()," playing=",p.playing)')
(out/'correction_payload.json').write_text(json.dumps(p),encoding='utf-8')
(out/'check_correction.gd').write_text(p['gd'],encoding='utf-8',newline='\n')
(out/'correction_initial_validation.json').write_bytes((out/'correction_validation.json').read_bytes())
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (out/'correction.log').open('w',encoding='utf-8') as f:r=subprocess.run([godot,'--path',str(root),'--script','res://tools/faction_music_apply_20260915/check_correction.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=25)
print((out/'correction.log').read_text(encoding='utf-8')[-800:],flush=True);assert r.returncode==0
hashes=json.loads((out/'source_hashes.json').read_text())
for name,h in hashes.items():
    if name!='assets/data/music_catalog.json':assert hashlib.sha256((root/name).read_bytes()).hexdigest()==h
hashes['assets/data/music_catalog.json']=hashlib.sha256((root/'assets/data/music_catalog.json').read_bytes()).hexdigest()
(out/'source_hashes.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
diff=''
for name in hashes:diff+=''.join(difflib.unified_diff((out/('before_'+Path(name).name)).read_text(encoding='utf-8').splitlines(True),(root/name).read_text(encoding='utf-8').splitlines(True),fromfile='a/'+name,tofile='b/'+name))
(out/'runtime.patch').write_text(diff,encoding='utf-8')
