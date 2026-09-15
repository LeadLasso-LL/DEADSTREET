class_name BattleCampaignSource
extends RefCounted

# Battle-local campaign provenance. Stable IDs only. Not campaign object ownership.

const SOURCE_NEIGHBORHOOD_HQ_ASSAULT := "neighborhood_hq_assault"

var source_type_id: String = ""
var mission_id: String = ""
var force_id: String = ""
var target_location_id: String = ""


func _init(
	p_source_type_id: String = "",
	p_mission_id: String = "",
	p_force_id: String = "",
	p_target_location_id: String = ""
) -> void:
	source_type_id = p_source_type_id
	mission_id = p_mission_id
	force_id = p_force_id
	target_location_id = p_target_location_id


func is_populated() -> bool:
	if source_type_id.is_empty():
		return false
	if mission_id.is_empty():
		return false
	if force_id.is_empty():
		return false
	if target_location_id.is_empty():
		return false
	return true
