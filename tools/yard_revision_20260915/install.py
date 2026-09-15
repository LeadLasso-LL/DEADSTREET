from pathlib import Path
import json,subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_revision_20260915';data=json.loads((o/'install_bundle.json').read_text())
for name,expected in data['expected'].items():assert (r/name).read_text(encoding='utf-8')==expected,'Concurrent change: '+name
for name,content in data['writes'].items():
 p=r/name;p.parent.mkdir(exist_ok=True,parents=True);p.write_text(content,encoding='utf-8',newline='\n')
print('INSTALLED',len(data['writes']),flush=True)
subprocess.run([sys.executable,str(o/'run_native.py'),'bake'],check=True)
subprocess.run([sys.executable,str(o/'run_native.py'),'review'],check=True)
