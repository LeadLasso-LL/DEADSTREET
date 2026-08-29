class_name BattleFireControlResult
extends RefCounted

var success: bool = false
var participants_considered: int = 0
var participants_with_targets: int = 0
var participants_eligible_to_fire: int = 0
var participants_blocked_by_los: int = 0
var participants_blocked_by_range: int = 0
var participants_blocked_by_cooldown: int = 0
var participants_reloading: int = 0
var participants_empty: int = 0
var error_code: String = ""
var error_message: String = ""
var can_fire: bool = false
var rejection_code: String = ""
var source_participant_id: String = ""
var target_participant_id: String = ""


static func succeeded(
	p_participants_considered: int,
	p_participants_with_targets: int = 0,
	p_participants_eligible_to_fire: int = 0,
	p_participants_blocked_by_los: int = 0,
	p_participants_blocked_by_range: int = 0,
	p_participants_blocked_by_cooldown: int = 0,
	p_participants_reloading: int = 0,
	p_participants_empty: int = 0
) -> BattleFireControlResult:
	var result := new()
	result.success = true
	result.participants_considered = p_participants_considered
	result.participants_with_targets = p_participants_with_targets
	result.participants_eligible_to_fire = p_participants_eligible_to_fire
	result.participants_blocked_by_los = p_participants_blocked_by_los
	result.participants_blocked_by_range = p_participants_blocked_by_range
	result.participants_blocked_by_cooldown = p_participants_blocked_by_cooldown
	result.participants_reloading = p_participants_reloading
	result.participants_empty = p_participants_empty
	result.error_code = ""
	result.error_message = ""
	return result


static func pair_eligible(
	p_source_participant_id: String,
	p_target_participant_id: String
) -> BattleFireControlResult:
	var result := new()
	result.success = true
	result.can_fire = true
	result.source_participant_id = p_source_participant_id
	result.target_participant_id = p_target_participant_id
	result.rejection_code = ""
	result.error_code = ""
	result.error_message = ""
	return result


static func pair_rejected(
	p_rejection_code: String,
	p_source_participant_id: String = "",
	p_target_participant_id: String = ""
) -> BattleFireControlResult:
	var result := new()
	result.success = true
	result.can_fire = false
	result.source_participant_id = p_source_participant_id
	result.target_participant_id = p_target_participant_id
	result.rejection_code = p_rejection_code
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleFireControlResult:
	var result := new()
	result.success = false
	result.participants_considered = 0
	result.participants_with_targets = 0
	result.participants_eligible_to_fire = 0
	result.participants_blocked_by_los = 0
	result.participants_blocked_by_range = 0
	result.participants_blocked_by_cooldown = 0
	result.participants_reloading = 0
	result.participants_empty = 0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
