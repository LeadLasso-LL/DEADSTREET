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
