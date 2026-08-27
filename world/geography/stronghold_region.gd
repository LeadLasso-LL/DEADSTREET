class_name StrongholdRegion
extends RefCounted

var id: String = ""
var display_name: String = ""


func _init(p_id: String = "", p_display_name: String = "") -> void:
	id = p_id
	display_name = p_display_name


func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	display_name = str(data.get("display_name", ""))
