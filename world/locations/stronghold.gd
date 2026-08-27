class_name Stronghold
extends Building

var level: int = 1:
	set(value):
		level = maxi(value, 1)
var upkeep_per_turn: float = 0.0:
	set(value):
		upkeep_per_turn = maxf(value, 0.0)
var vehicle_ids: Array[String] = []
var soldier_ids: Array[String] = []


func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_neighborhood_id: String = "",
	p_map_position: Vector2 = Vector2.ZERO,
	p_owner_faction_id: String = "",
	p_is_open: bool = true,
	p_level: int = 1,
	p_upkeep_per_turn: float = 0.0
) -> void:
	super(p_id, p_display_name, "stronghold", p_neighborhood_id, p_map_position, p_owner_faction_id, p_is_open)
	level = p_level
	upkeep_per_turn = p_upkeep_per_turn


func to_dict() -> Dictionary:
	var data := super.to_dict()
	var ids: Array[String] = []
	for vehicle_id in vehicle_ids:
		ids.append(vehicle_id)
	var soldier_id_data: Array[String] = []
	for soldier_id in soldier_ids:
		soldier_id_data.append(soldier_id)
	data["level"] = level
	data["upkeep_per_turn"] = upkeep_per_turn
	data["vehicle_ids"] = ids
	data["soldier_ids"] = soldier_id_data
	return data


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	location_type = "stronghold"
	level = int(data.get("level", 1))
	upkeep_per_turn = maxf(float(data.get("upkeep_per_turn", 0.0)), 0.0)
	vehicle_ids.clear()
	var ids_data: Variant = data.get("vehicle_ids", [])
	if ids_data is Array:
		for vehicle_id: Variant in ids_data:
			add_vehicle_id(str(vehicle_id))
	soldier_ids.clear()
	var soldier_ids_data: Variant = data.get("soldier_ids", [])
	if soldier_ids_data is Array:
		for soldier_id: Variant in soldier_ids_data:
			add_soldier_id(str(soldier_id))


func add_vehicle_id(vehicle_id: String) -> bool:
	if vehicle_id.is_empty():
		push_error("Stronghold.add_vehicle_id: vehicle id is empty (stronghold='%s')." % id)
		return false
	if vehicle_ids.has(vehicle_id):
		push_error("Stronghold.add_vehicle_id: duplicate vehicle id '%s' (stronghold='%s')." % [vehicle_id, id])
		return false
	vehicle_ids.append(vehicle_id)
	return true


func remove_vehicle_id(vehicle_id: String) -> bool:
	var index := vehicle_ids.find(vehicle_id)
	if index < 0:
		return false
	vehicle_ids.remove_at(index)
	return true


func has_vehicle_id(vehicle_id: String) -> bool:
	return vehicle_ids.has(vehicle_id)


func add_soldier_id(soldier_id: String) -> bool:
	if soldier_id.is_empty():
		push_error("Stronghold.add_soldier_id: soldier id is empty (stronghold='%s')." % id)
		return false
	if soldier_ids.has(soldier_id):
		push_error("Stronghold.add_soldier_id: duplicate soldier id '%s' (stronghold='%s')." % [soldier_id, id])
		return false
	soldier_ids.append(soldier_id)
	return true


func remove_soldier_id(soldier_id: String) -> bool:
	var index := soldier_ids.find(soldier_id)
	if index < 0:
		return false
	soldier_ids.remove_at(index)
	return true


func has_soldier_id(soldier_id: String) -> bool:
	return soldier_ids.has(soldier_id)
