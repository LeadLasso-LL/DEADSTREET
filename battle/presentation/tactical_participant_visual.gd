class_name TacticalParticipantVisual
extends RefCounted

# Shared presentation facing / origin. Does not own combat or hit-testing.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")

const COVER_OCCUPY_VISUAL_NUDGE_PIXELS := 3.2
const FACING_EPSILON := 0.001


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
	if not participant.has_occupied_cover_slot():
		return view_pos
	var face: Vector2 = facing(battle_state, participant)
	if not is_usable(face):
		return view_pos
	return view_pos + face.normalized() * COVER_OCCUPY_VISUAL_NUDGE_PIXELS


static func is_usable(direction: Vector2) -> bool:
	return direction.length_squared() > FACING_EPSILON


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
