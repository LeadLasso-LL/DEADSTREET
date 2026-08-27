class_name ForceTurnResult
extends RefCounted

var force_id: String = ""
var movement_refreshed: float = 0.0
var movement_spent: float = 0.0
var movement_remaining: float = 0.0
var state_before: String = ""
var state_after: String = ""
var reached_destination: bool = false
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_force_id: String,
	p_movement_refreshed: float,
	p_movement_spent: float,
	p_movement_remaining: float,
	p_state_before: String,
	p_state_after: String,
	p_reached_destination: bool
) -> ForceTurnResult:
	var result: ForceTurnResult = ForceTurnResult.new()
	result.force_id = p_force_id
	result.movement_refreshed = maxf(p_movement_refreshed, 0.0)
	result.movement_spent = maxf(p_movement_spent, 0.0)
	result.movement_remaining = maxf(p_movement_remaining, 0.0)
	result.state_before = p_state_before
	result.state_after = p_state_after
	result.reached_destination = p_reached_destination
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_force_id: String = "",
	p_movement_refreshed: float = 0.0,
	p_movement_spent: float = 0.0,
	p_movement_remaining: float = 0.0,
	p_state_before: String = "",
	p_state_after: String = "",
	p_reached_destination: bool = false
) -> ForceTurnResult:
	var result: ForceTurnResult = ForceTurnResult.new()
	result.force_id = p_force_id
	result.movement_refreshed = maxf(p_movement_refreshed, 0.0)
	result.movement_spent = maxf(p_movement_spent, 0.0)
	result.movement_remaining = maxf(p_movement_remaining, 0.0)
	result.state_before = p_state_before
	result.state_after = p_state_after
	result.reached_destination = p_reached_destination
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
