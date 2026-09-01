class_name BattleDeploymentCommitResult
extends RefCounted

var success: bool = false
var side_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_side_id: String):
	var result = new()
	result.success = true
	result.side_id = p_side_id
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String, p_side_id: String = ""):
	var result = new()
	result.success = false
	result.side_id = p_side_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
