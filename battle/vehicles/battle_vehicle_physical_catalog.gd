class_name BattleVehiclePhysicalCatalog
extends RefCounted

const BattleVehiclePhysicalProfile := preload("res://battle/vehicles/battle_vehicle_physical_profile.gd")

const TYPE_CAR := "car"

# Match the authored curb sedans; the same body drives art, navigation and cover.
const CAR_LENGTH := 5.15
const CAR_WIDTH := 2.1


static func get_profile(vehicle_type_id: String) -> BattleVehiclePhysicalProfile:
	var profile: BattleVehiclePhysicalProfile = _make_profile(vehicle_type_id)
	if profile == null or not profile.is_valid():
		return null
	return profile


static func has_profile(vehicle_type_id: String) -> bool:
	return get_profile(vehicle_type_id) != null


static func _make_profile(vehicle_type_id: String) -> BattleVehiclePhysicalProfile:
	match vehicle_type_id:
		TYPE_CAR:
			return BattleVehiclePhysicalProfile.new(TYPE_CAR, CAR_LENGTH, CAR_WIDTH)
		_:
			# Provisional default so unknown campaign types still have a body.
			# Not a second type catalog or a design lock.
			if vehicle_type_id.is_empty():
				return null
			return BattleVehiclePhysicalProfile.new(vehicle_type_id, CAR_LENGTH, CAR_WIDTH)
