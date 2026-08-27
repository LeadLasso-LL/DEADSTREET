class_name DeploymentRequest
extends RefCounted

var force_id: String = ""
var faction_id: String = ""
var origin_stronghold_id: String = ""
var destination_location_id: String = ""
var soldier_ids: Array[String] = []
var vehicle_ids: Array[String] = []
var movement_budget: float = 0.0:
	set(value):
		movement_budget = maxf(value, 0.0)


func _init(
	p_force_id: String = "",
	p_faction_id: String = "",
	p_origin_stronghold_id: String = "",
	p_destination_location_id: String = "",
	p_soldier_ids: Array[String] = [],
	p_vehicle_ids: Array[String] = [],
	p_movement_budget: float = 0.0
) -> void:
	force_id = p_force_id
	faction_id = p_faction_id
	origin_stronghold_id = p_origin_stronghold_id
	destination_location_id = p_destination_location_id
	for soldier_id in p_soldier_ids:
		soldier_ids.append(str(soldier_id))
	for vehicle_id in p_vehicle_ids:
		vehicle_ids.append(str(vehicle_id))
	movement_budget = p_movement_budget
