class_name BattleTargetSelectionService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleTargetSelectionResult := preload("res://battle/combat/battle_target_selection_result.gd")


static func advance(battle_state: BattleState) -> BattleTargetSelectionResult:
	if battle_state == null:
		return BattleTargetSelectionResult.failed(
			"null_battle_state",
			"Battle target selection failed: battle_state is null."
		)
	if battle_state.battle_phase != "active":
		return BattleTargetSelectionResult.failed(
			"battle_not_active",
			"Battle target selection failed: battle phase is '%s', not active." % battle_state.battle_phase
		)
	if battle_state.battlefield_geometry == null:
		return BattleTargetSelectionResult.failed(
			"missing_battlefield_geometry",
			"Battle target selection failed: battlefield geometry is missing."
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleTargetSelectionResult.failed(
			"invalid_battlefield_geometry",
			"Battle target selection failed: battlefield geometry is invalid."
		)
	var participant_ids: Array[String] = _sorted_participant_ids(battle_state)
	var participants_considered: int = 0
	var participants_with_hostiles: int = 0
	var participants_with_targets: int = 0
	var targets_changed: int = 0
	for participant_id: String in participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		var had_target: bool = participant.has_target_participant
		var previous_target_id: String = participant.target_participant_id
		if not _is_eligible_source(battle_state, participant):
			participant.clear_target_participant()
		else:
			var hostile_ids: Array[String] = _sorted_eligible_hostile_ids(battle_state, participant)
			if hostile_ids.is_empty():
				participant.clear_target_participant()
			else:
				participants_with_hostiles += 1
				var selected_id: String = _select_best_hostile_id(battle_state, participant, hostile_ids)
				if selected_id.is_empty() or not participant.set_target_participant(selected_id):
					participant.clear_target_participant()
		if participant.has_target_participant:
			participants_with_targets += 1
		if (
			participant.has_target_participant != had_target
			or participant.target_participant_id != previous_target_id
		):
			targets_changed += 1
	return BattleTargetSelectionResult.succeeded(
		participants_considered,
		participants_with_hostiles,
		participants_with_targets,
		targets_changed
	)


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids


static func _is_eligible_source(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.is_alive:
		return false
	if not participant.has_battle_position:
		return false
	if not _is_finite_vector(participant.battle_position):
		return false
	if participant.side_id.is_empty():
		return false
	if not battle_state.has_side(participant.side_id):
		return false
	return true


static func _are_tactical_hostiles(
	battle_state: BattleState,
	left: BattleParticipant,
	right: BattleParticipant
) -> bool:
	if left == null or right == null:
		return false
	if left.side_id.is_empty() or right.side_id.is_empty():
		return false
	if not battle_state.has_side(left.side_id) or not battle_state.has_side(right.side_id):
		return false
	return left.side_id != right.side_id


static func _is_eligible_hostile_candidate(
	battle_state: BattleState,
	source: BattleParticipant,
	candidate: BattleParticipant
) -> bool:
	if source == null or candidate == null:
		return false
	if candidate.participant_id == source.participant_id:
		return false
	if not candidate.is_alive:
		return false
	if not candidate.has_battle_position:
		return false
	if not _is_finite_vector(candidate.battle_position):
		return false
	if not _are_tactical_hostiles(battle_state, source, candidate):
		return false
	return true


static func _sorted_eligible_hostile_ids(
	battle_state: BattleState,
	source: BattleParticipant
) -> Array[String]:
	var ids: Array[String] = []
	for participant_id: String in _sorted_participant_ids(battle_state):
		var candidate: BattleParticipant = battle_state.get_participant(participant_id)
		if _is_eligible_hostile_candidate(battle_state, source, candidate):
			ids.append(participant_id)
	return ids


# Provisional nearest-hostile policy. Later combat scoring (LOS, preferred weapon
# range, cover, threat, wounded state, player force commands) should replace this
# comparison without changing target-state ownership or runtime order.
static func _is_better_hostile_candidate(
	source: BattleParticipant,
	challenger: BattleParticipant,
	incumbent: BattleParticipant
) -> bool:
	var challenger_distance: float = source.battle_position.distance_squared_to(challenger.battle_position)
	var incumbent_distance: float = source.battle_position.distance_squared_to(incumbent.battle_position)
	if not is_finite(challenger_distance):
		return false
	if not is_finite(incumbent_distance):
		return true
	if challenger_distance < incumbent_distance:
		return true
	if challenger_distance > incumbent_distance:
		return false
	return challenger.participant_id < incumbent.participant_id


static func _select_best_hostile_id(
	battle_state: BattleState,
	source: BattleParticipant,
	candidate_ids: Array[String]
) -> String:
	var best_id: String = ""
	var best: BattleParticipant = null
	for candidate_id: String in candidate_ids:
		var candidate: BattleParticipant = battle_state.get_participant(candidate_id)
		if candidate == null:
			continue
		if best == null:
			var distance: float = source.battle_position.distance_squared_to(candidate.battle_position)
			if not is_finite(distance):
				continue
			best_id = candidate_id
			best = candidate
			continue
		if _is_better_hostile_candidate(source, candidate, best):
			best_id = candidate_id
			best = candidate
	return best_id


static func _is_finite_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)
