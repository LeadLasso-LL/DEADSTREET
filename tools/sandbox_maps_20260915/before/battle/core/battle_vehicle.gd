class_name BattleVehicle
extends RefCounted

# Temporary tactical snapshot of one campaign vehicle.
# battle_vehicle_id reuses campaign_vehicle_id. Not an anonymous prop.

var battle_vehicle_id: String = ""
var campaign_vehicle_id: String = ""
var faction_id: String = ""
var side_id: String = ""
var vehicle_type_id: String = ""
var deployment_slot_id: String = ""
var has_battle_position: bool = false
var battle_position: Vector2 = Vector2.ZERO
# Unit vector along body length (forward). Derived body uses this + physical profile.
var has_facing: bool = false
var facing_direction: Vector2 = Vector2.ZERO


func _init(
	p_battle_vehicle_id: String = "",
	p_campaign_vehicle_id: String = "",
	p_faction_id: String = "",
	p_side_id: String = "",
	p_vehicle_type_id: String = "",
	p_deployment_slot_id: String = ""
) -> void:
	battle_vehicle_id = p_battle_vehicle_id
	campaign_vehicle_id = p_campaign_vehicle_id
	faction_id = p_faction_id
	side_id = p_side_id
	vehicle_type_id = p_vehicle_type_id
	deployment_slot_id = p_deployment_slot_id


func set_facing_direction(direction: Vector2) -> bool:
	if not is_finite(direction.x) or not is_finite(direction.y):
		push_error("BattleVehicle.set_facing_direction: direction is not finite.")
		return false
	if direction.is_equal_approx(Vector2.ZERO):
		push_error("BattleVehicle.set_facing_direction: direction is zero.")
		return false
	facing_direction = direction.normalized()
	has_facing = true
	return true


func has_valid_orientation() -> bool:
	if not has_facing:
		return false
	if not is_finite(facing_direction.x) or not is_finite(facing_direction.y):
		return false
	if facing_direction.is_equal_approx(Vector2.ZERO):
		return false
	return is_equal_approx(facing_direction.length(), 1.0)
