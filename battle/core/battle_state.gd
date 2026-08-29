class_name BattleState
extends RefCounted

const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCombatRandom := preload("res://battle/combat/battle_combat_random.gd")

var battle_id: String = ""
var battle_type_id: String = ""
var mission_id: String = ""
var location_id: String = ""
var attacker_side_id: String = ""
var defender_side_id: String = ""
var sides: Dictionary[String, BattleSide] = {}
var participants: Dictionary[String, BattleParticipant] = {}
var vehicles: Dictionary[String, BattleVehicle] = {}
var deployment_zones: Dictionary[String, DeploymentZone] = {}
var battle_phase: String = "deployment"
var elapsed_time_seconds: float = 0.0
var battlefield_geometry: BattlefieldGeometry = null
var combat_rng_seed: int = 1
var combat_random: BattleCombatRandom = null


func _init(
	p_battle_id: String = "",
	p_battle_type_id: String = "",
	p_mission_id: String = "",
	p_location_id: String = "",
	p_attacker_side_id: String = "",
	p_defender_side_id: String = "",
	p_battle_phase: String = "deployment"
) -> void:
	battle_id = p_battle_id
	battle_type_id = p_battle_type_id
	mission_id = p_mission_id
	location_id = p_location_id
	attacker_side_id = p_attacker_side_id
	defender_side_id = p_defender_side_id
	battle_phase = p_battle_phase
	combat_rng_seed = BattleCombatRandom.seed_from_string(p_battle_id)
	combat_random = BattleCombatRandom.new(combat_rng_seed)


func add_side(side: BattleSide) -> bool:
	if side == null:
		push_error("BattleState.add_side: side is null.")
		return false
	if side.side_id.is_empty():
		push_error("BattleState.add_side: side id is empty.")
		return false
	if sides.has(side.side_id):
		push_error("BattleState.add_side: duplicate side id '%s'." % side.side_id)
		return false
	sides[side.side_id] = side
	return true


func get_side(side_id: String) -> BattleSide:
	if sides.has(side_id):
		return sides[side_id]
	return null


func has_side(side_id: String) -> bool:
	return sides.has(side_id)


func add_participant(participant: BattleParticipant) -> bool:
	if participant == null:
		push_error("BattleState.add_participant: participant is null.")
		return false
	if participant.participant_id.is_empty():
		push_error("BattleState.add_participant: participant id is empty.")
		return false
	if participants.has(participant.participant_id):
		push_error("BattleState.add_participant: duplicate participant id '%s'." % participant.participant_id)
		return false
	participants[participant.participant_id] = participant
	return true


func get_participant(participant_id: String) -> BattleParticipant:
	if participants.has(participant_id):
		return participants[participant_id]
	return null


func has_participant(participant_id: String) -> bool:
	return participants.has(participant_id)


func add_vehicle(vehicle: BattleVehicle) -> bool:
	if vehicle == null:
		push_error("BattleState.add_vehicle: vehicle is null.")
		return false
	if vehicle.battle_vehicle_id.is_empty():
		push_error("BattleState.add_vehicle: vehicle id is empty.")
		return false
	if vehicles.has(vehicle.battle_vehicle_id):
		push_error("BattleState.add_vehicle: duplicate vehicle id '%s'." % vehicle.battle_vehicle_id)
		return false
	vehicles[vehicle.battle_vehicle_id] = vehicle
	return true


func get_vehicle(vehicle_id: String) -> BattleVehicle:
	if vehicles.has(vehicle_id):
		return vehicles[vehicle_id]
	return null


func has_vehicle(vehicle_id: String) -> bool:
	return vehicles.has(vehicle_id)


func add_deployment_zone(zone: DeploymentZone) -> bool:
	if zone == null:
		push_error("BattleState.add_deployment_zone: zone is null.")
		return false
	if zone.zone_id.is_empty():
		push_error("BattleState.add_deployment_zone: zone id is empty.")
		return false
	if deployment_zones.has(zone.zone_id):
		push_error("BattleState.add_deployment_zone: duplicate zone id '%s'." % zone.zone_id)
		return false
	deployment_zones[zone.zone_id] = zone
	return true


func get_deployment_zone(zone_id: String) -> DeploymentZone:
	if deployment_zones.has(zone_id):
		return deployment_zones[zone_id]
	return null


func has_deployment_zone(zone_id: String) -> bool:
	return deployment_zones.has(zone_id)


func deploy_participant(participant_id: String, zone_id: String) -> bool:
	if battle_phase != "deployment":
		push_error("BattleState.deploy_participant: battle phase is '%s', not deployment." % battle_phase)
		return false
	if participant_id.is_empty():
		push_error("BattleState.deploy_participant: participant id is empty.")
		return false
	if zone_id.is_empty():
		push_error("BattleState.deploy_participant: zone id is empty.")
		return false
	if not has_participant(participant_id):
		push_error("BattleState.deploy_participant: unknown participant id '%s'." % participant_id)
		return false
	if not has_deployment_zone(zone_id):
		push_error("BattleState.deploy_participant: unknown zone id '%s'." % zone_id)
		return false
	var participant: BattleParticipant = get_participant(participant_id)
	var zone: DeploymentZone = get_deployment_zone(zone_id)
	if not has_side(participant.side_id):
		push_error("BattleState.deploy_participant: participant '%s' side '%s' does not exist." % [participant_id, participant.side_id])
		return false
	var side: BattleSide = get_side(participant.side_id)
	if not side.has_participant_id(participant_id):
		push_error("BattleState.deploy_participant: participant '%s' is not registered on side '%s'." % [participant_id, side.side_id])
		return false
	if zone.side_id != participant.side_id:
		push_error("BattleState.deploy_participant: zone '%s' belongs to side '%s', not '%s'." % [zone_id, zone.side_id, participant.side_id])
		return false
	if not zone.allows_participant(participant_id):
		push_error("BattleState.deploy_participant: zone '%s' does not allow participant '%s'." % [zone_id, participant_id])
		return false
	if not participant.deployment_slot_id.is_empty() or zone.has_deployed_participant(participant_id):
		push_error("BattleState.deploy_participant: participant '%s' is already deployed." % participant_id)
		return false
	participant.deployment_slot_id = zone.zone_id
	zone.deployed_participant_ids.append(participant.participant_id)
	return true


func deploy_vehicle(vehicle_id: String, zone_id: String) -> bool:
	if battle_phase != "deployment":
		push_error("BattleState.deploy_vehicle: battle phase is '%s', not deployment." % battle_phase)
		return false
	if vehicle_id.is_empty():
		push_error("BattleState.deploy_vehicle: vehicle id is empty.")
		return false
	if zone_id.is_empty():
		push_error("BattleState.deploy_vehicle: zone id is empty.")
		return false
	if not has_vehicle(vehicle_id):
		push_error("BattleState.deploy_vehicle: unknown vehicle id '%s'." % vehicle_id)
		return false
	if not has_deployment_zone(zone_id):
		push_error("BattleState.deploy_vehicle: unknown zone id '%s'." % zone_id)
		return false
	var vehicle: BattleVehicle = get_vehicle(vehicle_id)
	var zone: DeploymentZone = get_deployment_zone(zone_id)
	if not has_side(vehicle.side_id):
		push_error("BattleState.deploy_vehicle: vehicle '%s' side '%s' does not exist." % [vehicle_id, vehicle.side_id])
		return false
	var side: BattleSide = get_side(vehicle.side_id)
	if not side.has_vehicle_id(vehicle_id):
		push_error("BattleState.deploy_vehicle: vehicle '%s' is not registered on side '%s'." % [vehicle_id, side.side_id])
		return false
	if zone.side_id != vehicle.side_id:
		push_error("BattleState.deploy_vehicle: zone '%s' belongs to side '%s', not '%s'." % [zone_id, zone.side_id, vehicle.side_id])
		return false
	if not zone.allows_vehicle(vehicle_id):
		push_error("BattleState.deploy_vehicle: zone '%s' does not allow vehicle '%s'." % [zone_id, vehicle_id])
		return false
	if not vehicle.deployment_slot_id.is_empty() or zone.has_deployed_vehicle(vehicle_id):
		push_error("BattleState.deploy_vehicle: vehicle '%s' is already deployed." % vehicle_id)
		return false
	vehicle.deployment_slot_id = zone.zone_id
	zone.deployed_vehicle_ids.append(vehicle.battle_vehicle_id)
	return true


func is_participant_deployed(participant_id: String) -> bool:
	if not has_participant(participant_id):
		return false
	var participant: BattleParticipant = get_participant(participant_id)
	return not participant.deployment_slot_id.is_empty()


func is_vehicle_deployed(vehicle_id: String) -> bool:
	if not has_vehicle(vehicle_id):
		return false
	var vehicle: BattleVehicle = get_vehicle(vehicle_id)
	return not vehicle.deployment_slot_id.is_empty()


func get_participant_deployment_zone_id(participant_id: String) -> String:
	if not has_participant(participant_id):
		return ""
	var participant: BattleParticipant = get_participant(participant_id)
	return participant.deployment_slot_id


func get_vehicle_deployment_zone_id(vehicle_id: String) -> String:
	if not has_vehicle(vehicle_id):
		return ""
	var vehicle: BattleVehicle = get_vehicle(vehicle_id)
	return vehicle.deployment_slot_id


func get_zone_deployed_participant_ids(zone_id: String) -> Array[String]:
	var ids: Array[String] = []
	if not has_deployment_zone(zone_id):
		return ids
	var zone: DeploymentZone = get_deployment_zone(zone_id)
	for participant_id: String in zone.deployed_participant_ids:
		ids.append(participant_id)
	return ids


func get_zone_deployed_vehicle_ids(zone_id: String) -> Array[String]:
	var ids: Array[String] = []
	if not has_deployment_zone(zone_id):
		return ids
	var zone: DeploymentZone = get_deployment_zone(zone_id)
	for vehicle_id: String in zone.deployed_vehicle_ids:
		ids.append(vehicle_id)
	return ids


func is_side_ready(side_id: String) -> bool:
	if side_id.is_empty() or not has_side(side_id):
		return false
	var side: BattleSide = get_side(side_id)
	for participant_id: String in side.participant_ids:
		if not _participant_assignment_is_valid(participant_id, side.side_id):
			return false
	for vehicle_id: String in side.vehicle_ids:
		if not _vehicle_assignment_is_valid(vehicle_id, side.side_id):
			return false
	return true


func is_battle_ready() -> bool:
	if attacker_side_id.is_empty() or defender_side_id.is_empty():
		return false
	if not has_side(attacker_side_id) or not has_side(defender_side_id):
		return false
	if not is_side_ready(attacker_side_id):
		return false
	if not is_side_ready(defender_side_id):
		return false
	return true


func is_spatially_ready() -> bool:
	if battlefield_geometry == null or not battlefield_geometry.is_valid():
		return false
	if attacker_side_id.is_empty() or defender_side_id.is_empty():
		return false
	if not has_side(attacker_side_id) or not has_side(defender_side_id):
		return false
	var attacker_side: BattleSide = get_side(attacker_side_id)
	var defender_side: BattleSide = get_side(defender_side_id)
	if attacker_side == null or defender_side == null:
		return false
	if not _zone_is_spatially_ready(
		attacker_side.deployment_zone_id,
		attacker_side_id,
		battlefield_geometry.attacker_deployment_rect
	):
		return false
	if not _zone_is_spatially_ready(
		defender_side.deployment_zone_id,
		defender_side_id,
		battlefield_geometry.defender_deployment_rect
	):
		return false
	return true


func begin_battle() -> bool:
	if battle_phase != "deployment":
		push_error("BattleState.begin_battle: battle phase is '%s', not deployment." % battle_phase)
		return false
	if not is_battle_ready():
		push_error("BattleState.begin_battle: battle is not ready.")
		return false
	if not is_spatially_ready():
		push_error("BattleState.begin_battle: battlefield is not spatially ready.")
		return false
	battle_phase = "active"
	_initialize_defender_posture()
	return true


func _initialize_defender_posture() -> void:
	if defender_side_id.is_empty() or not has_side(defender_side_id):
		return
	var defender_side: BattleSide = get_side(defender_side_id)
	if defender_side == null:
		return
	for participant_id: String in defender_side.participant_ids:
		var participant: BattleParticipant = get_participant(participant_id)
		if participant == null:
			continue
		if not participant.has_battle_position:
			continue
		if not is_finite(participant.battle_position.x) or not is_finite(participant.battle_position.y):
			continue
		participant.set_defend_position_anchor(participant.battle_position)
		participant.set_defend_position(true)


func _participant_assignment_is_valid(participant_id: String, expected_side_id: String) -> bool:
	if participant_id.is_empty() or expected_side_id.is_empty():
		return false
	if not has_participant(participant_id):
		return false
	var participant: BattleParticipant = get_participant(participant_id)
	if participant.side_id != expected_side_id:
		return false
	if participant.deployment_slot_id.is_empty():
		return false
	if not has_deployment_zone(participant.deployment_slot_id):
		return false
	var zone: DeploymentZone = get_deployment_zone(participant.deployment_slot_id)
	if zone.side_id != expected_side_id:
		return false
	if not zone.allows_participant(participant_id):
		return false
	if not zone.has_deployed_participant(participant_id):
		return false
	return true


func _vehicle_assignment_is_valid(vehicle_id: String, expected_side_id: String) -> bool:
	if vehicle_id.is_empty() or expected_side_id.is_empty():
		return false
	if not has_vehicle(vehicle_id):
		return false
	var vehicle: BattleVehicle = get_vehicle(vehicle_id)
	if vehicle.side_id != expected_side_id:
		return false
	if vehicle.deployment_slot_id.is_empty():
		return false
	if not has_deployment_zone(vehicle.deployment_slot_id):
		return false
	var zone: DeploymentZone = get_deployment_zone(vehicle.deployment_slot_id)
	if zone.side_id != expected_side_id:
		return false
	if not zone.allows_vehicle(vehicle_id):
		return false
	if not zone.has_deployed_vehicle(vehicle_id):
		return false
	return true


func _zone_is_spatially_ready(
	zone_id: String,
	expected_side_id: String,
	expected_rect: Rect2
) -> bool:
	if zone_id.is_empty() or expected_side_id.is_empty():
		return false
	if not has_deployment_zone(zone_id):
		return false
	var zone: DeploymentZone = get_deployment_zone(zone_id)
	if zone == null or zone.side_id != expected_side_id:
		return false
	if not zone.deployment_rect.position.is_equal_approx(expected_rect.position):
		return false
	if not zone.deployment_rect.size.is_equal_approx(expected_rect.size):
		return false
	for participant_id: String in zone.deployed_participant_ids:
		if not has_participant(participant_id):
			return false
		var participant: BattleParticipant = get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			return false
		if not is_finite(participant.battle_position.x) or not is_finite(participant.battle_position.y):
			return false
		if participant.deployment_slot_id != zone.zone_id:
			return false
		if not BattlefieldGeometry.rect_contains_point(zone.deployment_rect, participant.battle_position):
			return false
	for vehicle_id: String in zone.deployed_vehicle_ids:
		if not has_vehicle(vehicle_id):
			return false
		var vehicle: BattleVehicle = get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			return false
		if not is_finite(vehicle.battle_position.x) or not is_finite(vehicle.battle_position.y):
			return false
		if vehicle.deployment_slot_id != zone.zone_id:
			return false
		if not BattlefieldGeometry.rect_contains_point(zone.deployment_rect, vehicle.battle_position):
			return false
	return true
