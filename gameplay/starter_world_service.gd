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
