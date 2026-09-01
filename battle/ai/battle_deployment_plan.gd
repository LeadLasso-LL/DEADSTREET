class_name BattleDeploymentPlan
extends RefCounted

# Query-only tactical deployment plan. Does not mutate BattleState.

const BattleDeploymentPlanAssignment := preload("res://battle/ai/battle_deployment_plan_assignment.gd")

const POSTURE_WEAKER := "weaker"
const POSTURE_EVEN := "even"
const POSTURE_STRONGER := "stronger"

var success: bool = false
var side_id: String = ""
var opposing_side_id: String = ""
var posture: String = POSTURE_EVEN
var assignments: Array[BattleDeploymentPlanAssignment] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_side_id: String,
	p_opposing_side_id: String,
	p_posture: String,
	p_assignments
):
	var plan = new()
	plan.success = true
	plan.side_id = p_side_id
	plan.opposing_side_id = p_opposing_side_id
	plan.posture = p_posture
	plan.assignments = _copy_assignments(p_assignments)
	plan.error_code = ""
	plan.error_message = ""
	return plan


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_side_id: String = "",
	p_opposing_side_id: String = "",
	p_posture: String = POSTURE_EVEN
):
	var plan = new()
	plan.success = false
	plan.side_id = p_side_id
	plan.opposing_side_id = p_opposing_side_id
	plan.posture = p_posture
	plan.assignments = _copy_assignments([])
	plan.error_code = p_error_code
	plan.error_message = p_error_message
	return plan


func assignment_for(participant_id: String) -> BattleDeploymentPlanAssignment:
	if participant_id.is_empty():
		return null
	for assignment: BattleDeploymentPlanAssignment in assignments:
		if assignment != null and assignment.participant_id == participant_id:
			return assignment
	return null


static func _copy_assignments(source) -> Array[BattleDeploymentPlanAssignment]:
	var copied: Array[BattleDeploymentPlanAssignment] = []
	if source == null:
		return copied
	for assignment in source:
		if assignment != null:
			copied.append(assignment)
	return copied
