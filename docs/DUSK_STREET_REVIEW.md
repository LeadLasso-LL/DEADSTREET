# Dead Street dusk battle candidate — 2026-09-09

## What changed
The default HQ tactical session now uses dead_street_dusk_v1, a native procedural pixel street. The old proving-ground catalog remains available. This is a new implementation; it is not a recovered copy of the earlier standalone street prototype.

The scene uses an oblique ground projection, restrained sodium and cyan light pools, shopfronts, brickwork, awnings, drains, worn pavement, parked cars, dumpsters, service cabinets and a delivery van. Visible footprints and authoritative cover/collision come from one catalog.

Units use the accepted existing directional assets. Dusk display scale is 1.48, default framing 1.2 times fit, with foot shadows and depth ordering against props and the arrival car. Doorways were enlarged to maintain character/environment proportions. Locomotion advances frames from distance traveled with a 2.8-unit stride cycle. No unit source images or weapon statistics were changed.

Mouse wheel zooms; middle drag pans; Home returns to fit.

## Tactical intent
- Arriving gang deploys behind its vehicle on the south side.
- Delivery van interrupts opening sightlines; its sides provide exits toward the street.
- Central sedan provides an SMG-range approach position: 19.33 tactical units to the western club wall's north slot, against SMG max range 20.
- Side cars, dumpsters, pallets and service areas create alternate routes.
- Club frontage and eastern shops provide defender cover.
- Buildings, service cabinets and van block sightlines. Lower cover remains shoot-over cover under existing combat rules.
- Existing pistol 24, SMG 20 and rifle 40 ranges remain unchanged.
- Debug fixture uses supported pistol/SMG/rifle visual assets; two previous shotgun loadouts were replaced only in that fixture.

## Verification
Run tools/dusk_review/runtime_review.gd through Godot from the project directory. It launches the actual HQ session, places attackers through the deployment controller, deploys defenders through existing AI, validates cover reachability including the live arrival vehicle, then advances the actual combat runtime.

Final captured run:
- Geometry valid; all 68 cover slots reachable from arrival; no layout-audit problems.
- Six participants; 54 observed shots.
- Aim, walk, wounded walk, firing, cover tuck/pop-out/fire, hit and death clips exercised.
- About 55.1 FPS during active combat; active p95 frame time 30 ms. Full-run p95 after warm-up 18.06 ms.
- Battle resolved after about 14.41 simulation seconds.
- Actual screenshots at 1, 2, 5 and 10 seconds in tools/dusk_review/results.
- Compared and inspected in-game screenshots across three layout/presentation iterations.

## Limits / next review
This is a first playable art/layout candidate, not a balance certification. One fixture cannot establish fairness across loadouts, seeds or force sizes. There are still frame-time spikes; no claim of a locked 60 FPS. Generic HUD portraits remain an older presentation element. The map is not yet generated from campaign geography. The earlier standalone street could not be recovered from the unavailable local runtime, so its exact appearance was not reused.

Review the units at normal zoom, cover visibility and the dusk palette before expanding the map set. Preserve the accepted unit designs and source animation assets.
