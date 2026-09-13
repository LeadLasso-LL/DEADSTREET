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


## Owner-requested revision — 2026-09-13

- Attacker vehicles now queue lengthwise within one lane before filling another, separating their arrival from the defenders' roadblock.
- The eastern defending checkpoint has four striped concrete road blocks, a stop line, cones and a portable ROAD CLOSED board, backed by the selected defending convoy. Infantry gaps remain traversable.
- Six low concrete median sections provide physical movement obstruction and cover slots, with gaps for crossing between carriageways. Geometry and artwork share the same footprints.
- Revised native capture shows both the advancing attackers and their defending target; `revision_results/bridge_blockade.png` provides the closer checkpoint view.
- Run `--headless --script tools/bridge_map/validate_revision.gd` and `--script tools/bridge_map/review_revision.gd` to reproduce. Compile passed; 259 rules/navigation checks and 42 native checks passed; all eight attackers moved in the 8v8 review.
- Native review measured 15 FPS. The previously documented live-combat performance work remains outstanding.
- These source changes and review captures await visual acceptance and have not been committed or pushed by this revision pass.


## Bridge revision 2026-09-13

See [the revision report](v3_results/BRIDGE_REVISION_2026-09-13.md) for traffic, scale, cover-query changes, verification, and measured performance. The current design target is two maximum legal convoys; a three-vehicle convoy limit with composition restrictions is proposed, with exact capacities still undecided. No new production cap was imposed.
