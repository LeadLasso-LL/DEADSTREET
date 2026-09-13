# Bridge revision - 2026-09-13

## Intended battle size

The latest user direction is to make the battle ceiling two maximum legal convoys.
A convoy limit of three vehicles, with rules restricting vehicle combinations so that personnel capacity is bounded, is a proposed design direction. The exact compositions and personnel cap have not been chosen.
Do not treat the large synthetic performance cases below as the game's intended scale.
No new production convoy or personnel cap was implemented in this revision. The existing sandbox limit of 1-12 units per side is not a final convoy design decision.

A reasonable next design pass is to define legal combinations by vehicle class, derive the highest legal personnel capacity, and profile two forces of that capacity. One transport plus two escort slots is an example to consider, not an approved rule.

## Implemented

- Neutral eastern checkpoint supports the selected defending faction. Native fixtures cover TRC versus NBPD and Orlov versus Mercer Saints.
- Attacker vehicles stop diagonally on both carriageways.
- Upper traffic faces west; lower traffic faces east. Added vehicles queue behind the eastern checkpoint, with abandoned vehicles also ahead of it.
- 39 civilian vehicles, including five diagonal vehicles and three bumper-contact pairs; open doors convey evacuation.
- Civilian artwork and chassis collision/cover scale are 1.6. Unit artwork remains at its established 1.48 scale. This corrects overall vehicle length and width relative to people.
- Median divider sections and crossing gaps remain.
- Rotated civilian chassis use overlapping axis-aligned collision slabs. This is a conservative approximation, not exact polygon collision.
- Civilian open doors are visual; their chassis provide collision and cover.
- Corrected convoy door proxy offsets for diagonal vehicles so deployment validation does not reject a vehicle because its own door envelope overlaps its chassis.
- Cover ranking rejects unavailable, out-of-radius, and unprotective positions before costly path and visibility evaluation.
- Added a spatial cover lookup with 12-unit cells, invalidated when geometry/cover changes. Occupancy is checked live and candidate ordering stays deterministic.
- Existing shotgun/SMG staged advances remain. These choose successive protected positions; this revision does not introduce a precomputed multi-hop cover route.

## Existing cover radii retained

| Class | Normal search | Closing/staging search |
|---|---:|---:|
| Pistol | 10 | 14 |
| SMG | 12 | 18 |
| Shotgun | 10 | 22 |
| Rifle | 18 | Existing role positioning |
| Sniper | 28 | Existing role positioning |

Distances are battlefield units. Wounded-unit cover search is 30.

## Verification

- 334 bridge geometry, deployment, navigation, and door checks passed.
- 108 cover-ranking comparisons passed against the original ranker.
- 42 native checks passed for each of the two faction fixtures.
- Both native scenes contained 16 actors and four convoy vehicles; all eight attackers moved.
- Scoped diff whitespace validation passed for the six changed production files.
- No commit or push was performed. Unrelated working-tree changes were preserved.

## Performance and limits

A matched 16-unit instrumented comparison on the same earlier bridge layout reduced mean simulation-update time from 61.1596 ms to 37.675 ms, a 38.4% reduction. P95 fell from 133.685 ms to 85.825 ms. This comparison predates the final enlarged traffic and spatial-grid changes.

The final normal native captures sampled 19-25 FPS at 16 units, depending on fixture. These snapshots are not a guaranteed sustained frame rate. More optimization is needed even for modest convoy-sized battles.

The synthetic scale harness rendered every requested actor. It advanced 0.05 simulation seconds per update, with at most 120 updates or about 25 seconds wall time per case. These were early movement samples with no damage recorded, not sustained firing or complete-battle benchmarks. Loop throughput below is harness throughput, not the production scheduler's FPS.

| Actors / rendered | Mean update ms | P95 ms | Maximum ms | Harness loops/sec | Updates | Simulated seconds |
|---|---:|---:|---:|---:|---:|---:|
| 16 / 16 | 31.1253 | 61.097 | 202.427 | 27.1924 | 120 | 6.0 |
| 64 / 64 | 131.1427 | 174.094 | 1217.687 | 7.0788 | 120 | 6.0 |
| 128 / 128 | 376.6677 | 465.706 | 2673.957 | 2.5469 | 64 | 3.2 |
| 256 / 256 | 1144.3307 | 1008.807 | 5534.186 | 0.8561 | 22 | 1.1 |

The earlier assurance of hundreds of units without performance issues was unsupported and is contradicted by these measurements. The user has explicitly clarified that hundreds are not the intended target.

At higher counts, targeting and pressure work grew steeply. Further spatial target/threat queries, reuse of navigation results, and spreading expensive decisions across updates are possible next steps; none are claimed implemented here.

## Evidence

JSON measurements and native captures are in this directory and its gang subdirectory.
Harnesses are in tools/bridge_map: v3_validate.gd, v3_cover_equivalence.gd, v3_review.gd, v3_review_gang.gd, and v3_scale.gd.
