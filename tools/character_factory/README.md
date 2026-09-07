# Dead Street Character Factory V0

Automated DAZ Studio / Genesis 9 handshake and free Starter Essentials smoke proof.

This is a **capability pipeline**, not accepted Dead Street character art.

- Tactical runtime stays 2D.
- 3D source stays offline.
- Generated PNGs are **not** runtime-authoritative and must **not** be bound into `TacticalUnitAnimationCatalog`.
- Camera / lighting in this smoke profile are `PROVISIONAL_SMOKE_ONLY`.
- Procedural soldier fallback remains the live unit baseline.
- No Blender dependency for this factory.

## Run (unattended)

From the repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode handshake
powershell -NoProfile -ExecutionPolicy Bypass -File tools/character_factory/invoke_character_factory.ps1 -Mode smoke
```

DAZ may open visibly. Do not click it. The factory script must close DAZ itself.

Outputs are written to:

`%LOCALAPPDATA%\DeadStreetCharacterFactory\runs\<run-id>\`

Never copy DAZ proprietary DUF/DSF/textures into this repository.
Never copy generated smoke PNGs into `assets/` or bind them at runtime.

## Smoke camera caveat

Iray on the installed DAZ Studio 6 General Release produced empty/transparent frames with a true `ORTHO_CAMERA`. The V0 smoke therefore uses a framed 160mm elevated perspective camera labeled `PROVISIONAL_SMOKE_ONLY`. That is a technical stand-in, not Dead Street camera canon.
