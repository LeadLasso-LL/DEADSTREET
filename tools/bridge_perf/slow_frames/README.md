# Release slow frames and targeting — 2026-09-13

This checkpoint removes avoidable assault-target ranking work and adds a rendered
comparison with identical simulation steps. It does not establish steady 60 FPS.

## Measured costs

A valid 30-second, 32-unit release trace measured 9.085 ms/frame in runtime,
including 4.117 ms combat behavior, 1.576 ms target selection, 0.961 ms weapon
updates, 0.822 ms movement and 0.636 ms pressure. Actor synchronization was
1.350 ms/frame. These are instrumented timings, not uninstrumented capacity.
The first combat update peaked at 22.152 ms. Several 43–45 ms wall frames had
only about 10–11 ms measured runtime; their remaining delay is not diagnosed.

A detailed 15-second approach trace advanced simulation with all 32 units alive;
no damage occurred yet. Individual helper wrappers add substantial overhead.
The largest exclusive combat helper was the no-role-cover decision key at
0.442 ms/frame, followed by shot eligibility and defender/role checks.
Do not infer production FPS from this trace.

## Production change

Assault targeting rejects non-finite/out-of-range squared distances before
allocating and sorting candidate rows. Maximum squared range is calculated once
per scan. Original ranking distance, retained-target bias, tie order, target
identity validation, LOS order and nearest-hostile fallback are preserved.
No AI cadence, artwork, production roster limits or gameplay rules changed.

## Evidence and limits

| Test | Before | After |
| --- | ---: | ---: |
| Identical 600-step simulation, 24 units | 3479.594 ms | 3349.690 ms |
| Identical rendered 1800-step battle, 32 units | 61.062 FPS | 65.966 FPS |
| Simulation per rendered step | 9.726 ms | 8.781 ms |
| Rendered P95 frame | 18.343 ms | 18.400 ms |
| Rendered P99 frame | 20.613 ms | 23.509 ms |
| Rendered maximum frame | 33.298 ms | 32.888 ms |

The rendered comparison uses 1800 updates of 1/60 second, official release,
1440×1000, uncapped, three Bulwarks per side. Both runs had 1213 full-roster
frames, 22 survivors, damage 21.085, and identical recorded final state/RNG.
It is a throughput comparison: the battle advances faster than real time when
rendering above 60 FPS. It is not normal gameplay or proof of steady 60 FPS.
After was measured before the control. This is one paired sample; machine
variation can affect its magnitude. The 24-unit exact replay independently
supports lower simulation cost (3.7%). P95/P99 did not improve in the pair.

All 8,605 focused checks and 1,215 exact-before/after replay checks passed in
release, including the deciding-kill fixture. Replay compares state every step.
Final native, fixed-step and check runs had zero script/engine errors.
Actor behavior was not changed; the prior actor suite was not repeated.

Normal variable-step uncapped runs were inconsistent: baseline 64.660 FPS,
first trial 59.100, revised trial 48.154. Their P95 values were 18.601, 21.661
and 29.960 ms. Those slow results are retained, not discarded as capacity
successes. Different frame deltas produce different paths/casualties, while
external load remains another possible contributor. Neither cause is proven.
The controlled result supports accepting the narrow CPU optimization, not
claiming the normal-game slowdown has been fixed.

## Failed attempts and corrections

Initial test-only profiler wrappers failed script loading due to declaration
placement and mixed indentation. A rendered-but-idle run was rejected; the
retained coarse trace advances 30 seconds, causes damage and records runtime.
The detailed approach trace failed a too-strict damage gate despite advancing
15 seconds normally; it is labeled approach-only evidence.

The first targeting trial moved all eligibility calls before sorting. Its
small replay gain and worse native result were insufficient. The accepted
revision only hoists range math and preserves deferred identity checks.

## Reproduction

Use the verified official release folder and asset package from
`../headroom/README.md`; do not rebuild the 4.3 GB data pack for these scripts.
Run `python run_comparison.py EDITOR_EXE RELEASE_FOLDER checks`, then `fixed`
for matched rendered states, or `native` for normal variable-step runs.
`pack` restores the small launcher without running a battle. The runner fails
on script/engine errors, non-advancing battles, missing damage or wrong roster.

The base asset/source pack is the prior live-worktree snapshot described by
`../headroom/release_source_snapshot.json`, not a clean checkout of HEAD.
The comparison overlays only targeting, test launchers and generated oracle
scripts. Its target reference is commit 16405fbb057e8390fa0c0e864e879e461494232e.
Existing unrelated dirty gameplay/art work remains outside this checkpoint.
Raw JSON/logs and test scripts are beside this report. Re-running overwrites
named outputs; archive a measured set before replacing it.

## Immediate next task

Use the fixed-step rendered benchmark to isolate the remaining combat/cover validation cost and frame-time tails, then verify gains in the normal variable-step game. Steady 60 FPS and larger-battle headroom remain open.
