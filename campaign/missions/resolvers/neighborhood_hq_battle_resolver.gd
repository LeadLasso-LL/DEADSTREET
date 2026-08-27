class_name NeighborhoodHQBattleResolver
extends RefCounted

const NeighborhoodHQBattleResult := preload("res://campaign/missions/resolvers/neighborhood_hq_battle_result.gd")
const NeighborhoodHQCaptureResult := preload("res://campaign/missions/resolvers/neighborhood_hq_capture_result.gd")
const NeighborhoodHQCaptureResolver := preload("res://campaign/missions/resolvers/neighborhood_hq_capture_resolver.gd")
const NeighborhoodHQAttackFailureResult := preload("res://campaign/missions/resolvers/neighborhood_hq_attack_failure_result.gd")
const NeighborhoodHQAttackFailureResolver := preload("res://campaign/missions/resolvers/neighborhood_hq_attack_failure_resolver.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")


static func resolve(
	game_state: GameState,
	mission_id: String,
	attacker_won: bool
) -> NeighborhoodHQBattleResult:
	if attacker_won:
		var capture_result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(
			game_state,
			mission_id
		)
		return _from_capture_result(game_state, capture_result, attacker_won)
	var failure_result: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResolver.resolve_failure(
		game_state,
		mission_id
	)
	return _from_failure_result(game_state, failure_result, attacker_won)


static func _from_capture_result(
	game_state: GameState,
	capture_result: NeighborhoodHQCaptureResult,
	attacker_won: bool
) -> NeighborhoodHQBattleResult:
	var mission_fields: Dictionary = _mission_fields(game_state, capture_result.mission_id)
	var mission_state: String = str(mission_fields.get("mission_state", ""))
	var outcome_code: String = str(mission_fields.get("outcome_code", ""))
	if capture_result.success:
		if mission_state.is_empty():
			mission_state = "resolved_success"
		if outcome_code.is_empty():
			outcome_code = "neighborhood_hq_captured"
		return NeighborhoodHQBattleResult.succeeded(
			true,
			capture_result.mission_id,
			capture_result.force_id,
			capture_result.neighborhood_id,
			capture_result.hq_location_id,
			capture_result.attacker_faction_id,
			capture_result.defender_faction_id,
			mission_state,
			outcome_code,
			capture_result.businesses_unclaimed
		)
	return NeighborhoodHQBattleResult.failed(
		capture_result.error_code,
		capture_result.error_message,
		attacker_won,
		capture_result.mission_id,
		capture_result.force_id,
		capture_result.neighborhood_id,
		capture_result.hq_location_id,
		capture_result.attacker_faction_id,
		capture_result.defender_faction_id,
		mission_state,
		outcome_code
	)


static func _from_failure_result(
	game_state: GameState,
	failure_result: NeighborhoodHQAttackFailureResult,
	attacker_won: bool
) -> NeighborhoodHQBattleResult:
	var mission_fields: Dictionary = _mission_fields(game_state, failure_result.mission_id)
	var mission_state: String = str(mission_fields.get("mission_state", ""))
	var outcome_code: String = str(mission_fields.get("outcome_code", ""))
	var empty_unclaimed: Array[String] = []
	if failure_result.success:
		if mission_state.is_empty():
			mission_state = "resolved_failure"
		if outcome_code.is_empty():
			outcome_code = "neighborhood_hq_assault_failed"
		return NeighborhoodHQBattleResult.succeeded(
			false,
			failure_result.mission_id,
			failure_result.force_id,
			failure_result.neighborhood_id,
			failure_result.hq_location_id,
			failure_result.attacker_faction_id,
			failure_result.defender_faction_id,
			mission_state,
			outcome_code,
			empty_unclaimed
		)
	return NeighborhoodHQBattleResult.failed(
		failure_result.error_code,
		failure_result.error_message,
		attacker_won,
		failure_result.mission_id,
		failure_result.force_id,
		failure_result.neighborhood_id,
		failure_result.hq_location_id,
		failure_result.attacker_faction_id,
		failure_result.defender_faction_id,
		mission_state,
		outcome_code
	)


static func _mission_fields(game_state: GameState, mission_id: String) -> Dictionary:
	var fields: Dictionary = {
		"mission_state": "",
		"outcome_code": "",
	}
	if game_state == null or mission_id.is_empty():
		return fields
	if not game_state.has_mission(mission_id):
		return fields
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission == null:
		return fields
	fields["mission_state"] = mission.mission_state
	fields["outcome_code"] = mission.outcome_code
	return fields
