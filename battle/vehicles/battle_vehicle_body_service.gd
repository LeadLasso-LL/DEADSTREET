class_name BattleVehicleBodyService
extends RefCounted

# Authoritative derived tactical vehicle body.
# Position + facing + physical profile produce one oriented footprint.
# Renderer, placement, movement, and cover must use these queries.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleVehiclePhysicalCatalog := preload("res://battle/vehicles/battle_vehicle_physical_catalog.gd")
const BattleVehiclePhysicalProfile := preload("res://battle/vehicles/battle_vehicle_physical_profile.gd")

const PROJECTION_EPSILON := 0.0001
const NO_HIT := INF


static func profile_for_vehicle(vehicle: BattleVehicle) -> BattleVehiclePhysicalProfile:
	if vehicle == null:
		return null
	return BattleVehiclePhysicalCatalog.get_profile(vehicle.vehicle_type_id)


static func has_usable_pose(vehicle: BattleVehicle) -> bool:
	if vehicle == null:
		return false
	if not vehicle.has_battle_position:
		return false
	if not BattlefieldGeometry.is_finite_point(vehicle.battle_position):
		return false
	return vehicle.has_valid_orientation()


static func world_to_local(world_point: Vector2, position: Vector2, facing: Vector2) -> Vector2:
	var delta: Vector2 = world_point - position
	return delta.rotated(-facing.angle())


static func local_to_world(local_point: Vector2, position: Vector2, facing: Vector2) -> Vector2:
	return position + local_point.rotated(facing.angle())


static func local_aabb(profile: BattleVehiclePhysicalProfile) -> Rect2:
	if profile == null or not profile.is_valid():
		return Rect2()
	return Rect2(-profile.half_length(), -profile.half_width(), profile.length, profile.width)


static func world_corners(vehicle: BattleVehicle) -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	if not has_usable_pose(vehicle):
		return corners
	var profile: BattleVehiclePhysicalProfile = profile_for_vehicle(vehicle)
	if profile == null:
		return corners
	return corners_for_pose(vehicle.battle_position, vehicle.facing_direction, profile)


static func cleared_corners(vehicle: BattleVehicle, epsilon: float) -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	if not has_usable_pose(vehicle):
		return corners
	var profile: BattleVehiclePhysicalProfile = profile_for_vehicle(vehicle)
	if profile == null:
		return corners
	var clearance: float = 0.0
	if is_finite(epsilon) and epsilon > 0.0:
		clearance = epsilon
	var hl: float = profile.half_length() + clearance
	var hw: float = profile.half_width() + clearance
	var locals: Array[Vector2] = [
		Vector2(hl, -hw),
		Vector2(hl, hw),
		Vector2(-hl, hw),
		Vector2(-hl, -hw),
	]
	for local_point: Vector2 in locals:
		corners.append(local_to_world(local_point, vehicle.battle_position, vehicle.facing_direction))
	return corners


static func corners_for_pose(
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile
) -> PackedVector2Array:
	var corners: PackedVector2Array = PackedVector2Array()
	if profile == null or not profile.is_valid():
		return corners
	if not BattlefieldGeometry.is_finite_point(position):
		return corners
	if not _facing_is_usable(facing):
		return corners
	var hl: float = profile.half_length()
	var hw: float = profile.half_width()
	var locals: Array[Vector2] = [
		Vector2(hl, -hw),
		Vector2(hl, hw),
		Vector2(-hl, hw),
		Vector2(-hl, -hw),
	]
	for local_point: Vector2 in locals:
		corners.append(local_to_world(local_point, position, facing))
	return corners


static func contains_point(vehicle: BattleVehicle, point: Vector2) -> bool:
	if not has_usable_pose(vehicle):
		return false
	var profile: BattleVehiclePhysicalProfile = profile_for_vehicle(vehicle)
	if profile == null:
		return false
	return pose_contains_point(vehicle.battle_position, vehicle.facing_direction, profile, point)


static func pose_contains_point(
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile,
	point: Vector2
) -> bool:
	if profile == null or not profile.is_valid():
		return false
	if not BattlefieldGeometry.is_finite_point(position) or not BattlefieldGeometry.is_finite_point(point):
		return false
	if not _facing_is_usable(facing):
		return false
	var local_point: Vector2 = world_to_local(point, position, facing)
	var aabb: Rect2 = local_aabb(profile)
	return (
		local_point.x >= aabb.position.x
		and local_point.y >= aabb.position.y
		and local_point.x <= aabb.position.x + aabb.size.x
		and local_point.y <= aabb.position.y + aabb.size.y
	)


static func bodies_intersect(a: BattleVehicle, b: BattleVehicle) -> bool:
	if a == null or b == null:
		return false
	if not has_usable_pose(a) or not has_usable_pose(b):
		return false
	var profile_a: BattleVehiclePhysicalProfile = profile_for_vehicle(a)
	var profile_b: BattleVehiclePhysicalProfile = profile_for_vehicle(b)
	if profile_a == null or profile_b == null:
		return false
	return _sat_intersects(
		corners_for_pose(a.battle_position, a.facing_direction, profile_a),
		corners_for_pose(b.battle_position, b.facing_direction, profile_b)
	)


static func pose_intersects_vehicle(
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile,
	other: BattleVehicle
) -> bool:
	if other == null or not has_usable_pose(other):
		return false
	var other_profile: BattleVehiclePhysicalProfile = profile_for_vehicle(other)
	if other_profile == null:
		return false
	return _sat_intersects(
		corners_for_pose(position, facing, profile),
		corners_for_pose(other.battle_position, other.facing_direction, other_profile)
	)


static func pose_intersects_rect(
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile,
	rect: Rect2
) -> bool:
	if not BattlefieldGeometry.rect_is_usable(rect):
		return false
	var obb: PackedVector2Array = corners_for_pose(position, facing, profile)
	if obb.size() != 4:
		return false
	var aabb: PackedVector2Array = PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y),
	])
	return _sat_intersects(obb, aabb)


static func pose_contained_in_rect(
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile,
	rect: Rect2
) -> bool:
	var corners: PackedVector2Array = corners_for_pose(position, facing, profile)
	if corners.size() != 4:
		return false
	for corner: Vector2 in corners:
		if not BattlefieldGeometry.rect_contains_point(rect, corner):
			return false
	return true


static func segment_entry_t(
	vehicle: BattleVehicle,
	start_position: Vector2,
	displacement: Vector2
) -> float:
	if not has_usable_pose(vehicle):
		return NO_HIT
	var profile: BattleVehiclePhysicalProfile = profile_for_vehicle(vehicle)
	if profile == null:
		return NO_HIT
	if not BattlefieldGeometry.is_finite_point(start_position):
		return NO_HIT
	if not BattlefieldGeometry.is_finite_point(displacement):
		return NO_HIT
	var facing: Vector2 = vehicle.facing_direction
	var local_start: Vector2 = world_to_local(start_position, vehicle.battle_position, facing)
	var local_end: Vector2 = world_to_local(start_position + displacement, vehicle.battle_position, facing)
	var local_disp: Vector2 = local_end - local_start
	return _local_aabb_entry_t(local_start, local_disp, local_aabb(profile))


static func blocking_vehicle_id_at(battle_state: BattleState, point: Vector2) -> String:
	if battle_state == null or not BattlefieldGeometry.is_finite_point(point):
		return ""
	for vehicle_id: String in _sorted_vehicle_ids(battle_state):
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if contains_point(vehicle, point):
			return vehicle_id
	return ""


static func get_placement_error(
	battle_state: BattleState,
	vehicle_id: String,
	position: Vector2,
	facing: Vector2
) -> String:
	if battle_state == null:
		return "null_battle_state"
	if vehicle_id.is_empty() or not battle_state.has_vehicle(vehicle_id):
		return "unknown_vehicle"
	var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
	if vehicle == null:
		return "unknown_vehicle"
	if not BattlefieldGeometry.is_finite_point(position):
		return "invalid_position"
	if not _facing_is_usable(facing):
		return "invalid_orientation"
	var profile: BattleVehiclePhysicalProfile = profile_for_vehicle(vehicle)
	if profile == null:
		return "missing_profile"
	if battle_state.battlefield_geometry == null or not battle_state.battlefield_geometry.is_valid():
		return "missing_battlefield_geometry"
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not pose_contained_in_rect(position, facing, profile, geometry.bounds()):
		return "outside_battlefield"
	var zone_rect: Rect2 = _side_deployment_rect(battle_state, vehicle.side_id)
	if not BattlefieldGeometry.rect_is_usable(zone_rect):
		return "unknown_side"
	if not _pose_contained_in_side_deployment(
		battle_state,
		vehicle.side_id,
		position,
		facing,
		profile
	):
		return "outside_deployment_zone"
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if not obstacle.bounds_are_usable():
			continue
		if pose_intersects_rect(position, facing, profile, obstacle.bounds):
			return "inside_blocking_obstacle"
	for other_id: String in _sorted_vehicle_ids(battle_state):
		if other_id == vehicle_id:
			continue
		var other: BattleVehicle = battle_state.get_vehicle(other_id)
		if pose_intersects_vehicle(position, facing, profile, other):
			return "overlaps_vehicle"
	for participant_id: String in _sorted_participant_ids(battle_state):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			continue
		if not BattlefieldGeometry.is_finite_point(participant.battle_position):
			continue
		if pose_contains_point(position, facing, profile, participant.battle_position):
			return "overlaps_participant"
	return ""


static func _local_aabb_entry_t(
	start_position: Vector2,
	displacement: Vector2,
	rect: Rect2
) -> float:
	var overlap: Vector2 = _segment_aabb_overlap_t(start_position, displacement, rect)
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


static func _segment_aabb_overlap_t(
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


static func _side_deployment_rect(battle_state: BattleState, side_id: String) -> Rect2:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return Rect2()
	if side_id == battle_state.attacker_side_id:
		return battle_state.battlefield_geometry.attacker_deployment_rect
	if side_id == battle_state.defender_side_id:
		return battle_state.battlefield_geometry.defender_deployment_rect
	return Rect2()


static func _pose_contained_in_side_deployment(
	battle_state: BattleState,
	side_id: String,
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile
) -> bool:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return false
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	var use_pockets: bool = false
	if side_id == battle_state.attacker_side_id:
		use_pockets = geometry.has_attacker_deployment_pockets()
	elif side_id == battle_state.defender_side_id:
		use_pockets = geometry.has_defender_deployment_pockets()
	else:
		return false
	if not use_pockets:
		return pose_contained_in_rect(position, facing, profile, _side_deployment_rect(battle_state, side_id))
	var corners: PackedVector2Array = corners_for_pose(position, facing, profile)
	if corners.size() != 4:
		return false
	for corner: Vector2 in corners:
		if side_id == battle_state.attacker_side_id:
			if not geometry.attacker_deployment_contains(corner):
				return false
		elif not geometry.defender_deployment_contains(corner):
			return false
	return true


static func _facing_is_usable(facing: Vector2) -> bool:
	if not BattlefieldGeometry.is_finite_point(facing):
		return false
	if facing.is_equal_approx(Vector2.ZERO):
		return false
	return is_equal_approx(facing.length(), 1.0)


static func _sat_intersects(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	if a.size() < 3 or b.size() < 3:
		return false
	var axes: Array[Vector2] = []
	_append_edge_axes(axes, a)
	_append_edge_axes(axes, b)
	for axis: Vector2 in axes:
		if axis.is_equal_approx(Vector2.ZERO):
			continue
		var proj_a: Vector2 = _project_range(a, axis)
		var proj_b: Vector2 = _project_range(b, axis)
		if proj_a.y < proj_b.x - PROJECTION_EPSILON:
			return false
		if proj_b.y < proj_a.x - PROJECTION_EPSILON:
			return false
	return true


static func _append_edge_axes(axes: Array[Vector2], corners: PackedVector2Array) -> void:
	var count: int = corners.size()
	var index: int = 0
	while index < count:
		var next_index: int = (index + 1) % count
		var edge: Vector2 = corners[next_index] - corners[index]
		if not edge.is_equal_approx(Vector2.ZERO):
			axes.append(Vector2(-edge.y, edge.x).normalized())
		index += 1


static func _project_range(corners: PackedVector2Array, axis: Vector2) -> Vector2:
	var minimum: float = INF
	var maximum: float = -INF
	for corner: Vector2 in corners:
		var projected: float = corner.dot(axis)
		if projected < minimum:
			minimum = projected
		if projected > maximum:
			maximum = projected
	return Vector2(minimum, maximum)


static func _sorted_vehicle_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null:
		return ids
	for vehicle_id: String in battle_state.vehicles:
		ids.append(vehicle_id)
	ids.sort()
	return ids


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null:
		return ids
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids
