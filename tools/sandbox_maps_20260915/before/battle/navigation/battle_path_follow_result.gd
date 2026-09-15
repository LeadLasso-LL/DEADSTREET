class_name BattlePathFollowResult
extends RefCounted

var success: bool = false
var participants_considered: int = 0
var participants_with_paths: int = 0
var participants_completed_paths: int = 0
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_participants_considered: int,
	p_participants_with_paths: int,
	p_participants_completed_paths: int
) -> BattlePathFollowResult:
	var result: BattlePathFollowResult = BattlePathFollowResult.new()
	result.success = true
	result.participants_considered = p_participants_considered
	result.participants_with_paths = p_participants_with_paths
	result.participants_completed_paths = p_participants_completed_paths
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattlePathFollowResult:
	var result: BattlePathFollowResult = BattlePathFollowResult.new()
	result.success = false
	result.participants_considered = 0
	result.participants_with_paths = 0
	result.participants_completed_paths = 0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
