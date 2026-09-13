# Bounded cover optimization and return to sandbox — 2026-09-13

Brandon explicitly wants to move on from dedicated performance work. This pass
implements the remaining narrow cover shortcut, verifies current-scale normal
play, and parks further optimization so sandbox development can resume.
This is a development sequencing decision, not a declaration of perfect 60 FPS.

## Change and validation

Retained closing-cover routes only consume legality and directional protection.
A dedicated predicate now checks those without allocating a full cover evaluation,
tracing LOS, or resolving weapon range. Full evaluation remains unchanged for
callers that consume its other fields. A no-role-cover decision now rejects
excess movement before rebuilding its more expensive context/LOS key.

- 3,330 cover-predicate checks passed across all 277 fixture slots, four
  occupancy/reservation states, three threat directions, and invalid inputs.
- 1,215 exact replay checks passed, including the deciding-kill fixture.
  Battle state is compared each step against the pre-pass behavior snapshot.
- 3,000 isolated queries: full evaluation 78.775 ms; predicate 19.310 ms
  (about 4.1 times cheaper for this query; not a whole-game speedup).
- Same-state 600-step simulation: 3430.850 → 3348.143 ms (about 2.4% lower).
- All final check/native logs passed the script/engine-error gate.

## Normal current-scale play

Official Godot 4.7.2 release, GTX 1650 Max-Q, 1440×1000, normal VSync,
24 units, mixed convoys, river bridge, 30-second active sample:

| Metric | Result |
| --- | ---: |
| Average FPS | 59.670 |
| P95 frame | 17.028 ms |
| P99 frame | 21.596 ms |
| Maximum frame | 33.297 ms |
| Frames over 33.333 / 100 ms | 0 / 0 |
| Five-second windows | 59.63, 59.99, 60.00, 60.00, 57.90 FPS |
| Survivors / damage at cutoff | 18 / 15.51 |

All 24 actors rendered. The sample ends at a measurement cutoff, not a battle
victory. This supports resuming sandbox development at the current 12-per-side
limit. Occasional dips remain; it does not prove sustained 60 FPS, larger-battle
capacity, or equivalent performance on other hardware. Previous inconsistent
32-unit results remain recorded in ../slow_frames/README.md. No new 32-unit
campaign or broad/actor suite was run in this bounded pass.

## Reproduction and source ownership

Use the verified release runtime/data pack from ../headroom/README.md.
`python run.py EDITOR_EXE RELEASE_FOLDER checks` runs the specific checks.
Use `native` for the normal 24-unit sample or `pack` to build the small launcher.
Named outputs are overwritten on rerun; archive evidence before replacing it.

The base package contains the prior mixed live-worktree snapshot. This runner
overlays current target selection, combat behavior and cover evaluation. The
pre-pass behavior/runtime reference scripts are preserved beside the tests,
without global class names. They intentionally include the pre-existing live
behavior work, so the replay isolates only this pass. They are test oracles,
not production dependencies or a second runtime implementation.

The production combat-behavior file was already dirty. Only owned_behavior.patch
is staged from that file (zero-context format: use `git apply --unidiff-zero`); prior edits to it and all unrelated files are preserved.
The new cover predicate, evidence and shared records belong to this checkpoint.
No art, reaction cadence, balance, convoy rule or production unit-cap change.

## Parked performance work

Steady frame pacing and larger-battle headroom remain unresolved backlog items.
Resume focused performance work if normal current-scale play visibly regresses,
when raising the production cap, or before release acceptance. Do not keep
extending this investigation by default while the sandbox is unfinished.

## Immediate next task

Return to the remaining Whittaker Estate sandbox map: recover its agreed design
brief and begin its first build pass. Vehicle riding/dismount presentation and
cross-map scenario review remain on the sandbox roadmap afterward. This sequence
is the technical lead's next step; it does not invent unapproved estate design.
