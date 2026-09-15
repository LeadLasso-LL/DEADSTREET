import json,subprocess,sys
from pathlib import Path
out=Path(__file__).resolve().parent
p=json.loads((out/'record_payload.json').read_text(encoding='utf-8-sig'))
(out/'record_publish.py').write_text(p['publisher'],encoding='utf-8')
subprocess.run([sys.executable,str(out/'record_publish.py')],check=True)
