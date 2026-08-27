class_name MissionResult
extends RefCounted

var success: bool = false
var mission_id: String = ""
var force_id: String = ""
var error_code: String = ""
var error_message: String = ""
var mission_state: String = ""


static func succeeded(p_mission_id: String, p_force_id: String, p_mission_state: String) -> MissionResult:
	var result: MissionResult = MissionResult.new()
	result.success = true
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.error_code = ""
	result.error_message = ""
	result.mission_state = p_mission_state
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = "",
	p_force_id: String = "",
	p_mission_state: String = ""
) -> MissionResult:
	var result: MissionResult = MissionResult.new()
	result.success = false
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	result.mission_state = p_mission_state
	return result
