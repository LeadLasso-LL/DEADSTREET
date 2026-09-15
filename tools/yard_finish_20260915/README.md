# Doble Ocho final sidewalk/audio correction — 2026-09-15

Implemented and native-validated; owner review next. Latest event doble-ocho-12.

Gray neutral sidewalks and six-unit slab seams, gray curbs/aprons. Production edits only gameplay/doble_ocho_art.gd and gameplay/tactical_convoy_audio.gd plus rebaked assets/art/doble_ocho/ground.png. Previous geometry, cover, fleet and battle configuration unchanged.

Arrival focus: incoming radio+3dB plus retained10% boost,2600reach,.35attenuation; defender radio-14dB. Blends out with existing final-two-arrival-seconds transition. Combat gain/range/attenuation and victory foreground preserved. Actual native radio-bus capture gives23.34–26.92dB attacker lead at four sampled arrival positions. See audio_review.json/audio_review.gd. Initial silent/uninitialized probes were corrected and are not evidence; final probe waits for the authored view, enables audio and uses movie-maker rendering.

Final video: DEAD_STREET_Ravicci_Raid_Final.mp4;53.7967seconds,1280x720/30fps H264/AAC fast-start,7369078bytes. Native recording1152x648, export upscale1280x720. Fully decoded and finite audio peak.446738. SHA256 b31c1092b7bc3c7330a00d9370d4f1d5197050b8f103653b3efc4d627d74c413.
Video libfile_e00f8e02fe808191bafc7466b9aa68be v0; screenshot libfile_fe89df92fa588191b1d47f6f76e3d26f v0. Chat files /workspace/scratch/6a4bd31e258d/yard_finish/DEAD_STREET_Ravicci_Raid_Final.mp4 and DEAD_STREET_Gray_Sidewalks.png.

Same Ravicci7vCalleOcho7 showcase as previous: T3vsT2 stock weapons, Monarch4/Obsidian3, seed91517. Verify_delivery.py confirms exact winner/survivors23.90s combat/orders/manifest/results equality. Three Ravicci survivors; no health/damage/RNG/winner overrides.0camera violations over1342samples;0arrival/outro/errors. Six existing ObjectDB shutdown leaks; no full regression claim.

Preservation.json:246other production scripts match248file baseline;251capture hashes intact. HEAD9604323afae49ee63915b378048cfac9940f1f66; index empty. No commit/push. Preserve earlier mixed work. Exact backups before/ and baseline.json. Prior map geometry/integration checks remain in tools/yard_revision_20260915/; only the current correction was rerun here.

Reproduce: run_native.py bake for scenery; run_native.py audio audio_review.gd for mixer proof; record_worker.py for same native battle/encode. Preserve existing raw video by cloning capture tools into a new take directory and adjusting paths before recapturing. Source changes are live through Sandbox shortcut. Production reusable preset remains Sierra Roja; capture_config.gd defines the owner-requested Ravicci video cast. Next owner review; Harold cover/stairs remains separate.
