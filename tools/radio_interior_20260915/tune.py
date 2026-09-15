from pathlib import Path
import json,subprocess
out=Path(__file__).resolve().parent;root=out.parents[1]
for name in ['native_validation.json','measured_response.json']:
 (out/('initial_'+name)).write_bytes((out/name).read_bytes())
f=root/'gameplay/tactical_radio_filter.gd'
s=f.read_text(encoding='utf-8');assert s.count('FILTER_12DB')==1
f.write_text(s.replace('FILTER_12DB','FILTER_6DB'),encoding='utf-8',newline='\n')
a=out/'analyze.py';s=a.read_text(encoding='utf-8').replace('12 dB/oct','6 dB/oct').replace('radio-interior-02','radio-interior-03').replace('Interior treatment validated','Final gentler interior treatment validated')
a.write_text(s,encoding='utf-8',newline='\n')
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (out/'native.log').open('w',encoding='utf-8') as f:
 r=subprocess.run([godot,'--rendering-method','gl_compatibility','--resolution','160x120','--position','0,0','--path',str(root),'--script','res://tools/radio_interior_20260915/check_native.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=60)
assert r.returncode==0,(out/'native.log').read_text(encoding='utf-8')
exec(compile(a.read_text(encoding='utf-8'),str(a),'exec'))
