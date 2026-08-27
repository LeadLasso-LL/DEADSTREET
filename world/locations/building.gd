class_name Building
extends MapLocation

var owner_faction_id: String = ""
var is_open: bool = true


func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_location_type: String = "",
	p_neighborhood_id: String = "",
	p_map_position: Vector2 = Vector2.ZERO,
	p_owner_faction_id: String = "",
	p_is_open: bool = true
) -> void:
	super(p_id, p_display_name, p_location_type, p_neighborhood_id, p_map_position)
	owner_faction_id = p_owner_faction_id
	is_open = p_is_open


func to_dict() -> Dictionary:
	var data := super.to_dict()
	data["owner_faction_id"] = owner_faction_id
	data["is_open"] = is_open
	return data


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	owner_faction_id = str(data.get("owner_faction_id", ""))
	is_open = bool(data.get("is_open", true))
