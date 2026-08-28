class_name BattleSpatialResult
extends RefCounted

var success: bool = false
var start_position: Vector2 = Vector2.ZERO
var requested_displacement: Vector2 = Vector2.ZERO
var resolved_displacement: Vector2 = Vector2.ZERO
var final_position: Vector2 = Vector2.ZERO
var was_blocked: bool = false
var blocking_obstacle_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_start_position: Vector2,
	p_requested_displacement: Vector2,
	p_resolved_displacement: Vector2,
	p_final_position: Vector2,
	p_was_blocked: bool,
	p_blocking_obstacle_id: String = ""
) -> BattleSpatialResult:
	var result: BattleSpatialResult = BattleSpatialResult.new()
	result.success = true
	result.start_position = p_start_position
	result.requested_displacement = p_requested_displacement
	result.resolved_displacement = p_resolved_displacement
	result.final_position = p_final_position
	result.was_blocked = p_was_blocked
	result.blocking_obstacle_id = p_blocking_obstacle_id
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_start_position: Vector2 = Vector2.ZERO,
	p_requested_displacement: Vector2 = Vector2.ZERO,
	p_blocking_obstacle_id: String = ""
) -> BattleSpatialResult:
	var result: BattleSpatialResult = BattleSpatialResult.new()
	result.success = false
	result.start_position = p_start_position
	result.requested_displacement = p_requested_displacement
	result.resolved_displacement = Vector2.ZERO
	result.final_position = p_start_position
	result.was_blocked = false
	result.blocking_obstacle_id = p_blocking_obstacle_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
