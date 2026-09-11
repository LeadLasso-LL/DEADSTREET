# Faction design previews

Run from the repository with the existing DeadStreetTools Python and Godot:

1. `python tools/faction_design/mercer_preview.py`
2. `Godot --headless --path . --script res://tools/faction_design/render_mercer.gd`
3. `python tools/faction_design/mercer_preview.py --board`

Outputs are under `tools/faction_design/mercer/`. Source SVGs and 128px PNGs are
standing/aiming art candidates, not production animation atlases. The preview
script changes outfit bindings only inside its own process. Existing faction
atlases and combat behavior are untouched. See `docs/MERCER_SAINTS_UNIT_DESIGN.md`
for approved clothing and starting balance decisions, and unresolved choices.

Read `docs/UNIT_ART_STANDARD.md` before making another unit. The generator checks
the specialist torso and lower body against the existing Mercer pistol unit in
six poses. Eighteen frames render, including that reference. The fixed-scale
`mercer_body_comparison.png` accompanies `mercer_new_units_review.png`.
Geometry and frame-clearance reports support, but do not replace, visual review.
