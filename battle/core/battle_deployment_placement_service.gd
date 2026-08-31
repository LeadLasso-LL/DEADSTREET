class_name BattleDeploymentPlacementService
extends RefCounted

# Authoritative participant placement during deployment.
# Composes BattleState.deploy_participant (membership) with validated battle_position.
# Does not own geometry. Does not auto-layout. Does not begin battle.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
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
	if not BattlefieldGeometry.is_finite_point(position):
		return BattleDeploymentPlacementResult.failed(
			"invalid_position",
			"Deployment placement failed: position is not finite.",
			participant_id,
			position
		)
	if battle_state.battlefield_geometry == null or not battle_state.battlefield_geometry.is_valid():
		return BattleDeploymentPlacementResult.failed(
			"missing_battlefield_geometry",
			"Deployment placement failed: battlefield geometry is missing or invalid.",
			participant_id,
			position
		)
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if not geometry.contains_point(position):
		return BattleDeploymentPlacementResult.failed(
			"outside_battlefield",
			"Deployment placement failed: position is outside battlefield bounds.",
			participant_id,
			position
		)
	if side_id == battle_state.attacker_side_id:
		if not geometry.attacker_deployment_contains(position):
			return BattleDeploymentPlacementResult.failed(
				"outside_deployment_zone",
				"Deployment placement failed: position is outside the attacker deployment region.",
				participant_id,
				position
			)
	elif side_id == battle_state.defender_side_id:
		if not geometry.defender_deployment_contains(position):
			return BattleDeploymentPlacementResult.failed(
				"outside_deployment_zone",
				"Deployment placement failed: position is outside the defender deployment region.",
				participant_id,
				position
			)
	else:
		return BattleDeploymentPlacementResult.failed(
			"unknown_side",
			"Deployment placement failed: side '%s' is not attacker or defender." % side_id,
			participant_id,
			position
		)
	var blocking_id: String = _movement_blocking_obstacle_at(geometry, position)
	if not blocking_id.is_empty():
		return BattleDeploymentPlacementResult.failed(
			"inside_blocking_obstacle",
			"Deployment placement failed: position is inside movement-blocking obstacle '%s'." % blocking_id,
			participant_id,
			position
		)
	return null


static func _movement_blocking_obstacle_at(geometry: BattlefieldGeometry, point: Vector2) -> String:
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if obstacle.contains_point(point):
			return obstacle_id
	return ""
