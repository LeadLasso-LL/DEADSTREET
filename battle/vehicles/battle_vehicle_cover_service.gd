class_name BattleVehicleCoverService
extends RefCounted

# Derives ordinary BattleCoverObject / BattleCoverSlot geometry from a parked
# vehicle body. Does not reserve, occupy, or assign soldiers.
# Door/open-state cover is not implemented; later appendage objects can use
# distinct ids without replacing body cover.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleVehiclePhysicalProfile := preload("res://battle/vehicles/battle_vehicle_physical_profile.gd")

const SLOT_FRONT := "front"
const SLOT_REAR := "rear"
const SLOT_LEFT := "left"
const SLOT_RIGHT := "right"
const BODY_COVER_SUFFIX := "__body_cover"
const COVER_STANDOFF := 0.40


static func body_cover_object_id(vehicle_id: String) -> String:
	if vehicle_id.is_empty():
		return ""
	return "%s%s" % [vehicle_id, BODY_COVER_SUFFIX]


static func body_cover_slot_id(vehicle_id: String, local_side: String) -> String:
	if vehicle_id.is_empty() or local_side.is_empty():
		return ""
	return "%s%s__%s" % [vehicle_id, BODY_COVER_SUFFIX, local_side]


static func collect_legal_body_slots(battle_state: BattleState, vehicle: BattleVehicle) -> Array[BattleCoverSlot]:
	var slots: Array[BattleCoverSlot] = []
	if battle_state == null or vehicle == null:
		return slots
	if not BattleVehicleBodyService.has_usable_pose(vehicle):
		return slots
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return slots
	var profile: BattleVehiclePhysicalProfile = BattleVehicleBodyService.profile_for_vehicle(vehicle)
	if profile == null:
		return slots
	var object_id: String = body_cover_object_id(vehicle.battle_vehicle_id)
	var facing: Vector2 = vehicle.facing_direction
	var right: Vector2 = Vector2(-facing.y, facing.x)
	var specs: Array[Dictionary] = [
		_slot_spec(vehicle, profile, SLOT_FRONT, facing, true),
		_slot_spec(vehicle, profile, SLOT_REAR, -facing, true),
		_slot_spec(vehicle, profile, SLOT_RIGHT, right, false),
		_slot_spec(vehicle, profile, SLOT_LEFT, -right, false),
	]
	for spec: Dictionary in specs:
		var slot: BattleCoverSlot = BattleCoverSlot.new(
			str(spec.get("id", "")),
			object_id,
			spec.get("position", Vector2.ZERO),
			spec.get("facing", Vector2.ZERO)
		)
		if not slot.is_valid():
			continue
		if not geometry.contains_point(slot.position):
			continue
		if not geometry.get_movement_blocking_obstacle_id_at(slot.position).is_empty():
			continue
		slots.append(slot)
	return slots


static func ensure_body_cover(battle_state: BattleState, vehicle_id: String) -> bool:
	if battle_state == null or vehicle_id.is_empty():
		return false
	if not battle_state.has_vehicle(vehicle_id):
		return false
	var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
	if not BattleVehicleBodyService.has_usable_pose(vehicle):
		return false
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null or not geometry.is_valid():
		return false
	var object_id: String = body_cover_object_id(vehicle_id)
	if geometry.has_cover_object(object_id):
		return true
	var cover_object: BattleCoverObject = BattleCoverObject.new(object_id, "")
	if not geometry.add_cover_object(cover_object):
		return false
	var profile: BattleVehiclePhysicalProfile = BattleVehicleBodyService.profile_for_vehicle(vehicle)
	if profile == null:
		return false
	var facing: Vector2 = vehicle.facing_direction
	var right: Vector2 = Vector2(-facing.y, facing.x)
	var specs: Array[Dictionary] = [
		_slot_spec(vehicle, profile, SLOT_FRONT, facing, true),
		_slot_spec(vehicle, profile, SLOT_REAR, -facing, true),
		_slot_spec(vehicle, profile, SLOT_RIGHT, right, false),
		_slot_spec(vehicle, profile, SLOT_LEFT, -right, false),
	]
	var added: int = 0
	for spec: Dictionary in specs:
		var slot: BattleCoverSlot = BattleCoverSlot.new(
			str(spec.get("id", "")),
			object_id,
			spec.get("position", Vector2.ZERO),
			spec.get("facing", Vector2.ZERO)
		)
		if not slot.is_valid():
			continue
		if not geometry.add_cover_slot(slot):
			continue
		added += 1
	if added <= 0:
		geometry.remove_cover_object(object_id)
		return false
	return true


static func _slot_spec(
	vehicle: BattleVehicle,
	profile: BattleVehiclePhysicalProfile,
	local_side: String,
	outward: Vector2,
	along_length: bool
) -> Dictionary:
	var extent: float = profile.half_width()
	if along_length:
		extent = profile.half_length()
	var local_offset: Vector2 = outward.normalized() * (extent + COVER_STANDOFF)
	return {
		"id": body_cover_slot_id(vehicle.battle_vehicle_id, local_side),
		"position": vehicle.battle_position + local_offset,
		"facing": outward.normalized(),
	}
