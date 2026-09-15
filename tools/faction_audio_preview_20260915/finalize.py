from pathlib import Path
import json,hashlib,difflib,subprocess
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((O/'native_validation.json').read_text());assert report['checks']==250 and not report['errors']
music='gameplay/sandbox_menu_music.gd'
before=(O/'before'/music).read_text(encoding='utf-8-sig');after=(R/music).read_text(encoding='utf-8-sig')
(O/'applied_music_delta.patch').write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+music,tofile='b/'+music)),encoding='utf-8')
readme='''# Faction glossary audio preview — 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED. Reopen the normal live-source Sandbox launcher.

Each of 23 faction pages has **Faction Audio** beneath its leader photograph and a filled right-pointing triangle button. Playback changes it to a filled square. Stop ends the preview, restores the triangle and releases menu music at the same playback position. Only one snippet plays. Natural completion, faction changes, leaving the glossary (including Tutorial), hiding the sandbox and removing the page also release playback. An existing manual pause remains respected.

Uses the 21 approved faction-to-snippet mappings directly from MusicCatalog. TRC and NBPD preview their existing trc_siren.wav and police_siren.wav; TRC retains 0.75 pitch. Each freshly loaded WAV is one-shot for this UI; original files and battle-loop settings are unchanged. Preview gain follows the existing menu volume with 4 dB audition headroom. These are clean, centered previews, separate from the battlefield's spatial placement and interior filters.

`gameplay/faction_audio_preview.gd` owns the AudioStreamPlayer, icons and focus lifecycle. Glossary owns the label/button. `sandbox_menu_panels.gd` stops the preview on tab changes, including the modal Tutorial path. A narrow API/group addition in `sandbox_menu_music.gd` introduces external preview pause without changing manual pause, menu track, playback position, queue or persistent preferences. Next/Shuffle can select a song during audition but cannot make it overlap; stopping then plays that selected song.

## Evidence

Official Windows Godot 4.7.2/D3D12: **250 checks, zero failures** (`native_validation.json`, `native.log`). Actual button input starts/stops all 23 correct WAVs and checks filled icon state, menu pause, source bytes, one-shot mode and siren speed. Same song/player/play-count and frozen timeline/resume position verified; actual WAV finish tested. Navigation, Tutorial, hidden sandbox, prior manual pause, Shuffle interaction, removal cleanup and three desktop sizes pass. Mercer playing/stopped and NBPD siren screenshots inspected. Existing Tutorial layout emits an anchor-sizing warning; no script failures and no unrelated tutorial-layout changes.

Run Godot `--path <repo> --script res://tools/faction_audio_preview_20260915/check_native.gd`. Test uses its own temporary settings file and quiet playback; owner settings remain intact. No whole-battle/performance benchmark was required. No faction mappings, source audio assets or battlefield filters changed.

## Continuation

`baseline.json`/`before/` preserve originals; backups are excluded from editor imports. `install.py` is a single-use guarded source installer. The tab-navigation addition was separately applied and is visible in the committed source diff. `validated_sources.json` records final hashes.

The original opening/menu source remains separately owned and untracked; do not stage the full inherited sandbox_menu_music.gd. Its exact already-applied change is saved in applied_music_delta.patch; future opening-source publication must retain it. Do not reapply this delta to current live source. Existing menu-polish shuffle/compact-toast behavior is preserved.

The previous menu-polish checkpoint was explicitly approved in this turn and pushed/verified at 070469580f055e3352fae8eabaf2425fb171c40f. The earlier publication guard misread normal unified-diff context whitespace as source whitespace; approved publication checked all other source files while preserving valid patch syntax. This task's publication status is recorded separately in publication_receipt.json.
'''
(O/'README.md').write_text(readme,encoding='utf-8')
event='''## 20260915-faction-preview-02 - Implemented and native-validated

Faction Audio label and filled play/stop button installed beneath every glossary leader photograph. Plays exact 21 mapped snippets plus existing TRC/NBPD sirens (TRC 0.75 pitch), as fresh one-shot preview resources. Preview pauses the menu player and Stop/natural finish resumes the same song at its held position. Only one preview; faction/tab/Tutorial/hidden-page/removal transitions stop it. Pre-existing manual pause is respected; Next/Shuffle cannot overlap preview. Existing menu volume controls audition level. Catalogue, source WAVs, battle looping/spatial filters, portraits and art unchanged.

250 official Windows Godot native checks PASS, zero failures: actual controls for all 23 sources and icon states, byte identity, pause/position/play-count continuity, real clip end, navigation/cleanup, manual-pause and Shuffle interaction, three desktop layouts. Actual Mercer playing/stopped and NBPD screenshots visually inspected. Existing unrelated Tutorial anchor warning recorded; no broad battle benchmark or owner appearance acceptance claimed. Source/evidence/reproduction in tools/faction_audio_preview_20260915/README.md; exact live music delta preserved separately from untracked opening ownership. Narrow scope includes new preview node, glossary, one menu-navigation stop line and external menu-pause API.

Brandon's preceding explicit approval was fulfilled: menu-polish checkpoint 070469580f055e3352fae8eabaf2425fb171c40f pushed/remote verified. That prior blocker is resolved. Current preview implementation/evidence/records are complete; publication receipt states actual Git result. Reopen normal live-source Sandbox. Preserve parallel radio-interior/Harold/range work; no implementation work remains before owner review.
'''
milestone='''# Current milestone - faction glossary audio preview - 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED: Faction Audio filled play/stop controls for all 23 factions, automatic menu-music pause and same-position resume, one-shot end/navigation cleanup. 250 native checks PASS. 21 approved snippets and both existing authority sirens reused; no source audio or battlefield changes. Evidence/ownership/continuation: tools/faction_audio_preview_20260915/README.md and journal faction-preview-02. Previous approved menu-polish 07046958 is pushed/verified; current publication status is separate. Reopen normal Sandbox; owner review pending.
'''
deltas={}
for rel,block,prepend in [('docs/DEAD_STREET_HIVE_MIND.md',event,False),('docs/DEAD_STREET_JOURNAL.md',event,False),('docs/DEAD_STREET_PROJECT_CONTROL.md',milestone,True)]:
 p=R/rel;s=p.read_text(encoding='utf-8-sig')
 if block.splitlines()[0] not in s:p.write_text(block+'\n'+s if prepend else s.rstrip()+'\n\n\n'+block,encoding='utf-8')
 deltas[rel]={'block':block,'prepend':prepend}
(O/'owned_doc_deltas.json').write_text(json.dumps(deltas,indent=2))
core=['gameplay/faction_audio_preview.gd','gameplay/sandbox_glossary_panel.gd','gameplay/sandbox_menu_panels.gd']
(O/'validated_sources.json').write_text(json.dumps({p:sha(R/p) for p in core+[music]},indent=2))
scope=core+[str(p.relative_to(R)).replace('\\','/') for p in O.iterdir() if p.is_file() and p.suffix in ['.gd','.py','.md','.json','.patch','.png','.log'] and p.name not in ['publication_plan.json','publication_receipt.json']]
plan={'scope':scope,'hashes':{p:sha(R/p) for p in scope},'live_music_hash':sha(R/music),'checks':250}
(O/'publication_plan.json').write_text(json.dumps(plan,indent=2));print(json.dumps({'records_saved':True,'checks':250,'scope_files':len(scope)}),flush=True)
