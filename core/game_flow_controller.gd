class_name GameFlowController
extends RefCounted

const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const CampaignBattleSessionService := preload("res://battle/session/campaign_battle_session_service.gd")
const CampaignBattleSessionResult := preload("res://battle/session/campaign_battle_session_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const TurnManager := preload("res://campaign/turns/turn_manager.gd")
const TurnResult := preload("res://campaign/turns/turn_result.gd")
const BusinessEconomyCatalog := preload("res://campaign/economy/business_economy_catalog.gd")
const BattleState := preload("res://battle/core/battle_state.gd")

const MODE_CAMPAIGN := "campaign"
const MODE_TACTICAL_DEPLOYMENT := "tactical_deployment"
const MODE_TACTICAL_ACTIVE := "tactical_active"
const MODE_TACTICAL_PENDING_HANDOFF := "tactical_pending_handoff"

const MISSION_TYPE_CAPTURE_HQ := "capture_neighborhood_hq"
const CONTROLLER_PLAYER := "player"

# Reference to campaign authority. Not a copy and not ownership of registries.
var game_state: GameState = null
# V1 player-flow binding. Auto-filled when exactly one MajorGang has controller_type == "player".
var player_faction_id: String = ""
# Optional current tactical excursion. CampaignBattleSession remains owner of BattleState.
var current_session: CampaignBattleSession = null


static func create(
	p_game_state: GameState,
	p_player_faction_id: String = ""
) -> GameFlowResult:
	if p_game_state == null:
		return GameFlowResult.failed(
			"null_game_state",
			"Game flow failed: game_state is null."
		)
	if not p_player_faction_id.is_empty() and not p_game_state.has_faction(p_player_faction_id):
		return GameFlowResult.failed(
			"invalid_player_faction",
			"Game flow failed: player faction '%s' does not exist." % p_player_faction_id
		)
	var controller: GameFlowController = GameFlowController.new()
	controller.game_state = p_game_state
	controller.current_session = null
	if p_player_faction_id.is_empty():
		controller.player_faction_id = controller._auto_bind_player_faction_id()
	else:
		controller.player_faction_id = p_player_faction_id
	return GameFlowResult.succeeded(controller)


func get_current_mode() -> String:
	if current_session == null:
		return MODE_CAMPAIGN
	match current_session.session_state:
		CampaignBattleSession.SESSION_DEPLOYMENT:
			return MODE_TACTICAL_DEPLOYMENT
		CampaignBattleSession.SESSION_ACTIVE:
			return MODE_TACTICAL_ACTIVE
		CampaignBattleSession.SESSION_RESOLVED_PENDING_HANDOFF:
			return MODE_TACTICAL_PENDING_HANDOFF
		_:
			return MODE_CAMPAIGN


func is_campaign_mode() -> bool:
	return get_current_mode() == MODE_CAMPAIGN


func has_active_session() -> bool:
	return current_session != null


func get_battle_state() -> BattleState:
	if current_session == null:
		return null
	return current_session.battle_state


func list_pending_battle_ids() -> Array[String]:
	var pending: Array[String] = []
	if game_state == null:
		return pending
	var candidate_faction_ids: Array[String] = _candidate_player_faction_ids()
	if candidate_faction_ids.is_empty():
		return pending
	var current_mission_id: String = ""
	if current_session != null:
		current_mission_id = current_session.mission_id
	for mission_id: String in game_state.missions:
		if not current_mission_id.is_empty() and mission_id == current_mission_id:
			continue
		if not _is_supported_pending_player_battle(mission_id, candidate_faction_ids):
			continue
		pending.append(mission_id)
	pending.sort()
	return pending


func advance_campaign_turn(
	business_catalog: BusinessEconomyCatalog = null
) -> GameFlowResult:
	if game_state == null:
		return _fail(
			"null_game_state",
			"Game flow failed: game_state is null."
		)
	if current_session != null:
		return _fail(
			"tactical_session_active",
			"Game flow failed: campaign turn cannot advance while a tactical session is active."
		)
	var turn_result: TurnResult = TurnManager.advance_to_next_turn(game_state, business_catalog)
	if turn_result == null or not turn_result.success:
		var error_code: String = "turn_advancement_failed"
		var error_message: String = "Game flow failed: campaign turn advancement did not succeed."
		if turn_result != null:
			if not turn_result.error_code.is_empty():
				error_code = turn_result.error_code
			if not turn_result.error_message.is_empty():
				error_message = turn_result.error_message
		return _fail(error_code, error_message)
	return _ok()


func enter_pending_battle(mission_id: String = "") -> GameFlowResult:
	if game_state == null:
		return _fail(
			"null_game_state",
			"Game flow failed: game_state is null."
		)
	if current_session != null:
		return _fail(
			"session_already_active",
			"Game flow failed: a tactical session is already active."
		)
	var pending_ids: Array[String] = list_pending_battle_ids()
	var target_mission_id: String = mission_id
	if target_mission_id.is_empty():
		if pending_ids.is_empty():
			return _fail(
				"no_pending_battle",
				"Game flow failed: there is no pending player HQ battle awaiting resolution."
			)
		if pending_ids.size() > 1:
			return _fail(
				"multiple_pending_battles",
				"Game flow failed: multiple pending player HQ battles exist; pass a mission_id."
			)
		target_mission_id = pending_ids[0]
	var ownership_error: GameFlowResult = _reject_if_not_enterable(target_mission_id)
	if ownership_error != null:
		return ownership_error
	var session_result: CampaignBattleSessionResult = CampaignBattleSessionService.create_for_mission(
		game_state,
		target_mission_id
	)
	if session_result == null or not session_result.success or session_result.session == null:
		var error_code: String = "battle_insert_failed"
		var error_message: String = "Game flow failed: campaign battle session could not be created."
		if session_result != null:
			if not session_result.error_code.is_empty():
				error_code = session_result.error_code
			if not session_result.error_message.is_empty():
				error_message = session_result.error_message
		return _fail(error_code, error_message)
	current_session = session_result.session
	var result: GameFlowResult = _ok()
	result.entered_mission_id = current_session.mission_id
	return result


func begin_current_battle() -> GameFlowResult:
	if current_session == null:
		return _fail(
			"no_active_session",
			"Game flow failed: there is no active tactical session."
		)
	var session_result: CampaignBattleSessionResult = current_session.begin_battle()
	return _from_session_result(session_result, false)


func advance_tactical(delta_seconds: float) -> GameFlowResult:
	if current_session == null:
		return _fail(
			"no_active_session",
			"Game flow failed: there is no active tactical session."
		)
	var session_result: CampaignBattleSessionResult = current_session.advance_tactical(delta_seconds)
	if (
		current_session.session_state == CampaignBattleSession.SESSION_COMPLETE
	):
		return _return_to_campaign_after_completion(session_result)
	return _from_session_result(session_result, false)


func _return_to_campaign_after_completion(
	session_result: CampaignBattleSessionResult
) -> GameFlowResult:
	var result: GameFlowResult = _from_session_result(session_result, true)
	result.current_mode = MODE_CAMPAIGN
	current_session = null
	result.pending_battle_ids = list_pending_battle_ids()
	return result


func _from_session_result(
	session_result: CampaignBattleSessionResult,
	p_battle_completed_this_call: bool
) -> GameFlowResult:
	var result: GameFlowResult
	if session_result != null and session_result.success:
		result = _ok()
	else:
		var error_code: String = "tactical_operation_failed"
		var error_message: String = "Game flow failed: tactical session operation did not succeed."
		if session_result != null:
			if not session_result.error_code.is_empty():
				error_code = session_result.error_code
			if not session_result.error_message.is_empty():
				error_message = session_result.error_message
		result = _fail(error_code, error_message)
	result.battle_completed_this_call = p_battle_completed_this_call
	if session_result != null:
		result.outcome_kind = session_result.outcome_kind
		if result.entered_mission_id.is_empty():
			result.mission_id = session_result.mission_id
	return result


func _ok() -> GameFlowResult:
	return GameFlowResult.succeeded(self)


func _fail(p_error_code: String, p_error_message: String) -> GameFlowResult:
	return GameFlowResult.failed(p_error_code, p_error_message, self)


func _reject_if_not_enterable(mission_id: String) -> GameFlowResult:
	if mission_id.is_empty():
		return _fail(
			"empty_mission_id",
			"Game flow failed: mission_id is empty."
		)
	if not game_state.has_mission(mission_id):
		return _fail(
			"invalid_mission",
			"Game flow failed: mission '%s' does not exist." % mission_id
		)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission == null:
		return _fail(
			"invalid_mission",
			"Game flow failed: mission '%s' does not exist." % mission_id
		)
	if mission.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return _fail(
			"invalid_mission_type",
			"Game flow failed: mission '%s' type is '%s', not capture_neighborhood_hq."
			% [mission.id, mission.mission_type_id]
		)
	if mission.mission_state != "awaiting_resolution":
		return _fail(
			"mission_not_awaiting_resolution",
			"Game flow failed: mission '%s' is '%s', not awaiting_resolution."
			% [mission.id, mission.mission_state]
		)
	if not _faction_is_player_owned(mission.faction_id):
		return _fail(
			"not_player_mission",
			"Game flow failed: mission '%s' does not belong to the player-controlled faction."
			% mission.id
		)
	return null


func _is_supported_pending_player_battle(
	mission_id: String,
	candidate_faction_ids: Array[String]
) -> bool:
	if not game_state.has_mission(mission_id):
		return false
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission == null:
		return false
	if mission.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return false
	if mission.mission_state != "awaiting_resolution":
		return false
	if mission.faction_id.is_empty():
		return false
	return candidate_faction_ids.has(mission.faction_id)


func _faction_is_player_owned(faction_id: String) -> bool:
	if faction_id.is_empty():
		return false
	var candidate_faction_ids: Array[String] = _candidate_player_faction_ids()
	return candidate_faction_ids.has(faction_id)


func _candidate_player_faction_ids() -> Array[String]:
	if not player_faction_id.is_empty():
		var bound: Array[String] = []
		bound.append(player_faction_id)
		return bound
	return _collect_player_faction_ids()


func _auto_bind_player_faction_id() -> String:
	var player_ids: Array[String] = _collect_player_faction_ids()
	if player_ids.size() == 1:
		return player_ids[0]
	return ""


func _collect_player_faction_ids() -> Array[String]:
	var player_ids: Array[String] = []
	if game_state == null:
		return player_ids
	for faction_id: String in game_state.factions:
		var faction: Faction = game_state.get_faction(faction_id)
		if faction == null:
			continue
		if not (faction is MajorGang):
			continue
		var gang: MajorGang = faction as MajorGang
		if gang.controller_type == CONTROLLER_PLAYER:
			player_ids.append(faction_id)
	player_ids.sort()
	return player_ids
