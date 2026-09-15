# Dead Street title and menu music — 2026-09-14

Source: Brandon, chat 3438f1ea0e55. Title concept work and intro-track retrieval authorized. Full menu implementation remains a discussed design, not implemented.

## Owner direction
- Build the opening/menu into the Battle Testing Sandbox as the baseline for Dead Street V1.
- Title reads DEAD STREET in Mercer Saints Old English lettering; slight arch with sharp downward extensions at its outer left/right bottoms; deliberate 2D pixel-art finish matching the game.
- Title prominent in upper middle; gentle small vertical hover and occasional spaced TV-static effect.
- Background: prerecorded/edited actual battles, zooms/scenarios, vehicles, convoys, troop movement, arrivals and theatrical kills; black-and-white, subdued like a watermark, police-helicopter-camera framing.
- One button near the bottom: Open Sandbox.
- Signature track always plays on opening; entering sandbox menus starts shuffled catalogue.
- Signature track belongs in shuffle but NEVER plays first, preventing immediate intro repetition.
- Bottom-right controls and keyboard shortcuts skip tracks/open playlist; playlist shows current track and actual shuffle order; checkboxes exclude songs.
- On each track start, bottom-right title/artist popup; keep SoundCloud titles; OB credited OB, brandon credited B-22.
- Assistant suggestions only, not separately owner-approved: persist exclusions, exhaust shuffle before repeats, uninterrupted menu-page playback.
- Battle-start music fade behavior not yet answered; do not infer it.

## Current asset
- SoundCloud link supplied by owner resolves to Track 22, source artist brandon; game credit B-22, source duration 155338 ms.
- Full progressive MP3 retrieved without recompression: B-22_Track_22.mp3 (2485184 bytes).
- SHA256: 74f73732e59f915fd96cb007571004540d26839ffb4ddf2a3f7fc152294680bb.
- Metadata/provenance: track_22.json; retrieval script fetch_soundcloud.mjs. Full-frame MPEG structural validation passed; see mp3_validation.json. Full decode/listening check not run.
- Title preview uses current assets/art/factions/roster/mercer.png for Old English letterform reference. Preview is not owner acceptance or runtime integration.
- Existing BUILD chat owns estate/audio/results; preserve its sources and all unrelated dirty work.
