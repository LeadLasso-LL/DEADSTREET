# Mercer production pass

The approved sniper outfit is bound to all six existing sniper rifles: Remington 700, SKS, SVD, SSG 69, AWM and PSG-1. The four established ordinary Mercer outfits remain available.

The specialist uses two matching Glock 17s, alternating individual shots. Each event identifies the firing hand for the matching recoil clip and muzzle anchor. He retains normal vitality, strength and per-bullet trauma. Initial balance: 3.5 shots/second, 20 range, 90% of normal Glock hit probability, 24 combined rounds, 3-second reload and 95% of the corresponding Glock unit's movement speed. Recruit-cost metadata is 1.5×; the future campaign recruitment interface must apply it.

Animations use the existing eight-direction rig and clip layout: locomotion, idle, aim, firing, reload, cover transitions, hits, wounded motion, deaths and checking a comrade. Extra left-hand fire/cover-fire clips are selected by actual shot events. Wounded units retain the established free hand at the abdomen and existing combat penalties.

All frames use a fixed six-pixel upward packing offset with a matching 104-pixel foot anchor. This gives running feet clearance without rescaling anatomy or weapons. Torso and lower-body geometry assertions compare every specialist frame to the original rig before packing.

The arsenal's “Mercer dual-pistol specialist” toggle equips the Mercer pistol slot in its isolated test battle and previews the specialist with Glock selected. Both ordinary and sniper test battles remain available. It does not write campaign saves.

Soldier records persist specialist identity. The specialist catalog counts all owned soldiers across forces, keeps and garrisons; assignment requires an explicit faction-wide limit. No final campaign cap number, scaling rule or shared-pool policy has been chosen. The one specialist in the test fixture is a scenario selection, not that decision.

Production entry point: `tools/faction_design/produce_mercer.py <godot-console-path>`. It reuses the existing weapon art, SVG renderer and palette finish, writes a separate Mercer manifest, and leaves other faction atlases intact. `validate_mercer.gd` checks gameplay and all bound clips.

## Validation of this checkpoint

- 12,928 game animation frames across seven variants and eight directions; all renders passed the frame-boundary check.
- 1,090 Mercer checks passed, including clip completeness, unit geometry assertions during generation, actual hand-to-animation selection, stats, reloads, movement, save round-trip and faction-wide accounting.
- Existing arsenal checks: 290 passed. Existing attacker tactics checks: 12 passed.
- Two real battle fixtures exercised both pistols and resolved naturally: the ordinary scenario ended after 37 seconds with a defender win; the sniper scenario ended after 15.9 seconds with an attacker win. These are integration checks, not a win-rate estimate.
- Explicit elapsed-time checks at 120 seconds, one hour and one day did not resolve a living battle.
- The live arsenal menu, specialist toggle, six sniper loadouts and battle launch were captured and reviewed with no script errors. The standing left shoulder and both shoulder joins were visually checked; normal body proportions are preserved.

The checks above are scoped to this change. The previously documented broader core-suite failures were not reclassified as passing. Campaign recruitment UI, final cap values and unit-tier/armor systems remain separate planned work.

[Animation preview](../tools/faction_design/mercer_animation_review.gif) | [Standing review](../tools/faction_design/mercer_standing_review.png) | [Arsenal](../tools/faction_design/mercer_arsenal_review.png)
