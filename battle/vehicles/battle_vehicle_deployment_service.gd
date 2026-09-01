class_name BattleVehicleDeploymentService
extends RefCounted

# Authoritative apply of a query-only vehicle parking plan.
# Places through BattleVehiclePlacementService. Does not begin battle.
# Idempotent for already fully deployed vehicles.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicleDeploymentPlanner := preload("res://battle/ai/battle_vehicle_deployment_planner.gd")
const BattleVehicleDeploymentPlan := preload("res://battle/ai/battle_vehicle_deployment_plan.gd")
const BattleVehicleDeploymentPlanAssignment := preload(
	"res://battle/ai/battle_vehicle_deployment_plan_assignment.gd"
)
const BattleVehiclePlacementService := preload("res://battle/vehicles/battle_vehicle_placement_service.gd")
const BattleVehiclePlacementResult := preload("res://battle/vehicles/battle_vehicle_placement_result.gd")
const BattleVehiclePlacementContext := preload("res://battle/vehicles/battle_vehicle_placement_context.gd")
const BattleVehicleDeploymentResult := preload("res://battle/vehicles/battle_vehicle_deployment_result.gd")


static func apply_side(
	battle_state: BattleState,
	side_id: String,
	opposing_side_id: String,
	context: BattleVehiclePlacementContext = null
) -> BattleVehicleDeploymentResult:
	var plan: BattleVehicleDeploymentPlan = BattleVehicleDeploymentPlanner.plan_side_vehicles(
		battle_state,
		side_id,
		opposing_side_id,
		context
	)
	if plan == null or not plan.success:
		var error_code: String = "plan_failed"
		var error_message: String = "Vehicle deployment failed: planner did not produce a valid plan."
		if plan != null:
			if not plan.error_code.is_empty():
				error_code = plan.error_code
			if not plan.error_message.is_empty():
				error_message = plan.error_message
		return BattleVehicleDeploymentResult.failed(
			error_code,
			error_message,
			side_id,
			opposing_side_id,
			plan
		)
	var placed_count: int = 0
	for assignment: BattleVehicleDeploymentPlanAssignment in plan.assignments:
		var placed: BattleVehiclePlacementResult = BattleVehiclePlacementService.place_vehicle(
			battle_state,
			assignment.vehicle_id,
			assignment.position,
			assignment.facing_direction
		)
		if placed == null or not placed.success:
			var place_code: String = "place_failed"
			var place_message: String = (
				"Vehicle deployment failed: authoritative placement rejected '%s'."
				% assignment.vehicle_id
			)
			if placed != null:
				if not placed.error_code.is_empty():
					place_code = placed.error_code
				if not placed.error_message.is_empty():
					place_message = placed.error_message
			return BattleVehicleDeploymentResult.failed(
				place_code,
				place_message,
				side_id,
				opposing_side_id,
				plan
			)
		placed_count += 1
	return BattleVehicleDeploymentResult.succeeded(side_id, opposing_side_id, placed_count, plan)
