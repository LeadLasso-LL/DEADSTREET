# Sandbox emblems, precision guns and music controls — 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED. Reopen the normal live-source Dead Street Sandbox launcher. Owner visual acceptance remains separate.

## Completed behavior

- All 23 faction seals render without the white square canvas in both faction glossary (list/header) and Battle Setup badges, including changing either faction. Shared menu-only circle mask uses each source image's measured center/radius. Original PNGs and white interior artwork remain intact; battle emblems are unchanged.
- AK-47 and six sniper close-ups redrawn as distinct SVG illustrations: walnut/curved-magazine AK, traditional Remington stock/bolt, full-wood SKS, SVD thumbhole/vented handguard, olive SSG69, AWM chassis/brake/bipod, adjustable PSG1 stock/wood grip. Scopes have slim tubes, optical bells and lower individual mounts. `weapon_precision_art.py` is called by normal display generation. Seven SVG/PNG icons changed; combat stats, prices, unit rig/animation weapons remain intact.
- Song toast is 158x56 logical units versus the existing 123x36 Music dock. Two compact title/artist lines; long text ellipsizes. It appears above the dock, stays above an open music panel and fades toward the dock after the existing duration. Dock remains clickable while toast is visible.
- Crossed-arrow Shuffle button rebuilds a permutation of enabled tracks and immediately plays the first entry. With two or more enabled tracks it cannot start with the current song. Explicit shuffle resumes from pause. Unchecked songs stay out; zero enabled disables the button; one enabled song restarts explicitly. Natural finish and Next follow the new order. Volume and inclusion preferences are preserved.

## Native verification

Official Windows Godot4.7.2/D3D12, GTX1650: **249 checks, zero failures**, `native_validation.json` and `native.log`. Actual HUD clicks exercised eight 22-song reshuffles, uniqueness/full queue coverage, immediate playback, pause/resume, exclusions, zero/one-song cases, actual file-end advancement, Next, hidden-menu pause and three desktop sizes. User music preferences were isolated in a temporary test settings file and left intact.

All 23 emblems have four background-matching corners; masked and unmasked inner pixels match exactly. Both selector sides and every glossary faction bind the shared shader. Final screenshots of all23 emblems, actual faction pages, AK/six sniper panels and compact/open music views visually inspected. First pixel test used logical positions directly against physical screenshot pixels and failed64 checks; corrected the test's viewport conversion and grid sizing. No shader workaround was needed. First import wrapper read a PowerShell UTF16 log as UTF8; fixed BOM decoding. Failed evidence retained.

Seven icon imports refreshed using an isolated temporary project. All other734 assets from the preceding portrait/photo/icon pass match their recorded hashes. No full battle simulation or new economy balance pass was needed for these display/menu changes.

## Source ownership and reproduction

`sandbox_emblem.gd`/`.gdshader` and `assets/data/sandbox_emblem_masks.json` own menu masking. Consumers are `sandbox_glossary_panel.gd` and `sandbox_force_builder.gd`. The original assets were not edited.

Precision art: `tools/arsenal_production/weapon_precision_art.py`, integrated by `weapon_display_art.py`. Regenerate requested SVGs with the normal build_art.make / make_display_icon / save_svg calls, run render_icons.gd, then this folder's finish_assets.py. Do not rebuild unit atlases for icon changes. `install.py` is a guarded single-use takeover script and must not be rerun over newer work.

Native check: Godot `--path <repo> --script res://tools/menu_polish_20260915/check_native.gd`. Backup sources are excluded from editor import.

The live `gameplay/sandbox_menu_music.gd` belongs to the original, still-untracked opening/menu source. This task applied its narrow change there, preserving the existing player. `applied_music_delta.patch` plus baseline/validated hashes record the exact already-applied delta for that owner; do not apply it twice or stage unrelated opening sources. A checkpoint includes the delta rather than silently publishing the entire inherited source. All full music tracks, faction mappings, Harold changes and group ranges stay in their respective scopes.

The preceding approved portrait/Arsenal checkpoint is pushed and verified at dc0450543801f3b4046f39cb1f762abf0bd79e15. This pass's Git result is separately recorded in publication_receipt.json.
