class_name Faction
extends RefCounted

var id: String = ""
var display_name: String = ""
var faction_type: String = ""


func _init(p_id: String = "", p_display_name: String = "", p_faction_type: String = "") -> void:
	id = p_id
	display_name = p_display_name
	faction_type = p_faction_type


func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"faction_type": faction_type,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	display_name = str(data.get("display_name", ""))
	faction_type = str(data.get("faction_type", ""))
