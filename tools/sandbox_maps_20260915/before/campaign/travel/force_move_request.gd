class_name ForceMoveRequest
extends RefCounted

var force_id: String = ""
var destination_location_id: String = ""


func _init(p_force_id: String = "", p_destination_location_id: String = "") -> void:
	force_id = p_force_id
	destination_location_id = p_destination_location_id
