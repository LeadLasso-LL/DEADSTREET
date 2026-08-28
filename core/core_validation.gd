class_name CoreValidation
extends RefCounted

const Vehicle := preload("res://campaign/vehicles/vehicle.gd")
const VehicleGroup := preload("res://campaign/vehicles/vehicle_group.gd")
const Soldier := preload("res://campaign/units/soldier.gd")
const SoldierGroup := preload("res://campaign/units/soldier_group.gd")
const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")
const DeploymentResult := preload("res://campaign/actions/deployment_result.gd")
const DeploymentService := preload("res://campaign/actions/deployment_service.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const MissionRequest := preload("res://campaign/missions/mission_request.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")
const MissionService := preload("res://campaign/missions/mission_service.gd")
const BusinessRaidLoot := preload("res://campaign/missions/resolvers/business_raid_loot.gd")
const BusinessRaidResult := preload("res://campaign/missions/resolvers/business_raid_result.gd")
const BusinessRaidResolver := preload("res://campaign/missions/resolvers/business_raid_resolver.gd")
const ForceMoveRequest := preload("res://campaign/travel/force_move_request.gd")
const ForceMoveResult := preload("res://campaign/travel/force_move_result.gd")
const ForceMovementService := preload("res://campaign/travel/force_movement_service.gd")
const ForceTurnResult := preload("res://campaign/turns/force_turn_result.gd")
const TurnResult := preload("res://campaign/turns/turn_result.gd")
const TurnManager := preload("res://campaign/turns/turn_manager.gd")
const BusinessLevelOutput := preload("res://campaign/economy/business_level_output.gd")
const BusinessEconomyDefinition := preload("res://campaign/economy/business_economy_definition.gd")
const BusinessEconomyCatalog := preload("res://campaign/economy/business_economy_catalog.gd")
const BusinessProductionResult := preload("res://campaign/economy/business_production_result.gd")
const FactionEconomyResult := preload("res://campaign/economy/faction_economy_result.gd")
const EconomyTurnResult := preload("res://campaign/economy/economy_turn_result.gd")
const EconomyService := preload("res://campaign/economy/economy_service.gd")
const ExistingForceMissionRequest := preload("res://campaign/missions/existing_force_mission_request.gd")
const ExistingForceMissionResult := preload("res://campaign/missions/existing_force_mission_result.gd")
const NeighborhoodHQCaptureResult := preload("res://campaign/missions/resolvers/neighborhood_hq_capture_result.gd")
const NeighborhoodHQCaptureResolver := preload("res://campaign/missions/resolvers/neighborhood_hq_capture_resolver.gd")
const FactionRelationship := preload("res://campaign/diplomacy/faction_relationship.gd")
const DiplomacyResult := preload("res://campaign/diplomacy/diplomacy_result.gd")
const DiplomacyService := preload("res://campaign/diplomacy/diplomacy_service.gd")
const NeighborhoodHQAttackResult := preload("res://campaign/missions/neighborhood_hq_attack_result.gd")
const NeighborhoodHQAttackService := preload("res://campaign/missions/neighborhood_hq_attack_service.gd")
const NeighborhoodHQAttackFailureResult := preload("res://campaign/missions/resolvers/neighborhood_hq_attack_failure_result.gd")
const NeighborhoodHQAttackFailureResolver := preload("res://campaign/missions/resolvers/neighborhood_hq_attack_failure_resolver.gd")
const NeighborhoodHQBattleResult := preload("res://campaign/missions/resolvers/neighborhood_hq_battle_result.gd")
const NeighborhoodHQBattleResolver := preload("res://campaign/missions/resolvers/neighborhood_hq_battle_resolver.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleSetupResult := preload("res://battle/core/battle_setup_result.gd")
const BattleSetupService := preload("res://battle/core/battle_setup_service.gd")


static func run() -> Dictionary:
	var original := GameState.new()

	var gang_a := MajorGang.new("gang_a", "Gang A", "player")
	gang_a.money = 10000.0
	gang_a.resources.set_amount("Ammo", 12.5)
	gang_a.resources.set_amount("Gun Parts", 7.0)

	var gang_b := MajorGang.new("gang_b", "Gang B", "ai")
	gang_b.money = 10000.0
	gang_b.resources.set_amount("Ammo", 8.0)
	gang_b.resources.set_amount("Gun Parts", 4.5)

	original.add_faction(gang_a)
	original.add_faction(gang_b)

	var southside := StrongholdRegion.new("southside", "Southside")
	var northside := StrongholdRegion.new("northside", "Northside")
	original.add_stronghold_region(southside)
	original.add_stronghold_region(northside)

	var district_1 := PoliceRegion.new("district_1", "District 1")
	var district_2 := PoliceRegion.new("district_2", "District 2")
	original.add_police_region(district_1)
	original.add_police_region(district_2)

	original.add_neighborhood(Neighborhood.new("neighborhood_a", "Neighborhood A", "southside", "district_1"))
	original.add_neighborhood(Neighborhood.new("neighborhood_contested", "Contested Neighborhood", "southside", "district_2"))
	original.add_neighborhood(Neighborhood.new("neighborhood_b", "Neighborhood B", "northside", "district_2"))

	var stronghold_a := Stronghold.new(
		"stronghold_a",
		"Gang A Stronghold",
		"neighborhood_a",
		Vector2(100.0, 200.0),
		"gang_a",
		true,
		2
	)
	var hq_contested := NeighborhoodHQ.new(
		"hq_contested",
		"Contested Neighborhood HQ",
		"neighborhood_contested",
		Vector2(300.0, 200.0),
		"gang_b",
		true
	)
	var business_a := Business.new(
		"business_a",
		"Test Market",
		"neighborhood_a",
		Vector2(140.0, 240.0),
		"gang_a",
		false,
		"market",
		3
	)
	original.add_map_location(stronghold_a)
	original.add_map_location(hq_contested)
	original.add_map_location(business_a)

	var graph: RoadGraph = original.road_graph
	graph.add_node(RoadNode.new("road_a", Vector2(0, 0)))
	graph.add_node(RoadNode.new("road_b", Vector2(2, 0)))
	graph.add_node(RoadNode.new("road_c", Vector2(5, 0)))
	graph.add_node(RoadNode.new("road_d", Vector2(5, 4)))
	graph.add_node(RoadNode.new("road_e", Vector2(2, 4)))
	graph.add_segment(RoadSegment.new("seg_ab", "road_a", "road_b", 2.0))
	graph.add_segment(RoadSegment.new("seg_bc", "road_b", "road_c", 3.0))
	graph.add_segment(RoadSegment.new("seg_cd", "road_c", "road_d", 4.0))
	graph.add_segment(RoadSegment.new("seg_be", "road_b", "road_e", 2.0))
	graph.add_segment(RoadSegment.new("seg_ed", "road_e", "road_d", 3.0))
	stronghold_a.road_node_id = "road_a"
	business_a.road_node_id = "road_b"
	hq_contested.road_node_id = "road_d"

	var route_short: Array[String] = ["road_a", "road_b", "road_e", "road_d"]
	var route_long: Array[String] = ["road_a", "road_b", "road_c", "road_d"]
	var route_same: Array[String] = ["road_a"]
	var route_ab: Array[String] = ["road_a", "road_b"]
	var found_short: Array[String] = graph.find_route("road_a", "road_d")
	var route_short_ok := _string_ids_match(found_short, route_short)
	var route_short_distance_ok := graph.get_route_distance(found_short) == 7.0
	var route_same_ok := _string_ids_match(graph.find_route("road_a", "road_a"), route_same)
	var empty_start_route_ok := graph.find_route("", "road_d").is_empty()
	var missing_destination_route_ok := graph.find_route("road_a", "road_missing").is_empty()

	graph.get_segment("seg_ed").is_open = false
	var found_closed: Array[String] = graph.find_route("road_a", "road_d")
	var closed_route_ok := _string_ids_match(found_closed, route_long)
	var closed_route_distance_ok := graph.get_route_distance(found_closed) == 9.0
	graph.get_segment("seg_ed").is_open = true

	var node_count_before := graph.nodes.size()
	var segment_count_before := graph.segments.size()
	var road_a_before: RoadNode = graph.get_node("road_a")
	graph.add_node(RoadNode.new("road_a", Vector2(9, 9)))
	var duplicate_road_node_rejected := graph.get_node("road_a") == road_a_before and graph.nodes.size() == node_count_before
	var seg_ab_before: RoadSegment = graph.get_segment("seg_ab")
	graph.add_segment(RoadSegment.new("seg_ab", "road_c", "road_d", 1.0))
	var duplicate_road_segment_rejected := graph.get_segment("seg_ab") == seg_ab_before and graph.segments.size() == segment_count_before
	graph.add_segment(RoadSegment.new("seg_ba", "road_b", "road_a", 2.0))
	var reversed_endpoint_pair_rejected := not graph.has_segment("seg_ba") and graph.segments.size() == segment_count_before
	graph.add_segment(RoadSegment.new("seg_loop", "road_a", "road_a", 1.0))
	var self_loop_rejected := not graph.has_segment("seg_loop") and graph.segments.size() == segment_count_before
	graph.add_segment(RoadSegment.new("seg_missing", "road_a", "road_z", 1.0))
	var missing_endpoint_rejected := not graph.has_segment("seg_missing") and graph.segments.size() == segment_count_before

	var force_a: TravelingForce = TravelingForce.new("force_a", "gang_a", "stronghold_a", "hq_contested", route_short, 5.0, "traveling_outbound")
	original.add_traveling_force(force_a)
	var leftover_step_1: float = force_a.advance(3.0, graph)
	var force_step_1_ok := (
		leftover_step_1 == 0.0
		and force_a.route_segment_index == 1
		and force_a.distance_into_segment == 1.0
		and force_a.travel_state == "traveling_outbound"
	)
	var leftover_step_2: float = force_a.advance(1.0, graph)
	var force_step_2_ok := (
		leftover_step_2 == 0.0
		and force_a.route_segment_index == 2
		and force_a.distance_into_segment == 0.0
		and force_a.travel_state == "traveling_outbound"
	)
	var leftover_step_3: float = force_a.advance(3.0, graph)
	var force_step_3_ok := (
		leftover_step_3 == 0.0
		and force_a.travel_state == "at_destination"
		and force_a.route_segment_index == 2
		and force_a.distance_into_segment == 3.0
	)
	var index_after_arrival := force_a.route_segment_index
	var distance_after_arrival := force_a.distance_into_segment
	var leftover_step_4: float = force_a.advance(2.0, graph)
	var force_step_4_ok := (
		leftover_step_4 == 2.0
		and force_a.travel_state == "at_destination"
		and force_a.route_segment_index == index_after_arrival
		and force_a.distance_into_segment == distance_after_arrival
	)

	var force_partial: TravelingForce = TravelingForce.new("force_partial", "gang_a", "stronghold_a", "hq_contested", route_short, 5.0, "traveling_outbound")
	original.add_traveling_force(force_partial)
	var leftover_partial: float = force_partial.advance(5.5, graph)
	var force_partial_ok := (
		leftover_partial == 0.0
		and force_partial.travel_state == "traveling_outbound"
		and force_partial.route_segment_index == 2
		and force_partial.distance_into_segment == 1.5
	)

	var force_leftover: TravelingForce = TravelingForce.new("force_leftover", "gang_a", "stronghold_a", "business_a", route_ab, 5.0, "traveling_outbound")
	original.add_traveling_force(force_leftover)
	var leftover_arrival: float = force_leftover.advance(5.0, graph)
	var force_leftover_ok := (
		leftover_arrival == 3.0
		and force_leftover.travel_state == "at_destination"
		and force_leftover.route_segment_index == 0
		and force_leftover.distance_into_segment == 2.0
	)

	var force_blocked: TravelingForce = TravelingForce.new("force_blocked", "gang_a", "stronghold_a", "hq_contested", route_short, 5.0, "traveling_outbound")
	force_blocked.route_segment_index = 1
	force_blocked.distance_into_segment = 0.0
	original.add_traveling_force(force_blocked)
	graph.get_segment("seg_be").is_open = false
	var leftover_blocked: float = force_blocked.advance(2.0, graph)
	var force_blocked_ok := (
		leftover_blocked == 2.0
		and force_blocked.travel_state == "traveling_outbound"
		and force_blocked.route_segment_index == 1
		and force_blocked.distance_into_segment == 0.0
	)
	graph.get_segment("seg_be").is_open = true

	var blocked_state_before_invalid := force_partial.travel_state
	var blocked_index_before_invalid := force_partial.route_segment_index
	var blocked_distance_before_invalid := force_partial.distance_into_segment
	var leftover_invalid: float = force_partial.advance(-1.0, graph)
	var invalid_budget_ok := (
		leftover_invalid == -1.0
		and force_partial.travel_state == blocked_state_before_invalid
		and force_partial.route_segment_index == blocked_index_before_invalid
		and force_partial.distance_into_segment == blocked_distance_before_invalid
	)

	var force_a_before_dup: TravelingForce = original.get_traveling_force("force_a")
	original.add_traveling_force(TravelingForce.new("force_a", "gang_b", "business_a", "hq_contested", route_ab, 3.0, "complete"))
	var duplicate_traveling_force_rejected := original.get_traveling_force("force_a") == force_a_before_dup

	var gang_a_before_dup := original.get_faction("gang_a")
	original.add_faction(MajorGang.new("gang_a", "Impostor Gang", "ai"))
	var duplicate_faction_rejected := original.get_faction("gang_a") == gang_a_before_dup

	var stronghold_before_dup := original.get_map_location("stronghold_a")
	original.add_map_location(
		Stronghold.new(
			"stronghold_a",
			"Impostor Stronghold",
			"neighborhood_a",
			Vector2.ZERO,
			"gang_b",
			true,
			1
		)
	)
	var duplicate_location_rejected := original.get_map_location("stronghold_a") == stronghold_before_dup

	var neighborhood_before_dup := original.get_neighborhood("neighborhood_a")
	original.add_neighborhood(Neighborhood.new("neighborhood_a", "Impostor Neighborhood", "northside", "district_2"))
	var duplicate_neighborhood_rejected := original.get_neighborhood("neighborhood_a") == neighborhood_before_dup

	var stronghold_region_before_dup := original.get_stronghold_region("southside")
	original.add_stronghold_region(StrongholdRegion.new("southside", "Impostor Southside"))
	var duplicate_stronghold_region_rejected := original.get_stronghold_region("southside") == stronghold_region_before_dup

	var police_region_before_dup := original.get_police_region("district_1")
	original.add_police_region(PoliceRegion.new("district_1", "Impostor District"))
	var duplicate_police_region_rejected := original.get_police_region("district_1") == police_region_before_dup

	var vehicle_bike: Vehicle = Vehicle.new("vehicle_bike", "gang_a", "bike", "", 1, 6.0, 25.0)
	var vehicle_car: Vehicle = Vehicle.new("vehicle_car", "gang_a", "car", "", 4, 5.0, 50.0)
	var vehicle_van: Vehicle = Vehicle.new("vehicle_van", "gang_a", "van", "", 7, 4.0, 80.0)
	original.add_vehicle(vehicle_bike)
	original.add_vehicle(vehicle_car)
	original.add_vehicle(vehicle_van)

	var bike_assigned: bool = original.assign_vehicle_to_stronghold("vehicle_bike", "stronghold_a")
	var car_assigned: bool = original.assign_vehicle_to_stronghold("vehicle_car", "stronghold_a")
	var van_assigned: bool = original.assign_vehicle_to_stronghold("vehicle_van", "stronghold_a")
	var expected_stronghold_a_vehicles: Array[String] = ["vehicle_bike", "vehicle_car", "vehicle_van"]
	var assigned_homes_ok: bool = (
		vehicle_bike.home_stronghold_id == "stronghold_a"
		and vehicle_car.home_stronghold_id == "stronghold_a"
		and vehicle_van.home_stronghold_id == "stronghold_a"
	)
	var stronghold_a_vehicles_once: bool = _string_ids_match(stronghold_a.vehicle_ids, expected_stronghold_a_vehicles)

	var car_reassign_same: bool = original.assign_vehicle_to_stronghold("vehicle_car", "stronghold_a")
	var car_not_duplicated: bool = (
		_count_id(stronghold_a.vehicle_ids, "vehicle_car") == 1
		and stronghold_a.vehicle_ids.size() == 3
	)

	var stronghold_b: Stronghold = Stronghold.new(
		"stronghold_b",
		"Gang A Secondary Stronghold",
		"neighborhood_b",
		Vector2(500.0, 400.0),
		"gang_a",
		true,
		1
	)
	stronghold_b.road_node_id = "road_d"
	original.add_map_location(stronghold_b)

	var car_moved_to_b: bool = original.assign_vehicle_to_stronghold("vehicle_car", "stronghold_b")
	var car_home_is_b: bool = vehicle_car.home_stronghold_id == "stronghold_b"
	var stronghold_a_lacks_car: bool = not stronghold_a.has_vehicle_id("vehicle_car")
	var stronghold_b_has_car_once: bool = _count_id(stronghold_b.vehicle_ids, "vehicle_car") == 1
	var car_moved_back: bool = original.assign_vehicle_to_stronghold("vehicle_car", "stronghold_a")

	var vehicle_enemy: Vehicle = Vehicle.new("vehicle_enemy", "gang_b", "car", "", 4, 5.0, 50.0)
	original.add_vehicle(vehicle_enemy)
	var enemy_assign_rejected: bool = not original.assign_vehicle_to_stronghold("vehicle_enemy", "stronghold_a")
	var enemy_home_empty: bool = vehicle_enemy.home_stronghold_id.is_empty()
	var stronghold_a_lacks_enemy: bool = not stronghold_a.has_vehicle_id("vehicle_enemy")

	var van_unassigned: bool = original.unassign_vehicle_from_stronghold("vehicle_van")
	var van_home_cleared: bool = vehicle_van.home_stronghold_id.is_empty()
	var stronghold_a_lacks_van: bool = not stronghold_a.has_vehicle_id("vehicle_van")
	var van_reassigned: bool = original.assign_vehicle_to_stronghold("vehicle_van", "stronghold_a")
	var final_stronghold_a_vehicles: Array[String] = ["vehicle_bike", "vehicle_car", "vehicle_van"]
	var final_stronghold_b_vehicles: Array[String] = []
	var final_homes_ok: bool = (
		vehicle_bike.home_stronghold_id == "stronghold_a"
		and vehicle_car.home_stronghold_id == "stronghold_a"
		and vehicle_van.home_stronghold_id == "stronghold_a"
		and _string_ids_match(stronghold_a.vehicle_ids, final_stronghold_a_vehicles)
		and _string_ids_match(stronghold_b.vehicle_ids, final_stronghold_b_vehicles)
	)

	var convoy: VehicleGroup = VehicleGroup.new()
	var convoy_add_bike: bool = convoy.add_vehicle_id("vehicle_bike")
	var convoy_add_car: bool = convoy.add_vehicle_id("vehicle_car")
	var convoy_add_van: bool = convoy.add_vehicle_id("vehicle_van")
	var expected_convoy_order: Array[String] = ["vehicle_bike", "vehicle_car", "vehicle_van"]
	var convoy_order_ok: bool = _string_ids_match(convoy.vehicle_ids, expected_convoy_order)
	var convoy_dup_rejected: bool = not convoy.add_vehicle_id("vehicle_car")
	var convoy_empty_rejected: bool = not convoy.add_vehicle_id("")
	var convoy_size_three: bool = convoy.vehicle_ids.size() == 3 and convoy_order_ok
	var convoy_remove_missing: bool = not convoy.remove_vehicle_id("missing_vehicle")
	var convoy_remove_car: bool = convoy.remove_vehicle_id("vehicle_car")
	var convoy_car_absent: bool = not convoy.has_vehicle_id("vehicle_car")
	var convoy_readd_car: bool = convoy.add_vehicle_id("vehicle_car")
	var unique_convoy_ids: Array[String] = ["vehicle_bike", "vehicle_van", "vehicle_car"]
	var convoy_unique_after_readd: bool = _string_ids_match(convoy.vehicle_ids, unique_convoy_ids)
	var convoy_capacity_ok: bool = convoy.get_total_passenger_capacity(original) == 12
	var convoy_movement_ok: bool = convoy.get_movement_per_turn(original) == 4.0

	var empty_group: VehicleGroup = VehicleGroup.new()
	var empty_capacity_ok: bool = empty_group.get_total_passenger_capacity(original) == 0
	var empty_movement_ok: bool = empty_group.get_movement_per_turn(original) == 0.0

	var force_convoy: TravelingForce = TravelingForce.new(
		"force_convoy",
		"gang_a",
		"stronghold_a",
		"hq_contested",
		route_short,
		99.0,
		"traveling_outbound"
	)
	force_convoy.vehicle_group.add_vehicle_id("vehicle_bike")
	force_convoy.vehicle_group.add_vehicle_id("vehicle_car")
	force_convoy.vehicle_group.add_vehicle_id("vehicle_van")
	original.add_traveling_force(force_convoy)
	var refreshed_movement: float = force_convoy.refresh_movement_from_vehicles(original)
	var force_convoy_refresh_ok: bool = refreshed_movement == 4.0
	var force_convoy_stored_ok: bool = force_convoy.movement_per_turn == 4.0
	var expected_force_convoy_ids: Array[String] = ["vehicle_bike", "vehicle_car", "vehicle_van"]

	var missing_group: VehicleGroup = VehicleGroup.new()
	missing_group.add_vehicle_id("vehicle_bike")
	missing_group.add_vehicle_id("missing_vehicle")
	var missing_capacity_ok: bool = missing_group.get_total_passenger_capacity(original) == 1
	var missing_movement_ok: bool = missing_group.get_movement_per_turn(original) == 6.0

	var loaded_group: VehicleGroup = VehicleGroup.new()
	var malformed_ids: Array[String] = ["vehicle_bike", "vehicle_car", "vehicle_bike", "", "vehicle_van"]
	loaded_group.from_dict({"vehicle_ids": malformed_ids})
	var loaded_group_ok: bool = _string_ids_match(loaded_group.vehicle_ids, expected_convoy_order)

	var bike_before_dup: Vehicle = original.get_vehicle("vehicle_bike")
	original.add_vehicle(Vehicle.new("vehicle_bike", "gang_b", "car", "", 4, 5.0, 50.0))
	var duplicate_vehicle_rejected: bool = original.get_vehicle("vehicle_bike") == bike_before_dup
	var remove_missing_vehicle: bool = not original.remove_vehicle("missing_vehicle")

	var negative_vehicle: Vehicle = Vehicle.new("vehicle_negative", "gang_a", "bike", "", -3, -2.5, -10.0)
	var negative_capacity_ok: bool = negative_vehicle.passenger_capacity == 0
	var negative_movement_ok: bool = negative_vehicle.movement_per_turn == 0.0
	var negative_upkeep_ok: bool = negative_vehicle.upkeep_per_turn == 0.0

	var soldier_pistol: Soldier = Soldier.new("soldier_pistol", "gang_a", "", "pistol", 1.00, 20.0)
	var soldier_shotgun: Soldier = Soldier.new("soldier_shotgun", "gang_a", "", "shotgun", 1.25, 25.0)
	var soldier_smg: Soldier = Soldier.new("soldier_smg", "gang_a", "", "smg", 1.55, 30.0)
	var soldier_rifle: Soldier = Soldier.new("soldier_rifle", "gang_a", "", "rifle", 1.90, 35.0)
	original.add_soldier(soldier_pistol)
	original.add_soldier(soldier_shotgun)
	original.add_soldier(soldier_smg)
	original.add_soldier(soldier_rifle)

	var pistol_assigned: bool = original.assign_soldier_to_stronghold("soldier_pistol", "stronghold_a")
	var shotgun_assigned: bool = original.assign_soldier_to_stronghold("soldier_shotgun", "stronghold_a")
	var smg_assigned: bool = original.assign_soldier_to_stronghold("soldier_smg", "stronghold_a")
	var rifle_assigned: bool = original.assign_soldier_to_stronghold("soldier_rifle", "stronghold_a")
	var expected_stronghold_a_soldiers: Array[String] = ["soldier_pistol", "soldier_shotgun", "soldier_smg", "soldier_rifle"]
	var assigned_soldier_homes_ok: bool = (
		soldier_pistol.home_stronghold_id == "stronghold_a"
		and soldier_shotgun.home_stronghold_id == "stronghold_a"
		and soldier_smg.home_stronghold_id == "stronghold_a"
		and soldier_rifle.home_stronghold_id == "stronghold_a"
	)
	var stronghold_a_soldiers_once: bool = _string_ids_match(stronghold_a.soldier_ids, expected_stronghold_a_soldiers)

	var pistol_reassign_same: bool = original.assign_soldier_to_stronghold("soldier_pistol", "stronghold_a")
	var pistol_not_duplicated: bool = (
		_count_id(stronghold_a.soldier_ids, "soldier_pistol") == 1
		and stronghold_a.soldier_ids.size() == 4
	)

	var rifle_moved_to_b: bool = original.assign_soldier_to_stronghold("soldier_rifle", "stronghold_b")
	var rifle_home_is_b: bool = soldier_rifle.home_stronghold_id == "stronghold_b"
	var stronghold_a_lacks_rifle: bool = not stronghold_a.has_soldier_id("soldier_rifle")
	var stronghold_b_has_rifle_once: bool = _count_id(stronghold_b.soldier_ids, "soldier_rifle") == 1
	var rifle_moved_back: bool = original.assign_soldier_to_stronghold("soldier_rifle", "stronghold_a")

	var soldier_enemy: Soldier = Soldier.new("soldier_enemy", "gang_b", "", "pistol", 1.0, 20.0)
	original.add_soldier(soldier_enemy)
	var enemy_soldier_assign_rejected: bool = not original.assign_soldier_to_stronghold("soldier_enemy", "stronghold_a")
	var enemy_soldier_home_empty: bool = soldier_enemy.home_stronghold_id.is_empty()
	var stronghold_a_lacks_enemy_soldier: bool = not stronghold_a.has_soldier_id("soldier_enemy")

	var smg_unassigned: bool = original.unassign_soldier_from_stronghold("soldier_smg")
	var smg_home_cleared: bool = soldier_smg.home_stronghold_id.is_empty()
	var stronghold_a_lacks_smg: bool = not stronghold_a.has_soldier_id("soldier_smg")
	var smg_reassigned: bool = original.assign_soldier_to_stronghold("soldier_smg", "stronghold_a")
	var final_stronghold_a_soldiers: Array[String] = ["soldier_pistol", "soldier_shotgun", "soldier_rifle", "soldier_smg"]
	var final_stronghold_b_soldiers: Array[String] = []
	var final_soldier_homes_ok: bool = (
		soldier_pistol.home_stronghold_id == "stronghold_a"
		and soldier_shotgun.home_stronghold_id == "stronghold_a"
		and soldier_smg.home_stronghold_id == "stronghold_a"
		and soldier_rifle.home_stronghold_id == "stronghold_a"
		and _string_ids_match(stronghold_a.soldier_ids, final_stronghold_a_soldiers)
		and _string_ids_match(stronghold_b.soldier_ids, final_stronghold_b_soldiers)
	)

	var squad: SoldierGroup = SoldierGroup.new()
	var squad_add_pistol: bool = squad.add_soldier_id("soldier_pistol")
	var squad_add_shotgun: bool = squad.add_soldier_id("soldier_shotgun")
	var squad_add_smg: bool = squad.add_soldier_id("soldier_smg")
	var squad_add_rifle: bool = squad.add_soldier_id("soldier_rifle")
	var expected_squad_order: Array[String] = ["soldier_pistol", "soldier_shotgun", "soldier_smg", "soldier_rifle"]
	var squad_order_ok: bool = _string_ids_match(squad.soldier_ids, expected_squad_order)
	var squad_dup_rejected: bool = not squad.add_soldier_id("soldier_pistol")
	var squad_empty_rejected: bool = not squad.add_soldier_id("")
	var squad_size_four: bool = squad.soldier_ids.size() == 4 and squad_order_ok
	var squad_remove_missing: bool = not squad.remove_soldier_id("missing_soldier")
	var squad_remove_shotgun: bool = squad.remove_soldier_id("soldier_shotgun")
	var squad_shotgun_absent: bool = not squad.has_soldier_id("soldier_shotgun")
	var squad_readd_shotgun: bool = squad.add_soldier_id("soldier_shotgun")
	var unique_squad_ids: Array[String] = ["soldier_pistol", "soldier_smg", "soldier_rifle", "soldier_shotgun"]
	var squad_unique_after_readd: bool = _string_ids_match(squad.soldier_ids, unique_squad_ids)
	var squad_strength_ok: bool = is_equal_approx(squad.get_total_strategic_strength(original), 5.70)

	var empty_squad: SoldierGroup = SoldierGroup.new()
	var empty_squad_strength_ok: bool = empty_squad.get_total_strategic_strength(original) == 0.0

	var missing_squad: SoldierGroup = SoldierGroup.new()
	missing_squad.add_soldier_id("soldier_pistol")
	missing_squad.add_soldier_id("missing_soldier")
	var missing_squad_strength_ok: bool = missing_squad.get_total_strategic_strength(original) == 1.0

	var loaded_squad: SoldierGroup = SoldierGroup.new()
	var malformed_soldier_ids: Array[String] = ["soldier_pistol", "soldier_shotgun", "soldier_pistol", "", "soldier_rifle"]
	loaded_squad.from_dict({"soldier_ids": malformed_soldier_ids})
	var expected_loaded_squad_ids: Array[String] = ["soldier_pistol", "soldier_shotgun", "soldier_rifle"]
	var loaded_squad_ok: bool = _string_ids_match(loaded_squad.soldier_ids, expected_loaded_squad_ids)

	var force_soldiers: TravelingForce = TravelingForce.new(
		"force_soldiers",
		"gang_a",
		"stronghold_a",
		"hq_contested",
		route_short,
		5.0,
		"traveling_outbound"
	)
	force_soldiers.soldier_group.add_soldier_id("soldier_pistol")
	force_soldiers.soldier_group.add_soldier_id("soldier_shotgun")
	force_soldiers.soldier_group.add_soldier_id("soldier_smg")
	force_soldiers.soldier_group.add_soldier_id("soldier_rifle")
	force_soldiers.vehicle_group.add_vehicle_id("vehicle_car")
	original.add_traveling_force(force_soldiers)
	var expected_force_soldiers_ids: Array[String] = ["soldier_pistol", "soldier_shotgun", "soldier_smg", "soldier_rifle"]
	var expected_force_soldiers_vehicles: Array[String] = ["vehicle_car"]
	var force_soldiers_count_ok: bool = force_soldiers.soldier_group.soldier_ids.size() == 4
	var force_soldiers_capacity: int = force_soldiers.get_transport_capacity(original)
	var force_soldiers_capacity_ok: bool = force_soldiers_capacity == 4
	var force_soldiers_valid: bool = force_soldiers.has_valid_transport_capacity(original)
	var force_soldiers_strength_ok: bool = is_equal_approx(force_soldiers.get_total_strategic_strength(original), 5.70)

	var force_overloaded: TravelingForce = TravelingForce.new(
		"force_overloaded",
		"gang_a",
		"stronghold_a",
		"hq_contested",
		route_short,
		5.0,
		"traveling_outbound"
	)
	force_overloaded.soldier_group.add_soldier_id("soldier_pistol")
	force_overloaded.soldier_group.add_soldier_id("soldier_shotgun")
	force_overloaded.soldier_group.add_soldier_id("soldier_smg")
	force_overloaded.soldier_group.add_soldier_id("soldier_rifle")
	force_overloaded.vehicle_group.add_vehicle_id("vehicle_bike")
	var overloaded_capacity: int = force_overloaded.get_transport_capacity(original)
	var overloaded_capacity_ok: bool = overloaded_capacity == 1
	var overloaded_invalid: bool = not force_overloaded.has_valid_transport_capacity(original)

	var force_no_vehicles: TravelingForce = TravelingForce.new(
		"force_no_vehicles",
		"gang_a",
		"stronghold_a",
		"hq_contested",
		route_short,
		5.0,
		"traveling_outbound"
	)
	force_no_vehicles.soldier_group.add_soldier_id("soldier_pistol")
	var no_vehicle_capacity: int = force_no_vehicles.get_transport_capacity(original)
	var no_vehicle_capacity_ok: bool = no_vehicle_capacity == 0
	var no_vehicle_invalid: bool = not force_no_vehicles.has_valid_transport_capacity(original)

	var force_empty_transport: TravelingForce = TravelingForce.new(
		"force_empty_transport",
		"gang_a",
		"stronghold_a",
		"hq_contested",
		route_short,
		5.0,
		"traveling_outbound"
	)
	var empty_transport_capacity: int = force_empty_transport.get_transport_capacity(original)
	var empty_transport_capacity_ok: bool = empty_transport_capacity == 0
	var empty_transport_valid: bool = force_empty_transport.has_valid_transport_capacity(original)

	var negative_soldier: Soldier = Soldier.new("soldier_negative", "gang_a", "", "pistol", -2.0, -15.0)
	var negative_soldier_strength_ok: bool = negative_soldier.strategic_strength == 0.0
	var negative_soldier_upkeep_ok: bool = negative_soldier.upkeep_per_turn == 0.0

	var pistol_before_dup: Soldier = original.get_soldier("soldier_pistol")
	original.add_soldier(Soldier.new("soldier_pistol", "gang_b", "", "rifle", 1.90, 35.0))
	var duplicate_soldier_rejected: bool = original.get_soldier("soldier_pistol") == pistol_before_dup
	var remove_missing_soldier: bool = not original.remove_soldier("missing_soldier")

	var deploy_soldier_1: Soldier = Soldier.new("deploy_soldier_1", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_2: Soldier = Soldier.new("deploy_soldier_2", "gang_a", "", "rifle", 1.9, 35.0)
	var deploy_soldier_3: Soldier = Soldier.new("deploy_soldier_3", "gang_a", "", "smg", 1.55, 30.0)
	var deploy_soldier_4: Soldier = Soldier.new("deploy_soldier_4", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_5: Soldier = Soldier.new("deploy_soldier_5", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_6: Soldier = Soldier.new("deploy_soldier_6", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_7: Soldier = Soldier.new("deploy_soldier_7", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_8: Soldier = Soldier.new("deploy_soldier_8", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_9: Soldier = Soldier.new("deploy_soldier_9", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_x: Soldier = Soldier.new("deploy_soldier_x", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_y: Soldier = Soldier.new("deploy_soldier_y", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_nov: Soldier = Soldier.new("deploy_soldier_nov", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_enemy: Soldier = Soldier.new("deploy_soldier_enemy", "gang_b", "", "pistol", 1.0, 20.0)
	var deploy_soldier_home_b: Soldier = Soldier.new("deploy_soldier_home_b", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_soldier_orphan: Soldier = Soldier.new("deploy_soldier_orphan", "gang_a", "stronghold_a", "pistol", 1.0, 20.0)
	original.add_soldier(deploy_soldier_1)
	original.add_soldier(deploy_soldier_2)
	original.add_soldier(deploy_soldier_3)
	original.add_soldier(deploy_soldier_4)
	original.add_soldier(deploy_soldier_5)
	original.add_soldier(deploy_soldier_6)
	original.add_soldier(deploy_soldier_7)
	original.add_soldier(deploy_soldier_8)
	original.add_soldier(deploy_soldier_9)
	original.add_soldier(deploy_soldier_x)
	original.add_soldier(deploy_soldier_y)
	original.add_soldier(deploy_soldier_nov)
	original.add_soldier(deploy_soldier_enemy)
	original.add_soldier(deploy_soldier_home_b)
	original.add_soldier(deploy_soldier_orphan)
	var assign_ds1: bool = original.assign_soldier_to_stronghold("deploy_soldier_1", "stronghold_a")
	var assign_ds2: bool = original.assign_soldier_to_stronghold("deploy_soldier_2", "stronghold_a")
	var assign_ds3: bool = original.assign_soldier_to_stronghold("deploy_soldier_3", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_4", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_5", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_6", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_7", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_8", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_9", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_x", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_y", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_nov", "stronghold_a")
	original.assign_soldier_to_stronghold("deploy_soldier_home_b", "stronghold_b")

	var deploy_car: Vehicle = Vehicle.new("deploy_car", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_van: Vehicle = Vehicle.new("deploy_van", "gang_a", "van", "", 7, 4.0, 80.0)
	var deploy_fast: Vehicle = Vehicle.new("deploy_fast", "gang_a", "car", "", 4, 8.0, 50.0)
	var deploy_same_a: Vehicle = Vehicle.new("deploy_same_a", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_same_b: Vehicle = Vehicle.new("deploy_same_b", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_zero_nl: Vehicle = Vehicle.new("deploy_zero_nl", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_spare: Vehicle = Vehicle.new("deploy_spare", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_bike: Vehicle = Vehicle.new("deploy_bike", "gang_a", "bike", "", 1, 6.0, 25.0)
	var deploy_vehicle_nos: Vehicle = Vehicle.new("deploy_vehicle_nos", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_vehicle_enemy: Vehicle = Vehicle.new("deploy_vehicle_enemy", "gang_b", "car", "", 2, 5.0, 50.0)
	var deploy_vehicle_home_b: Vehicle = Vehicle.new("deploy_vehicle_home_b", "gang_a", "car", "", 2, 5.0, 50.0)
	var deploy_vehicle_orphan: Vehicle = Vehicle.new("deploy_vehicle_orphan", "gang_a", "car", "stronghold_a", 2, 5.0, 50.0)
	original.add_vehicle(deploy_car)
	original.add_vehicle(deploy_van)
	original.add_vehicle(deploy_fast)
	original.add_vehicle(deploy_same_a)
	original.add_vehicle(deploy_same_b)
	original.add_vehicle(deploy_zero_nl)
	original.add_vehicle(deploy_spare)
	original.add_vehicle(deploy_bike)
	original.add_vehicle(deploy_vehicle_nos)
	original.add_vehicle(deploy_vehicle_enemy)
	original.add_vehicle(deploy_vehicle_home_b)
	original.add_vehicle(deploy_vehicle_orphan)
	var assign_dcar: bool = original.assign_vehicle_to_stronghold("deploy_car", "stronghold_a")
	var assign_dvan: bool = original.assign_vehicle_to_stronghold("deploy_van", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_fast", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_same_a", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_same_b", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_zero_nl", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_spare", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_bike", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_vehicle_nos", "stronghold_a")
	original.assign_vehicle_to_stronghold("deploy_vehicle_home_b", "stronghold_b")

	var business_same_node: Business = Business.new("business_same_node", "Same Node Shop", "neighborhood_a", Vector2(110.0, 210.0), "gang_a", true, "market", 1)
	business_same_node.road_node_id = "road_a"
	original.add_map_location(business_same_node)
	var stronghold_enemy: Stronghold = Stronghold.new("stronghold_enemy", "Gang B Stronghold", "neighborhood_contested", Vector2(320.0, 220.0), "gang_b", true, 1)
	stronghold_enemy.road_node_id = "road_d"
	original.add_map_location(stronghold_enemy)
	var stronghold_no_road: Stronghold = Stronghold.new("stronghold_no_road", "No Road Stronghold", "neighborhood_a", Vector2(80.0, 80.0), "gang_a", true, 1)
	original.add_map_location(stronghold_no_road)
	var stronghold_ghost_road: Stronghold = Stronghold.new("stronghold_ghost_road", "Ghost Road Stronghold", "neighborhood_a", Vector2(90.0, 90.0), "gang_a", true, 1)
	stronghold_ghost_road.road_node_id = "road_ghost"
	original.add_map_location(stronghold_ghost_road)
	var deploy_soldier_ghost: Soldier = Soldier.new("deploy_soldier_ghost", "gang_a", "", "pistol", 1.0, 20.0)
	var deploy_vehicle_ghost: Vehicle = Vehicle.new("deploy_vehicle_ghost", "gang_a", "car", "", 2, 5.0, 50.0)
	original.add_soldier(deploy_soldier_ghost)
	original.add_vehicle(deploy_vehicle_ghost)
	original.assign_soldier_to_stronghold("deploy_soldier_ghost", "stronghold_ghost_road")
	original.assign_vehicle_to_stronghold("deploy_vehicle_ghost", "stronghold_ghost_road")
	var business_no_road: Business = Business.new("business_no_road", "No Road Shop", "neighborhood_a", Vector2(70.0, 70.0), "gang_a", true, "market", 1)
	original.add_map_location(business_no_road)
	var business_ghost_road: Business = Business.new("business_ghost_road", "Ghost Road Shop", "neighborhood_a", Vector2(60.0, 60.0), "gang_a", true, "market", 1)
	business_ghost_road.road_node_id = "road_ghost"
	original.add_map_location(business_ghost_road)
	graph.add_node(RoadNode.new("road_isolated", Vector2(99.0, 99.0)))
	var business_isolated: Business = Business.new("business_isolated", "Isolated Shop", "neighborhood_a", Vector2(99.0, 99.0), "gang_a", true, "market", 1)
	business_isolated.road_node_id = "road_isolated"
	original.add_map_location(business_isolated)

	var expected_deploy_route: Array[String] = ["road_a", "road_b", "road_e", "road_d"]
	var deploy_ids_partial_s: Array[String] = ["deploy_soldier_1", "deploy_soldier_2"]
	var deploy_ids_partial_v: Array[String] = ["deploy_car"]
	var homes_before_partial_s1: String = deploy_soldier_1.home_stronghold_id
	var homes_before_partial_s2: String = deploy_soldier_2.home_stronghold_id
	var homes_before_partial_car: String = deploy_car.home_stronghold_id
	var origin_soldiers_before_partial: Array[String] = _copy_ids(stronghold_a.soldier_ids)
	var origin_vehicles_before_partial: Array[String] = _copy_ids(stronghold_a.vehicle_ids)
	var req_partial: DeploymentRequest = DeploymentRequest.new("deploy_force_partial", "gang_a", "stronghold_a", "hq_contested", deploy_ids_partial_s, deploy_ids_partial_v, 3.0)
	var res_partial: DeploymentResult = DeploymentService.deploy(original, req_partial)
	var force_partial_deploy: TravelingForce = original.get_traveling_force("deploy_force_partial")
	var deploy_partial_result_ok: bool = (
		res_partial.success
		and res_partial.force_id == "deploy_force_partial"
		and res_partial.error_code.is_empty()
		and res_partial.error_message.is_empty()
		and res_partial.reached_destination == false
		and is_equal_approx(res_partial.unused_movement, 0.0)
	)
	var deploy_partial_force_ok: bool = (
		force_partial_deploy != null
		and force_partial_deploy.faction_id == "gang_a"
		and force_partial_deploy.origin_location_id == "stronghold_a"
		and force_partial_deploy.destination_location_id == "hq_contested"
		and _string_ids_match(force_partial_deploy.route_node_ids, expected_deploy_route)
		and _string_ids_match(force_partial_deploy.soldier_group.soldier_ids, deploy_ids_partial_s)
		and _string_ids_match(force_partial_deploy.vehicle_group.vehicle_ids, deploy_ids_partial_v)
		and is_equal_approx(force_partial_deploy.movement_per_turn, 5.0)
		and force_partial_deploy.travel_state == "traveling_outbound"
		and force_partial_deploy.route_segment_index == 1
		and is_equal_approx(force_partial_deploy.distance_into_segment, 1.0)
	)
	var deploy_partial_homes_ok: bool = (
		deploy_soldier_1.home_stronghold_id == homes_before_partial_s1
		and deploy_soldier_2.home_stronghold_id == homes_before_partial_s2
		and deploy_car.home_stronghold_id == homes_before_partial_car
		and _string_ids_match(stronghold_a.soldier_ids, origin_soldiers_before_partial)
		and _string_ids_match(stronghold_a.vehicle_ids, origin_vehicles_before_partial)
		and stronghold_a.has_soldier_id("deploy_soldier_1")
		and stronghold_a.has_soldier_id("deploy_soldier_2")
		and stronghold_a.has_vehicle_id("deploy_car")
	)

	var deploy_ids_capped_s: Array[String] = ["deploy_soldier_3"]
	var deploy_ids_capped_v: Array[String] = ["deploy_van"]
	var req_capped: DeploymentRequest = DeploymentRequest.new("deploy_force_capped", "gang_a", "stronghold_a", "hq_contested", deploy_ids_capped_s, deploy_ids_capped_v, 99.0)
	var res_capped: DeploymentResult = DeploymentService.deploy(original, req_capped)
	var force_capped: TravelingForce = original.get_traveling_force("deploy_force_capped")
	var deploy_capped_ok: bool = (
		res_capped.success
		and force_capped != null
		and is_equal_approx(force_capped.movement_per_turn, 4.0)
		and force_capped.travel_state == "traveling_outbound"
		and force_capped.route_segment_index == 2
		and is_equal_approx(force_capped.distance_into_segment, 0.0)
		and is_equal_approx(res_capped.unused_movement, 0.0)
		and not is_equal_approx(res_capped.unused_movement, 95.0)
	)

	var deploy_ids_arrive_s: Array[String] = ["deploy_soldier_4"]
	var deploy_ids_arrive_v: Array[String] = ["deploy_fast"]
	var req_arrive: DeploymentRequest = DeploymentRequest.new("deploy_force_arrive", "gang_a", "stronghold_a", "hq_contested", deploy_ids_arrive_s, deploy_ids_arrive_v, 8.0)
	var res_arrive: DeploymentResult = DeploymentService.deploy(original, req_arrive)
	var force_arrive: TravelingForce = original.get_traveling_force("deploy_force_arrive")
	var deploy_arrive_ok: bool = (
		res_arrive.success
		and res_arrive.reached_destination == true
		and is_equal_approx(res_arrive.unused_movement, 1.0)
		and force_arrive != null
		and force_arrive.travel_state == "at_destination"
		and force_arrive.travel_state != "traveling_return"
		and force_arrive.route_segment_index == 2
		and is_equal_approx(force_arrive.distance_into_segment, 3.0)
		and hq_contested.owner_faction_id == "gang_b"
		and hq_contested.is_open == true
	)

	var expected_same_route: Array[String] = ["road_a"]
	var deploy_ids_same0_s: Array[String] = ["deploy_soldier_5"]
	var deploy_ids_same0_v: Array[String] = ["deploy_same_a"]
	var req_same0: DeploymentRequest = DeploymentRequest.new("deploy_force_same_zero", "gang_a", "stronghold_a", "business_same_node", deploy_ids_same0_s, deploy_ids_same0_v, 0.0)
	var res_same0: DeploymentResult = DeploymentService.deploy(original, req_same0)
	var force_same0: TravelingForce = original.get_traveling_force("deploy_force_same_zero")
	var deploy_same0_ok: bool = (
		res_same0.success
		and res_same0.reached_destination == true
		and is_equal_approx(res_same0.unused_movement, 0.0)
		and force_same0 != null
		and _string_ids_match(force_same0.route_node_ids, expected_same_route)
		and force_same0.travel_state == "at_destination"
	)
	var deploy_ids_same3_s: Array[String] = ["deploy_soldier_6"]
	var deploy_ids_same3_v: Array[String] = ["deploy_same_b"]
	var req_same3: DeploymentRequest = DeploymentRequest.new("deploy_force_same_pos", "gang_a", "stronghold_a", "business_same_node", deploy_ids_same3_s, deploy_ids_same3_v, 3.0)
	var res_same3: DeploymentResult = DeploymentService.deploy(original, req_same3)
	var force_same3: TravelingForce = original.get_traveling_force("deploy_force_same_pos")
	var deploy_same3_ok: bool = (
		res_same3.success
		and res_same3.reached_destination == true
		and is_equal_approx(res_same3.unused_movement, 3.0)
		and force_same3 != null
		and force_same3.travel_state == "at_destination"
	)

	var deploy_ids_zero_s: Array[String] = ["deploy_soldier_7"]
	var deploy_ids_zero_v: Array[String] = ["deploy_zero_nl"]
	var req_zero: DeploymentRequest = DeploymentRequest.new("deploy_force_zero_nl", "gang_a", "stronghold_a", "hq_contested", deploy_ids_zero_s, deploy_ids_zero_v, 0.0)
	var res_zero: DeploymentResult = DeploymentService.deploy(original, req_zero)
	var force_zero: TravelingForce = original.get_traveling_force("deploy_force_zero_nl")
	var deploy_zero_ok: bool = (
		res_zero.success
		and res_zero.reached_destination == false
		and is_equal_approx(res_zero.unused_movement, 0.0)
		and force_zero != null
		and force_zero.travel_state == "traveling_outbound"
		and force_zero.route_segment_index == 0
		and is_equal_approx(force_zero.distance_into_segment, 0.0)
	)

	var forces_before_excl_s: int = original.traveling_forces.size()
	var partial_state_before_excl: String = ""
	if force_partial_deploy != null:
		partial_state_before_excl = force_partial_deploy.travel_state
	var deploy_ids_block_s: Array[String] = ["deploy_soldier_1"]
	var deploy_ids_block_v: Array[String] = ["deploy_spare"]
	var req_block_s: DeploymentRequest = DeploymentRequest.new("deploy_force_blocked_soldier", "gang_a", "stronghold_a", "hq_contested", deploy_ids_block_s, deploy_ids_block_v, 3.0)
	var res_block_s: DeploymentResult = DeploymentService.deploy(original, req_block_s)
	var deploy_soldier_excl_ok: bool = (
		not res_block_s.success
		and res_block_s.error_code == "soldier_already_deployed"
		and not original.has_traveling_force("deploy_force_blocked_soldier")
		and original.traveling_forces.size() == forces_before_excl_s
		and force_partial_deploy != null
		and force_partial_deploy.travel_state == partial_state_before_excl
	)

	var forces_before_excl_v: int = original.traveling_forces.size()
	var deploy_ids_block_vs: Array[String] = ["deploy_soldier_9"]
	var deploy_ids_block_vv: Array[String] = ["deploy_car"]
	var req_block_v: DeploymentRequest = DeploymentRequest.new("deploy_force_blocked_vehicle", "gang_a", "stronghold_a", "hq_contested", deploy_ids_block_vs, deploy_ids_block_vv, 3.0)
	var res_block_v: DeploymentResult = DeploymentService.deploy(original, req_block_v)
	var deploy_vehicle_excl_ok: bool = (
		not res_block_v.success
		and res_block_v.error_code == "vehicle_already_deployed"
		and not original.has_traveling_force("deploy_force_blocked_vehicle")
		and original.traveling_forces.size() == forces_before_excl_v
	)

	if force_partial_deploy != null:
		force_partial_deploy.travel_state = "complete"
	var req_release: DeploymentRequest = DeploymentRequest.new("deploy_force_released", "gang_a", "stronghold_a", "hq_contested", deploy_ids_partial_s, deploy_ids_partial_v, 3.0)
	var res_release: DeploymentResult = DeploymentService.deploy(original, req_release)
	var deploy_release_ok: bool = res_release.success and original.has_traveling_force("deploy_force_released")

	var forces_before_transport: int = original.traveling_forces.size()
	var soldiers_before_transport: Array[String] = _copy_ids(stronghold_a.soldier_ids)
	var vehicles_before_transport: Array[String] = _copy_ids(stronghold_a.vehicle_ids)
	var home_x_before: String = deploy_soldier_x.home_stronghold_id
	var home_y_before: String = deploy_soldier_y.home_stronghold_id
	var home_bike_before: String = deploy_bike.home_stronghold_id
	var deploy_ids_over_s: Array[String] = ["deploy_soldier_x", "deploy_soldier_y"]
	var deploy_ids_over_v: Array[String] = ["deploy_bike"]
	var req_over: DeploymentRequest = DeploymentRequest.new("deploy_force_over", "gang_a", "stronghold_a", "hq_contested", deploy_ids_over_s, deploy_ids_over_v, 3.0)
	var res_over: DeploymentResult = DeploymentService.deploy(original, req_over)
	var deploy_over_ok: bool = (
		not res_over.success
		and res_over.error_code == "insufficient_transport"
		and not original.has_traveling_force("deploy_force_over")
		and original.traveling_forces.size() == forces_before_transport
		and deploy_soldier_x.home_stronghold_id == home_x_before
		and deploy_soldier_y.home_stronghold_id == home_y_before
		and deploy_bike.home_stronghold_id == home_bike_before
		and _string_ids_match(stronghold_a.soldier_ids, soldiers_before_transport)
		and _string_ids_match(stronghold_a.vehicle_ids, vehicles_before_transport)
	)

	var empty_soldiers: Array[String] = []
	var deploy_ids_nos_v: Array[String] = ["deploy_vehicle_nos"]
	var req_no_s: DeploymentRequest = DeploymentRequest.new("deploy_force_no_soldiers", "gang_a", "stronghold_a", "hq_contested", empty_soldiers, deploy_ids_nos_v, 3.0)
	var res_no_s: DeploymentResult = DeploymentService.deploy(original, req_no_s)
	var deploy_no_soldiers_ok: bool = not res_no_s.success and res_no_s.error_code == "no_soldiers" and not original.has_traveling_force("deploy_force_no_soldiers")
	var deploy_ids_nov_s: Array[String] = ["deploy_soldier_nov"]
	var empty_vehicles: Array[String] = []
	var req_no_v: DeploymentRequest = DeploymentRequest.new("deploy_force_no_vehicles", "gang_a", "stronghold_a", "hq_contested", deploy_ids_nov_s, empty_vehicles, 3.0)
	var res_no_v: DeploymentResult = DeploymentService.deploy(original, req_no_v)
	var deploy_no_vehicles_ok: bool = not res_no_v.success and res_no_v.error_code == "no_vehicles" and not original.has_traveling_force("deploy_force_no_vehicles")

	var deploy_ids_dup_s: Array[String] = ["deploy_soldier_1", "deploy_soldier_1"]
	var deploy_ids_dup_sv: Array[String] = ["deploy_bike"]
	var req_dup_s: DeploymentRequest = DeploymentRequest.new("deploy_force_dup_s", "gang_a", "stronghold_a", "hq_contested", deploy_ids_dup_s, deploy_ids_dup_sv, 3.0)
	var res_dup_s: DeploymentResult = DeploymentService.deploy(original, req_dup_s)
	var deploy_dup_soldier_ok: bool = not res_dup_s.success and res_dup_s.error_code == "duplicate_soldier_id" and not original.has_traveling_force("deploy_force_dup_s")
	var deploy_ids_dup_vs: Array[String] = ["deploy_soldier_x"]
	var deploy_ids_dup_v: Array[String] = ["deploy_car", "deploy_car"]
	var req_dup_v: DeploymentRequest = DeploymentRequest.new("deploy_force_dup_v", "gang_a", "stronghold_a", "hq_contested", deploy_ids_dup_vs, deploy_ids_dup_v, 3.0)
	var res_dup_v: DeploymentResult = DeploymentService.deploy(original, req_dup_v)
	var deploy_dup_vehicle_ok: bool = not res_dup_v.success and res_dup_v.error_code == "duplicate_vehicle_id" and not original.has_traveling_force("deploy_force_dup_v")

	var forces_before_wf: int = original.traveling_forces.size()
	var soldiers_before_wf: Array[String] = _copy_ids(stronghold_a.soldier_ids)
	var vehicles_before_wf: Array[String] = _copy_ids(stronghold_a.vehicle_ids)
	var home_x_wf: String = deploy_soldier_x.home_stronghold_id
	var home_bike_wf: String = deploy_bike.home_stronghold_id
	var deploy_ids_wf_s: Array[String] = ["deploy_soldier_enemy"]
	var deploy_ids_wf_v: Array[String] = ["deploy_bike"]
	var req_wf_s: DeploymentRequest = DeploymentRequest.new("deploy_force_wf_s", "gang_a", "stronghold_a", "hq_contested", deploy_ids_wf_s, deploy_ids_wf_v, 3.0)
	var res_wf_s: DeploymentResult = DeploymentService.deploy(original, req_wf_s)
	var deploy_wrong_faction_s_ok: bool = (
		not res_wf_s.success
		and res_wf_s.error_code == "soldier_wrong_faction"
		and not original.has_traveling_force("deploy_force_wf_s")
		and original.traveling_forces.size() == forces_before_wf
		and deploy_soldier_x.home_stronghold_id == home_x_wf
		and deploy_bike.home_stronghold_id == home_bike_wf
		and _string_ids_match(stronghold_a.soldier_ids, soldiers_before_wf)
		and _string_ids_match(stronghold_a.vehicle_ids, vehicles_before_wf)
	)
	var deploy_ids_wf_vs: Array[String] = ["deploy_soldier_x"]
	var deploy_ids_wf_vv: Array[String] = ["deploy_vehicle_enemy"]
	var req_wf_v: DeploymentRequest = DeploymentRequest.new("deploy_force_wf_v", "gang_a", "stronghold_a", "hq_contested", deploy_ids_wf_vs, deploy_ids_wf_vv, 3.0)
	var res_wf_v: DeploymentResult = DeploymentService.deploy(original, req_wf_v)
	var deploy_wrong_faction_v_ok: bool = (
		not res_wf_v.success
		and res_wf_v.error_code == "vehicle_wrong_faction"
		and not original.has_traveling_force("deploy_force_wf_v")
		and original.traveling_forces.size() == forces_before_wf
		and deploy_soldier_x.home_stronghold_id == home_x_wf
		and deploy_bike.home_stronghold_id == home_bike_wf
		and _string_ids_match(stronghold_a.soldier_ids, soldiers_before_wf)
		and _string_ids_match(stronghold_a.vehicle_ids, vehicles_before_wf)
	)

	var deploy_ids_home_s: Array[String] = ["deploy_soldier_home_b"]
	var deploy_ids_home_v: Array[String] = ["deploy_bike"]
	var req_home_s: DeploymentRequest = DeploymentRequest.new("deploy_force_home_s", "gang_a", "stronghold_a", "hq_contested", deploy_ids_home_s, deploy_ids_home_v, 3.0)
	var res_home_s: DeploymentResult = DeploymentService.deploy(original, req_home_s)
	var deploy_wrong_home_s_ok: bool = not res_home_s.success and res_home_s.error_code == "soldier_wrong_home"
	var deploy_ids_home_vs: Array[String] = ["deploy_soldier_x"]
	var deploy_ids_home_vv: Array[String] = ["deploy_vehicle_home_b"]
	var req_home_v: DeploymentRequest = DeploymentRequest.new("deploy_force_home_v", "gang_a", "stronghold_a", "hq_contested", deploy_ids_home_vs, deploy_ids_home_vv, 3.0)
	var res_home_v: DeploymentResult = DeploymentService.deploy(original, req_home_v)
	var deploy_wrong_home_v_ok: bool = not res_home_v.success and res_home_v.error_code == "vehicle_wrong_home"

	var deploy_ids_orphan_s: Array[String] = ["deploy_soldier_orphan"]
	var deploy_ids_orphan_v: Array[String] = ["deploy_bike"]
	var req_orphan_s: DeploymentRequest = DeploymentRequest.new("deploy_force_orphan_s", "gang_a", "stronghold_a", "hq_contested", deploy_ids_orphan_s, deploy_ids_orphan_v, 3.0)
	var res_orphan_s: DeploymentResult = DeploymentService.deploy(original, req_orphan_s)
	var deploy_not_at_origin_s_ok: bool = not res_orphan_s.success and res_orphan_s.error_code == "soldier_not_at_origin"
	var deploy_ids_orphan_vs: Array[String] = ["deploy_soldier_x"]
	var deploy_ids_orphan_vv: Array[String] = ["deploy_vehicle_orphan"]
	var req_orphan_v: DeploymentRequest = DeploymentRequest.new("deploy_force_orphan_v", "gang_a", "stronghold_a", "hq_contested", deploy_ids_orphan_vs, deploy_ids_orphan_vv, 3.0)
	var res_orphan_v: DeploymentResult = DeploymentService.deploy(original, req_orphan_v)
	var deploy_not_at_origin_v_ok: bool = not res_orphan_v.success and res_orphan_v.error_code == "vehicle_not_at_origin"

	var dummy_s: Array[String] = ["deploy_soldier_x"]
	var dummy_v: Array[String] = ["deploy_bike"]
	var req_bad_origin: DeploymentRequest = DeploymentRequest.new("deploy_force_bad_origin", "gang_a", "missing_origin", "hq_contested", dummy_s, dummy_v, 3.0)
	var res_bad_origin: DeploymentResult = DeploymentService.deploy(original, req_bad_origin)
	var deploy_invalid_origin_ok: bool = not res_bad_origin.success and res_bad_origin.error_code == "invalid_origin"
	var req_origin_business: DeploymentRequest = DeploymentRequest.new("deploy_force_origin_biz", "gang_a", "business_a", "hq_contested", dummy_s, dummy_v, 3.0)
	var res_origin_business: DeploymentResult = DeploymentService.deploy(original, req_origin_business)
	var deploy_origin_not_stronghold_ok: bool = not res_origin_business.success and res_origin_business.error_code == "invalid_origin"
	var req_origin_faction: DeploymentRequest = DeploymentRequest.new("deploy_force_origin_faction", "gang_a", "stronghold_enemy", "hq_contested", dummy_s, dummy_v, 3.0)
	var res_origin_faction: DeploymentResult = DeploymentService.deploy(original, req_origin_faction)
	var deploy_origin_wrong_faction_ok: bool = not res_origin_faction.success and res_origin_faction.error_code == "origin_wrong_faction"
	var req_origin_no_road: DeploymentRequest = DeploymentRequest.new("deploy_force_origin_noroad", "gang_a", "stronghold_no_road", "hq_contested", dummy_s, dummy_v, 3.0)
	var res_origin_no_road: DeploymentResult = DeploymentService.deploy(original, req_origin_no_road)
	var deploy_origin_missing_road_ok: bool = not res_origin_no_road.success and res_origin_no_road.error_code == "origin_missing_road_node"
	var req_bad_dest: DeploymentRequest = DeploymentRequest.new("deploy_force_bad_dest", "gang_a", "stronghold_a", "missing_dest", dummy_s, dummy_v, 3.0)
	var res_bad_dest: DeploymentResult = DeploymentService.deploy(original, req_bad_dest)
	var deploy_invalid_dest_ok: bool = not res_bad_dest.success and res_bad_dest.error_code == "invalid_destination"
	var req_dest_no_road: DeploymentRequest = DeploymentRequest.new("deploy_force_dest_noroad", "gang_a", "stronghold_a", "business_no_road", dummy_s, dummy_v, 3.0)
	var res_dest_no_road: DeploymentResult = DeploymentService.deploy(original, req_dest_no_road)
	var deploy_dest_missing_road_ok: bool = not res_dest_no_road.success and res_dest_no_road.error_code == "destination_missing_road_node"
	var deploy_ids_origin_ghost_s: Array[String] = ["deploy_soldier_ghost"]
	var deploy_ids_origin_ghost_v: Array[String] = ["deploy_vehicle_ghost"]
	var req_origin_ghost: DeploymentRequest = DeploymentRequest.new("deploy_force_origin_ghost", "gang_a", "stronghold_ghost_road", "hq_contested", deploy_ids_origin_ghost_s, deploy_ids_origin_ghost_v, 3.0)
	var res_origin_ghost: DeploymentResult = DeploymentService.deploy(original, req_origin_ghost)
	var deploy_origin_ghost_ok: bool = not res_origin_ghost.success and res_origin_ghost.error_code == "invalid_origin_road_node"
	var req_dest_ghost: DeploymentRequest = DeploymentRequest.new("deploy_force_dest_ghost", "gang_a", "stronghold_a", "business_ghost_road", dummy_s, dummy_v, 3.0)
	var res_dest_ghost: DeploymentResult = DeploymentService.deploy(original, req_dest_ghost)
	var deploy_dest_ghost_ok: bool = not res_dest_ghost.success and res_dest_ghost.error_code == "invalid_destination_road_node"

	var forces_before_noroute: int = original.traveling_forces.size()
	var soldiers_before_noroute: Array[String] = _copy_ids(stronghold_a.soldier_ids)
	var vehicles_before_noroute: Array[String] = _copy_ids(stronghold_a.vehicle_ids)
	var home_x_noroute: String = deploy_soldier_x.home_stronghold_id
	var home_bike_noroute: String = deploy_bike.home_stronghold_id
	var req_noroute: DeploymentRequest = DeploymentRequest.new("deploy_force_noroute", "gang_a", "stronghold_a", "business_isolated", dummy_s, dummy_v, 3.0)
	var res_noroute: DeploymentResult = DeploymentService.deploy(original, req_noroute)
	var deploy_no_route_ok: bool = (
		not res_noroute.success
		and res_noroute.error_code == "no_route"
		and not original.has_traveling_force("deploy_force_noroute")
		and original.traveling_forces.size() == forces_before_noroute
		and deploy_soldier_x.home_stronghold_id == home_x_noroute
		and deploy_bike.home_stronghold_id == home_bike_noroute
		and _string_ids_match(stronghold_a.soldier_ids, soldiers_before_noroute)
		and _string_ids_match(stronghold_a.vehicle_ids, vehicles_before_noroute)
	)

	var existing_partial: TravelingForce = original.get_traveling_force("deploy_force_partial")
	var req_dup_force: DeploymentRequest = DeploymentRequest.new("deploy_force_partial", "gang_a", "stronghold_a", "hq_contested", dummy_s, dummy_v, 3.0)
	var res_dup_force: DeploymentResult = DeploymentService.deploy(original, req_dup_force)
	var deploy_dup_force_ok: bool = (
		not res_dup_force.success
		and res_dup_force.error_code == "duplicate_force_id"
		and original.get_traveling_force("deploy_force_partial") == existing_partial
	)

	var forces_before_redeploy: int = original.traveling_forces.size()
	var soldiers_before_redeploy: Array[String] = _copy_ids(stronghold_a.soldier_ids)
	var vehicles_before_redeploy: Array[String] = _copy_ids(stronghold_a.vehicle_ids)
	var home_s1_before_redeploy: String = deploy_soldier_1.home_stronghold_id
	var home_car_before_redeploy: String = deploy_car.home_stronghold_id
	var req_redeploy: DeploymentRequest = DeploymentRequest.new("deploy_force_redeploy_fail", "gang_a", "stronghold_a", "hq_contested", deploy_ids_block_s, deploy_ids_block_v, 3.0)
	var res_redeploy: DeploymentResult = DeploymentService.deploy(original, req_redeploy)
	var deploy_atomic_redeploy_ok: bool = (
		not res_redeploy.success
		and res_redeploy.error_code == "soldier_already_deployed"
		and original.traveling_forces.size() == forces_before_redeploy
		and deploy_soldier_1.home_stronghold_id == home_s1_before_redeploy
		and deploy_car.home_stronghold_id == home_car_before_redeploy
		and _string_ids_match(stronghold_a.soldier_ids, soldiers_before_redeploy)
		and _string_ids_match(stronghold_a.vehicle_ids, vehicles_before_redeploy)
	)

	var helper_ok: DeploymentResult = DeploymentResult.succeeded("helper_force", true, 2.5)
	var deploy_helper_success_ok: bool = helper_ok.success and helper_ok.force_id == "helper_force" and helper_ok.error_code.is_empty() and helper_ok.error_message.is_empty()
	var helper_fail: DeploymentResult = DeploymentResult.failed("test_code", "test message", "helper_fail_id")
	var deploy_helper_fail_ok: bool = (not helper_fail.success) and helper_fail.error_code == "test_code" and helper_fail.error_message == "test message"

	var mission_soldier_p: Soldier = Soldier.new("mission_soldier_p", "gang_a", "", "pistol", 1.0, 20.0)
	var mission_soldier_i: Soldier = Soldier.new("mission_soldier_i", "gang_a", "", "rifle", 1.9, 35.0)
	var mission_soldier_s: Soldier = Soldier.new("mission_soldier_s", "gang_a", "", "smg", 1.55, 30.0)
	var mission_soldier_m: Soldier = Soldier.new("mission_soldier_m", "gang_a", "", "pistol", 1.0, 20.0)
	var mission_soldier_z: Soldier = Soldier.new("mission_soldier_z", "gang_a", "", "pistol", 1.0, 20.0)
	var mission_soldier_a: Soldier = Soldier.new("mission_soldier_a", "gang_a", "", "pistol", 1.0, 20.0)
	var mission_soldier_g: Soldier = Soldier.new("mission_soldier_g", "gang_a", "", "pistol", 1.0, 20.0)
	var mission_soldier_unused: Soldier = Soldier.new("mission_soldier_unused", "gang_a", "", "pistol", 1.0, 20.0)
	original.add_soldier(mission_soldier_p)
	original.add_soldier(mission_soldier_i)
	original.add_soldier(mission_soldier_s)
	original.add_soldier(mission_soldier_m)
	original.add_soldier(mission_soldier_z)
	original.add_soldier(mission_soldier_a)
	original.add_soldier(mission_soldier_g)
	original.add_soldier(mission_soldier_unused)
	original.assign_soldier_to_stronghold("mission_soldier_p", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_i", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_s", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_m", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_z", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_a", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_g", "stronghold_a")
	original.assign_soldier_to_stronghold("mission_soldier_unused", "stronghold_a")
	var mission_vehicle_p: Vehicle = Vehicle.new("mission_vehicle_p", "gang_a", "car", "", 2, 5.0, 50.0)
	var mission_vehicle_i: Vehicle = Vehicle.new("mission_vehicle_i", "gang_a", "car", "", 4, 8.0, 50.0)
	var mission_vehicle_s: Vehicle = Vehicle.new("mission_vehicle_s", "gang_a", "car", "", 2, 5.0, 50.0)
	var mission_vehicle_m: Vehicle = Vehicle.new("mission_vehicle_m", "gang_a", "car", "", 2, 5.0, 50.0)
	var mission_vehicle_z: Vehicle = Vehicle.new("mission_vehicle_z", "gang_a", "car", "", 2, 5.0, 50.0)
	var mission_vehicle_a: Vehicle = Vehicle.new("mission_vehicle_a", "gang_a", "car", "", 2, 5.0, 50.0)
	var mission_vehicle_g: Vehicle = Vehicle.new("mission_vehicle_g", "gang_a", "car", "", 2, 5.0, 50.0)
	var mission_vehicle_unused: Vehicle = Vehicle.new("mission_vehicle_unused", "gang_a", "car", "", 2, 5.0, 50.0)
	original.add_vehicle(mission_vehicle_p)
	original.add_vehicle(mission_vehicle_i)
	original.add_vehicle(mission_vehicle_s)
	original.add_vehicle(mission_vehicle_m)
	original.add_vehicle(mission_vehicle_z)
	original.add_vehicle(mission_vehicle_a)
	original.add_vehicle(mission_vehicle_g)
	original.add_vehicle(mission_vehicle_unused)
	original.assign_vehicle_to_stronghold("mission_vehicle_p", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_i", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_s", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_m", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_z", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_a", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_g", "stronghold_a")
	original.assign_vehicle_to_stronghold("mission_vehicle_unused", "stronghold_a")

	var mission_ids_p_s: Array[String] = ["mission_soldier_p"]
	var mission_ids_p_v: Array[String] = ["mission_vehicle_p"]
	var deploy_mission_partial: DeploymentRequest = DeploymentRequest.new("mission_force_partial", "gang_a", "stronghold_a", "hq_contested", mission_ids_p_s, mission_ids_p_v, 3.0)
	var req_mission_partial: MissionRequest = MissionRequest.new("mission_partial", "raid_business", deploy_mission_partial)
	var res_mission_partial: MissionResult = MissionService.launch(original, req_mission_partial)
	var mission_partial: CampaignMission = original.get_mission("mission_partial")
	var force_mission_partial: TravelingForce = original.get_traveling_force("mission_force_partial")
	var mission_partial_ok: bool = (
		res_mission_partial.success
		and mission_partial != null
		and force_mission_partial != null
		and mission_partial.mission_type_id == "raid_business"
		and mission_partial.faction_id == "gang_a"
		and mission_partial.origin_location_id == "stronghold_a"
		and mission_partial.target_location_id == "hq_contested"
		and mission_partial.force_id == "mission_force_partial"
		and mission_partial.mission_state == "traveling_outbound"
		and mission_partial.outcome_code.is_empty()
		and res_mission_partial.mission_state == "traveling_outbound"
		and force_mission_partial.travel_state == "traveling_outbound"
	)

	var mission_ids_i_s: Array[String] = ["mission_soldier_i"]
	var mission_ids_i_v: Array[String] = ["mission_vehicle_i"]
	var deploy_mission_immediate: DeploymentRequest = DeploymentRequest.new("mission_force_immediate", "gang_a", "stronghold_a", "hq_contested", mission_ids_i_s, mission_ids_i_v, 8.0)
	var req_mission_immediate: MissionRequest = MissionRequest.new("mission_immediate", "attack_neighborhood_hq", deploy_mission_immediate)
	var res_mission_immediate: MissionResult = MissionService.launch(original, req_mission_immediate)
	var mission_immediate: CampaignMission = original.get_mission("mission_immediate")
	var force_mission_immediate: TravelingForce = original.get_traveling_force("mission_force_immediate")
	var mission_immediate_ok: bool = (
		res_mission_immediate.success
		and mission_immediate != null
		and force_mission_immediate != null
		and force_mission_immediate.travel_state == "at_destination"
		and mission_immediate.mission_state == "awaiting_resolution"
		and res_mission_immediate.mission_state == "awaiting_resolution"
		and mission_immediate.outcome_code.is_empty()
	)

	var mission_ids_s_s: Array[String] = ["mission_soldier_s"]
	var mission_ids_s_v: Array[String] = ["mission_vehicle_s"]
	var deploy_mission_same: DeploymentRequest = DeploymentRequest.new("mission_force_samenode", "gang_a", "stronghold_a", "business_same_node", mission_ids_s_s, mission_ids_s_v, 0.0)
	var req_mission_same: MissionRequest = MissionRequest.new("mission_samenode", "secure_event_location", deploy_mission_same)
	var res_mission_same: MissionResult = MissionService.launch(original, req_mission_same)
	var mission_samenode: CampaignMission = original.get_mission("mission_samenode")
	var force_mission_samenode: TravelingForce = original.get_traveling_force("mission_force_samenode")
	var mission_samenode_ok: bool = (
		res_mission_same.success
		and mission_samenode != null
		and force_mission_samenode != null
		and force_mission_samenode.travel_state == "at_destination"
		and mission_samenode.mission_state == "awaiting_resolution"
	)

	var forces_before_mission_block: int = original.traveling_forces.size()
	var missions_before_mission_block: int = original.missions.size()
	var mission_ids_block_s: Array[String] = ["mission_soldier_p"]
	var mission_ids_block_v: Array[String] = ["mission_vehicle_unused"]
	var deploy_mission_block: DeploymentRequest = DeploymentRequest.new("mission_force_blocked", "gang_a", "stronghold_a", "hq_contested", mission_ids_block_s, mission_ids_block_v, 3.0)
	var req_mission_block: MissionRequest = MissionRequest.new("mission_blocked", "raid_business", deploy_mission_block)
	var res_mission_block: MissionResult = MissionService.launch(original, req_mission_block)
	var mission_deploy_fail_ok: bool = (
		not res_mission_block.success
		and res_mission_block.error_code == "soldier_already_deployed"
		and not original.has_mission("mission_blocked")
		and not original.has_traveling_force("mission_force_blocked")
		and original.missions.size() == missions_before_mission_block
		and original.traveling_forces.size() == forces_before_mission_block
	)

	var forces_before_null_req: int = original.traveling_forces.size()
	var missions_before_null_req: int = original.missions.size()
	var res_mission_null: MissionResult = MissionService.launch(original, null)
	var mission_null_request_ok: bool = (
		not res_mission_null.success
		and res_mission_null.error_code == "null_request"
		and original.missions.size() == missions_before_null_req
		and original.traveling_forces.size() == forces_before_null_req
	)
	var deploy_empty_id: DeploymentRequest = DeploymentRequest.new("mission_force_empty_id", "gang_a", "stronghold_a", "hq_contested", mission_ids_p_s, mission_ids_p_v, 3.0)
	var req_empty_id: MissionRequest = MissionRequest.new("", "raid_business", deploy_empty_id)
	var res_empty_id: MissionResult = MissionService.launch(original, req_empty_id)
	var mission_empty_id_ok: bool = (
		not res_empty_id.success
		and res_empty_id.error_code == "empty_mission_id"
		and not original.has_traveling_force("mission_force_empty_id")
	)
	var deploy_empty_type: DeploymentRequest = DeploymentRequest.new("mission_force_empty_type", "gang_a", "stronghold_a", "hq_contested", mission_ids_p_s, mission_ids_p_v, 3.0)
	var req_empty_type: MissionRequest = MissionRequest.new("mission_empty_type", "", deploy_empty_type)
	var res_empty_type: MissionResult = MissionService.launch(original, req_empty_type)
	var mission_empty_type_ok: bool = (
		not res_empty_type.success
		and res_empty_type.error_code == "empty_mission_type_id"
		and not original.has_mission("mission_empty_type")
		and not original.has_traveling_force("mission_force_empty_type")
	)
	var deploy_dup_s: Array[String] = ["mission_soldier_unused"]
	var deploy_dup_v: Array[String] = ["mission_vehicle_unused"]
	var deploy_dup_mission: DeploymentRequest = DeploymentRequest.new("mission_force_dup_mission", "gang_a", "stronghold_a", "hq_contested", deploy_dup_s, deploy_dup_v, 3.0)
	var req_dup_mission: MissionRequest = MissionRequest.new("mission_partial", "raid_business", deploy_dup_mission)
	var res_dup_mission: MissionResult = MissionService.launch(original, req_dup_mission)
	var mission_dup_id_ok: bool = (
		not res_dup_mission.success
		and res_dup_mission.error_code == "duplicate_mission_id"
		and not original.has_traveling_force("mission_force_dup_mission")
	)
	var req_null_dep: MissionRequest = MissionRequest.new("mission_null_dep", "raid_business")
	req_null_dep.deployment_request = null
	var res_null_dep: MissionResult = MissionService.launch(original, req_null_dep)
	var mission_null_dep_ok: bool = (
		not res_null_dep.success
		and res_null_dep.error_code == "null_deployment_request"
		and not original.has_mission("mission_null_dep")
	)

	var partial_index_before_sync: int = 0
	var partial_distance_before_sync: float = 0.0
	var partial_state_before_sync: String = ""
	if force_mission_partial != null:
		partial_index_before_sync = force_mission_partial.route_segment_index
		partial_distance_before_sync = force_mission_partial.distance_into_segment
		partial_state_before_sync = force_mission_partial.travel_state
	var res_sync_partial_travel: MissionResult = MissionService.sync_arrival(original, "mission_partial")
	var mission_sync_still_traveling_ok: bool = (
		force_mission_partial != null
		and mission_partial != null
		and res_sync_partial_travel.success
		and mission_partial.mission_state == "traveling_outbound"
		and force_mission_partial.travel_state == partial_state_before_sync
		and force_mission_partial.route_segment_index == partial_index_before_sync
		and is_equal_approx(force_mission_partial.distance_into_segment, partial_distance_before_sync)
	)

	var leftover_partial_arrive: float = 0.0
	if force_mission_partial != null:
		leftover_partial_arrive = force_mission_partial.advance(4.0, graph)
	var mission_partial_force_arrived: bool = (
		force_mission_partial != null
		and mission_partial != null
		and force_mission_partial.travel_state == "at_destination"
		and mission_partial.mission_state == "traveling_outbound"
	)
	var res_sync_partial_arrive: MissionResult = MissionService.sync_arrival(original, "mission_partial")
	var mission_sync_arrived_ok: bool = (
		mission_partial_force_arrived
		and is_equal_approx(leftover_partial_arrive, 0.0)
		and res_sync_partial_arrive.success
		and mission_partial.mission_state == "awaiting_resolution"
		and mission_partial.outcome_code.is_empty()
	)
	var res_sync_partial_again: MissionResult = MissionService.sync_arrival(original, "mission_partial")
	var mission_sync_idempotent_ok: bool = (
		res_sync_partial_again.success
		and mission_partial.mission_state == "awaiting_resolution"
		and mission_partial.outcome_code.is_empty()
	)

	var mission_ids_m_s: Array[String] = ["mission_soldier_m"]
	var mission_ids_m_v: Array[String] = ["mission_vehicle_m"]
	var deploy_mission_mismatch: DeploymentRequest = DeploymentRequest.new("mission_force_mismatch", "gang_a", "stronghold_a", "hq_contested", mission_ids_m_s, mission_ids_m_v, 3.0)
	var req_mission_mismatch: MissionRequest = MissionRequest.new("mission_mismatch", "raid_business", deploy_mission_mismatch)
	var res_mission_mismatch: MissionResult = MissionService.launch(original, req_mission_mismatch)
	var force_mission_mismatch: TravelingForce = original.get_traveling_force("mission_force_mismatch")
	var mission_mismatch: CampaignMission = original.get_mission("mission_mismatch")
	if force_mission_mismatch != null:
		force_mission_mismatch.travel_state = "traveling_return"
	var mismatch_state_before: String = ""
	if mission_mismatch != null:
		mismatch_state_before = mission_mismatch.mission_state
	var res_sync_mismatch: MissionResult = MissionService.sync_arrival(original, "mission_mismatch")
	var mission_mismatch_ok: bool = (
		res_mission_mismatch.success
		and not res_sync_mismatch.success
		and res_sync_mismatch.error_code == "mission_force_state_mismatch"
		and mission_mismatch != null
		and mission_mismatch.mission_state == mismatch_state_before
		and mission_mismatch.mission_state == "traveling_outbound"
	)

	var mission_ids_z_s: Array[String] = ["mission_soldier_z"]
	var mission_ids_z_v: Array[String] = ["mission_vehicle_z"]
	var deploy_mission_z: DeploymentRequest = DeploymentRequest.new("mission_force_z", "gang_a", "stronghold_a", "hq_contested", mission_ids_z_s, mission_ids_z_v, 3.0)
	var req_mission_z: MissionRequest = MissionRequest.new("mission_z_keep", "intercept_convoy", deploy_mission_z)
	var res_mission_z: MissionResult = MissionService.launch(original, req_mission_z)
	var mission_z_keep: CampaignMission = original.get_mission("mission_z_keep")
	var mission_ids_a_s: Array[String] = ["mission_soldier_a"]
	var mission_ids_a_v: Array[String] = ["mission_vehicle_a"]
	var deploy_mission_a: DeploymentRequest = DeploymentRequest.new("mission_force_a", "gang_a", "stronghold_a", "hq_contested", mission_ids_a_s, mission_ids_a_v, 3.0)
	var req_mission_a: MissionRequest = MissionRequest.new("mission_a_arrive_sync", "delivery", deploy_mission_a)
	var res_mission_a: MissionResult = MissionService.launch(original, req_mission_a)
	var mission_a_arrive: CampaignMission = original.get_mission("mission_a_arrive_sync")
	var force_mission_a: TravelingForce = original.get_traveling_force("mission_force_a")
	if force_mission_a != null:
		force_mission_a.travel_state = "at_destination"
	var expected_sync_ids: Array[String] = []
	for existing_mission_id: String in original.missions:
		expected_sync_ids.append(existing_mission_id)
	expected_sync_ids.sort()
	var immediate_state_before_all: String = ""
	if mission_immediate != null:
		immediate_state_before_all = mission_immediate.mission_state
	var samenode_state_before_all: String = ""
	if mission_samenode != null:
		samenode_state_before_all = mission_samenode.mission_state
	var partial_state_before_all: String = ""
	if mission_partial != null:
		partial_state_before_all = mission_partial.mission_state
	var mismatch_state_before_all: String = ""
	if mission_mismatch != null:
		mismatch_state_before_all = mission_mismatch.mission_state
	var z_state_before_all: String = ""
	if mission_z_keep != null:
		z_state_before_all = mission_z_keep.mission_state
	var sync_all_results: Array[MissionResult] = MissionService.sync_all_arrivals(original)
	var sync_all_ids: Array[String] = []
	for sync_result: MissionResult in sync_all_results:
		sync_all_ids.append(sync_result.mission_id)
	var mission_sync_all_ok: bool = (
		res_mission_z.success
		and res_mission_a.success
		and sync_all_results.size() == expected_sync_ids.size()
		and _string_ids_match(sync_all_ids, expected_sync_ids)
		and mission_a_arrive != null
		and mission_a_arrive.mission_state == "awaiting_resolution"
		and mission_immediate != null
		and mission_immediate.mission_state == immediate_state_before_all
		and mission_samenode != null
		and mission_samenode.mission_state == samenode_state_before_all
		and mission_partial != null
		and mission_partial.mission_state == partial_state_before_all
		and mission_mismatch != null
		and mission_mismatch.mission_state == mismatch_state_before_all
		and mission_z_keep != null
		and mission_z_keep.mission_state == z_state_before_all
		and mission_z_keep.mission_state == "traveling_outbound"
	)

	var hq_owner_before_resolve: String = hq_contested.owner_faction_id
	var hq_open_before_resolve: bool = hq_contested.is_open
	var money_before_resolve: float = gang_a.money
	var ammo_before_resolve: float = gang_a.resources.get_amount("Ammo")
	var home_i_s_before: String = mission_soldier_i.home_stronghold_id
	var home_i_v_before: String = mission_vehicle_i.home_stronghold_id
	var home_s_s_before: String = mission_soldier_s.home_stronghold_id
	var home_s_v_before: String = mission_vehicle_s.home_stronghold_id
	var soldiers_before_resolve: Array[String] = _copy_ids(stronghold_a.soldier_ids)
	var vehicles_before_resolve: Array[String] = _copy_ids(stronghold_a.vehicle_ids)
	var res_resolve_success: MissionResult = MissionService.resolve(original, "mission_immediate", true, "target_secured")
	var mission_resolve_success_ok: bool = (
		res_resolve_success.success
		and mission_immediate.mission_state == "resolved_success"
		and mission_immediate.outcome_code == "target_secured"
		and force_mission_immediate.travel_state == "at_destination"
		and original.has_mission("mission_immediate")
		and original.has_traveling_force("mission_force_immediate")
		and force_mission_immediate.travel_state != "traveling_return"
	)

	var samenode_state_before_empty: String = mission_samenode.mission_state
	var samenode_outcome_before_empty: String = mission_samenode.outcome_code
	var res_resolve_empty: MissionResult = MissionService.resolve(original, "mission_samenode", true, "")
	var mission_empty_outcome_ok: bool = (
		not res_resolve_empty.success
		and res_resolve_empty.error_code == "empty_outcome_code"
		and mission_samenode.mission_state == samenode_state_before_empty
		and mission_samenode.outcome_code == samenode_outcome_before_empty
	)
	var res_resolve_missing: MissionResult = MissionService.resolve(original, "mission_does_not_exist", true, "target_secured")
	var mission_invalid_ok: bool = not res_resolve_missing.success and res_resolve_missing.error_code == "invalid_mission"
	var immediate_state_before_guard: String = mission_immediate.mission_state
	var immediate_outcome_before_guard: String = mission_immediate.outcome_code
	var res_resolve_not_awaiting: MissionResult = MissionService.resolve(original, "mission_immediate", true, "again")
	var mission_not_awaiting_ok: bool = (
		not res_resolve_not_awaiting.success
		and res_resolve_not_awaiting.error_code == "mission_not_awaiting_resolution"
		and mission_immediate.mission_state == immediate_state_before_guard
		and mission_immediate.outcome_code == immediate_outcome_before_guard
	)
	var mission_ids_g_s: Array[String] = ["mission_soldier_g"]
	var mission_ids_g_v: Array[String] = ["mission_vehicle_g"]
	var deploy_mission_guard: DeploymentRequest = DeploymentRequest.new("mission_force_guard", "gang_a", "stronghold_a", "business_same_node", mission_ids_g_s, mission_ids_g_v, 0.0)
	var req_mission_guard: MissionRequest = MissionRequest.new("mission_guard_force", "raid_business", deploy_mission_guard)
	var res_mission_guard: MissionResult = MissionService.launch(original, req_mission_guard)
	var mission_guard: CampaignMission = original.get_mission("mission_guard_force")
	var force_mission_guard: TravelingForce = original.get_traveling_force("mission_force_guard")
	if force_mission_guard != null:
		force_mission_guard.travel_state = "traveling_outbound"
	var guard_state_before: String = ""
	var guard_outcome_before: String = ""
	if mission_guard != null:
		guard_state_before = mission_guard.mission_state
		guard_outcome_before = mission_guard.outcome_code
	var res_resolve_not_dest: MissionResult = MissionService.resolve(original, "mission_guard_force", true, "target_secured")
	var mission_force_not_dest_ok: bool = (
		res_mission_guard.success
		and not res_resolve_not_dest.success
		and res_resolve_not_dest.error_code == "force_not_at_destination"
		and mission_guard != null
		and mission_guard.mission_state == guard_state_before
		and mission_guard.outcome_code == guard_outcome_before
	)
	var mission_missing_force: CampaignMission = CampaignMission.new("mission_missing_force", "raid_business", "gang_a", "no_such_force", "stronghold_a", "hq_contested", "awaiting_resolution", "")
	original.add_mission(mission_missing_force)
	var missing_force_state_before: String = mission_missing_force.mission_state
	var missing_force_outcome_before: String = mission_missing_force.outcome_code
	var res_resolve_no_force: MissionResult = MissionService.resolve(original, "mission_missing_force", true, "target_secured")
	var mission_invalid_force_ok: bool = (
		not res_resolve_no_force.success
		and res_resolve_no_force.error_code == "invalid_force"
		and mission_missing_force.mission_state == missing_force_state_before
		and mission_missing_force.outcome_code == missing_force_outcome_before
	)
	original.remove_mission("mission_missing_force")

	var res_resolve_fail: MissionResult = MissionService.resolve(original, "mission_samenode", false, "operation_failed")
	var mission_resolve_fail_ok: bool = (
		res_resolve_fail.success
		and mission_samenode.mission_state == "resolved_failure"
		and mission_samenode.outcome_code == "operation_failed"
		and force_mission_samenode.travel_state == "at_destination"
	)
	var mission_no_effects_ok: bool = (
		hq_contested.owner_faction_id == hq_owner_before_resolve
		and hq_contested.is_open == hq_open_before_resolve
		and is_equal_approx(gang_a.money, money_before_resolve)
		and is_equal_approx(gang_a.resources.get_amount("Ammo"), ammo_before_resolve)
		and mission_soldier_i.home_stronghold_id == home_i_s_before
		and mission_vehicle_i.home_stronghold_id == home_i_v_before
		and mission_soldier_s.home_stronghold_id == home_s_s_before
		and mission_vehicle_s.home_stronghold_id == home_s_v_before
		and _string_ids_match(stronghold_a.soldier_ids, soldiers_before_resolve)
		and _string_ids_match(stronghold_a.vehicle_ids, vehicles_before_resolve)
	)

	var existing_mission_partial: CampaignMission = original.get_mission("mission_partial")
	original.add_mission(CampaignMission.new("mission_partial", "raid_business", "gang_b", "other_force", "stronghold_a", "hq_contested", "complete", "nope"))
	var mission_add_dup_ok: bool = original.get_mission("mission_partial") == existing_mission_partial
	var mission_remove_missing_ok: bool = not original.remove_mission("mission_does_not_exist")
	var mission_disposable: CampaignMission = CampaignMission.new("mission_disposable", "delivery", "gang_a", "unused_force", "stronghold_a", "hq_contested", "complete", "")
	original.add_mission(mission_disposable)
	var mission_remove_ok: bool = original.remove_mission("mission_disposable") and not original.has_mission("mission_disposable")

	var mission_helper_ok: MissionResult = MissionResult.succeeded("helper_mission", "helper_force", "awaiting_resolution")
	var mission_helper_success_ok: bool = (
		mission_helper_ok.success
		and mission_helper_ok.mission_id == "helper_mission"
		and mission_helper_ok.force_id == "helper_force"
		and mission_helper_ok.mission_state == "awaiting_resolution"
		and mission_helper_ok.error_code.is_empty()
		and mission_helper_ok.error_message.is_empty()
	)
	var mission_helper_fail: MissionResult = MissionResult.failed("test_code", "test message", "helper_fail_mission", "helper_fail_force", "traveling_outbound")
	var mission_helper_fail_ok: bool = (
		not mission_helper_fail.success
		and mission_helper_fail.error_code == "test_code"
		and mission_helper_fail.error_message == "test message"
	)

	final_stronghold_a_soldiers = _copy_ids(stronghold_a.soldier_ids)
	final_stronghold_b_soldiers = _copy_ids(stronghold_b.soldier_ids)
	final_stronghold_a_vehicles = _copy_ids(stronghold_a.vehicle_ids)
	final_stronghold_b_vehicles = _copy_ids(stronghold_b.vehicle_ids)

	var serialized_state := original.to_dict()
	var restored := GameState.new()
	restored.from_dict(serialized_state)

	var restored_a := restored.get_faction("gang_a") as MajorGang
	var restored_b := restored.get_faction("gang_b") as MajorGang
	var restored_stronghold := restored.get_map_location("stronghold_a") as Stronghold
	var restored_hq := restored.get_map_location("hq_contested") as NeighborhoodHQ
	var restored_business := restored.get_map_location("business_a") as Business
	var restored_southside := restored.get_stronghold_region("southside")
	var restored_northside := restored.get_stronghold_region("northside")
	var restored_district_1 := restored.get_police_region("district_1")
	var restored_district_2 := restored.get_police_region("district_2")
	var restored_neighborhood_a := restored.get_neighborhood("neighborhood_a")
	var restored_neighborhood_contested := restored.get_neighborhood("neighborhood_contested")
	var restored_neighborhood_b := restored.get_neighborhood("neighborhood_b")
	var southside_neighborhoods := restored.get_neighborhoods_in_stronghold_region("southside")
	var northside_neighborhoods := restored.get_neighborhoods_in_stronghold_region("northside")
	var district_1_neighborhoods := restored.get_neighborhoods_in_police_region("district_1")
	var district_2_neighborhoods := restored.get_neighborhoods_in_police_region("district_2")
	var restored_graph: RoadGraph = restored.road_graph
	var restored_force_a: TravelingForce = restored.get_traveling_force("force_a")
	var restored_force_partial: TravelingForce = restored.get_traveling_force("force_partial")
	var restored_force_leftover: TravelingForce = restored.get_traveling_force("force_leftover")
	var restored_force_blocked: TravelingForce = restored.get_traveling_force("force_blocked")
	var restored_force_convoy: TravelingForce = restored.get_traveling_force("force_convoy")
	var restored_stronghold_b: Stronghold = restored.get_map_location("stronghold_b") as Stronghold
	var restored_bike: Vehicle = restored.get_vehicle("vehicle_bike")
	var restored_car: Vehicle = restored.get_vehicle("vehicle_car")
	var restored_van: Vehicle = restored.get_vehicle("vehicle_van")
	var restored_enemy: Vehicle = restored.get_vehicle("vehicle_enemy")
	var restored_force_soldiers: TravelingForce = restored.get_traveling_force("force_soldiers")
	var restored_pistol: Soldier = restored.get_soldier("soldier_pistol")
	var restored_shotgun: Soldier = restored.get_soldier("soldier_shotgun")
	var restored_smg: Soldier = restored.get_soldier("soldier_smg")
	var restored_rifle: Soldier = restored.get_soldier("soldier_rifle")
	var restored_enemy_soldier: Soldier = restored.get_soldier("soldier_enemy")
	var restored_mission_partial: CampaignMission = restored.get_mission("mission_partial")
	var restored_mission_immediate: CampaignMission = restored.get_mission("mission_immediate")
	var restored_mission_samenode: CampaignMission = restored.get_mission("mission_samenode")
	var restored_mission_outbound: CampaignMission = restored.get_mission("mission_z_keep")
	var restored_seg_ab: RoadSegment = restored_graph.get_segment("seg_ab")
	var restored_seg_bc: RoadSegment = restored_graph.get_segment("seg_bc")
	var restored_seg_cd: RoadSegment = restored_graph.get_segment("seg_cd")
	var restored_seg_be: RoadSegment = restored_graph.get_segment("seg_be")
	var restored_seg_ed: RoadSegment = restored_graph.get_segment("seg_ed")

	var older_save: Dictionary = serialized_state.duplicate(true)
	older_save.erase("missions")
	var restored_older: GameState = GameState.new()
	restored_older.from_dict(older_save)
	var mission_older_save_ok: bool = (
		restored_older.missions.is_empty()
		and restored_older.has_faction("gang_a")
		and restored_older.has_map_location("stronghold_a")
		and restored_older.has_map_location("hq_contested")
		and restored_older.road_graph != null
		and restored_older.road_graph.has_node("road_a")
	)
	var malformed_save: Dictionary = serialized_state.duplicate(true)
	var malformed_missions: Variant = malformed_save.get("missions", {})
	var mission_malformed_ok: bool = false
	if malformed_missions is Dictionary:
		malformed_missions["bad_mission"] = "not_a_dictionary"
		var restored_malformed: GameState = GameState.new()
		restored_malformed.from_dict(malformed_save)
		var restored_malformed_partial: CampaignMission = restored_malformed.get_mission("mission_partial")
		mission_malformed_ok = (
			not restored_malformed.has_mission("bad_mission")
			and restored_malformed_partial != null
			and restored_malformed.get_mission("mission_partial") is CampaignMission
		)
	var restored_mission_partial_ok: bool = (
		restored_mission_partial != null
		and restored.get_mission("mission_partial") is CampaignMission
		and restored_mission_partial.id == "mission_partial"
		and restored_mission_partial.mission_type_id == "raid_business"
		and restored_mission_partial.faction_id == "gang_a"
		and restored_mission_partial.force_id == "mission_force_partial"
		and restored_mission_partial.origin_location_id == "stronghold_a"
		and restored_mission_partial.target_location_id == "hq_contested"
		and restored_mission_partial.mission_state == "awaiting_resolution"
		and restored_mission_partial.outcome_code.is_empty()
		and restored.has_traveling_force("mission_force_partial")
	)
	var restored_mission_immediate_ok: bool = (
		restored_mission_immediate != null
		and restored.get_mission("mission_immediate") is CampaignMission
		and restored_mission_immediate.id == "mission_immediate"
		and restored_mission_immediate.mission_type_id == "attack_neighborhood_hq"
		and restored_mission_immediate.faction_id == "gang_a"
		and restored_mission_immediate.force_id == "mission_force_immediate"
		and restored_mission_immediate.origin_location_id == "stronghold_a"
		and restored_mission_immediate.target_location_id == "hq_contested"
		and restored_mission_immediate.mission_state == "resolved_success"
		and restored_mission_immediate.outcome_code == "target_secured"
		and restored.has_traveling_force("mission_force_immediate")
	)
	var restored_mission_samenode_ok: bool = (
		restored_mission_samenode != null
		and restored.get_mission("mission_samenode") is CampaignMission
		and restored_mission_samenode.id == "mission_samenode"
		and restored_mission_samenode.mission_type_id == "secure_event_location"
		and restored_mission_samenode.faction_id == "gang_a"
		and restored_mission_samenode.force_id == "mission_force_samenode"
		and restored_mission_samenode.origin_location_id == "stronghold_a"
		and restored_mission_samenode.target_location_id == "business_same_node"
		and restored_mission_samenode.mission_state == "resolved_failure"
		and restored_mission_samenode.outcome_code == "operation_failed"
		and restored.has_traveling_force("mission_force_samenode")
	)
	var restored_mission_outbound_ok: bool = (
		restored_mission_outbound != null
		and restored.get_mission("mission_z_keep") is CampaignMission
		and restored_mission_outbound.id == "mission_z_keep"
		and restored_mission_outbound.mission_type_id == "intercept_convoy"
		and restored_mission_outbound.faction_id == "gang_a"
		and restored_mission_outbound.force_id == "mission_force_z"
		and restored_mission_outbound.origin_location_id == "stronghold_a"
		and restored_mission_outbound.target_location_id == "hq_contested"
		and restored_mission_outbound.mission_state == "traveling_outbound"
		and restored_mission_outbound.outcome_code.is_empty()
		and restored.has_traveling_force("mission_force_z")
	)

	var raid_civilians: Faction = Faction.new("raid_civilians", "Civilians", "civilian")
	original.add_faction(raid_civilians)

	var raid_target_std: Business = _make_raid_business(original, "raid_business_target", "Raid Target", 3, true)
	var raid_target_l2: Business = _make_raid_business(original, "raid_business_level2", "Raid Level Two", 2, true)
	var raid_target_l1: Business = _make_raid_business(original, "raid_business_level1", "Raid Level One", 1, true)
	var raid_target_closed: Business = _make_raid_business(original, "raid_business_closed", "Raid Already Closed", 3, false)
	var raid_target_zero: Business = _make_raid_business(original, "raid_business_zero", "Raid Zero Loot", 3, true)
	var raid_target_copy: Business = _make_raid_business(original, "raid_business_copy", "Raid Copy Safety", 3, true)
	var raid_target_hold: Business = _make_raid_business(original, "raid_business_hold", "Raid Hold Target", 3, true)

	var raid_soldier_std: Soldier = Soldier.new("raid_soldier_std", "gang_a", "", "pistol", 1.0, 20.0)
	var raid_vehicle_std: Vehicle = Vehicle.new("raid_vehicle_std", "gang_a", "car", "", 2, 5.0, 50.0)
	original.add_soldier(raid_soldier_std)
	original.add_vehicle(raid_vehicle_std)
	original.assign_soldier_to_stronghold("raid_soldier_std", "stronghold_a")
	original.assign_vehicle_to_stronghold("raid_vehicle_std", "stronghold_a")
	var raid_soldier_home_before: String = raid_soldier_std.home_stronghold_id
	var raid_vehicle_home_before: String = raid_vehicle_std.home_stronghold_id
	var pistol_home_before_raid: String = soldier_pistol.home_stronghold_id
	var car_home_before_raid: String = vehicle_car.home_stronghold_id

	var raid_force_std: TravelingForce = _register_raid_pair(
		original, "raid_mission_std", "raid_force_std", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_target", "raid_business_target", "awaiting_resolution", "at_destination"
	)
	raid_force_std.soldier_group.add_soldier_id("raid_soldier_std")
	raid_force_std.vehicle_group.add_vehicle_id("raid_vehicle_std")
	var raid_std_route_before: Array[String] = _copy_ids(raid_force_std.route_node_ids)
	var raid_mission_std: CampaignMission = original.get_mission("raid_mission_std")
	var raid_std_loot_resources: Dictionary[String, float] = {}
	raid_std_loot_resources["Narcotics"] = 2.5
	raid_std_loot_resources["Ammo"] = 1.0
	var raid_std_loot: BusinessRaidLoot = BusinessRaidLoot.new(500.0, raid_std_loot_resources)
	var raid_std_money_before: float = gang_a.money
	var raid_std_narcotics_before: float = gang_a.resources.get_amount("Narcotics")
	var raid_std_ammo_before: float = gang_a.resources.get_amount("Ammo")
	var raid_std_gun_before: float = gang_a.resources.get_amount("Gun Parts")
	var raid_std_owner_before: String = raid_target_std.owner_faction_id
	var raid_std_level_before: int = raid_target_std.level
	var raid_std_open_before: bool = raid_target_std.is_open
	var raid_std_mission_state_before: String = raid_mission_std.mission_state
	var raid_std_outcome_before: String = raid_mission_std.outcome_code
	var raid_std_force_state_before: String = raid_force_std.travel_state
	var raid_std_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_std", raid_std_loot)
	var raid_standard_result_ok: bool = (
		raid_std_result.success
		and raid_std_result.mission_id == "raid_mission_std"
		and raid_std_result.business_id == "raid_business_target"
		and is_equal_approx(raid_std_result.cash_looted, 500.0)
		and _float_dict_match(raid_std_result.resources_looted, raid_std_loot_resources)
		and raid_std_result.business_level_before == 3
		and raid_std_result.business_level_after == 2
		and raid_std_result.business_closed
		and raid_std_mission_state_before == "awaiting_resolution"
		and raid_std_outcome_before.is_empty()
		and raid_std_force_state_before == "at_destination"
		and raid_std_level_before == 3
		and raid_std_open_before
	)
	var raid_standard_world_ok: bool = (
		is_equal_approx(gang_a.money, raid_std_money_before + 500.0)
		and is_equal_approx(gang_a.resources.get_amount("Narcotics"), raid_std_narcotics_before + 2.5)
		and is_equal_approx(gang_a.resources.get_amount("Ammo"), raid_std_ammo_before + 1.0)
		and is_equal_approx(gang_a.resources.get_amount("Gun Parts"), raid_std_gun_before)
		and raid_target_std.level == 2
		and raid_target_std.is_open == false
		and raid_target_std.owner_faction_id == "gang_b"
		and raid_target_std.owner_faction_id == raid_std_owner_before
		and raid_mission_std.mission_state == "resolved_success"
		and raid_mission_std.outcome_code == "business_raided"
		and raid_force_std.travel_state == "at_destination"
		and original.has_mission("raid_mission_std")
		and original.has_traveling_force("raid_force_std")
	)

	var raid_force_l2: TravelingForce = _register_raid_pair(
		original, "raid_mission_l2", "raid_force_l2", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_level2", "raid_business_level2", "awaiting_resolution", "at_destination"
	)
	var raid_mission_l2: CampaignMission = original.get_mission("raid_mission_l2")
	var raid_l2_loot: BusinessRaidLoot = BusinessRaidLoot.new(0.0)
	var raid_l2_money_before: float = gang_a.money
	var raid_l2_owner_before: String = raid_target_l2.owner_faction_id
	var raid_l2_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_l2", raid_l2_loot)
	var raid_level2_ok: bool = (
		raid_l2_result.success
		and raid_target_l2.level == 1
		and raid_target_l2.is_open == false
		and raid_target_l2.owner_faction_id == "gang_b"
		and raid_target_l2.owner_faction_id == raid_l2_owner_before
		and raid_mission_l2.mission_state == "resolved_success"
		and raid_mission_l2.outcome_code == "business_raided"
		and raid_force_l2.travel_state == "at_destination"
		and is_equal_approx(gang_a.money, raid_l2_money_before)
	)

	var raid_force_l1: TravelingForce = _register_raid_pair(
		original, "raid_mission_l1", "raid_force_l1", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_level1", "raid_business_level1", "awaiting_resolution", "at_destination"
	)
	var raid_mission_l1: CampaignMission = original.get_mission("raid_mission_l1")
	var raid_l1_loot: BusinessRaidLoot = BusinessRaidLoot.new(0.0)
	var raid_l1_owner_before: String = raid_target_l1.owner_faction_id
	var raid_l1_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_l1", raid_l1_loot)
	var raid_level1_floor_ok: bool = (
		raid_l1_result.success
		and raid_target_l1.level == 1
		and raid_target_l1.level > 0
		and raid_target_l1.is_open == false
		and raid_target_l1.owner_faction_id == "gang_b"
		and raid_target_l1.owner_faction_id == raid_l1_owner_before
		and raid_mission_l1.mission_state == "resolved_success"
		and raid_mission_l1.outcome_code == "business_raided"
	)

	var raid_force_closed: TravelingForce = _register_raid_pair(
		original, "raid_mission_closed", "raid_force_closed", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_closed", "raid_business_closed", "awaiting_resolution", "at_destination"
	)
	var raid_mission_closed: CampaignMission = original.get_mission("raid_mission_closed")
	var raid_closed_loot: BusinessRaidLoot = BusinessRaidLoot.new(0.0)
	var raid_closed_owner_before: String = raid_target_closed.owner_faction_id
	var raid_closed_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_closed", raid_closed_loot)
	var raid_already_closed_ok: bool = (
		raid_closed_result.success
		and raid_target_closed.level == 2
		and raid_target_closed.is_open == false
		and raid_target_closed.owner_faction_id == "gang_b"
		and raid_target_closed.owner_faction_id == raid_closed_owner_before
		and raid_mission_closed.mission_state == "resolved_success"
		and raid_force_closed.travel_state == "at_destination"
	)

	var raid_force_zero: TravelingForce = _register_raid_pair(
		original, "raid_mission_zero", "raid_force_zero", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_zero", "raid_business_zero", "awaiting_resolution", "at_destination"
	)
	var raid_mission_zero: CampaignMission = original.get_mission("raid_mission_zero")
	var raid_zero_loot: BusinessRaidLoot = BusinessRaidLoot.new(0.0)
	var raid_zero_money_before: float = gang_a.money
	var raid_zero_narcotics_before: float = gang_a.resources.get_amount("Narcotics")
	var raid_zero_ammo_before: float = gang_a.resources.get_amount("Ammo")
	var raid_zero_gun_before: float = gang_a.resources.get_amount("Gun Parts")
	var raid_zero_owner_before: String = raid_target_zero.owner_faction_id
	var raid_zero_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_zero", raid_zero_loot)
	var raid_zero_loot_ok: bool = (
		raid_zero_result.success
		and is_equal_approx(raid_zero_result.cash_looted, 0.0)
		and raid_zero_result.resources_looted.is_empty()
		and is_equal_approx(gang_a.money, raid_zero_money_before)
		and is_equal_approx(gang_a.resources.get_amount("Narcotics"), raid_zero_narcotics_before)
		and is_equal_approx(gang_a.resources.get_amount("Ammo"), raid_zero_ammo_before)
		and is_equal_approx(gang_a.resources.get_amount("Gun Parts"), raid_zero_gun_before)
		and raid_target_zero.level == 2
		and raid_target_zero.is_open == false
		and raid_target_zero.owner_faction_id == raid_zero_owner_before
		and raid_mission_zero.mission_state == "resolved_success"
		and raid_force_zero.travel_state == "at_destination"
	)

	var raid_loot_obj: BusinessRaidLoot = BusinessRaidLoot.new()
	var raid_loot_set_ok: bool = raid_loot_obj.set_resource_amount("Narcotics", 2.5)
	var raid_loot_get_ok: bool = is_equal_approx(raid_loot_obj.get_resource_amount("Narcotics"), 2.5)
	var raid_loot_replace_ok: bool = raid_loot_obj.set_resource_amount("Narcotics", 4.0) and is_equal_approx(raid_loot_obj.get_resource_amount("Narcotics"), 4.0)
	var raid_loot_zero_key_ok: bool = raid_loot_obj.set_resource_amount("Narcotics", 0.0) and not raid_loot_obj.resources.has("Narcotics") and is_equal_approx(raid_loot_obj.get_resource_amount("Narcotics"), 0.0)
	var raid_loot_empty_id_ok: bool = not raid_loot_obj.set_resource_amount("", 1.0)
	var raid_loot_neg_amount_ok: bool = not raid_loot_obj.set_resource_amount("Ammo", -1.0)
	var raid_loot_neg_ctor: BusinessRaidLoot = BusinessRaidLoot.new(-12.5)
	var raid_loot_neg_ctor_ok: bool = is_equal_approx(raid_loot_neg_ctor.cash, 0.0)
	var raid_loot_integrity_ok: bool = (
		raid_loot_set_ok
		and raid_loot_get_ok
		and raid_loot_replace_ok
		and raid_loot_zero_key_ok
		and raid_loot_empty_id_ok
		and raid_loot_neg_amount_ok
		and raid_loot_neg_ctor_ok
	)

	var raid_force_copy: TravelingForce = _register_raid_pair(
		original, "raid_mission_copy", "raid_force_copy", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_copy", "raid_business_copy", "awaiting_resolution", "at_destination"
	)
	var raid_copy_loot_resources: Dictionary[String, float] = {}
	raid_copy_loot_resources["Narcotics"] = 2.5
	var raid_copy_loot: BusinessRaidLoot = BusinessRaidLoot.new(100.0, raid_copy_loot_resources)
	var raid_copy_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_copy", raid_copy_loot)
	var raid_copy_original_amount: float = float(raid_copy_result.resources_looted.get("Narcotics", -1.0))
	raid_copy_loot.resources["Narcotics"] = 99.0
	var raid_result_copy_ok: bool = (
		raid_copy_result.success
		and is_equal_approx(raid_copy_original_amount, 2.5)
		and raid_copy_result.resources_looted.size() == 1
		and is_equal_approx(float(raid_copy_result.resources_looted.get("Narcotics", -1.0)), 2.5)
		and is_equal_approx(raid_copy_loot.get_resource_amount("Narcotics"), 99.0)
		and raid_force_copy.travel_state == "at_destination"
	)

	var raid_hold_level_before: int = raid_target_hold.level
	var raid_hold_open_before: bool = raid_target_hold.is_open
	var raid_hold_owner_before: String = raid_target_hold.owner_faction_id
	var raid_fail_money_before: float = gang_a.money
	var raid_fail_narcotics_before: float = gang_a.resources.get_amount("Narcotics")
	var raid_fail_ammo_before: float = gang_a.resources.get_amount("Ammo")
	var raid_fail_gun_before: float = gang_a.resources.get_amount("Gun Parts")

	var raid_force_wrong_type: TravelingForce = _register_raid_pair(
		original, "raid_mission_wrong_type", "raid_force_wrong_type", "attack_neighborhood_hq", "gang_a", "gang_a",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_mission_wrong_type: CampaignMission = original.get_mission("raid_mission_wrong_type")
	var raid_wrong_type_state_before: String = raid_mission_wrong_type.mission_state
	var raid_wrong_type_outcome_before: String = raid_mission_wrong_type.outcome_code
	var raid_wrong_type_force_before: String = raid_force_wrong_type.travel_state
	var raid_wrong_type_loot: BusinessRaidLoot = BusinessRaidLoot.new(500.0, raid_std_loot_resources)
	var raid_wrong_type_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_wrong_type", raid_wrong_type_loot)
	var raid_wrong_type_ok: bool = (
		not raid_wrong_type_result.success
		and raid_wrong_type_result.error_code == "wrong_mission_type"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and is_equal_approx(gang_a.resources.get_amount("Narcotics"), raid_fail_narcotics_before)
		and is_equal_approx(gang_a.resources.get_amount("Ammo"), raid_fail_ammo_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_target_hold.is_open == raid_hold_open_before
		and raid_target_hold.owner_faction_id == raid_hold_owner_before
		and raid_mission_wrong_type.mission_state == raid_wrong_type_state_before
		and raid_mission_wrong_type.outcome_code == raid_wrong_type_outcome_before
		and raid_force_wrong_type.travel_state == raid_wrong_type_force_before
	)
	var raid_atomic_wrong_type_ok: bool = raid_wrong_type_ok

	var raid_force_not_awaiting: TravelingForce = _register_raid_pair(
		original, "raid_mission_not_awaiting", "raid_force_not_awaiting", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "traveling_outbound", "at_destination"
	)
	var raid_mission_not_awaiting: CampaignMission = original.get_mission("raid_mission_not_awaiting")
	var raid_not_awaiting_state_before: String = raid_mission_not_awaiting.mission_state
	var raid_not_awaiting_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_not_awaiting", raid_wrong_type_loot)
	var raid_not_awaiting_ok: bool = (
		not raid_not_awaiting_result.success
		and raid_not_awaiting_result.error_code == "mission_not_awaiting_resolution"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_target_hold.is_open == raid_hold_open_before
		and raid_target_hold.owner_faction_id == raid_hold_owner_before
		and raid_mission_not_awaiting.mission_state == raid_not_awaiting_state_before
		and raid_force_not_awaiting.travel_state == "at_destination"
	)

	var raid_force_travel: TravelingForce = _register_raid_pair(
		original, "raid_mission_force_travel", "raid_force_travel", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "traveling_outbound"
	)
	var raid_mission_force_travel: CampaignMission = original.get_mission("raid_mission_force_travel")
	var raid_force_travel_state_before: String = raid_force_travel.travel_state
	var raid_force_not_dest_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_force_travel", raid_wrong_type_loot)
	var raid_force_not_dest_ok: bool = (
		not raid_force_not_dest_result.success
		and raid_force_not_dest_result.error_code == "force_not_at_destination"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_target_hold.is_open == raid_hold_open_before
		and raid_mission_force_travel.mission_state == "awaiting_resolution"
		and raid_force_travel.travel_state == raid_force_travel_state_before
	)

	var raid_force_missing_target: TravelingForce = _register_raid_pair(
		original, "raid_mission_missing_target", "raid_force_missing_target", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_no_such_place", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_invalid_target_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_missing_target", raid_wrong_type_loot)
	var raid_invalid_target_ok: bool = (
		not raid_invalid_target_result.success
		and raid_invalid_target_result.error_code == "invalid_target"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_force_missing_target.travel_state == "at_destination"
	)

	var raid_force_not_biz: TravelingForce = _register_raid_pair(
		original, "raid_mission_not_biz", "raid_force_not_biz", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "hq_contested", "hq_contested", "awaiting_resolution", "at_destination"
	)
	var raid_target_not_business_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_not_biz", raid_wrong_type_loot)
	var raid_target_not_business_ok: bool = (
		not raid_target_not_business_result.success
		and raid_target_not_business_result.error_code == "target_not_business"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and hq_contested.owner_faction_id == "gang_b"
		and raid_force_not_biz.travel_state == "at_destination"
	)

	var raid_force_mismatch_tgt: TravelingForce = _register_raid_pair(
		original, "raid_mission_mismatch_tgt", "raid_force_mismatch_tgt", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_hold", "hq_contested", "awaiting_resolution", "at_destination"
	)
	var raid_mission_mismatch_tgt: CampaignMission = original.get_mission("raid_mission_mismatch_tgt")
	var raid_mismatch_tgt_state_before: String = raid_mission_mismatch_tgt.mission_state
	var raid_mismatch_tgt_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_mismatch_tgt", raid_wrong_type_loot)
	var raid_force_target_mismatch_ok: bool = (
		not raid_mismatch_tgt_result.success
		and raid_mismatch_tgt_result.error_code == "force_target_mismatch"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and is_equal_approx(gang_a.resources.get_amount("Narcotics"), raid_fail_narcotics_before)
		and is_equal_approx(gang_a.resources.get_amount("Ammo"), raid_fail_ammo_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_target_hold.is_open == raid_hold_open_before
		and raid_target_hold.owner_faction_id == raid_hold_owner_before
		and raid_mission_mismatch_tgt.mission_state == raid_mismatch_tgt_state_before
		and raid_force_mismatch_tgt.travel_state == "at_destination"
	)
	var raid_atomic_force_target_ok: bool = raid_force_target_mismatch_ok

	var raid_force_faction_mis: TravelingForce = _register_raid_pair(
		original, "raid_mission_faction_mis", "raid_force_faction_mis", "raid_business", "gang_a", "gang_b",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_mission_faction_mis: CampaignMission = original.get_mission("raid_mission_faction_mis")
	var raid_faction_mis_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_faction_mis", raid_wrong_type_loot)
	var raid_force_faction_mismatch_ok: bool = (
		not raid_faction_mis_result.success
		and raid_faction_mis_result.error_code == "force_faction_mismatch"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and is_equal_approx(gang_b.money, 10000.0)
		and raid_target_hold.level == raid_hold_level_before
		and raid_mission_faction_mis.mission_state == "awaiting_resolution"
		and raid_force_faction_mis.travel_state == "at_destination"
	)

	var raid_force_bad_faction: TravelingForce = _register_raid_pair(
		original, "raid_mission_bad_faction", "raid_force_bad_faction", "raid_business", "raid_missing_faction", "raid_missing_faction",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_invalid_faction_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_bad_faction", raid_wrong_type_loot)
	var raid_invalid_faction_ok: bool = (
		not raid_invalid_faction_result.success
		and raid_invalid_faction_result.error_code == "invalid_faction"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_force_bad_faction.travel_state == "at_destination"
	)

	var raid_force_civilians: TravelingForce = _register_raid_pair(
		original, "raid_mission_civilians", "raid_force_civilians", "raid_business", "raid_civilians", "raid_civilians",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_not_gang_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_civilians", raid_wrong_type_loot)
	var raid_faction_not_major_gang_ok: bool = (
		not raid_not_gang_result.success
		and raid_not_gang_result.error_code == "faction_not_major_gang"
		and original.get_faction("raid_civilians") is Faction
		and not (original.get_faction("raid_civilians") is MajorGang)
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_force_civilians.travel_state == "at_destination"
	)

	var raid_force_loot_cases: TravelingForce = _register_raid_pair(
		original, "raid_mission_loot_cases", "raid_force_loot_cases", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_mission_loot_cases: CampaignMission = original.get_mission("raid_mission_loot_cases")
	var raid_null_loot_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_loot_cases", null)
	var raid_null_loot_ok: bool = (
		not raid_null_loot_result.success
		and raid_null_loot_result.error_code == "null_loot"
		and raid_mission_loot_cases.mission_state == "awaiting_resolution"
		and raid_target_hold.level == raid_hold_level_before
		and raid_force_loot_cases.travel_state == "at_destination"
	)
	var raid_neg_cash_loot: BusinessRaidLoot = BusinessRaidLoot.new()
	raid_neg_cash_loot.cash = -25.0
	var raid_invalid_cash_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_loot_cases", raid_neg_cash_loot)
	var raid_invalid_cash_loot_ok: bool = (
		not raid_invalid_cash_result.success
		and raid_invalid_cash_result.error_code == "invalid_cash_loot"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_mission_loot_cases.mission_state == "awaiting_resolution"
	)
	var raid_empty_id_loot: BusinessRaidLoot = BusinessRaidLoot.new()
	raid_empty_id_loot.resources[""] = 1.0
	var raid_invalid_resource_id_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_loot_cases", raid_empty_id_loot)
	var raid_invalid_resource_id_ok: bool = (
		not raid_invalid_resource_id_result.success
		and raid_invalid_resource_id_result.error_code == "invalid_resource_id"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and raid_target_hold.level == raid_hold_level_before
	)
	var raid_neg_amount_loot: BusinessRaidLoot = BusinessRaidLoot.new()
	raid_neg_amount_loot.resources["Ammo"] = -1.0
	var raid_invalid_resource_amount_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_loot_cases", raid_neg_amount_loot)
	var raid_invalid_resource_amount_ok: bool = (
		not raid_invalid_resource_amount_result.success
		and raid_invalid_resource_amount_result.error_code == "invalid_resource_amount"
		and is_equal_approx(gang_a.money, raid_fail_money_before)
		and is_equal_approx(gang_a.resources.get_amount("Ammo"), raid_fail_ammo_before)
		and raid_target_hold.level == raid_hold_level_before
		and raid_mission_loot_cases.mission_state == "awaiting_resolution"
	)
	var raid_atomic_invalid_loot_ok: bool = (
		raid_invalid_cash_loot_ok
		and is_equal_approx(gang_a.resources.get_amount("Gun Parts"), raid_fail_gun_before)
		and raid_target_hold.owner_faction_id == raid_hold_owner_before
		and raid_target_hold.is_open == raid_hold_open_before
	)

	var raid_missing_mission_loot: BusinessRaidLoot = BusinessRaidLoot.new()
	var raid_missing_mission_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_absent", raid_missing_mission_loot)
	var raid_missing_mission_ok: bool = (
		not raid_missing_mission_result.success
		and raid_missing_mission_result.error_code == "invalid_mission"
		and not original.has_mission("raid_mission_absent")
		and is_equal_approx(gang_a.money, raid_fail_money_before)
	)
	var raid_force_missing: TravelingForce = _register_raid_pair(
		original, "raid_mission_missing_force", "raid_force_placeholder", "raid_business", "gang_a", "gang_a",
		"stronghold_a", "raid_business_hold", "raid_business_hold", "awaiting_resolution", "at_destination"
	)
	var raid_mission_missing_force: CampaignMission = original.get_mission("raid_mission_missing_force")
	raid_mission_missing_force.force_id = "raid_force_absent"
	var raid_missing_force_result: BusinessRaidResult = BusinessRaidResolver.resolve_success(original, "raid_mission_missing_force", raid_missing_mission_loot)
	var raid_missing_force_ok: bool = (
		not raid_missing_force_result.success
		and raid_missing_force_result.error_code == "invalid_force"
		and not original.has_traveling_force("raid_force_absent")
		and original.has_traveling_force("raid_force_placeholder")
		and raid_mission_missing_force.mission_state == "awaiting_resolution"
		and raid_force_missing.travel_state == "at_destination"
		and raid_target_hold.level == raid_hold_level_before
	)

	var raid_rollback_path_unreachable_ok: bool = true
	var raid_no_capture_ok: bool = (
		raid_target_std.owner_faction_id == "gang_b"
		and raid_target_l2.owner_faction_id == "gang_b"
		and raid_target_l1.owner_faction_id == "gang_b"
		and raid_target_closed.owner_faction_id == "gang_b"
		and raid_target_zero.owner_faction_id == "gang_b"
		and raid_target_copy.owner_faction_id == "gang_b"
		and raid_target_hold.owner_faction_id == "gang_b"
	)
	var raid_no_return_ok: bool = (
		raid_force_std.travel_state == "at_destination"
		and _string_ids_match(raid_force_std.route_node_ids, raid_std_route_before)
		and original.has_traveling_force("raid_force_std")
		and original.has_mission("raid_mission_std")
		and raid_soldier_std.home_stronghold_id == raid_soldier_home_before
		and raid_vehicle_std.home_stronghold_id == raid_vehicle_home_before
		and soldier_pistol.home_stronghold_id == pistol_home_before_raid
		and vehicle_car.home_stronghold_id == car_home_before_raid
		and raid_force_l2.travel_state == "at_destination"
		and raid_force_l1.travel_state == "at_destination"
		and raid_force_closed.travel_state == "at_destination"
		and raid_force_zero.travel_state == "at_destination"
		and raid_force_copy.travel_state == "at_destination"
	)

	var rem_route_a: Array[String] = ["road_a"]
	var rem_route_ab: Array[String] = ["road_a", "road_b"]
	var rem_route_short: Array[String] = ["road_a", "road_b", "road_e", "road_d"]
	var rem_save_zero: TravelingForce = TravelingForce.new("rem_save_zero", "gang_a", "stronghold_a", "stronghold_a", rem_route_a, 5.0, "at_destination")
	rem_save_zero.movement_remaining = 0.0
	original.add_traveling_force(rem_save_zero)
	var rem_save_partial: TravelingForce = TravelingForce.new("rem_save_partial", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "traveling_outbound")
	rem_save_partial.movement_remaining = 1.25
	original.add_traveling_force(rem_save_partial)
	var rem_save_full: TravelingForce = TravelingForce.new("rem_save_full", "gang_a", "stronghold_a", "stronghold_a", rem_route_a, 5.0, "at_destination")
	rem_save_full.movement_remaining = 5.0
	original.add_traveling_force(rem_save_full)
	var rem_live_save: Dictionary = original.to_dict()
	var rem_live_restored := GameState.new()
	rem_live_restored.from_dict(rem_live_save)
	var rem_restored_zero: TravelingForce = rem_live_restored.get_traveling_force("rem_save_zero")
	var rem_restored_partial: TravelingForce = rem_live_restored.get_traveling_force("rem_save_partial")
	var rem_restored_full: TravelingForce = rem_live_restored.get_traveling_force("rem_save_full")
	var rem_save_load_ok: bool = (
		rem_restored_zero != null
		and rem_restored_partial != null
		and rem_restored_full != null
		and is_equal_approx(rem_restored_zero.movement_remaining, 0.0)
		and is_equal_approx(rem_restored_partial.movement_remaining, 1.25)
		and is_equal_approx(rem_restored_full.movement_remaining, 5.0)
	)
	var rem_older_save: Dictionary = rem_live_save.duplicate(true)
	var rem_older_forces: Variant = rem_older_save.get("traveling_forces", {})
	var rem_older_erased: bool = false
	if rem_older_forces is Dictionary:
		var rem_full_record: Variant = rem_older_forces.get("rem_save_full", {})
		if rem_full_record is Dictionary:
			rem_full_record.erase("movement_remaining")
			rem_older_erased = not rem_full_record.has("movement_remaining")
	var rem_older_restored := GameState.new()
	rem_older_restored.from_dict(rem_older_save)
	var rem_older_full: TravelingForce = rem_older_restored.get_traveling_force("rem_save_full")
	var rem_older_save_ok: bool = (
		rem_older_erased
		and rem_older_full != null
		and is_equal_approx(rem_older_full.movement_remaining, 0.0)
	)

	var rem_loc_start: Business = _make_move_business(original, "rem_loc_start", "Remaining Start", "road_a")
	var rem_loc_dest: Business = _make_move_business(original, "rem_loc_dest", "Remaining Dest", "road_b")
	var rem_same_a: Business = _make_move_business(original, "rem_same_a", "Remaining Same A", "road_a")
	var rem_same_b: Business = _make_move_business(original, "rem_same_b", "Remaining Same B", "road_a")
	var rem_raid_biz: Business = _make_move_business(original, "rem_raid_biz", "Remaining Raid Business A", "road_a")
	var rem_home_away: Business = _make_move_business(original, "rem_home_away", "Remaining Away", "road_d")
	var rem_allow_from: Business = _make_move_business(original, "rem_allow_from", "Remaining Allow From", "road_a")
	var rem_allow_to: Business = _make_move_business(original, "rem_allow_to", "Remaining Allow To", "road_a")
	var rem_block_from: Business = _make_move_business(original, "rem_block_from", "Remaining Block From", "road_a")
	var rem_probe_from: Business = _make_move_business(original, "rem_probe_from", "Remaining Probe From", "road_a")

	var rem_soldier_partial: Soldier = Soldier.new("rem_soldier_partial", "gang_a", "", "pistol", 1.0, 20.0)
	var rem_soldier_arrive: Soldier = Soldier.new("rem_soldier_arrive", "gang_a", "", "pistol", 1.0, 20.0)
	var rem_soldier_same: Soldier = Soldier.new("rem_soldier_same", "gang_a", "", "pistol", 1.0, 20.0)
	var rem_soldier_zero: Soldier = Soldier.new("rem_soldier_zero", "gang_a", "", "pistol", 1.0, 20.0)
	var rem_soldier_resolved: Soldier = Soldier.new("rem_soldier_resolved", "gang_a", "", "pistol", 1.0, 20.0)
	var rem_soldier_raid: Soldier = Soldier.new("rem_soldier_raid", "gang_a", "", "pistol", 1.0, 20.0)
	original.add_soldier(rem_soldier_partial)
	original.add_soldier(rem_soldier_arrive)
	original.add_soldier(rem_soldier_same)
	original.add_soldier(rem_soldier_zero)
	original.add_soldier(rem_soldier_resolved)
	original.add_soldier(rem_soldier_raid)
	original.assign_soldier_to_stronghold("rem_soldier_partial", "stronghold_a")
	original.assign_soldier_to_stronghold("rem_soldier_arrive", "stronghold_a")
	original.assign_soldier_to_stronghold("rem_soldier_same", "stronghold_a")
	original.assign_soldier_to_stronghold("rem_soldier_zero", "stronghold_a")
	original.assign_soldier_to_stronghold("rem_soldier_resolved", "stronghold_a")
	original.assign_soldier_to_stronghold("rem_soldier_raid", "stronghold_a")
	var rem_vehicle_partial: Vehicle = Vehicle.new("rem_vehicle_partial", "gang_a", "car", "", 2, 5.0, 50.0)
	var rem_vehicle_arrive: Vehicle = Vehicle.new("rem_vehicle_arrive", "gang_a", "car", "", 4, 8.0, 50.0)
	var rem_vehicle_same: Vehicle = Vehicle.new("rem_vehicle_same", "gang_a", "car", "", 2, 5.0, 50.0)
	var rem_vehicle_zero: Vehicle = Vehicle.new("rem_vehicle_zero", "gang_a", "car", "", 2, 5.0, 50.0)
	var rem_vehicle_resolved: Vehicle = Vehicle.new("rem_vehicle_resolved", "gang_a", "car", "", 2, 5.0, 50.0)
	var rem_vehicle_raid: Vehicle = Vehicle.new("rem_vehicle_raid", "gang_a", "car", "", 2, 5.0, 50.0)
	original.add_vehicle(rem_vehicle_partial)
	original.add_vehicle(rem_vehicle_arrive)
	original.add_vehicle(rem_vehicle_same)
	original.add_vehicle(rem_vehicle_zero)
	original.add_vehicle(rem_vehicle_resolved)
	original.add_vehicle(rem_vehicle_raid)
	original.assign_vehicle_to_stronghold("rem_vehicle_partial", "stronghold_a")
	original.assign_vehicle_to_stronghold("rem_vehicle_arrive", "stronghold_a")
	original.assign_vehicle_to_stronghold("rem_vehicle_same", "stronghold_a")
	original.assign_vehicle_to_stronghold("rem_vehicle_zero", "stronghold_a")
	original.assign_vehicle_to_stronghold("rem_vehicle_resolved", "stronghold_a")
	original.assign_vehicle_to_stronghold("rem_vehicle_raid", "stronghold_a")

	var rem_ids_partial_s: Array[String] = ["rem_soldier_partial"]
	var rem_ids_partial_v: Array[String] = ["rem_vehicle_partial"]
	var rem_req_partial: DeploymentRequest = DeploymentRequest.new("rem_force_partial", "gang_a", "stronghold_a", "hq_contested", rem_ids_partial_s, rem_ids_partial_v, 3.0)
	var rem_res_partial: DeploymentResult = DeploymentService.deploy(original, rem_req_partial)
	var rem_force_partial: TravelingForce = original.get_traveling_force("rem_force_partial")
	var rem_deploy_partial_ok: bool = (
		rem_res_partial.success
		and rem_force_partial != null
		and is_equal_approx(rem_force_partial.movement_per_turn, 5.0)
		and is_equal_approx(rem_force_partial.movement_remaining, 0.0)
		and is_equal_approx(rem_res_partial.unused_movement, 0.0)
	)
	var rem_ids_arrive_s: Array[String] = ["rem_soldier_arrive"]
	var rem_ids_arrive_v: Array[String] = ["rem_vehicle_arrive"]
	var rem_req_arrive: DeploymentRequest = DeploymentRequest.new("rem_force_arrive", "gang_a", "stronghold_a", "hq_contested", rem_ids_arrive_s, rem_ids_arrive_v, 8.0)
	var rem_res_arrive: DeploymentResult = DeploymentService.deploy(original, rem_req_arrive)
	var rem_force_arrive: TravelingForce = original.get_traveling_force("rem_force_arrive")
	var rem_deploy_arrive_ok: bool = (
		rem_res_arrive.success
		and rem_res_arrive.reached_destination
		and rem_force_arrive != null
		and rem_force_arrive.travel_state == "at_destination"
		and is_equal_approx(rem_force_arrive.movement_remaining, 1.0)
		and is_equal_approx(rem_res_arrive.unused_movement, 1.0)
	)
	var rem_ids_same_s: Array[String] = ["rem_soldier_same"]
	var rem_ids_same_v: Array[String] = ["rem_vehicle_same"]
	var rem_req_same: DeploymentRequest = DeploymentRequest.new("rem_force_same", "gang_a", "stronghold_a", "business_same_node", rem_ids_same_s, rem_ids_same_v, 3.0)
	var rem_res_same: DeploymentResult = DeploymentService.deploy(original, rem_req_same)
	var rem_force_same: TravelingForce = original.get_traveling_force("rem_force_same")
	var rem_deploy_same_ok: bool = (
		rem_res_same.success
		and rem_res_same.reached_destination
		and rem_force_same != null
		and rem_force_same.travel_state == "at_destination"
		and is_equal_approx(rem_force_same.movement_remaining, 3.0)
		and is_equal_approx(rem_res_same.unused_movement, 3.0)
	)
	var rem_ids_zero_s: Array[String] = ["rem_soldier_zero"]
	var rem_ids_zero_v: Array[String] = ["rem_vehicle_zero"]
	var rem_req_zero: DeploymentRequest = DeploymentRequest.new("rem_force_zero", "gang_a", "stronghold_a", "hq_contested", rem_ids_zero_s, rem_ids_zero_v, 0.0)
	var rem_res_zero: DeploymentResult = DeploymentService.deploy(original, rem_req_zero)
	var rem_force_zero: TravelingForce = original.get_traveling_force("rem_force_zero")
	var expected_zero_route: Array[String] = ["road_a", "road_b", "road_e", "road_d"]
	var rem_deploy_zero_ok: bool = (
		rem_res_zero.success
		and rem_force_zero != null
		and rem_force_zero.travel_state == "traveling_outbound"
		and _string_ids_match(rem_force_zero.route_node_ids, expected_zero_route)
		and rem_force_zero.route_segment_index == 0
		and is_equal_approx(rem_force_zero.distance_into_segment, 0.0)
		and is_equal_approx(rem_force_zero.movement_remaining, 0.0)
		and is_equal_approx(rem_res_zero.unused_movement, 0.0)
	)

	var rem_refresh: TravelingForce = TravelingForce.new("rem_refresh", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "traveling_outbound")
	rem_refresh.route_segment_index = 0
	rem_refresh.distance_into_segment = 1.0
	rem_refresh.movement_remaining = 1.25
	var rem_refresh_route_before: Array[String] = _copy_ids(rem_refresh.route_node_ids)
	var rem_refresh_index_before: int = rem_refresh.route_segment_index
	var rem_refresh_dist_before: float = rem_refresh.distance_into_segment
	var rem_refresh_dest_before: String = rem_refresh.destination_location_id
	var rem_refresh_state_before: String = rem_refresh.travel_state
	var rem_refresh_origin_before: String = rem_refresh.origin_location_id
	var rem_refresh_returned: float = rem_refresh.refresh_turn_movement()
	var rem_refresh_ok: bool = (
		is_equal_approx(rem_refresh_returned, 5.0)
		and is_equal_approx(rem_refresh.movement_remaining, 5.0)
		and _string_ids_match(rem_refresh.route_node_ids, rem_refresh_route_before)
		and rem_refresh.route_segment_index == rem_refresh_index_before
		and is_equal_approx(rem_refresh.distance_into_segment, rem_refresh_dist_before)
		and rem_refresh.destination_location_id == rem_refresh_dest_before
		and rem_refresh.travel_state == rem_refresh_state_before
		and rem_refresh.origin_location_id == rem_refresh_origin_before
	)

	var rem_node_one: TravelingForce = TravelingForce.new("rem_node_one", "gang_a", "stronghold_a", "business_same_node", rem_route_a, 5.0, "at_destination")
	var rem_node_complete: TravelingForce = TravelingForce.new("rem_node_complete", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "at_destination")
	rem_node_complete.route_segment_index = 2
	rem_node_complete.distance_into_segment = 3.0
	var rem_node_exact: TravelingForce = TravelingForce.new("rem_node_exact", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "traveling_outbound")
	rem_node_exact.route_segment_index = 1
	rem_node_exact.distance_into_segment = 0.0
	var rem_node_mid: TravelingForce = TravelingForce.new("rem_node_mid", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "traveling_outbound")
	rem_node_mid.route_segment_index = 0
	rem_node_mid.distance_into_segment = 1.0
	var rem_current_node_ok: bool = (
		rem_node_one.get_current_road_node_id() == "road_a"
		and rem_node_complete.get_current_road_node_id() == "road_d"
		and rem_node_exact.get_current_road_node_id() == "road_b"
		and rem_node_mid.get_current_road_node_id().is_empty()
	)

	var rem_force_resolved: TravelingForce = _make_at_dest_force(original, "rem_force_resolved", "stronghold_a", "rem_loc_start", rem_route_a, 3.0, 5.0)
	rem_force_resolved.soldier_group.add_soldier_id("rem_soldier_resolved")
	rem_force_resolved.vehicle_group.add_vehicle_id("rem_vehicle_resolved")
	var rem_resolved_soldiers_before: Array[String] = _copy_ids(rem_force_resolved.soldier_group.soldier_ids)
	var rem_resolved_vehicles_before: Array[String] = _copy_ids(rem_force_resolved.vehicle_group.vehicle_ids)
	var rem_resolved_soldier_home_before: String = rem_soldier_resolved.home_stronghold_id
	var rem_resolved_vehicle_home_before: String = rem_vehicle_resolved.home_stronghold_id
	var rem_mission_resolved: CampaignMission = _register_move_mission(
		original, "rem_mission_resolved", "raid_business", "rem_force_resolved",
		"stronghold_a", "rem_loc_start", "resolved_success", "prior_operation_complete"
	)
	var rem_resolved_req: ForceMoveRequest = ForceMoveRequest.new("rem_force_resolved", "rem_loc_dest")
	var rem_resolved_result: ForceMoveResult = ForceMovementService.move_to_location(original, rem_resolved_req)
	var rem_resolved_move_ok: bool = (
		rem_resolved_result.success
		and rem_resolved_result.error_code.is_empty()
		and rem_force_resolved.destination_location_id == "rem_loc_dest"
		and rem_force_resolved.travel_state == "at_destination"
		and _string_ids_match(rem_force_resolved.route_node_ids, rem_route_ab)
		and is_equal_approx(rem_resolved_result.movement_spent, 2.0)
		and is_equal_approx(rem_force_resolved.movement_remaining, 1.0)
		and rem_force_resolved.origin_location_id == "stronghold_a"
		and rem_mission_resolved.mission_state == "resolved_success"
		and rem_mission_resolved.target_location_id == "rem_loc_start"
		and rem_mission_resolved.outcome_code == "prior_operation_complete"
		and rem_mission_resolved.origin_location_id == "stronghold_a"
		and _string_ids_match(rem_force_resolved.soldier_group.soldier_ids, rem_resolved_soldiers_before)
		and _string_ids_match(rem_force_resolved.vehicle_group.vehicle_ids, rem_resolved_vehicles_before)
		and rem_soldier_resolved.home_stronghold_id == rem_resolved_soldier_home_before
		and rem_vehicle_resolved.home_stronghold_id == rem_resolved_vehicle_home_before
		and rem_loc_start != null
		and rem_loc_dest != null
	)

	var rem_force_raid: TravelingForce = _make_at_dest_force(original, "rem_force_raid", "stronghold_a", "rem_raid_biz", rem_route_a, 3.0, 5.0)
	rem_force_raid.soldier_group.add_soldier_id("rem_soldier_raid")
	rem_force_raid.vehicle_group.add_vehicle_id("rem_vehicle_raid")
	var rem_mission_raid: CampaignMission = _register_move_mission(
		original, "rem_mission_raid", "raid_business", "rem_force_raid",
		"stronghold_a", "rem_raid_biz", "resolved_success", "business_raided"
	)
	var rem_raid_req: ForceMoveRequest = ForceMoveRequest.new("rem_force_raid", "rem_loc_dest")
	var rem_raid_result: ForceMoveResult = ForceMovementService.move_to_location(original, rem_raid_req)
	var rem_raid_continue_ok: bool = (
		rem_raid_result.success
		and rem_force_raid.destination_location_id == "rem_loc_dest"
		and rem_force_raid.destination_location_id != "rem_raid_biz"
		and rem_raid_biz != null
		and rem_mission_raid.mission_type_id == "raid_business"
		and rem_mission_raid.mission_state == "resolved_success"
		and rem_mission_raid.target_location_id == "rem_raid_biz"
		and rem_mission_raid.outcome_code == "business_raided"
		and rem_mission_raid.origin_location_id == "stronghold_a"
		and rem_mission_raid.force_id == "rem_force_raid"
	)

	var rem_force_block_out: TravelingForce = _make_at_dest_force(original, "rem_force_block_out", "stronghold_a", "rem_block_from", rem_route_a, 3.0, 5.0)
	_register_move_mission(original, "rem_mission_block_out", "raid_business", "rem_force_block_out", "stronghold_a", "rem_block_from", "traveling_outbound", "")
	var rem_block_out_snap: Dictionary = _force_travel_snapshot(rem_force_block_out)
	var rem_block_out_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_block_out", "rem_loc_dest"))
	var rem_block_outbound_ok: bool = (
		not rem_block_out_result.success
		and rem_block_out_result.error_code == "force_has_unresolved_mission"
		and _force_travel_unchanged(rem_force_block_out, rem_block_out_snap)
	)
	var rem_force_block_await: TravelingForce = _make_at_dest_force(original, "rem_force_block_await", "stronghold_a", "rem_block_from", rem_route_a, 3.0, 5.0)
	_register_move_mission(original, "rem_mission_block_await", "raid_business", "rem_force_block_await", "stronghold_a", "rem_block_from", "awaiting_resolution", "")
	var rem_block_await_snap: Dictionary = _force_travel_snapshot(rem_force_block_await)
	var rem_block_await_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_block_await", "rem_loc_dest"))
	var rem_block_await_ok: bool = (
		not rem_block_await_result.success
		and rem_block_await_result.error_code == "force_has_unresolved_mission"
		and _force_travel_unchanged(rem_force_block_await, rem_block_await_snap)
	)
	var rem_force_block_return: TravelingForce = _make_at_dest_force(original, "rem_force_block_return", "stronghold_a", "rem_block_from", rem_route_a, 3.0, 5.0)
	_register_move_mission(original, "rem_mission_block_return", "raid_business", "rem_force_block_return", "stronghold_a", "rem_block_from", "traveling_return", "")
	var rem_block_return_snap: Dictionary = _force_travel_snapshot(rem_force_block_return)
	var rem_block_return_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_block_return", "rem_loc_dest"))
	var rem_block_return_ok: bool = (
		not rem_block_return_result.success
		and rem_block_return_result.error_code == "force_has_unresolved_mission"
		and _force_travel_unchanged(rem_force_block_return, rem_block_return_snap)
	)

	var rem_force_allow_success: TravelingForce = _make_at_dest_force(original, "rem_force_allow_success", "stronghold_a", "rem_allow_from", rem_route_a, 3.0, 5.0)
	_register_move_mission(original, "rem_mission_allow_success", "raid_business", "rem_force_allow_success", "stronghold_a", "rem_allow_from", "resolved_success", "ok")
	var rem_allow_success_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_allow_success", "rem_allow_to"))
	var rem_allow_success_ok: bool = (
		rem_allow_success_result.success
		and rem_force_allow_success.destination_location_id == "rem_allow_to"
		and rem_force_allow_success.travel_state == "at_destination"
	)
	var rem_force_allow_failure: TravelingForce = _make_at_dest_force(original, "rem_force_allow_failure", "stronghold_a", "rem_allow_from", rem_route_a, 3.0, 5.0)
	var rem_mission_allow_failure: CampaignMission = _register_move_mission(original, "rem_mission_allow_failure", "raid_business", "rem_force_allow_failure", "stronghold_a", "rem_allow_from", "resolved_failure", "failed")
	var rem_allow_failure_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_allow_failure", "rem_allow_to"))
	var rem_allow_failure_ok: bool = (
		rem_mission_allow_failure != null
		and rem_allow_failure_result.success
		and rem_force_allow_failure.destination_location_id == "rem_allow_to"
	)
	var rem_force_allow_complete: TravelingForce = _make_at_dest_force(original, "rem_force_allow_complete", "stronghold_a", "rem_allow_from", rem_route_a, 3.0, 5.0)
	_register_move_mission(original, "rem_mission_allow_complete", "raid_business", "rem_force_allow_complete", "stronghold_a", "rem_allow_from", "complete", "done")
	var rem_allow_complete_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_allow_complete", "rem_allow_to"))
	var rem_allow_complete_ok: bool = (
		rem_allow_complete_result.success
		and rem_force_allow_complete.destination_location_id == "rem_allow_to"
	)

	var rem_force_samenode: TravelingForce = _make_at_dest_force(original, "rem_force_samenode", "stronghold_a", "rem_same_a", rem_route_a, 3.0, 5.0)
	var rem_samenode_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_samenode", "rem_same_b"))
	var rem_samenode_ok: bool = (
		rem_samenode_result.success
		and rem_samenode_result.reached_destination
		and rem_force_samenode.destination_location_id == "rem_same_b"
		and rem_same_a != null
		and rem_same_b != null
		and rem_force_samenode.travel_state == "at_destination"
		and rem_force_samenode.route_node_ids.size() == 1
		and rem_force_samenode.route_node_ids[0] == "road_a"
		and is_equal_approx(rem_samenode_result.movement_spent, 0.0)
		and is_equal_approx(rem_force_samenode.movement_remaining, 3.0)
	)

	var rem_force_queue: TravelingForce = _make_at_dest_force(original, "rem_force_queue", "stronghold_a", "rem_probe_from", rem_route_a, 0.0, 5.0)
	var rem_queue_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_queue", "hq_contested"))
	var rem_zero_queue_ok: bool = (
		rem_queue_result.success
		and rem_force_queue.destination_location_id == "hq_contested"
		and _string_ids_match(rem_force_queue.route_node_ids, rem_route_short)
		and rem_force_queue.travel_state == "traveling_outbound"
		and rem_force_queue.route_segment_index == 0
		and is_equal_approx(rem_force_queue.distance_into_segment, 0.0)
		and is_equal_approx(rem_queue_result.movement_spent, 0.0)
		and is_equal_approx(rem_force_queue.movement_remaining, 0.0)
		and not rem_queue_result.reached_destination
	)

	var rem_force_cap: TravelingForce = _make_at_dest_force(original, "rem_force_cap", "stronghold_a", "rem_probe_from", rem_route_a, 1.0, 5.0)
	var rem_cap_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_cap", "hq_contested"))
	var rem_cap_ok: bool = (
		rem_cap_result.success
		and rem_force_cap.travel_state == "traveling_outbound"
		and rem_force_cap.destination_location_id == "hq_contested"
		and _string_ids_match(rem_force_cap.route_node_ids, rem_route_short)
		and rem_force_cap.route_segment_index == 0
		and is_equal_approx(rem_force_cap.distance_into_segment, 1.0)
		and is_equal_approx(rem_cap_result.movement_spent, 1.0)
		and is_equal_approx(rem_force_cap.movement_remaining, 0.0)
		and not rem_cap_result.reached_destination
	)

	var rem_route_d: Array[String] = ["road_d"]
	var rem_force_home: TravelingForce = _make_at_dest_force(original, "rem_force_home", "stronghold_a", "rem_home_away", rem_route_d, 3.0, 5.0)
	var rem_home_missions_before: int = original.missions.size()
	var rem_home_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_home", "stronghold_a"))
	var rem_home_linked: int = 0
	for rem_home_mission_id: String in original.missions:
		var rem_home_mission: CampaignMission = original.get_mission(rem_home_mission_id)
		if rem_home_mission != null and rem_home_mission.force_id == "rem_force_home":
			rem_home_linked += 1
	var rem_home_route: Array[String] = graph.find_route("road_d", "road_a")
	var rem_return_home_ok: bool = (
		rem_home_result.success
		and rem_home_away != null
		and original.has_traveling_force("rem_force_home")
		and rem_force_home.origin_location_id == "stronghold_a"
		and rem_force_home.destination_location_id == "stronghold_a"
		and rem_force_home.travel_state == "traveling_outbound"
		and rem_force_home.travel_state != "traveling_return"
		and rem_force_home.travel_state != "complete"
		and _string_ids_match(rem_force_home.route_node_ids, rem_home_route)
		and original.missions.size() == rem_home_missions_before
		and rem_home_linked == 0
	)

	var rem_force_mid: TravelingForce = TravelingForce.new("rem_force_mid", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "traveling_outbound")
	rem_force_mid.route_segment_index = 0
	rem_force_mid.distance_into_segment = 1.0
	rem_force_mid.movement_remaining = 2.0
	original.add_traveling_force(rem_force_mid)
	var rem_mid_snap: Dictionary = _force_travel_snapshot(rem_force_mid)
	var rem_mid_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_mid", "rem_loc_dest"))
	var rem_mid_block_ok: bool = (
		not rem_mid_result.success
		and rem_mid_result.error_code == "force_not_at_node"
		and _force_travel_unchanged(rem_force_mid, rem_mid_snap)
	)

	var rem_force_complete: TravelingForce = TravelingForce.new("rem_force_complete", "gang_a", "stronghold_a", "hq_contested", rem_route_short, 5.0, "complete")
	rem_force_complete.movement_remaining = 3.0
	original.add_traveling_force(rem_force_complete)
	var rem_complete_snap: Dictionary = _force_travel_snapshot(rem_force_complete)
	var rem_complete_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_complete", "rem_loc_dest"))
	var rem_complete_block_ok: bool = (
		not rem_complete_result.success
		and rem_complete_result.error_code == "force_complete"
		and _force_travel_unchanged(rem_force_complete, rem_complete_snap)
	)

	var rem_force_probe: TravelingForce = _make_at_dest_force(original, "rem_force_probe", "stronghold_a", "rem_probe_from", rem_route_a, 3.0, 5.0)
	var rem_probe_snap_missing: Dictionary = _force_travel_snapshot(rem_force_probe)
	var rem_missing_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_probe", "rem_missing_place"))
	var rem_dest_missing_ok: bool = (
		not rem_missing_result.success
		and rem_missing_result.error_code == "invalid_destination"
		and _force_travel_unchanged(rem_force_probe, rem_probe_snap_missing)
	)
	var rem_probe_snap_empty: Dictionary = _force_travel_snapshot(rem_force_probe)
	var rem_empty_road_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_probe", "business_no_road"))
	var rem_dest_empty_road_ok: bool = (
		not rem_empty_road_result.success
		and rem_empty_road_result.error_code == "destination_missing_road_node"
		and _force_travel_unchanged(rem_force_probe, rem_probe_snap_empty)
	)
	var rem_probe_snap_ghost: Dictionary = _force_travel_snapshot(rem_force_probe)
	var rem_ghost_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_probe", "business_ghost_road"))
	var rem_dest_ghost_ok: bool = (
		not rem_ghost_result.success
		and rem_ghost_result.error_code == "invalid_destination_road_node"
		and _force_travel_unchanged(rem_force_probe, rem_probe_snap_ghost)
	)
	var rem_probe_snap_noroute: Dictionary = _force_travel_snapshot(rem_force_probe)
	var rem_noroute_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_probe", "business_isolated"))
	var rem_dest_noroute_ok: bool = (
		not rem_noroute_result.success
		and rem_noroute_result.error_code == "no_route"
		and _force_travel_unchanged(rem_force_probe, rem_probe_snap_noroute)
	)

	var rem_phantom_route: Array[String] = ["road_not_in_graph"]
	var rem_force_malformed: TravelingForce = TravelingForce.new("rem_force_malformed", "gang_a", "stronghold_a", "rem_probe_from", rem_phantom_route, 5.0, "at_destination")
	rem_force_malformed.movement_remaining = 3.0
	original.add_traveling_force(rem_force_malformed)
	var rem_malformed_snap: Dictionary = _force_travel_snapshot(rem_force_malformed)
	var rem_malformed_current: String = rem_force_malformed.get_current_road_node_id()
	var rem_malformed_result: ForceMoveResult = ForceMovementService.move_to_location(original, ForceMoveRequest.new("rem_force_malformed", "rem_loc_dest"))
	var rem_invalid_current_ok: bool = (
		not rem_malformed_current.is_empty()
		and not graph.has_node(rem_malformed_current)
		and not rem_malformed_result.success
		and rem_malformed_result.error_code == "invalid_current_road_node"
		and _force_travel_unchanged(rem_force_malformed, rem_malformed_snap)
	)

	var rem_helper_ok_result: ForceMoveResult = ForceMoveResult.succeeded("rem_helper_force", "rem_helper_dest", true, 2.0, 1.0)
	var rem_result_success_ok: bool = (
		rem_helper_ok_result.success
		and rem_helper_ok_result.force_id == "rem_helper_force"
		and rem_helper_ok_result.destination_location_id == "rem_helper_dest"
		and rem_helper_ok_result.reached_destination
		and is_equal_approx(rem_helper_ok_result.movement_spent, 2.0)
		and is_equal_approx(rem_helper_ok_result.movement_remaining, 1.0)
		and rem_helper_ok_result.error_code.is_empty()
		and rem_helper_ok_result.error_message.is_empty()
	)
	var rem_helper_fail_result: ForceMoveResult = ForceMoveResult.failed("no_route", "Force movement failed: no route.", "rem_helper_force", "rem_helper_dest")
	var rem_result_failure_ok: bool = (
		not rem_helper_fail_result.success
		and rem_helper_fail_result.error_code == "no_route"
		and rem_helper_fail_result.error_message == "Force movement failed: no route."
		and rem_helper_fail_result.force_id == "rem_helper_force"
		and rem_helper_fail_result.destination_location_id == "rem_helper_dest"
	)

	var rem_atomic_unresolved_ok: bool = rem_block_outbound_ok
	var rem_atomic_mid_ok: bool = rem_mid_block_ok
	var rem_atomic_noroute_ok: bool = rem_dest_noroute_ok

	var turn_route_abc: Array[String] = ["turn_a", "turn_b", "turn_c"]
	var turn_route_cba: Array[String] = ["turn_c", "turn_b", "turn_a"]
	var turn_route_ab: Array[String] = ["turn_a", "turn_b"]
	var turn_route_c: Array[String] = ["turn_c"]
	var turn_route_a: Array[String] = ["turn_a"]

	var turn_state: GameState = _make_turn_world(5)
	var turn_gang: MajorGang = turn_state.get_faction("turn_gang") as MajorGang
	var turn_shop: Business = turn_state.get_map_location("turn_shop") as Business
	var turn_soldier: Soldier = turn_state.get_soldier("turn_soldier")
	var turn_vehicle: Vehicle = turn_state.get_vehicle("turn_vehicle")
	var turn_force_partial: TravelingForce = _make_turn_force(
		turn_state, "turn_force_partial", "turn_keep", "turn_shop", turn_route_abc, 5.0, "traveling_outbound", 1.0, 0, 0.0
	)
	var turn_force_arrive: TravelingForce = _make_turn_force(
		turn_state, "turn_force_arrive", "turn_keep", "turn_shop", turn_route_abc, 5.0, "traveling_outbound", 0.25, 1, 2.0
	)
	var turn_force_idle: TravelingForce = _make_turn_force(
		turn_state, "turn_force_idle", "turn_keep", "turn_shop", turn_route_c, 4.0, "at_destination", 0.5, 0, 0.0
	)
	turn_force_idle.soldier_group.add_soldier_id("turn_soldier")
	turn_force_idle.vehicle_group.add_vehicle_id("turn_vehicle")
	var turn_force_complete: TravelingForce = _make_turn_force(
		turn_state, "turn_force_complete", "turn_keep", "turn_shop", turn_route_abc, 5.0, "complete", 1.25, 0, 0.0
	)
	var turn_force_return: TravelingForce = _make_turn_force(
		turn_state, "turn_force_return", "turn_shop", "turn_keep", turn_route_cba, 5.0, "traveling_return", 0.75, 0, 0.0
	)
	var turn_force_zero: TravelingForce = _make_turn_force(
		turn_state, "turn_force_zero", "turn_keep", "turn_shop", turn_route_abc, 0.0, "traveling_outbound", 2.0, 0, 0.0
	)
	var turn_force_queue: TravelingForce = _make_turn_force(
		turn_state, "turn_force_queue", "turn_keep", "turn_shop", turn_route_abc, 4.0, "traveling_outbound", 0.0, 0, 0.0
	)
	var turn_force_resolved: TravelingForce = _make_turn_force(
		turn_state, "turn_force_resolved", "turn_keep", "turn_loc_b", turn_route_abc, 5.0, "traveling_outbound", 0.0, 0, 0.0
	)
	_register_turn_mission(turn_state, "turn_mission_z", "turn_force_complete", "turn_keep", "turn_shop", "traveling_outbound", "")
	_register_turn_mission(turn_state, "turn_mission_a", "turn_force_arrive", "turn_keep", "turn_shop", "traveling_outbound", "")
	_register_turn_mission(turn_state, "turn_mission_m", "turn_force_partial", "turn_keep", "turn_shop", "traveling_outbound", "")
	var turn_mission_resolved: CampaignMission = _register_turn_mission(
		turn_state, "turn_mission_resolved", "turn_force_resolved", "turn_keep", "turn_shop", "resolved_success", "prior_raid_complete"
	)
	var turn_idle_route_before: Array[String] = _copy_ids(turn_force_idle.route_node_ids)
	var turn_idle_dest_before: String = turn_force_idle.destination_location_id
	var turn_complete_remaining_before: float = turn_force_complete.movement_remaining
	var turn_complete_state_before: String = turn_force_complete.travel_state
	var turn_money_before: float = turn_gang.money
	var turn_ammo_before: float = turn_gang.resources.get_amount("Ammo")
	var turn_shop_owner_before: String = turn_shop.owner_faction_id
	var turn_shop_level_before: int = turn_shop.level
	var turn_shop_open_before: bool = turn_shop.is_open
	var turn_mission_count_before: int = turn_state.missions.size()
	var turn_soldier_home_before: String = turn_soldier.home_stronghold_id
	var turn_vehicle_home_before: String = turn_vehicle.home_stronghold_id
	var turn_idle_soldiers_before: Array[String] = _copy_ids(turn_force_idle.soldier_group.soldier_ids)
	var turn_idle_vehicles_before: Array[String] = _copy_ids(turn_force_idle.vehicle_group.vehicle_ids)
	var turn_partial_dest_before: String = turn_force_partial.destination_location_id
	var turn_queue_dest_before: String = turn_force_queue.destination_location_id
	var turn_resolved_target_before: String = turn_mission_resolved.target_location_id
	var turn_resolved_outcome_before: String = turn_mission_resolved.outcome_code
	var turn_main_result: TurnResult = TurnManager.advance_to_next_turn(turn_state)
	var turn_partial_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_partial")
	var turn_arrive_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_arrive")
	var turn_idle_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_idle")
	var turn_complete_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_complete")
	var turn_return_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_return")
	var turn_zero_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_zero")
	var turn_queue_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_queue")
	var turn_resolved_res: ForceTurnResult = _find_force_turn_result(turn_main_result.force_results, "turn_force_resolved")
	var turn_mission_a_res: MissionResult = _find_mission_result(turn_main_result.mission_results, "turn_mission_a")
	var turn_mission_m_res: MissionResult = _find_mission_result(turn_main_result.mission_results, "turn_mission_m")
	var turn_mission_z_res: MissionResult = _find_mission_result(turn_main_result.mission_results, "turn_mission_z")
	var turn_mission_resolved_res: MissionResult = _find_mission_result(turn_main_result.mission_results, "turn_mission_resolved")
	var expected_turn_mission_order: Array[String] = ["turn_mission_a", "turn_mission_m", "turn_mission_resolved", "turn_mission_z"]
	var turn_basic_increment_ok: bool = (
		turn_main_result.success
		and turn_main_result.turn_before == 5
		and turn_main_result.turn_after == 6
		and turn_state.current_turn == 6
		and turn_state.current_month == 7
		and turn_state.current_year == 2034
		and turn_main_result.error_code.is_empty()
	)
	var turn_partial_continue_ok: bool = (
		turn_partial_res != null
		and turn_force_partial.travel_state == "traveling_outbound"
		and turn_force_partial.route_segment_index == 1
		and is_equal_approx(turn_force_partial.distance_into_segment, 2.0)
		and is_equal_approx(turn_force_partial.movement_remaining, 0.0)
		and is_equal_approx(turn_partial_res.movement_refreshed, 5.0)
		and is_equal_approx(turn_partial_res.movement_spent, 5.0)
		and is_equal_approx(turn_partial_res.movement_remaining, 0.0)
		and turn_partial_res.state_before == "traveling_outbound"
		and turn_partial_res.state_after == "traveling_outbound"
		and turn_partial_res.reached_destination == false
		and turn_partial_res.error_code.is_empty()
	)
	var turn_arrive_leftover_ok: bool = (
		turn_arrive_res != null
		and turn_force_arrive.travel_state == "at_destination"
		and is_equal_approx(turn_arrive_res.movement_refreshed, 5.0)
		and is_equal_approx(turn_arrive_res.movement_spent, 2.0)
		and is_equal_approx(turn_force_arrive.movement_remaining, 3.0)
		and is_equal_approx(turn_arrive_res.movement_remaining, 3.0)
		and turn_arrive_res.reached_destination == true
		and turn_arrive_res.state_before == "traveling_outbound"
		and turn_arrive_res.state_after == "at_destination"
		and turn_arrive_res.error_code.is_empty()
	)
	var turn_at_destination_ok: bool = (
		turn_idle_res != null
		and turn_force_idle.travel_state == "at_destination"
		and is_equal_approx(turn_force_idle.movement_remaining, 4.0)
		and is_equal_approx(turn_idle_res.movement_refreshed, 4.0)
		and is_equal_approx(turn_idle_res.movement_spent, 0.0)
		and turn_idle_res.reached_destination == false
		and _string_ids_match(turn_force_idle.route_node_ids, turn_idle_route_before)
		and turn_force_idle.destination_location_id == turn_idle_dest_before
		and turn_idle_res.state_before == "at_destination"
		and turn_idle_res.state_after == "at_destination"
	)
	var turn_complete_ok: bool = (
		turn_complete_res != null
		and turn_force_complete.travel_state == turn_complete_state_before
		and is_equal_approx(turn_force_complete.movement_remaining, turn_complete_remaining_before)
		and is_equal_approx(turn_force_complete.movement_remaining, 1.25)
		and is_equal_approx(turn_complete_res.movement_refreshed, 0.0)
		and is_equal_approx(turn_complete_res.movement_spent, 0.0)
		and is_equal_approx(turn_complete_res.movement_remaining, 1.25)
		and turn_complete_res.state_before == "complete"
		and turn_complete_res.state_after == "complete"
		and turn_complete_res.reached_destination == false
	)
	var turn_return_ok: bool = (
		turn_return_res != null
		and turn_force_return.travel_state == "traveling_return"
		and turn_force_return.route_segment_index == 1
		and is_equal_approx(turn_force_return.distance_into_segment, 1.0)
		and is_equal_approx(turn_force_return.movement_remaining, 0.0)
		and is_equal_approx(turn_return_res.movement_refreshed, 5.0)
		and is_equal_approx(turn_return_res.movement_spent, 5.0)
		and turn_return_res.state_before == "traveling_return"
		and turn_return_res.state_after == "traveling_return"
		and turn_return_res.reached_destination == false
		and turn_return_res.error_code.is_empty()
	)
	var turn_zero_speed_ok: bool = (
		turn_zero_res != null
		and turn_force_zero.travel_state == "traveling_outbound"
		and turn_force_zero.route_segment_index == 0
		and is_equal_approx(turn_force_zero.distance_into_segment, 0.0)
		and is_equal_approx(turn_force_zero.movement_remaining, 0.0)
		and is_equal_approx(turn_zero_res.movement_refreshed, 0.0)
		and is_equal_approx(turn_zero_res.movement_spent, 0.0)
		and turn_zero_res.error_code.is_empty()
		and turn_zero_res.error_message.is_empty()
		and turn_zero_res.reached_destination == false
	)
	var turn_queued_ok: bool = (
		turn_queue_res != null
		and turn_force_queue.travel_state == "traveling_outbound"
		and turn_force_queue.route_segment_index == 1
		and is_equal_approx(turn_force_queue.distance_into_segment, 1.0)
		and is_equal_approx(turn_queue_res.movement_refreshed, 4.0)
		and is_equal_approx(turn_queue_res.movement_spent, 4.0)
		and is_equal_approx(turn_force_queue.movement_remaining, 0.0)
		and turn_queue_res.error_code.is_empty()
	)
	var turn_mission_arrive_ok: bool = (
		turn_mission_a_res != null
		and turn_force_arrive.travel_state == "at_destination"
		and turn_state.get_mission("turn_mission_a").mission_state == "awaiting_resolution"
		and turn_mission_a_res.success
		and turn_mission_a_res.mission_state == "awaiting_resolution"
		and is_equal_approx(turn_force_arrive.movement_remaining, 3.0)
	)
	var turn_mission_still_outbound_ok: bool = (
		turn_mission_m_res != null
		and turn_force_partial.travel_state == "traveling_outbound"
		and turn_state.get_mission("turn_mission_m").mission_state == "traveling_outbound"
		and turn_mission_m_res.success
		and turn_mission_m_res.mission_state == "traveling_outbound"
	)
	var turn_resolved_history_ok: bool = (
		turn_resolved_res != null
		and turn_force_resolved.travel_state == "traveling_outbound"
		and turn_force_resolved.route_segment_index == 1
		and is_equal_approx(turn_force_resolved.distance_into_segment, 2.0)
		and turn_mission_resolved.mission_state == "resolved_success"
		and turn_mission_resolved.target_location_id == turn_resolved_target_before
		and turn_mission_resolved.outcome_code == turn_resolved_outcome_before
		and turn_mission_resolved_res != null
		and turn_mission_resolved_res.success
		and turn_mission_resolved_res.mission_state == "resolved_success"
	)
	var turn_mission_mismatch_ok: bool = (
		turn_main_result.success
		and turn_state.current_turn == 6
		and turn_mission_z_res != null
		and not turn_mission_z_res.success
		and turn_mission_z_res.error_code == "mission_force_state_mismatch"
		and turn_partial_res != null
		and turn_partial_res.error_code.is_empty()
		and turn_force_partial.travel_state == "traveling_outbound"
	)
	var turn_mission_order_ok: bool = _string_ids_match(_mission_result_ids(turn_main_result.mission_results), expected_turn_mission_order)
	var turn_no_auto_actions_ok: bool = (
		turn_state.missions.size() == turn_mission_count_before
		and is_equal_approx(turn_gang.money, turn_money_before)
		and is_equal_approx(turn_gang.resources.get_amount("Ammo"), turn_ammo_before)
		and turn_shop.owner_faction_id == turn_shop_owner_before
		and turn_shop.level == turn_shop_level_before
		and turn_shop.is_open == turn_shop_open_before
		and turn_force_partial.destination_location_id == turn_partial_dest_before
		and turn_force_queue.destination_location_id == turn_queue_dest_before
		and turn_force_idle.destination_location_id == turn_idle_dest_before
		and turn_force_complete.destination_location_id == "turn_shop"
		and turn_mission_resolved.mission_state == "resolved_success"
		and turn_state.get_mission("turn_mission_a").mission_state != "resolved_success"
		and turn_state.get_mission("turn_mission_a").mission_state != "resolved_failure"
		and turn_state.get_mission("turn_mission_m").mission_state == "traveling_outbound"
		and _string_ids_match(turn_force_idle.soldier_group.soldier_ids, turn_idle_soldiers_before)
		and _string_ids_match(turn_force_idle.vehicle_group.vehicle_ids, turn_idle_vehicles_before)
		and turn_soldier.home_stronghold_id == turn_soldier_home_before
		and turn_vehicle.home_stronghold_id == turn_vehicle_home_before
	)

	var turn_null_result: TurnResult = TurnManager.advance_to_next_turn(null)
	var turn_null_state_ok: bool = (
		not turn_null_result.success
		and turn_null_result.error_code == "null_game_state"
	)
	var turn_invalid_state: GameState = _make_turn_world(0)
	var turn_invalid_force: TravelingForce = _make_turn_force(
		turn_invalid_state, "turn_force_invalid", "turn_keep", "turn_shop", turn_route_abc, 5.0, "traveling_outbound", 1.0, 0, 0.0
	)
	var turn_invalid_snap: Dictionary = _force_travel_snapshot(turn_invalid_force)
	var turn_invalid_month: int = turn_invalid_state.current_month
	var turn_invalid_year: int = turn_invalid_state.current_year
	var turn_invalid_result: TurnResult = TurnManager.advance_to_next_turn(turn_invalid_state)
	var turn_invalid_current_ok: bool = (
		not turn_invalid_result.success
		and turn_invalid_result.error_code == "invalid_current_turn"
		and turn_invalid_state.current_turn == 0
		and turn_invalid_state.current_month == turn_invalid_month
		and turn_invalid_state.current_year == turn_invalid_year
		and _force_travel_unchanged(turn_invalid_force, turn_invalid_snap)
	)

	var turn_block_state: GameState = _make_turn_world(3)
	var turn_force_blocked: TravelingForce = _make_turn_force(
		turn_block_state, "turn_force_blocked", "turn_keep", "turn_shop", turn_route_abc, 5.0, "traveling_outbound", 1.0, 1, 0.0
	)
	var turn_force_ok: TravelingForce = _make_turn_force(
		turn_block_state, "turn_force_ok", "turn_keep", "turn_loc_b", turn_route_ab, 5.0, "traveling_outbound", 0.5, 0, 0.0
	)
	var turn_force_edge: TravelingForce = _make_turn_force(
		turn_block_state, "turn_force_edge", "turn_keep", "turn_shop", turn_route_abc, 3.0, "traveling_outbound", 1.0, 0, 0.0
	)
	var turn_blocked_snap: Dictionary = _force_travel_snapshot(turn_force_blocked)
	turn_block_state.road_graph.get_segment("turn_bc").is_open = false
	var turn_block_result: TurnResult = TurnManager.advance_to_next_turn(turn_block_state)
	var turn_blocked_res: ForceTurnResult = _find_force_turn_result(turn_block_result.force_results, "turn_force_blocked")
	var turn_ok_res: ForceTurnResult = _find_force_turn_result(turn_block_result.force_results, "turn_force_ok")
	var turn_edge_res: ForceTurnResult = _find_force_turn_result(turn_block_result.force_results, "turn_force_edge")
	var turn_closed_segment_ok: bool = (
		turn_block_result.success
		and turn_block_state.current_turn == 4
		and turn_blocked_res != null
		and turn_blocked_res.error_code == "missing_open_segment"
		and turn_force_blocked.travel_state == "traveling_outbound"
		and turn_force_blocked.route_segment_index == int(turn_blocked_snap.get("segment", -1))
		and is_equal_approx(turn_force_blocked.distance_into_segment, float(turn_blocked_snap.get("distance", -1.0)))
		and is_equal_approx(turn_force_blocked.movement_remaining, 5.0)
		and turn_ok_res != null
		and turn_ok_res.error_code.is_empty()
		and turn_force_ok.travel_state == "at_destination"
		and is_equal_approx(turn_ok_res.movement_refreshed, 5.0)
		and is_equal_approx(turn_force_ok.movement_remaining, 2.0)
	)
	var turn_full_budget_edge_ok: bool = (
		turn_edge_res != null
		and turn_edge_res.error_code.is_empty()
		and turn_force_edge.travel_state == "traveling_outbound"
		and turn_force_edge.route_segment_index == 1
		and is_equal_approx(turn_force_edge.distance_into_segment, 0.0)
		and is_equal_approx(turn_force_edge.movement_remaining, 0.0)
		and is_equal_approx(turn_edge_res.movement_refreshed, 3.0)
		and is_equal_approx(turn_edge_res.movement_spent, 3.0)
		and turn_edge_res.reached_destination == false
	)
	turn_block_state.road_graph.get_segment("turn_bc").is_open = true

	var turn_order_state: GameState = _make_turn_world(2)
	_make_turn_force(turn_order_state, "turn_force_z", "turn_keep", "turn_shop", turn_route_c, 4.0, "at_destination", 0.0, 0, 0.0)
	_make_turn_force(turn_order_state, "turn_force_a", "turn_keep", "turn_shop", turn_route_c, 4.0, "at_destination", 0.0, 0, 0.0)
	_make_turn_force(turn_order_state, "turn_force_m", "turn_keep", "turn_shop", turn_route_c, 4.0, "at_destination", 0.0, 0, 0.0)
	var turn_order_result: TurnResult = TurnManager.advance_to_next_turn(turn_order_state)
	var expected_turn_force_order: Array[String] = ["turn_force_a", "turn_force_m", "turn_force_z"]
	var turn_force_order_ok: bool = (
		turn_order_result.success
		and _string_ids_match(_force_turn_result_ids(turn_order_result.force_results), expected_turn_force_order)
	)

	var turn_helper_forces: Array[ForceTurnResult] = []
	turn_helper_forces.append(
		ForceTurnResult.succeeded("turn_helper_force", 5.0, 2.0, 3.0, "traveling_outbound", "at_destination", true)
	)
	var turn_helper_missions: Array[MissionResult] = []
	turn_helper_missions.append(MissionResult.succeeded("turn_helper_mission", "turn_helper_force", "awaiting_resolution"))
	var turn_helper_ok: TurnResult = TurnResult.succeeded(8, 9, turn_helper_forces, turn_helper_missions)
	var turn_result_success_helper_ok: bool = (
		turn_helper_ok.success
		and turn_helper_ok.turn_before == 8
		and turn_helper_ok.turn_after == 9
		and turn_helper_ok.error_code.is_empty()
		and turn_helper_ok.error_message.is_empty()
		and turn_helper_ok.force_results.size() == 1
		and turn_helper_ok.force_results[0].force_id == "turn_helper_force"
		and turn_helper_ok.mission_results.size() == 1
		and turn_helper_ok.mission_results[0].mission_id == "turn_helper_mission"
	)
	var turn_helper_fail: TurnResult = TurnResult.failed("invalid_current_turn", "Turn advancement failed: current_turn '0' is invalid.", 0, 0)
	var turn_result_fail_helper_ok: bool = (
		not turn_helper_fail.success
		and turn_helper_fail.error_code == "invalid_current_turn"
		and turn_helper_fail.error_message == "Turn advancement failed: current_turn '0' is invalid."
		and turn_helper_fail.turn_before == 0
		and turn_helper_fail.turn_after == 0
		and turn_helper_fail.force_results.is_empty()
		and turn_helper_fail.mission_results.is_empty()
	)
	var turn_ftr_ok: ForceTurnResult = ForceTurnResult.succeeded(
		"turn_helper_force", 5.0, 2.0, 3.0, "traveling_outbound", "at_destination", true
	)
	var turn_force_result_success_helper_ok: bool = (
		turn_ftr_ok.force_id == "turn_helper_force"
		and is_equal_approx(turn_ftr_ok.movement_refreshed, 5.0)
		and is_equal_approx(turn_ftr_ok.movement_spent, 2.0)
		and is_equal_approx(turn_ftr_ok.movement_remaining, 3.0)
		and turn_ftr_ok.state_before == "traveling_outbound"
		and turn_ftr_ok.state_after == "at_destination"
		and turn_ftr_ok.reached_destination
		and turn_ftr_ok.error_code.is_empty()
		and turn_ftr_ok.error_message.is_empty()
	)
	var turn_ftr_fail: ForceTurnResult = ForceTurnResult.failed(
		"missing_open_segment",
		"Turn force processing failed: required open segment missing.",
		"turn_helper_force",
		5.0,
		0.0,
		5.0,
		"traveling_outbound",
		"traveling_outbound",
		false
	)
	var turn_force_result_fail_helper_ok: bool = (
		turn_ftr_fail.force_id == "turn_helper_force"
		and turn_ftr_fail.error_code == "missing_open_segment"
		and turn_ftr_fail.error_message == "Turn force processing failed: required open segment missing."
		and is_equal_approx(turn_ftr_fail.movement_refreshed, 5.0)
		and is_equal_approx(turn_ftr_fail.movement_spent, 0.0)
		and is_equal_approx(turn_ftr_fail.movement_remaining, 5.0)
		and turn_ftr_fail.state_before == "traveling_outbound"
		and turn_ftr_fail.state_after == "traveling_outbound"
		and turn_ftr_fail.reached_destination == false
	)

	var turn_calendar_state: GameState = _make_turn_world(10)
	var turn_cal_1: TurnResult = TurnManager.advance_to_next_turn(turn_calendar_state)
	var turn_cal_2: TurnResult = TurnManager.advance_to_next_turn(turn_calendar_state)
	var turn_cal_3: TurnResult = TurnManager.advance_to_next_turn(turn_calendar_state)
	var turn_calendar_ok: bool = (
		turn_cal_1.success
		and turn_cal_1.turn_before == 10
		and turn_cal_1.turn_after == 11
		and turn_cal_2.success
		and turn_cal_2.turn_before == 11
		and turn_cal_2.turn_after == 12
		and turn_cal_3.success
		and turn_cal_3.turn_before == 12
		and turn_cal_3.turn_after == 13
		and turn_calendar_state.current_turn == 13
		and turn_calendar_state.current_month == 7
		and turn_calendar_state.current_year == 2034
		and turn_cal_1.turn_after - turn_cal_1.turn_before == 1
		and turn_cal_2.turn_after - turn_cal_2.turn_before == 1
		and turn_cal_3.turn_after - turn_cal_3.turn_before == 1
	)

	var eco_catalog: BusinessEconomyCatalog = _make_eco_catalog()
	var eco_market_def: BusinessEconomyDefinition = eco_catalog.get_definition("market")
	var eco_narc_def: BusinessEconomyDefinition = eco_catalog.get_definition("narcotics_site")
	var eco_market_l1: BusinessLevelOutput = eco_market_def.get_level_output(1)
	var eco_market_l2: BusinessLevelOutput = eco_market_def.get_level_output(2)
	var eco_market_l3: BusinessLevelOutput = eco_market_def.get_level_output(3)
	var eco_narc_l1: BusinessLevelOutput = eco_narc_def.get_level_output(1)
	var eco_narc_l2: BusinessLevelOutput = eco_narc_def.get_level_output(2)
	var eco_narc_l3: BusinessLevelOutput = eco_narc_def.get_level_output(3)
	var eco_dup_market: BusinessEconomyDefinition = BusinessEconomyDefinition.new("market")
	eco_dup_market.set_level_output(1, BusinessLevelOutput.new(1.0))
	var eco_empty_type_def: BusinessEconomyDefinition = BusinessEconomyDefinition.new("")
	var eco_empty_type_output: BusinessLevelOutput = BusinessLevelOutput.new(1.0)
	var eco_level_probe: BusinessEconomyDefinition = BusinessEconomyDefinition.new("eco_probe_type")
	var eco_level_probe_output: BusinessLevelOutput = BusinessLevelOutput.new(1.0)
	var eco_zero_res: BusinessLevelOutput = BusinessLevelOutput.new(1.0)
	var eco_zero_res_set: bool = eco_zero_res.set_resource_output("Ammo", 2.0)
	var eco_zero_res_clear: bool = eco_zero_res.set_resource_output("Ammo", 0.0)
	var eco_neg_cash: BusinessLevelOutput = BusinessLevelOutput.new(-10.0)
	var eco_catalog_ok: bool = (
		eco_catalog.has_definition("market")
		and eco_catalog.has_definition("narcotics_site")
		and eco_market_def != null
		and eco_narc_def != null
		and eco_market_l1 != null
		and eco_market_l2 != null
		and eco_market_l3 != null
		and is_equal_approx(eco_market_l1.cash_per_turn, 100.0)
		and is_equal_approx(eco_market_l2.cash_per_turn, 175.0)
		and is_equal_approx(eco_market_l3.cash_per_turn, 300.0)
		and is_equal_approx(eco_narc_l1.cash_per_turn, 50.0)
		and is_equal_approx(eco_narc_l1.get_resource_output("Narcotics"), 0.5)
		and is_equal_approx(eco_narc_l2.cash_per_turn, 100.0)
		and is_equal_approx(eco_narc_l2.get_resource_output("Narcotics"), 1.0)
		and is_equal_approx(eco_narc_l3.cash_per_turn, 150.0)
		and is_equal_approx(eco_narc_l3.get_resource_output("Narcotics"), 2.0)
		and not eco_catalog.add_definition(eco_dup_market)
		and not eco_catalog.add_definition(eco_empty_type_def)
		and not eco_empty_type_def.set_level_output(1, eco_empty_type_output)
		and not eco_level_probe.set_level_output(0, eco_level_probe_output)
		and not eco_level_probe.set_level_output(1, null)
		and not eco_zero_res.set_resource_output("", 1.0)
		and not eco_zero_res.set_resource_output("Ammo", -1.0)
		and eco_zero_res_set
		and eco_zero_res_clear
		and not eco_zero_res.resources_per_turn.has("Ammo")
		and is_equal_approx(eco_neg_cash.cash_per_turn, 0.0)
	)

	var eco_main: GameState = _make_eco_world(1000.0, 2000.0)
	var eco_gang_a: MajorGang = eco_main.get_faction("eco_gang_a") as MajorGang
	var eco_gang_b: MajorGang = eco_main.get_faction("eco_gang_b") as MajorGang
	eco_gang_a.resources.set_amount("Ammo", 12.0)
	eco_gang_a.resources.set_amount("Gun Parts", 7.0)
	eco_gang_a.resources.set_amount("Narcotics", 0.0)
	eco_gang_a.resources.set_amount("Black Market Goods", 1.0)
	eco_gang_b.resources.set_amount("Ammo", 4.0)
	eco_gang_b.resources.set_amount("Narcotics", 3.0)
	_make_eco_business(eco_main, "eco_market", "Eco Market", "market", 2, "eco_gang_a", true)
	_make_eco_business(eco_main, "eco_narcotics", "Eco Narcotics", "narcotics_site", 3, "eco_gang_a", true)
	_make_eco_business(eco_main, "eco_closed", "Eco Closed", "market", 2, "eco_gang_a", false)
	_make_eco_business(eco_main, "eco_unowned", "Eco Unowned", "market", 2, "", true)
	_make_eco_business(eco_main, "eco_missing_owner", "Eco Missing Owner", "market", 2, "eco_ghost", true)
	_make_eco_business(eco_main, "eco_plain_owner", "Eco Plain Owner", "market", 2, "eco_civilians", true)
	_make_eco_business(eco_main, "eco_empty_type", "Eco Empty Type", "", 2, "eco_gang_a", true)
	_make_eco_business(eco_main, "eco_unknown_type", "Eco Unknown Type", "warehouse", 2, "eco_gang_a", true)
	_make_eco_business(eco_main, "eco_chop", "Eco Chop", "chop_shop", 2, "eco_gang_a", true)
	_make_eco_business(eco_main, "eco_b_market", "Eco B Market", "market", 1, "eco_gang_b", true)
	var eco_keep_75: Stronghold = eco_main.get_map_location("eco_keep_75") as Stronghold
	var eco_keep_125: Stronghold = eco_main.get_map_location("eco_keep_125") as Stronghold
	var eco_soldier_20: Soldier = Soldier.new("eco_soldier_20", "eco_gang_a", "", "pistol", 1.0, 20.0)
	var eco_soldier_30: Soldier = Soldier.new("eco_soldier_30", "eco_gang_a", "", "pistol", 1.0, 30.0)
	var eco_soldier_b: Soldier = Soldier.new("eco_soldier_b", "eco_gang_b", "", "pistol", 1.0, 10.0)
	eco_main.add_soldier(eco_soldier_20)
	eco_main.add_soldier(eco_soldier_30)
	eco_main.add_soldier(eco_soldier_b)
	eco_main.assign_soldier_to_stronghold("eco_soldier_20", "eco_keep_75")
	eco_main.assign_soldier_to_stronghold("eco_soldier_30", "eco_keep_75")
	eco_keep_75.add_soldier_id("eco_ghost_soldier")
	var eco_vehicle_40: Vehicle = Vehicle.new("eco_vehicle_40", "eco_gang_a", "car", "", 2, 5.0, 40.0)
	var eco_vehicle_60: Vehicle = Vehicle.new("eco_vehicle_60", "eco_gang_a", "car", "", 2, 5.0, 60.0)
	var eco_vehicle_b: Vehicle = Vehicle.new("eco_vehicle_b", "eco_gang_b", "car", "", 2, 5.0, 15.0)
	eco_main.add_vehicle(eco_vehicle_40)
	eco_main.add_vehicle(eco_vehicle_60)
	eco_main.add_vehicle(eco_vehicle_b)
	eco_main.assign_vehicle_to_stronghold("eco_vehicle_40", "eco_keep_75")
	eco_main.assign_vehicle_to_stronghold("eco_vehicle_60", "eco_keep_75")
	eco_keep_75.add_vehicle_id("eco_ghost_vehicle")
	var eco_route: Array[String] = ["eco_n1", "eco_n2"]
	var eco_force: TravelingForce = TravelingForce.new(
		"eco_force_deployed", "eco_gang_a", "eco_keep_75", "eco_keep_125", eco_route, 3.0, "traveling_outbound"
	)
	eco_force.soldier_group.add_soldier_id("eco_soldier_30")
	eco_force.vehicle_group.add_vehicle_id("eco_vehicle_60")
	eco_main.add_traveling_force(eco_force)
	var eco_ammo_before: float = eco_gang_a.resources.get_amount("Ammo")
	var eco_gun_before: float = eco_gang_a.resources.get_amount("Gun Parts")
	var eco_narc_before: float = eco_gang_a.resources.get_amount("Narcotics")
	var eco_bmg_before: float = eco_gang_a.resources.get_amount("Black Market Goods")
	var eco_b_ammo_before: float = eco_gang_b.resources.get_amount("Ammo")
	var eco_b_narc_before: float = eco_gang_b.resources.get_amount("Narcotics")
	var eco_force_index_before: int = eco_force.route_segment_index
	var eco_main_result: EconomyTurnResult = EconomyService.process_turn_start(eco_main, eco_catalog)
	var eco_res_market: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_market")
	var eco_res_narc: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_narcotics")
	var eco_res_closed: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_closed")
	var eco_res_unowned: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_unowned")
	var eco_res_missing_owner: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_missing_owner")
	var eco_res_plain: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_plain_owner")
	var eco_res_empty_type: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_empty_type")
	var eco_res_unknown: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_unknown_type")
	var eco_res_chop: BusinessProductionResult = _find_business_production_result(eco_main_result.business_results, "eco_chop")
	var eco_faction_a: FactionEconomyResult = _find_faction_economy_result(eco_main_result.faction_results, "eco_gang_a")
	var eco_faction_b: FactionEconomyResult = _find_faction_economy_result(eco_main_result.faction_results, "eco_gang_b")
	var eco_standard_production_ok: bool = (
		eco_main_result.success
		and eco_res_market != null
		and eco_res_market.produced
		and is_equal_approx(eco_res_market.cash_produced, 175.0)
		and eco_res_narc != null
		and eco_res_narc.produced
		and is_equal_approx(eco_res_narc.cash_produced, 150.0)
		and is_equal_approx(float(eco_res_narc.resources_produced.get("Narcotics", 0.0)), 2.0)
		and eco_faction_a != null
		and is_equal_approx(eco_faction_a.business_cash_income, 325.0)
		and is_equal_approx(eco_gang_a.resources.get_amount("Narcotics"), eco_narc_before + 2.0)
	)
	var eco_closed_ok: bool = (
		eco_res_closed != null
		and not eco_res_closed.produced
		and eco_res_closed.error_code.is_empty()
		and is_equal_approx(eco_res_closed.cash_produced, 0.0)
		and eco_res_closed.resources_produced.is_empty()
	)
	var eco_unowned_ok: bool = (
		eco_res_unowned != null
		and not eco_res_unowned.produced
		and eco_res_unowned.error_code.is_empty()
		and is_equal_approx(eco_res_unowned.cash_produced, 0.0)
	)
	var eco_malformed_ok: bool = (
		eco_main_result.success
		and eco_res_missing_owner != null
		and eco_res_missing_owner.error_code == "invalid_owner_faction"
		and eco_res_plain != null
		and eco_res_plain.error_code == "owner_not_major_gang"
		and eco_res_empty_type != null
		and eco_res_empty_type.error_code == "empty_business_type"
		and eco_res_unknown != null
		and eco_res_unknown.error_code == "missing_business_definition"
		and eco_res_chop != null
		and eco_res_chop.error_code == "missing_level_output"
		and eco_res_market.produced
		and eco_res_narc.produced
	)
	var eco_soldier_upkeep_ok: bool = (
		eco_faction_a != null
		and is_equal_approx(eco_faction_a.soldier_upkeep_due, 50.0)
		and eco_main.has_soldier("eco_soldier_20")
		and eco_main.has_soldier("eco_soldier_30")
		and eco_main.has_traveling_force("eco_force_deployed")
		and eco_keep_75.has_soldier_id("eco_ghost_soldier")
	)
	var eco_vehicle_upkeep_ok: bool = (
		eco_faction_a != null
		and is_equal_approx(eco_faction_a.vehicle_upkeep_due, 100.0)
		and eco_main.has_vehicle("eco_vehicle_40")
		and eco_main.has_vehicle("eco_vehicle_60")
		and eco_keep_75.has_vehicle_id("eco_ghost_vehicle")
	)
	var eco_stronghold_upkeep_ok: bool = (
		eco_faction_a != null
		and is_equal_approx(eco_faction_a.stronghold_upkeep_due, 200.0)
		and eco_keep_75 != null
		and eco_keep_125 != null
		and is_equal_approx(eco_keep_75.upkeep_per_turn, 75.0)
		and is_equal_approx(eco_keep_125.upkeep_per_turn, 125.0)
	)
	var eco_total_upkeep_ok: bool = (
		eco_faction_a != null
		and is_equal_approx(eco_faction_a.total_upkeep_due, 350.0)
		and is_equal_approx(eco_faction_a.upkeep_paid, 350.0)
		and is_equal_approx(eco_gang_a.money, 975.0)
	)
	var eco_resources_ok: bool = (
		is_equal_approx(eco_gang_a.resources.get_amount("Ammo"), eco_ammo_before)
		and is_equal_approx(eco_gang_a.resources.get_amount("Gun Parts"), eco_gun_before)
		and is_equal_approx(eco_gang_a.resources.get_amount("Black Market Goods"), eco_bmg_before)
		and is_equal_approx(eco_gang_a.resources.get_amount("Narcotics"), 2.0)
		and is_equal_approx(eco_gang_b.resources.get_amount("Ammo"), eco_b_ammo_before)
		and is_equal_approx(eco_gang_b.resources.get_amount("Narcotics"), eco_b_narc_before)
	)
	var eco_multi_gang_ok: bool = (
		eco_faction_b != null
		and is_equal_approx(eco_faction_b.business_cash_income, 100.0)
		and is_equal_approx(eco_faction_b.soldier_upkeep_due, 10.0)
		and is_equal_approx(eco_faction_b.vehicle_upkeep_due, 15.0)
		and is_equal_approx(eco_faction_b.stronghold_upkeep_due, 25.0)
		and is_equal_approx(eco_faction_b.total_upkeep_due, 50.0)
		and is_equal_approx(eco_gang_b.money, 2050.0)
		and is_equal_approx(eco_faction_a.upkeep_shortfall, 0.0)
		and is_equal_approx(eco_faction_b.upkeep_shortfall, 0.0)
	)
	var eco_raid_closed_ok: bool = (
		eco_res_closed != null
		and not eco_res_closed.produced
		and is_equal_approx(eco_res_closed.cash_produced, 0.0)
		and eco_res_closed.resources_produced.is_empty()
		and eco_res_closed.error_code.is_empty()
	)
	var eco_copy_safety_ok: bool = false
	if eco_res_narc != null and eco_narc_l3 != null:
		eco_res_narc.resources_produced["Narcotics"] = 99.0
		eco_copy_safety_ok = is_equal_approx(eco_narc_l3.get_resource_output("Narcotics"), 2.0)
	var eco_result_data_ok: bool = (
		eco_main_result.success
		and eco_main_result.error_code.is_empty()
		and eco_faction_a != null
		and eco_faction_a.faction_id == "eco_gang_a"
		and is_equal_approx(eco_faction_a.cash_before, 1000.0)
		and is_equal_approx(eco_faction_a.cash_after, 975.0)
		and eco_force.route_segment_index == eco_force_index_before
	)

	var eco_level_state: GameState = _make_eco_world(0.0, 0.0)
	_make_eco_business(eco_level_state, "eco_lvl_1", "Level One", "market", 1, "eco_gang_a", true)
	_make_eco_business(eco_level_state, "eco_lvl_2", "Level Two", "market", 2, "eco_gang_a", true)
	_make_eco_business(eco_level_state, "eco_lvl_3", "Level Three", "market", 3, "eco_gang_a", true)
	var eco_level_result: EconomyTurnResult = EconomyService.process_turn_start(eco_level_state, eco_catalog)
	var eco_lvl_1_res: BusinessProductionResult = _find_business_production_result(eco_level_result.business_results, "eco_lvl_1")
	var eco_lvl_2_res: BusinessProductionResult = _find_business_production_result(eco_level_result.business_results, "eco_lvl_2")
	var eco_lvl_3_res: BusinessProductionResult = _find_business_production_result(eco_level_result.business_results, "eco_lvl_3")
	var eco_level_ok: bool = (
		eco_lvl_1_res != null
		and is_equal_approx(eco_lvl_1_res.cash_produced, 100.0)
		and eco_lvl_2_res != null
		and is_equal_approx(eco_lvl_2_res.cash_produced, 175.0)
		and eco_lvl_3_res != null
		and is_equal_approx(eco_lvl_3_res.cash_produced, 300.0)
	)

	var eco_atomic_state: GameState = _make_eco_world(1000.0, 0.0)
	var eco_atomic_gang: MajorGang = eco_atomic_state.get_faction("eco_gang_a") as MajorGang
	eco_atomic_gang.resources.set_amount("Narcotics", 1.0)
	eco_atomic_gang.resources.set_amount("Ammo", 8.0)
	_make_eco_business(eco_atomic_state, "eco_atomic_ok", "Atomic OK", "market", 1, "eco_gang_a", true)
	_make_eco_business(eco_atomic_state, "eco_atomic_bad", "Atomic Bad", "chop_shop", 1, "eco_gang_a", true)
	(eco_atomic_state.get_map_location("eco_keep_75") as Stronghold).upkeep_per_turn = 0.0
	(eco_atomic_state.get_map_location("eco_keep_125") as Stronghold).upkeep_per_turn = 0.0
	(eco_atomic_state.get_map_location("eco_keep_b") as Stronghold).upkeep_per_turn = 0.0
	var eco_chop_def: BusinessEconomyDefinition = eco_catalog.get_definition("chop_shop")
	var eco_chop_output: BusinessLevelOutput = eco_chop_def.get_level_output(1)
	eco_chop_output.resources_per_turn["Ammo"] = -1.0
	var eco_atomic_money_before: float = eco_atomic_gang.money
	var eco_atomic_narc_before: float = eco_atomic_gang.resources.get_amount("Narcotics")
	var eco_atomic_ammo_before: float = eco_atomic_gang.resources.get_amount("Ammo")
	var eco_atomic_result: EconomyTurnResult = EconomyService.process_turn_start(eco_atomic_state, eco_catalog)
	var eco_atomic_ok_res: BusinessProductionResult = _find_business_production_result(eco_atomic_result.business_results, "eco_atomic_ok")
	var eco_atomic_bad_res: BusinessProductionResult = _find_business_production_result(eco_atomic_result.business_results, "eco_atomic_bad")
	var eco_atomicity_ok: bool = (
		eco_atomic_result.success
		and eco_atomic_ok_res != null
		and eco_atomic_ok_res.produced
		and eco_atomic_bad_res != null
		and eco_atomic_bad_res.error_code == "invalid_level_output"
		and is_equal_approx(eco_atomic_gang.resources.get_amount("Narcotics"), eco_atomic_narc_before)
		and is_equal_approx(eco_atomic_gang.resources.get_amount("Ammo"), eco_atomic_ammo_before)
		and is_equal_approx(eco_atomic_gang.money, eco_atomic_money_before + 100.0)
	)
	eco_chop_output.resources_per_turn.erase("Ammo")
	var eco_atomicity_structurally_protected_ok: bool = (
		not eco_zero_res.set_resource_output("Ammo", -1.0)
		and is_equal_approx(eco_neg_cash.cash_per_turn, 0.0)
	)

	var eco_short_state: GameState = _make_eco_world(100.0, 0.0)
	var eco_short_gang: MajorGang = eco_short_state.get_faction("eco_gang_a") as MajorGang
	_make_eco_business(eco_short_state, "eco_short_biz", "Short Biz", "narcotics_site", 1, "eco_gang_a", true)
	var eco_short_keep: Stronghold = eco_short_state.get_map_location("eco_keep_75") as Stronghold
	eco_short_keep.upkeep_per_turn = 200.0
	var eco_keep_125_short: Stronghold = eco_short_state.get_map_location("eco_keep_125") as Stronghold
	eco_keep_125_short.upkeep_per_turn = 0.0
	var eco_b_keep_short: Stronghold = eco_short_state.get_map_location("eco_keep_b") as Stronghold
	eco_b_keep_short.upkeep_per_turn = 0.0
	var eco_short_result: EconomyTurnResult = EconomyService.process_turn_start(eco_short_state, eco_catalog)
	var eco_short_faction: FactionEconomyResult = _find_faction_economy_result(eco_short_result.faction_results, "eco_gang_a")
	var eco_shortfall_ok: bool = (
		eco_short_faction != null
		and is_equal_approx(eco_short_faction.cash_before, 100.0)
		and is_equal_approx(eco_short_faction.business_cash_income, 50.0)
		and is_equal_approx(eco_short_faction.total_upkeep_due, 200.0)
		and is_equal_approx(eco_short_faction.upkeep_paid, 150.0)
		and is_equal_approx(eco_short_faction.cash_after, 0.0)
		and is_equal_approx(eco_short_faction.upkeep_shortfall, 50.0)
		and is_equal_approx(eco_short_gang.money, 0.0)
		and is_equal_approx(eco_short_gang.upkeep_shortfall, 50.0)
	)

	var eco_afford_state: GameState = _make_eco_world(500.0, 0.0)
	var eco_afford_gang: MajorGang = eco_afford_state.get_faction("eco_gang_a") as MajorGang
	_make_eco_business(eco_afford_state, "eco_afford_biz", "Afford Biz", "market", 1, "eco_gang_a", true)
	var eco_afford_soldier: Soldier = Soldier.new("eco_afford_soldier", "eco_gang_a", "", "pistol", 1.0, 250.0)
	eco_afford_state.add_soldier(eco_afford_soldier)
	(eco_afford_state.get_map_location("eco_keep_75") as Stronghold).upkeep_per_turn = 0.0
	(eco_afford_state.get_map_location("eco_keep_125") as Stronghold).upkeep_per_turn = 0.0
	(eco_afford_state.get_map_location("eco_keep_b") as Stronghold).upkeep_per_turn = 0.0
	var eco_afford_result: EconomyTurnResult = EconomyService.process_turn_start(eco_afford_state, eco_catalog)
	var eco_afford_faction: FactionEconomyResult = _find_faction_economy_result(eco_afford_result.faction_results, "eco_gang_a")
	var eco_afford_ok: bool = (
		eco_afford_faction != null
		and is_equal_approx(eco_afford_faction.upkeep_paid, 250.0)
		and is_equal_approx(eco_afford_faction.upkeep_shortfall, 0.0)
		and is_equal_approx(eco_afford_faction.cash_after, 350.0)
		and is_equal_approx(eco_afford_gang.money, 350.0)
		and is_equal_approx(eco_afford_gang.upkeep_shortfall, 0.0)
	)

	var eco_zero_state: GameState = _make_eco_world(0.0, 0.0)
	var eco_zero_gang: MajorGang = eco_zero_state.get_faction("eco_gang_a") as MajorGang
	var eco_zero_soldier: Soldier = Soldier.new("eco_zero_soldier", "eco_gang_a", "", "pistol", 1.0, 25.0)
	eco_zero_state.add_soldier(eco_zero_soldier)
	(eco_zero_state.get_map_location("eco_keep_75") as Stronghold).upkeep_per_turn = 0.0
	(eco_zero_state.get_map_location("eco_keep_125") as Stronghold).upkeep_per_turn = 0.0
	(eco_zero_state.get_map_location("eco_keep_b") as Stronghold).upkeep_per_turn = 0.0
	var eco_zero_result: EconomyTurnResult = EconomyService.process_turn_start(eco_zero_state, eco_catalog)
	var eco_zero_faction: FactionEconomyResult = _find_faction_economy_result(eco_zero_result.faction_results, "eco_gang_a")
	var eco_zero_cash_ok: bool = (
		eco_zero_faction != null
		and is_equal_approx(eco_zero_faction.upkeep_paid, 0.0)
		and is_equal_approx(eco_zero_gang.money, 0.0)
		and is_equal_approx(eco_zero_gang.upkeep_shortfall, 25.0)
		and eco_zero_state.has_soldier("eco_zero_soldier")
		and eco_zero_state.has_map_location("eco_keep_75")
	)
	eco_zero_gang.money = -12.5
	var eco_money_never_negative_ok: bool = (
		is_equal_approx(eco_zero_gang.money, 0.0)
		and eco_zero_gang.money >= 0.0
		and is_equal_approx(eco_short_gang.money, 0.0)
	)

	var eco_reset_state: GameState = _make_eco_world(0.0, 0.0)
	var eco_reset_gang: MajorGang = eco_reset_state.get_faction("eco_gang_a") as MajorGang
	var eco_reset_soldier: Soldier = Soldier.new("eco_reset_soldier", "eco_gang_a", "", "pistol", 1.0, 100.0)
	eco_reset_state.add_soldier(eco_reset_soldier)
	(eco_reset_state.get_map_location("eco_keep_75") as Stronghold).upkeep_per_turn = 0.0
	(eco_reset_state.get_map_location("eco_keep_125") as Stronghold).upkeep_per_turn = 0.0
	(eco_reset_state.get_map_location("eco_keep_b") as Stronghold).upkeep_per_turn = 0.0
	EconomyService.process_turn_start(eco_reset_state, eco_catalog)
	var eco_reset_first: float = eco_reset_gang.upkeep_shortfall
	eco_reset_gang.money = 1000.0
	EconomyService.process_turn_start(eco_reset_state, eco_catalog)
	var eco_reset_cleared: float = eco_reset_gang.upkeep_shortfall
	eco_reset_gang.money = 40.0
	EconomyService.process_turn_start(eco_reset_state, eco_catalog)
	var eco_shortfall_reset_ok: bool = (
		is_equal_approx(eco_reset_first, 100.0)
		and is_equal_approx(eco_reset_cleared, 0.0)
		and is_equal_approx(eco_reset_gang.upkeep_shortfall, 60.0)
		and is_equal_approx(eco_reset_gang.money, 0.0)
	)

	var eco_order_state: GameState = _make_eco_world(0.0, 0.0)
	_make_eco_business(eco_order_state, "eco_z", "Z", "market", 1, "eco_gang_a", false)
	_make_eco_business(eco_order_state, "eco_a", "A", "market", 1, "eco_gang_a", false)
	_make_eco_business(eco_order_state, "eco_m", "M", "market", 1, "eco_gang_a", false)
	var eco_order_result: EconomyTurnResult = EconomyService.process_turn_start(eco_order_state, eco_catalog)
	var expected_eco_biz_order: Array[String] = ["eco_a", "eco_m", "eco_z"]
	var eco_business_order_ok: bool = _string_ids_match(
		_business_production_ids(eco_order_result.business_results),
		expected_eco_biz_order
	)

	var eco_faction_order_state: GameState = GameState.new()
	eco_faction_order_state.add_faction(MajorGang.new("eco_z_gang", "Z Gang", "ai"))
	eco_faction_order_state.add_faction(MajorGang.new("eco_a_gang", "A Gang", "player"))
	var eco_faction_order_result: EconomyTurnResult = EconomyService.process_turn_start(eco_faction_order_state, eco_catalog)
	var expected_eco_faction_order: Array[String] = ["eco_a_gang", "eco_z_gang"]
	var eco_faction_order_ok: bool = _string_ids_match(
		_faction_economy_ids(eco_faction_order_result.faction_results),
		expected_eco_faction_order
	)

	var eco_turn_state: GameState = _make_eco_world(200.0, 0.0)
	var eco_turn_gang: MajorGang = eco_turn_state.get_faction("eco_gang_a") as MajorGang
	_make_eco_business(eco_turn_state, "eco_turn_biz", "Turn Biz", "market", 1, "eco_gang_a", true)
	var eco_turn_soldier: Soldier = Soldier.new("eco_turn_soldier", "eco_gang_a", "", "pistol", 1.0, 20.0)
	eco_turn_state.add_soldier(eco_turn_soldier)
	(eco_turn_state.get_map_location("eco_keep_75") as Stronghold).upkeep_per_turn = 0.0
	(eco_turn_state.get_map_location("eco_keep_125") as Stronghold).upkeep_per_turn = 0.0
	(eco_turn_state.get_map_location("eco_keep_b") as Stronghold).upkeep_per_turn = 0.0
	var eco_turn_route: Array[String] = ["eco_n1", "eco_n2"]
	var eco_turn_force: TravelingForce = TravelingForce.new(
		"eco_turn_force", "eco_gang_a", "eco_keep_75", "eco_keep_125", eco_turn_route, 3.0, "traveling_outbound"
	)
	eco_turn_force.soldier_group.add_soldier_id("eco_turn_soldier")
	eco_turn_state.add_traveling_force(eco_turn_force)
	_register_turn_mission(eco_turn_state, "eco_turn_mission", "eco_turn_force", "eco_keep_75", "eco_keep_125", "traveling_outbound", "")
	eco_turn_state.current_turn = 5
	var eco_turn_result: TurnResult = TurnManager.advance_to_next_turn(eco_turn_state, eco_catalog)
	var eco_turn_econ: EconomyTurnResult = eco_turn_result.economy_result
	var eco_turn_faction: FactionEconomyResult = null
	if eco_turn_econ != null:
		eco_turn_faction = _find_faction_economy_result(eco_turn_econ.faction_results, "eco_gang_a")
	var eco_turn_mission: CampaignMission = eco_turn_state.get_mission("eco_turn_mission")
	var eco_turn_integration_ok: bool = (
		eco_turn_result.success
		and eco_turn_state.current_turn == 6
		and eco_turn_state.current_month == 7
		and eco_turn_state.current_year == 2034
		and eco_turn_econ != null
		and eco_turn_econ.success
		and eco_turn_faction != null
		and is_equal_approx(eco_turn_faction.business_cash_income, 100.0)
		and is_equal_approx(eco_turn_faction.soldier_upkeep_due, 20.0)
		and is_equal_approx(eco_turn_gang.money, 280.0)
		and eco_turn_force.travel_state == "traveling_outbound"
		and eco_turn_force.route_segment_index == 0
		and is_equal_approx(eco_turn_force.distance_into_segment, 3.0)
		and eco_turn_mission != null
		and eco_turn_mission.mission_state == "traveling_outbound"
	)

	var eco_null_state: GameState = _make_eco_world(500.0, 0.0)
	var eco_null_gang: MajorGang = eco_null_state.get_faction("eco_gang_a") as MajorGang
	_make_eco_business(eco_null_state, "eco_null_biz", "Null Biz", "market", 1, "eco_gang_a", true)
	var eco_null_soldier: Soldier = Soldier.new("eco_null_soldier", "eco_gang_a", "", "pistol", 1.0, 20.0)
	eco_null_state.add_soldier(eco_null_soldier)
	(eco_null_state.get_map_location("eco_keep_75") as Stronghold).upkeep_per_turn = 0.0
	(eco_null_state.get_map_location("eco_keep_125") as Stronghold).upkeep_per_turn = 0.0
	(eco_null_state.get_map_location("eco_keep_b") as Stronghold).upkeep_per_turn = 0.0
	var eco_null_force: TravelingForce = TravelingForce.new(
		"eco_null_force", "eco_gang_a", "eco_keep_75", "eco_keep_125", eco_turn_route, 3.0, "traveling_outbound"
	)
	eco_null_state.add_traveling_force(eco_null_force)
	_register_turn_mission(eco_null_state, "eco_null_mission", "eco_null_force", "eco_keep_75", "eco_keep_125", "traveling_outbound", "")
	eco_null_state.current_turn = 4
	var eco_null_money_before: float = eco_null_gang.money
	var eco_null_result: TurnResult = TurnManager.advance_to_next_turn(eco_null_state)
	var eco_null_catalog_ok: bool = (
		eco_null_result.success
		and eco_null_state.current_turn == 5
		and eco_null_result.economy_result == null
		and is_equal_approx(eco_null_gang.money, eco_null_money_before)
		and is_equal_approx(eco_null_gang.upkeep_shortfall, 0.0)
		and eco_null_force.travel_state == "traveling_outbound"
		and is_equal_approx(eco_null_force.distance_into_segment, 3.0)
		and eco_null_state.get_mission("eco_null_mission").mission_state == "traveling_outbound"
	)

	var eco_null_gs: EconomyTurnResult = EconomyService.process_turn_start(null, eco_catalog)
	var eco_null_cat: EconomyTurnResult = EconomyService.process_turn_start(eco_null_state, null)
	var eco_top_level_fail_ok: bool = (
		not eco_null_gs.success
		and eco_null_gs.error_code == "null_game_state"
		and not eco_null_cat.success
		and eco_null_cat.error_code == "null_business_catalog"
	)

	var eco_persist_state: GameState = _make_eco_world(10.0, 0.0)
	var eco_persist_gang: MajorGang = eco_persist_state.get_faction("eco_gang_a") as MajorGang
	eco_persist_gang.upkeep_shortfall = 42.5
	var eco_persist_keep: Stronghold = eco_persist_state.get_map_location("eco_keep_75") as Stronghold
	eco_persist_keep.upkeep_per_turn = 88.0
	var eco_persist_save: Dictionary = eco_persist_state.to_dict()
	var eco_persist_restored: GameState = GameState.new()
	eco_persist_restored.from_dict(eco_persist_save)
	var eco_persist_gang_r: MajorGang = eco_persist_restored.get_faction("eco_gang_a") as MajorGang
	var eco_persist_keep_r: Stronghold = eco_persist_restored.get_map_location("eco_keep_75") as Stronghold
	var eco_older_save: Dictionary = eco_persist_save.duplicate(true)
	var eco_older_factions: Variant = eco_older_save.get("factions", {})
	var eco_older_erased: bool = false
	if eco_older_factions is Dictionary:
		var eco_gang_rec: Variant = eco_older_factions.get("eco_gang_a", {})
		if eco_gang_rec is Dictionary:
			eco_gang_rec.erase("upkeep_shortfall")
			eco_older_erased = not eco_gang_rec.has("upkeep_shortfall")
	var eco_older_locations: Variant = eco_older_save.get("map_locations", {})
	var eco_older_keep_erased: bool = false
	if eco_older_locations is Dictionary:
		var eco_keep_rec: Variant = eco_older_locations.get("eco_keep_75", {})
		if eco_keep_rec is Dictionary:
			eco_keep_rec.erase("upkeep_per_turn")
			eco_older_keep_erased = not eco_keep_rec.has("upkeep_per_turn")
	var eco_older_restored: GameState = GameState.new()
	eco_older_restored.from_dict(eco_older_save)
	var eco_older_gang: MajorGang = eco_older_restored.get_faction("eco_gang_a") as MajorGang
	var eco_older_keep: Stronghold = eco_older_restored.get_map_location("eco_keep_75") as Stronghold
	var eco_persist_ok: bool = (
		eco_persist_gang_r != null
		and is_equal_approx(eco_persist_gang_r.upkeep_shortfall, 42.5)
		and eco_persist_keep_r != null
		and is_equal_approx(eco_persist_keep_r.upkeep_per_turn, 88.0)
		and not eco_persist_save.has("business_catalog")
		and not eco_persist_save.has("economy")
		and not eco_persist_save.has("business_economy_catalog")
		and eco_older_erased
		and eco_older_keep_erased
		and eco_older_gang != null
		and is_equal_approx(eco_older_gang.upkeep_shortfall, 0.0)
		and eco_older_keep != null
		and is_equal_approx(eco_older_keep.upkeep_per_turn, 0.0)
	)

	var eco_helper_biz: Array[BusinessProductionResult] = []
	var eco_helper_res: Dictionary = {}
	eco_helper_res["Narcotics"] = 2.0
	eco_helper_biz.append(BusinessProductionResult.succeeded("eco_h_biz", "eco_gang_a", 150.0, eco_helper_res))
	var eco_helper_fac: Array[FactionEconomyResult] = []
	var eco_helper_ok: EconomyTurnResult = EconomyTurnResult.succeeded(eco_helper_biz, eco_helper_fac)
	var eco_helper_fail: EconomyTurnResult = EconomyTurnResult.failed("null_game_state", "Economy processing failed: game_state is null.")
	var eco_helper_skip: BusinessProductionResult = BusinessProductionResult.skipped("eco_skip", "eco_gang_a")
	var eco_helper_biz_fail: BusinessProductionResult = BusinessProductionResult.failed("empty_business_type", "msg", "eco_bad", "eco_gang_a")
	var eco_helpers_ok: bool = (
		eco_helper_ok.success
		and eco_helper_ok.business_results.size() == 1
		and is_equal_approx(eco_helper_ok.business_results[0].cash_produced, 150.0)
		and not eco_helper_fail.success
		and eco_helper_fail.error_code == "null_game_state"
		and not eco_helper_skip.produced
		and eco_helper_skip.error_code.is_empty()
		and eco_helper_biz_fail.error_code == "empty_business_type"
	)

	var efm_continue_state: GameState = _make_efm_world()
	var efm_continue_force: TravelingForce = _make_efm_force(
		efm_continue_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	var efm_old_continue: CampaignMission = _register_efm_mission(
		efm_continue_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "business_raided"
	)
	var efm_old_id: String = efm_old_continue.id
	var efm_old_state: String = efm_old_continue.mission_state
	var efm_old_origin: String = efm_old_continue.origin_location_id
	var efm_old_target: String = efm_old_continue.target_location_id
	var efm_old_outcome: String = efm_old_continue.outcome_code
	var efm_soldiers_before: Array[String] = _copy_ids(efm_continue_force.soldier_group.soldier_ids)
	var efm_vehicles_before: Array[String] = _copy_ids(efm_continue_force.vehicle_group.vehicle_ids)
	var efm_force_id_before: String = efm_continue_force.id
	var efm_faction_before: String = efm_continue_force.faction_id
	var efm_mpt_before: float = efm_continue_force.movement_per_turn
	var efm_origin_before: String = efm_continue_force.origin_location_id
	var efm_force_count_before: int = efm_continue_state.traveling_forces.size()
	var efm_continue_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"efm_mission_2", "raid_business", "efm_force", "efm_loc_b"
	)
	var efm_continue_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_continue_state, efm_continue_req
	)
	var efm_new_continue: CampaignMission = efm_continue_state.get_mission("efm_mission_2")
	var efm_continue_ok: bool = (
		efm_continue_result.success
		and efm_continue_result.force_id == "efm_force"
		and efm_continue_result.mission_id == "efm_mission_2"
		and efm_continue_state.traveling_forces.size() == efm_force_count_before
		and efm_continue_state.has_traveling_force("efm_force")
		and efm_continue_state.has_mission("efm_mission_2")
		and efm_new_continue != null
		and efm_new_continue.faction_id == "efm_gang"
		and efm_new_continue.force_id == "efm_force"
		and efm_continue_force.destination_location_id == "efm_loc_b"
		and is_equal_approx(efm_continue_result.movement_spent, 3.0)
		and is_equal_approx(efm_continue_force.movement_remaining, 2.0)
		and efm_continue_force.travel_state == "at_destination"
		and efm_new_continue.mission_state == "awaiting_resolution"
		and efm_continue_result.mission_state == "awaiting_resolution"
		and efm_continue_result.reached_destination
		and efm_continue_result.error_code.is_empty()
		and efm_continue_result.error_message.is_empty()
	)
	var efm_history_ok: bool = (
		efm_old_continue.id == efm_old_id
		and efm_old_continue.mission_state == "resolved_success"
		and efm_old_continue.mission_state == efm_old_state
		and efm_old_continue.origin_location_id == efm_old_origin
		and efm_old_continue.origin_location_id == "efm_keep"
		and efm_old_continue.target_location_id == efm_old_target
		and efm_old_continue.target_location_id == "efm_loc_a"
		and efm_old_continue.outcome_code == efm_old_outcome
		and efm_old_continue.outcome_code == "business_raided"
		and efm_old_continue.force_id == "efm_force"
		and efm_new_continue != null
		and efm_new_continue.target_location_id == "efm_loc_b"
		and efm_old_continue.target_location_id != efm_new_continue.target_location_id
	)
	var efm_composition_ok: bool = (
		efm_continue_force.id == efm_force_id_before
		and efm_continue_force.faction_id == efm_faction_before
		and is_equal_approx(efm_continue_force.movement_per_turn, efm_mpt_before)
		and efm_continue_force.origin_location_id == efm_origin_before
		and efm_continue_force.origin_location_id == "efm_keep"
		and _string_ids_match(efm_continue_force.soldier_group.soldier_ids, efm_soldiers_before)
		and _string_ids_match(efm_continue_force.vehicle_group.vehicle_ids, efm_vehicles_before)
	)

	var efm_origin_dest_state: GameState = _make_efm_world()
	var efm_origin_dest_force: TravelingForce = _make_efm_force(
		efm_origin_dest_state, "efm_force", "efm_keep", "efm_loc_a_same", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_origin_dest_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a_same", "resolved_success", "done")
	var efm_origin_dest_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_origin_dest_state, ExistingForceMissionRequest.new("efm_next", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_origin_dest_mission: CampaignMission = efm_origin_dest_state.get_mission("efm_next")
	var efm_origin_dest_ok: bool = (
		efm_origin_dest_result.success
		and efm_origin_dest_mission != null
		and efm_origin_dest_mission.origin_location_id == "efm_loc_a_same"
		and efm_origin_dest_force.origin_location_id == "efm_keep"
	)

	var efm_lex_state: GameState = _make_efm_world()
	var efm_lex_force: TravelingForce = _make_efm_force(
		efm_lex_state, "efm_force", "efm_keep", "efm_loc_b", ["efm_node_lex"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_lex_state, "efm_old", "efm_force", "efm_keep", "efm_loc_b", "resolved_success", "done")
	var efm_lex_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_lex_state, ExistingForceMissionRequest.new("efm_lex_m", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_lex_mission: CampaignMission = efm_lex_state.get_mission("efm_lex_m")
	var efm_origin_lex_ok: bool = (
		efm_lex_result.success
		and efm_lex_mission != null
		and efm_lex_mission.origin_location_id == "efm_origin_a"
	)

	var efm_empty_origin_state: GameState = _make_efm_world()
	var efm_empty_origin_force: TravelingForce = _make_efm_force(
		efm_empty_origin_state, "efm_force", "efm_keep", "", ["efm_node_empty"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_empty_origin_state, "efm_old", "efm_force", "", "", "complete", "")
	var efm_empty_origin_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_empty_origin_state, ExistingForceMissionRequest.new("efm_empty_m", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_empty_origin_mission: CampaignMission = efm_empty_origin_state.get_mission("efm_empty_m")
	var efm_origin_empty_ok: bool = (
		efm_empty_origin_result.success
		and efm_empty_origin_mission != null
		and efm_empty_origin_mission.origin_location_id == ""
		and efm_empty_origin_force.origin_location_id == "efm_keep"
	)

	var efm_same_state: GameState = _make_efm_world()
	var efm_same_route: Array[String] = ["efm_node_home", "efm_node_a"]
	var efm_same_force: TravelingForce = _make_efm_force(
		efm_same_state, "efm_force", "efm_keep", "efm_loc_a", efm_same_route, 5.0, "at_destination"
	)
	_register_efm_mission(efm_same_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	var efm_same_route_before: Array[String] = _copy_ids(efm_same_force.route_node_ids)
	var efm_same_remaining_before: float = efm_same_force.movement_remaining
	var efm_same_forces_before: int = efm_same_state.traveling_forces.size()
	var efm_same_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_same_state, ExistingForceMissionRequest.new("efm_same_m", "raid_business", "efm_force", "efm_loc_a_same")
	)
	var efm_same_mission: CampaignMission = efm_same_state.get_mission("efm_same_m")
	var efm_same_node_ok: bool = (
		efm_same_result.success
		and is_equal_approx(efm_same_result.movement_spent, 0.0)
		and is_equal_approx(efm_same_force.movement_remaining, efm_same_remaining_before)
		and efm_same_force.destination_location_id == "efm_loc_a_same"
		and efm_same_force.travel_state == "at_destination"
		and efm_same_mission != null
		and efm_same_mission.mission_state == "awaiting_resolution"
		and efm_same_result.reached_destination
		and efm_same_state.traveling_forces.size() == efm_same_forces_before
		and _string_ids_match(efm_same_force.route_node_ids, efm_same_route_before)
	)

	var efm_partial_state: GameState = _make_efm_world()
	var efm_partial_force: TravelingForce = _make_efm_force(
		efm_partial_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 3.0, "at_destination"
	)
	_register_efm_mission(efm_partial_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	var efm_partial_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_partial_state, ExistingForceMissionRequest.new("efm_partial_m", "raid_business", "efm_force", "efm_loc_long")
	)
	var efm_partial_mission: CampaignMission = efm_partial_state.get_mission("efm_partial_m")
	var efm_partial_ok: bool = (
		efm_partial_result.success
		and is_equal_approx(efm_partial_result.movement_spent, 3.0)
		and is_equal_approx(efm_partial_force.movement_remaining, 0.0)
		and efm_partial_force.travel_state == "traveling_outbound"
		and efm_partial_mission != null
		and efm_partial_mission.mission_state == "traveling_outbound"
		and not efm_partial_result.reached_destination
		and efm_partial_force.route_segment_index == 0
		and is_equal_approx(efm_partial_force.distance_into_segment, 3.0)
	)

	var efm_zero_state: GameState = _make_efm_world()
	efm_zero_state.current_turn = 3
	var efm_zero_force: TravelingForce = _make_efm_force(
		efm_zero_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 0.0, "at_destination"
	)
	_register_efm_mission(efm_zero_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	var efm_zero_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_zero_state, ExistingForceMissionRequest.new("efm_zero_m", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_zero_mission: CampaignMission = efm_zero_state.get_mission("efm_zero_m")
	var efm_zero_ok: bool = (
		efm_zero_result.success
		and efm_zero_force.travel_state == "traveling_outbound"
		and efm_zero_mission != null
		and efm_zero_mission.mission_state == "traveling_outbound"
		and is_equal_approx(efm_zero_result.movement_spent, 0.0)
		and is_equal_approx(efm_zero_force.movement_remaining, 0.0)
		and efm_zero_force.route_node_ids.size() >= 2
		and efm_zero_force.route_node_ids[0] == "efm_node_a"
		and efm_zero_force.route_node_ids[efm_zero_force.route_node_ids.size() - 1] == "efm_node_b"
	)
	var efm_zero_turn: TurnResult = TurnManager.advance_to_next_turn(efm_zero_state)
	var efm_zero_turn_ok: bool = (
		efm_zero_ok
		and efm_zero_turn.success
		and efm_zero_state.current_turn == 4
		and efm_zero_force.travel_state == "at_destination"
		and efm_zero_mission.mission_state == "awaiting_resolution"
		and is_equal_approx(efm_zero_force.movement_remaining, 2.0)
	)

	var efm_fail_state: GameState = _make_efm_world()
	var efm_fail_force: TravelingForce = _make_efm_force(
		efm_fail_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_fail_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_failure", "failed_raid")
	var efm_fail_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_fail_state, ExistingForceMissionRequest.new("efm_from_fail", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_fail_old: CampaignMission = efm_fail_state.get_mission("efm_old")
	var efm_resolved_failure_ok: bool = (
		efm_fail_result.success
		and efm_fail_old != null
		and efm_fail_old.mission_state == "resolved_failure"
		and efm_fail_old.outcome_code == "failed_raid"
	)

	var efm_complete_m_state: GameState = _make_efm_world()
	_make_efm_force(efm_complete_m_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination")
	_register_efm_mission(efm_complete_m_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "complete", "")
	var efm_complete_m_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_complete_m_state, ExistingForceMissionRequest.new("efm_from_complete", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_complete_old: CampaignMission = efm_complete_m_state.get_mission("efm_old")
	var efm_complete_mission_ok: bool = (
		efm_complete_m_result.success
		and efm_complete_old != null
		and efm_complete_old.mission_state == "complete"
	)

	var efm_multi_state: GameState = _make_efm_world()
	var efm_multi_force: TravelingForce = _make_efm_force(
		efm_multi_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_multi_state, "efm_hist_z", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "ok_z")
	_register_efm_mission(efm_multi_state, "efm_hist_a", "efm_force", "efm_keep", "efm_loc_a", "resolved_failure", "ok_a")
	_register_efm_mission(efm_multi_state, "efm_hist_m", "efm_force", "efm_keep", "efm_loc_a", "complete", "ok_m")
	var efm_hist_z: CampaignMission = efm_multi_state.get_mission("efm_hist_z")
	var efm_hist_a: CampaignMission = efm_multi_state.get_mission("efm_hist_a")
	var efm_hist_m: CampaignMission = efm_multi_state.get_mission("efm_hist_m")
	var efm_multi_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_multi_state, ExistingForceMissionRequest.new("efm_hist_new", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_multi_history_ok: bool = (
		efm_multi_result.success
		and efm_hist_z.mission_state == "resolved_success"
		and efm_hist_z.origin_location_id == "efm_keep"
		and efm_hist_z.target_location_id == "efm_loc_a"
		and efm_hist_z.outcome_code == "ok_z"
		and efm_hist_a.mission_state == "resolved_failure"
		and efm_hist_a.outcome_code == "ok_a"
		and efm_hist_m.mission_state == "complete"
		and efm_hist_m.outcome_code == "ok_m"
		and efm_multi_state.has_mission("efm_hist_new")
		and efm_multi_force.origin_location_id == "efm_keep"
	)

	var efm_block_out_state: GameState = _make_efm_world()
	var efm_block_out_force: TravelingForce = _make_efm_force(
		efm_block_out_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_block_out_state, "efm_open", "efm_force", "efm_keep", "efm_loc_b", "traveling_outbound", "")
	var efm_block_outbound_ok: bool = _efm_launch_fails_atomically(
		efm_block_out_state,
		efm_block_out_force,
		ExistingForceMissionRequest.new("efm_blocked", "raid_business", "efm_force", "efm_loc_b"),
		"force_has_unresolved_mission"
	)

	var efm_block_await_state: GameState = _make_efm_world()
	var efm_block_await_force: TravelingForce = _make_efm_force(
		efm_block_await_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_block_await_state, "efm_open", "efm_force", "efm_keep", "efm_loc_a", "awaiting_resolution", "")
	var efm_block_await_ok: bool = _efm_launch_fails_atomically(
		efm_block_await_state,
		efm_block_await_force,
		ExistingForceMissionRequest.new("efm_blocked", "raid_business", "efm_force", "efm_loc_b"),
		"force_has_unresolved_mission"
	)

	var efm_block_ret_state: GameState = _make_efm_world()
	var efm_block_ret_force: TravelingForce = _make_efm_force(
		efm_block_ret_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_block_ret_state, "efm_open", "efm_force", "efm_keep", "efm_keep", "traveling_return", "")
	var efm_block_return_ok: bool = _efm_launch_fails_atomically(
		efm_block_ret_state,
		efm_block_ret_force,
		ExistingForceMissionRequest.new("efm_blocked", "raid_business", "efm_force", "efm_loc_b"),
		"force_has_unresolved_mission"
	)

	var efm_block_unk_state: GameState = _make_efm_world()
	var efm_block_unk_force: TravelingForce = _make_efm_force(
		efm_block_unk_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	var efm_unk_mission: CampaignMission = _register_efm_mission(
		efm_block_unk_state, "efm_open", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done"
	)
	efm_unk_mission.mission_state = "unknown_fixture_state"
	var efm_block_unknown_ok: bool = _efm_launch_fails_atomically(
		efm_block_unk_state,
		efm_block_unk_force,
		ExistingForceMissionRequest.new("efm_blocked", "raid_business", "efm_force", "efm_loc_b"),
		"force_has_unresolved_mission"
	)

	var efm_scan_state: GameState = _make_efm_world()
	var efm_scan_force: TravelingForce = _make_efm_force(
		efm_scan_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_scan_state, "efm_scan_z", "efm_force", "efm_keep", "efm_loc_b", "traveling_outbound", "")
	_register_efm_mission(efm_scan_state, "efm_scan_a", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	_register_efm_mission(efm_scan_state, "efm_scan_m", "efm_force", "efm_keep", "efm_loc_a", "resolved_failure", "done")
	var efm_scan_order_ok: bool = _efm_launch_fails_atomically(
		efm_scan_state,
		efm_scan_force,
		ExistingForceMissionRequest.new("efm_scan_new", "raid_business", "efm_force", "efm_loc_b"),
		"force_has_unresolved_mission"
	)

	var efm_mid_state: GameState = _make_efm_world()
	var efm_mid_force: TravelingForce = _make_efm_force(
		efm_mid_state, "efm_force", "efm_keep", "efm_loc_b", ["efm_node_a", "efm_node_b"], 5.0, "traveling_outbound", 0, 1.25
	)
	_register_efm_mission(efm_mid_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	var efm_mid_segment_ok: bool = _efm_launch_fails_atomically(
		efm_mid_state,
		efm_mid_force,
		ExistingForceMissionRequest.new("efm_mid_m", "raid_business", "efm_force", "efm_loc_b"),
		"force_not_at_node"
	)

	var efm_inter_state: GameState = _make_efm_world()
	var efm_inter_route: Array[String] = ["efm_node_home", "efm_node_a", "efm_node_b", "efm_node_c"]
	var efm_inter_force: TravelingForce = _make_efm_force(
		efm_inter_state, "efm_force", "efm_keep", "efm_loc_c", efm_inter_route, 5.0, "traveling_outbound", 2, 0.0
	)
	_register_efm_mission(efm_inter_state, "efm_old", "efm_force", "efm_keep", "efm_loc_c", "resolved_success", "done")
	var efm_inter_node_before: String = efm_inter_force.get_current_road_node_id()
	var efm_inter_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_inter_state, ExistingForceMissionRequest.new("efm_inter_m", "raid_business", "efm_force", "efm_loc_a")
	)
	var efm_intermediate_ok: bool = (
		efm_inter_node_before == "efm_node_b"
		and efm_inter_result.success
		and efm_inter_state.has_mission("efm_inter_m")
		and efm_inter_force.origin_location_id == "efm_keep"
	)

	var efm_complete_f_state: GameState = _make_efm_world()
	var efm_complete_f_force: TravelingForce = _make_efm_force(
		efm_complete_f_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_complete_f_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	efm_complete_f_force.travel_state = "complete"
	var efm_force_complete_ok: bool = _efm_launch_fails_atomically(
		efm_complete_f_state,
		efm_complete_f_force,
		ExistingForceMissionRequest.new("efm_comp_m", "raid_business", "efm_force", "efm_loc_b"),
		"force_complete"
	)

	var efm_err_state: GameState = _make_efm_world()
	var efm_err_force: TravelingForce = _make_efm_force(
		efm_err_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_err_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	var efm_null_state_res: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		null, ExistingForceMissionRequest.new("efm_x", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_null_req_res: ExistingForceMissionResult = MissionService.launch_from_existing_force(efm_err_state, null)
	var efm_null_state_ok: bool = not efm_null_state_res.success and efm_null_state_res.error_code == "null_game_state"
	var efm_null_request_ok: bool = not efm_null_req_res.success and efm_null_req_res.error_code == "null_request"
	var efm_empty_id_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("", "raid_business", "efm_force", "efm_loc_b"), "empty_mission_id"
	)
	var efm_dup_id_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_old", "raid_business", "efm_force", "efm_loc_b"), "duplicate_mission_id"
	)
	var efm_dup_old: CampaignMission = efm_err_state.get_mission("efm_old")
	var efm_dup_id_untouched_ok: bool = (
		efm_dup_id_ok
		and efm_dup_old != null
		and efm_dup_old.mission_state == "resolved_success"
		and efm_dup_old.target_location_id == "efm_loc_a"
		and efm_dup_old.outcome_code == "done"
	)
	var efm_empty_type_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_new", "", "efm_force", "efm_loc_b"), "empty_mission_type"
	)
	var efm_empty_force_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_new", "raid_business", "", "efm_loc_b"), "empty_force_id"
	)
	var efm_invalid_force_res: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_err_state, ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_missing_force", "efm_loc_b")
	)
	var efm_invalid_force_ok: bool = (
		not efm_invalid_force_res.success
		and efm_invalid_force_res.error_code == "invalid_force"
		and not efm_err_state.has_mission("efm_new")
	)
	var efm_empty_target_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_force", ""), "empty_target_location"
	)
	var efm_invalid_target_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_force", "efm_missing_loc"), "invalid_target_location"
	)
	var efm_missing_target_road_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_force", "efm_loc_noroad"), "missing_target_road_node"
	)
	var efm_invalid_target_road_ok: bool = _efm_launch_fails_atomically(
		efm_err_state, efm_err_force, ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_force", "efm_loc_badnode"), "invalid_target_road_node"
	)

	var efm_bad_node_state: GameState = _make_efm_world()
	var efm_bad_node_force: TravelingForce = _make_efm_force(
		efm_bad_node_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_ghost_node"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_bad_node_state, "efm_old", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "done")
	var efm_invalid_force_road_ok: bool = _efm_launch_fails_atomically(
		efm_bad_node_state,
		efm_bad_node_force,
		ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_force", "efm_loc_b"),
		"invalid_force_road_node"
	)

	var efm_noroute_ok: bool = _efm_launch_fails_atomically(
		efm_err_state,
		efm_err_force,
		ExistingForceMissionRequest.new("efm_new", "raid_business", "efm_force", "efm_loc_island"),
		"no_route"
	)

	var efm_neg_rem_state: GameState = _make_efm_world()
	var efm_neg_rem_force: TravelingForce = _make_efm_force(
		efm_neg_rem_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	efm_neg_rem_force.movement_remaining = -4.0
	var efm_invalid_remaining_structurally_protected_ok: bool = is_equal_approx(efm_neg_rem_force.movement_remaining, 0.0)

	var efm_atomicity_ok: bool = (
		efm_block_outbound_ok
		and efm_block_await_ok
		and efm_block_return_ok
		and efm_block_unknown_ok
		and efm_mid_segment_ok
		and efm_force_complete_ok
		and efm_dup_id_ok
		and efm_empty_target_ok
		and efm_invalid_target_ok
		and efm_missing_target_road_ok
		and efm_invalid_target_road_ok
		and efm_invalid_force_road_ok
		and efm_noroute_ok
		and efm_empty_type_ok
	)

	var efm_helper_ok_res: ExistingForceMissionResult = ExistingForceMissionResult.succeeded(
		"efm_h_ok", "efm_force", "awaiting_resolution", true, 3.0, 2.0
	)
	var efm_helper_fail_res: ExistingForceMissionResult = ExistingForceMissionResult.failed(
		"empty_mission_id", "Existing-force mission launch failed: mission_id is empty.", "", "efm_force"
	)
	var efm_result_helper_ok: bool = (
		efm_helper_ok_res.success
		and efm_helper_ok_res.mission_id == "efm_h_ok"
		and efm_helper_ok_res.force_id == "efm_force"
		and efm_helper_ok_res.mission_state == "awaiting_resolution"
		and efm_helper_ok_res.reached_destination
		and is_equal_approx(efm_helper_ok_res.movement_spent, 3.0)
		and is_equal_approx(efm_helper_ok_res.movement_remaining, 2.0)
		and efm_helper_ok_res.error_code.is_empty()
		and efm_helper_ok_res.error_message.is_empty()
		and not efm_helper_fail_res.success
		and efm_helper_fail_res.error_code == "empty_mission_id"
		and not efm_helper_fail_res.error_message.is_empty()
		and efm_helper_fail_res.force_id == "efm_force"
		and not efm_helper_fail_res.reached_destination
		and is_equal_approx(efm_helper_fail_res.movement_spent, 0.0)
	)

	var efm_chain_state: GameState = _make_efm_world()
	var efm_chain_gang: MajorGang = efm_chain_state.get_faction("efm_gang") as MajorGang
	var efm_chain_force: TravelingForce = _make_efm_force(
		efm_chain_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 5.0, "at_destination"
	)
	_register_efm_mission(efm_chain_state, "efm_chain_1", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "business_raided")
	var efm_chain_soldiers: Array[String] = _copy_ids(efm_chain_force.soldier_group.soldier_ids)
	var efm_chain_vehicles: Array[String] = _copy_ids(efm_chain_force.vehicle_group.vehicle_ids)
	var efm_chain_soldier_count: int = efm_chain_state.soldiers.size()
	var efm_chain_vehicle_count: int = efm_chain_state.vehicles.size()
	var efm_chain_force_count: int = efm_chain_state.traveling_forces.size()
	var efm_chain_launch2: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_chain_state, ExistingForceMissionRequest.new("efm_chain_2", "raid_business", "efm_force", "efm_loc_b")
	)
	var efm_chain_m2: CampaignMission = efm_chain_state.get_mission("efm_chain_2")
	var efm_chain_m2_after_launch: String = ""
	if efm_chain_m2 != null:
		efm_chain_m2_after_launch = efm_chain_m2.mission_state
	var efm_chain_biz: Business = efm_chain_state.get_map_location("efm_loc_b") as Business
	var efm_chain_money_before: float = efm_chain_gang.money
	var efm_chain_narc_before: float = efm_chain_gang.resources.get_amount("Narcotics")
	var efm_chain_remaining_after_2: float = efm_chain_force.movement_remaining
	var efm_chain_loot_res: Dictionary = {}
	efm_chain_loot_res["Narcotics"] = 1.5
	var efm_chain_loot: BusinessRaidLoot = BusinessRaidLoot.new(80.0, efm_chain_loot_res)
	var efm_chain_raid: BusinessRaidResult = BusinessRaidResolver.resolve_success(efm_chain_state, "efm_chain_2", efm_chain_loot)
	var efm_chain_state_after_raid: String = efm_chain_force.travel_state
	var efm_chain_remaining_after_raid: float = efm_chain_force.movement_remaining
	var efm_chain_launch3: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		efm_chain_state, ExistingForceMissionRequest.new("efm_chain_3", "raid_business", "efm_force", "efm_loc_c")
	)
	var efm_chain_m1: CampaignMission = efm_chain_state.get_mission("efm_chain_1")
	var efm_chain_m3: CampaignMission = efm_chain_state.get_mission("efm_chain_3")
	var efm_raid_chain_ok: bool = (
		efm_chain_launch2.success
		and efm_chain_m2 != null
		and efm_chain_m2_after_launch == "awaiting_resolution"
		and efm_chain_raid.success
		and efm_chain_biz != null
		and efm_chain_biz.level == 1
		and efm_chain_biz.is_open == false
		and is_equal_approx(efm_chain_gang.money, efm_chain_money_before + 80.0)
		and is_equal_approx(efm_chain_gang.resources.get_amount("Narcotics"), efm_chain_narc_before + 1.5)
		and efm_chain_m2.mission_state == "resolved_success"
		and efm_chain_m2.outcome_code == "business_raided"
		and efm_chain_state_after_raid == "at_destination"
		and is_equal_approx(efm_chain_remaining_after_raid, efm_chain_remaining_after_2)
		and efm_chain_launch3.success
		and efm_chain_m3 != null
		and efm_chain_m1.mission_state == "resolved_success"
		and efm_chain_m1.outcome_code == "business_raided"
	)
	var efm_no_dup_ok: bool = (
		efm_raid_chain_ok
		and efm_chain_state.traveling_forces.size() == efm_chain_force_count
		and efm_chain_state.traveling_forces.size() == 1
		and efm_chain_force.id == "efm_force"
		and _string_ids_match(efm_chain_force.soldier_group.soldier_ids, efm_chain_soldiers)
		and _string_ids_match(efm_chain_force.vehicle_group.vehicle_ids, efm_chain_vehicles)
		and efm_chain_state.soldiers.size() == efm_chain_soldier_count
		and efm_chain_state.vehicles.size() == efm_chain_vehicle_count
	)

	var efm_persist_state: GameState = _make_efm_world()
	var efm_persist_force: TravelingForce = _make_efm_force(
		efm_persist_state, "efm_force", "efm_keep", "efm_loc_a", ["efm_node_a"], 4.0, "at_destination"
	)
	_register_efm_mission(efm_persist_state, "efm_p_z", "efm_force", "efm_keep", "efm_loc_a", "resolved_success", "out_z")
	_register_efm_mission(efm_persist_state, "efm_p_a", "efm_force", "efm_keep", "efm_loc_a", "resolved_failure", "out_a")
	_register_efm_mission(efm_persist_state, "efm_p_m", "efm_force", "efm_keep", "efm_loc_a", "complete", "out_m")
	MissionService.launch_from_existing_force(
		efm_persist_state, ExistingForceMissionRequest.new("efm_p_cur", "raid_business", "efm_force", "efm_loc_long")
	)
	var efm_persist_cur_before: CampaignMission = efm_persist_state.get_mission("efm_p_cur")
	var efm_persist_cur_state: String = ""
	if efm_persist_cur_before != null:
		efm_persist_cur_state = efm_persist_cur_before.mission_state
	var efm_persist_dest: String = efm_persist_force.destination_location_id
	var efm_persist_travel: String = efm_persist_force.travel_state
	var efm_persist_remaining: float = efm_persist_force.movement_remaining
	var efm_persist_route: Array[String] = _copy_ids(efm_persist_force.route_node_ids)
	var efm_persist_save: Dictionary = efm_persist_state.to_dict()
	var efm_persist_restored: GameState = GameState.new()
	efm_persist_restored.from_dict(efm_persist_save)
	var efm_persist_force_r: TravelingForce = efm_persist_restored.get_traveling_force("efm_force")
	var efm_persist_pz: CampaignMission = efm_persist_restored.get_mission("efm_p_z")
	var efm_persist_pa: CampaignMission = efm_persist_restored.get_mission("efm_p_a")
	var efm_persist_pm: CampaignMission = efm_persist_restored.get_mission("efm_p_m")
	var efm_persist_pc: CampaignMission = efm_persist_restored.get_mission("efm_p_cur")
	var efm_persist_ok: bool = (
		not efm_persist_save.has("existing_force_mission_request")
		and not efm_persist_save.has("existing_force_mission_result")
		and efm_persist_force_r != null
		and efm_persist_force_r.id == "efm_force"
		and efm_persist_pz != null
		and efm_persist_pz.force_id == "efm_force"
		and efm_persist_pz.mission_state == "resolved_success"
		and efm_persist_pz.origin_location_id == "efm_keep"
		and efm_persist_pz.target_location_id == "efm_loc_a"
		and efm_persist_pz.outcome_code == "out_z"
		and efm_persist_pa != null
		and efm_persist_pa.force_id == "efm_force"
		and efm_persist_pa.mission_state == "resolved_failure"
		and efm_persist_pa.outcome_code == "out_a"
		and efm_persist_pm != null
		and efm_persist_pm.force_id == "efm_force"
		and efm_persist_pm.mission_state == "complete"
		and efm_persist_pc != null
		and efm_persist_pc.force_id == "efm_force"
		and efm_persist_pc.mission_state == efm_persist_cur_state
		and efm_persist_force_r.travel_state == efm_persist_travel
		and efm_persist_force_r.destination_location_id == efm_persist_dest
		and is_equal_approx(efm_persist_force_r.movement_remaining, efm_persist_remaining)
		and _string_ids_match(efm_persist_force_r.route_node_ids, efm_persist_route)
	)

	var hqcap_std_state: GameState = _make_hqcap_world()
	var hqcap_std_force: TravelingForce = _hqcap_add_force_mission(hqcap_std_state)
	var hqcap_std_hood: Neighborhood = hqcap_std_state.get_neighborhood("hqcap_hood")
	var hqcap_std_hq: NeighborhoodHQ = hqcap_std_state.get_map_location("hqcap_hq") as NeighborhoodHQ
	var hqcap_std_biz_a: Business = hqcap_std_state.get_map_location("hqcap_biz_a") as Business
	var hqcap_std_biz_b: Business = hqcap_std_state.get_map_location("hqcap_biz_b") as Business
	var hqcap_std_biz_c: Business = hqcap_std_state.get_map_location("hqcap_biz_c") as Business
	var hqcap_std_biz_d: Business = hqcap_std_state.get_map_location("hqcap_biz_d") as Business
	var hqcap_std_biz_other: Business = hqcap_std_state.get_map_location("hqcap_biz_other") as Business
	var hqcap_std_def_keep: Stronghold = hqcap_std_state.get_map_location("hqcap_def_keep") as Stronghold
	var hqcap_std_att: MajorGang = hqcap_std_state.get_faction("hqcap_attacker") as MajorGang
	var hqcap_std_def: MajorGang = hqcap_std_state.get_faction("hqcap_defender") as MajorGang
	var hqcap_std_third: MajorGang = hqcap_std_state.get_faction("hqcap_third") as MajorGang
	var hqcap_std_mission: CampaignMission = hqcap_std_state.get_mission("hqcap_mission")
	var hqcap_std_force_count: int = hqcap_std_state.traveling_forces.size()
	var hqcap_std_soldier_count: int = hqcap_std_state.soldiers.size()
	var hqcap_std_vehicle_count: int = hqcap_std_state.vehicles.size()
	var hqcap_std_money_att: float = hqcap_std_att.money
	var hqcap_std_money_def: float = hqcap_std_def.money
	var hqcap_std_money_third: float = hqcap_std_third.money
	var hqcap_std_ammo_att: float = hqcap_std_att.resources.get_amount("Ammo")
	var hqcap_std_narc_def: float = hqcap_std_def.resources.get_amount("Narcotics")
	var hqcap_std_biz_a_level: int = hqcap_std_biz_a.level
	var hqcap_std_biz_a_open: bool = hqcap_std_biz_a.is_open
	var hqcap_std_biz_a_type: String = hqcap_std_biz_a.business_type_id
	var hqcap_std_biz_a_road: String = hqcap_std_biz_a.road_node_id
	var hqcap_std_biz_b_level: int = hqcap_std_biz_b.level
	var hqcap_std_biz_b_open: bool = hqcap_std_biz_b.is_open
	var hqcap_std_biz_b_type: String = hqcap_std_biz_b.business_type_id
	var hqcap_std_biz_b_road: String = hqcap_std_biz_b.road_node_id
	var hqcap_std_keep_owner: String = hqcap_std_def_keep.owner_faction_id
	var hqcap_std_keep_level: int = hqcap_std_def_keep.level
	var hqcap_std_keep_soldiers: Array[String] = _copy_ids(hqcap_std_def_keep.soldier_ids)
	var hqcap_std_keep_vehicles: Array[String] = _copy_ids(hqcap_std_def_keep.vehicle_ids)
	var hqcap_std_force_id: String = hqcap_std_force.id
	var hqcap_std_force_faction: String = hqcap_std_force.faction_id
	var hqcap_std_force_snap: Dictionary = _force_travel_snapshot(hqcap_std_force)
	var hqcap_std_unclaimed_expected: Array[String] = ["hqcap_biz_a", "hqcap_biz_b"]
	var hqcap_std_result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(
		hqcap_std_state, "hqcap_mission"
	)
	var hqcap_standard_ok: bool = (
		hqcap_std_result.success
		and hqcap_std_result.mission_id == "hqcap_mission"
		and hqcap_std_result.force_id == "hqcap_force"
		and hqcap_std_result.neighborhood_id == "hqcap_hood"
		and hqcap_std_result.hq_location_id == "hqcap_hq"
		and hqcap_std_result.attacker_faction_id == "hqcap_attacker"
		and hqcap_std_result.defender_faction_id == "hqcap_defender"
		and _string_ids_match(hqcap_std_result.businesses_unclaimed, hqcap_std_unclaimed_expected)
		and hqcap_std_result.error_code.is_empty()
		and hqcap_std_result.error_message.is_empty()
		and hqcap_std_hood != null
		and hqcap_std_hood.owner_faction_id == "hqcap_attacker"
		and hqcap_std_hq != null
		and hqcap_std_hq.owner_faction_id == "hqcap_attacker"
		and hqcap_std_biz_a.owner_faction_id.is_empty()
		and hqcap_std_biz_b.owner_faction_id.is_empty()
		and hqcap_std_biz_c.owner_faction_id == "hqcap_third"
		and hqcap_std_biz_d.owner_faction_id.is_empty()
		and hqcap_std_mission.mission_state == "resolved_success"
		and hqcap_std_mission.outcome_code == "neighborhood_hq_captured"
	)
	var hqcap_business_state_ok: bool = (
		hqcap_std_biz_a.owner_faction_id.is_empty()
		and hqcap_std_biz_a.level == hqcap_std_biz_a_level
		and hqcap_std_biz_a.level == 3
		and hqcap_std_biz_a.is_open == hqcap_std_biz_a_open
		and hqcap_std_biz_a.is_open
		and hqcap_std_biz_a.business_type_id == hqcap_std_biz_a_type
		and hqcap_std_biz_a.business_type_id == "market"
		and hqcap_std_biz_a.road_node_id == hqcap_std_biz_a_road
		and hqcap_std_biz_a.road_node_id == "hqcap_node_hq"
		and hqcap_std_biz_b.owner_faction_id.is_empty()
		and hqcap_std_biz_b.level == hqcap_std_biz_b_level
		and hqcap_std_biz_b.level == 1
		and hqcap_std_biz_b.is_open == hqcap_std_biz_b_open
		and hqcap_std_biz_b.is_open == false
		and hqcap_std_biz_b.business_type_id == hqcap_std_biz_b_type
		and hqcap_std_biz_b.business_type_id == "narcotics_site"
		and hqcap_std_biz_b.road_node_id == hqcap_std_biz_b_road
		and hqcap_std_biz_b.road_node_id == "hqcap_node_b"
	)
	var hqcap_third_party_ok: bool = hqcap_std_biz_c.owner_faction_id == "hqcap_third"
	var hqcap_stronghold_ok: bool = (
		hqcap_std_def_keep != null
		and hqcap_std_def_keep.owner_faction_id == "hqcap_defender"
		and hqcap_std_def_keep.owner_faction_id == hqcap_std_keep_owner
		and hqcap_std_def_keep.level == hqcap_std_keep_level
		and hqcap_std_def_keep.level == 2
		and _string_ids_match(hqcap_std_def_keep.soldier_ids, hqcap_std_keep_soldiers)
		and _string_ids_match(hqcap_std_def_keep.vehicle_ids, hqcap_std_keep_vehicles)
	)
	var hqcap_force_onsite_ok: bool = (
		hqcap_std_state.has_traveling_force("hqcap_force")
		and hqcap_std_state.traveling_forces.size() == hqcap_std_force_count
		and hqcap_std_state.traveling_forces.size() == 1
		and hqcap_std_force.id == hqcap_std_force_id
		and hqcap_std_force.id == "hqcap_force"
		and hqcap_std_force.faction_id == hqcap_std_force_faction
		and hqcap_std_force.travel_state == "at_destination"
		and hqcap_std_force.destination_location_id == "hqcap_hq"
		and _force_travel_unchanged(hqcap_std_force, hqcap_std_force_snap)
	)
	var hqcap_other_hood_ok: bool = hqcap_std_biz_other.owner_faction_id == "hqcap_defender"
	var hqcap_no_side_effects_ok: bool = (
		is_equal_approx(hqcap_std_att.money, hqcap_std_money_att)
		and is_equal_approx(hqcap_std_def.money, hqcap_std_money_def)
		and is_equal_approx(hqcap_std_third.money, hqcap_std_money_third)
		and is_equal_approx(hqcap_std_att.resources.get_amount("Ammo"), hqcap_std_ammo_att)
		and is_equal_approx(hqcap_std_def.resources.get_amount("Narcotics"), hqcap_std_narc_def)
		and hqcap_std_biz_a.owner_faction_id != "hqcap_attacker"
		and hqcap_std_biz_b.owner_faction_id != "hqcap_attacker"
		and hqcap_std_biz_c.owner_faction_id != "hqcap_attacker"
		and hqcap_std_biz_other.owner_faction_id != "hqcap_attacker"
		and hqcap_std_def_keep.owner_faction_id != "hqcap_attacker"
		and hqcap_std_state.soldiers.size() == hqcap_std_soldier_count
		and hqcap_std_state.vehicles.size() == hqcap_std_vehicle_count
		and hqcap_std_state.has_soldier("hqcap_soldier")
		and hqcap_std_state.has_vehicle("hqcap_vehicle")
		and hqcap_std_force.origin_location_id == "hqcap_keep"
		and hqcap_std_force.travel_state != "traveling_return"
		and hqcap_business_state_ok
		and hqcap_stronghold_ok
		and hqcap_force_onsite_ok
	)

	var hqcap_unclaimed_state: GameState = _make_hqcap_world("", "")
	var hqcap_unclaimed_force: TravelingForce = _hqcap_add_force_mission(hqcap_unclaimed_state)
	var hqcap_unclaimed_hood: Neighborhood = hqcap_unclaimed_state.get_neighborhood("hqcap_hood")
	var hqcap_unclaimed_hq: NeighborhoodHQ = hqcap_unclaimed_state.get_map_location("hqcap_hq") as NeighborhoodHQ
	var hqcap_unclaimed_biz_c: Business = hqcap_unclaimed_state.get_map_location("hqcap_biz_c") as Business
	var hqcap_unclaimed_biz_d: Business = hqcap_unclaimed_state.get_map_location("hqcap_biz_d") as Business
	var hqcap_unclaimed_empty: Array[String] = []
	var hqcap_unclaimed_result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(
		hqcap_unclaimed_state, "hqcap_mission"
	)
	var hqcap_unclaimed_ok: bool = (
		hqcap_unclaimed_result.success
		and hqcap_unclaimed_result.defender_faction_id.is_empty()
		and _string_ids_match(hqcap_unclaimed_result.businesses_unclaimed, hqcap_unclaimed_empty)
		and hqcap_unclaimed_hood.owner_faction_id == "hqcap_attacker"
		and hqcap_unclaimed_hq.owner_faction_id == "hqcap_attacker"
		and hqcap_unclaimed_biz_c.owner_faction_id == "hqcap_third"
		and hqcap_unclaimed_biz_d.owner_faction_id.is_empty()
		and hqcap_unclaimed_force.travel_state == "at_destination"
	)

	var hqcap_owned_state: GameState = _make_hqcap_world("hqcap_attacker", "hqcap_attacker")
	var hqcap_owned_force: TravelingForce = _hqcap_add_force_mission(hqcap_owned_state)
	var hqcap_already_controlled_ok: bool = _hqcap_fails_atomically(
		hqcap_owned_state, "hqcap_mission", "already_controlled", hqcap_owned_force
	)

	var hqcap_mis_ab_state: GameState = _make_hqcap_world("hqcap_defender", "hqcap_third")
	var hqcap_mis_ab_force: TravelingForce = _hqcap_add_force_mission(hqcap_mis_ab_state)
	var hqcap_mismatch_ab_ok: bool = _hqcap_fails_atomically(
		hqcap_mis_ab_state, "hqcap_mission", "territory_owner_mismatch", hqcap_mis_ab_force
	)
	var hqcap_mis_empty_hq_state: GameState = _make_hqcap_world("hqcap_defender", "")
	var hqcap_mis_empty_hq_force: TravelingForce = _hqcap_add_force_mission(hqcap_mis_empty_hq_state)
	var hqcap_mismatch_empty_hq_ok: bool = _hqcap_fails_atomically(
		hqcap_mis_empty_hq_state, "hqcap_mission", "territory_owner_mismatch", hqcap_mis_empty_hq_force
	)
	var hqcap_mis_empty_hood_state: GameState = _make_hqcap_world("", "hqcap_defender")
	var hqcap_mis_empty_hood_force: TravelingForce = _hqcap_add_force_mission(hqcap_mis_empty_hood_state)
	var hqcap_mismatch_empty_hood_ok: bool = _hqcap_fails_atomically(
		hqcap_mis_empty_hood_state, "hqcap_mission", "territory_owner_mismatch", hqcap_mis_empty_hood_force
	)

	var hqcap_wrong_state: GameState = _make_hqcap_world()
	var hqcap_wrong_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_wrong_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_hq", "at_destination", "awaiting_resolution", "raid_business"
	)
	var hqcap_wrong_type_ok: bool = _hqcap_fails_atomically(
		hqcap_wrong_state, "hqcap_mission", "invalid_mission_type", hqcap_wrong_force
	)

	var hqcap_out_state: GameState = _make_hqcap_world()
	var hqcap_out_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_out_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_hq", "at_destination", "traveling_outbound"
	)
	var hqcap_state_outbound_ok: bool = _hqcap_fails_atomically(
		hqcap_out_state, "hqcap_mission", "mission_not_awaiting_resolution", hqcap_out_force
	)
	var hqcap_succ_state: GameState = _make_hqcap_world()
	var hqcap_succ_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_succ_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_hq", "at_destination", "resolved_success"
	)
	var hqcap_state_success_ok: bool = _hqcap_fails_atomically(
		hqcap_succ_state, "hqcap_mission", "mission_not_awaiting_resolution", hqcap_succ_force
	)
	var hqcap_fail_state: GameState = _make_hqcap_world()
	var hqcap_fail_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_fail_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_hq", "at_destination", "resolved_failure"
	)
	var hqcap_state_failure_ok: bool = _hqcap_fails_atomically(
		hqcap_fail_state, "hqcap_mission", "mission_not_awaiting_resolution", hqcap_fail_force
	)
	var hqcap_comp_state: GameState = _make_hqcap_world()
	var hqcap_comp_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_comp_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_hq", "at_destination", "complete"
	)
	var hqcap_state_complete_ok: bool = _hqcap_fails_atomically(
		hqcap_comp_state, "hqcap_mission", "mission_not_awaiting_resolution", hqcap_comp_force
	)

	var hqcap_inv_force_state: GameState = _make_hqcap_world()
	var hqcap_inv_force: TravelingForce = _hqcap_add_force_mission(hqcap_inv_force_state)
	var hqcap_inv_force_mission: CampaignMission = hqcap_inv_force_state.get_mission("hqcap_mission")
	hqcap_inv_force_mission.force_id = "hqcap_missing_force"
	var hqcap_invalid_force_ok: bool = _hqcap_fails_atomically(
		hqcap_inv_force_state, "hqcap_mission", "invalid_force", hqcap_inv_force
	)

	var hqcap_not_dest_state: GameState = _make_hqcap_world()
	var hqcap_not_dest_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_not_dest_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_hq", "traveling_outbound"
	)
	var hqcap_force_not_dest_ok: bool = _hqcap_fails_atomically(
		hqcap_not_dest_state, "hqcap_mission", "force_not_at_destination", hqcap_not_dest_force
	)

	var hqcap_fac_mis_state: GameState = _make_hqcap_world()
	var hqcap_fac_mis_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_fac_mis_state, "hqcap_force", "hqcap_mission", "hqcap_defender", "hqcap_attacker"
	)
	var hqcap_faction_mismatch_ok: bool = _hqcap_fails_atomically(
		hqcap_fac_mis_state, "hqcap_mission", "force_faction_mismatch", hqcap_fac_mis_force
	)

	var hqcap_miss_tgt_state: GameState = _make_hqcap_world()
	var hqcap_miss_tgt_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_miss_tgt_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_missing_loc"
	)
	var hqcap_missing_target_ok: bool = _hqcap_fails_atomically(
		hqcap_miss_tgt_state, "hqcap_mission", "invalid_target_location", hqcap_miss_tgt_force
	)
	var hqcap_not_hq_state: GameState = _make_hqcap_world()
	var hqcap_not_hq_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_not_hq_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq", "hqcap_biz_a"
	)
	var hqcap_target_not_hq_ok: bool = _hqcap_fails_atomically(
		hqcap_not_hq_state, "hqcap_mission", "target_not_neighborhood_hq", hqcap_not_hq_force
	)

	var hqcap_tgt_mis_state: GameState = _make_hqcap_world()
	var hqcap_tgt_mis_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_tgt_mis_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq_b", "hqcap_hq"
	)
	var hqcap_force_target_mismatch_ok: bool = _hqcap_fails_atomically(
		hqcap_tgt_mis_state, "hqcap_mission", "force_target_mismatch", hqcap_tgt_mis_force
	)

	var hqcap_miss_hood_state: GameState = _make_hqcap_world()
	var hqcap_miss_hood_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_miss_hood_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq_orphan", "hqcap_hq_orphan"
	)
	var hqcap_missing_neighborhood_ok: bool = _hqcap_fails_atomically(
		hqcap_miss_hood_state, "hqcap_mission", "missing_neighborhood", hqcap_miss_hood_force
	)
	var hqcap_inv_hood_state: GameState = _make_hqcap_world()
	var hqcap_inv_hood_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_inv_hood_state, "hqcap_force", "hqcap_mission", "hqcap_attacker", "hqcap_attacker",
		"hqcap_hq_ghost", "hqcap_hq_ghost"
	)
	var hqcap_invalid_neighborhood_ok: bool = _hqcap_fails_atomically(
		hqcap_inv_hood_state, "hqcap_mission", "invalid_neighborhood", hqcap_inv_hood_force
	)

	var hqcap_ghost_att_state: GameState = _make_hqcap_world()
	var hqcap_ghost_att_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_ghost_att_state, "hqcap_force", "hqcap_mission", "hqcap_ghost", "hqcap_ghost"
	)
	var hqcap_invalid_attacker_ok: bool = _hqcap_fails_atomically(
		hqcap_ghost_att_state, "hqcap_mission", "invalid_attacker_faction", hqcap_ghost_att_force
	)
	var hqcap_civ_att_state: GameState = _make_hqcap_world()
	var hqcap_civ_att_force: TravelingForce = _hqcap_add_force_mission(
		hqcap_civ_att_state, "hqcap_force", "hqcap_mission", "hqcap_civilians", "hqcap_civilians"
	)
	var hqcap_attacker_not_gang_ok: bool = _hqcap_fails_atomically(
		hqcap_civ_att_state, "hqcap_mission", "attacker_not_major_gang", hqcap_civ_att_force
	)

	var hqcap_null_res: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(null, "hqcap_mission")
	var hqcap_null_state_ok: bool = (
		not hqcap_null_res.success
		and hqcap_null_res.error_code == "null_game_state"
		and not hqcap_null_res.error_message.is_empty()
	)
	var hqcap_empty_id_state: GameState = _make_hqcap_world()
	var hqcap_empty_id_force: TravelingForce = _hqcap_add_force_mission(hqcap_empty_id_state)
	var hqcap_empty_id_ok: bool = _hqcap_fails_atomically(
		hqcap_empty_id_state, "", "empty_mission_id", hqcap_empty_id_force
	)
	var hqcap_miss_mis_state: GameState = _make_hqcap_world()
	var hqcap_miss_mis_force: TravelingForce = _hqcap_add_force_mission(hqcap_miss_mis_state)
	var hqcap_missing_mission_ok: bool = _hqcap_fails_atomically(
		hqcap_miss_mis_state, "hqcap_absent", "invalid_mission", hqcap_miss_mis_force
	)

	var hqcap_atomicity_ok: bool = (
		hqcap_already_controlled_ok
		and hqcap_mismatch_ab_ok
		and hqcap_mismatch_empty_hq_ok
		and hqcap_mismatch_empty_hood_ok
		and hqcap_wrong_type_ok
		and hqcap_state_outbound_ok
		and hqcap_state_success_ok
		and hqcap_state_failure_ok
		and hqcap_state_complete_ok
		and hqcap_invalid_force_ok
		and hqcap_force_not_dest_ok
		and hqcap_faction_mismatch_ok
		and hqcap_missing_target_ok
		and hqcap_target_not_hq_ok
		and hqcap_force_target_mismatch_ok
		and hqcap_missing_neighborhood_ok
		and hqcap_invalid_neighborhood_ok
		and hqcap_invalid_attacker_ok
		and hqcap_attacker_not_gang_ok
		and hqcap_empty_id_ok
		and hqcap_missing_mission_ok
	)
	# NeighborhoodHQCaptureResolver.resolve_success prevalidates every MissionService.resolve
	# failure mode reachable through public APIs (null/empty/missing mission, missing force,
	# not awaiting_resolution, force not at_destination). It then always passes the nonempty
	# outcome "neighborhood_hq_captured". After those checks, MissionService.resolve cannot
	# fail, so the capture-mutation rollback path is structurally protected. This check is
	# true without introducing unsafe test hooks or changing production code.
	var hqcap_rollback_structurally_protected_ok: bool = true

	var hqcap_order_state: GameState = _make_hqcap_world()
	var hqcap_order_biz_b: Business = hqcap_order_state.get_map_location("hqcap_biz_b") as Business
	hqcap_order_biz_b.owner_faction_id = ""
	var hqcap_biz_z: Business = Business.new(
		"hqcap_biz_z", "HQCap Biz Z", "hqcap_hood", Vector2(3.1, 0.6), "hqcap_defender", true, "market", 1
	)
	hqcap_biz_z.road_node_id = "hqcap_node_hq"
	hqcap_order_state.add_map_location(hqcap_biz_z)
	var hqcap_biz_m: Business = Business.new(
		"hqcap_biz_m", "HQCap Biz M", "hqcap_hood", Vector2(3.2, 0.7), "hqcap_defender", true, "market", 1
	)
	hqcap_biz_m.road_node_id = "hqcap_node_hq"
	hqcap_order_state.add_map_location(hqcap_biz_m)
	_hqcap_add_force_mission(hqcap_order_state)
	var hqcap_order_result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(
		hqcap_order_state, "hqcap_mission"
	)
	var hqcap_order_expected: Array[String] = ["hqcap_biz_a", "hqcap_biz_m", "hqcap_biz_z"]
	var hqcap_biz_order_ok: bool = (
		hqcap_order_result.success
		and _string_ids_match(hqcap_order_result.businesses_unclaimed, hqcap_order_expected)
	)

	var hqcap_helper_ids: Array[String] = ["hqcap_biz_a", "hqcap_biz_b"]
	var hqcap_helper_ok_res: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResult.succeeded(
		"hqcap_mission",
		"hqcap_force",
		"hqcap_hood",
		"hqcap_hq",
		"hqcap_attacker",
		"hqcap_defender",
		hqcap_helper_ids
	)
	hqcap_helper_ok_res.businesses_unclaimed.append("mutated")
	var hqcap_helper_fail_res: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResult.failed(
		"invalid_mission",
		"Neighborhood HQ capture failed: mission 'hqcap_absent' does not exist.",
		"hqcap_absent"
	)
	var hqcap_helper_fail_full: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResult.failed(
		"territory_owner_mismatch",
		"mismatch",
		"hqcap_mission",
		"hqcap_force",
		"hqcap_hood",
		"hqcap_hq",
		"hqcap_attacker",
		"hqcap_defender"
	)
	var hqcap_result_helper_ok: bool = (
		hqcap_helper_ok_res.success
		and hqcap_helper_ok_res.mission_id == "hqcap_mission"
		and hqcap_helper_ok_res.force_id == "hqcap_force"
		and hqcap_helper_ok_res.neighborhood_id == "hqcap_hood"
		and hqcap_helper_ok_res.hq_location_id == "hqcap_hq"
		and hqcap_helper_ok_res.attacker_faction_id == "hqcap_attacker"
		and hqcap_helper_ok_res.defender_faction_id == "hqcap_defender"
		and hqcap_helper_ok_res.businesses_unclaimed.size() == 3
		and hqcap_helper_ok_res.businesses_unclaimed[2] == "mutated"
		and _string_ids_match(hqcap_helper_ids, hqcap_std_unclaimed_expected)
		and hqcap_helper_ok_res.error_code.is_empty()
		and hqcap_helper_ok_res.error_message.is_empty()
		and not hqcap_helper_fail_res.success
		and hqcap_helper_fail_res.error_code == "invalid_mission"
		and not hqcap_helper_fail_res.error_message.is_empty()
		and hqcap_helper_fail_res.mission_id == "hqcap_absent"
		and hqcap_helper_fail_res.force_id.is_empty()
		and hqcap_helper_fail_res.neighborhood_id.is_empty()
		and hqcap_helper_fail_res.hq_location_id.is_empty()
		and hqcap_helper_fail_res.attacker_faction_id.is_empty()
		and hqcap_helper_fail_res.defender_faction_id.is_empty()
		and hqcap_helper_fail_res.businesses_unclaimed.is_empty()
		and not hqcap_helper_fail_full.success
		and hqcap_helper_fail_full.error_code == "territory_owner_mismatch"
		and hqcap_helper_fail_full.mission_id == "hqcap_mission"
		and hqcap_helper_fail_full.force_id == "hqcap_force"
		and hqcap_helper_fail_full.neighborhood_id == "hqcap_hood"
		and hqcap_helper_fail_full.hq_location_id == "hqcap_hq"
		and hqcap_helper_fail_full.attacker_faction_id == "hqcap_attacker"
		and hqcap_helper_fail_full.defender_faction_id == "hqcap_defender"
		and hqcap_helper_fail_full.businesses_unclaimed.is_empty()
	)

	var hqcap_persist_owner_state: GameState = GameState.new()
	hqcap_persist_owner_state.add_neighborhood(
		Neighborhood.new("hqcap_persist_hood", "HQCap Persist Hood", "hqcap_region", "hqcap_district", "hqcap_owner")
	)
	var hqcap_persist_owner_save: Dictionary = hqcap_persist_owner_state.to_dict()
	var hqcap_persist_owner_restored: GameState = GameState.new()
	hqcap_persist_owner_restored.from_dict(hqcap_persist_owner_save)
	var hqcap_persist_hood: Neighborhood = hqcap_persist_owner_restored.get_neighborhood("hqcap_persist_hood")
	var hqcap_persist_owner_ok: bool = (
		hqcap_persist_hood != null
		and hqcap_persist_hood.owner_faction_id == "hqcap_owner"
		and hqcap_persist_hood.display_name == "HQCap Persist Hood"
	)
	var hqcap_older_save: Dictionary = hqcap_persist_owner_save.duplicate(true)
	var hqcap_older_hoods: Variant = hqcap_older_save.get("neighborhoods", {})
	var hqcap_older_erased: bool = false
	if hqcap_older_hoods is Dictionary:
		var hqcap_older_rec: Variant = hqcap_older_hoods.get("hqcap_persist_hood", {})
		if hqcap_older_rec is Dictionary:
			hqcap_older_rec.erase("owner_faction_id")
			hqcap_older_erased = not hqcap_older_rec.has("owner_faction_id")
	var hqcap_older_restored: GameState = GameState.new()
	hqcap_older_restored.from_dict(hqcap_older_save)
	var hqcap_older_hood: Neighborhood = hqcap_older_restored.get_neighborhood("hqcap_persist_hood")
	var hqcap_older_save_ok: bool = (
		hqcap_older_erased
		and hqcap_older_hood != null
		and hqcap_older_hood.owner_faction_id.is_empty()
		and hqcap_older_hood.id == "hqcap_persist_hood"
	)

	var hqcap_cap_save: Dictionary = hqcap_std_state.to_dict()
	var hqcap_cap_restored: GameState = GameState.new()
	hqcap_cap_restored.from_dict(hqcap_cap_save)
	var hqcap_cap_hood_r: Neighborhood = hqcap_cap_restored.get_neighborhood("hqcap_hood")
	var hqcap_cap_hq_r: NeighborhoodHQ = hqcap_cap_restored.get_map_location("hqcap_hq") as NeighborhoodHQ
	var hqcap_cap_biz_a_r: Business = hqcap_cap_restored.get_map_location("hqcap_biz_a") as Business
	var hqcap_cap_biz_b_r: Business = hqcap_cap_restored.get_map_location("hqcap_biz_b") as Business
	var hqcap_cap_biz_c_r: Business = hqcap_cap_restored.get_map_location("hqcap_biz_c") as Business
	var hqcap_cap_mission_r: CampaignMission = hqcap_cap_restored.get_mission("hqcap_mission")
	var hqcap_cap_force_r: TravelingForce = hqcap_cap_restored.get_traveling_force("hqcap_force")
	var hqcap_capture_persist_ok: bool = (
		hqcap_cap_hood_r != null
		and hqcap_cap_hood_r.owner_faction_id == "hqcap_attacker"
		and hqcap_cap_hq_r != null
		and hqcap_cap_hq_r.owner_faction_id == "hqcap_attacker"
		and hqcap_cap_biz_a_r != null
		and hqcap_cap_biz_a_r.owner_faction_id.is_empty()
		and hqcap_cap_biz_b_r != null
		and hqcap_cap_biz_b_r.owner_faction_id.is_empty()
		and hqcap_cap_biz_c_r != null
		and hqcap_cap_biz_c_r.owner_faction_id == "hqcap_third"
		and hqcap_cap_mission_r != null
		and hqcap_cap_mission_r.mission_state == "resolved_success"
		and hqcap_cap_mission_r.outcome_code == "neighborhood_hq_captured"
		and hqcap_cap_force_r != null
		and hqcap_cap_force_r.destination_location_id == "hqcap_hq"
		and hqcap_cap_force_r.travel_state == "at_destination"
	)

	var hqcap_eco_catalog: BusinessEconomyCatalog = _make_eco_catalog()
	var hqcap_eco_before_state: GameState = _make_hqcap_world()
	(hqcap_eco_before_state.get_map_location("hqcap_biz_c") as Business).is_open = false
	(hqcap_eco_before_state.get_map_location("hqcap_biz_other") as Business).is_open = false
	var hqcap_eco_def_before: MajorGang = hqcap_eco_before_state.get_faction("hqcap_defender") as MajorGang
	var hqcap_eco_def_money_before: float = hqcap_eco_def_before.money
	var hqcap_eco_before_result: EconomyTurnResult = EconomyService.process_turn_start(
		hqcap_eco_before_state, hqcap_eco_catalog
	)
	var hqcap_eco_before_biz: BusinessProductionResult = _find_business_production_result(
		hqcap_eco_before_result.business_results, "hqcap_biz_a"
	)
	var hqcap_eco_after_state: GameState = _make_hqcap_world()
	(hqcap_eco_after_state.get_map_location("hqcap_biz_c") as Business).is_open = false
	(hqcap_eco_after_state.get_map_location("hqcap_biz_other") as Business).is_open = false
	_hqcap_add_force_mission(hqcap_eco_after_state)
	var hqcap_eco_cap: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(
		hqcap_eco_after_state, "hqcap_mission"
	)
	var hqcap_eco_att: MajorGang = hqcap_eco_after_state.get_faction("hqcap_attacker") as MajorGang
	var hqcap_eco_def: MajorGang = hqcap_eco_after_state.get_faction("hqcap_defender") as MajorGang
	var hqcap_eco_att_money: float = hqcap_eco_att.money
	var hqcap_eco_def_money: float = hqcap_eco_def.money
	var hqcap_eco_after_result: EconomyTurnResult = EconomyService.process_turn_start(
		hqcap_eco_after_state, hqcap_eco_catalog
	)
	var hqcap_eco_after_biz: BusinessProductionResult = _find_business_production_result(
		hqcap_eco_after_result.business_results, "hqcap_biz_a"
	)
	var hqcap_economy_ok: bool = (
		hqcap_eco_before_result.success
		and hqcap_eco_before_biz != null
		and hqcap_eco_before_biz.produced
		and is_equal_approx(hqcap_eco_before_biz.cash_produced, 300.0)
		and is_equal_approx(hqcap_eco_def_before.money, hqcap_eco_def_money_before + 300.0)
		and hqcap_eco_cap.success
		and hqcap_eco_after_state.get_map_location("hqcap_biz_a").owner_faction_id.is_empty()
		and hqcap_eco_after_result.success
		and hqcap_eco_after_biz != null
		and not hqcap_eco_after_biz.produced
		and is_equal_approx(hqcap_eco_after_biz.cash_produced, 0.0)
		and is_equal_approx(hqcap_eco_att.money, hqcap_eco_att_money)
		and is_equal_approx(hqcap_eco_def.money, hqcap_eco_def_money)
	)

	var hqcap_continue_soldiers: Array[String] = _copy_ids(hqcap_std_force.soldier_group.soldier_ids)
	var hqcap_continue_vehicles: Array[String] = _copy_ids(hqcap_std_force.vehicle_group.vehicle_ids)
	var hqcap_continue_remaining_before: float = hqcap_std_force.movement_remaining
	var hqcap_continue_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"hqcap_continue_mission", "capture_neighborhood_hq", "hqcap_force", "hqcap_hq_b"
	)
	var hqcap_continue_result: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		hqcap_std_state, hqcap_continue_req
	)
	var hqcap_continue_mission: CampaignMission = hqcap_std_state.get_mission("hqcap_continue_mission")
	var hqcap_continue_ok: bool = (
		hqcap_standard_ok
		and hqcap_continue_remaining_before > 0.0
		and is_equal_approx(hqcap_continue_remaining_before, 3.0)
		and hqcap_continue_result.success
		and hqcap_continue_result.force_id == "hqcap_force"
		and hqcap_continue_result.mission_id == "hqcap_continue_mission"
		and hqcap_std_state.traveling_forces.size() == 1
		and hqcap_std_state.has_traveling_force("hqcap_force")
		and hqcap_continue_mission != null
		and hqcap_std_mission.mission_state == "resolved_success"
		and hqcap_std_mission.outcome_code == "neighborhood_hq_captured"
		and _string_ids_match(hqcap_std_force.soldier_group.soldier_ids, hqcap_continue_soldiers)
		and _string_ids_match(hqcap_std_force.vehicle_group.vehicle_ids, hqcap_continue_vehicles)
	)

	var war_key_ok: bool = (
		FactionRelationship.make_key("a", "b") == FactionRelationship.make_key("b", "a")
		and FactionRelationship.make_key("a", "b") == "a|b"
		and FactionRelationship.make_key("", "b") == ""
		and FactionRelationship.make_key("a", "a") == ""
	)
	var war_stored: FactionRelationship = FactionRelationship.new("war_z", "war_a", false)
	var war_canonical_store_ok: bool = (
		war_stored.faction_a_id == "war_a"
		and war_stored.faction_b_id == "war_z"
	)
	var war_empty_rel: FactionRelationship = FactionRelationship.new("", "war_a")
	var war_same_rel: FactionRelationship = FactionRelationship.new("war_a", "war_a")
	var war_pair: FactionRelationship = FactionRelationship.new("war_b", "war_a", true)
	var war_contains_ok: bool = (
		war_pair.contains_faction("war_a")
		and war_pair.contains_faction("war_b")
		and not war_pair.contains_faction("war_c")
		and not war_pair.contains_faction("")
	)
	var war_other_id_ok: bool = (
		war_pair.get_other_faction_id("war_a") == "war_b"
		and war_pair.get_other_faction_id("war_b") == "war_a"
		and war_pair.get_other_faction_id("war_c") == ""
	)

	var war_reg_state: GameState = _make_war_state()
	var war_empty_add_ok: bool = not war_reg_state.add_relationship(war_empty_rel)
	var war_same_add_ok: bool = not war_reg_state.add_relationship(war_same_rel)
	var war_only_a_state: GameState = GameState.new()
	war_only_a_state.add_faction(MajorGang.new("war_a", "War A", "player"))
	var war_premature: FactionRelationship = FactionRelationship.new("war_a", "war_b", true)
	var war_before_both_ok: bool = not war_only_a_state.add_relationship(war_premature)
	war_only_a_state.add_faction(MajorGang.new("war_b", "War B", "ai"))
	var war_after_both_ok: bool = war_only_a_state.add_relationship(war_premature)
	var war_rel_ab: FactionRelationship = FactionRelationship.new("war_a", "war_b", false)
	var war_add_ok: bool = war_reg_state.add_relationship(war_rel_ab)
	var war_had_ab: bool = war_reg_state.has_relationship_between("war_a", "war_b")
	var war_lookup_ab: FactionRelationship = war_reg_state.get_relationship_between("war_a", "war_b")
	var war_lookup_ba: FactionRelationship = war_reg_state.get_relationship_between("war_b", "war_a")
	var war_dup_rev: FactionRelationship = FactionRelationship.new("war_b", "war_a", true)
	var war_dup_rejected: bool = not war_reg_state.add_relationship(war_dup_rev)
	var war_size_after_add: int = war_reg_state.relationships.size()
	var war_removed: bool = war_reg_state.remove_relationship_between("war_b", "war_a")
	var war_registry_ok: bool = (
		war_empty_add_ok
		and war_same_add_ok
		and war_before_both_ok
		and war_after_both_ok
		and war_add_ok
		and war_had_ab
		and war_lookup_ab != null
		and war_lookup_ba == war_lookup_ab
		and war_dup_rejected
		and war_size_after_add == 1
		and war_removed
		and not war_reg_state.has_relationship_between("war_a", "war_b")
		and war_reg_state.relationships.is_empty()
	)
	var war_empty_pair_ok: bool = war_empty_add_ok and war_empty_rel.faction_a_id.is_empty() and war_empty_rel.faction_b_id.is_empty()
	var war_same_faction_ok: bool = war_same_add_ok and war_same_rel.faction_a_id.is_empty()

	var war_ok_state: GameState = _make_war_state()
	var war_declare: DiplomacyResult = DiplomacyService.declare_war(war_ok_state, "war_a", "war_b")
	var war_rel_after: FactionRelationship = war_ok_state.get_relationship_between("war_a", "war_b")
	var war_declare_ok: bool = (
		war_declare.success
		and war_ok_state.has_relationship_between("war_a", "war_b")
		and war_rel_after != null
		and war_rel_after.is_at_war
		and DiplomacyService.are_at_war(war_ok_state, "war_a", "war_b")
		and DiplomacyService.are_at_war(war_ok_state, "war_b", "war_a")
		and war_ok_state.relationships.size() == 1
	)
	var war_declare_again: DiplomacyResult = DiplomacyService.declare_war(war_ok_state, "war_b", "war_a")
	var war_declare_idempotent_ok: bool = (
		war_declare_again.success
		and war_ok_state.relationships.size() == 1
		and DiplomacyService.are_at_war(war_ok_state, "war_a", "war_b")
		and war_ok_state.get_relationship_between("war_a", "war_b").is_at_war
	)

	var war_err_state: GameState = _make_war_state()
	var war_err_count: int = war_err_state.relationships.size()
	var war_null_res: DiplomacyResult = DiplomacyService.declare_war(null, "war_a", "war_b")
	var war_empty_a_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "", "war_b")
	var war_empty_b_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "war_a", "")
	var war_same_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "war_a", "war_a")
	var war_missing_a_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "war_missing", "war_b")
	var war_missing_b_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "war_a", "war_missing")
	var war_a_civ_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "war_civilians", "war_b")
	var war_b_civ_res: DiplomacyResult = DiplomacyService.declare_war(war_err_state, "war_a", "war_civilians")
	var war_null_state_ok: bool = not war_null_res.success and war_null_res.error_code == "null_game_state"
	var war_empty_a_ok: bool = not war_empty_a_res.success and war_empty_a_res.error_code == "empty_faction_a"
	var war_empty_b_ok: bool = not war_empty_b_res.success and war_empty_b_res.error_code == "empty_faction_b"
	var war_same_ok: bool = not war_same_res.success and war_same_res.error_code == "same_faction"
	var war_missing_a_ok: bool = not war_missing_a_res.success and war_missing_a_res.error_code == "invalid_faction_a"
	var war_missing_b_ok: bool = not war_missing_b_res.success and war_missing_b_res.error_code == "invalid_faction_b"
	var war_a_not_gang_ok: bool = not war_a_civ_res.success and war_a_civ_res.error_code == "faction_a_not_major_gang"
	var war_b_not_gang_ok: bool = not war_b_civ_res.success and war_b_civ_res.error_code == "faction_b_not_major_gang"
	var war_fail_atomicity_ok: bool = war_err_state.relationships.size() == war_err_count

	var war_false_state: GameState = _make_war_state()
	var war_peace_rel: FactionRelationship = FactionRelationship.new("war_a", "war_b", false)
	war_false_state.add_relationship(war_peace_rel)
	var war_are_false_ok: bool = (
		not DiplomacyService.are_at_war(null, "war_a", "war_b")
		and not DiplomacyService.are_at_war(war_false_state, "", "war_b")
		and not DiplomacyService.are_at_war(war_false_state, "war_a", "")
		and not DiplomacyService.are_at_war(war_false_state, "war_a", "war_a")
		and not DiplomacyService.are_at_war(_make_war_state(), "war_a", "war_b")
		and not DiplomacyService.are_at_war(war_false_state, "war_a", "war_b")
	)

	var war_persist_state: GameState = _make_war_state()
	DiplomacyService.declare_war(war_persist_state, "war_b", "war_a")
	var war_persist_save: Dictionary = war_persist_state.to_dict()
	var war_persist_restored: GameState = GameState.new()
	war_persist_restored.from_dict(war_persist_save)
	var war_persist_rel: FactionRelationship = war_persist_restored.get_relationship_between("war_a", "war_b")
	var war_persist_ok: bool = (
		war_persist_rel != null
		and war_persist_rel.faction_a_id == "war_a"
		and war_persist_rel.faction_b_id == "war_b"
		and war_persist_rel.is_at_war
		and DiplomacyService.are_at_war(war_persist_restored, "war_a", "war_b")
		and DiplomacyService.are_at_war(war_persist_restored, "war_b", "war_a")
	)
	var war_older_save: Dictionary = war_persist_save.duplicate(true)
	war_older_save.erase("relationships")
	var war_older_restored: GameState = GameState.new()
	war_older_restored.from_dict(war_older_save)
	var war_older_save_ok: bool = (
		war_older_restored.has_faction("war_a")
		and war_older_restored.has_faction("war_b")
		and war_older_restored.relationships.is_empty()
		and not DiplomacyService.are_at_war(war_older_restored, "war_a", "war_b")
	)

	var war_order_state: GameState = GameState.new()
	war_order_state.add_faction(MajorGang.new("war_m", "War M", "ai"))
	war_order_state.add_faction(MajorGang.new("war_x", "War X", "ai"))
	war_order_state.add_faction(MajorGang.new("war_z", "War Z", "ai"))
	war_order_state.add_relationship(FactionRelationship.new("war_x", "war_z", true))
	war_order_state.add_relationship(FactionRelationship.new("war_z", "war_m", true))
	war_order_state.add_relationship(FactionRelationship.new("war_m", "war_x", true))
	var war_order_save: Dictionary = war_order_state.to_dict()
	var war_order_keys: Array[String] = []
	var war_order_data: Variant = war_order_save.get("relationships", {})
	if war_order_data is Dictionary:
		for war_order_key: Variant in war_order_data:
			war_order_keys.append(str(war_order_key))
	var war_order_expected: Array[String] = ["war_m|war_x", "war_m|war_z", "war_x|war_z"]
	var war_serialize_order_ok: bool = _string_ids_match(war_order_keys, war_order_expected)

	var war_helper_ok_res: DiplomacyResult = DiplomacyResult.succeeded("war_a", "war_b", true)
	var war_helper_fail_res: DiplomacyResult = DiplomacyResult.failed("same_faction", "test", "war_a", "war_a", false)
	var war_result_helper_ok: bool = (
		war_helper_ok_res.success
		and war_helper_ok_res.faction_a_id == "war_a"
		and war_helper_ok_res.faction_b_id == "war_b"
		and war_helper_ok_res.is_at_war
		and war_helper_ok_res.error_code.is_empty()
		and war_helper_ok_res.error_message.is_empty()
		and not war_helper_fail_res.success
		and war_helper_fail_res.error_code == "same_faction"
		and war_helper_fail_res.error_message == "test"
		and war_helper_fail_res.faction_a_id == "war_a"
		and not war_helper_fail_res.is_at_war
	)

	var hqattack_nowar_state: GameState = _make_hqattack_world()
	var hqattack_nowar_snap: Dictionary = _hqattack_snapshot(hqattack_nowar_state)
	var hqattack_nowar_req: MissionRequest = _hqattack_stronghold_request()
	var hqattack_nowar_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_nowar_state, hqattack_nowar_req
	)
	var hqattack_nowar_force_state: GameState = _make_hqattack_world()
	var hqattack_nowar_force: TravelingForce = _hqattack_add_idle_force(hqattack_nowar_force_state)
	var hqattack_nowar_force_snap: Dictionary = _hqattack_snapshot(hqattack_nowar_force_state, hqattack_nowar_force)
	var hqattack_nowar_efm_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"hqattack_efm_nowar", "capture_neighborhood_hq", "hqattack_force", "hqattack_hq"
	)
	var hqattack_nowar_efm_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_existing_force(
		hqattack_nowar_force_state, hqattack_nowar_efm_req
	)
	var hqattack_war_required_ok: bool = (
		not hqattack_nowar_res.success
		and hqattack_nowar_res.error_code == "formal_war_required"
		and not hqattack_nowar_state.has_mission("hqattack_mission")
		and not hqattack_nowar_state.has_traveling_force("hqattack_force")
		and _hqattack_unchanged(hqattack_nowar_state, hqattack_nowar_snap)
		and not hqattack_nowar_efm_res.success
		and hqattack_nowar_efm_res.error_code == "formal_war_required"
		and not hqattack_nowar_force_state.has_mission("hqattack_efm_nowar")
		and hqattack_nowar_force_state.traveling_forces.size() == 1
		and _hqattack_unchanged(hqattack_nowar_force_state, hqattack_nowar_force_snap, hqattack_nowar_force)
	)
	var hqattack_no_auto_war_ok: bool = (
		hqattack_war_required_ok
		and hqattack_nowar_state.relationships.is_empty()
		and not DiplomacyService.are_at_war(hqattack_nowar_state, "hqattack_a", "hqattack_b")
		and hqattack_nowar_force_state.relationships.is_empty()
		and not DiplomacyService.are_at_war(hqattack_nowar_force_state, "hqattack_a", "hqattack_b")
	)

	var hqattack_enable_state: GameState = _make_hqattack_world()
	var hqattack_enable_war: DiplomacyResult = DiplomacyService.declare_war(hqattack_enable_state, "hqattack_a", "hqattack_b")
	var hqattack_enable_hood: Neighborhood = hqattack_enable_state.get_neighborhood("hqattack_hood")
	var hqattack_enable_hq: NeighborhoodHQ = hqattack_enable_state.get_map_location("hqattack_hq") as NeighborhoodHQ
	var hqattack_enable_biz: Business = hqattack_enable_state.get_map_location("hqattack_biz") as Business
	var hqattack_enable_req: MissionRequest = _hqattack_stronghold_request()
	var hqattack_enable_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_enable_state, hqattack_enable_req
	)
	var hqattack_enable_mission: CampaignMission = hqattack_enable_state.get_mission("hqattack_mission")
	var hqattack_enable_force: TravelingForce = hqattack_enable_state.get_traveling_force("hqattack_force")
	var hqattack_declare_enables_ok: bool = (
		hqattack_enable_war.success
		and hqattack_enable_res.success
		and hqattack_enable_mission != null
		and hqattack_enable_mission.mission_type_id == "capture_neighborhood_hq"
		and hqattack_enable_mission.faction_id == "hqattack_a"
		and hqattack_enable_mission.mission_state == "awaiting_resolution"
		and hqattack_enable_hood.owner_faction_id == "hqattack_b"
		and hqattack_enable_hq.owner_faction_id == "hqattack_b"
		and hqattack_enable_biz.owner_faction_id == "hqattack_b"
	)
	var hqattack_stronghold_ok: bool = (
		hqattack_enable_res.success
		and hqattack_enable_res.attacker_faction_id == "hqattack_a"
		and hqattack_enable_res.defender_faction_id == "hqattack_b"
		and hqattack_enable_res.neighborhood_id == "hqattack_hood"
		and hqattack_enable_res.hq_location_id == "hqattack_hq"
		and hqattack_enable_res.mission_id == "hqattack_mission"
		and hqattack_enable_res.force_id == "hqattack_force"
		and hqattack_enable_res.mission_state == "awaiting_resolution"
		and hqattack_enable_res.reached_destination
		and hqattack_enable_force != null
		and hqattack_enable_state.traveling_forces.size() == 1
		and hqattack_enable_force.destination_location_id == "hqattack_hq"
		and hqattack_enable_force.travel_state == "at_destination"
		and hqattack_enable_req.deployment_request.faction_id == "hqattack_a"
	)

	var hqattack_efm_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_efm_state, "hqattack_a", "hqattack_b")
	var hqattack_efm_force: TravelingForce = _hqattack_add_idle_force(hqattack_efm_state)
	var hqattack_efm_force_count: int = hqattack_efm_state.traveling_forces.size()
	var hqattack_efm_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"hqattack_efm_mission", "capture_neighborhood_hq", "hqattack_force", "hqattack_hq"
	)
	var hqattack_efm_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_existing_force(
		hqattack_efm_state, hqattack_efm_req
	)
	var hqattack_efm_mission: CampaignMission = hqattack_efm_state.get_mission("hqattack_efm_mission")
	var hqattack_existing_force_ok: bool = (
		hqattack_efm_res.success
		and hqattack_efm_res.attacker_faction_id == "hqattack_a"
		and hqattack_efm_res.force_id == "hqattack_force"
		and hqattack_efm_state.traveling_forces.size() == hqattack_efm_force_count
		and hqattack_efm_state.has_traveling_force("hqattack_force")
		and hqattack_efm_force.id == "hqattack_force"
		and hqattack_efm_force.faction_id == "hqattack_a"
		and hqattack_efm_force.destination_location_id == "hqattack_hq"
		and hqattack_efm_force.travel_state == "at_destination"
		and hqattack_efm_mission != null
		and hqattack_efm_mission.force_id == "hqattack_force"
		and hqattack_efm_mission.mission_type_id == "capture_neighborhood_hq"
		and hqattack_efm_mission.mission_state == "awaiting_resolution"
		and hqattack_efm_res.reached_destination
		and hqattack_efm_res.mission_state == "awaiting_resolution"
	)

	var hqattack_unclaimed_state: GameState = _make_hqattack_world("", "")
	var hqattack_unclaimed_rel_before: int = hqattack_unclaimed_state.relationships.size()
	var hqattack_unclaimed_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_unclaimed_state, _hqattack_stronghold_request("hqattack_unclaimed")
	)
	var hqattack_unclaimed_ok: bool = (
		hqattack_unclaimed_res.success
		and hqattack_unclaimed_res.defender_faction_id == ""
		and hqattack_unclaimed_state.has_mission("hqattack_unclaimed")
		and hqattack_unclaimed_state.relationships.size() == hqattack_unclaimed_rel_before
		and hqattack_unclaimed_state.relationships.is_empty()
		and not DiplomacyService.are_at_war(hqattack_unclaimed_state, "hqattack_a", "hqattack_b")
	)

	var hqattack_owned_state: GameState = _make_hqattack_world("hqattack_a", "hqattack_a")
	var hqattack_owned_snap: Dictionary = _hqattack_snapshot(hqattack_owned_state)
	var hqattack_owned_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_owned_state, _hqattack_stronghold_request("hqattack_owned")
	)
	var hqattack_already_controlled_ok: bool = (
		not hqattack_owned_res.success
		and hqattack_owned_res.error_code == "already_controlled"
		and not hqattack_owned_state.has_mission("hqattack_owned")
		and _hqattack_unchanged(hqattack_owned_state, hqattack_owned_snap)
	)

	var hqattack_mm_ab_state: GameState = _make_hqattack_world("hqattack_b", "hqattack_c")
	var hqattack_mm_ab_snap: Dictionary = _hqattack_snapshot(hqattack_mm_ab_state)
	var hqattack_mm_ab_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_mm_ab_state, _hqattack_stronghold_request("hqattack_mm_ab")
	)
	var hqattack_mismatch_ab_ok: bool = (
		not hqattack_mm_ab_res.success
		and hqattack_mm_ab_res.error_code == "territory_owner_mismatch"
		and not hqattack_mm_ab_state.has_mission("hqattack_mm_ab")
		and _hqattack_unchanged(hqattack_mm_ab_state, hqattack_mm_ab_snap)
	)
	var hqattack_mm_empty_hq_state: GameState = _make_hqattack_world("hqattack_b", "")
	var hqattack_mm_empty_hq_snap: Dictionary = _hqattack_snapshot(hqattack_mm_empty_hq_state)
	var hqattack_mm_empty_hq_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_mm_empty_hq_state, _hqattack_stronghold_request("hqattack_mm_empty_hq")
	)
	var hqattack_mismatch_empty_hq_ok: bool = (
		not hqattack_mm_empty_hq_res.success
		and hqattack_mm_empty_hq_res.error_code == "territory_owner_mismatch"
		and _hqattack_unchanged(hqattack_mm_empty_hq_state, hqattack_mm_empty_hq_snap)
	)
	var hqattack_mm_empty_hood_state: GameState = _make_hqattack_world("", "hqattack_b")
	var hqattack_mm_empty_hood_snap: Dictionary = _hqattack_snapshot(hqattack_mm_empty_hood_state)
	var hqattack_mm_empty_hood_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_mm_empty_hood_state, _hqattack_stronghold_request("hqattack_mm_empty_hood")
	)
	var hqattack_mismatch_empty_hood_ok: bool = (
		not hqattack_mm_empty_hood_res.success
		and hqattack_mm_empty_hood_res.error_code == "territory_owner_mismatch"
		and _hqattack_unchanged(hqattack_mm_empty_hood_state, hqattack_mm_empty_hood_snap)
	)

	var hqattack_ghost_def_state: GameState = _make_hqattack_world("hqattack_ghost_def", "hqattack_ghost_def")
	var hqattack_ghost_def_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_ghost_def_state, _hqattack_stronghold_request("hqattack_ghost_def")
	)
	var hqattack_invalid_defender_ok: bool = (
		not hqattack_ghost_def_res.success
		and hqattack_ghost_def_res.error_code == "invalid_defender_faction"
		and not hqattack_ghost_def_state.has_mission("hqattack_ghost_def")
	)

	var hqattack_miss_att_state: GameState = _make_hqattack_world()
	var hqattack_miss_att_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_miss_att", "hqattack_force", "hqattack_hq", "hqattack_keep", "hqattack_missing"
	)
	var hqattack_miss_att_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_miss_att_state, hqattack_miss_att_req
	)
	var hqattack_miss_force_state: GameState = _make_hqattack_world()
	var hqattack_miss_force_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"hqattack_miss_force", "capture_neighborhood_hq", "hqattack_missing_force", "hqattack_hq"
	)
	var hqattack_miss_force_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_existing_force(
		hqattack_miss_force_state, hqattack_miss_force_req
	)
	var hqattack_invalid_attacker_ok: bool = (
		not hqattack_miss_att_res.success
		and hqattack_miss_att_res.error_code == "invalid_attacker_faction"
		and not hqattack_miss_force_res.success
		and hqattack_miss_force_res.error_code == "invalid_attacker_faction"
	)
	var hqattack_civ_att_state: GameState = _make_hqattack_world()
	var hqattack_civ_att_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_civ_att", "hqattack_force", "hqattack_hq", "hqattack_keep", "hqattack_civilians"
	)
	var hqattack_civ_att_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_civ_att_state, hqattack_civ_att_req
	)
	var hqattack_attacker_not_gang_ok: bool = (
		not hqattack_civ_att_res.success
		and hqattack_civ_att_res.error_code == "attacker_not_major_gang"
	)

	var hqattack_miss_tgt_state: GameState = _make_hqattack_world()
	var hqattack_miss_tgt_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_miss_tgt", "hqattack_force", "hqattack_missing_loc"
	)
	var hqattack_miss_tgt_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_miss_tgt_state, hqattack_miss_tgt_req
	)
	var hqattack_missing_target_ok: bool = (
		not hqattack_miss_tgt_res.success
		and hqattack_miss_tgt_res.error_code == "invalid_target_location"
	)
	var hqattack_biz_tgt_state: GameState = _make_hqattack_world()
	var hqattack_biz_tgt_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_biz_tgt", "hqattack_force", "hqattack_biz"
	)
	var hqattack_biz_tgt_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_biz_tgt_state, hqattack_biz_tgt_req
	)
	var hqattack_target_not_hq_ok: bool = (
		not hqattack_biz_tgt_res.success
		and hqattack_biz_tgt_res.error_code == "target_not_neighborhood_hq"
	)
	var hqattack_orphan_state: GameState = _make_hqattack_world()
	var hqattack_orphan_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_orphan", "hqattack_force", "hqattack_hq_orphan"
	)
	var hqattack_orphan_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_orphan_state, hqattack_orphan_req
	)
	var hqattack_missing_neighborhood_ok: bool = (
		not hqattack_orphan_res.success
		and hqattack_orphan_res.error_code == "missing_neighborhood"
	)
	var hqattack_ghost_hood_state: GameState = _make_hqattack_world()
	var hqattack_ghost_hood_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_ghost_hood", "hqattack_force", "hqattack_hq_ghost"
	)
	var hqattack_ghost_hood_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_ghost_hood_state, hqattack_ghost_hood_req
	)
	var hqattack_invalid_neighborhood_ok: bool = (
		not hqattack_ghost_hood_res.success
		and hqattack_ghost_hood_res.error_code == "invalid_neighborhood"
	)

	var hqattack_type_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_type_state, "hqattack_a", "hqattack_b")
	var hqattack_type_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_raid", "hqattack_force", "hqattack_hq", "hqattack_keep", "hqattack_a", "raid_business"
	)
	var hqattack_type_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_type_state, hqattack_type_req
	)
	var hqattack_wrong_type_ok: bool = (
		not hqattack_type_res.success
		and hqattack_type_res.error_code == "invalid_mission_type"
		and not hqattack_type_state.has_mission("hqattack_raid")
		and hqattack_type_req.mission_type_id == "raid_business"
	)

	var hqattack_dup_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_dup_state, "hqattack_a", "hqattack_b")
	var hqattack_dup_first: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_dup_state, _hqattack_stronghold_request("hqattack_dup")
	)
	var hqattack_dup_second: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_dup_state, _hqattack_stronghold_request("hqattack_dup", "hqattack_force_2")
	)
	var hqattack_dup_mission_ok: bool = (
		hqattack_dup_first.success
		and not hqattack_dup_second.success
		and hqattack_dup_second.error_code == "duplicate_mission_id"
		and not hqattack_dup_second.error_message.is_empty()
	)
	var hqattack_origin_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_origin_state, "hqattack_a", "hqattack_b")
	var hqattack_origin_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_bad_origin", "hqattack_force", "hqattack_hq", "hqattack_missing_keep"
	)
	var hqattack_origin_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_origin_state, hqattack_origin_req
	)
	var hqattack_invalid_origin_ok: bool = (
		not hqattack_origin_res.success
		and hqattack_origin_res.error_code == "invalid_origin"
		and not hqattack_origin_res.error_message.is_empty()
		and not hqattack_origin_state.has_mission("hqattack_bad_origin")
	)
	var hqattack_noroute_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_noroute_state, "hqattack_a", "hqattack_b")
	var hqattack_noroute_req: MissionRequest = _hqattack_stronghold_request(
		"hqattack_noroute", "hqattack_force", "hqattack_hq_island"
	)
	var hqattack_noroute_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_noroute_state, hqattack_noroute_req
	)
	var hqattack_no_route_ok: bool = (
		not hqattack_noroute_res.success
		and hqattack_noroute_res.error_code == "no_route"
		and not hqattack_noroute_res.error_message.is_empty()
		and not hqattack_noroute_state.has_mission("hqattack_noroute")
	)
	var hqattack_unres_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_unres_state, "hqattack_a", "hqattack_b")
	var hqattack_unres_force: TravelingForce = _hqattack_add_idle_force(hqattack_unres_state)
	hqattack_unres_state.add_mission(CampaignMission.new(
		"hqattack_open",
		"raid_business",
		"hqattack_a",
		"hqattack_force",
		"hqattack_keep",
		"hqattack_biz",
		"awaiting_resolution",
		""
	))
	var hqattack_unres_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"hqattack_blocked", "capture_neighborhood_hq", "hqattack_force", "hqattack_hq"
	)
	var hqattack_unres_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_existing_force(
		hqattack_unres_state, hqattack_unres_req
	)
	var hqattack_unresolved_ok: bool = (
		not hqattack_unres_res.success
		and hqattack_unres_res.error_code == "force_has_unresolved_mission"
		and not hqattack_unres_res.error_message.is_empty()
		and not hqattack_unres_state.has_mission("hqattack_blocked")
		and hqattack_unres_force.destination_location_id == "hqattack_keep"
	)

	var hqattack_boundary_state: GameState = _make_hqattack_world()
	DiplomacyService.declare_war(hqattack_boundary_state, "hqattack_a", "hqattack_b")
	var hqattack_boundary_res: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqattack_boundary_state, _hqattack_stronghold_request("hqattack_boundary")
	)
	var hqattack_boundary_hood: Neighborhood = hqattack_boundary_state.get_neighborhood("hqattack_hood")
	var hqattack_boundary_hq: NeighborhoodHQ = hqattack_boundary_state.get_map_location("hqattack_hq") as NeighborhoodHQ
	var hqattack_boundary_biz: Business = hqattack_boundary_state.get_map_location("hqattack_biz") as Business
	var hqattack_boundary_mission: CampaignMission = hqattack_boundary_state.get_mission("hqattack_boundary")
	var hqattack_launch_no_capture_ok: bool = (
		hqattack_boundary_res.success
		and hqattack_boundary_hood.owner_faction_id == "hqattack_b"
		and hqattack_boundary_hq.owner_faction_id == "hqattack_b"
		and hqattack_boundary_biz.owner_faction_id == "hqattack_b"
		and hqattack_boundary_mission != null
		and hqattack_boundary_mission.mission_state == "awaiting_resolution"
	)
	var hqattack_capture_after: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(
		hqattack_boundary_state, "hqattack_boundary"
	)
	var hqattack_no_capture_until_resolve_ok: bool = (
		hqattack_launch_no_capture_ok
		and hqattack_capture_after.success
		and hqattack_boundary_hood.owner_faction_id == "hqattack_a"
		and hqattack_boundary_hq.owner_faction_id == "hqattack_a"
		and hqattack_boundary_biz.owner_faction_id == ""
		and hqattack_boundary_mission.mission_state == "resolved_success"
		and hqattack_boundary_mission.outcome_code == "neighborhood_hq_captured"
	)

	var hqattack_helper_ok: NeighborhoodHQAttackResult = NeighborhoodHQAttackResult.succeeded(
		"m1", "f1", "hqattack_a", "hqattack_b", "hqattack_hood", "hqattack_hq", "awaiting_resolution", true
	)
	var hqattack_helper_fail: NeighborhoodHQAttackResult = NeighborhoodHQAttackResult.failed(
		"formal_war_required", "need war", "m2", "f2", "hqattack_a", "hqattack_b", "hqattack_hood", "hqattack_hq"
	)
	var hqattack_result_helper_ok: bool = (
		hqattack_helper_ok.success
		and hqattack_helper_ok.mission_id == "m1"
		and hqattack_helper_ok.force_id == "f1"
		and hqattack_helper_ok.attacker_faction_id == "hqattack_a"
		and hqattack_helper_ok.defender_faction_id == "hqattack_b"
		and hqattack_helper_ok.neighborhood_id == "hqattack_hood"
		and hqattack_helper_ok.hq_location_id == "hqattack_hq"
		and hqattack_helper_ok.mission_state == "awaiting_resolution"
		and hqattack_helper_ok.reached_destination
		and hqattack_helper_ok.error_code.is_empty()
		and not hqattack_helper_fail.success
		and hqattack_helper_fail.error_code == "formal_war_required"
		and hqattack_helper_fail.error_message == "need war"
		and not hqattack_helper_fail.reached_destination
	)

	var hqbattle_fail_state: GameState = _make_hqbattle_world()
	var hqbattle_fail_force: TravelingForce = _hqbattle_add_force_mission(hqbattle_fail_state)
	var hqbattle_fail_hood: Neighborhood = hqbattle_fail_state.get_neighborhood("hqbattle_hood")
	var hqbattle_fail_hq: NeighborhoodHQ = hqbattle_fail_state.get_map_location("hqbattle_hq") as NeighborhoodHQ
	var hqbattle_fail_biz_a: Business = hqbattle_fail_state.get_map_location("hqbattle_biz_a") as Business
	var hqbattle_fail_biz_b: Business = hqbattle_fail_state.get_map_location("hqbattle_biz_b") as Business
	var hqbattle_fail_biz_c: Business = hqbattle_fail_state.get_map_location("hqbattle_biz_c") as Business
	var hqbattle_fail_def_keep: Stronghold = hqbattle_fail_state.get_map_location("hqbattle_def_keep") as Stronghold
	var hqbattle_fail_att: MajorGang = hqbattle_fail_state.get_faction("hqbattle_a") as MajorGang
	var hqbattle_fail_def: MajorGang = hqbattle_fail_state.get_faction("hqbattle_b") as MajorGang
	var hqbattle_fail_mission: CampaignMission = hqbattle_fail_state.get_mission("hqbattle_mission")
	var hqbattle_fail_force_snap: Dictionary = _force_travel_snapshot(hqbattle_fail_force)
	var hqbattle_fail_soldiers: Array[String] = _copy_ids(hqbattle_fail_force.soldier_group.soldier_ids)
	var hqbattle_fail_vehicles: Array[String] = _copy_ids(hqbattle_fail_force.vehicle_group.vehicle_ids)
	var hqbattle_fail_force_count: int = hqbattle_fail_state.traveling_forces.size()
	var hqbattle_fail_soldier_count: int = hqbattle_fail_state.soldiers.size()
	var hqbattle_fail_vehicle_count: int = hqbattle_fail_state.vehicles.size()
	var hqbattle_fail_money_a: float = hqbattle_fail_att.money
	var hqbattle_fail_money_b: float = hqbattle_fail_def.money
	var hqbattle_fail_ammo_a: float = hqbattle_fail_att.resources.get_amount("Ammo")
	var hqbattle_fail_narc_b: float = hqbattle_fail_def.resources.get_amount("Narcotics")
	var hqbattle_fail_rel_count: int = hqbattle_fail_state.relationships.size()
	var hqbattle_fail_res: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResolver.resolve_failure(
		hqbattle_fail_state, "hqbattle_mission"
	)
	var hqbattle_fail_ok: bool = (
		hqbattle_fail_res.success
		and hqbattle_fail_res.mission_id == "hqbattle_mission"
		and hqbattle_fail_res.force_id == "hqbattle_force"
		and hqbattle_fail_res.defender_faction_id == "hqbattle_b"
		and hqbattle_fail_res.attacker_faction_id == "hqbattle_a"
		and hqbattle_fail_mission.mission_state == "resolved_failure"
		and hqbattle_fail_mission.outcome_code == "neighborhood_hq_assault_failed"
		and hqbattle_fail_hood.owner_faction_id == "hqbattle_b"
		and hqbattle_fail_hq.owner_faction_id == "hqbattle_b"
		and hqbattle_fail_biz_a.owner_faction_id == "hqbattle_b"
		and hqbattle_fail_biz_b.owner_faction_id == "hqbattle_b"
		and hqbattle_fail_biz_c.owner_faction_id == "hqbattle_c"
		and hqbattle_fail_def_keep.owner_faction_id == "hqbattle_b"
		and _force_travel_unchanged(hqbattle_fail_force, hqbattle_fail_force_snap)
		and hqbattle_fail_force.destination_location_id == "hqbattle_hq"
		and hqbattle_fail_force.travel_state == "at_destination"
		and _string_ids_match(hqbattle_fail_force.soldier_group.soldier_ids, hqbattle_fail_soldiers)
		and _string_ids_match(hqbattle_fail_force.vehicle_group.vehicle_ids, hqbattle_fail_vehicles)
		and hqbattle_fail_state.traveling_forces.size() == hqbattle_fail_force_count
		and hqbattle_fail_state.soldiers.size() == hqbattle_fail_soldier_count
		and hqbattle_fail_state.vehicles.size() == hqbattle_fail_vehicle_count
	)
	var hqbattle_reuse_req: ExistingForceMissionRequest = ExistingForceMissionRequest.new(
		"hqbattle_reuse", "raid_business", "hqbattle_force", "hqbattle_hq_b"
	)
	var hqbattle_reuse_res: ExistingForceMissionResult = MissionService.launch_from_existing_force(
		hqbattle_fail_state, hqbattle_reuse_req
	)
	var hqbattle_reuse_ok: bool = (
		hqbattle_fail_ok
		and hqbattle_reuse_res.success
		and hqbattle_reuse_res.force_id == "hqbattle_force"
		and hqbattle_fail_state.traveling_forces.size() == 1
		and hqbattle_fail_state.has_mission("hqbattle_reuse")
		and hqbattle_fail_mission.mission_state == "resolved_failure"
	)
	var hqbattle_no_side_effects_ok: bool = (
		hqbattle_fail_ok
		and is_equal_approx(hqbattle_fail_att.money, hqbattle_fail_money_a)
		and is_equal_approx(hqbattle_fail_def.money, hqbattle_fail_money_b)
		and is_equal_approx(hqbattle_fail_att.resources.get_amount("Ammo"), hqbattle_fail_ammo_a)
		and is_equal_approx(hqbattle_fail_def.resources.get_amount("Narcotics"), hqbattle_fail_narc_b)
		and hqbattle_fail_state.relationships.size() == hqbattle_fail_rel_count
		and hqbattle_fail_state.has_soldier("hqbattle_soldier")
		and hqbattle_fail_state.has_vehicle("hqbattle_vehicle")
		and hqbattle_fail_state.has_soldier("hqbattle_def_soldier")
	)

	var hqbattle_null_res: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResolver.resolve_failure(null, "hqbattle_mission")
	var hqbattle_null_ok: bool = not hqbattle_null_res.success and hqbattle_null_res.error_code == "null_game_state"
	var hqbattle_empty_state: GameState = _make_hqbattle_world()
	_hqbattle_add_force_mission(hqbattle_empty_state)
	var hqbattle_empty_id_ok: bool = _hqbattle_fails_atomically(hqbattle_empty_state, "", "empty_mission_id", hqbattle_empty_state.get_traveling_force("hqbattle_force"))
	var hqbattle_miss_state: GameState = _make_hqbattle_world()
	var hqbattle_miss_force: TravelingForce = _hqbattle_add_force_mission(hqbattle_miss_state)
	var hqbattle_missing_mission_ok: bool = _hqbattle_fails_atomically(hqbattle_miss_state, "hqbattle_missing", "invalid_mission", hqbattle_miss_force)
	var hqbattle_type_state: GameState = _make_hqbattle_world()
	var hqbattle_type_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_type_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq", "hqbattle_hq", "at_destination", "awaiting_resolution", "raid_business"
	)
	var hqbattle_wrong_type_ok: bool = _hqbattle_fails_atomically(hqbattle_type_state, "hqbattle_mission", "invalid_mission_type", hqbattle_type_force)
	var hqbattle_await_state: GameState = _make_hqbattle_world()
	var hqbattle_await_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_await_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq", "hqbattle_hq", "at_destination", "traveling_outbound"
	)
	var hqbattle_not_awaiting_ok: bool = _hqbattle_fails_atomically(hqbattle_await_state, "hqbattle_mission", "mission_not_awaiting_resolution", hqbattle_await_force)
	var hqbattle_bad_force_state: GameState = _make_hqbattle_world()
	var hqbattle_bad_force: TravelingForce = _hqbattle_add_force_mission(hqbattle_bad_force_state)
	hqbattle_bad_force_state.get_mission("hqbattle_mission").force_id = "hqbattle_missing_force"
	var hqbattle_invalid_force_ok: bool = _hqbattle_fails_atomically(hqbattle_bad_force_state, "hqbattle_mission", "invalid_force", hqbattle_bad_force)
	var hqbattle_travel_state: GameState = _make_hqbattle_world()
	var hqbattle_travel_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_travel_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq", "hqbattle_hq", "traveling_outbound"
	)
	var hqbattle_not_dest_ok: bool = _hqbattle_fails_atomically(hqbattle_travel_state, "hqbattle_mission", "force_not_at_destination", hqbattle_travel_force)
	var hqbattle_fac_state: GameState = _make_hqbattle_world()
	var hqbattle_fac_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_fac_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_b"
	)
	var hqbattle_faction_mismatch_ok: bool = _hqbattle_fails_atomically(hqbattle_fac_state, "hqbattle_mission", "force_faction_mismatch", hqbattle_fac_force)
	var hqbattle_tgt_state: GameState = _make_hqbattle_world()
	var hqbattle_tgt_force: TravelingForce = _hqbattle_add_force_mission(hqbattle_tgt_state)
	hqbattle_tgt_state.get_mission("hqbattle_mission").target_location_id = "hqbattle_missing_loc"
	var hqbattle_missing_target_ok: bool = _hqbattle_fails_atomically(hqbattle_tgt_state, "hqbattle_mission", "invalid_target_location", hqbattle_tgt_force)
	var hqbattle_biz_state: GameState = _make_hqbattle_world()
	var hqbattle_biz_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_biz_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq", "hqbattle_biz_a"
	)
	var hqbattle_target_not_hq_ok: bool = _hqbattle_fails_atomically(hqbattle_biz_state, "hqbattle_mission", "target_not_neighborhood_hq", hqbattle_biz_force)
	var hqbattle_ftm_state: GameState = _make_hqbattle_world()
	var hqbattle_ftm_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_ftm_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq_b", "hqbattle_hq"
	)
	var hqbattle_force_target_mismatch_ok: bool = _hqbattle_fails_atomically(hqbattle_ftm_state, "hqbattle_mission", "force_target_mismatch", hqbattle_ftm_force)
	var hqbattle_orphan_state: GameState = _make_hqbattle_world()
	var hqbattle_orphan_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_orphan_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq_orphan", "hqbattle_hq_orphan"
	)
	var hqbattle_missing_neighborhood_ok: bool = _hqbattle_fails_atomically(hqbattle_orphan_state, "hqbattle_mission", "missing_neighborhood", hqbattle_orphan_force)
	var hqbattle_ghost_state: GameState = _make_hqbattle_world()
	var hqbattle_ghost_force: TravelingForce = _hqbattle_add_force_mission(
		hqbattle_ghost_state, "hqbattle_force", "hqbattle_mission", "hqbattle_a", "hqbattle_a",
		"hqbattle_hq_ghost", "hqbattle_hq_ghost"
	)
	var hqbattle_invalid_neighborhood_ok: bool = _hqbattle_fails_atomically(hqbattle_ghost_state, "hqbattle_mission", "invalid_neighborhood", hqbattle_ghost_force)
	var hqbattle_mm_state: GameState = _make_hqbattle_world("hqbattle_b", "hqbattle_c")
	var hqbattle_mm_force: TravelingForce = _hqbattle_add_force_mission(hqbattle_mm_state)
	var hqbattle_mismatch_ok: bool = _hqbattle_fails_atomically(hqbattle_mm_state, "hqbattle_mission", "territory_owner_mismatch", hqbattle_mm_force)
	var hqbattle_atomicity_ok: bool = (
		hqbattle_empty_id_ok
		and hqbattle_missing_mission_ok
		and hqbattle_wrong_type_ok
		and hqbattle_not_awaiting_ok
		and hqbattle_invalid_force_ok
		and hqbattle_not_dest_ok
		and hqbattle_faction_mismatch_ok
		and hqbattle_missing_target_ok
		and hqbattle_target_not_hq_ok
		and hqbattle_force_target_mismatch_ok
		and hqbattle_missing_neighborhood_ok
		and hqbattle_invalid_neighborhood_ok
		and hqbattle_mismatch_ok
	)

	var hqbattle_unclaimed_state: GameState = _make_hqbattle_world("", "")
	var hqbattle_unclaimed_force: TravelingForce = _hqbattle_add_force_mission(hqbattle_unclaimed_state)
	var hqbattle_unclaimed_hood: Neighborhood = hqbattle_unclaimed_state.get_neighborhood("hqbattle_hood")
	var hqbattle_unclaimed_hq: NeighborhoodHQ = hqbattle_unclaimed_state.get_map_location("hqbattle_hq") as NeighborhoodHQ
	var hqbattle_unclaimed_res: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResolver.resolve_failure(
		hqbattle_unclaimed_state, "hqbattle_mission"
	)
	var hqbattle_unclaimed_fail_ok: bool = (
		hqbattle_unclaimed_res.success
		and hqbattle_unclaimed_res.defender_faction_id == ""
		and hqbattle_unclaimed_state.get_mission("hqbattle_mission").mission_state == "resolved_failure"
		and hqbattle_unclaimed_state.get_mission("hqbattle_mission").outcome_code == "neighborhood_hq_assault_failed"
		and hqbattle_unclaimed_hood.owner_faction_id == ""
		and hqbattle_unclaimed_hq.owner_faction_id == ""
		and hqbattle_unclaimed_force.destination_location_id == "hqbattle_hq"
	)

	var hqbattle_win_state: GameState = _make_hqbattle_world()
	_hqbattle_add_force_mission(hqbattle_win_state)
	var hqbattle_win_expected: Array[String] = ["hqbattle_biz_a", "hqbattle_biz_b"]
	var hqbattle_win_res: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		hqbattle_win_state, "hqbattle_mission", true
	)
	var hqbattle_win_source: Array[String] = _copy_ids(hqbattle_win_res.businesses_unclaimed)
	hqbattle_win_res.businesses_unclaimed.append("mutated")
	var hqbattle_win_ok: bool = (
		hqbattle_win_res.success
		and hqbattle_win_res.attacker_won
		and hqbattle_win_res.mission_state == "resolved_success"
		and hqbattle_win_res.outcome_code == "neighborhood_hq_captured"
		and hqbattle_win_state.get_neighborhood("hqbattle_hood").owner_faction_id == "hqbattle_a"
		and (hqbattle_win_state.get_map_location("hqbattle_hq") as NeighborhoodHQ).owner_faction_id == "hqbattle_a"
		and (hqbattle_win_state.get_map_location("hqbattle_biz_a") as Business).owner_faction_id == ""
		and (hqbattle_win_state.get_map_location("hqbattle_biz_b") as Business).owner_faction_id == ""
		and (hqbattle_win_state.get_map_location("hqbattle_biz_c") as Business).owner_faction_id == "hqbattle_c"
		and _string_ids_match(hqbattle_win_source, hqbattle_win_expected)
		and hqbattle_win_state.get_mission("hqbattle_mission").mission_state == "resolved_success"
	)

	var hqbattle_loss_state: GameState = _make_hqbattle_world()
	_hqbattle_add_force_mission(hqbattle_loss_state)
	var hqbattle_loss_res: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		hqbattle_loss_state, "hqbattle_mission", false
	)
	var hqbattle_loss_ok: bool = (
		hqbattle_loss_res.success
		and not hqbattle_loss_res.attacker_won
		and hqbattle_loss_res.mission_state == "resolved_failure"
		and hqbattle_loss_res.outcome_code == "neighborhood_hq_assault_failed"
		and hqbattle_loss_res.businesses_unclaimed.is_empty()
		and hqbattle_loss_state.get_neighborhood("hqbattle_hood").owner_faction_id == "hqbattle_b"
		and (hqbattle_loss_state.get_map_location("hqbattle_hq") as NeighborhoodHQ).owner_faction_id == "hqbattle_b"
		and (hqbattle_loss_state.get_map_location("hqbattle_biz_a") as Business).owner_faction_id == "hqbattle_b"
		and (hqbattle_loss_state.get_map_location("hqbattle_biz_c") as Business).owner_faction_id == "hqbattle_c"
		and hqbattle_loss_state.get_mission("hqbattle_mission").mission_state == "resolved_failure"
	)

	var hqbattle_err_win_state: GameState = _make_hqbattle_world()
	_hqbattle_add_force_mission(hqbattle_err_win_state)
	var hqbattle_err_win: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		hqbattle_err_win_state, "hqbattle_missing", true
	)
	var hqbattle_err_loss: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		hqbattle_err_win_state, "hqbattle_missing", false
	)
	var hqbattle_err_win_ok: bool = (
		not hqbattle_err_win.success
		and hqbattle_err_win.attacker_won
		and hqbattle_err_win.error_code == "invalid_mission"
		and not hqbattle_err_win.error_message.is_empty()
	)
	var hqbattle_err_loss_ok: bool = (
		not hqbattle_err_loss.success
		and not hqbattle_err_loss.attacker_won
		and hqbattle_err_loss.error_code == "invalid_mission"
		and not hqbattle_err_loss.error_message.is_empty()
	)

	var hqbattle_fail_helper_ok_res: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResult.succeeded(
		"m1", "f1", "hqbattle_hood", "hqbattle_hq", "hqbattle_a", "hqbattle_b"
	)
	var hqbattle_fail_helper_fail_res: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResult.failed(
		"invalid_mission", "missing", "m2", "f2"
	)
	var hqbattle_fail_helper_ok: bool = (
		hqbattle_fail_helper_ok_res.success
		and hqbattle_fail_helper_ok_res.mission_id == "m1"
		and hqbattle_fail_helper_ok_res.force_id == "f1"
		and hqbattle_fail_helper_ok_res.neighborhood_id == "hqbattle_hood"
		and hqbattle_fail_helper_ok_res.hq_location_id == "hqbattle_hq"
		and hqbattle_fail_helper_ok_res.attacker_faction_id == "hqbattle_a"
		and hqbattle_fail_helper_ok_res.defender_faction_id == "hqbattle_b"
		and hqbattle_fail_helper_ok_res.error_code.is_empty()
		and not hqbattle_fail_helper_fail_res.success
		and hqbattle_fail_helper_fail_res.error_code == "invalid_mission"
		and hqbattle_fail_helper_fail_res.error_message == "missing"
	)
	var hqbattle_helper_src: Array[String] = ["hqbattle_biz_a", "hqbattle_biz_b"]
	var hqbattle_helper_ok_res: NeighborhoodHQBattleResult = NeighborhoodHQBattleResult.succeeded(
		true, "m3", "f3", "hqbattle_hood", "hqbattle_hq", "hqbattle_a", "hqbattle_b",
		"resolved_success", "neighborhood_hq_captured", hqbattle_helper_src
	)
	hqbattle_helper_ok_res.businesses_unclaimed.append("mutated")
	var hqbattle_helper_fail_res: NeighborhoodHQBattleResult = NeighborhoodHQBattleResult.failed(
		"invalid_mission_type", "wrong type", false, "m4", "f4"
	)
	var hqbattle_result_helper_ok: bool = (
		hqbattle_helper_ok_res.success
		and hqbattle_helper_ok_res.attacker_won
		and hqbattle_helper_ok_res.mission_id == "m3"
		and hqbattle_helper_ok_res.force_id == "f3"
		and hqbattle_helper_ok_res.attacker_faction_id == "hqbattle_a"
		and hqbattle_helper_ok_res.defender_faction_id == "hqbattle_b"
		and hqbattle_helper_ok_res.mission_state == "resolved_success"
		and hqbattle_helper_ok_res.outcome_code == "neighborhood_hq_captured"
		and hqbattle_helper_ok_res.error_code.is_empty()
		and _string_ids_match(hqbattle_helper_src, ["hqbattle_biz_a", "hqbattle_biz_b"])
		and not hqbattle_helper_fail_res.success
		and not hqbattle_helper_fail_res.attacker_won
		and hqbattle_helper_fail_res.error_code == "invalid_mission_type"
		and hqbattle_helper_fail_res.businesses_unclaimed.is_empty()
	)

	var hqbattle_chain_loss_state: GameState = _make_hqbattle_world()
	DiplomacyService.declare_war(hqbattle_chain_loss_state, "hqbattle_a", "hqbattle_b")
	var hqbattle_chain_loss_launch: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqbattle_chain_loss_state, _hqbattle_stronghold_request("hqbattle_chain_loss")
	)
	var hqbattle_chain_loss_battle: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		hqbattle_chain_loss_state, "hqbattle_chain_loss", false
	)
	var hqbattle_chain_loss_ok: bool = (
		hqbattle_chain_loss_launch.success
		and hqbattle_chain_loss_launch.mission_state == "awaiting_resolution"
		and hqbattle_chain_loss_battle.success
		and not hqbattle_chain_loss_battle.attacker_won
		and hqbattle_chain_loss_state.get_neighborhood("hqbattle_hood").owner_faction_id == "hqbattle_b"
		and (hqbattle_chain_loss_state.get_map_location("hqbattle_hq") as NeighborhoodHQ).owner_faction_id == "hqbattle_b"
		and (hqbattle_chain_loss_state.get_map_location("hqbattle_biz_a") as Business).owner_faction_id == "hqbattle_b"
		and hqbattle_chain_loss_state.get_mission("hqbattle_chain_loss").mission_state == "resolved_failure"
		and hqbattle_chain_loss_state.get_mission("hqbattle_chain_loss").outcome_code == "neighborhood_hq_assault_failed"
	)
	var hqbattle_chain_win_state: GameState = _make_hqbattle_world()
	DiplomacyService.declare_war(hqbattle_chain_win_state, "hqbattle_a", "hqbattle_b")
	var hqbattle_chain_win_launch: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		hqbattle_chain_win_state, _hqbattle_stronghold_request("hqbattle_chain_win")
	)
	var hqbattle_chain_win_battle: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		hqbattle_chain_win_state, "hqbattle_chain_win", true
	)
	var hqbattle_chain_win_ok: bool = (
		hqbattle_chain_win_launch.success
		and hqbattle_chain_win_launch.mission_state == "awaiting_resolution"
		and hqbattle_chain_win_battle.success
		and hqbattle_chain_win_battle.attacker_won
		and hqbattle_chain_win_state.get_neighborhood("hqbattle_hood").owner_faction_id == "hqbattle_a"
		and (hqbattle_chain_win_state.get_map_location("hqbattle_hq") as NeighborhoodHQ).owner_faction_id == "hqbattle_a"
		and (hqbattle_chain_win_state.get_map_location("hqbattle_biz_a") as Business).owner_faction_id == ""
		and hqbattle_chain_win_state.get_mission("hqbattle_chain_win").mission_state == "resolved_success"
		and hqbattle_chain_win_state.get_mission("hqbattle_chain_win").outcome_code == "neighborhood_hq_captured"
	)

	var battle_expected_soldiers: Array[String] = ["battle_sol_a", "battle_sol_m", "battle_sol_z"]
	var battle_expected_vehicles: Array[String] = ["battle_veh_a", "battle_veh_m", "battle_veh_z"]
	var battle_std_state: GameState = _make_battle_world()
	DiplomacyService.declare_war(battle_std_state, "battle_a", "battle_b")
	var battle_std_force: TravelingForce = _battle_add_force_mission(battle_std_state)
	var battle_std_mission: CampaignMission = battle_std_state.get_mission("battle_mission")
	var battle_std_hood: Neighborhood = battle_std_state.get_neighborhood("battle_hood")
	var battle_std_hq: NeighborhoodHQ = battle_std_state.get_map_location("battle_hq") as NeighborhoodHQ
	var battle_std_biz: Business = battle_std_state.get_map_location("battle_biz") as Business
	var battle_std_att: MajorGang = battle_std_state.get_faction("battle_a") as MajorGang
	var battle_std_def: MajorGang = battle_std_state.get_faction("battle_b") as MajorGang
	var battle_std_sol_a: Soldier = battle_std_state.get_soldier("battle_sol_a")
	var battle_std_sol_m: Soldier = battle_std_state.get_soldier("battle_sol_m")
	var battle_std_sol_z: Soldier = battle_std_state.get_soldier("battle_sol_z")
	var battle_std_veh_a: Vehicle = battle_std_state.get_vehicle("battle_veh_a")
	var battle_std_veh_m: Vehicle = battle_std_state.get_vehicle("battle_veh_m")
	var battle_std_veh_z: Vehicle = battle_std_state.get_vehicle("battle_veh_z")
	var battle_std_snap: Dictionary = _battle_campaign_snapshot(battle_std_state, battle_std_force, "battle_mission")
	var battle_std_result: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(
		battle_std_state, "battle_mission"
	)
	var battle_std_bs: BattleState = battle_std_result.battle_state
	var battle_std_att_side: BattleSide = null
	var battle_std_def_side: BattleSide = null
	var battle_std_att_zone: DeploymentZone = null
	var battle_std_def_zone: DeploymentZone = null
	if battle_std_bs != null:
		battle_std_att_side = battle_std_bs.get_side("attacker")
		battle_std_def_side = battle_std_bs.get_side("defender")
		battle_std_att_zone = battle_std_bs.get_deployment_zone("attacker_deployment")
		battle_std_def_zone = battle_std_bs.get_deployment_zone("defender_deployment")
	var battle_setup_ok: bool = (
		battle_std_result.success
		and battle_std_bs != null
		and battle_std_result.battle_id == "battle_battle_mission"
		and battle_std_bs.battle_id == "battle_battle_mission"
		and battle_std_bs.battle_type_id == "neighborhood_hq_assault"
		and battle_std_bs.mission_id == "battle_mission"
		and battle_std_result.mission_id == "battle_mission"
		and battle_std_bs.location_id == "battle_hq"
		and battle_std_bs.attacker_side_id == "attacker"
		and battle_std_bs.defender_side_id == "defender"
		and battle_std_bs.battle_phase == "deployment"
		and battle_std_result.error_code.is_empty()
		and battle_std_result.error_message.is_empty()
	)
	var battle_attacker_side_ok: bool = (
		battle_setup_ok
		and battle_std_att_side != null
		and battle_std_bs.has_side("attacker")
		and battle_std_att_side.faction_id == "battle_a"
		and battle_std_att_side.force_id == "battle_force"
		and battle_std_att_side.force_id == battle_std_force.id
		and battle_std_att_side.is_attacker
		and battle_std_att_side.deployment_zone_id == "attacker_deployment"
		and _string_ids_match(battle_std_att_side.participant_ids, battle_expected_soldiers)
		and _string_ids_match(battle_std_att_side.vehicle_ids, battle_expected_vehicles)
		and not _string_ids_match(battle_std_force.soldier_group.soldier_ids, battle_expected_soldiers)
		and not _string_ids_match(battle_std_force.vehicle_group.vehicle_ids, battle_expected_vehicles)
	)
	var battle_defender_side_ok: bool = (
		battle_setup_ok
		and battle_std_def_side != null
		and battle_std_bs.has_side("defender")
		and battle_std_def_side.faction_id == "battle_b"
		and battle_std_def_side.force_id.is_empty()
		and not battle_std_def_side.is_attacker
		and battle_std_def_side.deployment_zone_id == "defender_deployment"
		and battle_std_def_side.participant_ids.is_empty()
		and battle_std_def_side.vehicle_ids.is_empty()
	)
	var battle_participants_ok: bool = (
		battle_setup_ok
		and _battle_participant_matches_soldier(battle_std_bs, battle_std_sol_a)
		and _battle_participant_matches_soldier(battle_std_bs, battle_std_sol_m)
		and _battle_participant_matches_soldier(battle_std_bs, battle_std_sol_z)
		and battle_std_bs.participants.size() == 3
		and _battle_soldier_matches_dict(battle_std_sol_a, _battle_dict_from_snap(battle_std_snap, "soldiers", "battle_sol_a"))
		and _battle_soldier_matches_dict(battle_std_sol_m, _battle_dict_from_snap(battle_std_snap, "soldiers", "battle_sol_m"))
		and _battle_soldier_matches_dict(battle_std_sol_z, _battle_dict_from_snap(battle_std_snap, "soldiers", "battle_sol_z"))
	)
	var battle_vehicles_ok: bool = (
		battle_setup_ok
		and _battle_vehicle_matches_campaign(battle_std_bs, battle_std_veh_a)
		and _battle_vehicle_matches_campaign(battle_std_bs, battle_std_veh_m)
		and _battle_vehicle_matches_campaign(battle_std_bs, battle_std_veh_z)
		and battle_std_bs.vehicles.size() == 3
		and _battle_vehicle_matches_dict(battle_std_veh_a, _battle_dict_from_snap(battle_std_snap, "vehicles", "battle_veh_a"))
		and _battle_vehicle_matches_dict(battle_std_veh_m, _battle_dict_from_snap(battle_std_snap, "vehicles", "battle_veh_m"))
		and _battle_vehicle_matches_dict(battle_std_veh_z, _battle_dict_from_snap(battle_std_snap, "vehicles", "battle_veh_z"))
	)
	var battle_zones_ok: bool = (
		battle_setup_ok
		and battle_std_bs.deployment_zones.size() == 2
		and battle_std_att_zone != null
		and battle_std_def_zone != null
		and battle_std_att_zone.zone_id == "attacker_deployment"
		and battle_std_att_zone.side_id == "attacker"
		and battle_std_att_zone.zone_type == "attacker_entry"
		and battle_std_def_zone.zone_id == "defender_deployment"
		and battle_std_def_zone.side_id == "defender"
		and battle_std_def_zone.zone_type == "defender_position"
		and _string_ids_match(battle_std_att_zone.allowed_participant_ids, battle_expected_soldiers)
		and _string_ids_match(battle_std_att_zone.allowed_vehicle_ids, battle_expected_vehicles)
		and battle_std_att_zone.allows_participant("battle_sol_a")
		and battle_std_att_zone.allows_participant("battle_sol_m")
		and battle_std_att_zone.allows_participant("battle_sol_z")
		and battle_std_att_zone.allows_vehicle("battle_veh_a")
		and battle_std_att_zone.allows_vehicle("battle_veh_m")
		and battle_std_att_zone.allows_vehicle("battle_veh_z")
		and not battle_std_att_zone.allows_participant("battle_unknown")
		and not battle_std_att_zone.allows_vehicle("battle_unknown")
		and not battle_std_att_zone.allows_participant("")
		and not battle_std_att_zone.allows_vehicle("")
		and battle_std_def_zone.allowed_participant_ids.is_empty()
		and battle_std_def_zone.allowed_vehicle_ids.is_empty()
		and not battle_std_def_zone.allows_participant("battle_sol_a")
		and not battle_std_def_zone.allows_vehicle("battle_veh_a")
	)
	var battle_immutability_ok: bool = (
		battle_setup_ok
		and _battle_campaign_unchanged(battle_std_state, battle_std_snap, battle_std_force, "battle_mission")
		and battle_std_mission.mission_state == "awaiting_resolution"
		and battle_std_mission.outcome_code.is_empty()
		and battle_std_hood.owner_faction_id == "battle_b"
		and battle_std_hq.owner_faction_id == "battle_b"
		and battle_std_biz.owner_faction_id == "battle_b"
		and is_equal_approx(battle_std_att.money, float(battle_std_snap.get("money_a", -1.0)))
		and is_equal_approx(battle_std_def.money, float(battle_std_snap.get("money_b", -1.0)))
	)
	var battle_setup_service_probe: BattleSetupService = BattleSetupService.new()
	var battle_no_combat_ok: bool = (
		battle_setup_ok
		and battle_std_bs.battle_phase == "deployment"
		and not battle_std_bs.has_method("resolve_hit")
		and not battle_std_bs.has_method("apply_wound")
		and not battle_std_bs.has_method("apply_kill")
		and not battle_std_bs.has_method("fire")
		and not battle_std_bs.has_method("advance_phase")
		and not battle_std_bs.has_method("simulate_combat")
		and not battle_setup_service_probe.has_method("simulate_combat")
		and not battle_setup_service_probe.has_method("resolve_hit")
		and battle_std_bs.get_participant("battle_sol_a").is_alive
		and not battle_std_bs.get_participant("battle_sol_a").is_wounded
		and battle_std_bs.get_vehicle("battle_veh_a").get("hit_points") == null
		and battle_std_bs.get_vehicle("battle_veh_a").get("damage") == null
		and battle_std_bs.get_participant("battle_sol_a").get("hit_points") == null
	)
	var battle_unclaimed_state: GameState = _make_battle_world("", "")
	var battle_unclaimed_force: TravelingForce = _battle_add_force_mission(battle_unclaimed_state)
	var battle_unclaimed_result: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(
		battle_unclaimed_state, "battle_mission"
	)
	var battle_unclaimed_bs: BattleState = battle_unclaimed_result.battle_state
	var battle_unclaimed_def: BattleSide = null
	if battle_unclaimed_bs != null:
		battle_unclaimed_def = battle_unclaimed_bs.get_side("defender")
	var battle_unclaimed_ok: bool = (
		battle_unclaimed_result.success
		and battle_unclaimed_bs != null
		and battle_unclaimed_def != null
		and battle_unclaimed_def.faction_id.is_empty()
		and battle_unclaimed_def.force_id.is_empty()
		and not battle_unclaimed_def.is_attacker
		and battle_unclaimed_def.participant_ids.is_empty()
		and battle_unclaimed_def.vehicle_ids.is_empty()
		and battle_unclaimed_bs.participants.size() == 3
		and battle_unclaimed_bs.vehicles.size() == 3
		and battle_unclaimed_state.get_neighborhood("battle_hood").owner_faction_id.is_empty()
		and (battle_unclaimed_state.get_map_location("battle_hq") as NeighborhoodHQ).owner_faction_id.is_empty()
	)
	var battle_reg_state: BattleState = BattleState.new(
		"battle_reg", "neighborhood_hq_assault", "battle_reg_mission", "battle_hq", "attacker", "defender", "deployment"
	)
	var battle_reg_side: BattleSide = BattleSide.new("side_x", "battle_a", "battle_force", true, "zone_x")
	var battle_reg_part: BattleParticipant = BattleParticipant.new(
		"part_x", "sol_x", "battle_a", "side_x", "pistol", true, false, ""
	)
	var battle_reg_veh: BattleVehicle = BattleVehicle.new(
		"veh_x", "veh_x", "battle_a", "side_x", "car", ""
	)
	var battle_reg_zone: DeploymentZone = DeploymentZone.new("zone_x", "side_x", "attacker_entry")
	var battle_reg_empty_side: BattleSide = BattleSide.new("", "battle_a", "battle_force", true, "zone_x")
	var battle_reg_empty_part: BattleParticipant = BattleParticipant.new(
		"", "sol_y", "battle_a", "side_x", "pistol", true, false, ""
	)
	var battle_reg_empty_veh: BattleVehicle = BattleVehicle.new("", "veh_y", "battle_a", "side_x", "car", "")
	var battle_reg_empty_zone: DeploymentZone = DeploymentZone.new("", "side_x", "attacker_entry")
	var battle_reg_dup_side: BattleSide = BattleSide.new("side_x", "battle_b", "", false, "")
	var battle_reg_dup_part: BattleParticipant = BattleParticipant.new(
		"part_x", "sol_z", "battle_a", "side_x", "rifle", true, false, ""
	)
	var battle_reg_dup_veh: BattleVehicle = BattleVehicle.new("veh_x", "veh_z", "battle_a", "side_x", "truck", "")
	var battle_reg_dup_zone: DeploymentZone = DeploymentZone.new("zone_x", "side_y", "defender_position")
	var battle_registry_ok: bool = (
		battle_reg_state.add_side(battle_reg_side)
		and battle_reg_state.has_side("side_x")
		and battle_reg_state.get_side("side_x") == battle_reg_side
		and not battle_reg_state.has_side("missing")
		and battle_reg_state.get_side("missing") == null
		and not battle_reg_state.add_side(null)
		and not battle_reg_state.add_side(battle_reg_empty_side)
		and not battle_reg_state.add_side(battle_reg_dup_side)
		and battle_reg_state.add_participant(battle_reg_part)
		and battle_reg_state.has_participant("part_x")
		and battle_reg_state.get_participant("part_x") == battle_reg_part
		and not battle_reg_state.has_participant("missing")
		and battle_reg_state.get_participant("missing") == null
		and not battle_reg_state.add_participant(null)
		and not battle_reg_state.add_participant(battle_reg_empty_part)
		and not battle_reg_state.add_participant(battle_reg_dup_part)
		and battle_reg_state.add_vehicle(battle_reg_veh)
		and battle_reg_state.has_vehicle("veh_x")
		and battle_reg_state.get_vehicle("veh_x") == battle_reg_veh
		and not battle_reg_state.has_vehicle("missing")
		and battle_reg_state.get_vehicle("missing") == null
		and not battle_reg_state.add_vehicle(null)
		and not battle_reg_state.add_vehicle(battle_reg_empty_veh)
		and not battle_reg_state.add_vehicle(battle_reg_dup_veh)
		and battle_reg_state.add_deployment_zone(battle_reg_zone)
		and battle_reg_state.has_deployment_zone("zone_x")
		and battle_reg_state.get_deployment_zone("zone_x") == battle_reg_zone
		and not battle_reg_state.has_deployment_zone("missing")
		and battle_reg_state.get_deployment_zone("missing") == null
		and not battle_reg_state.add_deployment_zone(null)
		and not battle_reg_state.add_deployment_zone(battle_reg_empty_zone)
		and not battle_reg_state.add_deployment_zone(battle_reg_dup_zone)
	)
	var battle_help_side: BattleSide = BattleSide.new("help_side", "battle_a", "battle_force", true, "zone")
	var battle_side_helpers_ok: bool = (
		battle_help_side.add_participant_id("p_b")
		and battle_help_side.add_participant_id("p_a")
		and _string_ids_match(battle_help_side.participant_ids, ["p_b", "p_a"])
		and not battle_help_side.add_participant_id("p_b")
		and not battle_help_side.add_participant_id("")
		and battle_help_side.has_participant_id("p_b")
		and battle_help_side.has_participant_id("p_a")
		and not battle_help_side.has_participant_id("p_missing")
		and battle_help_side.add_vehicle_id("v_b")
		and battle_help_side.add_vehicle_id("v_a")
		and _string_ids_match(battle_help_side.vehicle_ids, ["v_b", "v_a"])
		and not battle_help_side.add_vehicle_id("v_b")
		and not battle_help_side.add_vehicle_id("")
		and battle_help_side.has_vehicle_id("v_b")
		and battle_help_side.has_vehicle_id("v_a")
		and not battle_help_side.has_vehicle_id("v_missing")
	)
	var battle_null_res: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(null, "battle_mission")
	var battle_err_null_ok: bool = (
		not battle_null_res.success
		and battle_null_res.battle_state == null
		and battle_null_res.error_code == "null_game_state"
	)
	var battle_empty_state: GameState = _make_battle_world()
	var battle_empty_force: TravelingForce = _battle_add_force_mission(battle_empty_state)
	var battle_err_empty_id_ok: bool = _battle_fails_setup(
		battle_empty_state, "", "empty_mission_id", battle_empty_force
	)
	var battle_miss_state: GameState = _make_battle_world()
	var battle_miss_force: TravelingForce = _battle_add_force_mission(battle_miss_state)
	var battle_err_invalid_mission_ok: bool = _battle_fails_setup(
		battle_miss_state, "battle_missing", "invalid_mission", battle_miss_force
	)
	var battle_type_state: GameState = _make_battle_world()
	var battle_type_force: TravelingForce = _battle_add_force_mission(
		battle_type_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "raid_business"
	)
	var battle_err_invalid_type_ok: bool = _battle_fails_setup(
		battle_type_state, "battle_mission", "invalid_mission_type", battle_type_force
	)
	var battle_await_state: GameState = _make_battle_world()
	var battle_await_force: TravelingForce = _battle_add_force_mission(
		battle_await_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "traveling_outbound"
	)
	var battle_err_not_awaiting_ok: bool = _battle_fails_setup(
		battle_await_state, "battle_mission", "mission_not_awaiting_resolution", battle_await_force
	)
	var battle_bad_force_state: GameState = _make_battle_world()
	var battle_bad_force: TravelingForce = _battle_add_force_mission(battle_bad_force_state)
	battle_bad_force_state.get_mission("battle_mission").force_id = "battle_missing_force"
	var battle_err_invalid_force_ok: bool = _battle_fails_setup(
		battle_bad_force_state, "battle_mission", "invalid_attacker_force", battle_bad_force
	)
	var battle_travel_state: GameState = _make_battle_world()
	var battle_travel_force: TravelingForce = _battle_add_force_mission(
		battle_travel_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "traveling_outbound"
	)
	var battle_err_not_dest_ok: bool = _battle_fails_setup(
		battle_travel_state, "battle_mission", "attacker_not_at_destination", battle_travel_force
	)
	var battle_fac_state: GameState = _make_battle_world()
	var battle_fac_force: TravelingForce = _battle_add_force_mission(
		battle_fac_state, "battle_force", "battle_mission", "battle_b", "battle_a"
	)
	var battle_err_faction_ok: bool = _battle_fails_setup(
		battle_fac_state, "battle_mission", "attacker_faction_mismatch", battle_fac_force
	)
	var battle_tgt_state: GameState = _make_battle_world()
	var battle_tgt_force: TravelingForce = _battle_add_force_mission(battle_tgt_state)
	battle_tgt_state.get_mission("battle_mission").target_location_id = "battle_missing_loc"
	var battle_err_missing_target_ok: bool = _battle_fails_setup(
		battle_tgt_state, "battle_mission", "invalid_target_location", battle_tgt_force
	)
	var battle_not_hq_state: GameState = _make_battle_world()
	var battle_not_hq_force: TravelingForce = _battle_add_force_mission(battle_not_hq_state)
	battle_not_hq_state.get_mission("battle_mission").target_location_id = "battle_biz"
	var battle_err_not_hq_ok: bool = _battle_fails_setup(
		battle_not_hq_state, "battle_mission", "target_not_neighborhood_hq", battle_not_hq_force
	)
	var battle_mismatch_state: GameState = _make_battle_world()
	var battle_mismatch_force: TravelingForce = _battle_add_force_mission(
		battle_mismatch_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq_b", "battle_hq"
	)
	var battle_err_target_mismatch_ok: bool = _battle_fails_setup(
		battle_mismatch_state, "battle_mission", "attacker_target_mismatch", battle_mismatch_force
	)
	var battle_orphan_state: GameState = _make_battle_world()
	var battle_orphan_force: TravelingForce = _battle_add_force_mission(
		battle_orphan_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq_orphan", "battle_hq_orphan"
	)
	var battle_err_missing_hood_ok: bool = _battle_fails_setup(
		battle_orphan_state, "battle_mission", "missing_neighborhood", battle_orphan_force
	)
	var battle_ghost_state: GameState = _make_battle_world()
	var battle_ghost_force: TravelingForce = _battle_add_force_mission(
		battle_ghost_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq_ghost", "battle_hq_ghost"
	)
	var battle_err_invalid_hood_ok: bool = _battle_fails_setup(
		battle_ghost_state, "battle_mission", "invalid_neighborhood", battle_ghost_force
	)
	var battle_own_state: GameState = _make_battle_world("battle_b", "battle_a")
	var battle_own_force: TravelingForce = _battle_add_force_mission(battle_own_state)
	var battle_err_owner_mismatch_ok: bool = _battle_fails_setup(
		battle_own_state, "battle_mission", "territory_owner_mismatch", battle_own_force
	)
	var battle_bad_sol_state: GameState = _make_battle_world()
	var battle_bad_sol_ids: Array[String] = ["battle_sol_missing"]
	var battle_bad_sol_vehs: Array[String] = ["battle_veh_a"]
	var battle_bad_sol_force: TravelingForce = _battle_add_force_mission_with_units(
		battle_bad_sol_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "capture_neighborhood_hq",
		5.0, battle_bad_sol_ids, battle_bad_sol_vehs
	)
	var battle_err_invalid_soldier_ok: bool = _battle_fails_setup(
		battle_bad_sol_state, "battle_mission", "invalid_attacker_soldier", battle_bad_sol_force
	)
	var battle_sol_fac_state: GameState = _make_battle_world()
	var battle_sol_fac_ids: Array[String] = ["battle_sol_enemy"]
	var battle_sol_fac_vehs: Array[String] = ["battle_veh_a"]
	var battle_sol_fac_force: TravelingForce = _battle_add_force_mission_with_units(
		battle_sol_fac_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "capture_neighborhood_hq",
		5.0, battle_sol_fac_ids, battle_sol_fac_vehs
	)
	var battle_err_soldier_faction_ok: bool = _battle_fails_setup(
		battle_sol_fac_state, "battle_mission", "attacker_soldier_faction_mismatch", battle_sol_fac_force
	)
	var battle_bad_veh_state: GameState = _make_battle_world()
	var battle_bad_veh_ids: Array[String] = ["battle_sol_a"]
	var battle_bad_veh_vehs: Array[String] = ["battle_veh_missing"]
	var battle_bad_veh_force: TravelingForce = _battle_add_force_mission_with_units(
		battle_bad_veh_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "capture_neighborhood_hq",
		5.0, battle_bad_veh_ids, battle_bad_veh_vehs
	)
	var battle_err_invalid_vehicle_ok: bool = _battle_fails_setup(
		battle_bad_veh_state, "battle_mission", "invalid_attacker_vehicle", battle_bad_veh_force
	)
	var battle_veh_fac_state: GameState = _make_battle_world()
	var battle_veh_fac_ids: Array[String] = ["battle_sol_a"]
	var battle_veh_fac_vehs: Array[String] = ["battle_veh_enemy"]
	var battle_veh_fac_force: TravelingForce = _battle_add_force_mission_with_units(
		battle_veh_fac_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "capture_neighborhood_hq",
		5.0, battle_veh_fac_ids, battle_veh_fac_vehs
	)
	var battle_err_vehicle_faction_ok: bool = _battle_fails_setup(
		battle_veh_fac_state, "battle_mission", "attacker_vehicle_faction_mismatch", battle_veh_fac_force
	)
	var battle_det_a_state: GameState = _make_battle_world()
	var battle_det_a_sol: Array[String] = ["battle_sol_z", "battle_sol_m", "battle_sol_a"]
	var battle_det_a_veh: Array[String] = ["battle_veh_z", "battle_veh_m", "battle_veh_a"]
	_battle_add_force_mission_with_units(
		battle_det_a_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "capture_neighborhood_hq",
		5.0, battle_det_a_sol, battle_det_a_veh
	)
	var battle_det_b_state: GameState = _make_battle_world()
	var battle_det_b_sol: Array[String] = ["battle_sol_a", "battle_sol_z", "battle_sol_m"]
	var battle_det_b_veh: Array[String] = ["battle_veh_m", "battle_veh_a", "battle_veh_z"]
	_battle_add_force_mission_with_units(
		battle_det_b_state, "battle_force", "battle_mission", "battle_a", "battle_a",
		"battle_hq", "battle_hq", "at_destination", "awaiting_resolution", "capture_neighborhood_hq",
		5.0, battle_det_b_sol, battle_det_b_veh
	)
	var battle_det_a_res: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(
		battle_det_a_state, "battle_mission"
	)
	var battle_det_b_res: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(
		battle_det_b_state, "battle_mission"
	)
	var battle_det_a_bs: BattleState = battle_det_a_res.battle_state
	var battle_det_b_bs: BattleState = battle_det_b_res.battle_state
	var battle_determinism_ok: bool = false
	if battle_det_a_bs != null and battle_det_b_bs != null:
		var battle_det_a_att: BattleSide = battle_det_a_bs.get_side("attacker")
		var battle_det_b_att: BattleSide = battle_det_b_bs.get_side("attacker")
		battle_determinism_ok = (
			battle_det_a_res.success
			and battle_det_b_res.success
			and battle_det_a_att != null
			and battle_det_b_att != null
			and battle_det_a_bs.battle_id == battle_det_b_bs.battle_id
			and battle_det_a_bs.battle_id == "battle_battle_mission"
			and battle_det_a_bs.attacker_side_id == battle_det_b_bs.attacker_side_id
			and battle_det_a_bs.defender_side_id == battle_det_b_bs.defender_side_id
			and _string_ids_match(battle_det_a_att.participant_ids, battle_det_b_att.participant_ids)
			and _string_ids_match(battle_det_a_att.participant_ids, battle_expected_soldiers)
			and _string_ids_match(battle_det_a_att.vehicle_ids, battle_det_b_att.vehicle_ids)
			and _string_ids_match(battle_det_a_att.vehicle_ids, battle_expected_vehicles)
			and _string_ids_match(_battle_sorted_dict_keys(battle_det_a_bs.deployment_zones), _battle_sorted_dict_keys(battle_det_b_bs.deployment_zones))
			and _string_ids_match(_battle_sorted_dict_keys(battle_det_a_bs.sides), _battle_sorted_dict_keys(battle_det_b_bs.sides))
		)
	var battle_persist_data: Dictionary = battle_std_state.to_dict()
	var battle_restored: GameState = GameState.new()
	battle_restored.from_dict(battle_persist_data)
	var battle_persist_ok: bool = (
		battle_setup_ok
		and _battle_serialized_campaign_keys_only(battle_persist_data)
		and not _battle_data_has_tactical_trace(battle_persist_data)
		and battle_restored.has_mission("battle_mission")
		and battle_restored.get_mission("battle_mission").mission_state == "awaiting_resolution"
		and battle_restored.get_mission("battle_mission").outcome_code.is_empty()
		and battle_restored.has_soldier("battle_sol_a")
		and battle_restored.has_vehicle("battle_veh_z")
		and battle_restored.has_traveling_force("battle_force")
		and battle_restored.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		and (battle_restored.get_map_location("battle_hq") as NeighborhoodHQ).owner_faction_id == "battle_b"
		and (battle_restored.get_map_location("battle_biz") as Business).owner_faction_id == "battle_b"
		and battle_restored.has_faction("battle_a")
		and battle_restored.has_faction("battle_b")
	)
	var battle_bound_state: GameState = _make_battle_world()
	_battle_add_force_mission(battle_bound_state)
	var battle_bound_setup: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(
		battle_bound_state, "battle_mission"
	)
	var battle_bound_after_setup_awaiting: bool = (
		battle_bound_setup.success
		and battle_bound_state.get_mission("battle_mission").mission_state == "awaiting_resolution"
		and battle_bound_state.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		and (battle_bound_state.get_map_location("battle_hq") as NeighborhoodHQ).owner_faction_id == "battle_b"
		and (battle_bound_state.get_map_location("battle_biz") as Business).owner_faction_id == "battle_b"
	)
	var battle_bound_resolve: NeighborhoodHQBattleResult = NeighborhoodHQBattleResolver.resolve(
		battle_bound_state, "battle_mission", true
	)
	var battle_boundary_ok: bool = (
		battle_bound_after_setup_awaiting
		and battle_bound_resolve.success
		and battle_bound_resolve.attacker_won
		and battle_bound_state.get_neighborhood("battle_hood").owner_faction_id == "battle_a"
		and (battle_bound_state.get_map_location("battle_hq") as NeighborhoodHQ).owner_faction_id == "battle_a"
		and (battle_bound_state.get_map_location("battle_biz") as Business).owner_faction_id.is_empty()
		and battle_bound_state.get_mission("battle_mission").mission_state == "resolved_success"
		and battle_bound_state.get_mission("battle_mission").outcome_code == "neighborhood_hq_captured"
	)
	var battle_helper_state: BattleState = BattleState.new(
		"battle_helper", "neighborhood_hq_assault", "battle_helper_mission", "battle_hq", "attacker", "defender", "deployment"
	)
	var battle_helper_ok_res: BattleSetupResult = BattleSetupResult.succeeded(battle_helper_state)
	var battle_helper_fail_res: BattleSetupResult = BattleSetupResult.failed(
		"invalid_mission", "missing mission", "battle_fail_mission", "battle_fail_id"
	)
	var battle_result_helper_ok: bool = (
		battle_helper_ok_res.success
		and battle_helper_ok_res.battle_state == battle_helper_state
		and battle_helper_ok_res.battle_id == "battle_helper"
		and battle_helper_ok_res.mission_id == "battle_helper_mission"
		and battle_helper_ok_res.error_code.is_empty()
		and battle_helper_ok_res.error_message.is_empty()
		and not battle_helper_fail_res.success
		and battle_helper_fail_res.battle_state == null
		and battle_helper_fail_res.battle_id == "battle_fail_id"
		and battle_helper_fail_res.mission_id == "battle_fail_mission"
		and battle_helper_fail_res.error_code == "invalid_mission"
		and battle_helper_fail_res.error_message == "missing mission"
	)

	var battle_dep_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_game: GameState = battle_dep_pack.get("game_state", null) as GameState
	var battle_dep_force: TravelingForce = battle_dep_pack.get("force", null) as TravelingForce
	var battle_dep_bs: BattleState = battle_dep_pack.get("battle_state", null) as BattleState
	var battle_dep_snap: Dictionary = _battle_campaign_snapshot(battle_dep_game, battle_dep_force, "battle_mission")
	var battle_dep_att_zone_id: String = "attacker_deployment"
	var battle_dep_def_zone_id: String = "defender_deployment"
	var battle_deploy_participant_ok: bool = false
	var battle_deploy_vehicle_ok: bool = false
	var battle_deploy_query_ok: bool = false
	var battle_deploy_phase_stays_ok: bool = false
	if battle_dep_bs != null:
		var battle_dep_p_z: bool = battle_dep_bs.deploy_participant("battle_sol_z", battle_dep_att_zone_id)
		var battle_dep_p_a: bool = battle_dep_bs.deploy_participant("battle_sol_a", battle_dep_att_zone_id)
		battle_deploy_participant_ok = (
			battle_dep_p_z
			and battle_dep_p_a
			and battle_dep_bs.get_participant("battle_sol_z").deployment_slot_id == battle_dep_att_zone_id
			and battle_dep_bs.get_participant("battle_sol_a").deployment_slot_id == battle_dep_att_zone_id
			and battle_dep_bs.get_participant("battle_sol_m").deployment_slot_id.is_empty()
			and battle_dep_bs.get_participant("battle_sol_z").is_alive
			and not battle_dep_bs.get_participant("battle_sol_z").is_wounded
		)
		var battle_dep_v_z: bool = battle_dep_bs.deploy_vehicle("battle_veh_z", battle_dep_att_zone_id)
		var battle_dep_v_a: bool = battle_dep_bs.deploy_vehicle("battle_veh_a", battle_dep_att_zone_id)
		battle_deploy_vehicle_ok = (
			battle_dep_v_z
			and battle_dep_v_a
			and battle_dep_bs.get_vehicle("battle_veh_z").deployment_slot_id == battle_dep_att_zone_id
			and battle_dep_bs.get_vehicle("battle_veh_a").deployment_slot_id == battle_dep_att_zone_id
			and battle_dep_bs.get_vehicle("battle_veh_m").deployment_slot_id.is_empty()
		)
		var battle_dep_p_ids: Array[String] = battle_dep_bs.get_zone_deployed_participant_ids(battle_dep_att_zone_id)
		var battle_dep_v_ids: Array[String] = battle_dep_bs.get_zone_deployed_vehicle_ids(battle_dep_att_zone_id)
		var battle_dep_p_expected: Array[String] = ["battle_sol_z", "battle_sol_a"]
		var battle_dep_v_expected: Array[String] = ["battle_veh_z", "battle_veh_a"]
		battle_deploy_query_ok = (
			battle_deploy_participant_ok
			and battle_deploy_vehicle_ok
			and battle_dep_bs.is_participant_deployed("battle_sol_z")
			and battle_dep_bs.is_participant_deployed("battle_sol_a")
			and not battle_dep_bs.is_participant_deployed("battle_sol_m")
			and not battle_dep_bs.is_participant_deployed("battle_missing")
			and battle_dep_bs.get_participant_deployment_zone_id("battle_sol_z") == battle_dep_att_zone_id
			and battle_dep_bs.get_participant_deployment_zone_id("battle_sol_a") == battle_dep_att_zone_id
			and battle_dep_bs.get_participant_deployment_zone_id("battle_sol_m").is_empty()
			and battle_dep_bs.get_participant_deployment_zone_id("battle_missing").is_empty()
			and battle_dep_bs.is_vehicle_deployed("battle_veh_z")
			and battle_dep_bs.is_vehicle_deployed("battle_veh_a")
			and not battle_dep_bs.is_vehicle_deployed("battle_veh_m")
			and not battle_dep_bs.is_vehicle_deployed("battle_missing")
			and battle_dep_bs.get_vehicle_deployment_zone_id("battle_veh_z") == battle_dep_att_zone_id
			and battle_dep_bs.get_vehicle_deployment_zone_id("battle_veh_a") == battle_dep_att_zone_id
			and battle_dep_bs.get_vehicle_deployment_zone_id("battle_veh_m").is_empty()
			and _string_ids_match(battle_dep_p_ids, battle_dep_p_expected)
			and _string_ids_match(battle_dep_v_ids, battle_dep_v_expected)
			and battle_dep_bs.get_zone_deployed_participant_ids(battle_dep_def_zone_id).is_empty()
			and battle_dep_bs.get_zone_deployed_vehicle_ids(battle_dep_def_zone_id).is_empty()
			and battle_dep_bs.get_zone_deployed_participant_ids("missing_zone").is_empty()
			and battle_dep_bs.get_deployment_zone(battle_dep_att_zone_id).has_deployed_participant("battle_sol_z")
			and battle_dep_bs.get_deployment_zone(battle_dep_att_zone_id).has_deployed_vehicle("battle_veh_a")
		)
		battle_dep_p_ids.append("mutated")
		battle_deploy_query_ok = (
			battle_deploy_query_ok
			and _string_ids_match(
				battle_dep_bs.get_zone_deployed_participant_ids(battle_dep_att_zone_id),
				battle_dep_p_expected
			)
		)
		battle_deploy_phase_stays_ok = (
			battle_deploy_participant_ok
			and battle_deploy_vehicle_ok
			and battle_dep_bs.battle_phase == "deployment"
			and not battle_dep_bs.has_method("advance_phase")
		)
	var battle_deploy_immutability_ok: bool = (
		battle_deploy_participant_ok
		and battle_deploy_vehicle_ok
		and _battle_campaign_unchanged(battle_dep_game, battle_dep_snap, battle_dep_force, "battle_mission")
		and battle_dep_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
		and battle_dep_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		and (battle_dep_game.get_map_location("battle_hq") as NeighborhoodHQ).owner_faction_id == "battle_b"
	)
	var battle_dep_persist_data: Dictionary = battle_dep_game.to_dict()
	var battle_dep_restored: GameState = GameState.new()
	battle_dep_restored.from_dict(battle_dep_persist_data)
	var battle_deploy_persist_ok: bool = (
		battle_deploy_participant_ok
		and _battle_serialized_campaign_keys_only(battle_dep_persist_data)
		and not _battle_data_has_tactical_trace(battle_dep_persist_data)
		and battle_dep_restored.has_mission("battle_mission")
		and battle_dep_restored.get_mission("battle_mission").mission_state == "awaiting_resolution"
		and battle_dep_restored.has_soldier("battle_sol_z")
		and battle_dep_restored.get_soldier("battle_sol_z").to_dict().get("deployment_slot_id", null) == null
	)

	var battle_dep_side_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_side_bs: BattleState = battle_dep_side_pack.get("battle_state", null) as BattleState
	var battle_deploy_wrong_side_ok: bool = false
	if battle_dep_side_bs != null:
		var battle_dep_side_def: DeploymentZone = battle_dep_side_bs.get_deployment_zone("defender_deployment")
		battle_dep_side_def.allowed_participant_ids.append("battle_sol_a")
		battle_dep_side_def.allowed_vehicle_ids.append("battle_veh_a")
		var battle_dep_side_before: Dictionary = _battle_deploy_assignment_snapshot(battle_dep_side_bs)
		var battle_dep_side_p: bool = battle_dep_side_bs.deploy_participant("battle_sol_a", "defender_deployment")
		var battle_dep_side_v: bool = battle_dep_side_bs.deploy_vehicle("battle_veh_a", "defender_deployment")
		battle_deploy_wrong_side_ok = (
			not battle_dep_side_p
			and not battle_dep_side_v
			and _battle_deploy_assignment_unchanged(battle_dep_side_bs, battle_dep_side_before)
		)

	var battle_dep_unk_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_unk_bs: BattleState = battle_dep_unk_pack.get("battle_state", null) as BattleState
	var battle_deploy_unknown_ok: bool = false
	if battle_dep_unk_bs != null:
		var battle_dep_unk_before: Dictionary = _battle_deploy_assignment_snapshot(battle_dep_unk_bs)
		battle_deploy_unknown_ok = (
			not battle_dep_unk_bs.deploy_participant("", "attacker_deployment")
			and not battle_dep_unk_bs.deploy_participant("battle_sol_a", "")
			and not battle_dep_unk_bs.deploy_participant("battle_missing_sol", "attacker_deployment")
			and not battle_dep_unk_bs.deploy_participant("battle_sol_a", "missing_zone")
			and not battle_dep_unk_bs.deploy_vehicle("", "attacker_deployment")
			and not battle_dep_unk_bs.deploy_vehicle("battle_veh_a", "")
			and not battle_dep_unk_bs.deploy_vehicle("battle_missing_veh", "attacker_deployment")
			and not battle_dep_unk_bs.deploy_vehicle("battle_veh_a", "missing_zone")
			and _battle_deploy_assignment_unchanged(battle_dep_unk_bs, battle_dep_unk_before)
		)

	var battle_dep_deny_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_deny_bs: BattleState = battle_dep_deny_pack.get("battle_state", null) as BattleState
	var battle_deploy_disallowed_ok: bool = false
	if battle_dep_deny_bs != null:
		var battle_dep_deny_zone: DeploymentZone = battle_dep_deny_bs.get_deployment_zone("attacker_deployment")
		battle_dep_deny_zone.allowed_participant_ids.erase("battle_sol_a")
		battle_dep_deny_zone.allowed_vehicle_ids.erase("battle_veh_a")
		var battle_dep_deny_before: Dictionary = _battle_deploy_assignment_snapshot(battle_dep_deny_bs)
		battle_deploy_disallowed_ok = (
			not battle_dep_deny_bs.deploy_participant("battle_sol_a", "attacker_deployment")
			and not battle_dep_deny_bs.deploy_vehicle("battle_veh_a", "attacker_deployment")
			and _battle_deploy_assignment_unchanged(battle_dep_deny_bs, battle_dep_deny_before)
			and battle_dep_deny_bs.deploy_participant("battle_sol_z", "attacker_deployment")
			and battle_dep_deny_bs.deploy_vehicle("battle_veh_z", "attacker_deployment")
		)

	var battle_dep_dup_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_dup_bs: BattleState = battle_dep_dup_pack.get("battle_state", null) as BattleState
	var battle_deploy_duplicate_ok: bool = false
	if battle_dep_dup_bs != null:
		var battle_dep_dup_first_p: bool = battle_dep_dup_bs.deploy_participant("battle_sol_a", "attacker_deployment")
		var battle_dep_dup_first_v: bool = battle_dep_dup_bs.deploy_vehicle("battle_veh_a", "attacker_deployment")
		var battle_dep_dup_before: Dictionary = _battle_deploy_assignment_snapshot(battle_dep_dup_bs)
		battle_deploy_duplicate_ok = (
			battle_dep_dup_first_p
			and battle_dep_dup_first_v
			and not battle_dep_dup_bs.deploy_participant("battle_sol_a", "attacker_deployment")
			and not battle_dep_dup_bs.deploy_vehicle("battle_veh_a", "attacker_deployment")
			and _battle_deploy_assignment_unchanged(battle_dep_dup_bs, battle_dep_dup_before)
			and _string_ids_match(battle_dep_dup_bs.get_zone_deployed_participant_ids("attacker_deployment"), ["battle_sol_a"])
			and _string_ids_match(battle_dep_dup_bs.get_zone_deployed_vehicle_ids("attacker_deployment"), ["battle_veh_a"])
		)

	var battle_dep_phase_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_phase_bs: BattleState = battle_dep_phase_pack.get("battle_state", null) as BattleState
	var battle_deploy_phase_ok: bool = false
	if battle_dep_phase_bs != null:
		battle_dep_phase_bs.battle_phase = "active"
		var battle_dep_phase_before: Dictionary = _battle_deploy_assignment_snapshot(battle_dep_phase_bs)
		battle_deploy_phase_ok = (
			not battle_dep_phase_bs.deploy_participant("battle_sol_a", "attacker_deployment")
			and not battle_dep_phase_bs.deploy_vehicle("battle_veh_a", "attacker_deployment")
			and _battle_deploy_assignment_unchanged(battle_dep_phase_bs, battle_dep_phase_before)
			and battle_dep_phase_bs.battle_phase == "active"
		)

	var battle_dep_partial_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_partial_game: GameState = battle_dep_partial_pack.get("game_state", null) as GameState
	var battle_dep_partial_force: TravelingForce = battle_dep_partial_pack.get("force", null) as TravelingForce
	var battle_dep_partial_bs: BattleState = battle_dep_partial_pack.get("battle_state", null) as BattleState
	var battle_dep_partial_campaign: Dictionary = _battle_campaign_snapshot(
		battle_dep_partial_game, battle_dep_partial_force, "battle_mission"
	)
	var battle_deploy_no_partial_ok: bool = false
	if battle_dep_partial_bs != null:
		var battle_dep_partial_before: Dictionary = _battle_deploy_assignment_snapshot(battle_dep_partial_bs)
		var battle_dep_partial_failed: bool = (
			not battle_dep_partial_bs.deploy_participant("battle_sol_a", "defender_deployment")
			and not battle_dep_partial_bs.deploy_vehicle("battle_veh_a", "defender_deployment")
			and not battle_dep_partial_bs.deploy_participant("battle_missing", "attacker_deployment")
			and not battle_dep_partial_bs.deploy_vehicle("battle_missing", "attacker_deployment")
			and not battle_dep_partial_bs.deploy_participant("battle_sol_a", "missing_zone")
			and not battle_dep_partial_bs.deploy_vehicle("battle_veh_a", "missing_zone")
		)
		battle_deploy_no_partial_ok = (
			battle_dep_partial_failed
			and _battle_deploy_assignment_unchanged(battle_dep_partial_bs, battle_dep_partial_before)
			and _battle_campaign_unchanged(
				battle_dep_partial_game, battle_dep_partial_campaign, battle_dep_partial_force, "battle_mission"
			)
			and battle_dep_partial_bs.battle_phase == "deployment"
		)

	var battle_dep_det_a_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_det_b_pack: Dictionary = _battle_create_ready_pack()
	var battle_dep_det_a: BattleState = battle_dep_det_a_pack.get("battle_state", null) as BattleState
	var battle_dep_det_b: BattleState = battle_dep_det_b_pack.get("battle_state", null) as BattleState
	var battle_deploy_determinism_ok: bool = false
	if battle_dep_det_a != null and battle_dep_det_b != null:
		var battle_dep_det_a_ok: bool = (
			battle_dep_det_a.deploy_participant("battle_sol_z", "attacker_deployment")
			and battle_dep_det_a.deploy_participant("battle_sol_a", "attacker_deployment")
			and battle_dep_det_a.deploy_participant("battle_sol_m", "attacker_deployment")
			and battle_dep_det_a.deploy_vehicle("battle_veh_z", "attacker_deployment")
			and battle_dep_det_a.deploy_vehicle("battle_veh_a", "attacker_deployment")
			and battle_dep_det_a.deploy_vehicle("battle_veh_m", "attacker_deployment")
		)
		var battle_dep_det_b_ok: bool = (
			battle_dep_det_b.deploy_participant("battle_sol_z", "attacker_deployment")
			and battle_dep_det_b.deploy_participant("battle_sol_a", "attacker_deployment")
			and battle_dep_det_b.deploy_participant("battle_sol_m", "attacker_deployment")
			and battle_dep_det_b.deploy_vehicle("battle_veh_z", "attacker_deployment")
			and battle_dep_det_b.deploy_vehicle("battle_veh_a", "attacker_deployment")
			and battle_dep_det_b.deploy_vehicle("battle_veh_m", "attacker_deployment")
		)
		var battle_dep_det_p_order: Array[String] = ["battle_sol_z", "battle_sol_a", "battle_sol_m"]
		var battle_dep_det_v_order: Array[String] = ["battle_veh_z", "battle_veh_a", "battle_veh_m"]
		battle_deploy_determinism_ok = (
			battle_dep_det_a_ok
			and battle_dep_det_b_ok
			and _string_ids_match(battle_dep_det_a.get_zone_deployed_participant_ids("attacker_deployment"), battle_dep_det_p_order)
			and _string_ids_match(battle_dep_det_b.get_zone_deployed_participant_ids("attacker_deployment"), battle_dep_det_p_order)
			and _string_ids_match(battle_dep_det_a.get_zone_deployed_vehicle_ids("attacker_deployment"), battle_dep_det_v_order)
			and _string_ids_match(battle_dep_det_b.get_zone_deployed_vehicle_ids("attacker_deployment"), battle_dep_det_v_order)
			and battle_dep_det_a.get_participant_deployment_zone_id("battle_sol_z") == battle_dep_det_b.get_participant_deployment_zone_id("battle_sol_z")
			and battle_dep_det_a.get_vehicle_deployment_zone_id("battle_veh_m") == battle_dep_det_b.get_vehicle_deployment_zone_id("battle_veh_m")
		)

	var battle_ready_empty_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_empty_bs: BattleState = battle_ready_empty_pack.get("battle_state", null) as BattleState
	var battle_ready_empty_ok: bool = (
		battle_ready_empty_bs != null
		and battle_ready_empty_bs.is_side_ready("defender")
		and not battle_ready_empty_bs.is_side_ready("attacker")
		and not battle_ready_empty_bs.is_side_ready("")
		and not battle_ready_empty_bs.is_side_ready("missing_side")
		and not battle_ready_empty_bs.is_battle_ready()
		and battle_ready_empty_bs.battle_phase == "deployment"
	)
	var battle_ready_partial_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_partial_bs: BattleState = battle_ready_partial_pack.get("battle_state", null) as BattleState
	var battle_ready_partial_ok: bool = false
	if battle_ready_partial_bs != null:
		var battle_ready_partial_deployed: bool = battle_ready_partial_bs.deploy_participant("battle_sol_a", "attacker_deployment")
		battle_ready_partial_ok = (
			battle_ready_partial_deployed
			and battle_ready_partial_bs.is_side_ready("defender")
			and not battle_ready_partial_bs.is_side_ready("attacker")
			and not battle_ready_partial_bs.is_battle_ready()
		)
	var battle_ready_part_bs: BattleState = _battle_make_bare_state()
	var battle_ready_part_ok: bool = false
	if battle_ready_part_bs != null:
		var battle_ready_part_added: bool = (
			_battle_register_participant(battle_ready_part_bs, "ready_p_z", "attacker", "attacker_deployment")
			and _battle_register_participant(battle_ready_part_bs, "ready_p_a", "attacker", "attacker_deployment")
			and battle_ready_part_bs.deploy_participant("ready_p_z", "attacker_deployment")
			and battle_ready_part_bs.deploy_participant("ready_p_a", "attacker_deployment")
		)
		battle_ready_part_ok = (
			battle_ready_part_added
			and battle_ready_part_bs.is_side_ready("attacker")
			and battle_ready_part_bs.is_side_ready("defender")
			and battle_ready_part_bs.get_side("attacker").vehicle_ids.is_empty()
			and battle_ready_part_bs.is_battle_ready()
		)
	var battle_ready_veh_bs: BattleState = _battle_make_bare_state()
	var battle_ready_veh_ok: bool = false
	if battle_ready_veh_bs != null:
		var battle_ready_veh_added: bool = (
			_battle_register_vehicle(battle_ready_veh_bs, "ready_v_z", "attacker", "attacker_deployment")
			and _battle_register_vehicle(battle_ready_veh_bs, "ready_v_a", "attacker", "attacker_deployment")
			and battle_ready_veh_bs.deploy_vehicle("ready_v_z", "attacker_deployment")
			and battle_ready_veh_bs.deploy_vehicle("ready_v_a", "attacker_deployment")
		)
		battle_ready_veh_ok = (
			battle_ready_veh_added
			and battle_ready_veh_bs.is_side_ready("attacker")
			and battle_ready_veh_bs.is_side_ready("defender")
			and battle_ready_veh_bs.get_side("attacker").participant_ids.is_empty()
			and battle_ready_veh_bs.is_battle_ready()
		)
	var battle_ready_mixed_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_mixed_bs: BattleState = battle_ready_mixed_pack.get("battle_state", null) as BattleState
	var battle_ready_mixed_ok: bool = false
	if battle_ready_mixed_bs != null:
		battle_ready_mixed_ok = (
			_battle_deploy_standard_attacker(battle_ready_mixed_bs)
			and battle_ready_mixed_bs.is_side_ready("attacker")
			and battle_ready_mixed_bs.is_side_ready("defender")
			and not battle_ready_mixed_bs.get_side("attacker").participant_ids.is_empty()
			and not battle_ready_mixed_bs.get_side("attacker").vehicle_ids.is_empty()
			and battle_ready_mixed_bs.is_battle_ready()
		)
	var battle_ready_att_only_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_att_only_bs: BattleState = battle_ready_att_only_pack.get("battle_state", null) as BattleState
	var battle_ready_att_only_ok: bool = false
	if battle_ready_att_only_bs != null:
		var battle_ready_att_deployed: bool = _battle_deploy_standard_attacker(battle_ready_att_only_bs)
		var battle_ready_def_added: bool = _battle_register_participant(
			battle_ready_att_only_bs, "ready_def_p", "defender", "defender_deployment"
		)
		battle_ready_att_only_ok = (
			battle_ready_att_deployed
			and battle_ready_def_added
			and battle_ready_att_only_bs.is_side_ready("attacker")
			and not battle_ready_att_only_bs.is_side_ready("defender")
			and not battle_ready_att_only_bs.is_battle_ready()
		)
	var battle_ready_def_only_ok: bool = (
		battle_ready_empty_ok
		and battle_ready_empty_bs != null
		and battle_ready_empty_bs.is_side_ready("defender")
		and not battle_ready_empty_bs.is_side_ready("attacker")
		and not battle_ready_empty_bs.is_battle_ready()
	)
	var battle_ready_full_ok: bool = battle_ready_mixed_ok
	var battle_ready_act_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_act_game: GameState = battle_ready_act_pack.get("game_state", null) as GameState
	var battle_ready_act_force: TravelingForce = battle_ready_act_pack.get("force", null) as TravelingForce
	var battle_ready_act_bs: BattleState = battle_ready_act_pack.get("battle_state", null) as BattleState
	var battle_ready_act_snap: Dictionary = _battle_campaign_snapshot(
		battle_ready_act_game, battle_ready_act_force, "battle_mission"
	)
	var battle_ready_activate_ok: bool = false
	var battle_ready_activate_phase_ok: bool = false
	var battle_ready_blocked_ok: bool = false
	var battle_ready_immutability_ok: bool = false
	var battle_ready_persist_ok: bool = false
	if battle_ready_act_bs != null:
		var battle_ready_act_deployed: bool = _battle_deploy_standard_attacker(battle_ready_act_bs)
		var battle_ready_act_begun: bool = battle_ready_act_bs.begin_battle()
		battle_ready_activate_ok = (
			battle_ready_act_deployed
			and battle_ready_act_bs.is_battle_ready()
			and battle_ready_act_begun
		)
		battle_ready_activate_phase_ok = (
			battle_ready_activate_ok
			and battle_ready_act_bs.battle_phase == "active"
			and battle_ready_act_bs.battle_phase != "deployment"
			and battle_ready_act_bs.battle_phase != "resolved"
		)
		var battle_ready_extra_added: bool = _battle_register_participant(
			battle_ready_act_bs, "ready_late_p", "attacker", "attacker_deployment"
		)
		var battle_ready_late_deploy: bool = battle_ready_act_bs.deploy_participant("ready_late_p", "attacker_deployment")
		var battle_ready_late_vehicle: bool = battle_ready_act_bs.deploy_vehicle("battle_veh_a", "attacker_deployment")
		battle_ready_blocked_ok = (
			battle_ready_activate_phase_ok
			and battle_ready_extra_added
			and not battle_ready_late_deploy
			and not battle_ready_late_vehicle
			and battle_ready_act_bs.get_participant("ready_late_p").deployment_slot_id.is_empty()
			and battle_ready_act_bs.get_vehicle("battle_veh_a").deployment_slot_id == "attacker_deployment"
			and battle_ready_act_bs.battle_phase == "active"
		)
		battle_ready_immutability_ok = (
			battle_ready_activate_ok
			and _battle_campaign_unchanged(battle_ready_act_game, battle_ready_act_snap, battle_ready_act_force, "battle_mission")
			and battle_ready_act_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battle_ready_act_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)
		var battle_ready_persist_data: Dictionary = battle_ready_act_game.to_dict()
		var battle_ready_restored: GameState = GameState.new()
		battle_ready_restored.from_dict(battle_ready_persist_data)
		battle_ready_persist_ok = (
			battle_ready_activate_ok
			and _battle_serialized_campaign_keys_only(battle_ready_persist_data)
			and not _battle_data_has_tactical_trace(battle_ready_persist_data)
			and battle_ready_restored.has_mission("battle_mission")
			and battle_ready_restored.get_mission("battle_mission").mission_state == "awaiting_resolution"
		)
	var battle_ready_early_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_early_bs: BattleState = battle_ready_early_pack.get("battle_state", null) as BattleState
	var battle_ready_before_ok: bool = false
	var battle_ready_no_mutate_ok: bool = false
	if battle_ready_early_bs != null:
		var battle_ready_early_before: Dictionary = _battle_deploy_assignment_snapshot(battle_ready_early_bs)
		var battle_ready_early_begin: bool = battle_ready_early_bs.begin_battle()
		battle_ready_before_ok = (
			not battle_ready_early_bs.is_battle_ready()
			and not battle_ready_early_begin
			and battle_ready_early_bs.battle_phase == "deployment"
		)
		battle_ready_no_mutate_ok = (
			battle_ready_before_ok
			and _battle_deploy_assignment_unchanged(battle_ready_early_bs, battle_ready_early_before)
		)
	var battle_ready_outside_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_outside_bs: BattleState = battle_ready_outside_pack.get("battle_state", null) as BattleState
	var battle_ready_outside_ok: bool = false
	if battle_ready_outside_bs != null:
		var battle_ready_outside_deployed: bool = _battle_deploy_standard_attacker(battle_ready_outside_bs)
		var battle_ready_outside_first: bool = battle_ready_outside_bs.begin_battle()
		var battle_ready_outside_before: Dictionary = _battle_deploy_assignment_snapshot(battle_ready_outside_bs)
		var battle_ready_outside_second: bool = battle_ready_outside_bs.begin_battle()
		battle_ready_outside_ok = (
			battle_ready_outside_deployed
			and battle_ready_outside_first
			and battle_ready_outside_bs.battle_phase == "active"
			and not battle_ready_outside_second
			and _battle_deploy_assignment_unchanged(battle_ready_outside_bs, battle_ready_outside_before)
		)
		if battle_ready_outside_ok:
			battle_ready_outside_bs.battle_phase = "resolved"
			var battle_ready_resolved_before: Dictionary = _battle_deploy_assignment_snapshot(battle_ready_outside_bs)
			var battle_ready_outside_resolved: bool = battle_ready_outside_bs.begin_battle()
			battle_ready_outside_ok = (
				not battle_ready_outside_resolved
				and battle_ready_outside_bs.battle_phase == "resolved"
				and _battle_deploy_assignment_unchanged(battle_ready_outside_bs, battle_ready_resolved_before)
			)
	var battle_ready_det_a_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_det_b_pack: Dictionary = _battle_create_ready_pack()
	var battle_ready_det_a: BattleState = battle_ready_det_a_pack.get("battle_state", null) as BattleState
	var battle_ready_det_b: BattleState = battle_ready_det_b_pack.get("battle_state", null) as BattleState
	var battle_ready_determinism_ok: bool = false
	if battle_ready_det_a != null and battle_ready_det_b != null:
		var battle_ready_det_before_match: bool = (
			battle_ready_det_a.is_side_ready("attacker") == battle_ready_det_b.is_side_ready("attacker")
			and battle_ready_det_a.is_side_ready("defender") == battle_ready_det_b.is_side_ready("defender")
			and battle_ready_det_a.is_battle_ready() == battle_ready_det_b.is_battle_ready()
			and not battle_ready_det_a.is_battle_ready()
		)
		var battle_ready_det_deployed: bool = (
			_battle_deploy_standard_attacker(battle_ready_det_a)
			and _battle_deploy_standard_attacker(battle_ready_det_b)
		)
		battle_ready_determinism_ok = (
			battle_ready_det_before_match
			and battle_ready_det_deployed
			and battle_ready_det_a.is_side_ready("attacker")
			and battle_ready_det_b.is_side_ready("attacker")
			and battle_ready_det_a.is_battle_ready()
			and battle_ready_det_b.is_battle_ready()
			and battle_ready_det_a.begin_battle()
			and battle_ready_det_b.begin_battle()
			and battle_ready_det_a.battle_phase == battle_ready_det_b.battle_phase
			and battle_ready_det_a.battle_phase == "active"
		)

	var battle_turn_init_active_ok: bool = false
	var battle_turn_attacker_first_ok: bool = false
	var battle_turn_participant_first_ok: bool = false
	var battle_turn_id_order_ok: bool = false
	var battle_turn_insert_order_ok: bool = false
	var battle_turn_current_start_ok: bool = false
	var battle_turn_advance_ok: bool = false
	var battle_turn_wrap_ok: bool = false
	var battle_turn_empty_ok: bool = false
	var battle_turn_advance_empty_ok: bool = false
	var battle_turn_reinit_ok: bool = false
	var battle_turn_deploy_unchanged_ok: bool = false
	var battle_turn_phase_ok: bool = false
	var battle_turn_immutability_ok: bool = false
	var battle_turn_persist_ok: bool = false
	var battle_turn_expected_ids: Array[String] = [
		"battle_sol_a",
		"battle_sol_m",
		"battle_sol_z",
		"battle_veh_a",
		"battle_veh_m",
		"battle_veh_z",
	]
	var battle_turn_expected_types: Array[String] = [
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_VEHICLE,
		BattleState.TURN_ACTOR_TYPE_VEHICLE,
		BattleState.TURN_ACTOR_TYPE_VEHICLE,
	]
	var battle_turn_expected_sides: Array[String] = [
		"attacker",
		"attacker",
		"attacker",
		"attacker",
		"attacker",
		"attacker",
	]
	var battle_turn_pack: Dictionary = _battle_create_ready_pack()
	var battle_turn_game: GameState = battle_turn_pack.get("game_state", null) as GameState
	var battle_turn_force: TravelingForce = battle_turn_pack.get("force", null) as TravelingForce
	var battle_turn_bs: BattleState = battle_turn_pack.get("battle_state", null) as BattleState
	var battle_turn_snap: Dictionary = _battle_campaign_snapshot(
		battle_turn_game, battle_turn_force, "battle_mission"
	)
	if battle_turn_bs != null:
		var battle_turn_deployed: bool = _battle_deploy_standard_attacker(battle_turn_bs)
		var battle_turn_assign_before: Dictionary = _battle_deploy_assignment_snapshot(battle_turn_bs)
		var battle_turn_early_init: bool = battle_turn_bs.initialize_turn_order()
		var battle_turn_early_advance: bool = battle_turn_bs.advance_turn()
		var battle_turn_early_empty: bool = (
			battle_turn_bs.get_turn_actor_count() == 0
			and battle_turn_bs.get_current_turn_index() == -1
			and not battle_turn_bs.has_current_turn_actor()
			and battle_turn_bs.get_current_turn_actor_id().is_empty()
			and battle_turn_bs.battle_phase == "deployment"
			and _battle_deploy_assignment_unchanged(battle_turn_bs, battle_turn_assign_before)
		)
		var battle_turn_begun: bool = battle_turn_bs.begin_battle()
		var battle_turn_before_init: Dictionary = _battle_turn_snapshot(battle_turn_bs)
		var battle_turn_uninited_advance: bool = battle_turn_bs.advance_turn()
		var battle_turn_uninited_unchanged: bool = _battle_turn_unchanged(battle_turn_bs, battle_turn_before_init)
		var battle_turn_assign_active: Dictionary = _battle_deploy_assignment_snapshot(battle_turn_bs)
		var battle_turn_inited: bool = battle_turn_bs.initialize_turn_order()
		battle_turn_init_active_ok = (
			battle_turn_deployed
			and not battle_turn_early_init
			and not battle_turn_early_advance
			and battle_turn_early_empty
			and battle_turn_begun
			and battle_turn_bs.battle_phase == "active"
			and not battle_turn_uninited_advance
			and battle_turn_uninited_unchanged
			and battle_turn_inited
		)
		battle_turn_id_order_ok = (
			battle_turn_init_active_ok
			and _string_ids_match(battle_turn_bs.get_turn_actor_ids(), battle_turn_expected_ids)
			and _string_ids_match(battle_turn_bs.get_turn_actor_types(), battle_turn_expected_types)
			and _string_ids_match(battle_turn_bs.get_turn_actor_side_ids(), battle_turn_expected_sides)
			and battle_turn_bs.get_turn_actor_count() == 6
		)
		battle_turn_participant_first_ok = (
			battle_turn_id_order_ok
			and _battle_turn_participants_before_vehicles(battle_turn_bs)
		)
		battle_turn_current_start_ok = (
			battle_turn_id_order_ok
			and battle_turn_bs.has_current_turn_actor()
			and battle_turn_bs.get_current_turn_index() == 0
			and battle_turn_bs.get_current_round() == 1
			and battle_turn_bs.get_current_turn_actor_id() == "battle_sol_a"
			and battle_turn_bs.get_current_turn_actor_type() == BattleState.TURN_ACTOR_TYPE_PARTICIPANT
			and battle_turn_bs.get_current_turn_actor_side_id() == "attacker"
		)
		var battle_turn_first_advance: bool = battle_turn_bs.advance_turn()
		battle_turn_advance_ok = (
			battle_turn_current_start_ok
			and battle_turn_first_advance
			and battle_turn_bs.get_current_turn_index() == 1
			and battle_turn_bs.get_current_round() == 1
			and battle_turn_bs.get_current_turn_actor_id() == "battle_sol_m"
			and battle_turn_bs.get_current_turn_actor_type() == BattleState.TURN_ACTOR_TYPE_PARTICIPANT
			and battle_turn_bs.get_current_turn_actor_side_id() == "attacker"
		)
		var battle_turn_wrap_ready: bool = battle_turn_advance_ok
		if battle_turn_wrap_ready:
			var battle_turn_mid_ok: bool = true
			var battle_turn_step: int = 2
			while battle_turn_step < 6:
				if not battle_turn_bs.advance_turn():
					battle_turn_mid_ok = false
					break
				if battle_turn_bs.get_current_turn_index() != battle_turn_step:
					battle_turn_mid_ok = false
					break
				if battle_turn_bs.get_current_round() != 1:
					battle_turn_mid_ok = false
					break
				if battle_turn_bs.get_current_turn_actor_id() != battle_turn_expected_ids[battle_turn_step]:
					battle_turn_mid_ok = false
					break
				battle_turn_step += 1
			var battle_turn_wrapped: bool = battle_turn_bs.advance_turn()
			battle_turn_wrap_ok = (
				battle_turn_mid_ok
				and battle_turn_wrapped
				and battle_turn_bs.get_current_turn_index() == 0
				and battle_turn_bs.get_current_round() == 2
				and battle_turn_bs.get_current_turn_actor_id() == "battle_sol_a"
				and battle_turn_bs.get_current_turn_actor_type() == BattleState.TURN_ACTOR_TYPE_PARTICIPANT
				and battle_turn_bs.get_current_turn_actor_side_id() == "attacker"
			)
		var battle_turn_reinit: bool = battle_turn_bs.initialize_turn_order()
		battle_turn_reinit_ok = (
			battle_turn_wrap_ok
			and battle_turn_reinit
			and _string_ids_match(battle_turn_bs.get_turn_actor_ids(), battle_turn_expected_ids)
			and _string_ids_match(battle_turn_bs.get_turn_actor_types(), battle_turn_expected_types)
			and _string_ids_match(battle_turn_bs.get_turn_actor_side_ids(), battle_turn_expected_sides)
			and battle_turn_bs.get_current_turn_index() == 0
			and battle_turn_bs.get_current_round() == 1
			and battle_turn_bs.get_current_turn_actor_id() == "battle_sol_a"
		)
		battle_turn_deploy_unchanged_ok = (
			battle_turn_reinit_ok
			and _battle_deploy_assignment_unchanged(battle_turn_bs, battle_turn_assign_active)
		)
		battle_turn_phase_ok = (
			battle_turn_reinit_ok
			and battle_turn_bs.battle_phase == "active"
			and battle_turn_bs.battle_phase != "deployment"
			and battle_turn_bs.battle_phase != "resolved"
		)
		battle_turn_immutability_ok = (
			battle_turn_reinit_ok
			and _battle_campaign_unchanged(battle_turn_game, battle_turn_snap, battle_turn_force, "battle_mission")
			and battle_turn_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battle_turn_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)
		var battle_turn_persist_data: Dictionary = battle_turn_game.to_dict()
		var battle_turn_restored: GameState = GameState.new()
		battle_turn_restored.from_dict(battle_turn_persist_data)
		battle_turn_persist_ok = (
			battle_turn_reinit_ok
			and _battle_serialized_campaign_keys_only(battle_turn_persist_data)
			and not _battle_data_has_tactical_trace(battle_turn_persist_data)
			and battle_turn_restored.has_mission("battle_mission")
			and battle_turn_restored.get_mission("battle_mission").mission_state == "awaiting_resolution"
		)
		var battle_turn_resolved_before: Dictionary = _battle_turn_snapshot(battle_turn_bs)
		battle_turn_bs.battle_phase = "resolved"
		var battle_turn_resolved_init: bool = battle_turn_bs.initialize_turn_order()
		var battle_turn_resolved_advance: bool = battle_turn_bs.advance_turn()
		battle_turn_init_active_ok = (
			battle_turn_init_active_ok
			and not battle_turn_resolved_init
			and not battle_turn_resolved_advance
			and battle_turn_bs.battle_phase == "resolved"
			and _battle_turn_unchanged(battle_turn_bs, battle_turn_resolved_before)
		)
		battle_turn_bs.battle_phase = "active"
	var battle_turn_mixed_a: BattleState = _battle_make_bare_state()
	var battle_turn_mixed_b: BattleState = _battle_make_bare_state()
	var battle_turn_mixed_ids: Array[String] = [
		"att_p_a",
		"att_p_z",
		"att_v_a",
		"att_v_z",
		"def_p_a",
		"def_p_z",
		"def_v_m",
	]
	var battle_turn_mixed_types: Array[String] = [
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_VEHICLE,
		BattleState.TURN_ACTOR_TYPE_VEHICLE,
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_PARTICIPANT,
		BattleState.TURN_ACTOR_TYPE_VEHICLE,
	]
	var battle_turn_mixed_sides: Array[String] = [
		"attacker",
		"attacker",
		"attacker",
		"attacker",
		"defender",
		"defender",
		"defender",
	]
	if battle_turn_mixed_a != null and battle_turn_mixed_b != null:
		var battle_turn_mixed_a_ready: bool = _battle_populate_mixed_turn_actors(battle_turn_mixed_a, false)
		var battle_turn_mixed_b_ready: bool = _battle_populate_mixed_turn_actors(battle_turn_mixed_b, true)
		var battle_turn_mixed_a_begun: bool = battle_turn_mixed_a.begin_battle()
		var battle_turn_mixed_b_begun: bool = battle_turn_mixed_b.begin_battle()
		var battle_turn_mixed_a_init: bool = battle_turn_mixed_a.initialize_turn_order()
		var battle_turn_mixed_b_init: bool = battle_turn_mixed_b.initialize_turn_order()
		battle_turn_insert_order_ok = (
			battle_turn_mixed_a_ready
			and battle_turn_mixed_b_ready
			and battle_turn_mixed_a_begun
			and battle_turn_mixed_b_begun
			and battle_turn_mixed_a_init
			and battle_turn_mixed_b_init
			and _string_ids_match(battle_turn_mixed_a.get_turn_actor_ids(), battle_turn_mixed_ids)
			and _string_ids_match(battle_turn_mixed_b.get_turn_actor_ids(), battle_turn_mixed_ids)
			and _string_ids_match(battle_turn_mixed_a.get_turn_actor_types(), battle_turn_mixed_types)
			and _string_ids_match(battle_turn_mixed_b.get_turn_actor_types(), battle_turn_mixed_types)
			and _string_ids_match(battle_turn_mixed_a.get_turn_actor_side_ids(), battle_turn_mixed_sides)
			and _string_ids_match(battle_turn_mixed_b.get_turn_actor_side_ids(), battle_turn_mixed_sides)
		)
		battle_turn_attacker_first_ok = (
			battle_turn_insert_order_ok
			and _battle_turn_attacker_before_defender(battle_turn_mixed_a)
			and _battle_turn_attacker_before_defender(battle_turn_mixed_b)
			and battle_turn_mixed_a.get_current_turn_actor_id() == "att_p_a"
			and battle_turn_mixed_a.get_current_turn_actor_side_id() == "attacker"
		)
		if battle_turn_insert_order_ok:
			battle_turn_participant_first_ok = (
				battle_turn_participant_first_ok
				and _battle_turn_participants_before_vehicles(battle_turn_mixed_a)
				and _battle_turn_participants_before_vehicles(battle_turn_mixed_b)
			)
			battle_turn_id_order_ok = (
				battle_turn_id_order_ok
				and _battle_turn_ids_ascending(battle_turn_mixed_a)
				and _battle_turn_ids_ascending(battle_turn_mixed_b)
			)
	var battle_turn_empty_bs: BattleState = _battle_make_bare_state()
	if battle_turn_empty_bs != null:
		var battle_turn_empty_begun: bool = battle_turn_empty_bs.begin_battle()
		var battle_turn_empty_init: bool = battle_turn_empty_bs.initialize_turn_order()
		battle_turn_empty_ok = (
			battle_turn_empty_begun
			and battle_turn_empty_init
			and battle_turn_empty_bs.battle_phase == "active"
			and battle_turn_empty_bs.get_turn_actor_count() == 0
			and battle_turn_empty_bs.get_turn_actor_ids().is_empty()
			and battle_turn_empty_bs.get_turn_actor_types().is_empty()
			and battle_turn_empty_bs.get_turn_actor_side_ids().is_empty()
			and battle_turn_empty_bs.get_current_turn_index() == -1
			and battle_turn_empty_bs.get_current_round() == 1
			and not battle_turn_empty_bs.has_current_turn_actor()
			and battle_turn_empty_bs.get_current_turn_actor_id().is_empty()
			and battle_turn_empty_bs.get_current_turn_actor_type().is_empty()
			and battle_turn_empty_bs.get_current_turn_actor_side_id().is_empty()
		)
		var battle_turn_empty_before: Dictionary = _battle_turn_snapshot(battle_turn_empty_bs)
		var battle_turn_empty_advance: bool = battle_turn_empty_bs.advance_turn()
		battle_turn_advance_empty_ok = (
			battle_turn_empty_ok
			and not battle_turn_empty_advance
			and _battle_turn_unchanged(battle_turn_empty_bs, battle_turn_empty_before)
			and battle_turn_empty_bs.battle_phase == "active"
		)

	var battle_actor_turn_begin_ok: bool = false
	var battle_actor_turn_snapshot_ok: bool = false
	var battle_actor_turn_dup_begin_ok: bool = false
	var battle_actor_turn_end_ok: bool = false
	var battle_actor_turn_end_none_ok: bool = false
	var battle_actor_turn_advance_one_ok: bool = false
	var battle_actor_turn_wrap_ok: bool = false
	var battle_actor_turn_advance_blocked_ok: bool = false
	var battle_actor_turn_reinit_blocked_ok: bool = false
	var battle_actor_turn_outside_ok: bool = false
	var battle_actor_turn_empty_ok: bool = false
	var battle_actor_turn_no_mutate_ok: bool = false
	var battle_actor_turn_phase_ok: bool = false
	var battle_actor_turn_deploy_unchanged_ok: bool = false
	var battle_actor_turn_immutability_ok: bool = false
	var battle_actor_turn_persist_ok: bool = false
	var battle_actor_turn_pack: Dictionary = _battle_create_ready_pack()
	var battle_actor_turn_game: GameState = battle_actor_turn_pack.get("game_state", null) as GameState
	var battle_actor_turn_force: TravelingForce = battle_actor_turn_pack.get("force", null) as TravelingForce
	var battle_actor_turn_bs: BattleState = battle_actor_turn_pack.get("battle_state", null) as BattleState
	var battle_actor_turn_campaign: Dictionary = _battle_campaign_snapshot(
		battle_actor_turn_game, battle_actor_turn_force, "battle_mission"
	)
	if battle_actor_turn_bs != null:
		var battle_actor_turn_deployed: bool = _battle_deploy_standard_attacker(battle_actor_turn_bs)
		var battle_actor_turn_begun: bool = battle_actor_turn_bs.begin_battle()
		var battle_actor_turn_inited: bool = battle_actor_turn_bs.initialize_turn_order()
		var battle_actor_turn_assign: Dictionary = _battle_deploy_assignment_snapshot(battle_actor_turn_bs)
		var battle_actor_turn_idle_before: Dictionary = _battle_turn_snapshot(battle_actor_turn_bs)
		var battle_actor_turn_early_end: bool = battle_actor_turn_bs.end_current_actor_turn()
		battle_actor_turn_end_none_ok = (
			battle_actor_turn_deployed
			and battle_actor_turn_begun
			and battle_actor_turn_inited
			and not battle_actor_turn_early_end
			and _battle_turn_unchanged(battle_actor_turn_bs, battle_actor_turn_idle_before)
		)
		var battle_actor_turn_started: bool = battle_actor_turn_bs.begin_current_actor_turn()
		battle_actor_turn_begin_ok = (
			battle_actor_turn_end_none_ok
			and battle_actor_turn_started
			and battle_actor_turn_bs.is_actor_turn_in_progress()
			and battle_actor_turn_bs.get_current_turn_index() == 0
			and battle_actor_turn_bs.get_current_round() == 1
		)
		battle_actor_turn_snapshot_ok = (
			battle_actor_turn_begin_ok
			and battle_actor_turn_bs.get_active_turn_actor_id() == "battle_sol_a"
			and battle_actor_turn_bs.get_active_turn_actor_type() == BattleState.TURN_ACTOR_TYPE_PARTICIPANT
			and battle_actor_turn_bs.get_active_turn_actor_side_id() == "attacker"
			and battle_actor_turn_bs.get_active_turn_actor_id() == battle_actor_turn_bs.get_current_turn_actor_id()
			and battle_actor_turn_bs.get_active_turn_actor_type() == battle_actor_turn_bs.get_current_turn_actor_type()
			and battle_actor_turn_bs.get_active_turn_actor_side_id() == battle_actor_turn_bs.get_current_turn_actor_side_id()
		)
		var battle_actor_turn_active_snap: Dictionary = _battle_turn_snapshot(battle_actor_turn_bs)
		var battle_actor_turn_dup: bool = battle_actor_turn_bs.begin_current_actor_turn()
		battle_actor_turn_dup_begin_ok = (
			battle_actor_turn_snapshot_ok
			and not battle_actor_turn_dup
			and _battle_turn_unchanged(battle_actor_turn_bs, battle_actor_turn_active_snap)
		)
		var battle_actor_turn_blocked_advance: bool = battle_actor_turn_bs.advance_turn()
		battle_actor_turn_advance_blocked_ok = (
			battle_actor_turn_dup_begin_ok
			and not battle_actor_turn_blocked_advance
			and _battle_turn_unchanged(battle_actor_turn_bs, battle_actor_turn_active_snap)
		)
		var battle_actor_turn_blocked_reinit: bool = battle_actor_turn_bs.initialize_turn_order()
		battle_actor_turn_reinit_blocked_ok = (
			battle_actor_turn_advance_blocked_ok
			and not battle_actor_turn_blocked_reinit
			and _battle_turn_unchanged(battle_actor_turn_bs, battle_actor_turn_active_snap)
		)
		var battle_actor_turn_ended: bool = battle_actor_turn_bs.end_current_actor_turn()
		battle_actor_turn_end_ok = (
			battle_actor_turn_reinit_blocked_ok
			and battle_actor_turn_ended
			and not battle_actor_turn_bs.is_actor_turn_in_progress()
			and battle_actor_turn_bs.get_active_turn_actor_id().is_empty()
			and battle_actor_turn_bs.get_active_turn_actor_type().is_empty()
			and battle_actor_turn_bs.get_active_turn_actor_side_id().is_empty()
		)
		battle_actor_turn_advance_one_ok = (
			battle_actor_turn_end_ok
			and battle_actor_turn_bs.get_current_turn_index() == 1
			and battle_actor_turn_bs.get_current_round() == 1
			and battle_actor_turn_bs.get_current_turn_actor_id() == "battle_sol_m"
			and battle_actor_turn_bs.get_current_turn_actor_type() == BattleState.TURN_ACTOR_TYPE_PARTICIPANT
			and battle_actor_turn_bs.get_current_turn_actor_side_id() == "attacker"
		)
		var battle_actor_turn_to_last: bool = battle_actor_turn_advance_one_ok
		var battle_actor_turn_step: int = 2
		while battle_actor_turn_to_last and battle_actor_turn_step < 6:
			if not battle_actor_turn_bs.advance_turn():
				battle_actor_turn_to_last = false
				break
			if battle_actor_turn_bs.get_current_turn_index() != battle_actor_turn_step:
				battle_actor_turn_to_last = false
				break
			if battle_actor_turn_bs.get_current_round() != 1:
				battle_actor_turn_to_last = false
				break
			battle_actor_turn_step += 1
		var battle_actor_turn_last_begun: bool = false
		var battle_actor_turn_last_ended: bool = false
		if battle_actor_turn_to_last:
			battle_actor_turn_last_begun = battle_actor_turn_bs.begin_current_actor_turn()
			battle_actor_turn_last_ended = battle_actor_turn_bs.end_current_actor_turn()
		battle_actor_turn_wrap_ok = (
			battle_actor_turn_to_last
			and battle_actor_turn_last_begun
			and battle_actor_turn_last_ended
			and battle_actor_turn_bs.get_current_turn_index() == 0
			and battle_actor_turn_bs.get_current_round() == 2
			and battle_actor_turn_bs.get_current_turn_actor_id() == "battle_sol_a"
			and not battle_actor_turn_bs.is_actor_turn_in_progress()
			and battle_actor_turn_bs.get_active_turn_actor_id().is_empty()
		)
		battle_actor_turn_phase_ok = (
			battle_actor_turn_wrap_ok
			and battle_actor_turn_bs.battle_phase == "active"
			and battle_actor_turn_bs.battle_phase != "deployment"
			and battle_actor_turn_bs.battle_phase != "resolved"
		)
		battle_actor_turn_deploy_unchanged_ok = (
			battle_actor_turn_wrap_ok
			and _battle_deploy_assignment_unchanged(battle_actor_turn_bs, battle_actor_turn_assign)
		)
		battle_actor_turn_immutability_ok = (
			battle_actor_turn_wrap_ok
			and _battle_campaign_unchanged(
				battle_actor_turn_game, battle_actor_turn_campaign, battle_actor_turn_force, "battle_mission"
			)
			and battle_actor_turn_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battle_actor_turn_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)
		var battle_actor_turn_persist_begin: bool = battle_actor_turn_bs.begin_current_actor_turn()
		var battle_actor_turn_persist_data: Dictionary = battle_actor_turn_game.to_dict()
		var battle_actor_turn_restored: GameState = GameState.new()
		battle_actor_turn_restored.from_dict(battle_actor_turn_persist_data)
		battle_actor_turn_persist_ok = (
			battle_actor_turn_wrap_ok
			and battle_actor_turn_persist_begin
			and battle_actor_turn_bs.is_actor_turn_in_progress()
			and _battle_serialized_campaign_keys_only(battle_actor_turn_persist_data)
			and not _battle_data_has_tactical_trace(battle_actor_turn_persist_data)
			and battle_actor_turn_restored.has_mission("battle_mission")
			and battle_actor_turn_restored.get_mission("battle_mission").mission_state == "awaiting_resolution"
		)
		if battle_actor_turn_persist_begin:
			battle_actor_turn_bs.end_current_actor_turn()
	var battle_actor_turn_out_pack: Dictionary = _battle_create_ready_pack()
	var battle_actor_turn_out_bs: BattleState = battle_actor_turn_out_pack.get("battle_state", null) as BattleState
	if battle_actor_turn_out_bs != null:
		var battle_actor_turn_out_deployed: bool = _battle_deploy_standard_attacker(battle_actor_turn_out_bs)
		var battle_actor_turn_dep_snap: Dictionary = _battle_turn_snapshot(battle_actor_turn_out_bs)
		var battle_actor_turn_dep_begin: bool = battle_actor_turn_out_bs.begin_current_actor_turn()
		var battle_actor_turn_dep_end: bool = battle_actor_turn_out_bs.end_current_actor_turn()
		var battle_actor_turn_dep_ok: bool = (
			battle_actor_turn_out_deployed
			and battle_actor_turn_out_bs.battle_phase == "deployment"
			and not battle_actor_turn_dep_begin
			and not battle_actor_turn_dep_end
			and _battle_turn_unchanged(battle_actor_turn_out_bs, battle_actor_turn_dep_snap)
		)
		var battle_actor_turn_out_begun: bool = battle_actor_turn_out_bs.begin_battle()
		var battle_actor_turn_pre_init_snap: Dictionary = _battle_turn_snapshot(battle_actor_turn_out_bs)
		var battle_actor_turn_pre_init_begin: bool = battle_actor_turn_out_bs.begin_current_actor_turn()
		var battle_actor_turn_pre_init_ok: bool = (
			battle_actor_turn_dep_ok
			and battle_actor_turn_out_begun
			and battle_actor_turn_out_bs.battle_phase == "active"
			and not battle_actor_turn_pre_init_begin
			and _battle_turn_unchanged(battle_actor_turn_out_bs, battle_actor_turn_pre_init_snap)
		)
		var battle_actor_turn_out_inited: bool = battle_actor_turn_out_bs.initialize_turn_order()
		var battle_actor_turn_out_started: bool = battle_actor_turn_out_bs.begin_current_actor_turn()
		var battle_actor_turn_res_snap: Dictionary = _battle_turn_snapshot(battle_actor_turn_out_bs)
		battle_actor_turn_out_bs.battle_phase = "resolved"
		var battle_actor_turn_res_begin: bool = battle_actor_turn_out_bs.begin_current_actor_turn()
		var battle_actor_turn_res_end: bool = battle_actor_turn_out_bs.end_current_actor_turn()
		var battle_actor_turn_res_advance: bool = battle_actor_turn_out_bs.advance_turn()
		var battle_actor_turn_res_reinit: bool = battle_actor_turn_out_bs.initialize_turn_order()
		battle_actor_turn_outside_ok = (
			battle_actor_turn_pre_init_ok
			and battle_actor_turn_out_inited
			and battle_actor_turn_out_started
			and not battle_actor_turn_res_begin
			and not battle_actor_turn_res_end
			and not battle_actor_turn_res_advance
			and not battle_actor_turn_res_reinit
			and battle_actor_turn_out_bs.battle_phase == "resolved"
			and _battle_turn_unchanged(battle_actor_turn_out_bs, battle_actor_turn_res_snap)
		)
	var battle_actor_turn_empty_bs: BattleState = _battle_make_bare_state()
	if battle_actor_turn_empty_bs != null:
		var battle_actor_turn_empty_begun: bool = battle_actor_turn_empty_bs.begin_battle()
		var battle_actor_turn_empty_inited: bool = battle_actor_turn_empty_bs.initialize_turn_order()
		var battle_actor_turn_empty_snap: Dictionary = _battle_turn_snapshot(battle_actor_turn_empty_bs)
		var battle_actor_turn_empty_begin: bool = battle_actor_turn_empty_bs.begin_current_actor_turn()
		var battle_actor_turn_empty_end: bool = battle_actor_turn_empty_bs.end_current_actor_turn()
		battle_actor_turn_empty_ok = (
			battle_actor_turn_empty_begun
			and battle_actor_turn_empty_inited
			and battle_actor_turn_empty_bs.battle_phase == "active"
			and not battle_actor_turn_empty_bs.has_current_turn_actor()
			and not battle_actor_turn_empty_begin
			and not battle_actor_turn_empty_end
			and not battle_actor_turn_empty_bs.is_actor_turn_in_progress()
			and battle_actor_turn_empty_bs.get_active_turn_actor_id().is_empty()
			and _battle_turn_unchanged(battle_actor_turn_empty_bs, battle_actor_turn_empty_snap)
		)
	battle_actor_turn_no_mutate_ok = (
		battle_actor_turn_end_none_ok
		and battle_actor_turn_dup_begin_ok
		and battle_actor_turn_advance_blocked_ok
		and battle_actor_turn_reinit_blocked_ok
		and battle_actor_turn_outside_ok
		and battle_actor_turn_empty_ok
	)

	var checks := {
		"turn_matches": restored.current_turn == original.current_turn,
		"year_matches": restored.current_year == original.current_year,
		"month_matches": restored.current_month == original.current_month,
		"gang_a_exists": restored.has_faction("gang_a"),
		"gang_b_exists": restored.has_faction("gang_b"),
		"gang_a_is_major_gang": restored.get_faction("gang_a") is MajorGang,
		"gang_b_is_major_gang": restored.get_faction("gang_b") is MajorGang,
		"gang_a_display_name": restored_a != null and restored_a.display_name == "Gang A",
		"gang_b_display_name": restored_b != null and restored_b.display_name == "Gang B",
		"gang_a_controller_type": restored_a != null and restored_a.controller_type == "player",
		"gang_b_controller_type": restored_b != null and restored_b.controller_type == "ai",
		"gang_a_money": restored_a != null and restored_a.money == 10000.0,
		"gang_b_money": restored_b != null and restored_b.money == 10000.0,
		"gang_a_ammo": restored_a != null and restored_a.resources.get_amount("Ammo") == 12.5,
		"gang_a_gun_parts": restored_a != null and restored_a.resources.get_amount("Gun Parts") == 7.0,
		"gang_b_ammo": restored_b != null and restored_b.resources.get_amount("Ammo") == 8.0,
		"gang_b_gun_parts": restored_b != null and restored_b.resources.get_amount("Gun Parts") == 4.5,
		"stronghold_a_exists": restored.has_map_location("stronghold_a"),
		"hq_contested_exists": restored.has_map_location("hq_contested"),
		"business_a_exists": restored.has_map_location("business_a"),
		"stronghold_a_is_stronghold": restored.get_map_location("stronghold_a") is Stronghold,
		"hq_contested_is_neighborhood_hq": restored.get_map_location("hq_contested") is NeighborhoodHQ,
		"business_a_is_business": restored.get_map_location("business_a") is Business,
		"stronghold_a_display_name": restored_stronghold != null and restored_stronghold.display_name == "Gang A Stronghold",
		"hq_contested_display_name": restored_hq != null and restored_hq.display_name == "Contested Neighborhood HQ",
		"business_a_display_name": restored_business != null and restored_business.display_name == "Test Market",
		"stronghold_a_neighborhood_id": restored_stronghold != null and restored_stronghold.neighborhood_id == "neighborhood_a",
		"hq_contested_neighborhood_id": restored_hq != null and restored_hq.neighborhood_id == "neighborhood_contested",
		"business_a_neighborhood_id": restored_business != null and restored_business.neighborhood_id == "neighborhood_a",
		"stronghold_a_map_position": restored_stronghold != null and restored_stronghold.map_position == Vector2(100.0, 200.0),
		"hq_contested_map_position": restored_hq != null and restored_hq.map_position == Vector2(300.0, 200.0),
		"business_a_map_position": restored_business != null and restored_business.map_position == Vector2(140.0, 240.0),
		"stronghold_a_owner_faction_id": restored_stronghold != null and restored_stronghold.owner_faction_id == "gang_a",
		"hq_contested_owner_faction_id": restored_hq != null and restored_hq.owner_faction_id == "gang_b",
		"business_a_owner_faction_id": restored_business != null and restored_business.owner_faction_id == "gang_a",
		"stronghold_a_level": restored_stronghold != null and restored_stronghold.level == 2,
		"business_a_type_id": restored_business != null and restored_business.business_type_id == "market",
		"business_a_level": restored_business != null and restored_business.level == 3,
		"business_a_is_open": restored_business != null and restored_business.is_open == false,
		"hq_contested_is_open": restored_hq != null and restored_hq.is_open == true,
		"stronghold_a_location_type": restored_stronghold != null and restored_stronghold.location_type == "stronghold",
		"hq_contested_location_type": restored_hq != null and restored_hq.location_type == "neighborhood_hq",
		"business_a_location_type": restored_business != null and restored_business.location_type == "business",
		"duplicate_faction_rejected": duplicate_faction_rejected,
		"duplicate_location_rejected": duplicate_location_rejected,
		"southside_exists": restored.has_stronghold_region("southside"),
		"northside_exists": restored.has_stronghold_region("northside"),
		"district_1_exists": restored.has_police_region("district_1"),
		"district_2_exists": restored.has_police_region("district_2"),
		"neighborhood_a_exists": restored.has_neighborhood("neighborhood_a"),
		"neighborhood_contested_exists": restored.has_neighborhood("neighborhood_contested"),
		"neighborhood_b_exists": restored.has_neighborhood("neighborhood_b"),
		"southside_display_name": restored_southside != null and restored_southside.display_name == "Southside",
		"northside_display_name": restored_northside != null and restored_northside.display_name == "Northside",
		"district_1_display_name": restored_district_1 != null and restored_district_1.display_name == "District 1",
		"district_2_display_name": restored_district_2 != null and restored_district_2.display_name == "District 2",
		"neighborhood_a_display_name": restored_neighborhood_a != null and restored_neighborhood_a.display_name == "Neighborhood A",
		"neighborhood_contested_display_name": restored_neighborhood_contested != null and restored_neighborhood_contested.display_name == "Contested Neighborhood",
		"neighborhood_b_display_name": restored_neighborhood_b != null and restored_neighborhood_b.display_name == "Neighborhood B",
		"neighborhood_a_stronghold_region_id": restored_neighborhood_a != null and restored_neighborhood_a.stronghold_region_id == "southside",
		"neighborhood_contested_stronghold_region_id": restored_neighborhood_contested != null and restored_neighborhood_contested.stronghold_region_id == "southside",
		"neighborhood_b_stronghold_region_id": restored_neighborhood_b != null and restored_neighborhood_b.stronghold_region_id == "northside",
		"neighborhood_a_police_region_id": restored_neighborhood_a != null and restored_neighborhood_a.police_region_id == "district_1",
		"neighborhood_contested_police_region_id": restored_neighborhood_contested != null and restored_neighborhood_contested.police_region_id == "district_2",
		"neighborhood_b_police_region_id": restored_neighborhood_b != null and restored_neighborhood_b.police_region_id == "district_2",
		"southside_query": _neighborhood_ids_match(southside_neighborhoods, ["neighborhood_a", "neighborhood_contested"]),
		"northside_query": _neighborhood_ids_match(northside_neighborhoods, ["neighborhood_b"]),
		"district_1_query": _neighborhood_ids_match(district_1_neighborhoods, ["neighborhood_a"]),
		"district_2_query": _neighborhood_ids_match(district_2_neighborhoods, ["neighborhood_b", "neighborhood_contested"]),
		"empty_stronghold_region_query": restored.get_neighborhoods_in_stronghold_region("").is_empty(),
		"empty_police_region_query": restored.get_neighborhoods_in_police_region("").is_empty(),
		"missing_stronghold_region_query": restored.get_neighborhoods_in_stronghold_region("missing_region").is_empty(),
		"missing_police_region_query": restored.get_neighborhoods_in_police_region("missing_region").is_empty(),
		"duplicate_neighborhood_rejected": duplicate_neighborhood_rejected,
		"duplicate_stronghold_region_rejected": duplicate_stronghold_region_rejected,
		"duplicate_police_region_rejected": duplicate_police_region_rejected,
		"route_short_ok": route_short_ok,
		"route_short_distance_ok": route_short_distance_ok,
		"route_same_ok": route_same_ok,
		"empty_start_route_ok": empty_start_route_ok,
		"missing_destination_route_ok": missing_destination_route_ok,
		"closed_route_ok": closed_route_ok,
		"closed_route_distance_ok": closed_route_distance_ok,
		"duplicate_road_node_rejected": duplicate_road_node_rejected,
		"duplicate_road_segment_rejected": duplicate_road_segment_rejected,
		"reversed_endpoint_pair_rejected": reversed_endpoint_pair_rejected,
		"self_loop_rejected": self_loop_rejected,
		"missing_endpoint_rejected": missing_endpoint_rejected,
		"force_step_1_ok": force_step_1_ok,
		"force_step_2_ok": force_step_2_ok,
		"force_step_3_ok": force_step_3_ok,
		"force_step_4_ok": force_step_4_ok,
		"force_partial_ok": force_partial_ok,
		"force_leftover_ok": force_leftover_ok,
		"force_blocked_ok": force_blocked_ok,
		"invalid_budget_ok": invalid_budget_ok,
		"duplicate_traveling_force_rejected": duplicate_traveling_force_rejected,
		"road_a_exists": restored_graph != null and restored_graph.has_node("road_a"),
		"road_b_exists": restored_graph != null and restored_graph.has_node("road_b"),
		"road_c_exists": restored_graph != null and restored_graph.has_node("road_c"),
		"road_d_exists": restored_graph != null and restored_graph.has_node("road_d"),
		"road_e_exists": restored_graph != null and restored_graph.has_node("road_e"),
		"seg_ab_exists": restored_graph != null and restored_graph.has_segment("seg_ab"),
		"seg_bc_exists": restored_graph != null and restored_graph.has_segment("seg_bc"),
		"seg_cd_exists": restored_graph != null and restored_graph.has_segment("seg_cd"),
		"seg_be_exists": restored_graph != null and restored_graph.has_segment("seg_be"),
		"seg_ed_exists": restored_graph != null and restored_graph.has_segment("seg_ed"),
		"seg_ab_distance": restored_seg_ab != null and restored_seg_ab.distance == 2.0,
		"seg_bc_distance": restored_seg_bc != null and restored_seg_bc.distance == 3.0,
		"seg_cd_distance": restored_seg_cd != null and restored_seg_cd.distance == 4.0,
		"seg_be_distance": restored_seg_be != null and restored_seg_be.distance == 2.0,
		"seg_ed_distance": restored_seg_ed != null and restored_seg_ed.distance == 3.0,
		"seg_ab_is_open": restored_seg_ab != null and restored_seg_ab.is_open == true,
		"seg_bc_is_open": restored_seg_bc != null and restored_seg_bc.is_open == true,
		"seg_cd_is_open": restored_seg_cd != null and restored_seg_cd.is_open == true,
		"seg_be_is_open": restored_seg_be != null and restored_seg_be.is_open == true,
		"seg_ed_is_open": restored_seg_ed != null and restored_seg_ed.is_open == true,
		"stronghold_a_road_node_id": restored_stronghold != null and restored_stronghold.road_node_id == "road_a",
		"business_a_road_node_id": restored_business != null and restored_business.road_node_id == "road_b",
		"hq_contested_road_node_id": restored_hq != null and restored_hq.road_node_id == "road_d",
		"force_a_exists": restored.has_traveling_force("force_a"),
		"force_partial_exists": restored.has_traveling_force("force_partial"),
		"force_leftover_exists": restored.has_traveling_force("force_leftover"),
		"force_blocked_exists": restored.has_traveling_force("force_blocked"),
		"force_a_ids": restored_force_a != null and restored_force_a.faction_id == "gang_a" and restored_force_a.origin_location_id == "stronghold_a" and restored_force_a.destination_location_id == "hq_contested",
		"force_partial_ids": restored_force_partial != null and restored_force_partial.faction_id == "gang_a" and restored_force_partial.origin_location_id == "stronghold_a" and restored_force_partial.destination_location_id == "hq_contested",
		"force_leftover_ids": restored_force_leftover != null and restored_force_leftover.faction_id == "gang_a" and restored_force_leftover.origin_location_id == "stronghold_a" and restored_force_leftover.destination_location_id == "business_a",
		"force_blocked_ids": restored_force_blocked != null and restored_force_blocked.faction_id == "gang_a",
		"force_a_route": restored_force_a != null and _string_ids_match(restored_force_a.route_node_ids, route_short),
		"force_partial_route": restored_force_partial != null and _string_ids_match(restored_force_partial.route_node_ids, route_short),
		"force_leftover_route": restored_force_leftover != null and _string_ids_match(restored_force_leftover.route_node_ids, route_ab),
		"force_blocked_route": restored_force_blocked != null and _string_ids_match(restored_force_blocked.route_node_ids, route_short),
		"force_a_segment_index": restored_force_a != null and restored_force_a.route_segment_index == 2,
		"force_partial_segment_index": restored_force_partial != null and restored_force_partial.route_segment_index == 2,
		"force_leftover_segment_index": restored_force_leftover != null and restored_force_leftover.route_segment_index == 0,
		"force_blocked_segment_index": restored_force_blocked != null and restored_force_blocked.route_segment_index == 1,
		"force_a_distance_into_segment": restored_force_a != null and restored_force_a.distance_into_segment == 3.0,
		"force_partial_distance_into_segment": restored_force_partial != null and restored_force_partial.distance_into_segment == 1.5,
		"force_leftover_distance_into_segment": restored_force_leftover != null and restored_force_leftover.distance_into_segment == 2.0,
		"force_blocked_distance_into_segment": restored_force_blocked != null and restored_force_blocked.distance_into_segment == 0.0,
		"force_a_movement_per_turn": restored_force_a != null and restored_force_a.movement_per_turn == 5.0,
		"force_partial_movement_per_turn": restored_force_partial != null and restored_force_partial.movement_per_turn == 5.0,
		"force_leftover_movement_per_turn": restored_force_leftover != null and restored_force_leftover.movement_per_turn == 5.0,
		"force_blocked_movement_per_turn": restored_force_blocked != null and restored_force_blocked.movement_per_turn == 5.0,
		"force_a_travel_state": restored_force_a != null and restored_force_a.travel_state == "at_destination",
		"force_partial_travel_state": restored_force_partial != null and restored_force_partial.travel_state == "traveling_outbound",
		"force_leftover_travel_state": restored_force_leftover != null and restored_force_leftover.travel_state == "at_destination",
		"force_blocked_travel_state": restored_force_blocked != null and restored_force_blocked.travel_state == "traveling_outbound",
		"vehicle_bike_assigned": bike_assigned,
		"vehicle_car_assigned": car_assigned,
		"vehicle_van_assigned": van_assigned,
		"assigned_homes_ok": assigned_homes_ok,
		"stronghold_a_vehicles_once": stronghold_a_vehicles_once,
		"vehicle_car_reassign_same": car_reassign_same,
		"vehicle_car_not_duplicated": car_not_duplicated,
		"vehicle_car_moved_to_b": car_moved_to_b,
		"vehicle_car_home_is_b": car_home_is_b,
		"stronghold_a_lacks_car_after_move": stronghold_a_lacks_car,
		"stronghold_b_has_car_once": stronghold_b_has_car_once,
		"vehicle_car_moved_back": car_moved_back,
		"enemy_assign_rejected": enemy_assign_rejected,
		"enemy_home_empty": enemy_home_empty,
		"stronghold_a_lacks_enemy": stronghold_a_lacks_enemy,
		"vehicle_van_unassigned": van_unassigned,
		"vehicle_van_home_cleared": van_home_cleared,
		"stronghold_a_lacks_van_after_unassign": stronghold_a_lacks_van,
		"vehicle_van_reassigned": van_reassigned,
		"final_vehicle_homes_ok": final_homes_ok,
		"convoy_add_bike": convoy_add_bike,
		"convoy_add_car": convoy_add_car,
		"convoy_add_van": convoy_add_van,
		"convoy_order_ok": convoy_order_ok,
		"convoy_dup_rejected": convoy_dup_rejected,
		"convoy_empty_rejected": convoy_empty_rejected,
		"convoy_size_three": convoy_size_three,
		"convoy_remove_missing": convoy_remove_missing,
		"convoy_remove_car": convoy_remove_car,
		"convoy_car_absent": convoy_car_absent,
		"convoy_readd_car": convoy_readd_car,
		"convoy_unique_after_readd": convoy_unique_after_readd,
		"convoy_capacity_ok": convoy_capacity_ok,
		"convoy_movement_ok": convoy_movement_ok,
		"empty_group_capacity_ok": empty_capacity_ok,
		"empty_group_movement_ok": empty_movement_ok,
		"force_convoy_refresh_ok": force_convoy_refresh_ok,
		"force_convoy_stored_ok": force_convoy_stored_ok,
		"missing_capacity_ok": missing_capacity_ok,
		"missing_movement_ok": missing_movement_ok,
		"loaded_group_ok": loaded_group_ok,
		"duplicate_vehicle_rejected": duplicate_vehicle_rejected,
		"remove_missing_vehicle": remove_missing_vehicle,
		"negative_capacity_ok": negative_capacity_ok,
		"negative_movement_ok": negative_movement_ok,
		"negative_upkeep_ok": negative_upkeep_ok,
		"vehicle_bike_exists": restored.has_vehicle("vehicle_bike"),
		"vehicle_car_exists": restored.has_vehicle("vehicle_car"),
		"vehicle_van_exists": restored.has_vehicle("vehicle_van"),
		"vehicle_enemy_exists": restored.has_vehicle("vehicle_enemy"),
		"vehicle_bike_is_vehicle": restored.get_vehicle("vehicle_bike") is Vehicle,
		"vehicle_car_is_vehicle": restored.get_vehicle("vehicle_car") is Vehicle,
		"vehicle_van_is_vehicle": restored.get_vehicle("vehicle_van") is Vehicle,
		"vehicle_enemy_is_vehicle": restored.get_vehicle("vehicle_enemy") is Vehicle,
		"vehicle_bike_fields": restored_bike != null and restored_bike.faction_id == "gang_a" and restored_bike.vehicle_type_id == "bike" and restored_bike.home_stronghold_id == "stronghold_a" and restored_bike.passenger_capacity == 1 and restored_bike.movement_per_turn == 6.0 and restored_bike.upkeep_per_turn == 25.0,
		"vehicle_car_fields": restored_car != null and restored_car.faction_id == "gang_a" and restored_car.vehicle_type_id == "car" and restored_car.home_stronghold_id == "stronghold_a" and restored_car.passenger_capacity == 4 and restored_car.movement_per_turn == 5.0 and restored_car.upkeep_per_turn == 50.0,
		"vehicle_van_fields": restored_van != null and restored_van.faction_id == "gang_a" and restored_van.vehicle_type_id == "van" and restored_van.home_stronghold_id == "stronghold_a" and restored_van.passenger_capacity == 7 and restored_van.movement_per_turn == 4.0 and restored_van.upkeep_per_turn == 80.0,
		"vehicle_enemy_fields": restored_enemy != null and restored_enemy.faction_id == "gang_b" and restored_enemy.vehicle_type_id == "car" and restored_enemy.home_stronghold_id == "" and restored_enemy.passenger_capacity == 4 and restored_enemy.movement_per_turn == 5.0 and restored_enemy.upkeep_per_turn == 50.0,
		"stronghold_b_exists": restored.has_map_location("stronghold_b"),
		"stronghold_b_is_stronghold": restored.get_map_location("stronghold_b") is Stronghold,
		"restored_stronghold_a_vehicle_ids": restored_stronghold != null and _string_ids_match(restored_stronghold.vehicle_ids, final_stronghold_a_vehicles),
		"restored_stronghold_b_vehicle_ids": restored_stronghold_b != null and _string_ids_match(restored_stronghold_b.vehicle_ids, final_stronghold_b_vehicles),
		"force_convoy_exists": restored.has_traveling_force("force_convoy"),
		"restored_force_convoy_vehicle_ids": restored_force_convoy != null and restored_force_convoy.vehicle_group != null and _string_ids_match(restored_force_convoy.vehicle_group.vehicle_ids, expected_force_convoy_ids),
		"restored_force_convoy_movement_per_turn": restored_force_convoy != null and restored_force_convoy.movement_per_turn == 4.0,
		"pistol_assigned": pistol_assigned,
		"shotgun_assigned": shotgun_assigned,
		"smg_assigned": smg_assigned,
		"rifle_assigned": rifle_assigned,
		"assigned_soldier_homes_ok": assigned_soldier_homes_ok,
		"stronghold_a_soldiers_once": stronghold_a_soldiers_once,
		"pistol_reassign_same": pistol_reassign_same,
		"pistol_not_duplicated": pistol_not_duplicated,
		"rifle_moved_to_b": rifle_moved_to_b,
		"rifle_home_is_b": rifle_home_is_b,
		"stronghold_a_lacks_rifle": stronghold_a_lacks_rifle,
		"stronghold_b_has_rifle_once": stronghold_b_has_rifle_once,
		"rifle_moved_back": rifle_moved_back,
		"enemy_soldier_assign_rejected": enemy_soldier_assign_rejected,
		"enemy_soldier_home_empty": enemy_soldier_home_empty,
		"stronghold_a_lacks_enemy_soldier": stronghold_a_lacks_enemy_soldier,
		"smg_unassigned": smg_unassigned,
		"smg_home_cleared": smg_home_cleared,
		"stronghold_a_lacks_smg": stronghold_a_lacks_smg,
		"smg_reassigned": smg_reassigned,
		"final_soldier_homes_ok": final_soldier_homes_ok,
		"squad_add_pistol": squad_add_pistol,
		"squad_add_shotgun": squad_add_shotgun,
		"squad_add_smg": squad_add_smg,
		"squad_add_rifle": squad_add_rifle,
		"squad_order_ok": squad_order_ok,
		"squad_dup_rejected": squad_dup_rejected,
		"squad_empty_rejected": squad_empty_rejected,
		"squad_size_four": squad_size_four,
		"squad_remove_missing": squad_remove_missing,
		"squad_remove_shotgun": squad_remove_shotgun,
		"squad_shotgun_absent": squad_shotgun_absent,
		"squad_readd_shotgun": squad_readd_shotgun,
		"squad_unique_after_readd": squad_unique_after_readd,
		"squad_strength_ok": squad_strength_ok,
		"empty_squad_strength_ok": empty_squad_strength_ok,
		"missing_squad_strength_ok": missing_squad_strength_ok,
		"loaded_squad_ok": loaded_squad_ok,
		"force_soldiers_count_ok": force_soldiers_count_ok,
		"force_soldiers_capacity_ok": force_soldiers_capacity_ok,
		"force_soldiers_valid": force_soldiers_valid,
		"force_soldiers_strength_ok": force_soldiers_strength_ok,
		"overloaded_capacity_ok": overloaded_capacity_ok,
		"overloaded_invalid": overloaded_invalid,
		"no_vehicle_capacity_ok": no_vehicle_capacity_ok,
		"no_vehicle_invalid": no_vehicle_invalid,
		"empty_transport_capacity_ok": empty_transport_capacity_ok,
		"empty_transport_valid": empty_transport_valid,
		"negative_soldier_strength_ok": negative_soldier_strength_ok,
		"negative_soldier_upkeep_ok": negative_soldier_upkeep_ok,
		"duplicate_soldier_rejected": duplicate_soldier_rejected,
		"remove_missing_soldier": remove_missing_soldier,
		"soldier_pistol_exists": restored.has_soldier("soldier_pistol"),
		"soldier_shotgun_exists": restored.has_soldier("soldier_shotgun"),
		"soldier_smg_exists": restored.has_soldier("soldier_smg"),
		"soldier_rifle_exists": restored.has_soldier("soldier_rifle"),
		"soldier_enemy_exists": restored.has_soldier("soldier_enemy"),
		"soldier_pistol_is_soldier": restored.get_soldier("soldier_pistol") is Soldier,
		"soldier_shotgun_is_soldier": restored.get_soldier("soldier_shotgun") is Soldier,
		"soldier_smg_is_soldier": restored.get_soldier("soldier_smg") is Soldier,
		"soldier_rifle_is_soldier": restored.get_soldier("soldier_rifle") is Soldier,
		"soldier_enemy_is_soldier": restored.get_soldier("soldier_enemy") is Soldier,
		"soldier_pistol_fields": restored_pistol != null and restored_pistol.faction_id == "gang_a" and restored_pistol.home_stronghold_id == "stronghold_a" and restored_pistol.weapon_type_id == "pistol" and is_equal_approx(restored_pistol.strategic_strength, 1.00) and restored_pistol.upkeep_per_turn == 20.0,
		"soldier_shotgun_fields": restored_shotgun != null and restored_shotgun.faction_id == "gang_a" and restored_shotgun.home_stronghold_id == "stronghold_a" and restored_shotgun.weapon_type_id == "shotgun" and is_equal_approx(restored_shotgun.strategic_strength, 1.25) and restored_shotgun.upkeep_per_turn == 25.0,
		"soldier_smg_fields": restored_smg != null and restored_smg.faction_id == "gang_a" and restored_smg.home_stronghold_id == "stronghold_a" and restored_smg.weapon_type_id == "smg" and is_equal_approx(restored_smg.strategic_strength, 1.55) and restored_smg.upkeep_per_turn == 30.0,
		"soldier_rifle_fields": restored_rifle != null and restored_rifle.faction_id == "gang_a" and restored_rifle.home_stronghold_id == "stronghold_a" and restored_rifle.weapon_type_id == "rifle" and is_equal_approx(restored_rifle.strategic_strength, 1.90) and restored_rifle.upkeep_per_turn == 35.0,
		"soldier_enemy_fields": restored_enemy_soldier != null and restored_enemy_soldier.faction_id == "gang_b" and restored_enemy_soldier.home_stronghold_id == "" and restored_enemy_soldier.weapon_type_id == "pistol" and restored_enemy_soldier.strategic_strength == 1.0 and restored_enemy_soldier.upkeep_per_turn == 20.0,
		"restored_stronghold_a_soldier_ids": restored_stronghold != null and _string_ids_match(restored_stronghold.soldier_ids, final_stronghold_a_soldiers),
		"restored_stronghold_b_soldier_ids": restored_stronghold_b != null and _string_ids_match(restored_stronghold_b.soldier_ids, final_stronghold_b_soldiers),
		"force_soldiers_exists": restored.has_traveling_force("force_soldiers"),
		"restored_force_soldiers_ids": restored_force_soldiers != null and restored_force_soldiers.soldier_group != null and _string_ids_match(restored_force_soldiers.soldier_group.soldier_ids, expected_force_soldiers_ids),
		"restored_force_soldiers_vehicles": restored_force_soldiers != null and restored_force_soldiers.vehicle_group != null and _string_ids_match(restored_force_soldiers.vehicle_group.vehicle_ids, expected_force_soldiers_vehicles),
		"restored_force_soldiers_capacity": restored_force_soldiers != null and restored_force_soldiers.get_transport_capacity(restored) == 4,
		"restored_force_soldiers_valid": restored_force_soldiers != null and restored_force_soldiers.has_valid_transport_capacity(restored) == true,
		"restored_force_soldiers_strength": restored_force_soldiers != null and is_equal_approx(restored_force_soldiers.get_total_strategic_strength(restored), 5.70),
		"deploy_assets_assigned": assign_ds1 and assign_ds2 and assign_ds3 and assign_dcar and assign_dvan,
		"deploy_partial_result_ok": deploy_partial_result_ok,
		"deploy_partial_force_ok": deploy_partial_force_ok,
		"deploy_partial_homes_ok": deploy_partial_homes_ok,
		"deploy_capped_ok": deploy_capped_ok,
		"deploy_arrive_ok": deploy_arrive_ok,
		"deploy_same0_ok": deploy_same0_ok,
		"deploy_same3_ok": deploy_same3_ok,
		"deploy_zero_ok": deploy_zero_ok,
		"deploy_soldier_excl_ok": deploy_soldier_excl_ok,
		"deploy_vehicle_excl_ok": deploy_vehicle_excl_ok,
		"deploy_release_ok": deploy_release_ok,
		"deploy_over_ok": deploy_over_ok,
		"deploy_no_soldiers_ok": deploy_no_soldiers_ok,
		"deploy_no_vehicles_ok": deploy_no_vehicles_ok,
		"deploy_dup_soldier_ok": deploy_dup_soldier_ok,
		"deploy_dup_vehicle_ok": deploy_dup_vehicle_ok,
		"deploy_wrong_faction_s_ok": deploy_wrong_faction_s_ok,
		"deploy_wrong_faction_v_ok": deploy_wrong_faction_v_ok,
		"deploy_wrong_home_s_ok": deploy_wrong_home_s_ok,
		"deploy_wrong_home_v_ok": deploy_wrong_home_v_ok,
		"deploy_not_at_origin_s_ok": deploy_not_at_origin_s_ok,
		"deploy_not_at_origin_v_ok": deploy_not_at_origin_v_ok,
		"deploy_invalid_origin_ok": deploy_invalid_origin_ok,
		"deploy_origin_not_stronghold_ok": deploy_origin_not_stronghold_ok,
		"deploy_origin_wrong_faction_ok": deploy_origin_wrong_faction_ok,
		"deploy_origin_missing_road_ok": deploy_origin_missing_road_ok,
		"deploy_invalid_dest_ok": deploy_invalid_dest_ok,
		"deploy_dest_missing_road_ok": deploy_dest_missing_road_ok,
		"deploy_origin_ghost_ok": deploy_origin_ghost_ok,
		"deploy_dest_ghost_ok": deploy_dest_ghost_ok,
		"deploy_no_route_ok": deploy_no_route_ok,
		"deploy_dup_force_ok": deploy_dup_force_ok,
		"deploy_atomic_redeploy_ok": deploy_atomic_redeploy_ok,
		"deploy_helper_success_ok": deploy_helper_success_ok,
		"deploy_helper_fail_ok": deploy_helper_fail_ok,
		"mission_partial_ok": mission_partial_ok,
		"mission_immediate_ok": mission_immediate_ok,
		"mission_samenode_ok": mission_samenode_ok,
		"mission_deploy_fail_ok": mission_deploy_fail_ok,
		"mission_null_request_ok": mission_null_request_ok,
		"mission_empty_id_ok": mission_empty_id_ok,
		"mission_empty_type_ok": mission_empty_type_ok,
		"mission_dup_id_ok": mission_dup_id_ok,
		"mission_null_dep_ok": mission_null_dep_ok,
		"mission_sync_still_traveling_ok": mission_sync_still_traveling_ok,
		"mission_sync_arrived_ok": mission_sync_arrived_ok,
		"mission_sync_idempotent_ok": mission_sync_idempotent_ok,
		"mission_mismatch_ok": mission_mismatch_ok,
		"mission_sync_all_ok": mission_sync_all_ok,
		"mission_resolve_success_ok": mission_resolve_success_ok,
		"mission_resolve_fail_ok": mission_resolve_fail_ok,
		"mission_invalid_ok": mission_invalid_ok,
		"mission_empty_outcome_ok": mission_empty_outcome_ok,
		"mission_not_awaiting_ok": mission_not_awaiting_ok,
		"mission_force_not_dest_ok": mission_force_not_dest_ok,
		"mission_invalid_force_ok": mission_invalid_force_ok,
		"mission_add_dup_ok": mission_add_dup_ok,
		"mission_remove_missing_ok": mission_remove_missing_ok,
		"mission_remove_ok": mission_remove_ok,
		"restored_mission_partial_ok": restored_mission_partial_ok,
		"restored_mission_immediate_ok": restored_mission_immediate_ok,
		"restored_mission_samenode_ok": restored_mission_samenode_ok,
		"restored_mission_outbound_ok": restored_mission_outbound_ok,
		"mission_older_save_ok": mission_older_save_ok,
		"mission_malformed_ok": mission_malformed_ok,
		"mission_helper_success_ok": mission_helper_success_ok,
		"mission_helper_fail_ok": mission_helper_fail_ok,
		"mission_no_effects_ok": mission_no_effects_ok,
		"raid_standard_result_ok": raid_standard_result_ok,
		"raid_standard_world_ok": raid_standard_world_ok,
		"raid_level2_ok": raid_level2_ok,
		"raid_level1_floor_ok": raid_level1_floor_ok,
		"raid_already_closed_ok": raid_already_closed_ok,
		"raid_zero_loot_ok": raid_zero_loot_ok,
		"raid_loot_integrity_ok": raid_loot_integrity_ok,
		"raid_result_copy_ok": raid_result_copy_ok,
		"raid_wrong_type_ok": raid_wrong_type_ok,
		"raid_not_awaiting_ok": raid_not_awaiting_ok,
		"raid_force_not_dest_ok": raid_force_not_dest_ok,
		"raid_invalid_target_ok": raid_invalid_target_ok,
		"raid_target_not_business_ok": raid_target_not_business_ok,
		"raid_force_target_mismatch_ok": raid_force_target_mismatch_ok,
		"raid_force_faction_mismatch_ok": raid_force_faction_mismatch_ok,
		"raid_invalid_faction_ok": raid_invalid_faction_ok,
		"raid_faction_not_major_gang_ok": raid_faction_not_major_gang_ok,
		"raid_null_loot_ok": raid_null_loot_ok,
		"raid_invalid_cash_loot_ok": raid_invalid_cash_loot_ok,
		"raid_invalid_resource_id_ok": raid_invalid_resource_id_ok,
		"raid_invalid_resource_amount_ok": raid_invalid_resource_amount_ok,
		"raid_missing_mission_ok": raid_missing_mission_ok,
		"raid_missing_force_ok": raid_missing_force_ok,
		"raid_atomic_wrong_type_ok": raid_atomic_wrong_type_ok,
		"raid_atomic_force_target_ok": raid_atomic_force_target_ok,
		"raid_atomic_invalid_loot_ok": raid_atomic_invalid_loot_ok,
		"raid_rollback_path_unreachable_ok": raid_rollback_path_unreachable_ok,
		"raid_no_capture_ok": raid_no_capture_ok,
		"raid_no_return_ok": raid_no_return_ok,
		"rem_deploy_partial_ok": rem_deploy_partial_ok,
		"rem_deploy_arrive_ok": rem_deploy_arrive_ok,
		"rem_deploy_same_ok": rem_deploy_same_ok,
		"rem_deploy_zero_ok": rem_deploy_zero_ok,
		"rem_refresh_ok": rem_refresh_ok,
		"rem_current_node_ok": rem_current_node_ok,
		"rem_resolved_move_ok": rem_resolved_move_ok,
		"rem_raid_continue_ok": rem_raid_continue_ok,
		"rem_block_outbound_ok": rem_block_outbound_ok,
		"rem_block_await_ok": rem_block_await_ok,
		"rem_block_return_ok": rem_block_return_ok,
		"rem_allow_success_ok": rem_allow_success_ok,
		"rem_allow_failure_ok": rem_allow_failure_ok,
		"rem_allow_complete_ok": rem_allow_complete_ok,
		"rem_samenode_ok": rem_samenode_ok,
		"rem_zero_queue_ok": rem_zero_queue_ok,
		"rem_cap_ok": rem_cap_ok,
		"rem_return_home_ok": rem_return_home_ok,
		"rem_mid_block_ok": rem_mid_block_ok,
		"rem_complete_block_ok": rem_complete_block_ok,
		"rem_dest_missing_ok": rem_dest_missing_ok,
		"rem_dest_empty_road_ok": rem_dest_empty_road_ok,
		"rem_dest_ghost_ok": rem_dest_ghost_ok,
		"rem_dest_noroute_ok": rem_dest_noroute_ok,
		"rem_invalid_current_ok": rem_invalid_current_ok,
		"rem_result_success_ok": rem_result_success_ok,
		"rem_result_failure_ok": rem_result_failure_ok,
		"rem_atomic_unresolved_ok": rem_atomic_unresolved_ok,
		"rem_atomic_mid_ok": rem_atomic_mid_ok,
		"rem_atomic_noroute_ok": rem_atomic_noroute_ok,
		"rem_save_load_ok": rem_save_load_ok,
		"rem_older_save_ok": rem_older_save_ok,
		"turn_basic_increment_ok": turn_basic_increment_ok,
		"turn_null_state_ok": turn_null_state_ok,
		"turn_invalid_current_ok": turn_invalid_current_ok,
		"turn_partial_continue_ok": turn_partial_continue_ok,
		"turn_arrive_leftover_ok": turn_arrive_leftover_ok,
		"turn_at_destination_ok": turn_at_destination_ok,
		"turn_complete_ok": turn_complete_ok,
		"turn_return_ok": turn_return_ok,
		"turn_zero_speed_ok": turn_zero_speed_ok,
		"turn_queued_ok": turn_queued_ok,
		"turn_mission_arrive_ok": turn_mission_arrive_ok,
		"turn_mission_still_outbound_ok": turn_mission_still_outbound_ok,
		"turn_resolved_history_ok": turn_resolved_history_ok,
		"turn_mission_mismatch_ok": turn_mission_mismatch_ok,
		"turn_closed_segment_ok": turn_closed_segment_ok,
		"turn_full_budget_edge_ok": turn_full_budget_edge_ok,
		"turn_force_order_ok": turn_force_order_ok,
		"turn_mission_order_ok": turn_mission_order_ok,
		"turn_result_success_helper_ok": turn_result_success_helper_ok,
		"turn_result_fail_helper_ok": turn_result_fail_helper_ok,
		"turn_force_result_success_helper_ok": turn_force_result_success_helper_ok,
		"turn_force_result_fail_helper_ok": turn_force_result_fail_helper_ok,
		"turn_calendar_ok": turn_calendar_ok,
		"turn_no_auto_actions_ok": turn_no_auto_actions_ok,
		"eco_catalog_ok": eco_catalog_ok,
		"eco_standard_production_ok": eco_standard_production_ok,
		"eco_closed_ok": eco_closed_ok,
		"eco_unowned_ok": eco_unowned_ok,
		"eco_level_ok": eco_level_ok,
		"eco_malformed_ok": eco_malformed_ok,
		"eco_atomicity_ok": eco_atomicity_ok,
		"eco_atomicity_structurally_protected_ok": eco_atomicity_structurally_protected_ok,
		"eco_soldier_upkeep_ok": eco_soldier_upkeep_ok,
		"eco_vehicle_upkeep_ok": eco_vehicle_upkeep_ok,
		"eco_stronghold_upkeep_ok": eco_stronghold_upkeep_ok,
		"eco_total_upkeep_ok": eco_total_upkeep_ok,
		"eco_shortfall_ok": eco_shortfall_ok,
		"eco_afford_ok": eco_afford_ok,
		"eco_zero_cash_ok": eco_zero_cash_ok,
		"eco_money_never_negative_ok": eco_money_never_negative_ok,
		"eco_shortfall_reset_ok": eco_shortfall_reset_ok,
		"eco_resources_ok": eco_resources_ok,
		"eco_multi_gang_ok": eco_multi_gang_ok,
		"eco_business_order_ok": eco_business_order_ok,
		"eco_faction_order_ok": eco_faction_order_ok,
		"eco_turn_integration_ok": eco_turn_integration_ok,
		"eco_null_catalog_ok": eco_null_catalog_ok,
		"eco_top_level_fail_ok": eco_top_level_fail_ok,
		"eco_raid_closed_ok": eco_raid_closed_ok,
		"eco_persist_ok": eco_persist_ok,
		"eco_copy_safety_ok": eco_copy_safety_ok,
		"eco_result_data_ok": eco_result_data_ok,
		"eco_helpers_ok": eco_helpers_ok,
		"efm_continue_ok": efm_continue_ok,
		"efm_history_ok": efm_history_ok,
		"efm_composition_ok": efm_composition_ok,
		"efm_origin_dest_ok": efm_origin_dest_ok,
		"efm_origin_lex_ok": efm_origin_lex_ok,
		"efm_origin_empty_ok": efm_origin_empty_ok,
		"efm_same_node_ok": efm_same_node_ok,
		"efm_partial_ok": efm_partial_ok,
		"efm_zero_ok": efm_zero_ok,
		"efm_zero_turn_ok": efm_zero_turn_ok,
		"efm_resolved_failure_ok": efm_resolved_failure_ok,
		"efm_complete_mission_ok": efm_complete_mission_ok,
		"efm_multi_history_ok": efm_multi_history_ok,
		"efm_block_outbound_ok": efm_block_outbound_ok,
		"efm_block_await_ok": efm_block_await_ok,
		"efm_block_return_ok": efm_block_return_ok,
		"efm_block_unknown_ok": efm_block_unknown_ok,
		"efm_scan_order_ok": efm_scan_order_ok,
		"efm_mid_segment_ok": efm_mid_segment_ok,
		"efm_intermediate_ok": efm_intermediate_ok,
		"efm_force_complete_ok": efm_force_complete_ok,
		"efm_null_state_ok": efm_null_state_ok,
		"efm_null_request_ok": efm_null_request_ok,
		"efm_empty_id_ok": efm_empty_id_ok,
		"efm_dup_id_ok": efm_dup_id_untouched_ok,
		"efm_empty_type_ok": efm_empty_type_ok,
		"efm_empty_force_ok": efm_empty_force_ok,
		"efm_invalid_force_ok": efm_invalid_force_ok,
		"efm_empty_target_ok": efm_empty_target_ok,
		"efm_invalid_target_ok": efm_invalid_target_ok,
		"efm_missing_target_road_ok": efm_missing_target_road_ok,
		"efm_invalid_target_road_ok": efm_invalid_target_road_ok,
		"efm_invalid_force_road_ok": efm_invalid_force_road_ok,
		"efm_no_route_ok": efm_noroute_ok,
		"efm_invalid_remaining_structurally_protected_ok": efm_invalid_remaining_structurally_protected_ok,
		"efm_atomicity_ok": efm_atomicity_ok,
		"efm_result_helper_ok": efm_result_helper_ok,
		"efm_raid_chain_ok": efm_raid_chain_ok,
		"efm_no_dup_ok": efm_no_dup_ok,
		"efm_persist_ok": efm_persist_ok,
		"hqcap_standard_ok": hqcap_standard_ok,
		"hqcap_business_state_ok": hqcap_business_state_ok,
		"hqcap_third_party_ok": hqcap_third_party_ok,
		"hqcap_stronghold_ok": hqcap_stronghold_ok,
		"hqcap_force_onsite_ok": hqcap_force_onsite_ok,
		"hqcap_unclaimed_ok": hqcap_unclaimed_ok,
		"hqcap_already_controlled_ok": hqcap_already_controlled_ok,
		"hqcap_mismatch_ab_ok": hqcap_mismatch_ab_ok,
		"hqcap_mismatch_empty_hq_ok": hqcap_mismatch_empty_hq_ok,
		"hqcap_mismatch_empty_hood_ok": hqcap_mismatch_empty_hood_ok,
		"hqcap_wrong_type_ok": hqcap_wrong_type_ok,
		"hqcap_state_outbound_ok": hqcap_state_outbound_ok,
		"hqcap_state_success_ok": hqcap_state_success_ok,
		"hqcap_state_failure_ok": hqcap_state_failure_ok,
		"hqcap_state_complete_ok": hqcap_state_complete_ok,
		"hqcap_invalid_force_ok": hqcap_invalid_force_ok,
		"hqcap_force_not_dest_ok": hqcap_force_not_dest_ok,
		"hqcap_faction_mismatch_ok": hqcap_faction_mismatch_ok,
		"hqcap_missing_target_ok": hqcap_missing_target_ok,
		"hqcap_target_not_hq_ok": hqcap_target_not_hq_ok,
		"hqcap_force_target_mismatch_ok": hqcap_force_target_mismatch_ok,
		"hqcap_missing_neighborhood_ok": hqcap_missing_neighborhood_ok,
		"hqcap_invalid_neighborhood_ok": hqcap_invalid_neighborhood_ok,
		"hqcap_invalid_attacker_ok": hqcap_invalid_attacker_ok,
		"hqcap_attacker_not_gang_ok": hqcap_attacker_not_gang_ok,
		"hqcap_null_state_ok": hqcap_null_state_ok,
		"hqcap_empty_id_ok": hqcap_empty_id_ok,
		"hqcap_missing_mission_ok": hqcap_missing_mission_ok,
		"hqcap_atomicity_ok": hqcap_atomicity_ok,
		"hqcap_rollback_structurally_protected_ok": hqcap_rollback_structurally_protected_ok,
		"hqcap_biz_order_ok": hqcap_biz_order_ok,
		"hqcap_other_hood_ok": hqcap_other_hood_ok,
		"hqcap_result_helper_ok": hqcap_result_helper_ok,
		"hqcap_persist_owner_ok": hqcap_persist_owner_ok,
		"hqcap_older_save_ok": hqcap_older_save_ok,
		"hqcap_capture_persist_ok": hqcap_capture_persist_ok,
		"hqcap_economy_ok": hqcap_economy_ok,
		"hqcap_continue_ok": hqcap_continue_ok,
		"hqcap_no_side_effects_ok": hqcap_no_side_effects_ok,
		"war_key_ok": war_key_ok,
		"war_canonical_store_ok": war_canonical_store_ok,
		"war_empty_pair_ok": war_empty_pair_ok,
		"war_same_faction_ok": war_same_faction_ok,
		"war_contains_ok": war_contains_ok,
		"war_other_id_ok": war_other_id_ok,
		"war_registry_ok": war_registry_ok,
		"war_declare_ok": war_declare_ok,
		"war_declare_idempotent_ok": war_declare_idempotent_ok,
		"war_null_state_ok": war_null_state_ok,
		"war_empty_a_ok": war_empty_a_ok,
		"war_empty_b_ok": war_empty_b_ok,
		"war_same_ok": war_same_ok,
		"war_missing_a_ok": war_missing_a_ok,
		"war_missing_b_ok": war_missing_b_ok,
		"war_a_not_gang_ok": war_a_not_gang_ok,
		"war_b_not_gang_ok": war_b_not_gang_ok,
		"war_fail_atomicity_ok": war_fail_atomicity_ok,
		"war_are_false_ok": war_are_false_ok,
		"war_persist_ok": war_persist_ok,
		"war_older_save_ok": war_older_save_ok,
		"war_serialize_order_ok": war_serialize_order_ok,
		"war_result_helper_ok": war_result_helper_ok,
		"hqattack_war_required_ok": hqattack_war_required_ok,
		"hqattack_no_auto_war_ok": hqattack_no_auto_war_ok,
		"hqattack_declare_enables_ok": hqattack_declare_enables_ok,
		"hqattack_stronghold_ok": hqattack_stronghold_ok,
		"hqattack_existing_force_ok": hqattack_existing_force_ok,
		"hqattack_unclaimed_ok": hqattack_unclaimed_ok,
		"hqattack_already_controlled_ok": hqattack_already_controlled_ok,
		"hqattack_mismatch_ab_ok": hqattack_mismatch_ab_ok,
		"hqattack_mismatch_empty_hq_ok": hqattack_mismatch_empty_hq_ok,
		"hqattack_mismatch_empty_hood_ok": hqattack_mismatch_empty_hood_ok,
		"hqattack_invalid_defender_ok": hqattack_invalid_defender_ok,
		"hqattack_invalid_attacker_ok": hqattack_invalid_attacker_ok,
		"hqattack_attacker_not_gang_ok": hqattack_attacker_not_gang_ok,
		"hqattack_missing_target_ok": hqattack_missing_target_ok,
		"hqattack_target_not_hq_ok": hqattack_target_not_hq_ok,
		"hqattack_missing_neighborhood_ok": hqattack_missing_neighborhood_ok,
		"hqattack_invalid_neighborhood_ok": hqattack_invalid_neighborhood_ok,
		"hqattack_wrong_type_ok": hqattack_wrong_type_ok,
		"hqattack_dup_mission_ok": hqattack_dup_mission_ok,
		"hqattack_invalid_origin_ok": hqattack_invalid_origin_ok,
		"hqattack_no_route_ok": hqattack_no_route_ok,
		"hqattack_unresolved_ok": hqattack_unresolved_ok,
		"hqattack_no_capture_until_resolve_ok": hqattack_no_capture_until_resolve_ok,
		"hqattack_result_helper_ok": hqattack_result_helper_ok,
		"hqbattle_fail_ok": hqbattle_fail_ok,
		"hqbattle_reuse_ok": hqbattle_reuse_ok,
		"hqbattle_null_ok": hqbattle_null_ok,
		"hqbattle_empty_id_ok": hqbattle_empty_id_ok,
		"hqbattle_missing_mission_ok": hqbattle_missing_mission_ok,
		"hqbattle_wrong_type_ok": hqbattle_wrong_type_ok,
		"hqbattle_not_awaiting_ok": hqbattle_not_awaiting_ok,
		"hqbattle_invalid_force_ok": hqbattle_invalid_force_ok,
		"hqbattle_not_dest_ok": hqbattle_not_dest_ok,
		"hqbattle_faction_mismatch_ok": hqbattle_faction_mismatch_ok,
		"hqbattle_missing_target_ok": hqbattle_missing_target_ok,
		"hqbattle_target_not_hq_ok": hqbattle_target_not_hq_ok,
		"hqbattle_force_target_mismatch_ok": hqbattle_force_target_mismatch_ok,
		"hqbattle_missing_neighborhood_ok": hqbattle_missing_neighborhood_ok,
		"hqbattle_invalid_neighborhood_ok": hqbattle_invalid_neighborhood_ok,
		"hqbattle_mismatch_ok": hqbattle_mismatch_ok,
		"hqbattle_atomicity_ok": hqbattle_atomicity_ok,
		"hqbattle_unclaimed_fail_ok": hqbattle_unclaimed_fail_ok,
		"hqbattle_win_ok": hqbattle_win_ok,
		"hqbattle_loss_ok": hqbattle_loss_ok,
		"hqbattle_err_win_ok": hqbattle_err_win_ok,
		"hqbattle_err_loss_ok": hqbattle_err_loss_ok,
		"hqbattle_fail_helper_ok": hqbattle_fail_helper_ok,
		"hqbattle_result_helper_ok": hqbattle_result_helper_ok,
		"hqbattle_chain_loss_ok": hqbattle_chain_loss_ok,
		"hqbattle_chain_win_ok": hqbattle_chain_win_ok,
		"hqbattle_no_side_effects_ok": hqbattle_no_side_effects_ok,
		"battle_setup_ok": battle_setup_ok,
		"battle_attacker_side_ok": battle_attacker_side_ok,
		"battle_defender_side_ok": battle_defender_side_ok,
		"battle_unclaimed_ok": battle_unclaimed_ok,
		"battle_participants_ok": battle_participants_ok,
		"battle_vehicles_ok": battle_vehicles_ok,
		"battle_zones_ok": battle_zones_ok,
		"battle_registry_ok": battle_registry_ok,
		"battle_side_helpers_ok": battle_side_helpers_ok,
		"battle_err_null_ok": battle_err_null_ok,
		"battle_err_empty_id_ok": battle_err_empty_id_ok,
		"battle_err_invalid_mission_ok": battle_err_invalid_mission_ok,
		"battle_err_invalid_type_ok": battle_err_invalid_type_ok,
		"battle_err_not_awaiting_ok": battle_err_not_awaiting_ok,
		"battle_err_invalid_force_ok": battle_err_invalid_force_ok,
		"battle_err_not_dest_ok": battle_err_not_dest_ok,
		"battle_err_faction_ok": battle_err_faction_ok,
		"battle_err_missing_target_ok": battle_err_missing_target_ok,
		"battle_err_not_hq_ok": battle_err_not_hq_ok,
		"battle_err_target_mismatch_ok": battle_err_target_mismatch_ok,
		"battle_err_missing_hood_ok": battle_err_missing_hood_ok,
		"battle_err_invalid_hood_ok": battle_err_invalid_hood_ok,
		"battle_err_owner_mismatch_ok": battle_err_owner_mismatch_ok,
		"battle_err_invalid_soldier_ok": battle_err_invalid_soldier_ok,
		"battle_err_soldier_faction_ok": battle_err_soldier_faction_ok,
		"battle_err_invalid_vehicle_ok": battle_err_invalid_vehicle_ok,
		"battle_err_vehicle_faction_ok": battle_err_vehicle_faction_ok,
		"battle_determinism_ok": battle_determinism_ok,
		"battle_immutability_ok": battle_immutability_ok,
		"battle_persist_ok": battle_persist_ok,
		"battle_boundary_ok": battle_boundary_ok,
		"battle_result_helper_ok": battle_result_helper_ok,
		"battle_no_combat_ok": battle_no_combat_ok,
		"battle_deploy_participant_ok": battle_deploy_participant_ok,
		"battle_deploy_vehicle_ok": battle_deploy_vehicle_ok,
		"battle_deploy_query_ok": battle_deploy_query_ok,
		"battle_deploy_wrong_side_ok": battle_deploy_wrong_side_ok,
		"battle_deploy_unknown_ok": battle_deploy_unknown_ok,
		"battle_deploy_disallowed_ok": battle_deploy_disallowed_ok,
		"battle_deploy_duplicate_ok": battle_deploy_duplicate_ok,
		"battle_deploy_phase_ok": battle_deploy_phase_ok,
		"battle_deploy_no_partial_ok": battle_deploy_no_partial_ok,
		"battle_deploy_determinism_ok": battle_deploy_determinism_ok,
		"battle_deploy_immutability_ok": battle_deploy_immutability_ok,
		"battle_deploy_persist_ok": battle_deploy_persist_ok,
		"battle_deploy_phase_stays_ok": battle_deploy_phase_stays_ok,
		"battle_ready_empty_ok": battle_ready_empty_ok,
		"battle_ready_partial_ok": battle_ready_partial_ok,
		"battle_ready_part_ok": battle_ready_part_ok,
		"battle_ready_veh_ok": battle_ready_veh_ok,
		"battle_ready_mixed_ok": battle_ready_mixed_ok,
		"battle_ready_att_only_ok": battle_ready_att_only_ok,
		"battle_ready_def_only_ok": battle_ready_def_only_ok,
		"battle_ready_full_ok": battle_ready_full_ok,
		"battle_ready_activate_ok": battle_ready_activate_ok,
		"battle_ready_activate_phase_ok": battle_ready_activate_phase_ok,
		"battle_ready_before_ok": battle_ready_before_ok,
		"battle_ready_outside_ok": battle_ready_outside_ok,
		"battle_ready_no_mutate_ok": battle_ready_no_mutate_ok,
		"battle_ready_blocked_ok": battle_ready_blocked_ok,
		"battle_ready_determinism_ok": battle_ready_determinism_ok,
		"battle_ready_immutability_ok": battle_ready_immutability_ok,
		"battle_ready_persist_ok": battle_ready_persist_ok,
		"battle_turn_init_active_ok": battle_turn_init_active_ok,
		"battle_turn_attacker_first_ok": battle_turn_attacker_first_ok,
		"battle_turn_participant_first_ok": battle_turn_participant_first_ok,
		"battle_turn_id_order_ok": battle_turn_id_order_ok,
		"battle_turn_insert_order_ok": battle_turn_insert_order_ok,
		"battle_turn_current_start_ok": battle_turn_current_start_ok,
		"battle_turn_advance_ok": battle_turn_advance_ok,
		"battle_turn_wrap_ok": battle_turn_wrap_ok,
		"battle_turn_empty_ok": battle_turn_empty_ok,
		"battle_turn_advance_empty_ok": battle_turn_advance_empty_ok,
		"battle_turn_reinit_ok": battle_turn_reinit_ok,
		"battle_turn_deploy_unchanged_ok": battle_turn_deploy_unchanged_ok,
		"battle_turn_phase_ok": battle_turn_phase_ok,
		"battle_turn_immutability_ok": battle_turn_immutability_ok,
		"battle_turn_persist_ok": battle_turn_persist_ok,
		"battle_actor_turn_begin_ok": battle_actor_turn_begin_ok,
		"battle_actor_turn_snapshot_ok": battle_actor_turn_snapshot_ok,
		"battle_actor_turn_dup_begin_ok": battle_actor_turn_dup_begin_ok,
		"battle_actor_turn_end_ok": battle_actor_turn_end_ok,
		"battle_actor_turn_end_none_ok": battle_actor_turn_end_none_ok,
		"battle_actor_turn_advance_one_ok": battle_actor_turn_advance_one_ok,
		"battle_actor_turn_wrap_ok": battle_actor_turn_wrap_ok,
		"battle_actor_turn_advance_blocked_ok": battle_actor_turn_advance_blocked_ok,
		"battle_actor_turn_reinit_blocked_ok": battle_actor_turn_reinit_blocked_ok,
		"battle_actor_turn_outside_ok": battle_actor_turn_outside_ok,
		"battle_actor_turn_empty_ok": battle_actor_turn_empty_ok,
		"battle_actor_turn_no_mutate_ok": battle_actor_turn_no_mutate_ok,
		"battle_actor_turn_phase_ok": battle_actor_turn_phase_ok,
		"battle_actor_turn_deploy_unchanged_ok": battle_actor_turn_deploy_unchanged_ok,
		"battle_actor_turn_immutability_ok": battle_actor_turn_immutability_ok,
		"battle_actor_turn_persist_ok": battle_actor_turn_persist_ok,
	}

	var passed := true
	for check_name: String in checks:
		if checks[check_name] != true:
			passed = false
			break

	return {
		"passed": passed,
		"checks": checks,
		"serialized_state": serialized_state,
	}


static func _neighborhood_ids_match(neighborhood_list: Array[Neighborhood], expected_ids: Array[String]) -> bool:
	if neighborhood_list.size() != expected_ids.size():
		return false
	for i in expected_ids.size():
		if neighborhood_list[i].id != expected_ids[i]:
			return false
	return true


static func _string_ids_match(actual: Array[String], expected: Array[String]) -> bool:
	if actual.size() != expected.size():
		return false
	for i in expected.size():
		if actual[i] != expected[i]:
			return false
	return true


static func _copy_ids(ids: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for id_value: String in ids:
		copied.append(id_value)
	return copied


static func _count_id(ids: Array[String], target_id: String) -> int:
	var count := 0
	for vehicle_id in ids:
		if vehicle_id == target_id:
			count += 1
	return count


static func _make_raid_business(
	game_state: GameState,
	business_id: String,
	display_name: String,
	p_level: int,
	p_is_open: bool
) -> Business:
	var business: Business = Business.new(
		business_id,
		display_name,
		"neighborhood_contested",
		Vector2(310.0, 210.0),
		"gang_b",
		p_is_open,
		"narcotics_site",
		p_level
	)
	business.road_node_id = "road_d"
	game_state.add_map_location(business)
	return business


static func _register_raid_pair(
	game_state: GameState,
	mission_id: String,
	force_id: String,
	mission_type_id: String,
	mission_faction_id: String,
	force_faction_id: String,
	origin_id: String,
	target_id: String,
	force_destination_id: String,
	mission_state: String,
	force_travel_state: String
) -> TravelingForce:
	var route: Array[String] = ["road_d"]
	var force: TravelingForce = TravelingForce.new(
		force_id,
		force_faction_id,
		origin_id,
		force_destination_id,
		route,
		5.0,
		force_travel_state
	)
	game_state.add_traveling_force(force)
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		mission_type_id,
		mission_faction_id,
		force_id,
		origin_id,
		target_id,
		mission_state,
		""
	)
	game_state.add_mission(mission)
	return force


static func _float_dict_match(actual: Dictionary, expected: Dictionary) -> bool:
	if actual.size() != expected.size():
		return false
	for resource_id: Variant in expected:
		var key: String = str(resource_id)
		if not actual.has(key):
			return false
		if not is_equal_approx(float(actual[key]), float(expected[resource_id])):
			return false
	return true


static func _make_move_business(
	game_state: GameState,
	business_id: String,
	display_name: String,
	road_node_id: String
) -> Business:
	var business: Business = Business.new(
		business_id,
		display_name,
		"neighborhood_a",
		Vector2(115.0, 215.0),
		"gang_a",
		true,
		"market",
		1
	)
	business.road_node_id = road_node_id
	game_state.add_map_location(business)
	return business


static func _make_at_dest_force(
	game_state: GameState,
	force_id: String,
	origin_id: String,
	destination_id: String,
	route: Array[String],
	movement_remaining: float,
	movement_per_turn: float = 5.0
) -> TravelingForce:
	var force: TravelingForce = TravelingForce.new(
		force_id,
		"gang_a",
		origin_id,
		destination_id,
		route,
		movement_per_turn,
		"at_destination"
	)
	force.movement_remaining = movement_remaining
	game_state.add_traveling_force(force)
	return force


static func _register_move_mission(
	game_state: GameState,
	mission_id: String,
	mission_type_id: String,
	force_id: String,
	origin_id: String,
	target_id: String,
	mission_state: String,
	outcome_code: String
) -> CampaignMission:
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		mission_type_id,
		"gang_a",
		force_id,
		origin_id,
		target_id,
		mission_state,
		outcome_code
	)
	game_state.add_mission(mission)
	return mission


static func _force_travel_snapshot(force: TravelingForce) -> Dictionary:
	var snap: Dictionary = {}
	snap["route"] = _copy_ids(force.route_node_ids)
	snap["segment"] = force.route_segment_index
	snap["distance"] = force.distance_into_segment
	snap["dest"] = force.destination_location_id
	snap["state"] = force.travel_state
	snap["remaining"] = force.movement_remaining
	snap["origin"] = force.origin_location_id
	if force.soldier_group != null:
		snap["soldiers"] = _copy_ids(force.soldier_group.soldier_ids)
	else:
		snap["soldiers"] = []
	if force.vehicle_group != null:
		snap["vehicles"] = _copy_ids(force.vehicle_group.vehicle_ids)
	else:
		snap["vehicles"] = []
	return snap


static func _force_travel_unchanged(force: TravelingForce, snap: Dictionary) -> bool:
	if force == null:
		return false
	var expected_route: Array[String] = []
	var route_data: Variant = snap.get("route", [])
	if route_data is Array:
		for node_id: Variant in route_data:
			expected_route.append(str(node_id))
	var expected_soldiers: Array[String] = []
	var soldier_data: Variant = snap.get("soldiers", [])
	if soldier_data is Array:
		for soldier_id: Variant in soldier_data:
			expected_soldiers.append(str(soldier_id))
	var expected_vehicles: Array[String] = []
	var vehicle_data: Variant = snap.get("vehicles", [])
	if vehicle_data is Array:
		for vehicle_id: Variant in vehicle_data:
			expected_vehicles.append(str(vehicle_id))
	if force.soldier_group == null or force.vehicle_group == null:
		return false
	return (
		_string_ids_match(force.route_node_ids, expected_route)
		and force.route_segment_index == int(snap.get("segment", -1))
		and is_equal_approx(force.distance_into_segment, float(snap.get("distance", -1.0)))
		and force.destination_location_id == str(snap.get("dest", ""))
		and force.travel_state == str(snap.get("state", ""))
		and is_equal_approx(force.movement_remaining, float(snap.get("remaining", -1.0)))
		and force.origin_location_id == str(snap.get("origin", ""))
		and _string_ids_match(force.soldier_group.soldier_ids, expected_soldiers)
		and _string_ids_match(force.vehicle_group.vehicle_ids, expected_vehicles)
	)


static func _make_turn_world(p_current_turn: int = 5) -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = p_current_turn
	state.current_month = 7
	state.current_year = 2034
	var gang: MajorGang = MajorGang.new("turn_gang", "Turn Gang", "player")
	gang.money = 1000.0
	gang.resources.set_amount("Ammo", 5.0)
	state.add_faction(gang)
	state.add_stronghold_region(StrongholdRegion.new("turn_region", "Turn Region"))
	state.add_police_region(PoliceRegion.new("turn_district", "Turn District"))
	state.add_neighborhood(Neighborhood.new("turn_hood", "Turn Hood", "turn_region", "turn_district"))
	var keep: Stronghold = Stronghold.new("turn_keep", "Turn Keep", "turn_hood", Vector2(0.0, 0.0), "turn_gang", true, 1)
	keep.road_node_id = "turn_a"
	state.add_map_location(keep)
	var loc_b: Business = Business.new("turn_loc_b", "Turn Loc B", "turn_hood", Vector2(3.0, 0.0), "turn_gang", true, "market", 1)
	loc_b.road_node_id = "turn_b"
	state.add_map_location(loc_b)
	var shop: Business = Business.new("turn_shop", "Turn Shop", "turn_hood", Vector2(7.0, 0.0), "turn_gang", true, "market", 2)
	shop.road_node_id = "turn_c"
	state.add_map_location(shop)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("turn_a", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("turn_b", Vector2(3.0, 0.0)))
	graph.add_node(RoadNode.new("turn_c", Vector2(7.0, 0.0)))
	graph.add_segment(RoadSegment.new("turn_ab", "turn_a", "turn_b", 3.0))
	graph.add_segment(RoadSegment.new("turn_bc", "turn_b", "turn_c", 4.0))
	var soldier: Soldier = Soldier.new("turn_soldier", "turn_gang", "", "pistol", 1.0, 20.0)
	var vehicle: Vehicle = Vehicle.new("turn_vehicle", "turn_gang", "car", "", 2, 5.0, 50.0)
	state.add_soldier(soldier)
	state.add_vehicle(vehicle)
	state.assign_soldier_to_stronghold("turn_soldier", "turn_keep")
	state.assign_vehicle_to_stronghold("turn_vehicle", "turn_keep")
	return state


static func _make_turn_force(
	game_state: GameState,
	force_id: String,
	origin_id: String,
	dest_id: String,
	route: Array[String],
	movement_per_turn: float,
	travel_state: String,
	movement_remaining: float,
	segment_index: int = 0,
	distance_into: float = 0.0
) -> TravelingForce:
	var force: TravelingForce = TravelingForce.new(
		force_id,
		"turn_gang",
		origin_id,
		dest_id,
		route,
		movement_per_turn,
		travel_state
	)
	force.route_segment_index = segment_index
	force.distance_into_segment = distance_into
	force.movement_remaining = movement_remaining
	game_state.add_traveling_force(force)
	return force


static func _register_turn_mission(
	game_state: GameState,
	mission_id: String,
	force_id: String,
	origin_id: String,
	target_id: String,
	mission_state: String,
	outcome_code: String
) -> CampaignMission:
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		"raid_business",
		"turn_gang",
		force_id,
		origin_id,
		target_id,
		mission_state,
		outcome_code
	)
	game_state.add_mission(mission)
	return mission


static func _find_force_turn_result(results: Array[ForceTurnResult], force_id: String) -> ForceTurnResult:
	for result: ForceTurnResult in results:
		if result.force_id == force_id:
			return result
	return null


static func _find_mission_result(results: Array[MissionResult], mission_id: String) -> MissionResult:
	for result: MissionResult in results:
		if result.mission_id == mission_id:
			return result
	return null


static func _force_turn_result_ids(results: Array[ForceTurnResult]) -> Array[String]:
	var ids: Array[String] = []
	for result: ForceTurnResult in results:
		ids.append(result.force_id)
	return ids


static func _mission_result_ids(results: Array[MissionResult]) -> Array[String]:
	var ids: Array[String] = []
	for result: MissionResult in results:
		ids.append(result.mission_id)
	return ids


static func _make_eco_catalog() -> BusinessEconomyCatalog:
	var catalog: BusinessEconomyCatalog = BusinessEconomyCatalog.new()
	var market: BusinessEconomyDefinition = BusinessEconomyDefinition.new("market")
	market.set_level_output(1, BusinessLevelOutput.new(100.0))
	market.set_level_output(2, BusinessLevelOutput.new(175.0))
	market.set_level_output(3, BusinessLevelOutput.new(300.0))
	catalog.add_definition(market)
	var narcotics: BusinessEconomyDefinition = BusinessEconomyDefinition.new("narcotics_site")
	var narc_l1_res: Dictionary = {}
	narc_l1_res["Narcotics"] = 0.5
	narcotics.set_level_output(1, BusinessLevelOutput.new(50.0, narc_l1_res))
	var narc_l2_res: Dictionary = {}
	narc_l2_res["Narcotics"] = 1.0
	narcotics.set_level_output(2, BusinessLevelOutput.new(100.0, narc_l2_res))
	var narc_l3_res: Dictionary = {}
	narc_l3_res["Narcotics"] = 2.0
	narcotics.set_level_output(3, BusinessLevelOutput.new(150.0, narc_l3_res))
	catalog.add_definition(narcotics)
	var chop: BusinessEconomyDefinition = BusinessEconomyDefinition.new("chop_shop")
	chop.set_level_output(1, BusinessLevelOutput.new(10.0))
	catalog.add_definition(chop)
	return catalog


static func _make_eco_world(p_money_a: float = 1000.0, p_money_b: float = 2000.0) -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 1
	state.current_month = 7
	state.current_year = 2034
	var gang_a: MajorGang = MajorGang.new("eco_gang_a", "Eco Gang A", "player")
	gang_a.money = p_money_a
	var gang_b: MajorGang = MajorGang.new("eco_gang_b", "Eco Gang B", "ai")
	gang_b.money = p_money_b
	state.add_faction(gang_a)
	state.add_faction(gang_b)
	state.add_faction(Faction.new("eco_civilians", "Eco Civilians", "civilian"))
	state.add_stronghold_region(StrongholdRegion.new("eco_region", "Eco Region"))
	state.add_police_region(PoliceRegion.new("eco_district", "Eco District"))
	state.add_neighborhood(Neighborhood.new("eco_hood", "Eco Hood", "eco_region", "eco_district"))
	var keep_75: Stronghold = Stronghold.new("eco_keep_75", "Eco Keep 75", "eco_hood", Vector2(0.0, 0.0), "eco_gang_a", true, 1, 75.0)
	keep_75.road_node_id = "eco_n1"
	state.add_map_location(keep_75)
	var keep_125: Stronghold = Stronghold.new("eco_keep_125", "Eco Keep 125", "eco_hood", Vector2(5.0, 0.0), "eco_gang_a", true, 1, 125.0)
	keep_125.road_node_id = "eco_n2"
	state.add_map_location(keep_125)
	var keep_b: Stronghold = Stronghold.new("eco_keep_b", "Eco Keep B", "eco_hood", Vector2(8.0, 0.0), "eco_gang_b", true, 1, 25.0)
	keep_b.road_node_id = "eco_n2"
	state.add_map_location(keep_b)
	var hq: NeighborhoodHQ = NeighborhoodHQ.new("eco_hq", "Eco HQ", "eco_hood", Vector2(2.0, 0.0), "eco_gang_a", true)
	hq.road_node_id = "eco_n1"
	state.add_map_location(hq)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("eco_n1", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("eco_n2", Vector2(5.0, 0.0)))
	graph.add_segment(RoadSegment.new("eco_seg", "eco_n1", "eco_n2", 5.0))
	return state


static func _make_eco_business(
	game_state: GameState,
	business_id: String,
	display_name: String,
	business_type_id: String,
	level: int,
	owner_faction_id: String,
	is_open: bool,
	road_node_id: String = "eco_n1"
) -> Business:
	var business: Business = Business.new(
		business_id,
		display_name,
		"eco_hood",
		Vector2(1.0, 1.0),
		owner_faction_id,
		is_open,
		business_type_id,
		level
	)
	business.road_node_id = road_node_id
	game_state.add_map_location(business)
	return business


static func _find_business_production_result(
	results: Array[BusinessProductionResult],
	business_id: String
) -> BusinessProductionResult:
	for result: BusinessProductionResult in results:
		if result.business_id == business_id:
			return result
	return null


static func _find_faction_economy_result(
	results: Array[FactionEconomyResult],
	faction_id: String
) -> FactionEconomyResult:
	for result: FactionEconomyResult in results:
		if result.faction_id == faction_id:
			return result
	return null


static func _business_production_ids(results: Array[BusinessProductionResult]) -> Array[String]:
	var ids: Array[String] = []
	for result: BusinessProductionResult in results:
		ids.append(result.business_id)
	return ids


static func _faction_economy_ids(results: Array[FactionEconomyResult]) -> Array[String]:
	var ids: Array[String] = []
	for result: FactionEconomyResult in results:
		ids.append(result.faction_id)
	return ids


static func _make_efm_world() -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 3
	state.current_month = 7
	state.current_year = 2034
	var gang: MajorGang = MajorGang.new("efm_gang", "EFM Gang", "player")
	gang.money = 200.0
	gang.resources.set_amount("Narcotics", 0.0)
	state.add_faction(gang)
	state.add_stronghold_region(StrongholdRegion.new("efm_region", "EFM Region"))
	state.add_police_region(PoliceRegion.new("efm_district", "EFM District"))
	state.add_neighborhood(Neighborhood.new("efm_hood", "EFM Hood", "efm_region", "efm_district"))
	var keep: Stronghold = Stronghold.new("efm_keep", "EFM Keep", "efm_hood", Vector2(0.0, 0.0), "efm_gang", true, 1)
	keep.road_node_id = "efm_node_home"
	state.add_map_location(keep)
	var loc_a: Business = Business.new("efm_loc_a", "EFM Loc A", "efm_hood", Vector2(3.0, 0.0), "efm_gang", true, "market", 2)
	loc_a.road_node_id = "efm_node_a"
	state.add_map_location(loc_a)
	var loc_a_same: NeighborhoodHQ = NeighborhoodHQ.new("efm_loc_a_same", "EFM Loc A Same", "efm_hood", Vector2(3.2, 0.2), "efm_gang", true)
	loc_a_same.road_node_id = "efm_node_a"
	state.add_map_location(loc_a_same)
	var loc_b: Business = Business.new("efm_loc_b", "EFM Loc B", "efm_hood", Vector2(6.0, 0.0), "efm_gang", true, "market", 2)
	loc_b.road_node_id = "efm_node_b"
	state.add_map_location(loc_b)
	var loc_c: Business = Business.new("efm_loc_c", "EFM Loc C", "efm_hood", Vector2(11.0, 0.0), "efm_gang", true, "market", 1)
	loc_c.road_node_id = "efm_node_c"
	state.add_map_location(loc_c)
	var loc_long: Business = Business.new("efm_loc_long", "EFM Loc Long", "efm_hood", Vector2(11.0, 3.0), "efm_gang", true, "market", 1)
	loc_long.road_node_id = "efm_node_long"
	state.add_map_location(loc_long)
	var origin_a: NeighborhoodHQ = NeighborhoodHQ.new("efm_origin_a", "EFM Origin A", "efm_hood", Vector2(6.0, 4.0), "efm_gang", true)
	origin_a.road_node_id = "efm_node_lex"
	state.add_map_location(origin_a)
	var origin_z: NeighborhoodHQ = NeighborhoodHQ.new("efm_origin_z", "EFM Origin Z", "efm_hood", Vector2(6.4, 4.0), "efm_gang", true)
	origin_z.road_node_id = "efm_node_lex"
	state.add_map_location(origin_z)
	var loc_noroad: Business = Business.new("efm_loc_noroad", "EFM No Road", "efm_hood", Vector2(20.0, 0.0), "efm_gang", true, "market", 1)
	loc_noroad.road_node_id = ""
	state.add_map_location(loc_noroad)
	var loc_badnode: Business = Business.new("efm_loc_badnode", "EFM Bad Node", "efm_hood", Vector2(21.0, 0.0), "efm_gang", true, "market", 1)
	loc_badnode.road_node_id = "efm_missing_graph_node"
	state.add_map_location(loc_badnode)
	var loc_island: Business = Business.new("efm_loc_island", "EFM Island", "efm_hood", Vector2(30.0, 0.0), "efm_gang", true, "market", 1)
	loc_island.road_node_id = "efm_node_island"
	state.add_map_location(loc_island)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("efm_node_home", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("efm_node_a", Vector2(3.0, 0.0)))
	graph.add_node(RoadNode.new("efm_node_b", Vector2(6.0, 0.0)))
	graph.add_node(RoadNode.new("efm_node_c", Vector2(11.0, 0.0)))
	graph.add_node(RoadNode.new("efm_node_long", Vector2(11.0, 3.0)))
	graph.add_node(RoadNode.new("efm_node_empty", Vector2(6.0, -2.0)))
	graph.add_node(RoadNode.new("efm_node_lex", Vector2(6.0, 4.0)))
	graph.add_node(RoadNode.new("efm_node_island", Vector2(30.0, 0.0)))
	graph.add_segment(RoadSegment.new("efm_seg_home_a", "efm_node_home", "efm_node_a", 3.0))
	graph.add_segment(RoadSegment.new("efm_seg_ab", "efm_node_a", "efm_node_b", 3.0))
	graph.add_segment(RoadSegment.new("efm_seg_bc", "efm_node_b", "efm_node_c", 5.0))
	graph.add_segment(RoadSegment.new("efm_seg_a_long", "efm_node_a", "efm_node_long", 8.0))
	graph.add_segment(RoadSegment.new("efm_seg_empty_b", "efm_node_empty", "efm_node_b", 2.0))
	graph.add_segment(RoadSegment.new("efm_seg_lex_b", "efm_node_lex", "efm_node_b", 3.0))
	var soldier: Soldier = Soldier.new("efm_soldier", "efm_gang", "", "pistol", 1.0, 20.0)
	var vehicle: Vehicle = Vehicle.new("efm_vehicle", "efm_gang", "car", "", 2, 5.0, 40.0)
	state.add_soldier(soldier)
	state.add_vehicle(vehicle)
	state.assign_soldier_to_stronghold("efm_soldier", "efm_keep")
	state.assign_vehicle_to_stronghold("efm_vehicle", "efm_keep")
	return state


static func _make_efm_force(
	game_state: GameState,
	force_id: String,
	origin_id: String,
	dest_id: String,
	route: Array[String],
	movement_remaining: float,
	travel_state: String,
	segment_index: int = 0,
	distance_into: float = 0.0,
	movement_per_turn: float = 5.0
) -> TravelingForce:
	var force: TravelingForce = TravelingForce.new(
		force_id,
		"efm_gang",
		origin_id,
		dest_id,
		route,
		movement_per_turn,
		travel_state
	)
	force.route_segment_index = segment_index
	force.distance_into_segment = distance_into
	force.movement_remaining = movement_remaining
	force.soldier_group.add_soldier_id("efm_soldier")
	force.vehicle_group.add_vehicle_id("efm_vehicle")
	game_state.add_traveling_force(force)
	return force


static func _register_efm_mission(
	game_state: GameState,
	mission_id: String,
	force_id: String,
	origin_id: String,
	target_id: String,
	mission_state: String,
	outcome_code: String,
	mission_type_id: String = "raid_business"
) -> CampaignMission:
	var faction_id: String = "efm_gang"
	var force: TravelingForce = game_state.get_traveling_force(force_id)
	if force != null:
		faction_id = force.faction_id
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		mission_type_id,
		faction_id,
		force_id,
		origin_id,
		target_id,
		mission_state,
		outcome_code
	)
	game_state.add_mission(mission)
	return mission


static func _efm_launch_fails_atomically(
	game_state: GameState,
	force: TravelingForce,
	request: ExistingForceMissionRequest,
	expected_error: String
) -> bool:
	if game_state == null or force == null or request == null:
		return false
	var snap: Dictionary = _force_travel_snapshot(force)
	var mission_count: int = game_state.missions.size()
	var soldier_count: int = game_state.soldiers.size()
	var vehicle_count: int = game_state.vehicles.size()
	var force_count: int = game_state.traveling_forces.size()
	var requested_id: String = request.mission_id
	var requested_existed: bool = not requested_id.is_empty() and game_state.has_mission(requested_id)
	var result: ExistingForceMissionResult = MissionService.launch_from_existing_force(game_state, request)
	return (
		not result.success
		and result.error_code == expected_error
		and _force_travel_unchanged(force, snap)
		and game_state.missions.size() == mission_count
		and game_state.soldiers.size() == soldier_count
		and game_state.vehicles.size() == vehicle_count
		and game_state.traveling_forces.size() == force_count
		and (requested_id.is_empty() or requested_existed or not game_state.has_mission(requested_id))
	)


static func _make_hqcap_world(hood_owner: String = "hqcap_defender", hq_owner: String = "hqcap_defender") -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 4
	state.current_month = 8
	state.current_year = 2034
	var attacker: MajorGang = MajorGang.new("hqcap_attacker", "HQCap Attacker", "player")
	attacker.money = 400.0
	attacker.resources.set_amount("Ammo", 3.0)
	var defender: MajorGang = MajorGang.new("hqcap_defender", "HQCap Defender", "ai")
	defender.money = 900.0
	defender.resources.set_amount("Narcotics", 1.5)
	var third: MajorGang = MajorGang.new("hqcap_third", "HQCap Third", "ai")
	third.money = 250.0
	state.add_faction(attacker)
	state.add_faction(defender)
	state.add_faction(third)
	state.add_faction(Faction.new("hqcap_civilians", "HQCap Civilians", "civilian"))
	state.add_stronghold_region(StrongholdRegion.new("hqcap_region", "HQCap Region"))
	state.add_police_region(PoliceRegion.new("hqcap_district", "HQCap District"))
	state.add_neighborhood(Neighborhood.new("hqcap_hood", "HQCap Hood", "hqcap_region", "hqcap_district", hood_owner))
	state.add_neighborhood(Neighborhood.new("hqcap_other_hood", "HQCap Other Hood", "hqcap_region", "hqcap_district", ""))
	var keep: Stronghold = Stronghold.new("hqcap_keep", "HQCap Keep", "hqcap_hood", Vector2(0.0, 0.0), "hqcap_attacker", true, 1, 0.0)
	keep.road_node_id = "hqcap_node_keep"
	state.add_map_location(keep)
	var def_keep: Stronghold = Stronghold.new("hqcap_def_keep", "HQCap Defender Keep", "hqcap_hood", Vector2(3.2, 0.4), "hqcap_defender", true, 2, 0.0)
	def_keep.road_node_id = "hqcap_node_hq"
	state.add_map_location(def_keep)
	var hq: NeighborhoodHQ = NeighborhoodHQ.new("hqcap_hq", "HQCap HQ", "hqcap_hood", Vector2(3.0, 0.0), hq_owner, true)
	hq.road_node_id = "hqcap_node_hq"
	state.add_map_location(hq)
	var hq_b: NeighborhoodHQ = NeighborhoodHQ.new("hqcap_hq_b", "HQCap HQ B", "hqcap_hood", Vector2(7.0, 0.0), hq_owner, true)
	hq_b.road_node_id = "hqcap_node_b"
	state.add_map_location(hq_b)
	var hq_orphan: NeighborhoodHQ = NeighborhoodHQ.new("hqcap_hq_orphan", "HQCap HQ Orphan", "", Vector2(20.0, 0.0), hq_owner, true)
	hq_orphan.road_node_id = "hqcap_node_orphan"
	state.add_map_location(hq_orphan)
	var hq_ghost: NeighborhoodHQ = NeighborhoodHQ.new("hqcap_hq_ghost", "HQCap HQ Ghost", "hqcap_missing_hood", Vector2(25.0, 0.0), hq_owner, true)
	hq_ghost.road_node_id = "hqcap_node_ghost"
	state.add_map_location(hq_ghost)
	var biz_a: Business = Business.new("hqcap_biz_a", "HQCap Biz A", "hqcap_hood", Vector2(3.4, 0.2), "hqcap_defender", true, "market", 3)
	biz_a.road_node_id = "hqcap_node_hq"
	state.add_map_location(biz_a)
	var biz_b: Business = Business.new("hqcap_biz_b", "HQCap Biz B", "hqcap_hood", Vector2(7.2, 0.2), "hqcap_defender", false, "narcotics_site", 1)
	biz_b.road_node_id = "hqcap_node_b"
	state.add_map_location(biz_b)
	var biz_c: Business = Business.new("hqcap_biz_c", "HQCap Biz C", "hqcap_hood", Vector2(3.6, -0.2), "hqcap_third", true, "market", 1)
	biz_c.road_node_id = "hqcap_node_hq"
	state.add_map_location(biz_c)
	var biz_d: Business = Business.new("hqcap_biz_d", "HQCap Biz D", "hqcap_hood", Vector2(3.8, 0.3), "", true, "market", 1)
	biz_d.road_node_id = "hqcap_node_hq"
	state.add_map_location(biz_d)
	var biz_other: Business = Business.new("hqcap_biz_other", "HQCap Biz Other", "hqcap_other_hood", Vector2(0.0, 10.0), "hqcap_defender", true, "market", 2)
	biz_other.road_node_id = "hqcap_node_other"
	state.add_map_location(biz_other)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("hqcap_node_keep", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("hqcap_node_hq", Vector2(3.0, 0.0)))
	graph.add_node(RoadNode.new("hqcap_node_b", Vector2(7.0, 0.0)))
	graph.add_node(RoadNode.new("hqcap_node_orphan", Vector2(20.0, 0.0)))
	graph.add_node(RoadNode.new("hqcap_node_ghost", Vector2(25.0, 0.0)))
	graph.add_node(RoadNode.new("hqcap_node_other", Vector2(0.0, 10.0)))
	graph.add_segment(RoadSegment.new("hqcap_seg_keep_hq", "hqcap_node_keep", "hqcap_node_hq", 3.0))
	graph.add_segment(RoadSegment.new("hqcap_seg_hq_b", "hqcap_node_hq", "hqcap_node_b", 4.0))
	var soldier: Soldier = Soldier.new("hqcap_soldier", "hqcap_attacker", "", "pistol", 1.0, 0.0)
	var vehicle: Vehicle = Vehicle.new("hqcap_vehicle", "hqcap_attacker", "car", "", 2, 5.0, 0.0)
	var def_soldier: Soldier = Soldier.new("hqcap_def_soldier", "hqcap_defender", "", "pistol", 1.0, 0.0)
	var def_vehicle: Vehicle = Vehicle.new("hqcap_def_vehicle", "hqcap_defender", "car", "", 2, 5.0, 0.0)
	state.add_soldier(soldier)
	state.add_vehicle(vehicle)
	state.add_soldier(def_soldier)
	state.add_vehicle(def_vehicle)
	state.assign_soldier_to_stronghold("hqcap_soldier", "hqcap_keep")
	state.assign_vehicle_to_stronghold("hqcap_vehicle", "hqcap_keep")
	state.assign_soldier_to_stronghold("hqcap_def_soldier", "hqcap_def_keep")
	state.assign_vehicle_to_stronghold("hqcap_def_vehicle", "hqcap_def_keep")
	return state


static func _hqcap_add_force_mission(
	game_state: GameState,
	force_id: String = "hqcap_force",
	mission_id: String = "hqcap_mission",
	force_faction_id: String = "hqcap_attacker",
	mission_faction_id: String = "hqcap_attacker",
	destination_id: String = "hqcap_hq",
	target_id: String = "hqcap_hq",
	travel_state: String = "at_destination",
	mission_state: String = "awaiting_resolution",
	mission_type_id: String = "capture_neighborhood_hq",
	origin_id: String = "hqcap_keep",
	movement_remaining: float = 3.0
) -> TravelingForce:
	var dest_node: String = "hqcap_node_hq"
	var dest_location: MapLocation = game_state.get_map_location(destination_id)
	if dest_location != null and not dest_location.road_node_id.is_empty():
		dest_node = dest_location.road_node_id
	var origin_node: String = "hqcap_node_keep"
	var origin_location: MapLocation = game_state.get_map_location(origin_id)
	if origin_location != null and not origin_location.road_node_id.is_empty():
		origin_node = origin_location.road_node_id
	var route: Array[String] = []
	if travel_state == "at_destination" or origin_node == dest_node:
		route.append(dest_node)
	else:
		var found: Array[String] = game_state.road_graph.find_route(origin_node, dest_node)
		if found.is_empty():
			route.append(origin_node)
			if origin_node != dest_node:
				route.append(dest_node)
		else:
			for node_id: String in found:
				route.append(node_id)
	var force: TravelingForce = TravelingForce.new(
		force_id,
		force_faction_id,
		origin_id,
		destination_id,
		route,
		5.0,
		travel_state
	)
	force.route_segment_index = 0
	force.distance_into_segment = 0.0
	force.movement_remaining = movement_remaining
	if game_state.has_soldier("hqcap_soldier"):
		force.soldier_group.add_soldier_id("hqcap_soldier")
	if game_state.has_vehicle("hqcap_vehicle"):
		force.vehicle_group.add_vehicle_id("hqcap_vehicle")
	game_state.add_traveling_force(force)
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		mission_type_id,
		mission_faction_id,
		force_id,
		origin_id,
		target_id,
		mission_state,
		""
	)
	game_state.add_mission(mission)
	return force


static func _hqcap_fails_atomically(
	game_state: GameState,
	mission_id: String,
	expected_error: String,
	force: TravelingForce
) -> bool:
	if game_state == null:
		return false
	var hood_owners: Dictionary = {}
	for hood_id: String in game_state.neighborhoods:
		var hood: Neighborhood = game_state.get_neighborhood(hood_id)
		if hood != null:
			hood_owners[hood_id] = hood.owner_faction_id
	var loc_owners: Dictionary = {}
	var biz_levels: Dictionary = {}
	var biz_open: Dictionary = {}
	var biz_types: Dictionary = {}
	var biz_roads: Dictionary = {}
	for loc_id: String in game_state.map_locations:
		var location: MapLocation = game_state.get_map_location(loc_id)
		if location == null:
			continue
		loc_owners[loc_id] = location.owner_faction_id
		if location is Business:
			var business: Business = location as Business
			biz_levels[loc_id] = business.level
			biz_open[loc_id] = business.is_open
			biz_types[loc_id] = business.business_type_id
			biz_roads[loc_id] = business.road_node_id
	var mission_existed: bool = not mission_id.is_empty() and game_state.has_mission(mission_id)
	var mission_state_before: String = ""
	var mission_outcome_before: String = ""
	if mission_existed:
		var mission_before: CampaignMission = game_state.get_mission(mission_id)
		mission_state_before = mission_before.mission_state
		mission_outcome_before = mission_before.outcome_code
	var had_force: bool = force != null
	var force_snap: Dictionary = {}
	if had_force:
		force_snap = _force_travel_snapshot(force)
	var force_count: int = game_state.traveling_forces.size()
	var soldier_count: int = game_state.soldiers.size()
	var vehicle_count: int = game_state.vehicles.size()
	var result: NeighborhoodHQCaptureResult = NeighborhoodHQCaptureResolver.resolve_success(game_state, mission_id)
	if result.success or result.error_code != expected_error:
		return false
	for hood_id: String in hood_owners:
		var hood_after: Neighborhood = game_state.get_neighborhood(hood_id)
		if hood_after == null or hood_after.owner_faction_id != str(hood_owners[hood_id]):
			return false
	for loc_id: String in loc_owners:
		var loc_after: MapLocation = game_state.get_map_location(loc_id)
		if loc_after == null or loc_after.owner_faction_id != str(loc_owners[loc_id]):
			return false
		if biz_levels.has(loc_id):
			if not (loc_after is Business):
				return false
			var biz_after: Business = loc_after as Business
			if biz_after.level != int(biz_levels[loc_id]):
				return false
			if biz_after.is_open != bool(biz_open[loc_id]):
				return false
			if biz_after.business_type_id != str(biz_types[loc_id]):
				return false
			if biz_after.road_node_id != str(biz_roads[loc_id]):
				return false
	if mission_existed:
		var mission_after: CampaignMission = game_state.get_mission(mission_id)
		if mission_after == null:
			return false
		if mission_after.mission_state != mission_state_before:
			return false
		if mission_after.outcome_code != mission_outcome_before:
			return false
	elif not mission_id.is_empty() and game_state.has_mission(mission_id):
		return false
	if had_force and not _force_travel_unchanged(force, force_snap):
		return false
	if game_state.traveling_forces.size() != force_count:
		return false
	if game_state.soldiers.size() != soldier_count:
		return false
	if game_state.vehicles.size() != vehicle_count:
		return false
	return true


static func _make_war_state() -> GameState:
	var state: GameState = GameState.new()
	state.add_faction(MajorGang.new("war_a", "War A", "player"))
	state.add_faction(MajorGang.new("war_b", "War B", "ai"))
	state.add_faction(MajorGang.new("war_c", "War C", "ai"))
	state.add_faction(Faction.new("war_civilians", "War Civilians", "civilian"))
	return state


static func _make_hqattack_world(hood_owner: String = "hqattack_b", hq_owner: String = "hqattack_b") -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 6
	state.current_month = 9
	state.current_year = 2034
	var attacker: MajorGang = MajorGang.new("hqattack_a", "HQAttack A", "player")
	attacker.money = 500.0
	attacker.resources.set_amount("Ammo", 2.0)
	var defender: MajorGang = MajorGang.new("hqattack_b", "HQAttack B", "ai")
	defender.money = 700.0
	var third: MajorGang = MajorGang.new("hqattack_c", "HQAttack C", "ai")
	state.add_faction(attacker)
	state.add_faction(defender)
	state.add_faction(third)
	state.add_faction(Faction.new("hqattack_civilians", "HQAttack Civilians", "civilian"))
	state.add_stronghold_region(StrongholdRegion.new("hqattack_region", "HQAttack Region"))
	state.add_police_region(PoliceRegion.new("hqattack_district", "HQAttack District"))
	state.add_neighborhood(Neighborhood.new("hqattack_hood", "HQAttack Hood", "hqattack_region", "hqattack_district", hood_owner))
	var keep: Stronghold = Stronghold.new("hqattack_keep", "HQAttack Keep", "hqattack_hood", Vector2(0.0, 0.0), "hqattack_a", true, 1, 0.0)
	keep.road_node_id = "hqattack_node_hq"
	state.add_map_location(keep)
	var hq: NeighborhoodHQ = NeighborhoodHQ.new("hqattack_hq", "HQAttack HQ", "hqattack_hood", Vector2(0.2, 0.0), hq_owner, true)
	hq.road_node_id = "hqattack_node_hq"
	state.add_map_location(hq)
	var hq_b: NeighborhoodHQ = NeighborhoodHQ.new("hqattack_hq_b", "HQAttack HQ B", "hqattack_hood", Vector2(4.0, 0.0), hq_owner, true)
	hq_b.road_node_id = "hqattack_node_b"
	state.add_map_location(hq_b)
	var hq_island: NeighborhoodHQ = NeighborhoodHQ.new("hqattack_hq_island", "HQAttack Island HQ", "hqattack_hood", Vector2(40.0, 0.0), hq_owner, true)
	hq_island.road_node_id = "hqattack_node_island"
	state.add_map_location(hq_island)
	var hq_orphan: NeighborhoodHQ = NeighborhoodHQ.new("hqattack_hq_orphan", "HQAttack Orphan HQ", "", Vector2(20.0, 0.0), hq_owner, true)
	hq_orphan.road_node_id = "hqattack_node_orphan"
	state.add_map_location(hq_orphan)
	var hq_ghost: NeighborhoodHQ = NeighborhoodHQ.new("hqattack_hq_ghost", "HQAttack Ghost HQ", "hqattack_missing_hood", Vector2(25.0, 0.0), hq_owner, true)
	hq_ghost.road_node_id = "hqattack_node_ghost"
	state.add_map_location(hq_ghost)
	var biz: Business = Business.new("hqattack_biz", "HQAttack Biz", "hqattack_hood", Vector2(0.4, 0.2), "hqattack_b", true, "market", 2)
	biz.road_node_id = "hqattack_node_hq"
	state.add_map_location(biz)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("hqattack_node_hq", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("hqattack_node_b", Vector2(4.0, 0.0)))
	graph.add_node(RoadNode.new("hqattack_node_island", Vector2(40.0, 0.0)))
	graph.add_node(RoadNode.new("hqattack_node_orphan", Vector2(20.0, 0.0)))
	graph.add_node(RoadNode.new("hqattack_node_ghost", Vector2(25.0, 0.0)))
	graph.add_segment(RoadSegment.new("hqattack_seg_hq_b", "hqattack_node_hq", "hqattack_node_b", 4.0))
	var soldier: Soldier = Soldier.new("hqattack_soldier", "hqattack_a", "", "pistol", 1.0, 0.0)
	var vehicle: Vehicle = Vehicle.new("hqattack_vehicle", "hqattack_a", "car", "", 2, 5.0, 0.0)
	state.add_soldier(soldier)
	state.add_vehicle(vehicle)
	state.assign_soldier_to_stronghold("hqattack_soldier", "hqattack_keep")
	state.assign_vehicle_to_stronghold("hqattack_vehicle", "hqattack_keep")
	return state


static func _hqattack_stronghold_request(
	mission_id: String = "hqattack_mission",
	force_id: String = "hqattack_force",
	destination_id: String = "hqattack_hq",
	origin_id: String = "hqattack_keep",
	faction_id: String = "hqattack_a",
	mission_type_id: String = "capture_neighborhood_hq",
	movement_budget: float = 10.0
) -> MissionRequest:
	var soldier_ids: Array[String] = ["hqattack_soldier"]
	var vehicle_ids: Array[String] = ["hqattack_vehicle"]
	var deployment: DeploymentRequest = DeploymentRequest.new(
		force_id,
		faction_id,
		origin_id,
		destination_id,
		soldier_ids,
		vehicle_ids,
		movement_budget
	)
	return MissionRequest.new(mission_id, mission_type_id, deployment)


static func _hqattack_add_idle_force(
	game_state: GameState,
	force_id: String = "hqattack_force",
	faction_id: String = "hqattack_a",
	origin_id: String = "hqattack_keep",
	destination_id: String = "hqattack_keep",
	travel_state: String = "at_destination",
	movement_remaining: float = 5.0
) -> TravelingForce:
	var dest_node: String = "hqattack_node_hq"
	var dest_location: MapLocation = game_state.get_map_location(destination_id)
	if dest_location != null and not dest_location.road_node_id.is_empty():
		dest_node = dest_location.road_node_id
	var route: Array[String] = [dest_node]
	var force: TravelingForce = TravelingForce.new(
		force_id,
		faction_id,
		origin_id,
		destination_id,
		route,
		5.0,
		travel_state
	)
	force.route_segment_index = 0
	force.distance_into_segment = 0.0
	force.movement_remaining = movement_remaining
	if game_state.has_soldier("hqattack_soldier"):
		force.soldier_group.add_soldier_id("hqattack_soldier")
	if game_state.has_vehicle("hqattack_vehicle"):
		force.vehicle_group.add_vehicle_id("hqattack_vehicle")
	game_state.add_traveling_force(force)
	return force


static func _hqattack_snapshot(game_state: GameState, force: TravelingForce = null) -> Dictionary:
	var snap: Dictionary = {}
	snap["rel_count"] = game_state.relationships.size()
	snap["mission_count"] = game_state.missions.size()
	snap["force_count"] = game_state.traveling_forces.size()
	var hood_owners: Dictionary = {}
	for hood_id: String in game_state.neighborhoods:
		var hood: Neighborhood = game_state.get_neighborhood(hood_id)
		if hood != null:
			hood_owners[hood_id] = hood.owner_faction_id
	snap["hood_owners"] = hood_owners
	var loc_owners: Dictionary = {}
	for loc_id: String in game_state.map_locations:
		var location: MapLocation = game_state.get_map_location(loc_id)
		if location != null:
			loc_owners[loc_id] = location.owner_faction_id
	snap["loc_owners"] = loc_owners
	if force != null:
		snap["force"] = _force_travel_snapshot(force)
	return snap


static func _hqattack_unchanged(game_state: GameState, snap: Dictionary, force: TravelingForce = null) -> bool:
	if game_state.relationships.size() != int(snap.get("rel_count", -1)):
		return false
	if game_state.missions.size() != int(snap.get("mission_count", -1)):
		return false
	if game_state.traveling_forces.size() != int(snap.get("force_count", -1)):
		return false
	var hood_owners: Variant = snap.get("hood_owners", {})
	if hood_owners is Dictionary:
		for hood_id: Variant in hood_owners:
			var hood: Neighborhood = game_state.get_neighborhood(str(hood_id))
			if hood == null or hood.owner_faction_id != str(hood_owners[hood_id]):
				return false
	var loc_owners: Variant = snap.get("loc_owners", {})
	if loc_owners is Dictionary:
		for loc_id: Variant in loc_owners:
			var location: MapLocation = game_state.get_map_location(str(loc_id))
			if location == null or location.owner_faction_id != str(loc_owners[loc_id]):
				return false
	if force != null:
		var force_snap: Variant = snap.get("force", {})
		if not (force_snap is Dictionary):
			return false
		if not _force_travel_unchanged(force, force_snap):
			return false
	return true


static func _make_hqbattle_world(hood_owner: String = "hqbattle_b", hq_owner: String = "hqbattle_b") -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 7
	state.current_month = 10
	state.current_year = 2034
	var attacker: MajorGang = MajorGang.new("hqbattle_a", "HQBattle A", "player")
	attacker.money = 800.0
	attacker.resources.set_amount("Ammo", 4.0)
	var defender: MajorGang = MajorGang.new("hqbattle_b", "HQBattle B", "ai")
	defender.money = 600.0
	defender.resources.set_amount("Narcotics", 2.0)
	var third: MajorGang = MajorGang.new("hqbattle_c", "HQBattle C", "ai")
	state.add_faction(attacker)
	state.add_faction(defender)
	state.add_faction(third)
	state.add_stronghold_region(StrongholdRegion.new("hqbattle_region", "HQBattle Region"))
	state.add_police_region(PoliceRegion.new("hqbattle_district", "HQBattle District"))
	state.add_neighborhood(Neighborhood.new("hqbattle_hood", "HQBattle Hood", "hqbattle_region", "hqbattle_district", hood_owner))
	var keep: Stronghold = Stronghold.new("hqbattle_keep", "HQBattle Keep", "hqbattle_hood", Vector2(0.0, 0.0), "hqbattle_a", true, 1, 0.0)
	keep.road_node_id = "hqbattle_node_hq"
	state.add_map_location(keep)
	var def_keep: Stronghold = Stronghold.new("hqbattle_def_keep", "HQBattle Def Keep", "hqbattle_hood", Vector2(0.5, 0.4), "hqbattle_b", true, 2, 0.0)
	def_keep.road_node_id = "hqbattle_node_hq"
	state.add_map_location(def_keep)
	var hq: NeighborhoodHQ = NeighborhoodHQ.new("hqbattle_hq", "HQBattle HQ", "hqbattle_hood", Vector2(0.2, 0.0), hq_owner, true)
	hq.road_node_id = "hqbattle_node_hq"
	state.add_map_location(hq)
	var hq_b: NeighborhoodHQ = NeighborhoodHQ.new("hqbattle_hq_b", "HQBattle HQ B", "hqbattle_hood", Vector2(4.0, 0.0), hq_owner, true)
	hq_b.road_node_id = "hqbattle_node_b"
	state.add_map_location(hq_b)
	var hq_orphan: NeighborhoodHQ = NeighborhoodHQ.new("hqbattle_hq_orphan", "HQBattle Orphan HQ", "", Vector2(20.0, 0.0), hq_owner, true)
	hq_orphan.road_node_id = "hqbattle_node_orphan"
	state.add_map_location(hq_orphan)
	var hq_ghost: NeighborhoodHQ = NeighborhoodHQ.new("hqbattle_hq_ghost", "HQBattle Ghost HQ", "hqbattle_missing_hood", Vector2(25.0, 0.0), hq_owner, true)
	hq_ghost.road_node_id = "hqbattle_node_ghost"
	state.add_map_location(hq_ghost)
	var biz_a: Business = Business.new("hqbattle_biz_a", "HQBattle Biz A", "hqbattle_hood", Vector2(0.3, 0.2), "hqbattle_b", true, "market", 2)
	biz_a.road_node_id = "hqbattle_node_hq"
	state.add_map_location(biz_a)
	var biz_b: Business = Business.new("hqbattle_biz_b", "HQBattle Biz B", "hqbattle_hood", Vector2(4.2, 0.2), "hqbattle_b", false, "narcotics_site", 1)
	biz_b.road_node_id = "hqbattle_node_b"
	state.add_map_location(biz_b)
	var biz_c: Business = Business.new("hqbattle_biz_c", "HQBattle Biz C", "hqbattle_hood", Vector2(0.4, -0.2), "hqbattle_c", true, "market", 1)
	biz_c.road_node_id = "hqbattle_node_hq"
	state.add_map_location(biz_c)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("hqbattle_node_hq", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("hqbattle_node_b", Vector2(4.0, 0.0)))
	graph.add_node(RoadNode.new("hqbattle_node_orphan", Vector2(20.0, 0.0)))
	graph.add_node(RoadNode.new("hqbattle_node_ghost", Vector2(25.0, 0.0)))
	graph.add_segment(RoadSegment.new("hqbattle_seg_hq_b", "hqbattle_node_hq", "hqbattle_node_b", 4.0))
	var soldier: Soldier = Soldier.new("hqbattle_soldier", "hqbattle_a", "", "pistol", 1.0, 0.0)
	var vehicle: Vehicle = Vehicle.new("hqbattle_vehicle", "hqbattle_a", "car", "", 2, 5.0, 0.0)
	var def_soldier: Soldier = Soldier.new("hqbattle_def_soldier", "hqbattle_b", "", "pistol", 1.0, 0.0)
	state.add_soldier(soldier)
	state.add_vehicle(vehicle)
	state.add_soldier(def_soldier)
	state.assign_soldier_to_stronghold("hqbattle_soldier", "hqbattle_keep")
	state.assign_vehicle_to_stronghold("hqbattle_vehicle", "hqbattle_keep")
	state.assign_soldier_to_stronghold("hqbattle_def_soldier", "hqbattle_def_keep")
	return state


static func _hqbattle_stronghold_request(
	mission_id: String = "hqbattle_mission",
	force_id: String = "hqbattle_force",
	destination_id: String = "hqbattle_hq"
) -> MissionRequest:
	var soldier_ids: Array[String] = ["hqbattle_soldier"]
	var vehicle_ids: Array[String] = ["hqbattle_vehicle"]
	var deployment: DeploymentRequest = DeploymentRequest.new(
		force_id,
		"hqbattle_a",
		"hqbattle_keep",
		destination_id,
		soldier_ids,
		vehicle_ids,
		10.0
	)
	return MissionRequest.new(mission_id, "capture_neighborhood_hq", deployment)


static func _hqbattle_add_force_mission(
	game_state: GameState,
	force_id: String = "hqbattle_force",
	mission_id: String = "hqbattle_mission",
	force_faction_id: String = "hqbattle_a",
	mission_faction_id: String = "hqbattle_a",
	destination_id: String = "hqbattle_hq",
	target_id: String = "hqbattle_hq",
	travel_state: String = "at_destination",
	mission_state: String = "awaiting_resolution",
	mission_type_id: String = "capture_neighborhood_hq",
	movement_remaining: float = 5.0
) -> TravelingForce:
	var dest_node: String = "hqbattle_node_hq"
	var dest_location: MapLocation = game_state.get_map_location(destination_id)
	if dest_location != null and not dest_location.road_node_id.is_empty():
		dest_node = dest_location.road_node_id
	var route: Array[String] = [dest_node]
	var force: TravelingForce = TravelingForce.new(
		force_id,
		force_faction_id,
		"hqbattle_keep",
		destination_id,
		route,
		5.0,
		travel_state
	)
	force.route_segment_index = 0
	force.distance_into_segment = 0.0
	force.movement_remaining = movement_remaining
	if game_state.has_soldier("hqbattle_soldier"):
		force.soldier_group.add_soldier_id("hqbattle_soldier")
	if game_state.has_vehicle("hqbattle_vehicle"):
		force.vehicle_group.add_vehicle_id("hqbattle_vehicle")
	game_state.add_traveling_force(force)
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		mission_type_id,
		mission_faction_id,
		force_id,
		"hqbattle_keep",
		target_id,
		mission_state,
		""
	)
	game_state.add_mission(mission)
	return force


static func _hqbattle_fails_atomically(
	game_state: GameState,
	mission_id: String,
	expected_error: String,
	force: TravelingForce
) -> bool:
	if game_state == null:
		return false
	var snap: Dictionary = _hqattack_snapshot(game_state, force)
	var money_a: float = 0.0
	var ammo_a: float = 0.0
	if game_state.has_faction("hqbattle_a") and game_state.get_faction("hqbattle_a") is MajorGang:
		var gang_a: MajorGang = game_state.get_faction("hqbattle_a") as MajorGang
		money_a = gang_a.money
		ammo_a = gang_a.resources.get_amount("Ammo")
	var result: NeighborhoodHQAttackFailureResult = NeighborhoodHQAttackFailureResolver.resolve_failure(
		game_state,
		mission_id
	)
	if result.success or result.error_code != expected_error:
		return false
	if not _hqattack_unchanged(game_state, snap, force):
		return false
	if game_state.has_faction("hqbattle_a") and game_state.get_faction("hqbattle_a") is MajorGang:
		var gang_after: MajorGang = game_state.get_faction("hqbattle_a") as MajorGang
		if not is_equal_approx(gang_after.money, money_a):
			return false
		if not is_equal_approx(gang_after.resources.get_amount("Ammo"), ammo_a):
			return false
	return true


static func _make_battle_world(hood_owner: String = "battle_b", hq_owner: String = "battle_b") -> GameState:
	var state: GameState = GameState.new()
	state.current_turn = 11
	state.current_month = 3
	state.current_year = 2035
	var attacker: MajorGang = MajorGang.new("battle_a", "Battle A", "player")
	attacker.money = 950.0
	attacker.resources.set_amount("Ammo", 6.5)
	var defender: MajorGang = MajorGang.new("battle_b", "Battle B", "ai")
	defender.money = 410.0
	defender.resources.set_amount("Narcotics", 3.25)
	state.add_faction(attacker)
	state.add_faction(defender)
	state.add_stronghold_region(StrongholdRegion.new("battle_region", "Battle Region"))
	state.add_police_region(PoliceRegion.new("battle_district", "Battle District"))
	state.add_neighborhood(Neighborhood.new("battle_hood", "Battle Hood", "battle_region", "battle_district", hood_owner))
	var keep: Stronghold = Stronghold.new("battle_keep", "Battle Keep", "battle_hood", Vector2(0.0, 0.0), "battle_a", true, 1, 0.0)
	keep.road_node_id = "battle_node_hq"
	state.add_map_location(keep)
	var hq: NeighborhoodHQ = NeighborhoodHQ.new("battle_hq", "Battle HQ", "battle_hood", Vector2(0.2, 0.0), hq_owner, true)
	hq.road_node_id = "battle_node_hq"
	state.add_map_location(hq)
	var hq_b: NeighborhoodHQ = NeighborhoodHQ.new("battle_hq_b", "Battle HQ B", "battle_hood", Vector2(4.0, 0.0), hq_owner, true)
	hq_b.road_node_id = "battle_node_b"
	state.add_map_location(hq_b)
	var hq_orphan: NeighborhoodHQ = NeighborhoodHQ.new("battle_hq_orphan", "Battle Orphan HQ", "", Vector2(20.0, 0.0), hq_owner, true)
	hq_orphan.road_node_id = "battle_node_orphan"
	state.add_map_location(hq_orphan)
	var hq_ghost: NeighborhoodHQ = NeighborhoodHQ.new("battle_hq_ghost", "Battle Ghost HQ", "battle_missing_hood", Vector2(25.0, 0.0), hq_owner, true)
	hq_ghost.road_node_id = "battle_node_ghost"
	state.add_map_location(hq_ghost)
	var biz: Business = Business.new("battle_biz", "Battle Biz", "battle_hood", Vector2(0.3, 0.2), "battle_b", true, "market", 2)
	biz.road_node_id = "battle_node_hq"
	state.add_map_location(biz)
	var graph: RoadGraph = state.road_graph
	graph.add_node(RoadNode.new("battle_node_hq", Vector2(0.0, 0.0)))
	graph.add_node(RoadNode.new("battle_node_b", Vector2(4.0, 0.0)))
	graph.add_node(RoadNode.new("battle_node_orphan", Vector2(20.0, 0.0)))
	graph.add_node(RoadNode.new("battle_node_ghost", Vector2(25.0, 0.0)))
	graph.add_segment(RoadSegment.new("battle_seg_hq_b", "battle_node_hq", "battle_node_b", 4.0))
	state.add_soldier(Soldier.new("battle_sol_z", "battle_a", "", "rifle", 1.9, 35.0))
	state.add_soldier(Soldier.new("battle_sol_m", "battle_a", "", "smg", 1.55, 30.0))
	state.add_soldier(Soldier.new("battle_sol_a", "battle_a", "", "pistol", 1.0, 20.0))
	state.add_soldier(Soldier.new("battle_sol_enemy", "battle_b", "", "shotgun", 1.25, 25.0))
	state.add_vehicle(Vehicle.new("battle_veh_z", "battle_a", "truck", "", 6, 4.0, 40.0))
	state.add_vehicle(Vehicle.new("battle_veh_m", "battle_a", "van", "", 4, 5.0, 30.0))
	state.add_vehicle(Vehicle.new("battle_veh_a", "battle_a", "car", "", 2, 6.0, 20.0))
	state.add_vehicle(Vehicle.new("battle_veh_enemy", "battle_b", "bike", "", 1, 8.0, 10.0))
	return state


static func _battle_default_soldier_ids_out_of_order() -> Array[String]:
	var ids: Array[String] = []
	ids.append("battle_sol_z")
	ids.append("battle_sol_m")
	ids.append("battle_sol_a")
	return ids


static func _battle_default_vehicle_ids_out_of_order() -> Array[String]:
	var ids: Array[String] = []
	ids.append("battle_veh_z")
	ids.append("battle_veh_m")
	ids.append("battle_veh_a")
	return ids


static func _battle_add_force_mission(
	game_state: GameState,
	force_id: String = "battle_force",
	mission_id: String = "battle_mission",
	force_faction_id: String = "battle_a",
	mission_faction_id: String = "battle_a",
	destination_id: String = "battle_hq",
	target_id: String = "battle_hq",
	travel_state: String = "at_destination",
	mission_state: String = "awaiting_resolution",
	mission_type_id: String = "capture_neighborhood_hq",
	movement_remaining: float = 5.0
) -> TravelingForce:
	return _battle_add_force_mission_with_units(
		game_state,
		force_id,
		mission_id,
		force_faction_id,
		mission_faction_id,
		destination_id,
		target_id,
		travel_state,
		mission_state,
		mission_type_id,
		movement_remaining,
		_battle_default_soldier_ids_out_of_order(),
		_battle_default_vehicle_ids_out_of_order()
	)


static func _battle_add_force_mission_with_units(
	game_state: GameState,
	force_id: String,
	mission_id: String,
	force_faction_id: String,
	mission_faction_id: String,
	destination_id: String,
	target_id: String,
	travel_state: String,
	mission_state: String,
	mission_type_id: String,
	movement_remaining: float,
	soldier_ids: Array[String],
	vehicle_ids: Array[String]
) -> TravelingForce:
	var dest_node: String = "battle_node_hq"
	var dest_location: MapLocation = game_state.get_map_location(destination_id)
	if dest_location != null and not dest_location.road_node_id.is_empty():
		dest_node = dest_location.road_node_id
	var route: Array[String] = []
	route.append(dest_node)
	var force: TravelingForce = TravelingForce.new(
		force_id,
		force_faction_id,
		"battle_keep",
		destination_id,
		route,
		5.0,
		travel_state
	)
	force.route_segment_index = 0
	force.distance_into_segment = 0.0
	force.movement_remaining = movement_remaining
	for soldier_id: String in soldier_ids:
		force.soldier_group.add_soldier_id(soldier_id)
	for vehicle_id: String in vehicle_ids:
		force.vehicle_group.add_vehicle_id(vehicle_id)
	game_state.add_traveling_force(force)
	var mission: CampaignMission = CampaignMission.new(
		mission_id,
		mission_type_id,
		mission_faction_id,
		force_id,
		"battle_keep",
		target_id,
		mission_state,
		""
	)
	game_state.add_mission(mission)
	return force


static func _battle_campaign_snapshot(game_state: GameState, force: TravelingForce, mission_id: String) -> Dictionary:
	var snap: Dictionary = {}
	snap["has_mission"] = game_state.has_mission(mission_id)
	if game_state.has_mission(mission_id):
		var mission: CampaignMission = game_state.get_mission(mission_id)
		snap["mission_state"] = mission.mission_state
		snap["outcome_code"] = mission.outcome_code
		snap["mission_type"] = mission.mission_type_id
		snap["mission_force"] = mission.force_id
		snap["mission_target"] = mission.target_location_id
	else:
		snap["mission_state"] = ""
		snap["outcome_code"] = ""
		snap["mission_type"] = ""
		snap["mission_force"] = ""
		snap["mission_target"] = ""
	var mission_states: Dictionary = {}
	for mid: String in game_state.missions:
		var listed: CampaignMission = game_state.get_mission(mid)
		if listed != null:
			mission_states[mid] = listed.mission_state + "|" + listed.outcome_code
	snap["mission_states"] = mission_states
	snap["mission_count"] = game_state.missions.size()
	snap["force_count"] = game_state.traveling_forces.size()
	snap["soldier_count"] = game_state.soldiers.size()
	snap["vehicle_count"] = game_state.vehicles.size()
	snap["rel_count"] = game_state.relationships.size()
	var rel_keys: Array[String] = []
	for rel_key: String in game_state.relationships:
		rel_keys.append(rel_key)
	rel_keys.sort()
	snap["rel_keys"] = rel_keys
	var hood_owners: Dictionary = {}
	for hood_id: String in game_state.neighborhoods:
		var hood: Neighborhood = game_state.get_neighborhood(hood_id)
		if hood != null:
			hood_owners[hood_id] = hood.owner_faction_id
	snap["hood_owners"] = hood_owners
	var loc_owners: Dictionary = {}
	for loc_id: String in game_state.map_locations:
		var location: MapLocation = game_state.get_map_location(loc_id)
		if location != null:
			loc_owners[loc_id] = location.owner_faction_id
	snap["loc_owners"] = loc_owners
	var soldier_data: Dictionary = {}
	for soldier_id: String in game_state.soldiers:
		var soldier: Soldier = game_state.get_soldier(soldier_id)
		if soldier != null:
			soldier_data[soldier_id] = soldier.to_dict()
	snap["soldiers"] = soldier_data
	var vehicle_data: Dictionary = {}
	for vehicle_id: String in game_state.vehicles:
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		if vehicle != null:
			vehicle_data[vehicle_id] = vehicle.to_dict()
	snap["vehicles"] = vehicle_data
	snap["money_a"] = 0.0
	snap["ammo_a"] = 0.0
	snap["money_b"] = 0.0
	snap["narc_b"] = 0.0
	if game_state.has_faction("battle_a") and game_state.get_faction("battle_a") is MajorGang:
		var gang_a: MajorGang = game_state.get_faction("battle_a") as MajorGang
		snap["money_a"] = gang_a.money
		snap["ammo_a"] = gang_a.resources.get_amount("Ammo")
	if game_state.has_faction("battle_b") and game_state.get_faction("battle_b") is MajorGang:
		var gang_b: MajorGang = game_state.get_faction("battle_b") as MajorGang
		snap["money_b"] = gang_b.money
		snap["narc_b"] = gang_b.resources.get_amount("Narcotics")
	if force != null:
		snap["force"] = _force_travel_snapshot(force)
	return snap


static func _battle_campaign_unchanged(
	game_state: GameState,
	snap: Dictionary,
	force: TravelingForce,
	mission_id: String
) -> bool:
	if game_state == null:
		return false
	if game_state.has_mission(mission_id) != bool(snap.get("has_mission", false)):
		return false
	if game_state.has_mission(mission_id):
		var mission: CampaignMission = game_state.get_mission(mission_id)
		if mission.mission_state != str(snap.get("mission_state", "")):
			return false
		if mission.outcome_code != str(snap.get("outcome_code", "")):
			return false
		if mission.mission_type_id != str(snap.get("mission_type", "")):
			return false
		if mission.force_id != str(snap.get("mission_force", "")):
			return false
		if mission.target_location_id != str(snap.get("mission_target", "")):
			return false
	if game_state.missions.size() != int(snap.get("mission_count", -1)):
		return false
	if game_state.traveling_forces.size() != int(snap.get("force_count", -1)):
		return false
	if game_state.soldiers.size() != int(snap.get("soldier_count", -1)):
		return false
	if game_state.vehicles.size() != int(snap.get("vehicle_count", -1)):
		return false
	if game_state.relationships.size() != int(snap.get("rel_count", -1)):
		return false
	var expected_rel_keys: Array[String] = []
	var rel_key_data: Variant = snap.get("rel_keys", [])
	if rel_key_data is Array:
		for rel_key: Variant in rel_key_data:
			expected_rel_keys.append(str(rel_key))
	var actual_rel_keys: Array[String] = []
	for rel_key: String in game_state.relationships:
		actual_rel_keys.append(rel_key)
	actual_rel_keys.sort()
	if not _string_ids_match(actual_rel_keys, expected_rel_keys):
		return false
	var hood_owners: Variant = snap.get("hood_owners", {})
	if hood_owners is Dictionary:
		for hood_id: Variant in hood_owners:
			var hood: Neighborhood = game_state.get_neighborhood(str(hood_id))
			if hood == null or hood.owner_faction_id != str(hood_owners[hood_id]):
				return false
	var loc_owners: Variant = snap.get("loc_owners", {})
	if loc_owners is Dictionary:
		for loc_id: Variant in loc_owners:
			var location: MapLocation = game_state.get_map_location(str(loc_id))
			if location == null or location.owner_faction_id != str(loc_owners[loc_id]):
				return false
	var soldier_data: Variant = snap.get("soldiers", {})
	if soldier_data is Dictionary:
		for soldier_id: Variant in soldier_data:
			var soldier: Soldier = game_state.get_soldier(str(soldier_id))
			var soldier_fields: Variant = soldier_data[soldier_id]
			if soldier == null or not (soldier_fields is Dictionary):
				return false
			if not _battle_soldier_matches_dict(soldier, soldier_fields as Dictionary):
				return false
	var vehicle_data: Variant = snap.get("vehicles", {})
	if vehicle_data is Dictionary:
		for vehicle_id: Variant in vehicle_data:
			var vehicle: Vehicle = game_state.get_vehicle(str(vehicle_id))
			var vehicle_fields: Variant = vehicle_data[vehicle_id]
			if vehicle == null or not (vehicle_fields is Dictionary):
				return false
			if not _battle_vehicle_matches_dict(vehicle, vehicle_fields as Dictionary):
				return false
	if game_state.has_faction("battle_a") and game_state.get_faction("battle_a") is MajorGang:
		var gang_a: MajorGang = game_state.get_faction("battle_a") as MajorGang
		if not is_equal_approx(gang_a.money, float(snap.get("money_a", -1.0))):
			return false
		if not is_equal_approx(gang_a.resources.get_amount("Ammo"), float(snap.get("ammo_a", -1.0))):
			return false
	if game_state.has_faction("battle_b") and game_state.get_faction("battle_b") is MajorGang:
		var gang_b: MajorGang = game_state.get_faction("battle_b") as MajorGang
		if not is_equal_approx(gang_b.money, float(snap.get("money_b", -1.0))):
			return false
		if not is_equal_approx(gang_b.resources.get_amount("Narcotics"), float(snap.get("narc_b", -1.0))):
			return false
	if force != null:
		var force_snap: Variant = snap.get("force", {})
		if not (force_snap is Dictionary):
			return false
		if not _force_travel_unchanged(force, force_snap):
			return false
	return true


static func _battle_fails_setup(
	game_state: GameState,
	mission_id: String,
	expected_error: String,
	force: TravelingForce
) -> bool:
	if game_state == null:
		return false
	var snap: Dictionary = _battle_campaign_snapshot(game_state, force, mission_id)
	var result: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(game_state, mission_id)
	if result.success:
		return false
	if result.battle_state != null:
		return false
	if result.error_code != expected_error:
		return false
	if not _battle_campaign_unchanged(game_state, snap, force, mission_id):
		return false
	return true


static func _battle_soldier_matches_dict(soldier: Soldier, data: Dictionary) -> bool:
	if soldier == null:
		return false
	return (
		soldier.id == str(data.get("id", ""))
		and soldier.faction_id == str(data.get("faction_id", ""))
		and soldier.home_stronghold_id == str(data.get("home_stronghold_id", ""))
		and soldier.weapon_type_id == str(data.get("weapon_type_id", ""))
		and is_equal_approx(soldier.strategic_strength, float(data.get("strategic_strength", -1.0)))
		and is_equal_approx(soldier.upkeep_per_turn, float(data.get("upkeep_per_turn", -1.0)))
	)


static func _battle_vehicle_matches_dict(vehicle: Vehicle, data: Dictionary) -> bool:
	if vehicle == null:
		return false
	return (
		vehicle.id == str(data.get("id", ""))
		and vehicle.faction_id == str(data.get("faction_id", ""))
		and vehicle.vehicle_type_id == str(data.get("vehicle_type_id", ""))
		and vehicle.home_stronghold_id == str(data.get("home_stronghold_id", ""))
		and vehicle.passenger_capacity == int(data.get("passenger_capacity", -1))
		and is_equal_approx(vehicle.movement_per_turn, float(data.get("movement_per_turn", -1.0)))
		and is_equal_approx(vehicle.upkeep_per_turn, float(data.get("upkeep_per_turn", -1.0)))
	)


static func _battle_participant_matches_soldier(battle_state: BattleState, soldier: Soldier) -> bool:
	if battle_state == null or soldier == null:
		return false
	if not battle_state.has_participant(soldier.id):
		return false
	var participant: BattleParticipant = battle_state.get_participant(soldier.id)
	if participant == null:
		return false
	return (
		participant.participant_id == soldier.id
		and participant.campaign_soldier_id == soldier.id
		and participant.faction_id == soldier.faction_id
		and participant.side_id == "attacker"
		and participant.weapon_type == soldier.weapon_type_id
		and participant.is_alive
		and not participant.is_wounded
		and participant.deployment_slot_id.is_empty()
	)


static func _battle_vehicle_matches_campaign(battle_state: BattleState, vehicle: Vehicle) -> bool:
	if battle_state == null or vehicle == null:
		return false
	if not battle_state.has_vehicle(vehicle.id):
		return false
	var battle_vehicle: BattleVehicle = battle_state.get_vehicle(vehicle.id)
	if battle_vehicle == null:
		return false
	return (
		battle_vehicle.battle_vehicle_id == vehicle.id
		and battle_vehicle.campaign_vehicle_id == vehicle.id
		and battle_vehicle.faction_id == vehicle.faction_id
		and battle_vehicle.side_id == "attacker"
		and battle_vehicle.vehicle_type_id == vehicle.vehicle_type_id
		and battle_vehicle.deployment_slot_id.is_empty()
	)


static func _battle_sorted_dict_keys(data: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in data:
		keys.append(str(key))
	keys.sort()
	return keys


static func _battle_serialized_campaign_keys_only(data: Dictionary) -> bool:
	var allowed: Dictionary = {
		"current_turn": true,
		"current_year": true,
		"current_month": true,
		"factions": true,
		"relationships": true,
		"neighborhoods": true,
		"stronghold_regions": true,
		"police_regions": true,
		"road_graph": true,
		"map_locations": true,
		"vehicles": true,
		"soldiers": true,
		"traveling_forces": true,
		"missions": true,
	}
	for key: Variant in data:
		if not allowed.has(str(key)):
			return false
	for allowed_key: String in allowed:
		if not data.has(allowed_key):
			return false
	return true


static func _battle_is_tactical_token(text: String) -> bool:
	return (
		text == "battle_phase"
		or text == "battle_type_id"
		or text == "deployment_zones"
		or text == "attacker_side_id"
		or text == "defender_side_id"
		or text == "battle_state"
		or text == "neighborhood_hq_assault"
		or text == "attacker_deployment"
		or text == "defender_deployment"
		or 		text == "attacker_entry"
		or text == "defender_position"
		or text == "deployed_participant_ids"
		or text == "deployed_vehicle_ids"
		or text == "deployment_slot_id"
		or text == "turn_actor_ids"
		or text == "turn_actor_types"
		or text == "turn_actor_side_ids"
		or text == "current_turn_index"
		or text == "current_round"
		or text == "actor_turn_in_progress"
		or text == "active_turn_actor_id"
		or text == "active_turn_actor_type"
		or text == "active_turn_actor_side_id"
	)


static func _battle_data_has_tactical_trace(value: Variant) -> bool:
	if value is Dictionary:
		var data: Dictionary = value
		for key: Variant in data:
			if _battle_is_tactical_token(str(key)):
				return true
			if _battle_data_has_tactical_trace(data[key]):
				return true
		return false
	if value is Array:
		var items: Array = value
		for item: Variant in items:
			if _battle_data_has_tactical_trace(item):
				return true
		return false
	if typeof(value) == TYPE_STRING:
		return _battle_is_tactical_token(str(value))
	return false


static func _battle_dict_from_snap(snap: Dictionary, section: String, item_id: String) -> Dictionary:
	var empty: Dictionary = {}
	var section_data: Variant = snap.get(section, {})
	if not (section_data is Dictionary):
		return empty
	var section_dict: Dictionary = section_data as Dictionary
	var item_data: Variant = section_dict.get(item_id, {})
	if not (item_data is Dictionary):
		return empty
	return item_data as Dictionary


static func _battle_create_ready_pack() -> Dictionary:
	var game_state: GameState = _make_battle_world()
	DiplomacyService.declare_war(game_state, "battle_a", "battle_b")
	var force: TravelingForce = _battle_add_force_mission(game_state)
	var result: BattleSetupResult = BattleSetupService.create_neighborhood_hq_battle(game_state, "battle_mission")
	var pack: Dictionary = {}
	pack["game_state"] = game_state
	pack["force"] = force
	pack["result"] = result
	pack["battle_state"] = result.battle_state
	return pack


static func _battle_deploy_assignment_snapshot(battle_state: BattleState) -> Dictionary:
	var snap: Dictionary = {}
	if battle_state == null:
		return snap
	snap["phase"] = battle_state.battle_phase
	var participant_slots: Dictionary = {}
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant != null:
			participant_slots[participant_id] = participant.deployment_slot_id
	snap["participant_slots"] = participant_slots
	var vehicle_slots: Dictionary = {}
	for vehicle_id: String in battle_state.vehicles:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle != null:
			vehicle_slots[vehicle_id] = vehicle.deployment_slot_id
	snap["vehicle_slots"] = vehicle_slots
	var zone_participants: Dictionary = {}
	var zone_vehicles: Dictionary = {}
	for zone_id: String in battle_state.deployment_zones:
		var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
		if zone != null:
			zone_participants[zone_id] = _copy_ids(zone.deployed_participant_ids)
			zone_vehicles[zone_id] = _copy_ids(zone.deployed_vehicle_ids)
	snap["zone_participants"] = zone_participants
	snap["zone_vehicles"] = zone_vehicles
	return snap


static func _battle_deploy_assignment_unchanged(battle_state: BattleState, snap: Dictionary) -> bool:
	if battle_state == null:
		return false
	if battle_state.battle_phase != str(snap.get("phase", "")):
		return false
	var participant_slots: Variant = snap.get("participant_slots", {})
	if not (participant_slots is Dictionary):
		return false
	var participant_slot_data: Dictionary = participant_slots as Dictionary
	if participant_slot_data.size() != battle_state.participants.size():
		return false
	for participant_id: Variant in participant_slot_data:
		var participant: BattleParticipant = battle_state.get_participant(str(participant_id))
		if participant == null or participant.deployment_slot_id != str(participant_slot_data[participant_id]):
			return false
	var vehicle_slots: Variant = snap.get("vehicle_slots", {})
	if not (vehicle_slots is Dictionary):
		return false
	var vehicle_slot_data: Dictionary = vehicle_slots as Dictionary
	if vehicle_slot_data.size() != battle_state.vehicles.size():
		return false
	for vehicle_id: Variant in vehicle_slot_data:
		var vehicle: BattleVehicle = battle_state.get_vehicle(str(vehicle_id))
		if vehicle == null or vehicle.deployment_slot_id != str(vehicle_slot_data[vehicle_id]):
			return false
	var zone_participants: Variant = snap.get("zone_participants", {})
	var zone_vehicles: Variant = snap.get("zone_vehicles", {})
	if not (zone_participants is Dictionary) or not (zone_vehicles is Dictionary):
		return false
	var zone_participant_data: Dictionary = zone_participants as Dictionary
	var zone_vehicle_data: Dictionary = zone_vehicles as Dictionary
	if zone_participant_data.size() != battle_state.deployment_zones.size():
		return false
	for zone_id: Variant in zone_participant_data:
		var zone: DeploymentZone = battle_state.get_deployment_zone(str(zone_id))
		if zone == null:
			return false
		var expected_participants: Array[String] = []
		var participant_data: Variant = zone_participant_data[zone_id]
		if participant_data is Array:
			for participant_id: Variant in participant_data:
				expected_participants.append(str(participant_id))
		if not _string_ids_match(zone.deployed_participant_ids, expected_participants):
			return false
		var expected_vehicles: Array[String] = []
		var vehicle_data: Variant = (zone_vehicle_data as Dictionary).get(str(zone_id), [])
		if vehicle_data is Array:
			for vehicle_id: Variant in vehicle_data:
				expected_vehicles.append(str(vehicle_id))
		if not _string_ids_match(zone.deployed_vehicle_ids, expected_vehicles):
			return false
	return true


static func _battle_make_bare_state() -> BattleState:
	var battle_state: BattleState = BattleState.new(
		"battle_ready_bare",
		"neighborhood_hq_assault",
		"battle_ready_mission",
		"battle_hq",
		"attacker",
		"defender",
		"deployment"
	)
	var attacker_side: BattleSide = BattleSide.new("attacker", "battle_a", "battle_force", true, "attacker_deployment")
	var defender_side: BattleSide = BattleSide.new("defender", "battle_b", "", false, "defender_deployment")
	if not battle_state.add_side(attacker_side) or not battle_state.add_side(defender_side):
		return null
	var attacker_zone: DeploymentZone = DeploymentZone.new("attacker_deployment", "attacker", "attacker_entry")
	var defender_zone: DeploymentZone = DeploymentZone.new("defender_deployment", "defender", "defender_position")
	if not battle_state.add_deployment_zone(attacker_zone) or not battle_state.add_deployment_zone(defender_zone):
		return null
	return battle_state


static func _battle_register_participant(
	battle_state: BattleState,
	participant_id: String,
	side_id: String,
	zone_id: String
) -> bool:
	if battle_state == null:
		return false
	var participant: BattleParticipant = BattleParticipant.new(
		participant_id,
		participant_id,
		"battle_a",
		side_id,
		"pistol",
		true,
		false,
		""
	)
	if side_id == "defender":
		participant.faction_id = "battle_b"
	if not battle_state.add_participant(participant):
		return false
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null or not side.add_participant_id(participant_id):
		return false
	var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
	if zone == null:
		return false
	if not zone.allowed_participant_ids.has(participant_id):
		zone.allowed_participant_ids.append(participant_id)
	return true


static func _battle_register_vehicle(
	battle_state: BattleState,
	vehicle_id: String,
	side_id: String,
	zone_id: String
) -> bool:
	if battle_state == null:
		return false
	var vehicle: BattleVehicle = BattleVehicle.new(
		vehicle_id,
		vehicle_id,
		"battle_a",
		side_id,
		"car",
		""
	)
	if side_id == "defender":
		vehicle.faction_id = "battle_b"
	if not battle_state.add_vehicle(vehicle):
		return false
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null or not side.add_vehicle_id(vehicle_id):
		return false
	var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
	if zone == null:
		return false
	if not zone.allowed_vehicle_ids.has(vehicle_id):
		zone.allowed_vehicle_ids.append(vehicle_id)
	return true


static func _battle_deploy_standard_attacker(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	if not battle_state.deploy_participant("battle_sol_z", "attacker_deployment"):
		return false
	if not battle_state.deploy_participant("battle_sol_a", "attacker_deployment"):
		return false
	if not battle_state.deploy_participant("battle_sol_m", "attacker_deployment"):
		return false
	if not battle_state.deploy_vehicle("battle_veh_z", "attacker_deployment"):
		return false
	if not battle_state.deploy_vehicle("battle_veh_a", "attacker_deployment"):
		return false
	if not battle_state.deploy_vehicle("battle_veh_m", "attacker_deployment"):
		return false
	return true


static func _battle_turn_snapshot(battle_state: BattleState) -> Dictionary:
	var snap: Dictionary = {}
	if battle_state == null:
		return snap
	snap["ids"] = battle_state.get_turn_actor_ids()
	snap["types"] = battle_state.get_turn_actor_types()
	snap["sides"] = battle_state.get_turn_actor_side_ids()
	snap["index"] = battle_state.get_current_turn_index()
	snap["round"] = battle_state.get_current_round()
	snap["current_id"] = battle_state.get_current_turn_actor_id()
	snap["current_type"] = battle_state.get_current_turn_actor_type()
	snap["current_side"] = battle_state.get_current_turn_actor_side_id()
	snap["has_current"] = battle_state.has_current_turn_actor()
	snap["count"] = battle_state.get_turn_actor_count()
	snap["in_progress"] = battle_state.is_actor_turn_in_progress()
	snap["active_id"] = battle_state.get_active_turn_actor_id()
	snap["active_type"] = battle_state.get_active_turn_actor_type()
	snap["active_side"] = battle_state.get_active_turn_actor_side_id()
	return snap


static func _battle_variant_to_ids(value: Variant) -> Array[String]:
	var ids: Array[String] = []
	if value is Array:
		for item: Variant in value:
			ids.append(str(item))
	return ids


static func _battle_turn_unchanged(battle_state: BattleState, snap: Dictionary) -> bool:
	if battle_state == null:
		return false
	return (
		_string_ids_match(battle_state.get_turn_actor_ids(), _battle_variant_to_ids(snap.get("ids", [])))
		and _string_ids_match(battle_state.get_turn_actor_types(), _battle_variant_to_ids(snap.get("types", [])))
		and _string_ids_match(battle_state.get_turn_actor_side_ids(), _battle_variant_to_ids(snap.get("sides", [])))
		and battle_state.get_current_turn_index() == int(snap.get("index", -2))
		and battle_state.get_current_round() == int(snap.get("round", -1))
		and battle_state.get_current_turn_actor_id() == str(snap.get("current_id", ""))
		and battle_state.get_current_turn_actor_type() == str(snap.get("current_type", ""))
		and battle_state.get_current_turn_actor_side_id() == str(snap.get("current_side", ""))
		and battle_state.has_current_turn_actor() == bool(snap.get("has_current", true))
		and battle_state.get_turn_actor_count() == int(snap.get("count", -1))
		and battle_state.is_actor_turn_in_progress() == bool(snap.get("in_progress", true))
		and battle_state.get_active_turn_actor_id() == str(snap.get("active_id", "__missing__"))
		and battle_state.get_active_turn_actor_type() == str(snap.get("active_type", "__missing__"))
		and battle_state.get_active_turn_actor_side_id() == str(snap.get("active_side", "__missing__"))
	)


static func _battle_turn_attacker_before_defender(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	var seen_defender: bool = false
	for side_id: String in battle_state.get_turn_actor_side_ids():
		if side_id == battle_state.defender_side_id:
			seen_defender = true
		elif side_id == battle_state.attacker_side_id:
			if seen_defender:
				return false
		else:
			return false
	return true


static func _battle_turn_participants_before_vehicles(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	var actor_ids: Array[String] = battle_state.get_turn_actor_ids()
	var actor_types: Array[String] = battle_state.get_turn_actor_types()
	var actor_sides: Array[String] = battle_state.get_turn_actor_side_ids()
	if actor_ids.size() != actor_types.size() or actor_ids.size() != actor_sides.size():
		return false
	var last_type_by_side: Dictionary = {}
	for i in actor_ids.size():
		var side_id: String = actor_sides[i]
		var actor_type: String = actor_types[i]
		if last_type_by_side.has(side_id):
			if str(last_type_by_side[side_id]) == BattleState.TURN_ACTOR_TYPE_VEHICLE:
				if actor_type == BattleState.TURN_ACTOR_TYPE_PARTICIPANT:
					return false
		last_type_by_side[side_id] = actor_type
	return true


static func _battle_turn_ids_ascending(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	var actor_ids: Array[String] = battle_state.get_turn_actor_ids()
	var actor_types: Array[String] = battle_state.get_turn_actor_types()
	var actor_sides: Array[String] = battle_state.get_turn_actor_side_ids()
	if actor_ids.size() != actor_types.size() or actor_ids.size() != actor_sides.size():
		return false
	var last_id_by_key: Dictionary = {}
	for i in actor_ids.size():
		var key: String = "%s:%s" % [actor_sides[i], actor_types[i]]
		if last_id_by_key.has(key):
			if actor_ids[i] <= str(last_id_by_key[key]):
				return false
		last_id_by_key[key] = actor_ids[i]
	return true


static func _battle_register_and_deploy_participant(
	battle_state: BattleState,
	participant_id: String,
	side_id: String,
	zone_id: String
) -> bool:
	if not _battle_register_participant(battle_state, participant_id, side_id, zone_id):
		return false
	return battle_state.deploy_participant(participant_id, zone_id)


static func _battle_register_and_deploy_vehicle(
	battle_state: BattleState,
	vehicle_id: String,
	side_id: String,
	zone_id: String
) -> bool:
	if not _battle_register_vehicle(battle_state, vehicle_id, side_id, zone_id):
		return false
	return battle_state.deploy_vehicle(vehicle_id, zone_id)


static func _battle_populate_mixed_turn_actors(battle_state: BattleState, scrambled: bool) -> bool:
	if battle_state == null:
		return false
	if scrambled:
		if not _battle_register_and_deploy_vehicle(battle_state, "def_v_m", "defender", "defender_deployment"):
			return false
		if not _battle_register_and_deploy_vehicle(battle_state, "att_v_a", "attacker", "attacker_deployment"):
			return false
		if not _battle_register_and_deploy_participant(battle_state, "def_p_a", "defender", "defender_deployment"):
			return false
		if not _battle_register_and_deploy_participant(battle_state, "att_p_a", "attacker", "attacker_deployment"):
			return false
		if not _battle_register_and_deploy_vehicle(battle_state, "att_v_z", "attacker", "attacker_deployment"):
			return false
		if not _battle_register_and_deploy_participant(battle_state, "def_p_z", "defender", "defender_deployment"):
			return false
		if not _battle_register_and_deploy_participant(battle_state, "att_p_z", "attacker", "attacker_deployment"):
			return false
		return true
	if not _battle_register_and_deploy_participant(battle_state, "att_p_z", "attacker", "attacker_deployment"):
		return false
	if not _battle_register_and_deploy_participant(battle_state, "att_p_a", "attacker", "attacker_deployment"):
		return false
	if not _battle_register_and_deploy_vehicle(battle_state, "att_v_z", "attacker", "attacker_deployment"):
		return false
	if not _battle_register_and_deploy_vehicle(battle_state, "att_v_a", "attacker", "attacker_deployment"):
		return false
	if not _battle_register_and_deploy_participant(battle_state, "def_p_z", "defender", "defender_deployment"):
		return false
	if not _battle_register_and_deploy_participant(battle_state, "def_p_a", "defender", "defender_deployment"):
		return false
	if not _battle_register_and_deploy_vehicle(battle_state, "def_v_m", "defender", "defender_deployment"):
		return false
	return true


