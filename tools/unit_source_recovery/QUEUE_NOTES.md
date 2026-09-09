# Approved gameplay and animation queue
Base commit: 3a08aa6. User request: larger weapons, quicker restrained jog, pump shotgun, weapon-specific muzzle flashes and recoil, wounded limp with abdomen hand, and audited cover fixes.

## Source and export
All original guns use 1.12 times their previous scale. Hand and muzzle anchors follow the weapon scale.
Pump shotgun is a reusable fourth weapon for all three outfits. Black outlined metal, wood stock and ribbed wood pump, support palm beneath the fore-end.
Healthy jog: lower recovery arc, flatter toe-off, hip less compressed, 2.7 world units per cycle instead of 3.7. Movement speed and weapon balance are unchanged.
Wounded: unequal leg support periods, low sore-foot recovery, forward lean and breathing, one hand holding the gun and one on the abdomen. No wounded color modulation.
Wounded idle now has 24 frames. Atlas clips after it shift by 23 frames; 188 frames per direction, still six atlas rows. SW/W remain exact reflected SE/E pixels.
Muzzle flash suppression for retained sprites was removed. Runtime flashes use compact angular flames, with SMG < rifle < shotgun size; recoil multipliers differ per weapon.

## Build
Run export_review.py, render_native.gd with Godot, finish_review.py, update_sw_muzzles.py, mirror_exports.py, then queue_preview.py.
Despite its legacy filename, update_sw_muzzles.py now calculates every direction and weapon, including wounded poses.
Copy review_atlases PNGs into assets/art/units/pixel_v1 and run Godot import. Commit manifest and muzzle JSON with atlases.

## Gameplay
AI deployment claims an exact matching cover slot through the authoritative exclusive occupancy service.
Closing cover approaches persist through the transition into firing range while destination safety, target and command remain valid.
Defenders can reposition for range only to covered local firing positions. No open-ground chase for an out-of-range target.
The deployment validation now checks actual slot ownership rather than expecting empty occupancy.

## Validation
All 18,048 frames rendered; all 4,512 W/SW reflected frames verified.
Nine focused regression checks passed. Full suite comparison found 68 pre-existing baseline failures; the six additional failures were investigated, behavior narrowed, and the outdated occupancy expectation updated. Focused checks now pass; do not represent the entire legacy suite as green.
The first live trace confirmed all three defenders started in cover, the SMG reached threshold cover, and the defender with the legacy shotgun ID (actual SMG loadout) moved into cover. Final runtime trace is saved separately.

Final runtime: 59.8 average active FPS, 32 shot events, four living units at 15 seconds. Actual shotgun loadouts have a separate shotgun_showcase.gd fixture because legacy participant IDs are not authoritative weapon IDs. Nine focused regression checks pass.
