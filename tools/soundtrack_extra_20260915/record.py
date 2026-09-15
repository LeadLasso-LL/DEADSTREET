from pathlib import Path
import json
out=Path(__file__).resolve().parent;root=out.parents[1]
p=json.loads((out/'finish_payload.json').read_text(encoding='utf-8'))
(out/'README.md').write_text(p['readme'],encoding='utf-8',newline='\n')
(out/'publish.py').write_text(p['publish'],encoding='utf-8',newline='\n')
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md','DEAD_STREET_PROJECT_CONTROL.md']:
    path=root/'docs'/name
    if p['entry'].splitlines()[0] not in path.read_text(encoding='utf-8'):
        with path.open('a',encoding='utf-8') as f:f.write('\n\n'+p['entry'])
    assert p['entry'] in path.read_text(encoding='utf-8')
print('RECORDS_SAVED; PUBLICATION_PREPARED',flush=True)
