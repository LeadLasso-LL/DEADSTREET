# DEAD STREET native opening / Enter gate

Owner accepted cinematic revision3 and requested a silent black launch screen with one Enter button, visually identical to Open Sandbox. This pass makes that flow interactive in the testing sandbox.

## Runtime flow

- Boot waits indefinitely on black with Enter. No track, video timeline or battle advances.
- Mouse, keyboard focus/activation, or Enter starts the signature and credits once. Duplicate activation and early sandbox entry are ignored.
- Approved Gloria/Godot/caution/pixel assembly retained. Caution is stationary at full brightness8-9.25s; zoom completes into clean black; black11.5-13s; title completes at21s. Cue clock follows audible signature playback, compensated for audio output latency.
- At21s native title begins its same +/-3px suspended hover and the actual Bridge/Harold/Estate/TRC montage fades in. The 24s montage loops independently. Open Sandbox becomes available at27s.
- Open Sandbox reveals the current real arsenal scene and its Tutorial. The same AudioStreamPlayer continues, with no restart. Now-playing docks into Music. Music panel supports pause/resume, volume, the one-track catalogue and saved future-shuffle exclusion. Next is disabled while only one track exists; no fake tracks. A completed sole track waits for deliberate replay rather than repeating immediately.
- Menu music pauses during a launched battle so its soundtrack can play; it resumes from the same position on return. Music UI is hidden during battles. This is a menu-only scope choice, not a change to battle audio.

## Files / ownership

New gameplay/sandbox_opening.gd, sandbox_opening.tscn, sandbox_menu_music.gd; assets/menu/opening; tools/menu_title_20260914/native. Existing arsenal_review.gd/Tutorial are loaded unchanged. Project default campaign startup and the shared benchmark/release package remain unchanged. The sandbox launcher is updated only after native validation.

prepare_media.py rebuilds approved media from existing source assets and recordings. Source composition comes from revision3/compose_revision3.py; all original title/sign/logo assets preserved. Godot uses silent Ogg Theora startup/montage and a separate owner-supplied MP3. Existing ASSET_CREDITS.md covers artwork, Godot logo CC BY4.0 and music attribution. Display-frame counts are checked by complete FFmpeg decoding normalized to30fps. Theora intentionally omits redundant frame packets, so raw decoded packet count is not the displayed frame count; startup duration remains21s/630 display frames.

Windows FFmpeg7.1 resets frame-rate metadata through filter stages differently from the scratch renderer. Normalize fps after timestamps and every crossfade. Extend the final montage frame only as needed to preserve the exact720-frame endpoint; no cut offsets or music cues change. Startup uses per-input decoded concatenation because title motion is FFV1 while credit intermediates are H.264.

build_native.py snapshots production source into AppData/Local/DeadStreetTools/sandbox_opening_20260914 and builds an independent executable/PCK pair over the existing immutable4GB benchmark asset pack. It includes current tutorial and portrait assets. Rebuild after future production changes; this is not a live view of uncommitted source. Never repack the shared release runtime for this pass.

Commands: Python prepare_media.py, then build_native.py smoke, record (optional) or package. validate.gd uses actual button clicks, audible-time cues, full-frame blackout, same-player continuity, functional Music controls and Tutorial reachability. Documentation: https://docs.godotengine.org/en/stable/classes/class_videostreamplayer.html and https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html . Native evidence/limits and launcher installation receipt will be appended after validation.

Status: IMPLEMENTED / NATIVE-VALIDATED. Revision3 cinematic is OWNER-ACCEPTED; the new interactive native integration awaits owner review. No commit/push in this pass.

## Installed entry and final evidence

The normal tools/arsenal_production/Open-Arsenal.ps1 now enters gameplay/sandbox_opening.tscn. Open Dead Street Sandbox.cmd in the repository and the Dead Street Sandbox desktop shortcut use the installed Godot GUI runtime against live source, including the parallel sandbox navigation work. The isolated package is a diagnostic snapshot, not the default launcher.

The final live-source run on Godot4.7.2/D3D12 passes29 checks: silent indefinite gate, matching button bounds, click activation, duplicate/early-entry protection, approved title dimensions, full-black viewport, title cue21.000424s, button27.002758s, actual sandbox entry, same audio player/play_count1, popup docking, Music panel, playlist preference, pause/resume without replay and current navigation's Tutorial. Evidence: direct_smoke.json/log, gate.png, first_firefight.png, music_panel.png, launch_receipt.json, shortcut_receipt.json. Full media decoding passed separately. No battle/performance regression suite was run for this opening-only change. Existing Tutorial reports a non-equal-anchor size warning; opening test still passes, and its source was preserved.

Resolved implementation/validation findings: set TextureRect expand mode before size to avoid native texture dimensions overriding the approved title bounds; use explicit track_finished for replay so pause/resume cannot restart; use viewport-local push_input for the editor's scaled display; locate the visible new Tab_tutorial with legacy fallback; preserve UTF-8 on Windows transfers to prevent corrupted symbol labels. Network transport temporarily disconnected; final checks completed after recovery.

Only one supplied music track is installed. Next remains disabled until other music is supplied; full multi-track shuffle is future work. First title hover/background starts21s, Open Sandbox27s, both relative to Enter. Campaign main_scene and shared release pack are unchanged. Future work: owner tests this native entry; add supplied tracks and expand queue behavior; coordinate packaging with current glossary/menu owner.
