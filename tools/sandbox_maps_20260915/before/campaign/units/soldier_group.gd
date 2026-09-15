class_name SoldierGroup
extends RefCounted

var soldier_ids: Array[String] = []


func to_dict() -> Dictionary:
	var ids: Array[String] = []
	for soldier_id in soldier_ids:
		ids.append(soldier_id)
	return {
		"soldier_ids": ids,
	}


func from_dict(data: Dictionary) -> void:
	soldier_ids.clear()
	var ids_data: Variant = data.get("soldier_ids", [])
	if not (ids_data is Array):
		return
	for soldier_id: Variant in ids_data:
		add_soldier_id(str(soldier_id))


func add_soldier_id(soldier_id: String) -> bool:
	if soldier_id.is_empty():
		push_error("SoldierGroup.add_soldier_id: soldier id is empty.")
		return false
	if soldier_ids.has(soldier_id):
		push_error("SoldierGroup.add_soldier_id: duplicate soldier id '%s'." % soldier_id)
		return false
	soldier_ids.append(soldier_id)
	return true


func remove_soldier_id(soldier_id: String) -> bool:
	var index := soldier_ids.find(soldier_id)
	if index < 0:
		return false
	soldier_ids.remove_at(index)
	return true


func has_soldier_id(soldier_id: String) -> bool:
	return soldier_ids.has(soldier_id)


func get_total_strategic_strength(game_state: GameState) -> float:
	if game_state == null:
		push_error("SoldierGroup.get_total_strategic_strength: game_state is null.")
		return 0.0
	var total := 0.0
	for soldier_id in soldier_ids:
		var soldier: Soldier = game_state.get_soldier(soldier_id)
		if soldier == null:
			push_error("SoldierGroup.get_total_strategic_strength: missing soldier '%s'." % soldier_id)
			continue
		total += soldier.strategic_strength
	return total
