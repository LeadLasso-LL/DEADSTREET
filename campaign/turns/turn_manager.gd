class_name TurnManager
extends RefCounted

const ForceTurnResult := preload("res://campaign/turns/force_turn_result.gd")
const TurnResult := preload("res://campaign/turns/turn_result.gd")
const MissionService := preload("res://campaign/missions/mission_service.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")


static func advance_to_next_turn(game_state: GameState) -> TurnResult:
	if game_state == null:
		return TurnResult.failed("null_game_state", "Turn advancement failed: game_state is null.")
	if game_state.current_turn < 1:
		return TurnResult.failed(
			"invalid_current_turn",
			"Turn advancement failed: current_turn '%s' is invalid." % game_state.current_turn,
			game_state.current_turn,
			game_state.current_turn
		)

	var turn_before: int = game_state.current_turn
	game_state.current_turn = turn_before + 1
	var turn_after: int = game_state.current_turn

	# Future ordered phases (not implemented yet):
	# 1. income / resource production
	# 2. expenses / upkeep / bribes
	# 3. police disruption
	var force_results: Array[ForceTurnResult] = _process_force_movement(game_state)
	var mission_results: Array[MissionResult] = MissionService.sync_all_arrivals(game_state)
	return TurnResult.succeeded(turn_before, turn_after, force_results, mission_results)


static func _process_force_movement(game_state: GameState) -> Array[ForceTurnResult]:
	var results: Array[ForceTurnResult] = []
	var force_ids: Array[String] = []
	for force_id: String in game_state.traveling_forces:
		force_ids.append(force_id)
	force_ids.sort()
	for force_id: String in force_ids:
		var force: TravelingForce = game_state.get_traveling_force(force_id)
		if force == null:
			results.append(
				ForceTurnResult.failed(
					"invalid_force",
					"Turn force processing failed: force '%s' is missing." % force_id,
					force_id
				)
			)
			continue
		results.append(_process_one_force(game_state, force))
	return results


static func _process_one_force(game_state: GameState, force: TravelingForce) -> ForceTurnResult:
	var state_before: String = force.travel_state
	if state_before == "complete":
		return ForceTurnResult.succeeded(
			force.id,
			0.0,
			0.0,
			force.movement_remaining,
			state_before,
			force.travel_state,
			false
		)

	var movement_refreshed: float = force.refresh_turn_movement()
	if state_before != "traveling_outbound" and state_before != "traveling_return":
		return ForceTurnResult.succeeded(
			force.id,
			movement_refreshed,
			0.0,
			force.movement_remaining,
			state_before,
			force.travel_state,
			false
		)

	var unused_movement: float = force.advance(force.movement_remaining, game_state.road_graph)
	force.movement_remaining = unused_movement
	var movement_spent: float = movement_refreshed - force.movement_remaining
	if movement_spent < 0.0:
		movement_spent = 0.0
	if movement_spent > movement_refreshed:
		movement_spent = movement_refreshed
	var reached_destination: bool = force.travel_state == "at_destination"
	var processing_error_code: String = ""
	var processing_error_message: String = ""
	if force.movement_remaining > 0.0 and not reached_destination:
		processing_error_code = _detect_advance_failure(force, game_state.road_graph)
		if processing_error_code == "null_road_graph":
			processing_error_message = "Turn force processing failed: road graph is missing (force='%s')." % force.id
		elif processing_error_code == "missing_open_segment":
			var from_id: String = ""
			var to_id: String = ""
			if force.route_segment_index >= 0 and force.route_segment_index + 1 < force.route_node_ids.size():
				from_id = str(force.route_node_ids[force.route_segment_index])
				to_id = str(force.route_node_ids[force.route_segment_index + 1])
			processing_error_message = (
				"Turn force processing failed: required open segment missing between '%s' and '%s' (force='%s')."
				% [from_id, to_id, force.id]
			)
	if not processing_error_code.is_empty():
		return ForceTurnResult.failed(
			processing_error_code,
			processing_error_message,
			force.id,
			movement_refreshed,
			movement_spent,
			force.movement_remaining,
			state_before,
			force.travel_state,
			reached_destination
		)
	return ForceTurnResult.succeeded(
		force.id,
		movement_refreshed,
		movement_spent,
		force.movement_remaining,
		state_before,
		force.travel_state,
		reached_destination
	)


static func _detect_advance_failure(force: TravelingForce, road_graph: RoadGraph) -> String:
	if force.travel_state != "traveling_outbound" and force.travel_state != "traveling_return":
		return ""
	if force.route_node_ids.size() <= 1:
		return ""
	var last_segment_index: int = force.route_node_ids.size() - 2
	if force.route_segment_index > last_segment_index:
		return ""
	if road_graph == null:
		return "null_road_graph"
	if force.route_segment_index < 0 or force.route_segment_index + 1 >= force.route_node_ids.size():
		return "missing_open_segment"
	var from_id: String = str(force.route_node_ids[force.route_segment_index])
	var to_id: String = str(force.route_node_ids[force.route_segment_index + 1])
	if road_graph.get_open_segment_between(from_id, to_id) == null:
		return "missing_open_segment"
	return ""
