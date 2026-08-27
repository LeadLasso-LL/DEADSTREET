class_name EconomyTurnResult
extends RefCounted

const BusinessProductionResult := preload("res://campaign/economy/business_production_result.gd")
const FactionEconomyResult := preload("res://campaign/economy/faction_economy_result.gd")

var success: bool = false
var business_results: Array[BusinessProductionResult] = []
var faction_results: Array[FactionEconomyResult] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_business_results: Array[BusinessProductionResult],
	p_faction_results: Array[FactionEconomyResult]
) -> EconomyTurnResult:
	var result: EconomyTurnResult = EconomyTurnResult.new()
	result.success = true
	result.error_code = ""
	result.error_message = ""
	for business_result: BusinessProductionResult in p_business_results:
		result.business_results.append(business_result)
	for faction_result: FactionEconomyResult in p_faction_results:
		result.faction_results.append(faction_result)
	return result


static func failed(p_error_code: String, p_error_message: String) -> EconomyTurnResult:
	var result: EconomyTurnResult = EconomyTurnResult.new()
	result.success = false
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
