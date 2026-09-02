class_name BattleShotgunRangeFalloffService
extends RefCounted

const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleShotgunRangeFalloffResult := preload("res://battle/combat/battle_shotgun_range_falloff_result.gd")

# Shotgun-only close→edge interpolation. Not used by other weapons.
# t = 0 at preferred max and closer; t = 1 at max range and beyond.
# Interpolates cumulative quality bands and trauma. Does not draw RNG.
const EDGE_MISS_PROBABILITY := 0.60
const EDGE_GRAZE_PROBABILITY := 0.25
const EDGE_SOLID_PROBABILITY := 0.14
const EDGE_CRITICAL_PROBABILITY := 0.01
const EDGE_GRAZE_TRAUMA := 0.06
const EDGE_SOLID_TRAUMA := 0.28
const EDGE_CRITICAL_TRAUMA := 0.55


static func apply(
	definition: BattleWeaponDefinition,
	distance: float
) -> BattleShotgunRangeFalloffResult:
	if definition == null or definition.weapon_type_id != BattleWeaponCatalog.WEAPON_SHOTGUN:
		return null
	var t: float = distance_t(distance)
	var close_miss_end: float = definition.miss_probability
	var close_graze_end: float = close_miss_end + definition.graze_probability
	var close_solid_end: float = close_graze_end + definition.solid_probability
	var edge_miss_end: float = EDGE_MISS_PROBABILITY
	var edge_graze_end: float = edge_miss_end + EDGE_GRAZE_PROBABILITY
	var edge_solid_end: float = edge_graze_end + EDGE_SOLID_PROBABILITY
	var miss_end: float = lerpf(close_miss_end, edge_miss_end, t)
	var graze_end: float = lerpf(close_graze_end, edge_graze_end, t)
	var solid_end: float = lerpf(close_solid_end, edge_solid_end, t)
	var result: BattleShotgunRangeFalloffResult = BattleShotgunRangeFalloffResult.new()
	result.miss_probability = miss_end
	result.graze_probability = graze_end - miss_end
	result.solid_probability = solid_end - graze_end
	result.critical_probability = 1.0 - solid_end
	result.graze_trauma = lerpf(definition.graze_trauma, EDGE_GRAZE_TRAUMA, t)
	result.solid_trauma = lerpf(definition.solid_trauma, EDGE_SOLID_TRAUMA, t)
	result.critical_trauma = lerpf(definition.critical_trauma, EDGE_CRITICAL_TRAUMA, t)
	return result


static func distance_t(distance: float) -> float:
	if not is_finite(distance):
		return 0.0
	var full_strength_range: float = BattleCombatBehaviorCatalog.SHOTGUN_PREFERRED_MAX
	var max_range: float = BattleWeaponCatalog.SHOTGUN_MAX_RANGE
	if not is_finite(full_strength_range) or not is_finite(max_range):
		return 0.0
	if max_range <= full_strength_range:
		return 0.0
	if distance <= full_strength_range or is_equal_approx(distance, full_strength_range):
		return 0.0
	if distance >= max_range or is_equal_approx(distance, max_range):
		return 1.0
	return (distance - full_strength_range) / (max_range - full_strength_range)
