class_name BattleState
extends RefCounted

const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")

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
