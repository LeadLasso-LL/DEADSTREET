# Harold 4v4 recording checkpoint

Requested by Brandon on 2026-09-10. The approved map checkpoint remains `harold-map-art-v1` / `e17a513`; this pass adds character costumes, animation, HUD and a reproducible recording scenario. New visuals are ready for Brandon's creative review.

## Established whole-force commands

The recovered command set is **Push, Hold, Focus Left, Focus Right, Fall Back**. These are the existing `BattleForceCommandCatalog` commands and the right-hand HUD calls the existing service for each friendly force. They remain distinct from selecting an operative and issuing an individual move, target or defend-position order. Flee remains separate.

## Faction wardrobe specification

| Role | Mercer Saints | Orlov Bratva |
|---|---|---|
| SMG | Retained ski mask, white tank and existing outfit | Retained gray tracksuit and existing outfit |
| Rifle | Loose black tee; dark brown pants; black work boots; backward red cap; black mask lowered over nose, lower face and neck | Charcoal quarter zip, zipped high with visible zipper; black beanie; dark olive pants; black boots; darker black gloves |
| Pistol | Dark red hoodie with hood up; black bandana below eyes; black pants; white sneakers | Fitted black tee; dark gray ski mask; dark brown pants; black boots; tattoos on both arms |
| Shotgun | Red basketball jersey with distinct trim over white tee; black ski mask; black pants; white sneakers | Thick black bomber, fully zipped with visible zipper; black ski mask; dark gray pants; white sneakers |

The six new costumes extend the existing source rig, in all eight directions and existing movement, firing, reload, cover, hit, wound and death states. SW and W retain the established mirrored handedness. Garment-specific blood masks follow the new shapes. SMG wardrobe identity is retained. Italian wardrobe is unchanged.

## HUD and animation

- Four SW torso portraits in a screen-space bottom panel, with role/tier and gun/tier underneath.
- Green ACTIVE, yellow WOUNDED, red DEAD; actual vitality drives the small bars. Wounded portraits have a mild red tint and dead portraits a deeper red tint. Existing selection eligibility remains authoritative.
- Showcase tier-one labels: IMI UZI, AK-47, GLOCK 17, REMINGTON 870. These are display identities selected for the existing weapon classes; generic pistol/shotgun art did not establish a unique real model previously. This is a tier-one presentation pass, not a new equipment progression system.
- The backward death is a separate 32-frame, 24 FPS non-looping atlas. Arms lift during the fall and settle spread on the back. Stable participant identity chooses between original and backward deaths; the final frame holds. All twelve current archetype/weapon variants have backward sheets, including unchanged Italian outfits.
- Normal atlas rows and existing muzzle metadata retain their layout. Backward frame placement keeps limbs inside the 128px cell. Portraits are cropped from installed SW idle cells.

## Recording

The scenario launches the normal HQ mission with one rifle, SMG, pistol and shotgun on each side, through legal deployment. Orlov Bratva attacks; Mercer Saints defends. Six deterministic trial seeds were compared. Seed **2005** produced a 21.47-second fight, **79 shots**, and a resolved Mercer Saints defense with two survivors.

Group orders and several movement orders are staged only in `tools/battle_showcase/scenario.gd`. Hits, damage, wounds, incapacitation and the outcome come from normal combat simulation; no health edits or forced victory are used for the take. The two-second opening and 3.5-second aftermath are presentation pauses. Offline fixed-frame capture is not a live FPS benchmark.

## Verification and evidence

- 713 checks passed: 4v4 identities, HUD live states, five commands affecting only the friendly side, animation bindings and all 100 reachable cover positions.
- All 3,072 backward-death cells are nonempty and clear of atlas edges.
- Full native import and visual review covered the lineup, wounded poses, falling/landing poses and the live HUD.
- Six staged trial battles resolved through normal simulation. The recording uses the selected seed above.
- `docs/references/battle_showcase/` retains a costume lineup, a live battle frame, validation and take-selection reports. Recording/render intermediates stay out of version control.

## Reproduce

Use the repository's Godot 4.7 executable and Python with Pillow and NumPy. In the repository root:

```powershell
python tools/unit_source_recovery/showcase_build.py
godot --headless --path . --script tools/unit_source_recovery/showcase_render.gd
python tools/unit_source_recovery/showcase_finish.py
python tools/unit_source_recovery/showcase_build.py --death-only
godot --headless --path . --script tools/unit_source_recovery/showcase_render.gd
python tools/unit_source_recovery/showcase_finish.py
python tools/unit_source_recovery/showcase_install.py
python tools/unit_source_recovery/showcase_portraits.py
godot --headless --path . --editor --import --quit
godot --headless --path . --script tools/battle_showcase/validate.gd
python tools/battle_showcase/check_atlases.py
godot --headless --path . --script tools/battle_showcase/review.gd -- --sample
./tools/battle_showcase/record.ps1 -Godot <path-to-godot-console.exe> -Seed 2005
python tools/battle_showcase/encode_video.py
```

`showcase_build.py --sample` renders contact-sheet inputs. `--variant=1_ak_rifle` limits an iteration to one costume; pass the same filter to the finish script. The capture helper temporarily supplies 1920x1080 viewport settings and removes only its own override file in `finally`. It refuses to replace an existing override.

## Scope for later work

The HUD is a four-card tier-one layout for this recording, with functioning controls. Larger rosters, campaign equipment names/tiers, responsive narrow-window design and a full command-center product design remain later work. The normal game loop, map-art approval and combat balance were not redefined by the staged take.
