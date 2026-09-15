# Glock, Keys and Ripper soundtrack import

Implemented and validated on 2026-09-15. Extends the published Bond and 17-track import workflow.

| Artist | Dead Street title | Source slug | Battle excerpt |
| --- | --- | --- | --- |
| B-22 | Glock | glockk-draco | 00:30–01:00 |
| B-22 | Keys | keys | 00:31–01:01 |
| B-22 | Ripper | ripper | 00:48–01:18 |

The three unchanged full MP3s are registered in the menu catalogue; three separate WAVs are available through the existing battle-stream loader. Total: 22 menu tracks and 21 battle loops. Existing 19 entries and faction mapping preserved exactly. No faction associations supplied; faction assignment remains pending.

Each excerpt retains its requested start and exact 30-second period: 1,323,000 stereo frames at 44.1 kHz, PCM16. A final 80 ms raised-cosine blend into source preroll conditions the repeating boundary. Peak attenuation provides 1 dB sample headroom. Menu files are not transcoded.

Validation:
- All three source MP3s and resulting WAVs fully decode.
- Exact frame count, requested starts, source/destination hashes and loop seam checks pass.
- 25 focused native Godot checks pass: title/artist/timing, stream loading, enabled playlist rows, Next playback, actual end advance, scrolling and one native wrap per new loop.
- Four integrity checks pass: existing entries, faction mapping, music consumers and unique track count.
- No runtime code or account/track permissions changed.
- Numeric seam checks and native wrap tests do not constitute subjective listening approval.

Evidence: manifest.json, download_report.json, audio_validation.json, native_validation.json, integrity_validation.json and source_hashes.json. Reusable acquisition/processing source: fetch_batch.mjs, build_batch.py; focused native check: check_native.gd.

Publication scope: six new audio assets, shared catalogue, this batch's source/evidence and owned shared-record sections only. Preserve concurrent portrait/arsenal, BUILD and opening work. Reopen the normal live-source sandbox to load the updated playlist. Publication status is recorded in the hive mind and publication_receipt.json when verified.
