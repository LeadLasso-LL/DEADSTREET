from pathlib import Path
import json,shutil,subprocess,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/caution_impacts_20260915';a=r/'assets/menu/opening'
assert hashlib.sha256((r/'gameplay/sandbox_opening.gd').read_bytes()).hexdigest()=='ad343c57220d54ff281e95c3ad976c853b12e3719c72dfe6421f96724f503289'
(r/'gameplay/sandbox_caution.gd').write_text(json.loads((o/'native_revision.json').read_text())['code'],encoding='utf-8',newline='\n')
for name in ['credit_gloria.png','credit_godot.png']:shutil.copy2(r/'tools/menu_title_20260914'/name,a/name)
source=(r/'gameplay/sandbox_opening.gd').read_text(encoding='utf-8')
part=(o/'prepare.py').read_text().split('source=(r/')[1]
code='source=(r/'+part
code=code.replace("shutil.copy2(candidate,a/'startup.ogv');",'')
code=code.split("report={")[0]
exec(code,{'r':r,'a':a,'source':source})
report={'status':'INSTALLED_NATIVE_OVERLAY','startup_unchanged':hashlib.sha256((a/'startup.ogv').read_bytes()).hexdigest()==hashlib.sha256((o/'before/startup.ogv').read_bytes()).hexdigest(),'credits':[2.5,3.0],'sign':[5.5,11.5],'hits':[7.2,7.533333,7.933333,8.233333,8.566667],'title':21,'button':27}
(o/'installation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
with (o/'capture_worker.log').open('wb') as log:
 p=subprocess.Popen([r'C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe',str(o/'capture.py')],cwd=r,stdout=log,stderr=subprocess.STDOUT);print('CAPTURE_WORKER_PID',p.pid)