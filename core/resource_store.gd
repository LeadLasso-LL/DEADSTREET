class_name ResourceStore
extends RefCounted

var _amounts: Dictionary[String, float] = {}


func get_amount(resource_id: String) -> float:
	return _amounts.get(resource_id, 0.0)


func set_amount(resource_id: String, amount: float) -> void:
	if amount <= 0.0:
		_amounts.erase(resource_id)
	else:
		_amounts[resource_id] = amount


func add(resource_id: String, amount: float) -> void:
	if amount < 0.0:
		push_error("ResourceStore.add: negative amount is not allowed (resource_id='%s', amount=%s)." % [resource_id, amount])
		return
	if amount == 0.0:
		return
	set_amount(resource_id, get_amount(resource_id) + amount)


func remove(resource_id: String, amount: float) -> bool:
	if amount < 0.0:
		return false
	var current := get_amount(resource_id)
	if current < amount:
		return false
	set_amount(resource_id, current - amount)
	return true


func to_dict() -> Dictionary:
	var data := {}
	for resource_id: String in _amounts:
		data[resource_id] = _amounts[resource_id]
	return data


func from_dict(data: Dictionary) -> void:
	_amounts.clear()
	for resource_id: Variant in data:
		set_amount(str(resource_id), float(data[resource_id]))
