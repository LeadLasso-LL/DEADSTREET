class_name BattlePathFollowService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlePathFollowResult := preload("res://battle/navigation/battle_path_follow_result.gd")

# Geometric arrival tolerance only. Not gameplay stopping-distance.
const WAYPOINT_ARRIVAL_EPSILON := 0.0001


static func advance(battle_state: BattleState) -> BattlePathFollowResult:
	if battle_state == null:
		return BattlePathFollowResult.failed(
			"null_battle_state",
			"Battle path follow failed: battle_state is null."
		)
	if battle_state.battle_phase != "active":
		return BattlePathFollowResult.failed(
			"battle_not_active",
			"Battle path follow failed: battle phase is '%s', not active." % battle_state.battle_phase
		)
	if battle_state.battlefield_geometry == null:
		return BattlePathFollowResult.failed(
			"missing_battlefield_geometry",
			"Battle path follow failed: battlefield geometry is missing."
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattlePathFollowResult.failed(
			"invalid_battlefield_geometry",
			"Battle path follow failed: battlefield geometry is invalid."
		)
	var participant_ids: Array[String] = _sorted_participant_ids(battle_state)
	var participants_considered: int = 0
	var participants_with_paths: int = 0
	var participants_completed_paths: int = 0
	for participant_id: String in participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		var follow_status: int = _follow_participant(participant)
		if follow_status >= 1:
			participants_with_paths += 1
		if follow_status == 2:
			participants_completed_paths += 1
	return BattlePathFollowResult.succeeded(
		participants_considered,
		participants_with_paths,
		participants_completed_paths
	)


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids


# 0 = no active path, 1 = had path still following, 2 = had path and completed.
static func _follow_participant(participant: BattleParticipant) -> int:
	if not participant.has_active_navigation_path():
		participant.clear_movement_target_position()
		return 0
	if not participant.is_alive:
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	if not participant.has_battle_position:
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	if not _is_finite_vector(participant.battle_position):
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	if not _consume_reached_waypoints(participant):
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	if not participant.has_active_navigation_path():
		participant.clear_movement_intent()
		participant.clear_navigation_path()
		return 2
	var waypoint: Vector2 = participant.get_current_navigation_waypoint()
	if not _is_finite_vector(waypoint):
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	var direction: Vector2 = waypoint - participant.battle_position
	if not _is_finite_vector(direction) or direction == Vector2.ZERO:
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	if not participant.set_movement_intent(direction):
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	if not participant.set_movement_target_position(waypoint):
		participant.clear_movement_intent()
		participant.clear_movement_target_position()
		return 1
	return 1


static func _consume_reached_waypoints(participant: BattleParticipant) -> bool:
	while participant.has_active_navigation_path():
		var waypoint: Vector2 = participant.get_current_navigation_waypoint()
		if not _is_finite_vector(waypoint):
			return false
		var distance: float = participant.battle_position.distance_to(waypoint)
		if not is_finite(distance):
			return false
		if distance > WAYPOINT_ARRIVAL_EPSILON:
			return true
		if not participant.advance_navigation_waypoint():
			return false
	return true


static func _is_finite_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)
