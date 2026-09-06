class_name TacticalOrderResult
extends RefCounted

# Outcome of one live tactical player order. Does not own battle state.

var success: bool = false
var participant_id: String = ""
var order_kind: String = ""
var target_id: String = ""
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_participant_id: String,
	p_order_kind: String,
	p_target_id: String = ""
):
	var result := new()
	result.success = true
	result.participant_id = p_participant_id
	result.order_kind = p_order_kind
	result.target_id = p_target_id
	return result


static func failed(
	p_error_code: String,
	p_error_message: String,
	p_participant_id: String = "",
	p_order_kind: String = "",
	p_target_id: String = ""
):
	var result := new()
	result.success = false
	result.error_code = p_error_code
	result.error_message = p_error_message
	result.participant_id = p_participant_id
	result.order_kind = p_order_kind
	result.target_id = p_target_id
	return result
