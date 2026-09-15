from pathlib import Path
import json
O=Path(__file__).resolve().parent
s=json.loads((O/'publish_payload.json').read_text(encoding='utf-8'))['publish']
exec(compile(s,str(O/'publish.py'),'exec'))
