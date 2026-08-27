class_name RoadGraph
extends RefCounted

var nodes: Dictionary[String, RoadNode] = {}
var segments: Dictionary[String, RoadSegment] = {}


func add_node(node: RoadNode) -> void:
	if node == null:
		push_error("RoadGraph.add_node: node is null.")
		return
	if node.id.is_empty():
		push_error("RoadGraph.add_node: node id is empty.")
		return
	if nodes.has(node.id):
		push_error("RoadGraph.add_node: duplicate node id '%s'." % node.id)
		return
	nodes[node.id] = node


func add_segment(segment: RoadSegment) -> void:
	if segment == null:
		push_error("RoadGraph.add_segment: segment is null.")
		return
	if segment.id.is_empty():
		push_error("RoadGraph.add_segment: segment id is empty.")
		return
	if segments.has(segment.id):
		push_error("RoadGraph.add_segment: duplicate segment id '%s'." % segment.id)
		return
	if segment.node_a_id.is_empty() or segment.node_b_id.is_empty():
		push_error("RoadGraph.add_segment: segment '%s' has an empty endpoint id." % segment.id)
		return
	if segment.node_a_id == segment.node_b_id:
		push_error("RoadGraph.add_segment: segment '%s' cannot connect a node to itself." % segment.id)
		return
	if not nodes.has(segment.node_a_id) or not nodes.has(segment.node_b_id):
		push_error("RoadGraph.add_segment: segment '%s' endpoints are not both in the graph." % segment.id)
		return
	var existing := _segment_between(segment.node_a_id, segment.node_b_id)
	if existing != null:
		push_error("RoadGraph.add_segment: segment '%s' duplicates existing connection '%s' between '%s' and '%s'." % [segment.id, existing.id, segment.node_a_id, segment.node_b_id])
		return
	segments[segment.id] = segment


func get_node(node_id: String) -> RoadNode:
	if nodes.has(node_id):
		return nodes[node_id]
	return null


func get_segment(segment_id: String) -> RoadSegment:
	if segments.has(segment_id):
		return segments[segment_id]
	return null


func has_node(node_id: String) -> bool:
	return nodes.has(node_id)


func has_segment(segment_id: String) -> bool:
	return segments.has(segment_id)


func get_open_segment_between(node_a_id: String, node_b_id: String) -> RoadSegment:
	var segment := _segment_between(node_a_id, node_b_id)
	if segment == null or not segment.is_open:
		return null
	return segment


func find_route(start_node_id: String, destination_node_id: String) -> Array[String]:
	var empty: Array[String] = []
	if start_node_id.is_empty() or destination_node_id.is_empty():
		return empty
	if not has_node(start_node_id) or not has_node(destination_node_id):
		return empty
	if start_node_id == destination_node_id:
		var same: Array[String] = []
		same.append(start_node_id)
		return same

	var adjacency := _open_adjacency()
	var dist: Dictionary = {}
	var prev: Dictionary = {}
	var unsettled: Dictionary = {}
	for node_id: String in nodes:
		dist[node_id] = INF
		unsettled[node_id] = true
	dist[start_node_id] = 0.0

	while not unsettled.is_empty():
		var current := _closest_unsettled_node(unsettled, dist)
		if current.is_empty() or dist[current] == INF:
			break
		unsettled.erase(current)
		if current == destination_node_id:
			break
		var neighbors: Array = adjacency.get(current, [])
		for neighbor_entry: Variant in neighbors:
			if not (neighbor_entry is Dictionary):
				continue
			var neighbor_info: Dictionary = neighbor_entry
			var neighbor_id := str(neighbor_info.get("id", ""))
			if neighbor_id.is_empty() or not unsettled.has(neighbor_id):
				continue
			var new_dist: float = dist[current] + float(neighbor_info["distance"])
			var old_dist: float = dist[neighbor_id]
			var old_prev := str(prev.get(neighbor_id, ""))
			if new_dist < old_dist or (new_dist == old_dist and not old_prev.is_empty() and current < old_prev):
				dist[neighbor_id] = new_dist
				prev[neighbor_id] = current

	if dist.get(destination_node_id, INF) == INF:
		return empty

	var route: Array[String] = []
	var walk := destination_node_id
	while walk != start_node_id:
		route.append(walk)
		if not prev.has(walk):
			return empty
		walk = str(prev[walk])
	route.append(start_node_id)
	route.reverse()
	return route


func get_route_distance(route_node_ids: Array[String]) -> float:
	if route_node_ids.size() <= 1:
		return 0.0
	var total := 0.0
	for i in range(route_node_ids.size() - 1):
		var from_id := str(route_node_ids[i])
		var to_id := str(route_node_ids[i + 1])
		var segment := get_open_segment_between(from_id, to_id)
		if segment == null:
			push_error("RoadGraph.get_route_distance: no open segment between '%s' and '%s'." % [from_id, to_id])
			return -1.0
		total += segment.distance
	return total


func to_dict() -> Dictionary:
	var node_data := {}
	for node_id: String in nodes:
		node_data[node_id] = nodes[node_id].to_dict()
	var segment_data := {}
	for segment_id: String in segments:
		segment_data[segment_id] = segments[segment_id].to_dict()
	return {
		"nodes": node_data,
		"segments": segment_data,
	}


func from_dict(data: Dictionary) -> void:
	nodes.clear()
	segments.clear()
	var node_data: Variant = data.get("nodes", {})
	if node_data is Dictionary:
		for node_id: Variant in node_data:
			var record: Variant = node_data[node_id]
			if not (record is Dictionary):
				push_error("RoadGraph.from_dict: node record '%s' is not a Dictionary; skipping." % str(node_id))
				continue
			var node := RoadNode.new()
			node.from_dict(record)
			if node.id.is_empty():
				node.id = str(node_id)
			add_node(node)
	var segment_data: Variant = data.get("segments", {})
	if not (segment_data is Dictionary):
		return
	for segment_id: Variant in segment_data:
		var record: Variant = segment_data[segment_id]
		if not (record is Dictionary):
			push_error("RoadGraph.from_dict: segment record '%s' is not a Dictionary; skipping." % str(segment_id))
			continue
		var segment := RoadSegment.new()
		segment.from_dict(record)
		if segment.id.is_empty():
			segment.id = str(segment_id)
		add_segment(segment)


func _segment_between(node_a_id: String, node_b_id: String) -> RoadSegment:
	for segment_id: String in segments:
		var segment := segments[segment_id]
		if _segment_connects(segment, node_a_id, node_b_id):
			return segment
	return null


func _segment_connects(segment: RoadSegment, node_a_id: String, node_b_id: String) -> bool:
	return (
		(segment.node_a_id == node_a_id and segment.node_b_id == node_b_id)
		or (segment.node_a_id == node_b_id and segment.node_b_id == node_a_id)
	)


func _open_adjacency() -> Dictionary:
	var adjacency := {}
	var segment_ids: Array[String] = []
	for segment_id: String in segments:
		segment_ids.append(segment_id)
	segment_ids.sort()
	for segment_id in segment_ids:
		var segment := segments[segment_id]
		if not segment.is_open:
			continue
		_add_adjacency_edge(adjacency, segment.node_a_id, segment.node_b_id, segment.distance, segment.id)
		_add_adjacency_edge(adjacency, segment.node_b_id, segment.node_a_id, segment.distance, segment.id)
	for node_id: Variant in adjacency:
		var neighbors: Array = adjacency[node_id]
		neighbors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return str(a["id"]) < str(b["id"])
		)
	return adjacency


func _add_adjacency_edge(
	adjacency: Dictionary,
	from_id: String,
	to_id: String,
	distance: float,
	segment_id: String
) -> void:
	if from_id.is_empty() or to_id.is_empty():
		return
	var neighbors: Array = adjacency.get(from_id, [])
	neighbors.append({
		"id": to_id,
		"distance": distance,
		"segment_id": segment_id,
	})
	adjacency[from_id] = neighbors


func _closest_unsettled_node(unsettled: Dictionary, dist: Dictionary) -> String:
	var best_id := ""
	var best_dist := INF
	for node_id: Variant in unsettled:
		var candidate := str(node_id)
		var candidate_dist: float = dist[candidate]
		if best_id.is_empty() or candidate_dist < best_dist or (candidate_dist == best_dist and candidate < best_id):
			best_id = candidate
			best_dist = candidate_dist
	return best_id
