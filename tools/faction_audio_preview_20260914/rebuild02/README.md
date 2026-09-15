# DEAD STREET — Dark rebuild 02

Status: NEW PREVIEWS, OWNER LISTENING REVIEW PENDING. All audition01 music is OWNER-REJECTED for happy/upbeat/fun energy. Preserve it as rejected reference; do not install it.

Brandon ordered all 18 remade fundamentally with dark energy, bad vibes and hard music, approximately 20% slower each. compose_dark.py contains new scores throughout. engine.py reuses rendering/mastering infrastructure only. No rejected audio is slowed/remixed into these tracks. Exact tempos are 0.8x original BPM; full coverage and changed-score checks are in rebuild_checks.json.

Changes: replaced walking/funk bass and bright melodic flourishes with new low riffs, pedal-centered sub/amp bass, half-time low cracked drums, unresolved semitone/tritone pressure and space. Added synthesized 808, kick, snare, struck-metal, detuned bass and pressure layers. Faction-specific sampled instruments remain where useful, reshaped into dark arrangements. This is still synthesized/sampled-instrument music, not live-band recordings or a music-generation-service output. No vocals, no game integration, no existing five audio-identity edits.

Run Python 3.12 + numpy/scipy/tinysoundfont 0.3.7: python compose_dark.py; then python package_review.py. Use the verified GeneralUser bank and license in ../dependencies; same hash/dependency provenance as audition01. Packaging uses PIL, FFmpeg and Linux DejaVu fonts. Source on Windows, rendering in scratch Linux. All outputs stay under this directory. Shared game/index/tutorial/title work is not touched.

manifest.json preserves scores and output hashes; review_index.json has reel offsets; validation.json has complete export/loudness/peak checks; delivery_receipt.json identifies saved listening files. No independent auditory judgment or owner acceptance can be inferred from machine checks. Native game tests/loop seams/spatial mix are not applicable: previews only. HTML browser interaction remains untested.

Next: owner hears all 18 rebuilt tracks and gives named feedback. If approved, later prepare loops and game bindings. The previous source-publication automatic-review rejection remains unresolved; do not run ../publish_source.py. No commit/push attempted in this remake. Preserve all staged/uncommitted concurrent work.

Export recovery: two incomplete WAVs and one MP3 hash mismatch were found before delivery; three scores rerendered and all 18 lengths/hashes rechecked. Root cause unestablished. Engine hardened with private encode staging and flushed atomic final-file publication. No failed files delivered.
