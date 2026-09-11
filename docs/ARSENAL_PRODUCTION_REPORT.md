# Arsenal production completion

This pass turns the approved broader arsenal into usable native Godot assets and tactical equipment. It contains 30 models: five fixed unit classes, three weapon tiers, two models per class/tier. The SCAR-H is black.

## Delivered

- Model data separated from fixed unit class. Setup equipment assignment rejects the wrong class, dead units, foreign participants and changes during combat or after resolution. Existing class reload cycling is preserved; no model-specific capacity or finite tactical ammunition was added.
- Model-specific movement, range, firing cadence, acquisition/reacquisition time, hit-quality probabilities, trauma and recoil/recovery. Movement spans +25% to -25% before the existing cover dash. Unit tier and equipment tier remain separate.
- Thirty native weapon source drawings with grip/muzzle metadata and inventory icons. The four original tier-one unit atlases are retained. The other 26 weapons have 78 animated variants using the three existing faction rigs: 143,520 new frames across eight directions, including wounded movement, both death types, cover transitions and aftermath animation. Portraits and blood/muzzle presentation use the equipped model.
- Ninety original synthesized shot sounds: three variations per model. No external recordings were used. The apartment instrumental, heartbeat and city ambience retain their existing mix.
- Model names and weapon tiers in live unit cards and battle results. The AWM uses its short model name on narrow cards, with the full manufacturer/model name in the tooltip and arsenal inspector.
- An arsenal review scene with all models, animation/facing/faction previews, model stats, sound audition and loadout selectors for both teams. Its standard four-class 4v4 and sniper 4v4 tests use fresh isolated worlds and do not write campaign saves. The sniper test replaces the rifle recruitment slot; it does not put five people into a four-seat car.

## Sniper behavior

The recovered design history distinguishes an older kill/wound/graze example from the later trauma/vitality combat system. This implementation follows hit quality → trauma → vitality. A sufficiently strong critical can kill a healthy unit; a second wound is not an automatic death.

Snipers prefer distant visible targets, retain a valid target while settling, and switch to a visible immediate threat inside 12 tactical units. Explicit player focus orders remain authoritative. Movement interrupts aim and blocks firing, and wounded reactions cannot skip the settling delay. Model range influences positioning; useful cover is retained, while blocked sightlines and unsafe close threats can prompt repositioning. Close-range handling is deliberately weaker than settled long-range fire.

Dedicated sniper outfits remain deferred. They currently use each faction's existing rifle-role clothing.

## Validation

Machine-readable reports are under `tools/arsenal_production/`:

- `validation.json`: 290 gameplay assertions passed, covering model/profile validity, class assignment, movement, range/falloff, recoil and sniper fire/target behavior.
- `presentation_validation.json`: the exact final assertion count and results for all 90 model/faction bindings, portraits, icons, animation clips and audio references. The full atlas cache is bounded at 12 variants.
- `art_report.json`: 78 complete 1,840-frame variants. The long-rifle carry and transition crops were corrected. Eighteen pre-existing lower-body edge contacts per variant are inherited from the approved base rig; they are not new weapon crops.
- `battle_comparison.json`: 12 seeded Harold battles, including six sniper matchups, with no reported script errors. Eleven resolved; the standard non-sniper pair 2 (seed 4202) remained active at the 120-second limit with two survivors per side. All six sniper matchups resolved. All 96 starting participants had cover. A test-launch issue that reapplied deployment cover orders after beginning combat was fixed in the isolated review fixture.
- `graphics_validation.json`: one rendered battle with eight different tier-three weapons, including AWM versus PSG1, reached its ending/results presentation with 54 shots and no reported errors. Combat lasted 37.54 seconds. At 1440×900 on the laptop, measured median frame rate was 49 FPS, with a 34 FPS low during the sampled active portion.

The rendered captures verified equipped sprites, HUD portraits and end-result cards. The AWM label was subsequently shortened after this capture exposed truncation.

## Balance limits and next review

These are provisional game values, not claims about manufacturer specifications. All 11 resolved automated fixture battles were defender wins; one standard matchup remained unresolved at the 120-second limit. Those tests used the same far-arrival map and an attacking Push order, so they provide integration evidence, not proof that every battle finishes or balanced faction win rates. The unresolved seed needs a focused follow-up before declaring reliable battle completion. The rendered sniper battle also favored the defenders. Further tuning should compare equal-tier loadouts, alternate arrival/commands and representative player control before declaring final balance.

Campaign production costs, stockpiles, weapon shipping/trade and storage rules were not implemented in this tactical asset pass. Existing faction art direction remains intact.

## Review entry point

Run `tools/arsenal_production/Open-Arsenal.ps1`, or open `gameplay/arsenal_review.tscn` in Godot and run the current scene. Escape returns from a test battle to the arsenal. `arsenal_production_board.png` is a contact sheet made directly from the finished game sprites, with the same values listed in `docs/ARSENAL_MODEL_REFERENCE.md`.

## Checkpoint authorization and regression audit (2026-09-11 UTC)

The owner authorized committing and pushing this recoverable arsenal checkpoint, with subsequent visual and balance edits. This is a work-in-progress checkpoint, not a claim of final balance or a fully green legacy suite. The current focused arsenal validators pass 290 gameplay and 12,800 presentation checks. A full CORE VALIDATION run reports 166 failed assertions versus 120 on a fresh worktree of the prior ee3694a checkpoint; 46 additional failures require triage against changed model movement, handling and sniper behavior. The names are preserved in tools/arsenal_production/core_checkpoint_comparison.json.

Owner direction: attackers must have better chances to win, and battles must never resolve because time expires. Code audit confirms BattleVictoryService resolves by surviving sides, with no elapsed-time cutoff. The comparison script stops observing after 2,400 steps of 0.05 seconds; it leaves an unfinished battle active and assigns no winner. Future reports must label this as an observation cutoff. Attacker tuning follows this checkpoint.

## Checkpoint authorization and regression audit (2026-09-11 UTC)

The owner authorized committing and pushing this recoverable arsenal checkpoint, with subsequent visual and balance edits. This is a work-in-progress checkpoint, not a claim of final balance or a fully green legacy suite. The current focused arsenal validators pass 290 gameplay and 12,800 presentation checks. A full CORE VALIDATION run reports 166 failed assertions versus 120 on a fresh worktree of the prior ee3694a checkpoint; 46 additional failures require triage against changed model movement, handling and sniper behavior. The names are preserved in tools/arsenal_production/core_checkpoint_comparison.json.

Owner direction: attackers must have better chances to win, and battles must never resolve because time expires. Code audit confirms BattleVictoryService resolves by surviving sides, with no elapsed-time cutoff. The comparison script stops observing after 2,400 steps of 0.05 seconds; it leaves an unfinished battle active and assigns no winner. Future reports must label this as an observation cutoff. Attacker tuning follows this checkpoint.
