# Sandbox map and convoy refresh — 2026-09-15

Status: implemented, native-validated, ready for owner review in the live-source Sandbox. This pass did not stage, commit, or push. Existing shared work is preserved.

## Owner decisions
- Calder River; Calder Memorial Bridge; Harold Ave. These are display/canon names. Stable geometry identifiers remain unchanged.
- Fill the window; place map preview, dropdown and image choices between faction setups; make selected emblems larger.
- Map changes load that map's recommended unit composition and transport while preserving selected factions. Clicking the already-selected map preserves custom edits.
- Every sandbox map permits 1–16 units per side. Convoys have exactly three formation slots.
- Stateline and Blacktop biker factions, NBPD and TRC can group up to three motorcycles in a slot. Bikes still have independent bodies, drivers and passenger accounting.
- Visual convoy selection below setup, plus a full image picker and three-slot Your Convoy row. Invalid additions are dimmed, disabled and visibly marked; removal immediately recomputes availability.
- No additional heavy-vehicle quota was requested. Three Roadwardens are legal when drivers and personnel fit; a fourth is blocked. Empty capacity never creates extra combatants.

## What changed
The full-window responsive setup has larger 80px emblems, actual native map thumbnails, a centered map selector, and conspicuous convoy strips beneath the force editors. Weapon/class/tier/armor controls, duplication, glossary/comparisons, music and start/return behavior remain available. Picker images add vehicles; individual removal, Clear, Auto-fit, seat meter and Apply support assembling a legal convoy. Launch and picker use the same legality rules.

Presets owned by this pass: Harold 5, Calder bridge 8, estate 12, yard 7 per side. Yard preserves its existing composition/4+3 transport; other presets use suitable transport and existing equipment rules. Presets are recommendations; all maps retain the 16 cap. Faction choice is preserved.

Owned existing source: gameplay/sandbox_force_builder.gd, sandbox_force_config.gd, sandbox_menu_panels.gd, arsenal_review.gd, tactical_battle_presentation.gd, vehicle_fleet_panel.gd; campaign/vehicles/convoy_formation_catalog.gd.
New source: gameplay/sandbox_map_catalog.gd, sandbox_map_selector.gd, sandbox_convoy_rules.gd, sandbox_convoy_slots.gd, sandbox_convoy_summary.gd.
Generated real scene images: assets/menu/maps/harold.png, river_bridge.png, whittaker_estate.png, doble_ocho.png. No generated replacement map art or altered battle-camera framing.

## Validation actually run
- check.gd / check.json: 302 passing checks, no errors. Four map presets and actual 16v16 starts on all four existing maps; exact participant/passenger counts, legal seats and drivers; limit/availability/removal cases; no arrival-path errors.
- groups.gd / groups.json: 16 native mixed motorcycle deployment trials pass: four eligible factions by four existing maps, 16 passengers each. Nonconsecutive bike selections group correctly.
- clicks.gd / clicks.json: 23 native mouse checks pass. Image-map selection/dropdown synchronization, existing tabs, convoy image clicks/Apply, start battle and return preserve edited loadout.
- uishots.gd / uishots.log: native D3D12 layout captures at 1280x720, 1920x1080, 1920x1200, 2560x1080. All map-button rectangles enclosed by selector; final five-map layout inspected, together with seats/disabled cards and packed motorcycles.
- Native runtime: Godot 4.7.2, GTX1650 Max-Q. No claim of 60 FPS at 32 units. Existing cover fallbacks place 31/32 Harold and 28/32 bridge actors in cover at the cap; estate/yard place 32/32. No broad combat, cover or balance change made.
- Existing opening raw-image load warnings remain in uishots log and require proper inclusion/import when packaging. This task validates the live-source launcher, not a refreshed standalone export.

Initial mouse injection used the wrong viewport coordinate mode and registered no clicks, including unchanged tabs. Preserved clicks_initial.log. Correcting root.push_input(event, true) and button_mask yielded the passing native run; production click handlers did not need a workaround. One remote approval service capacity error resolved by retrying the identical permitted launch; no permissions or policy were changed.

## Concurrent Freight Exchange work
Freight Exchange was added by another active map pass during this task. Its added entries in sandbox_map_catalog, sandbox_force_config and presentation were re-read and preserved. The selector was adapted to three columns/two rows for five choices; its native thumbnail appears in the final screenshot. Freight geometry/night/rain/audio and its battle validation remain owned by tools/freight_exchange_20260915 and the newest freight-exchange journal events. Do not interpret the four-map 302 checks as a Freight battle certification.

completion_receipt.json records HEAD 35e0db12aae4d114364c911a69ae2136de30ee4e, build/arsenal-checkpoint-20260911, empty index; 227 unrelated baseline scripts remain byte-identical. Seven other baseline scripts and three shared owned files have concurrent Freight changes, recorded separately rather than overwritten or falsely counted unchanged. Latest Hive faction-reassign-04 reports that audio commit already pushed/verified; its prior block is superseded. Preserve mixed/untracked work.

## Review and reproduction
Reopen the desktop Dead Street Sandbox shortcut (or repository Open Dead Street Sandbox.cmd). It launches current source at gameplay/sandbox_opening.tscn.
Run Godot --path REPO --script res://tools/sandbox_maps_20260915/check.gd with --headless for logic; groups.gd, clicks.gd, uishots.gd use a native window. run.py wraps the owned process/log/timeout.
Do not rerun historical install.py, update.py or payload.json against future source. They are guarded task history, not general migrations; shared files now contain additive Freight work.
Evidence: baseline.json, before/, installed.json, completion_receipt.json; source_scope_snapshot.json preserves this pass's final source before concurrent merges, not an installation payload.
Review images: setup_1920x1080.png and convoy_bikes.png (delivered as DEAD_STREET_Battle_Setup.png and DEAD_STREET_Convoy_Builder.png). Other viewport captures and convoy_locked.png remain here. Persistent image IDs/hashes are in library_receipt.json.

Next: owner tests map selection, custom roster changes and convoy building; review 16v16 performance on the development PC. No remaining requested implementation failure in this UI/convoy scope. Freight Exchange and prior visual reviews retain separate ownership.
