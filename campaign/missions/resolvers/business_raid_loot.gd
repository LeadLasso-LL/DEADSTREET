class_name BusinessRaidLoot
extends RefCounted

var cash: float = 0.0
var resources: Dictionary[String, float] = {}


func _init(p_cash: float = 0.0, p_resources: Dictionary = {}) -> void:
	if p_cash < 0.0:
		push_error("BusinessRaidLoot: negative cash is not allowed (cash=%s)." % p_cash)
		cash = 0.0
	else:
		cash = p_cash
	for resource_id: Variant in p_resources:
		set_resource_amount(str(resource_id), float(p_resources[resource_id]))


func set_resource_amount(resource_id: String, amount: float) -> bool:
	if resource_id.is_empty():
		push_error("BusinessRaidLoot.set_resource_amount: resource_id is empty.")
		return false
	if amount < 0.0:
		push_error("BusinessRaidLoot.set_resource_amount: negative amount is not allowed (resource_id='%s', amount=%s)." % [resource_id, amount])
		return false
	if amount == 0.0:
		resources.erase(resource_id)
		return true
	resources[resource_id] = amount
	return true


func get_resource_amount(resource_id: String) -> float:
	return resources.get(resource_id, 0.0)
