from pathlib import Path
import json
O=Path(__file__).resolve().parent
s=json.loads((O/'finish_payload.json').read_text(encoding='utf-8'))['finish']
exec(compile(s,str(O/'finish.py'),'exec'))
