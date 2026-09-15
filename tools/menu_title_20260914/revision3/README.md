# DEAD STREET opening preview - revision 3

Current owner-requested revision of the 57-second opening preview. Edited video only; native intro/music controls remain pending. Revision 2 was positively received; three targeted changes were requested.

## Changes and locked cues

- Added three real Harold Apartments combat shots from the Orlov Bratva attacker / Mercer Saints defender recording. Cuts at 23-25s, 33-35s and 41-43s use source in-points 12.5s, 19.4s and 30.8s, with close crops of the crossfire, a Mercer casualty and advancing Orlov units. The first visible gameplay shot remains the accepted Bridge crossfire. TRC grass approach and dismount remain in the montage. Existing four-frame crossfades retained.
- Caution fades in 7.5-8.0s, then stays fully visible at fixed scale for 1.25 seconds, through 9.25s. Zoom runs 9.25-11.5s, within the existing sequence slot.
- Fixed the zoom center. The prior crop used 70% of the available pan range, leaving the pale sign edge at the top even at maximum zoom. The new crop centers its viewing window on the black redaction itself, then finishes cleanly into black. Original sign artwork is unchanged.
- Black hold remains 11.5-13s. Pixel assembly remains 13-21s. Full title, continuous tiny hover and background fade begin exactly at 21s. Open Sandbox appears at 27s. Demo enters at 45s, Music docks by 48.75s, playlist opens at 51s; preview ends at 57s.
- Dead Street by B-22 continues uninterrupted. Accepted title, credits, hover, TRC scenes, 12%-smaller Music UI and sandbox backdrop are retained.

## Source and rebuild

Harold recording: `Dead_Street_Harold_Battle_Finish.mp4`, Library `libfile_8999c66a893c8191b89b904c99decbbd` version 1; SHA256 1b193b4062b6d299251a72071a56ca83ea70cb80c7f4db31c7c4351e3b32fba7. Actual source frame confirms Harold Apartments, Orlov Bratva attacking and Mercer Saints defending. This already available recording satisfied the request; no fresh capture was needed. Source hash and exact crop/in-points are in manifest.json. The repository copy exists at tools/battle_finish/results/Dead_Street_Harold_Battle_Finish.mp4; its file size differs slightly from the delivered copy, so use the recorded Library source for byte-identical reproduction.

All artwork/audio assets remain one directory above. Bridge and Estate source provenance is unchanged; see ../ASSET_CREDITS.md and ../revision2/README.md. Shared startup cards retain prior timings. Do not change production gameplay or overwrite the concurrent Tutorial entry in arsenal_review.gd.

Python requires Pillow/numpy; FFmpeg and ffprobe must be available. Configure equivalent DejaVu font paths on Windows.

1. `python sandbox_smaller.py` (or reuse the unchanged revision2/sandbox_smaller.mkv).
2. `python compose_revision3.py` for full rebuild. Phases warning/title/action/main/export are individually available. `action-recut` rebuilds only changed shots 1, 5 and 9, reusing the other validated shots.
3. `python verify_revision3.py`.

The original title motion and sandbox sequence were reused without changes in this render. Intermediate files use exact decoded frame counts and atomic replacement. Validation includes the entire full-black hold, the last zoom frames/top border and the full-brightness stationary sign hold, plus existing exact title/button cues, shot identities and audio continuity.

## Status

Final export validation PASS: 1710 decoded frames / 57.000s; title complete at frame 630 (21s), button at frame 810 (27s), all eleven source shots and continuous audio verified. All 45 full-black hold frames are exactly black (maximum decoded pixel 0); the final zoom frames are also exactly black. Thirty-eight stationary full-brightness caution frames checked, mean pixel difference below 0.10. Final exported caution/Harold contact sheet visually reviewed. Owner review of revision 3 remains pending. No native UI/player changes, commit or push. Next: owner reviews this revised preview, then follow feedback before native integration.

Saved preview: Library libfile_bd207446ea3c81919a3d39bce90ae156 version 2. SHA256 27dfdb1cb7e9066a7dfeca409cedd9180aeee003cc7f3db29bd0a8b5d9186132; 9625058 bytes. Earlier versions retained. See verification.json and library_receipt.json.
