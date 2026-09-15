class_name BattleVehiclePlacementResult
extends RefCounted

var success: bool = false
var vehicle_id: String = ""
var position: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_vehicle_id: String,
	p_position: Vector2,
	p_facing_direction: Vector2
):
	var result = new()
	result.success = true
	result.vehicle_id = p_vehicle_id
	result.position = p_position
	result.facing_direction = p_facing_direction
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_vehicle_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_facing_direction: Vector2 = Vector2.ZERO
):
	var result = new()
	result.success = false
	result.vehicle_id = p_vehicle_id
	result.position = p_position
	result.facing_direction = p_facing_direction
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
