class_name BattleTargetSelectionResult
extends RefCounted

var success: bool = false
var participants_considered: int = 0
var participants_with_hostiles: int = 0
var participants_with_targets: int = 0
var targets_changed: int = 0
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_participants_considered: int,
	p_participants_with_hostiles: int,
	p_participants_with_targets: int,
	p_targets_changed: int
) -> BattleTargetSelectionResult:
	var result: BattleTargetSelectionResult = BattleTargetSelectionResult.new()
	result.success = true
	result.participants_considered = p_participants_considered
	result.participants_with_hostiles = p_participants_with_hostiles
	result.participants_with_targets = p_participants_with_targets
	result.targets_changed = p_targets_changed
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleTargetSelectionResult:
	var result: BattleTargetSelectionResult = BattleTargetSelectionResult.new()
	result.success = false
	result.participants_considered = 0
	result.participants_with_hostiles = 0
	result.participants_with_targets = 0
	result.targets_changed = 0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
