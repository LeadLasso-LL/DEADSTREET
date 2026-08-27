class_name NeighborhoodHQCaptureResolver
extends RefCounted

const NeighborhoodHQCaptureResult := preload("res://campaign/missions/resolvers/neighborhood_hq_capture_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const MissionService := preload("res://campaign/missions/mission_service.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")


static func resolve_success(game_state: GameState, mission_id: String) -> NeighborhoodHQCaptureResult:
	if game_state == null:
		return NeighborhoodHQCaptureResult.failed(
			"null_game_state",
			"Neighborhood HQ capture failed: game_state is null."
		)
	if mission_id.is_empty():
		return NeighborhoodHQCaptureResult.failed(
			"empty_mission_id",
			"Neighborhood HQ capture failed: mission_id is empty."
		)
	if not game_state.has_mission(mission_id):
		return NeighborhoodHQCaptureResult.failed(
			"invalid_mission",
			"Neighborhood HQ capture failed: mission '%s' does not exist." % mission_id,
			mission_id
		)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission.mission_type_id != "capture_neighborhood_hq":
		return NeighborhoodHQCaptureResult.failed(
			"invalid_mission_type",
			"Neighborhood HQ capture failed: mission '%s' type is '%s', not capture_neighborhood_hq."
			% [mission.id, mission.mission_type_id],
			mission.id,
			mission.force_id
		)
	if mission.mission_state != "awaiting_resolution":
		return NeighborhoodHQCaptureResult.failed(
			"mission_not_awaiting_resolution",
			"Neighborhood HQ capture failed: mission '%s' is '%s', not awaiting_resolution."
			% [mission.id, mission.mission_state],
			mission.id,
			mission.force_id
		)
	if mission.force_id.is_empty() or not game_state.has_traveling_force(mission.force_id):
		return NeighborhoodHQCaptureResult.failed(
			"invalid_force",
			"Neighborhood HQ capture failed: linked force '%s' does not exist." % mission.force_id,
			mission.id,
			mission.force_id
		)
	var force: TravelingForce = game_state.get_traveling_force(mission.force_id)
	if force.travel_state != "at_destination":
		return NeighborhoodHQCaptureResult.failed(
			"force_not_at_destination",
			"Neighborhood HQ capture failed: force '%s' is '%s', not at_destination."
			% [force.id, force.travel_state],
			mission.id,
			force.id
		)
	if force.faction_id != mission.faction_id:
		return NeighborhoodHQCaptureResult.failed(
			"force_faction_mismatch",
			"Neighborhood HQ capture failed: force '%s' faction '%s' does not match mission faction '%s'."
			% [force.id, force.faction_id, mission.faction_id],
			mission.id,
			force.id,
			"",
			mission.target_location_id,
			mission.faction_id
		)
	if mission.target_location_id.is_empty() or not game_state.has_map_location(mission.target_location_id):
		return NeighborhoodHQCaptureResult.failed(
			"invalid_target_location",
			"Neighborhood HQ capture failed: target '%s' does not exist." % mission.target_location_id,
			mission.id,
			force.id,
			"",
			mission.target_location_id,
			mission.faction_id
		)
	var target_location: MapLocation = game_state.get_map_location(mission.target_location_id)
	if not (target_location is NeighborhoodHQ):
		return NeighborhoodHQCaptureResult.failed(
			"target_not_neighborhood_hq",
			"Neighborhood HQ capture failed: target '%s' is not a NeighborhoodHQ." % mission.target_location_id,
			mission.id,
			force.id,
			target_location.neighborhood_id,
			target_location.id,
			mission.faction_id
		)
	var hq: NeighborhoodHQ = target_location as NeighborhoodHQ
	if force.destination_location_id != mission.target_location_id:
		return NeighborhoodHQCaptureResult.failed(
			"force_target_mismatch",
			"Neighborhood HQ capture failed: force '%s' destination '%s' does not match mission target '%s'."
			% [force.id, force.destination_location_id, mission.target_location_id],
			mission.id,
			force.id,
			hq.neighborhood_id,
			hq.id,
			mission.faction_id
		)
	if hq.neighborhood_id.is_empty():
		return NeighborhoodHQCaptureResult.failed(
			"missing_neighborhood",
			"Neighborhood HQ capture failed: HQ '%s' has empty neighborhood_id." % hq.id,
			mission.id,
			force.id,
			"",
			hq.id,
			mission.faction_id
		)
	if not game_state.has_neighborhood(hq.neighborhood_id):
		return NeighborhoodHQCaptureResult.failed(
			"invalid_neighborhood",
			"Neighborhood HQ capture failed: neighborhood '%s' does not exist." % hq.neighborhood_id,
			mission.id,
			force.id,
			hq.neighborhood_id,
			hq.id,
			mission.faction_id
		)
	var neighborhood: Neighborhood = game_state.get_neighborhood(hq.neighborhood_id)
	if mission.faction_id.is_empty() or not game_state.has_faction(mission.faction_id):
		return NeighborhoodHQCaptureResult.failed(
			"invalid_attacker_faction",
			"Neighborhood HQ capture failed: attacker faction '%s' does not exist." % mission.faction_id,
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id
		)
	var attacker: Faction = game_state.get_faction(mission.faction_id)
	if not (attacker is MajorGang):
		return NeighborhoodHQCaptureResult.failed(
			"attacker_not_major_gang",
			"Neighborhood HQ capture failed: attacker '%s' is not a MajorGang." % mission.faction_id,
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id
		)
	if neighborhood.owner_faction_id != hq.owner_faction_id:
		return NeighborhoodHQCaptureResult.failed(
			"territory_owner_mismatch",
			"Neighborhood HQ capture failed: neighborhood '%s' owner '%s' does not match HQ '%s' owner '%s'."
			% [neighborhood.id, neighborhood.owner_faction_id, hq.id, hq.owner_faction_id],
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id,
			neighborhood.owner_faction_id
		)
	var defender_faction_id: String = neighborhood.owner_faction_id
	if defender_faction_id == mission.faction_id:
		return NeighborhoodHQCaptureResult.failed(
			"already_controlled",
			"Neighborhood HQ capture failed: neighborhood '%s' and HQ '%s' are already controlled by '%s'."
			% [neighborhood.id, hq.id, mission.faction_id],
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id,
			defender_faction_id
		)

	var businesses_to_unclaim: Array[Business] = _defender_businesses_in_neighborhood(
		game_state,
		neighborhood.id,
		defender_faction_id
	)
	var neighborhood_owner_before: String = neighborhood.owner_faction_id
	var hq_owner_before: String = hq.owner_faction_id
	var business_owners_before: Dictionary[String, String] = {}
	var businesses_unclaimed: Array[String] = []
	for business: Business in businesses_to_unclaim:
		business_owners_before[business.id] = business.owner_faction_id
		businesses_unclaimed.append(business.id)

	neighborhood.owner_faction_id = mission.faction_id
	hq.owner_faction_id = mission.faction_id
	for business: Business in businesses_to_unclaim:
		business.owner_faction_id = ""

	var mission_result: MissionResult = MissionService.resolve(
		game_state,
		mission_id,
		true,
		"neighborhood_hq_captured"
	)
	if not mission_result.success:
		neighborhood.owner_faction_id = neighborhood_owner_before
		hq.owner_faction_id = hq_owner_before
		for business_id: String in business_owners_before:
			var restored_location: MapLocation = game_state.get_map_location(business_id)
			if restored_location != null and restored_location is Business:
				(restored_location as Business).owner_faction_id = business_owners_before[business_id]
		push_error(
			"NeighborhoodHQCaptureResolver.resolve_success: MissionService.resolve failed for mission '%s' after capture mutations; rolled back. error_code='%s' error_message='%s'."
			% [mission_id, mission_result.error_code, mission_result.error_message]
		)
		return NeighborhoodHQCaptureResult.failed(
			"mission_resolution_failed",
			"Neighborhood HQ capture failed: mission resolution failed after applying capture effects.",
			mission.id,
			force.id,
			neighborhood.id,
			hq.id,
			mission.faction_id,
			defender_faction_id
		)

	return NeighborhoodHQCaptureResult.succeeded(
		mission.id,
		force.id,
		neighborhood.id,
		hq.id,
		mission.faction_id,
		defender_faction_id,
		businesses_unclaimed
	)


static func _defender_businesses_in_neighborhood(
	game_state: GameState,
	neighborhood_id: String,
	defender_faction_id: String
) -> Array[Business]:
	var matched: Array[Business] = []
	if defender_faction_id.is_empty():
		return matched
	var location_ids: Array[String] = []
	for location_id: String in game_state.map_locations:
		location_ids.append(location_id)
	location_ids.sort()
	for location_id: String in location_ids:
		var location: MapLocation = game_state.get_map_location(location_id)
		if location == null or not (location is Business):
			continue
		var business: Business = location as Business
		if business.neighborhood_id != neighborhood_id:
			continue
		if business.owner_faction_id != defender_faction_id:
			continue
		matched.append(business)
	return matched
