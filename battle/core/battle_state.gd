class_name BattleState
extends RefCounted

const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleTacticalForce := preload("res://battle/core/battle_tactical_force.gd")
const BattleForceCommandCatalog := preload("res://battle/core/battle_force_command_catalog.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCombatRandom := preload("res://battle/combat/battle_combat_random.gd")
const BattleCombatPressureSnapshot := preload("res://battle/combat/battle_combat_pressure_snapshot.gd")
const BattleVictoryResult := preload("res://battle/core/battle_victory_result.gd")
const BattleCampaignSource := preload("res://battle/core/battle_campaign_source.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")
const BattleNavigationGraph := preload("res://battle/navigation/battle_navigation_graph.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")

const COMBAT_FEEDBACK_HISTORY_LIMIT := 12

var battle_id: String = ""
var battle_type_id: String = ""
var mission_id: String = ""
var location_id: String = ""
var attacker_side_id: String = ""
var defender_side_id: String = ""
var campaign_source: BattleCampaignSource = null
var sides: Dictionary[String, BattleSide] = {}
var participants: Dictionary[String, BattleParticipant] = {}
var vehicles: Dictionary[String, BattleVehicle] = {}
var tactical_forces: Dictionary[String, BattleTacticalForce] = {}
var deployment_zones: Dictionary[String, DeploymentZone] = {}
var battle_phase: String = "deployment"
var elapsed_time_seconds: float = 0.0
var battlefield_geometry: BattlefieldGeometry = null
var combat_rng_seed: int = 1
var combat_random: BattleCombatRandom = null
var combat_pressure_snapshots: Dictionary[String, BattleCombatPressureSnapshot] = {}
var tactical_result: BattleVictoryResult = null
var requires_deployment_commitments: bool = false
var combat_feedback_events: Array[BattleAttackEvent] = []
var combat_feedback_next_sequence: int = 1
# Per-tick LOS cache. Cleared at the start of each BattleRuntimeService.advance()
# and whenever authored geometry content_revision changes.
# Key: Vector4(from.x, from.y, to.x, to.y) — exact float equality.
# Value: Dictionary {has_los: bool, blocking_obstacle_id: String}.
var _los_cache: Dictionary = {}
var _los_cache_stamp: String = ""
# Reachability cache. Independent of LOS. Invalidated when authored geometry
# or vehicle bodies change, not on every simulation tick.
# Key: Vector4(from.x, from.y, to.x, to.y) — exact float equality.
# Value: true = path exists, false = no path.
var _nav_cache: Dictionary = {}
var _nav_cache_stamp: String = ""
var _static_nav_graph: BattleNavigationGraph = null
var _static_nav_build_count: int = 0
# Cheap occupancy/reservation stamp. Bumped only when a slot becomes free.
var cover_occupancy_revision: int = 0


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


func apply_combat_seed(p_seed: int) -> void:
	# Battle-local LCG replace. Does not change battle_id or campaign identity.
	var seed_value: int = p_seed
	if seed_value == 0:
		seed_value = 1
	combat_rng_seed = seed_value
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


func get_combat_pressure_snapshot(participant_id: String) -> BattleCombatPressureSnapshot:
	if participant_id.is_empty() or not combat_pressure_snapshots.has(participant_id):
		return null
	return combat_pressure_snapshots[participant_id]


func has_combat_pressure_snapshot(participant_id: String) -> bool:
	if participant_id.is_empty():
		return false
	return combat_pressure_snapshots.has(participant_id)


func clear_los_cache() -> void:
	_los_cache.clear()
	_los_cache_stamp = _current_los_cache_stamp()


func los_cache_lookup(from_pos: Vector2, to_pos: Vector2) -> Variant:
	_sync_los_cache_stamp()
	var key: Vector4 = Vector4(from_pos.x, from_pos.y, to_pos.x, to_pos.y)
	if _los_cache.has(key):
		return _los_cache[key]
	return null


func los_cache_store(
	from_pos: Vector2,
	to_pos: Vector2,
	has_los: bool,
	blocking_obstacle_id: String = ""
) -> void:
	_sync_los_cache_stamp()
	var key: Vector4 = Vector4(from_pos.x, from_pos.y, to_pos.x, to_pos.y)
	_los_cache[key] = {
		"has_los": has_los,
		"blocking_obstacle_id": blocking_obstacle_id,
	}


func _current_los_cache_stamp() -> String:
	if battlefield_geometry == null:
		return "null"
	return "%s:%s" % [battlefield_geometry.get_instance_id(), battlefield_geometry.content_revision]


func _sync_los_cache_stamp() -> void:
	var stamp: String = _current_los_cache_stamp()
	if _los_cache_stamp == stamp:
		return
	_los_cache.clear()
	_los_cache_stamp = stamp


func nav_cache_lookup(from_pos: Vector2, to_pos: Vector2) -> int:
	_sync_nav_cache_stamp()
	var key: Vector4 = Vector4(from_pos.x, from_pos.y, to_pos.x, to_pos.y)
	if _nav_cache.has(key):
		return 1 if _nav_cache[key] else 0
	return -1


func nav_cache_store(from_pos: Vector2, to_pos: Vector2, reachable: bool) -> void:
	_sync_nav_cache_stamp()
	var key: Vector4 = Vector4(from_pos.x, from_pos.y, to_pos.x, to_pos.y)
	_nav_cache[key] = reachable


func _current_nav_cache_stamp() -> String:
	var parts: PackedStringArray = PackedStringArray()
	parts.append(_current_los_cache_stamp())
	var vehicle_ids: Array = vehicles.keys()
	vehicle_ids.sort()
	for vehicle_id: Variant in vehicle_ids:
		var vehicle: BattleVehicle = vehicles[str(vehicle_id)]
		if vehicle == null:
			continue
		if vehicle.has_battle_position:
			parts.append(
				"%s:%.5f:%.5f:%.5f:%.5f" % [
					vehicle.battle_vehicle_id,
					vehicle.battle_position.x,
					vehicle.battle_position.y,
					vehicle.facing_direction.x,
					vehicle.facing_direction.y,
				]
			)
		else:
			parts.append("%s:undeployed" % vehicle.battle_vehicle_id)
	return "|".join(parts)


func _sync_nav_cache_stamp() -> void:
	var stamp: String = _current_nav_cache_stamp()
	if _nav_cache_stamp == stamp:
		return
	_nav_cache.clear()
	_nav_cache_stamp = stamp


func navigation_topology_stamp() -> String:
	return _current_nav_cache_stamp()


func get_static_nav_graph() -> BattleNavigationGraph:
	return _static_nav_graph


func set_static_nav_graph(graph: BattleNavigationGraph) -> void:
	_static_nav_graph = graph


func get_static_nav_build_count() -> int:
	return _static_nav_build_count


func increment_static_nav_build_count() -> void:
	_static_nav_build_count += 1


func add_tactical_force(force: BattleTacticalForce) -> bool:
	if force == null:
		push_error("BattleState.add_tactical_force: force is null.")
		return false
	if force.tactical_force_id.is_empty():
		push_error("BattleState.add_tactical_force: tactical force id is empty.")
		return false
	if tactical_forces.has(force.tactical_force_id):
		push_error(
			"BattleState.add_tactical_force: duplicate tactical force id '%s'."
			% force.tactical_force_id
		)
		return false
	if force.command_id.is_empty():
		force.command_id = BattleForceCommandCatalog.DEFAULT_COMMAND
	if not BattleForceCommandCatalog.is_valid_command(force.command_id):
		push_error(
			"BattleState.add_tactical_force: invalid command id '%s' for tactical force '%s'."
			% [force.command_id, force.tactical_force_id]
		)
		return false
	tactical_forces[force.tactical_force_id] = force
	return true


func get_tactical_force(tactical_force_id: String) -> BattleTacticalForce:
	if tactical_forces.has(tactical_force_id):
		return tactical_forces[tactical_force_id]
	return null


func has_tactical_force(tactical_force_id: String) -> bool:
	return tactical_forces.has(tactical_force_id)


func is_resolved() -> bool:
	if battle_phase == "resolved":
		return true
	if tactical_result != null and tactical_result.resolved:
		return true
	return false


func get_tactical_result() -> BattleVictoryResult:
	return tactical_result


func get_winning_side_id() -> String:
	if tactical_result == null or not tactical_result.resolved:
		return ""
	return tactical_result.winning_side_id


func get_result_kind() -> String:
	if tactical_result == null or not tactical_result.resolved:
		return ""
	return tactical_result.result_kind


func record_combat_feedback_event(event: BattleAttackEvent) -> void:
	if event == null:
		return
	event.sequence_id = combat_feedback_next_sequence
	combat_feedback_next_sequence += 1
	if not is_finite(event.elapsed_time_seconds) or event.elapsed_time_seconds < 0.0:
		event.elapsed_time_seconds = elapsed_time_seconds
	combat_feedback_events.append(event)
	while combat_feedback_events.size() > COMBAT_FEEDBACK_HISTORY_LIMIT:
		combat_feedback_events.remove_at(0)


func get_sorted_side_ids() -> Array[String]:
	var ids: Array[String] = []
	for side_id: String in sides:
		ids.append(side_id)
	ids.sort()
	return ids


func get_sorted_tactical_force_ids() -> Array[String]:
	var ids: Array[String] = []
	for tactical_force_id: String in tactical_forces:
		ids.append(tactical_force_id)
	ids.sort()
	return ids


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
	if is_side_deployment_committed(participant.side_id):
		push_error("BattleState.deploy_participant: side '%s' deployment is already committed." % participant.side_id)
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
	# Vehicle deployment is part of side-commit eligibility. Commitment freezes undeployed vehicles.
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
	if is_side_deployment_committed(vehicle.side_id):
		push_error("BattleState.deploy_vehicle: side '%s' deployment is already committed." % vehicle.side_id)
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


func is_side_deployment_committed(side_id: String) -> bool:
	if side_id.is_empty() or not has_side(side_id):
		return false
	var side: BattleSide = get_side(side_id)
	if side == null:
		return false
	return side.deployment_committed


func get_side_deployment_commit_error(side_id: String) -> String:
	if battle_phase != "deployment":
		return "battle_not_in_deployment"
	if side_id.is_empty() or not has_side(side_id):
		return "unknown_side"
	var side: BattleSide = get_side(side_id)
	if side == null:
		return "unknown_side"
	if side.deployment_zone_id.is_empty() or not has_deployment_zone(side.deployment_zone_id):
		return "missing_deployment_zone"
	if side.deployment_committed:
		return "already_committed"
	var living_count: int = 0
	for participant_id: String in side.participant_ids:
		var participant: BattleParticipant = get_participant(participant_id)
		if participant == null:
			return "unknown_participant"
		if not participant.is_alive:
			continue
		living_count += 1
		if not is_participant_deployed(participant_id):
			return "undeployed_living_participant"
		if not participant.has_battle_position:
			return "missing_battle_position"
		if not is_participant_fully_deployed(participant_id):
			return "invalid_position"
	if living_count <= 0:
		return "no_living_participants"
	for vehicle_id: String in side.vehicle_ids:
		var vehicle: BattleVehicle = get_vehicle(vehicle_id)
		if vehicle == null:
			return "unknown_vehicle"
		if not is_vehicle_fully_deployed(vehicle_id):
			if not is_vehicle_deployed(vehicle_id):
				return "undeployed_vehicle"
			if not vehicle.has_battle_position:
				return "missing_vehicle_position"
			return "invalid_vehicle_pose"
	return ""


func commit_side_deployment(side_id: String) -> bool:
	var error_code: String = get_side_deployment_commit_error(side_id)
	if not error_code.is_empty():
		push_error("BattleState.commit_side_deployment: %s." % error_code)
		return false
	var side: BattleSide = get_side(side_id)
	side.deployment_committed = true
	return true


func get_deployment_position_error(side_id: String, position: Vector2) -> String:
	if not BattlefieldGeometry.is_finite_point(position):
		return "invalid_position"
	if battlefield_geometry == null or not battlefield_geometry.is_valid():
		return "missing_battlefield_geometry"
	if not battlefield_geometry.contains_point(position):
		return "outside_battlefield"
	if side_id == attacker_side_id:
		if not battlefield_geometry.attacker_deployment_contains(position):
			return "outside_deployment_zone"
	elif side_id == defender_side_id:
		if not battlefield_geometry.defender_deployment_contains(position):
			return "outside_deployment_zone"
	else:
		return "unknown_side"
	var blocking_id: String = battlefield_geometry.get_movement_blocking_obstacle_id_at(position)
	if not blocking_id.is_empty():
		return "inside_blocking_obstacle"
	var blocking_vehicle_id: String = BattleVehicleBodyService.blocking_vehicle_id_at(self, position)
	if not blocking_vehicle_id.is_empty():
		return "inside_vehicle_body"
	return ""


func is_legal_deployment_position(side_id: String, position: Vector2) -> bool:
	return get_deployment_position_error(side_id, position).is_empty()


func is_vehicle_fully_deployed(vehicle_id: String) -> bool:
	if not has_vehicle(vehicle_id):
		return false
	var vehicle: BattleVehicle = get_vehicle(vehicle_id)
	if vehicle == null:
		return false
	if not _vehicle_assignment_is_valid(vehicle_id, vehicle.side_id):
		return false
	if not vehicle.has_battle_position:
		return false
	if not vehicle.has_valid_orientation():
		return false
	return BattleVehicleBodyService.get_placement_error(
		self,
		vehicle_id,
		vehicle.battle_position,
		vehicle.facing_direction
	).is_empty()


func is_participant_fully_deployed(participant_id: String) -> bool:
	if not has_participant(participant_id):
		return false
	var participant: BattleParticipant = get_participant(participant_id)
	if participant == null:
		return false
	if not _participant_assignment_is_valid(participant_id, participant.side_id):
		return false
	if not participant.has_battle_position:
		return false
	return is_legal_deployment_position(participant.side_id, participant.battle_position)


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
	if requires_deployment_commitments:
		if not is_side_deployment_committed(attacker_side_id):
			return false
		if not is_side_deployment_committed(defender_side_id):
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
	combat_pressure_snapshots.clear()
	_initialize_defender_posture()
	BattleNavigationService.prewarm(self)
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
		if expected_side_id == attacker_side_id:
			if not battlefield_geometry.attacker_deployment_contains(participant.battle_position):
				return false
		elif expected_side_id == defender_side_id:
			if not battlefield_geometry.defender_deployment_contains(participant.battle_position):
				return false
		else:
			return false
	for vehicle_id: String in zone.deployed_vehicle_ids:
		if not has_vehicle(vehicle_id):
			return false
		var vehicle: BattleVehicle = get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			return false
		if not vehicle.has_valid_orientation():
			return false
		if not is_finite(vehicle.battle_position.x) or not is_finite(vehicle.battle_position.y):
			return false
		if vehicle.deployment_slot_id != zone.zone_id:
			return false
		if BattleVehicleBodyService.get_placement_error(
			self,
			vehicle_id,
			vehicle.battle_position,
			vehicle.facing_direction
		) != "":
			return false
		if expected_side_id == attacker_side_id:
			if not battlefield_geometry.attacker_deployment_contains(vehicle.battle_position):
				return false
		elif expected_side_id == defender_side_id:
			if not battlefield_geometry.defender_deployment_contains(vehicle.battle_position):
				return false
		else:
			return false
	return true
