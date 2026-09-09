# Dead Street slowdown profile

Scope: profiling only. Production gameplay, art, and balance were not changed.

## Findings

Measured on the connected laptop using the existing six-unit HQ battle, normal renderer, new pixel units, with no concurrent Godot test. Diagnostic copies wrap functions with microsecond timers. The review disables automatic post-battle handoff and drives the existing runtime, as in the integration smoke test. No screenshots were captured during timing.

| Measurement | Deep profile |
|---|---:|
| Active battle FPS | 21.45 |
| Active frame p95 | 127.30 ms |
| Simulation time advanced | 8.72 s |
| Runtime advance cumulative CPU wall time | 8.48 s / 187 calls |
| Combat behavior inclusive time | 7.12 s (84% of runtime) |
| Cover slot evaluations | 3,650 |
| Instrumented sight geometry validations | 3,841 / 3.83 s |
| Actual instrumented sight traces | 2,017 / 0.092 s |
| Combat navigation path requests | 12 / 0.073 s |

Timings are inclusive and nested: do not add rows together. LOS instrumentation covers calls routed through diagnostic combat/cover evaluation copies, not every LOS caller in the game. Approximately 45% of measured runtime time is already explained by this subset of geometry validation calls. Function wrappers add overhead; this is hotspot diagnosis, not a capacity benchmark.

## Cause

BattleLineOfSightService._validate_geometry calls battlefield_geometry.is_valid() before visibility queries. That method walks surfaces, obstacles, cover objects, and cover slots, including slot legality checks. Cover ranking invokes sight queries for thousands of candidate evaluations. The full-map validation cost dwarfs the actual segment tracing, even though segment tracing has a cache.

The first profile independently reproduced ~20.47 active FPS and 84% runtime time in combat behavior. Two cover ranking functions accumulated 3.59 seconds across 75 calls. The deeper run found the validation cost inside that work. The existing navigation request path was much smaller in this fixture.

## Proposed fix, not implemented

Validate geometry at creation/change boundaries and reuse a validation result tied to a trustworthy geometry revision. Keep cheap null/endpoint checks per sight query. Invalidate on all relevant structural changes, including future destruction; account for mutable cover state rather than assuming permanent validity. Test invalid geometry rejection and mutation invalidation, then repeat the same battle and compare outcomes and frame times. After this, reassess whether cover candidate filtering or staggered decision updates are necessary.

No FPS improvement is claimed: no optimization has been applied. No large-battle or GPU-capacity conclusion follows from this six-unit test. Stop here for the user's next-objective notes.

## Reproduction

Run tools/slowdown_profile/generate.ps1 from PowerShell to create instrumented diagnostic service copies. Launch Godot with --path <repository> --script res://tools/slowdown_profile/review.gd. Results write to tools/pixel_integration/results/profile_report.json. Preserved first_report.json and deep_report.json contain the measured runs. Normal game startup does not use these diagnostic scripts.
