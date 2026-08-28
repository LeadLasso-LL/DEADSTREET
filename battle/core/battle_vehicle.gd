class_name BattleVehicle
extends RefCounted

var battle_vehicle_id: String = ""
var campaign_vehicle_id: String = ""
var faction_id: String = ""
var side_id: String = ""
var vehicle_type_id: String = ""
var deployment_slot_id: String = ""
var has_battle_position: bool = false
var battle_position: Vector2 = Vector2.ZERO


func _init(
	p_battle_vehicle_id: String = "",
	p_campaign_vehicle_id: String = "",
	p_faction_id: String = "",
	p_side_id: String = "",
	p_vehicle_type_id: String = "",
	p_deployment_slot_id: String = ""
) -> void:
	battle_vehicle_id = p_battle_vehicle_id
	campaign_vehicle_id = p_campaign_vehicle_id
	faction_id = p_faction_id
	side_id = p_side_id
	vehicle_type_id = p_vehicle_type_id
	deployment_slot_id = p_deployment_slot_id
