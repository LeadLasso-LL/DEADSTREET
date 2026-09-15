from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((O/'native_validation.json').read_text());assert report['passed']
manifest=json.loads((O/'manifest.json').read_text())
assert all(sha(R/p)==h for p,h in manifest['audio_hashes'].items())
done='''## 20260915-menu-trim-02 - Menu-only removal complete and validated

Removed Switch, Ripper, Dead or Alive and Lurk from the sandbox menu list and shuffle. 18 menu songs remain. Existing saved enable flags cannot reintroduce the four. All 22 shared track records, faction assignments and 43 MP3/WAV files are identical to baseline; faction battle snippets and Faction Audio previews still load the excluded songs. No siren, mix, volume, spatial-filter or playback-control changes.

Official Godot 4.7.2 headless menu initialization PASS, exit 0/no errors: 18 actual menu rows, old enabled preferences ignored, excluded IDs absent from three queue refills, four original full-song and battle streams still load, signature Dead Street preserved. No broader audio testing needed for this filtering-only change. Evidence/source hashes/delta: tools/menu_playlist_trim_20260915/. Scope is music_catalog.json eligibility list, MusicCatalog.menu_tracks() and one menu-source call replacement. Inherited untracked sandbox_menu_music.gd remains separately owned; exact already-applied delta saved for eventual opening-source publication. Do not reapply to current source. Reopen normal Sandbox; no further implementation is needed. Current Git outcome is in publication_receipt.json. Preserve concurrent Harold and weapon-card work. Previous comparison d6c0113 was published.
'''
milestone='''# Current milestone - four menu soundtrack exclusions - 2026-09-15

IMPLEMENTED / VALIDATED: Switch, Ripper, Dead or Alive and Lurk removed only from sandbox menu playlist/shuffle; 18 menu songs remain. All faction mappings, snippets and 43 audio assets unchanged. Native menu check PASS, including old saved preferences. See tools/menu_playlist_trim_20260915/README.md and publication_receipt.json. Reopen Sandbox.
'''
docs={}
for rel in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
 p=R/rel;s=p.read_text(encoding='utf-8-sig');p.write_text(s.rstrip()+'\n\n\n'+done,encoding='utf-8');docs[rel]={'block':manifest['event']+'\n\n'+done,'prepend':False}
rel='docs/DEAD_STREET_PROJECT_CONTROL.md';p=R/rel;s=p.read_text(encoding='utf-8-sig');p.write_text(milestone+'\n'+s,encoding='utf-8');docs[rel]={'block':milestone,'prepend':True}
(O/'owned_docs.json').write_text(json.dumps(docs,indent=2))
(O/'README.md').write_text('''# Menu playlist exclusions — 2026-09-15

Owner requested removal of Switch, Ripper, Dead or Alive and Lurk from the sandbox menu only. IMPLEMENTED / VALIDATED. The menu now loads MusicCatalog.menu_tracks(), which excludes the four IDs from the existing complete catalogue. This removes their checkboxes and queue eligibility even with old saved enable flags. All other menu preferences and controls retain their behavior.

All 22 original track records and every faction mapping are identical to baseline; all 43 referenced audio assets have identical SHA256 hashes. Faction battle loops and glossary snippets retain these four songs. No mix, siren, filter, volume or other audio behavior changed.

Official Godot 4.7.2 headless menu load PASS: 18 rows, three queue refills exclude the four, old enabled settings cannot reintroduce them, original menu and battle streams remain loadable, Dead Street signature preserved. Native process exit 0/no errors. Evidence: native_validation.json, native.log, manifest.json. Reproduce with Godot --path <repo> --script res://tools/menu_playlist_trim_20260915/check_menu.gd. Fixture uses and deletes its own temporary settings file.

Inherited untracked gameplay/sandbox_menu_music.gd is preserved with only its track-list call changed. Its already-applied one-line delta is saved in applied_menu_delta.patch; do not reapply it to live source. Before copies are preserved and excluded from Godot import. Publication stages the two tracked catalogue files, this task's evidence and only owned documentation blocks. Actual result is in publication_receipt.json. Reopen normal Sandbox. No further implementation remains.
''',encoding='utf-8')
scope=['assets/data/music_catalog.json','gameplay/music_catalog.gd']+[str(p.relative_to(R)).replace('\\','/') for p in O.iterdir() if p.is_file() and p.name not in ['publication_plan.json','publication_receipt.json']]
plan={'scope':scope,'hashes':{p:sha(R/p) for p in scope},'live_menu_hash':manifest['live_menu_hash']}
(O/'publication_plan.json').write_text(json.dumps(plan,indent=2));print('Menu-only change verified and handoff records saved.',flush=True)
