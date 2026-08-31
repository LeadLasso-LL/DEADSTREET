class_name BattleVictoryResult
extends RefCounted

# Battle-local terminal result. Not a campaign mission outcome.

const RESULT_NONE := ""
const RESULT_VICTORY := "victory"
const RESULT_DRAW := "draw"

var success: bool = false
var evaluated: bool = false
var resolved: bool = false
var resolved_this_call: bool = false
var result_kind: String = RESULT_NONE
var winning_side_id: String = ""
var losing_side_ids: Array[String] = []
var living_side_ids: Array[String] = []
var error_code: String = ""
var error_message: String = ""


static func continuing(p_living_side_ids: Array[String]) -> BattleVictoryResult:
	var result := new()
	result.success = true
	result.evaluated = true
	result.resolved = false
	result.resolved_this_call = false
	result.result_kind = RESULT_NONE
	result.winning_side_id = ""
	result.losing_side_ids = []
	result.living_side_ids = _copy_ids(p_living_side_ids)
	result.error_code = ""
	result.error_message = ""
	return result


static func resolved_victory(
	p_winning_side_id: String,
	p_losing_side_ids: Array[String],
	p_living_side_ids: Array[String],
	p_resolved_this_call: bool
) -> BattleVictoryResult:
	var result := new()
	result.success = true
	result.evaluated = true
	result.resolved = true
	result.resolved_this_call = p_resolved_this_call
	result.result_kind = RESULT_VICTORY
	result.winning_side_id = p_winning_side_id
	result.losing_side_ids = _copy_ids(p_losing_side_ids)
	result.living_side_ids = _copy_ids(p_living_side_ids)
	result.error_code = ""
	result.error_message = ""
	return result


static func resolved_draw(
	p_losing_side_ids: Array[String],
	p_resolved_this_call: bool
) -> BattleVictoryResult:
	var result := new()
	result.success = true
	result.evaluated = true
	result.resolved = true
	result.resolved_this_call = p_resolved_this_call
	result.result_kind = RESULT_DRAW
	result.winning_side_id = ""
	result.losing_side_ids = _copy_ids(p_losing_side_ids)
	result.living_side_ids = []
	result.error_code = ""
	result.error_message = ""
	return result


static func ineligible(p_error_code: String, p_error_message: String) -> BattleVictoryResult:
	var result := new()
	result.success = false
	result.evaluated = false
	result.resolved = false
	result.resolved_this_call = false
	result.result_kind = RESULT_NONE
	result.winning_side_id = ""
	result.losing_side_ids = []
	result.living_side_ids = []
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func from_stored(stored: BattleVictoryResult) -> BattleVictoryResult:
	if stored == null:
		return ineligible(
			"missing_tactical_result",
			"Battle victory failed: stored tactical result is missing."
		)
	if stored.result_kind == RESULT_DRAW:
		return resolved_draw(stored.losing_side_ids, false)
	if stored.result_kind == RESULT_VICTORY:
		return resolved_victory(
			stored.winning_side_id,
			stored.losing_side_ids,
			stored.living_side_ids,
			false
		)
	return ineligible(
		"invalid_tactical_result",
		"Battle victory failed: stored tactical result is invalid."
	)


static func _copy_ids(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for side_id: String in source:
		copied.append(side_id)
	return copied
