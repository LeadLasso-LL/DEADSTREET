> Superseded: the sprite-snapping change caused camera jitter. See EASTEX_FREIGHT_STABILITY_20260915.md for the correction and accepted-for-review replacement.

# Eastex arrival audio and tactical clarity — 2026-09-15

Owner requested clearly audible arriving-convoy music, sharper units and floating faction emblems, and a replacement recording of the Ashford-Crane victory over McAllister.

## Production changes

- `gameplay/tactical_convoy_audio.gd`: attacking radio reaches -3 dB during arrival, with a wider audible radius and gentler distance falloff. Its lowpass opens moderately to about 3.87 kHz, retaining interior coloration. Existing positional combat mix returns to -32 dB/2.4 kHz. Siren handling and track assignments are preserved. The arrival correction applies across maps.
- `gameplay/tactical_emblem_marker.gd`: source emblems are prefiltered once into cached output-sized textures, then sampled nearest at one texel per physical pixel. A restrained dark edge separates them from the terrain; selection glow remains.
- `gameplay/tactical_battle_presentation.gd`: floating markers use physical viewport stretch, including the game's 1152×648 logical canvas. They occupy 36×36 pixels at 1080p or 24×24 at 720p, on integer pixel positions.
- `gameplay/tactical_actor_presenter.gd`: render-only sprite anchoring snaps to physical pixels while preserving simulation positions, dimensions and existing nearest sampling. Freight night sprite tones are lifted slightly for legibility.
- `gameplay/freight_exchange_weather.gd`: rain streaks are reduced over visible unit bodies using a small spatial grid. The rain remains fully visible elsewhere; emblems already draw above it. The rain bed drops 6 dB during arrival, roof rain 5 dB, and returns during combat.

No combat, loadout, vehicle geometry, faction assignment, original artwork or menu changes belong to this pass. Preserve the separate bike-slots-04 work.

## Verification

`check.gd` / `validation.json`: 127 native checks pass. Comparing the same source passage at the same vehicle position measures approximately +11.32 dB arrival RMS over the old mix, with peak 0.265 and room below clipping. Combat returns to the prior quieter volume/filter. Tests also cover all 20 floating markers, physical output sizes, pixel alignment, texture dimensions, nearest unit filtering and emblem visibility toggles at 1080p/720p.

Checks initially measured logical rather than physical coordinates; those failures exposed the canvas stretch issue and are retained. Subpixel arithmetic tolerance is 0.01 physical pixel. Earlier frozen presentation test did not initialize visibility; the corrected fixture does so explicitly.

## Recording

`showcase.gd` preserves seed 915523, the previous 10v10 loadouts and scripted tactical orders. No health, damage, RNG or winner override. The runtime simulation determines the victory.

`capture_worker.py` records a lossless 1920×1080 PNG sequence with native WAV audio, then performs one H.264/AAC MP4 encode with faststart. An isolated `capture_project` copy sets MovieWriter's startup viewport resolution explicitly. The capture script restores the normal logical canvas and disables GUI focus/input. Shared project settings are untouched.

The first attempt saved MovieWriter's default 1152×648 frames and lost the presentation at the combat transition; it is preserved under `attempt1_*`. External GUI input was a possible cause, not established as a production failure. The corrected recording's `record.json`, decode result and `delivery.json` are the completion gates. Native frame and encoded MP4 visual review are required before delivery.

`before_sources.zip` / `install_backup.zip` preserve original sources. `capture_source_snapshot.zip`, hashes and `capture_project` preserve the recording's source. The asset/import-cache junctions reuse existing resources; they are not a standalone distributable game export. No commit or push is performed by this pass.

Final delivery and owner-review status are recorded in the hive mind and `docs/handoffs/EASTEX_FREIGHT_CLARITY_20260915.md`.


## 20260915-freight-clarity-03 - Complete; replacement MP4 ready for review
Arrival radio is approximately11.32dB louder than the former mix, retains positional/interior coloration, and returns to the existing quiet combat mix. Arrival rain reduced; floating emblems now use cached physical-pixel textures with integer placement through canvas stretch (36px at1080p /24px at720p). Unit render anchoring snaps to physical pixels, Freight tone is slightly lifted, rain streak interference over bodies is reduced. Five source files owned; bike-slots04 work preserved.
Native127 checks PASS. Full native fight resolves normally: Ashford-Crane wins,8 surviving attackers/0defenders,49.6 combat seconds. Arrival/outro errors0, camera violations0. No combat/loadout/outcome overrides or concurrent source changes during capture. Lossless1920x1080 source encoded once to88.1-second H.264/AAC MP4; complete decode PASS, no audio clipping, native and encoded frames visually reviewed. Mixed-scene arrival RMS0.10849 versus combat0.02145; full peak0.46778.
Replacement DEAD_STREET_Eastex_Freight_Exchange_Clarity.mp4 saved as libfile_11b997eb8900819180e3d0a22b8074c9 version1 (file_000000006c8081f5b48e96fd69f161f4),61580324bytes. SHA25664af0c87c2ae684903789f0edcdd60672c99b1ea066a16fcb213963a9e2f1051. Previous recording remains version0. Capture setup corrected for MovieWriter startup resolution and disabled physical GUI input in isolated capture copy; failed first attempt retained. No shared project setting changes, staging, commit or push. Handoff: docs/handoffs/EASTEX_FREIGHT_CLARITY_20260915.md; evidence/reproduction tools/freight_clarity_20260915/README.md. Next: owner reviews new recording and live-source audio/visuals; packed-export certification remains outside this pass.
