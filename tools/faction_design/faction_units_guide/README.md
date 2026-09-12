# Faction Units Guide render inputs

23 finalized factions, five regular classes each. The 115 representative loadouts use the existing 30 weapon models. These guide selections do not alter campaign equipment rules.

Run `python tools/faction_design/build_faction_units_guide.py all` with the existing project Python dependencies and Godot installation. Each faction renders in an isolated Python process so outfit hooks cannot leak between factions. The output contains fixed-scale standing, aiming, and rear atlases. Generated images and intermediary frames are ignored here; the published image sheets and combined PDF are separate guide deliverables.

Validation: all 345 sample frames rendered without frame-edge contact. Class assignments and 115-unit coverage are checked by the generator. Final page layout uses eight logical faction pairs and seven individual faction sheets.
