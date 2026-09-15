from pathlib import Path
import json
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/menu_title_20260914/native'
receipt=json.loads((out/'launch_receipt.json').read_text())
shortcut=json.loads((out/'shortcut_receipt.json').read_text(encoding='utf-8-sig'))
assert receipt['status']=='INSTALLED'
assert 'sandbox_opening.tscn' in shortcut['Arguments']
payload=json.loads((out/'finish_payload.json').read_text(encoding='utf-8-sig'))
for row in payload['records']:
 p=repo/row['path']
 current=p.read_text(encoding='utf-8-sig')
 if '20260914-opening-native-03' not in current and row['path']!='docs/DEAD_STREET_PROJECT_CONTROL.md' or (row['path']=='docs/DEAD_STREET_PROJECT_CONTROL.md' and '## 2026-09-14 - Native opening and Enter launch gate' not in current):
  with p.open('a',encoding='utf-8') as f:f.write(row['content'])
 assert row['content'].strip() in p.read_text(encoding='utf-8-sig')
print('OPENING_LAUNCH_AND_RECORDS_VERIFIED')
print(json.dumps(shortcut))
