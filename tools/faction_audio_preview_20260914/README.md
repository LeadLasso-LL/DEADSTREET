# DEAD STREET — Faction audio audition 01

Status: RENDERED / ENCODE-VALIDATED, OWNER LISTENING APPROVAL PENDING. Preview-only work; no game source or production audio edited. Source: Brandon, 2026-09-14, “Go for it. I wanna hear them all before approving”.

All 18 musical directions in docs/FACTION_AUDIO_DIRECTION_2026-09-14.md now have original instrumental sketches. Existing Mercer/Harold, Stateline, Whittaker, NBPD and TRC identities remain unchanged. Vocals stay parked. This is not the separate B-22 opening/playlist project.

## Review

- `review_index.json`: exact faction IDs, instruments/vibe, tempo, duration, file hashes and reel offsets.
- `validation.json`: full-decode, loudness, peak and reel/chapter checks. All 18 MP3s: -18.27 to -18.24 LUFS, highest true peak -2.23 dBTP. Reel 473.106333 seconds, 18 chapters, H.264/AAC 1280x720, full decode passed.
- Individual files are about 21-32 seconds. `delivery_receipt.json` records durable preview identities when saved.
- Title cards visually inspected across all 18. Encoded audio has not been independently listened to; technical checks establish valid playback data and levels, not artistic quality. Owner listening review is required. HTML browser interaction not independently exercised.

## Reproduce

Python 3.12; numpy 2.3.5, scipy 1.17.0, Pillow 12.3.0. Install TinySoundFont 0.3.7 without playback dependencies: `python -m pip install --no-deps tinysoundfont==0.3.7`. The renderer does not use an audio device. FFmpeg is required.

Run `python fetch_instruments.py`, `python compose.py`, then `python package_review.py`. All output stays in this folder. Composer accepts faction IDs to rerender a subset; package after all 18 JSON/WAV/MP3 sets exist. Packaging uses DejaVu Sans from the Linux runtime: adapt FONT/BOLD paths on Windows, or reproduce in Linux.

`compose.py` contains authored scores, dynamics, rhythms and processing. No songs or melodies sampled from recordings. `manifest.json` preserves exact scored events. GeneralUser GS 2.0.3 instrument bank is fetched from the creator's public repository and checked against its recorded SHA256. Its complete license is preserved, including its sample-provenance caveat; it permits music production. The soundfont itself is a local dependency, not shipped as a game asset. Sources: https://github.com/mrbumpy409/GeneralUser-GS and https://pypi.org/project/tinysoundfont/.

## Decisions and limits

Preview arrangements use sampled instruments and synthesis; these are not live band recordings. Saffar's oud/qanun direction is approximated with articulated nylon-string guitar/dulcimer timbres; no claim of an authentic recorded oud. Corrido, regional hip-hop and other labels express proposed musical direction, not new faction lore. Samples are deliberately clear audition mixes, not final spatial vehicle/property playback or combat ducking. Loop seams and in-game transitions have not been implemented or tested.

No connected instrumental generator was available. Local system package setup failed due setgroups/setuid limits; did not change system permissions. A user-local TinySoundFont installation provided an independent working route. Initial syntax/preset-query mistakes corrected before successful renders. Keep existing five sources and parked vocals untouched. Other chats own title/menu preview and native Tutorial work.

## Next

Brandon hears all 18, identifies keeps/changes/rejections. Revise only named sketches; preserve approved versions. Once sound choices are explicitly approved, prepare loopable masters and consistent faction bindings across maps, using existing spatial audio/combat ducking rules. Preview approval must not be inferred from the request to produce previews.
