class_name BattleFireControlService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleWeaponState := preload("res://battle/combat/battle_weapon_state.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")
const BattleLineOfSightService := preload("res://battle/combat/battle_line_of_sight_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")


static func initialize_weapon_state(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	var state: BattleWeaponState = BattleWeaponCatalog.create_initial_state(participant.weapon_type)
	participant.weapon_state = state
	return state != null


static func advance_weapon_state(
	battle_state: BattleState,
	delta_seconds: float
) -> BattleFireControlResult:
	if battle_state == null:
		return BattleFireControlResult.failed(
			"null_battle_state",
			"Battle fire control failed: battle_state is null."
		)
	if battle_state.battle_phase != "active":
		return BattleFireControlResult.failed(
			"battle_not_active",
			"Battle fire control failed: battle phase is '%s', not active." % battle_state.battle_phase
		)
	if not is_finite(delta_seconds) or delta_seconds < 0.0:
		return BattleFireControlResult.failed(
			"invalid_delta",
			"Battle fire control failed: delta_seconds is invalid."
		)
	if battle_state.battlefield_geometry == null:
		return BattleFireControlResult.failed(
			"missing_battlefield_geometry",
			"Battle fire control failed: battlefield geometry is missing."
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleFireControlResult.failed(
			"invalid_battlefield_geometry",
			"Battle fire control failed: battlefield geometry is invalid."
		)
	var participant_ids: Array[String] = _sorted_participant_ids(battle_state)
	var participants_considered: int = 0
	for participant_id: String in participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		if delta_seconds > 0.0:
			_advance_participant_weapon(participant, delta_seconds)
	return BattleFireControlResult.succeeded(participants_considered)


static func evaluate_fire_eligibility(battle_state: BattleState) -> BattleFireControlResult:
	if battle_state == null:
		return BattleFireControlResult.failed(
			"null_battle_state",
			"Battle fire control failed: battle_state is null."
		)
	if battle_state.battle_phase != "active":
		return BattleFireControlResult.failed(
			"battle_not_active",
			"Battle fire control failed: battle phase is '%s', not active." % battle_state.battle_phase
		)
	if battle_state.battlefield_geometry == null:
		return BattleFireControlResult.failed(
			"missing_battlefield_geometry",
			"Battle fire control failed: battlefield geometry is missing."
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleFireControlResult.failed(
			"invalid_battlefield_geometry",
			"Battle fire control failed: battlefield geometry is invalid."
		)
	var participant_ids: Array[String] = _sorted_participant_ids(battle_state)
	var participants_considered: int = 0
	var participants_with_targets: int = 0
	var participants_eligible_to_fire: int = 0
	var participants_blocked_by_los: int = 0
	var participants_blocked_by_range: int = 0
	var participants_blocked_by_cooldown: int = 0
	var participants_reloading: int = 0
	var participants_empty: int = 0
	for participant_id: String in participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		participants_considered += 1
		if participant.has_target_participant:
			participants_with_targets += 1
		var block_reason: String = _fire_block_reason(battle_state, participant)
		match block_reason:
			"":
				participants_eligible_to_fire += 1
			"reloading":
				participants_reloading += 1
			"empty":
				participants_empty += 1
			"cooldown":
				participants_blocked_by_cooldown += 1
			"range":
				participants_blocked_by_range += 1
			"los":
				participants_blocked_by_los += 1
			_:
				pass
	return BattleFireControlResult.succeeded(
		participants_considered,
		participants_with_targets,
		participants_eligible_to_fire,
		participants_blocked_by_los,
		participants_blocked_by_range,
		participants_blocked_by_cooldown,
		participants_reloading,
		participants_empty
	)


# Explicit shot commit for a future attack-resolution layer.
# Runtime does not call this. It does not query LOS, range, or targets.
static func commit_shot(
	participant: BattleParticipant,
	definition: BattleWeaponDefinition
) -> bool:
	if participant == null or definition == null:
		return false
	if not definition.is_valid():
		return false
	var state: BattleWeaponState = participant.weapon_state
	if state == null:
		return false
	if state.weapon_type_id != definition.weapon_type_id:
		return false
	if state.is_reloading:
		return false
	if state.ammo_in_magazine <= 0:
		return false
	if not is_finite(state.cooldown_remaining_seconds) or state.cooldown_remaining_seconds > 0.0:
		return false
	var cooldown_seconds: float = definition.cooldown_seconds()
	if not is_finite(cooldown_seconds) or cooldown_seconds < 0.0:
		return false
	state.ammo_in_magazine -= 1
	state.cooldown_remaining_seconds = cooldown_seconds
	return true


static func _advance_participant_weapon(
	participant: BattleParticipant,
	delta_seconds: float
) -> void:
	var state: BattleWeaponState = participant.weapon_state
	if state == null:
		return
	if state.ammo_in_magazine < 0:
		state.ammo_in_magazine = 0
	if not is_finite(state.cooldown_remaining_seconds) or not is_finite(state.reload_remaining_seconds):
		return
	if state.cooldown_remaining_seconds < 0.0:
		state.cooldown_remaining_seconds = 0.0
	if state.reload_remaining_seconds < 0.0:
		state.reload_remaining_seconds = 0.0
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(state.weapon_type_id)
	if definition != null and state.ammo_in_magazine == 0 and not state.is_reloading:
		_start_reload(state, definition)
	if state.is_reloading:
		state.reload_remaining_seconds = maxf(state.reload_remaining_seconds - delta_seconds, 0.0)
		if state.reload_remaining_seconds == 0.0:
			state.is_reloading = false
			_refill_magazine_to_capacity(state, definition)
	state.cooldown_remaining_seconds = maxf(state.cooldown_remaining_seconds - delta_seconds, 0.0)


static func _start_reload(state: BattleWeaponState, definition: BattleWeaponDefinition) -> void:
	if state == null or definition == null:
		return
	if definition.reload_seconds == 0.0:
		_refill_magazine_to_capacity(state, definition)
		state.is_reloading = false
		state.reload_remaining_seconds = 0.0
		return
	state.is_reloading = true
	state.reload_remaining_seconds = definition.reload_seconds


# Temporary magazine-only abstraction: a completed reload refills to capacity
# because reserve ammunition is not modeled yet. Replace this helper when
# reserve ammo exists. Eligibility should keep reading ammo_in_magazine.
static func _refill_magazine_to_capacity(
	state: BattleWeaponState,
	definition: BattleWeaponDefinition
) -> void:
	if state == null or definition == null:
		return
	state.ammo_in_magazine = definition.magazine_capacity


static func _fire_block_reason(
	battle_state: BattleState,
	participant: BattleParticipant
) -> String:
	if not _is_fire_source_ready(battle_state, participant):
		return "not_ready"
	if not _has_valid_hostile_target(battle_state, participant):
		return "not_ready"
	var state: BattleWeaponState = participant.weapon_state
	if state.is_reloading:
		return "reloading"
	if state.ammo_in_magazine <= 0:
		return "empty"
	if not is_finite(state.cooldown_remaining_seconds) or state.cooldown_remaining_seconds > 0.0:
		return "cooldown"
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(state.weapon_type_id)
	if definition == null:
		return "not_ready"
	if not _is_target_in_range(participant, battle_state.get_participant(participant.target_participant_id), definition):
		return "range"
	var los_result: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
		battle_state,
		participant.participant_id,
		participant.target_participant_id
	)
	if los_result == null or not los_result.success:
		return "not_ready"
	if not los_result.has_line_of_sight:
		return "los"
	return ""


static func _is_fire_source_ready(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null:
		return false
	if not participant.is_alive:
		return false
	if not participant.has_battle_position:
		return false
	if not _is_finite_vector(participant.battle_position):
		return false
	if participant.side_id.is_empty() or not battle_state.has_side(participant.side_id):
		return false
	var state: BattleWeaponState = participant.weapon_state
	if state == null:
		return false
	if state.weapon_type_id.is_empty():
		return false
	if not participant.weapon_type.is_empty() and participant.weapon_type != state.weapon_type_id:
		return false
	if BattleWeaponCatalog.get_definition(state.weapon_type_id) == null:
		return false
	if state.ammo_in_magazine < 0:
		return false
	if not is_finite(state.cooldown_remaining_seconds) or not is_finite(state.reload_remaining_seconds):
		return false
	return true


static func _has_valid_hostile_target(
	battle_state: BattleState,
	source: BattleParticipant
) -> bool:
	if source == null:
		return false
	if not source.has_target_participant or source.target_participant_id.is_empty():
		return false
	if not battle_state.has_participant(source.target_participant_id):
		return false
	var target: BattleParticipant = battle_state.get_participant(source.target_participant_id)
	if target == null:
		return false
	if target.participant_id == source.participant_id:
		return false
	if not target.is_alive:
		return false
	if not target.has_battle_position:
		return false
	if not _is_finite_vector(target.battle_position):
		return false
	if source.side_id.is_empty() or target.side_id.is_empty():
		return false
	if not battle_state.has_side(source.side_id) or not battle_state.has_side(target.side_id):
		return false
	return source.side_id != target.side_id


static func _is_target_in_range(
	source: BattleParticipant,
	target: BattleParticipant,
	definition: BattleWeaponDefinition
) -> bool:
	if source == null or target == null or definition == null:
		return false
	var max_range_squared: float = definition.max_range * definition.max_range
	if not is_finite(max_range_squared):
		return false
	var distance_squared: float = source.battle_position.distance_squared_to(target.battle_position)
	if not is_finite(distance_squared):
		return false
	return distance_squared <= max_range_squared


static func _sorted_participant_ids(battle_state: BattleState) -> Array[String]:
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	return ids


static func _is_finite_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)
