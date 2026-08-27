class_name DeploymentResult
extends RefCounted

var success: bool = false
var force_id: String = ""
var error_code: String = ""
var error_message: String = ""
var reached_destination: bool = false
var unused_movement: float = 0.0


static func succeeded(p_force_id: String, p_reached_destination: bool, p_unused_movement: float) -> DeploymentResult:
	var result: DeploymentResult = DeploymentResult.new()
	result.success = true
	result.force_id = p_force_id
	result.error_code = ""
	result.error_message = ""
	result.reached_destination = p_reached_destination
	result.unused_movement = p_unused_movement
	return result


static func failed(p_error_code: String, p_error_message: String, p_force_id: String = "") -> DeploymentResult:
	var result: DeploymentResult = DeploymentResult.new()
	result.success = false
	result.force_id = p_force_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	result.reached_destination = false
	result.unused_movement = 0.0
	return result
