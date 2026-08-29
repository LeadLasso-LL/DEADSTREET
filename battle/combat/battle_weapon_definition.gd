class_name BattleWeaponDefinition
extends RefCounted

var weapon_type_id: String = ""
var max_range: float = 0.0
var shots_per_second: float = 0.0
var magazine_capacity: int = 0
var reload_seconds: float = 0.0


func _init(
	p_weapon_type_id: String = "",
	p_max_range: float = 0.0,
	p_shots_per_second: float = 0.0,
	p_magazine_capacity: int = 0,
	p_reload_seconds: float = 0.0
) -> void:
	weapon_type_id = p_weapon_type_id
	max_range = p_max_range
	shots_per_second = p_shots_per_second
	magazine_capacity = p_magazine_capacity
	reload_seconds = p_reload_seconds


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


func cooldown_seconds() -> float:
	if not is_valid():
		return INF
	return 1.0 / shots_per_second
