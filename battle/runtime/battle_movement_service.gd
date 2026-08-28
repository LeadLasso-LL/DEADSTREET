class_name BattleMovementService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleMovementResult := preload("res://battle/runtime/battle_movement_result.gd")
const BattleSpatialService := preload("res://battle/geometry/battle_spatial_service.gd")
const BattleSpatialResult := preload("res://battle/geometry/battle_spatial_result.gd")


static func advance(battle_state: BattleState, delta_seconds: float) -> BattleMovementResult:
	if battle_state == null:
		return BattleMovementResult.failed(
			"null_battle_state",
			"Battle movement failed: battle_state is null.",
			delta_seconds
		)
	if battle_state.battle_phase != "active":
		return BattleMovementResult.failed(
			"battle_not_active",
			"Battle movement failed: battle phase is '%s', not active." % battle_state.battle_phase,
			delta_seconds
		)
	if not is_finite(delta_seconds) or delta_seconds < 0.0:
		return BattleMovementResult.failed(
			"invalid_delta",
			"Battle movement failed: delta_seconds is invalid.",
			delta_seconds
		)
	if battle_state.battlefield_geometry == null:
		return BattleMovementResult.failed(
			"missing_battlefield_geometry",
			"Battle movement failed: battlefield geometry is missing.",
			delta_seconds
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleMovementResult.failed(
			"invalid_battlefield_geometry",
			"Battle movement failed: battlefield geometry is invalid.",
			delta_seconds
		)
	var participant_ids: Array[String] = _sorted_participant_ids(battle_state)
	var participants_considered: int = 0
	var participants_moved: int = 0
	for participant_id: String in participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		if _advance_participant(battle_state, participant, delta_seconds):
			participants_moved += 1
	return BattleMovementResult.succeeded(delta_seconds, participants_considered, participants_moved)


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids


static func _advance_participant(
	battle_state: BattleState,
	participant: BattleParticipant,
	delta_seconds: float
) -> bool:
	if not participant.has_battle_position:
		participant.velocity = Vector2.ZERO
		return false
	if not participant.is_alive:
		participant.velocity = Vector2.ZERO
		return false
	var speed: float = participant.movement_speed
	if not is_finite(speed) or speed < 0.0:
		participant.velocity = Vector2.ZERO
		return false
	if speed == 0.0:
		participant.velocity = Vector2.ZERO
		return false
	var direction: Vector2 = _resolved_direction(participant.movement_intent)
	if direction == Vector2.ZERO:
		participant.velocity = Vector2.ZERO
		return false
	var next_velocity: Vector2 = direction * speed
	if not _is_finite_vector(next_velocity):
		participant.velocity = Vector2.ZERO
		return false
	participant.velocity = next_velocity
	if not _is_finite_vector(participant.battle_position):
		return false
	var displacement: Vector2 = participant.velocity * delta_seconds
	if not _is_finite_vector(displacement):
		return false
	var start_position: Vector2 = participant.battle_position
	displacement = _capped_displacement(participant, start_position, displacement)
	if not _is_finite_vector(displacement):
		return false
	var spatial: BattleSpatialResult = BattleSpatialService.resolve_translation(
		battle_state,
		start_position,
		displacement
	)
	if spatial == null or not spatial.success:
		return false
	if not _is_finite_vector(spatial.final_position):
		return false
	participant.battle_position = spatial.final_position
	return not start_position.is_equal_approx(spatial.final_position)


static func _capped_displacement(
	participant: BattleParticipant,
	start_position: Vector2,
	displacement: Vector2
) -> Vector2:
	if not participant.has_movement_target_position:
		return displacement
	if not _is_finite_vector(participant.movement_target_position):
		return displacement
	var to_target: Vector2 = participant.movement_target_position - start_position
	if not _is_finite_vector(to_target):
		return displacement
	var remaining: float = to_target.length()
	if not is_finite(remaining):
		return displacement
	if is_zero_approx(remaining):
		return Vector2.ZERO
	if displacement.length() < remaining:
		return displacement
	if displacement.dot(to_target) <= 0.0:
		return displacement
	return to_target


static func _resolved_direction(intent: Vector2) -> Vector2:
	if not _is_finite_vector(intent):
		return Vector2.ZERO
	if intent == Vector2.ZERO:
		return Vector2.ZERO
	var direction: Vector2 = intent.normalized()
	if not _is_finite_vector(direction) or direction == Vector2.ZERO:
		return Vector2.ZERO
	return direction


static func _is_finite_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)
