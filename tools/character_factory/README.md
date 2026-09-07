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
```

DAZ may open visibly. Do not click it. The factory script must close DAZ itself.

Outputs are written to:

`%LOCALAPPDATA%\DeadStreetCharacterFactory\runs\<run-id>\`

Never copy DAZ proprietary DUF/DSF/textures into this repository.
Never copy generated PNGs into `assets/` or bind them at runtime.

## Proof recipe

`recipes/local_street_gang_rifleman_proof_01.json`

- Character: Matt for Genesis 9 (already-installed free masculine source)
- Clothing: dForce Classic Tank Top Outfit (tank + trousers)
- Footwear: Worker Uniform Boots (tank-top product includes no footwear)
- Weapon: Multi-Caliber Weapon System Genesis 9 masculine carbine RH smart prop
- Hair: Mavick Hair (already installed; not the paid fade)

## Camera caveat

Iray on the installed DAZ Studio 6 General Release produced empty/transparent frames with a true `ORTHO_CAMERA`. Smoke and this proof use a framed 160mm elevated perspective camera. That is a technical stand-in, not Dead Street camera canon.
