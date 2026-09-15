# Soundtrack batch — 15 September 2026

IMPLEMENTED / FILE-VALIDATED / NATIVE-VALIDATED. All17 supplied tracks imported;5 OB and12 B-22. Display titles and timestamps follow owner metadata, including exact curly punctuation. Source titles and artists remain separate provenance. The shared catalogue now has19 menu songs and18 battle loops; existing Dead Street/B-22 and Bond/OB retained.

| Artist | Dead Street title | Battle excerpt |
|---|---|---|
| OB | Coupe | 00:44–01:14 |
| OB | Thunder | 00:15–00:45 |
| OB | Smoke | 00:30–01:00 |
| OB | Block | 00:14–00:44 |
| OB | Maria | 00:29–00:59 |
| B-22 | Natural | 00:32–01:02 |
| B-22 | ‘88 | 00:27–00:57 |
| B-22 | Burn | 00:24–00:54 |
| B-22 | Money Way | 00:11–00:41 |
| B-22 | Watchin’ | 00:49–01:19 |
| B-22 | Dead or Alive | 00:45–01:15 |
| B-22 | Jumpman | 00:41–01:11 |
| B-22 | Switch | 00:00–00:30 |
| B-22 | Skyfall | 00:00–00:30 |
| B-22 | Lurk | 00:35–01:05 |
| B-22 | ’97 | 00:38–01:08 |
| B-22 | Break Bad | 00:32–01:02 |

## Processing

Full progressive playback was retrieved through the existing public page-provided playback method with3 concurrent workers; no account/permission changes. Public playback-client discovery was reused in-process. Each complete MP3 was saved with source ID/title/artist, duration, byte count and hash; no full-song re-encoding. Each file fully decoded for integrity and excerpt generation, using2 processing workers. Completed downloads remain reusable by hash; no credentials, page HTML or transient playback URLs are included in deliverables.

All excerpts contain exactly1323000 stereo frames at44100Hz (30.000s),16-bit PCM WAV. The starting sample and requested30-second period are preserved. A smooth80ms tail blend joins to the80ms of source preceding the chosen start. Switch and Skyfall begin at zero: their seam uses odd reflection of the first80ms around the first sample (2*x[0]-x[k:0:-1]) instead of reading before the file. This preserves the zero-second start and matches the normal initial sample slope across the loop. No silent gap or tempo change was inserted. Uniform gain is reduced only when necessary to keep excerpt peaks at/below-1dBFS; full MP3s remain unchanged. Timing, gain, source hash, output hash and seam measurements are in audio_validation.json.

All17 full-source decodes, source-duration comparisons (<0.25s), exact excerpt bounds/frame counts, unchanged source hashes, gain/headroom, normal-sample boundary comparisons and full WAV decodes PASS. Native loop loading uses the existing stereo frame-count convention in gameplay/music_catalog.gd. Faction assignments remain empty; these are available battle-loop assets, not a claim that spatial faction playback has been bound.

## Runtime validation

Live Godot4.7.2:93 checks PASS, zero failures/errors. One full19-song shuffle round without repeats; queue matches selected songs; actual file-end advancement; source/title/artist/timestamp checks for17 imports; full native MP3 streams; scrolling to the last item; actual checkbox and persistence; Pause/Next with now-playing overlay; battle/menu pause-resume; scaled panel bounds and outside dismissal. All18 battle loops (Bond plus17) crossed a real native loop boundary while staying playing and emitting no finished signal. Screenshot playlist_bottom.png visually inspected.

Opening test uses a seek near27s to exercise gate/title/menu and same-player continuity; it is not a full cinematic timing revalidation. Earlier Bond36 checks cover precise seek-assisted21/27 cues. No battle regression, faction association, spatial mix, independent listening verdict or artistic loop-seam approval is claimed. Runtime/menu sources were unchanged in this batch; source_hashes.json identifies validated consumers.

## Reproduction and continuation

manifest.json is the exact owner mapping; fetch_batch.mjs resumes valid downloads by hash (3 workers). build_batch.py creates and validates assets (2 workers), then merges all17 into the current catalogue only after success. Reruns verify existing IDs/metadata and never overwrite a differing menu file; check catalogue snapshots before invoking after new edits. Native: Godot --path <repo> --script res://tools/soundtrack_batch_20260915/check_native.gd. Isolated test settings are deleted afterward. One batch owns this folder/catalogue merge; preserve unrelated work and original opening-source ownership.

Next: owner can reopen the normal live-source sandbox to use all19 tracks; explicit faction-to-track assignments remain open. Scoped publication includes34 new audio assets, catalogue, batch source/metadata/evidence and owned records. No other UI/audio source changes or generated faction compositions.
