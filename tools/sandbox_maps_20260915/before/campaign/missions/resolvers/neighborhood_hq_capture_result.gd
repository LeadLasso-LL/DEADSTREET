class_name NeighborhoodHQCaptureResult
extends RefCounted

var success: bool = false
var mission_id: String = ""
var force_id: String = ""
var neighborhood_id: String = ""
var hq_location_id: String = ""
var attacker_faction_id: String = ""
var defender_faction_id: String = ""
var businesses_unclaimed: Array[String] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_mission_id: String,
	p_force_id: String,
	p_neighborhood_id: String,
	p_hq_location_id: String,
	p_attacker_faction_id: String,
	p_defender_faction_id: String,
	p_businesses_unclaimed: Array[String]
) -> NeighborhoodHQCaptureResult:
	var result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResult.new()
	result.success = true
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.neighborhood_id = p_neighborhood_id
	result.hq_location_id = p_hq_location_id
	result.attacker_faction_id = p_attacker_faction_id
	result.defender_faction_id = p_defender_faction_id
	result.businesses_unclaimed = _copy_ids(p_businesses_unclaimed)
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = "",
	p_force_id: String = "",
	p_neighborhood_id: String = "",
	p_hq_location_id: String = "",
	p_attacker_faction_id: String = "",
	p_defender_faction_id: String = ""
) -> NeighborhoodHQCaptureResult:
	var result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResult.new()
	result.success = false
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.neighborhood_id = p_neighborhood_id
	result.hq_location_id = p_hq_location_id
	result.attacker_faction_id = p_attacker_faction_id
	result.defender_faction_id = p_defender_faction_id
	result.businesses_unclaimed = []
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func _copy_ids(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for business_id: String in source:
		copied.append(business_id)
	return copied
