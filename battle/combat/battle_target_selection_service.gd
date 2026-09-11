class_name BattleTargetSelectionService
extends RefCounted

const Weapons := preload("res://battle/combat/battle_weapon_catalog.gd")
const LOS := preload("res://battle/combat/battle_line_of_sight_service.gd")
const FireControl := preload("res://battle/combat/battle_fire_control_service.gd")

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
	if not battle_state.has_valid_geometry():
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
			participant.clear_player_priority_target()
		else:
			var locked_id: String = _honored_player_priority_target_id(battle_state, participant)
			if not locked_id.is_empty():
				participants_with_hostiles += 1
				if not participant.set_target_participant(locked_id):
					participant.clear_target_participant()
					participant.clear_player_priority_target()
			else:
				participant.clear_player_priority_target()
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


static func _honored_player_priority_target_id(
	battle_state: BattleState,
	participant: BattleParticipant
) -> String:
	if participant == null or not participant.has_player_priority_target():
		return ""
	var locked: BattleParticipant = battle_state.get_participant(participant.player_priority_target_id)
	if not _is_eligible_hostile_candidate(battle_state, participant, locked):
		return ""
	return locked.participant_id


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
	if source.weapon_type == "sniper":
		var sniper_id: String = _sniper_target(battle_state, source, candidate_ids)
		if not sniper_id.is_empty(): return sniper_id
	elif _uses_assault_targeting(battle_state, source):
		var visible_id: String = _assault_target(battle_state, source, candidate_ids)
		if not visible_id.is_empty(): return visible_id
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


# Pick a distant visible target, then finish the acquisition instead of target hopping.
# A close visible threat overrides the long-range preference; player focus wins upstream.
static func _sniper_target(b: BattleState, source: BattleParticipant, ids: Array[String]) -> String:
	var d = Weapons.for_participant(source)
	if d == null: return ""
	var urgent: String = ""
	var urgent_distance: float = INF
	var distant: String = ""
	var farthest: float = -1.0
	var retained: bool = false
	for id: String in ids:
		var p: BattleParticipant = b.get_participant(id)
		var distance: float = source.battle_position.distance_to(p.battle_position)
		if distance > d.max_range: continue
		var sight = LOS.check_participant_to_participant(b, source.participant_id, id)
		if sight == null or not sight.success or not sight.has_line_of_sight: continue
		if distance < 12.0 and distance < urgent_distance:
			urgent = id
			urgent_distance = distance
		if id == source.target_participant_id: retained = true
		if distance > farthest:
			distant = id
			farthest = distance
	if not urgent.is_empty(): return urgent
	if retained: return source.target_participant_id
	return distant


# Advancing units engage visible threats instead of tracking a blocked enemy.
# Explicit player targets are honored upstream; sniper acquisition is unchanged.
static func _uses_assault_targeting(b: BattleState, source: BattleParticipant) -> bool:
	var force = b.get_tactical_force(source.tactical_force_id)
	return force != null and force.command_id in ["push", "focus_left", "focus_right"]


static func _assault_target(b: BattleState, source: BattleParticipant, ids: Array[String]) -> String:
	var best_id: String = ""
	var best_distance: float = INF
	for id: String in ids:
		var candidate: BattleParticipant = b.get_participant(id)
		if not FireControl.is_spatial_fire_engagement(b, source, candidate): continue
		var distance: float = source.battle_position.distance_to(candidate.battle_position)
		# Avoid restarting acquisition for small changes in relative distance.
		if id == source.target_participant_id: distance *= 0.85
		if distance < best_distance:
			best_distance = distance
			best_id = id
	return best_id
