# Bridge runtime cleanup — 2026-09-13

## Result and limits

This receiving chat implemented and verified a further optimization pass on top
of the previously uncommitted bridge revision and performance work. The native
24-unit battle improved from 30.15 to 42.34 average FPS
in fresh 30-second runs on the same fixture. This is a 40.4% increase.
Stable 60 FPS remains unfinished. The largest final frame was 292.985 ms:
the average improved, but severe hitches are not solved.

Windows Godot 4.7.2, D3D12 Forward+, GTX 1650 Max-Q, 1440 x 1000, 12 units per
side and all 24 actors rendered. The normal gameplay loop uses variable delta;
those runs can produce different battle outcomes as timing changes. Their
survivor/damage counts are not a deterministic equivalence claim.

| Measurement | Fresh baseline | Final pass |
| --- | ---: | ---: |
| Normal playable average FPS | 30.15 | 42.34 |
| Normal playable P95 frame, ms | 52.977 | 31.842 |
| Normal playable maximum frame, ms | 248.724 | 292.985 |
| Matched fixed-step mean update, ms | 22.706 | 16.745 |
| Matched fixed-step P95 update, ms | 32.539 | 24.601 |
| Matched fixed-step maximum update, ms | 139.323 | 94.770 |

The mean fixed-step cost fell 26.3%.
Both fixed-step runs advanced 600 updates of 0.05 seconds, with identical
19 survivors, 13.392 damage, 18 moved participants and 13 occupied covers.
Normal gameplay advanced 29.520 simulation seconds in
30.018 wall seconds. The existing delta clamp loses some time
during large hitches. Pausing simulation afterward produced
60.57 FPS. These samples do not guarantee sustained FPS.

## Changes

- Fixed the obstacle grid's empty-cell return: an untyped empty array caused
  runtime type errors. The fresh pre-change playable run logged
  813 script errors in 30 seconds. Final runs log zero.
- Collision queries reuse internal physical profiles while observing live model
  dimension edits. Public profile requests still return independent objects.
  Conservative distant-segment rejection retains the exact oriented-body test.
- Navigation reuses component membership for exact endpoints on the existing
  topology-specific graph. The cache is bounded and replaced with that graph.
- Pressure observation prepares positioned, registered candidates once per
  synchronous refresh and reuses each pair's squared distance. Every refresh
  still observes live movement, wounds, deaths and side/deployment changes.
- Combat checks termination before its first actor and after every executed
  shot, before another actor acts. Previously it revalidated every participant
  and vehicle deployment assignment before every actor, even without a shot.
- Force-frame initialization reuses the existing scoped geometry validation
  instead of validating the full map again.

No art, unit counts, stats, weapon balance, player orders, firing cadence,
defender reaction schedule, cover advances or simulation frequency were reduced.

## Evidence and validation

- 5947 scoped assertions passed: previous movement/LOS/route/defender
  checks plus all-model profile comparisons, independent public profiles, live
  dimension edits, rotated and boundary collision equivalence, navigation
  component invalidation, empty buckets and exact pressure snapshots.
- 1215 full-runtime replay assertions passed. A 24-unit battle matched
  the prior combat loop exactly through 600 updates, including participant
  positions/velocity, health, targets, cover, ammunition/timers, phase, time and RNG.
  A 2-attacker/1-defender fixture resolved on the same sixth update, with no
  extra action after the deciding kill.
- Final validation, replay and native logs contain zero script errors.
- Same-process alternating collision trials took about 39.7-40.5 ms versus
  62.2-64.0 ms originally, with identical hits. Pressure trials were about
  25.3-28.6 ms versus 119.1-132.6 ms originally.
- The first collision/connectivity-only native comparison did not improve FPS.
  It is retained in the evidence, not presented as a successful gameplay result.
  Log inspection then exposed the empty-cell error and prompted the stricter gate.
- Legacy whole-project core-regression status was not re-established in this
  focused pass. No new owner art acceptance is implied.

Raw reports and reproductions are in next_pass/. Final evidence:
checks_final.json, replay.json, bench_victory.json, live_victory.json,
micro.json, pressure_micro.json and error_audit_before.json.
The old assertions alone missed script errors despite returning exit code zero.
Use run_checked.py for future checks so engine errors fail the gate.

## Continuation and checkpoint scope

Next: profile the remaining combat/target-selection work and the worst frame
spikes in the normal 24-unit loop. Final fixed-step stage means are approximately
7.34 ms combat,
4.17 ms target selection,
2.26 ms movement and
0.62 ms pressure. Do not call 60 FPS achieved.

The intended ceiling remains two maximum legal convoys; the three-vehicle limit
and exact personnel cap are undecided. This checkpoint includes the inherited
bridge/performance source, this cleanup, required diagnostics and updated records.
Older character-factory/dusk experiments and unrelated imports remain untouched.
This record travels with the performance commit; obtain its hash and pushed
state from Git/remote verification rather than a self-referential document hash.
