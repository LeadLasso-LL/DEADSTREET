class_name FactionRelationship
extends RefCounted

const KEY_DELIMITER := "|"

var faction_a_id: String = ""
var faction_b_id: String = ""
var is_at_war: bool = false


func _init(
	p_faction_a_id: String = "",
	p_faction_b_id: String = "",
	p_is_at_war: bool = false
) -> void:
	_assign_canonical_pair(p_faction_a_id, p_faction_b_id)
	is_at_war = p_is_at_war


static func make_key(faction_one_id: String, faction_two_id: String) -> String:
	if faction_one_id.is_empty() or faction_two_id.is_empty():
		return ""
	if faction_one_id == faction_two_id:
		return ""
	if faction_one_id < faction_two_id:
		return "%s%s%s" % [faction_one_id, KEY_DELIMITER, faction_two_id]
	return "%s%s%s" % [faction_two_id, KEY_DELIMITER, faction_one_id]


func contains_faction(faction_id: String) -> bool:
	if faction_id.is_empty():
		return false
	return faction_id == faction_a_id or faction_id == faction_b_id


func get_other_faction_id(faction_id: String) -> String:
	if faction_id == faction_a_id:
		return faction_b_id
	if faction_id == faction_b_id:
		return faction_a_id
	return ""


func canonicalize() -> void:
	_assign_canonical_pair(faction_a_id, faction_b_id)


func to_dict() -> Dictionary:
	return {
		"faction_a_id": faction_a_id,
		"faction_b_id": faction_b_id,
		"is_at_war": is_at_war,
	}


func from_dict(data: Dictionary) -> void:
	_assign_canonical_pair(
		str(data.get("faction_a_id", "")),
		str(data.get("faction_b_id", ""))
	)
	is_at_war = bool(data.get("is_at_war", false))


func _assign_canonical_pair(faction_one_id: String, faction_two_id: String) -> void:
	if faction_one_id.is_empty() or faction_two_id.is_empty() or faction_one_id == faction_two_id:
		faction_a_id = ""
		faction_b_id = ""
		return
	if faction_one_id < faction_two_id:
		faction_a_id = faction_one_id
		faction_b_id = faction_two_id
		return
	faction_a_id = faction_two_id
	faction_b_id = faction_one_id
