# Full faction roster and unit tiers

The sandbox makes all 23 factions, five regular classes, all 30 weapon models,
and all three unit tiers available. Every unit can equip all six models in its
own weapon class. Faction Units Guide pairings are editorial suggestions only.
Merged and invading factions have no campaign unlock requirements in this test.

## Training balance (initial values)

| Unit tier | Name | Base miss chance | Aim/reacquire time | Reload time | Recoil per shot | Recoil recovery |
|---|---|---|---|---|---|---|
| 1 | Regular | unchanged | unchanged | unchanged | unchanged | unchanged |
| 2 | Experienced | ×0.90 | ×0.90 | ×0.95 | ×0.90 | ×1.10 |
| 3 | Veteran | ×0.80 | ×0.80 | ×0.90 | ×0.80 | ×1.20 |

Reduced miss probability transfers to ordinary solid hits, not critical hits.
Health, per-hit damage, range, movement, magazine size, shot cadence, and outfit
remain unchanged. Thus a tier-three unit can carry a tier-one weapon and a
tier-one unit can carry a tier-three weapon. Gold HUD stars represent **unit**
tier; weapon tier remains a separate equipment label.

`Soldier.unit_tier` saves and loads independently and is copied into battle
participants. Existing saves default to tier one. Setup rejects invalid tiers,
cross-class weapons, and equipment/tier changes during active or resolved battles.
Derived training profiles never mutate the shared weapon-model definitions.

## Animation production

`build_roster.py` evaluates the accepted faction outfit adapters and shared rig.
It preserves their geometry and model-specific grip/weapon rendering. Workers
are isolated because the wardrobe adapters install process-local drawing hooks.
The build is resumable per variant and checks body signatures, empty frames,
frame boundaries, muzzle/wound anchors, and palette parity.

All regular units have eight directions and all 17 existing animation states:
idle, walk, aim, fire, reload, cover pop-out, tucked/exposed idle, cover fire,
cover tuck, cover edge, hit, wounded idle/walk, forward/backward death, and
checking a comrade. Each model pairing has 1,840 frames plus wound-mask frames.
Existing Mercer and regular Orlov production assets are reused; 636 additional
sets bring the full roster to 690 legal faction/model pairings.

`write_manifest.py` requires all new asset files before marking the catalog
complete. `--allow-building` is for local integration work during animation production;
it explicitly writes `complete: false` while anything is missing.

Runtime PNGs are loaded from the explicit catalog without redundant editor
imports. The enabled `faction_roster_export` editor plugin includes the complete manifest,
faction definitions, emblems, atlases, portraits, masks, and anchors in exported game packs. The browsing
cache is bounded; active actors retain their own frames even after cache eviction.
Wound masks and anchors are loaded on demand and released when the battle closes.

## Checks

- `validate_rules.gd`: all 2,070 faction/model/tier combinations, independent
  equipment and training, unchanged damage/health, invalid assignments, and saves.
- `validate_live.gd`: rendered five-versus-five battle with every class, mixed
  tiers, deliberately unrestricted loadouts, complete clips, and HUD captures.
- The live check's observation limit reports an unfinished fight; it never
  resolves combat or assigns a winner because a clock expired.

- `validate_coverage.gd`: loads every one of the 690 runtime SpriteFrames sets;
  checks all 17 clips in eight directions, frame counts, timing, loops, and
  atlas regions. It can validate completed sets while production continues.
- `validate_assets.py`: requires a complete manifest, verifies every PNG, and
  checks all 636 geometry/edge reports and 498,624 finite wound/muzzle anchors.
- `validate_cache.gd`: exercises thirteen active variants beyond the preview
  cache capacity, verifying living actors retain their existing frames.
- `validate_pack.gd`: loads a raw roster PNG from a PCK and verifies the
  export plugin's complete, duplicate-free asset list.

Open `tools/arsenal_production/Open-Arsenal.ps1` to use the sandbox. Both sides
select their faction, one model and training tier per class, then launch a 5v5
with all five regular classes. The campaign startup scene remains separate.

For a focused rebuild, use `build_roster.py --worker <faction> --model <model>`.
Omit `--model` to rebuild that faction's complete class-compatible weapon set.
Production checkpoints are per model, so completed files survive an interrupted
build. Re-run the manifest and asset/runtime gates before treating it as complete.

- `validate_controls.gd`: exercises both sides' faction, weapon and tier selectors,
  including long names, and verifies the resulting loadout and control widths.
