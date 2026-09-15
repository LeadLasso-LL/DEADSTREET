class_name BattleVehiclePhysicalProfile
extends RefCounted

# Provisional tactical body size for a vehicle_type_id.
# Not campaign travel stats, HP, weapons, or final art.

var vehicle_type_id: String = ""
var length: float = 0.0
var width: float = 0.0


func _init(p_vehicle_type_id: String = "", p_length: float = 0.0, p_width: float = 0.0) -> void:
	vehicle_type_id = p_vehicle_type_id
	length = p_length
	width = p_width


func is_valid() -> bool:
	if vehicle_type_id.is_empty():
		return false
	if not is_finite(length) or not is_finite(width):
		return false
	return length > 0.0 and width > 0.0


func half_length() -> float:
	return length * 0.5


func half_width() -> float:
	return width * 0.5
