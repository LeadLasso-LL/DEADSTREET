from pathlib import Path
import json,hashlib,subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_finish_20260915';base=json.loads((o/'baseline.json').read_text());old=json.loads((r/'tools/yard_revision_20260915/ravicci/record.json').read_text());new=json.loads((o/'record.json').read_text())
for key in ['winner','survivors','combat_seconds','commands','manifest','results']:assert old[key]==new[key],'Battle changed: '+key
allowed={'gameplay/doble_ocho_art.gd','gameplay/tactical_convoy_audio.gd'}
changed=[n for n,h in base['sources'].items() if hashlib.sha256((r/n).read_bytes()).hexdigest()!=h];assert all(n.replace('\\','/') in allowed for n in changed),changed
capture=json.loads((o/'capture_source_hashes.json').read_text());bad=[n for n,h in capture.items() if hashlib.sha256((r/n).read_bytes()).hexdigest()!=h];assert not bad,bad
head=subprocess.run(['git','rev-parse','HEAD'],cwd=r,capture_output=True,check=True).stdout.decode().strip();index=subprocess.run(['git','diff','--cached','--name-only'],cwd=r,capture_output=True,check=True).stdout.decode().strip()
proof={'head':head,'index':index,'baseline_count':len(base['sources']),'changed_sources':changed,'other_sources_unchanged':len(base['sources'])-len(changed),'capture_hash_count':len(capture),'changed_since_capture':bad,'exact_battle_comparison':'PASS: winner/survivors/combat time/orders/manifest/results identical'}
(o/'preservation.json').write_text(json.dumps(proof,indent=2));print(json.dumps(proof,indent=2))
