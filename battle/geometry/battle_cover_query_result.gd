class_name BattleCoverQueryResult
extends RefCounted

var success: bool = false
var cover_slot_id: String = ""
var cover_slot_ids: Array[String] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(p_cover_slot_ids: Array[String] = [], p_cover_slot_id: String = "") -> BattleCoverQueryResult:
	var result := new()
	result.success = true
	result.cover_slot_ids = _copy_ids(p_cover_slot_ids)
	result.cover_slot_id = p_cover_slot_id
	if result.cover_slot_id.is_empty() and not result.cover_slot_ids.is_empty():
		result.cover_slot_id = result.cover_slot_ids[0]
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleCoverQueryResult:
	var result := new()
	result.success = false
	result.cover_slot_id = ""
	result.cover_slot_ids = []
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func _copy_ids(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for slot_id: String in source:
		copied.append(slot_id)
	return copied
