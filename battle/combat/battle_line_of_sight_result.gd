class_name BattleLineOfSightResult
extends RefCounted

var success: bool = false
var has_line_of_sight: bool = false
var source_participant_id: String = ""
var target_participant_id: String = ""
var blocking_obstacle_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_has_line_of_sight: bool,
	p_source_participant_id: String = "",
	p_target_participant_id: String = "",
	p_blocking_obstacle_id: String = ""
) -> BattleLineOfSightResult:
	var result: BattleLineOfSightResult = BattleLineOfSightResult.new()
	result.success = true
	result.has_line_of_sight = p_has_line_of_sight
	result.source_participant_id = p_source_participant_id
	result.target_participant_id = p_target_participant_id
	result.blocking_obstacle_id = p_blocking_obstacle_id
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_source_participant_id: String = "",
	p_target_participant_id: String = ""
) -> BattleLineOfSightResult:
	var result: BattleLineOfSightResult = BattleLineOfSightResult.new()
	result.success = false
	result.has_line_of_sight = false
	result.source_participant_id = p_source_participant_id
	result.target_participant_id = p_target_participant_id
	result.blocking_obstacle_id = ""
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
