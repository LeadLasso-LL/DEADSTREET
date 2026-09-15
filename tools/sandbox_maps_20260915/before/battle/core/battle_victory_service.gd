class_name BattleVictoryService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVictoryResult := preload("res://battle/core/battle_victory_result.gd")

const PHASE_RESOLVED := "resolved"

# Side-level elimination. Does not mutate campaign state or consume RNG.


static func is_living_combat_participant(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if battle_state == null or participant == null:
		return false
	if participant.participant_id.is_empty():
		return false
	if not battle_state.has_participant(participant.participant_id):
		return false
	if not participant.is_alive:
		return false
	if participant.side_id.is_empty():
		return false
	if not battle_state.has_side(participant.side_id):
		return false
	return true


static func collect_living_side_ids(battle_state: BattleState) -> Array[String]:
	var living_sides: Dictionary[String, bool] = {}
	if battle_state == null:
		return []
	for participant_id: String in _sorted_participant_ids(battle_state):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if not is_living_combat_participant(battle_state, participant):
			continue
		living_sides[participant.side_id] = true
	var living_side_ids: Array[String] = []
	for side_id: String in battle_state.sides:
		if living_sides.has(side_id):
			living_side_ids.append(side_id)
	living_side_ids.sort()
	return living_side_ids


static func can_evaluate(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	if battle_state.battle_phase != "active":
		return false
	if battle_state.attacker_side_id.is_empty() or battle_state.defender_side_id.is_empty():
		return false
	if not battle_state.has_side(battle_state.attacker_side_id):
		return false
	if not battle_state.has_side(battle_state.defender_side_id):
		return false
	if battle_state.participants.is_empty():
		return false
	if not battle_state.is_battle_ready():
		return false
	return true


static func is_resolved(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	if battle_state.battle_phase == PHASE_RESOLVED:
		return true
	if battle_state.tactical_result != null and battle_state.tactical_result.resolved:
		return true
	return false


static func get_result(battle_state: BattleState) -> BattleVictoryResult:
	if battle_state == null:
		return BattleVictoryResult.ineligible(
			"null_battle_state",
			"Battle victory failed: battle_state is null."
		)
	if battle_state.tactical_result != null:
		return BattleVictoryResult.from_stored(battle_state.tactical_result)
	if battle_state.battle_phase == "active":
		return BattleVictoryResult.continuing(collect_living_side_ids(battle_state))
	return BattleVictoryResult.ineligible(
		"battle_not_resolved",
		"Battle victory failed: battle phase is '%s' and has no tactical result."
		% battle_state.battle_phase
	)


static func get_winning_side_id(battle_state: BattleState) -> String:
	var stored: BattleVictoryResult = get_result(battle_state)
	if stored == null or not stored.resolved:
		return ""
	return stored.winning_side_id


static func get_result_kind(battle_state: BattleState) -> String:
	var stored: BattleVictoryResult = get_result(battle_state)
	if stored == null or not stored.resolved:
		return BattleVictoryResult.RESULT_NONE
	return stored.result_kind


static func is_terminal_state(battle_state: BattleState) -> bool:
	if is_resolved(battle_state):
		return true
	if not can_evaluate(battle_state):
		return false
	return collect_living_side_ids(battle_state).size() <= 1


static func should_halt_autonomous_combat(battle_state: BattleState) -> bool:
	return is_terminal_state(battle_state)


static func evaluate(battle_state: BattleState) -> BattleVictoryResult:
	if battle_state == null:
		return BattleVictoryResult.ineligible(
			"null_battle_state",
			"Battle victory failed: battle_state is null."
		)
	if is_resolved(battle_state):
		return BattleVictoryResult.from_stored(battle_state.tactical_result)
	if not can_evaluate(battle_state):
		if battle_state.battle_phase != "active":
			return BattleVictoryResult.ineligible(
				"battle_not_active",
				"Battle victory failed: battle phase is '%s', not active." % battle_state.battle_phase
			)
		return BattleVictoryResult.ineligible(
			"battle_not_ready",
			"Battle victory failed: battle is not ready for terminal evaluation."
		)
	var living_side_ids: Array[String] = collect_living_side_ids(battle_state)
	if living_side_ids.size() > 1:
		return BattleVictoryResult.continuing(living_side_ids)
	return _terminal_snapshot(battle_state, living_side_ids, false)


static func resolve_if_terminal(battle_state: BattleState) -> BattleVictoryResult:
	if battle_state == null:
		return BattleVictoryResult.ineligible(
			"null_battle_state",
			"Battle victory failed: battle_state is null."
		)
	if is_resolved(battle_state):
		return BattleVictoryResult.from_stored(battle_state.tactical_result)
	if not can_evaluate(battle_state):
		return evaluate(battle_state)
	var living_side_ids: Array[String] = collect_living_side_ids(battle_state)
	if living_side_ids.size() > 1:
		return BattleVictoryResult.continuing(living_side_ids)
	var stored: BattleVictoryResult = _terminal_snapshot(battle_state, living_side_ids, true)
	battle_state.tactical_result = stored
	battle_state.battle_phase = PHASE_RESOLVED
	return stored


static func _terminal_snapshot(
	battle_state: BattleState,
	living_side_ids: Array[String],
	p_resolved_this_call: bool
) -> BattleVictoryResult:
	var losing_side_ids: Array[String] = _sorted_side_ids(battle_state)
	if living_side_ids.size() == 1:
		var winning_side_id: String = living_side_ids[0]
		var losers: Array[String] = []
		for side_id: String in losing_side_ids:
			if side_id != winning_side_id:
				losers.append(side_id)
		return BattleVictoryResult.resolved_victory(
			winning_side_id,
			losers,
			living_side_ids,
			p_resolved_this_call
		)
	return BattleVictoryResult.resolved_draw(losing_side_ids, p_resolved_this_call)


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null:
		return ids
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids


static func _sorted_side_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	if battle_state == null:
		return ids
	for side_id: String in battle_state.sides:
		ids.append(side_id)
	ids.sort()
	return ids
