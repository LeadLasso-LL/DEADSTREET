class_name BattleVehiclePlacementService
extends RefCounted

# Authoritative vehicle placement during deployment.
# Composes BattleState.deploy_vehicle (membership) with validated pose.
# Does not own geometry. Does not begin battle. Does not write from the view.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleVehiclePlacementResult := preload("res://battle/vehicles/battle_vehicle_placement_result.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleVehicleCoverService := preload("res://battle/vehicles/battle_vehicle_cover_service.gd")


static func place_vehicle(
	battle_state: BattleState,
	vehicle_id: String,
	position: Vector2,
	facing_direction: Vector2
) -> BattleVehiclePlacementResult:
	if battle_state == null:
		return BattleVehiclePlacementResult.failed(
			"null_battle_state",
			"Vehicle placement failed: battle_state is null.",
			vehicle_id,
			position,
			facing_direction
		)
	if battle_state.battle_phase != "deployment":
		return BattleVehiclePlacementResult.failed(
			"battle_not_in_deployment",
			"Vehicle placement failed: battle phase is '%s', not deployment." % battle_state.battle_phase,
			vehicle_id,
			position,
			facing_direction
		)
	if vehicle_id.is_empty() or not battle_state.has_vehicle(vehicle_id):
		return BattleVehiclePlacementResult.failed(
			"unknown_vehicle",
			"Vehicle placement failed: vehicle '%s' does not exist." % vehicle_id,
			vehicle_id,
			position,
			facing_direction
		)
	var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
	if vehicle == null:
		return BattleVehiclePlacementResult.failed(
			"unknown_vehicle",
			"Vehicle placement failed: vehicle '%s' does not exist." % vehicle_id,
			vehicle_id,
			position,
			facing_direction
		)
	if not _facing_is_usable(facing_direction):
		return BattleVehiclePlacementResult.failed(
			"invalid_orientation",
			"Vehicle placement failed: facing direction is invalid.",
			vehicle_id,
			position,
			facing_direction
		)
	var normalized_facing: Vector2 = facing_direction.normalized()
	if battle_state.is_vehicle_deployed(vehicle_id) and vehicle.has_battle_position:
		return BattleVehiclePlacementResult.failed(
			"already_deployed",
			"Vehicle placement failed: vehicle '%s' is already deployed." % vehicle_id,
			vehicle_id,
			position,
			normalized_facing
		)
	if not battle_state.has_side(vehicle.side_id):
		return BattleVehiclePlacementResult.failed(
			"missing_side",
			"Vehicle placement failed: side '%s' does not exist." % vehicle.side_id,
			vehicle_id,
			position,
			normalized_facing
		)
	if battle_state.is_side_deployment_committed(vehicle.side_id):
		return BattleVehiclePlacementResult.failed(
			"side_deployment_committed",
			"Vehicle placement failed: side '%s' deployment is already committed." % vehicle.side_id,
			vehicle_id,
			position,
			normalized_facing
		)
	var side: BattleSide = battle_state.get_side(vehicle.side_id)
	if side == null or side.deployment_zone_id.is_empty():
		return BattleVehiclePlacementResult.failed(
			"missing_deployment_zone",
			"Vehicle placement failed: side '%s' has no deployment zone." % vehicle.side_id,
			vehicle_id,
			position,
			normalized_facing
		)
	var legality: String = BattleVehicleBodyService.get_placement_error(
		battle_state,
		vehicle_id,
		position,
		normalized_facing
	)
	if not legality.is_empty():
		return BattleVehiclePlacementResult.failed(
			legality,
			_position_error_message(legality, vehicle.side_id, battle_state, vehicle_id),
			vehicle_id,
			position,
			normalized_facing
		)
	var preview_vehicle: BattleVehicle = BattleVehicle.new(
		vehicle.battle_vehicle_id,
		vehicle.campaign_vehicle_id,
		vehicle.faction_id,
		vehicle.side_id,
		vehicle.vehicle_type_id,
		vehicle.deployment_slot_id
	)
	preview_vehicle.has_battle_position = true
	preview_vehicle.battle_position = position
	preview_vehicle.set_facing_direction(normalized_facing)
	if BattleVehicleCoverService.collect_legal_body_slots(battle_state, preview_vehicle).is_empty():
		return BattleVehiclePlacementResult.failed(
			"cover_failed",
			"Vehicle placement failed: body cover could not be created for '%s'." % vehicle_id,
			vehicle_id,
			position,
			normalized_facing
		)
	var already_member: bool = battle_state.is_vehicle_deployed(vehicle_id)
	if not already_member:
		if not battle_state.deploy_vehicle(vehicle_id, side.deployment_zone_id):
			return BattleVehiclePlacementResult.failed(
				"deploy_failed",
				"Vehicle placement failed: BattleState.deploy_vehicle rejected '%s'." % vehicle_id,
				vehicle_id,
				position,
				normalized_facing
			)
	if not vehicle.set_facing_direction(normalized_facing):
		return BattleVehiclePlacementResult.failed(
			"invalid_orientation",
			"Vehicle placement failed: facing direction is invalid.",
			vehicle_id,
			position,
			normalized_facing
		)
	vehicle.has_battle_position = true
	vehicle.battle_position = position
	if not BattleVehicleCoverService.ensure_body_cover(battle_state, vehicle_id):
		vehicle.has_battle_position = false
		vehicle.battle_position = Vector2.ZERO
		vehicle.has_facing = false
		vehicle.facing_direction = Vector2.ZERO
		return BattleVehiclePlacementResult.failed(
			"cover_failed",
			"Vehicle placement failed: body cover could not be created for '%s'." % vehicle_id,
			vehicle_id,
			position,
			normalized_facing
		)
	return BattleVehiclePlacementResult.succeeded(vehicle_id, position, normalized_facing)


static func _facing_is_usable(facing: Vector2) -> bool:
	if not is_finite(facing.x) or not is_finite(facing.y):
		return false
	if facing.is_equal_approx(Vector2.ZERO):
		return false
	return true


static func _position_error_message(
	error_code: String,
	side_id: String,
	battle_state: BattleState,
	vehicle_id: String
) -> String:
	match error_code:
		"invalid_position":
			return "Vehicle placement failed: position is not finite."
		"invalid_orientation":
			return "Vehicle placement failed: facing direction is invalid."
		"unknown_vehicle":
			return "Vehicle placement failed: vehicle '%s' does not exist." % vehicle_id
		"missing_profile":
			return "Vehicle placement failed: vehicle '%s' has no physical profile." % vehicle_id
		"missing_battlefield_geometry":
			return "Vehicle placement failed: battlefield geometry is missing or invalid."
		"outside_battlefield":
			return "Vehicle placement failed: vehicle body is outside battlefield bounds."
		"outside_deployment_zone":
			if side_id == battle_state.attacker_side_id:
				return "Vehicle placement failed: vehicle body is outside the attacker deployment region."
			if side_id == battle_state.defender_side_id:
				return "Vehicle placement failed: vehicle body is outside the defender deployment region."
			return "Vehicle placement failed: vehicle body is outside the deployment region."
		"unknown_side":
			return "Vehicle placement failed: side '%s' is not attacker or defender." % side_id
		"inside_blocking_obstacle":
			return "Vehicle placement failed: vehicle body intersects a movement-blocking obstacle."
		"overlaps_vehicle":
			return "Vehicle placement failed: vehicle body overlaps another vehicle."
		"overlaps_participant":
			return "Vehicle placement failed: vehicle body overlaps a positioned participant."
		_:
			return "Vehicle placement failed: pose is not legal (%s)." % error_code
