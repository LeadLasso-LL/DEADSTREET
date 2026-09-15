from pathlib import Path
import json,subprocess,sys
out=Path(__file__).resolve().parent
p=json.loads((out/'scripts.json').read_text(encoding='utf-8-sig'))
for name,source in p.items():
    target=out/name
    assert not target.exists() or target.read_text(encoding='utf-8')==source,'Preserve existing task script'
    target.write_text(source,encoding='utf-8',newline='\n')
with (out/'fetch.log').open('w',encoding='utf-8') as f:r=subprocess.run(['node',str(out/'fetch_batch.mjs')],stdout=f,stderr=subprocess.STDOUT)
print('FETCH_RETURN',r.returncode,flush=True)
if r.returncode:raise SystemExit(r.returncode)
with (out/'build.log').open('w',encoding='utf-8') as f:r=subprocess.run([sys.executable,str(out/'build_batch.py')],stdout=f,stderr=subprocess.STDOUT)
print('BUILD_RETURN',r.returncode,flush=True)
raise SystemExit(r.returncode)
