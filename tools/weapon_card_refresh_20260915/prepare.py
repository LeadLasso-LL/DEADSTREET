from pathlib import Path
import json
O=Path(__file__).resolve().parent
p=json.loads((O/'payload.json').read_text(encoding='utf-8'))
exec(compile(p['prepare'],str(O/'prepare.py'),'exec'))
