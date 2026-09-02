class_name BattleCombatConsequenceResult
extends RefCounted

var success: bool = false
var trauma_applied: float = 0.0
var vitality_before: float = 1.0
var vitality_after: float = 1.0
var was_wounded: bool = false
var is_wounded: bool = false
var was_alive: bool = true
var is_alive: bool = true
var wound_transitioned: bool = false
var died: bool = false
var error_code: String = ""
var error_message: String = ""


static func applied(
	p_trauma_applied: float,
	p_vitality_before: float,
	p_vitality_after: float,
	p_was_wounded: bool,
	p_is_wounded: bool,
	p_was_alive: bool,
	p_is_alive: bool,
	p_wound_transitioned: bool,
	p_died: bool
) -> BattleCombatConsequenceResult:
	var result := new()
	result.success = true
	result.trauma_applied = p_trauma_applied
	result.vitality_before = p_vitality_before
	result.vitality_after = p_vitality_after
	result.was_wounded = p_was_wounded
	result.is_wounded = p_is_wounded
	result.was_alive = p_was_alive
	result.is_alive = p_is_alive
	result.wound_transitioned = p_wound_transitioned
	result.died = p_died
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleCombatConsequenceResult:
	var result := new()
	result.success = false
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result
