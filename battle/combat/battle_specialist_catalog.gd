class_name BattleSpecialistCatalog
extends RefCounted

const Definition = preload("res://battle/combat/battle_weapon_definition.gd")
const MERCER_DUAL_GLOCK := "mercer_dual_glock"
const RECRUIT_COST_MULTIPLIER := 1.5

# rival_gang is the current Mercer campaign ID in the authored dusk scenario.
static func eligible(faction_id: String, weapon_class: String, model_id: String, specialist_id: String) -> bool:
	return specialist_id == MERCER_DUAL_GLOCK and faction_id in ["mercer_saints", "rival_gang"] and weapon_class == "pistol" and model_id == "glock_17"

static var _dual_profile = null

static func profile(base):
	if base == null or base.model_id != "glock_17": return null
	if _dual_profile != null: return _dual_profile
	var d = Definition.new()
	for key in ["weapon_type_id", "model_id", "tier", "movement_multiplier", "acquire_seconds", "reacquire_seconds", "recoil_per_shot", "recoil_recovery", "graze_trauma", "solid_trauma", "critical_trauma"]:
		d.set(key, base.get(key))
	d.display_name = "Mercer dual-pistol specialist"
	d.max_range = 20.0
	d.shots_per_second = 3.5
	d.magazine_capacity = 24
	d.reload_seconds = 3.0
	d.movement_multiplier *= 0.95
	d.graze_probability = base.graze_probability * 0.90
	d.solid_probability = base.solid_probability * 0.90
	d.critical_probability = base.critical_probability * 0.90
	d.miss_probability = 1.0 - (1.0 - base.miss_probability) * 0.90
	_dual_profile = d
	return d

# Campaign limits are an explicit caller-supplied rule, never a per-army count.
# No final cap number has been approved. This API deliberately has no default.
static func faction_count(state, faction_id: String) -> int:
	var count := 0
	for soldier in state.soldiers.values():
		if soldier.faction_id == faction_id and not soldier.specialist_id.is_empty(): count += 1
	return count

static func assign_soldier(state, soldier, specialist_id: String, faction_limit: int) -> bool:
	if state == null or soldier == null or faction_limit < 0: return false
	if state.soldiers.get(soldier.id) != soldier: return false
	if not eligible(soldier.faction_id, soldier.weapon_type_id, "glock_17", specialist_id): return false
	if soldier.specialist_id == specialist_id: return true
	if not soldier.specialist_id.is_empty() or faction_count(state, soldier.faction_id) >= faction_limit: return false
	soldier.specialist_id = specialist_id
	return true
