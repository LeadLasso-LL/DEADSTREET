from pathlib import Path
import subprocess,sys
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
mode=sys.argv[1] if len(sys.argv)>1 else 'check'
args=[r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe','--path',str(r),'--script','res://tools/sandbox_maps_20260915/'+mode+'.gd']
if mode=='check':args.insert(1,'--headless')
with (out/(mode+'.log')).open('w') as log:
 child=subprocess.Popen(args,stdout=log,stderr=subprocess.STDOUT)
 print('OWNED_GODOT',child.pid,flush=True)
 try:code=child.wait(timeout=300)
 except subprocess.TimeoutExpired:child.kill();code=124
print((out/(mode+'.log')).read_text(errors='replace')[-18000:],flush=True)
sys.exit(code)
