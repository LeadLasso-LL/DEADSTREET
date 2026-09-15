from pathlib import Path
import json,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
r=Path(__file__).resolve().parents[2];data=json.loads((r/'assets/data/vehicle_models.json').read_text())
print('MERCER',data.get('faction_preferences',{}).get('mercer'))
for m in sorted(data['models'].values(),key=lambda x:x['price']):
 print(json.dumps({k:v for k,v in m.items() if k in ['id','name','class','category','price','length','width','description','height','display_name','body_height','unit_capacity','lore','sprite_width']}))
print('VEHICLE_ART',*[p.name for p in (r/'gameplay').glob('*vehicle*')])
