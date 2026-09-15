# Two-wheelers and Sandbox title — 2026-09-15
Status: IMPLEMENTED / NATIVE-VALIDATED / OWNER REVIEW. Local source only; no stage, commit or push by this pass.

## Owner decision
Every faction packs up to two two-wheelers in one convoy slot. Stateline Raiders MC, Blacktop Apostles MC, Zangyaku, Bitian, NBPD and TRC pack up to four. This supersedes the previous three-motorcycle exception. Exactly three convoy slots and sixteen units per side remain.

The Two-Wheelers picker shows one short faction-dependent explanation, and cards show the correct packing capacity. Nonconsecutive selections share a slot, removal restores valid additions, and seats/drivers remain authoritative. All two-wheelers, including bicycles, share the category rule; the motorcycle classifier still excludes bicycles for engine/rider behavior.

The existing approved title PNG is displayed as an AtlasTexture in the top-left Sandbox header with the original pixels preserved. Additive blending removes the black source matte on the dark header. No image regeneration or faction/unit/audio changes.

## Source ownership
- campaign/vehicles/convoy_formation_catalog.gd: central two/four limit and packing.
- gameplay/sandbox_convoy_rules.gd: remaining-seat feasibility uses faction limit.
- gameplay/vehicle_fleet_panel.gd: helper line and card capacity.
- gameplay/sandbox_menu_panels.gd: approved title artwork.
- gameplay/bridge_battle_setup.gd: four-bike attacking formation and collision-checked extra defender-bike placements.
- gameplay/estate_battle_setup.gd: grouped-bike placement and shared curve with held spacing; slot-local car alternatives only when packed bikes are present.
- gameplay/freight_exchange_setup.gd: narrow grouped-bike accommodation after Freight revision04; original no-bike curve/pose behavior and scenery retained.

Do not overwrite concurrent Freight, audio, portraits, or prior map/menu work. installed.json records exact final owned hashes. baseline.json/source_before.json retain the startup state; freight_before.gd retains the completed Freight revision immediately before this pass's guarded bike correction.

## Validation and reproduction
On DESKTOP-7CL4DM3, native Godot4.7.2/D3D12 with GTX1650 Max-Q, use the local DeadStreetTools Python to run tools/bike_slots_20260915/run.py with:
- check: 478 checks PASS, all23 faction rules;25 attacker starts across five maps, each sixteen actual unique passengers;12-bike defending bridge convoy. Final bike-specific arrival changes are additionally covered below.
- ui: 18 checks PASS; native pointer input selects exact models and four Ironhorses for all six eligible factions; helper hidden on other categories; title/viewport containment at1920x1080 and1280x720.
- motion: estate0/2/4/12-bike cases,29128 vehicle-pair samples at30Hz over1–12s; every vehicle positioned, no pair overlap, no dismount errors. No-bike poses exactly match the prior implementation at331 sampled times.
- freight_motion: same0/2/4/12-bike cases,44968 vehicle-pair samples at30Hz over1–18s; also checks actual scenery rectangles. No overlaps, unplaced vehicles or dismount errors. No-bike poses exactly match completed Freight revision04 at511 sampled times.

Sampled moving-body checks use the game's oriented hulls, not just center separation; numerical intersection tolerance0.02 world-area units. They cover representative Ironhorse groups plus Bayou/Shuttle mixed convoys, not every possible vehicle permutation or sustained32-unit performance.

## Retained findings
Initial check failures: estate only had five parking poses; bridge defender positions exhausted by12 bikes. Initial estate motion found rear riders catching front riders and cars crossing bike stops. Separate path lengths were replaced with a shared group centerline and held body spacing. Freight12-bike motion exposed a second turning overlap; the narrow group-only correction passes the original car baseline plus static/dynamic clearance. Preserve initial_check.*, initial_motion.*, motion_spacing_attempt.*, initial_freight_motion.*.

Initial UI automation clicked a stale grid layout and hit a different model. Fixed fixture waits for layout and asserts exact model IDs; final UI rerun passes. One guarded patch stopped on CRLF matching before writing source; corrected installer normalizes line endings. Generic campaign pre-placement may log no_legal_candidates before the authored map setup replaces it; final actual vehicle positions and exits are independently asserted.

## Review artifacts and limits
Native menu_title.png / menu_title_1280.png / two_bike_rule.png / four_bike_rule.png are final screenshots. Delivered copies:
- DEAD_STREET_Two_Wheeler_Convoy.png: libfile_fd08120acaac819197f066448d3028a7
- DEAD_STREET_Sandbox_Title.png: libfile_1f9b4f0d10ac81918955f63a08f41848

Original title SHA256: a7ad354ff6bb1e8182b88ad22a08fcc2c8452d9891a3e26d7afa0fb269d199a9.
Native source playback is verified; the title uses the existing opening's raw-image loading pattern and emits its export warning. A standalone packed export was not rebuilt or certified. No stable60FPS/32-unit claim and no owner-acceptance claim.

Next: close/reopen the live-source Dead Street Sandbox desktop shortcut and review. The latest separate Eastex Freight video/handoff is freight-revision04; its original no-bike sequence is preserved. Future publication must scope the mixed tree and preserve prior approvals/work.
