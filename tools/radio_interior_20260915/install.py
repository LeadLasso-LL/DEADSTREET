from pathlib import Path
import json,hashlib,subprocess,difflib,wave
import numpy as np
out=Path(__file__).resolve().parent;root=out.parents[1]
payload=json.loads((out/'payload.json').read_text(encoding='utf-8'))
target=root/'gameplay/tactical_convoy_audio.gd';before=target.read_text(encoding='utf-8')
assert not (root/'gameplay/tactical_radio_filter.gd').exists()
assert not subprocess.check_output(['git','diff','--name-only','--','gameplay/tactical_convoy_audio.gd'],cwd=root,text=True).strip()
(out/'before_tactical_convoy_audio.gd').write_text(before,encoding='utf-8',newline='\n')
protected=['assets/data/music_catalog.json','gameplay/music_catalog.gd','gameplay/tactical_battle_audio.gd']
(out/'protected_hashes.json').write_text(json.dumps({p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in protected},indent=2),encoding='utf-8')
after=before.replace('const Music=', 'const RadioFilter=preload("res://gameplay/tactical_radio_filter.gd")\nconst Music=',1)
needle=' player.set_meta("faction_id",identity);player.set_meta("track_id",track_id)\n'
assert after.count(needle)==1
after=after.replace(needle,needle+' RadioFilter.attach(player,building)\n',1)
needle='  var foreground=clampf(victory_mix,0.,1.) if owns_victory else 0.\n'
assert after.count(needle)==1
after=after.replace(needle,needle+'  RadioFilter.update(player,foreground)\n',1)
assert target.read_text(encoding='utf-8')==before
(root/'gameplay/tactical_radio_filter.gd').write_text(payload['helper'],encoding='utf-8',newline='\n')
target.write_text(after,encoding='utf-8',newline='\n')
(out/'runtime.patch').write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/gameplay/tactical_convoy_audio.gd',tofile='b/gameplay/tactical_convoy_audio.gd')),encoding='utf-8')
rate=48000;t=np.arange(rate)/rate
signal=sum(.07*np.sin(2*np.pi*f*t) for f in [120,1000,4000,8000]);pcm=np.rint(signal*32767).astype('<i2')
with wave.open(str(out/'filter_probe.wav'),'wb') as f:f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(pcm.tobytes())
(out/'check_native.gd').write_text(payload['test'],encoding='utf-8',newline='\n')
entry='\n\n## 20260915-radio-interior-01 - Subtle interior filtering implemented\n\nOwner authorized restrained, well-done vehicle/building muffling. Implemented per-source12dB/oct low-pass: vehicles2400Hz, buildings1800Hz, resonance0.5/no gain boost; winner smoothly opens to7500Hz using existing outro mix without replacing/restarting its loop. Each radio owns a separate temporary bus and cleans it up on exit. Sirens/menu sources never attach this treatment. Existing spatial anchors, gain/ducking, timing and assets unchanged. Scope: new gameplay/tactical_radio_filter.gd plus three narrow convoy-audio wiring lines; evidence in tools/radio_interior_20260915/. Next: native signal-response, source isolation, cleanup, transitions and siren checks; record final results and publish scoped change. Preserve concurrent Harold/Arsenal/menu/range work.\n'
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md']:
 with (root/'docs'/name).open('a',encoding='utf-8') as f:f.write(entry)
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (out/'native.log').open('w',encoding='utf-8') as f:r=subprocess.run([godot,'--rendering-method','gl_compatibility','--resolution','160x120','--position','0,0','--path',str(root),'--script','res://tools/radio_interior_20260915/check_native.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=60)
print('NATIVE_RETURN',r.returncode,flush=True)
print((out/'native.log').read_text(encoding='utf-8')[-1600:],flush=True)
