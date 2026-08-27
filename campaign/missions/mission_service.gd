class_name MissionService
extends RefCounted

const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")
const DeploymentResult := preload("res://campaign/actions/deployment_result.gd")
const DeploymentService := preload("res://campaign/actions/deployment_service.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const MissionRequest := preload("res://campaign/missions/mission_request.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")


static func launch(game_state: GameState, request: MissionRequest) -> MissionResult:
	if game_state == null:
		return MissionResult.failed("null_game_state", "Mission launch failed: game_state is null.")
	if request == null:
		return MissionResult.failed("null_request", "Mission launch failed: request is null.")
	if request.mission_id.is_empty():
		return MissionResult.failed("empty_mission_id", "Mission launch failed: mission_id is empty.")
	if request.mission_type_id.is_empty():
		return MissionResult.failed("empty_mission_type_id", "Mission launch failed: mission_type_id is empty.")
	if request.deployment_request == null:
		return MissionResult.failed("null_deployment_request", "Mission launch failed: deployment_request is null.", request.mission_id)
	if game_state.has_mission(request.mission_id):
		return MissionResult.failed("duplicate_mission_id", "Mission launch failed: mission_id '%s' already exists." % request.mission_id, request.mission_id)
	var deployment_request: DeploymentRequest = request.deployment_request
	if deployment_request.faction_id.is_empty():
		return MissionResult.failed("empty_faction_id", "Mission launch failed: deployment_request.faction_id is empty.", request.mission_id)
	if deployment_request.force_id.is_empty():
		return MissionResult.failed("empty_force_id", "Mission launch failed: deployment_request.force_id is empty.", request.mission_id)

	var deployment_result: DeploymentResult = DeploymentService.deploy(game_state, deployment_request)
	if not deployment_result.success:
		return MissionResult.failed(
			deployment_result.error_code,
			deployment_result.error_message,
			request.mission_id,
			deployment_result.force_id
		)

	var force_id: String = deployment_result.force_id
	if force_id.is_empty():
		force_id = deployment_request.force_id
	var force: TravelingForce = game_state.get_traveling_force(force_id)
	if force == null:
		push_error("MissionService.launch: deployment succeeded but force '%s' is missing." % force_id)
		return MissionResult.failed("invalid_force", "Mission launch failed: deployed force '%s' is missing." % force_id, request.mission_id, force_id)

	var mission_state: String = "traveling_outbound"
	if force.travel_state == "at_destination":
		mission_state = "awaiting_resolution"

	var mission: CampaignMission = CampaignMission.new(
		request.mission_id,
		request.mission_type_id,
		deployment_request.faction_id,
		force.id,
		deployment_request.origin_stronghold_id,
		deployment_request.destination_location_id,
		mission_state,
		""
	)
	game_state.add_mission(mission)
	if not game_state.has_mission(mission.id):
		push_error("MissionService.launch: failed to add mission '%s' after deployment; rolling back force '%s'." % [mission.id, force.id])
		game_state.remove_traveling_force(force.id)
		return MissionResult.failed(
			"mission_insert_failed",
			"Mission launch failed: could not add mission '%s' after deployment." % mission.id,
			request.mission_id,
			force.id
		)

	return MissionResult.succeeded(mission.id, force.id, mission.mission_state)


static func sync_arrival(game_state: GameState, mission_id: String) -> MissionResult:
	if game_state == null:
		return MissionResult.failed("null_game_state", "Mission arrival sync failed: game_state is null.", mission_id)
	if mission_id.is_empty():
		return MissionResult.failed("empty_mission_id", "Mission arrival sync failed: mission_id is empty.")
	if not game_state.has_mission(mission_id):
		return MissionResult.failed("invalid_mission", "Mission arrival sync failed: mission '%s' does not exist." % mission_id, mission_id)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission.force_id.is_empty() or not game_state.has_traveling_force(mission.force_id):
		return MissionResult.failed("invalid_force", "Mission arrival sync failed: linked force '%s' does not exist." % mission.force_id, mission.id, mission.force_id, mission.mission_state)
	var force: TravelingForce = game_state.get_traveling_force(mission.force_id)

	if mission.mission_state != "traveling_outbound":
		return MissionResult.succeeded(mission.id, force.id, mission.mission_state)

	if force.travel_state == "at_destination":
		mission.mission_state = "awaiting_resolution"
		return MissionResult.succeeded(mission.id, force.id, mission.mission_state)
	if force.travel_state == "traveling_outbound":
		return MissionResult.succeeded(mission.id, force.id, mission.mission_state)

	return MissionResult.failed(
		"mission_force_state_mismatch",
		"Mission arrival sync failed: mission '%s' is traveling_outbound but force '%s' is '%s'." % [mission.id, force.id, force.travel_state],
		mission.id,
		force.id,
		mission.mission_state
	)


static func sync_all_arrivals(game_state: GameState) -> Array[MissionResult]:
	var results: Array[MissionResult] = []
	if game_state == null:
		results.append(MissionResult.failed("null_game_state", "Mission arrival sync failed: game_state is null."))
		return results
	var mission_ids: Array[String] = []
	for mission_id: String in game_state.missions:
		mission_ids.append(mission_id)
	mission_ids.sort()
	for mission_id: String in mission_ids:
		results.append(sync_arrival(game_state, mission_id))
	return results


static func resolve(game_state: GameState, mission_id: String, succeeded: bool, outcome_code: String) -> MissionResult:
	if game_state == null:
		return MissionResult.failed("null_game_state", "Mission resolve failed: game_state is null.", mission_id)
	if mission_id.is_empty():
		return MissionResult.failed("invalid_mission", "Mission resolve failed: mission_id is empty.")
	if not game_state.has_mission(mission_id):
		return MissionResult.failed("invalid_mission", "Mission resolve failed: mission '%s' does not exist." % mission_id, mission_id)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission.force_id.is_empty() or not game_state.has_traveling_force(mission.force_id):
		return MissionResult.failed("invalid_force", "Mission resolve failed: linked force '%s' does not exist." % mission.force_id, mission.id, mission.force_id, mission.mission_state)
	var force: TravelingForce = game_state.get_traveling_force(mission.force_id)
	if mission.mission_state != "awaiting_resolution":
		return MissionResult.failed(
			"mission_not_awaiting_resolution",
			"Mission resolve failed: mission '%s' is '%s', not awaiting_resolution." % [mission.id, mission.mission_state],
			mission.id,
			force.id,
			mission.mission_state
		)
	if force.travel_state != "at_destination":
		return MissionResult.failed(
			"force_not_at_destination",
			"Mission resolve failed: force '%s' is '%s', not at_destination." % [force.id, force.travel_state],
			mission.id,
			force.id,
			mission.mission_state
		)
	if outcome_code.is_empty():
		return MissionResult.failed("empty_outcome_code", "Mission resolve failed: outcome_code is empty.", mission.id, force.id, mission.mission_state)

	if succeeded:
		mission.mission_state = "resolved_success"
	else:
		mission.mission_state = "resolved_failure"
	mission.outcome_code = outcome_code
	return MissionResult.succeeded(mission.id, force.id, mission.mission_state)
