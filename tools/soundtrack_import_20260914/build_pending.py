import json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parent
p=json.loads((root/'asset_payload.json').read_text(encoding='utf-8-sig'))
(root/'build_assets.py').write_text(p['script'],encoding='utf-8')
subprocess.run([sys.executable,str(root/'build_assets.py')],check=True)
