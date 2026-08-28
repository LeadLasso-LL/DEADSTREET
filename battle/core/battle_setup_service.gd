class_name BattleSetupService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattleSetupResult := preload("res://battle/core/battle_setup_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")

const SIDE_ATTACKER := "attacker"
const SIDE_DEFENDER := "defender"
const ZONE_ATTACKER := "attacker_deployment"
const ZONE_DEFENDER := "defender_deployment"
const BATTLE_TYPE_HQ_ASSAULT := "neighborhood_hq_assault"
const MISSION_TYPE_CAPTURE_HQ := "capture_neighborhood_hq"


static func create_neighborhood_hq_battle(game_state: GameState, mission_id: String) -> BattleSetupResult:
	if game_state == null:
		return BattleSetupResult.failed(
			"null_game_state",
			"Battle setup failed: game_state is null."
		)
	if mission_id.is_empty():
		return BattleSetupResult.failed(
			"empty_mission_id",
			"Battle setup failed: mission_id is empty."
		)
	if not game_state.has_mission(mission_id):
		return BattleSetupResult.failed(
			"invalid_mission",
			"Battle setup failed: mission '%s' does not exist." % mission_id,
			mission_id
		)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission.mission_type_id != MISSION_TYPE_CAPTURE_HQ:
		return BattleSetupResult.failed(
			"invalid_mission_type",
			"Battle setup failed: mission '%s' type is '%s', not capture_neighborhood_hq."
			% [mission.id, mission.mission_type_id],
			mission.id
		)
	if mission.mission_state != "awaiting_resolution":
		return BattleSetupResult.failed(
			"mission_not_awaiting_resolution",
			"Battle setup failed: mission '%s' is '%s', not awaiting_resolution."
			% [mission.id, mission.mission_state],
			mission.id
		)
	if mission.force_id.is_empty() or not game_state.has_traveling_force(mission.force_id):
		return BattleSetupResult.failed(
			"invalid_attacker_force",
			"Battle setup failed: attacker force '%s' does not exist." % mission.force_id,
			mission.id
		)
	var force: TravelingForce = game_state.get_traveling_force(mission.force_id)
	if force.travel_state != "at_destination":
		return BattleSetupResult.failed(
			"attacker_not_at_destination",
			"Battle setup failed: attacker force '%s' is '%s', not at_destination."
			% [force.id, force.travel_state],
			mission.id
		)
	if force.faction_id != mission.faction_id:
		return BattleSetupResult.failed(
			"attacker_faction_mismatch",
			"Battle setup failed: force '%s' faction '%s' does not match mission faction '%s'."
			% [force.id, force.faction_id, mission.faction_id],
			mission.id
		)
	if mission.target_location_id.is_empty() or not game_state.has_map_location(mission.target_location_id):
		return BattleSetupResult.failed(
			"invalid_target_location",
			"Battle setup failed: target '%s' does not exist." % mission.target_location_id,
			mission.id
		)
	var target_location: MapLocation = game_state.get_map_location(mission.target_location_id)
	if not (target_location is NeighborhoodHQ):
		return BattleSetupResult.failed(
			"target_not_neighborhood_hq",
			"Battle setup failed: target '%s' is not a NeighborhoodHQ." % mission.target_location_id,
			mission.id
		)
	var hq: NeighborhoodHQ = target_location as NeighborhoodHQ
	if force.destination_location_id != mission.target_location_id:
		return BattleSetupResult.failed(
			"attacker_target_mismatch",
			"Battle setup failed: force '%s' destination '%s' does not match mission target '%s'."
			% [force.id, force.destination_location_id, mission.target_location_id],
			mission.id
		)
	if hq.neighborhood_id.is_empty():
		return BattleSetupResult.failed(
			"missing_neighborhood",
			"Battle setup failed: HQ '%s' has empty neighborhood_id." % hq.id,
			mission.id
		)
	if not game_state.has_neighborhood(hq.neighborhood_id):
		return BattleSetupResult.failed(
			"invalid_neighborhood",
			"Battle setup failed: neighborhood '%s' does not exist." % hq.neighborhood_id,
			mission.id
		)
	var neighborhood: Neighborhood = game_state.get_neighborhood(hq.neighborhood_id)
	if neighborhood.owner_faction_id != hq.owner_faction_id:
		return BattleSetupResult.failed(
			"territory_owner_mismatch",
			"Battle setup failed: neighborhood '%s' owner '%s' does not match HQ '%s' owner '%s'."
			% [neighborhood.id, neighborhood.owner_faction_id, hq.id, hq.owner_faction_id],
			mission.id
		)
	var defender_faction_id: String = neighborhood.owner_faction_id

	var attacker_soldier_ids: Array[String] = _sorted_copy(_soldier_ids_from_force(force))
	for soldier_id: String in attacker_soldier_ids:
		if soldier_id.is_empty() or not game_state.has_soldier(soldier_id):
			return BattleSetupResult.failed(
				"invalid_attacker_soldier",
				"Battle setup failed: attacker soldier '%s' does not exist." % soldier_id,
				mission.id
			)
		var soldier: Soldier = game_state.get_soldier(soldier_id)
		if soldier.faction_id != force.faction_id:
			return BattleSetupResult.failed(
				"attacker_soldier_faction_mismatch",
				"Battle setup failed: soldier '%s' faction '%s' does not match attacker '%s'."
				% [soldier.id, soldier.faction_id, force.faction_id],
				mission.id
			)

	var attacker_vehicle_ids: Array[String] = _sorted_copy(_vehicle_ids_from_force(force))
	for vehicle_id: String in attacker_vehicle_ids:
		if vehicle_id.is_empty() or not game_state.has_vehicle(vehicle_id):
			return BattleSetupResult.failed(
				"invalid_attacker_vehicle",
				"Battle setup failed: attacker vehicle '%s' does not exist." % vehicle_id,
				mission.id
			)
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		if vehicle.faction_id != force.faction_id:
			return BattleSetupResult.failed(
				"attacker_vehicle_faction_mismatch",
				"Battle setup failed: vehicle '%s' faction '%s' does not match attacker '%s'."
				% [vehicle.id, vehicle.faction_id, force.faction_id],
				mission.id
			)

	var battle_id: String = "battle_%s" % mission.id
	var battle_state: BattleState = BattleState.new(
		battle_id,
		BATTLE_TYPE_HQ_ASSAULT,
		mission.id,
		hq.id,
		SIDE_ATTACKER,
		SIDE_DEFENDER,
		"deployment"
	)
	var attacker_side: BattleSide = BattleSide.new(
		SIDE_ATTACKER,
		force.faction_id,
		force.id,
		true,
		ZONE_ATTACKER
	)
	var defender_side: BattleSide = BattleSide.new(
		SIDE_DEFENDER,
		defender_faction_id,
		"",
		false,
		ZONE_DEFENDER
	)
	if not battle_state.add_side(attacker_side) or not battle_state.add_side(defender_side):
		push_error("BattleSetupService.create_neighborhood_hq_battle: failed to add battle sides.")
		return BattleSetupResult.failed(
			"battle_insert_failed",
			"Battle setup failed: could not add battle sides.",
			mission.id,
			battle_id
		)

	for soldier_id: String in attacker_soldier_ids:
		var soldier: Soldier = game_state.get_soldier(soldier_id)
		var participant: BattleParticipant = BattleParticipant.new(
			soldier.id,
			soldier.id,
			soldier.faction_id,
			SIDE_ATTACKER,
			soldier.weapon_type_id,
			true,
			false,
			""
		)
		if not battle_state.add_participant(participant) or not attacker_side.add_participant_id(participant.participant_id):
			push_error(
				"BattleSetupService.create_neighborhood_hq_battle: failed to add participant '%s'."
				% soldier.id
			)
			return BattleSetupResult.failed(
				"battle_insert_failed",
				"Battle setup failed: could not add participant '%s'." % soldier.id,
				mission.id,
				battle_id
			)

	for vehicle_id: String in attacker_vehicle_ids:
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		var battle_vehicle: BattleVehicle = BattleVehicle.new(
			vehicle.id,
			vehicle.id,
			vehicle.faction_id,
			SIDE_ATTACKER,
			vehicle.vehicle_type_id,
			""
		)
		if not battle_state.add_vehicle(battle_vehicle) or not attacker_side.add_vehicle_id(battle_vehicle.battle_vehicle_id):
			push_error(
				"BattleSetupService.create_neighborhood_hq_battle: failed to add vehicle '%s'."
				% vehicle.id
			)
			return BattleSetupResult.failed(
				"battle_insert_failed",
				"Battle setup failed: could not add vehicle '%s'." % vehicle.id,
				mission.id,
				battle_id
			)

	var attacker_zone: DeploymentZone = DeploymentZone.new(ZONE_ATTACKER, SIDE_ATTACKER, "attacker_entry")
	_copy_ids_into(attacker_side.participant_ids, attacker_zone.allowed_participant_ids)
	_copy_ids_into(attacker_side.vehicle_ids, attacker_zone.allowed_vehicle_ids)
	var defender_zone: DeploymentZone = DeploymentZone.new(ZONE_DEFENDER, SIDE_DEFENDER, "defender_position")
	_copy_ids_into(defender_side.participant_ids, defender_zone.allowed_participant_ids)
	_copy_ids_into(defender_side.vehicle_ids, defender_zone.allowed_vehicle_ids)
	if not battle_state.add_deployment_zone(attacker_zone) or not battle_state.add_deployment_zone(defender_zone):
		push_error("BattleSetupService.create_neighborhood_hq_battle: failed to add deployment zones.")
		return BattleSetupResult.failed(
			"battle_insert_failed",
			"Battle setup failed: could not add deployment zones.",
			mission.id,
			battle_id
		)

	return BattleSetupResult.succeeded(battle_state)


static func _soldier_ids_from_force(force: TravelingForce) -> Array[String]:
	var ids: Array[String] = []
	if force == null or force.soldier_group == null:
		return ids
	for soldier_id: String in force.soldier_group.soldier_ids:
		ids.append(soldier_id)
	return ids


static func _vehicle_ids_from_force(force: TravelingForce) -> Array[String]:
	var ids: Array[String] = []
	if force == null or force.vehicle_group == null:
		return ids
	for vehicle_id: String in force.vehicle_group.vehicle_ids:
		ids.append(vehicle_id)
	return ids


static func _sorted_copy(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for item_id: String in source:
		copied.append(item_id)
	copied.sort()
	return copied


static func _copy_ids_into(source: Array[String], destination: Array[String]) -> void:
	destination.clear()
	for item_id: String in source:
		destination.append(item_id)
