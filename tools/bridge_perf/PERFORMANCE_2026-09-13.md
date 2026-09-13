# Bridge battle performance — 13 September 2026

## Status

Implemented and regression checked. The 16-unit bridge battle is substantially faster. The 24-unit battle still has late-combat frame-rate drops; this is not a claim of stable 60 FPS or a final battle-cap decision.

## Defender behavior

Holding defenders retain their normal aiming, firing, cover-safety checks, and execution of an existing movement path. Expensive searches for a new position refresh every 0.25–0.39 simulation seconds, staggered by participant ID.

A fresh search runs immediately when the relevant context changes: target, orders, cover exposure, wounded state, occupied/reserved slot, weapon, defend anchor, geometry, threat direction/range band, or sufficient movement by either participant. Push and focus commands bypass the slower schedule. This changes decision timing slightly, as authorized, while keeping contextual reactions responsive.

## Other optimizations

- Native AStar2D routing reuses the static navigation graph instead of copying it and running scripted shortest-path searches for every route.
- Scoped obstacle grids restrict point and short-segment queries to nearby candidates. Exact collision and sight-line tests, including deterministic hit ordering, remain in place. Large queries fall back to the full obstacle list.
- Geometry validation uses a freshly built grid to check cover slots against nearby blockers.
- Visibility traces for unchanged endpoints survive between updates. Geometry revisions and obstacle snapshots invalidate them; the cache has a size limit. Target eligibility, range, aiming, and posture remain live.
- Defender candidate searches reject impossible weapon ranges before expensive geometry work.
- Assault target selection rejects candidates whose distance score cannot beat the current best before checking visibility, preserving the chosen target.
- Movement reuses a preloaded weapon catalog.

The civilian traffic cars are static artwork with collision/cover geometry, not fully simulated convoy vehicles. Their obstacle count contributes to query costs, but full vehicle simulation is not their cost. This pass preserves their artwork, size, arrangement, and cover geometry.

## Matched native benchmark

Windows Godot 4.7.2, D3D12 Forward+, GTX 1650 Max-Q, 1440×1000 window. Each run renders every participant and advances 600 updates of 0.05 seconds (30 simulation seconds). FPS figures below are checkpoints from this benchmark, not a guarantee of sustained gameplay FPS.

| Test | Mean simulation update | 95th percentile | FPS checkpoints |
|---|---:|---:|---|
| 16 units, before this performance pass | 29.67 ms | 61.10 ms | 27, 28, 20, 36, 37 |
| 16 units, final pass | 12.80 ms | 22.34 ms | 47, 54, 56, 56, 58 |
| 24 units, first measured checkpoint after routing optimization | 55.08 ms | 91.00 ms | 16, 21, 19, 13, 11 |
| 24 units, final pass | 26.73 ms | 48.44 ms | 32, 37, 35, 16, 20 |

The 16-unit mean update cost decreased about 57%. The 24-unit comparison begins after the first routing change because no matched pre-change 24-unit result was collected. Intermediate runs varied, including one large late-combat slowdown; these results should not be read as a stability guarantee.

The visibility and segment optimizations preserved the post-defender-change benchmark outcomes: 13 survivors / 6.763 damage at 16 units; 19 survivors / 13.392 damage at 24 units. Defender search pacing itself changes decision timing, so outcomes are not claimed identical to the original baseline.

## Normal playable runtime

An additional native 24-unit run used the actual `arsenal_review.gd` update loop, with its normal variable frame delta, for 30.06 wall-clock seconds. It averaged **34.46 FPS**; six five-second windows measured **27.57, 36.53, 38.24, 35.93, 37.09, and 31.39 FPS**. All 24 actors were present. Simulation time advanced 29.80 seconds; 19 units remained alive. The 95th-percentile frame was 43.44 ms and the largest was 231.07 ms.

Pausing only the simulation after that battle sample raised the same scene to **60.42 FPS** over five seconds. This supports simulation cost as the main remaining bottleneck. The native result is a substantial improvement, but it is not stable 60 FPS and still includes hitches. Remaining work should focus on measured simulation cost before reducing art fidelity.

## Validation

1,434 passing assertions cover movement results, blocking-object identity, visibility, inclusive obstacle edges, route connectivity/clearance/length, vehicle and geometry cache invalidation, direct unversioned edits between query scopes, defender search timing and immediate triggers, and unchanged assault target selection.

Scripts and raw results are in `tools/bridge_perf/`: `validate.gd`, `benchmark.gd`, `live.gd`, `checks.json`, `before.json`, `after24.json`, `segments16.json`, `segments24.json`, and `live24.json`. Detailed profiling scripts remain diagnostic tools, not production runtime dependencies.

## Scope and next performance boundary

No unit-size reduction, vehicle-art simplification, weapon rebalance, or convoy cap was introduced. The design target remains two maximum legal convoys; the proposed three-vehicle limit and allowed compositions still need a separate design decision. There is no requirement or promise to support hundreds of units.

Changes remain uncommitted. Existing unrelated repository changes are preserved.
