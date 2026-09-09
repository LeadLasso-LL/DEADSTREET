# Dead Street tactical decision review
Date: 2026-09-09. Approved visual baseline: a337ae7.

## Scope
Two unchanged six-unit HQ assaults and one assault with move, cover and target commands. Same current dusk map, actual runtime, rendered presentation. Samples approximately every 0.1 seconds. Runtime advancement was driven by the review harness; orders used the real tactical orders controller. This tests command acceptance and resulting simulation behavior, not mouse picking or subjective input feel. No production balance or AI changes made.

## Findings
1. **Attacking SMG abandons cover approaches.** Both baseline runs followed the same reservation sequence: arrival vehicle, threshold sedan, east sedan, then defender sedan after being wounded. It never occupied a slot before dying around 5.2 seconds. The threshold cover was abandoned while approaching. Review persistence of valid cover destinations when switching between closing and role-cover behaviors; avoid locking units to cover that has become unsafe.
2. **Defender with legacy shotgun ID (actual SMG loadout) remains stationary outside useful range.** In both baseline runs it stayed at (52.7,20.65), never occupied cover, and died around 4.6 seconds. Defend behavior searches for a new position when firing is rejected for blocked line of sight, but otherwise holds, including range-related rejection. This is a confirmed behavior, not proof defenders should always advance. A protected local position suited to the weapon is the appropriate first correction to assess.
3. **AI deployment lacks cover occupancy handoff.** Deployment service applies assignment positions and commits the side, without assigning the matching cover occupancy. All defenders began with empty occupied slots despite positions matching authored cover slots. Runtime defense only attempts arrival occupancy in particular branches. Placement near cover is not sufficient evidence that the unit receives its intended cover posture/protection.
4. **Orders were accepted.** Move at 0.500s, cover at 2.004s, target at 3.511s all succeeded. Controller calls took 7.45ms, 24.14ms and 0.028ms respectively on this run; these are not end-to-end input latency measurements. Move intent appeared by the next sampled frame and cleared on arrival. The later cover order was interrupted when the unit became wounded, consistent with the existing survival-first rule. Target order selected another healthy unit after the first had died.

## Other observations
All 68 cover slots passed navigation reachability from the arrival area. Threshold sedan-to-west club-wall spacing is 19.33 tactical units, within the SMG maximum of 20. This pairwise check does not guarantee a good route or firing opportunity against moving targets.
Baseline fights resolved at 10.71 and 11.39 simulation seconds; commanded fight at 7.54 seconds. This small sample is not sufficient to change lethality or infer command effectiveness.
Active combat averaged approximately 56-58 FPS. This was a behavior review, not a controlled performance benchmark.

## Recommended work order
1. Carry AI deployment cover assignments into valid, exclusive live occupancy.
2. Retain a still-useful cover approach across compatible behavior changes; release only for a concrete reason.
3. Review defensive local cover selection against the unit's weapon range while preserving defensive anchors.
4. Repeat this scenario and add an alternative deployment before changing damage, range or general battle duration.

Evidence: decision_review.gd, results/decisions_baseline.jsonl, decisions_repeat.jsonl, decisions_orders.jsonl, and corresponding decision logs. Approved unit art was preserved.
