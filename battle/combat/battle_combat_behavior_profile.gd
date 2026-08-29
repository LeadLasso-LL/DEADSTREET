class_name BattleCombatBehaviorProfile
extends RefCounted

var weapon_type_id: String = ""
var preferred_min_distance: float = 0.0
var preferred_max_distance: float = 0.0


func _init(
	p_weapon_type_id: String = "",
	p_preferred_min_distance: float = 0.0,
	p_preferred_max_distance: float = 0.0
) -> void:
	weapon_type_id = p_weapon_type_id
	preferred_min_distance = p_preferred_min_distance
	preferred_max_distance = p_preferred_max_distance


func is_valid() -> bool:
	if weapon_type_id.is_empty():
		return false
	if not is_finite(preferred_min_distance) or preferred_min_distance < 0.0:
		return false
	if not is_finite(preferred_max_distance) or preferred_max_distance < 0.0:
		return false
	return preferred_max_distance >= preferred_min_distance
