# Faction glossary audio preview — 2026-09-15

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
