class_name TravelingForce
extends RefCounted

var id: String = ""
var faction_id: String = ""
var origin_location_id: String = ""
var destination_location_id: String = ""
var route_node_ids: Array[String] = []
var route_segment_index: int = 0
var distance_into_segment: float = 0.0
var movement_per_turn: float = 0.0
var travel_state: String = ""
var vehicle_group: VehicleGroup = VehicleGroup.new()
var soldier_group: SoldierGroup = SoldierGroup.new()


func _init(
	p_id: String = "",
	p_faction_id: String = "",
	p_origin_location_id: String = "",
	p_destination_location_id: String = "",
	p_route_node_ids: Array[String] = [],
	p_movement_per_turn: float = 0.0,
	p_travel_state: String = ""
) -> void:
	id = p_id
	faction_id = p_faction_id
	origin_location_id = p_origin_location_id
	destination_location_id = p_destination_location_id
	for node_id in p_route_node_ids:
		route_node_ids.append(str(node_id))
	movement_per_turn = p_movement_per_turn
	travel_state = p_travel_state


func advance(distance_budget: float, road_graph: RoadGraph) -> float:
	if distance_budget < 0.0:
		push_error("TravelingForce.advance: negative movement budget is not allowed (id='%s', budget=%s)." % [id, distance_budget])
		return distance_budget
	if travel_state != "traveling_outbound" and travel_state != "traveling_return":
		return distance_budget
	if distance_budget == 0.0:
		return 0.0
	if road_graph == null:
		push_error("TravelingForce.advance: road_graph is null (id='%s')." % id)
		return distance_budget
	if route_node_ids.size() <= 1:
		_arrive_at_destination(0.0)
		return distance_budget

	var remaining := distance_budget
	while remaining > 0.0:
		var last_segment_index := route_node_ids.size() - 2
		if route_segment_index > last_segment_index:
			_arrive_at_destination(distance_into_segment)
			break
		var from_id := route_node_ids[route_segment_index]
		var to_id := route_node_ids[route_segment_index + 1]
		var segment := road_graph.get_open_segment_between(from_id, to_id)
		if segment == null:
			push_error("TravelingForce.advance: required open segment missing between '%s' and '%s' (force='%s')." % [from_id, to_id, id])
			break
		if distance_into_segment < 0.0:
			distance_into_segment = 0.0
		var remaining_on_segment := segment.distance - distance_into_segment
		if remaining_on_segment <= 0.0:
			if route_segment_index == last_segment_index:
				_arrive_at_destination(segment.distance)
				break
			route_segment_index += 1
			distance_into_segment = 0.0
			continue
		if remaining < remaining_on_segment:
			distance_into_segment += remaining
			remaining = 0.0
			break
		remaining -= remaining_on_segment
		if route_segment_index == last_segment_index:
			_arrive_at_destination(segment.distance)
			break
		route_segment_index += 1
		distance_into_segment = 0.0
	if distance_into_segment < 0.0:
		distance_into_segment = 0.0
	return remaining


func refresh_movement_from_vehicles(game_state: GameState) -> float:
	if vehicle_group == null:
		vehicle_group = VehicleGroup.new()
	movement_per_turn = vehicle_group.get_movement_per_turn(game_state)
	return movement_per_turn


func get_total_strategic_strength(game_state: GameState) -> float:
	if soldier_group == null:
		soldier_group = SoldierGroup.new()
	return soldier_group.get_total_strategic_strength(game_state)


func get_transport_capacity(game_state: GameState) -> int:
	if vehicle_group == null:
		vehicle_group = VehicleGroup.new()
	return vehicle_group.get_total_passenger_capacity(game_state)


func has_valid_transport_capacity(game_state: GameState) -> bool:
	if soldier_group == null:
		soldier_group = SoldierGroup.new()
	return soldier_group.soldier_ids.size() <= get_transport_capacity(game_state)


func to_dict() -> Dictionary:
	var route_data: Array[String] = []
	for node_id in route_node_ids:
		route_data.append(node_id)
	if vehicle_group == null:
		vehicle_group = VehicleGroup.new()
	if soldier_group == null:
		soldier_group = SoldierGroup.new()
	return {
		"id": id,
		"faction_id": faction_id,
		"origin_location_id": origin_location_id,
		"destination_location_id": destination_location_id,
		"route_node_ids": route_data,
		"route_segment_index": route_segment_index,
		"distance_into_segment": distance_into_segment,
		"movement_per_turn": movement_per_turn,
		"travel_state": travel_state,
		"vehicle_group": vehicle_group.to_dict(),
		"soldier_group": soldier_group.to_dict(),
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	faction_id = str(data.get("faction_id", ""))
	origin_location_id = str(data.get("origin_location_id", ""))
	destination_location_id = str(data.get("destination_location_id", ""))
	route_node_ids.clear()
	var route_data: Variant = data.get("route_node_ids", [])
	if route_data is Array:
		for node_id: Variant in route_data:
			route_node_ids.append(str(node_id))
	route_segment_index = maxi(int(data.get("route_segment_index", 0)), 0)
	distance_into_segment = maxf(float(data.get("distance_into_segment", 0.0)), 0.0)
	movement_per_turn = float(data.get("movement_per_turn", 0.0))
	travel_state = str(data.get("travel_state", ""))
	if vehicle_group == null:
		vehicle_group = VehicleGroup.new()
	var group_data: Variant = data.get("vehicle_group", {})
	if group_data is Dictionary:
		vehicle_group.from_dict(group_data)
	else:
		if data.has("vehicle_group"):
			push_error("TravelingForce.from_dict: vehicle_group is not a Dictionary (id='%s'); loading empty group." % id)
		vehicle_group.from_dict({})
	if soldier_group == null:
		soldier_group = SoldierGroup.new()
	var soldier_group_data: Variant = data.get("soldier_group", {})
	if soldier_group_data is Dictionary:
		soldier_group.from_dict(soldier_group_data)
	else:
		if data.has("soldier_group"):
			push_error("TravelingForce.from_dict: soldier_group is not a Dictionary (id='%s'); loading empty group." % id)
		soldier_group.from_dict({})


func _arrive_at_destination(final_distance_into_segment: float) -> void:
	travel_state = "at_destination"
	var last_segment_index := route_node_ids.size() - 2
	if last_segment_index < 0:
		route_segment_index = 0
		distance_into_segment = 0.0
		return
	route_segment_index = last_segment_index
	distance_into_segment = maxf(final_distance_into_segment, 0.0)
