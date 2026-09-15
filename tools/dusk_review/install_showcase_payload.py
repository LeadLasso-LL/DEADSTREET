from pathlib import Path
import json,zlib,base64
root=Path(__file__).resolve().parents[2]
files=json.loads((root/'tools/dusk_review/showcase_payload.json').read_text(encoding='utf-8'))
for name,data in files.items():
 path=root/name
 assert path.resolve().is_relative_to(root.resolve())
 path.parent.mkdir(parents=True,exist_ok=True)
 path.write_bytes(zlib.decompress(base64.b64decode(data)))
 print('INSTALLED',name)
