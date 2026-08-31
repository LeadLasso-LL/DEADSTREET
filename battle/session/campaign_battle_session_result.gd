class_name CampaignBattleSessionResult
extends RefCounted

var success: bool = false
var session: CampaignBattleSession = null
var session_state: String = ""
var battle_phase: String = ""
var battle_resolved_this_call: bool = false
var campaign_outcome_applied: bool = false
var outcome_kind: String = ""
var mission_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_session: CampaignBattleSession,
	p_battle_resolved_this_call: bool = false,
	p_campaign_outcome_applied: bool = false,
	p_outcome_kind: String = ""
) -> CampaignBattleSessionResult:
	var result: CampaignBattleSessionResult = CampaignBattleSessionResult.new()
	result.success = true
	result.session = p_session
	result.battle_resolved_this_call = p_battle_resolved_this_call
	result.campaign_outcome_applied = p_campaign_outcome_applied
	result.outcome_kind = p_outcome_kind
	result.error_code = ""
	result.error_message = ""
	result._copy_session_telemetry(p_session)
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_session: CampaignBattleSession = null,
	p_mission_id: String = "",
	p_battle_resolved_this_call: bool = false,
	p_campaign_outcome_applied: bool = false,
	p_outcome_kind: String = ""
) -> CampaignBattleSessionResult:
	var result: CampaignBattleSessionResult = CampaignBattleSessionResult.new()
	result.success = false
	result.session = p_session
	result.battle_resolved_this_call = p_battle_resolved_this_call
	result.campaign_outcome_applied = p_campaign_outcome_applied
	result.outcome_kind = p_outcome_kind
	result.error_code = p_error_code
	result.error_message = p_error_message
	if p_session != null:
		result._copy_session_telemetry(p_session)
	else:
		result.mission_id = p_mission_id
	return result


func _copy_session_telemetry(p_session: CampaignBattleSession) -> void:
	if p_session == null:
		return
	session_state = p_session.session_state
	mission_id = p_session.mission_id
	if p_session.battle_state != null:
		battle_phase = p_session.battle_state.battle_phase
	else:
		battle_phase = ""
