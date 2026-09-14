# Pistol card anatomy correction — 2026-09-14

Status: implemented and validated; product-owner visual acceptance remains separate.

## Scope and result
- 138 regular portraits: 23 canonical factions × Glock 17, M1911, USP, CZ75, Desert Eagle and Five-SeveN.
- All 276 SW/SE standing views visually inspected, enlarged at one fixed scale; all 138 actual SW card crops also inspected at native size.
- Mercer dual-pistol specialist inspected in both angles; complete arms, unchanged asset.
- Re-expose the existing far elbow-to-hand segment over the torso. SW is the established mirror of SE; handedness policy is preserved.
- Join legacy Mercer hoodie and Orlov tee shoulder caps using the existing continuous garment contour, respecting short/long sleeves.
- Shoulder/elbow/wrist positions, torso/head/lower body, weapon geometry and hand group are unchanged. Other outfit shoulder adapters are unchanged.
- 10,987 changed pixels across the portraits. Every pixel outside the correction is preserved. Original dimensions/crops/palette are preserved.
- No battle, HUD layout, audio, world animation atlas, or shared animation-generator source change.

## Evidence
validation.json records each portrait, exact source/candidate hashes, changed-pixel count and bounds. All 138 baseline renders matched installed portraits pixel-for-pixel before correction. The worker also checks torso/lower signatures, muzzle anchor and exact weapon/hand SVG group equality in both views.
review/all_models_0.png through _5.png cover every regular model in both directions plus actual native-size candidates. candidate_sample.png is the six-outfit before/after comparison.
native_card_checks.json: 139 catalog bindings, paths, textures and visible-pixel comparisons; 556 checks, zero failures. Transparent RGB padding is excluded from visual equality.
protected_hashes.json: all 415 protected world atlases, gameplay/generator sources and inherited dirty files matched after installation. This is a checkpoint inventory, not a claim to cover every repository file.
before_portraits.zip is the immutable source-art baseline for this narrow repair.

## Reproduce
Use the project Python with Pillow/NumPy and the recorded Godot 4.7.2 editor executable:
1. Run python tools/pistol_portrait_20260914/build_portraits.py.
2. Review the generated sheets; run python tools/pistol_portrait_20260914/install.py.
3. In the existing Windows checkout run python tools/pistol_portrait_20260914/refresh_imports.py to refresh only the 12 imported legacy portraits and run the native catalog check. A clean editor import also rebuilds these textures from the committed PNGs.
The builder renders only standing card poses, in isolated per-faction Python processes. Its in-process source adapter is intentionally portrait-only; normal animation generation remains untouched.
The installer requires matching reviewed candidate hashes and an unchanged original or already-corrected target. --require-protected additionally enforces the original local protected-file inventory. Do not use that checkpoint-specific option on another checkout with different unrelated work.
Future full atlas production must rerun this card finishing pass after cropping portraits. Do not overwrite approved cards with the older uncorrected atlas crop. A future outfit/model change that invalidates baseline equality requires a new scoped baseline and visual review.

## Failures and limits
The initial worker import path and SVG namespace setup errors were fixed before asset installation. The first texture probe compared invisible RGB padding, then was tightened to compare visible pixels and alpha; it identified 12 genuinely stale legacy imports. They were refreshed in an isolated native project, without modifying runtime loaders or unrelated import caches. One remote launch timed out before starting; process/log inspection confirmed no running refresh, and the retry completed in 4.50 seconds.
This pass validates static pistol card artwork, not all animation stances or the whole-project regression suite. No new battle recording was required.
