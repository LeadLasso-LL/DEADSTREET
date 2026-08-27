class_name ForceMoveResult
extends RefCounted

var success: bool = false
var force_id: String = ""
var destination_location_id: String = ""
var error_code: String = ""
var error_message: String = ""
var reached_destination: bool = false
var movement_spent: float = 0.0
var movement_remaining: float = 0.0


static func succeeded(
	p_force_id: String,
	p_destination_location_id: String,
	p_reached_destination: bool,
	p_movement_spent: float,
	p_movement_remaining: float
) -> ForceMoveResult:
	var result: ForceMoveResult = ForceMoveResult.new()
	result.success = true
	result.force_id = p_force_id
	result.destination_location_id = p_destination_location_id
	result.error_code = ""
	result.error_message = ""
	result.reached_destination = p_reached_destination
	result.movement_spent = maxf(p_movement_spent, 0.0)
	result.movement_remaining = maxf(p_movement_remaining, 0.0)
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_force_id: String = "",
	p_destination_location_id: String = ""
) -> ForceMoveResult:
	var result: ForceMoveResult = ForceMoveResult.new()
	result.success = false
	result.force_id = p_force_id
	result.destination_location_id = p_destination_location_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	result.reached_destination = false
	result.movement_spent = 0.0
	result.movement_remaining = 0.0
	return result
