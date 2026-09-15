class_name BattleCoverCombatEffectService
extends RefCounted

const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleCoverCombatEffectResult := preload("res://battle/combat/battle_cover_combat_effect_result.gd")

# Deterministic pre-cover → post-cover resolution-roll transform.
# cover_multiplier = 1.0 - (MAX_COVER_ROLL_REDUCTION * protection_factor)
# post_cover_roll = pre_cover_roll * cover_multiplier
# Does not draw RNG, mutate state, or decide fire eligibility.


static func apply(pre_cover_roll: float, protection_factor: float) -> BattleCoverCombatEffectResult:
	var result: BattleCoverCombatEffectResult = BattleCoverCombatEffectResult.new()
	var factor: float = 0.0
	if is_finite(protection_factor):
		factor = clampf(protection_factor, 0.0, 1.0)
	var reduction: float = BattleCombatBehaviorCatalog.MAX_COVER_ROLL_REDUCTION
	if not is_finite(reduction) or reduction < 0.0:
		reduction = 0.0
	else:
		reduction = clampf(reduction, 0.0, 1.0)
	var multiplier: float = 1.0 - (reduction * factor)
	if not is_finite(multiplier):
		multiplier = 1.0
	else:
		multiplier = clampf(multiplier, 0.0, 1.0)
	var post_cover_roll: float = pre_cover_roll
	if is_finite(pre_cover_roll):
		post_cover_roll = pre_cover_roll * multiplier
		if not is_finite(post_cover_roll):
			post_cover_roll = pre_cover_roll
	result.pre_cover_roll = pre_cover_roll
	result.protection_factor = factor
	result.cover_multiplier = multiplier
	result.post_cover_roll = post_cover_roll
	return result
