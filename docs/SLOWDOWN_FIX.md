# Dead Street runtime validation optimization

The repeated-validation slowdown is fixed for the measured six-unit HQ battle. Art, weapon statistics, AI decisions, and combat math are unchanged.

## Implementation

BattleRuntimeService opens a geometry-validation scope for one synchronous advance call and closes it after every normal return, including failed/terminal advances. BattleState shares the validation result across sight, attack, targeting, cover, navigation, movement, and vehicle-body checks inside that scope. Geometry replacement, content_revision, or cover_slot_revision changes force revalidation. Standalone queries and the next advance validate again.

This is deliberately not a permanent map-validity cache. Existing runtime updates do not directly mutate authored geometry structure without revision tracking; future structural mutations during an update must advance the corresponding revision. Occupancy and reservations are still checked by their existing per-query rules.

A cover-search-only batch experiment first reached 31.1 FPS. That implementation was removed in favor of the smaller common-scope solution; no additional batch API remains.

## Measurements

| Existing six-unit live battle | Before | After |
|---|---:|---:|
| Active combat mean FPS | 21.71 | 58.73 |
| Active frame p95 | 133.28 ms | 16.67 ms |

Before uses the preserved uninstrumented pixel integration run; after uses the same runtime review harness, normal renderer, laptop, and six-unit HQ scenario. Approximately 2.7x the active frame rate. This is one fixture, not a large-battle capacity claim. Screenshot capture remains part of this harness. Variable frame deltas can change the simulated fight, so behavior equivalence was checked separately at fixed 1/60-second steps.

## Correctness

Fixed-step before/after runs both resolved at tick 604 with 28 observed shots. Serialized final alive/wounded states, positions, targets, and shot source/target identities matched exactly. This comparison does not claim a byte-for-byte match of every internal object.

Focused checks passed for invalid geometry outside a scope, revalidation on a new scope, content and cover revision changes, invalid geometry sight rejection, and scope cleanup after invalid-delta returns.

The full core suite ran 2,292 checks: 2,275 passed, and 17 failed. Disabling validation reuse reproduced the exact same 17 failures (deployment UI and older visual-pass checks). This establishes no newly observed suite failures from this optimization; it does not make the existing failures resolved. core_before.json and core_after.json preserve the identical results.

## Reproduction

tools/slowdown_profile/generate.ps1 -BaselineRef 7bbdb3e generates diagnostic copies of the pre-fix runtime, combat, cover-evaluation, and LOS code. Run fixed_review.gd with -- --before for that path and without it for production. core_review.gd runs the existing full core suite. JSON results are saved alongside the diagnostic scripts.

Original unrelated working-tree edits were preserved. No subsequent creative objective has been started.
