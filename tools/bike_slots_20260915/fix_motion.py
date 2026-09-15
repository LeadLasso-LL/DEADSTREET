from pathlib import Path
import json,hashlib
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent;rel='gameplay/estate_battle_setup.gd';p=r/rel
installed=json.loads((out/'installed.json').read_text());assert hashlib.sha256(p.read_bytes()).hexdigest()==installed[rel]
s=p.read_text(encoding='utf-8')
for e in json.loads((out/'motion_fix.json').read_text()):
 assert s.count(e['old'])==1,e['old'];s=s.replace(e['old'],e['new'],1)
for name in ['motion.log','motion.json']:
 if (out/name).exists():(out/('initial_'+name)).write_bytes((out/name).read_bytes())
p.write_text(s,encoding='utf-8');installed[rel]=hashlib.sha256(p.read_bytes()).hexdigest();(out/'installed.json').write_text(json.dumps(installed,indent=2))
print('Estate mixed convoys retain their slot-specific destinations; bike trailing rows spaced for motion')
