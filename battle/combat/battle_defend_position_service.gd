class_name BattleDefendPositionService
extends RefCounted

# Query-only local Defend Position search. Behavior owns reservation and navigation.
# Reuses BattleCombatCoverEvaluationService ranking. Does not chase.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleLineOfSightService := preload("res://battle/combat/battle_line_of_sight_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleCombatCoverEvaluation := preload("res://battle/combat/battle_combat_cover_evaluation.gd")
const BattleCombatCoverEvaluationService := preload(
	"res://battle/combat/battle_combat_cover_evaluation_service.gd"
)
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")


static func defend_anchor(participant: BattleParticipant) -> Vector2:
	if participant == null:
		return Vector2.INF
	if participant.has_defend_position_anchor and BattlefieldGeometry.is_finite_point(
		participant.defend_position_anchor
	):
		return participant.defend_position_anchor
	if participant.has_battle_position and BattlefieldGeometry.is_finite_point(participant.battle_position):
		return participant.battle_position
	return Vector2.INF


static func is_within_defend_radius(origin: Vector2, point: Vector2) -> bool:
	if not BattlefieldGeometry.is_finite_point(origin) or not BattlefieldGeometry.is_finite_point(point):
		return false
	var distance: float = origin.distance_to(point)
	if not is_finite(distance):
		return false
	var radius: float = BattleCombatBehaviorCatalog.DEFEND_POSITION_RADIUS
	return distance < radius or is_equal_approx(distance, radius)


static func select_best_local_cover_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant
) -> BattleCoverSlot:
	var origin: Vector2 = defend_anchor(participant)
	if not BattlefieldGeometry.is_finite_point(origin):
		return null
	var ranked: Array[BattleCombatCoverEvaluation] = (
		BattleCombatCoverEvaluationService.rank_combat_usable_within_radius(
			battle_state,
			participant,
			hostile,
			true,
			origin,
			BattleCombatBehaviorCatalog.DEFEND_POSITION_RADIUS
		)
	)
	if ranked.is_empty():
		ranked = BattleCombatCoverEvaluationService.rank_combat_usable_within_radius(
			battle_state,
			participant,
			hostile,
			false,
			origin,
			BattleCombatBehaviorCatalog.DEFEND_POSITION_RADIUS
		)
	return BattleCombatCoverEvaluationService.first_reachable_ranked_slot(
		battle_state,
		participant,
		ranked,
		true
	)


static func select_best_local_los_point(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant
) -> Vector2:
	if participant == null or hostile == null or not _is_positioned(participant) or not _is_positioned(hostile):
		return Vector2.INF
	var origin: Vector2 = defend_anchor(participant)
	if not BattlefieldGeometry.is_finite_point(origin):
		return Vector2.INF
	var candidates: Array[Dictionary] = []
	var order := 0
	var radii: Array[float] = _sample_radii()
	var directions: int = BattleCombatBehaviorCatalog.DEFEND_POSITION_SAMPLE_DIRECTIONS
	for radius: float in radii:
		var dir := 0
		while dir < directions:
			order += 1
			var angle: float = (float(dir) * TAU) / float(directions)
			var point: Vector2 = origin + Vector2.from_angle(angle) * radius
			dir += 1
			if not _sample_is_legal(battle_state, participant, hostile, origin, point, false):
				continue
			var move_distance: float = participant.battle_position.distance_to(point)
			var anchor_distance: float = point.distance_to(origin)
			if not is_finite(move_distance) or not is_finite(anchor_distance):
				continue
			candidates.append({
				"point": point,
				"move": move_distance,
				"anchor": anchor_distance,
				"order": order,
			})
	candidates.sort_custom(_compare_defend_samples)
	var best: Vector2 = Vector2.INF
	for candidate: Dictionary in candidates:
		var point: Vector2 = candidate["point"]
		if participant.battle_position.distance_to(point) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
			best = point
			break
		if BattleNavigationService.is_reachable(battle_state, participant.battle_position, point):
			best = point
			break
	return best


static func destination_still_valid(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	destination: Vector2,
	require_reachable: bool = true
) -> bool:
	if participant == null or not _is_positioned(participant):
		return false
	var origin: Vector2 = defend_anchor(participant)
	return _sample_is_legal(
		battle_state,
		participant,
		hostile,
		origin,
		destination,
		require_reachable
	)


static func _sample_radii() -> Array[float]:
	var radii: Array[float] = [
		BattleCombatBehaviorCatalog.DEFEND_POSITION_SAMPLE_RADIUS_A,
		BattleCombatBehaviorCatalog.DEFEND_POSITION_SAMPLE_RADIUS_B,
		BattleCombatBehaviorCatalog.DEFEND_POSITION_SAMPLE_RADIUS_C,
		BattleCombatBehaviorCatalog.DEFEND_POSITION_SAMPLE_RADIUS_D,
	]
	return radii


static func _compare_defend_samples(left: Dictionary, right: Dictionary) -> bool:
	return _sample_ranks_better(
		float(left.get("move", INF)),
		float(left.get("anchor", INF)),
		int(left.get("order", 2147483647)),
		float(right.get("move", INF)),
		float(right.get("anchor", INF)),
		int(right.get("order", 2147483647))
	)


static func _sample_ranks_better(
	move_distance: float,
	anchor_distance: float,
	order: int,
	best_move: float,
	best_anchor: float,
	best_order: int
) -> bool:
	if not is_equal_approx(move_distance, best_move):
		return move_distance < best_move
	if not is_equal_approx(anchor_distance, best_anchor):
		return anchor_distance < best_anchor
	return order < best_order


static func _sample_is_legal(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	origin: Vector2,
	point: Vector2,
	require_reachable: bool = true
) -> bool:
	if not BattlefieldGeometry.is_finite_point(point):
		return false
	if participant != null and point.is_equal_approx(participant.battle_position):
		return false
	if not is_within_defend_radius(origin, point):
		return false
	if not _is_valid_destination(battle_state, point):
		return false
	if not _point_has_los_to_hostile(battle_state, point, hostile):
		return false
	if not _point_is_in_weapon_max_range(participant, point, hostile):
		return false
	if participant == null or not _is_positioned(participant):
		return false
	if participant.battle_position.distance_to(point) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		return true
	if not require_reachable:
		return true
	return BattleNavigationService.is_reachable(
		battle_state,
		participant.battle_position,
		point
	)


static func _point_has_los_to_hostile(
	battle_state: BattleState,
	point: Vector2,
	hostile: BattleParticipant
) -> bool:
	if hostile == null or not _is_positioned(hostile):
		return false
	var los: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
		battle_state,
		point,
		hostile.battle_position
	)
	return los != null and los.success and los.has_line_of_sight


static func _point_is_in_weapon_max_range(
	participant: BattleParticipant,
	point: Vector2,
	hostile: BattleParticipant
) -> bool:
	if participant == null or hostile == null or not _is_positioned(hostile):
		return false
	if not BattlefieldGeometry.is_finite_point(point):
		return false
	var weapon_type_id: String = participant.weapon_type
	if participant.weapon_state != null and not participant.weapon_state.weapon_type_id.is_empty():
		weapon_type_id = participant.weapon_state.weapon_type_id
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null or not definition.is_valid():
		return false
	var distance: float = point.distance_to(hostile.battle_position)
	if not is_finite(distance):
		return false
	return distance < definition.max_range or is_equal_approx(distance, definition.max_range)


static func _is_valid_destination(battle_state: BattleState, point: Vector2) -> bool:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if not BattlefieldGeometry.is_finite_point(point):
		return false
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not geometry.contains_point(point):
		return false
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if obstacle.contains_point(point):
			return false
	return true


static func _is_positioned(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.has_battle_position:
		return false
	return BattlefieldGeometry.is_finite_point(participant.battle_position)
