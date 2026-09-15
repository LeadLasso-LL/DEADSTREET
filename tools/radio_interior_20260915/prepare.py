from pathlib import Path
import json
out=Path(__file__).resolve().parent
p=json.loads((out/'finish_payload.json').read_text(encoding='utf-8'))
(out/'publish.py').write_text(p['publish'],encoding='utf-8',newline='\n')
exec(compile(p['prep'],str(out/'prepare.py'),'exec'))
