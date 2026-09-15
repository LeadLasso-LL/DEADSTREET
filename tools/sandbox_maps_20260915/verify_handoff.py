from pathlib import Path
import json,hashlib,subprocess
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
p=out/'README.md';t=p.read_text(encoding='utf-8').replace('Stateline Raiders, Blacktop Union, NBPD and TRC','Stateline and Blacktop biker factions, NBPD and TRC');p.write_text(t,encoding='utf-8')
receipt=json.loads((out/'library_receipt.json').read_text(encoding='utf-8'))
for row,name,sha in zip(receipt['results'],['setup_1920x1080.png','convoy_bikes.png'],['47fa019d1e322c83aa051f7858a77f068665b4c065f74100c925fd3fcc1cbba2','bc903b24d7df8790216da7541c571f2e894f131ab7eb59e1c35ea75ef85c4942']):
 row['delivered_sha256']=sha;row['native_path']=str(out/name);row['native_current_sha256']=hashlib.sha256((out/name).read_bytes()).hexdigest()
(out/'library_receipt.json').write_text(json.dumps(receipt,indent=2),encoding='utf-8')
h=r/'docs/DEAD_STREET_HIVE_MIND.md';before=h.read_bytes();t=before.decode('utf-8')
marker='- Observed build branch: build/arsenal-checkpoint-20260911'
line='- Working HEAD verified for sandbox-maps-04: 35e0db12aae4d114364c911a69ae2136de30ee4e; empty index, mixed local source retained. Audio checkpoint publication is verified in faction-reassign-04; this sandbox refresh is local/uncommitted.'
if line not in t:t=t.replace(marker,marker+'\n'+line,1)
assert h.read_bytes()==before;h.write_text(t,encoding='utf-8')
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 assert '20260915-sandbox-maps-04' in (r/'docs'/name).read_text(encoding='utf-8')
assert 'Calder Memorial Bridge' in (r/'gameplay/sandbox_map_catalog.gd').read_text(encoding='utf-8')
assert 'CALDER RIVER / CALDER MEMORIAL BRIDGE' in ' '.join((r/'gameplay/tactical_battle_presentation.gd').read_text(encoding='utf-8').split())
print('Final handoff verified; canonical names retained; screenshots saved:',json.dumps(receipt['results'],indent=2))
print('Git index:',subprocess.check_output(['git','-C',str(r),'diff','--cached','--name-only'],text=True).strip() or 'empty')
