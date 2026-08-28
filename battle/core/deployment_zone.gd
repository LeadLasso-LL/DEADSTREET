class_name DeploymentZone
extends RefCounted

var zone_id: String = ""
var side_id: String = ""
var zone_type: String = ""
var allowed_participant_ids: Array[String] = []
var allowed_vehicle_ids: Array[String] = []
var deployed_participant_ids: Array[String] = []
var deployed_vehicle_ids: Array[String] = []


func _init(
	p_zone_id: String = "",
	p_side_id: String = "",
	p_zone_type: String = ""
) -> void:
	zone_id = p_zone_id
	side_id = p_side_id
	zone_type = p_zone_type


func allows_participant(participant_id: String) -> bool:
	if participant_id.is_empty():
		return false
	return allowed_participant_ids.has(participant_id)


func allows_vehicle(vehicle_id: String) -> bool:
	if vehicle_id.is_empty():
		return false
	return allowed_vehicle_ids.has(vehicle_id)


func has_deployed_participant(participant_id: String) -> bool:
	if participant_id.is_empty():
		return false
	return deployed_participant_ids.has(participant_id)


func has_deployed_vehicle(vehicle_id: String) -> bool:
	if vehicle_id.is_empty():
		return false
	return deployed_vehicle_ids.has(vehicle_id)
