class_name NeighborhoodHQAttackService
extends RefCounted

const DiplomacyService := preload("res://campaign/diplomacy/diplomacy_service.gd")
const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")
const ExistingForceMissionRequest := preload("res://campaign/missions/existing_force_mission_request.gd")
const ExistingForceMissionResult := preload("res://campaign/missions/existing_force_mission_result.gd")
const MissionRequest := preload("res://campaign/missions/mission_request.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")
const MissionService := preload("res://campaign/missions/mission_service.gd")
const NeighborhoodHQAttackResult := preload("res://campaign/missions/neighborhood_hq_attack_result.gd")

const MISSION_TYPE_CAPTURE_HQ := "capture_neighborhood_hq"


class _Authorization extends RefCounted:
	var ok: bool = false
	var error_code: String = ""
	var error_message: String = ""
	var attacker_faction_id: String = ""
	var defender_faction_id: String = ""
	var neighborhood_id: String = ""
	var hq_location_id: String = ""


static func launch_from_stronghold(
	game_state: GameState,
	mission_request: MissionRequest
) -> NeighborhoodHQAttackResult:
	if game_state == null:
		return NeighborhoodHQAttackResult.failed(
			"null_game_state",
			"Neighborhood HQ attack failed: game_state is null."
		)
	if mission_request == null:
		return NeighborhoodHQAttackResult.failed(
			"null_request",
			"Neighborhood HQ attack failed: request is null."
		)
	if mission_request.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return NeighborhoodHQAttackResult.failed(
			"invalid_mission_type",
			"Neighborhood HQ attack failed: mission type is '%s', not capture_neighborhood_hq."
			% mission_request.mission_type_id,
			mission_request.mission_id
		)
	var deployment_request: DeploymentRequest = mission_request.deployment_request
	var attacker_faction_id: String = ""
	var target_location_id: String = ""
	var requested_force_id: String = ""
	if deployment_request != null:
		attacker_faction_id = deployment_request.faction_id
		target_location_id = deployment_request.destination_location_id
		requested_force_id = deployment_request.force_id
	var auth: _Authorization = _authorize_territory(
		game_state,
		attacker_faction_id,
		target_location_id
	)
	if not auth.ok:
		return _result_from_auth_failure(auth, mission_request.mission_id, requested_force_id)
	var mission_result: MissionResult = MissionService.launch(game_state, mission_request)
	return _result_from_mission_launch(mission_result, auth)


static func launch_from_existing_force(
	game_state: GameState,
	request: ExistingForceMissionRequest
) -> NeighborhoodHQAttackResult:
	if game_state == null:
		return NeighborhoodHQAttackResult.failed(
			"null_game_state",
			"Neighborhood HQ attack failed: game_state is null."
		)
	if request == null:
		return NeighborhoodHQAttackResult.failed(
			"null_request",
			"Neighborhood HQ attack failed: request is null."
		)
	if request.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return NeighborhoodHQAttackResult.failed(
			"invalid_mission_type",
			"Neighborhood HQ attack failed: mission type is '%s', not capture_neighborhood_hq."
			% request.mission_type_id,
			request.mission_id,
			request.force_id
		)
	var attacker_faction_id: String = ""
	if not request.force_id.is_empty() and game_state.has_traveling_force(request.force_id):
		var force: TravelingForce = game_state.get_traveling_force(request.force_id)
		if force != null:
			attacker_faction_id = force.faction_id
	var auth: _Authorization = _authorize_territory(
		game_state,
		attacker_faction_id,
		request.target_location_id
	)
	if not auth.ok:
		return _result_from_auth_failure(auth, request.mission_id, request.force_id)
	var existing_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		game_state,
		request
	)
	return _result_from_existing_force_launch(existing_result, auth)


static func _authorize_territory(
	game_state: GameState,
	attacker_faction_id: String,
	target_location_id: String
) -> _Authorization:
	var auth: _Authorization = _Authorization.new()
	auth.attacker_faction_id = attacker_faction_id
	auth.hq_location_id = target_location_id
	if attacker_faction_id.is_empty() or not game_state.has_faction(attacker_faction_id):
		auth.error_code = "invalid_attacker_faction"
		auth.error_message = (
			"Neighborhood HQ attack failed: attacker faction '%s' does not exist."
			% attacker_faction_id
		)
		return auth
	var attacker: Faction = game_state.get_faction(attacker_faction_id)
	if not (attacker is MajorGang):
		auth.error_code = "attacker_not_major_gang"
		auth.error_message = (
			"Neighborhood HQ attack failed: attacker '%s' is not a MajorGang."
			% attacker_faction_id
		)
		return auth
	if target_location_id.is_empty() or not game_state.has_map_location(target_location_id):
		auth.error_code = "invalid_target_location"
		auth.error_message = (
			"Neighborhood HQ attack failed: target '%s' does not exist."
			% target_location_id
		)
		return auth
	var target_location: MapLocation = game_state.get_map_location(target_location_id)
	if not (target_location is NeighborhoodHQ):
		auth.neighborhood_id = target_location.neighborhood_id
		auth.error_code = "target_not_neighborhood_hq"
		auth.error_message = (
			"Neighborhood HQ attack failed: target '%s' is not a NeighborhoodHQ."
			% target_location_id
		)
		return auth
	var hq: NeighborhoodHQ = target_location as NeighborhoodHQ
	auth.hq_location_id = hq.id
	if hq.neighborhood_id.is_empty():
		auth.error_code = "missing_neighborhood"
		auth.error_message = (
			"Neighborhood HQ attack failed: HQ '%s' has empty neighborhood_id."
			% hq.id
		)
		return auth
	auth.neighborhood_id = hq.neighborhood_id
	if not game_state.has_neighborhood(hq.neighborhood_id):
		auth.error_code = "invalid_neighborhood"
		auth.error_message = (
			"Neighborhood HQ attack failed: neighborhood '%s' does not exist."
			% hq.neighborhood_id
		)
		return auth
	var neighborhood: Neighborhood = game_state.get_neighborhood(hq.neighborhood_id)
	if neighborhood.owner_faction_id != hq.owner_faction_id:
		auth.defender_faction_id = neighborhood.owner_faction_id
		auth.error_code = "territory_owner_mismatch"
		auth.error_message = (
			"Neighborhood HQ attack failed: neighborhood '%s' owner '%s' does not match HQ '%s' owner '%s'."
			% [neighborhood.id, neighborhood.owner_faction_id, hq.id, hq.owner_faction_id]
		)
		return auth
	var defender_faction_id: String = neighborhood.owner_faction_id
	auth.defender_faction_id = defender_faction_id
	if defender_faction_id == attacker_faction_id:
		auth.error_code = "already_controlled"
		auth.error_message = (
			"Neighborhood HQ attack failed: neighborhood '%s' and HQ '%s' are already controlled by '%s'."
			% [neighborhood.id, hq.id, attacker_faction_id]
		)
		return auth
	if not defender_faction_id.is_empty() and not game_state.has_faction(defender_faction_id):
		auth.error_code = "invalid_defender_faction"
		auth.error_message = (
			"Neighborhood HQ attack failed: defender faction '%s' does not exist."
			% defender_faction_id
		)
		return auth
	if not defender_faction_id.is_empty():
		if not DiplomacyService.are_at_war(game_state, attacker_faction_id, defender_faction_id):
			auth.error_code = "formal_war_required"
			auth.error_message = (
				"Neighborhood HQ attack failed: '%s' and '%s' are not formally at war."
				% [attacker_faction_id, defender_faction_id]
			)
			return auth
	auth.ok = true
	return auth


static func _result_from_auth_failure(
	auth: _Authorization,
	mission_id: String,
	force_id: String
) -> NeighborhoodHQAttackResult:
	return NeighborhoodHQAttackResult.failed(
		auth.error_code,
		auth.error_message,
		mission_id,
		force_id,
		auth.attacker_faction_id,
		auth.defender_faction_id,
		auth.neighborhood_id,
		auth.hq_location_id
	)


static func _result_from_mission_launch(
	mission_result: MissionResult,
	auth: _Authorization
) -> NeighborhoodHQAttackResult:
	if mission_result.success:
		return NeighborhoodHQAttackResult.succeeded(
			mission_result.mission_id,
			mission_result.force_id,
			auth.attacker_faction_id,
			auth.defender_faction_id,
			auth.neighborhood_id,
			auth.hq_location_id,
			mission_result.mission_state,
			mission_result.mission_state == "awaiting_resolution"
		)
	return NeighborhoodHQAttackResult.failed(
		mission_result.error_code,
		mission_result.error_message,
		mission_result.mission_id,
		mission_result.force_id,
		auth.attacker_faction_id,
		auth.defender_faction_id,
		auth.neighborhood_id,
		auth.hq_location_id,
		mission_result.mission_state,
		false
	)


static func _result_from_existing_force_launch(
	existing_result: ExistingForceMissionResult,
	auth: _Authorization
) -> NeighborhoodHQAttackResult:
	if existing_result.success:
		return NeighborhoodHQAttackResult.succeeded(
			existing_result.mission_id,
			existing_result.force_id,
			auth.attacker_faction_id,
			auth.defender_faction_id,
			auth.neighborhood_id,
			auth.hq_location_id,
			existing_result.mission_state,
			existing_result.reached_destination
		)
	return NeighborhoodHQAttackResult.failed(
		existing_result.error_code,
		existing_result.error_message,
		existing_result.mission_id,
		existing_result.force_id,
		auth.attacker_faction_id,
		auth.defender_faction_id,
		auth.neighborhood_id,
		auth.hq_location_id,
		existing_result.mission_state,
		false
	)
