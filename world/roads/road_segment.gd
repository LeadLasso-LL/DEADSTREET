class_name RoadSegment
extends RefCounted

var id: String = ""
var node_a_id: String = ""
var node_b_id: String = ""
var distance: float = 0.0:
	set(value):
		distance = maxf(value, 0.0)
var is_open: bool = true


func _init(
	p_id: String = "",
	p_node_a_id: String = "",
	p_node_b_id: String = "",
	p_distance: float = 0.0,
	p_is_open: bool = true
) -> void:
	id = p_id
	node_a_id = p_node_a_id
	node_b_id = p_node_b_id
	distance = p_distance
	is_open = p_is_open


func to_dict() -> Dictionary:
	return {
		"id": id,
		"node_a_id": node_a_id,
		"node_b_id": node_b_id,
		"distance": distance,
		"is_open": is_open,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	node_a_id = str(data.get("node_a_id", ""))
	node_b_id = str(data.get("node_b_id", ""))
	distance = float(data.get("distance", 0.0))
	is_open = bool(data.get("is_open", true))
