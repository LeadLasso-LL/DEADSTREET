# Dead Street arsenal production

Thirty equipped weapon models: five fixed unit classes, three equipment tiers, two models per tier. The four previously approved tier-one weapons retain their existing unit atlases. The other 26 models are rendered with each of the three existing faction rigs, yielding 78 new animated variants. Snipers temporarily use each faction's existing rifle outfit; this does not establish their final clothing.

## Review

Open `gameplay/arsenal_review.tscn` in Godot and run the current scene (F6), or run the supplied `Open-Arsenal.ps1`. Select a class and model, facing, animation, and faction; Play Report auditions that model. The loadout selectors configure both sides of an isolated Harold Street battle. Test 4v4 uses the original four classes. Test 4v4 With Snipers recruits a sniper instead of each side's rifleman. Escape returns to the arsenal. Test worlds do not write campaign saves.

## Production and validation

Run from this repository using the existing DeadStreetTools Python environment:

1. `python tools/arsenal_production/build_catalog.py`
2. `python tools/arsenal_production/build_audio.py`
3. `python tools/arsenal_production/produce_art.py`
4. `python tools/arsenal_production/finalize_art.py`
5. Godot `--headless --path . --script res://tools/arsenal_production/render_icons.gd`
6. Godot `--headless --path . --editor --import`
7. Godot `--headless --path . --script res://tools/arsenal_production/validate.gd`
8. Godot `--headless --path . --script res://tools/arsenal_production/compare_battles.gd`
9. Godot `--headless --path . --script res://tools/arsenal_production/validate_presentation.gd`
10. Godot `--path . --script res://tools/arsenal_production/graphics_smoke.gd` for an isolated rendered battle and captures.
11. `python tools/arsenal_production/build_review_board.py` for a contact sheet and `docs/ARSENAL_MODEL_REFERENCE.md` from production assets.

Full art production resumes at `completed_<variant>.json` checkpoints. Delete only the relevant checkpoint(s) when intentionally rebuilding changed models. Intermediate `render_svg` files are disposable and excluded from Godot's importer. Approved source rigs remain under `tools/unit_source_recovery/src`.

## Behavior and tuning

The equipped `weapon_model_id` is separate from `weapon_type` (the unit class). Loadout assignment validates class and is allowed only during setup. Existing magazine/reload cycling is unchanged by model: no finite tactical ammo supply, magazine-capacity upgrade, or per-model capacity management has been introduced.

Model tuning is provisional game balance, not a simulation of manufacturer specifications. Range and trauma use existing tactical units. Movement multiplies the existing healthy/wounded base speed by 0.75–1.25, then applies the existing 1.18 cover dash when appropriate. With base speed 3.6, the extremes are 2.7 and 4.5 before the cover dash; wounded base speed remains 1.8.

Damage, range, firing cadence, acquisition time, recoil accumulation, and recovery differ by model. AI engagement bands scale with the equipped gun's range. Shotgun falloff follows each model's own range. There is no separate kill lottery: hit quality produces trauma, which reduces vitality. High-trauma sniper criticals can kill a healthy 1.5-vitality unit. Being wounded never makes the next hit an automatic death.

Snipers prefer distant visible targets and retain a valid target while aiming. A visible threat inside 12 tactical units takes priority. Player focus orders retain authority. Movement interrupts aim and immediately blocks firing. Snipers preserve useful cover but can reposition for lost sightlines, unsafe close threats, or orders. Their close-range handling is weaker than their settled long-range fire. Wounded reactions do not bypass sniper settling.

All 90 weapon reports (three variations per model) are original procedural synthesis with distinct attack, spectral balance, pressure/body decay, and action timing. They use no external recordings. City ambience, apartment instrumental, heartbeat, and their mix controls are preserved.

Art uses the existing SVG rig and palette. Weapon scale, supporting-hand attachments and muzzle anchors are authored per model. All walking, firing, cover, wounded, death, backward-death, and aftermath clips retain the established animation schema. Full atlas caches are bounded to avoid accumulating every preview model in memory.

Campaign manufacturing, resource recipes, stockpiles, transport, trade, storage, and faction-specific sniper outfits remain separate future work.

See `docs/ARSENAL_PRODUCTION_REPORT.md` for the acceptance results and remaining balance limitations. `docs/ARSENAL_MODEL_REFERENCE.md` lists every current model and its core game values.

## Attacker tactics diagnostics

Run `Godot --headless --path . --script res://tools/arsenal_production/validate_attacker_tactics.gd` for the focused tactics contracts.

Run `Godot --headless --path . --script res://tools/arsenal_production/attacker_balance_review.gd -- --equal --pairs=0,2,4 --out=attacker_balance_candidate.json` to reproduce the matched-loadout comparison. Omit `--equal` and `--pairs` for the original six mixed-loadout matchups. Add `--snipers` to replace each team's rifle recruitment slot with a sniper. The optional `--observe=240` budget limits diagnostic observation only; active battles remain active and are labelled `observation_cutoff`, without assigning a winner. The live battle has no time-limit result. See `docs/ATTACKER_TACTICS_2026-09-11.md` for saved before/after results and regression limits.
