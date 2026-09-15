from pathlib import Path
import subprocess,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1]
engine=str(r.parent/'Godot/Godot_v4.7.2-stable_win64_console.exe')
for label,args in [('bake_final',['--script','res://tools/dusk_review/bake_harold_frontage.gd','--','--ground-only']),('import_final',['--headless','--editor','--import']),('after',['--script','res://tools/harold_scale_20260915/check.gd','--position','20,30'])]:
 with (out/(label+'.log')).open('w',encoding='utf-8') as log:
  result=subprocess.run([engine,'--path',str(r),*args],stdout=log,stderr=subprocess.STDOUT,timeout=150)
 text=(out/(label+'.log')).read_text(encoding='utf-8')
 print(label,result.returncode,text[-4500:],flush=True)
 if result.returncode!=0 or 'SCRIPT ERROR' in text:sys.exit(1)