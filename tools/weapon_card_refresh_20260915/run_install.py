from pathlib import Path
import json
O=Path(__file__).resolve().parent
p=json.loads((O/'native_install_payload.json').read_text(encoding='utf-8'))
(O/'check_native.gd').write_text(p['check'],encoding='utf-8',newline='\n')
(O/'install.py').write_text(p['install'],encoding='utf-8',newline='\n')
exec(compile(p['install'],str(O/'install.py'),'exec'))
