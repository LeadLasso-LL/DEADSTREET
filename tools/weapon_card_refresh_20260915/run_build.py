from pathlib import Path
import json
O=Path(__file__).resolve().parent
s=json.loads((O/'build_payload.json').read_text(encoding='utf-8'))['build']
(O/'build_cards.py').write_text(s,encoding='utf-8',newline='\n')
exec(compile(s,str(O/'build_cards.py'),'exec'))
