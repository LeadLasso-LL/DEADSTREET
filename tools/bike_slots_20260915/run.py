from pathlib import Path
import json,subprocess,sys
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
for name,s in json.loads((out/'tests.json').read_text(encoding='utf-8')).items():(out/name).write_text(s,encoding='utf-8')
mode=sys.argv[1] if len(sys.argv)>1 else 'check'
cmd=[r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--path',str(r),'--script','res://tools/bike_slots_20260915/'+mode+'.gd']
with (out/(mode+'.log')).open('w') as log:
 p=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT);print('OWNED_GODOT',p.pid,flush=True)
 try:code=p.wait(timeout=300)
 except subprocess.TimeoutExpired:p.kill();code=124
print((out/(mode+'.log')).read_text(errors='replace')[-15000:],flush=True)
sys.exit(code)
