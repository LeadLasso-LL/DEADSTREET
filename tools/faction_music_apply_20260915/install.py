from pathlib import Path
import json,hashlib,subprocess,difflib
out=Path(__file__).resolve().parent;root=out.parents[1];payload=json.loads((out/'payload.json').read_text(encoding='utf-8'))
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=root,text=True).strip()
assignment=json.loads((root/'tools/faction_music_picker_20260915/assignments.json').read_text(encoding='utf-8'));mapping=payload['mapping']
assert assignment['faction_tracks']==mapping and len(mapping)==21 and not {'trc','nbpd'}&mapping.keys()
factions=json.loads((root/'assets/data/faction_units.json').read_text(encoding='utf-8'))['factions'];assert set(mapping)==set(factions)-{'trc','nbpd'}
paths=['assets/data/music_catalog.json','gameplay/tactical_convoy_audio.gd','gameplay/tactical_battle_audio.gd']
before={p:(root/p).read_bytes() for p in paths};text={p:v.decode('utf-8').replace('\r\n','\n') for p,v in before.items()}
for p,v in before.items():(out/('before_'+Path(p).name)).write_bytes(v)
catalog=json.loads(text[paths[0]]);assert len(catalog['tracks'])==22
tracks={t['id']:t for t in catalog['tracks']}
for tid in mapping.values():assert 'battle_loop' in tracks[tid]
catalog['faction_tracks']=mapping
text[paths[0]]=json.dumps(catalog,ensure_ascii=False,indent=2)+'\n'
convoy=text[paths[1]]
convoy=convoy.replace('const Models=', 'const Music=preload("res://gameplay/music_catalog.gd")\nconst Models=',1)
convoy=convoy.replace(' clear();battle_id=b.get_instance_id()\n',' clear();battle_id=b.get_instance_id()\n var mappings: Dictionary=Music.catalogue().get("faction_tracks",{})\n',1)
needle='  if identity=="whittaker" and b.battlefield_geometry.authored_layout_id=="whittaker_estate_v1":'
assert convoy.count(needle)==1
convoy=convoy.replace(needle,'  if identity not in ["trc","nbpd"] and mappings.has(identity):\n   add_faction_radio(b,side,identity,candidates,str(mappings[identity]));continue\n'+needle,1)
assert convoy.count('func sync(')==1
convoy=convoy.replace('func sync(',payload['helper']+'func sync(',1)
text[paths[1]]=convoy
audio=text[paths[2]].replace('const Weapons=','const Music=preload("res://gameplay/music_catalog.gd")\nconst Weapons=',1).replace('var battle_id=0','var battle_id=0\nvar has_faction_music=false',1)
needle=' if b.battlefield_geometry.authored_layout_id in ["river_suspension_bridge_v1","whittaker_estate_v1"]:music.stop()'
insert=' if battle_id!=b.get_instance_id():\n  has_faction_music=false\n  var mappings: Dictionary=Music.catalogue().get("faction_tracks",{})\n  for p in b.participants.values():\n   if p.identity!=null and mappings.has(p.identity.gang_archetype_id):has_faction_music=true;break\n'
assert audio.count(needle)==1
audio=audio.replace(needle,insert+needle.replace('if b.','if has_faction_music or b.'),1)
text[paths[2]]=audio
for p in paths:assert (root/p).read_bytes()==before[p],'Concurrent source edit'
for p in paths:(root/p).write_text(text[p],encoding='utf-8',newline='\n')
approved=dict(assignment);approved['status']='owner_approved';approved['approval_source']='Owner returned completed 21/21 assignment screenshot in chat, 2026-09-15.'
(out/'approved_assignments.json').write_text(json.dumps(approved,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
diff=''.join(''.join(difflib.unified_diff(before[p].decode().splitlines(True),text[p].splitlines(True),fromfile='a/'+p,tofile='b/'+p)) for p in paths)
(out/'runtime.patch').write_text(diff,encoding='utf-8')
protected=['gameplay/tactical_battle_presentation.gd','gameplay/sandbox_menu_music.gd','gameplay/music_catalog.gd']
(out/'protected_hashes.json').write_text(json.dumps({p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in protected},indent=2),encoding='utf-8')
entry='\n\n## 20260915-faction-music-apply-01 - Owner screenshot accepted; mapping installed\n\nOwner returned completed21/21 faction assignment screenshot. Saved picker mapping matches all21 screenshot rows exactly, including Burn shared by Calle Ocho and La Union del Sur; Glock remains available in menu/unassigned. Approved mapping captured in tools/faction_music_apply_20260915/approved_assignments.json and registered in assets/data/music_catalog.json. TRC/NBPD excluded: existing sirens retained. Narrow audio wiring extends current spatial convoy/stronghold radio to mapped factions, suppresses old Harold beat when mapped music is present, keeps existing winner-continuity/mix and siren code. No menu, combat or presentation source edits. Next: validate all mappings, actual battle placement/playback across three maps and siren equivalence; publish scoped source/evidence/owned records. Preserve concurrent portrait/range work.\n'
for name in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md']:
 with (root/'docs'/name).open('a',encoding='utf-8') as f:f.write(entry)
print('MAPPED_21_AND_RUNTIME_WIRED',flush=True)
