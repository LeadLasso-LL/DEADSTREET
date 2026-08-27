class_name NeighborhoodHQAttackFailureResolver
extends RefCounted

const NeighborhoodHQAttackFailureResult := preload("res://campaign/missions/resolvers/neighborhood_hq_attack_failure_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const MissionService := preload("res://campaign/missions/mission_service.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")

const OUTCOME_ASSAULT_FAILED := "neighborhood_hq_assault_failed"


static func resolve_failure(game_state: GameState, mission_id: String) -> NeighborhoodHQAttackFailureResult:
	if game_state == null:
		return NeighborhoodHQAttackFailureResult.failed(
			"null_game_state",
			"Neighborhood HQ assault resolution failed: game_state is null."
		)
	if mission_id.is_empty():
		return NeighborhoodHQAttackFailureResult.failed(
			"empty_mission_id",
			"Neighborhood HQ assault resolution failed: mission_id is empty."
		)
	if not game_state.has_mission(mission_id):
		return NeighborhoodHQAttackFailureResult.failed(
			"invalid_mission",
			"Neighborhood HQ assault resolution failed: mission '%s' does not exist." % mission_id,
			mission_id
		)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission.mission_type_id != "capture_neighborhood_hq":
		return NeighborhoodHQAttackFailureResult.failed(
			"invalid_mission_type",
			"Neighborhood HQ assault resolution failed: mission '%s' type is '%s', not capture_neighborhood_hq."
			% [mission.id, mission.mission_type_id],
			mission.id,
			mission.force_id
		)
	if mission.mission_state != "awaiting_resolution":
		return NeighborhoodHQAttackFailureResult.failed(
			"mission_not_awaiting_resolution",
			"Neighborhood HQ assault resolution failed: mission '%s' is '%s', not awaiting_resolution."
			% [mission.id, mission.mission_state],
			mission.id,
			mission.force_id
		)
	if mission.force_id.is_empty() or not game_state.has_traveling_force(mission.force_id):
		return NeighborhoodHQAttackFailureResult.failed(
			"invalid_force",
			"Neighborhood HQ assault resolution failed: linked force '%s' does not exist." % mission.force_id,
			mission.id,
			mission.force_id
		)
	var force: TravelingForce = game_state.get_traveling_force(mission.force_id)
	if force.travel_state != "at_destination":
		return NeighborhoodHQAttackFailureResult.failed(
			"force_not_at_destination",
			"Neighborhood HQ assault resolution failed: force '%s' is '%s', not at_destination."
			% [force.id, force.travel_state],
			mission.id,
			force.id
		)
	if force.faction_id != mission.faction_id:
		return NeighborhoodHQAttackFailureResult.failed(
			"force_faction_mismatch",
			"Neighborhood HQ assault resolution failed: force '%s' faction '%s' does not match mission faction '%s'."
			% [force.id, force.faction_id, mission.faction_id],
			mission.id,
			force.id,
			"",
			mission.target_location_id,
			mission.faction_id
		)
	if mission.target_location_id.is_empty() or not game_state.has_map_location(mission.target_location_id):
		return NeighborhoodHQAttackFailureResult.failed(
			"invalid_target_location",
			"Neighborhood HQ assault resolution failed: target '%s' does not exist." % mission.target_location_id,
			mission.id,
			force.id,
			"",
			mission.target_location_id,
			mission.faction_id
		)
	var target_location: MapLocation = game_state.get_map_location(mission.target_location_id)
	if not (target_location is NeighborhoodHQ):
		return NeighborhoodHQAttackFailureResult.failed(
			"target_not_neighborhood_hq",
			"Neighborhood HQ assault resolution failed: target '%s' is not a NeighborhoodHQ." % mission.target_location_id,
			mission.id,
			force.id,
			target_location.neighborhood_id,
			target_location.id,
			mission.faction_id
		)
	var hq: NeighborhoodHQ = target_location as NeighborhoodHQ
	if force.destination_location_id != mission.target_location_id:
		return NeighborhoodHQAttackFailureResult.failed(
			"force_target_mismatch",
			"Neighborhood HQ assault resolution failed: force '%s' destination '%s' does not match mission target '%s'."
			% [force.id, force.destination_location_id, mission.target_location_id],
			mission.id,
			force.id,
			hq.neighborhood_id,
			hq.id,
			mission.faction_id
		)
	if hq.neighborhood_id.is_empty():
		return NeighborhoodHQAttackFailureResult.failed(
			"missing_neighborhood",
			"Neighborhood HQ assault resolution failed: HQ '%s' has empty neighborhood_id." % hq.id,
			mission.id,
			force.id,
			"",
			hq.id,
			mission.faction_id
		)
	if not game_state.has_neighborhood(hq.neighborhood_id):
		return NeighborhoodHQAttackFailureResult.failed(
			"invalid_neighborhood",
			"Neighborhood HQ assault resolution failed: neighborhood '%s' does not exist." % hq.neighborhood_id,
			mission.id,
			force.id,
			hq.neighborhood_id,
			hq.id,
			mission.faction_id
		)
	var neighborhood: Neighborhood = game_state.get_neighborhood(hq.neighborhood_id)
	if neighborhood.owner_faction_id != hq.owner_faction_id:
		return NeighborhoodHQAttackFailureResult.failed(
			"territory_owner_mismatch",
			"Neighborhood HQ assault resolution failed: neighborhood '%s' owner '%s' does not match HQ '%s' owner '%s'."
			% [neighborhood.id, neighborhood.owner_faction_id, hq.id, hq.owner_faction_id],
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id,
			neighborhood.owner_faction_id
		)
	var defender_faction_id: String = neighborhood.owner_faction_id

	var mission_result: MissionResult = MissionService.resolve(
		game_state,
		mission_id,
		false,
		OUTCOME_ASSAULT_FAILED
	)
	if not mission_result.success:
		push_error(
			"NeighborhoodHQAttackFailureResolver.resolve_failure: MissionService.resolve failed for mission '%s'. error_code='%s' error_message='%s'."
			% [mission_id, mission_result.error_code, mission_result.error_message]
		)
		return NeighborhoodHQAttackFailureResult.failed(
			"mission_resolution_failed",
			"Neighborhood HQ assault resolution failed: mission resolution failed.",
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id,
			defender_faction_id
		)

	return NeighborhoodHQAttackFailureResult.succeeded(
		mission.id,
		force.id,
		neighborhood.id,
		hq.id,
		mission.faction_id,
		defender_faction_id
	)
