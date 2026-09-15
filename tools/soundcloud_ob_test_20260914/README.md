# OB SoundCloud extraction test — 2026-09-14

Status: extraction and file integrity VALIDATED; runtime integration not performed.

Source: https://soundcloud.com/colinobriennn/bond (owner-supplied short URL in manifest.json).
Title: Bond. Artist: OB. Track ID:408242721. No custom title supplied.

OB_Bond.mp3 is the unchanged full progressive playback MP3 supplied by the public page. Download-button setting is false; no account or permission settings were changed. No owner action is needed for this demonstrated retrieval method.

Reproduction: node inspect.mjs; node extract.mjs; configured DeadStreetTools Python validate.py. Requires normal network access, Node24 and imageio_ffmpeg. The validator decodes the entire MP3 with FFmpeg -xerror -err_detect explode, checks duration against source within0.15s and verifies file size/hash. Validation.json: all four checks PASS,139.598367s decoded versus139.662s source,2234408bytes, SHA256 b2e7a8f318a5c64083ad1ff3b9723b42f987638ba12c633b165e0b930f783634.

page.html is transient local response evidence containing expiring playback information; do not publish it. Inspection/manifest omit playback URLs/tokens. No independent listening or Godot playback test was performed. No playlist entry, shared-catalogue schema, faction assignment or runtime edit was made. Candidate and evidence are retained for future integration; do not duplicate or re-encode unnecessarily. Current state is uncommitted; other work preserved. See journal20260914-soundcloud-ob-test-01 for constraints and continuation.
