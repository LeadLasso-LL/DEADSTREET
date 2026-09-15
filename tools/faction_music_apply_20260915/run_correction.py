from pathlib import Path
import json
out=Path(__file__).resolve().parent
payload=json.loads((out/'correction_payload.json').read_text(encoding='utf-8'))
(out/'apply_correction.py').write_text(payload['apply'],encoding='utf-8',newline='\n')
exec(compile(payload['apply'],str(out/'apply_correction.py'),'exec'))
