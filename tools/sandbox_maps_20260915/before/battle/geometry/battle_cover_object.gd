class_name BattleCoverObject
extends RefCounted

# Logical grouping of authored cover slots. Not collision or LOS geometry.
var cover_object_id: String = ""
var slot_ids: Array[String] = []
var associated_obstacle_id: String = ""


func _init(p_cover_object_id: String = "", p_associated_obstacle_id: String = "") -> void:
	cover_object_id = p_cover_object_id
	associated_obstacle_id = p_associated_obstacle_id


func is_valid() -> bool:
	return not cover_object_id.is_empty()
