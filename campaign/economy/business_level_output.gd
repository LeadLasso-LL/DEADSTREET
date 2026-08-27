class_name BusinessLevelOutput
extends RefCounted

var cash_per_turn: float = 0.0:
	set(value):
		if value < 0.0:
			push_error("BusinessLevelOutput: negative cash_per_turn is not allowed (cash_per_turn=%s)." % value)
			cash_per_turn = 0.0
		else:
			cash_per_turn = value
var resources_per_turn: Dictionary[String, float] = {}


func _init(p_cash_per_turn: float = 0.0, p_resources: Dictionary = {}) -> void:
	cash_per_turn = p_cash_per_turn
	for resource_id: Variant in p_resources:
		set_resource_output(str(resource_id), float(p_resources[resource_id]))


func set_resource_output(resource_id: String, amount: float) -> bool:
	if resource_id.is_empty():
		push_error("BusinessLevelOutput.set_resource_output: resource_id is empty.")
		return false
	if amount < 0.0:
		push_error(
			"BusinessLevelOutput.set_resource_output: negative amount is not allowed (resource_id='%s', amount=%s)."
			% [resource_id, amount]
		)
		return false
	if amount == 0.0:
		resources_per_turn.erase(resource_id)
		return true
	resources_per_turn[resource_id] = amount
	return true


func get_resource_output(resource_id: String) -> float:
	if resource_id.is_empty() or not resources_per_turn.has(resource_id):
		return 0.0
	return resources_per_turn[resource_id]
