class_name BattleNavigationService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleSpatialService := preload("res://battle/geometry/battle_spatial_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleNavigationGraph := preload("res://battle/navigation/battle_navigation_graph.gd")

# Geometric clearance only. Matches spatial collision epsilon so planned
# segments sit outside authored blockers and positioned vehicle bodies.
# Vehicle corners are queried live from BattleState; they are not written
# into BattlefieldGeometry obstacles.
const NAVIGATION_CLEARANCE_EPSILON := 0.0001


static func is_reachable(
	battle_state: BattleState,
	start_position: Vector2,
	destination: Vector2
) -> bool:
	if battle_state == null:
		return false
	var cached: int = battle_state.nav_cache_lookup(start_position, destination)
	if cached >= 0:
		return cached == 1
	var result: BattleNavigationResult = find_path(battle_state, start_position, destination)
	var reachable: bool = result != null and result.success
	battle_state.nav_cache_store(start_position, destination, reachable)
	return reachable


static func prewarm(battle_state: BattleState) -> void:
	_ensure_static_graph(battle_state)


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
	var graph: BattleNavigationGraph = _ensure_static_graph(battle_state)
	if graph == null:
		return BattleNavigationResult.failed(
			"no_path",
			"Battle navigation failed: no legal path exists.",
			start_position,
			destination
		)
	var route: Array[Vector2] = _query_shortest_route(
		battle_state,
		graph,
		start_position,
		destination
	)
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


static func _ensure_static_graph(battle_state: BattleState) -> BattleNavigationGraph:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return null
	if not battle_state.battlefield_geometry.is_valid():
		return null
	var stamp: String = battle_state.navigation_topology_stamp()
	var graph: BattleNavigationGraph = battle_state.get_static_nav_graph()
	if graph != null and graph.stamp == stamp:
		return graph
	graph = BattleNavigationGraph.new()
	graph.stamp = stamp
	graph.nodes = _collect_static_nodes(battle_state)
	graph.blocking_rects = _collect_blocking_rects(battle_state)
	graph.adjacency = _build_adjacency(battle_state, graph.nodes, graph.blocking_rects)
	graph.build_count = battle_state.get_static_nav_build_count() + 1
	battle_state.increment_static_nav_build_count()
	battle_state.set_static_nav_graph(graph)
	return graph


static func _collect_static_nodes(battle_state: BattleState) -> Array[Vector2]:
	var nodes: Array[Vector2] = []
	if battle_state == null or battle_state.battlefield_geometry == null:
		return nodes
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


static func _query_shortest_route(
	battle_state: BattleState,
	graph: BattleNavigationGraph,
	start_position: Vector2,
	destination: Vector2
) -> Array[Vector2]:
	var nodes: Array[Vector2] = []
	nodes.append(start_position)
	nodes.append(destination)
	var static_to_query: Array[int] = []
	static_to_query.resize(graph.nodes.size())
	var static_index: int = 0
	while static_index < graph.nodes.size():
		var static_point: Vector2 = graph.nodes[static_index]
		if (
			static_point.is_equal_approx(start_position)
			or static_point.is_equal_approx(destination)
		):
			static_to_query[static_index] = -1
			static_index += 1
			continue
		static_to_query[static_index] = nodes.size()
		nodes.append(static_point)
		static_index += 1
	var adjacency: Array = _empty_adjacency(nodes.size())
	var i: int = 0
	while i < graph.nodes.size():
		var qi: int = static_to_query[i]
		if qi < 0:
			i += 1
			continue
		var from_map: Dictionary = graph.adjacency[i]
		var neighbor_ids: Array = from_map.keys()
		for neighbor_value: Variant in neighbor_ids:
			var j: int = int(neighbor_value)
			if j < 0 or j >= static_to_query.size():
				continue
			var qj: int = static_to_query[j]
			if qj < 0:
				continue
			adjacency[qi][qj] = from_map[j]
		i += 1
	var query_index: int = 2
	while query_index < nodes.size():
		var static_point: Vector2 = nodes[query_index]
		if _segment_open(battle_state, graph.blocking_rects, start_position, static_point):
			var start_weight: float = start_position.distance_to(static_point)
			if is_finite(start_weight) and start_weight >= 0.0:
				adjacency[0][query_index] = start_weight
				adjacency[query_index][0] = start_weight
		if _segment_open(battle_state, graph.blocking_rects, destination, static_point):
			var dest_weight: float = destination.distance_to(static_point)
			if is_finite(dest_weight) and dest_weight >= 0.0:
				adjacency[1][query_index] = dest_weight
				adjacency[query_index][1] = dest_weight
		query_index += 1
	return _shortest_route(nodes, adjacency)


static func _empty_adjacency(node_count: int) -> Array:
	var adjacency: Array = []
	var index: int = 0
	while index < node_count:
		var empty_neighbors: Dictionary = {}
		adjacency.append(empty_neighbors)
		index += 1
	return adjacency


static func _shortest_route(nodes: Array[Vector2], adjacency: Array) -> Array[Vector2]:
	var node_count: int = nodes.size()
	if node_count < 2:
		return []
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


static func _collect_blocking_rects(battle_state: BattleState) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	if battle_state == null or battle_state.battlefield_geometry == null:
		return rects
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if not obstacle.bounds_are_usable():
			continue
		rects.append(obstacle.bounds)
	return rects


static func _segment_open(
	battle_state: BattleState,
	blocking_rects: Array[Rect2],
	start_position: Vector2,
	destination: Vector2
) -> bool:
	if start_position.is_equal_approx(destination):
		return true
	var displacement: Vector2 = destination - start_position
	if not BattlefieldGeometry.is_finite_point(displacement):
		return false
	for rect: Rect2 in blocking_rects:
		if _segment_hits_rect(start_position, displacement, rect):
			return false
	if battle_state == null:
		return true
	for vehicle_id: String in battle_state.vehicles:
		var vehicle: BattleVehicle = battle_state.vehicles[vehicle_id]
		var hit_t: float = BattleVehicleBodyService.segment_entry_t(
			vehicle,
			start_position,
			displacement
		)
		if is_inf(hit_t):
			continue
		if hit_t < 0.0 or hit_t > 1.0:
			continue
		return false
	return true


static func _segment_hits_rect(start_position: Vector2, displacement: Vector2, rect: Rect2) -> bool:
	var overlap: Vector2 = BattleSpatialService.segment_aabb_overlap_t(start_position, displacement, rect)
	var t_enter: float = overlap.x
	var t_exit: float = overlap.y
	if t_enter > t_exit:
		return false
	if t_exit < 0.0:
		return false
	if t_enter > 1.0:
		return false
	if t_enter <= 0.0:
		return true
	return t_enter >= 0.0 and t_enter <= 1.0


static func _build_adjacency(
	battle_state: BattleState,
	nodes: Array[Vector2],
	blocking_rects: Array[Rect2]
) -> Array:
	var node_count: int = nodes.size()
	var adjacency: Array = _empty_adjacency(node_count)
	for i: int in range(node_count):
		for j: int in range(i + 1, node_count):
			if nodes[i].is_equal_approx(nodes[j]):
				continue
			if not _segment_open(battle_state, blocking_rects, nodes[i], nodes[j]):
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
	var blocking_rects: Array[Rect2] = _collect_blocking_rects(battle_state)
	var simplified: Array[Vector2] = []
	var current_index: int = 0
	while current_index < route.size() - 1:
		var farthest: int = current_index + 1
		var probe: int = route.size() - 1
		while probe > current_index + 1:
			if _segment_open(battle_state, blocking_rects, route[current_index], route[probe]):
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
