class_name ExistingForceMissionRequest
extends RefCounted

var mission_id: String = ""
var mission_type_id: String = ""
var force_id: String = ""
var target_location_id: String = ""


func _init(
	p_mission_id: String = "",
	p_mission_type_id: String = "",
	p_force_id: String = "",
	p_target_location_id: String = ""
) -> void:
	mission_id = p_mission_id
	mission_type_id = p_mission_type_id
	force_id = p_force_id
	target_location_id = p_target_location_id
