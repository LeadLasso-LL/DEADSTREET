class_name DeploymentService
extends RefCounted


static func deploy(game_state: GameState, request: DeploymentRequest) -> DeploymentResult:
	if game_state == null:
		return DeploymentResult.failed("null_game_state", "Deployment failed: game_state is null.")
	if request == null:
		return DeploymentResult.failed("null_request", "Deployment failed: request is null.")
	if request.force_id.is_empty():
		return DeploymentResult.failed("empty_force_id", "Deployment failed: force_id is empty.")
	if request.faction_id.is_empty():
		return DeploymentResult.failed("invalid_faction", "Deployment failed: faction_id is empty.")
	if request.origin_stronghold_id.is_empty():
		return DeploymentResult.failed("invalid_origin", "Deployment failed: origin_stronghold_id is empty.")
	if request.destination_location_id.is_empty():
		return DeploymentResult.failed("invalid_destination", "Deployment failed: destination_location_id is empty.")
	if request.movement_budget < 0.0:
		return DeploymentResult.failed("invalid_movement_budget", "Deployment failed: movement_budget is negative.")
	if game_state.has_traveling_force(request.force_id):
		return DeploymentResult.failed("duplicate_force_id", "Deployment failed: force_id '%s' already exists." % request.force_id)

	if not game_state.has_faction(request.faction_id):
		return DeploymentResult.failed("invalid_faction", "Deployment failed: faction '%s' does not exist." % request.faction_id)

	var origin_location: MapLocation = game_state.get_map_location(request.origin_stronghold_id)
	if origin_location == null:
		return DeploymentResult.failed("invalid_origin", "Deployment failed: origin '%s' does not exist." % request.origin_stronghold_id)
	if not (origin_location is Stronghold):
		return DeploymentResult.failed("invalid_origin", "Deployment failed: origin '%s' is not a Stronghold." % request.origin_stronghold_id)
	var origin: Stronghold = origin_location as Stronghold
	if origin.owner_faction_id != request.faction_id:
		return DeploymentResult.failed("origin_wrong_faction", "Deployment failed: origin '%s' is not owned by faction '%s'." % [request.origin_stronghold_id, request.faction_id])
	if origin.road_node_id.is_empty():
		return DeploymentResult.failed("origin_missing_road_node", "Deployment failed: origin '%s' has no road_node_id." % request.origin_stronghold_id)

	var destination: MapLocation = game_state.get_map_location(request.destination_location_id)
	if destination == null:
		return DeploymentResult.failed("invalid_destination", "Deployment failed: destination '%s' does not exist." % request.destination_location_id)
	if destination.road_node_id.is_empty():
		return DeploymentResult.failed("destination_missing_road_node", "Deployment failed: destination '%s' has no road_node_id." % request.destination_location_id)

	var soldier_result: DeploymentResult = _validate_soldiers(game_state, request, origin)
	if not soldier_result.success:
		return soldier_result
	var vehicle_result: DeploymentResult = _validate_vehicles(game_state, request, origin)
	if not vehicle_result.success:
		return vehicle_result

	if request.soldier_ids.is_empty():
		return DeploymentResult.failed("no_soldiers", "Deployment failed: at least one soldier must be selected.")
	if request.vehicle_ids.is_empty():
		return DeploymentResult.failed("no_vehicles", "Deployment failed: at least one vehicle must be selected.")

	var soldier_group: SoldierGroup = SoldierGroup.new()
	for soldier_id: String in request.soldier_ids:
		soldier_group.add_soldier_id(soldier_id)
	var vehicle_group: VehicleGroup = VehicleGroup.new()
	for vehicle_id: String in request.vehicle_ids:
		vehicle_group.add_vehicle_id(vehicle_id)
	var transport_capacity: int = vehicle_group.get_total_passenger_capacity(game_state)
	if request.soldier_ids.size() > transport_capacity:
		return DeploymentResult.failed("insufficient_transport", "Deployment failed: soldier count %s exceeds transport capacity %s." % [request.soldier_ids.size(), transport_capacity])

	var exclusivity_result: DeploymentResult = _validate_exclusivity(game_state, request)
	if not exclusivity_result.success:
		return exclusivity_result

	var graph: RoadGraph = game_state.road_graph
	if graph == null:
		return DeploymentResult.failed("invalid_origin_road_node", "Deployment failed: road graph is missing.")
	if not graph.has_node(origin.road_node_id):
		return DeploymentResult.failed("invalid_origin_road_node", "Deployment failed: origin road node '%s' is not in the road graph." % origin.road_node_id)
	if not graph.has_node(destination.road_node_id):
		return DeploymentResult.failed("invalid_destination_road_node", "Deployment failed: destination road node '%s' is not in the road graph." % destination.road_node_id)
	var route: Array[String] = graph.find_route(origin.road_node_id, destination.road_node_id)
	if route.is_empty():
		return DeploymentResult.failed("no_route", "Deployment failed: no route from '%s' to '%s'." % [origin.road_node_id, destination.road_node_id])

	var convoy_movement: float = vehicle_group.get_movement_per_turn(game_state)
	var actual_launch_budget: float = minf(request.movement_budget, convoy_movement)
	var force: TravelingForce = TravelingForce.new(
		request.force_id,
		request.faction_id,
		request.origin_stronghold_id,
		request.destination_location_id,
		route,
		convoy_movement,
		"traveling_outbound"
	)
	force.soldier_group = soldier_group
	force.vehicle_group = vehicle_group
	force.movement_per_turn = convoy_movement
	game_state.add_traveling_force(force)
	var unused_movement: float = force.advance(actual_launch_budget, graph)
	var reached_destination: bool = force.travel_state == "at_destination"
	return DeploymentResult.succeeded(force.id, reached_destination, unused_movement)


static func _validate_soldiers(game_state: GameState, request: DeploymentRequest, origin: Stronghold) -> DeploymentResult:
	var seen_ids: Dictionary[String, bool] = {}
	for soldier_id: String in request.soldier_ids:
		if soldier_id.is_empty():
			return DeploymentResult.failed("empty_soldier_id", "Deployment failed: a requested soldier id is empty.")
		if seen_ids.has(soldier_id):
			return DeploymentResult.failed("duplicate_soldier_id", "Deployment failed: duplicate soldier id '%s'." % soldier_id)
		seen_ids[soldier_id] = true
		if not game_state.has_soldier(soldier_id):
			return DeploymentResult.failed("invalid_soldier", "Deployment failed: soldier '%s' does not exist." % soldier_id)
		var soldier: Soldier = game_state.get_soldier(soldier_id)
		if soldier.faction_id != request.faction_id:
			return DeploymentResult.failed("soldier_wrong_faction", "Deployment failed: soldier '%s' does not belong to faction '%s'." % [soldier_id, request.faction_id])
		if soldier.home_stronghold_id != request.origin_stronghold_id:
			return DeploymentResult.failed("soldier_wrong_home", "Deployment failed: soldier '%s' home is not origin '%s'." % [soldier_id, request.origin_stronghold_id])
		if not origin.has_soldier_id(soldier_id):
			return DeploymentResult.failed("soldier_not_at_origin", "Deployment failed: origin '%s' does not contain soldier '%s'." % [request.origin_stronghold_id, soldier_id])
	return DeploymentResult.succeeded("", false, 0.0)


static func _validate_vehicles(game_state: GameState, request: DeploymentRequest, origin: Stronghold) -> DeploymentResult:
	var seen_ids: Dictionary[String, bool] = {}
	for vehicle_id: String in request.vehicle_ids:
		if vehicle_id.is_empty():
			return DeploymentResult.failed("empty_vehicle_id", "Deployment failed: a requested vehicle id is empty.")
		if seen_ids.has(vehicle_id):
			return DeploymentResult.failed("duplicate_vehicle_id", "Deployment failed: duplicate vehicle id '%s'." % vehicle_id)
		seen_ids[vehicle_id] = true
		if not game_state.has_vehicle(vehicle_id):
			return DeploymentResult.failed("invalid_vehicle", "Deployment failed: vehicle '%s' does not exist." % vehicle_id)
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		if vehicle.faction_id != request.faction_id:
			return DeploymentResult.failed("vehicle_wrong_faction", "Deployment failed: vehicle '%s' does not belong to faction '%s'." % [vehicle_id, request.faction_id])
		if vehicle.home_stronghold_id != request.origin_stronghold_id:
			return DeploymentResult.failed("vehicle_wrong_home", "Deployment failed: vehicle '%s' home is not origin '%s'." % [vehicle_id, request.origin_stronghold_id])
		if not origin.has_vehicle_id(vehicle_id):
			return DeploymentResult.failed("vehicle_not_at_origin", "Deployment failed: origin '%s' does not contain vehicle '%s'." % [request.origin_stronghold_id, vehicle_id])
	return DeploymentResult.succeeded("", false, 0.0)


static func _validate_exclusivity(game_state: GameState, request: DeploymentRequest) -> DeploymentResult:
	for soldier_id: String in request.soldier_ids:
		if _is_soldier_in_active_force(game_state, soldier_id):
			return DeploymentResult.failed("soldier_already_deployed", "Deployment failed: soldier '%s' is already deployed in an active force." % soldier_id)
	for vehicle_id: String in request.vehicle_ids:
		if _is_vehicle_in_active_force(game_state, vehicle_id):
			return DeploymentResult.failed("vehicle_already_deployed", "Deployment failed: vehicle '%s' is already deployed in an active force." % vehicle_id)
	return DeploymentResult.succeeded("", false, 0.0)


static func _is_force_active(force: TravelingForce) -> bool:
	if force == null:
		return false
	return force.travel_state != "complete"


static func _is_soldier_in_active_force(game_state: GameState, soldier_id: String) -> bool:
	for force_id: String in game_state.traveling_forces:
		var force: TravelingForce = game_state.get_traveling_force(force_id)
		if not _is_force_active(force):
			continue
		if force.soldier_group != null and force.soldier_group.has_soldier_id(soldier_id):
			return true
	return false


static func _is_vehicle_in_active_force(game_state: GameState, vehicle_id: String) -> bool:
	for force_id: String in game_state.traveling_forces:
		var force: TravelingForce = game_state.get_traveling_force(force_id)
		if not _is_force_active(force):
			continue
		if force.vehicle_group != null and force.vehicle_group.has_vehicle_id(vehicle_id):
			return true
	return false
