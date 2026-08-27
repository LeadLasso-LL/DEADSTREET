class_name NeighborhoodHQAttackResult
extends RefCounted

var success: bool = false
var mission_id: String = ""
var force_id: String = ""
var attacker_faction_id: String = ""
var defender_faction_id: String = ""
var neighborhood_id: String = ""
var hq_location_id: String = ""
var mission_state: String = ""
var reached_destination: bool = false
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_mission_id: String,
	p_force_id: String,
	p_attacker_faction_id: String,
	p_defender_faction_id: String,
	p_neighborhood_id: String,
	p_hq_location_id: String,
	p_mission_state: String,
	p_reached_destination: bool
) -> NeighborhoodHQAttackResult:
	var result: NeighborhoodHQAttackResult = NeighborhoodHQAttackResult.new()
	result.success = true
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.attacker_faction_id = p_attacker_faction_id
	result.defender_faction_id = p_defender_faction_id
	result.neighborhood_id = p_neighborhood_id
	result.hq_location_id = p_hq_location_id
	result.mission_state = p_mission_state
	result.reached_destination = p_reached_destination
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = "",
	p_force_id: String = "",
	p_attacker_faction_id: String = "",
	p_defender_faction_id: String = "",
	p_neighborhood_id: String = "",
	p_hq_location_id: String = "",
	p_mission_state: String = "",
	p_reached_destination: bool = false
) -> NeighborhoodHQAttackResult:
	var result: NeighborhoodHQAttackResult = NeighborhoodHQAttackResult.new()
	result.success = false
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.attacker_faction_id = p_attacker_faction_id
	result.defender_faction_id = p_defender_faction_id
	result.neighborhood_id = p_neighborhood_id
	result.hq_location_id = p_hq_location_id
	result.mission_state = p_mission_state
	result.reached_destination = p_reached_destination
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
