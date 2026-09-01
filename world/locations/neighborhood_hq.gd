class_name NeighborhoodHQ
extends Building

# v1 campaign garrison: genuine GameState Soldiers stationed at this HQ.
# Capture-time garrison fate is a later campaign consequence and is not handled here.

const DEFAULT_GARRISON_CAPACITY := 4

var garrison_capacity: int = DEFAULT_GARRISON_CAPACITY:
	set(value):
		garrison_capacity = maxi(value, 0)
var garrison_soldier_ids: Array[String] = []


func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_neighborhood_id: String = "",
	p_map_position: Vector2 = Vector2.ZERO,
	p_owner_faction_id: String = "",
	p_is_open: bool = true,
	p_garrison_capacity: int = DEFAULT_GARRISON_CAPACITY
) -> void:
	super(p_id, p_display_name, "neighborhood_hq", p_neighborhood_id, p_map_position, p_owner_faction_id, p_is_open)
	garrison_capacity = p_garrison_capacity


func to_dict() -> Dictionary:
	var data := super.to_dict()
	var soldier_id_data: Array[String] = []
	for soldier_id in garrison_soldier_ids:
		soldier_id_data.append(soldier_id)
	data["garrison_capacity"] = garrison_capacity
	data["garrison_soldier_ids"] = soldier_id_data
	return data


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	location_type = "neighborhood_hq"
	garrison_capacity = int(data.get("garrison_capacity", DEFAULT_GARRISON_CAPACITY))
	garrison_soldier_ids.clear()
	var soldier_ids_data: Variant = data.get("garrison_soldier_ids", [])
	if soldier_ids_data is Array:
		for soldier_id: Variant in soldier_ids_data:
			add_garrison_soldier_id(str(soldier_id))


func get_garrison_count() -> int:
	return garrison_soldier_ids.size()


func has_garrison_capacity() -> bool:
	return garrison_soldier_ids.size() < garrison_capacity


func has_garrison_soldier_id(soldier_id: String) -> bool:
	return garrison_soldier_ids.has(soldier_id)


func add_garrison_soldier_id(soldier_id: String) -> bool:
	if soldier_id.is_empty():
		push_error("NeighborhoodHQ.add_garrison_soldier_id: soldier id is empty (hq='%s')." % id)
		return false
	if garrison_soldier_ids.has(soldier_id):
		push_error(
			"NeighborhoodHQ.add_garrison_soldier_id: duplicate soldier id '%s' (hq='%s')."
			% [soldier_id, id]
		)
		return false
	if garrison_soldier_ids.size() >= garrison_capacity:
		push_error(
			"NeighborhoodHQ.add_garrison_soldier_id: garrison is full (%s/%s) (hq='%s')."
			% [garrison_soldier_ids.size(), garrison_capacity, id]
		)
		return false
	garrison_soldier_ids.append(soldier_id)
	return true


func remove_garrison_soldier_id(soldier_id: String) -> bool:
	var index := garrison_soldier_ids.find(soldier_id)
	if index < 0:
		return false
	garrison_soldier_ids.remove_at(index)
	return true
