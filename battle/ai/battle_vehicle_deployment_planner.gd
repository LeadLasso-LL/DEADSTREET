class_name BattleVehicleDeploymentPlanner
extends RefCounted

# Query-only side-generic vehicle parking planner.
# Proposes vehicle ID, position, and facing. Does not mutate BattleState.
# Fallback only: parks on the owning region's rear/arrival frontage, inset
# from edges and centered along that frontage. Not a permanent curb/road rule.
# Authored arrival_heading / anchor_position override when supplied.
# No RNG.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleVehiclePhysicalProfile := preload("res://battle/vehicles/battle_vehicle_physical_profile.gd")
const BattleVehicleCoverService := preload("res://battle/vehicles/battle_vehicle_cover_service.gd")
const BattleVehiclePlacementContext := preload("res://battle/vehicles/battle_vehicle_placement_context.gd")
const BattleVehicleDeploymentPlan := preload("res://battle/ai/battle_vehicle_deployment_plan.gd")
const BattleVehicleDeploymentPlanAssignment := preload(
	"res://battle/ai/battle_vehicle_deployment_plan_assignment.gd"
)

const SAMPLE_STEP := 0.75
const TOWARD_EPSILON_SQ := 0.0001
const LEGAL_INSET_PAD := 0.15
const FALLBACK_MIN_EDGE_CLEARANCE := 2.0
const FALLBACK_EDGE_FRACTION := 0.05


static func plan_side_vehicles(
	battle_state: BattleState,
	side_id: String,
	opposing_side_id: String,
	context: BattleVehiclePlacementContext = null
) -> BattleVehicleDeploymentPlan:
	if battle_state == null:
		return BattleVehicleDeploymentPlan.failed(
			"null_battle_state",
			"Vehicle deployment plan failed: battle_state is null.",
			side_id,
			opposing_side_id
		)
	if side_id.is_empty() or not battle_state.has_side(side_id):
		return BattleVehicleDeploymentPlan.failed(
			"unknown_side",
			"Vehicle deployment plan failed: side '%s' does not exist." % side_id,
			side_id,
			opposing_side_id
		)
	if opposing_side_id.is_empty() or not battle_state.has_side(opposing_side_id):
		return BattleVehicleDeploymentPlan.failed(
			"unknown_opposing_side",
			"Vehicle deployment plan failed: opposing side '%s' does not exist." % opposing_side_id,
			side_id,
			opposing_side_id
		)
	if battle_state.battlefield_geometry == null or not battle_state.battlefield_geometry.is_valid():
		return BattleVehicleDeploymentPlan.failed(
			"missing_battlefield_geometry",
			"Vehicle deployment plan failed: battlefield geometry is missing or invalid.",
			side_id,
			opposing_side_id
		)
	var eligible_ids: Array[String] = collect_undeployed_vehicle_ids(battle_state, side_id)
	if eligible_ids.is_empty():
		return BattleVehicleDeploymentPlan.succeeded(side_id, opposing_side_id, [])
	var own_rect: Rect2 = _side_rect(battle_state, side_id)
	var opposing_rect: Rect2 = _side_rect(battle_state, opposing_side_id)
	if not BattlefieldGeometry.rect_is_usable(own_rect):
		return BattleVehicleDeploymentPlan.failed(
			"missing_deployment_region",
			"Vehicle deployment plan failed: side '%s' has no usable deployment region." % side_id,
			side_id,
			opposing_side_id
		)
	var facing: Vector2 = _derive_facing(own_rect, opposing_rect, context)
	if facing.is_equal_approx(Vector2.ZERO):
		return BattleVehicleDeploymentPlan.failed(
			"invalid_orientation",
			"Vehicle deployment plan failed: could not derive a facing direction.",
			side_id,
			opposing_side_id
		)
	var planned: Array[BattleVehicleDeploymentPlanAssignment] = []
	var occupied: Array[Dictionary] = []
	for vehicle_id: String in eligible_ids:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		var profile: BattleVehiclePhysicalProfile = BattleVehicleBodyService.profile_for_vehicle(vehicle)
		if profile == null:
			return BattleVehicleDeploymentPlan.failed(
				"missing_profile",
				"Vehicle deployment plan failed: vehicle '%s' has no physical profile." % vehicle_id,
				side_id,
				opposing_side_id
			)
		var chosen: Dictionary = _choose_candidate(
			battle_state,
			vehicle,
			profile,
			own_rect,
			facing,
			context,
			occupied
		)
		if chosen.is_empty():
			return BattleVehicleDeploymentPlan.failed(
				"no_legal_candidates",
				"Vehicle deployment plan failed: no legal parking pose for '%s'." % vehicle_id,
				side_id,
				opposing_side_id
			)
		chosen["type"] = vehicle.vehicle_type_id
		var assignment: BattleVehicleDeploymentPlanAssignment = BattleVehicleDeploymentPlanAssignment.new(
			vehicle_id,
			chosen.get("position", Vector2.ZERO),
			chosen.get("facing", facing)
		)
		planned.append(assignment)
		occupied.append(chosen)
	return BattleVehicleDeploymentPlan.succeeded(side_id, opposing_side_id, planned)


static func collect_undeployed_vehicle_ids(battle_state: BattleState, side_id: String) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null or not battle_state.has_side(side_id):
		return ids
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null:
		return ids
	for vehicle_id: String in side.vehicle_ids:
		if vehicle_id.is_empty() or not battle_state.has_vehicle(vehicle_id):
			continue
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null:
			continue
		if battle_state.is_vehicle_deployed(vehicle_id) and vehicle.has_battle_position:
			continue
		ids.append(vehicle_id)
	ids.sort()
	return ids


static func _derive_facing(
	own_rect: Rect2,
	opposing_rect: Rect2,
	context: BattleVehiclePlacementContext
) -> Vector2:
	if context != null and context.has_arrival_heading:
		var heading: Vector2 = context.arrival_heading
		if BattlefieldGeometry.is_finite_point(heading) and not heading.is_equal_approx(Vector2.ZERO):
			return heading.normalized()
	var own_center: Vector2 = own_rect.get_center()
	var toward: Vector2 = Vector2.ZERO
	if BattlefieldGeometry.rect_is_usable(opposing_rect):
		toward = opposing_rect.get_center() - own_center
	if toward.length_squared() <= TOWARD_EPSILON_SQ:
		toward = Vector2(50.0, 30.0) - own_center
	if toward.length_squared() <= TOWARD_EPSILON_SQ:
		toward = Vector2.RIGHT
	return toward.normalized()


static func _choose_candidate(
	battle_state: BattleState,
	vehicle: BattleVehicle,
	profile: BattleVehiclePhysicalProfile,
	own_rect: Rect2,
	facing: Vector2,
	context: BattleVehiclePlacementContext,
	occupied: Array[Dictionary]
) -> Dictionary:
	var candidates: Array[Dictionary] = _generate_candidates(
		own_rect,
		facing,
		profile,
		context
	)
	for candidate: Dictionary in candidates:
		var position: Vector2 = candidate.get("position", Vector2.ZERO)
		var pose_facing: Vector2 = candidate.get("facing", facing)
		if not _candidate_is_free(occupied, position, pose_facing, profile):
			continue
		var error_code: String = BattleVehicleBodyService.get_placement_error(
			battle_state,
			vehicle.battle_vehicle_id,
			position,
			pose_facing
		)
		if not error_code.is_empty():
			continue
		var preview: BattleVehicle = BattleVehicle.new(
			vehicle.battle_vehicle_id,
			vehicle.campaign_vehicle_id,
			vehicle.faction_id,
			vehicle.side_id,
			vehicle.vehicle_type_id,
			vehicle.deployment_slot_id
		)
		preview.has_battle_position = true
		preview.battle_position = position
		preview.set_facing_direction(pose_facing)
		if BattleVehicleCoverService.collect_legal_body_slots(battle_state, preview).is_empty():
			continue
		return candidate
	return {}


static func _candidate_is_free(
	occupied: Array[Dictionary],
	position: Vector2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile
) -> bool:
	var ghost: BattleVehicle = BattleVehicle.new("ghost", "ghost", "", "", profile.vehicle_type_id, "")
	ghost.has_battle_position = true
	ghost.battle_position = position
	ghost.set_facing_direction(facing)
	for other: Dictionary in occupied:
		var other_ghost: BattleVehicle = BattleVehicle.new(
			"ghost_other",
			"ghost_other",
			"",
			"",
			str(other.get("type", profile.vehicle_type_id)),
			""
		)
		other_ghost.has_battle_position = true
		other_ghost.battle_position = other.get("position", Vector2.ZERO)
		other_ghost.set_facing_direction(other.get("facing", Vector2.RIGHT))
		if BattleVehicleBodyService.bodies_intersect(ghost, other_ghost):
			return false
	return true


static func _generate_candidates(
	own_rect: Rect2,
	facing: Vector2,
	profile: BattleVehiclePhysicalProfile,
	context: BattleVehiclePlacementContext
) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var usable: Rect2 = _fallback_usable_rect(own_rect, profile)
	var rearward: Vector2 = -facing
	var lateral: Vector2 = Vector2(-facing.y, facing.x)
	var rear_center: Vector2 = _rect_rear_center(usable, rearward)
	if context != null and context.has_anchor and BattlefieldGeometry.rect_contains_point(usable, context.anchor_position):
		candidates.append(
			_scored_candidate(context.anchor_position, facing, rearward, lateral, rear_center, 1)
		)
	candidates.append(_scored_candidate(rear_center, facing, rearward, lateral, rear_center, 0))
	var origin: Vector2 = usable.position
	var cols: int = maxi(1, int(floor(usable.size.x / SAMPLE_STEP)))
	var rows: int = maxi(1, int(floor(usable.size.y / SAMPLE_STEP)))
	var col: int = 0
	while col <= cols:
		var row: int = 0
		while row <= rows:
			var u: float = 0.5
			var v: float = 0.5
			if cols > 0:
				u = float(col) / float(cols)
			if rows > 0:
				v = float(row) / float(rows)
			var point: Vector2 = Vector2(
				origin.x + u * usable.size.x,
				origin.y + v * usable.size.y
			)
			candidates.append(_scored_candidate(point, facing, rearward, lateral, rear_center, 0))
			row += 1
		col += 1
	candidates.sort_custom(Callable(BattleVehicleDeploymentPlanner, "_candidate_sort"))
	return candidates


static func _scored_candidate(
	position: Vector2,
	facing: Vector2,
	rearward: Vector2,
	lateral: Vector2,
	rear_center: Vector2,
	preferred: int
) -> Dictionary:
	var lateral_offset: float = (position - rear_center).dot(lateral)
	return {
		"position": position,
		"facing": facing,
		"preferred": preferred,
		"rear": position.dot(rearward),
		"lateral_abs": absf(lateral_offset),
		"lateral": lateral_offset,
	}


static func _candidate_sort(a: Dictionary, b: Dictionary) -> bool:
	var preferred_a: int = int(a.get("preferred", 0))
	var preferred_b: int = int(b.get("preferred", 0))
	if preferred_a != preferred_b:
		return preferred_a > preferred_b
	var rear_a: float = float(a.get("rear", 0.0))
	var rear_b: float = float(b.get("rear", 0.0))
	if not is_equal_approx(rear_a, rear_b):
		return rear_a > rear_b
	var lateral_abs_a: float = float(a.get("lateral_abs", 0.0))
	var lateral_abs_b: float = float(b.get("lateral_abs", 0.0))
	if not is_equal_approx(lateral_abs_a, lateral_abs_b):
		return lateral_abs_a < lateral_abs_b
	var lateral_a: float = float(a.get("lateral", 0.0))
	var lateral_b: float = float(b.get("lateral", 0.0))
	if not is_equal_approx(lateral_a, lateral_b):
		return lateral_a < lateral_b
	var pos_a: Vector2 = a.get("position", Vector2.ZERO)
	var pos_b: Vector2 = b.get("position", Vector2.ZERO)
	if not is_equal_approx(pos_a.y, pos_b.y):
		return pos_a.y < pos_b.y
	return pos_a.x < pos_b.x


static func _fallback_usable_rect(own_rect: Rect2, profile: BattleVehiclePhysicalProfile) -> Rect2:
	var legal_inset: float = maxf(profile.half_length(), profile.half_width())
	legal_inset += BattleVehicleCoverService.COVER_STANDOFF + LEGAL_INSET_PAD
	var clearance: float = FALLBACK_MIN_EDGE_CLEARANCE
	var region_span: float = minf(own_rect.size.x, own_rect.size.y)
	clearance = maxf(clearance, region_span * FALLBACK_EDGE_FRACTION)
	var inset: float = legal_inset + clearance
	var usable: Rect2 = _inset_rect(own_rect, inset)
	if BattlefieldGeometry.rect_is_usable(usable):
		return usable
	usable = _inset_rect(own_rect, legal_inset)
	if BattlefieldGeometry.rect_is_usable(usable):
		return usable
	return own_rect


static func _inset_rect(rect: Rect2, inset: float) -> Rect2:
	return Rect2(
		rect.position.x + inset,
		rect.position.y + inset,
		rect.size.x - 2.0 * inset,
		rect.size.y - 2.0 * inset
	)


static func _rect_rear_center(rect: Rect2, rearward: Vector2) -> Vector2:
	if rearward.is_equal_approx(Vector2.ZERO):
		return rect.get_center()
	var axis: Vector2 = rearward.normalized()
	var center: Vector2 = rect.get_center()
	# Axis-aligned region: the rear frontage is the edge whose outward
	# normal best matches rearward. Use that edge's midpoint.
	if absf(axis.x) >= absf(axis.y):
		return Vector2(center.x + signf(axis.x) * rect.size.x * 0.5, center.y)
	return Vector2(center.x, center.y + signf(axis.y) * rect.size.y * 0.5)


static func _side_rect(battle_state: BattleState, side_id: String) -> Rect2:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return Rect2()
	if side_id == battle_state.attacker_side_id:
		return battle_state.battlefield_geometry.attacker_deployment_rect
	if side_id == battle_state.defender_side_id:
		return battle_state.battlefield_geometry.defender_deployment_rect
	return Rect2()
