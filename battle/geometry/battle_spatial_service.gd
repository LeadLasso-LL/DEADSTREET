class_name BattleSpatialService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleSpatialResult := preload("res://battle/geometry/battle_spatial_result.gd")

# Participants are treated as points at battle_position. A later body radius can
# be introduced here without changing movement intent or runtime architecture.
const COLLISION_EPSILON := 0.0001
const NO_HIT := INF


static func resolve_translation(
	battle_state: BattleState,
	start_position: Vector2,
	requested_displacement: Vector2
) -> BattleSpatialResult:
	if battle_state == null:
		return BattleSpatialResult.failed(
			"null_battle_state",
			"Battle spatial resolution failed: battle_state is null.",
			start_position,
			requested_displacement
		)
	if battle_state.battlefield_geometry == null:
		return BattleSpatialResult.failed(
			"missing_battlefield_geometry",
			"Battle spatial resolution failed: battlefield geometry is missing.",
			start_position,
			requested_displacement
		)
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not geometry.is_valid():
		return BattleSpatialResult.failed(
			"invalid_battlefield_geometry",
			"Battle spatial resolution failed: battlefield geometry is invalid.",
			start_position,
			requested_displacement
		)
	if not BattlefieldGeometry.is_finite_point(start_position):
		return BattleSpatialResult.failed(
			"invalid_start_position",
			"Battle spatial resolution failed: start position is invalid.",
			start_position,
			requested_displacement
		)
	if not BattlefieldGeometry.is_finite_point(requested_displacement):
		return BattleSpatialResult.failed(
			"invalid_displacement",
			"Battle spatial resolution failed: requested displacement is invalid.",
			start_position,
			requested_displacement
		)
	if not geometry.contains_point(start_position):
		return BattleSpatialResult.failed(
			"start_outside_battlefield",
			"Battle spatial resolution failed: start position is outside the battlefield.",
			start_position,
			requested_displacement
		)
	var inside_obstacle_id: String = _blocking_obstacle_at(geometry, start_position)
	if not inside_obstacle_id.is_empty():
		return BattleSpatialResult.failed(
			"start_inside_blocking_obstacle",
			"Battle spatial resolution failed: start position is inside blocking obstacle '%s'." % inside_obstacle_id,
			start_position,
			requested_displacement,
			inside_obstacle_id
		)
	if requested_displacement.is_equal_approx(Vector2.ZERO):
		return BattleSpatialResult.succeeded(
			start_position,
			requested_displacement,
			Vector2.ZERO,
			start_position,
			false,
			""
		)
	return _resolve_legal_translation(geometry, start_position, requested_displacement)


# Raw AABB slab overlap for start + t * displacement.
# Returns Vector2(t_enter, t_exit). A miss is encoded as t_enter > t_exit.
static func segment_aabb_overlap_t(
	start_position: Vector2,
	displacement: Vector2,
	rect: Rect2
) -> Vector2:
	var miss: Vector2 = Vector2(INF, -INF)
	if not BattlefieldGeometry.rect_is_usable(rect):
		return miss
	var min_x: float = rect.position.x
	var min_y: float = rect.position.y
	var max_x: float = rect.position.x + rect.size.x
	var max_y: float = rect.position.y + rect.size.y
	var t_enter: float = -INF
	var t_exit: float = INF
	if is_zero_approx(displacement.x):
		if start_position.x < min_x or start_position.x > max_x:
			return miss
	else:
		var t1: float = (min_x - start_position.x) / displacement.x
		var t2: float = (max_x - start_position.x) / displacement.x
		if t1 > t2:
			var swap_t: float = t1
			t1 = t2
			t2 = swap_t
		t_enter = maxf(t_enter, t1)
		t_exit = minf(t_exit, t2)
	if is_zero_approx(displacement.y):
		if start_position.y < min_y or start_position.y > max_y:
			return miss
	else:
		var t1y: float = (min_y - start_position.y) / displacement.y
		var t2y: float = (max_y - start_position.y) / displacement.y
		if t1y > t2y:
			var swap_y: float = t1y
			t1y = t2y
			t2y = swap_y
		t_enter = maxf(t_enter, t1y)
		t_exit = minf(t_exit, t2y)
	if t_enter > t_exit:
		return miss
	return Vector2(t_enter, t_exit)


static func is_translation_clear(
	battle_state: BattleState,
	start_position: Vector2,
	destination: Vector2
) -> bool:
	if not BattlefieldGeometry.is_finite_point(start_position):
		return false
	if not BattlefieldGeometry.is_finite_point(destination):
		return false
	var displacement: Vector2 = destination - start_position
	if not BattlefieldGeometry.is_finite_point(displacement):
		return false
	var result: BattleSpatialResult = resolve_translation(
		battle_state,
		start_position,
		displacement
	)
	if result == null or not result.success:
		return false
	if result.was_blocked:
		return false
	return result.final_position.is_equal_approx(destination)


static func _resolve_legal_translation(
	geometry: BattlefieldGeometry,
	start_position: Vector2,
	requested_displacement: Vector2
) -> BattleSpatialResult:
	var requested_end: Vector2 = start_position + requested_displacement
	var best_t: float = 1.0
	var best_obstacle_id: String = ""
	var blocked_by_boundary: bool = false
	var boundary_t: float = _battlefield_exit_t(geometry, start_position, requested_displacement)
	if boundary_t < 1.0:
		best_t = boundary_t
		blocked_by_boundary = true
	var obstacle_ids: Array[String] = geometry.get_sorted_obstacle_ids()
	for obstacle_id: String in obstacle_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if not obstacle.bounds_are_usable():
			continue
		var hit_t: float = _segment_rect_entry_t(start_position, requested_displacement, obstacle.bounds)
		if is_inf(hit_t):
			continue
		if hit_t < 0.0 or hit_t > 1.0:
			continue
		if _is_earlier_hit(hit_t, obstacle_id, best_t, best_obstacle_id, blocked_by_boundary):
			best_t = hit_t
			best_obstacle_id = obstacle_id
			blocked_by_boundary = false
	var was_blocked: bool = blocked_by_boundary or not best_obstacle_id.is_empty()
	var final_position: Vector2 = requested_end
	if was_blocked:
		final_position = _position_at_hit(
			geometry,
			start_position,
			requested_displacement,
			best_t,
			best_obstacle_id
		)
	final_position = _clamp_to_battlefield(geometry, final_position)
	if not geometry.contains_point(final_position):
		final_position = start_position
	if not _blocking_obstacle_at(geometry, final_position).is_empty():
		final_position = start_position
	var resolved_displacement: Vector2 = final_position - start_position
	if not BattlefieldGeometry.is_finite_point(resolved_displacement) or not BattlefieldGeometry.is_finite_point(final_position):
		return BattleSpatialResult.succeeded(
			start_position,
			requested_displacement,
			Vector2.ZERO,
			start_position,
			true,
			best_obstacle_id
		)
	return BattleSpatialResult.succeeded(
		start_position,
		requested_displacement,
		resolved_displacement,
		final_position,
		was_blocked,
		best_obstacle_id
	)


static func _is_earlier_hit(
	hit_t: float,
	obstacle_id: String,
	best_t: float,
	best_obstacle_id: String,
	blocked_by_boundary: bool
) -> bool:
	if hit_t < best_t and not is_equal_approx(hit_t, best_t):
		return true
	if not is_equal_approx(hit_t, best_t):
		return false
	if blocked_by_boundary or best_obstacle_id.is_empty():
		return true
	return obstacle_id < best_obstacle_id


static func _position_at_hit(
	geometry: BattlefieldGeometry,
	start_position: Vector2,
	requested_displacement: Vector2,
	hit_t: float,
	obstacle_id: String
) -> Vector2:
	var t: float = hit_t
	if t < 0.0:
		t = 0.0
	if t > 1.0:
		t = 1.0
	if not obstacle_id.is_empty():
		var path_length: float = requested_displacement.length()
		if not is_finite(path_length) or path_length <= COLLISION_EPSILON:
			return start_position
		var t_back: float = COLLISION_EPSILON / path_length
		t -= t_back
		if t < 0.0:
			t = 0.0
	var point: Vector2 = start_position + requested_displacement * t
	if not obstacle_id.is_empty():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle != null and obstacle.contains_point(point):
			return start_position
	return point


static func _battlefield_exit_t(
	geometry: BattlefieldGeometry,
	start_position: Vector2,
	displacement: Vector2
) -> float:
	var requested_end: Vector2 = start_position + displacement
	if geometry.contains_point(requested_end):
		return 1.0
	var t: float = 1.0
	if displacement.x > 0.0:
		t = minf(t, (geometry.width - start_position.x) / displacement.x)
	elif displacement.x < 0.0:
		t = minf(t, (0.0 - start_position.x) / displacement.x)
	if displacement.y > 0.0:
		t = minf(t, (geometry.height - start_position.y) / displacement.y)
	elif displacement.y < 0.0:
		t = minf(t, (0.0 - start_position.y) / displacement.y)
	if t < 0.0:
		return 0.0
	if t > 1.0:
		return 1.0
	return t


static func _segment_rect_entry_t(
	start_position: Vector2,
	displacement: Vector2,
	rect: Rect2
) -> float:
	var overlap: Vector2 = segment_aabb_overlap_t(start_position, displacement, rect)
	var t_enter: float = overlap.x
	var t_exit: float = overlap.y
	if t_enter > t_exit:
		return NO_HIT
	if t_exit < 0.0:
		return NO_HIT
	if t_enter > 1.0:
		return NO_HIT
	if t_enter <= 0.0:
		return 0.0
	return t_enter


static func _blocking_obstacle_at(geometry: BattlefieldGeometry, point: Vector2) -> String:
	var obstacle_ids: Array[String] = geometry.get_sorted_obstacle_ids()
	for obstacle_id: String in obstacle_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if obstacle.contains_point(point):
			return obstacle_id
	return ""


static func _clamp_to_battlefield(geometry: BattlefieldGeometry, point: Vector2) -> Vector2:
	if not BattlefieldGeometry.is_finite_point(point):
		return point
	return Vector2(
		clampf(point.x, 0.0, geometry.width),
		clampf(point.y, 0.0, geometry.height)
	)
