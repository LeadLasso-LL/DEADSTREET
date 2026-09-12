# Dead Street vehicle fleet

## Fleet revision — 2026-09-12

46 models: **10 Two-Wheelers, 14 Passenger Cars, 10 Utility Vehicles and 12 Heavy Transports**. Every model is unlocked in the battle sandbox. Seats include the driver. Only Heavy Transports carry campaign resources. Models retain fictional names, prices, upkeep, movement rates, seat/cargo limits and physical footprints. Faction motor pools remain suggestions.

The revision exposes motorcycle tires and spoke/rim centers, replaces the long exhaust slabs with short silencers, distinguishes low-bar sportbikes from V-twin cruisers and touring motorcycles, and adds sculpted body sections and stronger luxury/exotic color choices. The six new models are Outrider TRC, Marshal Police, Veloce Rosso, Vigil TRC, Aegis Armored TRC and Bulwark SWAT. Both TRC and NBPD now have dedicated branded models in all four classes. Existing Watchdog is rebuilt as a black armored utility truck.

All 46 models share the campaign and sandbox catalog. Production artwork contains **944 sprites and 46 icons**: 36 four-wheel vehicles with eight facings and three door phases, and ten two-wheelers with eight facings. The illustrated guide has 19 pages, plus three phone-friendly revision sheets.

## Gameplay and boundaries

Use **VEHICLE FLEET** in Arsenal Review to select a convoy with enough seats for the five attackers. At least one actual unit drives each vehicle; total vehicles cannot exceed unit count. The selected models persist through campaign forces, travel, arrival placement, troop assignment, parked collision/cover, disembark paths and save/load. Convoys move at their slowest member's campaign road speed.

Two-wheelers still use parked arrivals. Riding, pedaling and mounted-passenger animations remain to be authored. This visual update adds no turrets or vehicle damage system; armored styling does not grant hidden combat or unit-health bonuses. Existing unit outfits and armor-as-HP-only behavior are retained. Full campaign shopping/loading, fuel, repair and salvage interfaces remain later work.

## Rebuild

```bash
python tools/vehicle_fleet/build_catalog.py
python tools/vehicle_fleet/build_art.py
python tools/vehicle_fleet/build_guide.py
python tools/vehicle_fleet/build_revision_boards.py
```

Requires Pillow, NumPy and ReportLab. `build_art.py` and `vehicle_detail_geometry.py` are the editable geometry masters. The embedded Windows Python runtime uses an explicit script-directory import path. Sprite canvases are 640×480 with ground origin (320,330), 40 pixels per world unit. Native PNGs load through VehicleModelCatalog and the roster export plugin.

## Validation

Windows Godot 4.7.2: **2876 model/gameplay checks and 43 mixed-convoy checks passed with zero errors**. This covers all 46 models, image loading/bounds, brand coverage in all four classes, ownership/funds, cargo exclusivity and overflow, save/load, driver/capacity limits, and real campaign-to-battle arrival/disembark paths. Script-load and selector/filter/add/remove/apply checks passed.

Native D3D12/Forward+ rendered checks passed four scenarios: TRC armored convoy, NBPD SWAT convoy, mixed exotic cars/superbike, and five authority motorcycles. Representative native captures were visually inspected. All 944 sprite bounds passed; every direction of the revised geometry and all 19 guide-page layouts were reviewed.

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tools/vehicle_fleet/compile_fleet.gd
godot --headless --path . --script tools/vehicle_fleet/validate_fleet.gd
godot --headless --path . --script tools/vehicle_fleet/validate_mixed.gd
godot --headless --path . --script tools/vehicle_fleet/validate_panel.gd
godot --path . --script tools/vehicle_fleet/review_native.gd
```

Sources were applied to the authorized development repository with baseline guards, preserving unrelated work. Git history and remote confirmation record synchronization. Prices and movement remain game-balance values, not real-world quotes or mph.
