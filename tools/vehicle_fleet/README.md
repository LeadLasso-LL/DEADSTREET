# Dead Street vehicle fleet - 2034 design pass

60 models: **12 Two-Wheelers, 19 Passenger Cars, 13 Utility Vehicles and 16 Heavy Transports**. All models are unlocked in the battle sandbox. Seats include the driver. Only Heavy Transports carry campaign resources; faction motor pools remain suggestions.

## Art direction

The game is set in 2034. Contemporary vehicles use lower crowned roofs, shallower glass, raked pillars, fuller hood/deck proportions, sculpted shoulders, thin lighting signatures and visible wheel arches. Heritage models and scavenged vehicles remain intentional exceptions. The pass specifically corrects the high-cabin, short-hood appearance of the TRC and NBPD fleets.

The wheel openings are part of the body geometry. Pickup beds have recessed dark floors. Opaque van and armored panels suppress underlying glass. Open-top roadster seats and windscreen are modeled separately. Shared world dimensions and projection produce all eight facings and door phases.

Fourteen new models: Pulse EX, Cinder 900, Aurelia E4, Solstice Spider, Mistral Estate, Kestrel RX, Halcyon H1, Torque EV5, Dunecat R, Obsidian X, Lastlight Prison Bus, Dustchapel RV, Relay TRC and Concierge Lounge.

Lastlight and Dustchapel are dedicated Raiders of the Sand transports, with repaired body panels, roof storage, a ladder, spare wheels and model-specific scavenged equipment. Lastlight carries twelve units plus twelve resource slots; Dustchapel carries eight plus eight. Those limits are simultaneously usable.

## Gameplay and limits

Use **VEHICLE FLEET** in Arsenal Review. Every convoy vehicle needs an actual unit to drive it, and combined seats must accommodate the attackers. Models feed campaign forces, movement, arrival placement, troop assignment, parked collision/cover, disembark paths and save/load. Convoys travel at their slowest member's road movement rate.

Artwork contains **1,248 sprites and 60 icons**: 48 enclosed/four-wheel vehicles with eight facings and three door phases, plus twelve two-wheelers with eight facings. The complete guide contains 22 pages, ten complete-fleet phone sheets and two additional authority/Raiders close-ups.

Two-wheelers continue to use parked arrivals. Riding, pedaling and mounted-passenger animations remain pending. Vehicle damage, turrets and campaign fuel/charging/repair interfaces are not part of this pass. Electric models currently use their listed upkeep values; they do not enable an unimplemented charging system. Vehicle styling adds no hidden unit armor or outfit overlays.

Prices and movement are fictional game-balance values. Original models retain their capacities/economy; height corrections are presentation/physical-profile metadata. Models keep their stable save IDs.

## Rebuild

```bash
python tools/vehicle_fleet/build_catalog.py
python tools/vehicle_fleet/build_art.py
python tools/vehicle_fleet/build_guide.py
python tools/vehicle_fleet/build_2034_boards.py
```

Requires Pillow, NumPy and ReportLab. `fleet_2034_geometry.py`, `vehicle_detail_geometry.py` and `build_art.py` are the editable geometry masters. The embedded Windows Python runtime uses an explicit script-directory import path. Canonical sprites remain 640x480, ground origin (320,330), 40 pixels per world unit. Native PNGs load through VehicleModelCatalog and the existing export plugin.

## Validation

Windows Godot 4.7.2: **3,730 model/gameplay checks and 43 mixed-convoy checks passed with zero errors**. Script-load and selector/filter/add/remove/apply checks passed. Coverage includes all 60 models, image loading/bounds, both authority brands in all four classes, economy/cargo limits, save compatibility, drivers, campaign travel, arrival placement and disembark paths.

Six D3D12/Forward+ scenarios passed: TRC 2034 response, NBPD 2034 response, both Raiders transports, new exotics/electric bike, new utility vehicles, and Relay/Concierge transports. Representative native captures were visually inspected. All eight closed facings, representative door phases, every sprite's bounds, all 22 guide pages and all twelve phone sheets were reviewed. Technical checks and internal visual review do not replace owner acceptance.

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tools/vehicle_fleet/compile_fleet.gd
godot --headless --path . --script tools/vehicle_fleet/validate_fleet.gd
godot --headless --path . --script tools/vehicle_fleet/validate_mixed.gd
godot --headless --path . --script tools/vehicle_fleet/validate_panel.gd
godot --path . --script tools/vehicle_fleet/review_native.gd
```

The development repository received baseline-guarded source changes. Unrelated work was preserved. Git history and remote confirmation record commit/push status. The completed battle sandbox remains the active objective.
