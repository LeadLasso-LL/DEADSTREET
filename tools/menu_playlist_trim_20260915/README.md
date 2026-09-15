# Menu playlist exclusions — 2026-09-15

Owner requested removal of Switch, Ripper, Dead or Alive and Lurk from the sandbox menu only. IMPLEMENTED / VALIDATED. The menu now loads MusicCatalog.menu_tracks(), which excludes the four IDs from the existing complete catalogue. This removes their checkboxes and queue eligibility even with old saved enable flags. All other menu preferences and controls retain their behavior.

All 22 original track records and every faction mapping are identical to baseline; all 43 referenced audio assets have identical SHA256 hashes. Faction battle loops and glossary snippets retain these four songs. No mix, siren, filter, volume or other audio behavior changed.

Official Godot 4.7.2 headless menu load PASS: 18 rows, three queue refills exclude the four, old enabled settings cannot reintroduce them, original menu and battle streams remain loadable, Dead Street signature preserved. Native process exit 0/no errors. Evidence: native_validation.json, native.log, manifest.json. Reproduce with Godot --path <repo> --script res://tools/menu_playlist_trim_20260915/check_menu.gd. Fixture uses and deletes its own temporary settings file.

Inherited untracked gameplay/sandbox_menu_music.gd is preserved with only its track-list call changed. Its already-applied one-line delta is saved in applied_menu_delta.patch; do not reapply it to live source. Before copies are preserved and excluded from Godot import. Publication stages the two tracked catalogue files, this task's evidence and only owned documentation blocks. Actual result is in publication_receipt.json. Reopen normal Sandbox. No further implementation remains.
