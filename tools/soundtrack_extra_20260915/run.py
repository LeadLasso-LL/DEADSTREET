from pathlib import Path
import json,subprocess,sys,hashlib
out=Path(__file__).resolve().parent;root=out.parents[1];prior=root/'tools/soundtrack_batch_20260915'
manifest=json.loads((out/'manifest.json').read_text(encoding='utf-8-sig'));n=len(manifest['tracks'])
catalog=json.loads((root/'assets/data/music_catalog.json').read_text(encoding='utf-8'))
assert n==3 and len(catalog['tracks'])==19
assert not ({t['id'] for t in manifest['tracks']} & {t['id'] for t in catalog['tracks']})
(out/'protected_before.json').write_text(json.dumps({p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in ['gameplay/sandbox_menu_music.gd','gameplay/music_catalog.gd']},indent=2),encoding='utf-8')
fetch=(prior/'fetch_batch.mjs').read_text(encoding='utf-8').replace("+'/17 '","+'/3 '")
build=(prior/'build_batch.py').read_text(encoding='utf-8').replace('==17','==3').replace("'expected':17","'expected':3").replace("==19 and sum('battle_loop' in t for t in catalog['tracks'])==18","==22 and sum('battle_loop' in t for t in catalog['tracks'])==21").replace('19 menu /18 battle loops','22 menu /21 battle loops')
for name,source in [('fetch_batch.mjs',fetch),('build_batch.py',build)]:
    p=out/name;assert not p.exists()
    p.write_text(source,encoding='utf-8',newline='\n')
entry='\n\n## 20260915-soundtrack-extra-01 - Glock, Keys and Ripper intake\n\nOwner supplied three B-22 tracks: Glock30-60s from glockk-draco, Keys31-61s, Ripper48-78s. Full menu songs plus exact30-second loops follow the published model. Source/titles/timestamps saved in tools/soundtrack_extra_20260915/manifest.json. Fresh HEAD710964102ef3f6cca3f47bcbf26a815653e59453, empty index; preserve concurrent portrait/arsenal work. Scope six new audio assets, one catalogue merge and task evidence; no runtime source changes planned. Next: concurrent retrieval/validation, focused new-track native checks and publication. No faction assignments supplied.\n'
with (root/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write(entry)
with (out/'fetch.log').open('w',encoding='utf-8') as f:r=subprocess.run(['node',str(out/'fetch_batch.mjs')],stdout=f,stderr=subprocess.STDOUT)
print('FETCH_RETURN',r.returncode,flush=True)
if r.returncode:raise SystemExit(r.returncode)
with (out/'build.log').open('w',encoding='utf-8') as f:r=subprocess.run([sys.executable,str(out/'build_batch.py')],stdout=f,stderr=subprocess.STDOUT)
print('BUILD_RETURN',r.returncode,flush=True)
raise SystemExit(r.returncode)
