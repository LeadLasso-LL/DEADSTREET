from pathlib import Path
import json,hashlib
r=Path(r"C:\Users\brand\OneDrive\Documents\dead-street");p=r/"tools/bike_slots_20260915";key="gameplay/estate_battle_setup.gd";f=r/key
h=lambda b:hashlib.sha256(b).hexdigest()
receipt=json.loads((p/"installed.json").read_text());raw=f.read_bytes();assert h(raw)==receipt[key],"Concurrent edit"
s=raw.decode("utf-8").replace("\r\n","\n")
for old,new in json.loads((p/"motion_rigid.json").read_text()):
 assert s.count(old)==1,old
 s=s.replace(old,new,1)
f.write_bytes(s.encode("utf-8"));receipt[key]=h(f.read_bytes());(p/"installed.json").write_text(json.dumps(receipt,indent=2))
for ext in ["json","log"]:
 src=p/("motion."+ext)
 if src.exists():(p/("motion_spacing_attempt."+ext)).write_bytes(src.read_bytes())
tests=json.loads((p/"tests.json").read_text());tests["motion.gd"]=(p/"motion_verified.gd").read_text();(p/"tests.json").write_text(json.dumps(tests))
print("Estate group spacing now follows shared centerline; cars validate slot-local alternatives")
