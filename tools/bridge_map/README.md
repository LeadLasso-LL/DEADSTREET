# River suspension bridge — sandbox first pass

Select **River Suspension Bridge** in Custom Battle Setup. Pick one faction per side and its units, then choose both attacking and defending convoys. The sandbox retains the 1–12 units per side limit and unlocks every existing unit, weapon, tier, armor and vehicle.

The west approach is the arrival area. Attackers drive toward the queue and use physical vehicle exits; the defending convoy is already parked across the eastern carriageways. There is no close/middle/far selector on this map. Existing two-wheelers remain parked during arrival until riding animations are produced.

The 180 × 58 battlefield contains four lanes (two each direction), a traversable central maintenance strip, outer walkways, two suspension tower locations and 36 stopped vehicles. Traffic uses the existing fleet sprites and model dimensions. Vehicle bodies, tower plinths and service cabinets are physical obstacles; cover slots share their actual bounds. Taller obstructions block line of sight. River boundaries cannot be traversed. Upper tower sections fade when they obscure living units; ground cover remains visible.

Use the mouse wheel to zoom, middle drag to pan, and Home to fit the crossing. Existing selection, commands, HUD pages and normal battle resolution remain in use. End-of-battle staging stays on the bridge.

## Reproduction

Run Godot from the project root:

- `--headless --script tools/bridge_map/compile.gd`
- `--headless --script tools/bridge_map/validate.gd`
- `--script tools/bridge_map/bake_ground.gd` (regenerate the authored static art)
- `--script tools/bridge_map/review.gd`
- `--script tools/bridge_map/profile.gd` (separate scenery and simulation costs)

The rules review builds real 1v1, 5v5 and 12v12 battles with cars, a full bus and twelve bicycles, verifies both convoys, legal unit/exits, parallel crossing routes and river exclusion. Native review enters the map through the actual setup, observes arrivals and live combat, and captures an overview and close views. Reports and captures are in `tools/bridge_map/results`.

## Measured limitation

The 8v8 native review recorded 17 FPS on the GTX 1650 test PC. The first layout is reviewable, but live-combat performance remains unfinished. The profiler separates paused/hidden scenery from simulation and records stage costs.

## Scope

This is a first playable art pass awaiting owner review and balance playtesting. Civilian pre-fight animation is explicitly deferred until after the sandbox. Campaign road reopening and encounter integration remain future work; this isolated sandbox never settles results into a live campaign. Whittaker Estate is still the other pending map. Helicopters remain tabled.
