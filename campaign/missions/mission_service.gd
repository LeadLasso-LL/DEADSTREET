class_name MissionService
extends RefCounted

const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")
const DeploymentResult := preload("res://campaign/actions/deployment_result.gd")
const DeploymentService := preload("res://campaign/actions/deployment_service.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const MissionRequest := preload("res://campaign/missions/mission_request.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")
const ExistingForceMissionRequest := preload("res://campaign/missions/existing_force_mission_request.gd")
const ExistingForceMissionResult := preload("res://campaign/missions/existing_force_mission_result.gd")


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


static func launch_from_existing_force(
	game_state: GameState,
	request: ExistingForceMissionRequest
) -> ExistingForceMissionResult:
	if game_state == null:
		return ExistingForceMissionResult.failed(
			"null_game_state",
			"Existing-force mission launch failed: game_state is null."
		)
	if request == null:
		return ExistingForceMissionResult.failed(
			"null_request",
			"Existing-force mission launch failed: request is null."
		)
	if request.mission_id.is_empty():
		return ExistingForceMissionResult.failed(
			"empty_mission_id",
			"Existing-force mission launch failed: mission_id is empty."
		)
	if game_state.has_mission(request.mission_id):
		return ExistingForceMissionResult.failed(
			"duplicate_mission_id",
			"Existing-force mission launch failed: mission_id '%s' already exists." % request.mission_id,
			request.mission_id
		)
	if request.mission_type_id.is_empty():
		return ExistingForceMissionResult.failed(
			"empty_mission_type",
			"Existing-force mission launch failed: mission_type_id is empty.",
			request.mission_id
		)
	if request.force_id.is_empty():
		return ExistingForceMissionResult.failed(
			"empty_force_id",
			"Existing-force mission launch failed: force_id is empty.",
			request.mission_id
		)
	if not game_state.has_traveling_force(request.force_id):
		return ExistingForceMissionResult.failed(
			"invalid_force",
			"Existing-force mission launch failed: force '%s' does not exist." % request.force_id,
			request.mission_id,
			request.force_id
		)
	var force: TravelingForce = game_state.get_traveling_force(request.force_id)
	if force == null:
		return ExistingForceMissionResult.failed(
			"invalid_force",
			"Existing-force mission launch failed: force '%s' does not exist." % request.force_id,
			request.mission_id,
			request.force_id
		)
	if force.travel_state == "complete":
		return ExistingForceMissionResult.failed(
			"force_complete",
			"Existing-force mission launch failed: force '%s' is complete." % force.id,
			request.mission_id,
			force.id
		)
	if request.target_location_id.is_empty():
		return ExistingForceMissionResult.failed(
			"empty_target_location",
			"Existing-force mission launch failed: target_location_id is empty.",
			request.mission_id,
			force.id
		)
	var target: MapLocation = game_state.get_map_location(request.target_location_id)
	if target == null:
		return ExistingForceMissionResult.failed(
			"invalid_target_location",
			"Existing-force mission launch failed: target '%s' does not exist." % request.target_location_id,
			request.mission_id,
			force.id
		)
	if target.road_node_id.is_empty():
		return ExistingForceMissionResult.failed(
			"missing_target_road_node",
			"Existing-force mission launch failed: target '%s' has no road_node_id." % target.id,
			request.mission_id,
			force.id
		)
	var graph: RoadGraph = game_state.road_graph
	if graph == null or not graph.has_node(target.road_node_id):
		return ExistingForceMissionResult.failed(
			"invalid_target_road_node",
			"Existing-force mission launch failed: target road node '%s' is not in the road graph." % target.road_node_id,
			request.mission_id,
			force.id
		)
	var current_node_id: String = force.get_current_road_node_id()
	if current_node_id.is_empty():
		return ExistingForceMissionResult.failed(
			"force_not_at_node",
			"Existing-force mission launch failed: force '%s' is not at a road node." % force.id,
			request.mission_id,
			force.id
		)
	if not graph.has_node(current_node_id):
		return ExistingForceMissionResult.failed(
			"invalid_force_road_node",
			"Existing-force mission launch failed: force road node '%s' is not in the road graph." % current_node_id,
			request.mission_id,
			force.id
		)
	if _force_has_unresolved_mission(game_state, force.id):
		return ExistingForceMissionResult.failed(
			"force_has_unresolved_mission",
			"Existing-force mission launch failed: force '%s' has an unresolved mission." % force.id,
			request.mission_id,
			force.id
		)
	var route: Array[String] = graph.find_route(current_node_id, target.road_node_id)
	if route.is_empty():
		return ExistingForceMissionResult.failed(
			"no_route",
			"Existing-force mission launch failed: no route from '%s' to '%s'." % [current_node_id, target.road_node_id],
			request.mission_id,
			force.id
		)
	if force.movement_remaining < 0.0:
		return ExistingForceMissionResult.failed(
			"invalid_movement_remaining",
			"Existing-force mission launch failed: force '%s' has negative movement remaining." % force.id,
			request.mission_id,
			force.id
		)

	var origin_location_id: String = _derive_existing_force_mission_origin(game_state, force, current_node_id)
	var snapshot_destination: String = force.destination_location_id
	var snapshot_route: Array[String] = _copy_route(force.route_node_ids)
	var snapshot_segment_index: int = force.route_segment_index
	var snapshot_distance: float = force.distance_into_segment
	var snapshot_travel_state: String = force.travel_state
	var snapshot_movement_remaining: float = force.movement_remaining

	var same_node: bool = current_node_id == target.road_node_id
	var movement_spent: float = 0.0
	if same_node:
		force.destination_location_id = target.id
		if force.travel_state != "at_destination" or _route_last_node(force.route_node_ids) != current_node_id:
			force.route_node_ids.clear()
			force.route_node_ids.append(current_node_id)
			force.route_segment_index = 0
			force.distance_into_segment = 0.0
		force.travel_state = "at_destination"
	else:
		force.destination_location_id = target.id
		force.route_node_ids.clear()
		for node_id: String in route:
			force.route_node_ids.append(node_id)
		force.route_segment_index = 0
		force.distance_into_segment = 0.0
		force.travel_state = "traveling_outbound"
		var movement_before: float = force.movement_remaining
		var unused_movement: float = force.advance(movement_before, graph)
		force.movement_remaining = unused_movement
		movement_spent = movement_before - force.movement_remaining
		if movement_spent < 0.0:
			movement_spent = 0.0
		if movement_spent > movement_before:
			movement_spent = movement_before

	var reached_destination: bool = force.travel_state == "at_destination"
	var mission_state: String = "traveling_outbound"
	if reached_destination:
		mission_state = "awaiting_resolution"

	var mission: CampaignMission = CampaignMission.new(
		request.mission_id,
		request.mission_type_id,
		force.faction_id,
		force.id,
		origin_location_id,
		target.id,
		mission_state,
		""
	)
	game_state.add_mission(mission)
	if not game_state.has_mission(mission.id):
		push_error(
			"MissionService.launch_from_existing_force: failed to add mission '%s'; rolling back force '%s'."
			% [mission.id, force.id]
		)
		_restore_force_route_snapshot(
			force,
			snapshot_destination,
			snapshot_route,
			snapshot_segment_index,
			snapshot_distance,
			snapshot_travel_state,
			snapshot_movement_remaining
		)
		return ExistingForceMissionResult.failed(
			"mission_insert_failed",
			"Existing-force mission launch failed: could not add mission '%s'." % request.mission_id,
			request.mission_id,
			force.id
		)

	return ExistingForceMissionResult.succeeded(
		mission.id,
		force.id,
		mission.mission_state,
		reached_destination,
		movement_spent,
		force.movement_remaining
	)


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


static func _force_has_unresolved_mission(game_state: GameState, force_id: String) -> bool:
	var mission_ids: Array[String] = []
	for mission_id: String in game_state.missions:
		mission_ids.append(mission_id)
	mission_ids.sort()
	for mission_id: String in mission_ids:
		var mission: CampaignMission = game_state.get_mission(mission_id)
		if mission == null or mission.force_id != force_id:
			continue
		if (
			mission.mission_state == "resolved_success"
			or mission.mission_state == "resolved_failure"
			or mission.mission_state == "complete"
		):
			continue
		return true
	return false


static func _derive_existing_force_mission_origin(
	game_state: GameState,
	force: TravelingForce,
	current_node_id: String
) -> String:
	var location_ids: Array[String] = []
	for location_id: String in game_state.map_locations:
		location_ids.append(location_id)
	location_ids.sort()
	var matching_ids: Array[String] = []
	for location_id: String in location_ids:
		var location: MapLocation = game_state.get_map_location(location_id)
		if location == null:
			continue
		if location.road_node_id == current_node_id:
			matching_ids.append(location_id)
	if matching_ids.is_empty():
		return ""
	if not force.destination_location_id.is_empty() and matching_ids.has(force.destination_location_id):
		return force.destination_location_id
	return matching_ids[0]


static func _copy_route(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for node_id: String in source:
		copied.append(node_id)
	return copied


static func _route_last_node(route_node_ids: Array[String]) -> String:
	if route_node_ids.is_empty():
		return ""
	return str(route_node_ids[route_node_ids.size() - 1])


static func _restore_force_route_snapshot(
	force: TravelingForce,
	destination_location_id: String,
	route_node_ids: Array[String],
	route_segment_index: int,
	distance_into_segment: float,
	travel_state: String,
	movement_remaining: float
) -> void:
	force.destination_location_id = destination_location_id
	force.route_node_ids.clear()
	for node_id: String in route_node_ids:
		force.route_node_ids.append(node_id)
	force.route_segment_index = route_segment_index
	force.distance_into_segment = distance_into_segment
	force.travel_state = travel_state
	force.movement_remaining = movement_remaining

