class_name BattleForceCommandResult
extends RefCounted

var success: bool = false
var tactical_force_id: String = ""
var previous_command_id: String = ""
var command_id: String = ""
var rejection_reason: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_tactical_force_id: String,
	p_previous_command_id: String,
	p_command_id: String
) -> BattleForceCommandResult:
	var result: BattleForceCommandResult = BattleForceCommandResult.new()
	result.success = true
	result.tactical_force_id = p_tactical_force_id
	result.previous_command_id = p_previous_command_id
	result.command_id = p_command_id
	result.rejection_reason = ""
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_rejection_reason: String,
	p_error_message: String,
	p_tactical_force_id: String = "",
	p_previous_command_id: String = "",
	p_command_id: String = ""
) -> BattleForceCommandResult:
	var result: BattleForceCommandResult = BattleForceCommandResult.new()
	result.success = false
	result.tactical_force_id = p_tactical_force_id
	result.previous_command_id = p_previous_command_id
	result.command_id = p_command_id
	result.rejection_reason = p_rejection_reason
	result.error_code = p_rejection_reason
	result.error_message = p_error_message
	return result
