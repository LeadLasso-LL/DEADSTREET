class_name NeighborhoodHQ
extends Building


func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_neighborhood_id: String = "",
	p_map_position: Vector2 = Vector2.ZERO,
	p_owner_faction_id: String = "",
	p_is_open: bool = true
) -> void:
	super(p_id, p_display_name, "neighborhood_hq", p_neighborhood_id, p_map_position, p_owner_faction_id, p_is_open)


func to_dict() -> Dictionary:
	return super.to_dict()


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	location_type = "neighborhood_hq"
