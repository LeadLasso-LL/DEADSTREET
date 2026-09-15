class_name ExistingForceMissionResult
extends RefCounted

var success: bool = false
var mission_id: String = ""
var force_id: String = ""
var mission_state: String = ""
var reached_destination: bool = false
var movement_spent: float = 0.0
var movement_remaining: float = 0.0
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_mission_id: String,
	p_force_id: String,
	p_mission_state: String,
	p_reached_destination: bool,
	p_movement_spent: float,
	p_movement_remaining: float
) -> ExistingForceMissionResult:
	var result: ExistingForceMissionResult = ExistingForceMissionResult.new()
	result.success = true
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.mission_state = p_mission_state
	result.reached_destination = p_reached_destination
	result.movement_spent = maxf(p_movement_spent, 0.0)
	result.movement_remaining = maxf(p_movement_remaining, 0.0)
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = "",
	p_force_id: String = "",
	p_mission_state: String = ""
) -> ExistingForceMissionResult:
	var result: ExistingForceMissionResult = ExistingForceMissionResult.new()
	result.success = false
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.mission_state = p_mission_state
	result.reached_destination = false
	result.movement_spent = 0.0
	result.movement_remaining = 0.0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
