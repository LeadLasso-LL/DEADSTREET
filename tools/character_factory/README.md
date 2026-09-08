# Dead Street Character Factory

Automated DAZ Studio / Genesis 9 handshake, free Starter Essentials smoke, and paid-asset street-gang rifleman visual proof.

This is a **capability pipeline**, not accepted Dead Street character art.

- Tactical runtime stays 2D.
- 3D source stays offline.
- Generated PNGs are **not** runtime-authoritative and must **not** be bound into `TacticalUnitAnimationCatalog`.
- Camera / lighting profiles are **PROVISIONAL** and **not canon**.
- Post-process style profiles are **NON-CANON** comparison treatments. None are accepted.
- Procedural soldier fallback remains the live unit baseline.
- No Blender dependency for this factory.
- DAZ assets are never sent to an image-generation model.

## Run (unattended)

From the repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode handshake
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode smoke
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode proof
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode calibrate
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode silhouette
```

DAZ may open visibly. Do not click it. The factory script must close DAZ itself.

Outputs are written to:

`%LOCALAPPDATA%\DeadStreetCharacterFactory\runs\<run-id>\`

Never copy DAZ proprietary DUF/DSF/textures into this repository.
Never copy generated PNGs into `assets/` or bind them at runtime.

## Provisional continuation baseline (NOT canon, NOT accepted)

`provisional_baseline.json` is the machine-readable lock for the next style-conversion pass:

- Camera: `PROVISIONAL_TACTICAL_56` / `elevation_deg` 56.0
- Pose: `HYBRID_B`
- Character/assets: same as `local_street_gang_rifleman_proof_01`

V1.1 (`recipes/local_street_gang_rifleman_calib_v11.json`) and V1.2 (`recipes/local_street_gang_rifleman_silhouette_v12.json`) stay as calibration history. Alternate cameras and hybrids are not deleted. Nothing is bound into `TacticalUnitAnimationCatalog`. Do not copy these numbers into `TacticalUnitPipelineSpec`.

## Proof recipe

`recipes/local_street_gang_rifleman_proof_01.json`

- Character: Matt for Genesis 9 (already-installed free masculine source)
- Clothing: dForce Classic Tank Top Outfit (tank + trousers)
- Footwear: Worker Uniform Boots (tank-top product includes no footwear)
- Weapon: Multi-Caliber Weapon System Genesis 9 masculine carbine RH smart prop
- Hair: Mavick Hair (already installed; not the paid fade)

## Camera caveat

Iray on the installed DAZ Studio 6 General Release produced empty/transparent frames with a true `ORTHO_CAMERA`. Smoke and this proof use a framed 160mm elevated perspective camera. That is a technical stand-in, not Dead Street camera canon.
