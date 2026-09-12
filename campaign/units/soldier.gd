class_name Soldier
extends RefCounted

var id: String = ""
var faction_id: String = ""
var home_stronghold_id: String = ""
var garrison_hq_id: String = ""
var weapon_type_id: String = ""
var unit_tier: int = 1:
	set(value):
		unit_tier = clampi(value, 1, 3)
var specialist_id: String = ""
var strategic_strength: float = 0.0:
	set(value):
		strategic_strength = maxf(value, 0.0)
var upkeep_per_turn: float = 0.0:
	set(value):
		upkeep_per_turn = maxf(value, 0.0)


func _init(
	p_id: String = "",
	p_faction_id: String = "",
	p_home_stronghold_id: String = "",
	p_weapon_type_id: String = "",
	p_strategic_strength: float = 0.0,
	p_upkeep_per_turn: float = 0.0,
	p_garrison_hq_id: String = ""
) -> void:
	id = p_id
	faction_id = p_faction_id
	home_stronghold_id = p_home_stronghold_id
	weapon_type_id = p_weapon_type_id
	strategic_strength = p_strategic_strength
	upkeep_per_turn = p_upkeep_per_turn
	garrison_hq_id = p_garrison_hq_id


func to_dict() -> Dictionary:
	return {
		"id": id,
		"faction_id": faction_id,
		"home_stronghold_id": home_stronghold_id,
		"garrison_hq_id": garrison_hq_id,
		"weapon_type_id": weapon_type_id,
		"specialist_id": specialist_id,
		"unit_tier": unit_tier,
		"strategic_strength": strategic_strength,
		"upkeep_per_turn": upkeep_per_turn,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	faction_id = str(data.get("faction_id", ""))
	home_stronghold_id = str(data.get("home_stronghold_id", ""))
	garrison_hq_id = str(data.get("garrison_hq_id", ""))
	weapon_type_id = str(data.get("weapon_type_id", ""))
	specialist_id = str(data.get("specialist_id", ""))
	unit_tier = int(data.get("unit_tier", 1))
	strategic_strength = float(data.get("strategic_strength", 0.0))
	upkeep_per_turn = float(data.get("upkeep_per_turn", 0.0))
