from pathlib import Path
import json,subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_revision_20260915'
for name,content in json.loads((o/'ravicci_bundle.json').read_text()).items():
 assert name.startswith('tools/yard_revision_20260915/ravicci/');p=r/name;assert not p.exists(),name
 p.parent.mkdir(parents=True,exist_ok=True);p.write_text(content,encoding='utf-8',newline='\n')
subprocess.run([sys.executable,str(o/'ravicci/run_all.py')],check=True)
