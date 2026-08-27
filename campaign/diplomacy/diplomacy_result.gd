class_name DiplomacyResult
extends RefCounted

var success: bool = false
var faction_a_id: String = ""
var faction_b_id: String = ""
var is_at_war: bool = false
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_faction_a_id: String,
	p_faction_b_id: String,
	p_is_at_war: bool
) -> DiplomacyResult:
	var result: DiplomacyResult = DiplomacyResult.new()
	result.success = true
	result.faction_a_id = p_faction_a_id
	result.faction_b_id = p_faction_b_id
	result.is_at_war = p_is_at_war
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_faction_a_id: String = "",
	p_faction_b_id: String = "",
	p_is_at_war: bool = false
) -> DiplomacyResult:
	var result: DiplomacyResult = DiplomacyResult.new()
	result.success = false
	result.faction_a_id = p_faction_a_id
	result.faction_b_id = p_faction_b_id
	result.is_at_war = p_is_at_war
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
