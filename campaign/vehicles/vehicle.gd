class_name Vehicle
extends RefCounted

var id: String = ""
var faction_id: String = ""
var vehicle_type_id: String = ""
var home_stronghold_id: String = ""
var passenger_capacity: int = 0:
	set(value):
		passenger_capacity = maxi(value, 0)
var movement_per_turn: float = 0.0:
	set(value):
		movement_per_turn = maxf(value, 0.0)
var upkeep_per_turn: float = 0.0:
	set(value):
		upkeep_per_turn = maxf(value, 0.0)


func _init(
	p_id: String = "",
	p_faction_id: String = "",
	p_vehicle_type_id: String = "",
	p_home_stronghold_id: String = "",
	p_passenger_capacity: int = 0,
	p_movement_per_turn: float = 0.0,
	p_upkeep_per_turn: float = 0.0
) -> void:
	id = p_id
	faction_id = p_faction_id
	vehicle_type_id = p_vehicle_type_id
	home_stronghold_id = p_home_stronghold_id
	passenger_capacity = p_passenger_capacity
	movement_per_turn = p_movement_per_turn
	upkeep_per_turn = p_upkeep_per_turn


func to_dict() -> Dictionary:
	return {
		"id": id,
		"faction_id": faction_id,
		"vehicle_type_id": vehicle_type_id,
		"home_stronghold_id": home_stronghold_id,
		"passenger_capacity": passenger_capacity,
		"movement_per_turn": movement_per_turn,
		"upkeep_per_turn": upkeep_per_turn,
	}


func from_dict(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	faction_id = str(data.get("faction_id", ""))
	vehicle_type_id = str(data.get("vehicle_type_id", ""))
	home_stronghold_id = str(data.get("home_stronghold_id", ""))
	passenger_capacity = int(data.get("passenger_capacity", 0))
	movement_per_turn = float(data.get("movement_per_turn", 0.0))
	upkeep_per_turn = float(data.get("upkeep_per_turn", 0.0))
