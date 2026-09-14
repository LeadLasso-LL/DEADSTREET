# Dead Street — decision and work journal

Append meaningful events as work happens. Follow the
[Hive Mind protocol](DEAD_STREET_HIVE_MIND.md).
Historical seeds below identify their source and limits; they are not a claim
that every original conversation has been recovered.
Archive index: none yet.

## 20260913-workflow-01 — shared project memory established

- **Event/recovery date:** 2026-09-13. **Type:** WORKFLOW / USER DECISION.
- **Status:** ADOPTED by explicit instruction in the receiving chat.
- **Source:** Brandon asked to establish a document/workflow in this project that
  future chats review, edit and use as a “hive mind,” recording everything needed
  for continuity and clean handoffs.
- **Decision and reason:** maintain project memory during meaningful work so a
  maximum-length chat does not require the user to export/reconstruct its history.
  The working assistant owns this maintenance.
- **Implementation:** root AGENTS.md supplies startup/recording instructions;
  DEAD_STREET_HIVE_MIND.md coordinates reading/ownership/next action; this journal
  retains decisions, reasons, changes, failures and evidence. Existing Project
  Control remains the milestone tracker. Topic documents remain authoritative
  for their detailed rules.
- **Scope:** these three documentation files only. The concurrently active bridge
  optimization and existing project-control content are preserved.
- **Validation:** check file contents, relative links, expected destination,
  Git diff/scope and preservation of unrelated work. No game tests are needed for
  this documentation-only change; no new gameplay validation is claimed.
- **Checkpoint:** this entry travels with the documentation commit; obtain its
  exact hash and push state from Git/remote verification rather than a self-
  referential hardcoded hash. A reported save/push failure must remain explicit.
- **Next:** apply this rule from now on; reconcile the active build pass when it ends.

## 20260913-transfer-01 — active chat handoff remains pending

- **Date:** 2026-09-13. **Type:** COORDINATION. **Status:** OPEN.
- **Source:** direct statements by Brandon in this receiving chat.
- **Sequence:** Resume Build Pass reached maximum length; building continued in
  [[Idea Repository]], which was still working. Brandon will coordinate its finish
  before the new chat takes over gameplay implementation.
- **Reason:** preserve the active pass's work and include its final delta.
- **Evidence:** live read-only audit found branch build/arsenal-checkpoint-20260911,
  gameplay HEAD e2c9a1374c5f82336126c59becc9d59a9d5090d3, mixed dirty files and current
  bridge-performance harnesses. Identity was rechecked at 09:49 EDT.
- **Limit:** full transcripts were not retrieved. Current repository records give
  substantial technical/product context; unrecorded conversations remain gaps.
- **Next:** after completion, inspect latest HEAD, status, current docs, final
  measurements and remaining work; update the Hive Mind's ownership and next action.

## 20260913-scale-01 — convoy-sized battle ceiling

- **Original discussion:** latest visible Idea Repository context; exact event
  time unavailable. **Recovered:** 2026-09-13.
- **Type:** PRODUCT DIRECTION. **Status:** TARGET ESTABLISHED; DETAILS PROPOSED.
- **Sources:** visible user context and
  [bridge V3 report](../tools/bridge_map/v3_results/BRIDGE_REVISION_2026-09-13.md).
- **Direction:** maximum intended battle size is two maximum legal convoys.
  Hundreds of simultaneous units are not the intended target.
- **Proposal:** at most three vehicles per convoy, with composition constraints
  that make personnel capacity bounded. Exact combinations and cap remain open.
- **Reason:** define realistic battle scale through transport capacity.
- **Not approved:** transport-plus-two-escorts is a report example; sandbox
  1–12/side is an implementation limit, not the final campaign rule.
- **Next:** retain the open decision; measure the final legal ceiling when defined.

## 20260913-performance-01 — bridge performance is unfinished

- **Evidence recovered:** 2026-09-13. **Type:** FINDING / ACTIVE WORK. **Status:** OPEN.
- **Sources:** bridge V3 report, tools/bridge_perf/defender24.json and
  tools/bridge_perf/checks_defender.json; read-only defender-position diff.
- **Finding:** bridge traffic/geometry and combat simulation have substantial
  cost. Existing optimization includes cheap cover rejection and spatial queries.
  The inspected defender diff avoids necessarily out-of-range searches, moves
  range checks before expensive tests, and uses point-local obstacle queries.
- **Reason for current work:** user reported unacceptable performance and asked
  whether parked-car handling and defender decision workload could be reduced.
- **Product boundary:** defenders generally hold/pivot but can exploit an
  advantage. Do not remove contextual counterattacks merely to reduce work.
- **Evidence limits:** V3 final 16-actor snapshots were 19–25 FPS. A later stored
  24-actor/30-second report has mean update 36.75229 ms, P95 61.951 ms, snapshots
  12–31 FPS, and 1,062 focused checks reported separately with no errors.
  Different layouts/fixtures are not a valid matched performance comparison.
  These reports were read, not rerun by the receiving chat.
- **Correction to retain:** V3 explicitly retracts an unsupported earlier
  assurance about hundreds of units. Harness throughput is not production FPS.
- **Next:** await and inspect the active pass's final evidence and unresolved cost.

## 20260913-bridge-01 — scale, traffic and map-specific arrivals

- **Recovered:** 2026-09-13. **Type:** PRODUCT / IMPLEMENTATION. **Status:** BUILT
  REVISION; FINAL OWNER ACCEPTANCE NOT RECOVERED.
- **Sources:** user context, current Project Control, bridge README and V3 report.
- **Intent:** elevated left-to-right suspension-bridge battle; defender blockade
  and stopped traffic; close cover movement and long rifle/sniper lanes.
- **Decisions:** arrival choices depend on the map; close/middle/far is not
  universal. Civilian pre-fight animation is after the sandbox. Campaign route
  reopening is desired but not connected by the isolated bridge sandbox.
- **Latest recorded revision:** 39 civilian cars; upper traffic west/lower east;
  civilian art/chassis scale 1.6, units remain 1.48; median gaps and selected
  defender faction preserved. Rotated chassis use conservative axis-aligned
  slabs; civilian open doors remain visual. V3 diagonal attacker placement
  supersedes the intermediate lengthwise-arrival README entry.
- **Reason for scale correction:** people looked too large relative to vehicle
  length/width. The request was not to make sports cars taller than humans.
- **Next:** review final live revision and owner acceptance; preserve these distinctions.

## 20260913-standards-01 — preserve accepted visual baseline

- **Historical events:** Harold approval 2026-09-10; unit standard 2026-09-11.
  **Recovered:** 2026-09-13. **Type:** ACCEPTED STANDARD / CORRECTIONS.
- **Sources:** [Map standard](MAP_BUILDING_STANDARD.md),
  [unit art standard](UNIT_ART_STANDARD.md).
- **Accepted:** Harold through 139d10c is the reusable map visual baseline.
  Drawn gritty pixel art and elevated tactical perspective are current.
- **Corrections:** clothing must not distort accepted anatomy; shoulders/hips
  remain joined; weapons/grips keep identity across facings. Use believable
  thickness, materials, ground contact, small signs, worn graffiti and solid
  full-height Harold stoop sides. Appearance and physical cover must agree.
- **Reason:** repeated visual feedback established these as production criteria.
  Assistant inspection must catch visible defects before presenting work.
- **Limit:** neither numerical checks nor an existing asset imply new owner approval.
- **Next:** use the linked standards and actual accepted references for relevant work.

## 20260913-sandbox-01 — current scope and model distinctions

- **Historical milestones:** 2026-09-12–13. **Recovered:** 2026-09-13.
- **Type:** IMPLEMENTED STATE. **Status:** DOCUMENTED; LIVE ACCEPTANCE VARIES.
- **Sources:** current Project Control, sandbox README and fleet README.
- **State:** regular roster 23 factions / 115 outfits; five fixed classes;
  30 models within classes; guide pairings illustrative. Unit tiers are independent
  of weapon tiers. Armor modifies HP by 15/30/50% and leaves outfits unchanged.
  Current fleet count is 75; earlier 40/46/60/73 counts are history.
- **Rules:** seats include actual drivers; ordinary resource cargo belongs to
  Heavy Transports. Faction recommendations impose no sandbox restrictions.
- **Scope boundary:** isolated battle sandbox/Encounter Lab functionality does
  not imply full campaign dispatch, economy, battle-outcome or route integration.
  Two-wheeler riding and Whittaker Estate remain recorded follow-ups.
- **Next:** finish current sandbox priorities; do not reopen older completed
  roster integration or introduce deferred systems without current direction.

## 20260913-combat-01 — combat outcomes, authority and regression caveat

- **Historical evidence:** 2026-09-10–11. **Recovered:** 2026-09-13.
- **Type:** BEHAVIOR CONTRACT / VALIDATION LIMIT. **Status:** RETAIN; RECHECK GATES.
- **Sources:** arsenal production report, attacker-tactics follow-up and
  relative-strength AI document.
- **Contracts:** continuous real-time combat; no elapsed-time winner. Test
  observation cutoffs are not defeat conditions. Player orders retain authority.
  Defender pushes respond to assessed advantage; they are not a timed script.
  Sniper damage follows quality/trauma/vitality, not automatic second-wound death.
- **Reason:** owner wanted better attacker chances and contextual combat without
  fabricated outcomes; documented tactical fixes avoid attacker-only stat bonuses.
- **Validation gap:** historical arsenal notes list 166 core assertion failures
  versus 120 before that checkpoint; later resolution was not established by the
  recovery. Do not call these fresh current failures or claim all current gates green.
- **Next:** inspect latest relevant evidence when taking over. Broaden testing
  only to resolve a concrete risk or required gate.

## 20260913-workflow-02 — prompt completion and explicit push approval

- **Date/type/status:** 2026-09-13; USER INSTRUCTION; ADOPTED.
- **Source:** Brandon in this chat: finish work and report as soon as possible
  without compromising it; explicit approval to commit/push to LeadLasso GitHub.
- **Reason:** prolonged cleanup after completion reports caused frustration.
- **Rule:** acknowledge new notes/status questions promptly, update at least
  every minute when control is available, report blockers immediately, and stop
  optional checks once the concrete risk is covered. Distinguish work, tests,
  commit and push status.
- **Scope:** the pending startup/Hive Mind/journal files, the attached handoff
  archived in this repository, and the two referenced bridge reports.
  Bridge/performance source and unrelated working-tree changes are excluded.
- **Authorization:** verified origin https://github.com/LeadLasso-LL/DEADSTREET.git,
  branch build/arsenal-checkpoint-20260911. The prior automatic review rejected
  commit/push because it could not verify destination authorization; this direct
  approval supersedes that gap. No need to request the same approval again.
- **Validation/checkpoint:** documentation links and scoped whitespace checks
  precede commit; no gameplay tests are needed or claimed. Exact commit and push
  state are verified from Git and the remote branch, not a self-referential hash.

## 20260913-transfer-02 — final Idea Repository handoff received

- **Date/type/status:** 2026-09-13; COORDINATION / REVIEWED EVIDENCE; TRANSFERRED.
- **Source:** Brandon's attached handoff, preserved at
  [handoffs/DEAD_STREET_BUILD_HANDOFF_2026-09-13.md](handoffs/DEAD_STREET_BUILD_HANDOFF_2026-09-13.md);
  live performance and bridge V3 reports were also read.
- **Supersedes:** pending ownership in 20260913-transfer-01 and intermediate
  performance numbers in 20260913-performance-01.
- **Live state:** gameplay HEAD e2c9a1374c5f82336126c59becc9d59a9d5090d3 on
  build/arsenal-checkpoint-20260911; bridge/performance source remains uncommitted.
  The handoff reports no further build operation intentionally running.
  Continuation ownership transfers here.
- **Prior evidence:** 16-unit mean simulation update 29.67 → 12.80 ms. Normal
  playable 24-unit run averaged 34.46 FPS, P95 frame 43.44 ms, max 231.07 ms.
  Simulation pause raised the scene to 60.42 FPS. 1,434 focused assertions passed
  in the prior pass. Reviewed, not rerun here; stable 60 FPS, full-project
  validation and final bridge-art acceptance remain open.
- **Preserve:** static civilian-car art plus cover/collision; defender position
  search pacing with immediate context triggers; existing shotgun/SMG staged
  advances. Precomputed multi-hop routes and fixed-rate/interpolated simulation
  remain unimplemented.
- **Next:** one measured simulation bottleneck in the normal 24-unit bridge battle,
  existing relevant checks and matched playable comparison, then prompt report.

## 20260913-creative-01 — creative context preserved from final handoff

- **Date/type/status:** recovered 2026-09-13; HISTORICAL DECISIONS / CONCEPTS.
- **Source:** archived handoff section 12; accepted assets not re-audited here.
- **Reported accepted:** Silvio Ventresca unit and portrait; age 63, gray hair with
  white streaks, trimmed mustache, compact smoky gold-framed sunglasses, open
  brown blazer and cream shirt. Preserve corrected arms, folds and neck.
- **Portrait direction:** rough drawn/pixel identity, candid evidence photos,
  white borders and handwritten names, varied faction-specific settings.
  Authority leaders use official department plaques/portraits; TRC is military
  styled. Do not infer that every generated asset is present or inspected.
- **Concepts:** end-turn helicopter zoom-out with subtle rotors, staticky pilot
  gibberish and possible police-camera treatment; implementation unverified.
  Player-created factions are later work; detailed customization rules were
  not recovered and must not be invented.
- **Next:** locate accepted assets/topic notes when relevant; these concepts do
  not displace the immediate performance priority.

## 20260913-performance-02 — remove redundant collision and connectivity work

- User authorized implementation now after discussing inefficient prototype wiring.
- Fresh normal 24-unit baseline: 30.15 FPS, P95 52.98 ms, max 248.72 ms.
- Scope: internal vehicle collision profile reuse with live dimension checks, conservative segment rejection, exact-point navigation component reuse. Public profile ownership and exact collision tests retained.
- Validation and matched before/after evidence are being saved under tools/bridge_perf/next_pass. This entry records work in progress; final results follow.

- Follow-up finding: first native before/after did not establish an FPS improvement; same-process collision comparisons were 62.2-64.0 ms original versus 39.7-40.5 ms optimized with identical hits.
- Discovered pre-existing untyped empty-array assignment in obstacle grid queries. Assertions passed despite script errors; runner now rejects script errors in logs. Fixed typed empty-cell return and added explicit empty-cell tests.
- Pressure observation now prepares its valid roster once per refresh and reuses pair distance checks without pacing or changing pressure formulas. Exact snapshot comparisons cover immediate position, life/wound, side and deployment changes.

- Further measured cleanup: terminal checks inside every unit iteration repeat full side/deployment assignment validation. Combat now rechecks before the first actor and after every executed shot, before another actor acts. Force-frame initialization reuses the existing scoped geometry validation. Full deterministic replay and immediate-terminal-stop comparison are required before accepting this change.

## 20260913-performance-03 — verified cleanup and continuation

- Supersedes the in-progress status in performance-02. Final fresh native result: 30.15 -> 42.34 FPS; P95 frame 52.977 -> 31.842 ms; worst frame 248.724 -> 292.985 ms. Stable 60 FPS and severe hitches remain open.
- Fixed-step mean: 22.706 -> 16.745 ms (26.3% less simulation time); identical 19 survivors, 13.392 damage, 18 moved and 13 occupied covers.
- 5,947 scoped checks and 1,215 exact replay checks passed; the 24-unit replay matched 600 updates and the terminal fixture resolved on the same sixth update without an extra action. Final test/native logs contain zero script errors.
- The initial native trial did not improve FPS; it remains recorded. Same-process collision and pressure comparisons isolated real savings. A pre-existing empty-cell typed-array error was then found and fixed; prior assertions alone missed engine errors. The persistent run_checked.py gate rejects them.
- Source/records checkpoint includes inherited bridge/performance changes plus this pass, excluding older character-factory/dusk work and unrelated imports. Standing authorization in PROJECT_WORKFLOW_AUTHORIZATION.md applies. Exact commit/push status is verified from Git.
- Next: remaining combat/target selection and worst-frame spikes in normal 24-unit gameplay. Details/evidence: tools/bridge_perf/RUNTIME_CLEANUP_2026-09-13.md. No claim of full core-suite acceptance, final art acceptance or final convoy-cap approval.


## 20260913-headroom-01 ? steady FPS and expansion headroom

- **Source/status:** Brandon explicitly requested proceeding on 2026-09-13. APPROVED technical goal.
- Reach steady 60 FPS for the existing battle and identify scaling bottlenecks so larger battles remain possible. This does not approve a specific new convoy/personnel cap.
- Starting checkpoint: 613bbabb4d7d642bdaeb008e4ad272530ff53fd5, pushed. Last measured native 24-unit average 42.34 FPS, worst frame 292.985 ms.
- Current work: receiving chat traces frame stalls and per-function cost, then checks unchanged combat behavior and measured headroom.

- Profiling finding: new path endpoints caused the largest traced stall; repeated source/equipment/eligibility queries consumed routine work. Initial prepared-target/BVH/broad-phase pass matched 1,215 replay checks and measured 48.65 FPS, but worst frame was still 345.083 ms. This is an intermediate result, not steady-60 acceptance. Weapon definitions are now prepared once per synchronous runtime update; a separate test-only fixture permits larger-roster measurements while production MAX_UNITS stays 12 per side.

- Low-overhead trace separated pathfinding spikes from presentation stalls: several 150-245 ms frames had only 11-25 ms simulation work. Renderer comparison was slower (Compatibility 44.75 FPS), so renderer/settings remain unchanged. Found synchronous wound-anchor/blood-mask loading in the actor presenter. Preparing selected actors\u2019 assets and known navigation endpoints before combat; route queries now use a legal upper bound to prune provably unnecessary endpoint visibility checks, with full-search fallback. Per-actor shot-history scans are consolidated per refresh. Validation pending.

- Route/asset pass: native 24-unit 54.86 FPS, max 78.383 ms; native 32-unit 36.72 FPS, max 92.925 ms; both had zero >100 ms frames in those samples. Further target ordering/readiness reuse reached 57.18 FPS at 24 units, max 127.931 ms (one >100 ms frame). 4,049 focused checks including uncached route comparisons and 1,215 replay checks passed. The 60 FPS/headroom objective remains open. Current follow-up prepares vehicle transforms once per synchronous update; no lower simulation/AI update rate is introduced.

- Reachability now reuses prepared connectivity/endpoints (4,526 focused and 1,215 replay checks passed; actor comparison passed 1,202 checks across 11 observed clips). Native 24-unit sample varied down to 54.53 FPS despite the fixed-work speedup; steady 60 is not established. Further inspection found repeated vehicle-pose string formatting and fresh combat role/weapon-baseline allocations. These are now prepared per synchronous update with standalone ownership and between-update invalidation retained. Validation pending.

- Native presentation profile (32 units): runtime about 14.2 ms/update, actor presentation plus dynamic drawing about 2.5 ms/frame. Cover candidates now fail unchanged range/progress rules before expensive evaluation. Latest 24-unit sample 59.39 FPS, P95 19.031 ms, max 46.426 ms: close to 60 but not steady. Adding a conservative LOS rectangle index (exact hit tests retained) and bounded two-generation LOS/reachability caches; the prior caches grew without limit as units moved. Validation pending.

### 20260913-headroom-02 — verified checkpoint; release comparison blocked
- Status: implemented/validated performance gains, overall 60 FPS/headroom goal open.
- Source: current receiving chat; owner explicitly requested 60 FPS and expansion room.
- Normal native results: 24 units 59.05 FPS / P95 19.143 ms / max 46.517 ms;
  32 units 48.55 FPS / P95 24.651 ms / max 58.916 ms.
  Neither sample exceeded 100 ms. Uncapped 24 units 61.31 FPS, 32 units 55.03 FPS.
  Matching 24-unit Bulwark convoy sample 59.03 FPS.
- 11,022 focused/replay/actor checks passed; reference reconstruction matches tested oracles.
  See tools/bridge_perf/HEADROOM_2026-09-13.md and headroom/results.json.
- Automatic approval review rejected downloading/running the official matching release
  executable: externally sourced binary/supply-chain risk, no explicit authorization.
  Nothing was downloaded or executed by that rejected action. Existing Git push approval remains valid.
- Owner reported a stale “preparing vehicle collision cache” status for 20+ minutes.
  Corrected the visible plan: collision caching was already complete. Keep task status current
  and do not label substantive work complete while measured performance goals remain open.
- Next: explicit release-runtime download/execution authorization, then 24/32 capacity
  comparison and remaining frame-cost work. No promised release-build FPS result.
- Scoped checkpoint/push follows under existing authorization; preserve unrelated work.

### 20260913-release-01 — executable approval and release comparison
- Source/status: Brandon replied Approved to the explicit official release-runtime download/execution request. APPROVED; comparison IN PROGRESS.
- Downloaded the matching official 4.7.2 template; ZIP integrity checked and SHA256 recorded in tools/bridge_perf/headroom/release_provenance.json. Runtime probe confirms official hash ed1daf0bf001b61586d9930840f2f1394092c079, debug=false and editor=false.
- HTTP ranges failed with 501; full archive download succeeded. Official templates reject development path/script overrides, so the benchmark now launches through an adjacent PCK with existing code/imported assets. Production project settings are unchanged.
- First packaged native sample failed validation on a missing root icon.svg. Corrected the lightweight launcher package; the failed run is not accepted as clean evidence.
- Comparing both runtimes against the same package, including uncapped samples and display metadata. Results and final status follow; the 60 FPS/headroom objective remains open until measured.

- **Final status:** release comparison and bounded stability repeat COMPLETE;
  the overarching 60 FPS/headroom objective remains OPEN.
- Clean release 24 normal 59.87 FPS; 32 normal
  58.66 FPS, repeat 59.78 FPS. Same-package
  uncapped 24 developer 73.33 versus release 85.59 FPS; variable
  battle evolution prevents interpreting that as a precise causal speedup.
- Later 32-unit uncapped samples deteriorated in active, paused and setup work.
  Repeat release recovered to 63.64 FPS but P95 remained
  19.185 ms. AC power/healthy GPU clocks and background sync
  activity were sampled; the original slowdown's cause was not proven.
- 11,022 explicit checks passed in release; no disabled-assert dependency.
  Final selected native/check logs pass the script/engine-error gate. Preserved
  both successful and unstable measurements in headroom/release_results.json.
- Added two-stage package/comparison tools, bounded repeat telemetry and build/
  display metadata. Fixed normalized log writing. No production game settings,
  gameplay, art, cadence or force limits changed; inherited runtime/art work stays
  outside this checkpoint. Source metadata documents the mixed working tree.
- This entry/evidence belong to the scoped release-comparison checkpoint; Git
  records its exact commit and remote state under standing push authorization.
- **Next:** Profile the 32-unit release battle during its slow windows, isolate the remaining simulation cost from system-load variation, and remove that cost while preserving combat behavior. Judge the next change by frame-time tails and full-roster windows, not the overall average alone.

### 20260913-slowframes-01 — 32-unit release frame costs
- Source/status: Brandon requested continuation. IN PROGRESS; receiving chat owns this pass.
- Reusing the approved official release runtime/data pack. Test-only source overlays instrument coarse runtime and presentation phases; production files remain unchanged during measurement.
- Capture frame timing with live actor counts to avoid treating casualty-reduced averages as full-roster capacity. Next: measured bottleneck, behavior checks and matched uninstrumented samples.

### 20260913-slowframes-02 — controlled release targeting checkpoint
- Source: Brandon requested continuation toward 60 FPS plus battle expansion headroom; standing GitHub authorization applies.
- Measured: combat behavior dominates simulation (4.117 ms/frame); targeting contributes 1.576 ms. Initial wrapper loading failures and idle trace were rejected; final coarse trace is valid.
- Changed: range culling before assault-target ranking, preserving target priorities and cadence. First eligibility-hoisting trial was revised after worse native results.
- Verified: 8,605 focused + 1,215 exact replay checks; 600-step simulation 3479.594 to 3349.690 ms. Identical rendered 32-unit battle 61.062 to 65.966 FPS, simulation 9.726 to 8.781 ms/step; same recorded final state and 1213 full-roster frames.
- Limits: P95 stayed about 18.4 ms and P99 worsened. Normal variable-step runs varied from 64.660 to 48.154 FPS. The narrow CPU improvement is accepted; stable 60 and normal-game variability are NOT resolved.
- Preserved unrelated working changes. Added reproducible fixed-rendered comparison and retained failed/slow evidence. See tools/bridge_perf/slow_frames/README.md.
- Next: Use the fixed-step rendered benchmark to isolate the remaining combat/cover validation cost and frame-time tails, then verify gains in the normal variable-step game. Steady 60 FPS and larger-battle headroom remain open.

### 20260913-cover-close-01 — bounded pass before returning to sandbox
- Source: Brandon approved continuation and explicitly wants to move on from performance.
- Receiving chat owns a bounded combat/cover optimization plus a normal current-scale play check. Do not turn this into another open-ended expansion benchmark campaign.
- Identified a retained-closing-cover check that computes full LOS/weapon-range data but consumes only legality and directional protection. Preserve behavior while eliminating unused queries; document any remaining frame-time limitation before returning to sandbox work.

### 20260913-cover-close-02 — performance parked; sandbox resumes
- Source: Brandon's explicit preference to move on from performance. Dedicated optimization is PARKED after this bounded pass; steady 60 FPS/expansion headroom are not claimed complete.
- Implemented: cheap legality/protection predicate for retained closing cover; movement invalidation precedes no-role-cover context/LOS key construction. No cadence or art changes.
- Validated: 3,330 predicate comparisons + 1,215 exact replay checks (4,545 total), zero errors. Isolated query 78.775 to 19.310 ms for 3,000 calls; same-state 600-step simulation 3430.850 to 3348.143 ms.
- Normal 24-unit release: 59.670 FPS; P95 17.028 ms, P99 21.596, max 33.297; zero frames over 33.333/100 ms. One five-second window was 57.90 FPS. This is usable development evidence, not perfect frame-pacing acceptance.
- No additional 32-unit or broad actor/core suite. Prior larger-battle variability remains open. Preserve the already-dirty combat behavior and other unrelated working files; stage only this pass's two behavior hunks.
- Evidence/reproduction: tools/bridge_perf/cover_close/README.md. Scoped commit/push under standing authorization follows; Git records the exact checkpoint.
- Next: Return to the Whittaker Estate sandbox map: recover its agreed design brief and begin its first build pass. Keep remaining frame-pacing and expansion-headroom work on the backlog unless current-scale play regresses.

## 2026-09-13 — HUD/control redesign approved; implementation started

Source: Brandon, receiving build chat. OWNER-APPROVED DESIGN in
[TACTICAL_CONTROLS_2026-09-13.md](TACTICAL_CONTROLS_2026-09-13.md).
Approved all proposed controls, selected-group Clear Orders, stable living-first
roster, class/Select All shortcuts and ownership-derived filled order badges.
Whittaker Estate deferred; dedicated performance work remains parked.
This chat owns HUD, player orders and required runtime/view integration. Existing
unrelated participant/view hunks and asset/tool work will be preserved.
Implementation and native validation are pending; no acceptance claim.

## 2026-09-13 — HUD/control implementation and release validation

IMPLEMENTED / VALIDATED, owner playtest acceptance pending. Full friendly deck,
stable living-first order, approved monochrome class icons, class/Select All,
Shift/box selection, selected Hold/Push/Fall Back/Clear Orders, independent target
and positioning intent, explicit position persistence, order badges and overlays,
battle-local pause/0.5×/1×/1.5× beside audio. Fixed projected ground coordinates.
Wounded units remain visible/selectable; their established survival behavior
interrupts explicit commands. No force-cap or performance setting changes.

Evidence: tools/tactical_controls — 63 order/runtime checks and 39 native UI/input
checks passed in official release Godot 4.7.2, zero script/engine errors. All 24
actors rendered, all 12 friendly cards visible at 1440×1000. Initial Button property
collision fixed; test event coordinates corrected for viewport/window stretch.
Five-second commanded smoke was 59.91 FPS, not a comparable benchmark or sustained
performance acceptance. No new broad suite or 32-unit campaign.

Preserve pre-existing participant/view and unrelated work; this checkpoint owns
only its source hunks, new HUD/test files and records. Scoped commit/push follows
under standing authorization; Git records the exact checkpoint.
Next: Brandon's HUD/control playtest and requested changes, before Whittaker Estate.

## 2026-09-13 — Owner HUD review, second pass (IMPLEMENTED / VALIDATED)

Source: Brandon's review of the mobile screenshot and follow-up emblem spacing note.
Approved changes: remove selection/destination/target ground circles; selected floating
emblems get a yellow ring and glow. Bring badges modestly closer to heads. Transport
buttons become fixed pause bars, double left triangles, play triangle, double right
triangles, with both Emblems and Audio toggles to their right. Remove persistent
selection/manual hints and redundant pause/speed text. Show counts only at the left
of the roster header (green active number, red eliminated number, neutral words);
move faction name and emblem immediately left of relative strength. Redraw pistol
silhouette. Existing living-first roster and group-order marker rules remain accepted.

Found: static bridge traffic uses 1.6× art and geometry, while fleet art/body profiles
still use 1×. Correct the shared fleet tactical scale, including body/door/cover
consistency; retain the already approved traffic size and campaign stats.
146 native GUI/vehicle checks passed in official Godot 4.7.2 release, no errors.
Fixture: 12-v-12 bridge, Aegis/Vigil/Aegis versus Bulwark/Interceptor/Bulwark.
Checks include shared fleet/road footprints, collision-cache consistency, nonoverlap,
all attacker disembark routes, selection-emblem ownership and clearing, toggles,
GUI playback/selection/order input, pause and camera. All 12 friendly cards fit.
See tools/tactical_controls/native.json, native.log and hud_revision_*.png.
No broad optimization or benchmark pass; original core order checks not rerun.
Owner visual/playtest acceptance remains pending. Dedicated performance work stays parked.
Scoped commit/push uses existing authorization; unrelated working changes are preserved.
Next: Brandon reviews the revised HUD, emblem spacing and fleet size before Whittaker Estate.

## 2026-09-13 — Aligned faction and strength header (IMPLEMENTED / VISUALLY CHECKED)

Source: Brandon liked the revised HUD and requested the faction emblem/name and
relative strength to fill the upper-right space after the Sniper selector as two
aligned fields, with a thin white divider. Faction emblem grows from 26 to 38;
name uses larger wrapping type. Strength label grows and its thicker meter sits
lower. Both fields use the available header height without overlapping cards or
class selectors. This changes layout only. Native screenshot reviewed at 1440×1000 in official Godot 4.7.2 release with
zero script/engine errors: `tools/tactical_controls/hud_header.png` and
`header_preview.log`. No combat/performance suite rerun for this layout change.
Next: owner review before Whittaker Estate.

## 2026-09-13 — Tactical command revision discussion (REQUESTED / PROPOSED)

Source: Brandon's conversational design review. Recording remains paused; no command
implementation is authorized by this discussion-only request for feedback.

Requested correction: Hold should seek nearby reachable cover that provides protection
against relevant enemy directions, then hold there; stationary exposed freezing is rejected.
Proposed Push/Fall Back interaction: a translucent thick vertical line clipped to traversable
battlefield ground, positioned left/right with mouse input; green for Push, red for Fall Back.
Click commits; brief brighter confirmation then quick disappearance. Push advances up to
that boundary, Fall Back retreats to it or behind. Units retain tactical cover/firing/survival
behavior. Proposed Hold acknowledgement is a brief faded gray circle at recipient units;
this is a transient cue, distinct from the previously rejected persistent ground rings.
Orders should have audio acknowledgement. Card bottom-right labels: Pushing (muted green),
Falling Back (muted red), Holding (muted gray). User wants labels cleared on release,
arrival at the relevant line, wounds or elimination. Existing group markers versus replacement
by labels needs explicit treatment; do not silently ship redundant status systems.

Assistant recommendations/concerns (PROPOSED, not owner-approved): keep selection scope;
retain existing useful cover on Hold, rank reachable protection and exposure rather than
raw distance, reserve distinct cover slots, and handle unavailable cover without reckless
crossings. Treat line as a tactical limit with cover destinations nearby rather than a
literal parade line; account for faction advance direction and weapon roles. Prefer horizontal
pointer placement with wheel zoom retained and right-click/Escape cancel. Clarify arrival
semantics: label completion should correspond to a safe destination, and unrestricted AI
must not immediately reverse a retreat. Consider transition to a visible Holding state on
arrival; this differs from the requested text disappearance and requires agreement.
Acknowledge orders once per selected group rather than overlapping every unit's voice;
never report failed orders as successfully received. Individual replacement, wounds and
death still remove that unit from the old order. Next: conversational agreement on these
semantics before implementation; recording and Whittaker Estate remain deferred.

## 2026-09-13 ? Owner-approved asymmetric order completion (DESIGN APPROVED; NOT IMPLEMENTED)

Source: Brandon's follow-up to the tactical command discussion. Fall Back becomes
Holding per recipient after reaching a suitable position on the friendly/near side
of the chosen line. Push ends after each unit completes a meaningful role-appropriate
advance: close-range units seek suitable cover nearer the forward line, while snipers
advance to an appropriate position farther behind it. Completed Push releases that
unit to normal combat AI and removes its Pushing status. Completion is individual;
there is no requirement to wait for every selected unit. This supersedes the assistant
proposal that both movement commands should become Holding. Hold itself remains the
approved next-design correction: seek useful directional cover rather than freeze
exposed in place. These are design decisions, not claims of implemented behavior.

Implication discussed: after Push completes, normal AI can advance beyond the former
line when appropriate; the Push line constrains that active movement order, not all
future autonomous movement. A sniper already behind the line must not immediately
complete without the requested meaningful advance where a viable advance exists.
Recording remains paused during this discussion. Next: finish command design agreement
before implementing the revision or staging the requested battle recording.

## 2026-09-13 ? Cover-aware line commands (IMPLEMENTATION STARTED)

Brandon approved starting the command revision after agreeing Fall Back becomes
Holding at friendly-side cover, while Push releases each unit after its own meaningful
role-appropriate advance. Scope: cover-aware Hold, directional line placement/confirmation,
per-unit completion and interruption, text card statuses, transient Hold cues and command
audio. Existing role combat, reservations, pause and selected-unit scope remain authoritative.
Scripted recording explicitly deferred. Native behavior/UI verification and scoped Git
checkpoint follow implementation; owner acceptance remains pending.


## 2026-09-14 — Cover-aware command implementation (IMPLEMENTED / VALIDATED)

Source: Brandon approved starting the revised controls after the Hold/Push/Fall Back
conversation and paused the scripted recording. Implemented directional line placement,
protective cover planning, staged movement, per-unit asymmetric completion, interruption,
live text statuses, brief Hold pulses and muted procedural order/receipt audio.
Canonical behavior and limits: [Tactical controls](TACTICAL_CONTROLS_2026-09-13.md).

125 command checks and 43 native UI checks passed in official Godot 4.7.2 release,
zero final errors. Real Push and Fall Back navigation completed without teleporting;
weapons were held on cooldown in that fixture to isolate movement from casualties.
Own occupied-cover reservation rejection was found and fixed. An invalid retreat
behind all available starting cover failed visibly as intended; valid placement passed.
Native captures were reframed and line contrast improved after visual inspection.
No broad performance campaign was reopened. No spoken faction voices were added.

Updated Hive Mind, Project Control, topic rules and reproducible evidence. Scoped
commit/push uses the existing LeadLasso-LL/DEADSTREET authorization; Git history is
its receipt. Unrelated victory/character-factory/dusk/source-recovery work is preserved.
Owner acceptance remains pending. Next: Brandon playtests the new battle commands;
scripted recording and Whittaker Estate remain on hold.


## 2026-09-14 — Stateline Raiders / NBPD recording (IN PROGRESS)

Brandon resumed the scripted battle request: Stateline Raiders attacking NBPD; use
commands only when tactically appropriate. Recording uses the existing bridge arrival,
ordinary opposing AI/combat outcome and aftermath. Full 12-v-12; faction-preferred
pickup convoy versus police/SWAT vehicles. A seeded pacing pass resolves naturally.
No production balance or artwork changes are in scope. Deliver a mobile-shareable MP4.


## 2026-09-14 — Raiders motorcycle convoy grouping (PROPOSED; RECORDING PAUSED)

Source: Brandon interrupted delivery of the Stateline/NBPD video to discuss faction-specific abilities. Proposed Stateline Raiders ability: up to three motorcycles occupy one convoy slot. Desired 12-person arrival: three cruiser motorcycles, one pickup with six people, then three more cruiser motorcycles; six riders total plus six people in the truck, including its driver. This means three convoy slots but seven physical vehicles. Each motorcycle should retain its own cost, capacity, driver and physical footprint; grouping changes convoy slot accounting rather than merging bikes into one vehicle.

Current fleet facts read during this recording pass: Ironhorse/Longhaul/Cinder motorcycles each have two-person capacity; Mesa Crew has five, Workhorse C10 three. The exact six-rider/six-truck-passenger split is not legal with those current pickups. A six-person pickup/bed-seating configuration is a proposal, not an approved capacity change. An existing-capacity alternative is five in the Mesa and seven across six two-seat bikes. Motorcycle arrivals currently use parked presentation; grouped moving/ridden arrivals and dismounting would require additional work. No convoy, capacity, animation or faction balance changes have been implemented.

The original pickup-only battle has been captured; delivery/re-recording remains paused while this design is discussed. Next: settle grouped bike convoy behavior and seating, then implement the approved scope before producing the revised recording. Unique abilities for other factions remain an open design direction.


## 2026-09-14 — Raiders arrival/audio direction (OWNER-APPROVED DESIGN; NOT IMPLEMENTED)

Brandon confirmed one of the six motorcycles carries a passenger, giving seven people across the bikes and five in the Mesa pickup for this 12-v-12. He explicitly wants visible passengers in pickup beds and the convoy actually arriving in the proposed order: a clustered trio of biker-style motorcycles, pickup, second clustered trio. Suggested implementation allocation for this recording is three occupants in the cab including the driver and two in the bed, retaining five total pickup occupants. This does not authorize silently increasing all pickup model capacities. One bike visibly carries both its rider and passenger; all arrivals require coherent riding, stopping and dismount/climb-down presentation with individual cover routes.

Approved audio direction: muffled heavy metal, particularly heavy distorted electric guitar, sounding like the Raiders convoy radios. Reference is the diegetic/muffled hip-hop already associated with Mercer Saints apartments. Add muffled police sirens localized to the NBPD blockade. Suggested mixing is source-positioned approach/falloff with restrained levels under combat reports and vocals. Exact riff and mix remain subject to listening review.

This supersedes the prior six-person pickup requirement for this recording: the chosen split is seven motorcycle occupants plus five pickup occupants. Faction-specific three-motorcycles-per-convoy-slot grouping remains the design basis, with individual physical vehicles. The existing pickup-only video is retained but delivery remains on hold during this design discussion. Next implementation scope is grouped motorcycle convoy slots, the approved passenger arrangement, riding/bed-passenger arrival presentation and these audio layers, followed by a revised battle recording. No such implementation is claimed by this entry.


## 2026-09-14 — Raiders convoy implementation started

Brandon explicitly instructed implementation and delivery, no further confirmation. Scope: three motorcycles per Raiders convoy slot, six Ironhorse bikes in two staggered trios around one Mesa pickup; seven bike occupants (one pillion) and five truck occupants (three cab/two bed). Preserve every vehicle's individual capacity, cost and body. Build moving/ridden arrivals, dismounts and bed climb-down; original muffled guitar radio and NBPD-local sirens. Then re-record the natural 12-v-12 using tactically justified commands and deliver an audio MP4. Prior pickup-only video retained as superseded evidence. Performance and Whittaker remain parked. New shared manifest is implemented locally; native validation pending.


## 2026-09-14 — Raiders grouped convoy, arrival and recording (IMPLEMENTED / VALIDATED)

Brandon explicitly said to proceed without further confirmation. Implemented three consecutive motorcycles per Stateline convoy slot; distinct vehicles/costs/drivers/capacities remain. Six Ironhorse bikes form two staggered trios around a Mesa: seven motorcycle occupants, one pillion, five pickup occupants including two visibly in the bed. Every rider is an actual participant. Shared sandbox seating and grouped-slot UI are included; this does not impose a new global three-slot limit.

Built moving motorcycle arrival, seated riders from faction heads and code-drawn bent limbs/vests, pillion and bed poses, rear pickup exits and individual navigation to cover. Original synthesized muffled guitar radio follows Raiders transport; two quieter NBPD sirens stay at police vehicles. Ambience honors audio toggle and gunfire ducking. The bridge no longer inherits Harold apartment music.

67 native checks passed: faction-specific slot accounting, capacity/driver/bed validation, all 12 assignments, seven physical vehicle placements, nine visible seated riders, legal dismount paths, clean rider/actor handoff and three localized sound emitters. A headless live battle resolved naturally in 82.7 simulated seconds. Native visual inspection confirmed the formation, pillion and two bed occupants. The recorder camera was lowered to keep the top bike clear of the title banner, then pulls back before combat. No new broad performance campaign.

The final recording uses the normal combat outcome and contextual player orders, not forced damage/winner or a command checklist. Runtime and media details below are the exact receipts. The prior pickup-only recording is superseded and retained locally. Remote command calls twice timed out after executing; read-only report checks confirmed success before proceeding, avoiding duplicate runs.

Rules/source: [Convoy arrival](../tools/convoy_arrival/README.md); [recording reproduction](../tools/raiders_recording/README.md). Owner acceptance of animation, audio and ability balance remains pending. Next: deliver the MP4 and Brandon reviews the arrival, sound and command feel; Whittaker Estate and dedicated performance work remain deferred.

Final movie: 112.64 seconds, combat 82.70 seconds, 312 shot events, 4 contextual orders; H.264/AAC 1920x1080 at 30 FPS; 74.43 MiB; audio peak -6.42 dBFS. SHA256 `08c755f8466de2b622b9d7e321f2d7360fba50be90ebfa9eb3b67277aff6c297`. Zero final arrival/outro route errors. Delivery/save status is reported in the conversation.


## 2026-09-14 — Compact mobile battle export (VALIDATED)

The full-HD master is 74.43 MiB, so a separate 1280x720 H.264 copy was made for phone sharing, preserving the complete 112.64-second recording and its AAC audio. Mobile export decoding passed; file size is 16,269,495 bytes (15.52 MiB); SHA256 `0c80ad890641dd67f6bebe0a62c93fe594caced1a18d10d473d40412f6c663b7`. The full-HD master is retained. Convoy/arrival/audio implementation and records were committed and pushed as `7638a0915f0e1b3f1542d716e9401f6ce0f25937`. Mobile export source/metadata are a separate scoped checkpoint. The next owner task is to review the delivered battle, particularly the arrival, audio and command feel.


## 2026-09-14 — Owner recording corrections (IN PROGRESS)

Brandon rejected the arrival using oncoming lanes, the synthetic guitar timbre and persistent unit route lines. Requested real grungy heavy guitar (Walk by Pantera as a feel reference), slightly quieter sirens and a Raiders victory. Correct west-approach arrivals to the lower eastbound carriageway; preserve bike trio / Mesa / bike trio and the approved 7+5 occupants. Hide persistent route/target connectors while retaining brief command-placement acknowledgements. Sirens reduced 3 dB. The showcase fixture uses tier-3 Raiders against tier-2 NBPD; global combat balance is unchanged. Re-record with a verified Raiders win. Previous clip is superseded, not owner-accepted. Validation and replacement audio are pending.


## 2026-09-14 — Third-party music rejected by owner; delivery paused

Brandon objected to use of licensed material. The assistant had chosen a free CC BY recording to replace the poor synthetic guitar; it introduced an attribution dependency without establishing that third-party music was acceptable. That was an assistant error. The source/processed music and credit overlay were removed from the active build before any commit/push of this revision. The prior original music is retained only as a muted placeholder, because its sound was already rejected. No third-party version is approved for delivery. Treat named music references as sonic direction, not authorization to add third-party recordings.

Preserved completed work: correct eastbound arrival lane, hidden persistent route/target overlays, sirens reduced 3 dB, 102 passed native arrival checks, and a recording fixture with verified Raiders victory. The attempted recording is superseded due to its rejected music. Current immediate task: create suitable original heavy guitar audio and then finish the corrected mobile battle recording. Do not run the prepared finish_revised.py publisher: it describes the rejected third-party version. Performance and Whittaker stay parked.


## 2026-09-14 — Original radio and final Raiders recording started

Brandon instructed completion with original grungy, intimidating heavy guitar and a Raiders win. A new original 102 BPM Drop-C riff uses plucked-string waveguides, a driven/cabinet-filtered amplifier, original bass and procedural drums. No recordings, borrowed samples or external music assets are used. The radio is re-enabled with the new asset; sirens retain the requested 3 dB reduction. Correct eastbound arrival, clean selection overlays and the seeded Raiders-victory fixture are preserved. The rejected third-party version remains excluded. This pass is a new capture/export of the already-verified battle, followed by delivery; no new performance campaign.


## 2026-09-14 — Original-guitar Raiders victory recording (IMPLEMENTED / VALIDATED)

Brandon explicitly directed immediate completion after rejecting third-party music. The final radio is an original 102 BPM Drop-C groove-metal composition, built from plucked-string waveguides, a driven/cabinet-filtered amplifier, original bass and procedural drums. No recordings, borrowed samples or external music are used. The riff is filtered as a vehicle radio; police sirens are 3 dB quieter (-29 dB emitter gain). Source and deterministic asset metadata are in tools/convoy_arrival/build_audio.py and assets/audio/convoy/original_radio.json. The earlier additive riff and the removed third-party attempt are superseded. There is no outside-music credit overlay in the final video.

Corrected eastbound arrivals stay entirely within the lower carriageway, with no oncoming-lane overflow. The six-bike / Mesa formation, pillion and two bed occupants remain. Persistent selected-unit movement paths and target connector lines are hidden; brief command-placement/acknowledgement cues remain. The arrival camera keeps the formation clear of the banner.

The requested Raiders victory is staged through the recording fixture: tier-3 Raiders with reinforced_carrier, versus tier-1 unarmored NBPD. Global combat balance is unchanged; hits, casualties and contextual orders remain live. Seed 9141 resolves in an attacker victory after 68.40 simulated combat seconds, with 230 shot events and 5 contextual commands. The director releases later stale Hold orders as support loses contact. This is showcase staging, not a faction-balance comparison.

Validation: the lane/arrival pass previously passed 102 native checks, including all seven east-facing bodies entirely within y=31..44, legal seating and dismounts. The final capture has zero arrival/outro route errors, three ambient emitters and no final script/engine errors. Full video decode and finite/unclipped audio checks passed. Final visual review checked arrival, combat and result frames. No performance campaign or exhaustive all-map regression was reopened. Audio quality remains subject to Brandon's listening review; numerical checks are not aesthetic approval.

Mobile file: 93.37 seconds, 1280x720 at 30 FPS, H.264/AAC, 13.10 MiB. SHA256 5133f7fc34f9ecddf8cbd29f0fd06be7e7b7aae657b94984b452abd4d8ca4576. Original radio SHA256 88927d68c3fdcf4f9a39afb5043a85f17f0b83ba28978ec921ced51cc4d92043. Source hashes captured before recording are checked before this commit. Earlier recordings are superseded. Commit/push uses standing approval and excludes unrelated work. Delivery/save status is reported in chat.

Next: Brandon reviews the completed original-audio Raiders-victory video. Performance and Whittaker Estate remain parked.


## 2026-09-14 — Sparse heavy radio / battle fade / context alignment started

Brandon rejected the previous 102 BPM radio as busy and arcade-like and the combat music as too loud. Implementing an original 84 BPM Drop-A arrangement with twelve sustained chord attacks over eight bars, fewer percussion hits, retained low end and no lead melody. Radio gain is -18 dB during arrival and explicitly fades down another 14 dB over the final two arrival seconds; sirens keep -29 dB. Requested context change: ATTACKING directly beneath Raiders, aligned with DEFENDING beneath NBPD, and ROAD BLOCKADE at the context box top right. Same Raider-winning fixture, arrival, orders and hidden unit paths. New capture will verify native radio gains and the adjusted context before delivery. Aesthetic acceptance remains pending.


## 2026-09-14 — Sparse low guitar, combat radio fade and matched context roles (IMPLEMENTED / VALIDATED)

Brandon rejected the previous 102 BPM cue as an arcade-like busy melody and reported that the music stayed too loud as the camera revealed combat. That cue and its mix are SUPERSEDED; prior numerical audio checks were not owner acceptance.

The replacement is an original 84 BPM Drop-A composition: 12 chord strikes across eight bars (previously 48), sustained low power chords, two root pitches with no ascending lead melody, half-time percussion, less severe amplifier clipping and retained low body through a 58–2200 Hz radio filter. The longest written sustain is 3.1 beats (2.21 seconds). No outside recordings or samples. Radio starts at -18 dB source gain and fades another 14 dB during the final two seconds of arrival, then stays at -32 dB or lower during ready/combat/outro. Police sirens remain -29 dB. Spatial attenuation and gunfire ducking still apply.

The battle context puts ATTACKING under Stateline Raiders on the same baseline as NBPD's DEFENDING. ROAD BLOCKADE is right aligned at the top of that box, in both compact and expanded layouts.

Native capture validates the explicit fade, with samples: [{"arrival_clock": 5.99999999999999, "battle_mix": 0.0, "gain_db": -18.0, "movie_seconds": 6.0, "phase": "arrival"}, {"arrival_clock": 10.5, "battle_mix": 0.0758111102681216, "gain_db": -19.0613555908203, "movie_seconds": 10.5, "phase": "arrival"}, {"arrival_clock": 11.5, "battle_mix": 0.743501940722106, "gain_db": -28.4090270996094, "movie_seconds": 11.5, "phase": "arrival"}, {"arrival_clock": 12.1666666666666, "battle_mix": 1.0, "gain_db": -32.0, "movie_seconds": 13.0, "phase": "active"}, {"arrival_clock": 12.1666666666666, "battle_mix": 1.0, "gain_db": -32.0, "movie_seconds": 20.0, "phase": "active"}]. The same seed 9141 and disclosed veteran/armor showcase advantage yield a Raiders victory after 68.40 simulated seconds. There are 5 contextual commands and 230 shot events. Correct road-side entry, six bikes/pickup, pillion/bed riders, hidden movement paths and quieter sirens are preserved. Zero arrival/outro route errors and no capture script errors. Full master/mobile decode and finite, unclipped audio checks pass. Visual review of context and final result is performed for delivery; audio timbre remains subject to Brandon's listening approval. No additional performance or all-map regression campaign.

Current mobile recording: 93.37 seconds, 1280x720/30 FPS H.264/AAC, 13.18 MiB; SHA256 1ad5ab6d64e40239bff9500eba1030e3b3fef20416d5cf45ceb57eebd656fd2a. Radio SHA256 3550e3f8b6231f6815c2383a94404255752456a21b603fcbd8724d54f1952981. Sources are guarded by heavy_radio_source_hashes.json. This replaces the previous delivered recording. Commit/push uses standing authorization and excludes unrelated work.

Next: Brandon reviews the revised recording's guitar weight, quieter combat mix and context layout. Performance and Whittaker remain parked.


## 2026-09-14 — Winner music takeover / extended victory cards started

Brandon approved restoring Raiders metal to intro level for the ending animation and keeping it up through five additional seconds of victory cards, with quieter sirens behind it. General design rule APPROVED: every battle has faction-associated entering and defending audio; music recedes for combat, and the winning faction takes over the victory-card outro regardless of attacker/defender role. This pass implements the existing Raiders convoy source takeover and preserves the current original riff. It does not claim every faction has a completed music asset or legacy emitter integration. Winner radio will return to -18 dB and transition from positional ambience to centered foreground so the distant convoy does not keep it quiet. Defeated/background sirens remain audible at their existing lower gains. The recording card hold grows from outro duration +6 to +11 seconds.


## 2026-09-14 — Winner music takeover / extended victory cards plus result labels resumed

Brandon approved restoring Raiders metal to intro level for the ending animation and keeping it up through five additional seconds of victory cards, with quieter sirens behind it. General design rule APPROVED: every battle has faction-associated entering and defending audio; music recedes for combat, and the winning faction takes over the victory-card outro regardless of attacker/defender role. This pass implements the existing Raiders convoy source takeover and preserves the current original riff. It does not claim every faction has a completed music asset or legacy emitter integration. Winner radio will return to -18 dB and transition from positional ambience to centered foreground so the distant convoy does not keep it quiet. Defeated/background sirens remain audible at their existing lower gains. The recording card hold grows from outro duration +6 to +11 seconds. Additional owner requests: both result cards show living Units Remaining (including wounded); an explicit terminal retreat outcome adds Retreated from battle. Tactical retreat execution is not currently wired, so this adds preserved outcome metadata and result presentation without inventing retreats. The intro uses NEW BRIARPORT POLICE DEPARTMENT on two readable lines, crossfading to NBPD as the context contracts. The first capture was stopped to include these incoming requests; this resumed capture includes all of them.


## 2026-09-14 — Winner music takeover / extended victory cards plus result labels and equipped HUD weapons resumed

Brandon approved restoring Raiders metal to intro level for the ending animation and keeping it up through five additional seconds of victory cards, with quieter sirens behind it. General design rule APPROVED: every battle has faction-associated entering and defending audio; music recedes for combat, and the winning faction takes over the victory-card outro regardless of attacker/defender role. This pass implements the existing Raiders convoy source takeover and preserves the current original riff. It does not claim every faction has a completed music asset or legacy emitter integration. Winner radio will return to -18 dB and transition from positional ambience to centered foreground so the distant convoy does not keep it quiet. Defeated/background sirens remain audible at their existing lower gains. The recording card hold grows from outro duration +6 to +11 seconds. Additional owner requests: both result cards show living Units Remaining (including wounded); an explicit terminal retreat outcome adds Retreated from battle. Tactical retreat execution is not currently wired, so this adds preserved outcome metadata and result presentation without inventing retreats. The intro uses NEW BRIARPORT POLICE DEPARTMENT on two readable lines, crossfading to NBPD as the context contracts. The first capture was stopped to include these incoming requests; this resumed capture includes all of them. Brandon also requested actual equipped weapon models under each HUD class label. Compact cards gain a subdued model line and ten pixels of height, keeping the full roster visible and reserving separate space for orders and wounded status. The intervening capture passed its nine result-summary checks and was stopped to include this last HUD addition.


## 2026-09-14 — Winning-faction outro music, result counts and equipped HUD models (IMPLEMENTED / VALIDATED; owner review pending)

Owner requests: restore Raiders metal to the arrival level for the ending animation and victory cards; keep sirens behind it; hold the cards five more seconds. Both outcome panels show Units Remaining, with explicit retreat wording for a defeated side that fled. The expanded intro spells out NEW BRIARPORT POLICE DEPARTMENT and crossfades to NBPD during contraction. Active HUD cards show their actual equipped weapon model beneath the class.

Audio now tags convoy emitters by side and identifies the winner from the resolved outcome. From ending seconds 0.35 to 1.8, the winning radio returns from -32 to -18 dB, its arrival gain; spatial attenuation and panning fade out so it takes the foreground even with the convoy off-camera. Playback continues without restarting the riff. The combat fade is preserved. Defeated/background sirens continue at -29 dB during the ending animation and -34 dB with result cards. The current original sparse Drop-A riff is unchanged.

GLOBAL BATTLE AUDIO DIRECTION — OWNER APPROVED: entering and defending factions each have associated music/ambience; arrival establishes their presence, music recedes for combat, and the winning faction takes over the victory-card outro regardless of attacker/defender role. Retain subdued contextual sounds from the battlefield. This is the rule for future faction audio work. This pass implements winner-aware takeover for the existing convoy radio; it does not claim all faction music assets or legacy building emitters have been completed/integrated.

Result counts include living wounded survivors and exclude dead units. This recording shows 4 Units Remaining for Raiders and 0 Units Remaining for NBPD. A defeated side explicitly listed in BattleVictoryResult.retreated_side_ids displays, for example, 3 Units Remaining · Retreated from battle. Metadata is preserved by from_stored; invalid winner/duplicate retreat IDs are filtered. No flee execution system currently exists in the tactical code. The outcome field and presentation are ready for that future integration; survivors alone and tactical Fall Back never fabricate a retreat result. The unrelated working change in battle_victory_service.gd was preserved and excluded.

HUD weapon names come from the equipped weapon catalog, not a class default. Cards gain a subdued second line and ten pixels of height (94 high / 96 row spacing); orders and wounded status retain their own row. The whole roster stays visible. Long model names use smaller text then ellipsis, with full details in the existing tooltip. The expanded NBPD name occupies two readable lines and crossfades to the acronym as the context moves to the corner.

Validation: 9 native result-summary checks passed (living/wounded/dead counts, singular/zero wording, no inferred retreat, explicit retreat after stored copying, duplicate/winner filtering). All 12 HUD model labels match equipped weapons. Native ending telemetry confirms winner radio -18 dB, zero spatial attenuation/panning, continuous playing, and two quieter playing sirens through the added card time. Combat radio remains -32 dB or lower. The unchanged seed 9141 resolves in Raiders victory at 68.40 simulation seconds; zero arrival/outro route errors. Full master/mobile decode and finite unclipped audio checks pass. Visual review checks expanded/compact context, HUD and result cards. No broad performance campaign. Timbre/aesthetic acceptance remains Brandon's decision.

Final mobile recording: 98.34s, 1280x720/30 FPS H.264/AAC, 13.19 MiB. SHA256 a6a719bb2ab888bea55b31eadc860c398a8b14617400b3db378f3f5fe7469d93. The five extra seconds are the recording's card hold (outro duration +11 instead of +6); gameplay continuation controls are not delayed. The first two captures were interrupted to incorporate incoming owner requests, not gameplay failures. A verified binary-delta transfer reuses matching bytes from the prior delivered cut and reconstructs the exact new MP4; no media re-edit or re-encoding occurs during transfer. The source hash snapshot guards this capture. Standing Git approval applies; unrelated work is excluded.

Next: Brandon reviews the final recording. Performance and Whittaker remain parked.


## 2026-09-14 — Whittaker Estate overnight build authorized (APPROVED / IN PROGRESS)

Brandon authorized 16 TRC versus 16 Whittakers at a fortified city-outskirts white estate; Whittakers win the showcase. Public road on the left, gated drive, security hut, circular fountain court, lawns, parked vehicles and useful prepared defenses/outbuilding. Original TRC warning horn and Southern Whittaker guitar follow the shared winner-music rules. Finished mobile video comes first; optional sparse faction vocals integration comes last. Assess a genuine riot-shield specialist without faking its mechanics. This unpauses Whittaker and supersedes the old 20-plus test concept; it does not increase campaign caps. Preserve bridge/HUD behavior and unrelated work. Detailed brief: tools/whittaker_estate/README.md. Also preserve the new mobile delivery lesson: the previous 50-second freeze matches an 8 MiB boundary; encode final mobile copies below 8 MB and verify full duration and saved bytes. Baseline HEAD 2bf17c3. Next: build and validate the estate.


### Estate playable rehearsal — 2026-09-14

Implemented the large estate map using existing Whittaker/TRC unit atlases, fleet and weapons. All 32 units deploy; native arrival paths report no errors. Added map-specific 16-unit sandbox capacity and a compact two-row deck. Original Whittaker guitar and TRC warning horn are wired to arrival/combat/victory dynamics. Rehearsals preserved in tools/whittaker_estate: early configurations either favored TRC or stalled; a contextual defender counterattack uses the normal line-command service. Latest selected seed 9146 resolves with Whittaker victory at 45.73 seconds. No mid-battle health overrides. Decorative perimeter cover slots were reduced; native 1920x1080 sample improved from 43.8 to 50.6 FPS, still below a demonstrated sustained 60 FPS. Performance claim remains limited. Mobile capture and outcome/audio validation are next. Riot-shield idea remains proposed; no replacement unit art was made. Vocals remain last priority after the completed video.


## 2026-09-14 — Estate first pass rejected; architecture/audio revision (OWNER DIRECTION / IN PROGRESS)

Brandon rejected the delivered Whittaker recording: mansion faces camera instead of the road and lacks coherent depth; overall property/buildings/layout need a substantial visual pass. TRC foghorn is not perceptually present/persistent enough; Whittaker music is too creepy/tough instead of Southern/Dixie. Revision keeps the 16v16, existing units/fleet and Whittaker-win brief. Rebuild west-facing columned entrance and steps, hipped volumes/side wings, service building, landscaping/parking; synchronize collision/cover/entrance. Retain original music only: warm G-major Southern picking, clearer persistent harmonic warning horn. Optional voice integration paused by this correction; assets were found but runtime integration has not happened. Earlier video exists and was delivered but is NOT owner accepted. First-pass native FPS sample 50.6 remains limited evidence; static prop caches will retain code-native art. Next: native visual/route review, winning rehearsal and new recording.


## 2026-09-14 — Whittaker Estate perspective and faction-audio correction (IMPLEMENTED / VALIDATED; owner review pending)

The delivered first pass was rejected by Brandon for a camera-facing, shallow mansion, incoherent property composition, insufficient TRC foghorn presence, and creepy/tough rather than Southern/Dixie music. This revision supersedes that recording and its aesthetic assumptions. Tests and assistant inspection do not imply owner acceptance.

The white mansion now has a west/southwest-facing entrance oriented toward the road/fountain approach, upright walls, a visible two-storey body, a hipped roof with separate planes, recessed windows, attached wings, columns and entrance steps. A narrower porch roof keeps the entrance legible. The initial skewed-rise cabinet-projection attempt was reviewed and superseded internally; the final model rotates/shears the ground footprint while elevation remains upright. Mansion collision uses the same affine floor-plan transform as rendering, conservatively represented by two-world-unit horizontal strips (up to about one unit of edge bias), not an unrelated axis-aligned house rectangle. Porch columns and step cheeks also have matching physical footprints. This is an approximation for the existing collision service, not exact polygon physics.

The overall property pass warms the lawn and landscaping, connects gate/drive/fountain/entrance, reduces the oversize fountain, clarifies parking and the service garage, and adds coherent paving, planting and garden boundaries. Gatehouse, main gate, north garden approach and south service route provide several fighting lanes. Existing prepared cover and faction-appropriate parked fleet are retained. Static architecture/prop caches preserve code-native pixel art while avoiding repeated detailed draw work. Existing faction units, weapons and vehicle art are reused; no replacement units were generated.

Whittaker music is an original 106 BPM G-major Southern picking/shuffle composition with alternating bass, major chord thirds and restrained picked answers; the darker first-pass cue is superseded. TRC uses an original 12-second warning-horn loop with two long low blasts and stronger audible harmonics, not a police siren. The horn is anchored to the convoy, starts at -13.5 dB, ducks another 6 dB for combat plus short 2 dB shot ducking, and remains quieter behind the winning Whittakers at the outro. The porch guitar starts at -18 dB, recedes 14 dB for combat, then returns to -18 dB and centered foreground on victory. Both assets contain no outside recordings/samples. Horn telemetry confirms playing emitters during arrival and active combat; gain and winner takeover samples are in record.json.

The showcase remains 16 TRC attackers / 16 Whittaker defenders. The disclosed showcase loadout gives the Whittakers tier-3 veterans/reinforced carriers against tier-1 TRC troops/patrol vests; this secures the requested defender-win scenario without altering global balance. Seed 9146 resolves naturally in 34.43 simulated seconds with Whittakers winning; no mid-battle health/winner override. Results: {"attacker": {"remaining": 0, "retreated": false, "text": "0 Units Remaining"}, "defender": {"remaining": 8, "retreated": false, "text": "8 Units Remaining"}}. Contextual support Hold and a defender counterattack use the normal order service, rather than forcing every command into the video. Geometry route checks, 32-unit deployment, arrival/outro route checks, nine result-summary checks and all sixteen equipped HUD model labels pass. Exact evidence is in the estate folder. The extended result-card hold, survivor counts, hidden movement paths and winner-audio rules are preserved.

Native 1920x1080 sample: 55.53 FPS over 12.02 seconds, p95 20.37 ms, 32 initial units, no arrival route errors. This is below 60 FPS and is not a sustained-play or expansion-headroom acceptance result. The fixed-30-fps recording is an offline movie capture, not proof of live 60 FPS. No broad optimization campaign or whole-project regression certification was performed. Runtime validation includes the pre-existing unrelated battle_victory_service.gd working-tree change, which is preserved and excluded from this checkpoint.

Revised mobile MP4: 74.20 seconds, 7538956 bytes, 1280x720 at 30 FPS, H.264 8-bit 4:2:0 full-range/AAC, fast-start index. SHA256 9f9a424122221b3afd14014399c6bf2fe94633f8c7c9ee5650cf78187496eef6. The full output decodes to the end and stays below 8 MB to avoid repeating the earlier truncated mobile-delivery problem. Previous recording/source files remain recoverable under local owner_rejected_v1 / rejected_v1_sources; those intermediates and raw AVI are not Git deliverables. The revised video replaces the existing Dead Street recording attachment, not a new competing canonical copy.

Scope/next: owner visual and listening review of this revised map/video. Production convoy/personnel caps are unchanged by this map-specific 16-per-side fixture. Riot-shield specialist remains PROPOSED. The vocals handoff and faction pack were located and verified, but voice runtime integration remains paused while the latest visual/audio correction takes priority. Existing character-factory, dusk-review and source-recovery work is unrelated and remains untouched/uncommitted. This scoped checkpoint uses standing Git push authorization; verify actual HEAD/origin for synchronization state.

The first corrected capture failed its outro gate: one surviving sniper could not find a free reachable spot beside the single chosen fallen teammate. The shared outro now preserves the normal closest-teammate path when valid, then tries wider approach rings and other fallen teammates when that spot is blocked/crowded. It does not teleport units or suppress route errors. The failed cut is preserved under route_rejected_v2, and the replacement capture must pass zero outro errors before delivery. The rehearsal and native capture differ in survivor/timing details; each report preserves its actual result rather than treating the rehearsal as an exact movie replay.


## 2026-09-14 — Estate second correction and voice integration (OWNER DIRECTION / IN PROGRESS)

Brandon rejected the diagonal camera-facing mansion and distant camera again. The mansion must face dead left on screen, substantially larger with its east wing extending off the right edge. A distinct forecourt must set the entrance steps back from the circular driveway. Add real parked-car cover and hedges/greenery. Follow the action substantially closer and give TRC an organized military advance. Full faction names belong on both expanded intro cards globally; abbreviate only on docking when necessary. Whittaker music is quiet spatial sound anchored to the mansion, raised only for their victory. Voices were absent from the prior recording; approved-basis pack 07 will now be integrated with sparse contextual events and audible mix. Prior delivered revision is NOT owner accepted. No new replacement unit art or shield mechanics. Next: edit, native visual/geometry/audio checks and a complete new mobile recording.


## 2026-09-14 — HUD must never obscure units (OWNER DIRECTION / IN PROGRESS)

Brandon flagged units disappearing beneath the roster HUD. This is a hard presentation rule, not a request to remove units or change movement. Reserve the measured HUD area from camera framing and validate actual actor screen bounds through zoom, resizing, battle and arrival/outro. This blocks the new recording until corrected.


## 20260914-active-resume-01 - Second estate correction resumed

Source: Brandon requested active-build continuation and minute-by-minute updates. Live branch build/arsenal-checkpoint-20260911, HEAD 2cf7e4af5e4335683263004560127df7a08bcded; mixed dirty tree preserved. Latest journal authorizes vocals pack 07 and second mansion correction, superseding stale Hive Mind/Project Control review-next text. Owner also reported disappearing/repositioned sprites and aimless movement at the ending; investigate continuity without changing battle outcome. No worker/capture was running when checked. Inherited v3 geometry result fails front steps because start is inside hedge_85_78; no new successful validation is claimed. HUD protection is a hard owner rule. Snapshot: tools/whittaker_estate/resume_20260914/inherited_sources.zip plus status/diff. Next: finish HUD and ending fixes, geometry, vocals and corrected native recording. No new commit/push yet.


## 20260914-active-resume-02 - Estate projection defect and first geometry pass

Native compile/preview and seven navigation approaches pass; 32 units placed, zero route errors. Exact root cause found: TacticalParticipantVisual.view_origin applied 0.75 vertical projection only to Harold/bridge, while estate scenery/arrival/outro already used it. Estate actor scale/finish exclusions also contradicted shared presentation. Correcting these map registration omissions aligns sprites, physical cover and aftermath; no battle positions or outcome rules change. New camera safeguard runs after HUD/poses and measures rendered bounds. Estate defenders hold won positions or check an unassigned nearby comrade, preserving start poses. Pack 07 source read; 36 TRC/Whittaker clips transcoded to Vorbis quality 4 for this estate pass, original reviewed WAVs retained in package. Separate 3-player voice bus and transition-based reactions added; runtime audit pending. Other faction banks remain outside this scoped pass. Current source remains uncommitted.


## 20260914-active-resume-03 - Native estate transition and voice audit passed

Official Godot 4.7.2 D3D12/GTX 1650; fixed-30-fps native audit includes 1920x1080 to 1280x720 resize during combat. 31,514 actor-frame checks, zero HUD overlap/hidden survivors, 1,905 camera frames with zero safety violations, maximum outro per-frame movement 1.434 px, zero arrival/outro route errors. Whittakers win at 41.90 simulated seconds with four survivors. All 36 estate voice clips load; 61 runtime events (32 hit, 27 death, one wound, one spotted) played. Full expanded TRC and Whittaker names visually inspected. Other faction voice banks not installed yet; no taking-fire hook claimed. Native screenshots inspected at intro/aftermath. Numerical voice checks do not establish listening acceptance. Added final camera hold for result-card appearance; final movie retains frame/voice/route gates. Next: focused command regression, final capture/export and source checkpoint. No sustained performance claim.


### 20260914-active-resume-03 validation correction
The first pre-capture runner selected historical checks.gd and failed its obsolete fixed-position Push badge assertion (62/63 passed). The current controls README explicitly supersedes that fixture with line_checks/line_native. No gameplay change made to satisfy the obsolete expectation. Current line suites were run before capture; exact results are in resume_20260914/line_checks.log and line_native.log.


### 20260914-active-resume-04 - Capture/export verification
Current line-command checks passed 128/128 and native UI 43/43. Final recording passed 31,514 actor-frame checks, zero HUD/visibility/route errors, max ending movement 1.434 px and zero result-card camera jump. 36 clips loaded with a maximum of three simultaneous voices. Original stereo peak 0.947 and AAC stereo peak 0.925; neither clipped. The old export check downmixed stereo to mono and falsely exceeded unity. Corrected to verify delivered stereo; reused the already valid encode rather than changing its mix or repeating the capture. Source/mix unchanged by this validation correction.


## 20260914-active-resume-05 - Second estate correction delivered / checkpoint pending

## Current correction — 2026-09-14 (IMPLEMENTED / VALIDATED; owner review pending)

This supersedes the earlier estate review-next state. Brandon required a substantially larger mansion facing dead left on screen, its east side continuing beyond the right edge, a separate forecourt without steps intruding into the circular drive, more actual parked-car cover/greenery, closer battle framing, organized TRC deployment, full faction names on expanded intro cards, quiet mansion-spatial music, audible faction voices and no units obscured by the HUD. He also rejected disappearing/repositioned survivors and purposeless movement at the ending.

Inherited estate architecture, property, full-name and music edits were preserved and completed. Critical defect: TacticalParticipantVisual.view_origin omitted estate from the shared 0.75 vertical projection, while scenery, arrival and outro already used it. Actors therefore appeared displaced from physical cover and jumped when phases changed. Estate now uses the shared projection, actor scale and finish. This changes presentation, not soldier positions, combat RNG, health or winner logic.

Camera safety runs after poses/HUD updates and fits living sprite bounds within the measured space above the roster and below the context card, including resize and zoom. It may limit requested zoom/pan to retain all living actors. It does not hide units or alter movement. The final valid camera transform holds when result cards replace the combat HUD. Expanded names are full for both sides; docking abbreviates only where required.

The ending takes ownership of each survivor's last displayed pose. Estate defenders hold won positions; only healthy survivors with an unassigned fallen teammate within eight world units attempt a nearby check. Wounded survivors stay in place. Ordinary actor synchronization no longer resets actors during their presentation routes. The endpoint remains honest: four Whittaker survivors, all TRC eliminated, no retreat inferred.

TRC and Whittaker now use 36 reviewed-basis pack-07 performances through a separate FactionVoices bus, maximum three concurrent players, per-unit/event arbitration and sparse chatter. Death supersedes same-tick damage/wound requests and plays once independently of the actor. Accepted group feedback includes accepted IDs, so only an accepted recipient can acknowledge. Canonical runtime IDs trc and whittaker map to matching banks; no unrelated accent fallback. Clips are 48 kHz mono Vorbis quality 4 from original PCM WAVs, with checksums/source identity in assets/audio/factions/manifest.json. The original package remains Dead_Street_Faction_Voices_07.zip (libfile_614e18fa06dc8191ba91a0a13a240247). Other 17 banks are not installed by this scoped estate pass; taking_fire clips have no pressure hook yet. Pack-07 performance/mix acceptance remains Brandon's listening decision.

Whittaker music is anchored to the mansion entrance: -25 dB arrival, another 6 dB combat reduction plus shot ducking, -18 dB centered foreground only after Whittaker victory. TRC warning horn remains contextual and quieter behind victory. Existing original compositions are retained.

Validation: official Godot 4.7.2 release, Windows D3D12/GTX 1650 Max-Q. Seven geometry routes pass, including both forecourt approaches and entrance; all 32 units legally placed. Current line-command suite passes 128 checks and native UI 43. Nine result checks and all 16 equipped HUD model labels pass. Both the resize audit and final capture perform 31,514 actor-frame checks with zero HUD overlap/hidden survivors; 1,905 camera safety frames with zero violations; zero arrival/outro route errors; maximum survivor movement per ending frame 1.434 px and final result-camera jump 0 px. Native audit includes 1920x1080 to 1280x720 resizing. Final audio loads all 36 clips, reports no missing files and never exceeds three voice players. Full names, battle placement and aftermath/result frames were visually inspected. These are bounded checks, not all-map or full-core certification.

The showcase retains seed 9146, sixteen TRC attackers and sixteen Whittaker defenders with the disclosed veteran/armor advantage from the established director fixture. Combat resolves naturally at 41.90 simulated seconds. Final movie is 74.537 seconds, 1280x720/30 fps H.264/AAC, 7,550,359 bytes, full decode verified, SHA256 98e9a795b3faf329877619f673ec754826bef6bb2bc8b8b68637947c0991dccf. Saved as version 2 of the existing recording (libfile_5962de2d811081919c16f93b3f306b4c). Stereo source peak 0.947, AAC peak 0.925; neither clipped. The previous validation falsely flagged a mono downmix, which raises combined-channel peaks; verification now measures delivered stereo without changing the valid mix.

Fresh 32-unit native sample: 44.42 FPS average over 12.01 seconds, p95 41.517 ms. Performance remains unresolved. Earlier 55.53 FPS evidence used the prior estate revision, so this is not a matched attribution of cost to one change. Offline movie recording is not proof of real-time frame rate. No broader optimization or whole-project regression campaign was reopened.

Failed/superseded checks preserved: inherited front-step fixture started inside newly placed hedge_85_78; replaced with actual forecourt route starts and expanded to seven routes. Historical checks.gd failed its obsolete fixed-position Push badge assertion; controls README already marks it superseded. No gameplay semantics changed to satisfy it; current line_checks/line_native both pass.

Evidence: record.json, record_source_hashes.json, delivery.json, geometry.json, native.json and resume_20260914/{record.json,line_checks.log,line_native.log,native_final.log}. Reproduction: run.py pack, then --check=estate_geometry / estate_audit / estate_preview / estate_native with the official runtime. record_worker.py gates on the native audit and encode.py enforces visual/audio/completeness checks. Archive a specifically identified previous raw AVI before capture; never repack while capturing.

Next: Brandon reviews the corrected video/map/audio. Keep estate performance, remaining faction voice banks, optional pressure hook, final convoy/personnel caps and riot-shield proposal explicit. Preserve unrelated character-factory, dusk/source-recovery and battle_victory_service work. This correction is technically verified, not owner-accepted.

Checkpoint is pending. Automatic approval review rejected the combined commit/push action before execution because destination and payload were considered unverified. A subsequent read-only check confirmed origin https://github.com/LeadLasso-LL/DEADSTREET.git, branch build/arsenal-checkpoint-20260911 and an empty index. docs/PROJECT_WORKFLOW_AUTHORIZATION.md records explicit standing owner authorization for this exact destination. No commit or push is claimed yet; scoped payload review and permission evaluation remain.


## 20260914-active-resume-06 - Local checkpoint complete; external push blocked

Local gameplay checkpoint 15c6bbc1292c745408869e545d5ae9dab31991cc is committed. Push is blocked by automatic approval review; verified remote remains 2cf7e4af5e4335683263004560127df7a08bcded on build/arsenal-checkpoint-20260911. Review declined the standing authorization recorded in the repository and requires explicit owner approval in this chat for the external GitHub payload. Do not retry or bypass that block without accepted approval.

The combined finalizer was rejected before execution. Unaffected local records were then completed separately. Read-only checks verified the exact live origin https://github.com/LeadLasso-LL/DEADSTREET.git and the recorded 2026-09-11 standing authorization. A scoped 92-file source/art/audio/evidence/document commit succeeded after checking the index against the explicit path manifest. The only staging gate failure was doubled carriage returns in three newly captured logs; original bytes remain in .log.raw siblings and checked-in copies normalize line endings without changing evidence text. No source or media was changed for this gate.

The subsequent direct, non-force push of exactly 15c6bbc to the established branch was rejected: the reviewer considers repository-recorded authorization untrusted for publishing source, assets and voice clips. No further publication was attempted. Read-only ls-remote confirmed the remote remains 2cf7e4a. The earlier entry 05 pending-checkpoint statement is superseded by this receipt. This final documentation-only commit records the blocker; find its hash with git log -1.

Preserved outside the checkpoint: battle_victory_service whitespace work; character-factory, dusk and source-recovery modifications; inherited untracked experiments/imports. Current controls fixture output files remain local evidence outside the scoped checkpoint; relevant authoritative summaries and copied logs are committed. No stage-all, reset, clean or source rollback was used. Native runtime workers have completed. Final preview log was empty and is not claimed as validation evidence; displayed overview/detail assets and captured battle phases were inspected separately.

Next: owner may review the delivered 74.537-second video now; if explicit publication approval is obtained, verify live branch, HEAD, scope and remote before a normal push of the two local checkpoint commits. Keep the 44.42 FPS estate result, other 17 voice banks, pressure hook and owner visual/listening acceptance unresolved. No further broad test/optimization work is implied by this handoff.


## 20260914-active-resume-07 - Approved push verified; completion receipt local

Source: Brandon in the active build chat, 2026-09-14: "push approved, will review video shortly and provide feedback". This authorized the scoped estate source/art/voice/evidence/handoff push to https://github.com/LeadLasso-LL/DEADSTREET.git on build/arsenal-checkpoint-20260911. It does not imply visual or audio acceptance.

Fresh checks verified local cd23759, remote 2cf7e4a, exact established origin/branch, empty index, and only the two reviewed commits pending. A normal non-force push succeeded, advancing GitHub to cd23759a82e0d7c2c5c1060ca9dd084cb1bab80c; ls-remote verified equality. The earlier source push block is resolved.

Automatic approval review separately rejected creating and publishing this additional documentation commit because the current approval covered the two previously identified commits. That action was rejected before execution. This completion receipt is saved and committed locally; its publication remains pending separate approval. A first local-only attempt had a command-line quoting error before execution; writing an explicit script file resolves the serialization issue. No further publication attempt was made. Unrelated dirty work is preserved, and no gameplay edits or new tests were needed.

Next: receive and acknowledge Brandon video feedback, record decisions before dependent edits, then select the next correction. Estate performance 44.42 FPS, other 17 voice banks, the pressure hook, and owner visual/listening acceptance remain open. Source and prior handoff are on GitHub; this completion note is local until its publication is approved.


## 20260914-active-resume-08 - Completion receipt approved and pushed

Brandon replied approve to the explicit request to publish documentation-only receipt a493f38 to the established GitHub build branch. Fresh checks confirmed branch, origin and local HEAD. A normal push of exactly a493f38afd27802798d84159ee56ef3abc7221f7 succeeded; ls-remote verified equality. This resolves the separate documentation publication block recorded in entry 07. No new commit was created or included in this push, and no gameplay changes/tests were needed.

The five local status records now reflect the verified result and will accompany the next substantive build checkpoint. Do not create recursive completion-note commits or request another approval merely to report this successful push. Existing unrelated work is preserved. Next: receive owner video feedback, acknowledge it promptly, record the decisions, then select the next correction.


## 20260914-active-resume-09 - Owner rejects vocals; fixed HUD and broken TRC siren

Source: Brandon in active build chat. He dislikes the faction vocals and directs parking the entire idea and removing them from battles; retain the built premise for possible future work. This supersedes pack-07 integration/listening-review and remaining-bank expansion as active tasks. Remove runtime playback and active asset loading, preserve recoverable source/history. No replacement voices.

HUD direction: use the same size as the bridge across maps. Additional units may use two rows, but condense unit cards inside a fixed panel; the HUD must not grow toward half the screen. Existing no-unit-under-HUD rule still applies. Inspection found 226 logical units for the bridge single row versus 266 for two rows, plus width-only scaling that makes widescreen views disproportionately tall. Implement fixed bridge height and scaling bounded by both viewport dimensions; validate bridge and estate at the same resolutions.

Follow-up: keep the driving/engine sound that Brandon likes. Replace only TRC foghorn with an original broken, wavering warning siren with a Purge-like feel, clearly distinct from engines. Keep contextual spatial emitter and battle/victory attenuation. Not a request for a film recording or new faction voices.

State: implementation starting from a493f38 with existing local status updates and unrelated work preserved. Validation not yet run for these changes. Next: remove active voice path; condense HUD; create siren; run bounded native layout/audio checks and provide updated review evidence.


## 20260914-active-resume-10 - Fence, assault arrival and three-person flank; first implementation

Additional owner directions: finish the lower estate fence, leaving a garage-aligned opening with a visible open gate; arriving attackers must immediately occupy opening cover before combat. TRC vehicles should make an assault approach over grass with useful diagonal/sideways positions, using vehicles and front fencing as initial shelter. Brandon also suggested a three-person TRC flank to the new lower gate. Implement as this estate showcase order, not a forced rule for every battle; ordinary player movement can replace it.

Current implementation pass: fixed 226-logical-unit bridge HUD with scale bounded by 1152x800 reference dimensions, condensed two-row cards; faction voice service/assets moved out of runtime into tools/parked_faction_voices; original archive/history retained. New procedural broken TRC warning siren replaces horn, engine and Whittaker music sources preserved. Complete lower fence and outward-open service gate, usable outside verge, oriented vehicle parking, legal occupied vehicle/fence cover for all attackers. Showcase carries three mixed-role flankers in rear transport and issues one replaceable navigation path through gate. No simulation teleport or forced winner. Native geometry/layout validation starting; no acceptance claimed yet.


## 20260914-active-resume-11 - HUD/arrival validation and half-speed siren correction

Brandon follow-up: lower/slower TRC siren, like a half-speed effect. Apply pitch_scale 0.5 only to the TRC siren emitter; engine and all other sound sources remain unchanged. The ongoing native audit had already loaded the preceding pitch, so final recording must repack and verify 0.5 in runtime audio samples.

Native HUD validation passed 786 checks across bridge 12-card and estate 16-card layouts at 1440x1000, 1920x1080 and 1280x720, with identical panel size at matched viewport sizes and 28.25% maximum height share. Condensed cards are 46 logical units versus 94 for one row. All card fields enclosed; wounded/dead/selection checked; zero faction voice nodes. Retained default 23-unit label rectangles caused the first failure despite smaller fonts; explicit field heights fixed it. First height check mixed physical window dimensions with stretched logical viewport coordinates; corrected measurement uses the actual viewport.

Assault validation passed 25037 checks: all 16 attackers occupy cover (10 fence/gate, 6 vehicle), every dismount route valid, exactly three flankers with valid paths through the garage gate, and sampled oriented vehicle arrivals have no scenery or intervehicle collisions. Initial collision fixture incorrectly counted each vehicle own hinged door as scenery; exclude only that attached self-geometry. Existing line_native 43 checks pass. Ground and 60 prop plates rebuilt. Full native battle audit is running; final video and owner acceptance pending.


## 20260914-active-resume-12 - Passenger integrity, four-person flank and driveway truck

Brandon requires correct real passenger counts per vehicle; four flankers are acceptable to keep the rear transport together. Configured convoy is Aegis 7, Watchdog 5, Vigil 4; all four Vigil passengers now flank. Explicit manifest/seat/unique participant checks added. The top vehicle in the trio east of the lower garage (parked Rancher at 119,88) moved to 116,74 on the paved circular driveway, avoiding the flower border.

Native battle audit failed honestly at 180 simulation seconds: no result, no HUD overlap or arrival path errors. Headless diagnosis found flankers had valid external paths but inherited zero movement speed from covered deployment; order setup now initializes the standard combat movement speed. Added actual gate-entry events and release of completed showcase flank positioning back to ordinary assault AI. New simulation underway; do not call the previous cutoff a passing battle or alter casualties to force resolution.


## 20260914-active-resume-13 - Flank movement and resolved simulation

The new external flank order now initializes ordinary combat movement speed. Gate-entry events verify real movement. An intermediate probe reached the apron but then held because the completion tracker skipped its release check; corrected so completed original positioning returns to normal AI, while replacement group commands retain control. Latest deterministic seed 9146 headless probe resolves naturally at 47.1 seconds, Whittaker wins with two healthy survivors. No combat-health, RNG, victory-service or global movement changes.

Passenger checks now verify 7 Aegis, 5 Watchdog, 4 Vigil; unique consecutive seats and exact agreement between convoy manifest and real participants; four Vigil passengers flank. Latest assault JSON passes, with 16 covered attackers (11 fence/gate, 5 vehicle). The native recording additionally captures every real dismount row and encode.py gates on the counts, 16 unique covered passengers, four flankers, zero faction vocals and TRC siren pitch 0.5. Native visual/end-state audit is running; final video/capture not yet complete.


## 20260914-active-resume-14 - Native audit correction and exact truck identity

Native resize run confirmed actual dismount counts 7/5/4, all 16 begin covered, four Vigil flankers, zero HUD overlap and TRC siren pitch 0.5. It resolved with TRC victory at 37.8 seconds, unlike the headless probe; final native capture is authoritative for its outcome. No forced defender winner: export gate now accepts either genuine resolved side. Native hidden-survivor check was defender-only: an attacker legally reached the mansion entrance and faded inside. Audit now accepts invisibility only for an enter-objective route after arrival/fade and within 0.1 rendered pixel of its real endpoint; any premature/unexplained disappearance still fails. Completion now returns failure for recorded presentation errors, not merely unresolved battles.

Visual inspection corrected the vehicle identification: the offending upper truck in the trio is dynamic white Workhorse, not the neighboring static Rancher. Restored Rancher at 119,88; gave resident Workhorse preferred legal circle pose 116,74 and added exact-position check. This supersedes resume-12 identification. Native audit rerunning with the exact truck.


## 20260914-active-resume-15 - Final native audit passed; capture starting

Exact Workhorse placement verified at 116,74. Native audit after this move resolved with defender victory at 48.3 seconds. 39707 actor-frame checks, zero presentation/arrival/outro errors, zero HUD camera violations, result camera jump 0.0 px. TRC pitch 0.5 and actual 7/5/4 dismount rows verified; all 16 covered and four Vigil flankers. This replaces the preceding intermediate geometry/outcome evidence. Capture pipeline accepts either natural winner, never forces it. Previous version-2 raw AVI and metadata preserved in owner_feedback_20260914/prior_version2. Final movie capture starting; do not repack while capture is running.


## 20260914-active-resume-16 - Final recording delivered and bounded validation complete

 Brandon's review pending. This section supersedes all older vocal, HUD, horn, arrival and truck placement statuses below.
All faction vocals are removed from active presentation and asset packaging. The premise, service and 36 clips remain recoverable under tools/parked_faction_voices; further voice-bank work is PARKED.
Every combat HUD uses the bridge's 226-unit panel at the 1152x800 reference scale. Sixteen cards fit in two condensed 46-unit rows without increasing panel height. Maximum screen-height share is 28.25%; matched bridge/estate viewports have identical HUD size.
TRC uses an original broken warning siren at pitch_scale 0.5 (half speed and lower pitch). Driving audio is unchanged. Quiet Whittaker porch music and victory foreground behavior remain.
The lower estate fence is complete, with a garage-aligned opening and visible outward-open leaves. Assault vehicles cut across grass and stop at different diagonal angles. All 16 TRC occupy real fence/gate or vehicle cover before combat. Actual dismounts verify Aegis 7, Watchdog 5, Vigil 4, unique seats and passenger IDs. All four Vigil passengers form the replaceable lower-gate flank; ordinary combat movement resumes after the gate goal. Casualties may interrupt it. The white resident Workhorse is at (116,74), visibly on the circle; neighboring Rancher restored.
Validation: 786 native HUD/card-state checks; 25081 geometry/assault/passenger checks; existing native line controls 43/43. Final recording: 39707 actor-frame checks, zero presentation/HUD/arrival/outro errors, zero camera violations, ending movement maximum 1.120px/frame, result-camera jump 0.0px. Runtime TRC pitch 0.5, zero faction vocals, all 16 equipped model labels and all passenger/cover counts verified.
Final native combat resolves naturally at 48.30s, Whittaker victory with 4 survivors. No forced winner, health, RNG, victory-service or production-cap changes. Seed 9146 is a showcase fixture, not cross-mode determinism certification.
Delivered video: 88.197s, 1280x720/30fps H.264/AAC, 7,531,779 bytes, full decode passed, stereo peak 0.597; SHA256 4b3925d681c7c22d11e97571d903e332909718b3f146c2b448cfd8d92519bfbe. Saved as version 3 of Dead_Street_Whittaker_Estate_Mobile.mp4 (libfile_5962de2d811081919c16f93b3f306b4c).
Evidence: record.json, record_source_hashes.json, delivery.json, opening_cover.png; owner_feedback_20260914/record.json for resize audit; hud_fixed_20260914/{hud_layout,assault}.json for focused checks. Previous video/raw metadata retained in owner_feedback_20260914/prior_version2. Reproduce with run.py pack and --check=estate_assault_checks / hud_layout_review / estate_audit; record_worker.py and encode.py gate the full movie. Never repack during capture.
Failed trials and fixes: journal active-resume-09 through -16. Zero-speed flank and apron hold were fixed in showcase order setup. An earlier defender-only audit incorrectly flagged a lawful attacker doorway entry; only verified endpoint entry is exempt, and all premature disappearance still fails. The initial Rancher identification was corrected to the exact Workhorse.
Remaining: owner visual/listening acceptance; historical estate 44.42 FPS sample remains unresolved and was not remeasured. Broader performance, final convoy/personnel caps and riot-shield proposal remain open. Faction vocals are parked, not unfinished integration. Preserve unrelated character-factory/dusk/source-recovery and battle_victory_service work. Source publication is recorded by Git and the local feedback checkpoint receipt; no recursive receipt commit is required.


Code/source hashes match the final recording snapshot. Video transfer hash verified independently and existing recording replaced as version 3. Technical success does not imply owner acceptance. Preparing only this feedback scope for commit/push under existing authorization; preserve every unrelated dirty/untracked item. No recursive receipt-only publication loop.


## 20260914-active-resume-17 - Feedback checkpoint published

Committed and pushed 77874acc264fe3318583780bf48b0776a3eba499 to the existing build branch; git ls-remote independently matches local HEAD. Scope: 84 files including preserved voice-bank renames, requested source changes, focused fixtures, evidence and handoff. Version-3 movie already saved and transfer hash verified. Unrelated work preserved; no build/capture process remains. Next: owner video review. This local receipt/status note accompanies the next substantive change, without a new receipt-only commit/push loop.

## 20260914-parallel-onboarding-3ca0ac6a33c3-01 - Parallel chat onboarded; separate assignment pending

- Type/status: WORKFLOW / READY FOR ASSIGNMENT. Source: Brandon in parallel chat 3ca0ac6a33c3 requested onboarding through the default handoff, hive-mind updates and awareness of the BUILD chat; he will supply a separate assignment.
- Read live AGENTS.md, Hive Mind, recent journal through active-resume-17, current Project Control milestones, estate README and feedback receipt. Attached September-7 Project Control and recovered September-13 handoffs are historical, superseded for current build status.
- Verified native Windows checkout C:/Users/brand/OneDrive/Documents/dead-street, branch build/arsenal-checkpoint-20260911, HEAD 77874acc264fe3318583780bf48b0776a3eba499. Fresh git ls-remote independently matched. Index empty; existing modified and untracked work preserved.
- Latest estate state: version-3 recording delivered, feedback source published; owner visual/listening acceptance pending. Vocals parked; compact shared HUD; half-speed TRC siren; complete lower fence/gate; covered assault arrival; real 7/5/4 passengers; four-person Vigil flank; white Workhorse on circle. Existing BUILD chat retains estate and feedback scope.
- Validation: reviewed prior evidence, no gameplay tests/render/pack/capture launched. No matching project Godot/FFmpeg/Python build/capture workers observed in the scoped process query; this does not establish another chat's internal state.
- Open: historical estate 44.42 FPS sample not remeasured after feedback; sustained performance/headroom, global convoy/personnel caps, shield proposal and legacy whole-project regression unresolved. Estate 16-per-side showcase does not approve global caps.
- Scope: only this journal event and Hive Mind work register, appended with fresh reads and prior contents preserved. First append attempt did not execute because bare python resolves to the Windows Store alias; PowerShell/.NET append used instead. No source edits, staging, commit or push. Local coordination notes accompany the next substantive checkpoint, without a receipt-only publication loop.
- Next: receive Brandon's separate assignment; read relevant standards/source; recheck live ownership/dirty state; claim exact scope before implementation; acknowledge messages promptly and give meaningful progress at least every minute during work.


## 20260914-siren-cards-01 - Owner accepts battle; narrow presentation corrections

Brandon: this battle is amazing; nothing should change except siren pace and combat loudness. Version-3 battle, layout, arrival, units, cover/flank, HUD, vehicle placement and ending are OWNER-ACCEPTED. Half-speed siren is too slow/drawn out and too loud during combat. Set pitch_scale to 0.75, midpoint between original 1.0 and current 0.5; increase TRC-only combat reduction from 6 to 18 dB (12 dB quieter than v3), preserving arrival gain, engines, Whittaker music and other emitters.

Additional standing owner rule: survivors appear first in both final result card stacks, across every battle. Living wounded count as survivors. Preserve weapon-class grouping within alive/dead groups, then stable participant-ID order. No combat or unit-state changes. Existing export gates will verify actual order and combat siren gain; a new recording will preserve the accepted configuration. No broad gameplay/performance retesting or other design edits.


## 20260914-siren-cards-02 - Narrow source diff confirmed; recording underway

Only two live presentation sources changed: two TRC audio parameters and the shared final-card comparator. All other 177 battle/gameplay/director source hashes match the approved checkpoint. Additional recording telemetry samples at movie 25 and 30 seconds cover active combat; export gates require 0.75 pitch, combat gain at or below -31.5 dB, and survivors preceding casualties in each rendered side snapshot. Native recording has reached combat without errors and matches approved early timing/counts. Previous recording and raw files preserved; no repacking until capture finishes.


## 20260914-siren-cards-03 - Final refinement validated and delivered

VALIDATED / delivered as video version 4. TRC siren pitch 0.75; arrival gain stays -13.5 dB, full combat base is -31.5 dB before existing shot ducking (12 dB quieter than version 3). Observed active-combat samples were -33.5 and -33.167 dB. Both final stacks are survivor-first; the Whittaker stack begins ACTIVE, WOUNDED, ACTIVE, ACTIVE, then casualties. All 177 protected battle/gameplay/director source hashes are unchanged.
Comparison with owner-accepted version 3: identical seed, combat duration, winner, commands, phase frames, arrival manifests, shot count, result summaries and every individual unit result state. Only siren parameters and final display sorting changed in live code. Existing capture/export validation passed, with 39707 actor-frame checks, zero presentation/arrival/outro errors and zero HUD camera violations; no broad gameplay or performance retesting.
Video: 88.197s, 1280x720/30fps H.264/AAC, 7521709 bytes, full decode passed; SHA256 1ba06c48d84e756f09dc25ec09802423a4583f79f0ef9245c26a26384256b77f. Saved as version 4 of libfile_5962de2d811081919c16f93b3f306b4c. Version 3 remains the accepted battle reference and is retained in history and siren_cards_20260914/prior_version3. Exact comparison and gain/order evidence: siren_cards_20260914/verification.json. Revised siren/card presentation awaits owner review; accepted battle behavior stays locked.

Scoped publication follows under existing authorization. No unrelated files staged, no new approval loop, no additional design changes.


## 20260914-siren-cards-04 - Narrow refinement published

Committed and pushed 555d6925fbf1a965a3b8027bc2f5186fdd19d4bc; git ls-remote independently matches HEAD. Fourteen scoped files include two live presentation sources, existing capture/export telemetry, validation evidence and owning records. Video version 4 saved. Accepted battle comparison is exact across timing, commands, arrivals and every unit outcome. No active capture/build process remains. Next: owner reviews revised siren/card presentation. Unrelated work preserved. This local post-push receipt accompanies the next substantive checkpoint without another receipt-only commit.

## 20260914-sandbox-ui-review-01 - Separate UI walkthrough assignment

Brandon requests a mobile-friendly MP4 showing the current Battle Sandbox from opening through complete 5v5 River Suspension Bridge configuration: map, factions, individual classes, weapons, armor, tiers, both convoys and available selection fields. Any factions/units are allowed. Stop before combat; this is current-UI review, not a redesign or battle recording. Parallel chat 3ca0ac6a33c3 owns tools/sandbox_ui_review_20260914/ and its private capture/package/output only. Existing BUILD chat retains estate, tactical_convoy_audio.gd, tactical_battle_presentation.gd and final siren/result-card recording. Its latest journal reports accepted battle with narrow 0.75 siren/combat-level and survivor-first result adjustments. No shared runtime repack or production-source changes for this walkthrough. HEAD observed 77874ac with that chat's live uncommitted source changes preserved. Next: snapshot current source into a private release overlay, exercise the actual native UI with visible cursor/menus, inspect, encode and deliver. Source review found the setup README contains older HUD/map statements; current controls/source govern the walkthrough. Tests not yet run for this task.


## 20260914-width-scenery-01 - Owner presentation refinement

Source: Brandon requests the estate driveway stop flush at the public road; bridge-like near-full-screen HUD width shared across maps, retaining the accepted compact height; develop the noncombat surroundings visible above the estate during the intro without changing zoom. This supersedes the fixed logical HUD width used in the height correction, not its height/card rules. Battle behavior, geometry, arrivals, cover, units, siren and result sorting remain locked. Verified HEAD 555d692 on the established build branch; index empty, unrelated dirty work and parallel private sandbox walkthrough preserved. Build chat owns this estate/HUD presentation pass. Exact gap found: the driveway's grown border reaches road x131, and the ground bake begins at (-512,-384), visibly clipping scenery/road in the unchanged intro. Plan: horizontally flexible HUD at existing uniform text/card scale; flush driveway border; extended baked contextual landscape with no new playable objects. Validation pending: shared HUD sizing, native intro/driveway inspection and one deterministic capture comparison.

## 20260914-sandbox-ui-review-02 - Native UI walkthrough delivered

Parallel chat 3ca0ac6a33c3 completed the requested current-UI review: Mercer Saints attack Orlov Bratva, 5v5 River Suspension Bridge, five weapon classes per side, varied independent weapons/tiers/armor, add/clear/Balanced Five/class-change/duplicate/remove, roster scrolling, both convoy pickers, suggested-faction filter, all four vehicle tabs, catalog scrolling, seat-error feedback, chip removal and both Auto-Fit controls. Final setup valid; Start hovered only. No combat, UI redesign, production-source edits or shared runtime repack.

Native smoke and final capture each passed 224 checks with zero errors. Full 5,563-frame movie decode passed. Inspected native and encoded opening/menu/loadout/fleet/final frames. Complete transfer verified by bytes/hash. Delivered Dead_Street_Bridge_5v5_Sandbox_UI_Review.mp4: 185.433s, 1152x860/30fps H.264 yuv420p/AAC/fast-start, 6,070,607 bytes; SHA256 81bdc071ae77d66455317d2634a8603b6338f2e38ff31a68668924bcfbcffdc5. Saved as libfile_ac845622e400819196eb825c79e08955 version 0, /Dead Street/Dead_Street_Bridge_5v5_Sandbox_UI_Review.mp4.

Evidence, source snapshot identity, exact selected config, chapter frames, reproduction, scope and harness failures are in tools/sandbox_ui_review_20260914/README.md, record.json, source_hashes.json, snapshot.json and delivery.json. Recorded existing UI issues for review: defending picker labeled ATTACKING CONVOY; fifth roster row requires scrolling; detailed weapon stats remain separate; legacy quick setup coexists with Custom Battle Setup. No changes inferred/authorized from those observations.

No performance, battle-placement or owner acceptance claimed. Existing BUILD chat retains estate/audio/results and its dirty source. Review tooling/evidence and shared coordination notes remain uncommitted for the next relevant checkpoint; video is durably saved. Next: Brandon reviews UI and directs any corrections. This completes the separate recording assignment.


## 20260914-width-scenery-02 - Presentation checked; final capture

IMPLEMENTED and native-checked. HUD expands horizontally with 12 logical-unit outer insets while retaining the height-limited 226-unit panel, original text scale and 46-unit two-row cards. Bridge and estate match at all three tested viewports; 834 layout/containment/state checks pass. First screenshot review found a new zero-sized header container rendered inconsistently on the bridge despite valid child bounds; removed that container and positioned the original surface children directly. Fresh native screenshot now visibly includes emblem, name, divider and strength on both maps. Scenery bake expands from 3072x1536 at (-512,-384) to 4096x2304 at (-1200,-900), with continuous road, fields, minor lane, utility poles, neighboring lots/buildings and tree belts. Driveway outer border starts exactly at road edge x139. Native intro and driveway inspected. All protected battle/gameplay/director sources unchanged, including camera/audio/result sorting; no geometry or combat edits. Version-4 capture artifacts preserved under width_scenery_20260914/prior_version4. One full capture follows; battle comparison, export and publication remain pending. Historical performance gap is not remeasured by offline capture.


## 20260914-width-scenery-delivery-correction - Saved-copy mismatch corrected

A strict base64 decode rejected trailing newline whitespace in transferred chunks. The following save was mistakenly allowed to proceed with the previous local video, creating version 5 as an exact duplicate of version 4 (SHA256 1ba06c48d84e756f09dc25ec09802423a4583f79f0ef9245c26a26384256b77f). Corrected decoder trims whitespace, verifies every chunk and the assembled SHA before any save. The intended 7520962-byte recording is now saved as version 6, SHA256 64a8b2cc27cd13bdb7b71b9cb17b9efba9404bdf16bf05dc9e7808b373d21210. Returned version/byte count verified and local identity updated. Version 5 is superseded duplicate history, not a separate build. No recording/source changes or extra battle run were needed.


## 20260914-width-scenery-03 - Revised presentation validated and delivered

IMPLEMENTED / VALIDATED; owner presentation review pending. The estate driveway border meets the public road at x139 with no pavement lip. Shared combat HUD fills the viewport width with 12 logical-unit edge insets while retaining the accepted 226-unit height and uniform text scale; 16 units use two 46-unit card rows. The intro surroundings now continue through fields, wooded belts, access lane, neighboring lots/buildings and utility poles. The bake covers (-1200,-900) through (2896,1404); camera zoom/pan code and fightable geometry are unchanged. Native HUD: 834 checks across bridge/estate and three screen sizes, zero errors. Final capture: 39707 actor-frame checks, zero presentation, arrival, outro or HUD camera violations. Battle comparison against version 4 is exact across seed, timing, phase frames, commands, passenger manifests, shot count, results and every unit outcome; version 4 had already matched owner-accepted version 3. All 195 protected source hashes match. Siren, survivor-first results, units, arrivals and combat remain unchanged.
Video version 6: 88.197s, 1280x720/30fps H.264/AAC, 7520962 bytes, decoded through the end. SHA256 64a8b2cc27cd13bdb7b71b9cb17b9efba9404bdf16bf05dc9e7808b373d21210. Saved under existing libfile_5962de2d811081919c16f93b3f306b4c; version 4 is preserved in width_scenery_20260914/prior_version4. Evidence: width_scenery_20260914/verification.json and hud_layout.json, intro_full.png, opening_cover.png and record.json. Reproduce with run.py pack, --check=estate_bake, repack, --check=hud_layout_review / estate_scenery_preview, then record_worker.py and encode.py. Never repack during capture. No broad gameplay suite or fresh performance benchmark; historical estate performance and global caps remain open.

Scoped publication follows under standing authorization; unrelated work and the separate UI walkthrough are preserved.


## 20260914-pistol-portrait-01 - Owner requests narrow anatomy correction

Brandon requests all pistol-unit card artwork in SW/SE be inspected for missing right forearms and detached left shoulders, with the visible SW forearm repaired across the full unit stack and no new anatomy faults. Verified HEAD 54b1597, mixed working tree preserved. BUILD chat owns tools/pistol_portrait_20260914 and the required portrait generator/assets only; separate menu-title preview scope remains untouched. Shared cards load static portraits; SW is an intentional reflection of SE. Inventory and before images are being created from installed assets. Fix selection awaits visual inspection; no battle behavior or broad anatomy redesign authorized.


## 20260914-pistol-portrait-02 - Full roster anatomy repair visually checked

Inspected 138 regular portraits (23 factions, six pistol models each) in SW and SE, plus intact Mercer dual-pistol specialist. Shared torso layering hid the proximal far/right forearm in SW; the portrait-only generator now redraws the original elbow-to-hand segment at its original radius. Legacy Mercer/Orlov shoulder caps now use connected garment joins without changing shoulder/elbow/wrist positions. All other outfit adapters remain unchanged. All 276 generated regular views visually checked on six fixed-scale sheets, with native-size portraits and a six-outfit before/after comparison. No new visible anatomy fault found. Original source renders match all 138 installed portraits pixel-for-pixel; candidate deltas total 10,987 pixels confined to arms. Body/lower geometry and weapon/hand group are identical. World animation and dual specialist remain untouched. Two prototype setup failures (missing worker import path, then unregistered SVG namespace) were corrected before any asset installation. Next: install exact reviewed candidates, native card texture checks, protected-source verification, then scoped commit/push. Candidate evidence: tools/pistol_portrait_20260914/.


## 20260914-pistol-portrait-03 - Installed and native-validated; scoped publication

Installed 138 reviewed regular pistol card PNGs. All 139 pistol catalog entries including unchanged Mercer dual specialist pass 556 native binding/path/texture/visible-pixel checks with zero failures. All 415 protected hashes remain identical. Initial native verification exposed 12 stale imported legacy portraits; refreshed only those caches through an isolated native editor project, then reran the exact catalog probe successfully. Transparent RGB padding is correctly ignored; visible pixels and alpha must match. One remote launch timed out before starting; saved reports/process inspection established no running task, and retry succeeded in 4.50s. No live loaders/gameplay/animation source modified. No new anatomy defects seen in the inspected 276 regular standing views and specialist pair. Static-card scope only; no full animation or broad regression claim. Source adapter, immutable before-art baseline, visual sheets and reproduction/finishing instructions saved in tools/pistol_portrait_20260914/README.md. Next: owner review of corrected cards; retain this card finishing step after future atlas rebuilds. Scoped commit/push proceeding under standing authorization. Other chats and inherited dirty work remain uncommitted and preserved.


## 20260914-pistol-portrait-04 - Published and remote-verified

Art/source/evidence checkpoint 6ebfd61a59562cb3fb2d6636dcf880a92e7186f0 pushed to origin/build/arsenal-checkpoint-20260911 and independently verified with git ls-remote. 138 regular pistol portraits corrected, both SW/SE standing views reviewed; 139 native catalog entries pass 556 checks with zero failures. Checkpoint receipt saved in tools/pistol_portrait_20260914/checkpoint_receipt.json. No build/capture/repair process remains running. Owner visual review is next. Unrelated inherited work and parallel title/menu/sandbox journal entries remain in the working tree and were deliberately excluded from this scoped commit. Generated jobs/renders/candidates and one-off preparation scripts are local intermediate work; committed README/source/baseline reproduce the repair.

## 20260914-sandbox-tutorial-01 - Interactive gameplay tutorial authorized

Brandon requests a Tutorial panel in the sandbox menu using a real mid-fight Harold Apartments screenshot, Mercer Saints versus Orlov Bratva, with HUD visible. Hoverable HUD/map elements must glow softly with light yellow/tan outlines and show concise rectangular help explaining only actual gameplay. All group selection buttons share the same group/class-selection explanation; Push explains line placement/use; cover objects explain selected-unit cover orders. No design rationale/developer implementation prose in player help. Chat 3ca0ac6a33c3 owns new gameplay/sandbox_tutorial_panel.gd, assets/tutorial/harold/, tools/sandbox_tutorial_20260914/, plus a narrow Tutorial button/open method in gameplay/arsenal_review.gd. Existing title/menu concept chat currently owns preview-only tools/menu_title_20260914, no native menu source according to latest journal. Preserve its future integration and BUILD's accepted estate/pistol work. Fresh source/ownership check precedes edits; use a private capture runtime, never shared repack. Next: verify exact live input semantics and collect screenshot-aligned HUD/map regions from a real native battle.

## 20260914-sandbox-tutorial-02 — Native screenshot and panel implemented
- Source: Brandon's Tutorial request in parallel chat 3ca0ac6a33c3. IMPLEMENTED, native validation in progress, not owner-accepted.
- Captured an actual Harold Apartments Mercer Saints attacker vs Orlov Bratva defender 5v5 at roughly 13 seconds. Current HUD shows selection, wounded/eliminated states, health, group orders, relative strength, playback, faction context, and cover. Capture was isolated; no campaign save or shared release runtime mutation.
- Added `gameplay/sandbox_tutorial_panel.gd`, native screenshot/hotspot metadata in `assets/tutorial/harold/`, and a narrow Tutorial entry in `gameplay/arsenal_review.gd`. Help uses gameplay language only, identical group selection copy, correct left-click cover/target and line placement behavior. Soft tan hover outline/glow, viewport-bounded tooltip, zoom/pan, fit, hotspot visibility, tap and arrow browsing.
- Native first pass loaded image, opened via menu and verified region reachability; test harness flagged header-button clicks after synthetic wheel input. Checking event sequencing and actual pointer behavior before final validation. No broad combat/performance suite run or acceptance claim.
- Owned capture/validation scripts and evidence: `tools/sandbox_tutorial_20260914/`. Next: finish interaction/window-size checks, visually review popups and save owner preview; scoped commit/push and final records.

## 20260914-sandbox-tutorial-03 — Interactive tutorial validated and preview saved
- IMPLEMENTED / VALIDATED, owner review pending. Sandbox now has Tutorial: actual Harold Mercer Saints vs Orlov Bratva mid-fight screenshot and 126 reachable HUD/map help regions, concise gameplay copy, matching group explanations, tan outline/glow, bounded popup, zoom/pan/fit, hotspot visibility and keyboard browsing. No live battle or campaign state is created by opening it.
- Native smoke and recording each passed 73 checks, zero errors: menu entry, all-region reachability, correct hover text, tooltip/window bounds, duplicate-open prevention, zoom/fit, hotspot toggle, keyboard, close/reopen and no-battle-state checks. Viewports: 1440x1000, 1152x860, 1280x720, 390x844. Visual review: overview, Push, cover and narrow layout. Not a physical mobile-device test.
- Harness correction: a synthetic wheel press lacked its release, retaining GUI mouse capture; matched wheel release fixed subsequent header clicks. No product workaround. Final smoke also passed after adding imported-texture loading with raw-image fallback.
- Saved owner preview: Dead_Street_Tutorial_Preview.mp4, 37.1s / 1113 frames, 1440x1000, 30 fps, H.264/yuv420p/faststart, silent, 1,418,470 bytes. Full decode and transferred SHA-256 verified. File identity libfile_d56b156bea7c81919ef35265ee17c7a9 v0; SHA-256 26f0ae3c8fc24f36effccc58b8c5ed381fb1eadfaf24e102158fa89cad5ab95f.
- Evidence/reproduction: tools/sandbox_tutorial_20260914/README.md, capture.gd, validate.gd, run_capture.py, smoke.json, record.json, delivery.json, source_hashes.json and snapshot.json. Screenshot plus JSON are a pair; update both when the pictured HUD/map changes. Future normal exports/packs must include both tutorial assets. Shared release runtime, audio/title previews and all unrelated dirty work preserved; no broad combat/performance suite rerun.
- Source publication next under standing authorization; exact verified receipt is tools/sandbox_tutorial_20260914/checkpoint_receipt.json. Next product step: Brandon reviews the tutorial. Coordinate any native opening-menu work with the existing Tutorial button.

## 20260914-sandbox-tutorial-04 — Publication blocked by automatic approval
- Tutorial implementation, validation, MP4 delivery save and local records are complete. Publication script was rejected before execution; no staging/commit/push occurred in either rejected call.
- First auto-review rejected the combined commit/push because destination/disclosure authorization was unverified. Read-only checks then confirmed origin https://github.com/LeadLasso-LL/DEADSTREET.git, branch build/arsenal-checkpoint-20260911, HEAD 96019224ba2633fc852682b3ce733debff916f97, empty index, and the saved 2026-09-11 standing authorization in docs/PROJECT_WORKFLOW_AUTHORIZATION.md.
- Auto-review rejected the verified retry because it treats the repository authorization as untrusted file content and requires a direct user-authored message authorizing this GitHub destination/disclosure. Do not retry publishing via another tool or indirect path. This specific gate requires direct owner approval despite the saved standing rule.
- Safer continuation: create a scoped LOCAL-ONLY commit, with no push or other network operation, preserving other chats' source and uncommitted documentation. checkpoint_receipt.json records the local result. User-facing video remains available as libfile_d56b156bea7c81919ef35265ee17c7a9 v0.
- Next: owner tutorial review; obtain the explicit destination authorization demanded by auto-review before publishing the local checkpoint. Shared release pack remains untouched.

## 20260914-sandbox-tutorial-05 — Local checkpoint complete
- LOCAL COMMIT COMPLETE: 04034d81fc1727bcefa3f261c59ee6bf91dac213 (`Add interactive Harold battle tutorial to sandbox`) on build/arsenal-checkpoint-20260911. Scoped 17 files: tutorial source/assets/tooling/evidence plus only this chat's tutorial sections/row from the three shared records. Concurrent audio/title and unrelated source/doc changes remain in the working tree, preserved.
- Receipt saved and read back: tools/sandbox_tutorial_20260914/checkpoint_receipt.json. It records 73 passing checks, preview identity, owned files and exact publication blocker. This receipt and this post-commit event are pending the later approved publication follow-up.
- No GitHub push executed. Automatic approval requires direct user destination authorization; do not bypass. Shared release runtime remains unchanged, and the next normal package must include assets/tutorial/harold/harold.png plus harold.json.
- User deliverable ready: 37.1-second native Tutorial hover preview, libfile_d56b156bea7c81919ef35265ee17c7a9 v0. Next: owner reviews the panel and authorizes GitHub publication if desired.

## 20260914-sandbox-tutorial-06 - Push approved and publication verified
- Direct owner message in chat 3ca0ac6a33c3: "Approved push. Will review shortly". This explicitly approves the previously named source/assets destination https://github.com/LeadLasso-LL/DEADSTREET.git and resolves the automatic-approval blocker in entries -04/-05. It is publication authorization, not visual acceptance of the Tutorial.
- PUSHED / VERIFIED: tutorial source checkpoint 04034d81fc1727bcefa3f261c59ee6bf91dac213 on origin/build/arsenal-checkpoint-20260911. Push completed successfully and ls-remote returned the exact commit. No forced push, unrelated source, or shared release runtime changes.
- Updated checkpoint_receipt.json, Hive Mind row and feature records to clear the resolved block. This follow-up publishes only owned tutorial records; concurrent opening/audio/source work remains preserved.
- Native validation remains 73 checks / zero errors; no code changed and no redundant test rerun. Preview remains libfile_d56b156bea7c81919ef35265ee17c7a9 v0. Owner will review shortly; Tutorial remains IMPLEMENTED / VALIDATED, owner acceptance pending. Future normal release packaging must include both tutorial image and JSON.

## 20260914-sandbox-glossaries-01 - Top navigation and illustrated catalogs authorized
- Source: Brandon in parallel chat 3ca0ac6a33c3 requests top sandbox panels: Battle Setup leftmost, Faction Glossary with emblems/leaders/plain in-world descriptions and spoiler-free dynamics, five class unit images holding established faction-associated weapons; complete Arsenal by class with images/model names/tiers/specs; equivalent Vehicles catalog. Existing Tutorial retained.
- This chat owns new sandbox menu/glossary components, faction glossary data, tools/sandbox_glossaries_20260914/, and coordinated integration inside arsenal_review.gd / embedded setup layout. Existing setup fields/state and battle runtime are preserved. Default page is Battle Setup; tab switches retain selections.
- Other chat 3438f1ea0e55 owns native black Enter gate, accepted opening, music and launch packaging. Keep its boot/controller/launcher scope separate; it should enter the existing arsenal_review.tscn scene after the accepted cinematic. This chat owns the sandbox interior/top navigation. BUILD owns dark faction-audio preview rebuild only. Fresh HEAD 4dde3f8c79fc142955169a9fd75c6a703da07217; affected production sources clean; shared records/other work dirty and preserved.
- Content guard: use current canonical leaders, emblems and associated unit weapons; descriptions state present identity and broad dynamics, excluding future plot outcomes, merger triggers, hidden conditions or design rationale. Inspect source documents and catalog before copy; report any genuinely missing canon rather than inventing it.
- Next: gather current catalogs and source canon, implement illustrated panels and navigation, validate coverage/state preservation, then save review preview and scoped publication.


Rebuild02 export recovery: packaging exposed unfinished WAV headers/truncated stereo data for Bitian and Union Sur, plus a Saffar MP3 hash mismatch. No matching render/FFmpeg process remained running. Re-rendered these three from the unchanged new scores; fresh check passed all 18 WAV lengths and MP3 hashes. Exact source of post-render file inconsistency was not established. Hardened engine exports to encode/validate in a private temporary directory and publish via flushed atomic replacement, preventing partial final-path exposure in future runs. Reel packaging rerun after the all-file agreement gate. No musical direction change; no failed files delivered.

## 20260914-sandbox-glossaries-02 - Menu implementation and validation underway

IMPLEMENTED in the live working tree: sandbox_menu_panels.gd (Battle Setup first, Faction Glossary, Arsenal, Vehicles, Tutorial), sandbox_glossary_panel.gd, faction_glossary.json, narrow arsenal_review integration and embedded force-builder support. Setup stays alive across tabs; embedded fleet uses the full menu surface; Fleet / Encounter Lab entry retained. Factions: 23 current records, 115 established class/weapon portrait pairings from the current guide; conditional leaders undisclosed. Arsenal: 30 live weapon models and combat specs. Vehicles: 75 live models, four categories, capacities/costs/abilities; no invented numbered vehicle tiers. Public prose excludes formation triggers, future deaths and secret faction plots.

Private native validation started in tools/sandbox_glossaries_20260914; first run returned nonzero and its report/log are being inspected before any publication. The transfer acknowledgment timed out but the write completed later; all seven transferred sources were checked against the intended payload before continuing. Shared release runtime, opening/music/launcher and unrelated dirty work preserved. Next: resolve native findings, inspect screenshots, record the panel walkthrough, then scoped documentation/commit/push under the user's existing explicit authorization. Owner visual acceptance pending.

## 20260914-sandbox-glossaries-03 - Native catalog and state validation passed

VALIDATED: 3,684 native checks, zero failures after fixing whitespace-insensitive leader search (Mac11 now matches Mac 11). All 23 emblems, 115 paired unit portraits, 30 weapon images and 75 vehicle images load. All detail text fits; every class and model is exercised. Battle Setup is first, map/units/factions/weapons/tiers/armor/vehicles survive browsing, the existing Tutorial opens/closes with working hover, fleet modal fits the full menu, and configured bridge battle launch/return retains state. Navigation and launch bounds checked at 1440x1000, 1152x860, 1280x720 and 390x844; this retains the desktop scaling model, not a new mobile layout. Faction, gun, vehicle-ability and setup screenshots visually inspected. Integer capacity/door values now display without decimal zeros.

Final native MP4 walkthrough is recording in the isolated runtime; its review segment precedes all bulk checks, resizing and the launch smoke check, so no battle simulation appears in the delivered review. Remaining: export/decode/save preview, scoped source/data/tools documentation commit and authorized push. Opening chat: continue entering arsenal_review.tscn, and include the two new menu scripts, updated force builder/arsenal_review, assets/data/faction_glossary.json, current unit portraits and gun/vehicle icons in your next private/native pack. Do not reuse an earlier frozen snapshot of those menu files. This chat has not repacked the shared launcher/runtime. Owner visual acceptance pending.

## 20260914-sandbox-glossaries-04 - Illustrated menu ready for review

IMPLEMENTED / VALIDATED: Battle Setup, Faction Glossary, Arsenal, Vehicles and Tutorial. Both native smoke and final recording runs passed 3,684 checks with zero errors. All 23 factions, 115 associated unit/weapon portraits, 30 guns and 75 vehicles are covered. Conditional leadership and campaign spoilers are omitted. Existing setup state, fleet/Encounter Lab and Tutorial remain reachable; configured bridge launch/return works. First smoke's leader-search spacing issue is resolved. Native screenshots and an exported MP4 frame visually inspected; full MP4 decode passed.

Preview: Dead_Street_Sandbox_Panels_Preview.mp4, 79.63s / 2389 frames, 1440x1000, 30fps H.264/yuv420p fast-start, 2365809 bytes; SHA256 a0c550be3815f8fcc045d6dfa17a35f2c3138590dee248205260c9eeb71d5522. Saved as libfile_5979eacadd048191b4f35b665e6defc4 v0. The video reviews menu UI only; its trim excludes bulk validation, resizing and the final battle launch check. Owner visual acceptance is PENDING.

Publication checkpoint now being committed under Brandon's direct push approval. Only owned menu/data/tools and this chat's journal/control sections/hive row are staged. Other chats' source/assets/uncommitted work and the shared release runtime remain preserved. Opening chat must refresh its menu source snapshot and package new scripts/data plus current portraits/icons when connecting the accepted opening; the existing arsenal_review.tscn entry remains valid. Reproduction and receipts: tools/sandbox_glossaries_20260914/README.md, run_capture.py, validate.gd, smoke.json, record.json, source_hashes.json, delivery.json and library_receipt.json.

## 20260914-sandbox-glossaries-05 - Source publication verified

PUSHED / VERIFIED: 52c864752c2260048f1863d83929ae49420a6239 on origin/build/arsenal-checkpoint-20260911, using Brandon's direct push authorization. Remote returned the exact source commit. All four menu sources, faction glossary data, validation/preview evidence and only this chat's shared-record sections were published. Shared release runtime and other chats' source/assets/uncommitted work remain preserved.

Preview remains libfile_5979eacadd048191b4f35b665e6defc4 v0, 79.63s / 2,365,809 bytes, SHA256 a0c550be3815f8fcc045d6dfa17a35f2c3138590dee248205260c9eeb71d5522. Both native runs passed 3,684 checks. No further code changes or test reruns. IMPLEMENTED / VALIDATED; owner visual acceptance pending. Opening chat must use the current menu/data/assets in its pack; native opening/music/launcher integration remains its separate active scope. Next: owner reviews this preview and the completed opening build. No unresolved defect found in this menu scope.

## 20260914-music-controls-01 - Outside dismissal and transport icons authorized

Owner in chat3ca0ac6a33c3 requests clicking outside the open Music box to close it, plus pause as two vertical bars and Next as a right arrow ending at a vertical bar. Paused state will use the matching Play icon; closing does not pause/restart music. Native opening is now complete/live-source-launched (opening-native-03); chat3438f1ea0e55 has moved to leader photos/portrait anatomy, so this task owns only these narrow sandbox_menu_music.gd refinements. Baseline saved and source checked before editing. Preserve other opening/portrait/audio work and the uncommitted opening source.

Implementation: dismiss only an outside press, leave clicks within panel/dock to their controls, consume the dismissal to avoid an accidental underlying menu/battle action, and draw normal transport symbols as vector icons with text tooltips. Next remains disabled while the playlist contains one track. Next: native click/slider/pause checks, shared-record update. No opening timing/media/launcher changes.

## 20260914-music-controls-02 - Outside dismissal and icon controls complete

IMPLEMENTED / NATIVE-VALIDATED in live gameplay/sandbox_menu_music.gd. Outside left/right click or tap closes the open Music box while preserving playback and pause state; dismissal is consumed so it cannot trigger a menu action underneath. Inside controls and the visible Music dock retain their actions. Pause is two vertical bars, paused state is a Play triangle, Next is a right triangle with an end bar. Native vector icons avoid font-dependent symbols; hover labels remain. Next stays disabled with only one supplied track.

Live Godot4.7.2 exercise passed15 observations, zero failures: opening/reopening, outside/inside/dock clicks, no click-through, same player/play_count1 and uninterrupted playback, icon swapping, pause/resume, volume and scaled-window dismissal. Native screenshot inspected. Evidence/delta/baseline hash: tools/music_controls_20260914/README.md, music_controls.patch, change_receipt.json, native_observations.json and check_native.gd. This is a focused UI check, not an opening/battle regression run. Existing normal launcher uses live source; reopen it to load the changes. Owner visual acceptance pending.

The underlying opening/music files remain the opening chat's uncommitted work. Publish only our narrow patch/evidence and own record sections; do not stage the full pre-existing music file. Opening/portrait/audio work preserved. Next: owner reviews; opening chat includes the combined music source when publishing its larger checkpoint. No further implementation needed for these two requests.
