from pathlib import Path
import json,hashlib,subprocess,difflib
out=Path(__file__).resolve().parent;root=out.parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
hashes=json.loads((out/'source_hashes.json').read_text())
for p,h in hashes.items():assert sha(root/p)==h,'Concurrent audio source change: '+p
catalog_path=root/'assets/data/music_catalog.json';raw=catalog_path.read_bytes();catalog=json.loads(raw)
assert catalog['faction_tracks']['calle_ocho']=='burn_b22' and catalog['faction_tracks']['union_sur']=='burn_b22'
before=dict(catalog['faction_tracks']);catalog['faction_tracks']['calle_ocho']='glock_b22'
assert len(set(catalog['faction_tracks'].values()))==21 and all(v==catalog['faction_tracks'][k] for k,v in before.items() if k!='calle_ocho')
assert set(catalog['faction_tracks'].values())=={t['id'] for t in catalog['tracks'] if 'battle_loop' in t}
(out/'pre_correction_assignments.json').write_bytes((out/'approved_assignments.json').read_bytes())
for path in [out/'approved_assignments.json',root/'tools/faction_music_picker_20260915/assignments.json']:
    record=json.loads(path.read_text(encoding='utf-8'));record['faction_tracks']['calle_ocho']='glock_b22';record['status']='owner_approved';record.pop('pending_decision',None)
    record['correction']='Owner: make glock the track for calle ocho. La Union del Sur keeps Burn.'
    for row in record['assignments']:
        if row['faction_id']=='calle_ocho':row['track']='Glock';row['track_id']='glock_b22';row['artist']='B-22'
    path.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
assert catalog_path.read_bytes()==raw
catalog_path.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
payload=json.loads((out/'native_payload.json').read_text(encoding='utf-8'))
payload['gd']=payload['gd'].replace('note("shared_burn_preserved",approved.calle_ocho==approved.union_sur and approved.calle_ocho=="burn_b22")','note("final_calle_glock_union_burn",approved.calle_ocho=="glock_b22" and approved.union_sur=="burn_b22")')
(out/'native_payload.json').write_text(json.dumps(payload),encoding='utf-8')
(out/'check_native.gd').write_text(payload['gd'],encoding='utf-8',newline='\n')
correction=json.loads((out/'correction_payload.json').read_text(encoding='utf-8'))
(out/'check_correction.gd').write_text(correction['gd'],encoding='utf-8',newline='\n')
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
with (out/'correction.log').open('w',encoding='utf-8') as f:r=subprocess.run([godot,'--path',str(root),'--script','res://tools/faction_music_apply_20260915/check_correction.gd'],stdout=f,stderr=subprocess.STDOUT,timeout=35)
print((out/'correction.log').read_text(encoding='utf-8')[-800:],flush=True);assert r.returncode==0
hashes['assets/data/music_catalog.json']=sha(catalog_path)
(out/'source_hashes.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
diff=''
for name in hashes:
    diff+=''.join(difflib.unified_diff((out/('before_'+Path(name).name)).read_text(encoding='utf-8').splitlines(True),(root/name).read_text(encoding='utf-8').splitlines(True),fromfile='a/'+name,tofile='b/'+name))
(out/'runtime.patch').write_text(diff,encoding='utf-8')
print('FINAL_MAPPING_21_UNIQUE_VALIDATED',flush=True)
