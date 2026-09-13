## Blockade support extension

75 models / 1,560 directional and door sprites / 75 icons. Two additional vehicles: Roadwarden Lockdown (Heavy) and Bloodhound Pursuit (Utility). Native palette and geometry are in `blockade_catalog.py` and `blockade_geometry.py`; the phone sheet is built with `build_blockade_sheet.py`.

`vehicle_blockade_rules.gd` owns stationing, derived fortification, pursuit charges, battle holds and explicit survivor settlement. `vehicle_encounter_service.gd` exposes these rules and migrates old snapshots. `blockade_battle_setup.gd` constructs the controlled tactical checkpoint geometry before deployment. All rules are independent of weapon-guide recommendations and impose no faction unlock restrictions.

Run `validate_blockades.gd` for owned-post, crew, withdrawal, movement, topology, repeat-use, pending-battle, save and survivor checks plus controlled battle setup. Run `validate_fleet.gd -- roadwarden bloodhound` for the two new models; `validate_panel.gd` covers selector counts. `review_blockades.gd` presses the actual lab battle button and captures both native battles. Existing `validate_encounters.gd` and `validate_driveby.gd` remain regression gates.

Current scope: the lab launches isolated five-versus-five battles using the existing sandbox loadouts. Automatic campaign events and arbitrary campaign-force/result dispatch are not integrated. Native battle outcomes are not written back to the lab; Reset All starts another controlled scenario. `finish_pursuit` accepts explicit per-vehicle survivor manifests, rejects duplicate/missing/unknown survivors, and never grants cargo automatically. No road guns, invulnerability, hidden unit armor or faction-exclusive access.

# Dead Street vehicle fleet - endgame expansion

73 models: **15 Two-Wheelers, 22 Passenger Cars, 15 Utility Vehicles and 21 Heavy Transports**. All models are unlocked in the battle sandbox. Seats include the driver. Only Heavy Transports carry campaign resources; faction motor pools remain suggestions.

## Art direction

The game is set in 2034. Contemporary vehicles use lower crowned roofs, shallower glass, raked pillars, fuller hood/deck proportions, sculpted shoulders, thin lighting signatures and visible wheel arches. Heritage models and scavenged vehicles remain intentional exceptions. The pass specifically corrects the high-cabin, short-hood appearance of the TRC and NBPD fleets.

The wheel openings are part of the body geometry. Pickup beds have recessed dark floors. Opaque van and armored panels suppress underlying glass. Open-top roadster seats and windscreen are modeled separately. Shared world dimensions and projection produce all eight facings and door phases.

Fourteen new models: Pulse EX, Cinder 900, Aurelia E4, Solstice Spider, Mistral Estate, Kestrel RX, Halcyon H1, Torque EV5, Dunecat R, Obsidian X, Lastlight Prison Bus, Dustchapel RV, Relay TRC and Concierge Lounge.

Lastlight and Dustchapel are dedicated Raiders of the Sand transports, with repaired body panels, roof storage, a ladder, spare wheels and model-specific scavenged equipment. Lastlight carries twelve units plus twelve resource slots; Dustchapel carries eight plus eight. Those limits are simultaneously usable.

## Gameplay and limits

Use **VEHICLE FLEET** in Arsenal Review. Every convoy vehicle needs an actual unit to drive it, and combined seats must accommodate the attackers. Models feed campaign forces, movement, arrival placement, troop assignment, parked collision/cover, disembark paths and save/load. Convoys travel at their slowest member's road movement rate.

Artwork contains **1,512 sprites and 73 icons**: 58 enclosed/four-wheel vehicles with eight facings and three door phases, plus fifteen two-wheelers with eight facings. The complete guide contains 26 pages. Five new endgame sheets complement the historical 60-model 2034 sheets.

Two-wheelers continue to use parked arrivals. Riding, pedaling and mounted-passenger animations remain pending. Vehicle damage, turrets and campaign fuel/charging/repair interfaces are not part of this pass. Electric models currently use their listed upkeep values; they do not enable an unimplemented charging system. Vehicle styling adds no hidden unit armor or outfit overlays.

Prices and movement are fictional game-balance values. Original models retain their capacities/economy; height corrections are presentation/physical-profile metadata. Models keep their stable save IDs.

## Rebuild

```bash
python tools/vehicle_fleet/build_catalog.py
python tools/vehicle_fleet/build_art.py
python tools/vehicle_fleet/build_guide.py
python tools/vehicle_fleet/build_endgame_boards.py
```

Requires Pillow, NumPy and ReportLab. `fleet_2034_geometry.py`, `vehicle_detail_geometry.py` and `build_art.py` are the editable geometry masters. The embedded Windows Python runtime uses an explicit script-directory import path. Canonical sprites remain 640x480, ground origin (320,330), 40 pixels per world unit. Native PNGs load through VehicleModelCatalog and the existing export plugin.

## Previous 60-model validation

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

## Endgame abilities and independent services

The original endgame expansion added two premium vehicles per class: Wraith Zero, Crownfire V-Twin, Eidolon GT, Asterion One, Nomad Sovereign 6x6, Archangel Recovery, Leviathan Breacher and Palisade Escrow. Each has an explicit ability and counterplay. Catalog metadata and the phone sheets describe the exact boundaries. New native art lives in `endgame_geometry.py`; existing 60-model art is preserved. `build_art.py` accepts model IDs to rebuild only selected sprites.

Sterling CIT-4 and Sterling Bastion Reserve are independent cash services, carrying $75,000 with three crew and $300,000 with four crew. Custodian P8 has three guard seats plus eight separate prisoner positions. These three models are available in the sandbox; the faction purchase service rejects them. Their listed prices are reference fleet values. They do not carry ordinary resource freight.

Open **Vehicle Fleet -> Encounter Lab** to exercise all eleven controlled scenarios. Run/resolve, counter-test/intercept, advance turn, reset, and saved snapshots call the stateful `VehicleEncounterService`. Cash is debited at departure and credited to one recipient once. Palisade claims pay after two turns, wait while the origin is captured, and cannot be delivered and refunded twice. Life Support is limited to one living critical occupant per owner per battle across recovery vehicles. Prisoner rescue preserves original allegiance.

This is a runnable encounter-rule sandbox. Automatic campaign police stops, connected-road scouting UI, roadblock generation, banking/prison dispatchers, real bank security escorts, prisoner battle entities, battle entrance switching and extraction hooks are **not wired**. The service takes authoritative journey/event outcomes from its caller. Production world integration must connect these events before abilities affect ordinary campaign journeys or tactical battles. Standard arrival/cover behavior works for all new vehicle models. Two-wheelers still have parked arrival presentation, without new riding animations.

Windows Godot 4.7.2 passed **4,387 full-fleet checks, 43 mixed-convoy checks and 77 encounter checks**, with zero errors. Script compilation and fleet selector checks also passed. Validation for this expansion is recorded in `validation.json`, `validation_mixed.json`, `validation_encounters.json`, and `endgame_review/report.json`. The encounter suite includes 77 assertions plus all eleven interactive scenarios. Native scenarios cover each flagship class, both bank services and Custodian arrival.

```bash
godot --headless --path . --script tools/vehicle_fleet/validate_encounters.gd
godot --path . --script tools/vehicle_fleet/review_endgame.gd
```

## Drive-by vehicles — 2026-09-12

Revenant R2: two seats, 7.4 road units per turn, $165,000 purchase, $310 upkeep. Nocturne RS: four seats, 7.1 movement, $1,150,000 purchase, $1,650 upkeep. Both have native eight-direction artwork; Nocturne includes three door phases. The two models are unlocked in the fleet selector and work with the existing arrival/cover/driver systems.

Drive-By destroys an operational, enemy-owned, undefended roadside business/building. It needs a driver and passenger and is limited to once per vehicle per turn. One defender or unknown defense state blocks the action. Destruction stops income and production, leaves ownership unchanged, gives no loot, adds 30 heat, and neither advances the turn nor refills movement. Normal connected-road distance is still deducted. Charges and remaining movement survive lab snapshot save/load. Even a strike made at zero remaining movement grants no further travel.

In Encounter Lab, select Revenant or Nocturne. Run first drives two road units to the target and destroys it; Run again drives another 2.5 road units to the exit. Counter-test targets a building with one defender. The live display reports target status, income/production, heat, position and remaining movement. This remains encounter-lab functionality; campaign target destruction/world dispatch integration is not automatically active.

Build: `python tools/vehicle_fleet/build_driveby_sheet.py`. Rules gate: `godot --headless --path . --script tools/vehicle_fleet/validate_driveby.gd`. Model gate can be limited to this addition with `godot --headless --path . --script tools/vehicle_fleet/validate_fleet.gd -- revenant nocturne`. Its report is `validation_driveby_fleet.json`, preserving the previous full-fleet report. Native review: `review_driveby.gd`.
