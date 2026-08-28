class_name BattlefieldGeometryResult
extends RefCounted

var success: bool = false
var participants_positioned: int = 0
var vehicles_positioned: int = 0
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_participants_positioned: int,
	p_vehicles_positioned: int
) -> BattlefieldGeometryResult:
	var result: BattlefieldGeometryResult = BattlefieldGeometryResult.new()
	result.success = true
	result.participants_positioned = p_participants_positioned
	result.vehicles_positioned = p_vehicles_positioned
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattlefieldGeometryResult:
	var result: BattlefieldGeometryResult = BattlefieldGeometryResult.new()
	result.success = false
	result.participants_positioned = 0
	result.vehicles_positioned = 0
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
