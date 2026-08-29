class_name BattleWeaponState
extends RefCounted

# Temporary tactical runtime state. Not campaign-serialized.
var weapon_type_id: String = ""
var ammo_in_magazine: int = 0
var cooldown_remaining_seconds: float = 0.0
var reload_remaining_seconds: float = 0.0
var is_reloading: bool = false


func _init(
	p_weapon_type_id: String = "",
	p_ammo_in_magazine: int = 0,
	p_cooldown_remaining_seconds: float = 0.0,
	p_reload_remaining_seconds: float = 0.0,
	p_is_reloading: bool = false
) -> void:
	weapon_type_id = p_weapon_type_id
	ammo_in_magazine = p_ammo_in_magazine
	cooldown_remaining_seconds = p_cooldown_remaining_seconds
	reload_remaining_seconds = p_reload_remaining_seconds
	is_reloading = p_is_reloading


func has_ammo_in_magazine() -> bool:
	return ammo_in_magazine > 0


func is_cooling_down() -> bool:
	if not is_finite(cooldown_remaining_seconds):
		return false
	return cooldown_remaining_seconds > 0.0
