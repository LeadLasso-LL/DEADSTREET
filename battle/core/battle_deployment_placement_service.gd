class_name BattleDeploymentPlacementService
extends RefCounted

# Authoritative participant placement during deployment.
# Composes BattleState.deploy_participant (membership) with validated battle_position.
# Does not own geometry. Does not auto-layout. Does not begin battle.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleDeploymentPlacementResult := preload("res://battle/core/battle_deployment_placement_result.gd")


static func place_participant(
	battle_state: BattleState,
	participant_id: String,
	position: Vector2
) -> BattleDeploymentPlacementResult:
	if battle_state == null:
		return BattleDeploymentPlacementResult.failed(
			"null_battle_state",
			"Deployment placement failed: battle_state is null.",
			participant_id,
			position
		)
	if battle_state.battle_phase != "deployment":
		return BattleDeploymentPlacementResult.failed(
			"battle_not_in_deployment",
			"Deployment placement failed: battle phase is '%s', not deployment." % battle_state.battle_phase,
			participant_id,
			position
		)
	if participant_id.is_empty() or not battle_state.has_participant(participant_id):
		return BattleDeploymentPlacementResult.failed(
			"unknown_participant",
			"Deployment placement failed: participant '%s' does not exist." % participant_id,
			participant_id,
			position
		)
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return BattleDeploymentPlacementResult.failed(
			"unknown_participant",
			"Deployment placement failed: participant '%s' does not exist." % participant_id,
			participant_id,
			position
		)
	if not participant.is_alive:
		return BattleDeploymentPlacementResult.failed(
			"participant_dead",
			"Deployment placement failed: participant '%s' is not alive." % participant_id,
			participant_id,
			position
		)
	if battle_state.is_participant_deployed(participant_id) or participant.has_battle_position:
		return BattleDeploymentPlacementResult.failed(
			"already_deployed",
			"Deployment placement failed: participant '%s' is already deployed." % participant_id,
			participant_id,
			position
		)
	if not battle_state.has_side(participant.side_id):
		return BattleDeploymentPlacementResult.failed(
			"missing_side",
			"Deployment placement failed: side '%s' does not exist." % participant.side_id,
			participant_id,
			position
		)
	if battle_state.is_side_deployment_committed(participant.side_id):
		return BattleDeploymentPlacementResult.failed(
			"side_deployment_committed",
			"Deployment placement failed: side '%s' deployment is already committed." % participant.side_id,
			participant_id,
			position
		)
	var side: BattleSide = battle_state.get_side(participant.side_id)
	if side == null or side.deployment_zone_id.is_empty():
		return BattleDeploymentPlacementResult.failed(
			"missing_deployment_zone",
			"Deployment placement failed: side '%s' has no deployment zone." % participant.side_id,
			participant_id,
			position
		)
	var geometry_error: BattleDeploymentPlacementResult = _validate_position(
		battle_state,
		participant.side_id,
		position,
		participant_id
	)
	if geometry_error != null:
		return geometry_error
	if not battle_state.deploy_participant(participant_id, side.deployment_zone_id):
		return BattleDeploymentPlacementResult.failed(
			"deploy_failed",
			"Deployment placement failed: BattleState.deploy_participant rejected '%s'." % participant_id,
			participant_id,
			position
		)
	participant.has_battle_position = true
	participant.battle_position = position
	return BattleDeploymentPlacementResult.succeeded(participant_id, position)


static func _validate_position(
	battle_state: BattleState,
	side_id: String,
	position: Vector2,
	participant_id: String
) -> BattleDeploymentPlacementResult:
	# Shared legality lives on BattleState.get_deployment_position_error:
	# finite point, geometry.contains_point, attacker_deployment_contains,
	# defender_deployment_contains, and obstacle.blocks_movement.
	var error_code: String = battle_state.get_deployment_position_error(side_id, position)
	if error_code.is_empty():
		return null
	return BattleDeploymentPlacementResult.failed(
		error_code,
		_position_error_message(error_code, side_id, position, battle_state),
		participant_id,
		position
	)


static func _position_error_message(
	error_code: String,
	side_id: String,
	position: Vector2,
	battle_state: BattleState
) -> String:
	match error_code:
		"invalid_position":
			return "Deployment placement failed: position is not finite."
		"missing_battlefield_geometry":
			return "Deployment placement failed: battlefield geometry is missing or invalid."
		"outside_battlefield":
			return "Deployment placement failed: position is outside battlefield bounds."
		"outside_deployment_zone":
			if side_id == battle_state.attacker_side_id:
				return "Deployment placement failed: position is outside the attacker deployment region."
			if side_id == battle_state.defender_side_id:
				return "Deployment placement failed: position is outside the defender deployment region."
			return "Deployment placement failed: position is outside the deployment region."
		"unknown_side":
			return "Deployment placement failed: side '%s' is not attacker or defender." % side_id
		"inside_blocking_obstacle":
			var blocking_id: String = ""
			if battle_state.battlefield_geometry != null:
				blocking_id = battle_state.battlefield_geometry.get_movement_blocking_obstacle_id_at(position)
			if blocking_id.is_empty():
				return "Deployment placement failed: position is inside a movement-blocking obstacle."
			return "Deployment placement failed: position is inside movement-blocking obstacle '%s'." % blocking_id
		_:
			return "Deployment placement failed: position is not legal (%s)." % error_code
