class_name BattleRuntimeResult
extends RefCounted

var success: bool = false
var delta_seconds: float = 0.0
var elapsed_time_before: float = 0.0
var elapsed_time_after: float = 0.0
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_delta_seconds: float,
	p_elapsed_time_before: float,
	p_elapsed_time_after: float
) -> BattleRuntimeResult:
	var result: BattleRuntimeResult = BattleRuntimeResult.new()
	result.success = true
	result.delta_seconds = p_delta_seconds
	result.elapsed_time_before = p_elapsed_time_before
	result.elapsed_time_after = p_elapsed_time_after
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_delta_seconds: float = 0.0,
	p_elapsed_time_before: float = 0.0
) -> BattleRuntimeResult:
	var result: BattleRuntimeResult = BattleRuntimeResult.new()
	result.success = false
	result.delta_seconds = p_delta_seconds
	result.elapsed_time_before = p_elapsed_time_before
	result.elapsed_time_after = p_elapsed_time_before
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
