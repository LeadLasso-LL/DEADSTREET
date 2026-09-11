# Attacker tactics follow-up - 2026-09-11

The owner requested a recoverable arsenal checkpoint, better attacker chances, and battles that never end because time expires. The arsenal checkpoint is `d18c486` on `build/arsenal-checkpoint-20260911`; this follow-up keeps the changes on that branch for review and further editing.

## Behavior changes

- Advancing forces using Push or Focus Left/Right prefer an in-range enemy with a usable sightline over a nearer blocked enemy. A valid retained target receives a modest preference to avoid unnecessary switching. Explicit player targets and the separate sniper targeting policy retain authority.
- Healthy units retain protective cover when they have a usable firing position, even outside their weapon's preferred distance band. Existing unsafe-close-enemy and blocked-position recovery behavior remains.
- Covered opponents can begin their peek transitions when the only firing blocker is the other unit being tucked. Previously both could wait for the other to expose first. Actual shots still require the existing cover, sightline, handling and readiness checks. Walls continue to block both peeking opportunities and shots.

These are tactical decisions, with no attacker-only damage or accuracy multiplier.

## Battle endings

`BattleVictoryService` resolves combat from surviving sides, without an elapsed-time limit. The old 120-second figure was the comparison script's observation budget, not a timed defeat. The new diagnostic explicitly records `observation_cutoff` and leaves an unfinished battle active with no invented winner. Before each final test battle it checks that elapsed values of 120, 3,600 and 86,400 seconds cannot resolve a battle with both sides alive.

The existing no-shot repositioning recovery remains; it changes a unit's position, never the battle result. A candidate that suppressed this recovery was rejected and is absent from the final code.

## Reproducible comparisons

All tests use the isolated Harold far-arrival fixture and an attacker Push order. Pair N uses seed 4200 + N. Matched loadouts equip both teams with the same weapon model for each class. The original comparison cycles the defender to the next model, so those loadouts can differ in tier.

| Set | Before | Final |
| --- | --- | --- |
| Matched loadouts, pairs 0/2/4 | 0 attacker wins, 3 defender wins | 2 attacker wins, 1 defender win |
| Original mixed loadouts, pairs 0-5 | 0 attacker wins, 5 defender wins, 1 observation cutoff | 1 attacker win, 5 defender wins, no cutoff |
| Matched loadouts with sniper substitution, pairs 0/4 | No matched baseline captured | 1 attacker win, 1 defender win, no cutoff |

All 11 final battles resolved naturally, from 17.80 to 119.70 simulated seconds. The previously stalled original pair 2 resolved in 51.15 seconds. This is a small deterministic comparison, not an estimate of overall win rates. Different maps, arrivals, commands and player intervention remain product review work.

Evidence under `tools/arsenal_production/`:

- `attacker_balance_equal_before.json` and `attacker_balance_equal_final.json` preserve the matched before/after results.
- `battle_comparison.json` preserves the original arsenal comparison; `attacker_balance_original_final.json` contains the six final standard matchups.
- `attacker_balance_snipers_final.json` contains the two matched sniper substitution tests.
- `attacker_tactics_validation.json`: 12 checks passed, including mutual peeking, hard-wall blocking, protective cover, visible target selection and explicit player focus.
- `validation.json`: all 290 focused arsenal checks passed again.
- `attacker_regression_comparison.json`: full CORE VALIDATION still fails 166 assertions, exactly the same failure set as `d18c486`. This tactics follow-up adds no assertion failures. The earlier arsenal checkpoint had 46 more failures than the 120 in pre-arsenal `ee3694a`; that separate regression gate remains unresolved and is documented in `core_checkpoint_comparison.json`.

No new rendered performance or visual acceptance run was made for this tactics follow-up. The earlier arsenal graphics and presentation evidence remains historical evidence, not a fresh visual approval.
