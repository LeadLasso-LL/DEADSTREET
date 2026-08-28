class_name BattleParticipant
extends RefCounted

var participant_id: String = ""
var campaign_soldier_id: String = ""
var faction_id: String = ""
var side_id: String = ""
var weapon_type: String = ""
var is_alive: bool = true
var is_wounded: bool = false
var deployment_slot_id: String = ""


func _init(
	p_participant_id: String = "",
	p_campaign_soldier_id: String = "",
	p_faction_id: String = "",
	p_side_id: String = "",
	p_weapon_type: String = "",
	p_is_alive: bool = true,
	p_is_wounded: bool = false,
	p_deployment_slot_id: String = ""
) -> void:
	participant_id = p_participant_id
	campaign_soldier_id = p_campaign_soldier_id
	faction_id = p_faction_id
	side_id = p_side_id
	weapon_type = p_weapon_type
	is_alive = p_is_alive
	is_wounded = p_is_wounded
	deployment_slot_id = p_deployment_slot_id
