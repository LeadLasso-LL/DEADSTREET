class_name NeighborhoodHQBattleResult
extends RefCounted

var success: bool = false
var attacker_won: bool = false
var mission_id: String = ""
var force_id: String = ""
var neighborhood_id: String = ""
var hq_location_id: String = ""
var attacker_faction_id: String = ""
var defender_faction_id: String = ""
var mission_state: String = ""
var outcome_code: String = ""
var businesses_unclaimed: Array[String] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_attacker_won: bool,
	p_mission_id: String,
	p_force_id: String,
	p_neighborhood_id: String,
	p_hq_location_id: String,
	p_attacker_faction_id: String,
	p_defender_faction_id: String,
	p_mission_state: String,
	p_outcome_code: String,
	p_businesses_unclaimed: Array[String]
) -> NeighborhoodHQBattleResult:
	var result: NeighborhoodHQBattleResult = NeighborhoodHQBattleResult.new()
	result.success = true
	result.attacker_won = p_attacker_won
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.neighborhood_id = p_neighborhood_id
	result.hq_location_id = p_hq_location_id
	result.attacker_faction_id = p_attacker_faction_id
	result.defender_faction_id = p_defender_faction_id
	result.mission_state = p_mission_state
	result.outcome_code = p_outcome_code
	result.businesses_unclaimed = _copy_ids(p_businesses_unclaimed)
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_attacker_won: bool = false,
	p_mission_id: String = "",
	p_force_id: String = "",
	p_neighborhood_id: String = "",
	p_hq_location_id: String = "",
	p_attacker_faction_id: String = "",
	p_defender_faction_id: String = "",
	p_mission_state: String = "",
	p_outcome_code: String = ""
) -> NeighborhoodHQBattleResult:
	var result: NeighborhoodHQBattleResult = NeighborhoodHQBattleResult.new()
	result.success = false
	result.attacker_won = p_attacker_won
	result.mission_id = p_mission_id
	result.force_id = p_force_id
	result.neighborhood_id = p_neighborhood_id
	result.hq_location_id = p_hq_location_id
	result.attacker_faction_id = p_attacker_faction_id
	result.defender_faction_id = p_defender_faction_id
	result.mission_state = p_mission_state
	result.outcome_code = p_outcome_code
	result.businesses_unclaimed = []
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func _copy_ids(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for business_id: String in source:
		copied.append(business_id)
	return copied
