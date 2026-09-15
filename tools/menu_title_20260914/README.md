> CURRENT PREVIEW: revision3/README.md (20260914-opening-preview-10). Three Harold Mercer/Orlov combat cuts added; caution full hold8-9.25s before zoom; clean black11.5-13s. Title/background21s and button27s preserved. Validated 57s preview saved as libfile_bd207446ea3c81919a3d39bce90ae156 v2. Older revision notes below are historical.

> CURRENT PREVIEW: revision2/README.md (20260914-opening-preview-08). The validated 57-second revision supersedes the timing/montage/Music sizing below: title complete and first firefight fade at 21s, Open Sandbox at 27s, Music 12% smaller. Signature persists. Saved preview libfile_bd207446ea3c81919a3d39bce90ae156 v1. Native implementation remains pending. The remaining sections describe historical revision 1.

# DEAD STREET opening and Music handoff preview

Owner/chat: 3438f1ea0e55. This is an MP4 design preview, not installed native UI.

## Latest owner direction

- Use the exact accepted DEAD STREET title, with restrained hover/static over actual subdued monochrome helicopter-style battle footage.
- 0-3s: A GAME DEVELOPED BY + supplied white Gloria Systems symbol/wordmark on black.
- 3-4s: transition through black; 4-7s: POWERED BY + official white Godot logo/name.
- 7-8s: transition; 8-11s: worn pixel-art CAUTION: YOU ARE NOW ENTERING sign, fully black redaction in place of DEAD STREET, five bullet holes outside the redaction.
- 11-12s: accelerating zoom into the black redaction, full black at 11.5, then pull back into the main screen; settled at 12.000.
- Open Sandbox first appears at 17.000, five seconds after the main screen. This supersedes 27 seconds.
- Signature track is titled Dead Street by B-22. It starts with credits and persists through sandbox entry without restart or immediate shuffle. This supersedes immediate random selection upon entry.
- Upon entry, now-playing card appears bottom right, then drops/contracts into Music. Music opens current track/playlist in shuffle order with current track and inclusion checkboxes. Only one real track is supplied so far; no invented playlist entries.
- Original next/playlist keyboard controls remain a requirement. One enabled track cannot provide a distinct next selection. Once other tracks exist, avoid immediate signature repetition after it ends/is skipped; signature remains in the catalogue. Retain per-track exclusions and actual queue order.

## Preview-specific editorial choices

48 seconds, 1280x720, 30fps H.264/AAC. Sandbox demonstration enters at 36s, card settles into Music at 39.75s, playlist opens at 42s. Entry time is only for this recording; the real button will allow entry any time from 17s.

Sandbox background is a still from the real existing native sandbox UI recording, kept at its native aspect ratio. The animated Music overlay is a concept, not evidence of working native playlist controls. Only startup/main visuals are monochrome; sandbox retains normal colors.

No gameplay source, native menu, audio controller, main scene or production sandbox UI has been changed. Existing concurrent BUILD work remains owned by its chat. No commit/push performed for this scope.

## Rebuild

Requires Python with Pillow, numpy, lxml and cairosvg; FFmpeg/ffprobe; DejaVu Sans and Mono fonts. On Windows provide equivalent font paths and make FFmpeg available on PATH. The source script supports original repository-relative Bridge/Estate paths; local_source_paths.json is a scratch-only marker selecting the current mounted recordings. sandbox_handoff.py has a local source path for this render; substitute the durable source recording below when reproducing elsewhere.

1. `python compose_opening.py --shots-only` to rebuild the 60-second montage. Intermediate shots must use Matroska. The old concurrent MP4 assembly lost a moov atom and silently froze one shot; strict -xerror and sequential MKV generation solved it.
2. `python compose_opening.py --compose-only` makes the 60-second main-menu video.
3. `python sandbox_handoff.py` builds the 12-second Music concept.
4. `python startup_sequence.py` joins the 12-second startup, first 24 seconds of main menu and 12-second sandbox handoff with one continuous audio stream.
5. `python verify_preview.py` checks decode, scene identities, exact cue frames, grayscale and audio continuity. Every startup clip and concat input is also checked for its exact decoded frame count before export. A truncated overwritten warning clip was caught and replaced with startup_warning_v2.mkv. The final Music preview uses only the validated replacement.

The original fractional montage time base made the first button cue one frame early. Normalize fps and timestamps before the button overlay; the corrected button cue is frame 510 (17.000s).

The 60-second montage remains available for the future looping menu; this review uses its first four shots before entering the sandbox.

## Durable source recordings

- Current accepted estate: repository tools/whittaker_estate/Dead_Street_Whittaker_Estate_Mobile.mp4; SHA256 64a8b2cc27cd13bdb7b71b9cb17b9efba9404bdf16bf05dc9e7808b373d21210. Earlier same-named recordings are rejected/superseded.
- Bridge: repository tools/raiders_recording/Dead_Street_Raiders_Victory_Mobile.mp4; SHA256 a6a719bb2ab888bea55b31eadc860c398a8b14617400b3db378f3f5fe7469d93.
- Sandbox UI: libfile_ac845622e400819196eb825c79e08955, version 0, Dead_Street_Bridge_5v5_Sandbox_UI_Review.mp4; SHA256 81bdc071ae77d66455317d2634a8603b6338f2e38ff31a68668924bcfbcffdc5.
- Supplied Gloria HTML: libfile_8ba5ca1193c48191926088cef9111e7d. First inline SVG preserved as gloria_logo_original.svg.

See edit_manifest.json, timeline.json, verification.json and ASSET_CREDITS.md for source hashes, exact timings and validation evidence. Next: owner reviews this video, then native opening/music integration follows the accepted design and persistent-track behavior.
