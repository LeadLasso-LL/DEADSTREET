class_name StarterWorldService
extends RefCounted

const DiplomacyService := preload("res://campaign/diplomacy/diplomacy_service.gd")

const PLAYER_FACTION_ID := "player_gang"
const RIVAL_FACTION_ID := "rival_gang"
const REGION_ID := "starter_region"
const DISTRICT_ID := "starter_district"
const HOOD_ID := "starter_hood"
const KEEP_ID := "player_keep"
const HQ_ID := "rival_hq"
const NODE_KEEP_ID := "node_keep"
const NODE_HQ_ID := "node_hq"
const SEGMENT_ID := "seg_keep_hq"
const SOLDIER_ID := "player_soldier"
const SOLDIER_SMG_ID := "player_soldier_smg"
const SOLDIER_SHOTGUN_ID := "player_soldier_shotgun"
const RIVAL_SOLDIER_ID := "rival_soldier"
const RIVAL_RIFLE_ID := "rival_soldier_rifle"
const RIVAL_SHOTGUN_ID := "rival_soldier_shotgun"
const VEHICLE_ID := "player_vehicle"
const DEBUG_MISSION_ID := "debug_hq_assault"
const DEBUG_FORCE_ID := "debug_hq_force"
# Provisional starter travel tuning so the debug HQ assault takes multiple campaign turns.
# Launch budget is min(debug request 10.0, vehicle movement 5.0) = 5.0.
# Distance 12.0 => launch 5.0, turn 1 => 10.0, turn 2 arrives. Vehicle movement unchanged.
const KEEP_MAP_POSITION := Vector2(0.0, 0.0)
const HQ_MAP_POSITION := Vector2(12.0, 0.0)
const SEGMENT_DISTANCE := 12.0
const VEHICLE_MOVEMENT_PER_TURN := 5.0
# Debug 3v3 starts. Legal west/east pocket points, not cover slots.
const ATTACKER_RIFLE_START := Vector2(7.25, 31.5)
const ATTACKER_SMG_START := Vector2(14.2, 21.8)
const ATTACKER_SHOTGUN_START := Vector2(13.5, 38.6)
const DEFENDER_PISTOL_START := Vector2(87.2, 22.0)
const DEFENDER_RIFLE_START := Vector2(94.0, 31.5)
const DEFENDER_SHOTGUN_START := Vector2(85.5, 34.8)
const DEBUG_CAR_PASSENGER_CAPACITY := 4


static func create() -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 1
	state.current_month = 7
	state.current_year = 2034

	var player: MajorGang = MajorGang.new(PLAYER_FACTION_ID, "Player Gang", "player")
	player.money = 1000.0
	player.resources.set_amount("Ammo", 4.0)
	var rival: MajorGang = MajorGang.new(RIVAL_FACTION_ID, "Rival Gang", "ai")
	rival.money = 1000.0
	state.add_faction(player)
	state.add_faction(rival)

	state.add_stronghold_region(StrongholdRegion.new(REGION_ID, "Starter Region"))
	state.add_police_region(PoliceRegion.new(DISTRICT_ID, "Starter District"))
	state.add_neighborhood(
		Neighborhood.new(HOOD_ID, "Starter Hood", REGION_ID, DISTRICT_ID, RIVAL_FACTION_ID)
	)

	var keep: Stronghold = Stronghold.new(
		KEEP_ID,
		"Player Keep",
		HOOD_ID,
		KEEP_MAP_POSITION,
		PLAYER_FACTION_ID,
		true,
		1,
		0.0
	)
	keep.road_node_id = NODE_KEEP_ID
	state.add_map_location(keep)

	var hq: NeighborhoodHQ = NeighborhoodHQ.new(
		HQ_ID,
		"Rival HQ",
		HOOD_ID,
		HQ_MAP_POSITION,
		RIVAL_FACTION_ID,
		true
	)
	hq.road_node_id = NODE_HQ_ID
	state.add_map_location(hq)

	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new(NODE_KEEP_ID, KEEP_MAP_POSITION))
	graph.add_node(RoadNode.new(NODE_HQ_ID, HQ_MAP_POSITION))
	graph.add_segment(RoadSegment.new(SEGMENT_ID, NODE_KEEP_ID, NODE_HQ_ID, SEGMENT_DISTANCE))

	var vehicle: Vehicle = Vehicle.new(
		VEHICLE_ID,
		PLAYER_FACTION_ID,
		"car",
		"",
		DEBUG_CAR_PASSENGER_CAPACITY,
		VEHICLE_MOVEMENT_PER_TURN,
		0.0
	)
	state.add_vehicle(vehicle)
	state.assign_vehicle_to_stronghold(VEHICLE_ID, KEEP_ID)

	_add_keep_soldier(state, SOLDIER_ID, "rifle", 1.90, 35.0)
	_add_keep_soldier(state, SOLDIER_SMG_ID, "smg", 1.55, 30.0)
	_add_keep_soldier(state, SOLDIER_SHOTGUN_ID, "shotgun", 1.25, 25.0)
	_add_hq_soldier(state, RIVAL_SOLDIER_ID, "pistol", 1.00, 20.0)
	_add_hq_soldier(state, RIVAL_RIFLE_ID, "rifle", 1.90, 35.0)
	_add_hq_soldier(state, RIVAL_SHOTGUN_ID, "shotgun", 1.25, 25.0)

	DiplomacyService.declare_war(state, PLAYER_FACTION_ID, RIVAL_FACTION_ID)
	return state


static func debug_attacker_soldier_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.append(SOLDIER_ID)
	ids.append(SOLDIER_SMG_ID)
	ids.append(SOLDIER_SHOTGUN_ID)
	return ids


static func debug_defender_soldier_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.append(RIVAL_SOLDIER_ID)
	ids.append(RIVAL_RIFLE_ID)
	ids.append(RIVAL_SHOTGUN_ID)
	return ids


static func debug_start_position(participant_id: String) -> Vector2:
	match participant_id:
		SOLDIER_ID:
			return ATTACKER_RIFLE_START
		SOLDIER_SMG_ID:
			return ATTACKER_SMG_START
		SOLDIER_SHOTGUN_ID:
			return ATTACKER_SHOTGUN_START
		RIVAL_SOLDIER_ID:
			return DEFENDER_PISTOL_START
		RIVAL_RIFLE_ID:
			return DEFENDER_RIFLE_START
		RIVAL_SHOTGUN_ID:
			return DEFENDER_SHOTGUN_START
		_:
			return Vector2.INF


# Debug proving-ground only. True while the starter HQ assault mission is still
# traveling or awaiting resolution. Not a campaign consumption rule.
static func debug_hq_assault_in_progress(game_state: GameState) -> bool:
	if game_state == null or not game_state.has_mission(DEBUG_MISSION_ID):
		return false
	var mission: CampaignMission = game_state.get_mission(DEBUG_MISSION_ID)
	if mission == null:
		return false
	return (
		mission.mission_state == "traveling_outbound"
		or mission.mission_state == "awaiting_resolution"
	)


# Debug proving-ground only. True when StarterWorldService.create() fixture
# could accept a fresh debug HQ assault launch.
static func debug_hq_assault_can_launch(game_state: GameState) -> bool:
	if game_state == null:
		return false
	if game_state.has_mission(DEBUG_MISSION_ID):
		return false
	if game_state.has_traveling_force(DEBUG_FORCE_ID):
		return false
	if not game_state.has_vehicle(VEHICLE_ID):
		return false
	if not game_state.has_map_location(KEEP_ID) or not game_state.has_map_location(HQ_ID):
		return false
	if not game_state.has_neighborhood(HOOD_ID):
		return false
	var keep: Stronghold = game_state.get_map_location(KEEP_ID) as Stronghold
	var hq: NeighborhoodHQ = game_state.get_map_location(HQ_ID) as NeighborhoodHQ
	var hood: Neighborhood = game_state.get_neighborhood(HOOD_ID)
	if keep == null or hq == null or hood == null:
		return false
	if keep.owner_faction_id != PLAYER_FACTION_ID:
		return false
	if hq.owner_faction_id != RIVAL_FACTION_ID:
		return false
	if hood.owner_faction_id != RIVAL_FACTION_ID:
		return false
	var vehicle: Vehicle = game_state.get_vehicle(VEHICLE_ID)
	if vehicle == null:
		return false
	if vehicle.home_stronghold_id != KEEP_ID or not keep.has_vehicle_id(VEHICLE_ID):
		return false
	if vehicle.passenger_capacity < debug_attacker_soldier_ids().size():
		return false
	for attacker_id: String in debug_attacker_soldier_ids():
		if not _debug_keep_soldier_ready(game_state, keep, attacker_id):
			return false
	for defender_id: String in debug_defender_soldier_ids():
		if not _debug_hq_soldier_ready(game_state, hq, defender_id):
			return false
	if not DiplomacyService.are_at_war(game_state, PLAYER_FACTION_ID, RIVAL_FACTION_ID):
		return false
	return true


static func _add_keep_soldier(
	state: GameState,
	soldier_id: String,
	weapon_type_id: String,
	strategic_strength: float,
	upkeep_per_turn: float
) -> void:
	var soldier: Soldier = Soldier.new(
		soldier_id,
		PLAYER_FACTION_ID,
		"",
		weapon_type_id,
		strategic_strength,
		upkeep_per_turn
	)
	state.add_soldier(soldier)
	state.assign_soldier_to_stronghold(soldier_id, KEEP_ID)


static func _add_hq_soldier(
	state: GameState,
	soldier_id: String,
	weapon_type_id: String,
	strategic_strength: float,
	upkeep_per_turn: float
) -> void:
	var soldier: Soldier = Soldier.new(
		soldier_id,
		RIVAL_FACTION_ID,
		"",
		weapon_type_id,
		strategic_strength,
		upkeep_per_turn
	)
	state.add_soldier(soldier)
	if not state.assign_soldier_to_neighborhood_hq(soldier_id, HQ_ID):
		push_error(
			"StarterWorldService.create: failed to assign rival soldier '%s' to NeighborhoodHQ '%s'."
			% [soldier_id, HQ_ID]
		)


static func _debug_keep_soldier_ready(
	game_state: GameState,
	keep: Stronghold,
	soldier_id: String
) -> bool:
	if not game_state.has_soldier(soldier_id):
		return false
	var soldier: Soldier = game_state.get_soldier(soldier_id)
	if soldier == null:
		return false
	return soldier.home_stronghold_id == KEEP_ID and keep.has_soldier_id(soldier_id)


static func _debug_hq_soldier_ready(
	game_state: GameState,
	hq: NeighborhoodHQ,
	soldier_id: String
) -> bool:
	if not game_state.has_soldier(soldier_id):
		return false
	var soldier: Soldier = game_state.get_soldier(soldier_id)
	if soldier == null:
		return false
	return soldier.garrison_hq_id == HQ_ID and hq.has_garrison_soldier_id(soldier_id)
