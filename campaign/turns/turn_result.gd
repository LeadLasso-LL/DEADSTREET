class_name TurnResult
extends RefCounted

const ForceTurnResult := preload("res://campaign/turns/force_turn_result.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")

var success: bool = false
var turn_before: int = 0
var turn_after: int = 0
var error_code: String = ""
var error_message: String = ""
var force_results: Array[ForceTurnResult] = []
var mission_results: Array[MissionResult] = []


static func succeeded(
	p_turn_before: int,
	p_turn_after: int,
	p_force_results: Array[ForceTurnResult],
	p_mission_results: Array[MissionResult]
) -> TurnResult:
	var result: TurnResult = TurnResult.new()
	result.success = true
	result.turn_before = p_turn_before
	result.turn_after = p_turn_after
	result.error_code = ""
	result.error_message = ""
	for force_result: ForceTurnResult in p_force_results:
		result.force_results.append(force_result)
	for mission_result: MissionResult in p_mission_results:
		result.mission_results.append(mission_result)
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_turn_before: int = 0,
	p_turn_after: int = 0
) -> TurnResult:
	var result: TurnResult = TurnResult.new()
	result.success = false
	result.turn_before = p_turn_before
	result.turn_after = p_turn_after
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
