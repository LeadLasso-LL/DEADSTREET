from pathlib import Path
import json
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_revision_20260915';d=json.loads((o/'final_record.json').read_text(encoding='utf-8'))
p=r/'docs/DEAD_STREET_HIVE_MIND.md';s=p.read_text(encoding='utf-8')
for prefix,key in [('**Active objective (2026-09-15):**','active'),('**Immediate next task:**','next'),('| BUILD / fourth map |','row')]:
 matches=[line for line in s.splitlines() if line.startswith(prefix)];assert len(matches)==1,(prefix,len(matches));s=s.replace(matches[0],d[key])
if '### 20260915-doble-ocho-09' not in s:s+=d['entry']
p.write_text(s,encoding='utf-8')
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 p=r/'docs'/name;s=p.read_text(encoding='utf-8')
 if '### 20260915-doble-ocho-09' not in s:p.write_text(s+d['entry'],encoding='utf-8')
(o/'README.md').write_text(d['readme'],encoding='utf-8')
print('HIVE_JOURNAL_PROJECT_CONTROL_HANDOFF_UPDATED')
