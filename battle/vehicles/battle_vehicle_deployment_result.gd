class_name BattleVehicleDeploymentResult
extends RefCounted

const BattleVehicleDeploymentPlan := preload("res://battle/ai/battle_vehicle_deployment_plan.gd")

var success: bool = false
var side_id: String = ""
var opposing_side_id: String = ""
var placed_count: int = 0
var plan: BattleVehicleDeploymentPlan = null
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_side_id: String,
	p_opposing_side_id: String,
	p_placed_count: int,
	p_plan: BattleVehicleDeploymentPlan
):
	var result = new()
	result.success = true
	result.side_id = p_side_id
	result.opposing_side_id = p_opposing_side_id
	result.placed_count = p_placed_count
	result.plan = p_plan
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_side_id: String = "",
	p_opposing_side_id: String = "",
	p_plan: BattleVehicleDeploymentPlan = null
):
	var result = new()
	result.success = false
	result.side_id = p_side_id
	result.opposing_side_id = p_opposing_side_id
	result.placed_count = 0
	result.plan = p_plan
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
