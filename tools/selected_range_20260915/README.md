# Selected-unit firing range — 2026-09-15

Status: IMPLEMENTED / NATIVE-VALIDATED; owner visual acceptance pending. Publication result is separate in publication_receipt.json if present.

Select one living friendly in an active or paused battle to show a faint red ground circle. It follows the unit and uses the equipped model/tier maximum range from BattleWeaponCatalog. The circle is projected into the map ground plane, drawn under scenery/units, and clears for group/no/invalid/dead selection or battle exit. Nominal reach is not a LOS/accuracy/readiness guarantee. Combat, HUD, camera, audio and portrait sources are unchanged by this pass.

Runtime files: gameplay/tactical_selection_range.gd, .gdshader and eight added wiring lines in tactical_battle_view.gd. One retained Polygon2D; local-vertex shader coordinates (no texture dependency), faint fill 0.028 alpha, feathered rim up to0.178 alpha, 120ms fade-in. Original UV-based attempt was invisible on a textureless quad; native screenshot review found it and final mapping fixed it.

Reproduce on DESKTOP-7CL4DM3 with the official Godot4.7.2 console binary under Documents/Godot: --path <repo> --script res://tools/selected_range_20260915/check_native.gd --position 20,30. run_native.py launches that isolated review window, captures native.log and reports engine/script errors. This does not replace or close a user's running sandbox.

Final result: 234 checks PASS, zero script/engine errors, three independent 5-v-5 native fixtures (Harold, river_bridge, whittaker_estate). Fifteen model/tier range samples in native_validation.json: pistol24, SMG17, shotgun14, rifle35, sniper78. Actual HUD selection, single/group/none/dead/hidden/results states, movement following, zoom invariance, no paused combat-state change and layer ordering checked. Eighteen screenshots generated; final Harold SMG/bridge rifle/estate pistol visually inspected. This is not a benchmark, exhaustive model audit, full combat regression or owner visual acceptance.

The regular live-source sandbox loads the feature after reopening. Existing running sandbox instances keep their loaded source. Initial branch build/arsenal-checkpoint-20260911, HEAD710964102ef3f6cca3f47bcbf26a815653e59453; concurrent soundtrack publication advanced HEAD to d262e8f43f34b889ce72b1705d0f4de36d7e40fd during this pass. View was clean before our edit; final diff is exactly eight new lines. Existing mixed portrait/leader/Arsenal/opening/music work and index preserved. initial source backup/install receipt retained locally. final_source_hashes.json binds validation to runtime source.

Records: journal selected-range-01 (decision) and selected-range-02 (implementation/correction/validation), Tactical Controls topic, Project Control milestone, Hive Mind active next action. Durable preview libfile_5a697f4ecb308191a828e57f40a34f36. Next: owner visual review; tune only if requested.

Publication: BLOCKED by automatic approval review before staging/commit/push; explicit approval for the range-feature payload to the established GitHub origin is required. See journal selected-range-03.
