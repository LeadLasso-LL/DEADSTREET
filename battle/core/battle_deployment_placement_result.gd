class_name BattleDeploymentPlacementResult
extends RefCounted

var success: bool = false
var participant_id: String = ""
var position: Vector2 = Vector2.ZERO
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_participant_id: String, p_position: Vector2) -> BattleDeploymentPlacementResult:
	var result: BattleDeploymentPlacementResult = BattleDeploymentPlacementResult.new()
	result.success = true
	result.participant_id = p_participant_id
	result.position = p_position
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_participant_id: String = "",
	p_position: Vector2 = Vector2.ZERO
) -> BattleDeploymentPlacementResult:
	var result: BattleDeploymentPlacementResult = BattleDeploymentPlacementResult.new()
	result.success = false
	result.participant_id = p_participant_id
	result.position = p_position
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
