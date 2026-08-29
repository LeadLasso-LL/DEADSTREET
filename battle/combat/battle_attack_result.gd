class_name BattleAttackResult
extends RefCounted

const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")

var success: bool = false
var shot_executed: bool = false
var attack_event: BattleAttackEvent = null
var rejection_code: String = ""
var error_code: String = ""
var error_message: String = ""


static func executed(p_attack_event: BattleAttackEvent) -> BattleAttackResult:
	var result := new()
	result.success = true
	result.shot_executed = true
	result.attack_event = p_attack_event
	result.rejection_code = ""
	result.error_code = ""
	result.error_message = ""
	return result


static func rejected(p_rejection_code: String) -> BattleAttackResult:
	var result := new()
	result.success = true
	result.shot_executed = false
	result.attack_event = null
	result.rejection_code = p_rejection_code
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleAttackResult:
	var result := new()
	result.success = false
	result.shot_executed = false
	result.attack_event = null
	result.rejection_code = ""
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
