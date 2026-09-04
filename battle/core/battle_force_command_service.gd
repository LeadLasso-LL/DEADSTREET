class_name BattleForceCommandService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleTacticalForce := preload("res://battle/core/battle_tactical_force.gd")
const BattleForceCommandCatalog := preload("res://battle/core/battle_force_command_catalog.gd")
const BattleForceCommandResult := preload("res://battle/core/battle_force_command_result.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")

const REJECTION_NULL_BATTLE_STATE := "null_battle_state"
const REJECTION_EMPTY_FORCE_ID := "empty_force_id"
const REJECTION_FORCE_NOT_FOUND := "force_not_found"
const REJECTION_DUPLICATE_FORCE_ID := "duplicate_force_id"
const REJECTION_EMPTY_COMMAND_ID := "empty_command_id"
const REJECTION_INVALID_COMMAND := "invalid_command"

# Battle-local garrison identity. Not a campaign TravelingForce.id.
const GARRISON_FORCE_ID_PREFIX := "garrison:"


static func garrison_tactical_force_id(location_id: String) -> String:
	if location_id.is_empty():
		return ""
	return GARRISON_FORCE_ID_PREFIX + location_id


static func is_valid_command(command_id: String) -> bool:
	return BattleForceCommandCatalog.is_valid_command(command_id)


static func get_command_ids() -> Array[String]:
	return BattleForceCommandCatalog.command_ids()


static func get_tactical_force_ids(battle_state: BattleState) -> Array[String]:
	if battle_state == null:
		var empty: Array[String] = []
		return empty
	return battle_state.get_sorted_tactical_force_ids()


static func get_command(battle_state: BattleState, tactical_force_id: String) -> String:
	if battle_state == null or tactical_force_id.is_empty():
		return ""
	var force: BattleTacticalForce = battle_state.get_tactical_force(tactical_force_id)
	if force == null:
		return ""
	return force.command_id


static func get_command_for_participant(battle_state: BattleState, participant_id: String) -> String:
	if battle_state == null or participant_id.is_empty():
		return ""
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return ""
	if participant.tactical_force_id.is_empty():
		return ""
	return get_command(battle_state, participant.tactical_force_id)


static func register_force(
	battle_state: BattleState,
	tactical_force_id: String,
	side_id: String = ""
) -> BattleForceCommandResult:
	if battle_state == null:
		return BattleForceCommandResult.failed(
			REJECTION_NULL_BATTLE_STATE,
			"Force command failed: battle_state is null."
		)
	if tactical_force_id.is_empty():
		return BattleForceCommandResult.failed(
			REJECTION_EMPTY_FORCE_ID,
			"Force command failed: tactical_force_id is empty."
		)
	if battle_state.has_tactical_force(tactical_force_id):
		var existing: BattleTacticalForce = battle_state.get_tactical_force(tactical_force_id)
		var existing_command: String = ""
		if existing != null:
			existing_command = existing.command_id
		return BattleForceCommandResult.failed(
			REJECTION_DUPLICATE_FORCE_ID,
			"Force command failed: tactical force '%s' is already registered." % tactical_force_id,
			tactical_force_id,
			existing_command,
			existing_command
		)
	var force: BattleTacticalForce = BattleTacticalForce.new(
		tactical_force_id,
		side_id,
		BattleForceCommandCatalog.DEFAULT_COMMAND
	)
	if not battle_state.add_tactical_force(force):
		return BattleForceCommandResult.failed(
			REJECTION_FORCE_NOT_FOUND,
			"Force command failed: could not register tactical force '%s'." % tactical_force_id,
			tactical_force_id
		)
	return BattleForceCommandResult.succeeded(
		tactical_force_id,
		"",
		BattleForceCommandCatalog.DEFAULT_COMMAND
	)


static func set_command(
	battle_state: BattleState,
	tactical_force_id: String,
	command_id: String
) -> BattleForceCommandResult:
	if battle_state == null:
		return BattleForceCommandResult.failed(
			REJECTION_NULL_BATTLE_STATE,
			"Force command failed: battle_state is null.",
			tactical_force_id,
			"",
			command_id
		)
	if tactical_force_id.is_empty():
		return BattleForceCommandResult.failed(
			REJECTION_EMPTY_FORCE_ID,
			"Force command failed: tactical_force_id is empty.",
			"",
			"",
			command_id
		)
	if not battle_state.has_tactical_force(tactical_force_id):
		return BattleForceCommandResult.failed(
			REJECTION_FORCE_NOT_FOUND,
			"Force command failed: tactical force '%s' is not participating." % tactical_force_id,
			tactical_force_id,
			"",
			command_id
		)
	var force: BattleTacticalForce = battle_state.get_tactical_force(tactical_force_id)
	if force == null:
		return BattleForceCommandResult.failed(
			REJECTION_FORCE_NOT_FOUND,
			"Force command failed: tactical force '%s' is not participating." % tactical_force_id,
			tactical_force_id,
			"",
			command_id
		)
	var previous_command_id: String = force.command_id
	if command_id.is_empty():
		return BattleForceCommandResult.failed(
			REJECTION_EMPTY_COMMAND_ID,
			"Force command failed: command_id is empty.",
			tactical_force_id,
			previous_command_id,
			command_id
		)
	if not is_valid_command(command_id):
		return BattleForceCommandResult.failed(
			REJECTION_INVALID_COMMAND,
			"Force command failed: command '%s' is invalid." % command_id,
			tactical_force_id,
			previous_command_id,
			command_id
		)
	if previous_command_id == command_id:
		return BattleForceCommandResult.succeeded(
			tactical_force_id,
			previous_command_id,
			command_id
		)
	force.command_id = command_id
	return BattleForceCommandResult.succeeded(
		tactical_force_id,
		previous_command_id,
		command_id
	)


static func is_valid_forward_direction(direction: Vector2) -> bool:
	return BattleTacticalForce.is_valid_forward_direction(direction)


static func get_forward_direction(battle_state: BattleState, tactical_force_id: String) -> Vector2:
	var force: BattleTacticalForce = _require_force(battle_state, tactical_force_id)
	if force == null or not force.has_valid_forward_direction():
		return Vector2.ZERO
	return force.forward_direction


static func get_right_direction(battle_state: BattleState, tactical_force_id: String) -> Vector2:
	var force: BattleTacticalForce = _require_force(battle_state, tactical_force_id)
	if force == null:
		return Vector2.ZERO
	return force.right_direction()


static func get_left_direction(battle_state: BattleState, tactical_force_id: String) -> Vector2:
	var force: BattleTacticalForce = _require_force(battle_state, tactical_force_id)
	if force == null:
		return Vector2.ZERO
	return force.left_direction()


static func get_rear_direction(battle_state: BattleState, tactical_force_id: String) -> Vector2:
	var force: BattleTacticalForce = _require_force(battle_state, tactical_force_id)
	if force == null:
		return Vector2.ZERO
	return force.rear_direction()


static func get_forward_direction_for_participant(
	battle_state: BattleState,
	participant_id: String
) -> Vector2:
	var tactical_force_id: String = _participant_force_id(battle_state, participant_id)
	if tactical_force_id.is_empty():
		return Vector2.ZERO
	return get_forward_direction(battle_state, tactical_force_id)


static func get_right_direction_for_participant(
	battle_state: BattleState,
	participant_id: String
) -> Vector2:
	var tactical_force_id: String = _participant_force_id(battle_state, participant_id)
	if tactical_force_id.is_empty():
		return Vector2.ZERO
	return get_right_direction(battle_state, tactical_force_id)


static func get_left_direction_for_participant(
	battle_state: BattleState,
	participant_id: String
) -> Vector2:
	var tactical_force_id: String = _participant_force_id(battle_state, participant_id)
	if tactical_force_id.is_empty():
		return Vector2.ZERO
	return get_left_direction(battle_state, tactical_force_id)


static func get_rear_direction_for_participant(
	battle_state: BattleState,
	participant_id: String
) -> Vector2:
	var tactical_force_id: String = _participant_force_id(battle_state, participant_id)
	if tactical_force_id.is_empty():
		return Vector2.ZERO
	return get_rear_direction(battle_state, tactical_force_id)


static func set_forward_direction(
	battle_state: BattleState,
	tactical_force_id: String,
	direction: Vector2
) -> bool:
	var force: BattleTacticalForce = _require_force(battle_state, tactical_force_id)
	if force == null:
		return false
	return force.set_forward_direction(direction)


static func initialize_assault_frames_from_geometry(battle_state: BattleState) -> void:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not geometry.is_valid():
		return
	initialize_assault_frames(
		battle_state,
		geometry.attacker_deployment_centroid(),
		geometry.defender_deployment_centroid()
	)


static func initialize_assault_frames(
	battle_state: BattleState,
	attacker_origin: Vector2,
	defender_origin: Vector2
) -> void:
	if battle_state == null:
		return
	if not is_finite(attacker_origin.x) or not is_finite(attacker_origin.y):
		return
	if not is_finite(defender_origin.x) or not is_finite(defender_origin.y):
		return
	var toward_defender: Vector2 = defender_origin - attacker_origin
	if not is_finite(toward_defender.x) or not is_finite(toward_defender.y):
		return
	if toward_defender.is_equal_approx(Vector2.ZERO):
		return
	var attacker_forward: Vector2 = toward_defender.normalized()
	if not BattleTacticalForce.is_valid_forward_direction(attacker_forward):
		return
	var defender_forward: Vector2 = -attacker_forward
	if not BattleTacticalForce.is_valid_forward_direction(defender_forward):
		return
	var attacker_side_id: String = battle_state.attacker_side_id
	var defender_side_id: String = battle_state.defender_side_id
	for tactical_force_id: String in battle_state.get_sorted_tactical_force_ids():
		var force: BattleTacticalForce = battle_state.get_tactical_force(tactical_force_id)
		if force == null or force.has_valid_forward_direction():
			continue
		if not attacker_side_id.is_empty() and force.side_id == attacker_side_id:
			force.set_forward_direction(attacker_forward)
		elif not defender_side_id.is_empty() and force.side_id == defender_side_id:
			force.set_forward_direction(defender_forward)


static func _require_force(battle_state: BattleState, tactical_force_id: String) -> BattleTacticalForce:
	if battle_state == null or tactical_force_id.is_empty():
		return null
	return battle_state.get_tactical_force(tactical_force_id)


static func _participant_force_id(battle_state: BattleState, participant_id: String) -> String:
	if battle_state == null or participant_id.is_empty():
		return ""
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return ""
	return participant.tactical_force_id
