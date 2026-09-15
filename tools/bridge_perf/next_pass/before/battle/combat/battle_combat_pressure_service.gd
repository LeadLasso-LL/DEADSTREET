class_name BattleCombatPressureService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCombatPressureCatalog := preload("res://battle/combat/battle_combat_pressure_catalog.gd")
const BattleCombatPressureSnapshot := preload("res://battle/combat/battle_combat_pressure_snapshot.gd")
const BattleCombatPressureResult := preload("res://battle/combat/battle_combat_pressure_result.gd")

# Deterministic observational pressure. Does not mutate combat behavior or RNG.


static func refresh(battle_state: BattleState) -> BattleCombatPressureResult:
	if battle_state == null:
		return BattleCombatPressureResult.failed(
			"null_battle_state",
			"Battle combat pressure failed: battle_state is null."
		)
	var next_snapshots: Dictionary[String, BattleCombatPressureSnapshot] = {}
	var participants_considered: int = 0
	var snapshots_updated: int = 0
	for participant_id: String in _sorted_participant_ids(battle_state):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		var snapshot: BattleCombatPressureSnapshot = evaluate_participant(battle_state, participant_id)
		if snapshot == null:
			continue
		next_snapshots[participant_id] = snapshot
		snapshots_updated += 1
	battle_state.combat_pressure_snapshots = next_snapshots
	return BattleCombatPressureResult.succeeded(participants_considered, snapshots_updated)


static func evaluate_participant(
	battle_state: BattleState,
	participant_id: String
) -> BattleCombatPressureSnapshot:
	if battle_state == null or participant_id.is_empty():
		return null
	if not battle_state.has_participant(participant_id):
		return null
	var source: BattleParticipant = battle_state.get_participant(participant_id)
	if not _is_pressure_subject(battle_state, source):
		return null
	var nearby_dead_allies: int = 0
	var nearby_wounded_allies: int = 0
	var nearby_living_allies: int = 0
	var nearby_hostiles: int = 0
	var isolation_ally_present: bool = false
	var support_living_allies: int = 0
	var hostile_proximity_sum: float = 0.0
	var hostile_bearings: Array[Vector2] = []
	var pressure_radius: float = BattleCombatPressureCatalog.PRESSURE_RADIUS
	var isolation_radius: float = BattleCombatPressureCatalog.ISOLATION_RADIUS
	var support_radius: float = BattleCombatPressureCatalog.FRIENDLY_SUPPORT_RADIUS
	for candidate_id: String in _sorted_participant_ids(battle_state):
		var candidate: BattleParticipant = battle_state.get_participant(candidate_id)
		if candidate == null:
			continue
		if candidate.participant_id == source.participant_id:
			continue
		if not _is_positioned(candidate):
			continue
		if _are_tactical_allies(battle_state, source, candidate):
			if not candidate.is_alive:
				if _is_within_radius(source.battle_position, candidate.battle_position, pressure_radius):
					nearby_dead_allies += 1
				continue
			if _is_within_radius(source.battle_position, candidate.battle_position, pressure_radius):
				nearby_living_allies += 1
				if candidate.is_wounded:
					nearby_wounded_allies += 1
			if _is_within_radius(source.battle_position, candidate.battle_position, isolation_radius):
				isolation_ally_present = true
			if _is_within_radius(source.battle_position, candidate.battle_position, support_radius):
				support_living_allies += 1
			continue
		if not candidate.is_alive:
			continue
		if not _are_tactical_hostiles(battle_state, source, candidate):
			continue
		if not _is_within_radius(source.battle_position, candidate.battle_position, pressure_radius):
			continue
		nearby_hostiles += 1
		var distance: float = source.battle_position.distance_to(candidate.battle_position)
		if is_finite(distance) and is_finite(pressure_radius) and pressure_radius > 0.0:
			var proximity: float = 1.0 - (distance / pressure_radius)
			hostile_proximity_sum += _clamp_unit(proximity)
		var offset: Vector2 = candidate.battle_position - source.battle_position
		if _is_finite_vector(offset) and not offset.is_equal_approx(Vector2.ZERO):
			var bearing: Vector2 = offset.normalized()
			if _is_finite_vector(bearing) and not bearing.is_equal_approx(Vector2.ZERO):
				hostile_bearings.append(bearing)
	var casualty_pressure: float = _normalized_count(
		nearby_dead_allies,
		BattleCombatPressureCatalog.CASUALTY_COUNT_NORMALIZE
	)
	var wounded_pressure: float = _normalized_count(
		nearby_wounded_allies,
		BattleCombatPressureCatalog.WOUNDED_COUNT_NORMALIZE
	)
	var hostile_pressure: float = _normalized_sum(
		hostile_proximity_sum,
		BattleCombatPressureCatalog.HOSTILE_PROXIMITY_NORMALIZE
	)
	var isolation_pressure: float = 0.0
	if not isolation_ally_present:
		isolation_pressure = 1.0
	var multi_direction_pressure: float = 0.0
	if _has_multi_direction_threat(hostile_bearings):
		multi_direction_pressure = 1.0
	var friendly_support: float = _normalized_count(
		support_living_allies,
		BattleCombatPressureCatalog.FRIENDLY_SUPPORT_COUNT_NORMALIZE
	)
	var total_pressure: float = (
		casualty_pressure * BattleCombatPressureCatalog.CASUALTY_WEIGHT
		+ wounded_pressure * BattleCombatPressureCatalog.WOUNDED_WEIGHT
		+ hostile_pressure * BattleCombatPressureCatalog.HOSTILE_PROXIMITY_WEIGHT
		+ isolation_pressure * BattleCombatPressureCatalog.ISOLATION_WEIGHT
		+ multi_direction_pressure * BattleCombatPressureCatalog.MULTI_DIRECTION_WEIGHT
		- friendly_support * BattleCombatPressureCatalog.FRIENDLY_SUPPORT_MITIGATION
	)
	var snapshot: BattleCombatPressureSnapshot = BattleCombatPressureSnapshot.new()
	snapshot.participant_id = source.participant_id
	snapshot.nearby_dead_allies = nearby_dead_allies
	snapshot.nearby_wounded_allies = nearby_wounded_allies
	snapshot.nearby_living_allies = nearby_living_allies
	snapshot.nearby_hostiles = nearby_hostiles
	snapshot.casualty_pressure = casualty_pressure
	snapshot.wounded_pressure = wounded_pressure
	snapshot.hostile_pressure = hostile_pressure
	snapshot.isolation_pressure = isolation_pressure
	snapshot.multi_direction_pressure = multi_direction_pressure
	snapshot.friendly_support = friendly_support
	snapshot.total_pressure = _clamp_unit(total_pressure)
	return snapshot


static func get_snapshot(
	battle_state: BattleState,
	participant_id: String
) -> BattleCombatPressureSnapshot:
	if battle_state == null or participant_id.is_empty():
		return null
	return battle_state.get_combat_pressure_snapshot(participant_id)


static func get_total_pressure(battle_state: BattleState, participant_id: String) -> float:
	var snapshot: BattleCombatPressureSnapshot = get_snapshot(battle_state, participant_id)
	if snapshot == null:
		return 0.0
	if not is_finite(snapshot.total_pressure):
		return 0.0
	return _clamp_unit(snapshot.total_pressure)


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null:
		return ids
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids


static func _is_pressure_subject(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.is_alive:
		return false
	if not _is_positioned(participant):
		return false
	if participant.side_id.is_empty():
		return false
	if battle_state == null or not battle_state.has_side(participant.side_id):
		return false
	return true


static func _is_positioned(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.has_battle_position:
		return false
	return _is_finite_vector(participant.battle_position)


static func _is_finite_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)


static func _are_tactical_allies(
	battle_state: BattleState,
	left: BattleParticipant,
	right: BattleParticipant
) -> bool:
	if left == null or right == null:
		return false
	if left.side_id.is_empty() or right.side_id.is_empty():
		return false
	if battle_state == null:
		return false
	if not battle_state.has_side(left.side_id) or not battle_state.has_side(right.side_id):
		return false
	return left.side_id == right.side_id


static func _are_tactical_hostiles(
	battle_state: BattleState,
	left: BattleParticipant,
	right: BattleParticipant
) -> bool:
	if left == null or right == null:
		return false
	if left.side_id.is_empty() or right.side_id.is_empty():
		return false
	if battle_state == null:
		return false
	if not battle_state.has_side(left.side_id) or not battle_state.has_side(right.side_id):
		return false
	return left.side_id != right.side_id


static func _is_within_radius(from_position: Vector2, to_position: Vector2, radius: float) -> bool:
	if not _is_finite_vector(from_position) or not _is_finite_vector(to_position):
		return false
	if not is_finite(radius) or radius < 0.0:
		return false
	var distance_sq: float = from_position.distance_squared_to(to_position)
	if not is_finite(distance_sq):
		return false
	var radius_sq: float = radius * radius
	if not is_finite(radius_sq):
		return false
	return distance_sq <= radius_sq


static func _normalized_count(count: int, divisor: float) -> float:
	if count <= 0:
		return 0.0
	if not is_finite(divisor) or divisor <= 0.0:
		return 0.0
	return _clamp_unit(float(count) / divisor)


static func _normalized_sum(sum_value: float, divisor: float) -> float:
	if not is_finite(sum_value) or sum_value <= 0.0:
		return 0.0
	if not is_finite(divisor) or divisor <= 0.0:
		return 0.0
	return _clamp_unit(sum_value / divisor)


static func _has_multi_direction_threat(bearings: Array[Vector2]) -> bool:
	if bearings.size() < 2:
		return false
	for i: int in range(bearings.size()):
		var left: Vector2 = bearings[i]
		for j: int in range(i + 1, bearings.size()):
			var right: Vector2 = bearings[j]
			var alignment: float = left.dot(right)
			if not is_finite(alignment):
				continue
			if alignment <= 0.0 or is_equal_approx(alignment, 0.0):
				return true
	return false


static func _clamp_unit(value: float) -> float:
	if not is_finite(value):
		return 0.0
	return clampf(value, 0.0, 1.0)
