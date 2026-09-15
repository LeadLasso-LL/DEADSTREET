# Current correction: scarlet HQ Veloce
See hq_red/README.md for the latest car revision, screenshot and focused validation. Blue Volta revision hq_upgrade/ was rejected by the owner. The following original pass narrative and943+6 checks describe the pre-correction Cabrillo version.

# Harold Apartments — vehicle proportions and Arsenal neighborhood pass

Harold Apartments now uses12 actual Arsenal parked vehicles with model-specific1.6x physical footprints and the shared fleet renderer. Cheap Rattleback/Bayou cars, Workhorse, Courier and Civicline dominate; Cabrillo Lowline and Rancher Seven immediately by Saints HQ are the two modest upgrades (canonical Mercer preferences). Road widened12 to20 units (y23..43), lower sidewalk/building strip/lamps/litter shifted8; north frontage unchanged. Ground cache rebaked3456x1848. Three arrival options now allocate the full enlarged convoy length rather than the obsolete x31 lower bound. Unit scale, HUD/camera code and shared range feature preserved.

Native Windows Godot4.7.2 validation: 943 checks, zero failures. All12 canonical parked sprites/anchors/footprints checked, no static overlaps, all three heavy-convoy arrival choices clear of parked scenery, all12 transported attackers have exit routes, all available cover slots plus both entrances/alley/lower-walk endpoints reachable. Final bake/import/native logs contain zero script/engine errors. Screenshot uses a separate paused12v12 Orlov/Mercer scene with faction-appropriate Taiga/Bayou/Outlander arrivals. Assistant visually reviewed; owner appearance acceptance pending.

Harold also supplies1.52 units of authored vehicle padding for fully open doors; the shared context/planner retains its previous0.6 default everywhere else. This fixes the native Taiga/Bayou door-to-neighbor body overlap found during screenshot capture. Bridge/estate native setup/start and unchanged-clearance smokes pass6 checks. New planner/context source was clean before editing; guarded backups preserve it. The test fixture now reopens both sides before cycling arrival options, avoiding stale defender ownership of moved vehicle cover; no collision or ownership checks were weakened.

Bounded before/after native combat observations: before frame median/p95 28.394/38.170ms and advance median/p95 9.627/15.842ms over 20.02s; after 20.920/29.266ms and advance 7.138/12.901ms over 20.01s (active at cutoff). These are bounded native samples with changed geometry and concurrent project work, not a sustained60FPS promise or a full benchmark. Whole-project legacy regression suite and every fleet combination were not run.

Earlier failed attempts are retained: art identifier typo fixed; first full import timed out and exposed12 backup scripts shadowing canonical global classes; evidence folders excluded from Godot import via .gdignore, backups preserved and generated cache repaired. Clean subsequent editor import verifies the durable fix. Initial arrival test was checking an already-committed sandbox; corrected isolated fixture then exposed the real Close/Medium placement-width limit, now fixed. See import_recovery.json and logs.

Evidence/reproduction/source hashes: tools/harold_scale_20260915/README.md and completion_receipt.json. Current HEAD db2da64b0cb8a11c5b57a056b0829dcea246d289, branch build/arsenal-checkpoint-20260911, index empty. Concurrent faction-audio publication advanced HEAD from baseline d262e8f; that work was preserved. No staging/commit/push for this map pass. Next: owner reviews screenshot, then reopen the normal live-source Sandbox to play; prior publication blockers remain separately recorded.

## Reproduction

- Ground only: Godot --path REPO --script res://tools/dusk_review/bake_harold_frontage.gd -- --ground-only
- Import: Godot --headless --editor --import --path REPO (archive .gdignore markers must remain).
- Native checks: Godot --path REPO --script res://tools/harold_scale_20260915/check.gd
- Screenshot: same command followed by -- --screenshot.
- Engine: C:/Users/brand/OneDrive/Documents/Godot/Godot_v4.7.2-stable_win64.exe, NVIDIA GTX1650 Max-Q, native1440x1000 window.
- Final authority: after_report.json, after_final.log, arsenal_bake.log, arsenal_import.log, screenshot.log, DEAD_STREET_Harold_Updated.png.
- Before artifacts: before_report.json, before_ready.png, before_combat.png, baseline/ and baseline_hashes.json. prepare.py embeds the exact original baseline probe. Failed/intermediate records remain historical and are not final validation.
- Installer scripts are historical guarded transformations, not scripts to rerun over current source.

## Parked roster

| Curb / west to east | Arsenal model |
| --- | --- |
| north_car_0 (x1) | Rattleback Hatch |
| north_car_1 (x8.8) | Bayou Sedan |
| north_car_2 (x20.3) | Scarlet Veloce Rosso (conspicuous HQ upgrade; replaces rejected blue Volta) |
| north_car_3 (x29.6) | Rancher Seven |
| north_car_4 (x40.5) | Bayou Sedan |
| north_car_5 (x54) | Courier Panel Van |
| south_car_0 (x1.8) | Bayou Sedan |
| south_car_1 (x12.1) | Workhorse C10 |
| south_car_2 (x22.4) | Rattleback Hatch |
| south_car_3 (x32.7) | Bayou Sedan |
| south_car_4 (x43) | Civicline DX |
| south_car_5 (x53.3) | Rattleback Hatch |
