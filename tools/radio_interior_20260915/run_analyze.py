from pathlib import Path
import json
out=Path(__file__).resolve().parent
s=json.loads((out/'analyze_payload.json').read_text(encoding='utf-8'))['code']
(out/'analyze.py').write_text(s,encoding='utf-8',newline='\n')
exec(compile(s,str(out/'analyze.py'),'exec'))
