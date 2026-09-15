from pathlib import Path
import json
out=Path(__file__).resolve().parent
p=json.loads((out/'payload.json').read_text(encoding='utf-8'))
(out/'install.py').write_text(p['install'],encoding='utf-8',newline='\n')
exec(compile(p['install'],str(out/'install.py'),'exec'))
