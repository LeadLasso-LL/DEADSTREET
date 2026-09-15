from pathlib import Path
import json,hashlib,difflib,subprocess
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def git(*a):return subprocess.check_output(['git',*a],cwd=R)
assert git('branch','--show-current').decode().strip()=='build/arsenal-checkpoint-20260911'
data_path='assets/data/music_catalog.json';catalog_path='gameplay/music_catalog.gd';menu_path='gameplay/sandbox_menu_music.gd'
assert not git('diff','HEAD','--',data_path,catalog_path)
assert not (O/'before').exists(), 'Single-use installer already ran'
for rel in [data_path,catalog_path,menu_path]:
 p=O/'before'/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((R/rel).read_bytes())
(O/'before'/'.gdignore').write_text('')
original=json.loads((R/data_path).read_text(encoding='utf-8-sig'))
names=['Switch','Ripper','Dead or Alive','Lurk']
ids=[next(t['id'] for t in original['tracks'] if t['title']==name) for name in names]
assert len(set(ids))==4 and 'menu_excluded_tracks' not in original
audio_files=[]
for t in original['tracks']:
 for value in [t.get('menu_file',''),t.get('battle_loop',{}).get('file','')]:
  if value:audio_files.append(value.removeprefix('res://'))
audio_hashes={rel:sha(R/rel) for rel in audio_files}
event='''## 20260915-menu-trim-01 - Four tracks removed from menu only

Brandon explicitly requested removing Switch, Ripper, Dead or Alive and Lurk from the sandbox menu playlist because they do not suit the menu; change nothing else for audio. Implement menu-only eligibility in MusicCatalog and the menu player's track-list load. Preserve all 22 full track records, original audio assets, faction mappings/snippets, sirens, filters, volume and playback behavior. Exclusions apply even when an old user preference has those tracks enabled; they are absent from the menu list and shuffle. Menu roster becomes 18 tracks. Only catalogue data/helper and one live untracked menu-source line are owned; preserve other opening changes through an already-applied delta instead of staging that inherited source. Previous comparison d6c0113 is pushed/verified; this is a new narrow request. Native menu loading and exact catalogue/audio preservation will be checked before completion.
'''
for rel in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
 p=R/rel;s=p.read_text(encoding='utf-8-sig');p.write_text(s.rstrip()+'\n\n\n'+event,encoding='utf-8')
s=(R/data_path).read_text(encoding='utf-8-sig');assert s.startswith('{\n')
s=s.replace('{\n','{\n  "menu_excluded_tracks": '+json.dumps(ids)+',\n',1);(R/data_path).write_text(s,encoding='utf-8')
s=(R/catalog_path).read_text(encoding='utf-8-sig')
s+='\n\nstatic func menu_tracks() -> Array:\n\tvar data = catalogue()\n\tvar excluded: Array = data.get("menu_excluded_tracks", [])\n\treturn data.get("tracks", []).filter(func(item): return str(item.get("id", "")) not in excluded)\n'
(R/catalog_path).write_text(s,encoding='utf-8')
before=(R/menu_path).read_text(encoding='utf-8-sig');assert before.count('tracks = Catalog.tracks()')==1
after=before.replace('tracks = Catalog.tracks()','tracks = Catalog.menu_tracks()');(R/menu_path).write_text(after,encoding='utf-8')
(O/'applied_menu_delta.patch').write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+menu_path,tofile='b/'+menu_path)),encoding='utf-8')
updated=json.loads((R/data_path).read_text(encoding='utf-8-sig'));assert updated.pop('menu_excluded_tracks')==ids and updated==original
assert all(sha(R/p)==h for p,h in audio_hashes.items())
manifest={'removed_titles':names,'removed_ids':ids,'menu_count':18,'catalogue_count':22,'audio_hashes':audio_hashes,'other_catalogue_data_identical':True,'live_menu_hash':sha(R/menu_path),'event':event}
(O/'manifest.json').write_text(json.dumps(manifest,indent=2))
print(json.dumps({'removed':names,'menu_tracks':18,'full_catalogue':22,'unchanged_audio_files':len(audio_hashes),'all_other_catalogue_fields_identical':True}),flush=True)
