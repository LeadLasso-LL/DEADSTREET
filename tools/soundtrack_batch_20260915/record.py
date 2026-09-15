from pathlib import Path
import json,hashlib,re
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'records.json').read_text(encoding='utf-8-sig'))
native=json.loads((out/'native_validation.json').read_text(encoding='utf-8'));assert not native['failures'] and len(native['checks'])==93
assert not re.search(r'(SCRIPT ERROR|Parse Error|ERROR:)',(out/'process.log').read_text(encoding='utf-8'))
audio=json.loads((out/'audio_validation.json').read_text(encoding='utf-8'));assert audio['count']==17 and not audio['failures']
for path,digest in json.loads((out/'source_hashes.json').read_text(encoding='utf-8')).items():assert hashlib.sha256((root/path).read_bytes()).hexdigest()==digest,'Concurrent source change'
(out/'README.md').write_text(p['readme'],encoding='utf-8',newline='\n')
for path,entry in p['entries'].items():
    target=root/path
    assert entry.splitlines()[0] not in target.read_text(encoding='utf-8')
    with target.open('a',encoding='utf-8') as f:f.write('\n\n'+entry)
    assert entry in target.read_text(encoding='utf-8')
print('ALL17_BATCH_RECORDS_SAVED_VERIFIED',flush=True)
