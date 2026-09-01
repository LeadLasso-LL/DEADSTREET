class_name BattleNavigationService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleSpatialService := preload("res://battle/geometry/battle_spatial_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")

# Geometric clearance only. Matches spatial collision epsilon so planned
# segments sit outside authored blockers and positioned vehicle bodies.
# Vehicle corners are queried live from BattleState; they are not written
# into BattlefieldGeometry obstacles.
const NAVIGATION_CLEARANCE_EPSILON := 0.0001


static func find_path(
	battle_state: BattleState,
	start_position: Vector2,
	destination: Vector2
) -> BattleNavigationResult:
	if battle_state == null:
		return BattleNavigationResult.failed(
			"null_battle_state",
			"Battle navigation failed: battle_state is null.",
			start_position,
			destination
		)
	if battle_state.battlefield_geometry == null:
		return BattleNavigationResult.failed(
			"missing_battlefield_geometry",
			"Battle navigation failed: battlefield geometry is missing.",
			start_position,
			destination
		)
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not geometry.is_valid():
		return BattleNavigationResult.failed(
			"invalid_battlefield_geometry",
			"Battle navigation failed: battlefield geometry is invalid.",
			start_position,
			destination
		)
	if not BattlefieldGeometry.is_finite_point(start_position):
		return BattleNavigationResult.failed(
			"invalid_start_position",
			"Battle navigation failed: start position is invalid.",
			start_position,
			destination
		)
	if not BattlefieldGeometry.is_finite_point(destination):
		return BattleNavigationResult.failed(
			"invalid_destination",
			"Battle navigation failed: destination is invalid.",
			start_position,
			destination
		)
	if not geometry.contains_point(start_position):
		return BattleNavigationResult.failed(
			"start_outside_battlefield",
			"Battle navigation failed: start position is outside the battlefield.",
			start_position,
			destination
		)
	if not geometry.contains_point(destination):
		return BattleNavigationResult.failed(
			"destination_outside_battlefield",
			"Battle navigation failed: destination is outside the battlefield.",
			start_position,
			destination
		)
	var start_obstacle_id: String = _blocking_obstacle_id(geometry, start_position)
	if not start_obstacle_id.is_empty():
		return BattleNavigationResult.failed(
			"start_inside_blocking_obstacle",
			"Battle navigation failed: start position is inside blocking obstacle '%s'." % start_obstacle_id,
			start_position,
			destination
		)
	var start_vehicle_id: String = BattleVehicleBodyService.blocking_vehicle_id_at(
		battle_state,
		start_position
	)
	if not start_vehicle_id.is_empty():
		return BattleNavigationResult.failed(
			"start_inside_vehicle",
			"Battle navigation failed: start position is inside vehicle '%s'." % start_vehicle_id,
			start_position,
			destination
		)
	var destination_obstacle_id: String = _blocking_obstacle_id(geometry, destination)
	if not destination_obstacle_id.is_empty():
		return BattleNavigationResult.failed(
			"destination_inside_blocking_obstacle",
			"Battle navigation failed: destination is inside blocking obstacle '%s'." % destination_obstacle_id,
			start_position,
			destination
		)
	var destination_vehicle_id: String = BattleVehicleBodyService.blocking_vehicle_id_at(
		battle_state,
		destination
	)
	if not destination_vehicle_id.is_empty():
		return BattleNavigationResult.failed(
			"destination_inside_vehicle",
			"Battle navigation failed: destination is inside vehicle '%s'." % destination_vehicle_id,
			start_position,
			destination
		)
	if BattleSpatialService.is_translation_clear(battle_state, start_position, destination):
		var direct_waypoints: Array[Vector2] = [destination]
		return BattleNavigationResult.succeeded(
			start_position,
			destination,
			direct_waypoints,
			false
		)
	var nodes: Array[Vector2] = _collect_nodes(battle_state, start_position, destination)
	var route: Array[Vector2] = _shortest_route(battle_state, nodes)
	if route.is_empty():
		return BattleNavigationResult.failed(
			"no_path",
			"Battle navigation failed: no legal path exists.",
			start_position,
			destination
		)
	var waypoints: Array[Vector2] = _simplify_route(battle_state, route)
	var used_detour: bool = _route_uses_detour(waypoints, destination)
	return BattleNavigationResult.succeeded(
		start_position,
		destination,
		waypoints,
		used_detour
	)


static func _collect_nodes(
	battle_state: BattleState,
	start_position: Vector2,
	destination: Vector2
) -> Array[Vector2]:
	var nodes: Array[Vector2] = []
	nodes.append(start_position)
	nodes.append(destination)
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	var obstacle_ids: Array[String] = geometry.get_sorted_obstacle_ids()
	for obstacle_id: String in obstacle_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if not obstacle.bounds_are_usable():
			continue
		var corners: Array[Vector2] = _corner_offsets(obstacle.bounds)
		for corner: Vector2 in corners:
			if not _is_legal_candidate(battle_state, corner):
				continue
			if _has_equivalent_point(nodes, corner):
				continue
			nodes.append(corner)
	var vehicle_ids: Array[String] = []
	for vehicle_id: String in battle_state.vehicles:
		vehicle_ids.append(vehicle_id)
	vehicle_ids.sort()
	for vehicle_id: String in vehicle_ids:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null:
			continue
		var vehicle_corners: PackedVector2Array = BattleVehicleBodyService.cleared_corners(
			vehicle,
			NAVIGATION_CLEARANCE_EPSILON
		)
		for corner: Vector2 in vehicle_corners:
			if not _is_legal_candidate(battle_state, corner):
				continue
			if _has_equivalent_point(nodes, corner):
				continue
			nodes.append(corner)
	return nodes


static func _corner_offsets(bounds: Rect2) -> Array[Vector2]:
	var min_x: float = bounds.position.x
	var min_y: float = bounds.position.y
	var max_x: float = bounds.position.x + bounds.size.x
	var max_y: float = bounds.position.y + bounds.size.y
	var epsilon: float = NAVIGATION_CLEARANCE_EPSILON
	var corners: Array[Vector2] = [
		Vector2(min_x - epsilon, min_y - epsilon),
		Vector2(max_x + epsilon, min_y - epsilon),
		Vector2(min_x - epsilon, max_y + epsilon),
		Vector2(max_x + epsilon, max_y + epsilon)
	]
	return corners


static func _is_legal_candidate(battle_state: BattleState, point: Vector2) -> bool:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if not BattlefieldGeometry.is_finite_point(point):
		return false
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not geometry.contains_point(point):
		return false
	if not _blocking_obstacle_id(geometry, point).is_empty():
		return false
	return BattleVehicleBodyService.blocking_vehicle_id_at(battle_state, point).is_empty()


static func _has_equivalent_point(points: Array[Vector2], candidate: Vector2) -> bool:
	for point: Vector2 in points:
		if point.is_equal_approx(candidate):
			return true
	return false


static func _shortest_route(battle_state: BattleState, nodes: Array[Vector2]) -> Array[Vector2]:
	var node_count: int = nodes.size()
	if node_count < 2:
		return []
	var adjacency: Array = _build_adjacency(battle_state, nodes)
	var distances: Array[float] = []
	var previous: Array[int] = []
	var visited: Array[bool] = []
	distances.resize(node_count)
	previous.resize(node_count)
	visited.resize(node_count)
	for i: int in range(node_count):
		distances[i] = INF
		previous[i] = -1
		visited[i] = false
	distances[0] = 0.0
	while true:
		var current: int = _next_unvisited(distances, visited)
		if current < 0:
			break
		if is_inf(distances[current]):
			break
		visited[current] = true
		if current == 1:
			break
		var neighbor_map: Dictionary = adjacency[current]
		var neighbor_ids: Array = neighbor_map.keys()
		neighbor_ids.sort()
		for neighbor_value: Variant in neighbor_ids:
			var neighbor: int = int(neighbor_value)
			if neighbor < 0 or neighbor >= node_count:
				continue
			if visited[neighbor]:
				continue
			var weight: float = float(neighbor_map[neighbor])
			if not is_finite(weight) or weight < 0.0:
				continue
			var candidate_distance: float = distances[current] + weight
			if not is_finite(candidate_distance):
				continue
			if candidate_distance < distances[neighbor] and not is_equal_approx(candidate_distance, distances[neighbor]):
				distances[neighbor] = candidate_distance
				previous[neighbor] = current
			elif is_equal_approx(candidate_distance, distances[neighbor]):
				if previous[neighbor] < 0 or current < previous[neighbor]:
					previous[neighbor] = current
	if is_inf(distances[1]) or (previous[1] < 0 and not nodes[0].is_equal_approx(nodes[1])):
		return []
	return _reconstruct_route(nodes, previous)


static func _build_adjacency(battle_state: BattleState, nodes: Array[Vector2]) -> Array:
	var node_count: int = nodes.size()
	var adjacency: Array = []
	for _i: int in range(node_count):
		var empty_neighbors: Dictionary = {}
		adjacency.append(empty_neighbors)
	for i: int in range(node_count):
		for j: int in range(i + 1, node_count):
			if nodes[i].is_equal_approx(nodes[j]):
				continue
			if not BattleSpatialService.is_translation_clear(battle_state, nodes[i], nodes[j]):
				continue
			var weight: float = nodes[i].distance_to(nodes[j])
			if not is_finite(weight) or weight < 0.0:
				continue
			var from_map: Dictionary = adjacency[i]
			var to_map: Dictionary = adjacency[j]
			from_map[j] = weight
			to_map[i] = weight
	return adjacency


static func _next_unvisited(distances: Array[float], visited: Array[bool]) -> int:
	var best_index: int = -1
	var best_distance: float = INF
	for i: int in range(distances.size()):
		if visited[i]:
			continue
		var distance: float = distances[i]
		if is_inf(distance):
			continue
		if best_index < 0:
			best_index = i
			best_distance = distance
			continue
		if distance < best_distance and not is_equal_approx(distance, best_distance):
			best_index = i
			best_distance = distance
		elif is_equal_approx(distance, best_distance) and i < best_index:
			best_index = i
	return best_index


static func _reconstruct_route(nodes: Array[Vector2], previous: Array[int]) -> Array[Vector2]:
	var chain: Array[int] = []
	var cursor: int = 1
	var guard: int = nodes.size() + 1
	while cursor >= 0 and chain.size() <= guard:
		chain.append(cursor)
		if cursor == 0:
			break
		cursor = previous[cursor]
	if chain.is_empty() or chain[chain.size() - 1] != 0:
		return []
	var route: Array[Vector2] = []
	var index: int = chain.size() - 1
	while index >= 0:
		route.append(nodes[chain[index]])
		index -= 1
	return route


static func _simplify_route(battle_state: BattleState, route: Array[Vector2]) -> Array[Vector2]:
	if route.size() <= 1:
		return []
	var simplified: Array[Vector2] = []
	var current_index: int = 0
	while current_index < route.size() - 1:
		var farthest: int = current_index + 1
		var probe: int = route.size() - 1
		while probe > current_index + 1:
			if BattleSpatialService.is_translation_clear(battle_state, route[current_index], route[probe]):
				farthest = probe
				break
			probe -= 1
		if simplified.is_empty() or not simplified[simplified.size() - 1].is_equal_approx(route[farthest]):
			simplified.append(route[farthest])
		current_index = farthest
	return simplified


static func _route_uses_detour(waypoints: Array[Vector2], destination: Vector2) -> bool:
	if waypoints.size() != 1:
		return true
	return not waypoints[0].is_equal_approx(destination)


static func _blocking_obstacle_id(geometry: BattlefieldGeometry, point: Vector2) -> String:
	var obstacle_ids: Array[String] = geometry.get_sorted_obstacle_ids()
	for obstacle_id: String in obstacle_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if obstacle.contains_point(point):
			return obstacle_id
	return ""
