from pathlib import Path
import zlib,base64,subprocess,json
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=Path(__file__).resolve().parent
engine=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
for label,path in [('groups','res://tools/selected_range_groups_20260915/check_groups.gd'),('individual','res://tools/selected_range_20260915/check_native.gd')]:
    print('Starting '+label+' native checks',flush=True)
    log=o/(label+'.log')
    with log.open('w',encoding='utf-8') as f: result=subprocess.run([engine,'--path',str(r),'--script',path,'--position','20,30'],cwd=r,stdout=f,stderr=subprocess.STDOUT,timeout=180)
    text=log.read_text(encoding='utf-8'); errors=[s for s in text.splitlines() if 'SCRIPT ERROR' in s or 'ERROR:' in s or 'RANGE_FAIL' in s]
    print(json.dumps({'suite':label,'exit':result.returncode,'errors':errors[:12]}),flush=True)
    print(text[-1000:],flush=True)
    if result.returncode or errors: raise SystemExit(1)
