class_name BattleDeploymentAiResult
extends RefCounted

const BattleDeploymentPlan := preload("res://battle/ai/battle_deployment_plan.gd")

var success: bool = false
var side_id: String = ""
var opposing_side_id: String = ""
var plan: BattleDeploymentPlan = null
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_side_id: String,
	p_opposing_side_id: String,
	p_plan: BattleDeploymentPlan
):
	var result = new()
	result.success = true
	result.side_id = p_side_id
	result.opposing_side_id = p_opposing_side_id
	result.plan = p_plan
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_side_id: String = "",
	p_opposing_side_id: String = "",
	p_plan: BattleDeploymentPlan = null
):
	var result = new()
	result.success = false
	result.side_id = p_side_id
	result.opposing_side_id = p_opposing_side_id
	result.plan = p_plan
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
