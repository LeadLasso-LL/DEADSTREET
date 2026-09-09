# Dead Street pixel runtime integration — 2026-09-09

## Implemented
- Bound the existing tactical actor presenter to nine independent outfit/weapon combinations: three approved outfits × rifle, SMG and pistol; eight directions.
- Reused exact approved running pixels and the separately authored action candidates. No DAZ or source art redesign.
- Registered Italian mob presentation identity without adding faction simulation rules.
- Cached shared SpriteFrames and textures, nearest filtering, grounded sprite anchor.
- Direction follows movement while running; traveled distance drives the stride.
- Shot events drive fire playback. Exported 144 muzzle anchors position projectile effects, and the duplicate legacy muzzle flash is suppressed for bound sprites.
- Reload timing follows authoritative weapon state. Locomotion takes priority during moving reloads; blended moving-reload arm animation is not implemented.
- Connected hit reactions, wounded locomotion, cover popout/fire/tuck and held death frames.
- Terminal combat stops flashes and lets death poses finish.
- Existing simulation, weapon balance, deployment legality, navigation and damage rules are unchanged.

## Verification
- All nine atlas transfer hashes matched.
- Godot import and compilation passed after removing temporary duplicate staging scripts.
- Contract review passed: nine combinations, eight direction bindings, reload midpoint, moving-reload priority, held deaths and retained nodes.
- Actual existing HQ battlefield: campaign mission launched, attackers placed through the real placement controller, defender AI committed deployment, BattleRuntimeService resolved combat.
- Review harness retains the resolved battle for inspection rather than performing campaign handoff. It is a test harness, not a replacement runtime.
- Both comparison runs: six participants, 24 recorded shots, two survivors, three wounded.
- Normal renderer pixel run: active-combat mean 21.71 FPS; 95th-percentile active frame 133.28 ms.
- Same harness with old procedural visuals: active-combat mean 20.29 FPS; 95th-percentile active frame 135.64 ms.
- Overall 45-second averages were ~52 FPS, mostly after resolution. Those averages must not be presented as active-combat performance.
- These are small local smoke tests, not a battle-size capacity benchmark. The slowdown persists with the new sprites disabled. Simulation/render profiling is needed before a performance sign-off.
- No full core regression suite was run.

## Remaining visual/gameplay work
- The live battlefield still uses the older environment assets. The newer approved street artwork has not replaced that map.
- Shotgun and sniper types have no approved asset binding; they retain the existing fallback instead of being mislabeled as a pistol/AK.
- Edge-lean art is packaged but not selected by cover geometry yet. Current cover playback uses the over-cover poses.
- Cover height matching, crouched reload blending, moving reload upper-body blending and full camera/occlusion refinement still need work.
- Existing debug HUD portraits and casualty marks remain.
- New action poses remain review candidates; source running art is preserved.
- No dropped-weapon loot, casualty persistence or balance rules were invented.

## Reproduce
Run Godot from this project:
`godot --path . --resolution 1280x800 --script res://tools/pixel_integration/runtime_review.gd`
Append `-- --baseline-visuals` for the old visual comparison.
Contract test:
`godot --headless --path . --script res://tools/pixel_integration/contract_review.gd`

## Preservation
Original presentation files were backed up beside the project in dead-street-before-pixel-integration. Existing uncommitted character-factory and project-control work was preserved. Only the scoped pixel integration files belong in this change.
