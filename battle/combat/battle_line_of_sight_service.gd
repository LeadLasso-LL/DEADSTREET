class_name BattleLineOfSightService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleSpatialService := preload("res://battle/geometry/battle_spatial_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")

# Geometric contact tolerance only. Not perception range, weapon range, or cover.
const LINE_OF_SIGHT_EPSILON := 0.0001


static func check_participant_to_participant(
	battle_state: BattleState,
	source_participant_id: String,
	target_participant_id: String
) -> BattleLineOfSightResult:
	var geometry_error: BattleLineOfSightResult = _validate_geometry(
		battle_state,
		source_participant_id,
		target_participant_id
	)
	if geometry_error != null:
		return geometry_error
	if source_participant_id.is_empty() or not battle_state.has_participant(source_participant_id):
		return BattleLineOfSightResult.failed(
			"source_not_found",
			"Battle line of sight failed: source participant was not found.",
			source_participant_id,
			target_participant_id
		)
	if target_participant_id.is_empty() or not battle_state.has_participant(target_participant_id):
		return BattleLineOfSightResult.failed(
			"target_not_found",
			"Battle line of sight failed: target participant was not found.",
			source_participant_id,
			target_participant_id
		)
	var source: BattleParticipant = battle_state.get_participant(source_participant_id)
	var target: BattleParticipant = battle_state.get_participant(target_participant_id)
	if not _is_eligible_endpoint(source):
		return BattleLineOfSightResult.failed(
			"source_not_eligible",
			"Battle line of sight failed: source participant is not eligible.",
			source_participant_id,
			target_participant_id
		)
	if not _is_eligible_endpoint(target):
		return BattleLineOfSightResult.failed(
			"target_not_eligible",
			"Battle line of sight failed: target participant is not eligible.",
			source_participant_id,
			target_participant_id
		)
	return _trace_segment(
		battle_state.battlefield_geometry,
		source.battle_position,
		target.battle_position,
		source_participant_id,
		target_participant_id
	)


static func check_segment(
	battle_state: BattleState,
	start_position: Vector2,
	end_position: Vector2
) -> BattleLineOfSightResult:
	var geometry_error: BattleLineOfSightResult = _validate_geometry(battle_state, "", "")
	if geometry_error != null:
		return geometry_error
	if not BattlefieldGeometry.is_finite_point(start_position) or not BattlefieldGeometry.is_finite_point(end_position):
		return BattleLineOfSightResult.failed(
			"invalid_segment",
			"Battle line of sight failed: segment endpoints are invalid."
		)
	return _trace_segment(
		battle_state.battlefield_geometry,
		start_position,
		end_position,
		"",
		""
	)


static func _validate_geometry(
	battle_state: BattleState,
	source_participant_id: String,
	target_participant_id: String
) -> BattleLineOfSightResult:
	if battle_state == null:
		return BattleLineOfSightResult.failed(
			"null_battle_state",
			"Battle line of sight failed: battle_state is null.",
			source_participant_id,
			target_participant_id
		)
	if battle_state.battlefield_geometry == null:
		return BattleLineOfSightResult.failed(
			"missing_battlefield_geometry",
			"Battle line of sight failed: battlefield geometry is missing.",
			source_participant_id,
			target_participant_id
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleLineOfSightResult.failed(
			"invalid_battlefield_geometry",
			"Battle line of sight failed: battlefield geometry is invalid.",
			source_participant_id,
			target_participant_id
		)
	return null


static func _is_eligible_endpoint(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.is_alive:
		return false
	if not participant.has_battle_position:
		return false
	return BattlefieldGeometry.is_finite_point(participant.battle_position)


# Future elevation-aware visibility (source/target elevation_level, obstacle
# height/occupancy) belongs here. Callers should keep using this service rather
# than branching on elevation themselves. Current combat is flat level 0.
static func _trace_segment(
	geometry: BattlefieldGeometry,
	start_position: Vector2,
	end_position: Vector2,
	source_participant_id: String,
	target_participant_id: String
) -> BattleLineOfSightResult:
	var displacement: Vector2 = end_position - start_position
	if not BattlefieldGeometry.is_finite_point(displacement):
		return BattleLineOfSightResult.failed(
			"invalid_segment",
			"Battle line of sight failed: segment displacement is invalid.",
			source_participant_id,
			target_participant_id
		)
	if (
		start_position.is_equal_approx(end_position)
		or displacement.length() <= LINE_OF_SIGHT_EPSILON
	):
		return BattleLineOfSightResult.succeeded(
			true,
			source_participant_id,
			target_participant_id,
			""
		)
	var best_t: float = INF
	var best_obstacle_id: String = ""
	var obstacle_ids: Array[String] = geometry.get_sorted_obstacle_ids()
	for obstacle_id: String in obstacle_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_line_of_sight:
			continue
		if not obstacle.bounds_are_usable():
			continue
		var interior: Rect2 = _interior_bounds(obstacle.bounds)
		if not BattlefieldGeometry.rect_is_usable(interior):
			continue
		var overlap: Vector2 = BattleSpatialService.segment_aabb_overlap_t(
			start_position,
			displacement,
			interior
		)
		if overlap.x > overlap.y:
			continue
		var vis_enter: float = maxf(overlap.x, 0.0)
		var vis_exit: float = minf(overlap.y, 1.0)
		if vis_exit - vis_enter <= LINE_OF_SIGHT_EPSILON:
			continue
		var hit_t: float = vis_enter
		if hit_t < best_t and not is_equal_approx(hit_t, best_t):
			best_t = hit_t
			best_obstacle_id = obstacle_id
			continue
		if is_equal_approx(hit_t, best_t):
			if best_obstacle_id.is_empty() or obstacle_id < best_obstacle_id:
				best_t = hit_t
				best_obstacle_id = obstacle_id
	if best_obstacle_id.is_empty():
		return BattleLineOfSightResult.succeeded(
			true,
			source_participant_id,
			target_participant_id,
			""
		)
	return BattleLineOfSightResult.succeeded(
		false,
		source_participant_id,
		target_participant_id,
		best_obstacle_id
	)


static func _interior_bounds(bounds: Rect2) -> Rect2:
	return Rect2(
		bounds.position.x + LINE_OF_SIGHT_EPSILON,
		bounds.position.y + LINE_OF_SIGHT_EPSILON,
		bounds.size.x - (LINE_OF_SIGHT_EPSILON * 2.0),
		bounds.size.y - (LINE_OF_SIGHT_EPSILON * 2.0)
	)
