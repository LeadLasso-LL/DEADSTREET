from pathlib import Path
import json,re
r=Path(__file__).resolve().parents[2]
print("SCENARIOS",[str(p.relative_to(r)) for p in (r/'tools').glob('**/*config*.gd') if any(s in str(p) for s in ['estate','bridge'])])
for folder in ['gameplay','battle']:
 for p in (r/folder).rglob('*.gd'):
  for n,l in enumerate(p.read_text(encoding='utf-8-sig').splitlines(),1):
   if re.search('HAROLD|SUSPENSION BRIDGE|RIVER BRIDGE|RIVER CROSSING',l):print(str(p.relative_to(r)),n,l)
print((r/'campaign/vehicles/vehicle_model_catalog.gd').read_text()[:5000])
print("DATA",[str(p.relative_to(r)) for p in (r/'assets/data').glob('*vehicle*')])
