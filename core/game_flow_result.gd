class_name GameFlowResult
extends RefCounted

var success: bool = false
var controller: GameFlowController = null
var current_mode: String = ""
var pending_battle_ids: Array[String] = []
var entered_mission_id: String = ""
var mission_id: String = ""
var session: CampaignBattleSession = null
var session_state: String = ""
var battle_phase: String = ""
var battle_completed_this_call: bool = false
var outcome_kind: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_controller: GameFlowController) -> GameFlowResult:
	var result: GameFlowResult = GameFlowResult.new()
	result.success = true
	result.controller = p_controller
	result.error_code = ""
	result.error_message = ""
	result._copy_controller_telemetry(p_controller)
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_controller: GameFlowController = null
) -> GameFlowResult:
	var result: GameFlowResult = GameFlowResult.new()
	result.success = false
	result.controller = p_controller
	result.error_code = p_error_code
	result.error_message = p_error_message
	result._copy_controller_telemetry(p_controller)
	return result


func _copy_controller_telemetry(p_controller: GameFlowController) -> void:
	if p_controller == null:
		return
	current_mode = p_controller.get_current_mode()
	pending_battle_ids = p_controller.list_pending_battle_ids()
	session = p_controller.current_session
	if session == null:
		mission_id = ""
		session_state = ""
		battle_phase = ""
		return
	mission_id = session.mission_id
	session_state = session.session_state
	if session.battle_state != null:
		battle_phase = session.battle_state.battle_phase
	else:
		battle_phase = ""
