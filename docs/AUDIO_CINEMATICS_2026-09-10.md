# Harold audio and battle presentation — 10 September 2026

This pass builds on `9bc0802` and the approved `harold-map-art-v1` map. Map geometry, unit wardrobes, weapons, cover logic and combat balance remain authoritative.

## Presentation contract

- Location identity: **Mercer Heights / Harold Ave. / Harold Apartments**.
- Before the attacking vehicle arrives, a large context panel identifies **Orlov Bratva — Attacking** and **Mercer Saints — Defending**, with their original approved emblems. It contracts into the persistent top-left location bar.
- Deployment must be committed first. The vehicle approaches with closed doors, stops, opens its doors and lets attackers disembark. Defenders emerge from the apartment and take their committed positions. Routes use the navigation service; animation never changes canonical positions, vitality or simulation time.
- Combat remains stopped until the arrival completes and **START BATTLE** is pressed. The showcase presses it after a short pause. All four showcase attackers occupy legal cover before combat starts.
- The existing medium arrival slot is used. Close/medium/far selection remains the separately identified deployment milestone in `harold_street_catalog.gd`; this pass does not add that selector.
- Circular unit identifiers reuse each faction's original emblem. **UNIT EMBLEMS** toggles them; **AUDIO** mutes the presentation mix. Both switches are in the command HUD. The instructional footer is removed.
- On a result, the camera eases back over the battlefield. The two faction panels show green VICTORY/red DEFEAT and all four unit cards per faction. Cards use the same renderer, data query, status, portrait tint, weapon labels and health width as the live HUD. Health and status are never invented for the results presentation.
- Bodies and survivors remain at their actual finishing positions. The result stays until **CONTINUE**, then normal campaign handoff runs. No extraction or relocation is invented.

## Original emblem provenance

Recovered from the approved Idea Repository designs and copied byte-for-byte:

| Faction | Original asset | SHA-256 |
| --- | --- | --- |
| Mercer Saints | Mercer Heights M Badge.png | `8e98fa643e44fbb7bccd591e809cbbcf362f154f0af104558a8792fc83ac1c06` |
| Orlov Bratva | Silver double-headed eagle faction badge.png | `eda4977c0ff7f4a65839f2b1368d915c76a1be64063b0f1d4d4a1b75d0221a8f` |

The Saints emblem is a white blackletter M on deep red. The Bratva emblem is the silver double-headed eagle on gunmetal with its red rim. Texture size is explicitly constrained in UI controls; the full-resolution originals are retained in `assets/art/factions/`.

## Audio

`tools/battle_audio/build_audio.py` deterministically synthesizes 23 original 48 kHz WAVs. No third-party recordings, commercial songs, purchases or external audio assets are used.

- Three shot variations for each of SMG, rifle, pistol and shotgun, with different body/crack/decay and short street reflections.
- Stereo city bed with passing traffic, distant horns and a low mechanical background.
- Original 96 BPM four-bar hip-hop loop, low-pass filtered at 650 Hz and positioned inside Harold Apartments.
- Arrival engine and door sounds, four footstep variations, reload handling and impact sounds.

Gunshots follow actual attack-event sequence IDs exactly once. Spatial positions follow the source units; variation never consumes the combat random-number generator. Muting discards the backlog. Loops stop outside the scene. Audio is presentation-only and cannot affect hits, wounds, movement or the winner.

## Recording and verification

The selected 4v4 showcase uses seed **2002**, one of each role per side. Orders and timing are staged; accuracy, damage, wounds, deaths and victory use the normal simulation. The sequence uses covered deployment, advances between cover objects and a late push to finish the exchange. No unit health, damage probability or winner is modified for the recording.

- Existing showcase/wardrobe/HUD validation: **713 checks passed**.
- New presentation validation: **121 checks passed**, including no combat during arrival, legal routes, starting cover, emblem toggles, bounded result-logo sizing, identical terminal cards, audio event de-duplication, mute backlog behavior and campaign handoff after Continue.
- The native Godot recording includes live audio. H.264/AAC encoding retains 1080p/30 FPS, trims only two setup frames, and adds a short opening/closing fade.
- The encoder decodes the complete output and measures the audio for non-finite samples, missing content and clipping. Final machine-readable results and review frames are saved alongside the capture under `tools/battle_showcase/results/`.
- Auditory listening review was not available in the execution environment; waveform, event and encoded-mix checks are the audio validation performed.

Reproduce: run `tools/battle_showcase/record.ps1 -Godot <Godot console executable> -Seed 2002`, then `python tools/battle_showcase/encode_video.py`. The recording helper preserves existing overrides and removes only its own temporary capture override.

Final recording: `Dead_Street_Harold_Audio_Cinematics.mp4`, **62.4 seconds**, **1920x1080**, **30 FPS**, H.264 with 48 kHz stereo AAC. Battle duration is 42.633 seconds; 52 attack events produced exactly 52 gunshot playback events. Mercer Saints win with two survivors. The encoded audio peak is **-4.63 dBFS**, leaving headroom without clipping. SHA-256: `ad9185cd07fa208f3740d24ac4c92dc95680e451cdc57afd470991fde9d6655d`.
