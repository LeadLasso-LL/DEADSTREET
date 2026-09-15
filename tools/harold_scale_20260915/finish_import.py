from pathlib import Path
import subprocess,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1]
engine=str(r.parent/'Godot/Godot_v4.7.2-stable_win64.exe')
args=['--headless','--editor','--import']
with (out/'import_resume.log').open('w',encoding='utf-8') as log:
 p=subprocess.Popen([engine,'--path',str(r),*args,'--log-file',str(out/'import_engine.log')],stdout=log,stderr=subprocess.STDOUT)
 print('IMPORT_PID',p.pid,flush=True);code=p.wait(timeout=600)
print('IMPORT_EXIT',code,flush=True)
with (out/'after.log').open('w',encoding='utf-8') as log:
 p=subprocess.Popen([engine,'--path',str(r),'--script','res://tools/harold_scale_20260915/check.gd','--position','20,30','--log-file',str(out/'after_engine.log')],stdout=log,stderr=subprocess.STDOUT)
 print('AFTER_PID',p.pid,flush=True);code=p.wait(timeout=150)
print('AFTER_EXIT',code,flush=True)
print((out/'after_engine.log').read_text(encoding='utf-8')[-5000:])
