class_name GameState
extends RefCounted

var current_turn: int = 1
var current_year: int = 2034
var current_month: int = 7
var factions: Dictionary[String, Faction] = {}


func add_faction(faction: Faction) -> void:
	factions[faction.id] = faction


func get_faction(faction_id: String) -> Faction:
	if factions.has(faction_id):
		return factions[faction_id]
	return null


func has_faction(faction_id: String) -> bool:
	return factions.has(faction_id)


func to_dict() -> Dictionary:
	var faction_data := {}
	for faction_id: String in factions:
		faction_data[faction_id] = factions[faction_id].to_dict()
	return {
		"current_turn": current_turn,
		"current_year": current_year,
		"current_month": current_month,
		"factions": faction_data,
	}


func from_dict(data: Dictionary) -> void:
	current_turn = int(data.get("current_turn", 1))
	current_year = int(data.get("current_year", 2034))
	current_month = int(data.get("current_month", 7))
	factions.clear()
	var faction_data: Variant = data.get("factions", {})
	if not (faction_data is Dictionary):
		return
	for faction_id: Variant in faction_data:
		var record: Variant = faction_data[faction_id]
		if not (record is Dictionary):
			continue
		var faction := _create_faction_from_dict(record)
		if faction == null:
			continue
		if faction.id.is_empty():
			faction.id = str(faction_id)
		add_faction(faction)


func _create_faction_from_dict(data: Dictionary) -> Faction:
	var type_id := str(data.get("faction_type", ""))
	var faction: Faction
	match type_id:
		"major_gang":
			faction = MajorGang.new()
		_:
			push_error("GameState: unrecognized faction_type '%s' (id='%s'); skipping faction record." % [type_id, str(data.get("id", ""))])
			return null
	faction.from_dict(data)
	return faction
