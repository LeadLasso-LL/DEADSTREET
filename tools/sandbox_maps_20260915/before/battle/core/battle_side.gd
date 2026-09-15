class_name BattleSide
extends RefCounted

var side_id: String = ""
var faction_id: String = ""
var force_id: String = ""
var is_attacker: bool = false
var participant_ids: Array[String] = []
var vehicle_ids: Array[String] = []
var deployment_zone_id: String = ""
var deployment_committed: bool = false


func _init(
	p_side_id: String = "",
	p_faction_id: String = "",
	p_force_id: String = "",
	p_is_attacker: bool = false,
	p_deployment_zone_id: String = ""
) -> void:
	side_id = p_side_id
	faction_id = p_faction_id
	force_id = p_force_id
	is_attacker = p_is_attacker
	deployment_zone_id = p_deployment_zone_id


func add_participant_id(participant_id: String) -> bool:
	if participant_id.is_empty():
		push_error("BattleSide.add_participant_id: participant id is empty.")
		return false
	if participant_ids.has(participant_id):
		push_error("BattleSide.add_participant_id: duplicate participant id '%s'." % participant_id)
		return false
	participant_ids.append(participant_id)
	return true


func add_vehicle_id(vehicle_id: String) -> bool:
	if vehicle_id.is_empty():
		push_error("BattleSide.add_vehicle_id: vehicle id is empty.")
		return false
	if vehicle_ids.has(vehicle_id):
		push_error("BattleSide.add_vehicle_id: duplicate vehicle id '%s'." % vehicle_id)
		return false
	vehicle_ids.append(vehicle_id)
	return true


func has_participant_id(participant_id: String) -> bool:
	return participant_ids.has(participant_id)


func has_vehicle_id(vehicle_id: String) -> bool:
	return vehicle_ids.has(vehicle_id)
