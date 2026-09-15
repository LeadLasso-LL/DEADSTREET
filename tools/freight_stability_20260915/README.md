# Eastex camera stability correction - 2026-09-15

Owner rejected the clarity recording because the scenery and units shake continuously from combat start.

## Root cause and correction
The clarity pass introduced camera-dependent body-position snapping. CameraSafety fitted the actual translated sprite rectangles, so that cosmetic correction changed camera position and zoom, which changed the next snap. Stationary units participated in a feedback loop. The previous version0 video had no static-rail translation; version1 had1-4px frame-to-frame jumps.

Two guarded production changes:
- gameplay/tactical_actor_presenter.gd: remove camera-dependent body snapping and keep body.position at zero. Native actor positions/animation remain authoritative.
- gameplay/tactical_camera_safety.gd: compute safety extents from the canonical actor footprint, ignoring cosmetic body translation. Existing safety padding, HUD exclusion and automatic fitting remain.

Retained: improved emblem textures/pixel placement, nearest unit sampling, Freight tone/rain visibility, arrival radio gain and positional interior filtering. No combat, weapon, outcome or convoy changes. Preserve other chats' work.

## Evidence
before_motion.json and after_motion.json each contain180 active frames. The opening20 comparisons change camera on every frame before, zero after. Stationary body offsets peak1.155835 before and0 after. Maximum per-frame camera Y difference drops2.912201 to0.677155; remaining movement follows actual moving bounds.

The full replacement capture includes a MotionMonitor: whenever safety bounds and HUD-safe rectangle are unchanged, the camera must remain unchanged; actor bodies must have zero cosmetic offset. full_motion.json contains the full battle samples and counters. The ordinary battle/camera/arrival/outro checks still apply.

The final MP4 must also be checked across consecutive frames of static scenery, not merely isolated screenshots. Temporal review is required for future camera/sprite visual changes.

## Capture
showcase.gd uses the prior seed915523,10v10 forces and legitimate scripted orders. capture_worker.py uses an isolated native1080p project, lossless PNG frames and native audio, then a single H.264/AAC encode. Full source and audit hashes remain on this device. First recordings and failure evidence are preserved in the prior clarity work folder; approved source is not replaced by a video-only stabilization filter.

No staging, commit, push or standalone packed export by this pass. Final delivery/acceptance status follows in the hive mind and handoff.


## 20260915-freight-stability-03 - Fixed and re-recorded; owner review pending
Root cause confirmed: camera-dependent body snapping introduced by clarity pass changed sprite bounds; HUD-safe camera reacted each frame, feeding back into the next snap. Removed body-position snapping and made camera safety ignore cosmetic body translation. Existing nearest sampling, physical-pixel emblems, louder arrival radio, interior filtering and rain/night readability remain. Two source files changed, guarded hashes/backups; no combat/loadout/convoy changes.
Temporal verification:180-frame before/after probes, opening20 camera comparisons20 changes before/0 after; body offsets now0. Full native combat1487 frames:416 unchanged-bounds comparisons,0 unexpected camera changes,0 body-offset errors. Native and final encoded static-rail samples both59 adjacent pairs,0px movement; rejected clarity version1 had up to4px jumps. Arrival/outro and HUD camera safety errors0. Same legitimate scripted outcome: Ashford-Crane victory,8 survivors,49.6 seconds combat.
Delivered new88.1-second1920x1080/30fps H.264/AAC MP4 from lossless native frames. Full decode passes, no clipped audio, arrival mix retained. File DEAD_STREET_Eastex_Freight_Exchange_Stable.mp4,52798126bytes, SHA25645839ac0a2536cd77926c23edbac030b69bf89d9889ac67eb9332065fa43ecbd. Saved libfile_11b997eb8900819180e3d0a22b8074c9 version2, file_0000000080cc81fd9383099e1114a267. Version1 is visually rejected and preserved for comparison.
Handoff docs/handoffs/EASTEX_FREIGHT_STABILITY_20260915.md; evidence tools/freight_stability_20260915/. Future camera/sprite changes require temporal inspection, not only still frames. No concurrent source changes during capture; no staging/commit/push or packed export. Next: owner reviews new recording; reopen live-source Sandbox to load revised scripts.
