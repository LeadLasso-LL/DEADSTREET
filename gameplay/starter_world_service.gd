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
const RIVAL_SOLDIER_ID := "rival_soldier"
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

	var soldier: Soldier = Soldier.new(SOLDIER_ID, PLAYER_FACTION_ID, "", "pistol", 1.0, 0.0)
	var vehicle: Vehicle = Vehicle.new(
		VEHICLE_ID,
		PLAYER_FACTION_ID,
		"car",
		"",
		2,
		VEHICLE_MOVEMENT_PER_TURN,
		0.0
	)
	state.add_soldier(soldier)
	state.add_vehicle(vehicle)
	state.assign_soldier_to_stronghold(SOLDIER_ID, KEEP_ID)
	state.assign_vehicle_to_stronghold(VEHICLE_ID, KEEP_ID)

	# Provisional one-soldier rival HQ garrison so starter HQ assaults have a real defender.
	var rival_soldier: Soldier = Soldier.new(RIVAL_SOLDIER_ID, RIVAL_FACTION_ID, "", "pistol", 1.0, 0.0)
	state.add_soldier(rival_soldier)
	if not state.assign_soldier_to_neighborhood_hq(RIVAL_SOLDIER_ID, HQ_ID):
		push_error("StarterWorldService.create: failed to assign rival soldier '%s' to NeighborhoodHQ '%s'." % [RIVAL_SOLDIER_ID, HQ_ID])

	DiplomacyService.declare_war(state, PLAYER_FACTION_ID, RIVAL_FACTION_ID)
	return state


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
	if not game_state.has_soldier(SOLDIER_ID) or not game_state.has_soldier(RIVAL_SOLDIER_ID):
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
	var soldier: Soldier = game_state.get_soldier(SOLDIER_ID)
	var rival_soldier: Soldier = game_state.get_soldier(RIVAL_SOLDIER_ID)
	var vehicle: Vehicle = game_state.get_vehicle(VEHICLE_ID)
	if soldier == null or rival_soldier == null or vehicle == null:
		return false
	if soldier.home_stronghold_id != KEEP_ID or not keep.has_soldier_id(SOLDIER_ID):
		return false
	if vehicle.home_stronghold_id != KEEP_ID or not keep.has_vehicle_id(VEHICLE_ID):
		return false
	if rival_soldier.garrison_hq_id != HQ_ID or not hq.has_garrison_soldier_id(RIVAL_SOLDIER_ID):
		return false
	if not DiplomacyService.are_at_war(game_state, PLAYER_FACTION_ID, RIVAL_FACTION_ID):
		return false
	return true
