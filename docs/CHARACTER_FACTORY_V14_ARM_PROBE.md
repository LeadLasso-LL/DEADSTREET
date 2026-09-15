# Character Factory V1.4 prerequisite: controlled SE arm probes

Date: 2026-09-08. HEAD remains 5a7d3bd. All changes uncommitted.
Status: diagnostic rendering completed; NO usable two-handed pose or static style accepted.

## Scope and evidence
- Reused integrity recipe, same character/clothing/weapon, SOURCE_2 materials/lights, SE and provisional 56-degree camera.
- Opt-in `arm_probe` config branch in the existing DAZ factory; ordinary integrity/style paths unchanged.
- Camera built once from HYBRID_B before each batch; all six cell camera readbacks identical.
- Recorded hip and both thigh rotations identical across all cells. Only arm adjustments requested.
- DAZ completed both runs with three PNGs each and exited unattended.
- Runs under `%LOCALAPPDATA%/DeadStreetCharacterFactory/runs/`:
  - `20260908_141001_arm_probe` (A/B/C)
  - `20260908_141445_arm_open_probe` (D/E/F)
- Exact configs, effective joint rotations, validation records, logs and original PNGs remain in those external runs.
- A: HYBRID_B control. B/C: right forearm X -35/+35 degrees. The filenames say ELBOW, but these are axis probes, not verified anatomical bend labels. C clamps to effective X=80.
- D: right forearm Y -55. E/F: same plus right upperarm Y -35/+35.
- A/B/C: rifle remains unreadable. D/E/F: rifle visible, but left hand visibly fails to support it.
- D/E/F left-hand-to-weapon-AABB distances: 31.32 / 18.74 / 34.77 DAZ world units; even the loose existing test fails.
- A bounding-box-distance pass is not evidence of a correct grip; no cell is production-suitable.

## Next technical dependency
Replace approximate world-AABB support targeting with a verified weapon-local support contact and joint-aware arm placement. Read actual rig channel labels/limits; verify both hands visually, avoid torso intersections, and preserve fixed-camera comparisons. Then present viable pose options for product review before sprite reconstruction.

No runtime/catalog/spec change, no new assets, no style processing, no commit or push. Factory PASS means diagnostic renders completed only. Factory script diff check passed; whole-tree diff check separately finds existing Markdown trailing whitespace in Project Control.

## Support-contact follow-up (2026-09-08)
- Added measurement-only probes and a bounded multi-start coordinate solver, isolated to opt-in arm probes.
- Actual rig readback: forearm X is Twist; Y is Bend. Joint-specific min/max values replace generic +/-120 assumptions in the new solver.
- Weapon-local experimental wrist/knuckle contacts use the existing C_Front geometry region as a basis. They are geometry-informed proposals, NOT verified production sockets.
- Contacts: wrist [5,7,6], middle knuckle [-1,10,8] in weapon-local coordinates, transformed with DzMatrix3.multVec.
- Numerical check confirmed getWSPos changes immediately after control edits, matching the position after processEvents.
- Earlier D/E/F arm configurations still have large contact errors; do not promote them.
- Candidate G_NEUTRAL_FORWARD50 uses right upperarm (0,50,-60), forearm (0,90,0), hand (0,0,0), then solves left shoulder/arm/wrist. Remaining character pose and camera held fixed.
- Measurement run: `20260908_143627_neutral_contact_measure`.
- Render run: `20260908_143910_contact_render`, one raw 512px SE PNG and `contact_comparison.png`.
- Both runs PASS their diagnostic operation. Recorded joint angles repeat exactly (max delta 0); camera identical; no recorded joint-limit violations.
- Wrist target residual 1.88347 and knuckle residual 2.30391 DAZ world units, identical across both runs. These are contact-target residuals, not mesh-to-mesh collision measurements.
- Visual finding: rifle now clearly visible; support hand reaches the fore-end region. Candidate is suitable for reviewing carry-posture intent, not yet proven collision-free or production-ready.
- Comparison board uses identical raw crops enlarged 2x nearest on gray; no source reconstruction or gameplay-size assertion.
- No animation run. Two-point contacts leave roll ambiguity; later animation requires continuity constraints/warm starts rather than independent per-frame seed selection.
- Next gate: product-owner assessment of the across-body carry direction; then bounded contact refinement and static sprite reconstruction. No style acceptance, runtime bind, commit or push.
- DAZ API references consulted: https://docs.daz3d.com/public/software/dazstudio/4/referenceguide/scripting/api_reference/object_index/node_dz and matrix3_dz.
