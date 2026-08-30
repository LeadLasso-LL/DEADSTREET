class_name BattleCombatPressureResult
extends RefCounted

var success: bool = false
var participants_considered: int = 0
var snapshots_updated: int = 0
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_participants_considered: int, p_snapshots_updated: int) -> BattleCombatPressureResult:
	var result: BattleCombatPressureResult = BattleCombatPressureResult.new()
	result.success = true
	result.participants_considered = p_participants_considered
	result.snapshots_updated = p_snapshots_updated
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleCombatPressureResult:
	var result: BattleCombatPressureResult = BattleCombatPressureResult.new()
	result.success = false
	result.participants_considered = 0
	result.snapshots_updated = 0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
