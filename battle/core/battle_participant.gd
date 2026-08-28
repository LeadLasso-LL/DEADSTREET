class_name BattleParticipant
extends RefCounted

var participant_id: String = ""
var campaign_soldier_id: String = ""
var faction_id: String = ""
var side_id: String = ""
var weapon_type: String = ""
var is_alive: bool = true
var is_wounded: bool = false
var deployment_slot_id: String = ""
var has_battle_position: bool = false
var battle_position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var movement_intent: Vector2 = Vector2.ZERO
var movement_speed: float = 0.0
var navigation_destination: Vector2 = Vector2.ZERO
var has_navigation_destination: bool = false
var navigation_waypoints: Array[Vector2] = []
var navigation_waypoint_index: int = 0


func _init(
	p_participant_id: String = "",
	p_campaign_soldier_id: String = "",
	p_faction_id: String = "",
	p_side_id: String = "",
	p_weapon_type: String = "",
	p_is_alive: bool = true,
	p_is_wounded: bool = false,
	p_deployment_slot_id: String = ""
) -> void:
	participant_id = p_participant_id
	campaign_soldier_id = p_campaign_soldier_id
	faction_id = p_faction_id
	side_id = p_side_id
	weapon_type = p_weapon_type
	is_alive = p_is_alive
	is_wounded = p_is_wounded
	deployment_slot_id = p_deployment_slot_id


func set_movement_intent(direction: Vector2) -> bool:
	if not is_finite(direction.x) or not is_finite(direction.y):
		push_error("BattleParticipant.set_movement_intent: direction is not finite.")
		return false
	if direction == Vector2.ZERO:
		movement_intent = Vector2.ZERO
		return true
	movement_intent = direction.normalized()
	return true


func clear_movement_intent() -> void:
	movement_intent = Vector2.ZERO


func set_movement_speed(value: float) -> bool:
	if not is_finite(value) or value < 0.0:
		push_error("BattleParticipant.set_movement_speed: value is invalid.")
		return false
	movement_speed = value
	return true


func set_navigation_path(destination: Vector2, waypoints: Array[Vector2]) -> bool:
	if not is_finite(destination.x) or not is_finite(destination.y):
		push_error("BattleParticipant.set_navigation_path: destination is not finite.")
		return false
	var copied: Array[Vector2] = []
	for waypoint: Vector2 in waypoints:
		if not is_finite(waypoint.x) or not is_finite(waypoint.y):
			push_error("BattleParticipant.set_navigation_path: waypoint is not finite.")
			return false
		if copied.is_empty() or not copied[copied.size() - 1].is_equal_approx(waypoint):
			copied.append(waypoint)
	navigation_destination = destination
	has_navigation_destination = true
	navigation_waypoints = copied
	navigation_waypoint_index = 0
	return true


func clear_navigation_path() -> void:
	navigation_destination = Vector2.ZERO
	has_navigation_destination = false
	navigation_waypoints = []
	navigation_waypoint_index = 0


func has_active_navigation_path() -> bool:
	if not has_navigation_destination:
		return false
	if navigation_waypoint_index < 0:
		return false
	return navigation_waypoint_index < navigation_waypoints.size()


func get_current_navigation_waypoint() -> Vector2:
	if not has_active_navigation_path():
		return Vector2.ZERO
	return navigation_waypoints[navigation_waypoint_index]
