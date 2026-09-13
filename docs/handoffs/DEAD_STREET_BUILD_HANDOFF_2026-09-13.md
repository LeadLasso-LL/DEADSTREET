# DEAD STREET — active build handoff

Prepared 13 September 2026, at the end of the bridge performance pass in the Idea Repository conversation. This is a continuation guide, not a claim that all project history or every asset has been re-audited.

## 1. Start here

Continue building the existing Godot game on Brandon’s Windows laptop. The immediate unfinished objective is **improving tactical bridge-battle performance at realistic convoy-sized force counts**. The latest pass is implemented, tested, and documented; performance is substantially better, but the 24-unit battle still has hitches and is not consistently 60 FPS.

Do not restart the game, rebuild the bridge from scratch, re-create the units, or spend the first turn reconstructing thousands of PDF pages. Read this handoff and the two short repository reports below, inspect the current working tree, then take the next bounded step.

At this handoff, no further build operation is intentionally running. No commit or push was made for this performance pass. This handoff was prepared from verified results already in the conversation, without another benchmark run or fresh remote repository audit.

## 2. Communication is a build requirement

Brandon is frustrated by long silent work and messages sent during work apparently disappearing. He explicitly requested visibility so that a long operation does not leave him guessing.

1. **Acknowledge each incoming note at the first available response boundary.** Briefly repeat its substance and say whether it is being applied now, queued, already covered, or needs clarification. A generic progress message does not count as acknowledging the note.
2. Before tools, state the concrete next action and its purpose. Keep it to one or two sentences.
3. During active work, provide a meaningful update at least every minute when control is available: what is complete, what was learned, what is running, and what remains. If a tool may block updates, say so before starting it and report promptly when control returns.
4. Answer “hello?”, status questions, and corrections immediately when received, then continue the authorized task unless Brandon asks to stop.
5. Never claim that unseen messages were received. If a message is unavailable, say exactly what you can confirm. Do not promise that the interface cannot lose or delay messages.
6. Avoid giant invisible work blocks. Use bounded cycles: inspect the measured hotspot → one coherent change → relevant checks → matched result → report.
7. Make uncertainty visible: distinguish proposed, implemented, tested, approved, committed, and still unfinished. Report regressions and remaining FPS dips honestly.
8. Do not keep adding optional tests after the concrete risk is covered. Do not use a handoff request as an excuse to launch more development.

Suggested first response in the new chat:

> I’ve read the handoff. I have your notes on vehicle scale, local cover searches and shotgun advances, convoy-based battle limits, civilian-car processing, and reducing defender workload. The performance pass is in the working tree; 24-unit gameplay averaged 34.5 FPS, so performance remains the priority. I’ll first check the current repository state and reports, then identify one next bottleneck. I’ll acknowledge new notes and keep you updated at least every minute while working.

Use that wording only after actually reading the handoff. If the user supplies additional notes, acknowledge those too.

## 3. Roles, authority, and working method

- Brandon owns creative direction, product decisions, and approval of visual designs. Codex is the proactive technical/build lead: inspect code, implement authorized changes, diagnose problems, validate, and explain results.
- This is a real native Godot project. Use the actual game, renderer, and assets for gameplay previews. Generated concept imagery is not evidence that the game renders correctly.
- Work directly through the connected Windows environment where the repository lives. The ChatGPT scratch directory contains reference copies, not the authoritative game checkout.
- Continue authorized reversible work without repeatedly asking permission. Do not invent approval gates. Conversely, do not assume authorization for destructive operations, overwriting unrelated work, or publishing.
- These bridge/performance revisions remain **uncommitted**. Do not silently commit or push them merely because a prior broad workflow mentioned commits; inspect current instructions and get the intended integration scope clear.
- Preserve unrelated working-tree changes. Never use broad reset, clean, restore, or stage-all operations to simplify this task.
- If another chat is also working, establish which files it owns before editing overlapping files. Current HEAD and working-tree state must be rechecked; do not treat the snapshot below as permanently current.
- No AGENTS.md was found in the earlier repository inspection. Recheck if the checkout or instructions have changed.
- Do not delegate to subagents unless the current user or applicable instructions explicitly authorize it.

The user is also establishing a shared project record in the destination build chat. Incorporate this handoff into that record if it exists. Future meaningful decisions, changes, validation results, unresolved issues, and next steps should update that central record. Avoid creating competing “source of truth” documents.

## 4. Authoritative environment and files

| Item | Last verified value |
|---|---|
| Windows device | DESKTOP-7CL4DM3 |
| Remote device ID | `01064661-3272-4194-85ad-718eef125dd5` |
| Repository | `C:\Users\brand\OneDrive\Documents\dead-street` |
| GitHub repository | `https://github.com/LeadLasso-LL/DEADSTREET.git` |
| Branch | `build/arsenal-checkpoint-20260911` |
| HEAD | `e2c9a1374c5f82336126c59becc9d59a9d5090d3` |
| Godot | `C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe` |
| Python | `C:\Users\brand\AppData\Local\DeadStreetTools\python\python.exe` |
| Tested native renderer | Godot 4.7.2, D3D12 Forward+, GTX 1650 Max-Q |
| Benchmark window | 1440 × 1000 |

Read these repository files first; paths below are relative to the repository above:

- `tools/bridge_perf/PERFORMANCE_2026-09-13.md` — latest optimizations, native results, validation, limitations.
- `tools/bridge_map/v3_results/BRIDGE_REVISION_2026-09-13.md` — bridge layout, scaling, cover radii, prior validations. Its older FPS numbers are superseded by the performance report.
- `tools/bridge_perf/README.md` — diagnostic entry points.
- `gameplay/arsenal_review.gd` and `gameplay/arsenal_battle_fixture.gd` — actual sandbox setup and normal battle update loop.

Old scratch copies were under `/workspace/scratch/66f92efe9dad/bridge_perf/` and `/workspace/scratch/66f92efe9dad/bridge_v3/`. Scratch can disappear. Repository files and this attached handoff are the durable continuation points.

The repeated “Codex could not read the local image” notices reference old attachment paths. They do not demonstrate that the Windows game assets are missing. Do not repeatedly retry those stale paths or let them derail performance work. Resolve an original attachment only when that reference is actually needed.

## 5. Product and visual constraints

- Dead Street’s campaign is turn based; its tactical battles are **continuous / real time**.
- The city is New Briarport, also called “Seven Bridges.” Tactical maps are detailed battle locations within the larger campaign world.
- The accepted unit direction is gritty drawn/pixel artwork with a slightly elevated, angled camera. The DAZ rendering approach was abandoned for production units.
- The sandbox reports 23 factions, 115 regular outfits, and 30 weapons. Existing faction units, directional animations, firing, cover behavior, wounds, and deaths are established work. Preserve them.
- Unit body proportions and existing visual scale are fixed for this bridge work. Do not solve vehicle-scale problems by shrinking people.
- Clothing follows faction identity and weapon role; most factions are not covered head to toe in faction colors. Leaders and standard troops have distinct identities.
- Anatomy matters: arms connect to shoulders, necks connect naturally to heads and collars, limbs and clothing folds remain coherent. The user has repeatedly corrected detached limbs and unnatural neck shapes.

## 6. Bridge map decisions and implemented state

The sandbox bridge is a large suspension-bridge setting with battle running left to right at the game’s established camera angle. Attackers clear a road blockade to allow travel along that route. It is a test of close-range cover advances and long firing lanes.

Implemented before the performance pass:

- The eastern checkpoint belongs to whichever faction is selected to defend. It is not inherently an NBPD blockade. Fixtures checked TRC versus NBPD and Orlov versus Mercer Saints.
- Defenders hold their blockade; attackers advance from their arrival side. Do not depict TRC advancing from its own defended blockade by confusing faction and side roles.
- The upper carriageway travels west/left; the lower travels east/right. Traffic queues behind the blockade, while abandoned vehicles ahead of it are plausible because people fled the arriving attackers.
- Attacker vehicles stop diagonally across both carriageways, interrupting traffic on both.
- There are 39 civilian vehicles, including five diagonal vehicles and three bumper-contact pairs. Open doors convey that people abandoned them.
- Median divider sections have crossing gaps, providing additional central cover without sealing the two lanes off.
- Civilian artwork and chassis collision/cover use a 1.6 scale; existing unit artwork remains at 1.48. The correction concerns a car’s overall length/width relative to a person, not making sports cars taller than people.
- Rotated civilian chassis use overlapping axis-aligned collision slabs, a conservative approximation rather than exact polygon collision.
- Civilian open doors are visual details. Their chassis provide collision and cover. Convoy arrival-door proxies are separate; their diagonal offsets were corrected so a vehicle does not reject its own deployment.

**Civilian traffic cars are static artwork plus collision/cover geometry, not fully simulated convoy vehicles.** Their geometry still contributes to movement, visibility, and navigation query costs.

Earlier bridge validation: 334 geometry/deployment/navigation/door checks, 108 cover-ranker comparisons, and 42 native checks for each of two faction fixtures passed. Native captures are under `tools/bridge_map/v3_results/`; local previews previously used filenames `bridge_overview.png`, `bridge_combat.png`, `bridge_traffic.png`, and `bridge_gang_blockade.png`.

## 7. Cover behavior and intended battle ceiling

Brandon explicitly does **not** intend hundreds of units. A previous assurance that hundreds would run without performance problems was unsupported, and subsequent measurements contradicted it. Do not repeat that assurance.

The intended ceiling is **two maximum legal convoys**. A maximum of three vehicles per convoy, with allowed combinations that bound personnel capacity, is a proposed direction. Exact legal combinations and the personnel cap remain undecided. “One transport plus two escorts” was only an example, not an approved rule. The sandbox’s current 1–12 units per side is not the final convoy design.

The user wants units to consider nearby cover, with appropriate range-aware behavior. Retained existing radii, in battlefield units:

| Class | Normal cover search | Closing/staging search |
|---|---:|---:|
| Pistol | 10 | 14 |
| SMG | 12 | 18 |
| Shotgun | 10 | 22 |
| Rifle | 18 | Existing role positioning |
| Sniper | 28 | Existing role positioning |

Wounded-unit cover search is 30. Cover lookup uses 12-unit grid cells, with live occupancy checks and deterministic candidate ordering. Invalid, unavailable, out-of-radius, and unprotective positions are rejected before costly evaluation.

Existing shotgun/SMG advances select successive protected positions toward effective range. **A precomputed multi-hop cover route was not implemented.** Do not report the user’s broader “cover checkpoints along the way” idea as fully implemented beyond the existing staged advances.

## 8. Latest performance changes

Ten production files changed in the final scoped diff: 285 insertions and 88 deletions relative to the then-current HEAD. Source changes remain uncommitted.

| File | Main change |
|---|---|
| `battle/navigation/battle_navigation_service.gd` | Reused native AStar2D routing on the static graph; bounded endpoint-connection cache; segment-bounds rejection. |
| `battle/geometry/battle_spatial_service.gd` | Conservative bounds rejection; indexed point and finite-segment candidates before exact collision tests. |
| `battle/geometry/battlefield_geometry.gd` | Scoped 8-unit obstacle grid; local point/rectangle queries; freshly indexed cover-slot validity checks. Large rectangle queries fall back to all obstacles. |
| `battle/core/battle_state.gd` | Query-scope lifecycle; persistent exact-endpoint LOS cache with geometry invalidation and size limit. |
| `battle/combat/battle_line_of_sight_service.gd` | Reject distant obstacles; use indexed segment candidates while preserving exact sight-line rules and blocking-object identity. |
| `battle/combat/battle_defend_position_service.gd` | Reject impossible weapon ranges before geometry/LOS work; indexed destination legality. |
| `battle/combat/battle_combat_behavior_service.gd` | Indexed destination legality and paced expensive defender position searches. |
| `battle/runtime/battle_movement_service.gd` | Preload/reuse weapon catalog instead of repeated dynamic load. |
| `battle/runtime/battle_runtime_service.gd` | Prepare and invalidate LOS cache as needed rather than clearing every update. |
| `battle/combat/battle_target_selection_service.gd` | Reject assault candidates that cannot beat the best distance score before expensive fire-engagement/visibility evaluation. |

### Defender workload — latest user direction, implemented

Holding defenders continue aiming, firing, checking current cover safety, and executing their existing path each update. **Only expensive searches for a new position are paced**, every 0.25–0.39 simulation seconds, staggered by participant ID.

A fresh search is allowed immediately when relevant context changes: target ID, orders, cover exposure, wounded state, occupied/reserved slot, weapon/model/tier/range, defend anchor, geometry revisions, threat direction sector, range bands, or sufficient movement by the participant or target. Position thresholds are 1 battlefield unit for the defender and 2 for the target. Threat direction uses 16 sectors; range-band checks include weapon maximum and an 8-unit close-threat threshold.

Push/focus-left/focus-right commands bypass the slower schedule. Unrelated units changing reservations do not reset every defender’s cadence; ordinary availability changes are picked up on the periodic refresh. This intentionally changes some decision timing, so original battle outcomes are not claimed identical.

### Cache correctness boundaries

- LOS keys use exact ordered endpoint coordinates. Moving endpoints miss naturally; target eligibility, weapon range, aiming, cover posture, and alive status remain live.
- Geometry instance/revision changes and per-update obstacle snapshots invalidate LOS. The snapshots include IDs, bounds, and LOS-blocking flags, preserving direct edits between updates. The cache clears when it exceeds 4,096 entries at update preparation.
- Obstacle grids are scoped to synchronous runtime/navigation work and rebuild at scope start or relevant structural changes. Outside a scope, public queries fall back to live full-data scans.
- Exact collision tests and deterministic hit ordering remain authoritative. The raw infinite-line AABB overlap API was not redefined as a segment query.

## 9. Verified performance and limits

Matched native benchmarks render all actors and advance 600 updates of 0.05 seconds: 30 simulation seconds. These FPS values are checkpoint observations, not sustained-FPS guarantees.

| Benchmark | Mean update | P95 update | FPS checkpoints |
|---|---:|---:|---|
| 16 units before the performance pass | 29.67 ms | 61.10 ms | 27, 28, 20, 36, 37 |
| 16 units after the final pass | 12.80 ms | 22.34 ms | 47, 54, 56, 56, 58 |
| 24 units, first checkpoint after initial routing optimization | 55.08 ms | 91.00 ms | 16, 21, 19, 13, 11 |
| 24 units after the final pass | 26.73 ms | 48.44 ms | 32, 37, 35, 16, 20 |

The 16-unit average simulation cost fell about 57%. No matched original pre-routing 24-unit baseline was collected; label that comparison honestly. Intermediate runs varied, including one severe late-combat outlier.

**Normal playable 24-unit run:** actual `arsenal_review.gd` variable-delta update loop, 30.06 seconds of wall time, 29.80 simulation seconds, all 24 actors present, 19 survivors. Average **34.46 FPS**. Five-second windows: **27.57, 36.53, 38.24, 35.93, 37.09, 31.39 FPS**. P95 frame 43.44 ms; maximum frame 231.07 ms.

Pausing only the simulation afterward raised the same scene to **60.42 FPS** over five seconds. This supports simulation cost as the main remaining bottleneck. It does not prove rendering is free or guarantee performance on other machines.

Latest validation: **1,434 assertions passed**, covering movement/visibility equivalence, blocking-object identity, inclusive edges, route connectivity/clearance/length, cache invalidation, direct unversioned edits, defender triggers/cadence, and unchanged assault target selection. Scoped `git diff --check` passed. Git emitted line-ending normalization notices, not whitespace failures.

Visibility and segment-query optimizations preserved the post-defender-change benchmark outcomes: 13 survivors / 6.763 total damage at 16 units; 19 survivors / 13.392 damage at 24 units. The earlier cadence change itself was not expected to preserve exact outcomes.

## 10. Diagnostics and sensible next steps

Repository directory: `tools/bridge_perf/`.

- `validate.gd`, `checks.json` — latest regression suite and result.
- `benchmark.gd` — native matched benchmark; user arguments `--side=8` or `--side=12`, plus `--label=<name>`.
- `live.gd`, `live24.json` — normal 24-unit gameplay and late simulation-only pause.
- `before.json`, `after24.json`, `segments16.json`, `segments24.json` — comparisons above.
- `current_deep24.json` — detailed headless timings after LOS reuse, before the final segment-query pass. It includes instrumentation overhead and is not native FPS.
- `tools/bridge_map/profile_runtime.gd`, `v3_runtime_probe.gd`, `v3_combat_probe.gd` — diagnostic wrappers. They are not production runtime dependencies. Refresh copied wrappers from current source before trusting a new detailed profile.
- `original/`, `before_spatial/`, `before_defender/`, `before_los/`, `before_segments/` — incremental diagnostic backups. Never broadly restore these over newer work.

The detailed 24-unit headless profile recorded approximately 8.25 seconds total combat work over 600 updates, including 2.48 seconds healthy-role behavior and 1.92 seconds defender behavior; movement was 3.19 seconds, targeting 2.13 seconds, and pressure 1.52 seconds. Function timings are inclusive and overlap; do not add them as independent costs.

Next agent should:

1. Acknowledge the handoff and notes, inspect current branch/HEAD/diff and the two reports. Check for another active writer before edits.
2. Continue from the measured 24-unit simulation bottleneck. Choose one bounded investigation, then report what it finds. Reuse the existing harnesses rather than building more broad test systems.
3. Consider expensive repeated combat queries, movement checks, and target/pressure work. A vehicle physical-profile allocation cache or navigation component-query reuse are unimplemented hypotheses, not proven fixes. Weapon model/tier profiles already have caches; inspect before adding duplicates.
4. Preserve quick contextual reactions and shotgun cover advances. Do not globally throttle all AI or reduce art to manufacture a better number.
5. Validate the actual changed behavior and compare the same scenario. Use normal gameplay as well as benchmark timing when claiming user-visible FPS improvement.
6. Report the result promptly and update the central project record. Do not call performance finished if meaningful dips remain.

The normal sandbox currently calls `Runtime.advance(battle, minf(delta, 0.1))` every rendered frame. A fixed-rate simulation/interpolated rendering redesign has **not** been implemented or selected; it would be a separate architectural decision requiring care with timing and presentation.

## 11. Remote-tool practical notes

Remote tools were often slow, sometimes taking tens of seconds merely to return a process ID. This contributed to the poor experience; do not hide it behind vague “still working” updates.

- Discover the available Remote Desktop Commander tools and current schemas. Relevant tools previously included start_process, read_process_output, read_file, read_multiple_files, and write_file.
- Start long work with a short tool timeout and poll the returned process ID. Keep tool waits short enough to give updates. A remote PID is different from a functions.exec cell ID.
- Use ordinary plain-text file reads. A previous compressed/base64 source-export command was rejected by automatic review. Standard file reads were accepted; do not retry the rejected export approach.
- Reliable Windows execution used a PowerShell here-string written to a uniquely named temporary Python file, then invoked the installed Python executable. Nested Python -c quoting was unreliable. Use explicit UTF-8, careful quoting, and guarded edits.
- Validate current file content before applying changes, especially with another chat potentially active. Earlier patches used SHA-256 guards and plain-text line replacements.
- Do not leave benchmark Godot processes running. Do not start simultaneous benchmarks that contaminate one another.

## 12. Earlier creative decisions to preserve

These decisions are visible in this conversation; their generated assets were not re-audited during the performance pass.

- Silvio Ventresca’s leader unit and portrait were approved. Age 63; gray hair with white streaks and modest volume; trimmed mustache; compact smoky, gold-framed sunglasses; fully open dark brown blazer and cream dress shirt. Later corrections removed black hair patches and fixed arms, jacket folds, and neck anatomy.
- Leader campaign portraits retain the unit’s rough pixel/drawn identity, with slightly clearer faces. They resemble candid printed evidence photographs with white borders, subtle photograph treatment, and handwritten names. Pose, setting, and scenario vary by leader and faction; they are not polished realistic paintings or identical crops.
- Authority leaders use official department wall portraits/plaques; TRC is more military styled. They do not use criminal surveillance photographs.
- Brandon authorized creative drafts of the remaining leader units and photographs, then said to lock the result in. Do not infer that every resulting file is present merely from that approval; locate approved assets before editing them.
- Suggested portrait scenarios included Mac running with an Uzi, al-Saffar overseeing dock cargo unloading, biker leaders holding motorcycle handlebars, and a distant ambiguous Coyote image labeled with quotation marks and a question mark.
- Campaign end-turn zoom-out should evoke a police helicopter: subtle rotor audio, muffled staticky pilot-radio gibberish, possibly a police-camera fullscreen treatment. This is a recorded concept; implementation was not verified here.
- Player-created factions are a later-stage build focus. The detailed prior assistant proposal is not present in the visible record; do not invent approved customization rules. Recover its dedicated notes only when that feature becomes active.

## 13. Confirmed user notes versus unavailable messages

At the end of the previous chat, Brandon said five messages sent during work seemed lost. The assistant could confirm seeing these subjects: vehicle proportions without smaller units; nearby cover searches and shotgun covered approaches; convoy-derived battle ceiling; civilian-car processing cost; and reducing defender workload. It could not confirm that these were exactly the five messages he meant.

Do not silently assume any unseen note has been handled. Acknowledge additional notes explicitly as they arrive. The immediate handoff request is complete when this document is delivered; development should continue in the new chat, with visible progress.
