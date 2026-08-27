class_name BusinessProductionResult
extends RefCounted

var business_id: String = ""
var owner_faction_id: String = ""
var produced: bool = false
var cash_produced: float = 0.0
var resources_produced: Dictionary[String, float] = {}
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_business_id: String,
	p_owner_faction_id: String,
	p_cash_produced: float,
	p_resources_produced: Dictionary
) -> BusinessProductionResult:
	var result: BusinessProductionResult = BusinessProductionResult.new()
	result.business_id = p_business_id
	result.owner_faction_id = p_owner_faction_id
	result.produced = true
	result.cash_produced = maxf(p_cash_produced, 0.0)
	result.resources_produced = _copy_resources(p_resources_produced)
	result.error_code = ""
	result.error_message = ""
	return result


static func skipped(p_business_id: String, p_owner_faction_id: String = "") -> BusinessProductionResult:
	var result: BusinessProductionResult = BusinessProductionResult.new()
	result.business_id = p_business_id
	result.owner_faction_id = p_owner_faction_id
	result.produced = false
	result.cash_produced = 0.0
	result.resources_produced = {}
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_business_id: String = "",
	p_owner_faction_id: String = ""
) -> BusinessProductionResult:
	var result: BusinessProductionResult = BusinessProductionResult.new()
	result.business_id = p_business_id
	result.owner_faction_id = p_owner_faction_id
	result.produced = false
	result.cash_produced = 0.0
	result.resources_produced = {}
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func _copy_resources(source: Dictionary) -> Dictionary[String, float]:
	var copied: Dictionary[String, float] = {}
	for resource_id: Variant in source:
		copied[str(resource_id)] = float(source[resource_id])
	return copied
