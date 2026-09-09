class_name TacticalParticipantVisual
extends RefCounted

# Shared presentation facing / origin. Does not own combat or hit-testing.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")

const COVER_OCCUPY_VISUAL_NUDGE_PIXELS := 3.2
const FACING_EPSILON := 0.001
const LOCOMOTION_SPEED_EPSILON := 0.35
const DIRECTION_HYSTERESIS_DOT := 0.22
const FIRE_PRESENTATION_SECONDS := 0.32
const NOMINAL_WALK_SPEED := 3.6
const WALK_SPEED_SCALE_MIN := 0.72
const WALK_SPEED_SCALE_MAX := 1.28
const DIR_N := "n"
const DIR_NE := "ne"
const DIR_E := "e"
const DIR_SE := "se"
const DIR_S := "s"
const DIR_SW := "sw"
const DIR_W := "w"
const DIR_NW := "nw"
const DIRECTION_IDS_8: Array[String] = [
	DIR_N, DIR_NE, DIR_E, DIR_SE, DIR_S, DIR_SW, DIR_W, DIR_NW
]
const IMPLEMENTED_DIRECTION_IDS: Array[String] = [
	DIR_N, DIR_NE, DIR_E, DIR_SE, DIR_S, DIR_SW, DIR_W, DIR_NW
]


static func facing(battle_state: BattleState, participant: BattleParticipant) -> Vector2:
	if participant == null:
		return Vector2.UP
	if participant.has_target_participant and battle_state != null:
		var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
		if target != null and target.has_battle_position:
			var to_target: Vector2 = target.battle_position - participant.battle_position
			if is_usable(to_target):
				return to_target.normalized()
	if is_usable(participant.velocity):
		return participant.velocity.normalized()
	if is_usable(participant.movement_intent):
		return participant.movement_intent.normalized()
	if participant.has_movement_target_position:
		var to_move: Vector2 = participant.movement_target_position - participant.battle_position
		if is_usable(to_move):
			return to_move.normalized()
	if participant.has_active_navigation_path():
		var to_waypoint: Vector2 = participant.get_current_navigation_waypoint() - participant.battle_position
		if is_usable(to_waypoint):
			return to_waypoint.normalized()
	if participant.has_occupied_cover_slot() and battle_state != null and battle_state.battlefield_geometry != null:
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
			participant.occupied_cover_slot_id
		)
		if slot != null and is_usable(slot.facing_direction):
			return slot.facing_direction.normalized()
	var from_event: Vector2 = _latest_source_shot_facing(battle_state, participant)
	if is_usable(from_event):
		return from_event.normalized()
	if battle_state != null and participant.side_id == battle_state.defender_side_id:
		return Vector2.DOWN
	return Vector2.UP


static func view_origin(
	battle_state: BattleState,
	participant: BattleParticipant,
	pixels_per_unit: float
) -> Vector2:
	if participant == null or not participant.has_battle_position:
		return Vector2.ZERO
	var view_pos: Vector2 = participant.battle_position * pixels_per_unit
	if battle_state != null and battle_state.battlefield_geometry != null and battle_state.battlefield_geometry.authored_layout_id == "dead_street_dusk_v1":
		view_pos.y *= 0.75
	if not participant.has_occupied_cover_slot():
		return view_pos
	var face: Vector2 = facing(battle_state, participant)
	if not is_usable(face):
		return view_pos
	return view_pos + face.normalized() * COVER_OCCUPY_VISUAL_NUDGE_PIXELS


static func is_usable(direction: Vector2) -> bool:
	return direction.length_squared() > FACING_EPSILON


static func is_locomoting(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	return participant.velocity.length() >= LOCOMOTION_SPEED_EPSILON


static func presentation_facing(battle_state: BattleState, participant: BattleParticipant) -> Vector2:
	if participant == null:
		return Vector2.UP
	if is_locomoting(participant):
		return participant.velocity.normalized()
	return facing(battle_state, participant)


static func animation_clip_id(_battle_state: BattleState, participant: BattleParticipant) -> String:
	if participant == null or not participant.is_alive:
		return TacticalUnitAnimationCatalog.CLIP_DEATH
	if is_locomoting(participant):
		return TacticalUnitAnimationCatalog.CLIP_WALK
	if _is_reloading(participant):
		return TacticalUnitAnimationCatalog.CLIP_RELOAD
	if participant.has_occupied_cover_slot():
		if participant.cover_posture_phase == "exposing":
			return TacticalUnitAnimationCatalog.CLIP_COVER_POPOUT
		if _is_visually_firing(participant) and (
			participant.is_cover_exposed() or participant.cover_posture_phase == "holding"
		):
			return TacticalUnitAnimationCatalog.CLIP_COVER_FIRE
		if participant.is_cover_exposed() or participant.cover_posture_phase == "holding":
			return TacticalUnitAnimationCatalog.CLIP_COVER_EXPOSED_IDLE
		if participant.cover_posture_phase == "tucking":
			return TacticalUnitAnimationCatalog.CLIP_COVER_TUCKED_IDLE
		return TacticalUnitAnimationCatalog.CLIP_COVER_TUCKED_IDLE
	if _is_visually_firing(participant):
		return TacticalUnitAnimationCatalog.CLIP_FIRE
	if participant.has_target_participant:
		return TacticalUnitAnimationCatalog.CLIP_AIM
	if participant.is_wounded:
		return TacticalUnitAnimationCatalog.CLIP_WOUNDED_IDLE
	return TacticalUnitAnimationCatalog.CLIP_IDLE


static func walk_speed_scale(participant: BattleParticipant) -> float:
	if participant == null:
		return 1.0
	var nominal: float = participant.movement_speed
	if not is_finite(nominal) or nominal <= 0.1:
		nominal = NOMINAL_WALK_SPEED
	var speed: float = participant.velocity.length()
	return clampf(speed / nominal, WALK_SPEED_SCALE_MIN, WALK_SPEED_SCALE_MAX)


static func _is_reloading(participant: BattleParticipant) -> bool:
	if participant == null or participant.weapon_state == null:
		return false
	return participant.weapon_state.is_reloading


static func _is_visually_firing(participant: BattleParticipant) -> bool:
	if participant == null or participant.weapon_state == null:
		return false
	if not is_finite(participant.weapon_state.cooldown_remaining_seconds):
		return false
	return participant.weapon_state.cooldown_remaining_seconds > FIRE_PRESENTATION_SECONDS


static func eight_direction_id(direction: Vector2) -> String:
	if not is_usable(direction):
		return DIR_S
	var deg: float = rad_to_deg(atan2(direction.y, direction.x))
	var idx: int = int(round(deg / 45.0))
	if idx == 8 or idx == -8:
		idx = 0
	match idx:
		0:
			return DIR_E
		1:
			return DIR_SE
		2:
			return DIR_S
		3:
			return DIR_SW
		4, -4:
			return DIR_W
		-3:
			return DIR_NW
		-2:
			return DIR_N
		-1:
			return DIR_NE
		_:
			return DIR_S


static func implemented_direction_id(direction: Vector2, previous_id: String = "") -> String:
	var raw_id: String = eight_direction_id(direction)
	if previous_id.is_empty() or previous_id == raw_id:
		return raw_id
	if not DIRECTION_IDS_8.has(previous_id):
		return raw_id
	var incoming: Vector2 = direction.normalized()
	var prev_v: Vector2 = _eight_vector(previous_id)
	var raw_v: Vector2 = _eight_vector(raw_id)
	if incoming.dot(prev_v) + DIRECTION_HYSTERESIS_DOT >= incoming.dot(raw_v):
		return previous_id
	return raw_id


static func eight_vector(direction_id: String) -> Vector2:
	return _eight_vector(direction_id)


static func _eight_vector(direction_id: String) -> Vector2:
	match direction_id:
		DIR_E:
			return Vector2.RIGHT
		DIR_SE:
			return Vector2(1.0, 1.0).normalized()
		DIR_S:
			return Vector2.DOWN
		DIR_SW:
			return Vector2(-1.0, 1.0).normalized()
		DIR_W:
			return Vector2.LEFT
		DIR_NW:
			return Vector2(-1.0, -1.0).normalized()
		DIR_N:
			return Vector2.UP
		DIR_NE:
			return Vector2(1.0, -1.0).normalized()
		_:
			return Vector2.DOWN


static func _latest_source_shot_facing(
	battle_state: BattleState,
	participant: BattleParticipant
) -> Vector2:
	if battle_state == null or participant == null:
		return Vector2.ZERO
	var events: Array = battle_state.combat_feedback_events
	var i: int = events.size() - 1
	while i >= 0:
		var event: BattleAttackEvent = events[i]
		i -= 1
		if event == null or event.source_participant_id != participant.participant_id:
			continue
		if not event.has_source_position or not event.has_target_position:
			continue
		var along: Vector2 = event.target_position - event.source_position
		if is_usable(along):
			return along
	return Vector2.ZERO
