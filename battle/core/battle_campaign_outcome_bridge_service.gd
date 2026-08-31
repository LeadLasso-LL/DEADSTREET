class_name BattleCampaignOutcomeBridgeService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleCampaignSource := preload("res://battle/core/battle_campaign_source.gd")
const BattleCampaignOutcomeBridgeResult := preload("res://battle/core/battle_campaign_outcome_bridge_result.gd")
const BattleVictoryResult := preload("res://battle/core/battle_victory_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const NeighborhoodHQBattleResolver := preload("res://campaign/missions/resolvers/neighborhood_hq_battle_resolver.gd")
const NeighborhoodHQBattleResult := preload("res://campaign/missions/resolvers/neighborhood_hq_battle_result.gd")

const SOURCE_NEIGHBORHOOD_HQ_ASSAULT := BattleCampaignSource.SOURCE_NEIGHBORHOOD_HQ_ASSAULT
const MISSION_TYPE_CAPTURE_HQ := "capture_neighborhood_hq"


static func apply(
	game_state: GameState,
	battle_state: BattleState
) -> BattleCampaignOutcomeBridgeResult:
	if game_state == null:
		return BattleCampaignOutcomeBridgeResult.failed(
			"null_game_state",
			"Battle campaign outcome bridge failed: game_state is null."
		)
	if battle_state == null:
		return BattleCampaignOutcomeBridgeResult.failed(
			"null_battle_state",
			"Battle campaign outcome bridge failed: battle_state is null."
		)
	if battle_state.battle_phase != "resolved":
		return BattleCampaignOutcomeBridgeResult.failed(
			"battle_not_resolved",
			"Battle campaign outcome bridge failed: battle phase is '%s', not resolved."
			% battle_state.battle_phase,
			battle_state.mission_id
		)
	if battle_state.tactical_result == null:
		return BattleCampaignOutcomeBridgeResult.failed(
			"missing_tactical_result",
			"Battle campaign outcome bridge failed: resolved battle is missing tactical_result.",
			battle_state.mission_id
		)
	var tactical_result: BattleVictoryResult = battle_state.tactical_result
	if not tactical_result.resolved:
		return BattleCampaignOutcomeBridgeResult.failed(
			"missing_tactical_result",
			"Battle campaign outcome bridge failed: tactical_result is not resolved.",
			battle_state.mission_id
		)

	var source: BattleCampaignSource = _campaign_source(battle_state)
	if source == null or source.source_type_id.is_empty():
		return BattleCampaignOutcomeBridgeResult.failed(
			"malformed_campaign_source",
			"Battle campaign outcome bridge failed: campaign source type is missing.",
			battle_state.mission_id
		)
	if source.source_type_id != SOURCE_NEIGHBORHOOD_HQ_ASSAULT:
		return BattleCampaignOutcomeBridgeResult.acknowledged(
			BattleCampaignOutcomeBridgeResult.OUTCOME_UNSUPPORTED_BATTLE_SOURCE,
			source.mission_id
		)

	var context_error: BattleCampaignOutcomeBridgeResult = _validate_hq_assault_context(
		game_state,
		battle_state,
		source
	)
	if context_error != null:
		return context_error

	var mission: CampaignMission = game_state.get_mission(source.mission_id)
	if _mission_already_resolved(mission):
		return BattleCampaignOutcomeBridgeResult.acknowledged(
			BattleCampaignOutcomeBridgeResult.OUTCOME_ALREADY_APPLIED,
			mission.id
		)

	if tactical_result.result_kind == BattleVictoryResult.RESULT_DRAW:
		return BattleCampaignOutcomeBridgeResult.acknowledged(
			BattleCampaignOutcomeBridgeResult.OUTCOME_DRAW_UNSUPPORTED,
			mission.id
		)

	if tactical_result.result_kind != BattleVictoryResult.RESULT_VICTORY:
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_tactical_result",
			"Battle campaign outcome bridge failed: tactical result_kind '%s' is not victory or draw."
			% tactical_result.result_kind,
			mission.id
		)

	var attacker_won: bool = false
	if tactical_result.winning_side_id == battle_state.attacker_side_id:
		attacker_won = true
	elif tactical_result.winning_side_id == battle_state.defender_side_id:
		attacker_won = false
	else:
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_winning_side",
			"Battle campaign outcome bridge failed: winning side '%s' is neither attacker '%s' nor defender '%s'."
			% [
				tactical_result.winning_side_id,
				battle_state.attacker_side_id,
				battle_state.defender_side_id
			],
			mission.id
		)

	if mission.mission_state != "awaiting_resolution":
		return BattleCampaignOutcomeBridgeResult.failed(
			"mission_not_awaiting_resolution",
			"Battle campaign outcome bridge failed: mission '%s' is '%s', not awaiting_resolution."
			% [mission.id, mission.mission_state],
			mission.id
		)

	var campaign_result: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		game_state,
		mission.id,
		attacker_won
	)
	if campaign_result == null or not campaign_result.success:
		var error_code: String = "campaign_resolution_failed"
		var error_message: String = "Battle campaign outcome bridge failed: existing HQ resolver did not succeed."
		if campaign_result != null:
			if not campaign_result.error_code.is_empty():
				error_code = campaign_result.error_code
			if not campaign_result.error_message.is_empty():
				error_message = campaign_result.error_message
		return BattleCampaignOutcomeBridgeResult.failed(error_code, error_message, mission.id)

	if attacker_won:
		return BattleCampaignOutcomeBridgeResult.applied_outcome(
			BattleCampaignOutcomeBridgeResult.OUTCOME_ATTACKER_VICTORY_APPLIED,
			mission.id
		)
	return BattleCampaignOutcomeBridgeResult.applied_outcome(
		BattleCampaignOutcomeBridgeResult.OUTCOME_DEFENDER_VICTORY_APPLIED,
		mission.id
	)


static func _campaign_source(battle_state: BattleState) -> BattleCampaignSource:
	if battle_state.campaign_source != null:
		return battle_state.campaign_source
	var derived := BattleCampaignSource.new(
		battle_state.battle_type_id,
		battle_state.mission_id,
		"",
		battle_state.location_id
	)
	if not battle_state.attacker_side_id.is_empty():
		var attacker_side: BattleSide = battle_state.get_side(battle_state.attacker_side_id)
		if attacker_side != null:
			derived.force_id = attacker_side.force_id
	return derived


static func _validate_hq_assault_context(
	game_state: GameState,
	battle_state: BattleState,
	source: BattleCampaignSource
) -> BattleCampaignOutcomeBridgeResult:
	if not source.is_populated():
		return BattleCampaignOutcomeBridgeResult.failed(
			"malformed_campaign_source",
			"Battle campaign outcome bridge failed: HQ assault provenance IDs are incomplete.",
			source.mission_id
		)
	if battle_state.battle_type_id != SOURCE_NEIGHBORHOOD_HQ_ASSAULT:
		return BattleCampaignOutcomeBridgeResult.failed(
			"malformed_campaign_source",
			"Battle campaign outcome bridge failed: battle_type_id '%s' does not match neighborhood_hq_assault."
			% battle_state.battle_type_id,
			source.mission_id
		)
	if battle_state.mission_id != source.mission_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"mission_id_mismatch",
			"Battle campaign outcome bridge failed: battle mission_id '%s' does not match source mission_id '%s'."
			% [battle_state.mission_id, source.mission_id],
			source.mission_id
		)
	if battle_state.location_id != source.target_location_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"target_location_mismatch",
			"Battle campaign outcome bridge failed: battle location_id '%s' does not match source target_location_id '%s'."
			% [battle_state.location_id, source.target_location_id],
			source.mission_id
		)
	if battle_state.attacker_side_id.is_empty() or not battle_state.has_side(battle_state.attacker_side_id):
		return BattleCampaignOutcomeBridgeResult.failed(
			"missing_attacker_side",
			"Battle campaign outcome bridge failed: attacker_side_id '%s' is missing."
			% battle_state.attacker_side_id,
			source.mission_id
		)
	if battle_state.defender_side_id.is_empty() or not battle_state.has_side(battle_state.defender_side_id):
		return BattleCampaignOutcomeBridgeResult.failed(
			"missing_defender_side",
			"Battle campaign outcome bridge failed: defender_side_id '%s' is missing."
			% battle_state.defender_side_id,
			source.mission_id
		)
	if battle_state.attacker_side_id == battle_state.defender_side_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"attacker_defender_side_collision",
			"Battle campaign outcome bridge failed: attacker and defender share side id '%s'."
			% battle_state.attacker_side_id,
			source.mission_id
		)
	var attacker_side: BattleSide = battle_state.get_side(battle_state.attacker_side_id)
	if attacker_side == null or attacker_side.force_id != source.force_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"force_id_mismatch",
			"Battle campaign outcome bridge failed: attacker side force_id does not match source force_id '%s'."
			% source.force_id,
			source.mission_id
		)
	if not game_state.has_mission(source.mission_id):
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_mission",
			"Battle campaign outcome bridge failed: mission '%s' does not exist." % source.mission_id,
			source.mission_id
		)
	var mission: CampaignMission = game_state.get_mission(source.mission_id)
	if mission == null:
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_mission",
			"Battle campaign outcome bridge failed: mission '%s' does not exist." % source.mission_id,
			source.mission_id
		)
	if mission.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_mission_type",
			"Battle campaign outcome bridge failed: mission '%s' type is '%s', not capture_neighborhood_hq."
			% [mission.id, mission.mission_type_id],
			mission.id
		)
	if mission.force_id != source.force_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"force_id_mismatch",
			"Battle campaign outcome bridge failed: mission force_id '%s' does not match source force_id '%s'."
			% [mission.force_id, source.force_id],
			mission.id
		)
	if mission.target_location_id != source.target_location_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"target_location_mismatch",
			"Battle campaign outcome bridge failed: mission target_location_id '%s' does not match source target_location_id '%s'."
			% [mission.target_location_id, source.target_location_id],
			mission.id
		)
	if source.force_id.is_empty() or not game_state.has_traveling_force(source.force_id):
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_force",
			"Battle campaign outcome bridge failed: attacking force '%s' does not exist." % source.force_id,
			mission.id
		)
	var force: TravelingForce = game_state.get_traveling_force(source.force_id)
	if force == null:
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_force",
			"Battle campaign outcome bridge failed: attacking force '%s' does not exist." % source.force_id,
			mission.id
		)
	if force.faction_id != mission.faction_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"force_faction_mismatch",
			"Battle campaign outcome bridge failed: force '%s' faction '%s' does not match mission faction '%s'."
			% [force.id, force.faction_id, mission.faction_id],
			mission.id
		)
	if force.destination_location_id != source.target_location_id:
		return BattleCampaignOutcomeBridgeResult.failed(
			"force_target_mismatch",
			"Battle campaign outcome bridge failed: force '%s' destination '%s' does not match target '%s'."
			% [force.id, force.destination_location_id, source.target_location_id],
			mission.id
		)
	if force.travel_state != "at_destination":
		return BattleCampaignOutcomeBridgeResult.failed(
			"force_not_at_destination",
			"Battle campaign outcome bridge failed: force '%s' is '%s', not at_destination."
			% [force.id, force.travel_state],
			mission.id
		)
	if source.target_location_id.is_empty() or not game_state.has_map_location(source.target_location_id):
		return BattleCampaignOutcomeBridgeResult.failed(
			"invalid_target_location",
			"Battle campaign outcome bridge failed: target '%s' does not exist." % source.target_location_id,
			mission.id
		)
	var target_location: MapLocation = game_state.get_map_location(source.target_location_id)
	if target_location == null or not (target_location is NeighborhoodHQ):
		return BattleCampaignOutcomeBridgeResult.failed(
			"target_not_neighborhood_hq",
			"Battle campaign outcome bridge failed: target '%s' is not a NeighborhoodHQ."
			% source.target_location_id,
			mission.id
		)
	return null


static func _mission_already_resolved(mission: CampaignMission) -> bool:
	if mission == null:
		return false
	if mission.mission_state == "resolved_success":
		return true
	if mission.mission_state == "resolved_failure":
		return true
	if mission.mission_state == "complete":
		return true
	return false
