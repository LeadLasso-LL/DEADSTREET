class_name Neighborhood
extends RefCounted

var id: String = ""
var display_name: String = ""
var stronghold_region_id: String = ""
var police_region_id: String = ""
var owner_faction_id: String = ""


func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_stronghold_region_id: String = "",
	p_police_region_id: String = "",
	p_owner_faction_id: String = ""
) -> void:
	id = p_id
	display_name = p_display_name
	stronghold_region_id = p_stronghold_region_id
	police_region_id = p_police_region_id
	owner_faction_id = p_owner_faction_id


func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"stronghold_region_id": stronghold_region_id,
		"police_region_id": police_region_id,
		"owner_faction_id": owner_faction_id,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	display_name = str(data.get("display_name", ""))
	stronghold_region_id = str(data.get("stronghold_region_id", ""))
	police_region_id = str(data.get("police_region_id", ""))
	owner_faction_id = str(data.get("owner_faction_id", ""))
