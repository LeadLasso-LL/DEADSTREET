class_name BattleCampaignOutcomeBridgeResult
extends RefCounted

const OUTCOME_ATTACKER_VICTORY_APPLIED := "attacker_victory_applied"
const OUTCOME_DEFENDER_VICTORY_APPLIED := "defender_victory_applied"
const OUTCOME_DRAW_UNSUPPORTED := "draw_unsupported"
const OUTCOME_UNSUPPORTED_BATTLE_SOURCE := "unsupported_battle_source"
const OUTCOME_ALREADY_APPLIED := "already_applied"

var success: bool = false
var applied: bool = false
var outcome_kind: String = ""
var error_code: String = ""
var error_message: String = ""
var mission_id: String = ""


static func applied_outcome(
	p_outcome_kind: String,
	p_mission_id: String
) -> BattleCampaignOutcomeBridgeResult:
	var result := new()
	result.success = true
	result.applied = true
	result.outcome_kind = p_outcome_kind
	result.error_code = ""
	result.error_message = ""
	result.mission_id = p_mission_id
	return result


static func acknowledged(
	p_outcome_kind: String,
	p_mission_id: String = ""
) -> BattleCampaignOutcomeBridgeResult:
	var result := new()
	result.success = true
	result.applied = false
	result.outcome_kind = p_outcome_kind
	result.error_code = ""
	result.error_message = ""
	result.mission_id = p_mission_id
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = ""
) -> BattleCampaignOutcomeBridgeResult:
	var result := new()
	result.success = false
	result.applied = false
	result.outcome_kind = ""
	result.error_code = p_error_code
	result.error_message = p_error_message
	result.mission_id = p_mission_id
	return result
