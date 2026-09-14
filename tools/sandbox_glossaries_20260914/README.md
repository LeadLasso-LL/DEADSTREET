# Sandbox panels — 14 September 2026

Five top tabs, in order: Battle Setup, Faction Glossary, Arsenal, Vehicles, Tutorial. The default setup remains alive while browsing; map, factions, rows, equipment, tiers, armor and convoys are retained. Fleet selection and Encounter Lab remain accessible. The existing Harold tutorial remains its full-window interactive overlay.

Faction profiles use the current FactionUnitCatalog names/emblems and fixed leaders. Public descriptions are adapted from the supplied major-gang and authority sheets. Campaign-dependent leadership for Mercer 44, Union Sur and Lombardia is undisclosed. Formation triggers, future deaths, secret faction goals and scripted campaign outcomes are omitted. Five regular class portraits per faction use the same 115 established weapon pairings as tools/faction_design/build_faction_units_guide.py; assets are loaded from the current animation catalog's portraits.

Arsenal reads all 30 models directly from BattleWeaponCatalog, grouped by five weapon classes. Values describe actual game balance before unit-tier and battlefield modifiers. Vehicle pages read all 75 VehicleModelCatalog entries, grouped into four classes. Vehicles have no canonical numbered tiers, so none are invented: their categories, specifications and abilities are shown. Service capacities and current Encounter Lab availability are included.

## Private validation

Run with the installed private Python:

    python tools/sandbox_glossaries_20260914/run_capture.py smoke
    python tools/sandbox_glossaries_20260914/run_capture.py record

The runner freezes production sources in its own AppData runtime and overlays only this task's menu sources, current catalogs, icons, portraits and tutorial. It does not modify the shared release pack, opening controller, music or launchers. Existing benchmark assets are required. Re-recording refuses to overwrite glossary_raw.avi.

validate.gd uses native mouse clicks and wheel input for navigation, catalog selections, scrolling, Tutorial entry/exit and battle launch. It checks every faction, paired portrait, weapon and vehicle, leader-search privacy, text fit, setup persistence and navigation bounds. The recorded review segment ends before exhaustive checks, window resizing and the one launch/return smoke check. record.json supplies the trim time. The preview contains no battle simulation.

This is the existing desktop sandbox scaled to fit smaller windows. Native mobile layout has not been introduced by this change; the review MP4 is H.264/yuv420p with fast-start playback.

## Coordination

This chat owns sandbox interior/navigation and the new glossary sources/data/tools. Opening chat owns the separate Enter gate, accepted opening, persistent music and launcher integration. BUILD owns its faction-audio preview revisions. All unrelated working changes are preserved. Shared documentation is committed using only this chat's sections/row.

Validation results and publication commit are recorded in smoke.json, record.json, delivery.json, the shared journal and hive mind. Implementation/validation do not imply owner visual acceptance.
