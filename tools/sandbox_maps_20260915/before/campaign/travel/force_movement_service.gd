class_name ForceMovementService
extends RefCounted

const ForceMoveRequest := preload("res://campaign/travel/force_move_request.gd")
const ForceMoveResult := preload("res://campaign/travel/force_move_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")


static func move_to_location(game_state: GameState, request: ForceMoveRequest) -> ForceMoveResult:
	if game_state == null:
		return ForceMoveResult.failed("null_game_state", "Force movement failed: game_state is null.")
	if request == null:
		return ForceMoveResult.failed("null_request", "Force movement failed: request is null.")
	if request.force_id.is_empty():
		return ForceMoveResult.failed("empty_force_id", "Force movement failed: force_id is empty.")
	if request.destination_location_id.is_empty():
		return ForceMoveResult.failed(
			"empty_destination_id",
			"Force movement failed: destination_location_id is empty.",
			request.force_id
		)
	if not game_state.has_traveling_force(request.force_id):
		return ForceMoveResult.failed(
			"invalid_force",
			"Force movement failed: force '%s' does not exist." % request.force_id,
			request.force_id,
			request.destination_location_id
		)
	var force: TravelingForce = game_state.get_traveling_force(request.force_id)
	if force.travel_state == "complete":
		return ForceMoveResult.failed(
			"force_complete",
			"Force movement failed: force '%s' is complete." % force.id,
			force.id,
			request.destination_location_id
		)
	if force.travel_state != "at_destination":
		return ForceMoveResult.failed(
			"force_not_at_node",
			"Force movement failed: force '%s' is '%s', not at a destination node." % [force.id, force.travel_state],
			force.id,
			request.destination_location_id
		)
	if _force_has_unresolved_mission(game_state, force.id):
		return ForceMoveResult.failed(
			"force_has_unresolved_mission",
			"Force movement failed: force '%s' has an unresolved mission." % force.id,
			force.id,
			request.destination_location_id
		)
	var destination: MapLocation = game_state.get_map_location(request.destination_location_id)
	if destination == null:
		return ForceMoveResult.failed(
			"invalid_destination",
			"Force movement failed: destination '%s' does not exist." % request.destination_location_id,
			force.id,
			request.destination_location_id
		)
	if destination.road_node_id.is_empty():
		return ForceMoveResult.failed(
			"destination_missing_road_node",
			"Force movement failed: destination '%s' has no road_node_id." % destination.id,
			force.id,
			destination.id
		)
	var graph: RoadGraph = game_state.road_graph
	if graph == null or not graph.has_node(destination.road_node_id):
		return ForceMoveResult.failed(
			"invalid_destination_road_node",
			"Force movement failed: destination road node '%s' is not in the road graph." % destination.road_node_id,
			force.id,
			destination.id
		)
	var current_node_id: String = force.get_current_road_node_id()
	if current_node_id.is_empty():
		return ForceMoveResult.failed(
			"invalid_current_road_node",
			"Force movement failed: force '%s' has no current road node." % force.id,
			force.id,
			destination.id
		)
	if not graph.has_node(current_node_id):
		return ForceMoveResult.failed(
			"invalid_current_road_node",
			"Force movement failed: current road node '%s' is not in the road graph." % current_node_id,
			force.id,
			destination.id
		)
	var route: Array[String] = graph.find_route(current_node_id, destination.road_node_id)
	if route.is_empty():
		return ForceMoveResult.failed(
			"no_route",
			"Force movement failed: no route from '%s' to '%s'." % [current_node_id, destination.road_node_id],
			force.id,
			destination.id
		)
	if force.movement_remaining < 0.0:
		return ForceMoveResult.failed(
			"invalid_movement_remaining",
			"Force movement failed: force '%s' has negative movement remaining." % force.id,
			force.id,
			destination.id
		)

	force.destination_location_id = destination.id
	force.route_node_ids.clear()
	for node_id: String in route:
		force.route_node_ids.append(node_id)
	force.route_segment_index = 0
	force.distance_into_segment = 0.0
	if route.size() <= 1:
		force.travel_state = "at_destination"
		return ForceMoveResult.succeeded(force.id, destination.id, true, 0.0, force.movement_remaining)

	force.travel_state = "traveling_outbound"
	var movement_before: float = force.movement_remaining
	var unused_movement: float = force.advance(movement_before, graph)
	force.movement_remaining = unused_movement
	var movement_spent: float = movement_before - force.movement_remaining
	if movement_spent < 0.0:
		movement_spent = 0.0
	if movement_spent > movement_before:
		movement_spent = movement_before
	var reached_destination: bool = force.travel_state == "at_destination"
	return ForceMoveResult.succeeded(
		force.id,
		destination.id,
		reached_destination,
		movement_spent,
		force.movement_remaining
	)


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
