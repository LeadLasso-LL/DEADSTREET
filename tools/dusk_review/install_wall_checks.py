import json
from pathlib import Path
p=Path('tools/dusk_review/harold_review.gd')
s=p.read_text()
check=json.loads(Path('tools/dusk_review/wall_checks_payload.json').read_text())
s=s.replace('\tvar audit =',check+'\tvar audit =',1)
s=s.replace('out_dir := "res://tools/dusk_review/harold_results"','out_dir := "res://tools/dusk_review/frontage_results"')
p.write_text(s)
print('Added sightline and corner navigation checks')
