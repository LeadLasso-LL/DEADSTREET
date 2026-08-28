class_name BattleMovementResult
extends RefCounted

var success: bool = false
var delta_seconds: float = 0.0
var participants_considered: int = 0
var participants_moved: int = 0
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_delta_seconds: float,
	p_participants_considered: int,
	p_participants_moved: int
) -> BattleMovementResult:
	var result: BattleMovementResult = BattleMovementResult.new()
	result.success = true
	result.delta_seconds = p_delta_seconds
	result.participants_considered = p_participants_considered
	result.participants_moved = p_participants_moved
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_delta_seconds: float = 0.0
) -> BattleMovementResult:
	var result: BattleMovementResult = BattleMovementResult.new()
	result.success = false
	result.delta_seconds = p_delta_seconds
	result.participants_considered = 0
	result.participants_moved = 0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
