class_name BattleCoverResult
extends RefCounted

var success: bool = false
var cover_slot_id: String = ""
var participant_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_cover_slot_id: String = "", p_participant_id: String = "") -> BattleCoverResult:
	var result := new()
	result.success = true
	result.cover_slot_id = p_cover_slot_id
	result.participant_id = p_participant_id
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_cover_slot_id: String = "",
	p_participant_id: String = ""
) -> BattleCoverResult:
	var result := new()
	result.success = false
	result.cover_slot_id = p_cover_slot_id
	result.participant_id = p_participant_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
