class_name BattleSetupResult
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")

var success: bool = false
var battle_state: BattleState = null
var battle_id: String = ""
var mission_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_battle_state: BattleState) -> BattleSetupResult:
	var result: BattleSetupResult = BattleSetupResult.new()
	result.success = true
	result.battle_state = p_battle_state
	if p_battle_state != null:
		result.battle_id = p_battle_state.battle_id
		result.mission_id = p_battle_state.mission_id
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = "",
	p_battle_id: String = ""
) -> BattleSetupResult:
	var result: BattleSetupResult = BattleSetupResult.new()
	result.success = false
	result.battle_state = null
	result.battle_id = p_battle_id
	result.mission_id = p_mission_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
