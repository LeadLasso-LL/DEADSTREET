class_name BattleVehiclePhysicalCatalog
extends RefCounted

const BattleVehiclePhysicalProfile := preload("res://battle/vehicles/battle_vehicle_physical_profile.gd")

const TYPE_CAR := "car"
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")

# Match the authored curb sedans; the same body drives art, navigation and cover.
const CAR_LENGTH := 5.15 * Models.TACTICAL_SCALE
const CAR_WIDTH := 2.1 * Models.TACTICAL_SCALE


static func get_profile(vehicle_type_id: String) -> BattleVehiclePhysicalProfile:
	var profile: BattleVehiclePhysicalProfile = _make_profile(vehicle_type_id)
	if profile == null or not profile.is_valid():
		return null
	return profile


static func has_profile(vehicle_type_id: String) -> bool:
	return get_profile(vehicle_type_id) != null


static func _make_profile(vehicle_type_id: String) -> BattleVehiclePhysicalProfile:
	if Models.has_model(vehicle_type_id):
		var m=Models.model(vehicle_type_id)
		return BattleVehiclePhysicalProfile.new(vehicle_type_id,float(m.length)*Models.TACTICAL_SCALE,float(m.width)*Models.TACTICAL_SCALE)
	match vehicle_type_id:
		TYPE_CAR:
			return BattleVehiclePhysicalProfile.new(TYPE_CAR, CAR_LENGTH, CAR_WIDTH)
		_:
			# Provisional default so unknown campaign types still have a body.
			# Not a second type catalog or a design lock.
			if vehicle_type_id.is_empty():
				return null
			return BattleVehiclePhysicalProfile.new(vehicle_type_id, CAR_LENGTH, CAR_WIDTH)

# Internal collision queries reuse profiles. Public get_profile still returns
# an independent object. Authored model dimension edits are observed immediately.
static var _collision_profiles: Dictionary = {}

static func _get_collision_profile(vehicle_type_id: String) -> BattleVehiclePhysicalProfile:
	if vehicle_type_id.is_empty():
		return null
	var length: float = CAR_LENGTH
	var width: float = CAR_WIDTH
	if Models.has_model(vehicle_type_id):
		var model: Dictionary = Models.model(vehicle_type_id)
		length = float(model.length)*Models.TACTICAL_SCALE
		width = float(model.width)*Models.TACTICAL_SCALE
	if not is_finite(length) or not is_finite(width) or length <= 0.0 or width <= 0.0:
		return null
	var cached: BattleVehiclePhysicalProfile = _collision_profiles.get(vehicle_type_id)
	if cached != null and cached.vehicle_type_id == vehicle_type_id and cached.length == length and cached.width == width:
		return cached
	var profile := BattleVehiclePhysicalProfile.new(vehicle_type_id, length, width)
	if _collision_profiles.size() >= 128:
		_collision_profiles.clear()
	_collision_profiles[vehicle_type_id] = profile
	return profile
