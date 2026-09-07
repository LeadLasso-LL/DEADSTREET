# Dead Street character-pipeline sources

M7F MPFB `look_calib_01` is a superseded experiment (technical PASS, product-visual REJECTED).
The MPFB builder and calibration stills have been retired from the active path.

Do not commit huge download caches.

## Retained animation source

- Quaternius Universal Animation Library **CC0**
  - Keep: `tools/character_pipeline/source/gltf-universal-animation-library-main/`
  - Useful as an animation / retarget source for a future accepted rig
  - Do **not** use the UAL mannequin body as final Dead Street character art

## Retained generic render tooling

- `tools/character_pipeline/render_tactical_sprites.py`
  - Offline Blender directional RGBA renderer for a rigged GLTF
  - Source-agnostic enough for a future Human Generator or other rigged export
  - Default GLTF currently points at UAL (pipeline proof only)

## Retired (do not restore as current character art)

- MPFB 2 `look_calib_01` body / MHCLO clothes / balaclava / constructed AR
- `build_look_calibration.py`
- `assets/tactical/units/local_street_gang/look_calib_01/`
- Local MPFB pack zips and `look_calib_01.blend`

MPFB is not permanently forbidden as a technology. This specific result did not reach the product target.

## Current source experiment (not in this repo)

- Blender + Human Generator
- Installation / first-character vertical slice
- Acceptance not yet earned

## What should stay ignored / local

- `tools/character_pipeline/source/mpfb_packs/*.zip` if leftover locally
- `tools/character_pipeline/look_calib_01.blend` if leftover locally
- `tools/character_pipeline/calib/` preview stills
- Nested duplicate UAL extracts, installer zips, unused GLBs
