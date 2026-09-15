class_name BusinessRaidResult
extends RefCounted

var success: bool = false
var mission_id: String = ""
var business_id: String = ""
var error_code: String = ""
var error_message: String = ""
var cash_looted: float = 0.0
var resources_looted: Dictionary[String, float] = {}
var business_level_before: int = 0
var business_level_after: int = 0
var business_closed: bool = false


static func succeeded(
	p_mission_id: String,
	p_business_id: String,
	p_cash_looted: float,
	p_resources_looted: Dictionary,
	p_business_level_before: int,
	p_business_level_after: int
) -> BusinessRaidResult:
	var result: BusinessRaidResult = BusinessRaidResult.new()
	result.success = true
	result.mission_id = p_mission_id
	result.business_id = p_business_id
	result.error_code = ""
	result.error_message = ""
	result.cash_looted = p_cash_looted
	result.resources_looted = _copy_resources(p_resources_looted)
	result.business_level_before = p_business_level_before
	result.business_level_after = p_business_level_after
	result.business_closed = true
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_mission_id: String = "",
	p_business_id: String = ""
) -> BusinessRaidResult:
	var result: BusinessRaidResult = BusinessRaidResult.new()
	result.success = false
	result.mission_id = p_mission_id
	result.business_id = p_business_id
	result.error_code = p_error_code
	result.error_message = p_error_message
	result.cash_looted = 0.0
	result.resources_looted = {}
	result.business_level_before = 0
	result.business_level_after = 0
	result.business_closed = false
	return result


static func _copy_resources(source: Dictionary) -> Dictionary[String, float]:
	var copied: Dictionary[String, float] = {}
	for resource_id: Variant in source:
		copied[str(resource_id)] = float(source[resource_id])
	return copied
