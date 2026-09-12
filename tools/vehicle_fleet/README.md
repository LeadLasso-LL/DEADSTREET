# Dead Street vehicle fleet

## Status: installed and validated on the development PC

The 40-model fleet covers eight Two-Wheelers, twelve Passenger Cars, ten Utility Vehicles and ten Heavy Transports. Each model has a fictional name, purchase price, upkeep, road movement, seats, physical footprint, cargo limit and native pixel artwork. Six suggested models per faction cover all 23 factions; suggestions never restrict sandbox access.

Only Heavy Transports accept campaign resources. Cargo slots are abstract resource quantities, independent of the listed seats. Seats include the driver. Every moving vehicle reserves one actual unit as its driver or rider; a convoy cannot contain more vehicles than units. Convoys travel at their slowest vehicle's speed. Luxury prices confer no hidden combat, health or armor bonus.

## Prepared gameplay

- Open the existing Arsenal Review and use **VEHICLE FLEET**. Select one or more vehicles with sufficient seats for the five attacking units. Every model is unlocked. Defenders retain the existing garrison deployment.
- Selected models persist into the campaign force, travel, arrival placement, unit-to-vehicle assignment, parked collision and cover, and disembark pathfinding.
- Eight facings and three door phases for 32 four-wheel models, plus eight facings for eight two-wheel models: 832 sprites and 40 icons.
- Vehicle-specific dimensions and door locations drive placement; two-wheelers supply no vehicle cover. Door obstacles temporarily hide unowned cover slots they obstruct and restore them when clear.
- Model selection and cargo persist in game saves. Existing `car` saves retain their travel/capacity values and use Bayou artwork.
- Purchase and cargo-transfer services validate ownership, funds and resource capacity. Upkeep uses the existing vehicle cost field. Full campaign purchase/loading screens are future work.

## Boundaries

Two-wheelers appear already parked in tactical arrivals. Riding, pedaling and mounted-passenger animations have **not** been authored. Four-wheel models use the existing arrival presentation. No turrets, driving combat, vehicle damage model, fuel, repairs or salvage system was introduced. Existing unit outfits, armor-as-HP-only behavior, weapons and animation atlases are unchanged.

The initial Linux source mirror did not contain the complete production art/audio installation. The same automated suites subsequently passed on Windows Godot 4.7.2. A native D3D12/Forward+ run captured the live selector and TRC Bastion, NBPD mixed-patrol, Raiders bus and five-bicycle scenarios. Representative screenshots were visually inspected for vehicle scale, placement and exits. This validates parked-bike presentation, not the still-unimplemented riding animation.

## Rebuild

From the project root, with Python, Pillow, NumPy and ReportLab installed:

```bash
python tools/vehicle_fleet/build_catalog.py
python tools/vehicle_fleet/build_art.py
python tools/vehicle_fleet/build_guide.py
```

`build_art.py` is the editable geometry source. It rasterizes with a depth buffer; no Blender or generated SVG master is required. Sprite canvases are 640 by 480 with ground origin at (320, 330). The art manifest records render settings. PNGs under `.gdignore` load through `VehicleModelCatalog` and are explicitly included by the roster export plugin.

## Validation performed

Godot 4.5.1 headless on Linux and Godot 4.7.2 headless on Windows:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tools/vehicle_fleet/compile_fleet.gd
godot --headless --path . --script tools/vehicle_fleet/validate_fleet.gd
godot --headless --path . --script tools/vehicle_fleet/validate_mixed.gd
godot --headless --path . --script tools/vehicle_fleet/validate_panel.gd
```

- `validate_fleet.gd`: **2,528 checks, zero errors**. All 40 models, 23 preferences, factories, purchases, cargo overflow, save/load, image integrity, convoy constraints and all 40 real campaign-to-battle fixture paths.
- `validate_mixed.gd`: **43 checks, zero errors**. Five mixed convoys, drivers, unit exits, battle geometry, failed purchases, resource conservation and whole-state saves.
- `validate_panel.gd`: passed selector category/filter, add/remove, capacity and apply checks.
- `compile_fleet.gd`: all selected runtime and export scripts loaded without errors.
- All 40 vehicle illustrations and all 17 guide pages visually inspected; final POLICE/TRC lettering and representative card pages checked after the last art rebuild.

The native `review_native.gd` scenario also passed with zero errors on Windows D3D12/Forward+. Run it without `--headless`; it captures four selector categories and four complete 5v5 arrival/battle scenarios under `tools/vehicle_fleet/native_review/`.

Prices and upkeep are initial game-balance values, not real-world quotes. Movement is campaign road-distance units per turn, not mph.

## Installed project

The user explicitly approved the OneDrive-backed destination on 2026-09-12. The reviewed source changes were applied with baseline hash guards to `C:\Users\brand\OneDrive\Documents\dead-street`, branch `build/arsenal-checkpoint-20260911`, based on HEAD `ae8b12cb3136c40f2e2476e215bb33a42b93deeb`. Native artwork and guide outputs were rebuilt there. Unrelated dirty work was preserved. The earlier destination approval block is resolved.

The authorized remote is `https://github.com/LeadLasso-LL/DEADSTREET.git`. Commit and remote history provide the final synchronization record. Guide outputs live in `docs/vehicle_fleet/`; validation reports are beside this README.
