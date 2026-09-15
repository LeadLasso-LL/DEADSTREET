class_name MissionRequest
extends RefCounted

const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")

var mission_id: String = ""
var mission_type_id: String = ""
var deployment_request: DeploymentRequest = DeploymentRequest.new()


func _init(
	p_mission_id: String = "",
	p_mission_type_id: String = "",
	p_deployment_request: DeploymentRequest = null
) -> void:
	mission_id = p_mission_id
	mission_type_id = p_mission_type_id
	if p_deployment_request != null:
		deployment_request = p_deployment_request
