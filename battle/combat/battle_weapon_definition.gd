class_name BattleWeaponDefinition
extends RefCounted

const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")

var weapon_type_id: String = ""
var max_range: float = 0.0
var shots_per_second: float = 0.0
var magazine_capacity: int = 0
var reload_seconds: float = 0.0
var miss_probability: float = 0.0
var graze_probability: float = 0.0
var solid_probability: float = 0.0
var critical_probability: float = 0.0
var graze_trauma: float = 0.0
var solid_trauma: float = 0.0
var critical_trauma: float = 0.0


func _init(
	p_weapon_type_id: String = "",
	p_max_range: float = 0.0,
	p_shots_per_second: float = 0.0,
	p_magazine_capacity: int = 0,
	p_reload_seconds: float = 0.0,
	p_miss_probability: float = 0.0,
	p_graze_probability: float = 0.0,
	p_solid_probability: float = 0.0,
	p_critical_probability: float = 0.0,
	p_graze_trauma: float = 0.0,
	p_solid_trauma: float = 0.0,
	p_critical_trauma: float = 0.0
) -> void:
	weapon_type_id = p_weapon_type_id
	max_range = p_max_range
	shots_per_second = p_shots_per_second
	magazine_capacity = p_magazine_capacity
	reload_seconds = p_reload_seconds
	miss_probability = p_miss_probability
	graze_probability = p_graze_probability
	solid_probability = p_solid_probability
	critical_probability = p_critical_probability
	graze_trauma = p_graze_trauma
	solid_trauma = p_solid_trauma
	critical_trauma = p_critical_trauma


func is_valid() -> bool:
	if weapon_type_id.is_empty():
		return false
	if not is_finite(max_range) or max_range <= 0.0:
		return false
	if not is_finite(shots_per_second) or shots_per_second <= 0.0:
		return false
	if magazine_capacity < 1:
		return false
	if not is_finite(reload_seconds) or reload_seconds < 0.0:
		return false
	return true


func has_valid_combat_profile() -> bool:
	if not is_valid():
		return false
	var profile: BattleAttackProfile = attack_profile()
	if profile == null or not profile.is_valid():
		return false
	if not is_finite(graze_trauma) or graze_trauma < 0.0:
		return false
	if not is_finite(solid_trauma) or solid_trauma < 0.0:
		return false
	if not is_finite(critical_trauma) or critical_trauma < 0.0:
		return false
	return true


func attack_profile() -> BattleAttackProfile:
	return BattleAttackProfile.new(
		miss_probability,
		graze_probability,
		solid_probability,
		critical_probability
	)


func trauma_for_hit_quality(hit_quality: String) -> float:
	match hit_quality:
		BattleAttackProfile.QUALITY_GRAZE:
			return graze_trauma
		BattleAttackProfile.QUALITY_SOLID:
			return solid_trauma
		BattleAttackProfile.QUALITY_CRITICAL:
			return critical_trauma
		_:
			return 0.0


func cooldown_seconds() -> float:
	if not is_valid():
		return INF
	return 1.0 / shots_per_second
