class_name BattleCombatBehaviorService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverResult := preload("res://battle/geometry/battle_cover_result.gd")
const BattleCoverQueryResult := preload("res://battle/geometry/battle_cover_query_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")
const BattleAttackResolutionService := preload("res://battle/combat/battle_attack_resolution_service.gd")
const BattleAttackResult := preload("res://battle/combat/battle_attack_result.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")
const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")
const BattleCombatRandom := preload("res://battle/combat/battle_combat_random.gd")
const BattleCombatBehaviorProfile := preload("res://battle/combat/battle_combat_behavior_profile.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleCombatBehaviorResult := preload("res://battle/combat/battle_combat_behavior_result.gd")
const BattleCombatPressureBehaviorPolicy := preload(
	"res://battle/combat/battle_combat_pressure_behavior_policy.gd"
)
const BattleCombatPressureBehaviorPolicyResult := preload(
	"res://battle/combat/battle_combat_pressure_behavior_policy_result.gd"
)
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleForceCommandService := preload("res://battle/core/battle_force_command_service.gd")
const BattleForceCommandCatalog := preload("res://battle/core/battle_force_command_catalog.gd")
const BattleVictoryService := preload("res://battle/core/battle_victory_service.gd")

const MOVE_HOLD := "hold"
const MOVE_APPROACH := "approach"
const MOVE_RETREAT := "retreat"
const MOVE_FALL_BACK := "fall_back"
const MOVE_SEEK_COVER := "seek_cover"
const MOVE_SEEK_ROLE_COVER := "seek_role_cover"

const WOUNDED_HOLD_COVER := "hold_cover"
const WOUNDED_SEEK_COVER := "seek_cover"
const WOUNDED_THREAT_OVERRIDE := "threat_override"
const WOUNDED_FALLBACK := "fallback"

const HEALTHY_HOLD_COVER := "hold_cover"
const HEALTHY_SEEK_COVER := "seek_role_cover"
const HEALTHY_NONE := ""

const MOVEMENT_NONE := 0
const MOVEMENT_REPOSITIONING := 1
const MOVEMENT_HOLD_CONSTRAINED := 2
const MOVEMENT_PUSH_PRESSURE := 3
const MOVEMENT_FOCUS_LEFT := 4
const MOVEMENT_FOCUS_RIGHT := 5
const MOVEMENT_FALL_BACK := 6
const MOVEMENT_PRESSURE_SUPPRESSED := 7


static func advance(battle_state: BattleState, delta_seconds: float) -> BattleCombatBehaviorResult:
	if battle_state == null:
		return BattleCombatBehaviorResult.failed(
			"null_battle_state",
			"Battle combat behavior failed: battle_state is null."
		)
	if battle_state.battle_phase != "active":
		return BattleCombatBehaviorResult.failed(
			"battle_not_active",
			"Battle combat behavior failed: battle phase is '%s', not active." % battle_state.battle_phase
		)
	if not is_finite(delta_seconds) or delta_seconds < 0.0:
		return BattleCombatBehaviorResult.failed(
			"invalid_delta",
			"Battle combat behavior failed: delta_seconds is invalid."
		)
	if battle_state.battlefield_geometry == null:
		return BattleCombatBehaviorResult.failed(
			"missing_battlefield_geometry",
			"Battle combat behavior failed: battlefield geometry is missing."
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleCombatBehaviorResult.failed(
			"invalid_battlefield_geometry",
			"Battle combat behavior failed: battlefield geometry is invalid."
		)
	if battle_state.combat_random == null:
		battle_state.combat_random = BattleCombatRandom.new(battle_state.combat_rng_seed)
	BattleForceCommandService.initialize_assault_frames_from_geometry(battle_state)
	# Zero delta is a valid refresh. It is not passage of combat time, so no shot.
	var execute_autonomous_attacks: bool = delta_seconds > 0.0
	var participants_considered: int = 0
	var shots_executed: int = 0
	var misses: int = 0
	var grazes: int = 0
	var wounds: int = 0
	var kills: int = 0
	var participants_repositioning: int = 0
	var participants_holding_defend_position: int = 0
	var wounded_seeking_cover: int = 0
	var wounded_holding_cover: int = 0
	var wounded_threat_override: int = 0
	var healthy_seeking_cover: int = 0
	var healthy_holding_cover: int = 0
	var force_command_hold: int = 0
	var force_command_push: int = 0
	var force_command_focus_left: int = 0
	var force_command_focus_right: int = 0
	var force_command_fall_back: int = 0
	var pressure_aggression_suppressed: int = 0
	var attack_events: Array[BattleAttackEvent] = []
	for participant_id: String in _sorted_participant_ids(battle_state):
		if BattleVictoryService.is_terminal_state(battle_state):
			break
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		if not participant.is_alive:
			continue
		if not _is_positioned(participant):
			continue
		if participant.defend_position:
			participants_holding_defend_position += 1
			_clear_owned_combat_navigation(participant)
			if execute_autonomous_attacks:
				var defended_shot: BattleAttackEvent = _try_execute_shot(battle_state, participant)
				if defended_shot != null:
					attack_events.append(defended_shot)
			continue
		if participant.is_wounded:
			var wounded_action: String = _update_wounded_cover_behavior(battle_state, participant)
			if wounded_action == WOUNDED_HOLD_COVER:
				wounded_holding_cover += 1
				if execute_autonomous_attacks:
					var cover_shot: BattleAttackEvent = _try_execute_shot(battle_state, participant)
					if cover_shot != null:
						attack_events.append(cover_shot)
				continue
			if wounded_action == WOUNDED_SEEK_COVER:
				wounded_seeking_cover += 1
				participants_repositioning += 1
				continue
			if wounded_action == WOUNDED_THREAT_OVERRIDE:
				wounded_threat_override += 1
			# Threat override and no-cover fallback use normal fire-then-move.
		else:
			var healthy_action: String = _update_healthy_role_cover_behavior(battle_state, participant)
			if healthy_action == HEALTHY_HOLD_COVER:
				healthy_holding_cover += 1
				if execute_autonomous_attacks:
					var role_cover_shot: BattleAttackEvent = _try_execute_shot(battle_state, participant)
					if role_cover_shot != null:
						attack_events.append(role_cover_shot)
				continue
			if healthy_action == HEALTHY_SEEK_COVER:
				healthy_seeking_cover += 1
				participants_repositioning += 1
				if execute_autonomous_attacks:
					var seeking_shot: BattleAttackEvent = _try_execute_shot(battle_state, participant)
					if seeking_shot != null:
						attack_events.append(seeking_shot)
				continue
		if execute_autonomous_attacks:
			var executed_event: BattleAttackEvent = _try_execute_shot(battle_state, participant)
			if executed_event != null:
				attack_events.append(executed_event)
				_clear_owned_combat_navigation(participant)
				continue
		var movement_status: int = _update_combat_movement(battle_state, participant)
		if movement_status == MOVEMENT_REPOSITIONING:
			participants_repositioning += 1
		elif movement_status == MOVEMENT_HOLD_CONSTRAINED:
			force_command_hold += 1
		elif movement_status == MOVEMENT_PUSH_PRESSURE:
			participants_repositioning += 1
			force_command_push += 1
		elif movement_status == MOVEMENT_FOCUS_LEFT:
			participants_repositioning += 1
			force_command_focus_left += 1
		elif movement_status == MOVEMENT_FOCUS_RIGHT:
			participants_repositioning += 1
			force_command_focus_right += 1
		elif movement_status == MOVEMENT_FALL_BACK:
			participants_repositioning += 1
			force_command_fall_back += 1
		elif movement_status == MOVEMENT_PRESSURE_SUPPRESSED:
			pressure_aggression_suppressed += 1
	shots_executed = attack_events.size()
	for attack_event: BattleAttackEvent in attack_events:
		match attack_event.outcome:
			BattleAttackProfile.OUTCOME_MISS:
				misses += 1
			BattleAttackProfile.OUTCOME_GRAZE:
				grazes += 1
			BattleAttackProfile.OUTCOME_WOUND:
				wounds += 1
			BattleAttackProfile.OUTCOME_KILL:
				kills += 1
	return BattleCombatBehaviorResult.succeeded(
		participants_considered,
		shots_executed,
		misses,
		grazes,
		wounds,
		kills,
		participants_repositioning,
		participants_holding_defend_position,
		attack_events,
		wounded_seeking_cover,
		wounded_holding_cover,
		wounded_threat_override,
		healthy_seeking_cover,
		healthy_holding_cover,
		force_command_hold,
		force_command_push,
		force_command_focus_left,
		force_command_focus_right,
		force_command_fall_back,
		pressure_aggression_suppressed
	)


static func _try_execute_shot(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleAttackEvent:
	if participant == null:
		return null
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		return null
	if not battle_state.has_participant(participant.target_participant_id):
		return null
	var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
	if target == null or not target.is_alive:
		return null
	var eligibility: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
		battle_state,
		participant.participant_id,
		participant.target_participant_id
	)
	if eligibility == null or not eligibility.success or not eligibility.can_fire:
		return null
	var combat_random: BattleCombatRandom = battle_state.combat_random
	if combat_random == null:
		return null
	var previous_state: int = combat_random.snapshot_state()
	var raw_roll: float = combat_random.next_normalized()
	var outcome_roll: float = raw_roll
	if participant.is_wounded:
		outcome_roll = BattleCombatBehaviorCatalog.wounded_effective_outcome_roll(raw_roll)
	var attack_result: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
		battle_state,
		participant.participant_id,
		participant.target_participant_id,
		outcome_roll
	)
	if attack_result == null or not attack_result.shot_executed:
		combat_random.restore_state(previous_state)
		return null
	return attack_result.attack_event


static func _update_wounded_cover_behavior(
	battle_state: BattleState,
	participant: BattleParticipant
) -> String:
	_reconcile_cover_state(battle_state, participant)
	if _has_valid_occupancy(battle_state, participant):
		_clear_owned_combat_navigation(participant)
		return WOUNDED_HOLD_COVER
	if _has_external_navigation(participant):
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	var cover_slot: BattleCoverSlot = _wounded_cover_candidate(battle_state, participant)
	if cover_slot == null:
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	var cover_distance_sq: float = participant.battle_position.distance_squared_to(cover_slot.position)
	if not is_finite(cover_distance_sq):
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	var hostile_distance_sq: float = _nearest_hostile_distance_sq(battle_state, participant)
	if is_finite(hostile_distance_sq) and hostile_distance_sq < cover_distance_sq:
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_THREAT_OVERRIDE
	if not _ensure_cover_reservation(battle_state, participant, cover_slot):
		var retry_slot: BattleCoverSlot = _query_nearest_reachable_cover(battle_state, participant)
		if retry_slot == null or not _ensure_cover_reservation(battle_state, participant, retry_slot):
			_release_owned_reservation(battle_state, participant)
			return WOUNDED_FALLBACK
		cover_slot = retry_slot
	if participant.battle_position.distance_to(cover_slot.position) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		var occupy: BattleCoverResult = BattleCoverService.occupy_slot(
			battle_state,
			participant.participant_id,
			cover_slot.cover_slot_id
		)
		if occupy != null and occupy.success:
			_clear_owned_combat_navigation(participant)
			return WOUNDED_HOLD_COVER
	if _navigate_to_cover(battle_state, participant, cover_slot):
		return WOUNDED_SEEK_COVER
	_release_owned_reservation(battle_state, participant)
	return WOUNDED_FALLBACK


static func _update_healthy_role_cover_behavior(
	battle_state: BattleState,
	participant: BattleParticipant
) -> String:
	_reconcile_cover_state(battle_state, participant)
	if _has_external_navigation(participant):
		_release_owned_reservation(battle_state, participant)
		return HEALTHY_NONE
	var weapon_type_id: String = _participant_weapon_type_id(participant)
	if not BattleCombatBehaviorCatalog.uses_healthy_role_cover(weapon_type_id):
		if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
			_release_owned_reservation(battle_state, participant)
			_clear_owned_combat_navigation(participant)
		return HEALTHY_NONE
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if _has_valid_occupancy(battle_state, participant):
		if _healthy_occupied_cover_is_suitable(battle_state, participant, target, weapon_type_id):
			_clear_owned_combat_navigation(participant)
			return HEALTHY_HOLD_COVER
		BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
		_reconcile_cover_state(battle_state, participant)
		_clear_owned_combat_navigation(participant)
	if target == null:
		if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
			_release_owned_reservation(battle_state, participant)
			_clear_owned_combat_navigation(participant)
		return HEALTHY_NONE
	if _has_valid_reservation(battle_state, participant):
		var reserved_slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
			participant.reserved_cover_slot_id
		)
		if _healthy_reserved_cover_is_suitable(battle_state, participant, reserved_slot, target, weapon_type_id):
			return _pursue_healthy_role_cover(battle_state, participant, reserved_slot)
		_release_owned_reservation(battle_state, participant)
		if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
			_clear_owned_combat_navigation(participant)
	if _is_immediately_fire_eligible(battle_state, participant, target):
		return HEALTHY_NONE
	var selected_slot: BattleCoverSlot = _reserve_healthy_role_cover_slot(
		battle_state,
		participant,
		target,
		weapon_type_id
	)
	if selected_slot == null:
		return HEALTHY_NONE
	return _pursue_healthy_role_cover(battle_state, participant, selected_slot)


static func _pursue_healthy_role_cover(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot
) -> String:
	if participant == null or slot == null:
		_release_owned_reservation(battle_state, participant)
		return HEALTHY_NONE
	if participant.battle_position.distance_to(slot.position) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		var occupy: BattleCoverResult = BattleCoverService.occupy_slot(
			battle_state,
			participant.participant_id,
			slot.cover_slot_id
		)
		if occupy != null and occupy.success:
			_clear_owned_combat_navigation(participant)
			return HEALTHY_HOLD_COVER
	if _navigate_to_cover(battle_state, participant, slot, MOVE_SEEK_ROLE_COVER):
		return HEALTHY_SEEK_COVER
	_release_owned_reservation(battle_state, participant)
	return HEALTHY_NONE


static func _healthy_current_target(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleParticipant:
	if participant == null or battle_state == null:
		return null
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		return null
	if not battle_state.has_participant(participant.target_participant_id):
		return null
	var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
	if target == null or not target.is_alive or not _is_positioned(target):
		return null
	return target


static func _is_immediately_fire_eligible(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or target == null:
		return false
	var eligibility: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
		battle_state,
		participant.participant_id,
		target.participant_id
	)
	return eligibility != null and eligibility.success and eligibility.can_fire


static func _healthy_occupied_cover_is_suitable(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if not _has_valid_occupancy(battle_state, participant):
		return false
	if target == null:
		return true
	var occupied_slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
		participant.occupied_cover_slot_id
	)
	if _push_applies(battle_state, participant):
		return _healthy_slot_is_within_weapon_max_range(occupied_slot, target, weapon_type_id)
	if weapon_type_id == BattleWeaponCatalog.WEAPON_PISTOL:
		return true
	return _healthy_slot_is_role_suitable(occupied_slot, target, weapon_type_id)


static func _healthy_reserved_cover_is_suitable(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or slot == null or target == null:
		return false
	if not _has_valid_reservation(battle_state, participant):
		return false
	if slot.cover_slot_id != participant.reserved_cover_slot_id:
		return false
	if _push_applies(battle_state, participant):
		return _healthy_slot_is_within_weapon_max_range(slot, target, weapon_type_id)
	if weapon_type_id == BattleWeaponCatalog.WEAPON_PISTOL:
		return true
	return _healthy_slot_is_role_suitable(slot, target, weapon_type_id)


static func _healthy_slot_is_role_suitable(
	slot: BattleCoverSlot,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if slot == null or not slot.is_valid() or target == null:
		return false
	var replan_distance: float = BattleCombatBehaviorCatalog.healthy_cover_replan_distance(weapon_type_id)
	if not is_finite(replan_distance):
		return false
	var slot_range: float = slot.position.distance_to(target.battle_position)
	var band_error: float = BattleCombatBehaviorCatalog.preferred_band_error(weapon_type_id, slot_range)
	if not is_finite(band_error):
		return false
	return band_error <= replan_distance


static func _healthy_slot_is_within_weapon_max_range(
	slot: BattleCoverSlot,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if slot == null or not slot.is_valid() or target == null:
		return false
	if not _is_positioned(target):
		return false
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null or not definition.is_valid():
		return false
	var slot_range: float = slot.position.distance_to(target.battle_position)
	if not is_finite(slot_range):
		return false
	return slot_range <= definition.max_range or is_equal_approx(slot_range, definition.max_range)


static func _reserve_healthy_role_cover_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> BattleCoverSlot:
	var ranked: Array[Dictionary] = _ranked_healthy_cover_candidates(
		battle_state,
		participant,
		target,
		weapon_type_id
	)
	for candidate: Dictionary in ranked:
		var slot_id: String = str(candidate.get("slot_id", ""))
		if slot_id.is_empty() or battle_state.battlefield_geometry == null:
			continue
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot == null or not slot.is_valid():
			continue
		if _ensure_cover_reservation(battle_state, participant, slot):
			return slot
	_release_owned_reservation(battle_state, participant)
	return null


static func _ranked_healthy_cover_candidates(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> Array[Dictionary]:
	var ranked: Array[Dictionary] = []
	if participant == null or target == null or battle_state == null or battle_state.battlefield_geometry == null:
		return ranked
	var seek_radius: float = BattleCombatBehaviorCatalog.healthy_cover_seek_radius(weapon_type_id)
	if not is_finite(seek_radius) or seek_radius <= 0.0:
		return ranked
	var prefer_band: bool = (
		weapon_type_id == BattleWeaponCatalog.WEAPON_RIFLE
		or weapon_type_id == BattleWeaponCatalog.WEAPON_SNIPER
	)
	for slot_id: String in battle_state.battlefield_geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if not _healthy_slot_is_candidate(participant, slot):
			continue
		var move_distance: float = participant.battle_position.distance_to(slot.position)
		if not is_finite(move_distance) or move_distance > seek_radius:
			continue
		if not _healthy_slot_is_reachable(battle_state, participant, slot):
			continue
		if (
			_push_applies(battle_state, participant)
			and not _healthy_slot_is_within_weapon_max_range(slot, target, weapon_type_id)
		):
			continue
		var slot_range: float = slot.position.distance_to(target.battle_position)
		var band_error: float = 0.0
		var in_band: bool = true
		if prefer_band:
			band_error = BattleCombatBehaviorCatalog.preferred_band_error(weapon_type_id, slot_range)
			if not is_finite(band_error):
				continue
			in_band = is_equal_approx(band_error, 0.0)
		var candidate: Dictionary = {
			"slot_id": slot.cover_slot_id,
			"in_band": in_band,
			"band_error": band_error,
			"move_distance": move_distance
		}
		_insert_ranked_cover_candidate(ranked, candidate)
	return ranked


static func _healthy_slot_is_candidate(participant: BattleParticipant, slot: BattleCoverSlot) -> bool:
	if participant == null or slot == null or not slot.is_valid():
		return false
	if slot.occupied_by_participant_id != "" and slot.occupied_by_participant_id != participant.participant_id:
		return false
	if slot.occupied_by_participant_id == participant.participant_id:
		return false
	if slot.reserved_by_participant_id != "" and slot.reserved_by_participant_id != participant.participant_id:
		return false
	return true


static func _healthy_slot_is_reachable(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot
) -> bool:
	if participant == null or slot == null:
		return false
	if participant.battle_position.distance_to(slot.position) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		return true
	if not _is_valid_navigation_destination(battle_state, slot.position):
		return false
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		slot.position
	)
	return navigation != null and navigation.success


static func _insert_ranked_cover_candidate(ranked: Array[Dictionary], candidate: Dictionary) -> void:
	var index: int = 0
	while index < ranked.size() and not _healthy_cover_score_less(candidate, ranked[index]):
		index += 1
	ranked.insert(index, candidate)


static func _healthy_cover_score_less(left: Dictionary, right: Dictionary) -> bool:
	var left_in_band: bool = bool(left.get("in_band", false))
	var right_in_band: bool = bool(right.get("in_band", false))
	if left_in_band != right_in_band:
		return left_in_band and not right_in_band
	var left_error: float = float(left.get("band_error", INF))
	var right_error: float = float(right.get("band_error", INF))
	if not is_equal_approx(left_error, right_error):
		return left_error < right_error
	var left_move: float = float(left.get("move_distance", INF))
	var right_move: float = float(right.get("move_distance", INF))
	if not is_equal_approx(left_move, right_move):
		return left_move < right_move
	return str(left.get("slot_id", "")) < str(right.get("slot_id", ""))


static func _participant_weapon_type_id(participant: BattleParticipant) -> String:
	if participant == null:
		return ""
	if participant.weapon_state != null and not participant.weapon_state.weapon_type_id.is_empty():
		return participant.weapon_state.weapon_type_id
	return participant.weapon_type


static func _reconcile_cover_state(battle_state: BattleState, participant: BattleParticipant) -> void:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not participant.occupied_cover_slot_id.is_empty():
		var occupied: BattleCoverSlot = geometry.get_cover_slot(participant.occupied_cover_slot_id)
		if occupied == null or occupied.occupied_by_participant_id != participant.participant_id:
			participant.occupied_cover_slot_id = ""
	if not participant.reserved_cover_slot_id.is_empty():
		var reserved: BattleCoverSlot = geometry.get_cover_slot(participant.reserved_cover_slot_id)
		if reserved == null or reserved.reserved_by_participant_id != participant.participant_id:
			participant.reserved_cover_slot_id = ""


static func _has_valid_occupancy(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if participant.occupied_cover_slot_id.is_empty():
		return false
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(participant.occupied_cover_slot_id)
	if slot == null or not slot.is_valid():
		return false
	return slot.occupied_by_participant_id == participant.participant_id


static func _has_valid_reservation(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if participant.reserved_cover_slot_id.is_empty():
		return false
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(participant.reserved_cover_slot_id)
	if slot == null or not slot.is_valid():
		return false
	if slot.occupied_by_participant_id != "" and slot.occupied_by_participant_id != participant.participant_id:
		return false
	return slot.reserved_by_participant_id == participant.participant_id


static func _wounded_cover_candidate(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleCoverSlot:
	if _has_valid_reservation(battle_state, participant):
		return battle_state.battlefield_geometry.get_cover_slot(participant.reserved_cover_slot_id)
	return _query_nearest_reachable_cover(battle_state, participant)


static func _query_nearest_reachable_cover(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleCoverSlot:
	if participant == null:
		return null
	var query: BattleCoverQueryResult = BattleCoverService.find_nearest_available_slot(
		battle_state,
		participant.participant_id,
		true
	)
	if query == null or not query.success or query.cover_slot_id.is_empty():
		return null
	if battle_state.battlefield_geometry == null:
		return null
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(query.cover_slot_id)
	if slot == null or not slot.is_valid() or not slot.is_available():
		return null
	return slot


static func _ensure_cover_reservation(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot
) -> bool:
	if participant == null or slot == null:
		return false
	if (
		participant.reserved_cover_slot_id == slot.cover_slot_id
		and slot.reserved_by_participant_id == participant.participant_id
	):
		return true
	var reserved: BattleCoverResult = BattleCoverService.reserve_slot(
		battle_state,
		participant.participant_id,
		slot.cover_slot_id
	)
	return reserved != null and reserved.success


static func _release_owned_reservation(battle_state: BattleState, participant: BattleParticipant) -> void:
	if participant == null or participant.reserved_cover_slot_id.is_empty():
		return
	BattleCoverService.release_reservation(battle_state, participant.participant_id)


static func _navigate_to_cover(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	move_mode: String = MOVE_SEEK_COVER
) -> bool:
	if participant == null or slot == null:
		return false
	if _has_external_navigation(participant):
		return false
	if slot.position.is_equal_approx(participant.battle_position):
		return false
	if _should_keep_cover_path(participant, slot, move_mode):
		_ensure_combat_movement_speed(participant)
		return true
	if not _is_valid_navigation_destination(battle_state, slot.position):
		return false
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		slot.position
	)
	if navigation == null or not navigation.success:
		return false
	if not participant.set_navigation_path(
		navigation.destination,
		navigation.waypoints,
		BattleParticipant.NAVIGATION_SOURCE_COMBAT
	):
		return false
	participant.combat_move_mode = move_mode
	participant.combat_move_target_id = slot.cover_slot_id
	_ensure_combat_movement_speed(participant)
	return true


static func _should_keep_cover_path(
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	move_mode: String = MOVE_SEEK_COVER
) -> bool:
	if participant == null or slot == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != move_mode:
		return false
	if participant.combat_move_target_id != slot.cover_slot_id:
		return false
	var drift: float = participant.navigation_destination.distance_to(slot.position)
	if not is_finite(drift):
		return false
	return drift <= BattleCombatBehaviorCatalog.REPLAN_DISTANCE_EPSILON


static func _nearest_hostile_distance_sq(battle_state: BattleState, source: BattleParticipant) -> float:
	if battle_state == null or source == null:
		return INF
	var best_distance: float = INF
	var best_id: String = ""
	for participant_id: String in _sorted_participant_ids(battle_state):
		var candidate: BattleParticipant = battle_state.get_participant(participant_id)
		if not _is_eligible_threat(battle_state, source, candidate):
			continue
		var distance: float = source.battle_position.distance_squared_to(candidate.battle_position)
		if not is_finite(distance):
			continue
		if best_id.is_empty() or distance < best_distance:
			best_distance = distance
			best_id = participant_id
	return best_distance


static func _is_eligible_threat(
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
	if not _is_positioned(candidate):
		return false
	if source.side_id.is_empty() or candidate.side_id.is_empty():
		return false
	if not battle_state.has_side(source.side_id) or not battle_state.has_side(candidate.side_id):
		return false
	return source.side_id != candidate.side_id


static func _update_combat_movement(
	battle_state: BattleState,
	participant: BattleParticipant
) -> int:
	if participant == null:
		return MOVEMENT_NONE
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if not battle_state.has_participant(participant.target_participant_id):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
	if target == null or not target.is_alive or not _is_positioned(target):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if _has_external_navigation(participant):
		return MOVEMENT_NONE
	var move_mode: String = _desired_move_mode(battle_state, participant, target)
	var hold_constrained: bool = false
	var push_pressure: bool = false
	var focus_bias_applied: bool = false
	var focus_left: bool = false
	if move_mode == MOVE_APPROACH and _hold_suppresses_target_approach(battle_state, participant):
		move_mode = MOVE_HOLD
		hold_constrained = true
	elif move_mode == MOVE_APPROACH and _push_applies(battle_state, participant):
		push_pressure = true
	elif move_mode != MOVE_RETREAT and _fall_back_applies(battle_state, participant):
		move_mode = MOVE_FALL_BACK
	if move_mode == MOVE_HOLD:
		_clear_owned_combat_navigation(participant)
		if hold_constrained:
			return MOVEMENT_HOLD_CONSTRAINED
		return MOVEMENT_NONE
	if move_mode == MOVE_FALL_BACK:
		return _update_fall_back_movement(battle_state, participant, target)
	if (
		move_mode == MOVE_APPROACH
		and _should_suppress_autonomous_aggressive_approach(battle_state, participant, push_pressure)
	):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_PRESSURE_SUPPRESSED
	var destination: Vector2 = Vector2.ZERO
	var unbiased_destination: Vector2 = Vector2.ZERO
	if move_mode == MOVE_APPROACH:
		if push_pressure:
			destination = _push_approach_destination(battle_state, participant, target)
			unbiased_destination = destination
		elif _focus_applies(battle_state, participant):
			unbiased_destination = _push_approach_destination(battle_state, participant, target)
			var biased_destination: Vector2 = _focus_biased_destination(
				battle_state,
				participant,
				target,
				unbiased_destination
			)
			if (
				_is_finite_vector(biased_destination)
				and not biased_destination.is_equal_approx(unbiased_destination)
			):
				destination = biased_destination
				focus_bias_applied = true
				focus_left = (
					_participant_force_command_id(battle_state, participant)
					== BattleForceCommandCatalog.COMMAND_FOCUS_LEFT
				)
			else:
				destination = unbiased_destination
		else:
			destination = target.battle_position
			unbiased_destination = destination
	else:
		destination = _retreat_destination(battle_state, participant, target)
		unbiased_destination = destination
		if not _is_finite_vector(destination):
			_clear_owned_combat_navigation(participant)
			return MOVEMENT_NONE
	if not _is_finite_vector(destination):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if destination.is_equal_approx(participant.battle_position):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if _should_keep_combat_path(participant, target, move_mode, destination):
		_ensure_combat_movement_speed(participant)
		return _approach_movement_status(push_pressure, focus_bias_applied, focus_left)
	if not _is_valid_navigation_destination(battle_state, destination):
		if (
			focus_bias_applied
			and _is_valid_navigation_destination(battle_state, unbiased_destination)
			and not unbiased_destination.is_equal_approx(participant.battle_position)
		):
			destination = unbiased_destination
			focus_bias_applied = false
		else:
			_clear_owned_combat_navigation(participant)
			return MOVEMENT_NONE
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		destination
	)
	if navigation == null or not navigation.success:
		if (
			focus_bias_applied
			and _is_valid_navigation_destination(battle_state, unbiased_destination)
			and not unbiased_destination.is_equal_approx(participant.battle_position)
		):
			navigation = BattleNavigationService.find_path(
				battle_state,
				participant.battle_position,
				unbiased_destination
			)
			destination = unbiased_destination
			focus_bias_applied = false
		if navigation == null or not navigation.success:
			_clear_owned_combat_navigation(participant)
			return MOVEMENT_NONE
	if not participant.set_navigation_path(
		navigation.destination,
		navigation.waypoints,
		BattleParticipant.NAVIGATION_SOURCE_COMBAT
	):
		return MOVEMENT_NONE
	participant.combat_move_mode = move_mode
	participant.combat_move_target_id = target.participant_id
	_ensure_combat_movement_speed(participant)
	return _approach_movement_status(push_pressure, focus_bias_applied, focus_left)


static func _participant_force_command_id(
	battle_state: BattleState,
	participant: BattleParticipant
) -> String:
	if battle_state == null or participant == null:
		return ""
	return BattleForceCommandService.get_command_for_participant(
		battle_state,
		participant.participant_id
	)


static func _hold_suppresses_target_approach(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null:
		return false
	if participant.is_wounded:
		return false
	var command_id: String = _participant_force_command_id(battle_state, participant)
	return command_id == BattleForceCommandCatalog.COMMAND_HOLD


static func _push_applies(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if participant.is_wounded:
		return false
	var command_id: String = _participant_force_command_id(battle_state, participant)
	return command_id == BattleForceCommandCatalog.COMMAND_PUSH


static func _focus_applies(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if participant.is_wounded:
		return false
	var command_id: String = _participant_force_command_id(battle_state, participant)
	if (
		command_id != BattleForceCommandCatalog.COMMAND_FOCUS_LEFT
		and command_id != BattleForceCommandCatalog.COMMAND_FOCUS_RIGHT
	):
		return false
	var forward: Vector2 = BattleForceCommandService.get_forward_direction_for_participant(
		battle_state,
		participant.participant_id
	)
	return BattleForceCommandService.is_valid_forward_direction(forward)


static func _fall_back_applies(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if participant.is_wounded:
		return false
	var command_id: String = _participant_force_command_id(battle_state, participant)
	if command_id != BattleForceCommandCatalog.COMMAND_FALL_BACK:
		return false
	var forward: Vector2 = BattleForceCommandService.get_forward_direction_for_participant(
		battle_state,
		participant.participant_id
	)
	return BattleForceCommandService.is_valid_forward_direction(forward)


static func _update_fall_back_movement(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> int:
	if participant == null or target == null:
		return MOVEMENT_NONE
	if _should_keep_fall_back_path(battle_state, participant):
		_ensure_combat_movement_speed(participant)
		return MOVEMENT_FALL_BACK
	var sampled: Dictionary = _fall_back_destination(battle_state, participant, target)
	if not bool(sampled.get("found", false)):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if typeof(sampled.get("destination", null)) != TYPE_VECTOR2:
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	var destination: Vector2 = sampled["destination"] as Vector2
	if not _is_finite_vector(destination):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if destination.is_equal_approx(participant.battle_position):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if not _is_valid_navigation_destination(battle_state, destination):
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		destination
	)
	if navigation == null or not navigation.success:
		_clear_owned_combat_navigation(participant)
		return MOVEMENT_NONE
	if not participant.set_navigation_path(
		navigation.destination,
		navigation.waypoints,
		BattleParticipant.NAVIGATION_SOURCE_COMBAT
	):
		return MOVEMENT_NONE
	participant.combat_move_mode = MOVE_FALL_BACK
	participant.combat_move_target_id = target.participant_id
	_ensure_combat_movement_speed(participant)
	return MOVEMENT_FALL_BACK


static func _should_keep_fall_back_path(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != MOVE_FALL_BACK:
		return false
	var destination: Vector2 = participant.navigation_destination
	if not _is_finite_vector(destination):
		return false
	if destination.is_equal_approx(participant.battle_position):
		return false
	if not _is_valid_navigation_destination(battle_state, destination):
		return false
	var forward: Vector2 = BattleForceCommandService.get_forward_direction_for_participant(
		battle_state,
		participant.participant_id
	)
	return _is_rearward_or_neutral_displacement(participant.battle_position, destination, forward)


static func _fall_back_destination_result(found: bool, destination: Vector2 = Vector2.ZERO) -> Dictionary:
	var result: Dictionary = {}
	result["found"] = found
	if found:
		result["destination"] = destination
	return result


static func _fall_back_destination(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant
) -> Dictionary:
	if source == null or battle_state == null:
		return _fall_back_destination_result(false)
	var rear: Vector2 = BattleForceCommandService.get_rear_direction_for_participant(
		battle_state,
		source.participant_id
	)
	if not _is_finite_vector(rear) or rear.is_equal_approx(Vector2.ZERO):
		return _fall_back_destination_result(false)
	if not is_equal_approx(rear.length_squared(), 1.0):
		rear = rear.normalized()
		if not _is_finite_vector(rear) or rear.is_equal_approx(Vector2.ZERO):
			return _fall_back_destination_result(false)
	var forward: Vector2 = BattleForceCommandService.get_forward_direction_for_participant(
		battle_state,
		source.participant_id
	)
	if not BattleForceCommandService.is_valid_forward_direction(forward):
		return _fall_back_destination_result(false)
	var distance: float = BattleCombatBehaviorCatalog.FALL_BACK_DISTANCE
	if not is_finite(distance) or distance <= 0.0:
		return _fall_back_destination_result(false)
	var preferred_min: float = 0.0
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(
		_participant_weapon_type_id(source)
	)
	if profile != null and is_finite(profile.preferred_min_distance):
		preferred_min = profile.preferred_min_distance
	for step_index: int in range(16, 0, -1):
		var scale: float = float(step_index) / 16.0
		var candidate: Vector2 = source.battle_position + rear * (distance * scale)
		if not _is_finite_vector(candidate):
			continue
		if candidate.is_equal_approx(source.battle_position):
			continue
		if not _is_rearward_or_neutral_displacement(source.battle_position, candidate, forward):
			continue
		if not _is_valid_navigation_destination(battle_state, candidate):
			continue
		if preferred_min > 0.0 and target != null and _is_positioned(target):
			var candidate_range: float = candidate.distance_to(target.battle_position)
			if (
				is_finite(candidate_range)
				and candidate_range < preferred_min
				and not is_equal_approx(candidate_range, preferred_min)
			):
				continue
		return _fall_back_destination_result(true, candidate)
	return _fall_back_destination_result(false)


static func _is_rearward_or_neutral_displacement(
	current_position: Vector2,
	destination: Vector2,
	forward: Vector2
) -> bool:
	if not _is_finite_vector(current_position) or not _is_finite_vector(destination):
		return false
	if not BattleForceCommandService.is_valid_forward_direction(forward):
		return false
	var offset: Vector2 = destination - current_position
	if not _is_finite_vector(offset):
		return false
	var along_forward: float = offset.dot(forward)
	if not is_finite(along_forward):
		return false
	if along_forward > 0.0 and not is_equal_approx(along_forward, 0.0):
		return false
	return true


static func _focus_lateral_direction(
	battle_state: BattleState,
	participant: BattleParticipant
) -> Vector2:
	var command_id: String = _participant_force_command_id(battle_state, participant)
	if command_id == BattleForceCommandCatalog.COMMAND_FOCUS_LEFT:
		return BattleForceCommandService.get_left_direction_for_participant(
			battle_state,
			participant.participant_id
		)
	if command_id == BattleForceCommandCatalog.COMMAND_FOCUS_RIGHT:
		return BattleForceCommandService.get_right_direction_for_participant(
			battle_state,
			participant.participant_id
		)
	return Vector2.ZERO


static func _focus_biased_destination(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant,
	base_destination: Vector2
) -> Vector2:
	if source == null or target == null:
		return base_destination
	if not _is_finite_vector(base_destination):
		return base_destination
	if base_destination.is_equal_approx(source.battle_position):
		return base_destination
	var lateral: Vector2 = _focus_lateral_direction(battle_state, source)
	if not _is_finite_vector(lateral) or lateral.is_equal_approx(Vector2.ZERO):
		return base_destination
	if not is_equal_approx(lateral.length_squared(), 1.0):
		lateral = lateral.normalized()
		if not _is_finite_vector(lateral) or lateral.is_equal_approx(Vector2.ZERO):
			return base_destination
	var offset: float = BattleCombatBehaviorCatalog.FOCUS_LATERAL_OFFSET
	if not is_finite(offset) or offset <= 0.0:
		return base_destination
	var candidate: Vector2 = base_destination + lateral * offset
	if not _is_finite_vector(candidate):
		return base_destination
	var offset_from_target: Vector2 = candidate - target.battle_position
	var direction: Vector2 = Vector2.ZERO
	var radius: float = 0.0
	if _is_finite_vector(offset_from_target) and not offset_from_target.is_equal_approx(Vector2.ZERO):
		radius = offset_from_target.length()
		direction = offset_from_target.normalized()
	if not _is_finite_vector(direction) or direction.is_equal_approx(Vector2.ZERO):
		direction = lateral
		radius = 0.0
	if not _is_finite_vector(direction) or direction.is_equal_approx(Vector2.ZERO):
		return base_destination
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(
		_participant_weapon_type_id(source)
	)
	if profile != null:
		var preferred_min: float = profile.preferred_min_distance
		var preferred_max: float = profile.preferred_max_distance
		if (
			is_finite(preferred_min)
			and is_finite(preferred_max)
			and preferred_max >= preferred_min
		):
			if radius < preferred_min and not is_equal_approx(radius, preferred_min):
				radius = preferred_min
			elif radius > preferred_max and not is_equal_approx(radius, preferred_max):
				radius = preferred_max
	var projected: Vector2 = target.battle_position + direction * radius
	if not _is_finite_vector(projected):
		return base_destination
	if not _is_valid_navigation_destination(battle_state, projected):
		return base_destination
	if profile != null and not _focus_range_is_in_preferred_band(
		projected.distance_to(target.battle_position),
		profile
	):
		return base_destination
	if projected.is_equal_approx(source.battle_position):
		return base_destination
	return projected


static func _focus_range_is_in_preferred_band(
	range_distance: float,
	profile: BattleCombatBehaviorProfile
) -> bool:
	if profile == null or not is_finite(range_distance):
		return false
	if (
		range_distance < profile.preferred_min_distance
		and not is_equal_approx(range_distance, profile.preferred_min_distance)
	):
		return false
	if (
		range_distance > profile.preferred_max_distance
		and not is_equal_approx(range_distance, profile.preferred_max_distance)
	):
		return false
	return true


static func _approach_movement_status(
	push_pressure: bool,
	focus_bias_applied: bool,
	focus_left: bool
) -> int:
	if push_pressure:
		return MOVEMENT_PUSH_PRESSURE
	if focus_bias_applied:
		if focus_left:
			return MOVEMENT_FOCUS_LEFT
		return MOVEMENT_FOCUS_RIGHT
	return MOVEMENT_REPOSITIONING


static func _should_suppress_autonomous_aggressive_approach(
	battle_state: BattleState,
	participant: BattleParticipant,
	push_pressure: bool
) -> bool:
	if push_pressure:
		return false
	if _focus_applies(battle_state, participant):
		return false
	var policy_result: BattleCombatPressureBehaviorPolicyResult = BattleCombatPressureBehaviorPolicy.evaluate(
		battle_state,
		participant
	)
	if policy_result == null:
		return false
	return policy_result.suppress_aggressive_autonomous_movement


static func _push_uses_controlled_advance(weapon_type_id: String) -> bool:
	return (
		weapon_type_id == BattleWeaponCatalog.WEAPON_RIFLE
		or weapon_type_id == BattleWeaponCatalog.WEAPON_SNIPER
	)


static func _push_approach_destination(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant
) -> Vector2:
	if source == null or target == null:
		return Vector2.ZERO
	var weapon_type_id: String = _participant_weapon_type_id(source)
	if not _push_uses_controlled_advance(weapon_type_id):
		return target.battle_position
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if profile == null:
		return source.battle_position
	var distance: float = source.battle_position.distance_to(target.battle_position)
	var stand_off_distance: float = profile.preferred_max_distance
	if is_finite(distance) and distance <= profile.preferred_max_distance:
		stand_off_distance = profile.preferred_min_distance
	return _preferred_band_stand_off(
		battle_state,
		source,
		target,
		profile.preferred_min_distance,
		stand_off_distance
	)


static func _preferred_band_stand_off(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant,
	preferred_min_distance: float,
	stand_off_distance: float
) -> Vector2:
	if source == null or target == null:
		return Vector2.ZERO
	if not is_finite(preferred_min_distance) or not is_finite(stand_off_distance):
		return source.battle_position
	var away: Vector2 = source.battle_position - target.battle_position
	if not _is_finite_vector(away) or away.is_equal_approx(Vector2.ZERO):
		away = Vector2(1.0, 0.0)
	away = away.normalized()
	if not _is_finite_vector(away) or away.is_equal_approx(Vector2.ZERO):
		return source.battle_position
	var ideal: Vector2 = target.battle_position + away * stand_off_distance
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return source.battle_position
	ideal.x = clampf(ideal.x, 0.0, geometry.width)
	ideal.y = clampf(ideal.y, 0.0, geometry.height)
	var steps: Array[float] = [1.0, 0.75, 0.5, 0.25]
	for step: float in steps:
		var candidate: Vector2 = source.battle_position.lerp(ideal, step)
		if not _is_valid_navigation_destination(battle_state, candidate):
			continue
		if candidate.is_equal_approx(source.battle_position):
			continue
		var candidate_range: float = candidate.distance_to(target.battle_position)
		if not is_finite(candidate_range):
			continue
		if candidate_range < preferred_min_distance and not is_equal_approx(candidate_range, preferred_min_distance):
			continue
		return candidate
	return source.battle_position


static func _desired_move_mode(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant
) -> String:
	var eligibility: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
		battle_state,
		source.participant_id,
		target.participant_id
	)
	var rejection_code: String = ""
	if eligibility != null and eligibility.success:
		rejection_code = eligibility.rejection_code
	var distance: float = source.battle_position.distance_to(target.battle_position)
	if not is_finite(distance):
		return MOVE_HOLD
	var weapon_type_id: String = ""
	if source.weapon_state != null and not source.weapon_state.weapon_type_id.is_empty():
		weapon_type_id = source.weapon_state.weapon_type_id
	elif not source.weapon_type.is_empty():
		weapon_type_id = source.weapon_type
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if profile == null:
		if rejection_code == "out_of_range" or rejection_code == "line_of_sight_blocked":
			return MOVE_APPROACH
		return MOVE_HOLD
	if profile.preferred_min_distance > 0.0 and distance < profile.preferred_min_distance:
		return MOVE_RETREAT
	if distance > profile.preferred_max_distance or rejection_code == "out_of_range":
		return MOVE_APPROACH
	if rejection_code == "line_of_sight_blocked":
		return MOVE_APPROACH
	return MOVE_HOLD


static func _retreat_destination(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant
) -> Vector2:
	var weapon_type_id: String = ""
	if source.weapon_state != null and not source.weapon_state.weapon_type_id.is_empty():
		weapon_type_id = source.weapon_state.weapon_type_id
	elif not source.weapon_type.is_empty():
		weapon_type_id = source.weapon_type
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if profile == null:
		return Vector2.ZERO
	var away: Vector2 = source.battle_position - target.battle_position
	if not _is_finite_vector(away) or away.is_equal_approx(Vector2.ZERO):
		away = Vector2(1.0, 0.0)
	away = away.normalized()
	if not _is_finite_vector(away) or away.is_equal_approx(Vector2.ZERO):
		return Vector2.ZERO
	var ideal: Vector2 = target.battle_position + away * profile.preferred_min_distance
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return Vector2.ZERO
	ideal.x = clampf(ideal.x, 0.0, geometry.width)
	ideal.y = clampf(ideal.y, 0.0, geometry.height)
	var steps: Array[float] = [1.0, 0.75, 0.5, 0.25]
	for step: float in steps:
		var candidate: Vector2 = source.battle_position.lerp(ideal, step)
		if _is_valid_navigation_destination(battle_state, candidate):
			if not candidate.is_equal_approx(source.battle_position):
				return candidate
	return Vector2.ZERO


static func _should_keep_combat_path(
	participant: BattleParticipant,
	target: BattleParticipant,
	move_mode: String,
	destination: Vector2
) -> bool:
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != move_mode:
		return false
	if participant.combat_move_target_id != target.participant_id:
		return false
	var drift: float = participant.navigation_destination.distance_to(destination)
	if not is_finite(drift):
		return false
	return drift <= BattleCombatBehaviorCatalog.REPLAN_DISTANCE_EPSILON


static func _is_valid_navigation_destination(battle_state: BattleState, point: Vector2) -> bool:
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


static func _has_external_navigation(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_EXTERNAL:
		return false
	return participant.has_active_navigation_path()


static func _clear_owned_combat_navigation(participant: BattleParticipant) -> void:
	if participant == null:
		return
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		participant.combat_move_mode = ""
		participant.combat_move_target_id = ""
		return
	participant.clear_navigation_path()


static func _ensure_combat_movement_speed(participant: BattleParticipant) -> void:
	if participant == null:
		return
	if participant.is_wounded:
		_ensure_wounded_combat_movement_speed(participant)
		return
	if is_finite(participant.movement_speed) and participant.movement_speed > 0.0:
		return
	participant.set_movement_speed(BattleCombatBehaviorCatalog.DEFAULT_COMBAT_MOVEMENT_SPEED)


static func _ensure_wounded_combat_movement_speed(participant: BattleParticipant) -> void:
	if participant == null:
		return
	var wounded_speed: float = BattleCombatBehaviorCatalog.WOUNDED_COMBAT_MOVEMENT_SPEED
	if not is_finite(participant.movement_speed) or participant.movement_speed <= 0.0:
		participant.set_movement_speed(wounded_speed)
		return
	if participant.movement_speed > wounded_speed:
		participant.set_movement_speed(wounded_speed)


static func _is_positioned(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.has_battle_position:
		return false
	return _is_finite_vector(participant.battle_position)


static func _is_finite_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids
