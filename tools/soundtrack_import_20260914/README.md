# Imported soundtrack model — Bond / OB

IMPLEMENTED / NATIVE-VALIDATED, 2026-09-14. Owner requested full Bond in the menu and a 30-second looping battle excerpt starting at 00:21 as the model for the incoming batch.

The shared catalogue is assets/data/music_catalog.json; gameplay/music_catalog.gd loads full menu MP3s and explicit stereo WAV battle loops by stable track ID. Bond's ID is bond_ob. Its catalogue entry keeps title/artist, SoundCloud identity and URL, source hash, menu path, excerpt timing, processing and loop asset hash. Menu exclusions are user preferences, separate from faction associations. No faction was assigned and no existing faction audio was replaced. The faction_tracks map is empty until owner assignments; Catalog.faction_stream returns null for unmapped factions. Battle callers can use Catalog.battle_stream("bond_ob") now; BUILD retains world-source/mix integration.

## Assets

- Full menu: assets/audio/music/OB_Bond.mp3. Original unchanged bytes: 2234408; SHA256 b2e7a8f318a5c64083ad1ff3b9723b42f987638ba12c633b165e0b930f783634. Source https://soundcloud.com/colinobriennn/bond, ID408242721, title Bond, artist OB.
- Battle: assets/audio/music/OB_Bond_battle_21_51.wav. Exactly 30.000 seconds /1323000 stereo frames at44100Hz,16-bit PCM. Starts at source21.000s and runs to51.000s. Final80ms uses a smooth wrap blend into the80ms of source immediately preceding21s (20.92–21.00) so the next first sample follows naturally. No silent gap and no change to the30-second period. Source decoded peak1.01422 required -1.12266dB gain on the excerpt, leaving -1dBFS peak; full MP3 unchanged. The rest of the excerpt is unchanged apart from uniform gain and PCM quantization.
- Loop loader explicitly sets LOOP_FORWARD, begin0 and end1323000; stereo loop_end counts frames, not interleaved samples. Avoid an MP3 excerpt and its encoder-padding risk.

## Menu behavior

Silent Enter starts Dead Street by B-22 once; same player/song/position continues through entry. After entry, end-of-file or Next selects from the enabled shuffle bag without immediate repeats when another song exists. Dead Street stays eligible. The visible list shows current song, numbered upcoming order and remaining/excluded entries; the scroll area accommodates future imports. Checkboxes and volume persist in user://dead_street_music.cfg. Unchecking the current song affects future selection and lets it finish. With no alternative enabled, ending stops and deliberate Play can replay an enabled current song, preserving prior one-track behavior.

M opens/closes Music; media Next skips; media Play toggles pause; Space toggles while the panel is open and the key is otherwise unhandled; Escape closes. Pause/Play/Next icons and outside-click/tap dismissal remain. Next while paused selects the new song and preserves pause. Battle/menu visibility pauses and resumes the current position. Each track change resets title/artist toast; toast is above an open panel and ignores mouse/touch so it cannot cover or intercept transport controls.

## Future batch intake

1. Resolve the owner-supplied SoundCloud URL using its existing access settings. Retrieve full playback, validate complete decode/duration and retain original bytes/hash/provenance. The existing demonstrated importer is tools/menu_title_20260914/fetch_soundcloud.mjs; OB extraction evidence is tools/soundcloud_ob_test_20260914. Never publish temporary page HTML or playback tokens.
2. Exact owner text outside the URL is the display title; URL alone uses the source title. Keep source title separately. Credit brandon as B-22 and OB as OB. Give each track a stable distinct ID and a full menu asset.
3. Record the requested battle start/duration per track; create a loop asset with exact period and a short documented seam treatment. Bond is21–51; future start points remain data, not an assumed universal timestamp. Check decoded peaks before PCM conversion.
4. Add the catalogue entry. Menu discovers it automatically; new entries default enabled and appear in the shuffle UI without new button code. Verify all assets/IDs, decoding and loop boundaries. Assign factions separately after owner direction; preserve existing spatial/combat audio until coordinated binding.

## Validation and limitations

Final native Godot4.7.2 test:36 checks PASS, zero failures/errors. Includes real opening scene Enter and audio-clock21/27 cues (seek-assisted, not a complete cinematic rerun), same-player entry, actual end-of-file advancement, eight no-repeat advances, actual pointer Pause/Next/checkbox use, persisted settings, battle/menu pause-resume, keys, popup/dismissal and scaled bounds. Three real WAV wrap crossings remain playing without emitting finished. Audio validation checks full decode, exact sample count, unchanged full source, seam step and headroom. Processed boundary step0.0176231 equals the source's normal adjacent-sample step, versus raw splice0.2240224. This is signal/runtime validation, not independent musical/listening approval or faction mix validation. Screenshot playlist.png inspected.

Initial checks exposed a real popup input-interception bug; final toast ignores input and sits above the panel. Brief source peak assertion failure was resolved by uniform gain on battle clip only. No additional native/battle regression testing is claimed.

Reproduce: use configured DeadStreetTools Python build_assets.py for Bond asset derivation; Godot --path <repo> --script res://tools/soundtrack_import_20260914/check_native.gd for native checks. A newer/different catalogue is protected from replacement by the asset builder. Native test uses an isolated settings file and deletes it afterward.

The opening/music script was previously untracked opening-chat work. This checkpoint preserves its baseline and publishes our already-applied music_playlist.patch plus new catalogue/assets/evidence; it does not take ownership of the entire original opening. Do not apply the patch twice. Opening chat includes combined live sandbox_menu_music.gd in its later source checkpoint. Existing launcher uses live source on restart. Other chats' staged/uncommitted work and shared release pack are preserved.

Publication authorized explicitly by Brandon on2026-09-15 UTC for these code/audio changes to https://github.com/LeadLasso-LL/DEADSTREET.git. This supersedes the prior automatic-review block.


## Upcoming batch format — 2026-09-15

For the owner's forthcoming17-link submission, each URL is followed by separate artist, Dead Street title and excerpt-start fields. This supersedes step2 above for that submission: use only the title field as title, normalize the artist field to OB or B-22, and extract30 seconds from its timestamp. Do not concatenate artist/timestamp into the title. Reuse catalogue/player; process in a bounded, resumable batch and integrate once. See journal20260915-soundtrack-batch-01 for execution plan. Links not yet received.
