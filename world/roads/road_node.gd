class_name RoadNode
extends RefCounted

var id: String = ""
var map_position: Vector2 = Vector2.ZERO


func _init(p_id: String = "", p_map_position: Vector2 = Vector2.ZERO) -> void:
	id = p_id
	map_position = p_map_position


func to_dict() -> Dictionary:
	return {
		"id": id,
		"map_position": {
			"x": map_position.x,
			"y": map_position.y,
		},
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	map_position = _vector2_from_save(data.get("map_position", {}))


func _vector2_from_save(data: Variant) -> Vector2:
	if not (data is Dictionary):
		return Vector2.ZERO
	var pos: Dictionary = data
	return Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))
