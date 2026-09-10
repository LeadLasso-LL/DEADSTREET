# Live relative strength and adaptive counterattacks

Requested by Brandon after the Harold audio/cinematics recording: a Total War-like relative-strength display should influence battle behavior, including defenders exploiting an advantage during a lull. This replaces the need for a timed defender counterattack in the new AI review. The approved video and its reproduction script remain an archived staged showcase.

## First implementation

`battle/ai/battle_relative_strength.gd` derives fighting capability from the live participants and weapon catalog every half-second. Contributions use sustained expected weapon trauma (including magazine/reload cycle), weapon reach, remaining vitality, wound state, immediate reload readiness and a modest occupied-cover benefit. Dead units contribute nothing. Contributions from both sides form complementary shares. It is a fighting-strength estimate, not a win probability. Current weapons/stats are provisional; there is no new hit, damage, health or RNG bonus.

The bottom command HUD shows a compact green/red relative-strength bar and Advantage/Even/Disadvantage label. Its visual fill eases between observations. It does not enlarge or change the approved top-left context graphic.

`battle/ai/battle_adaptive_tactics.gd` uses the same snapshot to choose intent for AI-controlled forces:

- A share of at least 60%, persisting for 2.5 seconds and with a short break in friendly health losses, can trigger Push.
- A share at or below 34% can trigger tactical Fall Back.
- Hysteresis (53% to retain Push; 42% to retain Fall Back) and a five-second minimum posture duration avoid order oscillation.
- Per-unit nearby support and local strength gate aggressive advances. A healthy supported unit can leave its initial defender anchor; wounded units keep their existing survival behavior. Useful cover and role-specific movement still use the existing combat/navigation services.
- The previous unconditional defender-cover hold now permits supported adaptive counterattacks. This activates existing short-range cover advances rather than inventing a separate scripted mover.
- Explicit group orders are marked and never overwritten by the adaptive director, including reissuing the current command. Individual player movement/cover/target intent remains authoritative under the existing survival rules.

The current gameplay contract identifies the attacker as the player side. That side's strategic group command remains player-controlled; enemy forces choose their own group intent. A future selectable player side must update this ownership contract together with `TacticalUnitHudQuery.player_side_id`. This implementation uses the current fully known battlefield; it does not add fog of war, intelligence estimation, morale, routing or campaign withdrawal.

## Evidence

`tools/strength_review/validate.gd`: 19 targeted checks pass for casualties, wounds, reloading, complementary shares, deterministic observations, confirmation delay, balanced holds, advantage-driven Push, disadvantage-driven Fall Back, local caution, command authority and zero-delta behavior.

`tools/strength_review/review.gd`: legal 4v4 deployment, seed 2002. Only the player's opening maneuvers are authored. There are **no timed defender orders and no health edits**. The Saints independently selected Push at **14.267 seconds**, with a **67.08%** assessed share. Three defenders moved approximately **11.0, 21.7 and 5.4** world units; the rifleman remained in cover. The 55-second observation produced 69 shots and was still active at the observation limit. This demonstrates a reactive counterattack, not a promise that every battle finishes within that window.

Decision records include the time, force, order, assessed share and reason. These are debug evidence, not an extra player-facing explanation panel. Review output lives in `tools/strength_review/results/` and the checkpoint evidence in `docs/references/relative_strength/`.

## Deferred visual notes — do not implement in this pass

- Open the arrival car's rear doors for four occupants.
- Make open doors usable cover positions.
- Preserve the seamless large intro-to-corner transition.
- Trim excess empty space on the right of the persistent top-left rectangle; keep its content readable.

Regression verification: the existing **713** unit/HUD checks and **121** presentation checks also passed, for **853 total checks** including the new strength suite. The compact HUD meter was visually inspected in a live rendered battle.
