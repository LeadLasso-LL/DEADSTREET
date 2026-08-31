class_name CampaignBattleSessionService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleSetupService := preload("res://battle/core/battle_setup_service.gd")
const BattleSetupResult := preload("res://battle/core/battle_setup_result.gd")
const BattlefieldGeometryService := preload("res://battle/geometry/battlefield_geometry_service.gd")
const BattlefieldGeometryResult := preload("res://battle/geometry/battlefield_geometry_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const CampaignBattleSessionResult := preload("res://battle/session/campaign_battle_session_result.gd")

const MISSION_TYPE_CAPTURE_HQ := "capture_neighborhood_hq"
const BATTLE_TYPE_HQ_ASSAULT := "neighborhood_hq_assault"


static func create_for_mission(
	game_state: GameState,
	mission_id: String
) -> CampaignBattleSessionResult:
	if game_state == null:
		return CampaignBattleSessionResult.failed(
			"null_game_state",
			"Campaign battle session failed: game_state is null."
		)
	if mission_id.is_empty():
		return CampaignBattleSessionResult.failed(
			"empty_mission_id",
			"Campaign battle session failed: mission_id is empty."
		)
	if not game_state.has_mission(mission_id):
		return CampaignBattleSessionResult.failed(
			"invalid_mission",
			"Campaign battle session failed: mission '%s' does not exist." % mission_id,
			null,
			mission_id
		)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission == null:
		return CampaignBattleSessionResult.failed(
			"invalid_mission",
			"Campaign battle session failed: mission '%s' does not exist." % mission_id,
			null,
			mission_id
		)
	if mission.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return CampaignBattleSessionResult.failed(
			"invalid_mission_type",
			"Campaign battle session failed: mission '%s' type is '%s', not capture_neighborhood_hq."
			% [mission.id, mission.mission_type_id],
			null,
			mission.id
		)
	if mission.mission_state != "awaiting_resolution":
		return CampaignBattleSessionResult.failed(
			"mission_not_awaiting_resolution",
			"Campaign battle session failed: mission '%s' is '%s', not awaiting_resolution."
			% [mission.id, mission.mission_state],
			null,
			mission.id
		)

	var setup_result: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(
		game_state,
		mission.id
	)
	if setup_result == null or not setup_result.success or setup_result.battle_state == null:
		var error_code: String = "battle_insert_failed"
		var error_message: String = "Campaign battle session failed: battle setup did not succeed."
		if setup_result != null:
			if not setup_result.error_code.is_empty():
				error_code = setup_result.error_code
			if not setup_result.error_message.is_empty():
				error_message = setup_result.error_message
		return CampaignBattleSessionResult.failed(error_code, error_message, null, mission.id)

	var battle_state: BattleState = setup_result.battle_state
	if battle_state.battle_type_id != BATTLE_TYPE_HQ_ASSAULT:
		return CampaignBattleSessionResult.failed(
			"unsupported_battle_source",
			"Campaign battle session failed: battle type '%s' is not neighborhood_hq_assault."
			% battle_state.battle_type_id,
			null,
			mission.id
		)
	if battle_state.battle_phase != "deployment":
		return CampaignBattleSessionResult.failed(
			"battle_not_in_deployment",
			"Campaign battle session failed: created battle phase is '%s', not deployment."
			% battle_state.battle_phase,
			null,
			mission.id
		)

	# Provisional default geometry is required for spatial readiness / begin_battle.
	# Called before any deployment so no participants or vehicles are placed.
	# This is not campaign-location battlefield generation.
	var geometry_result: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
		battle_state
	)
	if geometry_result == null or not geometry_result.success:
		var geometry_error_code: String = "invalid_geometry"
		var geometry_error_message: String = "Campaign battle session failed: default geometry initialization did not succeed."
		if geometry_result != null:
			if not geometry_result.error_code.is_empty():
				geometry_error_code = geometry_result.error_code
			if not geometry_result.error_message.is_empty():
				geometry_error_message = geometry_result.error_message
		return CampaignBattleSessionResult.failed(
			geometry_error_code,
			geometry_error_message,
			null,
			mission.id
		)

	var session: CampaignBattleSession = CampaignBattleSession.new()
	session.configure(game_state, mission.id, battle_state)
	return CampaignBattleSessionResult.succeeded(session)
