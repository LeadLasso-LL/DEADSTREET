class_name BattleDeploymentPlanner
extends RefCounted

# Query-only generic side deployment planner.
# Produces intended positions. Does not write battle_position, zone membership,
# commitment flags, or combat cover occupancy.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleCombatBehaviorProfile := preload("res://battle/combat/battle_combat_behavior_profile.gd")
const BattleLineOfSightService := preload("res://battle/combat/battle_line_of_sight_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")
const BattleDeploymentPlan := preload("res://battle/ai/battle_deployment_plan.gd")
const BattleDeploymentPlanAssignment := preload("res://battle/ai/battle_deployment_plan_assignment.gd")

const POSTURE_WEAKER := BattleDeploymentPlan.POSTURE_WEAKER
const POSTURE_EVEN := BattleDeploymentPlan.POSTURE_EVEN
const POSTURE_STRONGER := BattleDeploymentPlan.POSTURE_STRONGER

# Provisional planning-only strength bands. Not campaign morale or persistent rating.
const WEAKER_RATIO := 0.75
const STRONGER_RATIO := 1.25
const WOUNDED_STRENGTH_MULTIPLIER := 0.70
const LIVING_STRENGTH_BASE := 25.0

# Planning-only assignment spread. Not an authoritative spacing rule.
const ASSIGNMENT_SPREAD_RADIUS := 8.0

const SAMPLE_INSET := 1.0
const TOWARD_EPSILON_SQ := 0.0001


static func plan_side_deployment(
	battle_state: BattleState,
	side_id: String,
	opposing_side_id: String
) -> BattleDeploymentPlan:
	var context_error: BattleDeploymentPlan = _validate_plan_context(
		battle_state,
		side_id,
		opposing_side_id
	)
	if context_error != null:
		return context_error
	var eligible_ids: Array[String] = collect_eligible_participant_ids(battle_state, side_id)
	if eligible_ids.is_empty():
		return BattleDeploymentPlan.failed(
			"no_living_participants",
			"Deployment plan failed: side '%s' has no living undeployed participants." % side_id,
			side_id,
			opposing_side_id
		)
	var opposing_positions: Array[Vector2] = collect_opposing_positions(battle_state, opposing_side_id)
	if opposing_positions.is_empty():
		return BattleDeploymentPlan.failed(
			"missing_opposing_positions",
			"Deployment plan failed: opposing side '%s' has no committed living positions." % opposing_side_id,
			side_id,
			opposing_side_id
		)
	var own_rect: Rect2 = side_deployment_rect(battle_state, side_id)
	if not BattlefieldGeometry.rect_is_usable(own_rect):
		return BattleDeploymentPlan.failed(
			"missing_deployment_region",
			"Deployment plan failed: side '%s' has no usable deployment region." % side_id,
			side_id,
			opposing_side_id
		)
	var posture: String = relative_posture(battle_state, side_id, opposing_side_id)
	var opposing_centroid: Vector2 = _centroid(opposing_positions)
	var toward_enemy: Vector2 = _toward_enemy(own_rect, opposing_centroid)
	var candidates: Array[Dictionary] = _generate_legal_candidates(battle_state, side_id, own_rect)
	if candidates.is_empty():
		return BattleDeploymentPlan.failed(
			"no_legal_candidates",
			"Deployment plan failed: side '%s' has no legal candidate positions." % side_id,
			side_id,
			opposing_side_id,
			posture
		)
	var assigned_positions: Array[Vector2] = []
	var used_candidate_indexes: Dictionary = {}
	var assignments: Array[BattleDeploymentPlanAssignment] = []
	for participant_id: String in eligible_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			return BattleDeploymentPlan.failed(
				"unknown_participant",
				"Deployment plan failed: participant '%s' is missing." % participant_id,
				side_id,
				opposing_side_id,
				posture
			)
		var best_index: int = -1
		var best_score: float = -INF
		var best_reason: String = ""
		var index: int = 0
		while index < candidates.size():
			if used_candidate_indexes.has(index):
				index += 1
				continue
			var candidate: Dictionary = candidates[index]
			var scored: Dictionary = _score_candidate(
				battle_state,
				participant,
				candidate,
				own_rect,
				toward_enemy,
				opposing_centroid,
				opposing_side_id,
				posture,
				assigned_positions
			)
			var score: float = float(scored.get("score", -INF))
			var reason: String = str(scored.get("reason", ""))
			if _is_better_candidate(score, candidate, best_score, best_index, candidates):
				best_index = index
				best_score = score
				best_reason = reason
			index += 1
		if best_index < 0:
			return BattleDeploymentPlan.failed(
				"insufficient_candidates",
				"Deployment plan failed: not enough distinct legal candidates for side '%s'." % side_id,
				side_id,
				opposing_side_id,
				posture
			)
		var chosen: Dictionary = candidates[best_index]
		var chosen_position: Vector2 = chosen.get("position", Vector2.ZERO)
		var legality: String = battle_state.get_deployment_position_error(side_id, chosen_position)
		if not legality.is_empty():
			return BattleDeploymentPlan.failed(
				legality,
				"Deployment plan failed: planned position for '%s' is not legal (%s)." % [participant_id, legality],
				side_id,
				opposing_side_id,
				posture
			)
		used_candidate_indexes[best_index] = true
		assigned_positions.append(chosen_position)
		assignments.append(
			BattleDeploymentPlanAssignment.new(
				participant_id,
				chosen_position,
				best_score,
				best_reason
			)
		)
	return BattleDeploymentPlan.succeeded(side_id, opposing_side_id, posture, assignments)


static func collect_eligible_participant_ids(battle_state: BattleState, side_id: String) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null or side_id.is_empty() or not battle_state.has_side(side_id):
		return ids
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null:
		return ids
	for participant_id: String in side.participant_ids:
		if not _is_eligible_planner_participant(battle_state, side_id, participant_id):
			continue
		ids.append(participant_id)
	ids.sort()
	return ids


static func collect_opposing_positions(battle_state: BattleState, opposing_side_id: String) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if battle_state == null or opposing_side_id.is_empty() or not battle_state.has_side(opposing_side_id):
		return positions
	var side: BattleSide = battle_state.get_side(opposing_side_id)
	if side == null:
		return positions
	var ids: Array[String] = []
	for participant_id: String in side.participant_ids:
		ids.append(participant_id)
	ids.sort()
	for participant_id: String in ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		if not participant.is_alive:
			continue
		if not participant.has_battle_position:
			continue
		if not BattlefieldGeometry.is_finite_point(participant.battle_position):
			continue
		positions.append(participant.battle_position)
	return positions


static func relative_posture(
	battle_state: BattleState,
	side_id: String,
	opposing_side_id: String
) -> String:
	var own_strength: float = estimate_side_strength(battle_state, side_id)
	var opposing_strength: float = estimate_side_strength(battle_state, opposing_side_id)
	if not is_finite(own_strength) or not is_finite(opposing_strength) or opposing_strength <= 0.0:
		return POSTURE_EVEN
	var ratio: float = own_strength / opposing_strength
	if ratio < WEAKER_RATIO:
		return POSTURE_WEAKER
	if ratio > STRONGER_RATIO:
		return POSTURE_STRONGER
	return POSTURE_EVEN


static func estimate_side_strength(battle_state: BattleState, side_id: String) -> float:
	if battle_state == null or side_id.is_empty() or not battle_state.has_side(side_id):
		return 0.0
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null:
		return 0.0
	var total: float = 0.0
	for participant_id: String in side.participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.is_alive:
			continue
		total += _participant_strength(participant)
	return total


static func side_deployment_rect(battle_state: BattleState, side_id: String) -> Rect2:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return Rect2()
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if side_id == battle_state.attacker_side_id:
		return geometry.attacker_deployment_rect
	if side_id == battle_state.defender_side_id:
		return geometry.defender_deployment_rect
	return Rect2()


static func _validate_plan_context(
	battle_state: BattleState,
	side_id: String,
	opposing_side_id: String
) -> BattleDeploymentPlan:
	if battle_state == null:
		return BattleDeploymentPlan.failed(
			"null_battle_state",
			"Deployment plan failed: battle_state is null.",
			side_id,
			opposing_side_id
		)
	if battle_state.battle_phase != "deployment":
		return BattleDeploymentPlan.failed(
			"battle_not_in_deployment",
			"Deployment plan failed: battle phase is '%s', not deployment." % battle_state.battle_phase,
			side_id,
			opposing_side_id
		)
	if side_id.is_empty() or not battle_state.has_side(side_id):
		return BattleDeploymentPlan.failed(
			"unknown_side",
			"Deployment plan failed: side '%s' does not exist." % side_id,
			side_id,
			opposing_side_id
		)
	if opposing_side_id.is_empty() or not battle_state.has_side(opposing_side_id):
		return BattleDeploymentPlan.failed(
			"unknown_opposing_side",
			"Deployment plan failed: opposing side '%s' does not exist." % opposing_side_id,
			side_id,
			opposing_side_id
		)
	if side_id == opposing_side_id:
		return BattleDeploymentPlan.failed(
			"identical_sides",
			"Deployment plan failed: side and opposing side are the same.",
			side_id,
			opposing_side_id
		)
	if battle_state.battlefield_geometry == null or not battle_state.battlefield_geometry.is_valid():
		return BattleDeploymentPlan.failed(
			"missing_battlefield_geometry",
			"Deployment plan failed: battlefield geometry is missing or invalid.",
			side_id,
			opposing_side_id
		)
	if battle_state.is_side_deployment_committed(side_id):
		return BattleDeploymentPlan.failed(
			"side_deployment_committed",
			"Deployment plan failed: side '%s' is already committed." % side_id,
			side_id,
			opposing_side_id
		)
	return null


static func _is_eligible_planner_participant(
	battle_state: BattleState,
	side_id: String,
	participant_id: String
) -> bool:
	if participant_id.is_empty() or not battle_state.has_participant(participant_id):
		return false
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return false
	if participant.side_id != side_id:
		return false
	if not participant.is_alive:
		return false
	if battle_state.is_participant_deployed(participant_id):
		return false
	if participant.has_battle_position:
		return false
	return true


static func _participant_strength(participant: BattleParticipant) -> float:
	var capability: float = _weapon_capability(participant.weapon_type)
	var strength: float = LIVING_STRENGTH_BASE + capability
	if participant.is_wounded:
		strength *= WOUNDED_STRENGTH_MULTIPLIER
	return strength


static func _weapon_capability(weapon_type_id: String) -> float:
	var definition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null:
		return 1.0
	return definition.max_range * definition.shots_per_second


static func _desired_forwardness(weapon_type_id: String) -> float:
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if profile == null:
		return 0.5
	var mid: float = (profile.preferred_min_distance + profile.preferred_max_distance) * 0.5
	var scale: float = BattleCombatBehaviorCatalog.SNIPER_PREFERRED_MAX
	if scale <= 0.0:
		return 0.5
	return 1.0 - clampf(mid / scale, 0.0, 1.0)


static func _preferred_band_midpoint(weapon_type_id: String) -> float:
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if profile == null:
		return 0.0
	return (profile.preferred_min_distance + profile.preferred_max_distance) * 0.5


static func _generate_legal_candidates(
	battle_state: BattleState,
	side_id: String,
	own_rect: Rect2
) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var sample_rects: Array[Rect2] = []
	var geometry: BattlefieldGeometry = null
	if battle_state != null:
		geometry = battle_state.battlefield_geometry
	if geometry != null:
		var for_attacker: bool = side_id == battle_state.attacker_side_id
		sample_rects = geometry.deployment_sample_rects(for_attacker)
	if sample_rects.is_empty() and BattlefieldGeometry.rect_is_usable(own_rect):
		sample_rects.append(own_rect)
	for sample_source: Rect2 in sample_rects:
		var sample_rect: Rect2 = _inset_rect(sample_source, SAMPLE_INSET)
		if not BattlefieldGeometry.rect_is_usable(sample_rect):
			sample_rect = sample_source
		if not BattlefieldGeometry.rect_is_usable(sample_rect):
			continue
		var nx: int = clampi(int(round(sample_rect.size.x / 3.5)), 3, 8)
		var ny: int = clampi(int(round(sample_rect.size.y / 6.0)), 4, 10)
		var iy: int = 0
		while iy < ny:
			var ix: int = 0
			while ix < nx:
				var point: Vector2 = Vector2(
					sample_rect.position.x + (float(ix) + 0.5) * sample_rect.size.x / float(nx),
					sample_rect.position.y + (float(iy) + 0.5) * sample_rect.size.y / float(ny)
				)
				if battle_state.get_deployment_position_error(side_id, point).is_empty():
					candidates.append(
						{
							"position": point,
							"is_cover": false,
							"cover_slot_id": "",
							"facing": Vector2.ZERO,
						}
					)
				ix += 1
			iy += 1
	if geometry != null:
		for slot_id: String in geometry.get_sorted_cover_slot_ids():
			var slot: BattleCoverSlot = geometry.get_cover_slot(slot_id)
			if slot == null:
				continue
			if not battle_state.get_deployment_position_error(side_id, slot.position).is_empty():
				continue
			candidates.append(
				{
					"position": slot.position,
					"is_cover": true,
					"cover_slot_id": slot.cover_slot_id,
					"facing": slot.facing_direction,
				}
			)
	return candidates


static func _score_candidate(
	battle_state: BattleState,
	participant: BattleParticipant,
	candidate: Dictionary,
	own_rect: Rect2,
	toward_enemy: Vector2,
	opposing_centroid: Vector2,
	opposing_side_id: String,
	posture: String,
	assigned_positions: Array[Vector2]
) -> Dictionary:
	var position: Vector2 = candidate.get("position", Vector2.ZERO)
	var is_cover: bool = bool(candidate.get("is_cover", false))
	var facing: Vector2 = candidate.get("facing", Vector2.ZERO)
	var forwardness: float = _forwardness_01(position, own_rect, toward_enemy)
	var desired: float = _desired_forwardness(participant.weapon_type)
	var attacker_standoff: float = _opposing_standoff_01(battle_state, opposing_side_id)
	desired -= 0.28 * (1.0 - attacker_standoff)
	if posture == POSTURE_WEAKER:
		desired -= 0.22
	elif posture == POSTURE_STRONGER:
		desired += 0.16
	if attacker_standoff >= 0.55:
		desired = maxf(desired, 0.32)
	desired = clampf(desired, 0.05, 0.97)
	var score: float = 0.0
	score -= absf(forwardness - desired) * 12.0
	var range_distance: float = position.distance_to(opposing_centroid)
	var band_error: float = BattleCombatBehaviorCatalog.preferred_band_error(
		participant.weapon_type,
		range_distance
	)
	if is_finite(band_error):
		score -= clampf(band_error / 20.0, 0.0, 3.5)
	var definition = BattleWeaponCatalog.get_definition(participant.weapon_type)
	if definition != null and range_distance > definition.max_range:
		score -= clampf((range_distance - definition.max_range) / 20.0, 0.0, 2.0)
	var cover_weight: float = 0.0
	if is_cover:
		cover_weight = 0.7
		if BattleCombatBehaviorCatalog.uses_healthy_role_cover(participant.weapon_type):
			cover_weight = 2.1
		if posture == POSTURE_WEAKER:
			cover_weight += 1.4
		if attacker_standoff >= 0.55:
			cover_weight += 1.3
		if facing.length_squared() > TOWARD_EPSILON_SQ and toward_enemy.length_squared() > TOWARD_EPSILON_SQ:
			if facing.normalized().dot(toward_enemy) > 0.25:
				cover_weight += 1.0
		score += cover_weight
	var has_los: bool = _has_los_to_any_opponent(battle_state, position, opposing_side_id)
	var own_standoff: float = 1.0 - _desired_forwardness(participant.weapon_type)
	if has_los:
		score += 0.35 + own_standoff * 1.1
	else:
		if own_standoff >= 0.45:
			score -= 1.1
		elif is_cover and attacker_standoff >= 0.55:
			score += 0.7
		else:
			score -= 0.25
	for assigned: Vector2 in assigned_positions:
		var spread_distance: float = position.distance_to(assigned)
		if spread_distance < ASSIGNMENT_SPREAD_RADIUS:
			score -= (ASSIGNMENT_SPREAD_RADIUS - spread_distance) * 0.9
	var reason: String = posture + " " + participant.weapon_type
	if is_cover:
		reason += " cover"
	return {
		"score": score,
		"reason": reason,
	}


static func _is_better_candidate(
	score: float,
	candidate: Dictionary,
	best_score: float,
	best_index: int,
	candidates: Array[Dictionary]
) -> bool:
	if best_index < 0:
		return true
	if score > best_score + 0.00001:
		return true
	if score < best_score - 0.00001:
		return false
	var position: Vector2 = candidate.get("position", Vector2.ZERO)
	var best: Dictionary = candidates[best_index]
	var best_position: Vector2 = best.get("position", Vector2.ZERO)
	if position.x < best_position.x - 0.00001:
		return true
	if position.x > best_position.x + 0.00001:
		return false
	if position.y < best_position.y - 0.00001:
		return true
	if position.y > best_position.y + 0.00001:
		return false
	var cover_id: String = str(candidate.get("cover_slot_id", ""))
	var best_cover_id: String = str(best.get("cover_slot_id", ""))
	return cover_id < best_cover_id


static func _opposing_standoff_01(battle_state: BattleState, opposing_side_id: String) -> float:
	if battle_state == null or opposing_side_id.is_empty() or not battle_state.has_side(opposing_side_id):
		return 0.5
	var side: BattleSide = battle_state.get_side(opposing_side_id)
	if side == null:
		return 0.5
	var total: float = 0.0
	var count: int = 0
	for participant_id: String in side.participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.is_alive:
			continue
		total += _preferred_band_midpoint(participant.weapon_type)
		count += 1
	if count <= 0:
		return 0.5
	var scale: float = BattleCombatBehaviorCatalog.SNIPER_PREFERRED_MAX
	if scale <= 0.0:
		return 0.5
	return clampf((total / float(count)) / scale, 0.0, 1.0)


static func _has_los_to_any_opponent(
	battle_state: BattleState,
	position: Vector2,
	opposing_side_id: String
) -> bool:
	var positions: Array[Vector2] = collect_opposing_positions(battle_state, opposing_side_id)
	for opposing_position: Vector2 in positions:
		var los: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
			battle_state,
			position,
			opposing_position
		)
		if los != null and los.success and los.has_line_of_sight:
			return true
	return false


static func _forwardness_01(point: Vector2, own_rect: Rect2, toward_enemy: Vector2) -> float:
	if toward_enemy.length_squared() < TOWARD_EPSILON_SQ:
		return 0.5
	var corners: Array[Vector2] = [
		own_rect.position,
		own_rect.position + Vector2(own_rect.size.x, 0.0),
		own_rect.position + Vector2(0.0, own_rect.size.y),
		own_rect.position + own_rect.size,
	]
	var min_proj: float = INF
	var max_proj: float = -INF
	for corner: Vector2 in corners:
		var proj: float = corner.dot(toward_enemy)
		if proj < min_proj:
			min_proj = proj
		if proj > max_proj:
			max_proj = proj
	var span: float = max_proj - min_proj
	if span <= 0.0001:
		return 0.5
	return clampf((point.dot(toward_enemy) - min_proj) / span, 0.0, 1.0)


static func _toward_enemy(own_rect: Rect2, opposing_centroid: Vector2) -> Vector2:
	var delta: Vector2 = opposing_centroid - own_rect.get_center()
	if delta.length_squared() < TOWARD_EPSILON_SQ:
		return Vector2.ZERO
	return delta.normalized()


static func _centroid(positions: Array[Vector2]) -> Vector2:
	if positions.is_empty():
		return Vector2.ZERO
	var sum: Vector2 = Vector2.ZERO
	for position: Vector2 in positions:
		sum += position
	return sum / float(positions.size())


static func _inset_rect(rect: Rect2, inset: float) -> Rect2:
	if not BattlefieldGeometry.rect_is_usable(rect):
		return Rect2()
	if inset <= 0.0:
		return rect
	if rect.size.x <= 2.0 * inset or rect.size.y <= 2.0 * inset:
		return rect
	return Rect2(rect.position + Vector2(inset, inset), rect.size - Vector2(2.0 * inset, 2.0 * inset))
