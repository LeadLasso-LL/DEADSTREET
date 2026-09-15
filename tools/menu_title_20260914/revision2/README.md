# DEAD STREET opening preview — revision 2

Owner-directed revision of the delivered 48-second preview. Scope is an edited MP4 design review; no native menu, gameplay or music-controller integration.

## Current sequence

- Gloria Systems: existing white supplied logo/wordmark card, 0–3 seconds.
- Godot: existing official white logo card, 4–7 seconds. Existing one-second transitions retained.
- Caution sign: becomes visible at 7.5 seconds and immediately begins a gradual camera push into its fully black redaction; reaches black by 11.5 seconds. Existing bullet-hole sign artwork unchanged.
- Black hold: 11.5–13 seconds.
- Title assembly: original accepted title pixels gather in small fragments from 13–21 seconds. The final pieces finish exactly at 21.000, then the title begins continuous suspended hover: two combined sine motions, maximum ±3 output pixels, main period 1.35 seconds and secondary period 0.43 seconds. This replaces the prior 8.6-second drift.
- Background: fades in from 21.000–21.600 behind the complete title. FIRST SHOT IS AN ACTIVE BRIDGE FIREFIGHT, from source 34.5 seconds. Eleven actual gameplay shots alternate close crossfire, casualties, TRC convoy crossing grass, troops dismounting and advances. Most last two seconds; convoy/dismount last three. Transitions cross-dissolve over four frames (~0.133s).
- Open Sandbox: first visible at 27.000. Supersedes the prior 17-second cue.
- Demo entry: 45 seconds; now-playing contracts into Music by 48.75; playlist opens at 51. The real future button can be used any time from 27.
- Music: Dead Street by B-22 remains continuous and unshifted across all phases, including sandbox entry. Music popup/dock/panel are 12% smaller than revision 1. One supplied track; no invented catalogue tracks.

## Source and implementation

The title PNG, supplied Gloria SVG, Godot artwork and bullet-hole sign are unchanged. All new motion is video compositing. Original Bridge and accepted Estate recordings are reused; exact cuts, crop rectangles and hashes are in manifest.json. The sandbox background remains a still from actual native UI; Music controls are a designed video overlay, not working runtime controls.

Shared assets are one directory above: approved_title.png, warning_sign_bullet_holes.png, credit_gloria.png, credit_godot.png, camera_ui.png, button_ui.png, and B-22_Dead_Street.mp3. See ../ASSET_CREDITS.md. The original title hash remains a7ad354ff6bb1e8182b88ad22a08fcc2c8452d9891a3e26d7afa0fb269d199a9.

Rebuild with Python (Pillow/numpy), FFmpeg/ffprobe and DejaVu Sans/Mono. Windows needs FFmpeg/font paths configured. The script uses mounted source recordings locally and repository-relative tools/whittaker_estate / tools/raiders_recording paths otherwise. The sandbox source recording is libfile_ac845622e400819196eb825c79e08955 v0; place it under tools/sandbox_ui_review_20260914 if unavailable locally.

1. python sandbox_smaller.py
2. python compose_revision2.py
3. python verify_revision2.py

Render phases warning/title/action/main/export can be run separately. Intermediate clips use Matroska, exact decoded frame counts and atomic replacement to catch incomplete files before muxing. No discarded revision-1 truncated inputs are reused.

## Review status

Final export validation PASS: 1710 decoded frames, 57.000 seconds, 1280x720 at 30 fps, H.264/AAC. Full audio/video decode passed. Exact completion at frame 630 (21.000s), button at frame 810 (27.000s), black hold, hover offsets, all eleven source cuts and uninterrupted source music across the handoff verified. Visual review passed for the final title reveal, first firefight and smaller Music layout. Owner review of this revision remains pending. Source art acceptance remains separate from acceptance of this revised motion. No production source changes or commit/push. Existing BUILD/character work remains outside this scope. Next: review the revised MP4; native opening and persistent playlist controller remain pending.

Delivered as Dead_Street_Opening_Preview.mp4, 10,376,426 bytes; SHA256 f78e031422f5effad363f083fbae987c3e648cd2dd2f97c269a457ca9b2ac7ba. Library libfile_bd207446ea3c81919a3d39bce90ae156, version 1 (revision 1 preserved as version 0). See library_receipt.json and verification.json.
