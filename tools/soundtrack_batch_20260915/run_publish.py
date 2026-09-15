from pathlib import Path
import json,subprocess,sys
out=Path(__file__).resolve().parent
p=json.loads((out/'publish.json').read_text(encoding='utf-8-sig'))
(out/'publish.py').write_text(p['script'],encoding='utf-8',newline='\n')
subprocess.run([sys.executable,str(out/'publish.py')],check=True)
