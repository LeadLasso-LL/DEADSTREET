class_name BattleCombatBehaviorService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverResult := preload("res://battle/geometry/battle_cover_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")
const BattleCoverPostureService := preload("res://battle/combat/battle_cover_posture_service.gd")
const BattleLineOfSightService := preload("res://battle/combat/battle_line_of_sight_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")
const BattleCombatCoverEvaluation := preload("res://battle/combat/battle_combat_cover_evaluation.gd")
const BattleCombatCoverEvaluationService := preload(
	"res://battle/combat/battle_combat_cover_evaluation_service.gd"
)
const BattleDefendPositionService := preload("res://battle/combat/battle_defend_position_service.gd")
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
const MOVE_CLOSE := "close"
const MOVE_DEFEND_REPOSITION := "defend_reposition"
const MOVE_WOUNDED_REENTER := "wounded_reenter"

const WOUNDED_HOLD_COVER := "hold_cover"
const WOUNDED_SEEK_COVER := "seek_cover"
const WOUNDED_THREAT_OVERRIDE := "threat_override"
const WOUNDED_FALLBACK := "fallback"

const HEALTHY_HOLD_COVER := "hold_cover"
const HEALTHY_SEEK_COVER := "seek_role_cover"
const HEALTHY_NONE := ""

const DEFEND_HOLD := "hold"
const DEFEND_REPOSITION := "reposition"

const MOVEMENT_NONE := 0
const MOVEMENT_REPOSITIONING := 1
const MOVEMENT_HOLD_CONSTRAINED := 2
const MOVEMENT_PUSH_PRESSURE := 3
const MOVEMENT_FOCUS_LEFT := 4
const MOVEMENT_FOCUS_RIGHT := 5
const MOVEMENT_FALL_BACK := 6
const MOVEMENT_PRESSURE_SUPPRESSED := 7

# Expensive tactical search selects a destination. Cheap per-tick logic
# executes and validates it. Full cover ranking, visibility-graph pathfinding,
# and 64-point defend sampling must not rerun every tick while a combat-owned
# route toward a still-valid decision is already in progress.


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
	var hits: int = 0
	var wounded: int = 0
	var killed: int = 0
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
	var search_counts: Dictionary = {
		"healthy": 0,
		"wounded": 0,
		"defend": 0,
		"nav": 0,
	}
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
		_update_acquire_reaction(battle_state, participant)
		_update_sniper_aim(battle_state, participant)
		if participant.defend_position:
			participants_holding_defend_position += 1
			var defend_action: String = _update_defend_position_behavior(
				battle_state,
				participant,
				search_counts
			)
			_update_occupied_cover_posture(
				battle_state,
				participant,
				delta_seconds,
				execute_autonomous_attacks
			)
			if defend_action == DEFEND_REPOSITION:
				participants_repositioning += 1
				continue
			if execute_autonomous_attacks:
				var defended_shot: BattleAttackEvent = _try_execute_shot(battle_state, participant)
				if defended_shot != null:
					attack_events.append(defended_shot)
			continue
		if participant.is_wounded:
			_clear_no_role_cover_decision(participant)
			var wounded_action: String = _update_wounded_cover_behavior(
				battle_state,
				participant,
				search_counts,
				delta_seconds
			)
			_update_occupied_cover_posture(
				battle_state,
				participant,
				delta_seconds,
				execute_autonomous_attacks
			)
			if wounded_action == WOUNDED_HOLD_COVER:
				wounded_holding_cover += 1
				_halt_wounded_stand_motion(participant)
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
			# Threat override and no-cover fallback may fire, hold, or retreat.
			# They must not approach the hostile. _update_combat_movement enforces that.
		else:
			var healthy_action: String = _update_healthy_role_cover_behavior(
				battle_state,
				participant,
				search_counts,
				delta_seconds
			)
			_update_occupied_cover_posture(
				battle_state,
				participant,
				delta_seconds,
				execute_autonomous_attacks
			)
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
				if not _should_continue_closing_after_shot(battle_state, participant):
					_clear_owned_combat_navigation(participant)
					if participant.is_wounded:
						_halt_wounded_stand_motion(participant)
					continue
		var movement_status: int = _update_combat_movement(
			battle_state,
			participant,
			search_counts
		)
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
			BattleAttackProfile.OUTCOME_HIT:
				hits += 1
			BattleAttackProfile.OUTCOME_WOUNDED:
				wounded += 1
			BattleAttackProfile.OUTCOME_KILLED:
				killed += 1
	var result: BattleCombatBehaviorResult = BattleCombatBehaviorResult.succeeded(
		participants_considered,
		shots_executed,
		misses,
		grazes,
		hits,
		wounded,
		killed,
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
	result.healthy_cover_searches = int(search_counts.get("healthy", 0))
	result.wounded_cover_searches = int(search_counts.get("wounded", 0))
	result.defend_sample_searches = int(search_counts.get("defend", 0))
	result.combat_path_searches = int(search_counts.get("nav", 0))
	return result


static func _update_acquire_reaction(
	battle_state: BattleState,
	participant: BattleParticipant
) -> void:
	if participant == null:
		return
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		_clear_acquire_reaction(participant)
		return
	if not battle_state.has_participant(participant.target_participant_id):
		_clear_acquire_reaction(participant)
		return
	var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
	if not BattleFireControlService.is_spatial_fire_engagement(battle_state, participant, target):
		_clear_acquire_reaction(participant)
		return
	var engaged_target_id: String = target.participant_id
	if participant.acquire_reaction_target_id == engaged_target_id:
		if participant.has_wound_reaction():
			participant.acquire_reaction_remaining_seconds = 0.0
		return
	participant.acquire_reaction_target_id = engaged_target_id
	if participant.has_wound_reaction():
		participant.acquire_reaction_remaining_seconds = 0.0
		return
	participant.acquire_reaction_remaining_seconds = (
		BattleCombatBehaviorCatalog.HEALTHY_FIRST_SHOT_REACTION_SECONDS
	)


static func _clear_acquire_reaction(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.acquire_reaction_remaining_seconds = 0.0
	participant.acquire_reaction_target_id = ""


static func _update_sniper_aim(
	battle_state: BattleState,
	participant: BattleParticipant
) -> void:
	if participant == null:
		return
	if _participant_weapon_type_id(participant) != BattleWeaponCatalog.WEAPON_SNIPER:
		return
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		participant.sniper_aim_engagement_active = false
		return
	if not battle_state.has_participant(participant.target_participant_id):
		participant.sniper_aim_engagement_active = false
		return
	var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
	if not BattleFireControlService.is_spatial_fire_engagement(battle_state, participant, target):
		participant.sniper_aim_engagement_active = false
		return
	var engaged_target_id: String = target.participant_id
	if (
		participant.sniper_aim_engagement_active
		and participant.sniper_aim_target_id == engaged_target_id
	):
		if participant.has_wound_reaction():
			participant.sniper_aim_remaining_seconds = 0.0
		return
	var is_initial_aim: bool = participant.sniper_aim_target_id.is_empty()
	participant.sniper_aim_target_id = engaged_target_id
	participant.sniper_aim_engagement_active = true
	if participant.has_wound_reaction():
		participant.sniper_aim_remaining_seconds = 0.0
		return
	if is_initial_aim:
		participant.sniper_aim_remaining_seconds = (
			BattleCombatBehaviorCatalog.SNIPER_INITIAL_AIM_SECONDS
		)
		return
	participant.sniper_aim_remaining_seconds = (
		BattleCombatBehaviorCatalog.SNIPER_TARGET_CHANGE_REACQUIRE_SECONDS
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
	if _should_withhold_out_of_band_shot(battle_state, participant, target):
		return null
	if participant.has_acquire_reaction():
		return null
	if participant.has_sniper_aim():
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


static func _update_defend_position_behavior(
	battle_state: BattleState,
	participant: BattleParticipant,
	search_counts: Dictionary
) -> String:
	_reconcile_cover_state(battle_state, participant)
	if _has_external_navigation(participant):
		_release_owned_reservation(battle_state, participant)
		return DEFEND_HOLD
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if _defend_can_fire(battle_state, participant, target):
		_try_occupy_arrived_defend_cover(battle_state, participant)
		_clear_owned_combat_navigation(participant)
		return DEFEND_HOLD
	if not _defend_los_blocks_fire(battle_state, participant, target):
		_clear_owned_combat_navigation(participant)
		return DEFEND_HOLD
	if _defend_keep_current_path(battle_state, participant, target):
		_bind_combat_decision(battle_state, participant, _combat_context_id(target))
		_ensure_combat_movement_speed(participant)
		return DEFEND_REPOSITION
	_increment_search(search_counts, "defend")
	var cover_slot: BattleCoverSlot = BattleDefendPositionService.select_best_local_cover_slot(
		battle_state,
		participant,
		target
	)
	if cover_slot != null:
		if _has_valid_occupancy(battle_state, participant):
			if participant.occupied_cover_slot_id != cover_slot.cover_slot_id:
				BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
				_reconcile_cover_state(battle_state, participant)
		var cover_action: String = _pursue_defend_cover(
			battle_state,
			participant,
			cover_slot,
			search_counts
		)
		if not cover_action.is_empty():
			return cover_action
	var sample: Vector2 = BattleDefendPositionService.select_best_local_los_point(
		battle_state,
		participant,
		target
	)
	if BattlefieldGeometry.is_finite_point(sample):
		if _has_valid_occupancy(battle_state, participant):
			BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
			_reconcile_cover_state(battle_state, participant)
		_release_owned_reservation(battle_state, participant)
		if _navigate_to_defend_point(battle_state, participant, sample, target, search_counts):
			return DEFEND_REPOSITION
	_clear_owned_combat_navigation(participant)
	return DEFEND_HOLD


static func _defend_can_fire(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or target == null:
		return false
	return BattleFireControlService.would_fire_if_source_cover_exposed(
		battle_state,
		participant.participant_id,
		target.participant_id
	)


static func _defend_los_blocks_fire(
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
	return (
		eligibility != null
		and eligibility.success
		and not eligibility.can_fire
		and eligibility.rejection_code == "line_of_sight_blocked"
	)


static func _defend_keep_current_path(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or target == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != MOVE_DEFEND_REPOSITION:
		return false
	if not _combat_decision_matches(battle_state, participant, _combat_context_id(target)):
		return false
	return BattleDefendPositionService.destination_still_valid(
		battle_state,
		participant,
		target,
		participant.navigation_destination,
		false
	)


static func _try_occupy_arrived_defend_cover(
	battle_state: BattleState,
	participant: BattleParticipant
) -> void:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return
	var slot_id: String = participant.reserved_cover_slot_id
	if slot_id.is_empty():
		slot_id = participant.combat_move_target_id
	if slot_id.is_empty():
		return
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
	if slot == null or not slot.is_valid():
		return
	if participant.battle_position.distance_to(slot.position) > BattleCoverService.COVER_OCCUPANCY_EPSILON:
		return
	BattleCoverService.occupy_slot(battle_state, participant.participant_id, slot.cover_slot_id)


static func _pursue_defend_cover(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	search_counts: Dictionary
) -> String:
	if participant == null or slot == null:
		return ""
	if not _ensure_cover_reservation(battle_state, participant, slot):
		_release_owned_reservation(battle_state, participant)
		return ""
	if participant.battle_position.distance_to(slot.position) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		var occupy: BattleCoverResult = BattleCoverService.occupy_slot(
			battle_state,
			participant.participant_id,
			slot.cover_slot_id
		)
		if occupy != null and occupy.success:
			_clear_owned_combat_navigation(participant)
			return DEFEND_HOLD
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if _navigate_to_cover(
		battle_state,
		participant,
		slot,
		MOVE_DEFEND_REPOSITION,
		_combat_context_id(target),
		search_counts
	):
		return DEFEND_REPOSITION
	return ""


static func _navigate_to_defend_point(
	battle_state: BattleState,
	participant: BattleParticipant,
	destination: Vector2,
	target: BattleParticipant,
	search_counts: Dictionary
) -> bool:
	if participant == null or not BattlefieldGeometry.is_finite_point(destination):
		return false
	if _has_external_navigation(participant):
		return false
	if destination.is_equal_approx(participant.battle_position):
		return false
	if (
		participant.navigation_source == BattleParticipant.NAVIGATION_SOURCE_COMBAT
		and participant.has_active_navigation_path()
		and participant.combat_move_mode == MOVE_DEFEND_REPOSITION
	):
		var drift: float = participant.navigation_destination.distance_to(destination)
		if is_finite(drift) and drift <= BattleCombatBehaviorCatalog.REPLAN_DISTANCE_EPSILON:
			_bind_combat_decision(battle_state, participant, _combat_context_id(target))
			_ensure_combat_movement_speed(participant)
			return true
	if not _is_valid_navigation_destination(battle_state, destination):
		return false
	var navigation: BattleNavigationResult = _find_combat_navigation_path(
		battle_state,
		participant.battle_position,
		destination,
		search_counts
	)
	if navigation == null or not navigation.success:
		return false
	if not participant.set_navigation_path(
		navigation.destination,
		navigation.waypoints,
		BattleParticipant.NAVIGATION_SOURCE_COMBAT
	):
		return false
	participant.combat_move_mode = MOVE_DEFEND_REPOSITION
	participant.combat_move_target_id = ""
	_bind_combat_decision(battle_state, participant, _combat_context_id(target))
	_ensure_combat_movement_speed(participant)
	return true


static func _update_wounded_cover_behavior(
	battle_state: BattleState,
	participant: BattleParticipant,
	search_counts: Dictionary,
	delta_seconds: float
) -> String:
	_reconcile_cover_state(battle_state, participant)
	if _wounded_keep_reenter_decision(battle_state, participant):
		return WOUNDED_SEEK_COVER
	if _has_valid_occupancy(battle_state, participant):
		if _wounded_occupied_cover_is_suitable(battle_state, participant):
			_clear_owned_combat_navigation(participant)
			if _wounded_should_break_stalemate(battle_state, participant, delta_seconds):
				return _wounded_break_stalemate(battle_state, participant, search_counts)
			return WOUNDED_HOLD_COVER
		participant.combat_wounded_stall_seconds = 0.0
		BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
		_reconcile_cover_state(battle_state, participant)
		_clear_owned_combat_navigation(participant)
	else:
		participant.combat_wounded_stall_seconds = 0.0
	if _has_external_navigation(participant):
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	var hostile: BattleParticipant = _active_hostile(battle_state, participant)
	if _wounded_keep_current_cover_decision(battle_state, participant, hostile):
		var kept_slot: BattleCoverSlot = _reserved_cover_slot(battle_state, participant)
		return _commit_wounded_cover_slot(battle_state, participant, kept_slot, hostile, search_counts)
	_increment_search(search_counts, "wounded")
	var ranked: Array[BattleCombatCoverEvaluation] = BattleCombatCoverEvaluationService.rank_combat_usable(
		battle_state,
		participant,
		hostile,
		false,
		BattleCombatBehaviorCatalog.WOUNDED_COVER_SEEK_RADIUS
	)
	var cover_slot: BattleCoverSlot = _first_reservable_ranked_slot(
		battle_state,
		participant,
		ranked,
		participant.combat_wounded_abandoned_slot_id
	)
	if cover_slot == null and hostile == null:
		cover_slot = _nearest_reachable_cover_any(battle_state, participant)
	if cover_slot == null:
		_release_owned_reservation(battle_state, participant)
		if _wounded_threat_override_without_cover(battle_state, participant):
			return WOUNDED_THREAT_OVERRIDE
		return WOUNDED_FALLBACK
	var cover_distance_sq: float = participant.battle_position.distance_squared_to(cover_slot.position)
	if not is_finite(cover_distance_sq):
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	var hostile_distance_sq: float = _nearest_hostile_distance_sq(battle_state, participant)
	if (
		is_finite(hostile_distance_sq)
		and hostile_distance_sq < cover_distance_sq
		and _has_los_to_nearest_hostile(battle_state, participant)
	):
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_THREAT_OVERRIDE
	return _commit_wounded_cover_slot(battle_state, participant, cover_slot, hostile, search_counts)


static func _commit_wounded_cover_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	cover_slot: BattleCoverSlot,
	hostile: BattleParticipant,
	search_counts: Dictionary
) -> String:
	if cover_slot == null:
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	if not _ensure_cover_reservation(battle_state, participant, cover_slot):
		_release_owned_reservation(battle_state, participant)
		return WOUNDED_FALLBACK
	if participant.battle_position.distance_to(cover_slot.position) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		var occupy: BattleCoverResult = BattleCoverService.occupy_slot(
			battle_state,
			participant.participant_id,
			cover_slot.cover_slot_id
		)
		if occupy != null and occupy.success:
			_clear_owned_combat_navigation(participant)
			if participant.occupied_cover_slot_id != participant.combat_wounded_abandoned_slot_id:
				participant.combat_wounded_abandoned_slot_id = ""
			participant.combat_wounded_stall_seconds = 0.0
			return WOUNDED_HOLD_COVER
	if _navigate_to_cover(
		battle_state,
		participant,
		cover_slot,
		MOVE_SEEK_COVER,
		_combat_context_id(hostile),
		search_counts
	):
		return WOUNDED_SEEK_COVER
	_release_owned_reservation(battle_state, participant)
	return WOUNDED_FALLBACK


static func _update_healthy_role_cover_behavior(
	battle_state: BattleState,
	participant: BattleParticipant,
	search_counts: Dictionary,
	delta_seconds: float
) -> String:
	_reconcile_cover_state(battle_state, participant)
	if _has_external_navigation(participant):
		_clear_no_role_cover_decision(participant)
		_release_owned_reservation(battle_state, participant)
		return HEALTHY_NONE
	var weapon_type_id: String = _participant_weapon_type_id(participant)
	if BattleCombatBehaviorCatalog.uses_short_range_closing(weapon_type_id):
		if _short_range_closing_applies(battle_state, participant, weapon_type_id):
			return _update_short_range_closing_behavior(
				battle_state,
				participant,
				weapon_type_id,
				search_counts,
				delta_seconds
			)
		_clear_closing_pursuit(battle_state, participant)
	if not BattleCombatBehaviorCatalog.uses_healthy_role_cover(weapon_type_id):
		_clear_no_role_cover_decision(participant)
		if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
			_release_owned_reservation(battle_state, participant)
			_clear_owned_combat_navigation(participant)
		return HEALTHY_NONE
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if _has_valid_occupancy(battle_state, participant):
		if _healthy_occupied_cover_is_suitable(battle_state, participant, target, weapon_type_id):
			_clear_no_role_cover_decision(participant)
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
	if _healthy_keep_current_cover_decision(battle_state, participant, target, weapon_type_id):
		_clear_no_role_cover_decision(participant)
		return _pursue_healthy_role_cover(
			battle_state,
			participant,
			_reserved_cover_slot(battle_state, participant),
			search_counts
		)
	if _healthy_keep_no_role_cover_decision(battle_state, participant, target, weapon_type_id):
		return HEALTHY_NONE
	if _is_immediately_fire_eligible(battle_state, participant, target):
		if not _has_valid_reservation(battle_state, participant):
			_release_owned_reservation(battle_state, participant)
			if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
				_clear_owned_combat_navigation(participant)
			return HEALTHY_NONE
		_increment_search(search_counts, "healthy")
		var reserved_slot: BattleCoverSlot = _best_healthy_role_cover_slot(
			battle_state,
			participant,
			target,
			weapon_type_id
		)
		if (
			reserved_slot != null
			and participant.reserved_cover_slot_id == reserved_slot.cover_slot_id
		):
			_clear_no_role_cover_decision(participant)
			return _pursue_healthy_role_cover(battle_state, participant, reserved_slot, search_counts)
		_release_owned_reservation(battle_state, participant)
		if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
			_clear_owned_combat_navigation(participant)
		return HEALTHY_NONE
	_increment_search(search_counts, "healthy")
	var selected_slot: BattleCoverSlot = _best_healthy_role_cover_slot(
		battle_state,
		participant,
		target,
		weapon_type_id
	)
	if selected_slot == null:
		_release_owned_reservation(battle_state, participant)
		if participant.combat_move_mode == MOVE_SEEK_ROLE_COVER:
			_clear_owned_combat_navigation(participant)
		_bind_no_role_cover_decision(battle_state, participant, target, weapon_type_id)
		return HEALTHY_NONE
	_clear_no_role_cover_decision(participant)
	if not _ensure_cover_reservation(battle_state, participant, selected_slot):
		_release_owned_reservation(battle_state, participant)
		return HEALTHY_NONE
	return _pursue_healthy_role_cover(battle_state, participant, selected_slot, search_counts)


static func _short_range_closing_applies(
	battle_state: BattleState,
	participant: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or participant.is_wounded:
		return false
	if not _closing_command_permits(battle_state, participant):
		return false
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if target == null:
		return false
	return _is_too_far_for_preferred_band(participant, target, weapon_type_id)


static func _closing_command_permits(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	var command_id: String = _participant_force_command_id(battle_state, participant)
	if command_id == BattleForceCommandCatalog.COMMAND_HOLD:
		return false
	if command_id == BattleForceCommandCatalog.COMMAND_FALL_BACK:
		return false
	return true


static func _is_too_far_for_preferred_band(
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or target == null:
		return false
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if profile == null:
		return false
	var range_distance: float = participant.battle_position.distance_to(target.battle_position)
	if not is_finite(range_distance):
		return false
	return (
		range_distance > profile.preferred_max_distance
		and not is_equal_approx(range_distance, profile.preferred_max_distance)
	)


static func _closing_should_commit(
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or target == null:
		return false
	var commit_range: float = BattleCombatBehaviorCatalog.closing_commit_range(weapon_type_id)
	if not is_finite(commit_range) or commit_range <= 0.0:
		return false
	var range_distance: float = participant.battle_position.distance_to(target.battle_position)
	if not is_finite(range_distance):
		return false
	return range_distance < commit_range or is_equal_approx(range_distance, commit_range)


static func _update_short_range_closing_behavior(
	battle_state: BattleState,
	participant: BattleParticipant,
	weapon_type_id: String,
	search_counts: Dictionary,
	delta_seconds: float
) -> String:
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if target == null:
		_clear_closing_pursuit(battle_state, participant)
		_clear_no_role_cover_decision(participant)
		return HEALTHY_NONE
	if _has_valid_occupancy(battle_state, participant):
		if _closing_should_commit(participant, target, weapon_type_id):
			_vacate_owned_cover(battle_state, participant)
			_clear_no_role_cover_decision(participant)
			return HEALTHY_NONE
		var arrived_as_closer: bool = (
			participant.combat_closing_hold_slot_id == participant.occupied_cover_slot_id
		)
		_begin_closing_occupancy_if_needed(participant)
		if is_finite(delta_seconds) and delta_seconds > 0.0:
			participant.combat_closing_settle_seconds += delta_seconds
		if not _closing_occupied_slot_is_protective(battle_state, participant, target):
			return _continue_closing_from_occupied(
				battle_state,
				participant,
				target,
				weapon_type_id,
				search_counts
			)
		var can_fire: bool = _can_take_worthwhile_closing_shot(battle_state, participant, target)
		if arrived_as_closer:
			if _closing_posture_cycle_in_progress(participant):
				participant.combat_closing_peek_served = true
				_clear_no_role_cover_decision(participant)
				_clear_owned_combat_navigation(participant)
				return HEALTHY_HOLD_COVER
			if (
				participant.combat_closing_settle_seconds
				< BattleCombatBehaviorCatalog.CLOSING_COVER_MIN_SETTLE_SECONDS
			):
				_clear_no_role_cover_decision(participant)
				_clear_owned_combat_navigation(participant)
				return HEALTHY_HOLD_COVER
			if can_fire and not participant.combat_closing_peek_served:
				_clear_no_role_cover_decision(participant)
				_clear_owned_combat_navigation(participant)
				return HEALTHY_HOLD_COVER
		elif can_fire and not participant.combat_closing_peek_served:
			if _closing_posture_cycle_in_progress(participant):
				participant.combat_closing_peek_served = true
			_clear_no_role_cover_decision(participant)
			_clear_owned_combat_navigation(participant)
			return HEALTHY_HOLD_COVER
		if _is_too_far_for_preferred_band(participant, target, weapon_type_id):
			return _continue_closing_from_occupied(
				battle_state,
				participant,
				target,
				weapon_type_id,
				search_counts
			)
		_clear_no_role_cover_decision(participant)
		_clear_owned_combat_navigation(participant)
		return HEALTHY_HOLD_COVER
	if _has_valid_reservation(battle_state, participant):
		var reserved_slot: BattleCoverSlot = _reserved_cover_slot(battle_state, participant)
		if (
			reserved_slot != null
			and participant.battle_position.distance_to(reserved_slot.position)
			<= BattleCoverService.COVER_OCCUPANCY_EPSILON
		):
			_clear_no_role_cover_decision(participant)
			return _pursue_closing_cover(battle_state, participant, reserved_slot, search_counts)
	if _healthy_keep_closing_cover_decision(battle_state, participant, target, weapon_type_id):
		_clear_no_role_cover_decision(participant)
		return _pursue_closing_cover(
			battle_state,
			participant,
			_reserved_cover_slot(battle_state, participant),
			search_counts
		)
	if _healthy_keep_no_role_cover_decision(battle_state, participant, target, weapon_type_id):
		return HEALTHY_NONE
	if _closing_should_commit(participant, target, weapon_type_id):
		_clear_closing_pursuit(battle_state, participant)
		_clear_no_role_cover_decision(participant)
		return HEALTHY_NONE
	_increment_search(search_counts, "healthy")
	var selected_slot: BattleCoverSlot = _best_closing_cover_slot(
		battle_state,
		participant,
		target,
		weapon_type_id
	)
	if selected_slot == null:
		_release_owned_reservation(battle_state, participant)
		if participant.combat_move_mode == MOVE_CLOSE:
			_clear_owned_combat_navigation(participant)
		_bind_no_role_cover_decision(battle_state, participant, target, weapon_type_id)
		return HEALTHY_NONE
	_clear_no_role_cover_decision(participant)
	if not _ensure_cover_reservation(battle_state, participant, selected_slot):
		_release_owned_reservation(battle_state, participant)
		_bind_no_role_cover_decision(battle_state, participant, target, weapon_type_id)
		return HEALTHY_NONE
	return _pursue_closing_cover(battle_state, participant, selected_slot, search_counts)


static func _continue_closing_from_occupied(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String,
	search_counts: Dictionary
) -> String:
	_increment_search(search_counts, "healthy")
	var next_slot: BattleCoverSlot = _best_closing_cover_slot(
		battle_state,
		participant,
		target,
		weapon_type_id
	)
	_vacate_owned_cover(battle_state, participant)
	if next_slot == null:
		_bind_no_role_cover_decision(battle_state, participant, target, weapon_type_id)
		return HEALTHY_NONE
	_clear_no_role_cover_decision(participant)
	if not _ensure_cover_reservation(battle_state, participant, next_slot):
		_release_owned_reservation(battle_state, participant)
		_bind_no_role_cover_decision(battle_state, participant, target, weapon_type_id)
		return HEALTHY_NONE
	return _pursue_closing_cover(battle_state, participant, next_slot, search_counts)


static func _pursue_closing_cover(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	search_counts: Dictionary
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
			participant.combat_closing_hold_slot_id = slot.cover_slot_id
			participant.combat_closing_settle_seconds = 0.0
			participant.combat_closing_peek_served = false
			return HEALTHY_HOLD_COVER
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if _navigate_to_cover(
		battle_state,
		participant,
		slot,
		MOVE_CLOSE,
		_combat_context_id(target),
		search_counts
	):
		return HEALTHY_SEEK_COVER
	_release_owned_reservation(battle_state, participant)
	return HEALTHY_NONE


static func _best_closing_cover_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> BattleCoverSlot:
	var seek_radius: float = BattleCombatBehaviorCatalog.closing_cover_seek_radius(weapon_type_id)
	if not is_finite(seek_radius) or seek_radius <= 0.0:
		return null
	var ranked: Array[BattleCombatCoverEvaluation] = BattleCombatCoverEvaluationService.rank_closing_cover(
		battle_state,
		participant,
		target,
		weapon_type_id,
		seek_radius
	)
	return _first_reservable_ranked_slot(battle_state, participant, ranked)


static func _healthy_keep_closing_cover_decision(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or target == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != MOVE_CLOSE:
		return false
	var slot: BattleCoverSlot = _reserved_cover_slot(battle_state, participant)
	if slot == null:
		return false
	if participant.combat_move_target_id != slot.cover_slot_id:
		return false
	if not _should_keep_cover_path(participant, slot, MOVE_CLOSE):
		return false
	if not _combat_decision_matches(battle_state, participant, target.participant_id):
		return false
	if not _cheap_closing_slot_still_valid(battle_state, participant, slot, target, weapon_type_id):
		return false
	_bind_combat_decision(battle_state, participant, target.participant_id)
	return true


static func _cheap_closing_slot_still_valid(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	hostile: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if slot == null or not slot.is_valid() or participant == null or hostile == null:
		return false
	if not _is_valid_navigation_destination(battle_state, slot.position):
		return false
	var evaluation: BattleCombatCoverEvaluation = BattleCombatCoverEvaluationService.evaluate_slot(
		battle_state,
		participant,
		slot,
		hostile,
		false,
		false,
		INF
	)
	if evaluation == null or not evaluation.legal:
		return false
	if not evaluation.has_useful_direction:
		return false
	var slot_range: float = slot.position.distance_to(hostile.battle_position)
	if not is_finite(slot_range):
		return false
	var profile: BattleCombatBehaviorProfile = BattleCombatBehaviorCatalog.get_profile(weapon_type_id)
	if (
		profile != null
		and profile.preferred_min_distance > 0.0
		and slot_range < profile.preferred_min_distance
		and not is_equal_approx(slot_range, profile.preferred_min_distance)
	):
		return false
	return true


static func _closing_posture_cycle_in_progress(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	match participant.cover_posture_phase:
		BattleCoverPostureService.PHASE_EXPOSING, BattleCoverPostureService.PHASE_HOLDING, BattleCoverPostureService.PHASE_TUCKING:
			return true
		_:
			return false


static func _begin_closing_occupancy_if_needed(participant: BattleParticipant) -> void:
	if participant == null:
		return
	if participant.combat_closing_hold_slot_id == participant.occupied_cover_slot_id:
		return
	participant.combat_closing_hold_slot_id = participant.occupied_cover_slot_id
	participant.combat_closing_settle_seconds = 0.0
	participant.combat_closing_peek_served = false


static func _closing_occupied_slot_is_protective(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if participant.occupied_cover_slot_id.is_empty():
		return false
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
		participant.occupied_cover_slot_id
	)
	if slot == null:
		return false
	var evaluation: BattleCombatCoverEvaluation = BattleCombatCoverEvaluationService.evaluate_slot(
		battle_state,
		participant,
		slot,
		target,
		false,
		false,
		INF
	)
	if evaluation == null or not evaluation.legal:
		return false
	return evaluation.has_useful_direction


static func _vacate_owned_cover(battle_state: BattleState, participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.combat_closing_hold_slot_id = ""
	participant.combat_closing_settle_seconds = 0.0
	participant.combat_closing_peek_served = false
	BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
	_reconcile_cover_state(battle_state, participant)
	_clear_owned_combat_navigation(participant)


static func _clear_closing_pursuit(battle_state: BattleState, participant: BattleParticipant) -> void:
	if participant == null:
		return
	if participant.combat_move_mode != MOVE_CLOSE:
		return
	if not _has_valid_occupancy(battle_state, participant):
		_release_owned_reservation(battle_state, participant)
	_clear_owned_combat_navigation(participant)


static func _can_take_worthwhile_closing_shot(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or target == null:
		return false
	var weapon_type_id: String = _participant_weapon_type_id(participant)
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null or not definition.is_valid():
		return false
	var range_distance: float = participant.battle_position.distance_to(target.battle_position)
	if not is_finite(range_distance):
		return false
	if range_distance > definition.max_range and not is_equal_approx(range_distance, definition.max_range):
		return false
	return BattleFireControlService.would_fire_if_source_cover_exposed(
		battle_state,
		participant.participant_id,
		target.participant_id
	)


static func _should_withhold_out_of_band_shot(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or target == null or participant.is_wounded:
		return false
	var weapon_type_id: String = _participant_weapon_type_id(participant)
	if weapon_type_id != BattleWeaponCatalog.WEAPON_SHOTGUN:
		return false
	if not _closing_command_permits(battle_state, participant):
		return false
	return _is_too_far_for_preferred_band(participant, target, weapon_type_id)


static func _should_continue_closing_after_shot(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null or participant.is_wounded:
		return false
	var weapon_type_id: String = _participant_weapon_type_id(participant)
	if not BattleCombatBehaviorCatalog.uses_short_range_closing(weapon_type_id):
		return false
	if not _short_range_closing_applies(battle_state, participant, weapon_type_id):
		return false
	return true


static func _pursue_healthy_role_cover(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	search_counts: Dictionary
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
	var target: BattleParticipant = _healthy_current_target(battle_state, participant)
	if _navigate_to_cover(
		battle_state,
		participant,
		slot,
		MOVE_SEEK_ROLE_COVER,
		_combat_context_id(target),
		search_counts
	):
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
	if not BattleCombatCoverEvaluationService.occupied_cover_is_suitable(
		battle_state,
		participant,
		target,
		_push_applies(battle_state, participant)
	):
		return false
	if weapon_type_id == BattleWeaponCatalog.WEAPON_PISTOL:
		return true
	return _healthy_slot_is_role_suitable(
		battle_state.battlefield_geometry.get_cover_slot(participant.occupied_cover_slot_id),
		target,
		weapon_type_id
	)


static func _best_healthy_role_cover_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> BattleCoverSlot:
	var seek_radius: float = BattleCombatBehaviorCatalog.healthy_cover_seek_radius(weapon_type_id)
	if not is_finite(seek_radius) or seek_radius <= 0.0:
		return null
	var ranked: Array[BattleCombatCoverEvaluation] = BattleCombatCoverEvaluationService.rank_healthy_role(
		battle_state,
		participant,
		target,
		weapon_type_id,
		_push_applies(battle_state, participant),
		seek_radius
	)
	return _first_reservable_ranked_slot(battle_state, participant, ranked)


static func _wounded_occupied_cover_is_suitable(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	return BattleCombatCoverEvaluationService.occupied_cover_is_suitable(
		battle_state,
		participant,
		_active_hostile(battle_state, participant),
		false
	)


static func _living_count_on_side(battle_state: BattleState, side_id: String) -> int:
	if battle_state == null or side_id.is_empty():
		return 0
	var living: int = 0
	for participant_id: String in battle_state.participants:
		var candidate: BattleParticipant = battle_state.get_participant(participant_id)
		if candidate == null or not candidate.is_alive:
			continue
		if candidate.side_id != side_id:
			continue
		living += 1
	return living


static func _wounded_would_fire_if_exposed(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null:
		return false
	var hostile: BattleParticipant = _active_hostile(battle_state, participant)
	if hostile == null:
		return false
	return BattleFireControlService.would_fire_if_source_cover_exposed(
		battle_state,
		participant.participant_id,
		hostile.participant_id
	)


static func _wounded_should_break_stalemate(
	battle_state: BattleState,
	participant: BattleParticipant,
	delta_seconds: float
) -> bool:
	if participant == null:
		return false
	if (
		_participant_force_command_id(battle_state, participant)
		== BattleForceCommandCatalog.COMMAND_FALL_BACK
	):
		participant.combat_wounded_stall_seconds = 0.0
		return false
	if _living_count_on_side(battle_state, participant.side_id) != 1:
		participant.combat_wounded_stall_seconds = 0.0
		return false
	if _wounded_would_fire_if_exposed(battle_state, participant):
		participant.combat_wounded_stall_seconds = 0.0
		return false
	if is_finite(delta_seconds) and delta_seconds > 0.0:
		participant.combat_wounded_stall_seconds += delta_seconds
	var threshold: float = BattleCombatBehaviorCatalog.WOUNDED_STALEMATE_SECONDS
	return (
		participant.combat_wounded_stall_seconds > threshold
		or is_equal_approx(participant.combat_wounded_stall_seconds, threshold)
	)


static func _wounded_break_stalemate(
	battle_state: BattleState,
	participant: BattleParticipant,
	search_counts: Dictionary
) -> String:
	if participant == null:
		return WOUNDED_FALLBACK
	var abandoned_id: String = participant.occupied_cover_slot_id
	_vacate_owned_cover(battle_state, participant)
	participant.combat_wounded_abandoned_slot_id = abandoned_id
	participant.combat_wounded_stall_seconds = 0.0
	if _wounded_would_fire_if_exposed(battle_state, participant):
		return WOUNDED_FALLBACK
	var hostile: BattleParticipant = _active_hostile(battle_state, participant)
	if hostile == null or not _is_positioned(hostile):
		return WOUNDED_FALLBACK
	var destination: Vector2 = _wounded_reenter_destination(battle_state, participant, hostile)
	if not _is_finite_vector(destination):
		return WOUNDED_FALLBACK
	if destination.is_equal_approx(participant.battle_position):
		return WOUNDED_FALLBACK
	if _navigate_to_combat_destination(
		battle_state,
		participant,
		destination,
		MOVE_WOUNDED_REENTER,
		hostile.participant_id,
		search_counts
	):
		return WOUNDED_SEEK_COVER
	return WOUNDED_FALLBACK


static func _wounded_reenter_destination(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant
) -> Vector2:
	if participant == null or hostile == null:
		return Vector2.ZERO
	var weapon_type_id: String = _participant_weapon_type_id(participant)
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null or not definition.is_valid():
		return participant.battle_position
	var current_range: float = participant.battle_position.distance_to(hostile.battle_position)
	if not is_finite(current_range):
		return participant.battle_position
	if current_range < definition.max_range or is_equal_approx(current_range, definition.max_range):
		return participant.battle_position
	return _preferred_band_stand_off(
		battle_state,
		participant,
		hostile,
		0.0,
		definition.max_range
	)


static func _wounded_keep_reenter_decision(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null:
		return false
	if participant.combat_move_mode != MOVE_WOUNDED_REENTER:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	var hostile: BattleParticipant = _active_hostile(battle_state, participant)
	if hostile == null:
		_clear_owned_combat_navigation(participant)
		return false
	if not _combat_decision_matches(battle_state, participant, hostile.participant_id):
		_clear_owned_combat_navigation(participant)
		return false
	if (
		participant.battle_position.distance_to(participant.navigation_destination)
		<= BattleCoverService.COVER_OCCUPANCY_EPSILON
	):
		_clear_owned_combat_navigation(participant)
		return false
	if _wounded_would_fire_if_exposed(battle_state, participant):
		_clear_owned_combat_navigation(participant)
		return false
	var expected: Vector2 = _wounded_reenter_destination(battle_state, participant, hostile)
	if not _is_finite_vector(expected):
		_clear_owned_combat_navigation(participant)
		return false
	var drift: float = participant.navigation_destination.distance_to(expected)
	if not is_finite(drift) or drift > BattleCombatBehaviorCatalog.REPLAN_DISTANCE_EPSILON:
		_clear_owned_combat_navigation(participant)
		return false
	_bind_combat_decision(battle_state, participant, hostile.participant_id)
	_ensure_combat_movement_speed(participant)
	return true


static func _navigate_to_combat_destination(
	battle_state: BattleState,
	participant: BattleParticipant,
	destination: Vector2,
	move_mode: String,
	context_id: String,
	search_counts: Dictionary
) -> bool:
	if participant == null:
		return false
	if _has_external_navigation(participant):
		return false
	if destination.is_equal_approx(participant.battle_position):
		return false
	if not _is_valid_navigation_destination(battle_state, destination):
		return false
	var navigation: BattleNavigationResult = _find_combat_navigation_path(
		battle_state,
		participant.battle_position,
		destination,
		search_counts
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
	participant.combat_move_target_id = context_id
	_bind_combat_decision(battle_state, participant, context_id)
	_ensure_combat_movement_speed(participant)
	return true


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


static func _increment_search(search_counts: Dictionary, key: String) -> void:
	if search_counts == null or key.is_empty():
		return
	search_counts[key] = int(search_counts.get(key, 0)) + 1


static func _combat_context_id(context: BattleParticipant) -> String:
	if context == null:
		return ""
	return context.participant_id


static func _combat_decision_key_for(
	battle_state: BattleState,
	participant: BattleParticipant,
	context_id: String
) -> String:
	return "%s|%s" % [context_id, _participant_force_command_id(battle_state, participant)]


static func _bind_combat_decision(
	battle_state: BattleState,
	participant: BattleParticipant,
	context_id: String
) -> void:
	if participant == null:
		return
	participant.combat_decision_key = _combat_decision_key_for(battle_state, participant, context_id)


static func _cover_availability_stamp(battle_state: BattleState) -> String:
	var occupancy_revision: int = 0
	var slot_revision: int = 0
	if battle_state != null:
		occupancy_revision = battle_state.cover_occupancy_revision
		if battle_state.battlefield_geometry != null:
			slot_revision = battle_state.battlefield_geometry.cover_slot_revision
	return "%s|%s" % [occupancy_revision, slot_revision]


static func _healthy_no_role_cover_key(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> String:
	if participant == null or target == null:
		return ""
	var wounded_flag: int = 1 if participant.is_wounded else 0
	var topology: String = ""
	if battle_state != null:
		topology = battle_state.navigation_topology_stamp()
	var has_los: int = 0
	if battle_state != null:
		var los: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
			battle_state,
			participant.participant_id,
			target.participant_id
		)
		if los != null and los.success and los.has_line_of_sight:
			has_los = 1
	var range_distance: float = participant.battle_position.distance_to(target.battle_position)
	var in_max_range: int = 0
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition != null and is_finite(range_distance) and range_distance <= definition.max_range:
		in_max_range = 1
	var in_band: int = 0
	var band_error: float = BattleCombatBehaviorCatalog.preferred_band_error(weapon_type_id, range_distance)
	if is_finite(band_error) and is_equal_approx(band_error, 0.0):
		in_band = 1
	return "%s|%s|%s|%s|%s|%s|%s|%s" % [
		target.participant_id,
		_participant_force_command_id(battle_state, participant),
		wounded_flag,
		_cover_availability_stamp(battle_state),
		topology,
		has_los,
		in_max_range,
		in_band,
	]


static func _bind_no_role_cover_decision(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> void:
	if participant == null or target == null:
		return
	participant.combat_no_role_cover = true
	participant.combat_no_role_cover_key = _healthy_no_role_cover_key(
		battle_state,
		participant,
		target,
		weapon_type_id
	)
	participant.combat_no_role_cover_self_position = participant.battle_position
	participant.combat_no_role_cover_target_position = target.battle_position


static func _clear_no_role_cover_decision(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.combat_no_role_cover = false
	participant.combat_no_role_cover_key = ""
	participant.combat_no_role_cover_self_position = Vector2.ZERO
	participant.combat_no_role_cover_target_position = Vector2.ZERO


static func _healthy_keep_no_role_cover_decision(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or target == null:
		return false
	if not participant.combat_no_role_cover:
		return false
	if participant.combat_no_role_cover_key.is_empty():
		return false
	if participant.combat_no_role_cover_key != _healthy_no_role_cover_key(
		battle_state,
		participant,
		target,
		weapon_type_id
	):
		return false
	var self_drift: float = participant.battle_position.distance_to(
		participant.combat_no_role_cover_self_position
	)
	if not is_finite(self_drift) or self_drift > BattleCombatBehaviorCatalog.REPLAN_DISTANCE_EPSILON:
		return false
	var target_drift: float = target.battle_position.distance_to(
		participant.combat_no_role_cover_target_position
	)
	if not is_finite(target_drift) or target_drift > BattleCombatBehaviorCatalog.REPLAN_DISTANCE_EPSILON:
		return false
	return true


static func _combat_decision_matches(
	battle_state: BattleState,
	participant: BattleParticipant,
	context_id: String
) -> bool:
	if participant == null:
		return false
	if participant.combat_decision_key.is_empty():
		return true
	return participant.combat_decision_key == _combat_decision_key_for(
		battle_state,
		participant,
		context_id
	)


static func _reserved_cover_slot(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleCoverSlot:
	if not _has_valid_reservation(battle_state, participant):
		return null
	return battle_state.battlefield_geometry.get_cover_slot(participant.reserved_cover_slot_id)


static func _cheap_cover_decision_still_valid(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	hostile: BattleParticipant,
	require_weapon_range: bool,
	weapon_type_id: String,
	require_role: bool,
	max_move_distance: float = INF
) -> bool:
	if slot == null or not slot.is_valid():
		return false
	if not _is_valid_navigation_destination(battle_state, slot.position):
		return false
	if hostile == null:
		return true
	var evaluation: BattleCombatCoverEvaluation = BattleCombatCoverEvaluationService.evaluate_slot(
		battle_state,
		participant,
		slot,
		hostile,
		false,
		require_weapon_range,
		max_move_distance
	)
	if evaluation == null or not evaluation.combat_usable:
		return false
	if require_role and weapon_type_id != BattleWeaponCatalog.WEAPON_PISTOL:
		if not _healthy_slot_is_role_suitable(slot, hostile, weapon_type_id):
			return false
	return true


static func _healthy_keep_current_cover_decision(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if participant == null or target == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != MOVE_SEEK_ROLE_COVER:
		return false
	var slot: BattleCoverSlot = _reserved_cover_slot(battle_state, participant)
	if slot == null:
		return false
	if participant.combat_move_target_id != slot.cover_slot_id:
		return false
	if not _should_keep_cover_path(participant, slot, MOVE_SEEK_ROLE_COVER):
		return false
	if not _combat_decision_matches(battle_state, participant, target.participant_id):
		return false
	if not _cheap_cover_decision_still_valid(
		battle_state,
		participant,
		slot,
		target,
		_push_applies(battle_state, participant),
		weapon_type_id,
		true
	):
		return false
	_bind_combat_decision(battle_state, participant, target.participant_id)
	return true


static func _wounded_keep_current_cover_decision(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant
) -> bool:
	if participant == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != MOVE_SEEK_COVER:
		return false
	var slot: BattleCoverSlot = _reserved_cover_slot(battle_state, participant)
	if slot == null:
		return false
	if slot.cover_slot_id == participant.combat_wounded_abandoned_slot_id:
		return false
	if participant.combat_move_target_id != slot.cover_slot_id:
		return false
	if not _should_keep_cover_path(participant, slot, MOVE_SEEK_COVER):
		return false
	if not _combat_decision_matches(battle_state, participant, _combat_context_id(hostile)):
		return false
	var cover_distance_sq: float = participant.battle_position.distance_squared_to(slot.position)
	var hostile_distance_sq: float = _nearest_hostile_distance_sq(battle_state, participant)
	if (
		is_finite(cover_distance_sq)
		and is_finite(hostile_distance_sq)
		and hostile_distance_sq < cover_distance_sq
		and _has_los_to_nearest_hostile(battle_state, participant)
	):
		return false
	if not _cheap_cover_decision_still_valid(
		battle_state,
		participant,
		slot,
		hostile,
		false,
		"",
		false,
		BattleCombatBehaviorCatalog.WOUNDED_COVER_SEEK_RADIUS
	):
		return false
	_bind_combat_decision(battle_state, participant, _combat_context_id(hostile))
	return true


static func _find_combat_navigation_path(
	battle_state: BattleState,
	from_position: Vector2,
	destination: Vector2,
	search_counts: Dictionary
) -> BattleNavigationResult:
	_increment_search(search_counts, "nav")
	return BattleNavigationService.find_path(battle_state, from_position, destination)


static func _first_reservable_ranked_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	ranked: Array[BattleCombatCoverEvaluation],
	exclude_slot_id: String = ""
) -> BattleCoverSlot:
	if battle_state == null or participant == null or battle_state.battlefield_geometry == null:
		return null
	if exclude_slot_id.is_empty():
		return BattleCombatCoverEvaluationService.first_reachable_ranked_slot(
			battle_state,
			participant,
			ranked,
			true
		)
	var filtered: Array[BattleCombatCoverEvaluation] = []
	for evaluation: BattleCombatCoverEvaluation in ranked:
		if evaluation == null or evaluation.slot_id == exclude_slot_id:
			continue
		filtered.append(evaluation)
	return BattleCombatCoverEvaluationService.first_reachable_ranked_slot(
		battle_state,
		participant,
		filtered,
		true
	)


static func _active_hostile(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleParticipant:
	if battle_state == null or participant == null:
		return null
	var best: BattleParticipant = null
	var best_distance: float = INF
	for participant_id: String in _sorted_participant_ids(battle_state):
		var candidate: BattleParticipant = battle_state.get_participant(participant_id)
		if not _is_eligible_threat(battle_state, participant, candidate):
			continue
		var distance: float = participant.battle_position.distance_squared_to(candidate.battle_position)
		if not is_finite(distance):
			continue
		if best == null or distance < best_distance:
			best = candidate
			best_distance = distance
	return best


static func _has_los_to_nearest_hostile(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	var hostile: BattleParticipant = _active_hostile(battle_state, participant)
	if hostile == null:
		return false
	var los: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
		battle_state,
		participant.participant_id,
		hostile.participant_id
	)
	return los != null and los.success and los.has_line_of_sight


static func _wounded_threat_override_without_cover(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if not _has_los_to_nearest_hostile(battle_state, participant):
		return false
	var hostile_distance_sq: float = _nearest_hostile_distance_sq(battle_state, participant)
	if not is_finite(hostile_distance_sq):
		return false
	var nearest_cover: BattleCoverSlot = _nearest_reachable_cover_any(battle_state, participant)
	if nearest_cover == null:
		return false
	var cover_distance_sq: float = participant.battle_position.distance_squared_to(nearest_cover.position)
	return is_finite(cover_distance_sq) and hostile_distance_sq < cover_distance_sq


static func _nearest_reachable_cover_any(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleCoverSlot:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return null
	var candidates: Array[Dictionary] = []
	for slot_id: String in battle_state.battlefield_geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot == null or not slot.is_valid():
			continue
		if slot.occupied_by_participant_id != "" and slot.occupied_by_participant_id != participant.participant_id:
			continue
		if slot.reserved_by_participant_id != "" and slot.reserved_by_participant_id != participant.participant_id:
			continue
		if slot.occupied_by_participant_id == participant.participant_id:
			continue
		if slot.cover_slot_id == participant.combat_wounded_abandoned_slot_id:
			continue
		var distance: float = participant.battle_position.distance_to(slot.position)
		if not is_finite(distance):
			continue
		if (
			distance > BattleCombatBehaviorCatalog.WOUNDED_COVER_SEEK_RADIUS
			and not is_equal_approx(distance, BattleCombatBehaviorCatalog.WOUNDED_COVER_SEEK_RADIUS)
		):
			continue
		candidates.append({
			"slot": slot,
			"distance": distance,
			"slot_id": slot_id,
		})
	candidates.sort_custom(_nearest_cover_sort)
	for candidate: Dictionary in candidates:
		var slot: BattleCoverSlot = candidate["slot"]
		if BattleNavigationService.is_reachable(battle_state, participant.battle_position, slot.position):
			return slot
	return null


static func _nearest_cover_sort(left: Dictionary, right: Dictionary) -> bool:
	var left_distance: float = float(left.get("distance", INF))
	var right_distance: float = float(right.get("distance", INF))
	if not is_equal_approx(left_distance, right_distance):
		return left_distance < right_distance
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
			BattleCoverPostureService.clear(participant)
	if not participant.reserved_cover_slot_id.is_empty():
		var reserved: BattleCoverSlot = geometry.get_cover_slot(participant.reserved_cover_slot_id)
		if reserved == null or reserved.reserved_by_participant_id != participant.participant_id:
			participant.reserved_cover_slot_id = ""


static func _update_occupied_cover_posture(
	battle_state: BattleState,
	participant: BattleParticipant,
	delta_seconds: float,
	allow_begin_expose: bool
) -> void:
	BattleCoverPostureService.update_for_combat(
		battle_state,
		participant,
		delta_seconds,
		allow_begin_expose
	)


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
	move_mode: String,
	context_id: String,
	search_counts: Dictionary
) -> bool:
	if participant == null or slot == null:
		return false
	if _has_external_navigation(participant):
		return false
	if slot.position.is_equal_approx(participant.battle_position):
		return false
	if _should_keep_cover_path(participant, slot, move_mode):
		_bind_combat_decision(battle_state, participant, context_id)
		_ensure_combat_movement_speed(participant)
		return true
	if not _is_valid_navigation_destination(battle_state, slot.position):
		return false
	var navigation: BattleNavigationResult = _find_combat_navigation_path(
		battle_state,
		participant.battle_position,
		slot.position,
		search_counts
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
	_bind_combat_decision(battle_state, participant, context_id)
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
	participant: BattleParticipant,
	search_counts: Dictionary
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
	# Wounded threat-override / no-cover fallback reuse this mover, but must never
	# walk toward the hostile. Too-close still uses existing retreat. Far-side of
	# the preferred band, max-range, and LOS blocks hold instead of approaching.
	if participant.is_wounded and move_mode == MOVE_APPROACH:
		move_mode = MOVE_HOLD
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
		if participant.is_wounded:
			_halt_wounded_stand_motion(participant)
		if hold_constrained:
			return MOVEMENT_HOLD_CONSTRAINED
		return MOVEMENT_NONE
	if move_mode == MOVE_FALL_BACK:
		return _update_fall_back_movement(battle_state, participant, target, search_counts)
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
	if _should_keep_combat_path(battle_state, participant, target, move_mode, destination):
		_bind_combat_decision(battle_state, participant, target.participant_id)
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
	var navigation: BattleNavigationResult = _find_combat_navigation_path(
		battle_state,
		participant.battle_position,
		destination,
		search_counts
	)
	if navigation == null or not navigation.success:
		if (
			focus_bias_applied
			and _is_valid_navigation_destination(battle_state, unbiased_destination)
			and not unbiased_destination.is_equal_approx(participant.battle_position)
		):
			navigation = _find_combat_navigation_path(
				battle_state,
				participant.battle_position,
				unbiased_destination,
				search_counts
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
	_bind_combat_decision(battle_state, participant, target.participant_id)
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
	target: BattleParticipant,
	search_counts: Dictionary
) -> int:
	if participant == null or target == null:
		return MOVEMENT_NONE
	if _should_keep_fall_back_path(battle_state, participant, target):
		_bind_combat_decision(battle_state, participant, target.participant_id)
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
	var navigation: BattleNavigationResult = _find_combat_navigation_path(
		battle_state,
		participant.battle_position,
		destination,
		search_counts
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
	_bind_combat_decision(battle_state, participant, target.participant_id)
	_ensure_combat_movement_speed(participant)
	return MOVEMENT_FALL_BACK


static func _should_keep_fall_back_path(
	battle_state: BattleState,
	participant: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if participant == null or target == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_COMBAT:
		return false
	if not participant.has_active_navigation_path():
		return false
	if participant.combat_move_mode != MOVE_FALL_BACK:
		return false
	if not _combat_decision_matches(battle_state, participant, target.participant_id):
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
	battle_state: BattleState,
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
	if not _combat_decision_matches(battle_state, participant, target.participant_id):
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


static func _halt_wounded_stand_motion(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.clear_movement_intent()
	participant.velocity = Vector2.ZERO


static func _has_external_navigation(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if participant.navigation_source != BattleParticipant.NAVIGATION_SOURCE_EXTERNAL:
		return false
	return participant.has_active_navigation_path()


static func _clear_owned_combat_navigation(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.combat_decision_key = ""
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
