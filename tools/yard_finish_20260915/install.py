from pathlib import Path
import json,hashlib,subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_finish_20260915';data=json.loads((o/'writes.json').read_text());base=json.loads((o/'baseline.json').read_text())
for n in ['gameplay/doble_ocho_art.gd','gameplay/tactical_convoy_audio.gd']:
 assert hashlib.sha256((r/n).read_bytes()).hexdigest()==base['sources'][str(Path(n))],n
 assert (r/n).read_bytes()==(o/'before'/n).read_bytes(),n
for n,c in data.items():
 assert n in ['gameplay/doble_ocho_art.gd','gameplay/tactical_convoy_audio.gd'] or n.startswith('tools/yard_finish_20260915/'),n
 p=r/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(c,encoding='utf-8',newline='\n')
print('INSTALLED_WITH_BYTE_GUARDS',flush=True)
subprocess.run([sys.executable,str(o/'run_native.py'),'bake'],check=True)
subprocess.run([sys.executable,str(o/'run_native.py'),'audio','audio_review.gd'],check=True)
print('BAKE_AND_SPATIAL_AUDIO_PASS',flush=True)
