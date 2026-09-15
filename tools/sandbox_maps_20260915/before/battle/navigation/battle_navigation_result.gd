class_name BattleNavigationResult
extends RefCounted

var success: bool = false
var start_position: Vector2 = Vector2.ZERO
var destination: Vector2 = Vector2.ZERO
var waypoints: Array[Vector2] = []
var used_detour: bool = false
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_start_position: Vector2,
	p_destination: Vector2,
	p_waypoints: Array[Vector2],
	p_used_detour: bool
) -> BattleNavigationResult:
	var result: BattleNavigationResult = BattleNavigationResult.new()
	result.success = true
	result.start_position = p_start_position
	result.destination = p_destination
	result.waypoints = _copy_waypoints(p_waypoints)
	result.used_detour = p_used_detour
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_start_position: Vector2 = Vector2.ZERO,
	p_destination: Vector2 = Vector2.ZERO
) -> BattleNavigationResult:
	var result: BattleNavigationResult = BattleNavigationResult.new()
	result.success = false
	result.start_position = p_start_position
	result.destination = p_destination
	result.waypoints = []
	result.used_detour = false
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func _copy_waypoints(source: Array[Vector2]) -> Array[Vector2]:
	var copied: Array[Vector2] = []
	for waypoint: Vector2 in source:
		copied.append(waypoint)
	return copied
