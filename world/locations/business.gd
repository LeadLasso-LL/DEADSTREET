class_name Business
extends Building

var business_type_id: String = ""
var level: int = 1:
	set(value):
		level = maxi(value, 1)


func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_neighborhood_id: String = "",
	p_map_position: Vector2 = Vector2.ZERO,
	p_owner_faction_id: String = "",
	p_is_open: bool = true,
	p_business_type_id: String = "",
	p_level: int = 1
) -> void:
	super(p_id, p_display_name, "business", p_neighborhood_id, p_map_position, p_owner_faction_id, p_is_open)
	business_type_id = p_business_type_id
	level = p_level


func to_dict() -> Dictionary:
	var data := super.to_dict()
	data["business_type_id"] = business_type_id
	data["level"] = level
	return data


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	location_type = "business"
	business_type_id = str(data.get("business_type_id", ""))
	level = int(data.get("level", 1))
