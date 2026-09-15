from pathlib import Path
import json,subprocess,sys,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_revision_20260915'
data=json.loads((o/'install_bundle.json').read_text());base=json.loads((o/'baseline.json').read_text());original=json.loads((o/'sources.json').read_text())
# Read-only verification proved these hashes and original byte backups still match.
# Preserve the original baseline; reject any true change before writing anything.
for name,transferred in data['expected'].items():
 current=(r/name).read_bytes();expected=base['sources'][str(Path(name))]
 assert hashlib.sha256(current).hexdigest()==expected,'Live file changed: '+name
 assert current==(o/'before'/name).read_bytes(),'Original backup mismatch: '+name
 assert transferred==original[name]+'\n','Unexpected transfer difference: '+name
 assert (r/name).read_text(encoding='utf-8')==original[name],'Original source mismatch: '+name
for name,content in data['writes'].items():
 assert name in data['expected'] or name.startswith('tools/yard_revision_20260915/'),name
 p=r/name;p.parent.mkdir(exist_ok=True,parents=True);p.write_text(content,encoding='utf-8',newline='\n')
print('INSTALLED_WITH_ORIGINAL_BYTE_HASH_GUARDS',len(data['writes']),flush=True)
subprocess.run([sys.executable,str(o/'run_native.py'),'bake'],check=True)
subprocess.run([sys.executable,str(o/'run_native.py'),'review'],check=True)
