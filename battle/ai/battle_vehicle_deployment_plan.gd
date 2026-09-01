class_name BattleVehicleDeploymentPlan
extends RefCounted

# Query-only vehicle deployment plan. Does not mutate BattleState.

const BattleVehicleDeploymentPlanAssignment := preload(
	"res://battle/ai/battle_vehicle_deployment_plan_assignment.gd"
)

var success: bool = false
var side_id: String = ""
var opposing_side_id: String = ""
var assignments: Array[BattleVehicleDeploymentPlanAssignment] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_side_id: String,
	p_opposing_side_id: String,
	p_assignments
):
	var plan = new()
	plan.success = true
	plan.side_id = p_side_id
	plan.opposing_side_id = p_opposing_side_id
	plan.assignments = _copy_assignments(p_assignments)
	plan.error_code = ""
	plan.error_message = ""
	return plan


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_side_id: String = "",
	p_opposing_side_id: String = ""
):
	var plan = new()
	plan.success = false
	plan.side_id = p_side_id
	plan.opposing_side_id = p_opposing_side_id
	plan.assignments = _copy_assignments([])
	plan.error_code = p_error_code
	plan.error_message = p_error_message
	return plan


static func _copy_assignments(source) -> Array[BattleVehicleDeploymentPlanAssignment]:
	var copied: Array[BattleVehicleDeploymentPlanAssignment] = []
	if source == null:
		return copied
	for assignment in source:
		if assignment != null:
			copied.append(assignment)
	return copied
