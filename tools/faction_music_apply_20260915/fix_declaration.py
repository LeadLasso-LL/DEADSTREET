from pathlib import Path
import json,subprocess,difflib
out=Path(__file__).resolve().parent;root=out.parents[1]
p=root/'gameplay/tactical_convoy_audio.gd';s=p.read_text(encoding='utf-8')
needle=' clear();battle_id=b.get_instance_id()'
assert s.count(needle)==1 and 'var mappings:' not in s
s=s.replace(needle,needle+'\n var mappings: Dictionary=Music.catalogue().get("faction_tracks",{})',1)
p.write_text(s,encoding='utf-8',newline='\n')
payload=json.loads((out/'payload.json').read_text(encoding='utf-8'))
payload['install']=payload['install'].replace("v.decode('utf-8') for p,v","v.decode('utf-8').replace('\\r\\n','\\n') for p,v")
(out/'payload.json').write_text(json.dumps(payload),encoding='utf-8')
(out/'install.py').write_text(payload['install'],encoding='utf-8',newline='\n')
if (out/'native.log').exists():(out/'native_first_failure.log').write_bytes((out/'native.log').read_bytes())
diff=''
for name in ['assets/data/music_catalog.json','gameplay/tactical_convoy_audio.gd','gameplay/tactical_battle_audio.gd']:
    old=(out/('before_'+Path(name).name)).read_text(encoding='utf-8');new=(root/name).read_text(encoding='utf-8')
    diff+=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+name,tofile='b/'+name))
(out/'runtime.patch').write_text(diff,encoding='utf-8')
print('DECLARATION_FIXED',flush=True)
