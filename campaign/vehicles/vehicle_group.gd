class_name VehicleGroup
extends RefCounted

var vehicle_ids: Array[String] = []


func to_dict() -> Dictionary:
	var ids: Array[String] = []
	for vehicle_id in vehicle_ids:
		ids.append(vehicle_id)
	return {
		"vehicle_ids": ids,
	}


func from_dict(data: Dictionary) -> void:
	vehicle_ids.clear()
	var ids_data: Variant = data.get("vehicle_ids", [])
	if not (ids_data is Array):
		return
	for vehicle_id: Variant in ids_data:
		add_vehicle_id(str(vehicle_id))


func add_vehicle_id(vehicle_id: String) -> bool:
	if vehicle_id.is_empty():
		push_error("VehicleGroup.add_vehicle_id: vehicle id is empty.")
		return false
	if vehicle_ids.has(vehicle_id):
		push_error("VehicleGroup.add_vehicle_id: duplicate vehicle id '%s'." % vehicle_id)
		return false
	vehicle_ids.append(vehicle_id)
	return true


func remove_vehicle_id(vehicle_id: String) -> bool:
	var index := vehicle_ids.find(vehicle_id)
	if index < 0:
		return false
	vehicle_ids.remove_at(index)
	return true


func has_vehicle_id(vehicle_id: String) -> bool:
	return vehicle_ids.has(vehicle_id)


func get_total_passenger_capacity(game_state: GameState) -> int:
	if game_state == null:
		push_error("VehicleGroup.get_total_passenger_capacity: game_state is null.")
		return 0
	var total := 0
	for vehicle_id in vehicle_ids:
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		if vehicle == null:
			push_error("VehicleGroup.get_total_passenger_capacity: missing vehicle '%s'." % vehicle_id)
			continue
		total += vehicle.passenger_capacity
	return total


func get_movement_per_turn(game_state: GameState) -> float:
	if game_state == null:
		push_error("VehicleGroup.get_movement_per_turn: game_state is null.")
		return 0.0
	var found := false
	var slowest := 0.0
	for vehicle_id in vehicle_ids:
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		if vehicle == null:
			push_error("VehicleGroup.get_movement_per_turn: missing vehicle '%s'." % vehicle_id)
			continue
		if not found or vehicle.movement_per_turn < slowest:
			slowest = vehicle.movement_per_turn
			found = true
	if not found:
		return 0.0
	return slowest
