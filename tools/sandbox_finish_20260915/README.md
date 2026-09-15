# Portrait and Arsenal continuation — completed 2026-09-15

Owner requested completion after the previous conversation exhausted context. Implemented in the live-source sandbox; owner appearance acceptance and economy playtesting remain separate.

- Recovered the exact approved 20-leader gallery, bound complete-frame 288x359 photo derivatives to the upper-right faction header. Manifest records source/output SHA256 and source gallery Library identity/version. Conditional merger leaders remain undisclosed.
- Installed 691 fixed 90x80 standing portraits: 23 factions x30 weapons plus Mercer dual-Glock specialist. All 691 reviewed visually on 23 fixed-scale boards in `review/`. No remaining obvious detached shoulders/limbs or noticeable anatomy fault observed in these standing cards. This is not a claim about every animation/facing. Unit atlases were not rebuilt.
- Recovered source finishing adapter joins shoulder roots and whole elbow-to-hand forearms while preserving body/torso/lower-body/muzzle signatures across 1,382 SW/SE structural checks. Most earlier files were only candidates. Tight 64x50 Mercer/Orlov base crops caused enlarged UI figures; all card canvases now share scale. Specialist baseline differs from stale installed art and was reviewed separately (`review/specialist_before_after.png`).
- All 75 vehicles sort ascending purchase price within each existing category; equal prices sort by name. No vehicle price/stat changes.
- All 30 firearms have canonical game prices and identical Arsenal quotes; combat data is unchanged. See `docs/WEAPON_PRICING.md`.
- Editable display-art pass improves first pistol frame/trigger guard, pistols/SMGs and restrained long-gun material detail. Normal icon generation imports `weapon_display_art.py`; all 30 SVG sources and PNG icons refreshed. This changes close-up illustrations, not unit animation weapons/rigs.

## Validation and evidence

Official Windows Godot 4.7.2, native D3D12: **6,178 checks, zero failures** (`smoke.json`, `native.log`). Tested 23 faction pages/115 visible paired cards, all 20 photo bindings, all 30 prices/spec panels, all 75 vehicle entries/order, all 691 imported portrait textures, desktop navigation at 1152x860, 1280x720 and 1440x1000, fleet/tutorial/setup preservation, and one launch/return without battle simulation. Native screenshots are saved alongside this report. All five gun boards were visually reviewed. Gun detail strokes outside a wood stock and small stray pistol highlights were corrected before final rendering.

Raw PNG comparison applies Godot's configured `fix_alpha_edges()` before byte comparison, exactly matching lossless texture import processing. All 741 affected texture imports refreshed. Warnings from diagnostic `Image.load_from_file` are expected in this development-only harness; production uses imported textures.

Initial harness failed because global input injection mismatched Windows coordinates; corrected to viewport-local `root.push_input(e,true)`. Second attempt flagged transparent-edge RGB processing and an unsupported 390px Windows window request. Corrected import-parity comparison and tested the three actual supported desktop sizes. Failed logs retained as `native_attempt1.log` / `native_attempt2.log`; do not mistake them for final results. No production input workaround or phone-support claim.

## Reproduction and handoff

Native check: Godot `--path <repo> --script res://tools/sandbox_finish_20260915/check_native.gd -- --fast`.

`tools/portrait_audit_20260914/run_build.py` plus worker/anatomy/render sources regenerate standing candidates and structural evidence. It generates candidates, not installed outputs. For future source changes regenerate from the then-current portrait inventory, review fixed-scale SW/SE candidates, then explicitly install each candidate at the inventory portrait path. Keep 90x80 crops and the anatomy adapter; do not overwrite corrected cards with tight or uncorrected atlas crops. The takeover installer is deliberately single-use and guards original hashes; do not rerun it on updated content.

`finish_assets.py` renders icons and refreshes isolated texture imports; it does not generate source SVGs. For display-art regeneration call `weapon_art.make(model, build_art.ORIGINAL)`, `make_display_icon(model, art)`, then `build_art.save_svg` into `assets/art/weapons/arsenal/source/<id>.svg`; normal full `build_art.py` also uses the module. Do not rebuild all unit atlases for an icon edit. Catalog regeneration retains prices via `weapon_pricing.py`.

`installed.json` contains before/after hashes and all affected asset paths. `before/` retains prior files locally. Publication scope explicitly excludes transfer payloads, caches and unrelated music/opening/BUILD work. Reopen the normal Dead Street Sandbox desktop launcher to load changes. Publication result is recorded separately; native completion does not imply owner acceptance.
