class_name BattleForceCommandService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleTacticalForce := preload("res://battle/core/battle_tactical_force.gd")
const BattleForceCommandCatalog := preload("res://battle/core/battle_force_command_catalog.gd")
const BattleForceCommandResult := preload("res://battle/core/battle_force_command_result.gd")

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
