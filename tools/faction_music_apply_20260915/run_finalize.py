from pathlib import Path
import json
out=Path(__file__).resolve().parent
p=json.loads((out/'publication_payload.json').read_text(encoding='utf-8'))
(out/'finalize.py').write_text(p['finalize'],encoding='utf-8',newline='\n')
exec(compile(p['finalize'],str(out/'finalize.py'),'exec'))
