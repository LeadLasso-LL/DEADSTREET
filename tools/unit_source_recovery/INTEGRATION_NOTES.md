# Dead Street — integration handoff

The live desktop device was offline during this build. These notes describe the exported assets, not completed modifications to the main Godot game.

## Asset contract

- Outfit keys: 0 street gang, 1 Russian mafia, 2 Italian mob.
- Weapon keys: uzi_smg, ak_rifle, pistol. These are preview identifiers; map to actual inventory IDs after inspecting the live catalog.
- Each outfit can use each weapon.
- Sprite cell: 128×128. Presentation anchor: (64,110), nominal ground origin.
- Atlas layout: columns are frames, rows are E, SE, S, SW, W, NW, N, NE.
- Action preview FPS: 16. Previous combat preview FPS: 20. Approved running preview FPS: 30. Preserve per-clip timing rather than assigning one global FPS.
- Use nearest filtering. Draw order must follow projected ground position; do not sort by the top edge of a sprite.
- These clips are in place. World movement remains simulation-authoritative; synchronize animation phase with traveled distance.

## Clips

| Clip | Frames | End behavior |
|---|---:|---|
| cover_over | 40 | Holds ducked. Includes standing entry, duck, rise/fire, duck. Split into state transitions during integration. |
| cover_edge | 32 | Returns to the initial crouched pose. |
| hit | 16 | Returns to the initial combat stance. |
| injured_run | 24 | Loops. Reduced stride, slower cadence, hunched posture. |
| death | 24 | Holds final ground pose. Never loop or resurrect a unit through animation completion. |
| reload | 40 | Returns support hand to the gun. Ammo updates belong to the simulation. |

Preview shot events in cover_over are frames 24 and 27. These are illustrative. The game must trigger appropriate clips/effects from actual combat events. Reload removal/insertion progress markers are in manifest.json and are not weapon balance decisions.

## Before live binding

1. Reconnect the desktop and inspect the current repository, local instructions and dirty changes.
2. Find the existing presenter, animation catalog and actual inventory identifiers. Preserve simulation and hit-test authority.
3. Add new assets through those existing interfaces. Do not replace TacticalBattleView with a parallel renderer.
4. Test move/stop/fire interruptions, reload cancellation, directional cover exposure, hit reactions and death priority.
5. Check muzzle placement, occlusion, normal tactical scale and frame pacing in the real street battle.

Cover poses still require matching to actual obstacle height and threat direction. Death currently releases the rendered weapon during the fall without creating persistent loot. Casualty persistence, dropped equipment and gameplay effects are separate rules, not introduced here.

The included street rehearsal is scripted. It exercises layered scenery and animation playback, but is not evidence of AI, line-of-sight, cover protection, damage, inventory integration or game performance.
