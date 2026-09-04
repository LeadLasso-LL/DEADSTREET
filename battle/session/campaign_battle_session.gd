class_name CampaignBattleSession
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleRuntimeService := preload("res://battle/runtime/battle_runtime_service.gd")
const BattleRuntimeResult := preload("res://battle/runtime/battle_runtime_result.gd")
const BattleCampaignOutcomeBridgeService := preload("res://battle/core/battle_campaign_outcome_bridge_service.gd")
const BattleCampaignOutcomeBridgeResult := preload("res://battle/core/battle_campaign_outcome_bridge_result.gd")

const SESSION_DEPLOYMENT := "deployment"
const SESSION_ACTIVE := "active"
const SESSION_RESOLVED_PENDING_HANDOFF := "resolved_pending_handoff"
const SESSION_COMPLETE := "complete"

# Presentation hold after BattleState is resolved. Not tactical simulation time.
const RESULT_PRESENTATION_HOLD_SECONDS := 3.0

# Reference to campaign authority. Not ownership of campaign registries.
var game_state: GameState = null
var mission_id: String = ""
# Temporary tactical excursion owned by this session. Not stored on GameState.
var battle_state: BattleState = null
var session_state: String = ""
var campaign_handoff_applied: bool = false
var campaign_handoff_blocked_as_draw: bool = false
var result_presentation_elapsed_seconds: float = 0.0
var result_presentation_started: bool = false
# Debug/manual playtest only. Not campaign identity and not serialized.
var has_combat_seed_override: bool = false
var combat_seed_override: int = 0
var manual_playtest_serial: int = 0


func configure(
	p_game_state: GameState,
	p_mission_id: String,
	p_battle_state: BattleState
) -> void:
	game_state = p_game_state
	mission_id = p_mission_id
	battle_state = p_battle_state
	session_state = SESSION_DEPLOYMENT
	campaign_handoff_applied = false
	campaign_handoff_blocked_as_draw = false
	result_presentation_elapsed_seconds = 0.0
	result_presentation_started = false
	has_combat_seed_override = false
	combat_seed_override = 0
	manual_playtest_serial = 0


func has_battle() -> bool:
	return battle_state != null


func begin_battle() -> CampaignBattleSessionResult:
	if session_state == SESSION_COMPLETE:
		return _fail_without_mutation(
			"session_complete",
			"Campaign battle session failed: session is complete."
		)
	if battle_state == null:
		return _fail_without_mutation(
			"null_battle_state",
			"Campaign battle session failed: battle_state is null."
		)
	if session_state != SESSION_DEPLOYMENT or battle_state.battle_phase != "deployment":
		return _fail_without_mutation(
			"battle_not_in_deployment",
			"Campaign battle session failed: battle phase is '%s', not deployment."
			% battle_state.battle_phase
		)
	if not battle_state.is_battle_ready():
		return _fail_without_mutation(
			"deployment_incomplete",
			"Campaign battle session failed: deployment is incomplete."
		)
	if not battle_state.is_spatially_ready():
		return _fail_without_mutation(
			"battlefield_not_spatially_ready",
			"Campaign battle session failed: battlefield is not spatially ready."
		)
	if not battle_state.begin_battle():
		return _fail_without_mutation(
			"begin_battle_failed",
			"Campaign battle session failed: existing begin_battle readiness checks did not succeed."
		)
	session_state = SESSION_ACTIVE
	return CampaignBattleSessionResult.succeeded(self)


func advance_tactical(delta_seconds: float) -> CampaignBattleSessionResult:
	if session_state == SESSION_COMPLETE:
		return _fail_without_mutation(
			"session_complete",
			"Campaign battle session failed: session is complete."
		)
	if battle_state == null:
		return _fail_without_mutation(
			"null_battle_state",
			"Campaign battle session failed: battle_state is null."
		)
	if session_state == SESSION_RESOLVED_PENDING_HANDOFF:
		return _advance_resolved_presentation(delta_seconds)
	if campaign_handoff_blocked_as_draw:
		return _fail_without_mutation(
			"draw_unsupported",
			"Campaign battle session failed: tactical draw is unsupported for campaign HQ handoff.",
			false,
			BattleCampaignOutcomeBridgeResult.OUTCOME_DRAW_UNSUPPORTED
		)
	if session_state != SESSION_ACTIVE or battle_state.battle_phase != "active":
		return _fail_without_mutation(
			"battle_not_active",
			"Campaign battle session failed: battle phase is '%s', not active."
			% battle_state.battle_phase
		)
	var runtime_result: BattleRuntimeResult = BattleRuntimeService.advance(battle_state, delta_seconds)
	if runtime_result == null or not runtime_result.success:
		var error_code: String = "battle_not_active"
		var error_message: String = "Campaign battle session failed: tactical runtime did not succeed."
		if runtime_result != null:
			if not runtime_result.error_code.is_empty():
				error_code = runtime_result.error_code
			if not runtime_result.error_message.is_empty():
				error_message = runtime_result.error_message
		return _fail_without_mutation(error_code, error_message)
	if battle_state.battle_phase == "resolved":
		return _begin_resolved_presentation(runtime_result.battle_resolved_this_pass)
	return CampaignBattleSessionResult.succeeded(self)


func _begin_resolved_presentation(p_battle_resolved_this_call: bool) -> CampaignBattleSessionResult:
	session_state = SESSION_RESOLVED_PENDING_HANDOFF
	result_presentation_started = true
	result_presentation_elapsed_seconds = 0.0
	return CampaignBattleSessionResult.succeeded(self, p_battle_resolved_this_call, false, "")


func _advance_resolved_presentation(delta_seconds: float) -> CampaignBattleSessionResult:
	if campaign_handoff_applied:
		return CampaignBattleSessionResult.succeeded(
			self,
			false,
			false,
			BattleCampaignOutcomeBridgeResult.OUTCOME_ALREADY_APPLIED
		)
	if campaign_handoff_blocked_as_draw:
		return CampaignBattleSessionResult.succeeded(
			self,
			false,
			false,
			BattleCampaignOutcomeBridgeResult.OUTCOME_DRAW_UNSUPPORTED
		)
	if battle_state.battle_phase != "resolved":
		return _fail_without_mutation(
			"battle_not_active",
			"Campaign battle session failed: battle phase is '%s', not active."
			% battle_state.battle_phase
		)
	if not result_presentation_started:
		result_presentation_started = true
		result_presentation_elapsed_seconds = 0.0
	if is_finite(delta_seconds) and delta_seconds > 0.0:
		result_presentation_elapsed_seconds += delta_seconds
	if result_presentation_elapsed_seconds < RESULT_PRESENTATION_HOLD_SECONDS:
		return CampaignBattleSessionResult.succeeded(self, false, false, "")
	return _apply_campaign_handoff(false)


func _apply_campaign_handoff(p_battle_resolved_this_call: bool) -> CampaignBattleSessionResult:
	if campaign_handoff_applied or session_state == SESSION_COMPLETE:
		return CampaignBattleSessionResult.succeeded(
			self,
			p_battle_resolved_this_call,
			false,
			BattleCampaignOutcomeBridgeResult.OUTCOME_ALREADY_APPLIED
		)
	if campaign_handoff_blocked_as_draw:
		return _fail_without_mutation(
			"draw_unsupported",
			"Campaign battle session failed: tactical draw is unsupported for campaign HQ handoff.",
			p_battle_resolved_this_call,
			BattleCampaignOutcomeBridgeResult.OUTCOME_DRAW_UNSUPPORTED
		)
	var bridge_result: BattleCampaignOutcomeBridgeResult = BattleCampaignOutcomeBridgeService.apply(
		game_state,
		battle_state
	)
	if bridge_result == null:
		session_state = SESSION_RESOLVED_PENDING_HANDOFF
		return CampaignBattleSessionResult.failed(
			"campaign_resolution_failed",
			"Campaign battle session failed: campaign outcome bridge did not return a result.",
			self,
			mission_id,
			p_battle_resolved_this_call
		)
	if bridge_result.outcome_kind == BattleCampaignOutcomeBridgeResult.OUTCOME_DRAW_UNSUPPORTED:
		campaign_handoff_blocked_as_draw = true
		session_state = SESSION_RESOLVED_PENDING_HANDOFF
		return CampaignBattleSessionResult.succeeded(
			self,
			p_battle_resolved_this_call,
			false,
			bridge_result.outcome_kind
		)
	if bridge_result.applied and bridge_result.success:
		campaign_handoff_applied = true
		session_state = SESSION_COMPLETE
		return CampaignBattleSessionResult.succeeded(
			self,
			p_battle_resolved_this_call,
			true,
			bridge_result.outcome_kind
		)
	if (
		bridge_result.success
		and bridge_result.outcome_kind == BattleCampaignOutcomeBridgeResult.OUTCOME_ALREADY_APPLIED
	):
		campaign_handoff_applied = true
		session_state = SESSION_COMPLETE
		return CampaignBattleSessionResult.succeeded(
			self,
			p_battle_resolved_this_call,
			false,
			bridge_result.outcome_kind
		)
	session_state = SESSION_RESOLVED_PENDING_HANDOFF
	var error_code: String = "campaign_resolution_failed"
	var error_message: String = "Campaign battle session failed: campaign outcome bridge did not succeed."
	if not bridge_result.error_code.is_empty():
		error_code = bridge_result.error_code
	if not bridge_result.error_message.is_empty():
		error_message = bridge_result.error_message
	return CampaignBattleSessionResult.failed(
		error_code,
		error_message,
		self,
		mission_id,
		p_battle_resolved_this_call,
		false,
		bridge_result.outcome_kind
	)


func _fail_without_mutation(
	p_error_code: String,
	p_error_message: String,
	p_battle_resolved_this_call: bool = false,
	p_outcome_kind: String = ""
) -> CampaignBattleSessionResult:
	return CampaignBattleSessionResult.failed(
		p_error_code,
		p_error_message,
		self,
		mission_id,
		p_battle_resolved_this_call,
		false,
		p_outcome_kind
	)
