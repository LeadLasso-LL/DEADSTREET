class_name CampaignMission
extends RefCounted

var id: String = ""
var mission_type_id: String = ""
var faction_id: String = ""
var force_id: String = ""
var origin_location_id: String = ""
var target_location_id: String = ""
var mission_state: String = ""
var outcome_code: String = ""


func _init(
	p_id: String = "",
	p_mission_type_id: String = "",
	p_faction_id: String = "",
	p_force_id: String = "",
	p_origin_location_id: String = "",
	p_target_location_id: String = "",
	p_mission_state: String = "",
	p_outcome_code: String = ""
) -> void:
	id = p_id
	mission_type_id = p_mission_type_id
	faction_id = p_faction_id
	force_id = p_force_id
	origin_location_id = p_origin_location_id
	target_location_id = p_target_location_id
	mission_state = p_mission_state
	outcome_code = p_outcome_code


func to_dict() -> Dictionary:
	return {
		"id": id,
		"mission_type_id": mission_type_id,
		"faction_id": faction_id,
		"force_id": force_id,
		"origin_location_id": origin_location_id,
		"target_location_id": target_location_id,
		"mission_state": mission_state,
		"outcome_code": outcome_code,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	mission_type_id = str(data.get("mission_type_id", ""))
	faction_id = str(data.get("faction_id", ""))
	force_id = str(data.get("force_id", ""))
	origin_location_id = str(data.get("origin_location_id", ""))
	target_location_id = str(data.get("target_location_id", ""))
	mission_state = str(data.get("mission_state", ""))
	outcome_code = str(data.get("outcome_code", ""))
