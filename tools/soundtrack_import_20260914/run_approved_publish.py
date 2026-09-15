from pathlib import Path
import json,subprocess,sys
out=Path(__file__).resolve().parent
p=json.loads((out/'approved_publish.json').read_text(encoding='utf-8-sig'))
(out/'approved_publish.py').write_text(p['script'],encoding='utf-8')
subprocess.run([sys.executable,str(out/'approved_publish.py')],check=True)
