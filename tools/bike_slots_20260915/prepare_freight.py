from pathlib import Path
import json
r=Path(r"C:\Users\brand\OneDrive\Documents\dead-street");p=r/"tools/bike_slots_20260915"
f=r/"gameplay/freight_exchange_setup.gd"
if not (p/"freight_before.gd").exists():(p/"freight_before.gd").write_bytes(f.read_bytes())
tests=json.loads((p/"tests.json").read_text());s=tests["motion.gd"]
s=s.replace("res://gameplay/estate_battle_setup.gd","res://gameplay/freight_exchange_setup.gd").replace('"whittaker_estate"','"freight_exchange"')
s=s.replace('JSON.parse_string(FileAccess.get_file_as_string("res://tools/bike_slots_20260915/source_before.json"))["gameplay/estate_battle_setup.gd"]','FileAccess.get_file_as_string("res://tools/bike_slots_20260915/freight_before.gd")')
s=s.replace('range(30,361)','range(30,541)').replace('/motion.json','/freight_motion.json')
tests["freight_motion.gd"]=s;(p/"tests.json").write_text(json.dumps(tests))
print("Freight mixed and twelve-bike motion fixture installed; no production edits")
