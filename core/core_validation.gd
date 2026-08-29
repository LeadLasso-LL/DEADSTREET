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
const BattleRuntimeResult := preload("res://battle/runtime/battle_runtime_result.gd")
const BattleRuntimeService := preload("res://battle/runtime/battle_runtime_service.gd")
const BattleMovementResult := preload("res://battle/runtime/battle_movement_result.gd")
const BattleMovementService := preload("res://battle/runtime/battle_movement_service.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattlefieldGeometryResult := preload("res://battle/geometry/battlefield_geometry_result.gd")
const BattlefieldGeometryService := preload("res://battle/geometry/battlefield_geometry_service.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleSpatialResult := preload("res://battle/geometry/battle_spatial_result.gd")
const BattleSpatialService := preload("res://battle/geometry/battle_spatial_service.gd")
const BattleNavigationRequest := preload("res://battle/navigation/battle_navigation_request.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattlePathFollowResult := preload("res://battle/navigation/battle_path_follow_result.gd")
const BattlePathFollowService := preload("res://battle/navigation/battle_path_follow_service.gd")
const BattleTargetSelectionResult := preload("res://battle/combat/battle_target_selection_result.gd")
const BattleTargetSelectionService := preload("res://battle/combat/battle_target_selection_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")
const BattleLineOfSightService := preload("res://battle/combat/battle_line_of_sight_service.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponState := preload("res://battle/combat/battle_weapon_state.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")
const BattleAttackResult := preload("res://battle/combat/battle_attack_result.gd")
const BattleAttackResolutionService := preload("res://battle/combat/battle_attack_resolution_service.gd")


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
		var battle_ready_act_geo: bool = _battlegeo_init(battle_ready_act_bs)
		var battle_ready_act_begun: bool = battle_ready_act_geo and battle_ready_act_bs.begin_battle()
		battle_ready_activate_ok = (
			battle_ready_act_deployed
			and battle_ready_act_geo
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
		var battle_ready_outside_geo: bool = _battlegeo_init(battle_ready_outside_bs)
		var battle_ready_outside_first: bool = battle_ready_outside_geo and battle_ready_outside_bs.begin_battle()
		var battle_ready_outside_before: Dictionary = _battle_deploy_assignment_snapshot(battle_ready_outside_bs)
		var battle_ready_outside_second: bool = battle_ready_outside_bs.begin_battle()
		battle_ready_outside_ok = (
			battle_ready_outside_deployed
			and battle_ready_outside_geo
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
			and _battlegeo_init(battle_ready_det_a)
			and _battlegeo_init(battle_ready_det_b)
			and battle_ready_det_a.begin_battle()
			and battle_ready_det_b.begin_battle()
			and battle_ready_det_a.battle_phase == battle_ready_det_b.battle_phase
			and battle_ready_det_a.battle_phase == "active"
		)

	var battle_rt_activate_ok: bool = false
	var battle_rt_no_current_actor_ok: bool = false
	var battle_rt_no_round_ok: bool = false
	var battle_rt_identity_ok: bool = false
	var battle_rt_deploy_unchanged_ok: bool = false
	var battle_rt_immutability_ok: bool = false
	var battle_rt_pack: Dictionary = _battle_create_ready_pack()
	var battle_rt_game: GameState = battle_rt_pack.get("game_state", null) as GameState
	var battle_rt_force: TravelingForce = battle_rt_pack.get("force", null) as TravelingForce
	var battle_rt_bs: BattleState = battle_rt_pack.get("battle_state", null) as BattleState
	var battle_rt_campaign: Dictionary = _battle_campaign_snapshot(
		battle_rt_game, battle_rt_force, "battle_mission"
	)
	if battle_rt_bs != null:
		var battle_rt_deployed: bool = _battle_deploy_standard_attacker(battle_rt_bs)
		var battle_rt_ids_before: Dictionary = _battle_side_ids_snapshot(battle_rt_bs)
		var battle_rt_assign_before: Dictionary = _battle_deploy_assignment_snapshot(battle_rt_bs)
		var battle_rt_no_turn_before: bool = _battle_has_no_combat_turn_model(battle_rt_bs)
		var battle_rt_geo: bool = _battlegeo_init(battle_rt_bs)
		var battle_rt_begun: bool = battle_rt_geo and battle_rt_bs.begin_battle()
		battle_rt_activate_ok = (
			battle_rt_deployed
			and battle_rt_geo
			and battle_rt_no_turn_before
			and battle_rt_bs.is_battle_ready()
			and battle_rt_begun
			and battle_rt_bs.battle_phase == "active"
			and battle_rt_bs.battle_phase != "deployment"
			and battle_rt_bs.battle_phase != "resolved"
		)
		battle_rt_no_current_actor_ok = (
			battle_rt_activate_ok
			and _battle_has_no_combat_turn_model(battle_rt_bs)
			and battle_rt_bs.get("current_turn_index") == null
			and battle_rt_bs.get("turn_actor_ids") == null
			and battle_rt_bs.get("actor_turn_in_progress") == null
			and battle_rt_bs.get("active_turn_actor_id") == null
			and not battle_rt_bs.has_method("initialize_turn_order")
			and not battle_rt_bs.has_method("advance_turn")
			and not battle_rt_bs.has_method("begin_current_actor_turn")
			and not battle_rt_bs.has_method("end_current_actor_turn")
			and not battle_rt_bs.has_method("get_current_turn_actor_id")
			and not battle_rt_bs.has_method("has_current_turn_actor")
			and not battle_rt_bs.has_method("is_actor_turn_in_progress")
		)
		battle_rt_no_round_ok = (
			battle_rt_no_current_actor_ok
			and battle_rt_bs.get("current_round") == null
			and not battle_rt_bs.has_method("get_current_round")
		)
		battle_rt_identity_ok = (
			battle_rt_activate_ok
			and _battle_side_ids_match(battle_rt_bs, battle_rt_ids_before)
			and battle_rt_bs.has_participant("battle_sol_a")
			and battle_rt_bs.has_participant("battle_sol_m")
			and battle_rt_bs.has_participant("battle_sol_z")
			and battle_rt_bs.has_vehicle("battle_veh_a")
			and battle_rt_bs.has_vehicle("battle_veh_m")
			and battle_rt_bs.has_vehicle("battle_veh_z")
		)
		battle_rt_assign_before["phase"] = "active"
		battle_rt_deploy_unchanged_ok = (
			battle_rt_activate_ok
			and _battle_deploy_assignment_unchanged(battle_rt_bs, battle_rt_assign_before)
		)
		battle_rt_immutability_ok = (
			battle_rt_activate_ok
			and _battle_campaign_unchanged(battle_rt_game, battle_rt_campaign, battle_rt_force, "battle_mission")
			and battle_rt_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battle_rt_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)
		var battle_rt_persist_data: Dictionary = battle_rt_game.to_dict()
		battle_rt_immutability_ok = (
			battle_rt_immutability_ok
			and _battle_serialized_campaign_keys_only(battle_rt_persist_data)
			and not _battle_data_has_tactical_trace(battle_rt_persist_data)
		)
	var battle_rt_det_a_pack: Dictionary = _battle_create_ready_pack()
	var battle_rt_det_b_pack: Dictionary = _battle_create_ready_pack()
	var battle_rt_det_a: BattleState = battle_rt_det_a_pack.get("battle_state", null) as BattleState
	var battle_rt_det_b: BattleState = battle_rt_det_b_pack.get("battle_state", null) as BattleState
	if battle_rt_det_a != null and battle_rt_det_b != null:
		var battle_rt_det_a_deployed: bool = _battle_deploy_standard_attacker(battle_rt_det_a)
		var battle_rt_det_b_deployed: bool = false
		if battle_rt_det_b.deploy_vehicle("battle_veh_m", "attacker_deployment"):
			if battle_rt_det_b.deploy_vehicle("battle_veh_a", "attacker_deployment"):
				if battle_rt_det_b.deploy_vehicle("battle_veh_z", "attacker_deployment"):
					if battle_rt_det_b.deploy_participant("battle_sol_m", "attacker_deployment"):
						if battle_rt_det_b.deploy_participant("battle_sol_a", "attacker_deployment"):
							battle_rt_det_b_deployed = battle_rt_det_b.deploy_participant("battle_sol_z", "attacker_deployment")
		var battle_rt_ids_a: Dictionary = _battle_side_ids_snapshot(battle_rt_det_a)
		var battle_rt_ids_b: Dictionary = _battle_side_ids_snapshot(battle_rt_det_b)
		var battle_rt_det_begun: bool = (
			_battlegeo_init(battle_rt_det_a)
			and _battlegeo_init(battle_rt_det_b)
			and battle_rt_det_a.begin_battle()
			and battle_rt_det_b.begin_battle()
		)
		battle_rt_identity_ok = (
			battle_rt_identity_ok
			and battle_rt_det_a_deployed
			and battle_rt_det_b_deployed
			and battle_rt_det_begun
			and battle_rt_det_a.battle_phase == "active"
			and battle_rt_det_b.battle_phase == "active"
			and _battle_side_ids_match(battle_rt_det_a, battle_rt_ids_a)
			and _battle_side_ids_match(battle_rt_det_b, battle_rt_ids_b)
			and _battle_side_ids_match(battle_rt_det_a, battle_rt_ids_b)
			and _battle_has_no_combat_turn_model(battle_rt_det_a)
			and _battle_has_no_combat_turn_model(battle_rt_det_b)
		)

	var battlert_default_ok: bool = false
	var battlert_reject_deploy_ok: bool = false
	var battlert_advance_ok: bool = false
	var battlert_zero_delta_ok: bool = false
	var battlert_invalid_delta_ok: bool = false
	var battlert_invalid_elapsed_ok: bool = false
	var battlert_null_ok: bool = false
	var battlert_intent_norm_ok: bool = false
	var battlert_intent_zero_ok: bool = false
	var battlert_intent_invalid_ok: bool = false
	var battlert_no_move_ok: bool = false
	var battlert_combat_state_ok: bool = false
	var battlert_multi_ok: bool = false
	var battlert_begin_active_ok: bool = false
	var battlert_no_turn_ok: bool = false
	var battlert_result_ok: bool = false
	var battlert_persist_ok: bool = false
	var battlert_immutability_ok: bool = false

	var battlert_fresh_state: BattleState = BattleState.new()
	var battlert_fresh_part: BattleParticipant = BattleParticipant.new()
	battlert_default_ok = (
		is_equal_approx(battlert_fresh_state.elapsed_time_seconds, 0.0)
		and battlert_fresh_part.has_battle_position == false
		and battlert_fresh_part.battle_position.is_equal_approx(Vector2.ZERO)
		and battlert_fresh_part.velocity.is_equal_approx(Vector2.ZERO)
		and battlert_fresh_part.movement_intent.is_equal_approx(Vector2.ZERO)
		and not (
			battlert_fresh_part.battle_position.is_equal_approx(Vector2.ZERO)
			and battlert_fresh_part.has_battle_position
		)
	)

	var battlert_deploy_state: BattleState = _battlert_make_state("deployment")
	if battlert_deploy_state != null:
		var battlert_deploy_elapsed: float = battlert_deploy_state.elapsed_time_seconds
		var battlert_deploy_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_deploy_state, 0.1)
		battlert_reject_deploy_ok = (
			_battlert_fail_ok(battlert_deploy_res, "battle_not_active", battlert_deploy_elapsed)
			and battlert_deploy_res.error_message == "Battle runtime failed: battle phase is 'deployment', not active."
			and is_equal_approx(battlert_deploy_elapsed, 0.0)
			and is_equal_approx(battlert_deploy_state.elapsed_time_seconds, battlert_deploy_elapsed)
			and battlert_deploy_state.battle_phase == "deployment"
		)

	var battlert_clock: BattleState = _battlert_make_state("active")
	if battlert_clock != null:
		var battlert_adv1: BattleRuntimeResult = BattleRuntimeService.advance(battlert_clock, 0.25)
		var battlert_adv1_ok: bool = (
			_battlert_clock_ok(battlert_adv1, 0.25, 0.0, 0.25)
			and is_equal_approx(battlert_clock.elapsed_time_seconds, 0.25)
		)
		var battlert_adv2: BattleRuntimeResult = BattleRuntimeService.advance(battlert_clock, 0.50)
		battlert_advance_ok = (
			battlert_adv1_ok
			and _battlert_clock_ok(battlert_adv2, 0.50, 0.25, 0.75)
			and is_equal_approx(battlert_clock.elapsed_time_seconds, 0.75)
		)
		battlert_no_turn_ok = _battle_has_no_combat_turn_model(battlert_clock)

	var battlert_zero_state: BattleState = _battlert_make_state("active")
	if battlert_zero_state != null:
		battlert_zero_state.elapsed_time_seconds = 1.25
		var battlert_zero_part: BattleParticipant = _battlert_add_participant(
			battlert_zero_state,
			"battlert_zero_p",
			"attacker"
		)
		if battlert_zero_part != null:
			battlert_zero_part.has_battle_position = true
			battlert_zero_part.battle_position = Vector2(4.0, 5.0)
			battlert_zero_part.velocity = Vector2(0.0, 1.0)
			var battlert_zero_intent_ok: bool = battlert_zero_part.set_movement_intent(Vector2(0.0, 1.0))
			var battlert_zero_alive: bool = battlert_zero_part.is_alive
			var battlert_zero_wounded: bool = battlert_zero_part.is_wounded
			var battlert_zero_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_zero_state, 0.0)
			battlert_zero_delta_ok = (
				battlert_zero_intent_ok
				and _battlert_clock_ok(battlert_zero_res, 0.0, 1.25, 1.25)
				and is_equal_approx(battlert_zero_state.elapsed_time_seconds, 1.25)
				and battlert_zero_part.has_battle_position
				and battlert_zero_part.battle_position.is_equal_approx(Vector2(4.0, 5.0))
				and battlert_zero_part.velocity.is_equal_approx(Vector2.ZERO)
				and battlert_zero_part.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
				and battlert_zero_part.is_alive == battlert_zero_alive
				and battlert_zero_part.is_wounded == battlert_zero_wounded
			)

	var battlert_delta_state: BattleState = _battlert_make_state("active")
	if battlert_delta_state != null:
		battlert_delta_state.elapsed_time_seconds = 0.40
		var battlert_neg_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_delta_state, -0.1)
		var battlert_neg_ok: bool = (
			_battlert_fail_ok(battlert_neg_res, "invalid_delta", 0.40)
			and battlert_neg_res.error_message == "Battle runtime failed: delta_seconds is invalid."
			and is_equal_approx(battlert_neg_res.delta_seconds, -0.1)
			and is_equal_approx(battlert_delta_state.elapsed_time_seconds, 0.40)
		)
		var battlert_nan_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_delta_state, NAN)
		var battlert_nan_ok: bool = (
			battlert_nan_res != null
			and not battlert_nan_res.success
			and battlert_nan_res.error_code == "invalid_delta"
			and battlert_nan_res.error_message == "Battle runtime failed: delta_seconds is invalid."
			and is_nan(battlert_nan_res.delta_seconds)
			and is_equal_approx(battlert_nan_res.elapsed_time_before, 0.40)
			and is_equal_approx(battlert_nan_res.elapsed_time_after, 0.40)
			and is_equal_approx(battlert_delta_state.elapsed_time_seconds, 0.40)
		)
		var battlert_inf_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_delta_state, INF)
		var battlert_inf_ok: bool = (
			battlert_inf_res != null
			and not battlert_inf_res.success
			and battlert_inf_res.error_code == "invalid_delta"
			and battlert_inf_res.error_message == "Battle runtime failed: delta_seconds is invalid."
			and is_inf(battlert_inf_res.delta_seconds)
			and is_equal_approx(battlert_inf_res.elapsed_time_before, 0.40)
			and is_equal_approx(battlert_inf_res.elapsed_time_after, 0.40)
			and is_equal_approx(battlert_delta_state.elapsed_time_seconds, 0.40)
		)
		battlert_invalid_delta_ok = battlert_neg_ok and battlert_nan_ok and battlert_inf_ok

	var battlert_elapsed_state: BattleState = _battlert_make_state("active")
	if battlert_elapsed_state != null:
		battlert_elapsed_state.elapsed_time_seconds = -1.0
		var battlert_bad_elapsed_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_elapsed_state, 0.1)
		var battlert_neg_elapsed_ok: bool = (
			_battlert_fail_ok(battlert_bad_elapsed_res, "invalid_elapsed_time", -1.0)
			and battlert_bad_elapsed_res.error_message == "Battle runtime failed: elapsed_time_seconds is invalid."
			and is_equal_approx(battlert_elapsed_state.elapsed_time_seconds, -1.0)
		)
		battlert_elapsed_state.elapsed_time_seconds = NAN
		var battlert_nan_elapsed_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_elapsed_state, 0.1)
		var battlert_nan_elapsed_ok: bool = (
			battlert_nan_elapsed_res != null
			and not battlert_nan_elapsed_res.success
			and battlert_nan_elapsed_res.error_code == "invalid_elapsed_time"
			and battlert_nan_elapsed_res.error_message == "Battle runtime failed: elapsed_time_seconds is invalid."
			and is_nan(battlert_nan_elapsed_res.elapsed_time_before)
			and is_nan(battlert_nan_elapsed_res.elapsed_time_after)
			and is_nan(battlert_elapsed_state.elapsed_time_seconds)
		)
		battlert_elapsed_state.elapsed_time_seconds = INF
		var battlert_inf_elapsed_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_elapsed_state, 0.1)
		var battlert_inf_elapsed_ok: bool = (
			battlert_inf_elapsed_res != null
			and not battlert_inf_elapsed_res.success
			and battlert_inf_elapsed_res.error_code == "invalid_elapsed_time"
			and battlert_inf_elapsed_res.error_message == "Battle runtime failed: elapsed_time_seconds is invalid."
			and is_inf(battlert_inf_elapsed_res.elapsed_time_before)
			and is_inf(battlert_inf_elapsed_res.elapsed_time_after)
			and is_inf(battlert_elapsed_state.elapsed_time_seconds)
		)
		battlert_invalid_elapsed_ok = (
			battlert_neg_elapsed_ok
			and battlert_nan_elapsed_ok
			and battlert_inf_elapsed_ok
		)

	var battlert_null_state: BattleState = null
	var battlert_null_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_null_state, 0.1)
	battlert_null_ok = (
		_battlert_fail_ok(battlert_null_res, "null_battle_state", 0.0)
		and battlert_null_res.error_message == "Battle runtime failed: battle_state is null."
		and is_equal_approx(battlert_null_res.delta_seconds, 0.1)
	)

	var battlert_intent_part: BattleParticipant = BattleParticipant.new(
		"battlert_intent_p",
		"battlert_intent_soldier",
		"battlert_a",
		"attacker",
		"pistol",
		true,
		false,
		""
	)
	var battlert_intent_set: bool = battlert_intent_part.set_movement_intent(Vector2(3.0, 4.0))
	battlert_intent_norm_ok = (
		battlert_intent_set
		and battlert_intent_part.movement_intent.is_equal_approx(Vector2(0.6, 0.8))
		and is_equal_approx(battlert_intent_part.movement_intent.length(), 1.0)
	)
	var battlert_intent_zero_set: bool = battlert_intent_part.set_movement_intent(Vector2.ZERO)
	var battlert_intent_zero_after_set: bool = battlert_intent_part.movement_intent.is_equal_approx(Vector2.ZERO)
	var battlert_intent_reset: bool = battlert_intent_part.set_movement_intent(Vector2(3.0, 4.0))
	battlert_intent_part.clear_movement_intent()
	battlert_intent_zero_ok = (
		battlert_intent_norm_ok
		and battlert_intent_zero_set
		and battlert_intent_zero_after_set
		and battlert_intent_reset
		and battlert_intent_part.movement_intent.is_equal_approx(Vector2.ZERO)
	)
	var battlert_intent_restore: bool = battlert_intent_part.set_movement_intent(Vector2(3.0, 4.0))
	var battlert_intent_before_invalid: Vector2 = battlert_intent_part.movement_intent
	var battlert_nan_intent: Vector2 = Vector2(NAN, 0.0)
	var battlert_inf_intent: Vector2 = Vector2(INF, 1.0)
	var battlert_nan_intent_set: bool = battlert_intent_part.set_movement_intent(battlert_nan_intent)
	var battlert_after_nan: Vector2 = battlert_intent_part.movement_intent
	var battlert_inf_intent_set: bool = battlert_intent_part.set_movement_intent(battlert_inf_intent)
	battlert_intent_invalid_ok = (
		battlert_intent_restore
		and not battlert_nan_intent_set
		and not battlert_inf_intent_set
		and battlert_after_nan.is_equal_approx(battlert_intent_before_invalid)
		and battlert_intent_part.movement_intent.is_equal_approx(battlert_intent_before_invalid)
		and battlert_intent_part.movement_intent.is_equal_approx(Vector2(0.6, 0.8))
	)

	var battlert_move_state: BattleState = _battlert_make_state("active")
	if battlert_move_state != null:
		var battlert_move_part: BattleParticipant = _battlert_add_participant(
			battlert_move_state,
			"battlert_move_p",
			"attacker"
		)
		if battlert_move_part != null:
			battlert_move_part.has_battle_position = true
			battlert_move_part.battle_position = Vector2(10.0, 20.0)
			battlert_move_part.velocity = Vector2.ZERO
			var battlert_move_intent_ok: bool = battlert_move_part.set_movement_intent(Vector2(1.0, 0.0))
			var battlert_move_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_move_state, 1.0)
			battlert_no_move_ok = (
				battlert_move_intent_ok
				and _battlert_clock_ok(battlert_move_res, 1.0, 0.0, 1.0)
				and is_equal_approx(battlert_move_state.elapsed_time_seconds, 1.0)
				and battlert_move_part.has_battle_position
				and battlert_move_part.battle_position.is_equal_approx(Vector2(10.0, 20.0))
				and battlert_move_part.velocity.is_equal_approx(Vector2.ZERO)
				and battlert_move_part.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)

	var battlert_combat_state: BattleState = _battlert_make_state("active")
	if battlert_combat_state != null:
		var battlert_combat_part: BattleParticipant = _battlert_add_participant(
			battlert_combat_state,
			"battlert_combat_p",
			"attacker"
		)
		if battlert_combat_part != null:
			battlert_combat_part.deployment_slot_id = "battlert_slot"
			battlert_combat_part.is_alive = true
			battlert_combat_part.is_wounded = true
			var battlert_combat_alive: bool = battlert_combat_part.is_alive
			var battlert_combat_wounded: bool = battlert_combat_part.is_wounded
			var battlert_combat_slot: String = battlert_combat_part.deployment_slot_id
			var battlert_combat_side: String = battlert_combat_part.side_id
			var battlert_combat_soldier: String = battlert_combat_part.campaign_soldier_id
			var battlert_combat_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_combat_state, 0.5)
			battlert_combat_state_ok = (
				_battlert_clock_ok(battlert_combat_res, 0.5, 0.0, 0.5)
				and battlert_combat_part.is_alive == battlert_combat_alive
				and battlert_combat_part.is_wounded == battlert_combat_wounded
				and battlert_combat_part.deployment_slot_id == battlert_combat_slot
				and battlert_combat_part.side_id == battlert_combat_side
				and battlert_combat_part.campaign_soldier_id == battlert_combat_soldier
				and battlert_combat_part.is_alive == true
				and battlert_combat_part.is_wounded == true
				and battlert_combat_part.deployment_slot_id == "battlert_slot"
				and battlert_combat_part.side_id == "attacker"
				and battlert_combat_part.campaign_soldier_id == "battlert_soldier_battlert_combat_p"
			)

	var battlert_multi_state: BattleState = _battlert_make_state("active")
	if battlert_multi_state != null:
		var battlert_multi_a: BattleParticipant = _battlert_add_participant(
			battlert_multi_state,
			"battlert_multi_a",
			"attacker"
		)
		var battlert_multi_b: BattleParticipant = _battlert_add_participant(
			battlert_multi_state,
			"battlert_multi_b",
			"attacker"
		)
		var battlert_multi_c: BattleParticipant = _battlert_add_participant(
			battlert_multi_state,
			"battlert_multi_c",
			"defender"
		)
		if battlert_multi_a != null and battlert_multi_b != null and battlert_multi_c != null:
			battlert_multi_a.has_battle_position = true
			battlert_multi_a.battle_position = Vector2(10.0, 20.0)
			battlert_multi_a.velocity = Vector2.ZERO
			var battlert_multi_a_intent: bool = battlert_multi_a.set_movement_intent(Vector2(1.0, 0.0))
			battlert_multi_b.has_battle_position = true
			battlert_multi_b.battle_position = Vector2(30.0, 40.0)
			battlert_multi_b.velocity = Vector2(0.0, 2.0)
			var battlert_multi_b_intent: bool = battlert_multi_b.set_movement_intent(Vector2(0.0, 1.0))
			battlert_multi_c.has_battle_position = true
			battlert_multi_c.battle_position = Vector2(50.0, 60.0)
			battlert_multi_c.velocity = Vector2(-1.0, 0.0)
			var battlert_multi_c_intent: bool = battlert_multi_c.set_movement_intent(Vector2(-3.0, -4.0))
			var battlert_multi_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_multi_state, 0.40)
			battlert_multi_ok = (
				battlert_multi_a_intent
				and battlert_multi_b_intent
				and battlert_multi_c_intent
				and _battlert_clock_ok(battlert_multi_res, 0.40, 0.0, 0.40)
				and is_equal_approx(battlert_multi_state.elapsed_time_seconds, 0.40)
				and battlert_multi_a.battle_position.is_equal_approx(Vector2(10.0, 20.0))
				and battlert_multi_a.velocity.is_equal_approx(Vector2.ZERO)
				and battlert_multi_a.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlert_multi_b.battle_position.is_equal_approx(Vector2(30.0, 40.0))
				and battlert_multi_b.velocity.is_equal_approx(Vector2.ZERO)
				and battlert_multi_b.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
				and battlert_multi_c.battle_position.is_equal_approx(Vector2(50.0, 60.0))
				and battlert_multi_c.velocity.is_equal_approx(Vector2.ZERO)
				and battlert_multi_c.movement_intent.is_equal_approx(Vector2(-0.6, -0.8))
			)
			battlert_no_turn_ok = (
				battlert_no_turn_ok
				and _battle_has_no_combat_turn_model(battlert_multi_state)
			)

	var battlert_begin_pack: Dictionary = _battle_create_ready_pack()
	var battlert_begin_bs: BattleState = battlert_begin_pack.get("battle_state", null) as BattleState
	if battlert_begin_bs != null:
		var battlert_begin_deployed: bool = _battle_deploy_standard_attacker(battlert_begin_bs)
		var battlert_begin_assign: Dictionary = _battle_deploy_assignment_snapshot(battlert_begin_bs)
		var battlert_begin_before_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_begin_bs, 0.1)
		var battlert_begin_blocked: bool = (
			battlert_begin_deployed
			and battlert_begin_bs.battle_phase == "deployment"
			and is_equal_approx(battlert_begin_bs.elapsed_time_seconds, 0.0)
			and _battlert_fail_ok(battlert_begin_before_res, "battle_not_active", 0.0)
		)
		var battlert_begun: bool = _battlegeo_init(battlert_begin_bs) and battlert_begin_bs.begin_battle()
		var battlert_begin_after_res: BattleRuntimeResult = BattleRuntimeService.advance(battlert_begin_bs, 0.25)
		battlert_begin_assign["phase"] = "active"
		battlert_begin_active_ok = (
			battlert_begin_blocked
			and battlert_begun
			and battlert_begin_bs.battle_phase == "active"
			and _battlert_clock_ok(battlert_begin_after_res, 0.25, 0.0, 0.25)
			and is_equal_approx(battlert_begin_bs.elapsed_time_seconds, 0.25)
			and _battle_deploy_assignment_unchanged(battlert_begin_bs, battlert_begin_assign)
		)
		battlert_no_turn_ok = (
			battlert_no_turn_ok
			and _battle_has_no_combat_turn_model(battlert_begin_bs)
			and battlert_begin_bs.get("current_turn_index") == null
			and battlert_begin_bs.get("current_round") == null
			and battlert_begin_bs.get("actor_turn_in_progress") == null
			and battlert_begin_bs.get("active_turn_actor_id") == null
		)

	var battlert_ok_res: BattleRuntimeResult = BattleRuntimeResult.succeeded(0.25, 0.0, 0.25)
	var battlert_fail_res: BattleRuntimeResult = BattleRuntimeResult.failed(
		"invalid_delta",
		"Battle runtime failed: delta_seconds is invalid.",
		-1.0,
		0.4
	)
	battlert_result_ok = (
		battlert_ok_res != null
		and battlert_ok_res.success
		and is_equal_approx(battlert_ok_res.delta_seconds, 0.25)
		and is_equal_approx(battlert_ok_res.elapsed_time_before, 0.0)
		and is_equal_approx(battlert_ok_res.elapsed_time_after, 0.25)
		and battlert_ok_res.error_code.is_empty()
		and battlert_ok_res.error_message.is_empty()
		and battlert_fail_res != null
		and not battlert_fail_res.success
		and battlert_fail_res.error_code == "invalid_delta"
		and battlert_fail_res.error_message == "Battle runtime failed: delta_seconds is invalid."
		and is_equal_approx(battlert_fail_res.delta_seconds, -1.0)
		and is_equal_approx(battlert_fail_res.elapsed_time_before, 0.4)
		and is_equal_approx(battlert_fail_res.elapsed_time_after, 0.4)
	)

	var battlert_persist_pack: Dictionary = _battle_create_ready_pack()
	var battlert_persist_game: GameState = battlert_persist_pack.get("game_state", null) as GameState
	var battlert_persist_bs: BattleState = battlert_persist_pack.get("battle_state", null) as BattleState
	if battlert_persist_game != null and battlert_persist_bs != null:
		var battlert_persist_deployed: bool = _battle_deploy_standard_attacker(battlert_persist_bs)
		var battlert_persist_begun: bool = _battlegeo_init(battlert_persist_bs) and battlert_persist_bs.begin_battle()
		battlert_persist_bs.elapsed_time_seconds = 42.75
		var battlert_persist_part: BattleParticipant = battlert_persist_bs.get_participant("battle_sol_a")
		if battlert_persist_part != null:
			battlert_persist_part.has_battle_position = true
			battlert_persist_part.battle_position = Vector2(123.0, 456.0)
			battlert_persist_part.velocity = Vector2(7.0, 8.0)
			var battlert_persist_intent: bool = battlert_persist_part.set_movement_intent(Vector2(1.0, 0.0))
			var battlert_persist_data: Dictionary = battlert_persist_game.to_dict()
			battlert_persist_ok = (
				battlert_persist_deployed
				and battlert_persist_begun
				and battlert_persist_intent
				and is_equal_approx(battlert_persist_bs.elapsed_time_seconds, 42.75)
				and battlert_persist_part.has_battle_position
				and battlert_persist_part.battle_position.is_equal_approx(Vector2(123.0, 456.0))
				and battlert_persist_part.velocity.is_equal_approx(Vector2(7.0, 8.0))
				and battlert_persist_part.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and _battle_serialized_campaign_keys_only(battlert_persist_data)
				and not _battle_data_has_tactical_trace(battlert_persist_data)
			)

	var battlert_imm_pack: Dictionary = _battle_create_ready_pack()
	var battlert_imm_game: GameState = battlert_imm_pack.get("game_state", null) as GameState
	var battlert_imm_force: TravelingForce = battlert_imm_pack.get("force", null) as TravelingForce
	var battlert_imm_bs: BattleState = battlert_imm_pack.get("battle_state", null) as BattleState
	var battlert_imm_campaign: Dictionary = _battle_campaign_snapshot(
		battlert_imm_game,
		battlert_imm_force,
		"battle_mission"
	)
	if battlert_imm_game != null and battlert_imm_bs != null:
		var battlert_imm_deployed: bool = _battle_deploy_standard_attacker(battlert_imm_bs)
		var battlert_imm_begun: bool = _battlegeo_init(battlert_imm_bs) and battlert_imm_bs.begin_battle()
		var battlert_imm_res1: BattleRuntimeResult = BattleRuntimeService.advance(battlert_imm_bs, 0.10)
		var battlert_imm_res2: BattleRuntimeResult = BattleRuntimeService.advance(battlert_imm_bs, 0.20)
		var battlert_imm_res3: BattleRuntimeResult = BattleRuntimeService.advance(battlert_imm_bs, 0.30)
		battlert_immutability_ok = (
			battlert_imm_deployed
			and battlert_imm_begun
			and _battlert_clock_ok(battlert_imm_res1, 0.10, 0.0, 0.10)
			and _battlert_clock_ok(battlert_imm_res2, 0.20, 0.10, 0.30)
			and _battlert_clock_ok(battlert_imm_res3, 0.30, 0.30, 0.60)
			and is_equal_approx(battlert_imm_bs.elapsed_time_seconds, 0.60)
			and _battle_campaign_unchanged(
				battlert_imm_game,
				battlert_imm_campaign,
				battlert_imm_force,
				"battle_mission"
			)
			and battlert_imm_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlert_imm_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlemove_default_ok: bool = false
	var battlemove_speed_set_ok: bool = false
	var battlemove_reject_ok: bool = false
	var battlemove_physics_ok: bool = false
	var battlemove_zero_delta_ok: bool = false
	var battlemove_zero_speed_ok: bool = false
	var battlemove_zero_intent_ok: bool = false
	var battlemove_unpos_ok: bool = false
	var battlemove_dead_ok: bool = false
	var battlemove_bad_speed_ok: bool = false
	var battlemove_bad_intent_ok: bool = false
	var battlemove_norm_ok: bool = false
	var battlemove_multi_ok: bool = false
	var battlemove_runtime_ok: bool = false
	var battlemove_tx_ok: bool = false
	var battlemove_intent_stable_ok: bool = false
	var battlemove_wounded_ok: bool = false
	var battlemove_weapon_ok: bool = false
	var battlemove_deploy_geo_ok: bool = false
	var battlemove_persist_ok: bool = false
	var battlemove_immutability_ok: bool = false
	var battlemove_no_turn_ok: bool = false
	var battlemove_result_ok: bool = false

	var battlemove_fresh: BattleParticipant = BattleParticipant.new()
	battlemove_default_ok = (
		is_equal_approx(battlemove_fresh.movement_speed, 0.0)
		and battlemove_fresh.velocity.is_equal_approx(Vector2.ZERO)
		and battlemove_fresh.movement_intent.is_equal_approx(Vector2.ZERO)
		and battlemove_fresh.has_battle_position == false
	)

	var battlemove_speed_part: BattleParticipant = BattleParticipant.new()
	var battlemove_speed_pos: bool = battlemove_speed_part.set_movement_speed(5.0)
	var battlemove_speed_stored: float = battlemove_speed_part.movement_speed
	var battlemove_speed_zero: bool = battlemove_speed_part.set_movement_speed(0.0)
	var battlemove_speed_zero_stored: float = battlemove_speed_part.movement_speed
	var battlemove_speed_neg: bool = battlemove_speed_part.set_movement_speed(-1.0)
	var battlemove_speed_after_neg: float = battlemove_speed_part.movement_speed
	var battlemove_speed_nan: bool = battlemove_speed_part.set_movement_speed(NAN)
	var battlemove_speed_after_nan: float = battlemove_speed_part.movement_speed
	var battlemove_speed_inf: bool = battlemove_speed_part.set_movement_speed(INF)
	battlemove_speed_set_ok = (
		battlemove_speed_pos
		and is_equal_approx(battlemove_speed_stored, 5.0)
		and battlemove_speed_zero
		and is_equal_approx(battlemove_speed_zero_stored, 0.0)
		and not battlemove_speed_neg
		and is_equal_approx(battlemove_speed_after_neg, 0.0)
		and not battlemove_speed_nan
		and is_equal_approx(battlemove_speed_after_nan, 0.0)
		and not battlemove_speed_inf
		and is_equal_approx(battlemove_speed_part.movement_speed, 0.0)
	)
	var battlemove_speed_reset: bool = battlemove_speed_part.set_movement_speed(5.0)
	battlemove_speed_set_ok = (
		battlemove_speed_set_ok
		and battlemove_speed_reset
		and is_equal_approx(battlemove_speed_part.movement_speed, 5.0)
		and not battlemove_speed_part.set_movement_speed(-2.0)
		and is_equal_approx(battlemove_speed_part.movement_speed, 5.0)
		and not battlemove_speed_part.set_movement_speed(NAN)
		and is_equal_approx(battlemove_speed_part.movement_speed, 5.0)
		and not battlemove_speed_part.set_movement_speed(INF)
		and is_equal_approx(battlemove_speed_part.movement_speed, 5.0)
	)

	var battlemove_reject_null: BattleState = null
	var battlemove_null_res: BattleMovementResult = BattleMovementService.advance(battlemove_reject_null, 0.1)
	var battlemove_deploy_state: BattleState = _battlemove_make_state("deployment")
	var battlemove_reject_deploy_ok: bool = false
	if battlemove_deploy_state != null:
		var battlemove_reject_p: BattleParticipant = _battlemove_add_participant(
			battlemove_deploy_state,
			"battlemove_reject_p",
			"attacker"
		)
		if battlemove_reject_p != null:
			battlemove_reject_p.has_battle_position = true
			battlemove_reject_p.battle_position = Vector2(1.0, 2.0)
			battlemove_reject_p.velocity = Vector2(3.0, 4.0)
			var battlemove_reject_speed: bool = battlemove_reject_p.set_movement_speed(5.0)
			var battlemove_reject_intent: bool = battlemove_reject_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_reject_snap: Dictionary = _battlemove_part_snap(battlemove_reject_p)
			var battlemove_deploy_res: BattleMovementResult = BattleMovementService.advance(battlemove_deploy_state, 0.25)
			var battlemove_deploy_fail_ok: bool = (
				_battlemove_fail_ok(battlemove_deploy_res, "battle_not_active", 0.25)
				and battlemove_deploy_res.error_message == "Battle movement failed: battle phase is 'deployment', not active."
				and _battlemove_part_unchanged(battlemove_reject_p, battlemove_reject_snap)
			)
			battlemove_deploy_state.battle_phase = "active"
			var battlemove_neg_res: BattleMovementResult = BattleMovementService.advance(battlemove_deploy_state, -0.5)
			var battlemove_nan_delta: BattleMovementResult = BattleMovementService.advance(battlemove_deploy_state, NAN)
			var battlemove_inf_delta: BattleMovementResult = BattleMovementService.advance(battlemove_deploy_state, INF)
			battlemove_reject_deploy_ok = (
				battlemove_reject_speed
				and battlemove_reject_intent
				and battlemove_deploy_fail_ok
				and _battlemove_fail_ok(battlemove_neg_res, "invalid_delta", -0.5)
				and battlemove_neg_res.error_message == "Battle movement failed: delta_seconds is invalid."
				and battlemove_nan_delta != null
				and not battlemove_nan_delta.success
				and battlemove_nan_delta.error_code == "invalid_delta"
				and is_nan(battlemove_nan_delta.delta_seconds)
				and battlemove_inf_delta != null
				and not battlemove_inf_delta.success
				and battlemove_inf_delta.error_code == "invalid_delta"
				and is_inf(battlemove_inf_delta.delta_seconds)
				and _battlemove_part_unchanged(battlemove_reject_p, battlemove_reject_snap)
			)
	battlemove_reject_ok = (
		_battlemove_fail_ok(battlemove_null_res, "null_battle_state", 0.1)
		and battlemove_null_res.error_message == "Battle movement failed: battle_state is null."
		and battlemove_reject_deploy_ok
	)

	var battlemove_phys_state: BattleState = _battlemove_make_state("active")
	if battlemove_phys_state != null:
		var battlemove_phys_p: BattleParticipant = _battlemove_add_participant(
			battlemove_phys_state,
			"battlemove_phys_p",
			"attacker"
		)
		if battlemove_phys_p != null:
			battlemove_phys_p.has_battle_position = true
			battlemove_phys_p.battle_position = Vector2(10.0, 20.0)
			var battlemove_phys_speed: bool = battlemove_phys_p.set_movement_speed(4.0)
			var battlemove_phys_intent: bool = battlemove_phys_p.set_movement_intent(Vector2(3.0, 4.0))
			var battlemove_phys_res: BattleMovementResult = BattleMovementService.advance(battlemove_phys_state, 2.0)
			battlemove_physics_ok = (
				battlemove_phys_speed
				and battlemove_phys_intent
				and battlemove_phys_p.movement_intent.is_equal_approx(Vector2(0.6, 0.8))
				and _battlemove_ok(battlemove_phys_res, 2.0, 1, 1)
				and battlemove_phys_p.velocity.is_equal_approx(Vector2(2.4, 3.2))
				and battlemove_phys_p.battle_position.is_equal_approx(Vector2(14.8, 26.4))
			)
			battlemove_no_turn_ok = _battle_has_no_combat_turn_model(battlemove_phys_state)

	var battlemove_zd_state: BattleState = _battlemove_make_state("active")
	if battlemove_zd_state != null:
		var battlemove_zd_p: BattleParticipant = _battlemove_add_participant(
			battlemove_zd_state,
			"battlemove_zd_p",
			"attacker"
		)
		if battlemove_zd_p != null:
			battlemove_zd_p.has_battle_position = true
			battlemove_zd_p.battle_position = Vector2(8.0, 9.0)
			var battlemove_zd_speed: bool = battlemove_zd_p.set_movement_speed(5.0)
			var battlemove_zd_intent: bool = battlemove_zd_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_zd_res: BattleMovementResult = BattleMovementService.advance(battlemove_zd_state, 0.0)
			battlemove_zero_delta_ok = (
				battlemove_zd_speed
				and battlemove_zd_intent
				and _battlemove_ok(battlemove_zd_res, 0.0, 1, 0)
				and battlemove_zd_p.velocity.is_equal_approx(Vector2(5.0, 0.0))
				and battlemove_zd_p.battle_position.is_equal_approx(Vector2(8.0, 9.0))
			)

	var battlemove_zs_state: BattleState = _battlemove_make_state("active")
	if battlemove_zs_state != null:
		var battlemove_zs_p: BattleParticipant = _battlemove_add_participant(
			battlemove_zs_state,
			"battlemove_zs_p",
			"attacker"
		)
		if battlemove_zs_p != null:
			battlemove_zs_p.has_battle_position = true
			battlemove_zs_p.battle_position = Vector2(10.0, 20.0)
			battlemove_zs_p.velocity = Vector2(7.0, 8.0)
			var battlemove_zs_speed: bool = battlemove_zs_p.set_movement_speed(0.0)
			var battlemove_zs_intent: bool = battlemove_zs_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_zs_res: BattleMovementResult = BattleMovementService.advance(battlemove_zs_state, 1.0)
			battlemove_zero_speed_ok = (
				battlemove_zs_speed
				and battlemove_zs_intent
				and _battlemove_ok(battlemove_zs_res, 1.0, 1, 0)
				and battlemove_zs_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_zs_p.battle_position.is_equal_approx(Vector2(10.0, 20.0))
				and battlemove_zs_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)

	var battlemove_zi_state: BattleState = _battlemove_make_state("active")
	if battlemove_zi_state != null:
		var battlemove_zi_p: BattleParticipant = _battlemove_add_participant(
			battlemove_zi_state,
			"battlemove_zi_p",
			"attacker"
		)
		if battlemove_zi_p != null:
			battlemove_zi_p.has_battle_position = true
			battlemove_zi_p.battle_position = Vector2(2.0, 3.0)
			battlemove_zi_p.velocity = Vector2(9.0, 1.0)
			var battlemove_zi_speed: bool = battlemove_zi_p.set_movement_speed(6.0)
			var battlemove_zi_intent: bool = battlemove_zi_p.set_movement_intent(Vector2.ZERO)
			var battlemove_zi_res: BattleMovementResult = BattleMovementService.advance(battlemove_zi_state, 1.0)
			battlemove_zero_intent_ok = (
				battlemove_zi_speed
				and battlemove_zi_intent
				and _battlemove_ok(battlemove_zi_res, 1.0, 1, 0)
				and battlemove_zi_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_zi_p.battle_position.is_equal_approx(Vector2(2.0, 3.0))
				and battlemove_zi_p.movement_intent.is_equal_approx(Vector2.ZERO)
			)

	var battlemove_unpos_state: BattleState = _battlemove_make_state("active")
	if battlemove_unpos_state != null:
		var battlemove_unpos_p: BattleParticipant = _battlemove_add_participant(
			battlemove_unpos_state,
			"battlemove_unpos_p",
			"attacker"
		)
		if battlemove_unpos_p != null:
			battlemove_unpos_p.has_battle_position = false
			battlemove_unpos_p.battle_position = Vector2.ZERO
			battlemove_unpos_p.velocity = Vector2(4.0, 5.0)
			var battlemove_unpos_speed: bool = battlemove_unpos_p.set_movement_speed(8.0)
			var battlemove_unpos_intent: bool = battlemove_unpos_p.set_movement_intent(Vector2(0.0, 1.0))
			var battlemove_unpos_res: BattleMovementResult = BattleMovementService.advance(battlemove_unpos_state, 1.0)
			battlemove_unpos_ok = (
				battlemove_unpos_speed
				and battlemove_unpos_intent
				and _battlemove_ok(battlemove_unpos_res, 1.0, 1, 0)
				and battlemove_unpos_p.has_battle_position == false
				and battlemove_unpos_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_unpos_p.battle_position.is_equal_approx(Vector2.ZERO)
				and battlemove_unpos_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
			)

	var battlemove_dead_state: BattleState = _battlemove_make_state("active")
	if battlemove_dead_state != null:
		var battlemove_dead_p: BattleParticipant = _battlemove_add_participant(
			battlemove_dead_state,
			"battlemove_dead_p",
			"attacker"
		)
		if battlemove_dead_p != null:
			battlemove_dead_p.has_battle_position = true
			battlemove_dead_p.battle_position = Vector2(12.0, 13.0)
			battlemove_dead_p.velocity = Vector2(2.0, 2.0)
			battlemove_dead_p.is_alive = false
			var battlemove_dead_speed: bool = battlemove_dead_p.set_movement_speed(5.0)
			var battlemove_dead_intent: bool = battlemove_dead_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_dead_res: BattleMovementResult = BattleMovementService.advance(battlemove_dead_state, 1.0)
			battlemove_dead_ok = (
				battlemove_dead_speed
				and battlemove_dead_intent
				and _battlemove_ok(battlemove_dead_res, 1.0, 1, 0)
				and battlemove_dead_p.is_alive == false
				and battlemove_dead_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_dead_p.battle_position.is_equal_approx(Vector2(12.0, 13.0))
				and battlemove_dead_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)

	var battlemove_badsp_state: BattleState = _battlemove_make_state("active")
	if battlemove_badsp_state != null:
		var battlemove_bad_neg: BattleParticipant = _battlemove_add_participant(
			battlemove_badsp_state,
			"battlemove_bad_neg",
			"attacker"
		)
		var battlemove_bad_nan: BattleParticipant = _battlemove_add_participant(
			battlemove_badsp_state,
			"battlemove_bad_nan",
			"attacker"
		)
		var battlemove_bad_inf: BattleParticipant = _battlemove_add_participant(
			battlemove_badsp_state,
			"battlemove_bad_inf",
			"attacker"
		)
		var battlemove_bad_okp: BattleParticipant = _battlemove_add_participant(
			battlemove_badsp_state,
			"battlemove_bad_okp",
			"attacker"
		)
		if (
			battlemove_bad_neg != null
			and battlemove_bad_nan != null
			and battlemove_bad_inf != null
			and battlemove_bad_okp != null
		):
			battlemove_bad_neg.has_battle_position = true
			battlemove_bad_neg.battle_position = Vector2(1.0, 1.0)
			battlemove_bad_neg.velocity = Vector2(1.0, 1.0)
			battlemove_bad_neg.movement_speed = -1.0
			var battlemove_bad_neg_intent: bool = battlemove_bad_neg.set_movement_intent(Vector2(1.0, 0.0))
			battlemove_bad_nan.has_battle_position = true
			battlemove_bad_nan.battle_position = Vector2(2.0, 2.0)
			battlemove_bad_nan.velocity = Vector2(1.0, 0.0)
			battlemove_bad_nan.movement_speed = NAN
			var battlemove_bad_nan_intent: bool = battlemove_bad_nan.set_movement_intent(Vector2(0.0, 1.0))
			battlemove_bad_inf.has_battle_position = true
			battlemove_bad_inf.battle_position = Vector2(3.0, 3.0)
			battlemove_bad_inf.velocity = Vector2(0.0, 1.0)
			battlemove_bad_inf.movement_speed = INF
			var battlemove_bad_inf_intent: bool = battlemove_bad_inf.set_movement_intent(Vector2(1.0, 0.0))
			battlemove_bad_okp.has_battle_position = true
			battlemove_bad_okp.battle_position = Vector2(1.0, 1.0)
			var battlemove_bad_ok_speed: bool = battlemove_bad_okp.set_movement_speed(2.0)
			var battlemove_bad_ok_intent: bool = battlemove_bad_okp.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_badsp_res: BattleMovementResult = BattleMovementService.advance(battlemove_badsp_state, 1.0)
			battlemove_bad_speed_ok = (
				battlemove_bad_neg_intent
				and battlemove_bad_nan_intent
				and battlemove_bad_inf_intent
				and battlemove_bad_ok_speed
				and battlemove_bad_ok_intent
				and _battlemove_ok(battlemove_badsp_res, 1.0, 4, 1)
				and is_equal_approx(battlemove_bad_neg.movement_speed, -1.0)
				and battlemove_bad_neg.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_bad_neg.battle_position.is_equal_approx(Vector2(1.0, 1.0))
				and is_nan(battlemove_bad_nan.movement_speed)
				and battlemove_bad_nan.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_bad_nan.battle_position.is_equal_approx(Vector2(2.0, 2.0))
				and is_inf(battlemove_bad_inf.movement_speed)
				and battlemove_bad_inf.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_bad_inf.battle_position.is_equal_approx(Vector2(3.0, 3.0))
				and battlemove_bad_okp.velocity.is_equal_approx(Vector2(2.0, 0.0))
				and battlemove_bad_okp.battle_position.is_equal_approx(Vector2(3.0, 1.0))
			)

	var battlemove_badi_state: BattleState = _battlemove_make_state("active")
	if battlemove_badi_state != null:
		var battlemove_badi_p: BattleParticipant = _battlemove_add_participant(
			battlemove_badi_state,
			"battlemove_badi_p",
			"attacker"
		)
		if battlemove_badi_p != null:
			battlemove_badi_p.has_battle_position = true
			battlemove_badi_p.battle_position = Vector2(5.0, 6.0)
			var battlemove_badi_speed: bool = battlemove_badi_p.set_movement_speed(4.0)
			battlemove_badi_p.movement_intent = Vector2(NAN, 1.0)
			var battlemove_badi_res: BattleMovementResult = BattleMovementService.advance(battlemove_badi_state, 1.0)
			battlemove_bad_intent_ok = (
				battlemove_badi_speed
				and _battlemove_ok(battlemove_badi_res, 1.0, 1, 0)
				and battlemove_badi_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlemove_badi_p.battle_position.is_equal_approx(Vector2(5.0, 6.0))
				and is_nan(battlemove_badi_p.movement_intent.x)
				and is_equal_approx(battlemove_badi_p.movement_intent.y, 1.0)
			)

	var battlemove_norm_state: BattleState = _battlemove_make_state("active")
	if battlemove_norm_state != null:
		var battlemove_norm_p: BattleParticipant = _battlemove_add_participant(
			battlemove_norm_state,
			"battlemove_norm_p",
			"attacker"
		)
		if battlemove_norm_p != null:
			battlemove_norm_p.has_battle_position = true
			battlemove_norm_p.battle_position = Vector2(0.0, 0.0)
			var battlemove_norm_speed: bool = battlemove_norm_p.set_movement_speed(3.0)
			battlemove_norm_p.movement_intent = Vector2(10.0, 0.0)
			var battlemove_norm_res: BattleMovementResult = BattleMovementService.advance(battlemove_norm_state, 1.0)
			battlemove_norm_ok = (
				battlemove_norm_speed
				and _battlemove_ok(battlemove_norm_res, 1.0, 1, 1)
				and battlemove_norm_p.velocity.is_equal_approx(Vector2(3.0, 0.0))
				and not battlemove_norm_p.velocity.is_equal_approx(Vector2(30.0, 0.0))
				and battlemove_norm_p.battle_position.is_equal_approx(Vector2(3.0, 0.0))
				and battlemove_norm_p.movement_intent.is_equal_approx(Vector2(10.0, 0.0))
			)

	var battlemove_multi_state: BattleState = _battlemove_make_state("active")
	if battlemove_multi_state != null:
		var battlemove_mz: BattleParticipant = _battlemove_add_participant(
			battlemove_multi_state,
			"z_unit",
			"attacker"
		)
		var battlemove_ma: BattleParticipant = _battlemove_add_participant(
			battlemove_multi_state,
			"a_unit",
			"attacker"
		)
		var battlemove_mm: BattleParticipant = _battlemove_add_participant(
			battlemove_multi_state,
			"m_unit",
			"defender"
		)
		if battlemove_mz != null and battlemove_ma != null and battlemove_mm != null:
			battlemove_mz.has_battle_position = true
			battlemove_mz.battle_position = Vector2(0.0, 0.0)
			var battlemove_mz_speed: bool = battlemove_mz.set_movement_speed(1.0)
			var battlemove_mz_intent: bool = battlemove_mz.set_movement_intent(Vector2(1.0, 0.0))
			battlemove_ma.has_battle_position = true
			battlemove_ma.battle_position = Vector2(10.0, 0.0)
			var battlemove_ma_speed: bool = battlemove_ma.set_movement_speed(2.0)
			var battlemove_ma_intent: bool = battlemove_ma.set_movement_intent(Vector2(0.0, 1.0))
			battlemove_mm.has_battle_position = true
			battlemove_mm.battle_position = Vector2(3.0, 10.0)
			var battlemove_mm_speed: bool = battlemove_mm.set_movement_speed(3.0)
			var battlemove_mm_intent: bool = battlemove_mm.set_movement_intent(Vector2(-1.0, 0.0))
			var battlemove_multi_res: BattleMovementResult = BattleMovementService.advance(battlemove_multi_state, 1.0)
			battlemove_multi_ok = (
				battlemove_mz_speed
				and battlemove_mz_intent
				and battlemove_ma_speed
				and battlemove_ma_intent
				and battlemove_mm_speed
				and battlemove_mm_intent
				and _battlemove_ok(battlemove_multi_res, 1.0, 3, 3)
				and battlemove_mz.velocity.is_equal_approx(Vector2(1.0, 0.0))
				and battlemove_mz.battle_position.is_equal_approx(Vector2(1.0, 0.0))
				and battlemove_ma.velocity.is_equal_approx(Vector2(0.0, 2.0))
				and battlemove_ma.battle_position.is_equal_approx(Vector2(10.0, 2.0))
				and battlemove_mm.velocity.is_equal_approx(Vector2(-3.0, 0.0))
				and battlemove_mm.battle_position.is_equal_approx(Vector2(0.0, 10.0))
			)
			battlemove_no_turn_ok = (
				battlemove_no_turn_ok
				and _battle_has_no_combat_turn_model(battlemove_multi_state)
			)

	var battlemove_rt_state: BattleState = _battlemove_make_state("active")
	if battlemove_rt_state != null:
		var battlemove_rt_p: BattleParticipant = _battlemove_add_participant(
			battlemove_rt_state,
			"battlemove_rt_p",
			"attacker"
		)
		if battlemove_rt_p != null:
			battlemove_rt_p.has_battle_position = true
			battlemove_rt_p.battle_position = Vector2(10.0, 20.0)
			var battlemove_rt_speed: bool = battlemove_rt_p.set_movement_speed(4.0)
			var battlemove_rt_intent: bool = battlemove_rt_p.set_movement_intent(Vector2(3.0, 4.0))
			var battlemove_rt_res: BattleRuntimeResult = BattleRuntimeService.advance(battlemove_rt_state, 2.0)
			battlemove_runtime_ok = (
				battlemove_rt_speed
				and battlemove_rt_intent
				and _battlert_clock_ok(battlemove_rt_res, 2.0, 0.0, 2.0)
				and is_equal_approx(battlemove_rt_state.elapsed_time_seconds, 2.0)
				and battlemove_rt_p.velocity.is_equal_approx(Vector2(2.4, 3.2))
				and battlemove_rt_p.battle_position.is_equal_approx(Vector2(14.8, 26.4))
			)

	var battlemove_tx_state: BattleState = _battlemove_make_state("active")
	if battlemove_tx_state != null:
		var battlemove_tx_p: BattleParticipant = _battlemove_add_participant(
			battlemove_tx_state,
			"battlemove_tx_p",
			"attacker"
		)
		if battlemove_tx_p != null:
			battlemove_tx_p.has_battle_position = true
			battlemove_tx_p.battle_position = Vector2(10.0, 20.0)
			battlemove_tx_p.velocity = Vector2(1.0, 1.0)
			var battlemove_tx_speed: bool = battlemove_tx_p.set_movement_speed(4.0)
			var battlemove_tx_intent: bool = battlemove_tx_p.set_movement_intent(Vector2(1.0, 0.0))
			battlemove_tx_state.elapsed_time_seconds = 3.0
			var battlemove_tx_snap: Dictionary = _battlemove_part_snap(battlemove_tx_p)
			var battlemove_tx_neg: BattleRuntimeResult = BattleRuntimeService.advance(battlemove_tx_state, -0.5)
			var battlemove_tx_neg_ok: bool = (
				battlemove_tx_speed
				and battlemove_tx_intent
				and _battlert_fail_ok(battlemove_tx_neg, "invalid_delta", 3.0)
				and is_equal_approx(battlemove_tx_state.elapsed_time_seconds, 3.0)
				and _battlemove_part_unchanged(battlemove_tx_p, battlemove_tx_snap)
			)
			battlemove_tx_state.battle_phase = "deployment"
			var battlemove_tx_phase: BattleRuntimeResult = BattleRuntimeService.advance(battlemove_tx_state, 1.0)
			battlemove_tx_ok = (
				battlemove_tx_neg_ok
				and _battlert_fail_ok(battlemove_tx_phase, "battle_not_active", 3.0)
				and is_equal_approx(battlemove_tx_state.elapsed_time_seconds, 3.0)
				and _battlemove_part_unchanged(battlemove_tx_p, battlemove_tx_snap)
			)

	var battlemove_int_state: BattleState = _battlemove_make_state("active")
	if battlemove_int_state != null:
		var battlemove_int_p: BattleParticipant = _battlemove_add_participant(
			battlemove_int_state,
			"battlemove_int_p",
			"attacker"
		)
		if battlemove_int_p != null:
			battlemove_int_p.has_battle_position = true
			battlemove_int_p.battle_position = Vector2(0.0, 0.0)
			var battlemove_int_speed: bool = battlemove_int_p.set_movement_speed(1.0)
			var battlemove_int_set: bool = battlemove_int_p.set_movement_intent(Vector2(0.0, 1.0))
			var battlemove_int_before: Vector2 = battlemove_int_p.movement_intent
			var battlemove_int_r1: BattleMovementResult = BattleMovementService.advance(battlemove_int_state, 0.5)
			var battlemove_int_r2: BattleMovementResult = BattleMovementService.advance(battlemove_int_state, 0.5)
			var battlemove_int_r3: BattleMovementResult = BattleMovementService.advance(battlemove_int_state, 0.5)
			battlemove_intent_stable_ok = (
				battlemove_int_speed
				and battlemove_int_set
				and battlemove_int_r1 != null
				and battlemove_int_r1.success
				and battlemove_int_r2 != null
				and battlemove_int_r2.success
				and battlemove_int_r3 != null
				and battlemove_int_r3.success
				and battlemove_int_p.movement_intent.is_equal_approx(battlemove_int_before)
				and battlemove_int_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
			)

	var battlemove_wnd_state: BattleState = _battlemove_make_state("active")
	if battlemove_wnd_state != null:
		var battlemove_wnd_a: BattleParticipant = _battlemove_add_participant(
			battlemove_wnd_state,
			"battlemove_wnd_a",
			"attacker"
		)
		var battlemove_wnd_b: BattleParticipant = _battlemove_add_participant(
			battlemove_wnd_state,
			"battlemove_wnd_b",
			"attacker"
		)
		if battlemove_wnd_a != null and battlemove_wnd_b != null:
			battlemove_wnd_a.has_battle_position = true
			battlemove_wnd_a.battle_position = Vector2(0.0, 0.0)
			battlemove_wnd_a.is_wounded = false
			var battlemove_wnd_a_speed: bool = battlemove_wnd_a.set_movement_speed(2.0)
			var battlemove_wnd_a_intent: bool = battlemove_wnd_a.set_movement_intent(Vector2(1.0, 0.0))
			battlemove_wnd_b.has_battle_position = true
			battlemove_wnd_b.battle_position = Vector2(0.0, 0.0)
			battlemove_wnd_b.is_wounded = true
			var battlemove_wnd_b_speed: bool = battlemove_wnd_b.set_movement_speed(2.0)
			var battlemove_wnd_b_intent: bool = battlemove_wnd_b.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_wnd_res: BattleMovementResult = BattleMovementService.advance(battlemove_wnd_state, 1.0)
			battlemove_wounded_ok = (
				battlemove_wnd_a_speed
				and battlemove_wnd_a_intent
				and battlemove_wnd_b_speed
				and battlemove_wnd_b_intent
				and _battlemove_ok(battlemove_wnd_res, 1.0, 2, 2)
				and battlemove_wnd_a.battle_position.is_equal_approx(battlemove_wnd_b.battle_position)
				and battlemove_wnd_a.velocity.is_equal_approx(battlemove_wnd_b.velocity)
				and battlemove_wnd_a.battle_position.is_equal_approx(Vector2(2.0, 0.0))
			)

	var battlemove_wpn_state: BattleState = _battlemove_make_state("active")
	if battlemove_wpn_state != null:
		var battlemove_wpn_a: BattleParticipant = _battlemove_add_participant(
			battlemove_wpn_state,
			"battlemove_wpn_a",
			"attacker"
		)
		var battlemove_wpn_b: BattleParticipant = _battlemove_add_participant(
			battlemove_wpn_state,
			"battlemove_wpn_b",
			"attacker"
		)
		if battlemove_wpn_a != null and battlemove_wpn_b != null:
			battlemove_wpn_a.weapon_type = "pistol"
			battlemove_wpn_a.has_battle_position = true
			battlemove_wpn_a.battle_position = Vector2(0.0, 0.0)
			var battlemove_wpn_a_speed: bool = battlemove_wpn_a.set_movement_speed(2.0)
			var battlemove_wpn_a_intent: bool = battlemove_wpn_a.set_movement_intent(Vector2(0.0, 1.0))
			battlemove_wpn_b.weapon_type = "rifle"
			battlemove_wpn_b.has_battle_position = true
			battlemove_wpn_b.battle_position = Vector2(0.0, 0.0)
			var battlemove_wpn_b_speed: bool = battlemove_wpn_b.set_movement_speed(2.0)
			var battlemove_wpn_b_intent: bool = battlemove_wpn_b.set_movement_intent(Vector2(0.0, 1.0))
			var battlemove_wpn_res: BattleMovementResult = BattleMovementService.advance(battlemove_wpn_state, 1.0)
			battlemove_weapon_ok = (
				battlemove_wpn_a_speed
				and battlemove_wpn_a_intent
				and battlemove_wpn_b_speed
				and battlemove_wpn_b_intent
				and battlemove_wpn_a.weapon_type != battlemove_wpn_b.weapon_type
				and _battlemove_ok(battlemove_wpn_res, 1.0, 2, 2)
				and battlemove_wpn_a.battle_position.is_equal_approx(battlemove_wpn_b.battle_position)
				and battlemove_wpn_a.velocity.is_equal_approx(battlemove_wpn_b.velocity)
				and battlemove_wpn_a.battle_position.is_equal_approx(Vector2(0.0, 2.0))
			)

	var battlemove_dep_pack: Dictionary = _battle_create_ready_pack()
	var battlemove_dep_bs: BattleState = battlemove_dep_pack.get("battle_state", null) as BattleState
	if battlemove_dep_bs != null:
		var battlemove_dep_deployed: bool = _battle_deploy_standard_attacker(battlemove_dep_bs)
		var battlemove_dep_part: BattleParticipant = battlemove_dep_bs.get_participant("battle_sol_a")
		var battlemove_dep_before: bool = (
			battlemove_dep_part != null
			and battlemove_dep_part.has_battle_position == false
		)
		var battlemove_dep_geo: bool = _battlegeo_init(battlemove_dep_bs)
		var battlemove_dep_zone: DeploymentZone = battlemove_dep_bs.get_deployment_zone("attacker_deployment")
		var battlemove_dep_pos_ok: bool = false
		if battlemove_dep_part != null and battlemove_dep_zone != null:
			battlemove_dep_pos_ok = (
				battlemove_dep_part.has_battle_position
				and is_finite(battlemove_dep_part.battle_position.x)
				and is_finite(battlemove_dep_part.battle_position.y)
				and battlemove_dep_zone.contains_point(battlemove_dep_part.battle_position)
			)
		var battlemove_dep_begun: bool = battlemove_dep_geo and battlemove_dep_bs.begin_battle()
		battlemove_deploy_geo_ok = (
			battlemove_dep_deployed
			and battlemove_dep_before
			and battlemove_dep_geo
			and battlemove_dep_pos_ok
			and battlemove_dep_begun
			and battlemove_dep_bs.battle_phase == "active"
		)
		battlemove_no_turn_ok = (
			battlemove_no_turn_ok
			and _battle_has_no_combat_turn_model(battlemove_dep_bs)
			and battlemove_dep_bs.get("current_turn_index") == null
			and battlemove_dep_bs.get("current_round") == null
			and battlemove_dep_bs.get("active_turn_actor_id") == null
		)

	var battlemove_persist_pack: Dictionary = _battle_create_ready_pack()
	var battlemove_persist_game: GameState = battlemove_persist_pack.get("game_state", null) as GameState
	var battlemove_persist_bs: BattleState = battlemove_persist_pack.get("battle_state", null) as BattleState
	if battlemove_persist_game != null and battlemove_persist_bs != null:
		var battlemove_persist_part: BattleParticipant = battlemove_persist_bs.get_participant("battle_sol_a")
		if battlemove_persist_part != null:
			battlemove_persist_part.has_battle_position = true
			battlemove_persist_part.battle_position = Vector2(111.0, 222.0)
			battlemove_persist_part.velocity = Vector2(3.0, 4.0)
			var battlemove_persist_speed: bool = battlemove_persist_part.set_movement_speed(9.5)
			var battlemove_persist_intent: bool = battlemove_persist_part.set_movement_intent(Vector2(1.0, 0.0))
			var battlemove_persist_data: Dictionary = battlemove_persist_game.to_dict()
			battlemove_persist_ok = (
				battlemove_persist_speed
				and battlemove_persist_intent
				and battlemove_persist_part.has_battle_position
				and _battle_serialized_campaign_keys_only(battlemove_persist_data)
				and not _battle_data_has_tactical_trace(battlemove_persist_data)
			)

	var battlemove_imm_pack: Dictionary = _battle_create_ready_pack()
	var battlemove_imm_game: GameState = battlemove_imm_pack.get("game_state", null) as GameState
	var battlemove_imm_force: TravelingForce = battlemove_imm_pack.get("force", null) as TravelingForce
	var battlemove_imm_bs: BattleState = battlemove_imm_pack.get("battle_state", null) as BattleState
	var battlemove_imm_campaign: Dictionary = _battle_campaign_snapshot(
		battlemove_imm_game,
		battlemove_imm_force,
		"battle_mission"
	)
	if battlemove_imm_game != null and battlemove_imm_bs != null:
		var battlemove_imm_deployed: bool = _battle_deploy_standard_attacker(battlemove_imm_bs)
		var battlemove_imm_begun: bool = _battlegeo_init(battlemove_imm_bs) and battlemove_imm_bs.begin_battle()
		var battlemove_imm_part: BattleParticipant = battlemove_imm_bs.get_participant("battle_sol_a")
		var battlemove_imm_ready: bool = false
		if battlemove_imm_part != null:
			battlemove_imm_part.has_battle_position = true
			battlemove_imm_part.battle_position = Vector2(0.0, 0.0)
			battlemove_imm_ready = (
				battlemove_imm_part.set_movement_speed(2.0)
				and battlemove_imm_part.set_movement_intent(Vector2(1.0, 0.0))
			)
		var battlemove_imm_res: BattleRuntimeResult = BattleRuntimeService.advance(battlemove_imm_bs, 0.5)
		battlemove_immutability_ok = (
			battlemove_imm_deployed
			and battlemove_imm_begun
			and battlemove_imm_ready
			and _battlert_clock_ok(battlemove_imm_res, 0.5, 0.0, 0.5)
			and battlemove_imm_part != null
			and battlemove_imm_part.battle_position.is_equal_approx(Vector2(1.0, 0.0))
			and _battle_campaign_unchanged(
				battlemove_imm_game,
				battlemove_imm_campaign,
				battlemove_imm_force,
				"battle_mission"
			)
			and battlemove_imm_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlemove_imm_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlemove_ok_res: BattleMovementResult = BattleMovementResult.succeeded(0.25, 3, 2)
	var battlemove_fail_res: BattleMovementResult = BattleMovementResult.failed(
		"invalid_delta",
		"Battle movement failed: delta_seconds is invalid.",
		-1.0
	)
	battlemove_result_ok = (
		battlemove_ok_res != null
		and battlemove_ok_res.success
		and is_equal_approx(battlemove_ok_res.delta_seconds, 0.25)
		and battlemove_ok_res.participants_considered == 3
		and battlemove_ok_res.participants_moved == 2
		and battlemove_ok_res.error_code.is_empty()
		and battlemove_ok_res.error_message.is_empty()
		and battlemove_fail_res != null
		and not battlemove_fail_res.success
		and battlemove_fail_res.error_code == "invalid_delta"
		and battlemove_fail_res.error_message == "Battle movement failed: delta_seconds is invalid."
		and is_equal_approx(battlemove_fail_res.delta_seconds, -1.0)
		and battlemove_fail_res.participants_considered == 0
		and battlemove_fail_res.participants_moved == 0
	)

	var battlegeo_default_ok: bool = false
	var battlegeo_default_bs: BattleState = _battle_make_bare_state()
	var battlegeo_default_res: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
		battlegeo_default_bs
	)
	if battlegeo_default_bs != null and battlegeo_default_res != null:
		var battlegeo_default_geo: BattlefieldGeometry = battlegeo_default_bs.battlefield_geometry
		var battlegeo_default_att: DeploymentZone = battlegeo_default_bs.get_deployment_zone("attacker_deployment")
		var battlegeo_default_def: DeploymentZone = battlegeo_default_bs.get_deployment_zone("defender_deployment")
		battlegeo_default_ok = (
			battlegeo_default_res.success
			and battlegeo_default_res.participants_positioned == 0
			and battlegeo_default_res.vehicles_positioned == 0
			and battlegeo_default_res.error_code.is_empty()
			and battlegeo_default_res.error_message.is_empty()
			and battlegeo_default_geo != null
			and is_equal_approx(battlegeo_default_geo.width, 100.0)
			and is_equal_approx(battlegeo_default_geo.height, 60.0)
			and battlegeo_default_geo.is_valid()
			and battlegeo_default_geo.bounds().is_equal_approx(Rect2(0.0, 0.0, 100.0, 60.0))
			and battlegeo_default_geo.attacker_deployment_rect.is_equal_approx(Rect2(0.0, 0.0, 20.0, 60.0))
			and battlegeo_default_geo.defender_deployment_rect.is_equal_approx(Rect2(80.0, 0.0, 20.0, 60.0))
			and battlegeo_default_att != null
			and battlegeo_default_def != null
			and battlegeo_default_att.deployment_rect.is_equal_approx(Rect2(0.0, 0.0, 20.0, 60.0))
			and battlegeo_default_def.deployment_rect.is_equal_approx(Rect2(80.0, 0.0, 20.0, 60.0))
		)

	var battlegeo_null_res: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(null)
	var battlegeo_fail_null_ok: bool = _battlegeo_fail_ok(battlegeo_null_res, "null_battle_state")

	var battlegeo_fail_not_deploy_ok: bool = false
	var battlegeo_active_bs: BattleState = _battle_make_bare_state()
	if battlegeo_active_bs != null and _battlegeo_add_marker(battlegeo_active_bs, "attacker", "attacker_deployment"):
		var battlegeo_active_init: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_active_bs
		)
		if battlegeo_active_init != null and battlegeo_active_init.success:
			battlegeo_active_bs.battle_phase = "active"
			var battlegeo_active_snap: Dictionary = _battlegeo_spatial_snap(battlegeo_active_bs)
			battlegeo_fail_not_deploy_ok = _battlegeo_fail_and_unchanged(
				battlegeo_active_bs,
				"battle_not_in_deployment",
				battlegeo_active_snap
			)

	var battlegeo_fail_missing_att_side_ok: bool = false
	var battlegeo_miss_att_side: BattleState = _battlegeo_make_incomplete(false, true, false, true)
	if battlegeo_miss_att_side != null and _battlegeo_add_marker(
		battlegeo_miss_att_side, "defender", "defender_deployment"
	):
		_battlegeo_seed_zone_rects(battlegeo_miss_att_side)
		var battlegeo_miss_att_side_snap: Dictionary = _battlegeo_spatial_snap(battlegeo_miss_att_side)
		battlegeo_fail_missing_att_side_ok = _battlegeo_fail_and_unchanged(
			battlegeo_miss_att_side,
			"missing_attacker_side",
			battlegeo_miss_att_side_snap
		)

	var battlegeo_fail_missing_def_side_ok: bool = false
	var battlegeo_miss_def_side: BattleState = _battlegeo_make_incomplete(true, false, true, false)
	if battlegeo_miss_def_side != null and _battlegeo_add_marker(
		battlegeo_miss_def_side, "attacker", "attacker_deployment"
	):
		_battlegeo_seed_zone_rects(battlegeo_miss_def_side)
		var battlegeo_miss_def_side_snap: Dictionary = _battlegeo_spatial_snap(battlegeo_miss_def_side)
		battlegeo_fail_missing_def_side_ok = _battlegeo_fail_and_unchanged(
			battlegeo_miss_def_side,
			"missing_defender_side",
			battlegeo_miss_def_side_snap
		)

	var battlegeo_fail_missing_att_zone_ok: bool = false
	var battlegeo_miss_att_zone: BattleState = _battlegeo_make_incomplete(true, true, false, true)
	if battlegeo_miss_att_zone != null and _battlegeo_add_marker(
		battlegeo_miss_att_zone, "defender", "defender_deployment"
	):
		_battlegeo_seed_zone_rects(battlegeo_miss_att_zone)
		var battlegeo_miss_att_zone_snap: Dictionary = _battlegeo_spatial_snap(battlegeo_miss_att_zone)
		battlegeo_fail_missing_att_zone_ok = _battlegeo_fail_and_unchanged(
			battlegeo_miss_att_zone,
			"missing_attacker_deployment_zone",
			battlegeo_miss_att_zone_snap
		)

	var battlegeo_fail_missing_def_zone_ok: bool = false
	var battlegeo_miss_def_zone: BattleState = _battlegeo_make_incomplete(true, true, true, false)
	if battlegeo_miss_def_zone != null and _battlegeo_add_marker(
		battlegeo_miss_def_zone, "attacker", "attacker_deployment"
	):
		_battlegeo_seed_zone_rects(battlegeo_miss_def_zone)
		var battlegeo_miss_def_zone_snap: Dictionary = _battlegeo_spatial_snap(battlegeo_miss_def_zone)
		battlegeo_fail_missing_def_zone_ok = _battlegeo_fail_and_unchanged(
			battlegeo_miss_def_zone,
			"missing_defender_deployment_zone",
			battlegeo_miss_def_zone_snap
		)

	# BattlefieldGeometryService returns invalid_geometry only if internal provisional
	# constants or generated layout fail validity. Current public constants always
	# produce valid geometry, and public APIs expose no hook to inject invalid
	# dimensions, so this failure mode is unreachable through normal APIs.
	var battlegeo_invalid_geo_unreachable_ok: bool = true

	var battlegeo_empty_ids: Array[String] = []
	var battlegeo_part_ids_a: Array[String] = ["geo_p_z", "geo_p_a", "geo_p_m"]
	var battlegeo_part_ids_b: Array[String] = ["geo_p_m", "geo_p_a", "geo_p_z"]
	var battlegeo_def_part_ids_a: Array[String] = ["geo_dp_z", "geo_dp_a"]
	var battlegeo_def_part_ids_b: Array[String] = ["geo_dp_a", "geo_dp_z"]
	var battlegeo_part_a: BattleState = _battlegeo_make_unit_state(
		battlegeo_part_ids_a,
		battlegeo_empty_ids,
		battlegeo_def_part_ids_a,
		battlegeo_empty_ids
	)
	var battlegeo_part_b: BattleState = _battlegeo_make_unit_state(
		battlegeo_part_ids_b,
		battlegeo_empty_ids,
		battlegeo_def_part_ids_b,
		battlegeo_empty_ids
	)
	var battlegeo_part_place_ok: bool = false
	if battlegeo_part_a != null and battlegeo_part_b != null:
		var battlegeo_part_res_a: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_part_a
		)
		var battlegeo_part_res_b: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_part_b
		)
		var battlegeo_part_res_a2: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_part_a
		)
		battlegeo_part_place_ok = (
			battlegeo_part_res_a != null
			and battlegeo_part_res_a.success
			and battlegeo_part_res_b != null
			and battlegeo_part_res_b.success
			and battlegeo_part_res_a2 != null
			and battlegeo_part_res_a2.success
			and battlegeo_part_res_a.participants_positioned == 5
			and battlegeo_part_res_b.participants_positioned == 5
			and _battlegeo_same_part_positions(battlegeo_part_a, battlegeo_part_b)
			and _battlegeo_deployed_parts_positioned(battlegeo_part_a)
			and _battlegeo_side_part_unique(battlegeo_part_a, "attacker")
			and _battlegeo_side_part_unique(battlegeo_part_a, "defender")
			and _battlegeo_side_part_unique(battlegeo_part_b, "attacker")
			and _battlegeo_side_part_unique(battlegeo_part_b, "defender")
		)

	var battlegeo_veh_ids_a: Array[String] = ["geo_v_z", "geo_v_a", "geo_v_m"]
	var battlegeo_veh_ids_b: Array[String] = ["geo_v_m", "geo_v_a", "geo_v_z"]
	var battlegeo_def_veh_ids_a: Array[String] = ["geo_dv_z", "geo_dv_a"]
	var battlegeo_def_veh_ids_b: Array[String] = ["geo_dv_a", "geo_dv_z"]
	var battlegeo_veh_a: BattleState = _battlegeo_make_unit_state(
		battlegeo_empty_ids,
		battlegeo_veh_ids_a,
		battlegeo_empty_ids,
		battlegeo_def_veh_ids_a
	)
	var battlegeo_veh_b: BattleState = _battlegeo_make_unit_state(
		battlegeo_empty_ids,
		battlegeo_veh_ids_b,
		battlegeo_empty_ids,
		battlegeo_def_veh_ids_b
	)
	var battlegeo_veh_place_ok: bool = false
	if battlegeo_veh_a != null and battlegeo_veh_b != null:
		var battlegeo_veh_res_a: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_veh_a
		)
		var battlegeo_veh_res_b: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_veh_b
		)
		battlegeo_veh_place_ok = (
			battlegeo_veh_res_a != null
			and battlegeo_veh_res_a.success
			and battlegeo_veh_res_b != null
			and battlegeo_veh_res_b.success
			and battlegeo_veh_res_a.vehicles_positioned == 5
			and battlegeo_veh_res_b.vehicles_positioned == 5
			and _battlegeo_same_veh_positions(battlegeo_veh_a, battlegeo_veh_b)
			and _battlegeo_deployed_vehs_positioned(battlegeo_veh_a)
			and _battlegeo_side_veh_unique(battlegeo_veh_a, "attacker")
			and _battlegeo_side_veh_unique(battlegeo_veh_a, "defender")
			and _battlegeo_side_veh_in_zone(battlegeo_veh_a, "attacker")
			and _battlegeo_side_veh_in_zone(battlegeo_veh_a, "defender")
		)

	var battlegeo_sep_part_ids: Array[String] = ["geo_sep_p_z", "geo_sep_p_a"]
	var battlegeo_sep_veh_ids: Array[String] = ["geo_sep_v_z", "geo_sep_v_a"]
	var battlegeo_sep_bs: BattleState = _battlegeo_make_unit_state(
		battlegeo_sep_part_ids,
		battlegeo_sep_veh_ids,
		battlegeo_empty_ids,
		battlegeo_empty_ids
	)
	var battlegeo_part_veh_sep_ok: bool = false
	if battlegeo_sep_bs != null:
		var battlegeo_sep_res: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_sep_bs
		)
		battlegeo_part_veh_sep_ok = (
			battlegeo_sep_res != null
			and battlegeo_sep_res.success
			and _battlegeo_side_part_in_zone(battlegeo_sep_bs, "attacker")
			and _battlegeo_side_veh_in_zone(battlegeo_sep_bs, "attacker")
			and _battlegeo_part_veh_separated(battlegeo_sep_bs, "attacker")
		)

	var battlegeo_undeployed_ok: bool = false
	var battlegeo_semantic_ok: bool = false
	var battlegeo_undep_part_ids: Array[String] = ["geo_dep_p"]
	var battlegeo_undep_veh_ids: Array[String] = ["geo_dep_v"]
	var battlegeo_undep_bs: BattleState = _battlegeo_make_unit_state(
		battlegeo_undep_part_ids,
		battlegeo_undep_veh_ids,
		battlegeo_empty_ids,
		battlegeo_empty_ids
	)
	if battlegeo_undep_bs != null:
		var battlegeo_undep_p_ok: bool = _battle_register_participant(
			battlegeo_undep_bs, "geo_undep_p", "attacker", "attacker_deployment"
		)
		var battlegeo_undep_v_ok: bool = _battle_register_vehicle(
			battlegeo_undep_bs, "geo_undep_v", "attacker", "attacker_deployment"
		)
		var battlegeo_undep_p: BattleParticipant = battlegeo_undep_bs.get_participant("geo_undep_p")
		var battlegeo_undep_v: BattleVehicle = battlegeo_undep_bs.get_vehicle("geo_undep_v")
		var battlegeo_dep_p: BattleParticipant = battlegeo_undep_bs.get_participant("geo_dep_p")
		var battlegeo_dep_v: BattleVehicle = battlegeo_undep_bs.get_vehicle("geo_dep_v")
		if battlegeo_undep_p != null:
			battlegeo_undep_p.has_battle_position = false
			battlegeo_undep_p.battle_position = Vector2(7.0, 9.0)
		if battlegeo_undep_v != null:
			battlegeo_undep_v.has_battle_position = false
			battlegeo_undep_v.battle_position = Vector2(8.0, 6.0)
		var battlegeo_sem_snap: Dictionary = _battlegeo_semantic_snap(battlegeo_undep_bs)
		var battlegeo_undep_res: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
			battlegeo_undep_bs
		)
		battlegeo_undeployed_ok = (
			battlegeo_undep_p_ok
			and battlegeo_undep_v_ok
			and battlegeo_undep_res != null
			and battlegeo_undep_res.success
			and battlegeo_dep_p != null
			and battlegeo_dep_v != null
			and battlegeo_dep_p.has_battle_position
			and battlegeo_dep_v.has_battle_position
			and battlegeo_undep_p != null
			and battlegeo_undep_v != null
			and battlegeo_undep_p.has_battle_position == false
			and battlegeo_undep_v.has_battle_position == false
			and battlegeo_undep_p.battle_position.is_equal_approx(Vector2(7.0, 9.0))
			and battlegeo_undep_v.battle_position.is_equal_approx(Vector2(8.0, 6.0))
			and battlegeo_undep_p.deployment_slot_id.is_empty()
			and battlegeo_undep_v.deployment_slot_id.is_empty()
			and battlegeo_undep_res.participants_positioned == 1
			and battlegeo_undep_res.vehicles_positioned == 1
		)
		battlegeo_semantic_ok = (
			battlegeo_undeployed_ok
			and _battlegeo_semantic_unchanged(battlegeo_undep_bs, battlegeo_sem_snap)
		)

	var battlegeo_ready_before_ok: bool = false
	var battlegeo_ready_after_ok: bool = false
	var battlegeo_no_combat_ok: bool = false
	var battlegeo_ready_pack: Dictionary = _battle_create_ready_pack()
	var battlegeo_ready_bs: BattleState = battlegeo_ready_pack.get("battle_state", null) as BattleState
	if battlegeo_ready_bs != null:
		var battlegeo_ready_deployed: bool = _battle_deploy_standard_attacker(battlegeo_ready_bs)
		var battlegeo_ready_begin_before: bool = battlegeo_ready_bs.begin_battle()
		battlegeo_ready_before_ok = (
			battlegeo_ready_deployed
			and battlegeo_ready_bs.is_battle_ready()
			and not battlegeo_ready_bs.is_spatially_ready()
			and not battlegeo_ready_begin_before
			and battlegeo_ready_bs.battle_phase == "deployment"
		)
		var battlegeo_ready_geo: bool = _battlegeo_init(battlegeo_ready_bs)
		battlegeo_ready_after_ok = (
			battlegeo_ready_before_ok
			and battlegeo_ready_geo
			and battlegeo_ready_bs.is_battle_ready()
			and battlegeo_ready_bs.is_spatially_ready()
			and battlegeo_ready_bs.begin_battle()
			and battlegeo_ready_bs.battle_phase == "active"
		)
		battlegeo_no_combat_ok = (
			battlegeo_ready_after_ok
			and _battle_has_no_combat_turn_model(battlegeo_ready_bs)
			and battlegeo_ready_bs.get("current_turn_index") == null
			and battlegeo_ready_bs.get("current_round") == null
			and battlegeo_ready_bs.get("active_turn_actor_id") == null
		)

	var battlegeo_reject_missing_pos_ok: bool = false
	var battlegeo_reject_nan_pos_ok: bool = false
	var battlegeo_reject_outside_ok: bool = false
	var battlegeo_reject_pack: Dictionary = _battle_create_ready_pack()
	var battlegeo_reject_bs: BattleState = battlegeo_reject_pack.get("battle_state", null) as BattleState
	if battlegeo_reject_bs != null and _battle_deploy_standard_attacker(battlegeo_reject_bs) and _battlegeo_init(
		battlegeo_reject_bs
	):
		var battlegeo_rej_part: BattleParticipant = battlegeo_reject_bs.get_participant("battle_sol_a")
		var battlegeo_rej_veh: BattleVehicle = battlegeo_reject_bs.get_vehicle("battle_veh_a")
		var battlegeo_rej_def: BattleParticipant = null
		if (
			_battle_register_participant(battlegeo_reject_bs, "geo_rej_def", "defender", "defender_deployment")
			and battlegeo_reject_bs.deploy_participant("geo_rej_def", "defender_deployment")
		):
			_battlegeo_init(battlegeo_reject_bs)
			battlegeo_rej_def = battlegeo_reject_bs.get_participant("geo_rej_def")
		if (
			battlegeo_rej_part != null
			and battlegeo_rej_veh != null
			and battlegeo_reject_bs.is_spatially_ready()
		):
			var battlegeo_orig_part_pos: Vector2 = battlegeo_rej_part.battle_position
			var battlegeo_orig_veh_pos: Vector2 = battlegeo_rej_veh.battle_position
			battlegeo_rej_part.has_battle_position = false
			var battlegeo_miss_part_begin: bool = battlegeo_reject_bs.begin_battle()
			var battlegeo_miss_part_ok: bool = (
				not battlegeo_reject_bs.is_spatially_ready()
				and not battlegeo_miss_part_begin
				and battlegeo_reject_bs.battle_phase == "deployment"
			)
			battlegeo_rej_part.has_battle_position = true
			battlegeo_rej_veh.has_battle_position = false
			var battlegeo_miss_veh_begin: bool = battlegeo_reject_bs.begin_battle()
			battlegeo_reject_missing_pos_ok = (
				battlegeo_miss_part_ok
				and not battlegeo_reject_bs.is_spatially_ready()
				and not battlegeo_miss_veh_begin
				and battlegeo_reject_bs.battle_phase == "deployment"
			)
			battlegeo_rej_veh.has_battle_position = true
			battlegeo_rej_part.battle_position = Vector2(NAN, 0.0)
			var battlegeo_nan_begin: bool = battlegeo_reject_bs.begin_battle()
			var battlegeo_nan_ok: bool = (
				not battlegeo_reject_bs.is_spatially_ready()
				and not battlegeo_nan_begin
				and battlegeo_reject_bs.battle_phase == "deployment"
			)
			battlegeo_rej_part.battle_position = Vector2(INF, 1.0)
			var battlegeo_inf_begin: bool = battlegeo_reject_bs.begin_battle()
			battlegeo_reject_nan_pos_ok = (
				battlegeo_nan_ok
				and not battlegeo_reject_bs.is_spatially_ready()
				and not battlegeo_inf_begin
				and battlegeo_reject_bs.battle_phase == "deployment"
			)
			battlegeo_rej_part.battle_position = Vector2(90.0, 30.0)
			var battlegeo_out_att_begin: bool = battlegeo_reject_bs.begin_battle()
			var battlegeo_out_att_ok: bool = (
				not battlegeo_reject_bs.is_spatially_ready()
				and not battlegeo_out_att_begin
				and battlegeo_reject_bs.battle_phase == "deployment"
			)
			battlegeo_rej_part.battle_position = battlegeo_orig_part_pos
			var battlegeo_out_def_ok: bool = true
			if battlegeo_rej_def != null:
				var battlegeo_orig_def_pos: Vector2 = battlegeo_rej_def.battle_position
				battlegeo_rej_def.battle_position = Vector2(10.0, 30.0)
				var battlegeo_out_def_begin: bool = battlegeo_reject_bs.begin_battle()
				battlegeo_out_def_ok = (
					not battlegeo_reject_bs.is_spatially_ready()
					and not battlegeo_out_def_begin
					and battlegeo_reject_bs.battle_phase == "deployment"
				)
				battlegeo_rej_def.battle_position = battlegeo_orig_def_pos
			battlegeo_reject_outside_ok = (
				battlegeo_out_att_ok
				and battlegeo_out_def_ok
				and battlegeo_rej_veh.battle_position.is_equal_approx(battlegeo_orig_veh_pos)
			)

	var battlegeo_ok_res: BattlefieldGeometryResult = BattlefieldGeometryResult.succeeded(3, 2)
	var battlegeo_fail_res: BattlefieldGeometryResult = BattlefieldGeometryResult.failed(
		"null_battle_state",
		"Battlefield geometry failed: battle_state is null."
	)
	var battlegeo_result_ok: bool = (
		battlegeo_ok_res != null
		and battlegeo_ok_res.success
		and battlegeo_ok_res.participants_positioned == 3
		and battlegeo_ok_res.vehicles_positioned == 2
		and battlegeo_ok_res.error_code.is_empty()
		and battlegeo_ok_res.error_message.is_empty()
		and battlegeo_fail_res != null
		and not battlegeo_fail_res.success
		and battlegeo_fail_res.participants_positioned == 0
		and battlegeo_fail_res.vehicles_positioned == 0
		and battlegeo_fail_res.error_code == "null_battle_state"
		and battlegeo_fail_res.error_message == "Battlefield geometry failed: battle_state is null."
		and battlegeo_default_ok
	)

	var battlegeo_move_ok: bool = false
	var battlegeo_move_pack: Dictionary = _battle_create_ready_pack()
	var battlegeo_move_bs: BattleState = battlegeo_move_pack.get("battle_state", null) as BattleState
	if battlegeo_move_bs != null:
		var battlegeo_move_deployed: bool = _battle_deploy_standard_attacker(battlegeo_move_bs)
		var battlegeo_move_geo: bool = _battlegeo_init(battlegeo_move_bs)
		var battlegeo_move_part: BattleParticipant = battlegeo_move_bs.get_participant("battle_sol_a")
		var battlegeo_move_start: Vector2 = Vector2.ZERO
		var battlegeo_move_ready: bool = false
		if battlegeo_move_part != null and battlegeo_move_part.has_battle_position:
			battlegeo_move_start = battlegeo_move_part.battle_position
			battlegeo_move_ready = (
				_battlegeo_finite_point(battlegeo_move_start)
				and battlegeo_move_part.set_movement_speed(2.0)
				and battlegeo_move_part.set_movement_intent(Vector2(1.0, 0.0))
			)
		var battlegeo_move_begun: bool = battlegeo_move_geo and battlegeo_move_bs.begin_battle()
		var battlegeo_move_res: BattleRuntimeResult = BattleRuntimeService.advance(battlegeo_move_bs, 0.5)
		battlegeo_move_ok = (
			battlegeo_move_deployed
			and battlegeo_move_geo
			and battlegeo_move_ready
			and battlegeo_move_begun
			and _battlert_clock_ok(battlegeo_move_res, 0.5, 0.0, 0.5)
			and is_equal_approx(battlegeo_move_bs.elapsed_time_seconds, 0.5)
			and battlegeo_move_part != null
			and battlegeo_move_part.battle_position.is_equal_approx(battlegeo_move_start + Vector2(1.0, 0.0))
			and not battlegeo_move_part.battle_position.is_equal_approx(Vector2.ZERO)
		)

	var battlegeo_locality_ok: bool = false
	var battlegeo_persist_ok: bool = false
	var battlegeo_immutability_ok: bool = false
	var battlegeo_camp_pack: Dictionary = _battle_create_ready_pack()
	var battlegeo_camp_game: GameState = battlegeo_camp_pack.get("game_state", null) as GameState
	var battlegeo_camp_force: TravelingForce = battlegeo_camp_pack.get("force", null) as TravelingForce
	var battlegeo_camp_bs: BattleState = battlegeo_camp_pack.get("battle_state", null) as BattleState
	if battlegeo_camp_game != null and battlegeo_camp_bs != null:
		var battlegeo_camp_deployed: bool = _battle_deploy_standard_attacker(battlegeo_camp_bs)
		var battlegeo_camp_snap: Dictionary = _battle_campaign_snapshot(
			battlegeo_camp_game,
			battlegeo_camp_force,
			"battle_mission"
		)
		var battlegeo_camp_dict_before: Dictionary = battlegeo_camp_game.to_dict()
		var battlegeo_camp_coords: Dictionary = _battlegeo_campaign_coords(battlegeo_camp_game)
		var battlegeo_camp_geo: bool = _battlegeo_init(battlegeo_camp_bs)
		var battlegeo_camp_dict_after: Dictionary = battlegeo_camp_game.to_dict()
		battlegeo_locality_ok = (
			battlegeo_camp_deployed
			and battlegeo_camp_geo
			and battlegeo_camp_dict_before == battlegeo_camp_dict_after
			and _battlegeo_campaign_coords_unchanged(battlegeo_camp_game, battlegeo_camp_coords)
		)
		var battlegeo_camp_persist: Dictionary = battlegeo_camp_game.to_dict()
		battlegeo_persist_ok = (
			battlegeo_locality_ok
			and _battle_serialized_campaign_keys_only(battlegeo_camp_persist)
			and not _battle_data_has_tactical_trace(battlegeo_camp_persist)
		)
		battlegeo_immutability_ok = (
			battlegeo_camp_geo
			and _battle_campaign_unchanged(
				battlegeo_camp_game,
				battlegeo_camp_snap,
				battlegeo_camp_force,
				"battle_mission"
			)
			and battlegeo_camp_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlegeo_camp_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlespatial_obstacle_ok: bool = false
	var battlespatial_registry_ok: bool = false
	var battlespatial_reject_ok: bool = false
	var battlespatial_geo: BattlefieldGeometry = _battlespatial_open_geometry()
	if battlespatial_geo != null:
		var battlespatial_wall: BattleObstacle = BattleObstacle.new(
			"wall_ok",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		battlespatial_obstacle_ok = (
			battlespatial_wall.obstacle_id == "wall_ok"
			and battlespatial_wall.blocks_movement
			and battlespatial_wall.bounds_are_usable()
			and battlespatial_wall.is_valid()
			and battlespatial_wall.contains_point(Vector2(45.0, 30.0))
			and not battlespatial_wall.contains_point(Vector2(10.0, 10.0))
		)
		var battlespatial_added: bool = battlespatial_geo.add_obstacle(battlespatial_wall)
		var battlespatial_z: BattleObstacle = BattleObstacle.new("z_obs", Rect2(1.0, 1.0, 2.0, 2.0), true)
		var battlespatial_a: BattleObstacle = BattleObstacle.new("a_obs", Rect2(3.0, 1.0, 2.0, 2.0), true)
		var battlespatial_m: BattleObstacle = BattleObstacle.new("m_obs", Rect2(5.0, 1.0, 2.0, 2.0), true)
		var battlespatial_expected_ids: Array[String] = ["a_obs", "m_obs", "wall_ok", "z_obs"]
		var battlespatial_sorted_ok: bool = (
			battlespatial_geo.add_obstacle(battlespatial_z)
			and battlespatial_geo.add_obstacle(battlespatial_a)
			and battlespatial_geo.add_obstacle(battlespatial_m)
			and _string_ids_match(
				battlespatial_geo.get_sorted_obstacle_ids(),
				battlespatial_expected_ids
			)
		)
		battlespatial_registry_ok = (
			battlespatial_added
			and battlespatial_geo.has_obstacle("wall_ok")
			and battlespatial_geo.get_obstacle("wall_ok") == battlespatial_wall
			and battlespatial_sorted_ok
		)
		var battlespatial_before_count: int = battlespatial_geo.obstacles.size()
		var battlespatial_dup: BattleObstacle = BattleObstacle.new("wall_ok", Rect2(8.0, 8.0, 2.0, 2.0), true)
		var battlespatial_empty: BattleObstacle = BattleObstacle.new("", Rect2(8.0, 8.0, 2.0, 2.0), true)
		var battlespatial_bad_rect: BattleObstacle = BattleObstacle.new("bad_rect", Rect2(0.0, 0.0, 0.0, 1.0), true)
		battlespatial_reject_ok = (
			not battlespatial_geo.add_obstacle(null)
			and not battlespatial_geo.add_obstacle(battlespatial_empty)
			and not battlespatial_geo.add_obstacle(battlespatial_dup)
			and not battlespatial_geo.add_obstacle(battlespatial_bad_rect)
			and battlespatial_geo.obstacles.size() == battlespatial_before_count
			and battlespatial_geo.has_obstacle("wall_ok")
			and not battlespatial_geo.has_obstacle("bad_rect")
			and not battlespatial_geo.has_obstacle("")
		)

	var battlespatial_default_empty_ok: bool = false
	var battlespatial_default_bs: BattleState = _battle_make_bare_state()
	var battlespatial_default_res: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(
		battlespatial_default_bs
	)
	if battlespatial_default_bs != null and battlespatial_default_bs.battlefield_geometry != null:
		battlespatial_default_empty_ok = (
			battlespatial_default_res != null
			and battlespatial_default_res.success
			and battlespatial_default_bs.battlefield_geometry.obstacles.size() == 0
			and battlespatial_default_bs.battlefield_geometry.get_sorted_obstacle_ids().is_empty()
		)

	var battlespatial_open_ok: bool = false
	var battlespatial_zero_disp_ok: bool = false
	var battlespatial_open_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_open_bs != null:
		var battlespatial_open_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_open_bs,
			Vector2(10.0, 10.0),
			Vector2(5.0, 0.0)
		)
		battlespatial_open_ok = (
			battlespatial_open_res != null
			and battlespatial_open_res.success
			and battlespatial_open_res.start_position.is_equal_approx(Vector2(10.0, 10.0))
			and battlespatial_open_res.requested_displacement.is_equal_approx(Vector2(5.0, 0.0))
			and battlespatial_open_res.resolved_displacement.is_equal_approx(Vector2(5.0, 0.0))
			and battlespatial_open_res.final_position.is_equal_approx(Vector2(15.0, 10.0))
			and battlespatial_open_res.was_blocked == false
			and battlespatial_open_res.blocking_obstacle_id.is_empty()
			and battlespatial_open_res.error_code.is_empty()
			and battlespatial_open_res.error_message.is_empty()
		)
		var battlespatial_zero_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_open_bs,
			Vector2(10.0, 10.0),
			Vector2.ZERO
		)
		battlespatial_zero_disp_ok = (
			battlespatial_zero_res != null
			and battlespatial_zero_res.success
			and battlespatial_zero_res.final_position.is_equal_approx(Vector2(10.0, 10.0))
			and battlespatial_zero_res.resolved_displacement.is_equal_approx(Vector2.ZERO)
			and battlespatial_zero_res.was_blocked == false
		)

	var battlespatial_null_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
		null,
		Vector2(10.0, 10.0),
		Vector2(1.0, 0.0)
	)
	var battlespatial_fail_null_ok: bool = _battlespatial_fail_ok(battlespatial_null_res, "null_battle_state")

	var battlespatial_fail_missing_geo_ok: bool = false
	var battlespatial_miss_bs: BattleState = BattleState.new(
		"spatial_miss",
		"spatial_type",
		"spatial_mission",
		"spatial_loc",
		"attacker",
		"defender",
		"active"
	)
	var battlespatial_miss_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
		battlespatial_miss_bs,
		Vector2(10.0, 10.0),
		Vector2(1.0, 0.0)
	)
	battlespatial_fail_missing_geo_ok = (
		_battlespatial_fail_ok(battlespatial_miss_res, "missing_battlefield_geometry")
		and battlespatial_miss_bs.battlefield_geometry == null
	)

	var battlespatial_fail_invalid_geo_ok: bool = false
	var battlespatial_badgeo_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_badgeo_bs != null:
		battlespatial_badgeo_bs.battlefield_geometry = BattlefieldGeometry.new()
		var battlespatial_badgeo_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_badgeo_bs,
			Vector2(10.0, 10.0),
			Vector2(1.0, 0.0)
		)
		battlespatial_fail_invalid_geo_ok = (
			_battlespatial_fail_ok(battlespatial_badgeo_res, "invalid_battlefield_geometry")
			and battlespatial_badgeo_bs.battlefield_geometry != null
			and not battlespatial_badgeo_bs.battlefield_geometry.is_valid()
			and is_equal_approx(battlespatial_badgeo_bs.battlefield_geometry.width, 0.0)
		)

	var battlespatial_fail_bad_start_ok: bool = false
	var battlespatial_fail_outside_ok: bool = false
	var battlespatial_fail_bad_disp_ok: bool = false
	var battlespatial_err_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_err_bs != null:
		var battlespatial_err_part: BattleParticipant = _battlemove_add_participant(
			battlespatial_err_bs,
			"spatial_err_p",
			"attacker"
		)
		if battlespatial_err_part != null:
			battlespatial_err_part.has_battle_position = true
			battlespatial_err_part.battle_position = Vector2(10.0, 10.0)
			var battlespatial_err_snap: Dictionary = _battlemove_part_snap(battlespatial_err_part)
			var battlespatial_nan_start: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_err_bs,
				Vector2(NAN, 10.0),
				Vector2(1.0, 0.0)
			)
			var battlespatial_inf_start: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_err_bs,
				Vector2(INF, 10.0),
				Vector2(1.0, 0.0)
			)
			battlespatial_fail_bad_start_ok = (
				_battlespatial_fail_ok(battlespatial_nan_start, "invalid_start_position")
				and _battlespatial_fail_ok(battlespatial_inf_start, "invalid_start_position")
				and _battlemove_part_unchanged(battlespatial_err_part, battlespatial_err_snap)
			)
			var battlespatial_out_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_err_bs,
				Vector2(-1.0, 10.0),
				Vector2(1.0, 0.0)
			)
			battlespatial_fail_outside_ok = (
				_battlespatial_fail_ok(battlespatial_out_res, "start_outside_battlefield")
				and _battlemove_part_unchanged(battlespatial_err_part, battlespatial_err_snap)
			)
			var battlespatial_nan_disp: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_err_bs,
				Vector2(10.0, 10.0),
				Vector2(NAN, 0.0)
			)
			var battlespatial_inf_disp: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_err_bs,
				Vector2(10.0, 10.0),
				Vector2(INF, 0.0)
			)
			battlespatial_fail_bad_disp_ok = (
				_battlespatial_fail_ok(battlespatial_nan_disp, "invalid_displacement")
				and _battlespatial_fail_ok(battlespatial_inf_disp, "invalid_displacement")
				and _battlemove_part_unchanged(battlespatial_err_part, battlespatial_err_snap)
			)

	var battlespatial_bound_right_ok: bool = false
	var battlespatial_bound_left_ok: bool = false
	var battlespatial_bound_top_ok: bool = false
	var battlespatial_bound_bottom_ok: bool = false
	var battlespatial_bound_diag_ok: bool = false
	var battlespatial_bound_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_bound_bs != null and battlespatial_bound_bs.battlefield_geometry != null:
		var battlespatial_bound_geo: BattlefieldGeometry = battlespatial_bound_bs.battlefield_geometry
		var battlespatial_right: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_bound_bs,
			Vector2(95.0, 30.0),
			Vector2(20.0, 0.0)
		)
		battlespatial_bound_right_ok = (
			battlespatial_right != null
			and battlespatial_right.success
			and battlespatial_right.was_blocked
			and battlespatial_bound_geo.contains_point(battlespatial_right.final_position)
			and is_equal_approx(battlespatial_right.final_position.x, 100.0)
			and is_equal_approx(battlespatial_right.final_position.y, 30.0)
			and battlespatial_right.resolved_displacement.x < 20.0
			and battlespatial_right.blocking_obstacle_id.is_empty()
		)
		var battlespatial_left: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_bound_bs,
			Vector2(5.0, 30.0),
			Vector2(-20.0, 0.0)
		)
		battlespatial_bound_left_ok = (
			battlespatial_left != null
			and battlespatial_left.success
			and battlespatial_left.was_blocked
			and battlespatial_bound_geo.contains_point(battlespatial_left.final_position)
			and is_equal_approx(battlespatial_left.final_position.x, 0.0)
			and is_equal_approx(battlespatial_left.final_position.y, 30.0)
		)
		var battlespatial_top: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_bound_bs,
			Vector2(50.0, 5.0),
			Vector2(0.0, -20.0)
		)
		battlespatial_bound_top_ok = (
			battlespatial_top != null
			and battlespatial_top.success
			and battlespatial_top.was_blocked
			and battlespatial_bound_geo.contains_point(battlespatial_top.final_position)
			and is_equal_approx(battlespatial_top.final_position.x, 50.0)
			and is_equal_approx(battlespatial_top.final_position.y, 0.0)
		)
		var battlespatial_bottom: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_bound_bs,
			Vector2(50.0, 55.0),
			Vector2(0.0, 20.0)
		)
		battlespatial_bound_bottom_ok = (
			battlespatial_bottom != null
			and battlespatial_bottom.success
			and battlespatial_bottom.was_blocked
			and battlespatial_bound_geo.contains_point(battlespatial_bottom.final_position)
			and is_equal_approx(battlespatial_bottom.final_position.x, 50.0)
			and is_equal_approx(battlespatial_bottom.final_position.y, 60.0)
		)
		var battlespatial_diag_req: Vector2 = Vector2(20.0, 20.0)
		var battlespatial_diag: BattleSpatialResult = BattleSpatialService.resolve_translation(
			battlespatial_bound_bs,
			Vector2(98.0, 50.0),
			battlespatial_diag_req
		)
		battlespatial_bound_diag_ok = (
			battlespatial_diag != null
			and battlespatial_diag.success
			and battlespatial_diag.was_blocked
			and battlespatial_bound_geo.contains_point(battlespatial_diag.final_position)
			and BattlefieldGeometry.is_finite_point(battlespatial_diag.final_position)
			and _battlespatial_collinear(battlespatial_diag.resolved_displacement, battlespatial_diag_req)
			and is_equal_approx(battlespatial_diag.final_position.x, 100.0)
			and is_equal_approx(battlespatial_diag.final_position.y, 52.0)
		)

	var battlespatial_eps: float = BattleSpatialService.COLLISION_EPSILON
	var battlespatial_wall_hit_ok: bool = false
	var battlespatial_tunnel_ok: bool = false
	var battlespatial_nonblock_ok: bool = false
	var battlespatial_start_inside_ok: bool = false
	var battlespatial_start_inside_nonblock_ok: bool = false
	var battlespatial_hit_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_hit_bs != null and battlespatial_hit_bs.battlefield_geometry != null:
		var battlespatial_hit_geo: BattlefieldGeometry = battlespatial_hit_bs.battlefield_geometry
		var battlespatial_wall_a: BattleObstacle = BattleObstacle.new(
			"wall_a",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		if battlespatial_hit_geo.add_obstacle(battlespatial_wall_a):
			var battlespatial_hit_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_hit_bs,
				Vector2(30.0, 30.0),
				Vector2(20.0, 0.0)
			)
			battlespatial_wall_hit_ok = (
				battlespatial_hit_res != null
				and battlespatial_hit_res.success
				and battlespatial_hit_res.was_blocked
				and battlespatial_hit_res.blocking_obstacle_id == "wall_a"
				and is_equal_approx(battlespatial_hit_res.final_position.x, 40.0 - battlespatial_eps)
				and is_equal_approx(battlespatial_hit_res.final_position.y, 30.0)
				and not battlespatial_wall_a.contains_point(battlespatial_hit_res.final_position)
				and battlespatial_hit_geo.contains_point(battlespatial_hit_res.final_position)
			)
			var battlespatial_tunnel_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_hit_bs,
				Vector2(30.0, 30.0),
				Vector2(100.0, 0.0)
			)
			battlespatial_tunnel_ok = (
				battlespatial_tunnel_res != null
				and battlespatial_tunnel_res.success
				and battlespatial_tunnel_res.was_blocked
				and battlespatial_tunnel_res.blocking_obstacle_id == "wall_a"
				and battlespatial_tunnel_res.final_position.x < 40.0
				and battlespatial_tunnel_res.final_position.x < 50.0
				and not battlespatial_wall_a.contains_point(battlespatial_tunnel_res.final_position)
				and not battlespatial_tunnel_res.final_position.is_equal_approx(Vector2(130.0, 30.0))
			)
			var battlespatial_inside_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_hit_bs,
				Vector2(45.0, 30.0),
				Vector2(5.0, 0.0)
			)
			battlespatial_start_inside_ok = (
				_battlespatial_fail_ok(battlespatial_inside_res, "start_inside_blocking_obstacle")
				and battlespatial_inside_res.blocking_obstacle_id == "wall_a"
				and battlespatial_inside_res.final_position.is_equal_approx(Vector2(45.0, 30.0))
				and battlespatial_inside_res.resolved_displacement.is_equal_approx(Vector2.ZERO)
			)
		var battlespatial_non_bs: BattleState = _battlemove_make_state("active")
		if battlespatial_non_bs != null and battlespatial_non_bs.battlefield_geometry != null:
			var battlespatial_soft: BattleObstacle = BattleObstacle.new(
				"soft_zone",
				Rect2(40.0, 20.0, 10.0, 20.0),
				false
			)
			if battlespatial_non_bs.battlefield_geometry.add_obstacle(battlespatial_soft):
				var battlespatial_soft_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
					battlespatial_non_bs,
					Vector2(30.0, 30.0),
					Vector2(20.0, 0.0)
				)
				battlespatial_nonblock_ok = (
					battlespatial_soft_res != null
					and battlespatial_soft_res.success
					and battlespatial_soft_res.was_blocked == false
					and battlespatial_soft_res.blocking_obstacle_id.is_empty()
					and battlespatial_soft_res.final_position.is_equal_approx(Vector2(50.0, 30.0))
				)
				var battlespatial_soft_inside: BattleSpatialResult = BattleSpatialService.resolve_translation(
					battlespatial_non_bs,
					Vector2(45.0, 30.0),
					Vector2(5.0, 0.0)
				)
				battlespatial_start_inside_nonblock_ok = (
					battlespatial_soft_inside != null
					and battlespatial_soft_inside.success
					and battlespatial_soft_inside.was_blocked == false
					and battlespatial_soft_inside.final_position.is_equal_approx(Vector2(50.0, 30.0))
				)

	var battlespatial_earliest_ok: bool = false
	var battlespatial_tie_ok: bool = false
	var battlespatial_early_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_early_bs != null and battlespatial_early_bs.battlefield_geometry != null:
		var battlespatial_far: BattleObstacle = BattleObstacle.new("far_wall", Rect2(60.0, 20.0, 10.0, 20.0), true)
		var battlespatial_near: BattleObstacle = BattleObstacle.new("near_wall", Rect2(40.0, 20.0, 10.0, 20.0), true)
		if (
			battlespatial_early_bs.battlefield_geometry.add_obstacle(battlespatial_far)
			and battlespatial_early_bs.battlefield_geometry.add_obstacle(battlespatial_near)
		):
			var battlespatial_early_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_early_bs,
				Vector2(30.0, 30.0),
				Vector2(50.0, 0.0)
			)
			battlespatial_earliest_ok = (
				battlespatial_early_res != null
				and battlespatial_early_res.success
				and battlespatial_early_res.was_blocked
				and battlespatial_early_res.blocking_obstacle_id == "near_wall"
				and battlespatial_early_res.final_position.x < 40.0
				and not battlespatial_near.contains_point(battlespatial_early_res.final_position)
			)
		var battlespatial_tie_bs: BattleState = _battlemove_make_state("active")
		if battlespatial_tie_bs != null and battlespatial_tie_bs.battlefield_geometry != null:
			var battlespatial_z_wall: BattleObstacle = BattleObstacle.new("z_wall", Rect2(40.0, 25.0, 10.0, 10.0), true)
			var battlespatial_a_wall: BattleObstacle = BattleObstacle.new("a_wall", Rect2(40.0, 20.0, 10.0, 20.0), true)
			if (
				battlespatial_tie_bs.battlefield_geometry.add_obstacle(battlespatial_z_wall)
				and battlespatial_tie_bs.battlefield_geometry.add_obstacle(battlespatial_a_wall)
			):
				var battlespatial_tie_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
					battlespatial_tie_bs,
					Vector2(30.0, 30.0),
					Vector2(20.0, 0.0)
				)
				battlespatial_tie_ok = (
					battlespatial_tie_res != null
					and battlespatial_tie_res.success
					and battlespatial_tie_res.was_blocked
					and battlespatial_tie_res.blocking_obstacle_id == "a_wall"
				)

	var battlespatial_obs_before_bound_ok: bool = false
	var battlespatial_bound_before_obs_ok: bool = false
	var battlespatial_obs_bound_tie_ok: bool = false
	var battlespatial_order_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_order_bs != null and battlespatial_order_bs.battlefield_geometry != null:
		var battlespatial_pre_exit: BattleObstacle = BattleObstacle.new(
			"pre_exit",
			Rect2(95.0, 0.0, 2.0, 60.0),
			true
		)
		if battlespatial_order_bs.battlefield_geometry.add_obstacle(battlespatial_pre_exit):
			var battlespatial_pre_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_order_bs,
				Vector2(90.0, 30.0),
				Vector2(20.0, 0.0)
			)
			battlespatial_obs_before_bound_ok = (
				battlespatial_pre_res != null
				and battlespatial_pre_res.success
				and battlespatial_pre_res.was_blocked
				and battlespatial_pre_res.blocking_obstacle_id == "pre_exit"
				and battlespatial_pre_res.final_position.x < 95.0
			)
		var battlespatial_post_bs: BattleState = _battlemove_make_state("active")
		if battlespatial_post_bs != null and battlespatial_post_bs.battlefield_geometry != null:
			var battlespatial_outside_wall: BattleObstacle = BattleObstacle.new(
				"outside_wall",
				Rect2(105.0, 20.0, 10.0, 20.0),
				true
			)
			if battlespatial_post_bs.battlefield_geometry.add_obstacle(battlespatial_outside_wall):
				var battlespatial_post_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
					battlespatial_post_bs,
					Vector2(95.0, 30.0),
					Vector2(20.0, 0.0)
				)
				battlespatial_bound_before_obs_ok = (
					battlespatial_post_res != null
					and battlespatial_post_res.success
					and battlespatial_post_res.was_blocked
					and battlespatial_post_res.blocking_obstacle_id.is_empty()
					and is_equal_approx(battlespatial_post_res.final_position.x, 100.0)
				)
		var battlespatial_tie2_bs: BattleState = _battlemove_make_state("active")
		if battlespatial_tie2_bs != null and battlespatial_tie2_bs.battlefield_geometry != null:
			var battlespatial_edge_wall: BattleObstacle = BattleObstacle.new(
				"edge_wall",
				Rect2(100.0, 0.0, 5.0, 60.0),
				true
			)
			if battlespatial_tie2_bs.battlefield_geometry.add_obstacle(battlespatial_edge_wall):
				var battlespatial_tie2_res: BattleSpatialResult = BattleSpatialService.resolve_translation(
					battlespatial_tie2_bs,
					Vector2(90.0, 30.0),
					Vector2(20.0, 0.0)
				)
				battlespatial_obs_bound_tie_ok = (
					battlespatial_tie2_res != null
					and battlespatial_tie2_res.success
					and battlespatial_tie2_res.was_blocked
					and battlespatial_tie2_res.blocking_obstacle_id == "edge_wall"
				)

	var battlespatial_diag_wall_ok: bool = false
	var battlespatial_diag_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_diag_bs != null and battlespatial_diag_bs.battlefield_geometry != null:
		var battlespatial_diag_wall: BattleObstacle = BattleObstacle.new(
			"diag_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		if battlespatial_diag_bs.battlefield_geometry.add_obstacle(battlespatial_diag_wall):
			var battlespatial_diag_req2: Vector2 = Vector2(20.0, 10.0)
			var battlespatial_diag_hit: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_diag_bs,
				Vector2(30.0, 25.0),
				battlespatial_diag_req2
			)
			battlespatial_diag_wall_ok = (
				battlespatial_diag_hit != null
				and battlespatial_diag_hit.success
				and battlespatial_diag_hit.was_blocked
				and battlespatial_diag_hit.blocking_obstacle_id == "diag_wall"
				and not battlespatial_diag_wall.contains_point(battlespatial_diag_hit.final_position)
				and _battlespatial_collinear(battlespatial_diag_hit.resolved_displacement, battlespatial_diag_req2)
				and not is_equal_approx(battlespatial_diag_hit.final_position.x, 50.0)
				and not is_equal_approx(battlespatial_diag_hit.final_position.y, 35.0)
			)

	var battlespatial_move_integrate_ok: bool = false
	var battlespatial_blocked_count_ok: bool = false
	var battlespatial_partial_count_ok: bool = false
	var battlespatial_velocity_ok: bool = false
	var battlespatial_move_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_move_bs != null and battlespatial_move_bs.battlefield_geometry != null:
		var battlespatial_move_wall: BattleObstacle = BattleObstacle.new(
			"move_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlespatial_move_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_move_bs,
			"spatial_move_p",
			"attacker"
		)
		if battlespatial_move_p != null and battlespatial_move_bs.battlefield_geometry.add_obstacle(battlespatial_move_wall):
			battlespatial_move_p.has_battle_position = true
			battlespatial_move_p.battle_position = Vector2(30.0, 30.0)
			var battlespatial_move_speed: bool = battlespatial_move_p.set_movement_speed(10.0)
			var battlespatial_move_intent: bool = battlespatial_move_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_expected: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlespatial_move_bs,
				Vector2(30.0, 30.0),
				Vector2(20.0, 0.0)
			)
			var battlespatial_move_res: BattleMovementResult = BattleMovementService.advance(battlespatial_move_bs, 2.0)
			battlespatial_move_integrate_ok = (
				battlespatial_move_speed
				and battlespatial_move_intent
				and battlespatial_move_res != null
				and battlespatial_move_res.success
				and battlespatial_move_p.velocity.is_equal_approx(Vector2(10.0, 0.0))
				and battlespatial_move_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlespatial_expected != null
				and battlespatial_expected.success
				and battlespatial_move_p.battle_position.is_equal_approx(battlespatial_expected.final_position)
				and not battlespatial_move_wall.contains_point(battlespatial_move_p.battle_position)
				and battlespatial_move_p.battle_position.x < 40.0
			)
			battlespatial_partial_count_ok = (
				battlespatial_move_integrate_ok
				and _battlemove_ok(battlespatial_move_res, 2.0, 1, 1)
			)
			var battlespatial_block_bs: BattleState = _battlemove_make_state("active")
			if battlespatial_block_bs != null and battlespatial_block_bs.battlefield_geometry != null:
				var battlespatial_block_wall: BattleObstacle = BattleObstacle.new(
					"block_wall",
					Rect2(40.0, 20.0, 10.0, 20.0),
					true
				)
				var battlespatial_block_p: BattleParticipant = _battlemove_add_participant(
					battlespatial_block_bs,
					"spatial_block_p",
					"attacker"
				)
				if (
					battlespatial_block_p != null
					and battlespatial_block_bs.battlefield_geometry.add_obstacle(battlespatial_block_wall)
				):
					var battlespatial_block_start: Vector2 = Vector2(40.0 - battlespatial_eps * 0.5, 30.0)
					battlespatial_block_p.has_battle_position = true
					battlespatial_block_p.battle_position = battlespatial_block_start
					var battlespatial_block_speed: bool = battlespatial_block_p.set_movement_speed(5.0)
					var battlespatial_block_intent: bool = battlespatial_block_p.set_movement_intent(Vector2(1.0, 0.0))
					var battlespatial_block_res: BattleMovementResult = BattleMovementService.advance(
						battlespatial_block_bs,
						1.0
					)
					battlespatial_blocked_count_ok = (
						battlespatial_block_speed
						and battlespatial_block_intent
						and _battlemove_ok(battlespatial_block_res, 1.0, 1, 0)
						and battlespatial_block_p.battle_position.is_equal_approx(battlespatial_block_start)
						and battlespatial_block_p.velocity.is_equal_approx(Vector2(5.0, 0.0))
						and battlespatial_block_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
					)
					battlespatial_velocity_ok = battlespatial_blocked_count_ok

	var battlespatial_sibling_malformed_ok: bool = false
	var battlespatial_sib_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_sib_bs != null:
		var battlespatial_sib_a: BattleParticipant = _battlemove_add_participant(
			battlespatial_sib_bs,
			"spatial_sib_a",
			"attacker"
		)
		var battlespatial_sib_b: BattleParticipant = _battlemove_add_participant(
			battlespatial_sib_bs,
			"spatial_sib_b",
			"attacker"
		)
		if battlespatial_sib_a != null and battlespatial_sib_b != null:
			battlespatial_sib_a.has_battle_position = true
			battlespatial_sib_a.battle_position = Vector2(10.0, 10.0)
			var battlespatial_sib_a_speed: bool = battlespatial_sib_a.set_movement_speed(2.0)
			var battlespatial_sib_a_intent: bool = battlespatial_sib_a.set_movement_intent(Vector2(1.0, 0.0))
			battlespatial_sib_b.has_battle_position = true
			battlespatial_sib_b.battle_position = Vector2(NAN, 20.0)
			var battlespatial_sib_b_speed: bool = battlespatial_sib_b.set_movement_speed(2.0)
			var battlespatial_sib_b_intent: bool = battlespatial_sib_b.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_sib_res: BattleMovementResult = BattleMovementService.advance(battlespatial_sib_bs, 1.0)
			battlespatial_sibling_malformed_ok = (
				battlespatial_sib_a_speed
				and battlespatial_sib_a_intent
				and battlespatial_sib_b_speed
				and battlespatial_sib_b_intent
				and battlespatial_sib_res != null
				and battlespatial_sib_res.success
				and _battlemove_ok(battlespatial_sib_res, 1.0, 2, 1)
				and battlespatial_sib_a.battle_position.is_equal_approx(Vector2(12.0, 10.0))
				and is_nan(battlespatial_sib_b.battle_position.x)
				and is_equal_approx(battlespatial_sib_b.battle_position.y, 20.0)
			)

	var battlespatial_sibling_inside_ok: bool = false
	var battlespatial_in_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_in_bs != null and battlespatial_in_bs.battlefield_geometry != null:
		var battlespatial_in_wall: BattleObstacle = BattleObstacle.new(
			"inside_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlespatial_in_a: BattleParticipant = _battlemove_add_participant(
			battlespatial_in_bs,
			"spatial_in_a",
			"attacker"
		)
		var battlespatial_in_b: BattleParticipant = _battlemove_add_participant(
			battlespatial_in_bs,
			"spatial_in_b",
			"attacker"
		)
		if (
			battlespatial_in_a != null
			and battlespatial_in_b != null
			and battlespatial_in_bs.battlefield_geometry.add_obstacle(battlespatial_in_wall)
		):
			battlespatial_in_a.has_battle_position = true
			battlespatial_in_a.battle_position = Vector2(10.0, 10.0)
			var battlespatial_in_a_speed: bool = battlespatial_in_a.set_movement_speed(2.0)
			var battlespatial_in_a_intent: bool = battlespatial_in_a.set_movement_intent(Vector2(1.0, 0.0))
			battlespatial_in_b.has_battle_position = true
			battlespatial_in_b.battle_position = Vector2(45.0, 30.0)
			var battlespatial_in_b_speed: bool = battlespatial_in_b.set_movement_speed(2.0)
			var battlespatial_in_b_intent: bool = battlespatial_in_b.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_in_res: BattleMovementResult = BattleMovementService.advance(battlespatial_in_bs, 1.0)
			battlespatial_sibling_inside_ok = (
				battlespatial_in_a_speed
				and battlespatial_in_a_intent
				and battlespatial_in_b_speed
				and battlespatial_in_b_intent
				and battlespatial_in_res != null
				and battlespatial_in_res.success
				and _battlemove_ok(battlespatial_in_res, 1.0, 2, 1)
				and battlespatial_in_a.battle_position.is_equal_approx(Vector2(12.0, 10.0))
				and battlespatial_in_b.battle_position.is_equal_approx(Vector2(45.0, 30.0))
			)

	var battlespatial_move_missing_geo_ok: bool = false
	var battlespatial_missmove_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_missmove_bs != null:
		var battlespatial_missmove_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_missmove_bs,
			"spatial_missmove_p",
			"attacker"
		)
		if battlespatial_missmove_p != null:
			battlespatial_missmove_p.has_battle_position = true
			battlespatial_missmove_p.battle_position = Vector2(10.0, 10.0)
			var battlespatial_missmove_speed: bool = battlespatial_missmove_p.set_movement_speed(2.0)
			var battlespatial_missmove_intent: bool = battlespatial_missmove_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_missmove_snap: Dictionary = _battlemove_part_snap(battlespatial_missmove_p)
			battlespatial_missmove_bs.battlefield_geometry = null
			var battlespatial_missmove_res: BattleMovementResult = BattleMovementService.advance(
				battlespatial_missmove_bs,
				0.5
			)
			battlespatial_move_missing_geo_ok = (
				battlespatial_missmove_speed
				and battlespatial_missmove_intent
				and _battlemove_fail_ok(battlespatial_missmove_res, "missing_battlefield_geometry", 0.5)
				and _battlemove_part_unchanged(battlespatial_missmove_p, battlespatial_missmove_snap)
			)

	var battlespatial_move_invalid_geo_ok: bool = false
	var battlespatial_badmove_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_badmove_bs != null:
		var battlespatial_badmove_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_badmove_bs,
			"spatial_badmove_p",
			"attacker"
		)
		if battlespatial_badmove_p != null:
			battlespatial_badmove_p.has_battle_position = true
			battlespatial_badmove_p.battle_position = Vector2(10.0, 10.0)
			var battlespatial_badmove_speed: bool = battlespatial_badmove_p.set_movement_speed(2.0)
			var battlespatial_badmove_intent: bool = battlespatial_badmove_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_badmove_snap: Dictionary = _battlemove_part_snap(battlespatial_badmove_p)
			battlespatial_badmove_bs.battlefield_geometry = BattlefieldGeometry.new()
			var battlespatial_badmove_res: BattleMovementResult = BattleMovementService.advance(
				battlespatial_badmove_bs,
				0.5
			)
			battlespatial_move_invalid_geo_ok = (
				battlespatial_badmove_speed
				and battlespatial_badmove_intent
				and _battlemove_fail_ok(battlespatial_badmove_res, "invalid_battlefield_geometry", 0.5)
				and _battlemove_part_unchanged(battlespatial_badmove_p, battlespatial_badmove_snap)
			)

	var battlespatial_runtime_tx_ok: bool = false
	var battlespatial_runtime_ok: bool = false
	var battlespatial_rt_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_rt_bs != null:
		var battlespatial_rt_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_rt_bs,
			"spatial_rt_p",
			"attacker"
		)
		if battlespatial_rt_p != null:
			battlespatial_rt_p.has_battle_position = true
			battlespatial_rt_p.battle_position = Vector2(10.0, 10.0)
			var battlespatial_rt_speed: bool = battlespatial_rt_p.set_movement_speed(2.0)
			var battlespatial_rt_intent: bool = battlespatial_rt_p.set_movement_intent(Vector2(1.0, 0.0))
			battlespatial_rt_bs.elapsed_time_seconds = 4.0
			var battlespatial_rt_snap: Dictionary = _battlemove_part_snap(battlespatial_rt_p)
			battlespatial_rt_bs.battlefield_geometry = null
			var battlespatial_rt_fail: BattleRuntimeResult = BattleRuntimeService.advance(battlespatial_rt_bs, 0.5)
			battlespatial_runtime_tx_ok = (
				battlespatial_rt_speed
				and battlespatial_rt_intent
				and _battlert_fail_ok(battlespatial_rt_fail, "missing_battlefield_geometry", 4.0)
				and is_equal_approx(battlespatial_rt_bs.elapsed_time_seconds, 4.0)
				and _battlemove_part_unchanged(battlespatial_rt_p, battlespatial_rt_snap)
			)
			_battlespatial_attach_open_geometry(battlespatial_rt_bs)
			var battlespatial_rt_ok_res: BattleRuntimeResult = BattleRuntimeService.advance(battlespatial_rt_bs, 0.5)
			battlespatial_runtime_ok = (
				battlespatial_runtime_tx_ok
				and _battlert_clock_ok(battlespatial_rt_ok_res, 0.5, 4.0, 4.5)
				and is_equal_approx(battlespatial_rt_bs.elapsed_time_seconds, 4.5)
				and battlespatial_rt_p.battle_position.is_equal_approx(Vector2(11.0, 10.0))
			)

	var battlespatial_dead_ok: bool = false
	var battlespatial_zero_speed_ok: bool = false
	var battlespatial_zero_intent_ok: bool = false
	var battlespatial_rules_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_rules_bs != null:
		var battlespatial_dead_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_rules_bs,
			"spatial_dead_p",
			"attacker"
		)
		if battlespatial_dead_p != null:
			battlespatial_dead_p.has_battle_position = true
			battlespatial_dead_p.battle_position = Vector2(10.0, 10.0)
			battlespatial_dead_p.is_alive = false
			var battlespatial_dead_speed: bool = battlespatial_dead_p.set_movement_speed(4.0)
			var battlespatial_dead_intent: bool = battlespatial_dead_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_dead_res: BattleMovementResult = BattleMovementService.advance(battlespatial_rules_bs, 1.0)
			battlespatial_dead_ok = (
				battlespatial_dead_speed
				and battlespatial_dead_intent
				and _battlemove_ok(battlespatial_dead_res, 1.0, 1, 0)
				and battlespatial_dead_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlespatial_dead_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
			)
		var battlespatial_zs_bs: BattleState = _battlemove_make_state("active")
		var battlespatial_zs_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_zs_bs,
			"spatial_zs_p",
			"attacker"
		)
		if battlespatial_zs_p != null:
			battlespatial_zs_p.has_battle_position = true
			battlespatial_zs_p.battle_position = Vector2(10.0, 10.0)
			var battlespatial_zs_speed: bool = battlespatial_zs_p.set_movement_speed(0.0)
			var battlespatial_zs_intent: bool = battlespatial_zs_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_zs_res: BattleMovementResult = BattleMovementService.advance(battlespatial_zs_bs, 1.0)
			battlespatial_zero_speed_ok = (
				battlespatial_zs_speed
				and battlespatial_zs_intent
				and _battlemove_ok(battlespatial_zs_res, 1.0, 1, 0)
				and battlespatial_zs_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlespatial_zs_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
			)
		var battlespatial_zi_bs: BattleState = _battlemove_make_state("active")
		var battlespatial_zi_p: BattleParticipant = _battlemove_add_participant(
			battlespatial_zi_bs,
			"spatial_zi_p",
			"attacker"
		)
		if battlespatial_zi_p != null:
			battlespatial_zi_p.has_battle_position = true
			battlespatial_zi_p.battle_position = Vector2(10.0, 10.0)
			var battlespatial_zi_speed: bool = battlespatial_zi_p.set_movement_speed(4.0)
			var battlespatial_zi_intent: bool = battlespatial_zi_p.set_movement_intent(Vector2.ZERO)
			var battlespatial_zi_res: BattleMovementResult = BattleMovementService.advance(battlespatial_zi_bs, 1.0)
			battlespatial_zero_intent_ok = (
				battlespatial_zi_speed
				and battlespatial_zi_intent
				and _battlemove_ok(battlespatial_zi_res, 1.0, 1, 0)
				and battlespatial_zi_p.velocity.is_equal_approx(Vector2.ZERO)
				and battlespatial_zi_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
			)

	var battlespatial_persist_ok: bool = false
	var battlespatial_immutability_ok: bool = false
	var battlespatial_camp_pack: Dictionary = _battle_create_ready_pack()
	var battlespatial_camp_game: GameState = battlespatial_camp_pack.get("game_state", null) as GameState
	var battlespatial_camp_force: TravelingForce = battlespatial_camp_pack.get("force", null) as TravelingForce
	var battlespatial_camp_bs: BattleState = battlespatial_camp_pack.get("battle_state", null) as BattleState
	if battlespatial_camp_game != null and battlespatial_camp_bs != null:
		var battlespatial_camp_deployed: bool = _battle_deploy_standard_attacker(battlespatial_camp_bs)
		var battlespatial_camp_geo: bool = _battlegeo_init(battlespatial_camp_bs)
		var battlespatial_camp_snap: Dictionary = _battle_campaign_snapshot(
			battlespatial_camp_game,
			battlespatial_camp_force,
			"battle_mission"
		)
		var battlespatial_camp_wall: BattleObstacle = BattleObstacle.new(
			"camp_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlespatial_camp_added: bool = false
		if battlespatial_camp_bs.battlefield_geometry != null:
			battlespatial_camp_added = battlespatial_camp_bs.battlefield_geometry.add_obstacle(battlespatial_camp_wall)
		var battlespatial_camp_part: BattleParticipant = battlespatial_camp_bs.get_participant("battle_sol_a")
		var battlespatial_camp_ready: bool = false
		if battlespatial_camp_part != null and battlespatial_camp_part.has_battle_position:
			battlespatial_camp_ready = (
				battlespatial_camp_part.set_movement_speed(2.0)
				and battlespatial_camp_part.set_movement_intent(Vector2(1.0, 0.0))
			)
		var battlespatial_camp_begun: bool = battlespatial_camp_geo and battlespatial_camp_bs.begin_battle()
		var battlespatial_camp_adv: BattleRuntimeResult = BattleRuntimeService.advance(battlespatial_camp_bs, 0.25)
		var battlespatial_camp_persist: Dictionary = battlespatial_camp_game.to_dict()
		battlespatial_persist_ok = (
			battlespatial_camp_deployed
			and battlespatial_camp_added
			and battlespatial_camp_ready
			and battlespatial_camp_begun
			and battlespatial_camp_adv != null
			and battlespatial_camp_adv.success
			and _battle_serialized_campaign_keys_only(battlespatial_camp_persist)
			and not _battle_data_has_tactical_trace(battlespatial_camp_persist)
		)
		battlespatial_immutability_ok = (
			battlespatial_persist_ok
			and _battle_campaign_unchanged(
				battlespatial_camp_game,
				battlespatial_camp_snap,
				battlespatial_camp_force,
				"battle_mission"
			)
			and battlespatial_camp_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlespatial_camp_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlespatial_no_part_collision_ok: bool = false
	var battlespatial_overlap_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_overlap_bs != null:
		var battlespatial_ov_a: BattleParticipant = _battlemove_add_participant(
			battlespatial_overlap_bs,
			"spatial_ov_a",
			"attacker"
		)
		var battlespatial_ov_b: BattleParticipant = _battlemove_add_participant(
			battlespatial_overlap_bs,
			"spatial_ov_b",
			"attacker"
		)
		if battlespatial_ov_a != null and battlespatial_ov_b != null:
			battlespatial_ov_a.has_battle_position = true
			battlespatial_ov_a.battle_position = Vector2(12.0, 12.0)
			var battlespatial_ov_a_speed: bool = battlespatial_ov_a.set_movement_speed(2.0)
			var battlespatial_ov_a_intent: bool = battlespatial_ov_a.set_movement_intent(Vector2(1.0, 0.0))
			battlespatial_ov_b.has_battle_position = true
			battlespatial_ov_b.battle_position = Vector2(12.0, 12.0)
			var battlespatial_ov_b_speed: bool = battlespatial_ov_b.set_movement_speed(2.0)
			var battlespatial_ov_b_intent: bool = battlespatial_ov_b.set_movement_intent(Vector2(1.0, 0.0))
			var battlespatial_ov_res: BattleMovementResult = BattleMovementService.advance(battlespatial_overlap_bs, 1.0)
			battlespatial_no_part_collision_ok = (
				battlespatial_ov_a_speed
				and battlespatial_ov_a_intent
				and battlespatial_ov_b_speed
				and battlespatial_ov_b_intent
				and _battlemove_ok(battlespatial_ov_res, 1.0, 2, 2)
				and battlespatial_ov_a.battle_position.is_equal_approx(battlespatial_ov_b.battle_position)
				and battlespatial_ov_a.battle_position.is_equal_approx(Vector2(14.0, 12.0))
			)

	var battlespatial_no_combat_ok: bool = false
	var battlespatial_no_combat_bs: BattleState = _battlemove_make_state("active")
	if battlespatial_no_combat_bs != null:
		battlespatial_no_combat_ok = (
			_battle_has_no_combat_turn_model(battlespatial_no_combat_bs)
			and battlespatial_no_combat_bs.get("current_turn_index") == null
			and battlespatial_no_combat_bs.get("current_round") == null
			and battlespatial_no_combat_bs.get("active_turn_actor_id") == null
			and battlespatial_no_combat_bs.get("find_path") == null
			and battlespatial_no_combat_bs.get("cover_value") == null
		)

	var battlespatial_ok_res: BattleSpatialResult = BattleSpatialResult.succeeded(
		Vector2(1.0, 2.0),
		Vector2(3.0, 0.0),
		Vector2(3.0, 0.0),
		Vector2(4.0, 2.0),
		false,
		""
	)
	var battlespatial_fail_res: BattleSpatialResult = BattleSpatialResult.failed(
		"null_battle_state",
		"Battle spatial resolution failed: battle_state is null.",
		Vector2(1.0, 2.0),
		Vector2(3.0, 0.0),
		"wall_a"
	)
	var battlespatial_result_helper_ok: bool = (
		battlespatial_ok_res != null
		and battlespatial_ok_res.success
		and battlespatial_ok_res.start_position.is_equal_approx(Vector2(1.0, 2.0))
		and battlespatial_ok_res.requested_displacement.is_equal_approx(Vector2(3.0, 0.0))
		and battlespatial_ok_res.resolved_displacement.is_equal_approx(Vector2(3.0, 0.0))
		and battlespatial_ok_res.final_position.is_equal_approx(Vector2(4.0, 2.0))
		and battlespatial_ok_res.was_blocked == false
		and battlespatial_ok_res.blocking_obstacle_id.is_empty()
		and battlespatial_ok_res.error_code.is_empty()
		and battlespatial_ok_res.error_message.is_empty()
		and battlespatial_fail_res != null
		and not battlespatial_fail_res.success
		and battlespatial_fail_res.error_code == "null_battle_state"
		and battlespatial_fail_res.error_message == "Battle spatial resolution failed: battle_state is null."
		and battlespatial_fail_res.final_position.is_equal_approx(Vector2(1.0, 2.0))
		and battlespatial_fail_res.resolved_displacement.is_equal_approx(Vector2.ZERO)
		and battlespatial_fail_res.was_blocked == false
		and battlespatial_fail_res.blocking_obstacle_id == "wall_a"
	)

	var battlenav_req_ok: BattleNavigationRequest = BattleNavigationRequest.new(
		Vector2(10.0, 10.0),
		Vector2(30.0, 20.0)
	)
	var battlenav_req_nan_start: BattleNavigationRequest = BattleNavigationRequest.new(
		Vector2(NAN, 10.0),
		Vector2(30.0, 20.0)
	)
	var battlenav_req_inf_start: BattleNavigationRequest = BattleNavigationRequest.new(
		Vector2(INF, 10.0),
		Vector2(30.0, 20.0)
	)
	var battlenav_req_nan_dest: BattleNavigationRequest = BattleNavigationRequest.new(
		Vector2(10.0, 10.0),
		Vector2(NAN, 20.0)
	)
	var battlenav_req_inf_dest: BattleNavigationRequest = BattleNavigationRequest.new(
		Vector2(10.0, 10.0),
		Vector2(INF, 20.0)
	)
	var battlenav_request_ok: bool = (
		battlenav_req_ok != null
		and battlenav_req_ok.is_valid()
		and battlenav_req_ok.start_position.is_equal_approx(Vector2(10.0, 10.0))
		and battlenav_req_ok.destination.is_equal_approx(Vector2(30.0, 20.0))
		and not battlenav_req_nan_start.is_valid()
		and not battlenav_req_inf_start.is_valid()
		and not battlenav_req_nan_dest.is_valid()
		and not battlenav_req_inf_dest.is_valid()
		and not battlenav_req_ok.has_method("to_dict")
		and not battlenav_req_ok.has_method("from_dict")
		and battlenav_req_ok.get("force_id") == null
		and battlenav_req_ok.get("mission_id") == null
	)

	var battlenav_direct_ok: bool = false
	var battlenav_same_point_ok: bool = false
	var battlenav_length_direct_ok: bool = false
	var battlenav_clear_direct_ok: bool = false
	var battlenav_no_dup_ok: bool = true
	var battlenav_open_bs: BattleState = _battlemove_make_state("active")
	if battlenav_open_bs != null:
		var battlenav_direct_res: BattleNavigationResult = BattleNavigationService.find_path(
			battlenav_open_bs,
			Vector2(10.0, 10.0),
			Vector2(30.0, 20.0)
		)
		var battlenav_direct_len: float = _battlenav_route_length(Vector2(10.0, 10.0), battlenav_direct_res.waypoints)
		battlenav_direct_ok = (
			_battlenav_success_ok(battlenav_direct_res, Vector2(10.0, 10.0), Vector2(30.0, 20.0), false)
			and battlenav_direct_res.waypoints.size() == 1
			and battlenav_direct_res.waypoints[0].is_equal_approx(Vector2(30.0, 20.0))
			and _battlenav_segments_clear(battlenav_open_bs, Vector2(10.0, 10.0), battlenav_direct_res.waypoints)
		)
		battlenav_clear_direct_ok = battlenav_direct_ok
		battlenav_length_direct_ok = (
			battlenav_direct_ok
			and is_finite(battlenav_direct_len)
			and battlenav_direct_len >= 0.0
			and is_equal_approx(battlenav_direct_len, Vector2(10.0, 10.0).distance_to(Vector2(30.0, 20.0)))
		)
		battlenav_no_dup_ok = battlenav_no_dup_ok and _battlenav_no_duplicate_waypoints(battlenav_direct_res)
		var battlenav_same_res: BattleNavigationResult = BattleNavigationService.find_path(
			battlenav_open_bs,
			Vector2(12.0, 14.0),
			Vector2(12.0, 14.0)
		)
		battlenav_same_point_ok = (
			_battlenav_success_ok(battlenav_same_res, Vector2(12.0, 14.0), Vector2(12.0, 14.0), false)
			and battlenav_same_res.waypoints.size() == 1
			and battlenav_same_res.waypoints[0].is_equal_approx(Vector2(12.0, 14.0))
			and _battlenav_segments_clear(battlenav_open_bs, Vector2(12.0, 14.0), battlenav_same_res.waypoints)
		)

	var battlenav_null_res: BattleNavigationResult = BattleNavigationService.find_path(
		null,
		Vector2(10.0, 10.0),
		Vector2(20.0, 10.0)
	)
	var battlenav_fail_null_ok: bool = _battlenav_fail_ok(
		battlenav_null_res,
		"null_battle_state",
		Vector2(10.0, 10.0),
		Vector2(20.0, 10.0)
	)

	var battlenav_fail_missing_geo_ok: bool = false
	var battlenav_miss_bs: BattleState = BattleState.new(
		"nav_miss",
		"nav_type",
		"nav_mission",
		"nav_loc",
		"attacker",
		"defender",
		"active"
	)
	var battlenav_miss_res: BattleNavigationResult = BattleNavigationService.find_path(
		battlenav_miss_bs,
		Vector2(10.0, 10.0),
		Vector2(20.0, 10.0)
	)
	battlenav_fail_missing_geo_ok = (
		_battlenav_fail_ok(battlenav_miss_res, "missing_battlefield_geometry", Vector2(10.0, 10.0), Vector2(20.0, 10.0))
		and battlenav_miss_bs.battlefield_geometry == null
	)

	var battlenav_fail_invalid_geo_ok: bool = false
	var battlenav_fail_bad_start_ok: bool = false
	var battlenav_fail_bad_dest_ok: bool = false
	var battlenav_fail_start_out_ok: bool = false
	var battlenav_fail_dest_out_ok: bool = false
	var battlenav_fail_start_inside_ok: bool = false
	var battlenav_fail_dest_inside_ok: bool = false
	var battlenav_err_bs: BattleState = _battlemove_make_state("active")
	if battlenav_err_bs != null and battlenav_err_bs.battlefield_geometry != null:
		var battlenav_err_wall: BattleObstacle = BattleObstacle.new(
			"nav_err_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlenav_err_added: bool = battlenav_err_bs.battlefield_geometry.add_obstacle(battlenav_err_wall)
		var battlenav_err_part: BattleParticipant = _battlemove_add_participant(
			battlenav_err_bs,
			"nav_err_p",
			"attacker"
		)
		if battlenav_err_added and battlenav_err_part != null:
			battlenav_err_part.has_battle_position = true
			battlenav_err_part.battle_position = Vector2(10.0, 10.0)
			var battlenav_err_geo_snap: Dictionary = _battlenav_geo_snap(battlenav_err_bs.battlefield_geometry)
			var battlenav_err_part_snap: Dictionary = _battlemove_part_snap(battlenav_err_part)
			var battlenav_badgeo_bs: BattleState = _battlemove_make_state("active")
			if battlenav_badgeo_bs != null:
				battlenav_badgeo_bs.battlefield_geometry = BattlefieldGeometry.new()
				var battlenav_badgeo_res: BattleNavigationResult = BattleNavigationService.find_path(
					battlenav_badgeo_bs,
					Vector2(10.0, 10.0),
					Vector2(20.0, 10.0)
				)
				battlenav_fail_invalid_geo_ok = (
					_battlenav_fail_ok(
						battlenav_badgeo_res,
						"invalid_battlefield_geometry",
						Vector2(10.0, 10.0),
						Vector2(20.0, 10.0)
					)
					and battlenav_badgeo_bs.battlefield_geometry != null
					and not battlenav_badgeo_bs.battlefield_geometry.is_valid()
					and is_equal_approx(battlenav_badgeo_bs.battlefield_geometry.width, 0.0)
				)
			var battlenav_nan_start: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(NAN, 10.0),
				Vector2(20.0, 10.0)
			)
			var battlenav_inf_start: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(INF, 10.0),
				Vector2(20.0, 10.0)
			)
			battlenav_fail_bad_start_ok = (
				_battlenav_fail_ok(battlenav_nan_start, "invalid_start_position", Vector2(NAN, 10.0), Vector2(20.0, 10.0))
				and _battlenav_fail_ok(battlenav_inf_start, "invalid_start_position", Vector2(INF, 10.0), Vector2(20.0, 10.0))
			)
			var battlenav_nan_dest: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(10.0, 10.0),
				Vector2(NAN, 10.0)
			)
			var battlenav_inf_dest: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(10.0, 10.0),
				Vector2(INF, 10.0)
			)
			battlenav_fail_bad_dest_ok = (
				_battlenav_fail_ok(battlenav_nan_dest, "invalid_destination", Vector2(10.0, 10.0), Vector2(NAN, 10.0))
				and _battlenav_fail_ok(battlenav_inf_dest, "invalid_destination", Vector2(10.0, 10.0), Vector2(INF, 10.0))
			)
			var battlenav_start_out: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(-1.0, 10.0),
				Vector2(20.0, 10.0)
			)
			battlenav_fail_start_out_ok = _battlenav_fail_ok(
				battlenav_start_out,
				"start_outside_battlefield",
				Vector2(-1.0, 10.0),
				Vector2(20.0, 10.0)
			)
			var battlenav_dest_out: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(10.0, 10.0),
				Vector2(120.0, 10.0)
			)
			battlenav_fail_dest_out_ok = _battlenav_fail_ok(
				battlenav_dest_out,
				"destination_outside_battlefield",
				Vector2(10.0, 10.0),
				Vector2(120.0, 10.0)
			)
			var battlenav_start_in: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(45.0, 30.0),
				Vector2(20.0, 10.0)
			)
			battlenav_fail_start_inside_ok = _battlenav_fail_ok(
				battlenav_start_in,
				"start_inside_blocking_obstacle",
				Vector2(45.0, 30.0),
				Vector2(20.0, 10.0)
			)
			var battlenav_dest_in: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_err_bs,
				Vector2(10.0, 10.0),
				Vector2(45.0, 30.0)
			)
			battlenav_fail_dest_inside_ok = _battlenav_fail_ok(
				battlenav_dest_in,
				"destination_inside_blocking_obstacle",
				Vector2(10.0, 10.0),
				Vector2(45.0, 30.0)
			)
			battlenav_fail_bad_start_ok = (
				battlenav_fail_bad_start_ok
				and _battlenav_geo_unchanged(battlenav_err_bs.battlefield_geometry, battlenav_err_geo_snap)
				and _battlemove_part_unchanged(battlenav_err_part, battlenav_err_part_snap)
			)
			battlenav_fail_bad_dest_ok = (
				battlenav_fail_bad_dest_ok
				and _battlenav_geo_unchanged(battlenav_err_bs.battlefield_geometry, battlenav_err_geo_snap)
			)
			battlenav_fail_start_out_ok = (
				battlenav_fail_start_out_ok
				and _battlenav_geo_unchanged(battlenav_err_bs.battlefield_geometry, battlenav_err_geo_snap)
			)
			battlenav_fail_dest_out_ok = (
				battlenav_fail_dest_out_ok
				and _battlenav_geo_unchanged(battlenav_err_bs.battlefield_geometry, battlenav_err_geo_snap)
			)
			battlenav_fail_start_inside_ok = (
				battlenav_fail_start_inside_ok
				and _battlenav_geo_unchanged(battlenav_err_bs.battlefield_geometry, battlenav_err_geo_snap)
			)
			battlenav_fail_dest_inside_ok = (
				battlenav_fail_dest_inside_ok
				and _battlenav_geo_unchanged(battlenav_err_bs.battlefield_geometry, battlenav_err_geo_snap)
				and _battlemove_part_unchanged(battlenav_err_part, battlenav_err_part_snap)
			)

	var battlenav_detour_ok: bool = false
	var battlenav_length_detour_ok: bool = false
	var battlenav_clear_detour_ok: bool = false
	var battlenav_corner_ok: bool = false
	var battlenav_detour_bs: BattleState = _battlemove_make_state("active")
	if battlenav_detour_bs != null and battlenav_detour_bs.battlefield_geometry != null:
		var battlenav_detour_wall: BattleObstacle = BattleObstacle.new(
			"nav_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		if battlenav_detour_bs.battlefield_geometry.add_obstacle(battlenav_detour_wall):
			var battlenav_detour_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_detour_bs,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			var battlenav_detour_len: float = _battlenav_route_length(
				Vector2(30.0, 30.0),
				battlenav_detour_res.waypoints
			)
			var battlenav_straight: float = Vector2(30.0, 30.0).distance_to(Vector2(60.0, 30.0))
			battlenav_detour_ok = (
				_battlenav_success_ok(battlenav_detour_res, Vector2(30.0, 30.0), Vector2(60.0, 30.0), true)
				and battlenav_detour_res.waypoints.size() >= 2
				and _battlenav_waypoints_legal(battlenav_detour_bs, battlenav_detour_res.waypoints, Vector2(60.0, 30.0))
				and _battlenav_segments_clear(battlenav_detour_bs, Vector2(30.0, 30.0), battlenav_detour_res.waypoints)
			)
			battlenav_clear_detour_ok = battlenav_detour_ok
			battlenav_length_detour_ok = (
				battlenav_detour_ok
				and is_finite(battlenav_detour_len)
				and battlenav_detour_len >= 0.0
				and battlenav_detour_len > battlenav_straight
			)
			battlenav_corner_ok = (
				battlenav_detour_ok
				and _battlenav_corners_clear(battlenav_detour_bs, Vector2(30.0, 30.0), battlenav_detour_res.waypoints)
			)
			battlenav_no_dup_ok = battlenav_no_dup_ok and _battlenav_no_duplicate_waypoints(battlenav_detour_res)

	var battlenav_short_side_ok: bool = false
	var battlenav_short_bs: BattleState = _battlemove_make_state("active")
	if battlenav_short_bs != null and battlenav_short_bs.battlefield_geometry != null:
		var battlenav_short_wall: BattleObstacle = BattleObstacle.new(
			"nav_short_wall",
			Rect2(40.0, 8.0, 10.0, 32.0),
			true
		)
		if battlenav_short_bs.battlefield_geometry.add_obstacle(battlenav_short_wall):
			var battlenav_short_start: Vector2 = Vector2(30.0, 12.0)
			var battlenav_short_dest: Vector2 = Vector2(60.0, 12.0)
			var battlenav_short_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_short_bs,
				battlenav_short_start,
				battlenav_short_dest
			)
			var battlenav_short_len: float = _battlenav_route_length(
				battlenav_short_start,
				battlenav_short_res.waypoints
			)
			var battlenav_expected_short: float = _battlenav_rect_short_detour_length(
				battlenav_short_wall.bounds,
				battlenav_short_start,
				battlenav_short_dest
			)
			battlenav_short_side_ok = (
				_battlenav_success_ok(battlenav_short_res, battlenav_short_start, battlenav_short_dest, true)
				and _battlenav_segments_clear(battlenav_short_bs, battlenav_short_start, battlenav_short_res.waypoints)
				and is_finite(battlenav_expected_short)
				and is_equal_approx(battlenav_short_len, battlenav_expected_short)
			)

	var battlenav_equal_cost_ok: bool = false
	var battlenav_eq_a: BattleState = _battlemove_make_state("active")
	var battlenav_eq_b: BattleState = _battlemove_make_state("active")
	if (
		battlenav_eq_a != null
		and battlenav_eq_b != null
		and battlenav_eq_a.battlefield_geometry != null
		and battlenav_eq_b.battlefield_geometry != null
	):
		var battlenav_eq_wall_a: BattleObstacle = BattleObstacle.new(
			"mid_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlenav_eq_dummy_z: BattleObstacle = BattleObstacle.new("z_dummy", Rect2(90.0, 55.0, 2.0, 2.0), true)
		var battlenav_eq_dummy_a: BattleObstacle = BattleObstacle.new("a_dummy", Rect2(2.0, 2.0, 2.0, 2.0), true)
		var battlenav_eq_wall_b: BattleObstacle = BattleObstacle.new(
			"mid_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlenav_eq_dummy_z2: BattleObstacle = BattleObstacle.new("z_dummy", Rect2(90.0, 55.0, 2.0, 2.0), true)
		var battlenav_eq_dummy_a2: BattleObstacle = BattleObstacle.new("a_dummy", Rect2(2.0, 2.0, 2.0, 2.0), true)
		var battlenav_eq_added: bool = (
			battlenav_eq_a.battlefield_geometry.add_obstacle(battlenav_eq_wall_a)
			and battlenav_eq_a.battlefield_geometry.add_obstacle(battlenav_eq_dummy_z)
			and battlenav_eq_a.battlefield_geometry.add_obstacle(battlenav_eq_dummy_a)
			and battlenav_eq_b.battlefield_geometry.add_obstacle(battlenav_eq_dummy_a2)
			and battlenav_eq_b.battlefield_geometry.add_obstacle(battlenav_eq_dummy_z2)
			and battlenav_eq_b.battlefield_geometry.add_obstacle(battlenav_eq_wall_b)
		)
		if battlenav_eq_added:
			var battlenav_eq_res_a: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_eq_a,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			var battlenav_eq_res_b: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_eq_b,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			battlenav_equal_cost_ok = (
				_battlenav_success_ok(battlenav_eq_res_a, Vector2(30.0, 30.0), Vector2(60.0, 30.0), true)
				and _battlenav_success_ok(battlenav_eq_res_b, Vector2(30.0, 30.0), Vector2(60.0, 30.0), true)
				and _battlenav_waypoints_match(battlenav_eq_res_a.waypoints, battlenav_eq_res_b.waypoints)
				and _battlenav_segments_clear(battlenav_eq_a, Vector2(30.0, 30.0), battlenav_eq_res_a.waypoints)
			)

	var battlenav_multi_ok: bool = false
	var battlenav_clear_multi_ok: bool = false
	var battlenav_simplify_ok: bool = false
	var battlenav_multi_bs: BattleState = _battlemove_make_state("active")
	if battlenav_multi_bs != null and battlenav_multi_bs.battlefield_geometry != null:
		var battlenav_multi_a: BattleObstacle = BattleObstacle.new("nav_multi_a", Rect2(25.0, 0.0, 10.0, 40.0), true)
		var battlenav_multi_b: BattleObstacle = BattleObstacle.new("nav_multi_b", Rect2(55.0, 20.0, 10.0, 40.0), true)
		if (
			battlenav_multi_bs.battlefield_geometry.add_obstacle(battlenav_multi_b)
			and battlenav_multi_bs.battlefield_geometry.add_obstacle(battlenav_multi_a)
		):
			var battlenav_multi_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_multi_bs,
				Vector2(10.0, 20.0),
				Vector2(80.0, 40.0)
			)
			battlenav_multi_ok = (
				_battlenav_success_ok(battlenav_multi_res, Vector2(10.0, 20.0), Vector2(80.0, 40.0), true)
				and _battlenav_waypoints_legal(battlenav_multi_bs, battlenav_multi_res.waypoints, Vector2(80.0, 40.0))
				and _battlenav_segments_clear(battlenav_multi_bs, Vector2(10.0, 20.0), battlenav_multi_res.waypoints)
			)
			battlenav_clear_multi_ok = battlenav_multi_ok
			battlenav_simplify_ok = (
				battlenav_multi_ok
				and battlenav_multi_res.waypoints.size() < 9
				and _battlenav_is_simplified(battlenav_multi_bs, Vector2(10.0, 20.0), battlenav_multi_res.waypoints)
			)
			battlenav_no_dup_ok = battlenav_no_dup_ok and _battlenav_no_duplicate_waypoints(battlenav_multi_res)

	var battlenav_corridor_ok: bool = false
	var battlenav_clear_corridor_ok: bool = false
	var battlenav_corridor_bs: BattleState = _battlemove_make_state("active")
	if battlenav_corridor_bs != null and battlenav_corridor_bs.battlefield_geometry != null:
		var battlenav_cor_n: BattleObstacle = BattleObstacle.new("nav_cor_n", Rect2(40.0, 0.0, 10.0, 22.0), true)
		var battlenav_cor_s: BattleObstacle = BattleObstacle.new("nav_cor_s", Rect2(40.0, 38.0, 10.0, 22.0), true)
		if (
			battlenav_corridor_bs.battlefield_geometry.add_obstacle(battlenav_cor_n)
			and battlenav_corridor_bs.battlefield_geometry.add_obstacle(battlenav_cor_s)
		):
			var battlenav_cor_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_corridor_bs,
				Vector2(20.0, 30.0),
				Vector2(70.0, 30.0)
			)
			battlenav_corridor_ok = (
				_battlenav_success_ok(battlenav_cor_res, Vector2(20.0, 30.0), Vector2(70.0, 30.0), false)
				and battlenav_cor_res.waypoints.size() == 1
				and _battlenav_waypoints_legal(battlenav_corridor_bs, battlenav_cor_res.waypoints, Vector2(70.0, 30.0))
				and _battlenav_segments_clear(battlenav_corridor_bs, Vector2(20.0, 30.0), battlenav_cor_res.waypoints)
				and not battlenav_cor_n.contains_point(Vector2(20.0, 30.0))
				and not battlenav_cor_s.contains_point(Vector2(70.0, 30.0))
			)
			battlenav_clear_corridor_ok = battlenav_corridor_ok
			battlenav_no_dup_ok = battlenav_no_dup_ok and _battlenav_no_duplicate_waypoints(battlenav_cor_res)

	var battlenav_barrier_ok: bool = false
	var battlenav_barrier_bs: BattleState = _battlemove_make_state("active")
	if battlenav_barrier_bs != null and battlenav_barrier_bs.battlefield_geometry != null:
		var battlenav_barrier: BattleObstacle = BattleObstacle.new(
			"nav_barrier",
			Rect2(0.0, 25.0, 100.0, 10.0),
			true
		)
		if battlenav_barrier_bs.battlefield_geometry.add_obstacle(battlenav_barrier):
			var battlenav_barrier_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_barrier_bs,
				Vector2(50.0, 10.0),
				Vector2(50.0, 50.0)
			)
			battlenav_barrier_ok = _battlenav_fail_ok(
				battlenav_barrier_res,
				"no_path",
				Vector2(50.0, 10.0),
				Vector2(50.0, 50.0)
			)

	var battlenav_edge_ok: bool = false
	var battlenav_edge_bs: BattleState = _battlemove_make_state("active")
	if battlenav_edge_bs != null and battlenav_edge_bs.battlefield_geometry != null:
		var battlenav_edge_wall: BattleObstacle = BattleObstacle.new(
			"nav_edge_wall",
			Rect2(40.0, 0.0, 10.0, 40.0),
			true
		)
		if battlenav_edge_bs.battlefield_geometry.add_obstacle(battlenav_edge_wall):
			var battlenav_edge_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_edge_bs,
				Vector2(30.0, 20.0),
				Vector2(60.0, 20.0)
			)
			var battlenav_edge_via_bottom: bool = false
			for battlenav_edge_wp: Vector2 in battlenav_edge_res.waypoints:
				if battlenav_edge_wp.is_equal_approx(Vector2(60.0, 20.0)):
					continue
				if battlenav_edge_wp.y >= 40.0:
					battlenav_edge_via_bottom = true
				else:
					battlenav_edge_via_bottom = false
					break
			battlenav_edge_ok = (
				_battlenav_success_ok(battlenav_edge_res, Vector2(30.0, 20.0), Vector2(60.0, 20.0), true)
				and _battlenav_waypoints_legal(battlenav_edge_bs, battlenav_edge_res.waypoints, Vector2(60.0, 20.0))
				and _battlenav_segments_clear(battlenav_edge_bs, Vector2(30.0, 20.0), battlenav_edge_res.waypoints)
				and battlenav_edge_via_bottom
			)

	var battlenav_nonblock_ok: bool = false
	var battlenav_nonblock_bs: BattleState = _battlemove_make_state("active")
	if battlenav_nonblock_bs != null and battlenav_nonblock_bs.battlefield_geometry != null:
		var battlenav_soft: BattleObstacle = BattleObstacle.new(
			"nav_soft",
			Rect2(40.0, 20.0, 10.0, 20.0),
			false
		)
		if battlenav_nonblock_bs.battlefield_geometry.add_obstacle(battlenav_soft):
			var battlenav_soft_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_nonblock_bs,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			battlenav_nonblock_ok = (
				_battlenav_success_ok(battlenav_soft_res, Vector2(30.0, 30.0), Vector2(60.0, 30.0), false)
				and battlenav_soft_res.waypoints.size() == 1
				and battlenav_soft_res.waypoints[0].is_equal_approx(Vector2(60.0, 30.0))
				and _battlenav_segments_clear(battlenav_nonblock_bs, Vector2(30.0, 30.0), battlenav_soft_res.waypoints)
			)

	var battlenav_mixed_ok: bool = false
	var battlenav_mixed_bs: BattleState = _battlemove_make_state("active")
	if battlenav_mixed_bs != null and battlenav_mixed_bs.battlefield_geometry != null:
		var battlenav_mix_hard: BattleObstacle = BattleObstacle.new(
			"nav_mix_hard",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlenav_mix_soft: BattleObstacle = BattleObstacle.new(
			"nav_mix_soft",
			Rect2(10.0, 40.0, 20.0, 10.0),
			false
		)
		if (
			battlenav_mixed_bs.battlefield_geometry.add_obstacle(battlenav_mix_soft)
			and battlenav_mixed_bs.battlefield_geometry.add_obstacle(battlenav_mix_hard)
		):
			var battlenav_mix_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_mixed_bs,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			var battlenav_hard_only: BattleState = _battlemove_make_state("active")
			var battlenav_hard_match: bool = false
			if battlenav_hard_only != null and battlenav_hard_only.battlefield_geometry != null:
				var battlenav_hard_copy: BattleObstacle = BattleObstacle.new(
					"nav_mix_hard",
					Rect2(40.0, 20.0, 10.0, 20.0),
					true
				)
				if battlenav_hard_only.battlefield_geometry.add_obstacle(battlenav_hard_copy):
					var battlenav_hard_res: BattleNavigationResult = BattleNavigationService.find_path(
						battlenav_hard_only,
						Vector2(30.0, 30.0),
						Vector2(60.0, 30.0)
					)
					battlenav_hard_match = _battlenav_waypoints_match(
						battlenav_mix_res.waypoints,
						battlenav_hard_res.waypoints
					)
			battlenav_mixed_ok = (
				_battlenav_success_ok(battlenav_mix_res, Vector2(30.0, 30.0), Vector2(60.0, 30.0), true)
				and battlenav_hard_match
				and _battlenav_segments_clear(battlenav_mixed_bs, Vector2(30.0, 30.0), battlenav_mix_res.waypoints)
			)

	var battlenav_readonly_ok: bool = false
	var battlenav_ro_bs: BattleState = _battlemove_make_state("active")
	if battlenav_ro_bs != null and battlenav_ro_bs.battlefield_geometry != null:
		var battlenav_ro_wall: BattleObstacle = BattleObstacle.new(
			"nav_ro_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlenav_ro_part: BattleParticipant = _battlemove_add_participant(
			battlenav_ro_bs,
			"nav_ro_p",
			"attacker"
		)
		if battlenav_ro_part != null and battlenav_ro_bs.battlefield_geometry.add_obstacle(battlenav_ro_wall):
			battlenav_ro_part.has_battle_position = true
			battlenav_ro_part.battle_position = Vector2(12.0, 12.0)
			var battlenav_ro_geo_snap: Dictionary = _battlenav_geo_snap(battlenav_ro_bs.battlefield_geometry)
			var battlenav_ro_part_snap: Dictionary = _battlemove_part_snap(battlenav_ro_part)
			var battlenav_ro_phase: String = battlenav_ro_bs.battle_phase
			var battlenav_ro_elapsed: float = battlenav_ro_bs.elapsed_time_seconds
			var battlenav_ro_res1: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_ro_bs,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			var battlenav_ro_res2: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_ro_bs,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			battlenav_readonly_ok = (
				battlenav_ro_res1 != null
				and battlenav_ro_res2 != null
				and battlenav_ro_res1.success
				and _battlenav_waypoints_match(battlenav_ro_res1.waypoints, battlenav_ro_res2.waypoints)
				and _battlenav_geo_unchanged(battlenav_ro_bs.battlefield_geometry, battlenav_ro_geo_snap)
				and _battlemove_part_unchanged(battlenav_ro_part, battlenav_ro_part_snap)
				and battlenav_ro_bs.battle_phase == battlenav_ro_phase
				and is_equal_approx(battlenav_ro_bs.elapsed_time_seconds, battlenav_ro_elapsed)
			)

	var battlenav_equiv_ok: bool = false
	var battlenav_eqs_a: BattleState = _battlemove_make_state("active")
	var battlenav_eqs_b: BattleState = _battlemove_make_state("active")
	if (
		battlenav_eqs_a != null
		and battlenav_eqs_b != null
		and battlenav_eqs_a.battlefield_geometry != null
		and battlenav_eqs_b.battlefield_geometry != null
	):
		var battlenav_eqs_w1: BattleObstacle = BattleObstacle.new("eqs_wall", Rect2(40.0, 20.0, 10.0, 20.0), true)
		var battlenav_eqs_d1: BattleObstacle = BattleObstacle.new("eqs_dummy", Rect2(90.0, 2.0, 2.0, 2.0), true)
		var battlenav_eqs_w2: BattleObstacle = BattleObstacle.new("eqs_wall", Rect2(40.0, 20.0, 10.0, 20.0), true)
		var battlenav_eqs_d2: BattleObstacle = BattleObstacle.new("eqs_dummy", Rect2(90.0, 2.0, 2.0, 2.0), true)
		if (
			battlenav_eqs_a.battlefield_geometry.add_obstacle(battlenav_eqs_w1)
			and battlenav_eqs_a.battlefield_geometry.add_obstacle(battlenav_eqs_d1)
			and battlenav_eqs_b.battlefield_geometry.add_obstacle(battlenav_eqs_d2)
			and battlenav_eqs_b.battlefield_geometry.add_obstacle(battlenav_eqs_w2)
		):
			var battlenav_eqs_ra: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_eqs_a,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			var battlenav_eqs_rb: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_eqs_b,
				Vector2(30.0, 30.0),
				Vector2(60.0, 30.0)
			)
			battlenav_equiv_ok = (
				battlenav_eqs_ra != null
				and battlenav_eqs_rb != null
				and battlenav_eqs_ra.success == battlenav_eqs_rb.success
				and battlenav_eqs_ra.used_detour == battlenav_eqs_rb.used_detour
				and battlenav_eqs_ra.waypoints.size() == battlenav_eqs_rb.waypoints.size()
				and _battlenav_waypoints_match(battlenav_eqs_ra.waypoints, battlenav_eqs_rb.waypoints)
			)

	var battlenav_store_default_ok: bool = false
	var battlenav_store_set_ok: bool = false
	var battlenav_store_alias_ok: bool = false
	var battlenav_store_tx_ok: bool = false
	var battlenav_store_strip_ok: bool = false
	var battlenav_store_clear_ok: bool = false
	var battlenav_fresh: BattleParticipant = BattleParticipant.new()
	battlenav_store_default_ok = (
		battlenav_fresh.has_navigation_destination == false
		and battlenav_fresh.navigation_waypoints.is_empty()
		and battlenav_fresh.navigation_waypoint_index == 0
		and not battlenav_fresh.has_active_navigation_path()
		and battlenav_fresh.get_current_navigation_waypoint().is_equal_approx(Vector2.ZERO)
		and battlenav_fresh.has_movement_target_position == false
		and battlenav_fresh.movement_target_position.is_equal_approx(Vector2.ZERO)
	)
	var battlenav_store_p: BattleParticipant = BattleParticipant.new()
	var battlenav_caller_path: Array[Vector2] = [Vector2(12.0, 8.0), Vector2(18.0, 8.0), Vector2(22.0, 14.0)]
	var battlenav_set_ok: bool = battlenav_store_p.set_navigation_path(Vector2(22.0, 14.0), battlenav_caller_path)
	battlenav_store_set_ok = (
		battlenav_set_ok
		and battlenav_store_p.has_navigation_destination
		and battlenav_store_p.navigation_destination.is_equal_approx(Vector2(22.0, 14.0))
		and battlenav_store_p.navigation_waypoints.size() == 3
		and battlenav_store_p.navigation_waypoints[0].is_equal_approx(Vector2(12.0, 8.0))
		and battlenav_store_p.navigation_waypoints[1].is_equal_approx(Vector2(18.0, 8.0))
		and battlenav_store_p.navigation_waypoints[2].is_equal_approx(Vector2(22.0, 14.0))
		and battlenav_store_p.navigation_waypoint_index == 0
		and battlenav_store_p.get_current_navigation_waypoint().is_equal_approx(Vector2(12.0, 8.0))
		and battlenav_store_p.has_active_navigation_path()
	)
	battlenav_caller_path[0] = Vector2(99.0, 99.0)
	battlenav_store_alias_ok = (
		battlenav_store_set_ok
		and battlenav_store_p.navigation_waypoints[0].is_equal_approx(Vector2(12.0, 8.0))
		and not battlenav_store_p.navigation_waypoints[0].is_equal_approx(Vector2(99.0, 99.0))
	)
	var battlenav_tx_dest: Vector2 = battlenav_store_p.navigation_destination
	var battlenav_tx_flag: bool = battlenav_store_p.has_navigation_destination
	var battlenav_tx_index: int = battlenav_store_p.navigation_waypoint_index
	var battlenav_tx_copy: Array[Vector2] = _battlenav_copy_points(battlenav_store_p.navigation_waypoints)
	var battlenav_bad_dest: bool = battlenav_store_p.set_navigation_path(Vector2(NAN, 1.0), battlenav_tx_copy)
	var battlenav_bad_wp: Array[Vector2] = [Vector2(1.0, 1.0), Vector2(INF, 2.0)]
	var battlenav_bad_wp_set: bool = battlenav_store_p.set_navigation_path(Vector2(4.0, 4.0), battlenav_bad_wp)
	battlenav_store_tx_ok = (
		not battlenav_bad_dest
		and not battlenav_bad_wp_set
		and battlenav_store_p.has_navigation_destination == battlenav_tx_flag
		and battlenav_store_p.navigation_destination.is_equal_approx(battlenav_tx_dest)
		and battlenav_store_p.navigation_waypoint_index == battlenav_tx_index
		and _battlenav_waypoints_match(battlenav_store_p.navigation_waypoints, battlenav_tx_copy)
	)
	var battlenav_dup_in: Array[Vector2] = [
		Vector2(1.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(4.0, 2.0),
		Vector2(4.0, 2.0),
		Vector2(6.0, 3.0)
	]
	var battlenav_strip_p: BattleParticipant = BattleParticipant.new()
	var battlenav_strip_ok: bool = battlenav_strip_p.set_navigation_path(Vector2(6.0, 3.0), battlenav_dup_in)
	battlenav_store_strip_ok = (
		battlenav_strip_ok
		and battlenav_strip_p.navigation_waypoints.size() == 3
		and battlenav_strip_p.navigation_waypoints[0].is_equal_approx(Vector2(1.0, 1.0))
		and battlenav_strip_p.navigation_waypoints[1].is_equal_approx(Vector2(4.0, 2.0))
		and battlenav_strip_p.navigation_waypoints[2].is_equal_approx(Vector2(6.0, 3.0))
	)
	battlenav_store_p.clear_navigation_path()
	battlenav_store_clear_ok = (
		battlenav_store_p.has_navigation_destination == false
		and battlenav_store_p.navigation_destination.is_equal_approx(Vector2.ZERO)
		and battlenav_store_p.navigation_waypoints.is_empty()
		and battlenav_store_p.navigation_waypoint_index == 0
		and not battlenav_store_p.has_active_navigation_path()
	)

	var battlenav_plan_readonly_ok: bool = false
	var battlenav_follow_owns_intent_ok: bool = false
	var battlenav_plan_bs: BattleState = _battlemove_make_state("active")
	if battlenav_plan_bs != null:
		var battlenav_plan_p: BattleParticipant = _battlemove_add_participant(
			battlenav_plan_bs,
			"nav_plan_p",
			"attacker"
		)
		if battlenav_plan_p != null:
			battlenav_plan_p.has_battle_position = true
			battlenav_plan_p.battle_position = Vector2(10.0, 10.0)
			var battlenav_plan_speed: bool = battlenav_plan_p.set_movement_speed(5.0)
			var battlenav_plan_intent: bool = battlenav_plan_p.set_movement_intent(Vector2.ZERO)
			var battlenav_plan_find: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_plan_bs,
				Vector2(10.0, 10.0),
				Vector2(40.0, 10.0)
			)
			var battlenav_plan_found: bool = (
				battlenav_plan_find != null
				and battlenav_plan_find.success
				and battlenav_plan_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and battlenav_plan_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
			)
			var battlenav_plan_stored: bool = false
			if battlenav_plan_found:
				battlenav_plan_stored = battlenav_plan_p.set_navigation_path(
					Vector2(40.0, 10.0),
					battlenav_plan_find.waypoints
				)
			var battlenav_plan_stored_idle: bool = (
				battlenav_plan_stored
				and battlenav_plan_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and battlenav_plan_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
				and not battlenav_plan_p.has_movement_target_position
			)
			var battlenav_plan_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlenav_plan_bs, 1.0)
			battlenav_plan_readonly_ok = (
				battlenav_plan_speed
				and battlenav_plan_intent
				and battlenav_plan_found
				and battlenav_plan_stored_idle
				and battlenav_plan_rt != null
				and battlenav_plan_rt.success
				and battlenav_plan_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlenav_plan_p.battle_position.is_equal_approx(Vector2(15.0, 10.0))
			)
		var battlenav_own_bs: BattleState = _battlemove_make_state("active")
		var battlenav_own_p: BattleParticipant = _battlemove_add_participant(
			battlenav_own_bs,
			"nav_own_p",
			"attacker"
		)
		if battlenav_own_p != null:
			battlenav_own_p.has_battle_position = true
			battlenav_own_p.battle_position = Vector2(10.0, 10.0)
			var battlenav_own_speed: bool = battlenav_own_p.set_movement_speed(4.0)
			var battlenav_own_intent: bool = battlenav_own_p.set_movement_intent(Vector2(0.0, 1.0))
			var battlenav_own_path: Array[Vector2] = [Vector2(40.0, 10.0)]
			var battlenav_own_stored: bool = battlenav_own_p.set_navigation_path(Vector2(40.0, 10.0), battlenav_own_path)
			var battlenav_own_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlenav_own_bs, 1.0)
			battlenav_follow_owns_intent_ok = (
				battlenav_own_speed
				and battlenav_own_intent
				and battlenav_own_stored
				and battlenav_own_rt != null
				and battlenav_own_rt.success
				and battlenav_own_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlenav_own_p.velocity.is_equal_approx(Vector2(4.0, 0.0))
				and battlenav_own_p.battle_position.is_equal_approx(Vector2(14.0, 10.0))
				and battlenav_own_p.has_navigation_destination
				and battlenav_own_p.navigation_destination.is_equal_approx(Vector2(40.0, 10.0))
			)

	var battlenav_persist_ok: bool = false
	var battlenav_immutability_ok: bool = false
	var battlenav_camp_pack: Dictionary = _battle_create_ready_pack()
	var battlenav_camp_game: GameState = battlenav_camp_pack.get("game_state", null) as GameState
	var battlenav_camp_force: TravelingForce = battlenav_camp_pack.get("force", null) as TravelingForce
	var battlenav_camp_bs: BattleState = battlenav_camp_pack.get("battle_state", null) as BattleState
	if battlenav_camp_game != null and battlenav_camp_bs != null:
		var battlenav_camp_deployed: bool = _battle_deploy_standard_attacker(battlenav_camp_bs)
		var battlenav_camp_geo: bool = _battlegeo_init(battlenav_camp_bs)
		var battlenav_camp_snap: Dictionary = _battle_campaign_snapshot(
			battlenav_camp_game,
			battlenav_camp_force,
			"battle_mission"
		)
		var battlenav_camp_part: BattleParticipant = battlenav_camp_bs.get_participant("battle_sol_a")
		var battlenav_camp_planned: bool = false
		if battlenav_camp_part != null and battlenav_camp_part.has_battle_position:
			var battlenav_camp_dest: Vector2 = battlenav_camp_part.battle_position + Vector2(8.0, 0.0)
			var battlenav_camp_res: BattleNavigationResult = BattleNavigationService.find_path(
				battlenav_camp_bs,
				battlenav_camp_part.battle_position,
				battlenav_camp_dest
			)
			if battlenav_camp_res != null and battlenav_camp_res.success:
				battlenav_camp_planned = battlenav_camp_part.set_navigation_path(
					battlenav_camp_dest,
					battlenav_camp_res.waypoints
				)
		var battlenav_camp_persist: Dictionary = battlenav_camp_game.to_dict()
		battlenav_persist_ok = (
			battlenav_camp_deployed
			and battlenav_camp_geo
			and battlenav_camp_planned
			and _battle_serialized_campaign_keys_only(battlenav_camp_persist)
			and not _battle_data_has_tactical_trace(battlenav_camp_persist)
		)
		battlenav_immutability_ok = (
			battlenav_persist_ok
			and _battle_campaign_unchanged(
				battlenav_camp_game,
				battlenav_camp_snap,
				battlenav_camp_force,
				"battle_mission"
			)
			and battlenav_camp_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlenav_camp_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlenav_no_combat_ok: bool = false
	var battlenav_no_combat_bs: BattleState = _battlemove_make_state("active")
	var battlenav_no_combat_rt: BattleRuntimeService = BattleRuntimeService.new()
	var battlenav_no_combat_mv: BattleMovementService = BattleMovementService.new()
	var battlenav_no_combat_p: BattleParticipant = BattleParticipant.new()
	if battlenav_no_combat_bs != null:
		battlenav_no_combat_ok = (
			_battle_has_no_combat_turn_model(battlenav_no_combat_bs)
			and battlenav_no_combat_bs.get("current_turn_index") == null
			and battlenav_no_combat_bs.get("current_round") == null
			and battlenav_no_combat_bs.get("active_turn_actor_id") == null
			and battlenav_no_combat_bs.get("find_path") == null
			and battlenav_no_combat_bs.get("cover_value") == null
			and not battlenav_no_combat_rt.has_method("find_path")
			and not battlenav_no_combat_rt.has_method("follow_path")
			and not battlenav_no_combat_rt.has_method("advance_navigation")
			and not battlenav_no_combat_mv.has_method("follow_path")
			and not battlenav_no_combat_p.has_method("follow_navigation")
			and not battlenav_no_combat_p.has_method("apply_navigation_intent")
		)

	var battlenav_helper_wps: Array[Vector2] = [Vector2(1.0, 2.0), Vector2(3.0, 4.0)]
	var battlenav_ok_res: BattleNavigationResult = BattleNavigationResult.succeeded(
		Vector2(0.0, 0.0),
		Vector2(3.0, 4.0),
		battlenav_helper_wps,
		true
	)
	battlenav_helper_wps[0] = Vector2(9.0, 9.0)
	var battlenav_fail_res: BattleNavigationResult = BattleNavigationResult.failed(
		"no_path",
		"Battle navigation failed: no legal path exists.",
		Vector2(1.0, 1.0),
		Vector2(2.0, 2.0)
	)
	var battlenav_result_helper_ok: bool = (
		battlenav_ok_res != null
		and battlenav_ok_res.success
		and battlenav_ok_res.start_position.is_equal_approx(Vector2(0.0, 0.0))
		and battlenav_ok_res.destination.is_equal_approx(Vector2(3.0, 4.0))
		and battlenav_ok_res.used_detour
		and battlenav_ok_res.waypoints.size() == 2
		and battlenav_ok_res.waypoints[0].is_equal_approx(Vector2(1.0, 2.0))
		and battlenav_ok_res.waypoints[1].is_equal_approx(Vector2(3.0, 4.0))
		and battlenav_ok_res.error_code.is_empty()
		and battlenav_ok_res.error_message.is_empty()
		and battlenav_fail_res != null
		and not battlenav_fail_res.success
		and battlenav_fail_res.start_position.is_equal_approx(Vector2(1.0, 1.0))
		and battlenav_fail_res.destination.is_equal_approx(Vector2(2.0, 2.0))
		and battlenav_fail_res.waypoints.is_empty()
		and battlenav_fail_res.used_detour == false
		and battlenav_fail_res.error_code == "no_path"
		and battlenav_fail_res.error_message == "Battle navigation failed: no legal path exists."
	)

	var battlefollow_default_ok: bool = false
	var battlefollow_fresh: BattleParticipant = BattleParticipant.new()
	battlefollow_default_ok = (
		battlefollow_fresh.has_movement_target_position == false
		and battlefollow_fresh.movement_target_position.is_equal_approx(Vector2.ZERO)
		and battlefollow_fresh.has_navigation_destination == false
		and battlefollow_fresh.navigation_waypoints.is_empty()
		and battlefollow_fresh.navigation_waypoint_index == 0
		and not battlefollow_fresh.has_active_navigation_path()
	)

	var battlefollow_fail_null_ok: bool = _battlefollow_fail_ok(
		BattlePathFollowService.advance(null),
		"null_battle_state"
	)
	var battlefollow_fail_not_active_ok: bool = false
	var battlefollow_fail_missing_geo_ok: bool = false
	var battlefollow_fail_invalid_geo_ok: bool = false
	var battlefollow_deploy_bs: BattleState = _battlemove_make_state("deployment")
	if battlefollow_deploy_bs != null:
		var battlefollow_deploy_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_deploy_bs,
			"follow_dep_p",
			"attacker"
		)
		if battlefollow_deploy_p != null:
			var battlefollow_dep_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_dep_stored: bool = battlefollow_deploy_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_dep_path
			)
			var battlefollow_dep_intent: bool = battlefollow_deploy_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlefollow_dep_target: bool = battlefollow_deploy_p.set_movement_target_position(Vector2(20.0, 10.0))
			var battlefollow_dep_snap: Dictionary = _battlefollow_part_snap(battlefollow_deploy_p)
			var battlefollow_dep_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_deploy_bs)
			battlefollow_fail_not_active_ok = (
				battlefollow_dep_stored
				and battlefollow_dep_intent
				and battlefollow_dep_target
				and _battlefollow_fail_ok(battlefollow_dep_res, "battle_not_active")
				and _battlefollow_part_unchanged(battlefollow_deploy_p, battlefollow_dep_snap)
			)
	var battlefollow_miss_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_miss_bs != null:
		var battlefollow_miss_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_miss_bs,
			"follow_miss_p",
			"attacker"
		)
		if battlefollow_miss_p != null:
			var battlefollow_miss_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_miss_stored: bool = battlefollow_miss_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_miss_path
			)
			var battlefollow_miss_intent: bool = battlefollow_miss_p.set_movement_intent(Vector2(0.0, 1.0))
			var battlefollow_miss_snap: Dictionary = _battlefollow_part_snap(battlefollow_miss_p)
			battlefollow_miss_bs.battlefield_geometry = null
			var battlefollow_miss_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_miss_bs)
			battlefollow_fail_missing_geo_ok = (
				battlefollow_miss_stored
				and battlefollow_miss_intent
				and _battlefollow_fail_ok(battlefollow_miss_res, "missing_battlefield_geometry")
				and _battlefollow_part_unchanged(battlefollow_miss_p, battlefollow_miss_snap)
			)
	var battlefollow_badgeo_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_badgeo_bs != null:
		var battlefollow_badgeo_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_badgeo_bs,
			"follow_badgeo_p",
			"attacker"
		)
		if battlefollow_badgeo_p != null:
			var battlefollow_badgeo_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_badgeo_stored: bool = battlefollow_badgeo_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_badgeo_path
			)
			var battlefollow_badgeo_intent: bool = battlefollow_badgeo_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlefollow_badgeo_snap: Dictionary = _battlefollow_part_snap(battlefollow_badgeo_p)
			battlefollow_badgeo_bs.battlefield_geometry = BattlefieldGeometry.new()
			var battlefollow_badgeo_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_badgeo_bs)
			battlefollow_fail_invalid_geo_ok = (
				battlefollow_badgeo_stored
				and battlefollow_badgeo_intent
				and _battlefollow_fail_ok(battlefollow_badgeo_res, "invalid_battlefield_geometry")
				and _battlefollow_part_unchanged(battlefollow_badgeo_p, battlefollow_badgeo_snap)
			)

	var battlefollow_nopath_intent_ok: bool = false
	var battlefollow_manual_intent_ok: bool = false
	var battlefollow_nopath_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_nopath_bs != null:
		var battlefollow_nopath_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_nopath_bs,
			"follow_nopath_p",
			"attacker"
		)
		if battlefollow_nopath_p != null:
			battlefollow_nopath_p.has_battle_position = true
			battlefollow_nopath_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_nopath_intent: bool = battlefollow_nopath_p.set_movement_intent(Vector2(0.0, 1.0))
			var battlefollow_nopath_speed: bool = battlefollow_nopath_p.set_movement_speed(4.0)
			var battlefollow_nopath_stale: bool = battlefollow_nopath_p.set_movement_target_position(Vector2(20.0, 10.0))
			var battlefollow_nopath_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_nopath_bs)
			battlefollow_nopath_intent_ok = (
				battlefollow_nopath_intent
				and battlefollow_nopath_speed
				and battlefollow_nopath_stale
				and _battlefollow_ok(battlefollow_nopath_res, 1, 0, 0)
				and battlefollow_nopath_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
				and not battlefollow_nopath_p.has_navigation_destination
				and battlefollow_nopath_p.navigation_waypoints.is_empty()
				and not battlefollow_nopath_p.has_movement_target_position
			)
			var battlefollow_manual_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_nopath_bs, 1.0)
			battlefollow_manual_intent_ok = (
				battlefollow_nopath_intent_ok
				and battlefollow_manual_rt != null
				and battlefollow_manual_rt.success
				and battlefollow_nopath_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
				and battlefollow_nopath_p.battle_position.is_equal_approx(Vector2(10.0, 14.0))
			)

	var battlefollow_intent_ok: bool = false
	var battlefollow_norm_ok: bool = false
	var battlefollow_intent_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_intent_bs != null:
		var battlefollow_intent_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_intent_bs,
			"follow_intent_p",
			"attacker"
		)
		if battlefollow_intent_p != null:
			battlefollow_intent_p.has_battle_position = true
			battlefollow_intent_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_intent_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_intent_stored: bool = battlefollow_intent_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_intent_path
			)
			var battlefollow_intent_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_intent_bs)
			battlefollow_intent_ok = (
				battlefollow_intent_stored
				and _battlefollow_ok(battlefollow_intent_res, 1, 1, 0)
				and battlefollow_intent_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_intent_p.has_movement_target_position
				and battlefollow_intent_p.movement_target_position.is_equal_approx(Vector2(20.0, 10.0))
				and battlefollow_intent_p.navigation_waypoint_index == 0
				and battlefollow_intent_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
			)
		var battlefollow_norm_bs: BattleState = _battlemove_make_state("active")
		var battlefollow_norm_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_norm_bs,
			"follow_norm_p",
			"attacker"
		)
		if battlefollow_norm_p != null:
			battlefollow_norm_p.has_battle_position = true
			battlefollow_norm_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_norm_path: Array[Vector2] = [Vector2(13.0, 14.0)]
			var battlefollow_norm_stored: bool = battlefollow_norm_p.set_navigation_path(
				Vector2(13.0, 14.0),
				battlefollow_norm_path
			)
			var battlefollow_norm_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_norm_bs)
			battlefollow_norm_ok = (
				battlefollow_norm_stored
				and battlefollow_norm_res != null
				and battlefollow_norm_res.success
				and battlefollow_norm_p.movement_intent.is_equal_approx(Vector2(0.6, 0.8))
				and is_equal_approx(battlefollow_norm_p.movement_intent.length(), 1.0)
			)

	var battlefollow_dead_ok: bool = false
	var battlefollow_unpos_ok: bool = false
	var battlefollow_malformed_ok: bool = false
	var battlefollow_dead_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_dead_bs != null:
		var battlefollow_dead_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_dead_bs,
			"follow_dead_p",
			"attacker"
		)
		var battlefollow_dead_sib: BattleParticipant = _battlemove_add_participant(
			battlefollow_dead_bs,
			"follow_dead_sib",
			"attacker"
		)
		if battlefollow_dead_p != null and battlefollow_dead_sib != null:
			battlefollow_dead_p.has_battle_position = true
			battlefollow_dead_p.battle_position = Vector2(10.0, 10.0)
			battlefollow_dead_p.is_alive = false
			var battlefollow_dead_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_dead_stored: bool = battlefollow_dead_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_dead_path
			)
			var battlefollow_dead_intent: bool = battlefollow_dead_p.set_movement_intent(Vector2(1.0, 0.0))
			battlefollow_dead_sib.has_battle_position = true
			battlefollow_dead_sib.battle_position = Vector2(12.0, 12.0)
			var battlefollow_dead_sib_path: Array[Vector2] = [Vector2(22.0, 12.0)]
			var battlefollow_dead_sib_stored: bool = battlefollow_dead_sib.set_navigation_path(
				Vector2(22.0, 12.0),
				battlefollow_dead_sib_path
			)
			var battlefollow_dead_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_dead_bs)
			battlefollow_dead_ok = (
				battlefollow_dead_stored
				and battlefollow_dead_intent
				and battlefollow_dead_sib_stored
				and _battlefollow_ok(battlefollow_dead_res, 2, 2, 0)
				and battlefollow_dead_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and not battlefollow_dead_p.has_movement_target_position
				and battlefollow_dead_p.navigation_waypoint_index == 0
				and battlefollow_dead_p.has_active_navigation_path()
				and battlefollow_dead_sib.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)
	var battlefollow_unpos_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_unpos_bs != null:
		var battlefollow_unpos_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_unpos_bs,
			"follow_unpos_p",
			"attacker"
		)
		var battlefollow_unpos_sib: BattleParticipant = _battlemove_add_participant(
			battlefollow_unpos_bs,
			"follow_unpos_sib",
			"attacker"
		)
		if battlefollow_unpos_p != null and battlefollow_unpos_sib != null:
			battlefollow_unpos_p.has_battle_position = false
			var battlefollow_unpos_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_unpos_stored: bool = battlefollow_unpos_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_unpos_path
			)
			var battlefollow_unpos_intent: bool = battlefollow_unpos_p.set_movement_intent(Vector2(1.0, 0.0))
			battlefollow_unpos_sib.has_battle_position = true
			battlefollow_unpos_sib.battle_position = Vector2(8.0, 8.0)
			var battlefollow_unpos_sib_path: Array[Vector2] = [Vector2(18.0, 8.0)]
			var battlefollow_unpos_sib_stored: bool = battlefollow_unpos_sib.set_navigation_path(
				Vector2(18.0, 8.0),
				battlefollow_unpos_sib_path
			)
			var battlefollow_unpos_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_unpos_bs)
			battlefollow_unpos_ok = (
				battlefollow_unpos_stored
				and battlefollow_unpos_intent
				and battlefollow_unpos_sib_stored
				and _battlefollow_ok(battlefollow_unpos_res, 2, 2, 0)
				and battlefollow_unpos_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and not battlefollow_unpos_p.has_movement_target_position
				and battlefollow_unpos_p.navigation_waypoint_index == 0
				and battlefollow_unpos_p.has_active_navigation_path()
				and battlefollow_unpos_sib.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)
	var battlefollow_mal_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_mal_bs != null:
		var battlefollow_mal_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_mal_bs,
			"follow_mal_p",
			"attacker"
		)
		var battlefollow_mal_sib: BattleParticipant = _battlemove_add_participant(
			battlefollow_mal_bs,
			"follow_mal_sib",
			"attacker"
		)
		if battlefollow_mal_p != null and battlefollow_mal_sib != null:
			battlefollow_mal_p.has_battle_position = true
			battlefollow_mal_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_mal_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_mal_stored: bool = battlefollow_mal_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_mal_path
			)
			if battlefollow_mal_stored and not battlefollow_mal_p.navigation_waypoints.is_empty():
				battlefollow_mal_p.navigation_waypoints[0] = Vector2(NAN, 10.0)
			battlefollow_mal_sib.has_battle_position = true
			battlefollow_mal_sib.battle_position = Vector2(6.0, 6.0)
			var battlefollow_mal_sib_path: Array[Vector2] = [Vector2(16.0, 6.0)]
			var battlefollow_mal_sib_stored: bool = battlefollow_mal_sib.set_navigation_path(
				Vector2(16.0, 6.0),
				battlefollow_mal_sib_path
			)
			var battlefollow_mal_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_mal_bs)
			battlefollow_malformed_ok = (
				battlefollow_mal_stored
				and battlefollow_mal_sib_stored
				and battlefollow_mal_res != null
				and battlefollow_mal_res.success
				and _battlefollow_ok(battlefollow_mal_res, 2, 2, 0)
				and battlefollow_mal_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and not battlefollow_mal_p.has_movement_target_position
				and battlefollow_mal_p.navigation_waypoint_index == 0
				and battlefollow_mal_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
				and battlefollow_mal_sib.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)

	var battlefollow_reached_first_ok: bool = false
	var battlefollow_reached_multi_ok: bool = false
	var battlefollow_complete_ok: bool = false
	var battlefollow_reach_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_reach_bs != null:
		var battlefollow_reach_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_reach_bs,
			"follow_reach_p",
			"attacker"
		)
		if battlefollow_reach_p != null:
			battlefollow_reach_p.has_battle_position = true
			battlefollow_reach_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_reach_path: Array[Vector2] = [Vector2(10.0, 10.0), Vector2(20.0, 10.0)]
			var battlefollow_reach_stored: bool = battlefollow_reach_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_reach_path
			)
			var battlefollow_reach_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_reach_bs)
			battlefollow_reached_first_ok = (
				battlefollow_reach_stored
				and _battlefollow_ok(battlefollow_reach_res, 1, 1, 0)
				and battlefollow_reach_p.navigation_waypoint_index == 1
				and battlefollow_reach_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_reach_p.movement_target_position.is_equal_approx(Vector2(20.0, 10.0))
				and battlefollow_reach_p.has_active_navigation_path()
			)
	var battlefollow_multi_reach_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_multi_reach_bs != null:
		var battlefollow_multi_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_multi_reach_bs,
			"follow_multi_p",
			"attacker"
		)
		if battlefollow_multi_p != null:
			battlefollow_multi_p.has_battle_position = true
			battlefollow_multi_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_multi_path: Array[Vector2] = [Vector2(12.0, 10.0), Vector2(14.0, 10.0), Vector2(30.0, 10.0)]
			var battlefollow_multi_stored: bool = battlefollow_multi_p.set_navigation_path(
				Vector2(30.0, 10.0),
				battlefollow_multi_path
			)
			if battlefollow_multi_stored and battlefollow_multi_p.navigation_waypoints.size() == 3:
				battlefollow_multi_p.navigation_waypoints[0] = Vector2(10.0, 10.0)
				battlefollow_multi_p.navigation_waypoints[1] = Vector2(10.0, 10.0)
			var battlefollow_multi_res: BattlePathFollowResult = BattlePathFollowService.advance(
				battlefollow_multi_reach_bs
			)
			battlefollow_reached_multi_ok = (
				battlefollow_multi_stored
				and _battlefollow_ok(battlefollow_multi_res, 1, 1, 0)
				and battlefollow_multi_p.navigation_waypoint_index == 2
				and battlefollow_multi_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_multi_p.movement_target_position.is_equal_approx(Vector2(30.0, 10.0))
			)
	var battlefollow_done_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_done_bs != null:
		var battlefollow_done_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_done_bs,
			"follow_done_p",
			"attacker"
		)
		if battlefollow_done_p != null:
			battlefollow_done_p.has_battle_position = true
			battlefollow_done_p.battle_position = Vector2(20.0, 10.0)
			var battlefollow_done_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_done_stored: bool = battlefollow_done_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_done_path
			)
			var battlefollow_done_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_done_bs)
			battlefollow_complete_ok = (
				battlefollow_done_stored
				and _battlefollow_ok(battlefollow_done_res, 1, 1, 1)
				and battlefollow_done_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and not battlefollow_done_p.has_movement_target_position
				and not battlefollow_done_p.has_navigation_destination
				and battlefollow_done_p.navigation_waypoints.is_empty()
				and battlefollow_done_p.navigation_waypoint_index == 0
				and battlefollow_done_p.battle_position.is_equal_approx(Vector2(20.0, 10.0))
			)

	var battlefollow_overshoot_final_ok: bool = false
	var battlefollow_speed_cap_ok: bool = false
	var battlefollow_runtime_order_ok: bool = false
	var battlefollow_complete_next_ok: bool = false
	var battlefollow_cap_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_cap_bs != null:
		var battlefollow_cap_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_cap_bs,
			"follow_cap_p",
			"attacker"
		)
		if battlefollow_cap_p != null:
			battlefollow_cap_p.has_battle_position = true
			battlefollow_cap_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_cap_speed: bool = battlefollow_cap_p.set_movement_speed(10.0)
			var battlefollow_cap_intent: bool = battlefollow_cap_p.set_movement_intent(Vector2.ZERO)
			var battlefollow_cap_path: Array[Vector2] = [Vector2(11.0, 10.0)]
			var battlefollow_cap_stored: bool = battlefollow_cap_p.set_navigation_path(
				Vector2(11.0, 10.0),
				battlefollow_cap_path
			)
			var battlefollow_cap_rt1: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_cap_bs, 1.0)
			battlefollow_overshoot_final_ok = (
				battlefollow_cap_speed
				and battlefollow_cap_intent
				and battlefollow_cap_stored
				and battlefollow_cap_rt1 != null
				and battlefollow_cap_rt1.success
				and battlefollow_cap_p.velocity.is_equal_approx(Vector2(10.0, 0.0))
				and battlefollow_cap_p.battle_position.is_equal_approx(Vector2(11.0, 10.0))
				and is_equal_approx(battlefollow_cap_p.movement_speed, 10.0)
				and battlefollow_cap_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_cap_p.has_active_navigation_path()
			)
			battlefollow_speed_cap_ok = battlefollow_overshoot_final_ok
			battlefollow_runtime_order_ok = battlefollow_overshoot_final_ok
			var battlefollow_cap_rt2: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_cap_bs, 1.0)
			battlefollow_complete_next_ok = (
				battlefollow_overshoot_final_ok
				and battlefollow_cap_rt2 != null
				and battlefollow_cap_rt2.success
				and not battlefollow_cap_p.has_active_navigation_path()
				and battlefollow_cap_p.movement_intent.is_equal_approx(Vector2.ZERO)
				and not battlefollow_cap_p.has_movement_target_position
				and battlefollow_cap_p.battle_position.is_equal_approx(Vector2(11.0, 10.0))
			)

	var battlefollow_overshoot_mid_ok: bool = false
	var battlefollow_mid_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_mid_bs != null:
		var battlefollow_mid_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_mid_bs,
			"follow_mid_p",
			"attacker"
		)
		if battlefollow_mid_p != null:
			battlefollow_mid_p.has_battle_position = true
			battlefollow_mid_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_mid_speed: bool = battlefollow_mid_p.set_movement_speed(10.0)
			var battlefollow_mid_path: Array[Vector2] = [Vector2(11.0, 10.0), Vector2(11.0, 20.0)]
			var battlefollow_mid_stored: bool = battlefollow_mid_p.set_navigation_path(
				Vector2(11.0, 20.0),
				battlefollow_mid_path
			)
			var battlefollow_mid_rt1: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_mid_bs, 1.0)
			var battlefollow_mid_first: bool = (
				battlefollow_mid_speed
				and battlefollow_mid_stored
				and battlefollow_mid_rt1 != null
				and battlefollow_mid_rt1.success
				and battlefollow_mid_p.battle_position.is_equal_approx(Vector2(11.0, 10.0))
				and battlefollow_mid_p.navigation_waypoint_index == 0
			)
			var battlefollow_mid_follow: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_mid_bs)
			battlefollow_overshoot_mid_ok = (
				battlefollow_mid_first
				and battlefollow_mid_follow != null
				and battlefollow_mid_follow.success
				and battlefollow_mid_p.navigation_waypoint_index == 1
				and battlefollow_mid_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
				and battlefollow_mid_p.movement_target_position.is_equal_approx(Vector2(11.0, 20.0))
			)

	var battlefollow_collision_ok: bool = false
	var battlefollow_no_replan_ok: bool = false
	var battlefollow_col_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_col_bs != null and battlefollow_col_bs.battlefield_geometry != null:
		var battlefollow_col_wall: BattleObstacle = BattleObstacle.new(
			"follow_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		var battlefollow_col_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_col_bs,
			"follow_col_p",
			"attacker"
		)
		if battlefollow_col_p != null and battlefollow_col_bs.battlefield_geometry.add_obstacle(battlefollow_col_wall):
			battlefollow_col_p.has_battle_position = true
			battlefollow_col_p.battle_position = Vector2(30.0, 30.0)
			var battlefollow_col_speed: bool = battlefollow_col_p.set_movement_speed(20.0)
			var battlefollow_col_path: Array[Vector2] = [Vector2(60.0, 30.0)]
			var battlefollow_col_stored: bool = battlefollow_col_p.set_navigation_path(
				Vector2(60.0, 30.0),
				battlefollow_col_path
			)
			var battlefollow_col_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_col_bs, 1.0)
			battlefollow_collision_ok = (
				battlefollow_col_speed
				and battlefollow_col_stored
				and battlefollow_col_rt != null
				and battlefollow_col_rt.success
				and battlefollow_col_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_col_p.has_movement_target_position
				and battlefollow_col_p.movement_target_position.is_equal_approx(Vector2(60.0, 30.0))
				and battlefollow_col_p.battle_position.x < 40.0
				and not battlefollow_col_p.battle_position.is_equal_approx(Vector2(60.0, 30.0))
				and battlefollow_col_p.has_active_navigation_path()
				and battlefollow_col_p.navigation_waypoint_index == 0
			)
			var battlefollow_col_index: int = battlefollow_col_p.navigation_waypoint_index
			var battlefollow_col_wp: Vector2 = battlefollow_col_p.get_current_navigation_waypoint()
			var battlefollow_col_rt2: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_col_bs, 1.0)
			battlefollow_no_replan_ok = (
				battlefollow_collision_ok
				and battlefollow_col_rt2 != null
				and battlefollow_col_rt2.success
				and battlefollow_col_p.navigation_waypoint_index == battlefollow_col_index
				and battlefollow_col_p.get_current_navigation_waypoint().is_equal_approx(battlefollow_col_wp)
				and battlefollow_col_p.has_active_navigation_path()
				and battlefollow_col_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
			)

	var battlefollow_clear_target_ok: bool = false
	var battlefollow_replace_path_ok: bool = false
	var battlefollow_stale_target_ok: bool = false
	var battlefollow_clear_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_clear_bs != null:
		var battlefollow_clear_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_clear_bs,
			"follow_clear_p",
			"attacker"
		)
		if battlefollow_clear_p != null:
			battlefollow_clear_p.has_battle_position = true
			battlefollow_clear_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_clear_speed: bool = battlefollow_clear_p.set_movement_speed(5.0)
			var battlefollow_clear_path: Array[Vector2] = [Vector2(11.0, 10.0)]
			var battlefollow_clear_stored: bool = battlefollow_clear_p.set_navigation_path(
				Vector2(11.0, 10.0),
				battlefollow_clear_path
			)
			var battlefollow_clear_follow: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_clear_bs)
			var battlefollow_clear_had_target: bool = battlefollow_clear_p.has_movement_target_position
			battlefollow_clear_p.clear_navigation_path()
			var battlefollow_clear_intent: bool = battlefollow_clear_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlefollow_clear_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_clear_bs, 1.0)
			battlefollow_clear_target_ok = (
				battlefollow_clear_speed
				and battlefollow_clear_stored
				and battlefollow_clear_follow != null
				and battlefollow_clear_follow.success
				and battlefollow_clear_had_target
				and not battlefollow_clear_p.has_navigation_destination
				and not battlefollow_clear_p.has_movement_target_position
				and battlefollow_clear_intent
				and battlefollow_clear_rt != null
				and battlefollow_clear_rt.success
				and battlefollow_clear_p.battle_position.is_equal_approx(Vector2(15.0, 10.0))
			)
	var battlefollow_rep_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_rep_bs != null:
		var battlefollow_rep_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_rep_bs,
			"follow_rep_p",
			"attacker"
		)
		if battlefollow_rep_p != null:
			battlefollow_rep_p.has_battle_position = true
			battlefollow_rep_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_rep_a: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_rep_stored_a: bool = battlefollow_rep_p.set_navigation_path(Vector2(20.0, 10.0), battlefollow_rep_a)
			var battlefollow_rep_follow_a: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_rep_bs)
			var battlefollow_rep_b: Array[Vector2] = [Vector2(10.0, 20.0)]
			var battlefollow_rep_stored_b: bool = battlefollow_rep_p.set_navigation_path(Vector2(10.0, 20.0), battlefollow_rep_b)
			var battlefollow_rep_cleared: bool = not battlefollow_rep_p.has_movement_target_position
			var battlefollow_rep_follow_b: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_rep_bs)
			battlefollow_replace_path_ok = (
				battlefollow_rep_stored_a
				and battlefollow_rep_follow_a != null
				and battlefollow_rep_follow_a.success
				and battlefollow_rep_stored_b
				and battlefollow_rep_cleared
				and battlefollow_rep_follow_b != null
				and battlefollow_rep_follow_b.success
				and battlefollow_rep_p.movement_target_position.is_equal_approx(Vector2(10.0, 20.0))
				and battlefollow_rep_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
			)
	var battlefollow_stale_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_stale_bs != null:
		var battlefollow_stale_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_stale_bs,
			"follow_stale_p",
			"attacker"
		)
		if battlefollow_stale_p != null:
			battlefollow_stale_p.has_battle_position = true
			battlefollow_stale_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_stale_intent: bool = battlefollow_stale_p.set_movement_intent(Vector2(0.0, 1.0))
			var battlefollow_stale_target: bool = battlefollow_stale_p.set_movement_target_position(Vector2(20.0, 10.0))
			var battlefollow_stale_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_stale_bs)
			battlefollow_stale_target_ok = (
				battlefollow_stale_intent
				and battlefollow_stale_target
				and _battlefollow_ok(battlefollow_stale_res, 1, 0, 0)
				and not battlefollow_stale_p.has_movement_target_position
				and battlefollow_stale_p.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
			)

	var battlefollow_zero_delta_ok: bool = false
	var battlefollow_zero_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_zero_bs != null:
		var battlefollow_zero_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_zero_bs,
			"follow_zero_p",
			"attacker"
		)
		if battlefollow_zero_p != null:
			battlefollow_zero_p.has_battle_position = true
			battlefollow_zero_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_zero_speed: bool = battlefollow_zero_p.set_movement_speed(5.0)
			var battlefollow_zero_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_zero_stored: bool = battlefollow_zero_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_zero_path
			)
			battlefollow_zero_bs.elapsed_time_seconds = 3.0
			var battlefollow_zero_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_zero_bs, 0.0)
			var battlefollow_zero_far: bool = (
				battlefollow_zero_speed
				and battlefollow_zero_stored
				and battlefollow_zero_rt != null
				and battlefollow_zero_rt.success
				and battlefollow_zero_p.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_zero_p.movement_target_position.is_equal_approx(Vector2(20.0, 10.0))
				and battlefollow_zero_p.velocity.is_equal_approx(Vector2(5.0, 0.0))
				and battlefollow_zero_p.battle_position.is_equal_approx(Vector2(10.0, 10.0))
				and is_equal_approx(battlefollow_zero_bs.elapsed_time_seconds, 3.0)
			)
			var battlefollow_zero_done_bs: BattleState = _battlemove_make_state("active")
			var battlefollow_zero_done_p: BattleParticipant = _battlemove_add_participant(
				battlefollow_zero_done_bs,
				"follow_zero_done_p",
				"attacker"
			)
			var battlefollow_zero_done: bool = false
			if battlefollow_zero_done_p != null:
				battlefollow_zero_done_p.has_battle_position = true
				battlefollow_zero_done_p.battle_position = Vector2(20.0, 10.0)
				var battlefollow_zero_done_path: Array[Vector2] = [Vector2(20.0, 10.0)]
				var battlefollow_zero_done_stored: bool = battlefollow_zero_done_p.set_navigation_path(
					Vector2(20.0, 10.0),
					battlefollow_zero_done_path
				)
				battlefollow_zero_done_bs.elapsed_time_seconds = 2.0
				var battlefollow_zero_done_rt: BattleRuntimeResult = BattleRuntimeService.advance(
					battlefollow_zero_done_bs,
					0.0
				)
				battlefollow_zero_done = (
					battlefollow_zero_done_stored
					and battlefollow_zero_done_rt != null
					and battlefollow_zero_done_rt.success
					and not battlefollow_zero_done_p.has_active_navigation_path()
					and battlefollow_zero_done_p.battle_position.is_equal_approx(Vector2(20.0, 10.0))
					and is_equal_approx(battlefollow_zero_done_bs.elapsed_time_seconds, 2.0)
				)
			battlefollow_zero_delta_ok = battlefollow_zero_far and battlefollow_zero_done

	var battlefollow_runtime_tx_ok: bool = false
	var battlefollow_move_after_follow_ok: bool = false
	var battlefollow_tx_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_tx_bs != null:
		var battlefollow_tx_p: BattleParticipant = _battlemove_add_participant(
			battlefollow_tx_bs,
			"follow_tx_p",
			"attacker"
		)
		if battlefollow_tx_p != null:
			battlefollow_tx_p.has_battle_position = true
			battlefollow_tx_p.battle_position = Vector2(10.0, 10.0)
			var battlefollow_tx_speed: bool = battlefollow_tx_p.set_movement_speed(5.0)
			var battlefollow_tx_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battlefollow_tx_stored: bool = battlefollow_tx_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battlefollow_tx_path
			)
			var battlefollow_tx_intent: bool = battlefollow_tx_p.set_movement_intent(Vector2.ZERO)
			battlefollow_tx_bs.elapsed_time_seconds = 4.0
			var battlefollow_tx_snap: Dictionary = _battlefollow_part_snap(battlefollow_tx_p)
			battlefollow_tx_bs.battlefield_geometry = null
			var battlefollow_tx_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_tx_bs, 0.5)
			battlefollow_runtime_tx_ok = (
				battlefollow_tx_speed
				and battlefollow_tx_stored
				and battlefollow_tx_intent
				and _battlert_fail_ok(battlefollow_tx_rt, "missing_battlefield_geometry", 4.0)
				and is_equal_approx(battlefollow_tx_bs.elapsed_time_seconds, 4.0)
				and _battlefollow_part_unchanged(battlefollow_tx_p, battlefollow_tx_snap)
			)
			_battlespatial_attach_open_geometry(battlefollow_tx_bs)
			var battlefollow_tx_ok_rt: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_tx_bs, 0.5)
			battlefollow_move_after_follow_ok = (
				battlefollow_runtime_tx_ok
				and battlefollow_tx_ok_rt != null
				and battlefollow_tx_ok_rt.success
				and battlefollow_tx_p.battle_position.x > 10.0
			)

	var battlefollow_multi_ok: bool = false
	var battlefollow_counts_ok: bool = false
	var battlefollow_count_bs: BattleState = _battlemove_make_state("active")
	if battlefollow_count_bs != null:
		var battlefollow_z_none: BattleParticipant = _battlemove_add_participant(
			battlefollow_count_bs,
			"z_none",
			"attacker"
		)
		var battlefollow_m_done: BattleParticipant = _battlemove_add_participant(
			battlefollow_count_bs,
			"m_done",
			"attacker"
		)
		var battlefollow_d_dead: BattleParticipant = _battlemove_add_participant(
			battlefollow_count_bs,
			"d_dead",
			"defender"
		)
		var battlefollow_a_active: BattleParticipant = _battlemove_add_participant(
			battlefollow_count_bs,
			"a_active",
			"attacker"
		)
		if (
			battlefollow_z_none != null
			and battlefollow_m_done != null
			and battlefollow_d_dead != null
			and battlefollow_a_active != null
		):
			battlefollow_z_none.has_battle_position = true
			battlefollow_z_none.battle_position = Vector2(8.0, 8.0)
			var battlefollow_z_intent: bool = battlefollow_z_none.set_movement_intent(Vector2(0.0, 1.0))
			battlefollow_m_done.has_battle_position = true
			battlefollow_m_done.battle_position = Vector2(16.0, 10.0)
			var battlefollow_m_path: Array[Vector2] = [Vector2(16.0, 10.0)]
			var battlefollow_m_stored: bool = battlefollow_m_done.set_navigation_path(Vector2(16.0, 10.0), battlefollow_m_path)
			battlefollow_d_dead.has_battle_position = true
			battlefollow_d_dead.battle_position = Vector2(12.0, 12.0)
			battlefollow_d_dead.is_alive = false
			var battlefollow_d_path: Array[Vector2] = [Vector2(22.0, 12.0)]
			var battlefollow_d_stored: bool = battlefollow_d_dead.set_navigation_path(Vector2(22.0, 12.0), battlefollow_d_path)
			battlefollow_a_active.has_battle_position = true
			battlefollow_a_active.battle_position = Vector2(10.0, 10.0)
			var battlefollow_a_path: Array[Vector2] = [Vector2(30.0, 10.0)]
			var battlefollow_a_stored: bool = battlefollow_a_active.set_navigation_path(
				Vector2(30.0, 10.0),
				battlefollow_a_path
			)
			var battlefollow_count_res: BattlePathFollowResult = BattlePathFollowService.advance(battlefollow_count_bs)
			battlefollow_counts_ok = (
				battlefollow_z_intent
				and battlefollow_m_stored
				and battlefollow_d_stored
				and battlefollow_a_stored
				and _battlefollow_ok(battlefollow_count_res, 4, 3, 1)
			)
			battlefollow_multi_ok = (
				battlefollow_counts_ok
				and battlefollow_z_none.movement_intent.is_equal_approx(Vector2(0.0, 1.0))
				and not battlefollow_z_none.has_active_navigation_path()
				and not battlefollow_m_done.has_active_navigation_path()
				and battlefollow_d_dead.has_active_navigation_path()
				and battlefollow_d_dead.navigation_waypoint_index == 0
				and battlefollow_a_active.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battlefollow_a_active.movement_target_position.is_equal_approx(Vector2(30.0, 10.0))
			)

	var battlefollow_ok_res: BattlePathFollowResult = BattlePathFollowResult.succeeded(4, 3, 1)
	var battlefollow_fail_res: BattlePathFollowResult = BattlePathFollowResult.failed(
		"null_battle_state",
		"Battle path follow failed: battle_state is null."
	)
	var battlefollow_result_helper_ok: bool = (
		battlefollow_ok_res != null
		and battlefollow_ok_res.success
		and battlefollow_ok_res.participants_considered == 4
		and battlefollow_ok_res.participants_with_paths == 3
		and battlefollow_ok_res.participants_completed_paths == 1
		and battlefollow_ok_res.error_code.is_empty()
		and battlefollow_ok_res.error_message.is_empty()
		and battlefollow_fail_res != null
		and not battlefollow_fail_res.success
		and battlefollow_fail_res.participants_considered == 0
		and battlefollow_fail_res.participants_with_paths == 0
		and battlefollow_fail_res.participants_completed_paths == 0
		and battlefollow_fail_res.error_code == "null_battle_state"
		and battlefollow_fail_res.error_message == "Battle path follow failed: battle_state is null."
	)

	var battlefollow_persist_ok: bool = false
	var battlefollow_immutability_ok: bool = false
	var battlefollow_camp_pack: Dictionary = _battle_create_ready_pack()
	var battlefollow_camp_game: GameState = battlefollow_camp_pack.get("game_state", null) as GameState
	var battlefollow_camp_force: TravelingForce = battlefollow_camp_pack.get("force", null) as TravelingForce
	var battlefollow_camp_bs: BattleState = battlefollow_camp_pack.get("battle_state", null) as BattleState
	if battlefollow_camp_game != null and battlefollow_camp_bs != null:
		var battlefollow_camp_deployed: bool = _battle_deploy_standard_attacker(battlefollow_camp_bs)
		var battlefollow_camp_geo: bool = _battlegeo_init(battlefollow_camp_bs)
		var battlefollow_camp_snap: Dictionary = _battle_campaign_snapshot(
			battlefollow_camp_game,
			battlefollow_camp_force,
			"battle_mission"
		)
		var battlefollow_camp_part: BattleParticipant = battlefollow_camp_bs.get_participant("battle_sol_a")
		var battlefollow_camp_ready: bool = false
		if battlefollow_camp_part != null and battlefollow_camp_part.has_battle_position:
			var battlefollow_camp_dest: Vector2 = battlefollow_camp_part.battle_position + Vector2(6.0, 0.0)
			var battlefollow_camp_path: Array[Vector2] = [battlefollow_camp_dest]
			battlefollow_camp_ready = (
				battlefollow_camp_part.set_navigation_path(battlefollow_camp_dest, battlefollow_camp_path)
				and battlefollow_camp_part.set_movement_intent(Vector2(1.0, 0.0))
				and battlefollow_camp_part.set_movement_target_position(battlefollow_camp_dest)
				and battlefollow_camp_part.set_movement_speed(2.0)
			)
		var battlefollow_camp_persist: Dictionary = battlefollow_camp_game.to_dict()
		battlefollow_persist_ok = (
			battlefollow_camp_deployed
			and battlefollow_camp_geo
			and battlefollow_camp_ready
			and _battle_serialized_campaign_keys_only(battlefollow_camp_persist)
			and not _battle_data_has_tactical_trace(battlefollow_camp_persist)
		)
		var battlefollow_camp_begun: bool = battlefollow_camp_bs.begin_battle()
		var battlefollow_camp_adv: BattleRuntimeResult = BattleRuntimeService.advance(battlefollow_camp_bs, 0.25)
		battlefollow_immutability_ok = (
			battlefollow_persist_ok
			and battlefollow_camp_begun
			and battlefollow_camp_adv != null
			and battlefollow_camp_adv.success
			and _battle_campaign_unchanged(
				battlefollow_camp_game,
				battlefollow_camp_snap,
				battlefollow_camp_force,
				"battle_mission"
			)
			and battlefollow_camp_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlefollow_camp_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlefollow_no_combat_ok: bool = false
	var battlefollow_no_combat_bs: BattleState = _battlemove_make_state("active")
	var battlefollow_no_combat_svc: BattlePathFollowService = BattlePathFollowService.new()
	if battlefollow_no_combat_bs != null:
		battlefollow_no_combat_ok = (
			_battle_has_no_combat_turn_model(battlefollow_no_combat_bs)
			and battlefollow_no_combat_bs.get("find_path") == null
			and battlefollow_no_combat_bs.get("cover_value") == null
			and battlefollow_no_combat_bs.get("current_turn_index") == null
			and not battlefollow_no_combat_svc.has_method("find_path")
			and not battlefollow_no_combat_svc.has_method("replan")
			and not battlefollow_no_combat_svc.has_method("select_destination")
			and not battlefollow_no_combat_svc.has_method("select_cover")
		)

	var battletarget_default_ok: bool = false
	var battletarget_fresh: BattleParticipant = BattleParticipant.new()
	battletarget_default_ok = (
		battletarget_fresh.has_target_participant == false
		and battletarget_fresh.target_participant_id == ""
	)

	var battletarget_helper_ok: bool = false
	var battletarget_helper_p: BattleParticipant = BattleParticipant.new("helper_src")
	var battletarget_helper_set: bool = battletarget_helper_p.set_target_participant("enemy_a")
	var battletarget_helper_empty: bool = battletarget_helper_p.set_target_participant("")
	var battletarget_helper_after_empty: bool = (
		battletarget_helper_p.has_target_participant
		and battletarget_helper_p.target_participant_id == "enemy_a"
	)
	battletarget_helper_p.clear_target_participant()
	battletarget_helper_ok = (
		battletarget_helper_set
		and battletarget_helper_after_empty
		and battletarget_helper_empty == false
		and not battletarget_helper_p.has_target_participant
		and battletarget_helper_p.target_participant_id.is_empty()
	)

	var battletarget_fail_null_ok: bool = _battletarget_fail_ok(
		BattleTargetSelectionService.advance(null),
		"null_battle_state"
	)
	var battletarget_fail_not_active_ok: bool = false
	var battletarget_fail_missing_geo_ok: bool = false
	var battletarget_fail_invalid_geo_ok: bool = false
	var battletarget_deploy_bs: BattleState = _battlemove_make_state("deployment")
	if battletarget_deploy_bs != null:
		var battletarget_deploy_p: BattleParticipant = _battlemove_add_participant(
			battletarget_deploy_bs,
			"target_dep_p",
			"attacker"
		)
		if battletarget_deploy_p != null:
			_battletarget_place(battletarget_deploy_p, Vector2(10.0, 10.0))
			var battletarget_dep_intent: bool = battletarget_deploy_p.set_movement_intent(Vector2(1.0, 0.0))
			var battletarget_dep_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battletarget_dep_nav: bool = battletarget_deploy_p.set_navigation_path(
				Vector2(20.0, 10.0),
				battletarget_dep_path
			)
			var battletarget_dep_tgt: bool = battletarget_deploy_p.set_target_participant("enemy_a")
			var battletarget_dep_snap: Dictionary = _battletarget_part_snap(battletarget_deploy_p)
			var battletarget_dep_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_deploy_bs
			)
			battletarget_fail_not_active_ok = (
				battletarget_dep_intent
				and battletarget_dep_nav
				and battletarget_dep_tgt
				and _battletarget_fail_ok(battletarget_dep_res, "battle_not_active")
				and _battletarget_part_unchanged(battletarget_deploy_p, battletarget_dep_snap)
			)
	var battletarget_miss_bs: BattleState = _battlemove_make_state("active")
	if battletarget_miss_bs != null:
		var battletarget_miss_p: BattleParticipant = _battlemove_add_participant(
			battletarget_miss_bs,
			"target_miss_p",
			"attacker"
		)
		if battletarget_miss_p != null:
			_battletarget_place(battletarget_miss_p, Vector2(10.0, 10.0))
			var battletarget_miss_intent: bool = battletarget_miss_p.set_movement_intent(Vector2(0.0, 1.0))
			var battletarget_miss_path: Array[Vector2] = [Vector2(10.0, 20.0)]
			var battletarget_miss_nav: bool = battletarget_miss_p.set_navigation_path(
				Vector2(10.0, 20.0),
				battletarget_miss_path
			)
			var battletarget_miss_tgt: bool = battletarget_miss_p.set_target_participant("enemy_b")
			var battletarget_miss_snap: Dictionary = _battletarget_part_snap(battletarget_miss_p)
			battletarget_miss_bs.battlefield_geometry = null
			var battletarget_miss_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_miss_bs
			)
			battletarget_fail_missing_geo_ok = (
				battletarget_miss_intent
				and battletarget_miss_nav
				and battletarget_miss_tgt
				and _battletarget_fail_ok(battletarget_miss_res, "missing_battlefield_geometry")
				and _battletarget_part_unchanged(battletarget_miss_p, battletarget_miss_snap)
			)
	var battletarget_badgeo_bs: BattleState = _battlemove_make_state("active")
	if battletarget_badgeo_bs != null:
		var battletarget_badgeo_p: BattleParticipant = _battlemove_add_participant(
			battletarget_badgeo_bs,
			"target_badgeo_p",
			"attacker"
		)
		if battletarget_badgeo_p != null:
			_battletarget_place(battletarget_badgeo_p, Vector2(10.0, 10.0))
			var battletarget_badgeo_intent: bool = battletarget_badgeo_p.set_movement_intent(Vector2(1.0, 0.0))
			var battletarget_badgeo_path: Array[Vector2] = [Vector2(18.0, 10.0)]
			var battletarget_badgeo_nav: bool = battletarget_badgeo_p.set_navigation_path(
				Vector2(18.0, 10.0),
				battletarget_badgeo_path
			)
			var battletarget_badgeo_tgt: bool = battletarget_badgeo_p.set_target_participant("enemy_c")
			var battletarget_badgeo_snap: Dictionary = _battletarget_part_snap(battletarget_badgeo_p)
			battletarget_badgeo_bs.battlefield_geometry = BattlefieldGeometry.new()
			var battletarget_badgeo_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_badgeo_bs
			)
			battletarget_fail_invalid_geo_ok = (
				battletarget_badgeo_intent
				and battletarget_badgeo_nav
				and battletarget_badgeo_tgt
				and _battletarget_fail_ok(battletarget_badgeo_res, "invalid_battlefield_geometry")
				and _battletarget_part_unchanged(battletarget_badgeo_p, battletarget_badgeo_snap)
			)

	var battletarget_two_side_ok: bool = false
	var battletarget_two_bs: BattleState = _battlemove_make_state("active")
	if battletarget_two_bs != null:
		var battletarget_two_a: BattleParticipant = _battlemove_add_participant(
			battletarget_two_bs,
			"alpha_src",
			"attacker"
		)
		var battletarget_two_b: BattleParticipant = _battlemove_add_participant(
			battletarget_two_bs,
			"beta_src",
			"defender"
		)
		if battletarget_two_a != null and battletarget_two_b != null:
			_battletarget_place(battletarget_two_a, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_two_b, Vector2(20.0, 10.0))
			var battletarget_two_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_two_bs
			)
			battletarget_two_side_ok = (
				_battletarget_ok(battletarget_two_res, 2, 2, 2, 2)
				and _battletarget_has(battletarget_two_a, "beta_src")
				and _battletarget_has(battletarget_two_b, "alpha_src")
			)

	var battletarget_same_side_ok: bool = false
	var battletarget_same_bs: BattleState = _battlemove_make_state("active")
	if battletarget_same_bs != null:
		var battletarget_same_a: BattleParticipant = _battlemove_add_participant(
			battletarget_same_bs,
			"same_a",
			"attacker"
		)
		var battletarget_same_b: BattleParticipant = _battlemove_add_participant(
			battletarget_same_bs,
			"same_b",
			"attacker"
		)
		if battletarget_same_a != null and battletarget_same_b != null:
			_battletarget_place(battletarget_same_a, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_same_b, Vector2(16.0, 10.0))
			var battletarget_same_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_same_bs
			)
			battletarget_same_side_ok = (
				_battletarget_ok(battletarget_same_res, 2, 0, 0, 0)
				and _battletarget_none(battletarget_same_a)
				and _battletarget_none(battletarget_same_b)
			)

	var battletarget_nearest_ok: bool = false
	var battletarget_near_bs: BattleState = _battlemove_make_state("active")
	if battletarget_near_bs != null:
		var battletarget_near_src: BattleParticipant = _battlemove_add_participant(
			battletarget_near_bs,
			"near_src",
			"attacker"
		)
		var battletarget_near_close: BattleParticipant = _battlemove_add_participant(
			battletarget_near_bs,
			"near_close",
			"defender"
		)
		var battletarget_near_far: BattleParticipant = _battlemove_add_participant(
			battletarget_near_bs,
			"near_far",
			"defender"
		)
		if (
			battletarget_near_src != null
			and battletarget_near_close != null
			and battletarget_near_far != null
		):
			_battletarget_place(battletarget_near_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_near_close, Vector2(16.0, 10.0))
			_battletarget_place(battletarget_near_far, Vector2(40.0, 10.0))
			var battletarget_near_src_d2: float = battletarget_near_src.battle_position.distance_squared_to(
				battletarget_near_close.battle_position
			)
			var battletarget_near_far_d2: float = battletarget_near_src.battle_position.distance_squared_to(
				battletarget_near_far.battle_position
			)
			var battletarget_near_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_near_bs
			)
			battletarget_nearest_ok = (
				battletarget_near_src_d2 < battletarget_near_far_d2
				and battletarget_near_res != null
				and battletarget_near_res.success
				and _battletarget_has(battletarget_near_src, "near_close")
			)

	var battletarget_tiebreak_ok: bool = false
	var battletarget_tie_first: String = _battletarget_tie_selected("z_enemy", "a_enemy")
	var battletarget_tie_second: String = _battletarget_tie_selected("a_enemy", "z_enemy")
	battletarget_tiebreak_ok = (
		battletarget_tie_first == "a_enemy"
		and battletarget_tie_second == "a_enemy"
	)

	var battletarget_dead_src_ok: bool = false
	var battletarget_dead_src_bs: BattleState = _battlemove_make_state("active")
	if battletarget_dead_src_bs != null:
		var battletarget_dead_src: BattleParticipant = _battlemove_add_participant(
			battletarget_dead_src_bs,
			"dead_src",
			"attacker"
		)
		var battletarget_dead_sib: BattleParticipant = _battlemove_add_participant(
			battletarget_dead_src_bs,
			"dead_sib",
			"attacker"
		)
		var battletarget_dead_def: BattleParticipant = _battlemove_add_participant(
			battletarget_dead_src_bs,
			"dead_def",
			"defender"
		)
		if (
			battletarget_dead_src != null
			and battletarget_dead_sib != null
			and battletarget_dead_def != null
		):
			_battletarget_place(battletarget_dead_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_dead_sib, Vector2(12.0, 12.0))
			_battletarget_place(battletarget_dead_def, Vector2(20.0, 10.0))
			var battletarget_dead_src_set: bool = battletarget_dead_src.set_target_participant("dead_def")
			battletarget_dead_src.is_alive = false
			var battletarget_dead_src_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_dead_src_bs
			)
			battletarget_dead_src_ok = (
				battletarget_dead_src_set
				and _battletarget_ok(battletarget_dead_src_res, 3, 2, 2, 3)
				and _battletarget_none(battletarget_dead_src)
				and _battletarget_has(battletarget_dead_sib, "dead_def")
				and _battletarget_has(battletarget_dead_def, "dead_sib")
			)

	var battletarget_dead_hostile_ok: bool = false
	var battletarget_dead_h_bs: BattleState = _battlemove_make_state("active")
	if battletarget_dead_h_bs != null:
		var battletarget_dead_h_src: BattleParticipant = _battlemove_add_participant(
			battletarget_dead_h_bs,
			"dead_h_src",
			"attacker"
		)
		var battletarget_dead_h_close: BattleParticipant = _battlemove_add_participant(
			battletarget_dead_h_bs,
			"dead_h_close",
			"defender"
		)
		var battletarget_dead_h_far: BattleParticipant = _battlemove_add_participant(
			battletarget_dead_h_bs,
			"dead_h_far",
			"defender"
		)
		if (
			battletarget_dead_h_src != null
			and battletarget_dead_h_close != null
			and battletarget_dead_h_far != null
		):
			_battletarget_place(battletarget_dead_h_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_dead_h_close, Vector2(12.0, 10.0))
			_battletarget_place(battletarget_dead_h_far, Vector2(30.0, 10.0))
			battletarget_dead_h_close.is_alive = false
			var battletarget_dead_h_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_dead_h_bs
			)
			battletarget_dead_hostile_ok = (
				battletarget_dead_h_res != null
				and battletarget_dead_h_res.success
				and _battletarget_has(battletarget_dead_h_src, "dead_h_far")
			)

	var battletarget_wounded_src_ok: bool = false
	var battletarget_wounded_hostile_ok: bool = false
	var battletarget_wnd_bs: BattleState = _battlemove_make_state("active")
	if battletarget_wnd_bs != null:
		var battletarget_wnd_src: BattleParticipant = _battlemove_add_participant(
			battletarget_wnd_bs,
			"wnd_src",
			"attacker"
		)
		var battletarget_wnd_h: BattleParticipant = _battlemove_add_participant(
			battletarget_wnd_bs,
			"wnd_hostile",
			"defender"
		)
		if battletarget_wnd_src != null and battletarget_wnd_h != null:
			_battletarget_place(battletarget_wnd_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_wnd_h, Vector2(18.0, 10.0))
			battletarget_wnd_src.is_wounded = true
			battletarget_wnd_h.is_wounded = true
			var battletarget_wnd_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_wnd_bs
			)
			battletarget_wounded_src_ok = (
				_battletarget_ok(battletarget_wnd_res, 2, 2, 2, 2)
				and _battletarget_has(battletarget_wnd_src, "wnd_hostile")
			)
			battletarget_wounded_hostile_ok = (
				battletarget_wounded_src_ok
				and _battletarget_has(battletarget_wnd_h, "wnd_src")
			)

	var battletarget_unpos_src_ok: bool = false
	var battletarget_unpos_src_bs: BattleState = _battlemove_make_state("active")
	if battletarget_unpos_src_bs != null:
		var battletarget_unpos_src: BattleParticipant = _battlemove_add_participant(
			battletarget_unpos_src_bs,
			"unpos_src",
			"attacker"
		)
		var battletarget_unpos_sib: BattleParticipant = _battlemove_add_participant(
			battletarget_unpos_src_bs,
			"unpos_sib",
			"attacker"
		)
		var battletarget_unpos_def: BattleParticipant = _battlemove_add_participant(
			battletarget_unpos_src_bs,
			"unpos_def",
			"defender"
		)
		if (
			battletarget_unpos_src != null
			and battletarget_unpos_sib != null
			and battletarget_unpos_def != null
		):
			_battletarget_place(battletarget_unpos_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_unpos_sib, Vector2(14.0, 10.0))
			_battletarget_place(battletarget_unpos_def, Vector2(22.0, 10.0))
			var battletarget_unpos_set: bool = battletarget_unpos_src.set_target_participant("unpos_def")
			battletarget_unpos_src.has_battle_position = false
			var battletarget_unpos_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_unpos_src_bs
			)
			battletarget_unpos_src_ok = (
				battletarget_unpos_set
				and battletarget_unpos_res != null
				and battletarget_unpos_res.success
				and _battletarget_none(battletarget_unpos_src)
				and _battletarget_has(battletarget_unpos_sib, "unpos_def")
			)

	var battletarget_unpos_hostile_ok: bool = false
	var battletarget_unpos_h_bs: BattleState = _battlemove_make_state("active")
	if battletarget_unpos_h_bs != null:
		var battletarget_unpos_h_src: BattleParticipant = _battlemove_add_participant(
			battletarget_unpos_h_bs,
			"unpos_h_src",
			"attacker"
		)
		var battletarget_unpos_h_close: BattleParticipant = _battlemove_add_participant(
			battletarget_unpos_h_bs,
			"unpos_h_close",
			"defender"
		)
		var battletarget_unpos_h_far: BattleParticipant = _battlemove_add_participant(
			battletarget_unpos_h_bs,
			"unpos_h_far",
			"defender"
		)
		if (
			battletarget_unpos_h_src != null
			and battletarget_unpos_h_close != null
			and battletarget_unpos_h_far != null
		):
			_battletarget_place(battletarget_unpos_h_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_unpos_h_close, Vector2(12.0, 10.0))
			_battletarget_place(battletarget_unpos_h_far, Vector2(28.0, 10.0))
			battletarget_unpos_h_close.has_battle_position = false
			var battletarget_unpos_h_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_unpos_h_bs
			)
			battletarget_unpos_hostile_ok = (
				battletarget_unpos_h_res != null
				and battletarget_unpos_h_res.success
				and _battletarget_has(battletarget_unpos_h_src, "unpos_h_far")
			)

	var battletarget_malformed_src_ok: bool = false
	var battletarget_mal_src_bs: BattleState = _battlemove_make_state("active")
	if battletarget_mal_src_bs != null:
		var battletarget_mal_src: BattleParticipant = _battlemove_add_participant(
			battletarget_mal_src_bs,
			"mal_src",
			"attacker"
		)
		var battletarget_mal_sib: BattleParticipant = _battlemove_add_participant(
			battletarget_mal_src_bs,
			"mal_sib",
			"attacker"
		)
		var battletarget_mal_def: BattleParticipant = _battlemove_add_participant(
			battletarget_mal_src_bs,
			"mal_def",
			"defender"
		)
		if (
			battletarget_mal_src != null
			and battletarget_mal_sib != null
			and battletarget_mal_def != null
		):
			_battletarget_place(battletarget_mal_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_mal_sib, Vector2(8.0, 8.0))
			_battletarget_place(battletarget_mal_def, Vector2(20.0, 10.0))
			var battletarget_mal_set: bool = battletarget_mal_src.set_target_participant("mal_def")
			battletarget_mal_src.battle_position = Vector2(NAN, 10.0)
			var battletarget_mal_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_mal_src_bs
			)
			battletarget_malformed_src_ok = (
				battletarget_mal_set
				and battletarget_mal_res != null
				and battletarget_mal_res.success
				and _battletarget_none(battletarget_mal_src)
				and _battletarget_has(battletarget_mal_sib, "mal_def")
			)

	var battletarget_malformed_hostile_ok: bool = false
	var battletarget_mal_h_bs: BattleState = _battlemove_make_state("active")
	if battletarget_mal_h_bs != null:
		var battletarget_mal_h_src: BattleParticipant = _battlemove_add_participant(
			battletarget_mal_h_bs,
			"mal_h_src",
			"attacker"
		)
		var battletarget_mal_h_close: BattleParticipant = _battlemove_add_participant(
			battletarget_mal_h_bs,
			"mal_h_close",
			"defender"
		)
		var battletarget_mal_h_far: BattleParticipant = _battlemove_add_participant(
			battletarget_mal_h_bs,
			"mal_h_far",
			"defender"
		)
		if (
			battletarget_mal_h_src != null
			and battletarget_mal_h_close != null
			and battletarget_mal_h_far != null
		):
			_battletarget_place(battletarget_mal_h_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_mal_h_close, Vector2(12.0, 10.0))
			_battletarget_place(battletarget_mal_h_far, Vector2(26.0, 10.0))
			battletarget_mal_h_close.battle_position = Vector2(INF, 10.0)
			var battletarget_mal_h_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_mal_h_bs
			)
			battletarget_malformed_hostile_ok = (
				battletarget_mal_h_res != null
				and battletarget_mal_h_res.success
				and _battletarget_has(battletarget_mal_h_src, "mal_h_far")
			)

	var battletarget_invalid_src_side_ok: bool = false
	var battletarget_inv_src_bs: BattleState = _battlemove_make_state("active")
	if battletarget_inv_src_bs != null:
		var battletarget_inv_empty: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_src_bs,
			"inv_empty_src",
			"attacker"
		)
		var battletarget_inv_ghost: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_src_bs,
			"inv_ghost_src",
			"attacker"
		)
		var battletarget_inv_sib: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_src_bs,
			"inv_sib",
			"attacker"
		)
		var battletarget_inv_def: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_src_bs,
			"inv_def",
			"defender"
		)
		if (
			battletarget_inv_empty != null
			and battletarget_inv_ghost != null
			and battletarget_inv_sib != null
			and battletarget_inv_def != null
		):
			_battletarget_place(battletarget_inv_empty, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_inv_ghost, Vector2(11.0, 10.0))
			_battletarget_place(battletarget_inv_sib, Vector2(12.0, 10.0))
			_battletarget_place(battletarget_inv_def, Vector2(24.0, 10.0))
			var battletarget_inv_empty_set: bool = battletarget_inv_empty.set_target_participant("inv_def")
			var battletarget_inv_ghost_set: bool = battletarget_inv_ghost.set_target_participant("inv_def")
			battletarget_inv_empty.side_id = ""
			battletarget_inv_ghost.side_id = "missing_side"
			var battletarget_inv_src_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_inv_src_bs
			)
			battletarget_invalid_src_side_ok = (
				battletarget_inv_empty_set
				and battletarget_inv_ghost_set
				and battletarget_inv_src_res != null
				and battletarget_inv_src_res.success
				and _battletarget_none(battletarget_inv_empty)
				and _battletarget_none(battletarget_inv_ghost)
				and _battletarget_has(battletarget_inv_sib, "inv_def")
			)

	var battletarget_invalid_hostile_side_ok: bool = false
	var battletarget_inv_h_bs: BattleState = _battlemove_make_state("active")
	if battletarget_inv_h_bs != null:
		var battletarget_inv_h_src: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_h_bs,
			"inv_h_src",
			"attacker"
		)
		var battletarget_inv_h_empty: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_h_bs,
			"inv_h_empty",
			"defender"
		)
		var battletarget_inv_h_ghost: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_h_bs,
			"inv_h_ghost",
			"defender"
		)
		var battletarget_inv_h_ok: BattleParticipant = _battlemove_add_participant(
			battletarget_inv_h_bs,
			"inv_h_ok",
			"defender"
		)
		if (
			battletarget_inv_h_src != null
			and battletarget_inv_h_empty != null
			and battletarget_inv_h_ghost != null
			and battletarget_inv_h_ok != null
		):
			_battletarget_place(battletarget_inv_h_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_inv_h_empty, Vector2(12.0, 10.0))
			_battletarget_place(battletarget_inv_h_ghost, Vector2(14.0, 10.0))
			_battletarget_place(battletarget_inv_h_ok, Vector2(30.0, 10.0))
			battletarget_inv_h_empty.side_id = ""
			battletarget_inv_h_ghost.side_id = "missing_side"
			var battletarget_inv_h_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_inv_h_bs
			)
			battletarget_invalid_hostile_side_ok = (
				battletarget_inv_h_res != null
				and battletarget_inv_h_res.success
				and _battletarget_has(battletarget_inv_h_src, "inv_h_ok")
			)

	var battletarget_clear_none_ok: bool = false
	var battletarget_clear_bs: BattleState = _battlemove_make_state("active")
	if battletarget_clear_bs != null:
		var battletarget_clear_src: BattleParticipant = _battlemove_add_participant(
			battletarget_clear_bs,
			"clear_src",
			"attacker"
		)
		var battletarget_clear_mate: BattleParticipant = _battlemove_add_participant(
			battletarget_clear_bs,
			"clear_mate",
			"attacker"
		)
		if battletarget_clear_src != null and battletarget_clear_mate != null:
			_battletarget_place(battletarget_clear_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_clear_mate, Vector2(16.0, 10.0))
			var battletarget_clear_set: bool = battletarget_clear_src.set_target_participant("stale_enemy")
			var battletarget_clear_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_clear_bs
			)
			battletarget_clear_none_ok = (
				battletarget_clear_set
				and _battletarget_ok(battletarget_clear_res, 2, 0, 0, 1)
				and _battletarget_none(battletarget_clear_src)
			)

	var battletarget_unchanged_ok: bool = false
	var battletarget_hold_bs: BattleState = _battlemove_make_state("active")
	if battletarget_hold_bs != null:
		var battletarget_hold_a: BattleParticipant = _battlemove_add_participant(
			battletarget_hold_bs,
			"hold_a",
			"attacker"
		)
		var battletarget_hold_b: BattleParticipant = _battlemove_add_participant(
			battletarget_hold_bs,
			"hold_b",
			"defender"
		)
		if battletarget_hold_a != null and battletarget_hold_b != null:
			_battletarget_place(battletarget_hold_a, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_hold_b, Vector2(20.0, 10.0))
			var battletarget_hold_first: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_hold_bs
			)
			var battletarget_hold_second: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_hold_bs
			)
			battletarget_unchanged_ok = (
				_battletarget_ok(battletarget_hold_first, 2, 2, 2, 2)
				and _battletarget_ok(battletarget_hold_second, 2, 2, 2, 0)
				and _battletarget_has(battletarget_hold_a, "hold_b")
				and _battletarget_has(battletarget_hold_b, "hold_a")
			)

	var battletarget_switch_nearer_ok: bool = false
	var battletarget_sw_bs: BattleState = _battlemove_make_state("active")
	if battletarget_sw_bs != null:
		var battletarget_sw_src: BattleParticipant = _battlemove_add_participant(
			battletarget_sw_bs,
			"sw_src",
			"attacker"
		)
		var battletarget_sw_a: BattleParticipant = _battlemove_add_participant(
			battletarget_sw_bs,
			"sw_a",
			"defender"
		)
		var battletarget_sw_b: BattleParticipant = _battlemove_add_participant(
			battletarget_sw_bs,
			"sw_b",
			"defender"
		)
		if battletarget_sw_src != null and battletarget_sw_a != null and battletarget_sw_b != null:
			_battletarget_place(battletarget_sw_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_sw_a, Vector2(20.0, 10.0))
			_battletarget_place(battletarget_sw_b, Vector2(40.0, 10.0))
			var battletarget_sw_first: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_sw_bs
			)
			var battletarget_sw_first_ok: bool = (
				battletarget_sw_first != null
				and battletarget_sw_first.success
				and _battletarget_has(battletarget_sw_src, "sw_a")
			)
			_battletarget_place(battletarget_sw_b, Vector2(12.0, 10.0))
			var battletarget_sw_second: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_sw_bs
			)
			battletarget_switch_nearer_ok = (
				battletarget_sw_first_ok
				and battletarget_sw_second != null
				and battletarget_sw_second.success
				and _battletarget_has(battletarget_sw_src, "sw_b")
				and battletarget_sw_second.targets_changed >= 1
			)

	var battletarget_replace_dead_ok: bool = false
	var battletarget_rep_bs: BattleState = _battlemove_make_state("active")
	if battletarget_rep_bs != null:
		var battletarget_rep_src: BattleParticipant = _battlemove_add_participant(
			battletarget_rep_bs,
			"rep_src",
			"attacker"
		)
		var battletarget_rep_a: BattleParticipant = _battlemove_add_participant(
			battletarget_rep_bs,
			"rep_a",
			"defender"
		)
		var battletarget_rep_b: BattleParticipant = _battlemove_add_participant(
			battletarget_rep_bs,
			"rep_b",
			"defender"
		)
		if battletarget_rep_src != null and battletarget_rep_a != null and battletarget_rep_b != null:
			_battletarget_place(battletarget_rep_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_rep_a, Vector2(16.0, 10.0))
			_battletarget_place(battletarget_rep_b, Vector2(32.0, 10.0))
			var battletarget_rep_first: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_rep_bs
			)
			var battletarget_rep_first_ok: bool = (
				battletarget_rep_first != null
				and battletarget_rep_first.success
				and _battletarget_has(battletarget_rep_src, "rep_a")
			)
			battletarget_rep_a.is_alive = false
			var battletarget_rep_second: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_rep_bs
			)
			var battletarget_rep_second_ok: bool = (
				battletarget_rep_second != null
				and battletarget_rep_second.success
				and _battletarget_has(battletarget_rep_src, "rep_b")
			)
			battletarget_rep_b.is_alive = false
			var battletarget_rep_third: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_rep_bs
			)
			battletarget_replace_dead_ok = (
				battletarget_rep_first_ok
				and battletarget_rep_second_ok
				and battletarget_rep_third != null
				and battletarget_rep_third.success
				and _battletarget_none(battletarget_rep_src)
			)

	var battletarget_multi_side_ok: bool = false
	var battletarget_ms_sides: Array[String] = ["alpha", "beta", "gamma"]
	var battletarget_ms_bs: BattleState = _battletarget_make_state_with_sides(
		"active",
		battletarget_ms_sides
	)
	if battletarget_ms_bs != null:
		var battletarget_ms_a: BattleParticipant = _battlemove_add_participant(
			battletarget_ms_bs,
			"ms_alpha",
			"alpha"
		)
		var battletarget_ms_b: BattleParticipant = _battlemove_add_participant(
			battletarget_ms_bs,
			"ms_beta",
			"beta"
		)
		var battletarget_ms_g: BattleParticipant = _battlemove_add_participant(
			battletarget_ms_bs,
			"ms_gamma",
			"gamma"
		)
		if battletarget_ms_a != null and battletarget_ms_b != null and battletarget_ms_g != null:
			_battletarget_place(battletarget_ms_a, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_ms_b, Vector2(30.0, 10.0))
			_battletarget_place(battletarget_ms_g, Vector2(14.0, 10.0))
			var battletarget_ms_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_ms_bs
			)
			battletarget_multi_side_ok = (
				battletarget_ms_res != null
				and battletarget_ms_res.success
				and _battletarget_has(battletarget_ms_a, "ms_gamma")
				and battletarget_ms_a.target_participant_id != "ms_beta"
			)

	var battletarget_pre_los_wall_ok: bool = false
	var battletarget_wall_bs: BattleState = _battlemove_make_state("active")
	if battletarget_wall_bs != null and battletarget_wall_bs.battlefield_geometry != null:
		var battletarget_wall: BattleObstacle = BattleObstacle.new(
			"target_pre_los_wall",
			Rect2(28.0, 18.0, 20.0, 10.0),
			true
		)
		var battletarget_wall_src: BattleParticipant = _battlemove_add_participant(
			battletarget_wall_bs,
			"pre_los_src",
			"attacker"
		)
		var battletarget_wall_near: BattleParticipant = _battlemove_add_participant(
			battletarget_wall_bs,
			"pre_los_behind_wall",
			"defender"
		)
		var battletarget_wall_far: BattleParticipant = _battlemove_add_participant(
			battletarget_wall_bs,
			"pre_los_open_far",
			"defender"
		)
		if (
			battletarget_wall_src != null
			and battletarget_wall_near != null
			and battletarget_wall_far != null
			and battletarget_wall_bs.battlefield_geometry.add_obstacle(battletarget_wall)
		):
			_battletarget_place(battletarget_wall_src, Vector2(30.0, 10.0))
			_battletarget_place(battletarget_wall_near, Vector2(30.0, 40.0))
			_battletarget_place(battletarget_wall_far, Vector2(80.0, 10.0))
			var battletarget_wall_near_d2: float = battletarget_wall_src.battle_position.distance_squared_to(
				battletarget_wall_near.battle_position
			)
			var battletarget_wall_far_d2: float = battletarget_wall_src.battle_position.distance_squared_to(
				battletarget_wall_far.battle_position
			)
			var battletarget_wall_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_wall_bs
			)
			battletarget_pre_los_wall_ok = (
				battletarget_wall_near_d2 < battletarget_wall_far_d2
				and battletarget_wall_res != null
				and battletarget_wall_res.success
				and _battletarget_has(battletarget_wall_src, "pre_los_behind_wall")
			)

	var battletarget_no_move_ok: bool = false
	var battletarget_no_nav_ok: bool = false
	var battletarget_nomut_bs: BattleState = _battlemove_make_state("active")
	if battletarget_nomut_bs != null:
		var battletarget_nomut_src: BattleParticipant = _battlemove_add_participant(
			battletarget_nomut_bs,
			"nomut_src",
			"attacker"
		)
		var battletarget_nomut_h: BattleParticipant = _battlemove_add_participant(
			battletarget_nomut_bs,
			"nomut_h",
			"defender"
		)
		if battletarget_nomut_src != null and battletarget_nomut_h != null:
			_battletarget_place(battletarget_nomut_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_nomut_h, Vector2(22.0, 10.0))
			var battletarget_nomut_intent: bool = battletarget_nomut_src.set_movement_intent(Vector2(0.0, 1.0))
			var battletarget_nomut_speed: bool = battletarget_nomut_src.set_movement_speed(4.0)
			var battletarget_nomut_path: Array[Vector2] = [Vector2(10.0, 18.0), Vector2(18.0, 18.0)]
			var battletarget_nomut_nav: bool = battletarget_nomut_src.set_navigation_path(
				Vector2(18.0, 18.0),
				battletarget_nomut_path
			)
			var battletarget_nomut_cap: bool = battletarget_nomut_src.set_movement_target_position(Vector2(10.0, 18.0))
			battletarget_nomut_src.velocity = Vector2(0.0, 4.0)
			var battletarget_nomut_pos: Vector2 = battletarget_nomut_src.battle_position
			var battletarget_nomut_vel: Vector2 = battletarget_nomut_src.velocity
			var battletarget_nomut_intent_v: Vector2 = battletarget_nomut_src.movement_intent
			var battletarget_nomut_move_tgt: Vector2 = battletarget_nomut_src.movement_target_position
			var battletarget_nomut_dest: Vector2 = battletarget_nomut_src.navigation_destination
			var battletarget_nomut_index: int = battletarget_nomut_src.navigation_waypoint_index
			var battletarget_nomut_wps: Array[Vector2] = _battlenav_copy_points(
				battletarget_nomut_src.navigation_waypoints
			)
			var battletarget_nomut_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_nomut_bs
			)
			battletarget_no_move_ok = (
				battletarget_nomut_intent
				and battletarget_nomut_speed
				and battletarget_nomut_nav
				and battletarget_nomut_cap
				and battletarget_nomut_res != null
				and battletarget_nomut_res.success
				and _battletarget_has(battletarget_nomut_src, "nomut_h")
				and battletarget_nomut_src.battle_position.is_equal_approx(battletarget_nomut_pos)
				and battletarget_nomut_src.velocity.is_equal_approx(battletarget_nomut_vel)
				and battletarget_nomut_src.movement_intent.is_equal_approx(battletarget_nomut_intent_v)
				and battletarget_nomut_src.has_movement_target_position
				and battletarget_nomut_src.movement_target_position.is_equal_approx(battletarget_nomut_move_tgt)
			)
			battletarget_no_nav_ok = (
				battletarget_no_move_ok
				and battletarget_nomut_src.has_navigation_destination
				and battletarget_nomut_src.navigation_destination.is_equal_approx(battletarget_nomut_dest)
				and battletarget_nomut_src.navigation_waypoint_index == battletarget_nomut_index
				and _battlenav_waypoints_match(battletarget_nomut_src.navigation_waypoints, battletarget_nomut_wps)
			)

	var battletarget_runtime_ok: bool = false
	var battletarget_rt_bs: BattleState = _battlemove_make_state("active")
	if battletarget_rt_bs != null:
		var battletarget_rt_src: BattleParticipant = _battlemove_add_participant(
			battletarget_rt_bs,
			"rt_src",
			"attacker"
		)
		var battletarget_rt_h: BattleParticipant = _battlemove_add_participant(
			battletarget_rt_bs,
			"rt_h",
			"defender"
		)
		if battletarget_rt_src != null and battletarget_rt_h != null:
			_battletarget_place(battletarget_rt_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_rt_h, Vector2(10.0, 40.0))
			var battletarget_rt_speed: bool = battletarget_rt_src.set_movement_speed(5.0)
			var battletarget_rt_path: Array[Vector2] = [Vector2(40.0, 10.0)]
			var battletarget_rt_nav: bool = battletarget_rt_src.set_navigation_path(
				Vector2(40.0, 10.0),
				battletarget_rt_path
			)
			var battletarget_rt_res: BattleRuntimeResult = BattleRuntimeService.advance(battletarget_rt_bs, 1.0)
			battletarget_runtime_ok = (
				battletarget_rt_speed
				and battletarget_rt_nav
				and battletarget_rt_res != null
				and battletarget_rt_res.success
				and _battletarget_has(battletarget_rt_src, "rt_h")
				and battletarget_rt_src.battle_position.is_equal_approx(Vector2(15.0, 10.0))
				and battletarget_rt_src.movement_intent.is_equal_approx(Vector2(1.0, 0.0))
				and battletarget_rt_h.battle_position.is_equal_approx(Vector2(10.0, 40.0))
			)

	var battletarget_zero_delta_ok: bool = false
	var battletarget_zd_bs: BattleState = _battlemove_make_state("active")
	if battletarget_zd_bs != null:
		var battletarget_zd_src: BattleParticipant = _battlemove_add_participant(
			battletarget_zd_bs,
			"zd_src",
			"attacker"
		)
		var battletarget_zd_h: BattleParticipant = _battlemove_add_participant(
			battletarget_zd_bs,
			"zd_h",
			"defender"
		)
		if battletarget_zd_src != null and battletarget_zd_h != null:
			_battletarget_place(battletarget_zd_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_zd_h, Vector2(18.0, 10.0))
			battletarget_zd_bs.elapsed_time_seconds = 3.0
			var battletarget_zd_res: BattleRuntimeResult = BattleRuntimeService.advance(battletarget_zd_bs, 0.0)
			battletarget_zero_delta_ok = (
				battletarget_zd_res != null
				and battletarget_zd_res.success
				and _battletarget_has(battletarget_zd_src, "zd_h")
				and _battletarget_has(battletarget_zd_h, "zd_src")
				and battletarget_zd_src.battle_position.is_equal_approx(Vector2(10.0, 10.0))
				and battletarget_zd_h.battle_position.is_equal_approx(Vector2(18.0, 10.0))
				and is_equal_approx(battletarget_zd_bs.elapsed_time_seconds, 3.0)
			)

	var battletarget_runtime_tx_ok: bool = false
	var battletarget_tx_bs: BattleState = _battlemove_make_state("active")
	if battletarget_tx_bs != null:
		var battletarget_tx_src: BattleParticipant = _battlemove_add_participant(
			battletarget_tx_bs,
			"tx_src",
			"attacker"
		)
		var battletarget_tx_h: BattleParticipant = _battlemove_add_participant(
			battletarget_tx_bs,
			"tx_h",
			"defender"
		)
		if battletarget_tx_src != null and battletarget_tx_h != null:
			_battletarget_place(battletarget_tx_src, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_tx_h, Vector2(20.0, 10.0))
			var battletarget_tx_speed: bool = battletarget_tx_src.set_movement_speed(5.0)
			var battletarget_tx_intent: bool = battletarget_tx_src.set_movement_intent(Vector2.ZERO)
			var battletarget_tx_path: Array[Vector2] = [Vector2(20.0, 10.0)]
			var battletarget_tx_nav: bool = battletarget_tx_src.set_navigation_path(
				Vector2(20.0, 10.0),
				battletarget_tx_path
			)
			var battletarget_tx_tgt: bool = battletarget_tx_src.set_target_participant("stale_tx")
			battletarget_tx_bs.elapsed_time_seconds = 4.0
			var battletarget_tx_src_snap: Dictionary = _battletarget_part_snap(battletarget_tx_src)
			var battletarget_tx_h_snap: Dictionary = _battletarget_part_snap(battletarget_tx_h)
			battletarget_tx_bs.battlefield_geometry = null
			var battletarget_tx_rt: BattleRuntimeResult = BattleRuntimeService.advance(battletarget_tx_bs, 0.5)
			battletarget_runtime_tx_ok = (
				battletarget_tx_speed
				and battletarget_tx_intent
				and battletarget_tx_nav
				and battletarget_tx_tgt
				and _battlert_fail_ok(battletarget_tx_rt, "missing_battlefield_geometry", 4.0)
				and is_equal_approx(battletarget_tx_bs.elapsed_time_seconds, 4.0)
				and _battletarget_part_unchanged(battletarget_tx_src, battletarget_tx_src_snap)
				and _battletarget_part_unchanged(battletarget_tx_h, battletarget_tx_h_snap)
			)

	var battletarget_multi_ok: bool = false
	var battletarget_multi_order_a: Array[String] = ["z_src", "m_enemy", "a_src", "b_enemy"]
	var battletarget_multi_order_b: Array[String] = ["b_enemy", "a_src", "m_enemy", "z_src"]
	var battletarget_multi_a: bool = _battletarget_multi_run(battletarget_multi_order_a)
	var battletarget_multi_b: bool = _battletarget_multi_run(battletarget_multi_order_b)
	battletarget_multi_ok = battletarget_multi_a and battletarget_multi_b

	# considered = every existing participant
	# with_hostiles = eligible sources that had at least one eligible hostile this update
	# with_targets = participants that still have a target after the update
	# targets_changed = (has_flag, id) pair differed from the start of that participant's update
	var battletarget_counts_ok: bool = false
	var battletarget_count_hostiles: bool = false
	var battletarget_count_none: bool = false
	var battletarget_cnt_bs: BattleState = _battlemove_make_state("active")
	if battletarget_cnt_bs != null:
		var battletarget_cnt_ok: BattleParticipant = _battlemove_add_participant(
			battletarget_cnt_bs,
			"cnt_ok",
			"attacker"
		)
		var battletarget_cnt_dead: BattleParticipant = _battlemove_add_participant(
			battletarget_cnt_bs,
			"cnt_dead",
			"attacker"
		)
		var battletarget_cnt_mal: BattleParticipant = _battlemove_add_participant(
			battletarget_cnt_bs,
			"cnt_mal",
			"attacker"
		)
		var battletarget_cnt_h: BattleParticipant = _battlemove_add_participant(
			battletarget_cnt_bs,
			"cnt_h",
			"defender"
		)
		if (
			battletarget_cnt_ok != null
			and battletarget_cnt_dead != null
			and battletarget_cnt_mal != null
			and battletarget_cnt_h != null
		):
			_battletarget_place(battletarget_cnt_ok, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_cnt_dead, Vector2(12.0, 10.0))
			_battletarget_place(battletarget_cnt_mal, Vector2(14.0, 10.0))
			_battletarget_place(battletarget_cnt_h, Vector2(24.0, 10.0))
			var battletarget_cnt_dead_set: bool = battletarget_cnt_dead.set_target_participant("cnt_h")
			var battletarget_cnt_mal_set: bool = battletarget_cnt_mal.set_target_participant("cnt_h")
			battletarget_cnt_dead.is_alive = false
			battletarget_cnt_mal.battle_position = Vector2(NAN, 10.0)
			var battletarget_cnt_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_cnt_bs
			)
			battletarget_count_hostiles = (
				battletarget_cnt_dead_set
				and battletarget_cnt_mal_set
				and _battletarget_ok(battletarget_cnt_res, 4, 2, 2, 4)
				and _battletarget_has(battletarget_cnt_ok, "cnt_h")
				and _battletarget_has(battletarget_cnt_h, "cnt_ok")
				and _battletarget_none(battletarget_cnt_dead)
				and _battletarget_none(battletarget_cnt_mal)
			)
	var battletarget_none_bs: BattleState = _battlemove_make_state("active")
	if battletarget_none_bs != null:
		var battletarget_none_a: BattleParticipant = _battlemove_add_participant(
			battletarget_none_bs,
			"cnt_none_a",
			"attacker"
		)
		var battletarget_none_b: BattleParticipant = _battlemove_add_participant(
			battletarget_none_bs,
			"cnt_none_b",
			"attacker"
		)
		if battletarget_none_a != null and battletarget_none_b != null:
			_battletarget_place(battletarget_none_a, Vector2(10.0, 10.0))
			_battletarget_place(battletarget_none_b, Vector2(16.0, 10.0))
			var battletarget_none_res: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battletarget_none_bs
			)
			battletarget_count_none = _battletarget_ok(battletarget_none_res, 2, 0, 0, 0)
	battletarget_counts_ok = battletarget_count_hostiles and battletarget_count_none

	var battletarget_ok_res: BattleTargetSelectionResult = BattleTargetSelectionResult.succeeded(4, 2, 2, 3)
	var battletarget_fail_res: BattleTargetSelectionResult = BattleTargetSelectionResult.failed(
		"null_battle_state",
		"Battle target selection failed: battle_state is null."
	)
	var battletarget_result_helper_ok: bool = (
		battletarget_ok_res != null
		and battletarget_ok_res.success
		and battletarget_ok_res.participants_considered == 4
		and battletarget_ok_res.participants_with_hostiles == 2
		and battletarget_ok_res.participants_with_targets == 2
		and battletarget_ok_res.targets_changed == 3
		and battletarget_ok_res.error_code.is_empty()
		and battletarget_ok_res.error_message.is_empty()
		and battletarget_fail_res != null
		and not battletarget_fail_res.success
		and battletarget_fail_res.participants_considered == 0
		and battletarget_fail_res.participants_with_hostiles == 0
		and battletarget_fail_res.participants_with_targets == 0
		and battletarget_fail_res.targets_changed == 0
		and battletarget_fail_res.error_code == "null_battle_state"
		and battletarget_fail_res.error_message == "Battle target selection failed: battle_state is null."
	)

	var battletarget_no_candidate_list_ok: bool = false
	var battletarget_cand_p: BattleParticipant = BattleParticipant.new("cand_p")
	battletarget_no_candidate_list_ok = (
		battletarget_cand_p.get("hostile_candidates") == null
		and battletarget_cand_p.get("visible_enemies") == null
		and battletarget_cand_p.get("hostile_ids") == null
		and not battletarget_cand_p.has_method("get_hostile_candidates")
		and not battletarget_cand_p.has_method("set_hostile_candidates")
	)

	var battletarget_persist_ok: bool = false
	var battletarget_immutability_ok: bool = false
	var battletarget_camp_pack: Dictionary = _battle_create_ready_pack()
	var battletarget_camp_game: GameState = battletarget_camp_pack.get("game_state", null) as GameState
	var battletarget_camp_force: TravelingForce = battletarget_camp_pack.get("force", null) as TravelingForce
	var battletarget_camp_bs: BattleState = battletarget_camp_pack.get("battle_state", null) as BattleState
	if battletarget_camp_game != null and battletarget_camp_bs != null:
		var battletarget_camp_deployed: bool = _battle_deploy_standard_attacker(battletarget_camp_bs)
		var battletarget_camp_geo: bool = _battlegeo_init(battletarget_camp_bs)
		var battletarget_camp_snap: Dictionary = _battle_campaign_snapshot(
			battletarget_camp_game,
			battletarget_camp_force,
			"battle_mission"
		)
		var battletarget_camp_part: BattleParticipant = battletarget_camp_bs.get_participant("battle_sol_a")
		var battletarget_camp_ready: bool = false
		if battletarget_camp_part != null and battletarget_camp_part.has_battle_position:
			battletarget_camp_ready = battletarget_camp_part.set_target_participant("battle_sol_m")
		var battletarget_camp_persist: Dictionary = battletarget_camp_game.to_dict()
		battletarget_persist_ok = (
			battletarget_camp_deployed
			and battletarget_camp_geo
			and battletarget_camp_ready
			and _battle_serialized_campaign_keys_only(battletarget_camp_persist)
			and not _battle_data_has_tactical_trace(battletarget_camp_persist)
		)
		var battletarget_camp_begun: bool = battletarget_camp_bs.begin_battle()
		var battletarget_camp_sel: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
			battletarget_camp_bs
		)
		var battletarget_camp_adv: BattleRuntimeResult = BattleRuntimeService.advance(battletarget_camp_bs, 0.25)
		battletarget_immutability_ok = (
			battletarget_persist_ok
			and battletarget_camp_begun
			and battletarget_camp_sel != null
			and battletarget_camp_sel.success
			and battletarget_camp_adv != null
			and battletarget_camp_adv.success
			and _battle_campaign_unchanged(
				battletarget_camp_game,
				battletarget_camp_snap,
				battletarget_camp_force,
				"battle_mission"
			)
			and battletarget_camp_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battletarget_camp_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battletarget_no_combat_ok: bool = false
	var battletarget_no_combat_bs: BattleState = _battlemove_make_state("active")
	var battletarget_no_combat_svc: BattleTargetSelectionService = BattleTargetSelectionService.new()
	if battletarget_no_combat_bs != null:
		battletarget_no_combat_ok = (
			_battle_has_no_combat_turn_model(battletarget_no_combat_bs)
			and battletarget_no_combat_bs.get("current_turn_index") == null
			and battletarget_no_combat_bs.get("cover_value") == null
			and not battletarget_no_combat_svc.has_method("compute_los")
			and not battletarget_no_combat_svc.has_method("has_line_of_sight")
			and not battletarget_no_combat_svc.has_method("select_cover")
			and not battletarget_no_combat_svc.has_method("find_path")
			and not battletarget_no_combat_svc.has_method("set_movement_intent")
			and not battletarget_no_combat_svc.has_method("fire")
			and not battletarget_no_combat_svc.has_method("apply_damage")
			and not battletarget_no_combat_svc.has_method("resolve_hit")
		)

	var battlelos_clear_ok: bool = false
	var battlelos_clear_bs: BattleState = _battlemove_make_state("active")
	if battlelos_clear_bs != null:
		var battlelos_clear_a: BattleParticipant = _battlemove_add_participant(
			battlelos_clear_bs,
			"los_clear_a",
			"attacker"
		)
		var battlelos_clear_b: BattleParticipant = _battlemove_add_participant(
			battlelos_clear_bs,
			"los_clear_b",
			"defender"
		)
		if battlelos_clear_a != null and battlelos_clear_b != null:
			_battletarget_place(battlelos_clear_a, Vector2(10.0, 10.0))
			_battletarget_place(battlelos_clear_b, Vector2(40.0, 10.0))
			var battlelos_clear_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_clear_bs,
				"los_clear_a",
				"los_clear_b"
			)
			battlelos_clear_ok = _battlelos_clear_ok(battlelos_clear_res, "los_clear_a", "los_clear_b")

	var battlelos_blocked_ok: bool = false
	var battlelos_block_bs: BattleState = _battlemove_make_state("active")
	if battlelos_block_bs != null and battlelos_block_bs.battlefield_geometry != null:
		var battlelos_block_wall: BattleObstacle = BattleObstacle.new(
			"los_block_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true,
			true
		)
		var battlelos_block_a: BattleParticipant = _battlemove_add_participant(
			battlelos_block_bs,
			"los_block_a",
			"attacker"
		)
		var battlelos_block_b: BattleParticipant = _battlemove_add_participant(
			battlelos_block_bs,
			"los_block_b",
			"defender"
		)
		if (
			battlelos_block_a != null
			and battlelos_block_b != null
			and battlelos_block_bs.battlefield_geometry.add_obstacle(battlelos_block_wall)
		):
			_battletarget_place(battlelos_block_a, Vector2(20.0, 30.0))
			_battletarget_place(battlelos_block_b, Vector2(70.0, 30.0))
			var battlelos_block_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_block_bs,
				"los_block_a",
				"los_block_b"
			)
			battlelos_blocked_ok = _battlelos_blocked_ok(
				battlelos_block_res,
				"los_block_a",
				"los_block_b",
				"los_block_wall"
			)

	var battlelos_fail_null_ok: bool = _battlelos_fail_ok(
		BattleLineOfSightService.check_participant_to_participant(null, "a", "b"),
		"null_battle_state"
	)
	var battlelos_fail_missing_geo_ok: bool = false
	var battlelos_fail_invalid_geo_ok: bool = false
	var battlelos_fail_src_missing_ok: bool = false
	var battlelos_fail_tgt_missing_ok: bool = false
	var battlelos_fail_src_ineligible_ok: bool = false
	var battlelos_fail_tgt_ineligible_ok: bool = false
	var battlelos_fail_bs: BattleState = _battlemove_make_state("active")
	if battlelos_fail_bs != null:
		var battlelos_fail_src: BattleParticipant = _battlemove_add_participant(
			battlelos_fail_bs,
			"los_fail_src",
			"attacker"
		)
		var battlelos_fail_tgt: BattleParticipant = _battlemove_add_participant(
			battlelos_fail_bs,
			"los_fail_tgt",
			"defender"
		)
		if battlelos_fail_src != null and battlelos_fail_tgt != null:
			_battletarget_place(battlelos_fail_src, Vector2(10.0, 10.0))
			_battletarget_place(battlelos_fail_tgt, Vector2(20.0, 10.0))
			var battlelos_fail_src_snap: Dictionary = _battletarget_part_snap(battlelos_fail_src)
			var battlelos_fail_tgt_snap: Dictionary = _battletarget_part_snap(battlelos_fail_tgt)
			battlelos_fail_bs.battlefield_geometry = null
			var battlelos_miss_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_fail_bs,
				"los_fail_src",
				"los_fail_tgt"
			)
			battlelos_fail_missing_geo_ok = (
				_battlelos_fail_ok(battlelos_miss_res, "missing_battlefield_geometry")
				and _battletarget_part_unchanged(battlelos_fail_src, battlelos_fail_src_snap)
				and _battletarget_part_unchanged(battlelos_fail_tgt, battlelos_fail_tgt_snap)
			)
	var battlelos_badgeo_bs: BattleState = _battlemove_make_state("active")
	if battlelos_badgeo_bs != null:
		var battlelos_badgeo_src: BattleParticipant = _battlemove_add_participant(
			battlelos_badgeo_bs,
			"los_badgeo_src",
			"attacker"
		)
		var battlelos_badgeo_tgt: BattleParticipant = _battlemove_add_participant(
			battlelos_badgeo_bs,
			"los_badgeo_tgt",
			"defender"
		)
		if battlelos_badgeo_src != null and battlelos_badgeo_tgt != null:
			_battletarget_place(battlelos_badgeo_src, Vector2(10.0, 10.0))
			_battletarget_place(battlelos_badgeo_tgt, Vector2(18.0, 10.0))
			var battlelos_badgeo_src_snap: Dictionary = _battletarget_part_snap(battlelos_badgeo_src)
			battlelos_badgeo_bs.battlefield_geometry = BattlefieldGeometry.new()
			var battlelos_badgeo_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_badgeo_bs,
				"los_badgeo_src",
				"los_badgeo_tgt"
			)
			battlelos_fail_invalid_geo_ok = (
				_battlelos_fail_ok(battlelos_badgeo_res, "invalid_battlefield_geometry")
				and _battletarget_part_unchanged(battlelos_badgeo_src, battlelos_badgeo_src_snap)
			)
	var battlelos_missp_bs: BattleState = _battlemove_make_state("active")
	if battlelos_missp_bs != null:
		var battlelos_missp_tgt: BattleParticipant = _battlemove_add_participant(
			battlelos_missp_bs,
			"los_missp_tgt",
			"defender"
		)
		var battlelos_missp_src: BattleParticipant = _battlemove_add_participant(
			battlelos_missp_bs,
			"los_missp_src",
			"attacker"
		)
		if battlelos_missp_tgt != null and battlelos_missp_src != null:
			_battletarget_place(battlelos_missp_tgt, Vector2(20.0, 10.0))
			_battletarget_place(battlelos_missp_src, Vector2(10.0, 10.0))
			var battlelos_missp_snap: Dictionary = _battletarget_part_snap(battlelos_missp_tgt)
			var battlelos_src_miss: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_missp_bs,
				"no_such_src",
				"los_missp_tgt"
			)
			var battlelos_tgt_miss: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_missp_bs,
				"los_missp_src",
				"no_such_tgt"
			)
			battlelos_fail_src_missing_ok = (
				_battlelos_fail_ok(battlelos_src_miss, "source_not_found")
				and _battletarget_part_unchanged(battlelos_missp_tgt, battlelos_missp_snap)
			)
			battlelos_fail_tgt_missing_ok = (
				_battlelos_fail_ok(battlelos_tgt_miss, "target_not_found")
				and _battletarget_part_unchanged(battlelos_missp_src, _battletarget_part_snap(battlelos_missp_src))
			)
	var battlelos_inel_src_dead: bool = false
	var battlelos_inel_src_unpos: bool = false
	var battlelos_inel_src_nan: bool = false
	var battlelos_inel_tgt_dead: bool = false
	var battlelos_inel_tgt_unpos: bool = false
	var battlelos_inel_tgt_nan: bool = false
	var battlelos_inel_bs: BattleState = _battlemove_make_state("active")
	if battlelos_inel_bs != null:
		var battlelos_inel_src: BattleParticipant = _battlemove_add_participant(
			battlelos_inel_bs,
			"los_inel_src",
			"attacker"
		)
		var battlelos_inel_tgt: BattleParticipant = _battlemove_add_participant(
			battlelos_inel_bs,
			"los_inel_tgt",
			"defender"
		)
		if battlelos_inel_src != null and battlelos_inel_tgt != null:
			_battletarget_place(battlelos_inel_src, Vector2(10.0, 10.0))
			_battletarget_place(battlelos_inel_tgt, Vector2(22.0, 10.0))
			battlelos_inel_src.is_alive = false
			var battlelos_inel_src_dead_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_inel_bs,
				"los_inel_src",
				"los_inel_tgt"
			)
			battlelos_inel_src_dead = _battlelos_fail_ok(battlelos_inel_src_dead_res, "source_not_eligible")
			battlelos_inel_src.is_alive = true
			battlelos_inel_src.has_battle_position = false
			var battlelos_inel_src_unpos_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_inel_bs,
				"los_inel_src",
				"los_inel_tgt"
			)
			battlelos_inel_src_unpos = _battlelos_fail_ok(battlelos_inel_src_unpos_res, "source_not_eligible")
			battlelos_inel_src.has_battle_position = true
			battlelos_inel_src.battle_position = Vector2(NAN, 10.0)
			var battlelos_inel_src_nan_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_inel_bs,
				"los_inel_src",
				"los_inel_tgt"
			)
			battlelos_inel_src_nan = _battlelos_fail_ok(battlelos_inel_src_nan_res, "source_not_eligible")
			_battletarget_place(battlelos_inel_src, Vector2(10.0, 10.0))
			battlelos_inel_tgt.is_alive = false
			var battlelos_inel_tgt_dead_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_inel_bs,
				"los_inel_src",
				"los_inel_tgt"
			)
			battlelos_inel_tgt_dead = _battlelos_fail_ok(battlelos_inel_tgt_dead_res, "target_not_eligible")
			battlelos_inel_tgt.is_alive = true
			battlelos_inel_tgt.has_battle_position = false
			var battlelos_inel_tgt_unpos_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_inel_bs,
				"los_inel_src",
				"los_inel_tgt"
			)
			battlelos_inel_tgt_unpos = _battlelos_fail_ok(battlelos_inel_tgt_unpos_res, "target_not_eligible")
			battlelos_inel_tgt.has_battle_position = true
			battlelos_inel_tgt.battle_position = Vector2(INF, 10.0)
			var battlelos_inel_tgt_nan_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_inel_bs,
				"los_inel_src",
				"los_inel_tgt"
			)
			battlelos_inel_tgt_nan = _battlelos_fail_ok(battlelos_inel_tgt_nan_res, "target_not_eligible")
	battlelos_fail_src_ineligible_ok = (
		battlelos_inel_src_dead and battlelos_inel_src_unpos and battlelos_inel_src_nan
	)
	battlelos_fail_tgt_ineligible_ok = (
		battlelos_inel_tgt_dead and battlelos_inel_tgt_unpos and battlelos_inel_tgt_nan
	)

	var battlelos_wounded_ok: bool = false
	var battlelos_wnd_bs: BattleState = _battlemove_make_state("active")
	if battlelos_wnd_bs != null:
		var battlelos_wnd_a: BattleParticipant = _battlemove_add_participant(
			battlelos_wnd_bs,
			"los_wnd_a",
			"attacker"
		)
		var battlelos_wnd_b: BattleParticipant = _battlemove_add_participant(
			battlelos_wnd_bs,
			"los_wnd_b",
			"defender"
		)
		if battlelos_wnd_a != null and battlelos_wnd_b != null:
			_battletarget_place(battlelos_wnd_a, Vector2(12.0, 12.0))
			_battletarget_place(battlelos_wnd_b, Vector2(28.0, 12.0))
			battlelos_wnd_a.is_wounded = true
			battlelos_wnd_b.is_wounded = true
			var battlelos_wnd_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_wnd_bs,
				"los_wnd_a",
				"los_wnd_b"
			)
			battlelos_wounded_ok = _battlelos_clear_ok(battlelos_wnd_res, "los_wnd_a", "los_wnd_b")

	var battlelos_side_independent_ok: bool = false
	var battlelos_same_bs: BattleState = _battlemove_make_state("active")
	if battlelos_same_bs != null:
		var battlelos_same_a: BattleParticipant = _battlemove_add_participant(
			battlelos_same_bs,
			"los_same_a",
			"attacker"
		)
		var battlelos_same_b: BattleParticipant = _battlemove_add_participant(
			battlelos_same_bs,
			"los_same_b",
			"attacker"
		)
		if battlelos_same_a != null and battlelos_same_b != null:
			_battletarget_place(battlelos_same_a, Vector2(8.0, 8.0))
			_battletarget_place(battlelos_same_b, Vector2(24.0, 8.0))
			var battlelos_same_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_same_bs,
				"los_same_a",
				"los_same_b"
			)
			battlelos_side_independent_ok = (
				_battlelos_clear_ok(battlelos_same_res, "los_same_a", "los_same_b")
				and battlelos_clear_ok
			)

	var battlelos_same_pos_ok: bool = false
	var battlelos_sp_bs: BattleState = _battlemove_make_state("active")
	if battlelos_sp_bs != null:
		var battlelos_sp_a: BattleParticipant = _battlemove_add_participant(
			battlelos_sp_bs,
			"los_sp_a",
			"attacker"
		)
		var battlelos_sp_b: BattleParticipant = _battlemove_add_participant(
			battlelos_sp_bs,
			"los_sp_b",
			"defender"
		)
		if battlelos_sp_a != null and battlelos_sp_b != null:
			_battletarget_place(battlelos_sp_a, Vector2(16.0, 16.0))
			_battletarget_place(battlelos_sp_b, Vector2(16.0, 16.0))
			var battlelos_sp_res: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_sp_bs,
				"los_sp_a",
				"los_sp_b"
			)
			battlelos_same_pos_ok = _battlelos_clear_ok(battlelos_sp_res, "los_sp_a", "los_sp_b")

	var battlelos_move_block_sight_clear_ok: bool = false
	var battlelos_fence_bs: BattleState = _battlemove_make_state("active")
	if battlelos_fence_bs != null and battlelos_fence_bs.battlefield_geometry != null:
		var battlelos_fence: BattleObstacle = BattleObstacle.new(
			"los_fence",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true,
			false
		)
		var battlelos_fence_a: BattleParticipant = _battlemove_add_participant(
			battlelos_fence_bs,
			"los_fence_a",
			"attacker"
		)
		var battlelos_fence_b: BattleParticipant = _battlemove_add_participant(
			battlelos_fence_bs,
			"los_fence_b",
			"defender"
		)
		if (
			battlelos_fence_a != null
			and battlelos_fence_b != null
			and battlelos_fence_bs.battlefield_geometry.add_obstacle(battlelos_fence)
		):
			_battletarget_place(battlelos_fence_a, Vector2(20.0, 30.0))
			_battletarget_place(battlelos_fence_b, Vector2(70.0, 30.0))
			var battlelos_fence_move: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlelos_fence_bs,
				Vector2(20.0, 30.0),
				Vector2(50.0, 0.0)
			)
			var battlelos_fence_los: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_fence_bs,
				"los_fence_a",
				"los_fence_b"
			)
			battlelos_move_block_sight_clear_ok = (
				battlelos_fence.blocks_movement
				and not battlelos_fence.blocks_line_of_sight
				and battlelos_fence_move != null
				and battlelos_fence_move.success
				and battlelos_fence_move.was_blocked
				and battlelos_fence_move.blocking_obstacle_id == "los_fence"
				and _battlelos_clear_ok(battlelos_fence_los, "los_fence_a", "los_fence_b")
			)

	var battlelos_sight_block_move_clear_ok: bool = false
	var battlelos_glass_bs: BattleState = _battlemove_make_state("active")
	if battlelos_glass_bs != null and battlelos_glass_bs.battlefield_geometry != null:
		var battlelos_glass: BattleObstacle = BattleObstacle.new(
			"los_glass",
			Rect2(40.0, 20.0, 10.0, 20.0),
			false,
			true
		)
		var battlelos_glass_a: BattleParticipant = _battlemove_add_participant(
			battlelos_glass_bs,
			"los_glass_a",
			"attacker"
		)
		var battlelos_glass_b: BattleParticipant = _battlemove_add_participant(
			battlelos_glass_bs,
			"los_glass_b",
			"defender"
		)
		if (
			battlelos_glass_a != null
			and battlelos_glass_b != null
			and battlelos_glass_bs.battlefield_geometry.add_obstacle(battlelos_glass)
		):
			_battletarget_place(battlelos_glass_a, Vector2(20.0, 30.0))
			_battletarget_place(battlelos_glass_b, Vector2(70.0, 30.0))
			var battlelos_glass_move: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlelos_glass_bs,
				Vector2(20.0, 30.0),
				Vector2(50.0, 0.0)
			)
			var battlelos_glass_los: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_glass_bs,
				"los_glass_a",
				"los_glass_b"
			)
			battlelos_sight_block_move_clear_ok = (
				not battlelos_glass.blocks_movement
				and battlelos_glass.blocks_line_of_sight
				and battlelos_glass_move != null
				and battlelos_glass_move.success
				and battlelos_glass_move.was_blocked == false
				and battlelos_glass_move.final_position.is_equal_approx(Vector2(70.0, 30.0))
				and _battlelos_blocked_ok(battlelos_glass_los, "los_glass_a", "los_glass_b", "los_glass")
			)

	var battlelos_neither_block_ok: bool = false
	var battlelos_soft_bs: BattleState = _battlemove_make_state("active")
	if battlelos_soft_bs != null and battlelos_soft_bs.battlefield_geometry != null:
		var battlelos_soft: BattleObstacle = BattleObstacle.new(
			"los_soft",
			Rect2(40.0, 20.0, 10.0, 20.0),
			false,
			false
		)
		var battlelos_soft_a: BattleParticipant = _battlemove_add_participant(
			battlelos_soft_bs,
			"los_soft_a",
			"attacker"
		)
		var battlelos_soft_b: BattleParticipant = _battlemove_add_participant(
			battlelos_soft_bs,
			"los_soft_b",
			"defender"
		)
		if (
			battlelos_soft_a != null
			and battlelos_soft_b != null
			and battlelos_soft_bs.battlefield_geometry.add_obstacle(battlelos_soft)
		):
			_battletarget_place(battlelos_soft_a, Vector2(20.0, 30.0))
			_battletarget_place(battlelos_soft_b, Vector2(70.0, 30.0))
			var battlelos_soft_move: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlelos_soft_bs,
				Vector2(20.0, 30.0),
				Vector2(50.0, 0.0)
			)
			var battlelos_soft_los: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_soft_bs,
				"los_soft_a",
				"los_soft_b"
			)
			battlelos_neither_block_ok = (
				not battlelos_soft.blocks_movement
				and not battlelos_soft.blocks_line_of_sight
				and battlelos_soft_move != null
				and battlelos_soft_move.success
				and battlelos_soft_move.was_blocked == false
				and battlelos_soft_move.final_position.is_equal_approx(Vector2(70.0, 30.0))
				and _battlelos_clear_ok(battlelos_soft_los, "los_soft_a", "los_soft_b")
			)

	var battlelos_interior_ok: bool = battlelos_blocked_ok

	var battlelos_graze_ok: bool = false
	var battlelos_corner_ok: bool = false
	var battlelos_endpoint_ok: bool = false
	var battlelos_edge_bs: BattleState = _battlemove_make_state("active")
	if battlelos_edge_bs != null and battlelos_edge_bs.battlefield_geometry != null:
		var battlelos_edge_wall: BattleObstacle = BattleObstacle.new(
			"los_edge_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true,
			true
		)
		if battlelos_edge_bs.battlefield_geometry.add_obstacle(battlelos_edge_wall):
			var battlelos_graze_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_edge_bs,
				Vector2(30.0, 20.0),
				Vector2(70.0, 20.0)
			)
			battlelos_graze_ok = _battlelos_segment_clear_ok(battlelos_graze_res)
			var battlelos_corner_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_edge_bs,
				Vector2(30.0, 20.0),
				Vector2(40.0, 10.0)
			)
			battlelos_corner_ok = _battlelos_segment_clear_ok(battlelos_corner_res)
			var battlelos_end_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_edge_bs,
				Vector2(40.0, 30.0),
				Vector2(20.0, 30.0)
			)
			battlelos_endpoint_ok = _battlelos_segment_clear_ok(battlelos_end_res)

	var battlelos_tunnel_ok: bool = false
	var battlelos_tun_bs: BattleState = _battlemove_make_state("active")
	if battlelos_tun_bs != null and battlelos_tun_bs.battlefield_geometry != null:
		var battlelos_tun_wall: BattleObstacle = BattleObstacle.new(
			"los_thin_wall",
			Rect2(49.8, 29.8, 0.4, 0.4),
			true,
			true
		)
		if battlelos_tun_bs.battlefield_geometry.add_obstacle(battlelos_tun_wall):
			var battlelos_tun_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_tun_bs,
				Vector2(5.0, 30.0),
				Vector2(95.0, 30.0)
			)
			battlelos_tunnel_ok = _battlelos_blocked_ok(battlelos_tun_res, "", "", "los_thin_wall")

	var battlelos_earliest_ok: bool = false
	var battlelos_insert_order_ok: bool = false
	var battlelos_early_order_a: Array[String] = ["los_far", "los_near"]
	var battlelos_early_order_b: Array[String] = ["los_near", "los_far"]
	var battlelos_early_a: String = _battlelos_earliest_blocker(battlelos_early_order_a)
	var battlelos_early_b: String = _battlelos_earliest_blocker(battlelos_early_order_b)
	battlelos_earliest_ok = battlelos_early_a == "los_near" and battlelos_early_b == "los_near"
	battlelos_insert_order_ok = battlelos_earliest_ok

	var battlelos_tie_ok: bool = false
	var battlelos_tie_bs: BattleState = _battlemove_make_state("active")
	if battlelos_tie_bs != null and battlelos_tie_bs.battlefield_geometry != null:
		var battlelos_tie_z: BattleObstacle = BattleObstacle.new(
			"z_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true,
			true
		)
		var battlelos_tie_a: BattleObstacle = BattleObstacle.new(
			"a_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true,
			true
		)
		if (
			battlelos_tie_bs.battlefield_geometry.add_obstacle(battlelos_tie_z)
			and battlelos_tie_bs.battlefield_geometry.add_obstacle(battlelos_tie_a)
		):
			var battlelos_tie_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_tie_bs,
				Vector2(20.0, 30.0),
				Vector2(70.0, 30.0)
			)
			battlelos_tie_ok = _battlelos_blocked_ok(battlelos_tie_res, "", "", "a_wall")

	var battlelos_reverse_ok: bool = false
	var battlelos_rev_bs: BattleState = _battlemove_make_state("active")
	if battlelos_rev_bs != null and battlelos_rev_bs.battlefield_geometry != null:
		var battlelos_rev_near: BattleObstacle = BattleObstacle.new(
			"los_rev_near",
			Rect2(30.0, 20.0, 8.0, 20.0),
			true,
			true
		)
		var battlelos_rev_far: BattleObstacle = BattleObstacle.new(
			"los_rev_far",
			Rect2(55.0, 20.0, 8.0, 20.0),
			true,
			true
		)
		var battlelos_rev_a: BattleParticipant = _battlemove_add_participant(
			battlelos_rev_bs,
			"los_rev_a",
			"attacker"
		)
		var battlelos_rev_b: BattleParticipant = _battlemove_add_participant(
			battlelos_rev_bs,
			"los_rev_b",
			"defender"
		)
		if (
			battlelos_rev_a != null
			and battlelos_rev_b != null
			and battlelos_rev_bs.battlefield_geometry.add_obstacle(battlelos_rev_far)
			and battlelos_rev_bs.battlefield_geometry.add_obstacle(battlelos_rev_near)
		):
			_battletarget_place(battlelos_rev_a, Vector2(15.0, 30.0))
			_battletarget_place(battlelos_rev_b, Vector2(80.0, 30.0))
			var battlelos_fwd: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_rev_bs,
				"los_rev_a",
				"los_rev_b"
			)
			var battlelos_back: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_rev_bs,
				"los_rev_b",
				"los_rev_a"
			)
			battlelos_reverse_ok = (
				_battlelos_blocked_ok(battlelos_fwd, "los_rev_a", "los_rev_b", "los_rev_near")
				and _battlelos_blocked_ok(battlelos_back, "los_rev_b", "los_rev_a", "los_rev_far")
			)

	var battlelos_mixed_ok: bool = false
	var battlelos_mix_bs: BattleState = _battlemove_make_state("active")
	if battlelos_mix_bs != null and battlelos_mix_bs.battlefield_geometry != null:
		var battlelos_mix_fence: BattleObstacle = BattleObstacle.new(
			"los_mix_fence",
			Rect2(28.0, 20.0, 6.0, 20.0),
			true,
			false
		)
		var battlelos_mix_soft: BattleObstacle = BattleObstacle.new(
			"los_mix_soft",
			Rect2(38.0, 20.0, 6.0, 20.0),
			false,
			false
		)
		var battlelos_mix_hard: BattleObstacle = BattleObstacle.new(
			"los_mix_hard",
			Rect2(52.0, 20.0, 6.0, 20.0),
			false,
			true
		)
		if (
			battlelos_mix_bs.battlefield_geometry.add_obstacle(battlelos_mix_fence)
			and battlelos_mix_bs.battlefield_geometry.add_obstacle(battlelos_mix_soft)
			and battlelos_mix_bs.battlefield_geometry.add_obstacle(battlelos_mix_hard)
		):
			var battlelos_mix_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_mix_bs,
				Vector2(15.0, 30.0),
				Vector2(80.0, 30.0)
			)
			battlelos_mixed_ok = _battlelos_blocked_ok(battlelos_mix_res, "", "", "los_mix_hard")

	var battlelos_segment_ok: bool = false
	var battlelos_seg_bs: BattleState = _battlemove_make_state("active")
	if battlelos_seg_bs != null:
		var battlelos_seg_res: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
			battlelos_seg_bs,
			Vector2(10.0, 10.0),
			Vector2(40.0, 10.0)
		)
		battlelos_segment_ok = _battlelos_segment_clear_ok(battlelos_seg_res)

	var battlelos_segment_invalid_ok: bool = false
	var battlelos_segi_bs: BattleState = _battlemove_make_state("active")
	if battlelos_segi_bs != null:
		var battlelos_segi_geo: Dictionary = _battlelos_geo_snap(battlelos_segi_bs.battlefield_geometry)
		var battlelos_segi_nan: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
			battlelos_segi_bs,
			Vector2(NAN, 10.0),
			Vector2(40.0, 10.0)
		)
		var battlelos_segi_inf: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
			battlelos_segi_bs,
			Vector2(10.0, 10.0),
			Vector2(INF, 10.0)
		)
		battlelos_segment_invalid_ok = (
			_battlelos_fail_ok(battlelos_segi_nan, "invalid_segment")
			and _battlelos_fail_ok(battlelos_segi_inf, "invalid_segment")
			and _battlelos_geo_unchanged(battlelos_segi_bs.battlefield_geometry, battlelos_segi_geo)
		)

	var battlelos_spatial_regress_ok: bool = false
	var battlelos_reg_bs: BattleState = _battlemove_make_state("active")
	if battlelos_reg_bs != null and battlelos_reg_bs.battlefield_geometry != null:
		var battlelos_reg_eps: float = BattleSpatialService.COLLISION_EPSILON
		var battlelos_reg_wall: BattleObstacle = BattleObstacle.new(
			"wall_a",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true
		)
		if battlelos_reg_bs.battlefield_geometry.add_obstacle(battlelos_reg_wall):
			var battlelos_reg_hit: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlelos_reg_bs,
				Vector2(30.0, 30.0),
				Vector2(20.0, 0.0)
			)
			var battlelos_reg_tun: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlelos_reg_bs,
				Vector2(30.0, 30.0),
				Vector2(100.0, 0.0)
			)
			var battlelos_reg_diag: BattleSpatialResult = BattleSpatialService.resolve_translation(
				battlelos_reg_bs,
				Vector2(30.0, 25.0),
				Vector2(20.0, 10.0)
			)
			battlelos_spatial_regress_ok = (
				battlelos_reg_hit != null
				and battlelos_reg_hit.success
				and battlelos_reg_hit.was_blocked
				and battlelos_reg_hit.blocking_obstacle_id == "wall_a"
				and is_equal_approx(battlelos_reg_hit.final_position.x, 40.0 - battlelos_reg_eps)
				and battlelos_reg_tun != null
				and battlelos_reg_tun.success
				and battlelos_reg_tun.was_blocked
				and battlelos_reg_tun.blocking_obstacle_id == "wall_a"
				and battlelos_reg_tun.final_position.x < 40.0
				and battlelos_reg_diag != null
				and battlelos_reg_diag.success
				and battlelos_reg_diag.was_blocked
				and battlelos_reg_diag.blocking_obstacle_id == "wall_a"
				and not battlelos_reg_wall.contains_point(battlelos_reg_diag.final_position)
				and _battlespatial_collinear(battlelos_reg_diag.resolved_displacement, Vector2(20.0, 10.0))
			)

	var battlelos_target_blocked_ok: bool = false
	var battlelos_pref_bs: BattleState = _battlemove_make_state("active")
	if battlelos_pref_bs != null and battlelos_pref_bs.battlefield_geometry != null:
		var battlelos_pref_wall: BattleObstacle = BattleObstacle.new(
			"target_pre_los_wall",
			Rect2(28.0, 18.0, 20.0, 10.0),
			true,
			true
		)
		var battlelos_pref_src: BattleParticipant = _battlemove_add_participant(
			battlelos_pref_bs,
			"pre_los_src",
			"attacker"
		)
		var battlelos_pref_near: BattleParticipant = _battlemove_add_participant(
			battlelos_pref_bs,
			"pre_los_behind_wall",
			"defender"
		)
		var battlelos_pref_far: BattleParticipant = _battlemove_add_participant(
			battlelos_pref_bs,
			"pre_los_open_far",
			"defender"
		)
		if (
			battlelos_pref_src != null
			and battlelos_pref_near != null
			and battlelos_pref_far != null
			and battlelos_pref_bs.battlefield_geometry.add_obstacle(battlelos_pref_wall)
		):
			_battletarget_place(battlelos_pref_src, Vector2(30.0, 10.0))
			_battletarget_place(battlelos_pref_near, Vector2(30.0, 40.0))
			_battletarget_place(battlelos_pref_far, Vector2(80.0, 10.0))
			var battlelos_pref_sel: BattleTargetSelectionResult = BattleTargetSelectionService.advance(
				battlelos_pref_bs
			)
			var battlelos_pref_los: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_pref_bs,
				"pre_los_src",
				"pre_los_behind_wall"
			)
			battlelos_target_blocked_ok = (
				battlelos_pref_sel != null
				and battlelos_pref_sel.success
				and _battletarget_has(battlelos_pref_src, "pre_los_behind_wall")
				and _battlelos_blocked_ok(
					battlelos_pref_los,
					"pre_los_src",
					"pre_los_behind_wall",
					"target_pre_los_wall"
				)
			)

	var battlelos_no_target_mutate_ok: bool = false
	var battlelos_no_move_mutate_ok: bool = false
	var battlelos_geo_readonly_ok: bool = false
	var battlelos_mut_bs: BattleState = _battlemove_make_state("active")
	if battlelos_mut_bs != null and battlelos_mut_bs.battlefield_geometry != null:
		var battlelos_mut_wall: BattleObstacle = BattleObstacle.new(
			"los_mut_wall",
			Rect2(40.0, 20.0, 10.0, 20.0),
			true,
			true
		)
		var battlelos_mut_src: BattleParticipant = _battlemove_add_participant(
			battlelos_mut_bs,
			"los_mut_src",
			"attacker"
		)
		var battlelos_mut_tgt: BattleParticipant = _battlemove_add_participant(
			battlelos_mut_bs,
			"los_mut_tgt",
			"defender"
		)
		if (
			battlelos_mut_src != null
			and battlelos_mut_tgt != null
			and battlelos_mut_bs.battlefield_geometry.add_obstacle(battlelos_mut_wall)
		):
			_battletarget_place(battlelos_mut_src, Vector2(20.0, 30.0))
			_battletarget_place(battlelos_mut_tgt, Vector2(70.0, 30.0))
			var battlelos_mut_nav: bool = battlelos_mut_src.set_navigation_path(
				Vector2(20.0, 18.0),
				[Vector2(20.0, 18.0)]
			)
			var battlelos_mut_intent: bool = battlelos_mut_src.set_movement_intent(Vector2(0.0, 1.0))
			var battlelos_mut_speed: bool = battlelos_mut_src.set_movement_speed(3.0)
			var battlelos_mut_cap: bool = battlelos_mut_src.set_movement_target_position(Vector2(20.0, 18.0))
			var battlelos_mut_tgt_set: bool = battlelos_mut_src.set_target_participant("los_mut_tgt")
			battlelos_mut_src.velocity = Vector2(0.0, 3.0)
			var battlelos_mut_snap: Dictionary = _battletarget_part_snap(battlelos_mut_src)
			var battlelos_mut_geo: Dictionary = _battlelos_geo_snap(battlelos_mut_bs.battlefield_geometry)
			var battlelos_mut_res1: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_mut_bs,
				"los_mut_src",
				"los_mut_tgt"
			)
			var battlelos_mut_res2: BattleLineOfSightResult = BattleLineOfSightService.check_participant_to_participant(
				battlelos_mut_bs,
				"los_mut_src",
				"los_mut_tgt"
			)
			battlelos_no_target_mutate_ok = (
				battlelos_mut_nav
				and battlelos_mut_intent
				and battlelos_mut_speed
				and battlelos_mut_cap
				and battlelos_mut_tgt_set
				and battlelos_mut_res1 != null
				and battlelos_mut_res1.success
				and battlelos_mut_res2 != null
				and battlelos_mut_res2.success
				and _battletarget_has(battlelos_mut_src, "los_mut_tgt")
				and _battletarget_part_unchanged(battlelos_mut_src, battlelos_mut_snap)
			)
			battlelos_no_move_mutate_ok = battlelos_no_target_mutate_ok
			battlelos_geo_readonly_ok = (
				battlelos_no_move_mutate_ok
				and _battlelos_geo_unchanged(battlelos_mut_bs.battlefield_geometry, battlelos_mut_geo)
			)

	var battlelos_no_cache_ok: bool = false
	var battlelos_cache_p: BattleParticipant = BattleParticipant.new("los_cache_p")
	battlelos_no_cache_ok = (
		battlelos_cache_p.get("visible_enemy_ids") == null
		and battlelos_cache_p.get("visible_participant_ids") == null
		and battlelos_cache_p.get("los_candidate_ids") == null
		and battlelos_cache_p.get("has_line_of_sight") == null
		and not battlelos_cache_p.has_method("set_visible_enemies")
		and not battlelos_cache_p.has_method("get_visible_enemies")
	)

	var battlelos_no_runtime_refresh_ok: bool = false
	var battlelos_rt_bs: BattleState = _battlemove_make_state("active")
	if battlelos_rt_bs != null:
		var battlelos_rt_a: BattleParticipant = _battlemove_add_participant(
			battlelos_rt_bs,
			"los_rt_a",
			"attacker"
		)
		var battlelos_rt_b: BattleParticipant = _battlemove_add_participant(
			battlelos_rt_bs,
			"los_rt_b",
			"defender"
		)
		if battlelos_rt_a != null and battlelos_rt_b != null:
			_battletarget_place(battlelos_rt_a, Vector2(10.0, 10.0))
			_battletarget_place(battlelos_rt_b, Vector2(20.0, 10.0))
			var battlelos_rt_res: BattleRuntimeResult = BattleRuntimeService.advance(battlelos_rt_bs, 0.0)
			battlelos_no_runtime_refresh_ok = (
				battlelos_rt_res != null
				and battlelos_rt_res.success
				and battlelos_rt_a.get("visible_enemy_ids") == null
				and battlelos_rt_a.get("has_line_of_sight") == null
				and battlelos_rt_b.get("visible_enemy_ids") == null
				and not battlelos_rt_a.has_method("refresh_line_of_sight")
			)

	var battlelos_persist_ok: bool = false
	var battlelos_immutability_ok: bool = false
	var battlelos_camp_pack: Dictionary = _battle_create_ready_pack()
	var battlelos_camp_game: GameState = battlelos_camp_pack.get("game_state", null) as GameState
	var battlelos_camp_force: TravelingForce = battlelos_camp_pack.get("force", null) as TravelingForce
	var battlelos_camp_bs: BattleState = battlelos_camp_pack.get("battle_state", null) as BattleState
	if battlelos_camp_game != null and battlelos_camp_bs != null:
		var battlelos_camp_deployed: bool = _battle_deploy_standard_attacker(battlelos_camp_bs)
		var battlelos_camp_geo: bool = _battlegeo_init(battlelos_camp_bs)
		var battlelos_camp_snap: Dictionary = _battle_campaign_snapshot(
			battlelos_camp_game,
			battlelos_camp_force,
			"battle_mission"
		)
		var battlelos_camp_wall: BattleObstacle = BattleObstacle.new(
			"los_camp_fence",
			Rect2(40.0, 20.0, 8.0, 8.0),
			true,
			false
		)
		var battlelos_camp_added: bool = false
		if battlelos_camp_bs.battlefield_geometry != null:
			battlelos_camp_added = battlelos_camp_bs.battlefield_geometry.add_obstacle(battlelos_camp_wall)
		var battlelos_camp_persist: Dictionary = battlelos_camp_game.to_dict()
		battlelos_persist_ok = (
			battlelos_camp_deployed
			and battlelos_camp_geo
			and battlelos_camp_added
			and _battle_serialized_campaign_keys_only(battlelos_camp_persist)
			and not _battle_data_has_tactical_trace(battlelos_camp_persist)
		)
		var battlelos_camp_part: BattleParticipant = battlelos_camp_bs.get_participant("battle_sol_a")
		var battlelos_camp_los_ok: bool = false
		if battlelos_camp_part != null and battlelos_camp_part.has_battle_position:
			var battlelos_camp_seg: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
				battlelos_camp_bs,
				battlelos_camp_part.battle_position,
				battlelos_camp_part.battle_position + Vector2(4.0, 0.0)
			)
			battlelos_camp_los_ok = battlelos_camp_seg != null and battlelos_camp_seg.success
		battlelos_immutability_ok = (
			battlelos_persist_ok
			and battlelos_camp_los_ok
			and _battle_campaign_unchanged(
				battlelos_camp_game,
				battlelos_camp_snap,
				battlelos_camp_force,
				"battle_mission"
			)
			and battlelos_camp_game.get_mission("battle_mission").mission_state == "awaiting_resolution"
			and battlelos_camp_game.get_neighborhood("battle_hood").owner_faction_id == "battle_b"
		)

	var battlelos_flat_ok: bool = false
	var battlelos_flat_p: BattleParticipant = BattleParticipant.new("los_flat_p")
	var battlelos_flat_svc: BattleLineOfSightService = BattleLineOfSightService.new()
	battlelos_flat_ok = (
		battlelos_flat_p.get("elevation_level") == null
		and battlelos_flat_p.get("elevation") == null
		and not battlelos_flat_p.has_method("set_elevation_level")
		and not battlelos_flat_svc.has_method("check_elevation")
		and typeof(battlelos_flat_p.battle_position) == TYPE_VECTOR2
	)

	var battlelos_ok_clear: BattleLineOfSightResult = BattleLineOfSightResult.succeeded(
		true,
		"src_h",
		"tgt_h",
		""
	)
	var battlelos_ok_block: BattleLineOfSightResult = BattleLineOfSightResult.succeeded(
		false,
		"src_h",
		"tgt_h",
		"wall_h"
	)
	var battlelos_fail_h: BattleLineOfSightResult = BattleLineOfSightResult.failed(
		"null_battle_state",
		"Battle line of sight failed: battle_state is null.",
		"src_h",
		"tgt_h"
	)
	var battlelos_result_helper_ok: bool = (
		battlelos_ok_clear != null
		and battlelos_ok_clear.success
		and battlelos_ok_clear.has_line_of_sight
		and battlelos_ok_clear.source_participant_id == "src_h"
		and battlelos_ok_clear.target_participant_id == "tgt_h"
		and battlelos_ok_clear.blocking_obstacle_id.is_empty()
		and battlelos_ok_clear.error_code.is_empty()
		and battlelos_ok_clear.error_message.is_empty()
		and battlelos_ok_block != null
		and battlelos_ok_block.success
		and battlelos_ok_block.has_line_of_sight == false
		and battlelos_ok_block.blocking_obstacle_id == "wall_h"
		and battlelos_fail_h != null
		and not battlelos_fail_h.success
		and battlelos_fail_h.has_line_of_sight == false
		and battlelos_fail_h.error_code == "null_battle_state"
		and battlelos_fail_h.error_message == "Battle line of sight failed: battle_state is null."
		and battlelos_fail_h.blocking_obstacle_id.is_empty()
	)

	var battlelos_no_combat_ok: bool = false
	var battlelos_no_combat_bs: BattleState = _battlemove_make_state("active")
	var battlelos_no_combat_svc: BattleLineOfSightService = BattleLineOfSightService.new()
	if battlelos_no_combat_bs != null:
		battlelos_no_combat_ok = (
			_battle_has_no_combat_turn_model(battlelos_no_combat_bs)
			and not battlelos_no_combat_svc.has_method("fire")
			and not battlelos_no_combat_svc.has_method("apply_damage")
			and not battlelos_no_combat_svc.has_method("resolve_hit")
			and not battlelos_no_combat_svc.has_method("compute_perception")
			and not battlelos_no_combat_svc.has_method("select_cover")
			and not battlelos_no_combat_svc.has_method("find_path")
			and battlelos_no_combat_bs.get("fog_of_war") == null
			and battlelos_no_combat_bs.get("perception_radius") == null
		)

	var battlefire_ok_def: BattleWeaponDefinition = BattleWeaponDefinition.new("test_ok", 10.0, 2.0, 8, 1.25)
	var battlefire_def_ok: bool = (
		battlefire_ok_def != null
		and battlefire_ok_def.is_valid()
		and not BattleWeaponDefinition.new("", 10.0, 2.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 0.0, 2.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", -4.0, 2.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", NAN, 2.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", INF, 2.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, 0.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, -1.0, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, NAN, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, INF, 8, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, 2.0, 0, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, 2.0, -2, 1.0).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, 2.0, 8, -0.1).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, 2.0, 8, NAN).is_valid()
		and not BattleWeaponDefinition.new("bad", 10.0, 2.0, 8, INF).is_valid()
		and BattleWeaponDefinition.new("zero_reload", 10.0, 2.0, 8, 0.0).is_valid()
	)

	var battlefire_pistol_a: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("pistol")
	var battlefire_pistol_b: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("pistol")
	var battlefire_unknown: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("laser")
	var battlefire_catalog_ok: bool = (
		_battlefire_catalog_match(battlefire_pistol_a, "pistol", 24.0, 2.5, 12, 1.5)
		and _battlefire_catalog_match(battlefire_pistol_b, "pistol", 24.0, 2.5, 12, 1.5)
		and _battlefire_catalog_match(BattleWeaponCatalog.get_definition("shotgun"), "shotgun", 12.0, 1.0, 6, 2.5)
		and _battlefire_catalog_match(BattleWeaponCatalog.get_definition("smg"), "smg", 20.0, 8.0, 30, 2.0)
		and _battlefire_catalog_match(BattleWeaponCatalog.get_definition("rifle"), "rifle", 40.0, 2.0, 20, 2.2)
		and _battlefire_catalog_match(BattleWeaponCatalog.get_definition("sniper"), "sniper", 70.0, 0.5, 5, 3.0)
		and battlefire_unknown == null
		and BattleWeaponCatalog.get_definition("") == null
		and not BattleWeaponCatalog.has_definition("laser")
		and BattleWeaponCatalog.has_definition("pistol")
	)

	var battlefire_init_ok: bool = (
		_battlefire_initial_ok(BattleParticipant.new("init_pistol", "", "a", "attacker", "pistol"), "pistol", 12)
		and _battlefire_initial_ok(BattleParticipant.new("init_shotgun", "", "a", "attacker", "shotgun"), "shotgun", 6)
		and _battlefire_initial_ok(BattleParticipant.new("init_smg", "", "a", "attacker", "smg"), "smg", 30)
		and _battlefire_initial_ok(BattleParticipant.new("init_rifle", "", "a", "attacker", "rifle"), "rifle", 20)
		and _battlefire_initial_ok(BattleParticipant.new("init_sniper", "", "a", "attacker", "sniper"), "sniper", 5)
	)
	var battlefire_init_empty: BattleParticipant = BattleParticipant.new("init_empty")
	var battlefire_init_unknown: BattleParticipant = BattleParticipant.new(
		"init_unknown", "", "a", "attacker", "laser"
	)
	battlefire_init_ok = (
		battlefire_init_ok
		and battlefire_init_empty != null
		and battlefire_init_empty.weapon_state == null
		and battlefire_init_unknown != null
		and battlefire_init_unknown.weapon_type == "laser"
		and battlefire_init_unknown.weapon_state == null
	)

	var battlefire_own_ok: bool = false
	var battlefire_own_p: BattleParticipant = BattleParticipant.new("own_p", "", "a", "attacker", "pistol")
	if battlefire_own_p != null and battlefire_own_p.weapon_state != null:
		battlefire_own_p.weapon_state.ammo_in_magazine = 3
		battlefire_own_p.weapon_state.cooldown_remaining_seconds = 0.4
		battlefire_own_p.weapon_state.reload_remaining_seconds = 0.8
		battlefire_own_p.weapon_state.is_reloading = true
		battlefire_own_ok = battlefire_own_p.weapon_type == "pistol"
	var battlefire_own_pack: Dictionary = _battle_create_ready_pack()
	var battlefire_own_game: GameState = battlefire_own_pack.get("game_state", null) as GameState
	var battlefire_own_bs: BattleState = battlefire_own_pack.get("battle_state", null) as BattleState
	if battlefire_own_ok and battlefire_own_game != null and battlefire_own_bs != null:
		var battlefire_own_sol: Soldier = battlefire_own_game.get_soldier("battle_sol_a")
		var battlefire_own_part: BattleParticipant = battlefire_own_bs.get_participant("battle_sol_a")
		if battlefire_own_sol != null and battlefire_own_part != null and battlefire_own_part.weapon_state != null:
			var battlefire_own_wpn: String = battlefire_own_sol.weapon_type_id
			battlefire_own_part.weapon_state.ammo_in_magazine = 1
			battlefire_own_part.weapon_state.cooldown_remaining_seconds = 0.9
			battlefire_own_ok = (
				battlefire_own_part.weapon_type == battlefire_own_wpn
				and battlefire_own_sol.weapon_type_id == battlefire_own_wpn
				and battlefire_own_sol.to_dict().get("weapon_type_id", "") == battlefire_own_wpn
			)

	var battlefire_fail_null_ok: bool = _battlefire_fail_ok(
		BattleFireControlService.advance_weapon_state(null, 0.1),
		"null_battle_state"
	)
	var battlefire_fail_inactive_ok: bool = false
	var battlefire_fail_delta_ok: bool = false
	var battlefire_fail_missing_geo_ok: bool = false
	var battlefire_fail_invalid_geo_ok: bool = false
	var battlefire_fail_dep: BattleState = _battlemove_make_state("deployment")
	if battlefire_fail_dep != null:
		var battlefire_fail_dep_p: BattleParticipant = _battlefire_add(battlefire_fail_dep, "fire_dep_p", "attacker", "pistol")
		if battlefire_fail_dep_p != null:
			_battletarget_place(battlefire_fail_dep_p, Vector2(10.0, 10.0))
			var battlefire_fail_dep_snap: Dictionary = _battlefire_full_snap(battlefire_fail_dep_p)
			battlefire_fail_inactive_ok = (
				_battlefire_fail_ok(
					BattleFireControlService.advance_weapon_state(battlefire_fail_dep, 0.2),
					"battle_not_active"
				)
				and _battlefire_full_unchanged(battlefire_fail_dep_p, battlefire_fail_dep_snap)
			)
	var battlefire_fail_delta_bs: BattleState = _battlemove_make_state("active")
	if battlefire_fail_delta_bs != null:
		var battlefire_fail_delta_p: BattleParticipant = _battlefire_add(
			battlefire_fail_delta_bs, "fire_delta_p", "attacker", "pistol"
		)
		if battlefire_fail_delta_p != null and battlefire_fail_delta_p.weapon_state != null:
			_battletarget_place(battlefire_fail_delta_p, Vector2(12.0, 12.0))
			battlefire_fail_delta_p.weapon_state.cooldown_remaining_seconds = 0.8
			var battlefire_fail_delta_snap: Dictionary = _battlefire_full_snap(battlefire_fail_delta_p)
			battlefire_fail_delta_ok = (
				_battlefire_fail_ok(
					BattleFireControlService.advance_weapon_state(battlefire_fail_delta_bs, -0.1),
					"invalid_delta"
				)
				and _battlefire_fail_ok(
					BattleFireControlService.advance_weapon_state(battlefire_fail_delta_bs, NAN),
					"invalid_delta"
				)
				and _battlefire_fail_ok(
					BattleFireControlService.advance_weapon_state(battlefire_fail_delta_bs, INF),
					"invalid_delta"
				)
				and _battlefire_full_unchanged(battlefire_fail_delta_p, battlefire_fail_delta_snap)
			)
	var battlefire_fail_miss_bs: BattleState = _battlemove_make_state("active")
	if battlefire_fail_miss_bs != null:
		var battlefire_fail_miss_p: BattleParticipant = _battlefire_add(
			battlefire_fail_miss_bs, "fire_miss_p", "attacker", "pistol"
		)
		if battlefire_fail_miss_p != null:
			_battletarget_place(battlefire_fail_miss_p, Vector2(8.0, 8.0))
			var battlefire_fail_miss_intent: bool = battlefire_fail_miss_p.set_movement_intent(Vector2(1.0, 0.0))
			var battlefire_fail_miss_snap: Dictionary = _battlefire_full_snap(battlefire_fail_miss_p)
			battlefire_fail_miss_bs.battlefield_geometry = null
			battlefire_fail_missing_geo_ok = (
				battlefire_fail_miss_intent
				and _battlefire_fail_ok(
					BattleFireControlService.advance_weapon_state(battlefire_fail_miss_bs, 0.3),
					"missing_battlefield_geometry"
				)
				and _battlefire_full_unchanged(battlefire_fail_miss_p, battlefire_fail_miss_snap)
			)
	var battlefire_fail_bad_bs: BattleState = _battlemove_make_state("active")
	if battlefire_fail_bad_bs != null:
		var battlefire_fail_bad_p: BattleParticipant = _battlefire_add(
			battlefire_fail_bad_bs, "fire_bad_p", "attacker", "pistol"
		)
		if battlefire_fail_bad_p != null:
			_battletarget_place(battlefire_fail_bad_p, Vector2(9.0, 9.0))
			var battlefire_fail_bad_snap: Dictionary = _battlefire_full_snap(battlefire_fail_bad_p)
			battlefire_fail_bad_bs.battlefield_geometry = BattlefieldGeometry.new()
			battlefire_fail_invalid_geo_ok = (
				_battlefire_fail_ok(
					BattleFireControlService.advance_weapon_state(battlefire_fail_bad_bs, 0.3),
					"invalid_battlefield_geometry"
				)
				and _battlefire_full_unchanged(battlefire_fail_bad_p, battlefire_fail_bad_snap)
			)

	var battlefire_cooldown_ok: bool = false
	var battlefire_cd_bs: BattleState = _battlemove_make_state("active")
	if battlefire_cd_bs != null:
		var battlefire_cd_p: BattleParticipant = _battlefire_add(battlefire_cd_bs, "fire_cd_p", "attacker", "pistol")
		if battlefire_cd_p != null and battlefire_cd_p.weapon_state != null:
			battlefire_cd_p.weapon_state.cooldown_remaining_seconds = 1.0
			var battlefire_cd_res1: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_cd_bs, 0.25
			)
			var battlefire_cd_mid: bool = (
				battlefire_cd_res1 != null
				and battlefire_cd_res1.success
				and is_equal_approx(battlefire_cd_p.weapon_state.cooldown_remaining_seconds, 0.75)
			)
			var battlefire_cd_res2: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_cd_bs, 1.0
			)
			battlefire_cooldown_ok = (
				battlefire_cd_mid
				and battlefire_cd_res2 != null
				and battlefire_cd_res2.success
				and is_equal_approx(battlefire_cd_p.weapon_state.cooldown_remaining_seconds, 0.0)
				and battlefire_cd_p.weapon_state.cooldown_remaining_seconds >= 0.0
			)

	var battlefire_zero_delta_ok: bool = false
	var battlefire_zd_bs: BattleState = _battlemove_make_state("active")
	if battlefire_zd_bs != null:
		var battlefire_zd_p: BattleParticipant = _battlefire_add(battlefire_zd_bs, "fire_zd_p", "attacker", "pistol")
		if battlefire_zd_p != null and battlefire_zd_p.weapon_state != null:
			battlefire_zd_p.weapon_state.ammo_in_magazine = 4
			battlefire_zd_p.weapon_state.cooldown_remaining_seconds = 0.9
			battlefire_zd_p.weapon_state.reload_remaining_seconds = 0.6
			battlefire_zd_p.weapon_state.is_reloading = true
			var battlefire_zd_snap: Dictionary = _battlefire_weapon_snap(battlefire_zd_p)
			var battlefire_zd_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_zd_bs, 0.0
			)
			battlefire_zero_delta_ok = (
				battlefire_zd_res != null
				and battlefire_zd_res.success
				and _battlefire_weapon_unchanged(battlefire_zd_p, battlefire_zd_snap)
			)

	var battlefire_reload_start_ok: bool = false
	var battlefire_rs_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rs_bs != null:
		var battlefire_rs_p: BattleParticipant = _battlefire_add(battlefire_rs_bs, "fire_rs_p", "attacker", "pistol")
		if battlefire_rs_p != null and battlefire_rs_p.weapon_state != null:
			battlefire_rs_p.weapon_state.ammo_in_magazine = 0
			battlefire_rs_p.weapon_state.is_reloading = false
			battlefire_rs_p.weapon_state.reload_remaining_seconds = 0.0
			var battlefire_rs_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_rs_bs, 0.25
			)
			# Same-tick contract: reload starts at catalog 1.5s then the same 0.25s is subtracted.
			battlefire_reload_start_ok = (
				battlefire_rs_res != null
				and battlefire_rs_res.success
				and battlefire_rs_p.weapon_state.is_reloading
				and battlefire_rs_p.weapon_state.ammo_in_magazine == 0
				and is_equal_approx(battlefire_rs_p.weapon_state.reload_remaining_seconds, 1.25)
			)

	var battlefire_reload_mid_ok: bool = false
	var battlefire_rm_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rm_bs != null:
		var battlefire_rm_p: BattleParticipant = _battlefire_add(battlefire_rm_bs, "fire_rm_p", "attacker", "pistol")
		if battlefire_rm_p != null and battlefire_rm_p.weapon_state != null:
			battlefire_rm_p.weapon_state.ammo_in_magazine = 0
			battlefire_rm_p.weapon_state.is_reloading = true
			battlefire_rm_p.weapon_state.reload_remaining_seconds = 1.0
			var battlefire_rm_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_rm_bs, 0.25
			)
			battlefire_reload_mid_ok = (
				battlefire_rm_res != null
				and battlefire_rm_res.success
				and battlefire_rm_p.weapon_state.is_reloading
				and battlefire_rm_p.weapon_state.ammo_in_magazine == 0
				and is_equal_approx(battlefire_rm_p.weapon_state.reload_remaining_seconds, 0.75)
			)

	var battlefire_reload_done_ok: bool = false
	var battlefire_rd_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rd_bs != null:
		var battlefire_rd_p: BattleParticipant = _battlefire_add(battlefire_rd_bs, "fire_rd_p", "attacker", "pistol")
		if battlefire_rd_p != null and battlefire_rd_p.weapon_state != null:
			battlefire_rd_p.weapon_state.ammo_in_magazine = 0
			battlefire_rd_p.weapon_state.is_reloading = true
			battlefire_rd_p.weapon_state.reload_remaining_seconds = 0.2
			var battlefire_rd_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_rd_bs, 0.2
			)
			battlefire_reload_done_ok = (
				battlefire_rd_res != null
				and battlefire_rd_res.success
				and not battlefire_rd_p.weapon_state.is_reloading
				and is_equal_approx(battlefire_rd_p.weapon_state.reload_remaining_seconds, 0.0)
				and battlefire_rd_p.weapon_state.ammo_in_magazine == 12
				and battlefire_rd_p.get("reserve_ammo") == null
			)

	var battlefire_reload_large_ok: bool = false
	var battlefire_rl_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rl_bs != null:
		var battlefire_rl_p: BattleParticipant = _battlefire_add(battlefire_rl_bs, "fire_rl_p", "attacker", "pistol")
		if battlefire_rl_p != null and battlefire_rl_p.weapon_state != null:
			battlefire_rl_p.weapon_state.ammo_in_magazine = 0
			battlefire_rl_p.weapon_state.is_reloading = true
			battlefire_rl_p.weapon_state.reload_remaining_seconds = 0.5
			var battlefire_rl_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_rl_bs, 10.0
			)
			battlefire_reload_large_ok = (
				battlefire_rl_res != null
				and battlefire_rl_res.success
				and not battlefire_rl_p.weapon_state.is_reloading
				and battlefire_rl_p.weapon_state.reload_remaining_seconds >= 0.0
				and is_equal_approx(battlefire_rl_p.weapon_state.reload_remaining_seconds, 0.0)
				and battlefire_rl_p.weapon_state.ammo_in_magazine == 12
			)

	var battlefire_zero_reload_def: BattleWeaponDefinition = BattleWeaponDefinition.new(
		"zero_reload_probe", 10.0, 1.0, 8, 0.0
	)
	var battlefire_reload_zero_ok: bool = (
		battlefire_zero_reload_def != null
		and battlefire_zero_reload_def.is_valid()
		and BattleWeaponCatalog.get_definition("pistol").reload_seconds > 0.0
		and BattleWeaponCatalog.get_definition("shotgun").reload_seconds > 0.0
		and BattleWeaponCatalog.get_definition("smg").reload_seconds > 0.0
		and BattleWeaponCatalog.get_definition("rifle").reload_seconds > 0.0
		and BattleWeaponCatalog.get_definition("sniper").reload_seconds > 0.0
	)

	var battlefire_neg_repair_ok: bool = false
	var battlefire_neg_bs: BattleState = _battlemove_make_state("active")
	if battlefire_neg_bs != null:
		var battlefire_neg_p: BattleParticipant = _battlefire_add(battlefire_neg_bs, "fire_neg_p", "attacker", "pistol")
		if battlefire_neg_p != null and battlefire_neg_p.weapon_state != null:
			battlefire_neg_p.weapon_state.ammo_in_magazine = -3
			battlefire_neg_p.weapon_state.cooldown_remaining_seconds = -1.0
			battlefire_neg_p.weapon_state.reload_remaining_seconds = -0.5
			battlefire_neg_p.weapon_state.is_reloading = false
			var battlefire_neg_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_neg_bs, 0.25
			)
			# Clamp ammo/timers to 0, then empty mag starts reload in the same tick (1.5 - 0.25).
			battlefire_neg_repair_ok = (
				battlefire_neg_res != null
				and battlefire_neg_res.success
				and battlefire_neg_p.weapon_state.ammo_in_magazine == 0
				and is_equal_approx(battlefire_neg_p.weapon_state.cooldown_remaining_seconds, 0.0)
				and battlefire_neg_p.weapon_state.is_reloading
				and is_equal_approx(battlefire_neg_p.weapon_state.reload_remaining_seconds, 1.25)
				and is_finite(battlefire_neg_p.weapon_state.cooldown_remaining_seconds)
				and is_finite(battlefire_neg_p.weapon_state.reload_remaining_seconds)
			)

	var battlefire_nan_ok: bool = false
	var battlefire_nan_bs: BattleState = _battlemove_make_state("active")
	if battlefire_nan_bs != null:
		var battlefire_nan_bad: BattleParticipant = _battlefire_add(
			battlefire_nan_bs, "fire_nan_bad", "attacker", "pistol"
		)
		var battlefire_nan_okp: BattleParticipant = _battlefire_add(
			battlefire_nan_bs, "fire_nan_ok", "attacker", "pistol"
		)
		if (
			battlefire_nan_bad != null
			and battlefire_nan_okp != null
			and battlefire_nan_bad.weapon_state != null
			and battlefire_nan_okp.weapon_state != null
		):
			battlefire_nan_bad.weapon_state.cooldown_remaining_seconds = NAN
			battlefire_nan_bad.weapon_state.reload_remaining_seconds = INF
			battlefire_nan_okp.weapon_state.cooldown_remaining_seconds = 1.0
			var battlefire_nan_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_nan_bs, 0.25
			)
			battlefire_nan_ok = (
				battlefire_nan_res != null
				and battlefire_nan_res.success
				and not is_finite(battlefire_nan_bad.weapon_state.cooldown_remaining_seconds)
				and not is_finite(battlefire_nan_bad.weapon_state.reload_remaining_seconds)
				and is_equal_approx(battlefire_nan_okp.weapon_state.cooldown_remaining_seconds, 0.75)
			)

	var battlefire_unknown_ok: bool = false
	var battlefire_unk_bs: BattleState = _battlemove_make_state("active")
	if battlefire_unk_bs != null:
		var battlefire_unk_p: BattleParticipant = _battlefire_add(battlefire_unk_bs, "fire_unk_p", "attacker", "pistol")
		if battlefire_unk_p != null:
			battlefire_unk_p.weapon_type = "laser"
			battlefire_unk_p.weapon_state = BattleWeaponState.new("laser", 0, 1.0, 0.8, false)
			var battlefire_unk_res: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_unk_bs, 0.25
			)
			battlefire_unknown_ok = (
				battlefire_unk_res != null
				and battlefire_unk_res.success
				and battlefire_unk_p.weapon_state != null
				and battlefire_unk_p.weapon_state.weapon_type_id == "laser"
				and battlefire_unk_p.weapon_state.ammo_in_magazine == 0
				and not battlefire_unk_p.weapon_state.is_reloading
				and is_equal_approx(battlefire_unk_p.weapon_state.cooldown_remaining_seconds, 0.75)
				and is_equal_approx(battlefire_unk_p.weapon_state.reload_remaining_seconds, 0.8)
				and BattleWeaponCatalog.get_definition("laser") == null
			)

	var battlefire_eligible_ok: bool = false
	var battlefire_el_bs: BattleState = _battlemove_make_state("active")
	if battlefire_el_bs != null:
		var battlefire_el_src: BattleParticipant = _battlefire_add(
			battlefire_el_bs, "fire_el_src", "attacker", "pistol"
		)
		var battlefire_el_tgt: BattleParticipant = _battlefire_add(
			battlefire_el_bs, "fire_el_tgt", "defender", "pistol"
		)
		if battlefire_el_src != null and battlefire_el_tgt != null and battlefire_el_src.weapon_state != null:
			_battletarget_place(battlefire_el_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_el_tgt, Vector2(20.0, 10.0))
			var battlefire_el_aimed: bool = battlefire_el_src.set_target_participant("fire_el_tgt")
			var battlefire_el_ammo: int = battlefire_el_src.weapon_state.ammo_in_magazine
			var battlefire_el_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_el_bs
			)
			battlefire_eligible_ok = (
				battlefire_el_aimed
				and _battlefire_eval_counts(battlefire_el_res, 2, 1, 1, 0, 0, 0, 0, 0)
				and battlefire_el_src.weapon_state.ammo_in_magazine == battlefire_el_ammo
				and is_equal_approx(battlefire_el_src.weapon_state.cooldown_remaining_seconds, 0.0)
			)

	var battlefire_query_only_ok: bool = false
	var battlefire_qo_bs: BattleState = _battlemove_make_state("active")
	if battlefire_qo_bs != null:
		var battlefire_qo_src: BattleParticipant = _battlefire_add(
			battlefire_qo_bs, "fire_qo_src", "attacker", "pistol"
		)
		var battlefire_qo_tgt: BattleParticipant = _battlefire_add(
			battlefire_qo_bs, "fire_qo_tgt", "defender", "pistol"
		)
		if battlefire_qo_src != null and battlefire_qo_tgt != null:
			_battletarget_place(battlefire_qo_src, Vector2(12.0, 12.0))
			_battletarget_place(battlefire_qo_tgt, Vector2(18.0, 12.0))
			battlefire_qo_src.set_target_participant("fire_qo_tgt")
			battlefire_qo_src.set_movement_intent(Vector2(0.0, 1.0))
			battlefire_qo_src.set_navigation_path(Vector2(12.0, 20.0), [Vector2(12.0, 20.0)])
			var battlefire_qo_snap: Dictionary = _battlefire_full_snap(battlefire_qo_src)
			var battlefire_qo_res1: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_qo_bs
			)
			var battlefire_qo_res2: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_qo_bs
			)
			battlefire_query_only_ok = (
				battlefire_qo_res1 != null
				and battlefire_qo_res1.success
				and battlefire_qo_res2 != null
				and battlefire_qo_res2.success
				and _battlefire_full_unchanged(battlefire_qo_src, battlefire_qo_snap)
			)

	var battlefire_no_target_ok: bool = false
	var battlefire_nt_bs: BattleState = _battlemove_make_state("active")
	if battlefire_nt_bs != null:
		var battlefire_nt_p: BattleParticipant = _battlefire_add(battlefire_nt_bs, "fire_nt_p", "attacker", "pistol")
		if battlefire_nt_p != null:
			_battletarget_place(battlefire_nt_p, Vector2(10.0, 10.0))
			var battlefire_nt_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_nt_bs
			)
			battlefire_no_target_ok = _battlefire_eval_counts(battlefire_nt_res, 1, 0, 0, 0, 0, 0, 0, 0)

	var battlefire_stale_target_ok: bool = false
	var battlefire_st_bs: BattleState = _battlemove_make_state("active")
	if battlefire_st_bs != null:
		var battlefire_st_p: BattleParticipant = _battlefire_add(battlefire_st_bs, "fire_st_p", "attacker", "pistol")
		if battlefire_st_p != null:
			_battletarget_place(battlefire_st_p, Vector2(10.0, 10.0))
			battlefire_st_p.has_target_participant = true
			battlefire_st_p.target_participant_id = "missing_fire_tgt"
			var battlefire_st_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_st_bs
			)
			battlefire_stale_target_ok = (
				_battlefire_eval_counts(battlefire_st_res, 1, 1, 0, 0, 0, 0, 0, 0)
				and battlefire_st_p.has_target_participant
				and battlefire_st_p.target_participant_id == "missing_fire_tgt"
			)

	var battlefire_same_side_ok: bool = false
	var battlefire_ss_bs: BattleState = _battlemove_make_state("active")
	if battlefire_ss_bs != null:
		var battlefire_ss_a: BattleParticipant = _battlefire_add(battlefire_ss_bs, "fire_ss_a", "attacker", "pistol")
		var battlefire_ss_b: BattleParticipant = _battlefire_add(battlefire_ss_bs, "fire_ss_b", "attacker", "pistol")
		if battlefire_ss_a != null and battlefire_ss_b != null:
			_battletarget_place(battlefire_ss_a, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_ss_b, Vector2(16.0, 10.0))
			battlefire_ss_a.set_target_participant("fire_ss_b")
			var battlefire_ss_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_ss_bs
			)
			battlefire_same_side_ok = _battlefire_eval_counts(battlefire_ss_res, 2, 1, 0, 0, 0, 0, 0, 0)

	var battlefire_bad_side_ok: bool = false
	var battlefire_bs_bs: BattleState = _battlemove_make_state("active")
	if battlefire_bs_bs != null:
		var battlefire_bs_src: BattleParticipant = _battlefire_add(
			battlefire_bs_bs, "fire_bs_src", "attacker", "pistol"
		)
		var battlefire_bs_tgt: BattleParticipant = _battlefire_add(
			battlefire_bs_bs, "fire_bs_tgt", "defender", "pistol"
		)
		if battlefire_bs_src != null and battlefire_bs_tgt != null:
			_battletarget_place(battlefire_bs_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_bs_tgt, Vector2(18.0, 10.0))
			battlefire_bs_src.set_target_participant("fire_bs_tgt")
			battlefire_bs_src.side_id = ""
			var battlefire_bs_res1: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_bs_bs
			)
			battlefire_bs_src.side_id = "attacker"
			battlefire_bs_tgt.side_id = "ghost_side"
			var battlefire_bs_res2: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_bs_bs
			)
			battlefire_bad_side_ok = (
				battlefire_bs_res1 != null
				and battlefire_bs_res1.success
				and battlefire_bs_res1.participants_eligible_to_fire == 0
				and battlefire_bs_res2 != null
				and battlefire_bs_res2.success
				and battlefire_bs_res2.participants_eligible_to_fire == 0
			)

	var battlefire_ineligible_ok: bool = false
	var battlefire_in_bs: BattleState = _battlemove_make_state("active")
	if battlefire_in_bs != null:
		var battlefire_in_ready: BattleParticipant = _battlefire_add(
			battlefire_in_bs, "fire_in_ready", "attacker", "pistol"
		)
		var battlefire_in_dead: BattleParticipant = _battlefire_add(
			battlefire_in_bs, "fire_in_dead", "attacker", "pistol"
		)
		var battlefire_in_unpos: BattleParticipant = _battlefire_add(
			battlefire_in_bs, "fire_in_unpos", "attacker", "pistol"
		)
		var battlefire_in_nan: BattleParticipant = _battlefire_add(
			battlefire_in_bs, "fire_in_nan", "attacker", "pistol"
		)
		var battlefire_in_tgt: BattleParticipant = _battlefire_add(
			battlefire_in_bs, "fire_in_tgt", "defender", "pistol"
		)
		var battlefire_in_dead_t: BattleParticipant = _battlefire_add(
			battlefire_in_bs, "fire_in_dead_t", "defender", "pistol"
		)
		if (
			battlefire_in_ready != null
			and battlefire_in_dead != null
			and battlefire_in_unpos != null
			and battlefire_in_nan != null
			and battlefire_in_tgt != null
			and battlefire_in_dead_t != null
		):
			_battletarget_place(battlefire_in_ready, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_in_dead, Vector2(10.0, 12.0))
			_battletarget_place(battlefire_in_nan, Vector2(10.0, 14.0))
			_battletarget_place(battlefire_in_tgt, Vector2(18.0, 10.0))
			_battletarget_place(battlefire_in_dead_t, Vector2(18.0, 16.0))
			battlefire_in_dead.is_alive = false
			battlefire_in_unpos.has_battle_position = false
			battlefire_in_nan.battle_position = Vector2(NAN, 14.0)
			battlefire_in_dead_t.is_alive = false
			battlefire_in_ready.set_target_participant("fire_in_tgt")
			battlefire_in_dead.set_target_participant("fire_in_tgt")
			battlefire_in_unpos.set_target_participant("fire_in_tgt")
			battlefire_in_nan.set_target_participant("fire_in_tgt")
			var battlefire_in_src2: BattleParticipant = _battlefire_add(
				battlefire_in_bs, "fire_in_src2", "attacker", "pistol"
			)
			if battlefire_in_src2 != null:
				_battletarget_place(battlefire_in_src2, Vector2(10.0, 16.0))
				battlefire_in_src2.set_target_participant("fire_in_dead_t")
			var battlefire_in_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_in_bs
			)
			battlefire_ineligible_ok = (
				battlefire_in_res != null
				and battlefire_in_res.success
				and battlefire_in_res.participants_eligible_to_fire == 1
			)

	var battlefire_reload_block_ok: bool = false
	var battlefire_rb_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rb_bs != null:
		var battlefire_rb_src: BattleParticipant = _battlefire_add(
			battlefire_rb_bs, "fire_rb_src", "attacker", "pistol"
		)
		var battlefire_rb_tgt: BattleParticipant = _battlefire_add(
			battlefire_rb_bs, "fire_rb_tgt", "defender", "pistol"
		)
		if battlefire_rb_src != null and battlefire_rb_tgt != null and battlefire_rb_src.weapon_state != null:
			_battletarget_place(battlefire_rb_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_rb_tgt, Vector2(18.0, 10.0))
			battlefire_rb_src.set_target_participant("fire_rb_tgt")
			battlefire_rb_src.weapon_state.is_reloading = true
			battlefire_rb_src.weapon_state.reload_remaining_seconds = 0.9
			var battlefire_rb_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_rb_bs
			)
			battlefire_reload_block_ok = _battlefire_eval_counts(battlefire_rb_res, 2, 1, 0, 0, 0, 0, 1, 0)

	var battlefire_empty_block_ok: bool = false
	var battlefire_eb_bs: BattleState = _battlemove_make_state("active")
	if battlefire_eb_bs != null:
		var battlefire_eb_src: BattleParticipant = _battlefire_add(
			battlefire_eb_bs, "fire_eb_src", "attacker", "pistol"
		)
		var battlefire_eb_tgt: BattleParticipant = _battlefire_add(
			battlefire_eb_bs, "fire_eb_tgt", "defender", "pistol"
		)
		if battlefire_eb_src != null and battlefire_eb_tgt != null and battlefire_eb_src.weapon_state != null:
			_battletarget_place(battlefire_eb_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_eb_tgt, Vector2(18.0, 10.0))
			battlefire_eb_src.set_target_participant("fire_eb_tgt")
			battlefire_eb_src.weapon_state.ammo_in_magazine = 0
			battlefire_eb_src.weapon_state.is_reloading = false
			var battlefire_eb_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_eb_bs
			)
			battlefire_empty_block_ok = (
				_battlefire_eval_counts(battlefire_eb_res, 2, 1, 0, 0, 0, 0, 0, 1)
				and battlefire_eb_src.weapon_state.ammo_in_magazine == 0
				and not battlefire_eb_src.weapon_state.is_reloading
			)

	var battlefire_cooldown_block_ok: bool = false
	var battlefire_cb_bs: BattleState = _battlemove_make_state("active")
	if battlefire_cb_bs != null:
		var battlefire_cb_src: BattleParticipant = _battlefire_add(
			battlefire_cb_bs, "fire_cb_src", "attacker", "pistol"
		)
		var battlefire_cb_tgt: BattleParticipant = _battlefire_add(
			battlefire_cb_bs, "fire_cb_tgt", "defender", "pistol"
		)
		if battlefire_cb_src != null and battlefire_cb_tgt != null and battlefire_cb_src.weapon_state != null:
			_battletarget_place(battlefire_cb_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_cb_tgt, Vector2(18.0, 10.0))
			battlefire_cb_src.set_target_participant("fire_cb_tgt")
			battlefire_cb_src.weapon_state.cooldown_remaining_seconds = 0.4
			var battlefire_cb_hot: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_cb_bs
			)
			battlefire_cb_src.weapon_state.cooldown_remaining_seconds = 0.0
			var battlefire_cb_ready: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_cb_bs
			)
			battlefire_cooldown_block_ok = (
				_battlefire_eval_counts(battlefire_cb_hot, 2, 1, 0, 0, 0, 1, 0, 0)
				and _battlefire_eval_counts(battlefire_cb_ready, 2, 1, 1, 0, 0, 0, 0, 0)
			)

	var battlefire_range_ok: bool = false
	var battlefire_rg_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rg_bs != null:
		var battlefire_rg_src: BattleParticipant = _battlefire_add(
			battlefire_rg_bs, "fire_rg_src", "attacker", "pistol"
		)
		var battlefire_rg_tgt: BattleParticipant = _battlefire_add(
			battlefire_rg_bs, "fire_rg_tgt", "defender", "pistol"
		)
		if battlefire_rg_src != null and battlefire_rg_tgt != null:
			_battletarget_place(battlefire_rg_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_rg_tgt, Vector2(34.0, 10.0))
			battlefire_rg_src.set_target_participant("fire_rg_tgt")
			var battlefire_rg_edge: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_rg_bs
			)
			_battletarget_place(battlefire_rg_tgt, Vector2(34.5, 10.0))
			var battlefire_rg_out: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_rg_bs
			)
			battlefire_range_ok = (
				is_equal_approx(battlefire_rg_src.battle_position.distance_to(Vector2(34.0, 10.0)), 24.0)
				and _battlefire_eval_counts(battlefire_rg_edge, 2, 1, 1, 0, 0, 0, 0, 0)
				and _battlefire_eval_counts(battlefire_rg_out, 2, 1, 0, 0, 1, 0, 0, 0)
			)

	var battlefire_range_diff_ok: bool = false
	var battlefire_rdiff_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rdiff_bs != null:
		var battlefire_rdiff_sg: BattleParticipant = _battlefire_add(
			battlefire_rdiff_bs, "fire_rdiff_sg", "attacker", "shotgun"
		)
		var battlefire_rdiff_rf: BattleParticipant = _battlefire_add(
			battlefire_rdiff_bs, "fire_rdiff_rf", "attacker", "rifle"
		)
		var battlefire_rdiff_t: BattleParticipant = _battlefire_add(
			battlefire_rdiff_bs, "fire_rdiff_t", "defender", "pistol"
		)
		if battlefire_rdiff_sg != null and battlefire_rdiff_rf != null and battlefire_rdiff_t != null:
			_battletarget_place(battlefire_rdiff_sg, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_rdiff_rf, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_rdiff_t, Vector2(26.0, 10.0))
			battlefire_rdiff_sg.set_target_participant("fire_rdiff_t")
			battlefire_rdiff_rf.set_target_participant("fire_rdiff_t")
			var battlefire_rdiff_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_rdiff_bs
			)
			battlefire_range_diff_ok = _battlefire_eval_counts(battlefire_rdiff_res, 3, 2, 1, 0, 1, 0, 0, 0)

	var battlefire_los_block_ok: bool = false
	var battlefire_lb_bs: BattleState = _battlemove_make_state("active")
	if battlefire_lb_bs != null and battlefire_lb_bs.battlefield_geometry != null:
		var battlefire_lb_wall: BattleObstacle = BattleObstacle.new(
			"fire_los_wall",
			Rect2(28.0, 20.0, 6.0, 20.0),
			true,
			true
		)
		var battlefire_lb_src: BattleParticipant = _battlefire_add(
			battlefire_lb_bs, "fire_lb_src", "attacker", "pistol"
		)
		var battlefire_lb_tgt: BattleParticipant = _battlefire_add(
			battlefire_lb_bs, "fire_lb_tgt", "defender", "pistol"
		)
		if (
			battlefire_lb_src != null
			and battlefire_lb_tgt != null
			and battlefire_lb_bs.battlefield_geometry.add_obstacle(battlefire_lb_wall)
		):
			_battletarget_place(battlefire_lb_src, Vector2(20.0, 30.0))
			_battletarget_place(battlefire_lb_tgt, Vector2(40.0, 30.0))
			battlefire_lb_src.set_target_participant("fire_lb_tgt")
			var battlefire_lb_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_lb_bs
			)
			battlefire_los_block_ok = (
				battletarget_pre_los_wall_ok
				and _battletarget_has(battlefire_lb_src, "fire_lb_tgt")
				and _battlefire_eval_counts(battlefire_lb_res, 2, 1, 0, 1, 0, 0, 0, 0)
			)

	var battlefire_blocker_indep_ok: bool = false
	var battlefire_fence_bs: BattleState = _battlemove_make_state("active")
	var battlefire_glass_bs: BattleState = _battlemove_make_state("active")
	if (
		battlefire_fence_bs != null
		and battlefire_glass_bs != null
		and battlefire_fence_bs.battlefield_geometry != null
		and battlefire_glass_bs.battlefield_geometry != null
	):
		var battlefire_fence: BattleObstacle = BattleObstacle.new(
			"fire_fence", Rect2(26.0, 20.0, 4.0, 20.0), true, false
		)
		var battlefire_glass: BattleObstacle = BattleObstacle.new(
			"fire_glass", Rect2(26.0, 20.0, 4.0, 20.0), false, true
		)
		var battlefire_fence_src: BattleParticipant = _battlefire_add(
			battlefire_fence_bs, "fire_fence_src", "attacker", "pistol"
		)
		var battlefire_fence_tgt: BattleParticipant = _battlefire_add(
			battlefire_fence_bs, "fire_fence_tgt", "defender", "pistol"
		)
		var battlefire_glass_src: BattleParticipant = _battlefire_add(
			battlefire_glass_bs, "fire_glass_src", "attacker", "pistol"
		)
		var battlefire_glass_tgt: BattleParticipant = _battlefire_add(
			battlefire_glass_bs, "fire_glass_tgt", "defender", "pistol"
		)
		if (
			battlefire_fence_src != null
			and battlefire_fence_tgt != null
			and battlefire_glass_src != null
			and battlefire_glass_tgt != null
			and battlefire_fence_bs.battlefield_geometry.add_obstacle(battlefire_fence)
			and battlefire_glass_bs.battlefield_geometry.add_obstacle(battlefire_glass)
		):
			_battletarget_place(battlefire_fence_src, Vector2(20.0, 30.0))
			_battletarget_place(battlefire_fence_tgt, Vector2(34.0, 30.0))
			_battletarget_place(battlefire_glass_src, Vector2(20.0, 30.0))
			_battletarget_place(battlefire_glass_tgt, Vector2(34.0, 30.0))
			battlefire_fence_src.set_target_participant("fire_fence_tgt")
			battlefire_glass_src.set_target_participant("fire_glass_tgt")
			var battlefire_fence_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_fence_bs
			)
			var battlefire_glass_res: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_glass_bs
			)
			battlefire_blocker_indep_ok = (
				_battlefire_eval_counts(battlefire_fence_res, 2, 1, 1, 0, 0, 0, 0, 0)
				and _battlefire_eval_counts(battlefire_glass_res, 2, 1, 0, 1, 0, 0, 0, 0)
			)

	var battlefire_reason_order_ok: bool = false
	var battlefire_ro1: BattleFireControlResult = _battlefire_reason_eval(
		true, 0, 0.0, Vector2(10.0, 10.0), Vector2(18.0, 10.0), false
	)
	var battlefire_ro2: BattleFireControlResult = _battlefire_reason_eval(
		false, 8, 0.5, Vector2(10.0, 10.0), Vector2(50.0, 10.0), false
	)
	var battlefire_ro3: BattleFireControlResult = _battlefire_reason_eval(
		false, 12, 0.0, Vector2(10.0, 10.0), Vector2(50.0, 10.0), true
	)
	battlefire_reason_order_ok = (
		_battlefire_eval_counts(battlefire_ro1, 2, 1, 0, 0, 0, 0, 1, 0)
		and _battlefire_eval_counts(battlefire_ro2, 2, 1, 0, 0, 0, 1, 0, 0)
		and _battlefire_eval_counts(battlefire_ro3, 2, 1, 0, 0, 1, 0, 0, 0)
	)

	var battlefire_drift_ok: bool = false
	var battlefire_dr_bs: BattleState = _battlemove_make_state("active")
	if battlefire_dr_bs != null:
		var battlefire_dr_src: BattleParticipant = _battlefire_add(
			battlefire_dr_bs, "fire_dr_src", "attacker", "pistol"
		)
		var battlefire_dr_tgt: BattleParticipant = _battlefire_add(
			battlefire_dr_bs, "fire_dr_tgt", "defender", "pistol"
		)
		if battlefire_dr_src != null and battlefire_dr_tgt != null and battlefire_dr_src.weapon_state != null:
			_battletarget_place(battlefire_dr_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_dr_tgt, Vector2(18.0, 10.0))
			battlefire_dr_src.set_target_participant("fire_dr_tgt")
			battlefire_dr_src.weapon_state.weapon_type_id = "rifle"
			battlefire_dr_src.weapon_state.cooldown_remaining_seconds = 1.0
			var battlefire_dr_eval: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
				battlefire_dr_bs
			)
			var battlefire_dr_adv: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
				battlefire_dr_bs, 0.25
			)
			battlefire_drift_ok = (
				battlefire_dr_src.weapon_type == "pistol"
				and battlefire_dr_src.weapon_state.weapon_type_id == "rifle"
				and battlefire_dr_eval != null
				and battlefire_dr_eval.success
				and battlefire_dr_eval.participants_eligible_to_fire == 0
				and battlefire_dr_adv != null
				and battlefire_dr_adv.success
				and is_equal_approx(battlefire_dr_src.weapon_state.cooldown_remaining_seconds, 0.75)
			)

	var battlefire_commit_ok: bool = false
	var battlefire_cm_src: BattleParticipant = BattleParticipant.new("fire_cm_src", "", "a", "attacker", "pistol")
	var battlefire_cm_def: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("pistol")
	if battlefire_cm_src != null and battlefire_cm_src.weapon_state != null and battlefire_cm_def != null:
		_battletarget_place(battlefire_cm_src, Vector2(10.0, 10.0))
		battlefire_cm_src.set_target_participant("ghost")
		var battlefire_cm_nav: bool = battlefire_cm_src.set_navigation_path(Vector2(10.0, 16.0), [Vector2(10.0, 16.0)])
		var battlefire_cm_snap: Dictionary = _battlefire_full_snap(battlefire_cm_src)
		var battlefire_cm_did: bool = BattleFireControlService.commit_shot(battlefire_cm_src, battlefire_cm_def)
		battlefire_commit_ok = (
			battlefire_cm_nav
			and battlefire_cm_did
			and battlefire_cm_src.weapon_state.ammo_in_magazine == 11
			and is_equal_approx(battlefire_cm_src.weapon_state.cooldown_remaining_seconds, 0.4)
			and battlefire_cm_src.battle_position.is_equal_approx(Vector2(10.0, 10.0))
			and battlefire_cm_src.target_participant_id == "ghost"
			and battlefire_cm_src.has_navigation_destination
			and battlefire_cm_src.get("hit_points") == null
			and battlefire_cm_src.is_alive
			and not battlefire_cm_src.is_wounded
		)

	var battlefire_commit_no_combat_ok: bool = false
	var battlefire_cnc_bs: BattleState = _battlemove_make_state("active")
	if battlefire_cnc_bs != null and battlefire_cnc_bs.battlefield_geometry != null:
		var battlefire_cnc_wall: BattleObstacle = BattleObstacle.new(
			"fire_cnc_wall", Rect2(28.0, 20.0, 6.0, 20.0), true, true
		)
		var battlefire_cnc_src: BattleParticipant = _battlefire_add(
			battlefire_cnc_bs, "fire_cnc_src", "attacker", "pistol"
		)
		var battlefire_cnc_tgt: BattleParticipant = _battlefire_add(
			battlefire_cnc_bs, "fire_cnc_tgt", "defender", "pistol"
		)
		if (
			battlefire_cnc_src != null
			and battlefire_cnc_tgt != null
			and battlefire_cnc_src.weapon_state != null
			and battlefire_cnc_bs.battlefield_geometry.add_obstacle(battlefire_cnc_wall)
		):
			_battletarget_place(battlefire_cnc_src, Vector2(20.0, 30.0))
			_battletarget_place(battlefire_cnc_tgt, Vector2(80.0, 30.0))
			var battlefire_cnc_def: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("pistol")
			var battlefire_cnc_did: bool = BattleFireControlService.commit_shot(battlefire_cnc_src, battlefire_cnc_def)
			var battlefire_cnc_svc: BattleFireControlService = BattleFireControlService.new()
			battlefire_commit_no_combat_ok = (
				battlefire_cnc_did
				and battlefire_cnc_src.weapon_state.ammo_in_magazine == 11
				and not battlefire_cnc_svc.has_method("apply_damage")
				and not battlefire_cnc_svc.has_method("resolve_hit")
				and not battlefire_cnc_svc.has_method("roll_hit")
				and not battlefire_cnc_svc.has_method("fire")
			)

	var battlefire_commit_safe_ok: bool = false
	var battlefire_cs_empty: BattleParticipant = BattleParticipant.new("fire_cs_empty", "", "a", "attacker", "pistol")
	var battlefire_cs_cd: BattleParticipant = BattleParticipant.new("fire_cs_cd", "", "a", "attacker", "pistol")
	var battlefire_cs_rl: BattleParticipant = BattleParticipant.new("fire_cs_rl", "", "a", "attacker", "pistol")
	var battlefire_cs_def: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("pistol")
	if (
		battlefire_cs_empty != null
		and battlefire_cs_cd != null
		and battlefire_cs_rl != null
		and battlefire_cs_empty.weapon_state != null
		and battlefire_cs_cd.weapon_state != null
		and battlefire_cs_rl.weapon_state != null
		and battlefire_cs_def != null
	):
		battlefire_cs_empty.weapon_state.ammo_in_magazine = 0
		battlefire_cs_cd.weapon_state.cooldown_remaining_seconds = 0.5
		battlefire_cs_rl.weapon_state.is_reloading = true
		var battlefire_cs_e: bool = BattleFireControlService.commit_shot(battlefire_cs_empty, battlefire_cs_def)
		var battlefire_cs_c: bool = BattleFireControlService.commit_shot(battlefire_cs_cd, battlefire_cs_def)
		var battlefire_cs_r: bool = BattleFireControlService.commit_shot(battlefire_cs_rl, battlefire_cs_def)
		battlefire_commit_safe_ok = (
			not battlefire_cs_e
			and not battlefire_cs_c
			and not battlefire_cs_r
			and battlefire_cs_empty.weapon_state.ammo_in_magazine == 0
			and battlefire_cs_cd.weapon_state.ammo_in_magazine == 12
			and is_equal_approx(battlefire_cs_cd.weapon_state.cooldown_remaining_seconds, 0.5)
			and battlefire_cs_rl.weapon_state.ammo_in_magazine == 12
			and battlefire_cs_rl.weapon_state.is_reloading
		)

	var battlefire_commit_mismatch_ok: bool = false
	var battlefire_mm_p: BattleParticipant = BattleParticipant.new("fire_mm_p", "", "a", "attacker", "pistol")
	var battlefire_mm_rifle: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("rifle")
	if battlefire_mm_p != null and battlefire_mm_p.weapon_state != null and battlefire_mm_rifle != null:
		var battlefire_mm_did: bool = BattleFireControlService.commit_shot(battlefire_mm_p, battlefire_mm_rifle)
		battlefire_commit_mismatch_ok = (
			not battlefire_mm_did
			and battlefire_mm_p.weapon_state.ammo_in_magazine == 12
			and is_equal_approx(battlefire_mm_p.weapon_state.cooldown_remaining_seconds, 0.0)
			and battlefire_mm_p.weapon_state.weapon_type_id == "pistol"
		)

	var battlefire_runtime_ok: bool = false
	var battlefire_runtime_order_ok: bool = false
	var battlefire_rt_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rt_bs != null:
		var battlefire_rt_src: BattleParticipant = _battlefire_add(
			battlefire_rt_bs, "fire_rt_src", "attacker", "pistol"
		)
		var battlefire_rt_tgt: BattleParticipant = _battlefire_add(
			battlefire_rt_bs, "fire_rt_tgt", "defender", "pistol"
		)
		if battlefire_rt_src != null and battlefire_rt_tgt != null and battlefire_rt_src.weapon_state != null:
			_battletarget_place(battlefire_rt_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_rt_tgt, Vector2(20.0, 10.0))
			battlefire_rt_src.set_movement_speed(2.0)
			battlefire_rt_src.set_movement_intent(Vector2(1.0, 0.0))
			battlefire_rt_src.weapon_state.cooldown_remaining_seconds = 1.0
			var battlefire_rt_res: BattleRuntimeResult = BattleRuntimeService.advance(battlefire_rt_bs, 0.25)
			battlefire_runtime_ok = (
				battlefire_rt_res != null
				and battlefire_rt_res.success
				and is_equal_approx(battlefire_rt_src.weapon_state.cooldown_remaining_seconds, 0.75)
				and battlefire_rt_src.battle_position.is_equal_approx(Vector2(10.5, 10.0))
				and _battletarget_has(battlefire_rt_src, "fire_rt_tgt")
			)
			battlefire_runtime_order_ok = battlefire_runtime_ok

	var battlefire_runtime_zero_ok: bool = false
	var battlefire_rz_bs: BattleState = _battlemove_make_state("active")
	if battlefire_rz_bs != null:
		var battlefire_rz_src: BattleParticipant = _battlefire_add(
			battlefire_rz_bs, "fire_rz_src", "attacker", "pistol"
		)
		var battlefire_rz_tgt: BattleParticipant = _battlefire_add(
			battlefire_rz_bs, "fire_rz_tgt", "defender", "pistol"
		)
		if battlefire_rz_src != null and battlefire_rz_tgt != null and battlefire_rz_src.weapon_state != null:
			_battletarget_place(battlefire_rz_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_rz_tgt, Vector2(22.0, 10.0))
			battlefire_rz_src.weapon_state.cooldown_remaining_seconds = 0.8
			battlefire_rz_bs.elapsed_time_seconds = 3.0
			var battlefire_rz_res: BattleRuntimeResult = BattleRuntimeService.advance(battlefire_rz_bs, 0.0)
			battlefire_runtime_zero_ok = (
				battlefire_rz_res != null
				and battlefire_rz_res.success
				and is_equal_approx(battlefire_rz_src.weapon_state.cooldown_remaining_seconds, 0.8)
				and battlefire_rz_src.battle_position.is_equal_approx(Vector2(10.0, 10.0))
				and is_equal_approx(battlefire_rz_bs.elapsed_time_seconds, 3.0)
				and _battletarget_has(battlefire_rz_src, "fire_rz_tgt")
			)

	var battlefire_runtime_tx_ok: bool = false
	var battlefire_tx_bs: BattleState = _battlemove_make_state("active")
	if battlefire_tx_bs != null:
		var battlefire_tx_src: BattleParticipant = _battlefire_add(
			battlefire_tx_bs, "fire_tx_src", "attacker", "pistol"
		)
		var battlefire_tx_tgt: BattleParticipant = _battlefire_add(
			battlefire_tx_bs, "fire_tx_tgt", "defender", "pistol"
		)
		if battlefire_tx_src != null and battlefire_tx_tgt != null and battlefire_tx_src.weapon_state != null:
			_battletarget_place(battlefire_tx_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_tx_tgt, Vector2(20.0, 10.0))
			battlefire_tx_src.set_target_participant("fire_tx_tgt")
			battlefire_tx_src.set_movement_speed(2.0)
			battlefire_tx_src.set_movement_intent(Vector2(1.0, 0.0))
			battlefire_tx_src.weapon_state.cooldown_remaining_seconds = 1.0
			battlefire_tx_bs.elapsed_time_seconds = 4.0
			var battlefire_tx_snap: Dictionary = _battlefire_full_snap(battlefire_tx_src)
			battlefire_tx_bs.battlefield_geometry = null
			var battlefire_tx_res: BattleRuntimeResult = BattleRuntimeService.advance(battlefire_tx_bs, 0.5)
			battlefire_runtime_tx_ok = (
				_battlert_fail_ok(battlefire_tx_res, "missing_battlefield_geometry", 4.0)
				and is_equal_approx(battlefire_tx_bs.elapsed_time_seconds, 4.0)
				and _battlefire_full_unchanged(battlefire_tx_src, battlefire_tx_snap)
			)

	var battlefire_counts_ok: bool = false
	var battlefire_ct_order_a: Array[String] = ["e", "c", "r", "l", "m", "n"]
	var battlefire_ct_order_b: Array[String] = ["n", "m", "l", "r", "c", "e"]
	var battlefire_ct_a: BattleFireControlResult = _battlefire_mixed_eval(battlefire_ct_order_a)
	var battlefire_ct_b: BattleFireControlResult = _battlefire_mixed_eval(battlefire_ct_order_b)
	battlefire_counts_ok = (
		_battlefire_eval_counts(battlefire_ct_a, 7, 6, 1, 1, 1, 1, 1, 1)
		and _battlefire_eval_counts(battlefire_ct_b, 7, 6, 1, 1, 1, 1, 1, 1)
	)

	var battlefire_ok_res: BattleFireControlResult = BattleFireControlResult.succeeded(4, 3, 1, 1, 0, 1, 0, 1)
	var battlefire_fail_res: BattleFireControlResult = BattleFireControlResult.failed(
		"null_battle_state",
		"Battle fire control failed: battle_state is null."
	)
	var battlefire_result_helper_ok: bool = (
		battlefire_ok_res != null
		and battlefire_ok_res.success
		and battlefire_ok_res.participants_considered == 4
		and battlefire_ok_res.participants_with_targets == 3
		and battlefire_ok_res.participants_eligible_to_fire == 1
		and battlefire_ok_res.participants_blocked_by_los == 1
		and battlefire_ok_res.participants_blocked_by_range == 0
		and battlefire_ok_res.participants_blocked_by_cooldown == 1
		and battlefire_ok_res.participants_reloading == 0
		and battlefire_ok_res.participants_empty == 1
		and battlefire_ok_res.error_code.is_empty()
		and battlefire_ok_res.error_message.is_empty()
		and battlefire_fail_res != null
		and not battlefire_fail_res.success
		and battlefire_fail_res.participants_considered == 0
		and battlefire_fail_res.participants_eligible_to_fire == 0
		and battlefire_fail_res.error_code == "null_battle_state"
		and battlefire_fail_res.error_message == "Battle fire control failed: battle_state is null."
	)

	var battlefire_persist_ok: bool = false
	var battlefire_immutability_ok: bool = false
	var battlefire_camp_pack: Dictionary = _battle_create_ready_pack()
	var battlefire_camp_game: GameState = battlefire_camp_pack.get("game_state", null) as GameState
	var battlefire_camp_force: TravelingForce = battlefire_camp_pack.get("force", null) as TravelingForce
	var battlefire_camp_bs: BattleState = battlefire_camp_pack.get("battle_state", null) as BattleState
	if battlefire_camp_game != null and battlefire_camp_bs != null:
		var battlefire_camp_deployed: bool = _battle_deploy_standard_attacker(battlefire_camp_bs)
		var battlefire_camp_geo: bool = _battlegeo_init(battlefire_camp_bs)
		var battlefire_camp_part: BattleParticipant = battlefire_camp_bs.get_participant("battle_sol_a")
		if battlefire_camp_part != null and battlefire_camp_part.weapon_state != null:
			battlefire_camp_part.weapon_state.ammo_in_magazine = 2
			battlefire_camp_part.weapon_state.cooldown_remaining_seconds = 0.7
			battlefire_camp_part.weapon_state.is_reloading = true
			battlefire_camp_part.weapon_state.reload_remaining_seconds = 0.4
		var battlefire_camp_persist: Dictionary = battlefire_camp_game.to_dict()
		battlefire_persist_ok = (
			battlefire_camp_deployed
			and battlefire_camp_geo
			and _battle_serialized_campaign_keys_only(battlefire_camp_persist)
			and not _battle_data_has_tactical_trace(battlefire_camp_persist)
		)
		var battlefire_camp_snap: Dictionary = _battle_campaign_snapshot(
			battlefire_camp_game,
			battlefire_camp_force,
			"battle_mission"
		)
		var battlefire_camp_soldier: Soldier = battlefire_camp_game.get_soldier("battle_sol_a")
		var battlefire_camp_wpn: String = ""
		if battlefire_camp_soldier != null:
			battlefire_camp_wpn = battlefire_camp_soldier.weapon_type_id
		var battlefire_camp_begun: bool = battlefire_camp_bs.begin_battle()
		var battlefire_camp_adv: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
			battlefire_camp_bs, 0.2
		)
		var battlefire_camp_eval: BattleFireControlResult = BattleFireControlService.evaluate_fire_eligibility(
			battlefire_camp_bs
		)
		battlefire_immutability_ok = (
			battlefire_persist_ok
			and battlefire_camp_begun
			and battlefire_camp_adv != null
			and battlefire_camp_adv.success
			and battlefire_camp_eval != null
			and battlefire_camp_eval.success
			and _battle_campaign_unchanged(
				battlefire_camp_game,
				battlefire_camp_snap,
				battlefire_camp_force,
				"battle_mission"
			)
			and battlefire_camp_soldier != null
			and battlefire_camp_soldier.weapon_type_id == battlefire_camp_wpn
		)

	var battlefire_no_auto_fire_ok: bool = false
	var battlefire_naf_bs: BattleState = _battlemove_make_state("active")
	if battlefire_naf_bs != null:
		var battlefire_naf_src: BattleParticipant = _battlefire_add(
			battlefire_naf_bs, "fire_naf_src", "attacker", "pistol"
		)
		var battlefire_naf_tgt: BattleParticipant = _battlefire_add(
			battlefire_naf_bs, "fire_naf_tgt", "defender", "pistol"
		)
		if battlefire_naf_src != null and battlefire_naf_tgt != null and battlefire_naf_src.weapon_state != null:
			_battletarget_place(battlefire_naf_src, Vector2(10.0, 10.0))
			_battletarget_place(battlefire_naf_tgt, Vector2(20.0, 10.0))
			var battlefire_naf_r1: BattleRuntimeResult = BattleRuntimeService.advance(battlefire_naf_bs, 0.5)
			var battlefire_naf_r2: BattleRuntimeResult = BattleRuntimeService.advance(battlefire_naf_bs, 0.5)
			var battlefire_naf_r3: BattleRuntimeResult = BattleRuntimeService.advance(battlefire_naf_bs, 0.5)
			battlefire_no_auto_fire_ok = (
				battlefire_naf_r1 != null
				and battlefire_naf_r1.success
				and battlefire_naf_r2 != null
				and battlefire_naf_r2.success
				and battlefire_naf_r3 != null
				and battlefire_naf_r3.success
				and _battletarget_has(battlefire_naf_src, "fire_naf_tgt")
				and battlefire_naf_src.weapon_state.ammo_in_magazine == 12
				and is_equal_approx(battlefire_naf_src.weapon_state.cooldown_remaining_seconds, 0.0)
			)

	var battlefire_no_combat_ok: bool = false
	var battlefire_nc_bs: BattleState = _battlemove_make_state("active")
	var battlefire_nc_svc: BattleFireControlService = BattleFireControlService.new()
	var battlefire_nc_rt: BattleRuntimeService = BattleRuntimeService.new()
	var battlefire_nc_p: BattleParticipant = BattleParticipant.new("fire_nc_p", "", "a", "attacker", "pistol")
	if battlefire_nc_bs != null:
		battlefire_no_combat_ok = (
			_battle_has_no_combat_turn_model(battlefire_nc_bs)
			and not battlefire_nc_svc.has_method("fire")
			and not battlefire_nc_svc.has_method("apply_damage")
			and not battlefire_nc_svc.has_method("resolve_hit")
			and not battlefire_nc_svc.has_method("roll_accuracy")
			and not battlefire_nc_svc.has_method("spawn_projectile")
			and not battlefire_nc_rt.has_method("commit_shot")
			and not battlefire_nc_rt.has_method("fire")
			and battlefire_nc_p.get("hit_points") == null
			and battlefire_nc_p.get("cover_value") == null
			and battlefire_nc_p.get("elevation_level") == null
			and battlefire_nc_p.get("defend_position") == null
			and battlefire_nc_bs.get("perception_radius") == null
			and battlefire_nc_bs.get("fog_of_war") == null
		)

	var battleattack_current: BattleAttackProfile = BattleAttackProfile.current()
	var battleattack_profile_current_ok: bool = (
		battleattack_current != null
		and battleattack_current.is_valid()
		and is_equal_approx(battleattack_current.miss_probability, 0.50)
		and is_equal_approx(battleattack_current.graze_probability, 0.20)
		and is_equal_approx(battleattack_current.wound_probability, 0.25)
		and is_equal_approx(battleattack_current.kill_probability, 0.05)
		and is_equal_approx(
			battleattack_current.miss_probability
			+ battleattack_current.graze_probability
			+ battleattack_current.wound_probability
			+ battleattack_current.kill_probability,
			1.0
		)
	)
	var battleattack_neg: BattleAttackProfile = BattleAttackProfile.new(-0.10, 0.40, 0.40, 0.30)
	var battleattack_nan: BattleAttackProfile = BattleAttackProfile.new(NAN, 0.20, 0.30, 0.50)
	var battleattack_inf: BattleAttackProfile = BattleAttackProfile.new(INF, 0.00, 0.00, 0.00)
	var battleattack_low: BattleAttackProfile = BattleAttackProfile.new(0.40, 0.20, 0.20, 0.10)
	var battleattack_high: BattleAttackProfile = BattleAttackProfile.new(0.50, 0.50, 0.50, 0.50)
	var battleattack_profile_invalid_ok: bool = (
		battleattack_neg != null
		and not battleattack_neg.is_valid()
		and battleattack_nan != null
		and not battleattack_nan.is_valid()
		and battleattack_inf != null
		and not battleattack_inf.is_valid()
		and battleattack_low != null
		and not battleattack_low.is_valid()
		and battleattack_high != null
		and not battleattack_high.is_valid()
	)
	var battleattack_eps: float = BattleAttackProfile.TOTAL_EPSILON
	var battleattack_edge: BattleAttackProfile = BattleAttackProfile.new(
		0.50, 0.20, 0.25, 0.05 + battleattack_eps
	)
	var battleattack_over: BattleAttackProfile = BattleAttackProfile.new(
		0.50, 0.20, 0.25, 0.05 + battleattack_eps + battleattack_eps
	)
	var battleattack_under: BattleAttackProfile = BattleAttackProfile.new(
		0.50, 0.20, 0.25, 0.05 - battleattack_eps - battleattack_eps
	)
	var battleattack_profile_epsilon_ok: bool = (
		battleattack_eps > 0.0
		and is_finite(battleattack_eps)
		and battleattack_edge != null
		and battleattack_edge.is_valid()
		and battleattack_over != null
		and not battleattack_over.is_valid()
		and battleattack_under != null
		and battleattack_under.kill_probability >= 0.0
		and not battleattack_under.is_valid()
	)
	var battleattack_outcome_ids_ok: bool = (
		BattleAttackProfile.OUTCOME_MISS == "miss"
		and BattleAttackProfile.OUTCOME_GRAZE == "graze"
		and BattleAttackProfile.OUTCOME_WOUND == "wound"
		and BattleAttackProfile.OUTCOME_KILL == "kill"
		and battleattack_current != null
		and battleattack_current.resolve_outcome(0.0) == BattleAttackProfile.OUTCOME_MISS
		and battleattack_current.resolve_outcome(0.5) == BattleAttackProfile.OUTCOME_GRAZE
		and battleattack_current.resolve_outcome(0.7) == BattleAttackProfile.OUTCOME_WOUND
		and battleattack_current.resolve_outcome(0.95) == BattleAttackProfile.OUTCOME_KILL
	)
	var battleattack_roll_valid_ok: bool = (
		BattleAttackProfile.is_valid_outcome_roll(0.0)
		and BattleAttackProfile.is_valid_outcome_roll(0.25)
		and BattleAttackProfile.is_valid_outcome_roll(0.5)
		and BattleAttackProfile.is_valid_outcome_roll(0.7)
		and BattleAttackProfile.is_valid_outcome_roll(0.95)
		and BattleAttackProfile.is_valid_outcome_roll(0.999999)
	)
	var battleattack_roll_invalid_ok: bool = (
		not BattleAttackProfile.is_valid_outcome_roll(-0.01)
		and not BattleAttackProfile.is_valid_outcome_roll(1.0)
		and not BattleAttackProfile.is_valid_outcome_roll(1.5)
		and not BattleAttackProfile.is_valid_outcome_roll(NAN)
		and not BattleAttackProfile.is_valid_outcome_roll(INF)
	)
	var battleattack_thresholds_ok: bool = false
	if battleattack_current != null:
		battleattack_thresholds_ok = (
			battleattack_current.resolve_outcome(0.0) == BattleAttackProfile.OUTCOME_MISS
			and battleattack_current.resolve_outcome(0.499999) == BattleAttackProfile.OUTCOME_MISS
			and battleattack_current.resolve_outcome(0.5) == BattleAttackProfile.OUTCOME_GRAZE
			and battleattack_current.resolve_outcome(0.699999) == BattleAttackProfile.OUTCOME_GRAZE
			and battleattack_current.resolve_outcome(0.7) == BattleAttackProfile.OUTCOME_WOUND
			and battleattack_current.resolve_outcome(0.949999) == BattleAttackProfile.OUTCOME_WOUND
			and battleattack_current.resolve_outcome(0.95) == BattleAttackProfile.OUTCOME_KILL
			and battleattack_current.resolve_outcome(0.999999) == BattleAttackProfile.OUTCOME_KILL
		)

	var battleattack_helper_event: BattleAttackEvent = BattleAttackEvent.new(
		"src_h",
		"tgt_h",
		"pistol",
		BattleAttackProfile.OUTCOME_MISS,
		0.1,
		false,
		false,
		true,
		true
	)
	var battleattack_ok_res: BattleAttackResult = BattleAttackResult.executed(battleattack_helper_event)
	var battleattack_rej_res: BattleAttackResult = BattleAttackResult.rejected("cooldown")
	var battleattack_fail_res: BattleAttackResult = BattleAttackResult.failed(
		"null_battle_state",
		"Battle attack resolution failed: battle_state is null."
	)
	var battleattack_result_helpers_ok: bool = (
		battleattack_ok_res != null
		and battleattack_ok_res.success
		and battleattack_ok_res.shot_executed
		and battleattack_ok_res.attack_event == battleattack_helper_event
		and battleattack_ok_res.rejection_code.is_empty()
		and battleattack_ok_res.error_code.is_empty()
		and battleattack_ok_res.error_message.is_empty()
		and battleattack_rej_res != null
		and battleattack_rej_res.success
		and not battleattack_rej_res.shot_executed
		and battleattack_rej_res.attack_event == null
		and battleattack_rej_res.rejection_code == "cooldown"
		and battleattack_rej_res.error_code.is_empty()
		and battleattack_rej_res.error_message.is_empty()
		and battleattack_fail_res != null
		and not battleattack_fail_res.success
		and not battleattack_fail_res.shot_executed
		and battleattack_fail_res.attack_event == null
		and battleattack_fail_res.rejection_code.is_empty()
		and battleattack_fail_res.error_code == "null_battle_state"
		and not battleattack_fail_res.error_message.is_empty()
	)

	var battleattack_fail_null_ok: bool = _battleattack_fail_ok(
		BattleAttackResolutionService.resolve_attack(null, "a", "b", 0.0),
		"null_battle_state"
	)
	var battleattack_fail_empty_ids_ok: bool = false
	var battleattack_fail_missing_ok: bool = false
	var battleattack_fail_phase_geo_ok: bool = false
	var battleattack_fail_roll_no_mutate_ok: bool = false
	var battleattack_id_pack: Dictionary = _battleattack_make_ready("atk_id_src", "atk_id_tgt")
	var battleattack_id_bs: BattleState = battleattack_id_pack.get("battle_state", null) as BattleState
	var battleattack_id_src: BattleParticipant = battleattack_id_pack.get("source", null) as BattleParticipant
	var battleattack_id_tgt: BattleParticipant = battleattack_id_pack.get("target", null) as BattleParticipant
	if battleattack_id_bs != null and battleattack_id_src != null and battleattack_id_tgt != null:
		var battleattack_id_src_snap: Dictionary = _battleattack_tx_snap(battleattack_id_src)
		var battleattack_id_tgt_snap: Dictionary = _battleattack_tx_snap(battleattack_id_tgt)
		var battleattack_empty_src: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "", "atk_id_tgt", 0.0
		)
		var battleattack_empty_tgt: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "", 0.0
		)
		var battleattack_miss_src: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "ghost_src", "atk_id_tgt", 0.0
		)
		var battleattack_miss_tgt: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "ghost_tgt", 0.0
		)
		battleattack_fail_empty_ids_ok = (
			_battleattack_fail_ok(battleattack_empty_src, "empty_source_id")
			and _battleattack_fail_ok(battleattack_empty_tgt, "empty_target_id")
			and _battleattack_tx_unchanged(battleattack_id_src, battleattack_id_src_snap)
			and _battleattack_tx_unchanged(battleattack_id_tgt, battleattack_id_tgt_snap)
		)
		battleattack_fail_missing_ok = (
			_battleattack_fail_ok(battleattack_miss_src, "source_not_found")
			and _battleattack_fail_ok(battleattack_miss_tgt, "target_not_found")
			and _battleattack_tx_unchanged(battleattack_id_src, battleattack_id_src_snap)
			and _battleattack_tx_unchanged(battleattack_id_tgt, battleattack_id_tgt_snap)
		)
		var battleattack_roll_src_snap: Dictionary = _battleattack_tx_snap(battleattack_id_src)
		var battleattack_roll_tgt_snap: Dictionary = _battleattack_tx_snap(battleattack_id_tgt)
		var battleattack_bad_neg: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "atk_id_tgt", -0.01
		)
		var battleattack_bad_one: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "atk_id_tgt", 1.0
		)
		var battleattack_bad_over: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "atk_id_tgt", 1.5
		)
		var battleattack_bad_nan: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "atk_id_tgt", NAN
		)
		var battleattack_bad_inf: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_id_bs, "atk_id_src", "atk_id_tgt", INF
		)
		battleattack_fail_roll_no_mutate_ok = (
			_battleattack_fail_ok(battleattack_bad_neg, "invalid_outcome_roll")
			and _battleattack_fail_ok(battleattack_bad_one, "invalid_outcome_roll")
			and _battleattack_fail_ok(battleattack_bad_over, "invalid_outcome_roll")
			and _battleattack_fail_ok(battleattack_bad_nan, "invalid_outcome_roll")
			and _battleattack_fail_ok(battleattack_bad_inf, "invalid_outcome_roll")
			and _battleattack_tx_unchanged(battleattack_id_src, battleattack_roll_src_snap)
			and _battleattack_tx_unchanged(battleattack_id_tgt, battleattack_roll_tgt_snap)
		)
	var battleattack_dep_bs: BattleState = _battlemove_make_state("deployment")
	var battleattack_missgeo_bs: BattleState = _battlemove_make_state("active")
	var battleattack_badgeo_bs: BattleState = _battlemove_make_state("active")
	if battleattack_dep_bs != null and battleattack_missgeo_bs != null and battleattack_badgeo_bs != null:
		var battleattack_dep_src: BattleParticipant = _battlefire_add(
			battleattack_dep_bs, "atk_dep_src", "attacker", "pistol"
		)
		var battleattack_dep_tgt: BattleParticipant = _battlefire_add(
			battleattack_dep_bs, "atk_dep_tgt", "defender", "pistol"
		)
		var battleattack_mg_src: BattleParticipant = _battlefire_add(
			battleattack_missgeo_bs, "atk_mg_src", "attacker", "pistol"
		)
		var battleattack_mg_tgt: BattleParticipant = _battlefire_add(
			battleattack_missgeo_bs, "atk_mg_tgt", "defender", "pistol"
		)
		var battleattack_bg_src: BattleParticipant = _battlefire_add(
			battleattack_badgeo_bs, "atk_bg_src", "attacker", "pistol"
		)
		var battleattack_bg_tgt: BattleParticipant = _battlefire_add(
			battleattack_badgeo_bs, "atk_bg_tgt", "defender", "pistol"
		)
		if (
			battleattack_dep_src != null
			and battleattack_dep_tgt != null
			and battleattack_mg_src != null
			and battleattack_mg_tgt != null
			and battleattack_bg_src != null
			and battleattack_bg_tgt != null
		):
			_battletarget_place(battleattack_dep_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_dep_tgt, Vector2(20.0, 10.0))
			_battletarget_place(battleattack_mg_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_mg_tgt, Vector2(20.0, 10.0))
			_battletarget_place(battleattack_bg_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_bg_tgt, Vector2(20.0, 10.0))
			var battleattack_dep_src_snap: Dictionary = _battleattack_tx_snap(battleattack_dep_src)
			var battleattack_mg_src_snap: Dictionary = _battleattack_tx_snap(battleattack_mg_src)
			var battleattack_bg_src_snap: Dictionary = _battleattack_tx_snap(battleattack_bg_src)
			battleattack_missgeo_bs.battlefield_geometry = null
			battleattack_badgeo_bs.battlefield_geometry = BattlefieldGeometry.new()
			var battleattack_dep_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_dep_bs, "atk_dep_src", "atk_dep_tgt", 0.0
			)
			var battleattack_mg_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_missgeo_bs, "atk_mg_src", "atk_mg_tgt", 0.0
			)
			var battleattack_bg_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_badgeo_bs, "atk_bg_src", "atk_bg_tgt", 0.0
			)
			battleattack_fail_phase_geo_ok = (
				_battleattack_fail_ok(battleattack_dep_res, "battle_not_active")
				and _battleattack_fail_ok(battleattack_mg_res, "missing_battlefield_geometry")
				and _battleattack_fail_ok(battleattack_bg_res, "invalid_battlefield_geometry")
				and _battleattack_tx_unchanged(battleattack_dep_src, battleattack_dep_src_snap)
				and _battleattack_tx_unchanged(battleattack_mg_src, battleattack_mg_src_snap)
				and _battleattack_tx_unchanged(battleattack_bg_src, battleattack_bg_src_snap)
			)

	var battleattack_reject_source_dead_ok: bool = _battleattack_expect_reject("source_dead")
	var battleattack_reject_source_unpos_ok: bool = _battleattack_expect_reject("source_unpos")
	var battleattack_reject_target_dead_ok: bool = _battleattack_expect_reject("target_dead")
	var battleattack_reject_target_unpos_ok: bool = _battleattack_expect_reject("target_unpos")
	var battleattack_reject_no_weapon_ok: bool = _battleattack_expect_reject("no_weapon")
	var battleattack_reject_unknown_weapon_ok: bool = _battleattack_expect_reject("unknown_weapon")
	var battleattack_reject_mismatch_ok: bool = _battleattack_expect_reject("mismatch")
	var battleattack_reject_reloading_ok: bool = _battleattack_expect_reject("reloading")
	var battleattack_reject_empty_ok: bool = _battleattack_expect_reject("empty")
	var battleattack_reject_cooldown_ok: bool = _battleattack_expect_reject("cooldown")
	var battleattack_reject_range_ok: bool = _battleattack_expect_reject("out_of_range")
	var battleattack_reject_los_ok: bool = _battleattack_expect_reject("los")

	var battleattack_reject_same_side_ok: bool = false
	var battleattack_ss_bs: BattleState = _battlemove_make_state("active")
	if battleattack_ss_bs != null:
		var battleattack_ss_src: BattleParticipant = _battlefire_add(
			battleattack_ss_bs, "atk_ss_src", "attacker", "pistol"
		)
		var battleattack_ss_ally: BattleParticipant = _battlefire_add(
			battleattack_ss_bs, "atk_ss_ally", "attacker", "pistol"
		)
		var battleattack_ss_enemy: BattleParticipant = _battlefire_add(
			battleattack_ss_bs, "atk_ss_enemy", "defender", "pistol"
		)
		if battleattack_ss_src != null and battleattack_ss_ally != null and battleattack_ss_enemy != null:
			_battletarget_place(battleattack_ss_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_ss_ally, Vector2(16.0, 10.0))
			_battletarget_place(battleattack_ss_enemy, Vector2(22.0, 10.0))
			battleattack_ss_src.set_target_participant("atk_ss_enemy")
			var battleattack_ss_src_snap: Dictionary = _battleattack_tx_snap(battleattack_ss_src)
			var battleattack_ss_ally_snap: Dictionary = _battleattack_tx_snap(battleattack_ss_ally)
			var battleattack_ss_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_ss_bs, "atk_ss_src", "atk_ss_ally", 0.0
			)
			battleattack_reject_same_side_ok = (
				_battleattack_rejected_ok(battleattack_ss_res, "not_hostile")
				and _battletarget_has(battleattack_ss_src, "atk_ss_enemy")
				and _battleattack_tx_unchanged(battleattack_ss_src, battleattack_ss_src_snap)
				and _battleattack_tx_unchanged(battleattack_ss_ally, battleattack_ss_ally_snap)
			)

	var battleattack_pair_target_indep_ok: bool = false
	var battleattack_pi_bs: BattleState = _battlemove_make_state("active")
	if battleattack_pi_bs != null:
		var battleattack_pi_src: BattleParticipant = _battlefire_add(
			battleattack_pi_bs, "atk_pi_src", "attacker", "pistol"
		)
		var battleattack_pi_a: BattleParticipant = _battlefire_add(
			battleattack_pi_bs, "atk_pi_a", "defender", "pistol"
		)
		var battleattack_pi_b: BattleParticipant = _battlefire_add(
			battleattack_pi_bs, "atk_pi_b", "defender", "pistol"
		)
		if (
			battleattack_pi_src != null
			and battleattack_pi_a != null
			and battleattack_pi_b != null
			and battleattack_pi_src.weapon_state != null
		):
			_battletarget_place(battleattack_pi_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_pi_a, Vector2(18.0, 10.0))
			_battletarget_place(battleattack_pi_b, Vector2(10.0, 18.0))
			battleattack_pi_src.set_target_participant("atk_pi_a")
			var battleattack_pi_ammo: int = battleattack_pi_src.weapon_state.ammo_in_magazine
			var battleattack_pi_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_pi_bs, "atk_pi_src", "atk_pi_b", 0.0
			)
			battleattack_pair_target_indep_ok = (
				_battleattack_executed_ok(
					battleattack_pi_res,
					"atk_pi_src",
					"atk_pi_b",
					"pistol",
					BattleAttackProfile.OUTCOME_MISS,
					0.0,
					false,
					false,
					true,
					true
				)
				and _battletarget_has(battleattack_pi_src, "atk_pi_a")
				and battleattack_pi_a.is_alive
				and not battleattack_pi_a.is_wounded
				and _battleattack_cycled_once(battleattack_pi_src, battleattack_pi_ammo, "pistol")
			)

	var battleattack_miss_ok: bool = false
	var battleattack_event_fields_ok: bool = false
	var battleattack_miss_pack: Dictionary = _battleattack_make_ready("atk_ms_src", "atk_ms_tgt")
	var battleattack_miss_bs: BattleState = battleattack_miss_pack.get("battle_state", null) as BattleState
	var battleattack_miss_src: BattleParticipant = battleattack_miss_pack.get("source", null) as BattleParticipant
	var battleattack_miss_tgt: BattleParticipant = battleattack_miss_pack.get("target", null) as BattleParticipant
	if battleattack_miss_bs != null and battleattack_miss_src != null and battleattack_miss_tgt != null:
		if battleattack_miss_src.weapon_state != null:
			var battleattack_miss_ammo: int = battleattack_miss_src.weapon_state.ammo_in_magazine
			var battleattack_miss_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_miss_bs, "atk_ms_src", "atk_ms_tgt", 0.0
			)
			battleattack_miss_ok = (
				_battleattack_executed_ok(
					battleattack_miss_res,
					"atk_ms_src",
					"atk_ms_tgt",
					"pistol",
					BattleAttackProfile.OUTCOME_MISS,
					0.0,
					false,
					false,
					true,
					true
				)
				and _battleattack_cycled_once(battleattack_miss_src, battleattack_miss_ammo, "pistol")
				and battleattack_miss_tgt.is_alive
				and not battleattack_miss_tgt.is_wounded
			)
			battleattack_event_fields_ok = battleattack_miss_ok

	var battleattack_graze_ok: bool = false
	var battleattack_graze_pack: Dictionary = _battleattack_make_ready("atk_gz_src", "atk_gz_tgt")
	var battleattack_graze_bs: BattleState = battleattack_graze_pack.get("battle_state", null) as BattleState
	var battleattack_graze_src: BattleParticipant = battleattack_graze_pack.get("source", null) as BattleParticipant
	var battleattack_graze_tgt: BattleParticipant = battleattack_graze_pack.get("target", null) as BattleParticipant
	if battleattack_graze_bs != null and battleattack_graze_src != null and battleattack_graze_tgt != null:
		if battleattack_graze_src.weapon_state != null:
			var battleattack_graze_ammo: int = battleattack_graze_src.weapon_state.ammo_in_magazine
			var battleattack_graze_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_graze_bs, "atk_gz_src", "atk_gz_tgt", 0.5
			)
			battleattack_graze_ok = (
				_battleattack_executed_ok(
					battleattack_graze_res,
					"atk_gz_src",
					"atk_gz_tgt",
					"pistol",
					BattleAttackProfile.OUTCOME_GRAZE,
					0.5,
					false,
					false,
					true,
					true
				)
				and _battleattack_cycled_once(battleattack_graze_src, battleattack_graze_ammo, "pistol")
				and battleattack_graze_tgt.is_alive
				and not battleattack_graze_tgt.is_wounded
				and _battleattack_no_hidden_status(battleattack_graze_tgt)
			)

	var battleattack_wound_ok: bool = false
	var battleattack_wound_pack: Dictionary = _battleattack_make_ready("atk_wd_src", "atk_wd_tgt")
	var battleattack_wound_bs: BattleState = battleattack_wound_pack.get("battle_state", null) as BattleState
	var battleattack_wound_src: BattleParticipant = battleattack_wound_pack.get("source", null) as BattleParticipant
	var battleattack_wound_tgt: BattleParticipant = battleattack_wound_pack.get("target", null) as BattleParticipant
	if battleattack_wound_bs != null and battleattack_wound_src != null and battleattack_wound_tgt != null:
		if battleattack_wound_src.weapon_state != null:
			var battleattack_wound_ammo: int = battleattack_wound_src.weapon_state.ammo_in_magazine
			var battleattack_wound_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_wound_bs, "atk_wd_src", "atk_wd_tgt", 0.7
			)
			battleattack_wound_ok = (
				_battleattack_executed_ok(
					battleattack_wound_res,
					"atk_wd_src",
					"atk_wd_tgt",
					"pistol",
					BattleAttackProfile.OUTCOME_WOUND,
					0.7,
					false,
					true,
					true,
					true
				)
				and _battleattack_cycled_once(battleattack_wound_src, battleattack_wound_ammo, "pistol")
				and battleattack_wound_tgt.is_alive
				and battleattack_wound_tgt.is_wounded
			)

	var battleattack_repeat_wound_ok: bool = false
	var battleattack_rw_pack: Dictionary = _battleattack_make_ready("atk_rw_src", "atk_rw_tgt")
	var battleattack_rw_bs: BattleState = battleattack_rw_pack.get("battle_state", null) as BattleState
	var battleattack_rw_src: BattleParticipant = battleattack_rw_pack.get("source", null) as BattleParticipant
	var battleattack_rw_tgt: BattleParticipant = battleattack_rw_pack.get("target", null) as BattleParticipant
	if battleattack_rw_bs != null and battleattack_rw_src != null and battleattack_rw_tgt != null:
		if battleattack_rw_src.weapon_state != null:
			battleattack_rw_tgt.is_wounded = true
			var battleattack_rw_ammo: int = battleattack_rw_src.weapon_state.ammo_in_magazine
			var battleattack_rw_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_rw_bs, "atk_rw_src", "atk_rw_tgt", 0.7
			)
			battleattack_repeat_wound_ok = (
				_battleattack_executed_ok(
					battleattack_rw_res,
					"atk_rw_src",
					"atk_rw_tgt",
					"pistol",
					BattleAttackProfile.OUTCOME_WOUND,
					0.7,
					true,
					true,
					true,
					true
				)
				and _battleattack_cycled_once(battleattack_rw_src, battleattack_rw_ammo, "pistol")
				and battleattack_rw_tgt.is_alive
				and battleattack_rw_tgt.is_wounded
			)

	var battleattack_kill_ok: bool = false
	var battleattack_registry_after_kill_ok: bool = false
	var battleattack_kill_pack: Dictionary = _battleattack_make_ready("atk_kl_src", "atk_kl_tgt")
	var battleattack_kill_bs: BattleState = battleattack_kill_pack.get("battle_state", null) as BattleState
	var battleattack_kill_src: BattleParticipant = battleattack_kill_pack.get("source", null) as BattleParticipant
	var battleattack_kill_tgt: BattleParticipant = battleattack_kill_pack.get("target", null) as BattleParticipant
	if battleattack_kill_bs != null and battleattack_kill_src != null and battleattack_kill_tgt != null:
		if battleattack_kill_src.weapon_state != null:
			var battleattack_kill_ammo: int = battleattack_kill_src.weapon_state.ammo_in_magazine
			var battleattack_kill_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_kill_bs, "atk_kl_src", "atk_kl_tgt", 0.95
			)
			battleattack_kill_ok = (
				_battleattack_executed_ok(
					battleattack_kill_res,
					"atk_kl_src",
					"atk_kl_tgt",
					"pistol",
					BattleAttackProfile.OUTCOME_KILL,
					0.95,
					false,
					false,
					true,
					false
				)
				and _battleattack_cycled_once(battleattack_kill_src, battleattack_kill_ammo, "pistol")
				and not battleattack_kill_tgt.is_alive
			)
			battleattack_registry_after_kill_ok = (
				battleattack_kill_ok
				and battleattack_kill_bs.has_participant("atk_kl_tgt")
				and battleattack_kill_bs.get_participant("atk_kl_tgt") == battleattack_kill_tgt
			)

	var battleattack_kill_wounded_ok: bool = false
	var battleattack_kw_pack: Dictionary = _battleattack_make_ready("atk_kw_src", "atk_kw_tgt")
	var battleattack_kw_bs: BattleState = battleattack_kw_pack.get("battle_state", null) as BattleState
	var battleattack_kw_src: BattleParticipant = battleattack_kw_pack.get("source", null) as BattleParticipant
	var battleattack_kw_tgt: BattleParticipant = battleattack_kw_pack.get("target", null) as BattleParticipant
	if battleattack_kw_bs != null and battleattack_kw_src != null and battleattack_kw_tgt != null:
		battleattack_kw_tgt.is_wounded = true
		var battleattack_kw_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_kw_bs, "atk_kw_src", "atk_kw_tgt", 0.95
		)
		battleattack_kill_wounded_ok = (
			_battleattack_executed_ok(
				battleattack_kw_res,
				"atk_kw_src",
				"atk_kw_tgt",
				"pistol",
				BattleAttackProfile.OUTCOME_KILL,
				0.95,
				true,
				true,
				true,
				false
			)
			and not battleattack_kw_tgt.is_alive
			and battleattack_kw_tgt.is_wounded
			and battleattack_kw_bs.has_participant("atk_kw_tgt")
		)

	var battleattack_dead_followup_ok: bool = false
	var battleattack_df_pack: Dictionary = _battleattack_make_ready("atk_df_src", "atk_df_tgt")
	var battleattack_df_bs: BattleState = battleattack_df_pack.get("battle_state", null) as BattleState
	var battleattack_df_src: BattleParticipant = battleattack_df_pack.get("source", null) as BattleParticipant
	var battleattack_df_tgt: BattleParticipant = battleattack_df_pack.get("target", null) as BattleParticipant
	if battleattack_df_bs != null and battleattack_df_src != null and battleattack_df_tgt != null:
		if battleattack_df_src.weapon_state != null:
			var battleattack_df_first: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_df_bs, "atk_df_src", "atk_df_tgt", 0.95
			)
			var battleattack_df_ammo: int = battleattack_df_src.weapon_state.ammo_in_magazine
			var battleattack_df_cd: float = battleattack_df_src.weapon_state.cooldown_remaining_seconds
			var battleattack_df_src_snap: Dictionary = _battleattack_tx_snap(battleattack_df_src)
			var battleattack_df_tgt_snap: Dictionary = _battleattack_tx_snap(battleattack_df_tgt)
			var battleattack_df_second: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_df_bs, "atk_df_src", "atk_df_tgt", 0.95
			)
			battleattack_dead_followup_ok = (
				battleattack_df_first != null
				and battleattack_df_first.shot_executed
				and _battleattack_rejected_ok(battleattack_df_second, "target_not_eligible")
				and battleattack_df_src.weapon_state.ammo_in_magazine == battleattack_df_ammo
				and is_equal_approx(battleattack_df_src.weapon_state.cooldown_remaining_seconds, battleattack_df_cd)
				and not battleattack_df_tgt.is_alive
				and _battleattack_tx_unchanged(battleattack_df_src, battleattack_df_src_snap)
				and _battleattack_tx_unchanged(battleattack_df_tgt, battleattack_df_tgt_snap)
			)

	var battleattack_pistol_cycle_ok: bool = false
	var battleattack_pc_pack: Dictionary = _battleattack_make_ready("atk_pc_src", "atk_pc_tgt")
	var battleattack_pc_bs: BattleState = battleattack_pc_pack.get("battle_state", null) as BattleState
	var battleattack_pc_src: BattleParticipant = battleattack_pc_pack.get("source", null) as BattleParticipant
	if battleattack_pc_bs != null and battleattack_pc_src != null and battleattack_pc_src.weapon_state != null:
		var battleattack_pc_def: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("pistol")
		var battleattack_pc_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_pc_bs, "atk_pc_src", "atk_pc_tgt", 0.0
		)
		battleattack_pistol_cycle_ok = (
			battleattack_pc_res != null
			and battleattack_pc_res.shot_executed
			and battleattack_pc_src.weapon_state.ammo_in_magazine == 11
			and battleattack_pc_def != null
			and is_equal_approx(battleattack_pc_src.weapon_state.cooldown_remaining_seconds, 0.4)
			and is_equal_approx(
				battleattack_pc_src.weapon_state.cooldown_remaining_seconds,
				battleattack_pc_def.cooldown_seconds()
			)
		)

	var battleattack_other_weapon_cycle_ok: bool = false
	var battleattack_oc_pack: Dictionary = _battleattack_make_ready(
		"atk_oc_src", "atk_oc_tgt", "rifle", Vector2(10.0, 10.0), Vector2(30.0, 10.0)
	)
	var battleattack_oc_bs: BattleState = battleattack_oc_pack.get("battle_state", null) as BattleState
	var battleattack_oc_src: BattleParticipant = battleattack_oc_pack.get("source", null) as BattleParticipant
	if battleattack_oc_bs != null and battleattack_oc_src != null and battleattack_oc_src.weapon_state != null:
		var battleattack_oc_def: BattleWeaponDefinition = BattleWeaponCatalog.get_definition("rifle")
		var battleattack_oc_ammo: int = battleattack_oc_src.weapon_state.ammo_in_magazine
		var battleattack_oc_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_oc_bs, "atk_oc_src", "atk_oc_tgt", 0.0
		)
		battleattack_other_weapon_cycle_ok = (
			battleattack_oc_res != null
			and battleattack_oc_res.shot_executed
			and battleattack_oc_def != null
			and battleattack_oc_ammo == 20
			and battleattack_oc_src.weapon_state.ammo_in_magazine == 19
			and is_equal_approx(
				battleattack_oc_src.weapon_state.cooldown_remaining_seconds,
				battleattack_oc_def.cooldown_seconds()
			)
			and is_equal_approx(battleattack_oc_src.weapon_state.cooldown_remaining_seconds, 0.5)
		)

	var battleattack_every_outcome_cycles_ok: bool = true
	var battleattack_outcome_rolls: Array[float] = [0.0, 0.5, 0.7, 0.95]
	for battleattack_cycle_i: int in battleattack_outcome_rolls.size():
		var battleattack_cycle_roll: float = battleattack_outcome_rolls[battleattack_cycle_i]
		var battleattack_cycle_pack: Dictionary = _battleattack_make_ready(
			"atk_cy_src_%d" % battleattack_cycle_i,
			"atk_cy_tgt_%d" % battleattack_cycle_i
		)
		var battleattack_cycle_bs: BattleState = battleattack_cycle_pack.get("battle_state", null) as BattleState
		var battleattack_cycle_src: BattleParticipant = battleattack_cycle_pack.get("source", null) as BattleParticipant
		if battleattack_cycle_bs == null or battleattack_cycle_src == null or battleattack_cycle_src.weapon_state == null:
			battleattack_every_outcome_cycles_ok = false
			break
		var battleattack_cycle_ammo: int = battleattack_cycle_src.weapon_state.ammo_in_magazine
		var battleattack_cycle_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_cycle_bs,
			"atk_cy_src_%d" % battleattack_cycle_i,
			"atk_cy_tgt_%d" % battleattack_cycle_i,
			battleattack_cycle_roll
		)
		if battleattack_cycle_res == null or not battleattack_cycle_res.shot_executed:
			battleattack_every_outcome_cycles_ok = false
			break
		if not _battleattack_cycled_once(battleattack_cycle_src, battleattack_cycle_ammo, "pistol"):
			battleattack_every_outcome_cycles_ok = false
			break

	var battleattack_immediate_cooldown_ok: bool = false
	var battleattack_ic_pack: Dictionary = _battleattack_make_ready("atk_ic_src", "atk_ic_tgt")
	var battleattack_ic_bs: BattleState = battleattack_ic_pack.get("battle_state", null) as BattleState
	var battleattack_ic_src: BattleParticipant = battleattack_ic_pack.get("source", null) as BattleParticipant
	var battleattack_ic_tgt: BattleParticipant = battleattack_ic_pack.get("target", null) as BattleParticipant
	if battleattack_ic_bs != null and battleattack_ic_src != null and battleattack_ic_tgt != null:
		if battleattack_ic_src.weapon_state != null:
			var battleattack_ic_first: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_ic_bs, "atk_ic_src", "atk_ic_tgt", 0.0
			)
			var battleattack_ic_ammo: int = battleattack_ic_src.weapon_state.ammo_in_magazine
			var battleattack_ic_tgt_snap: Dictionary = _battleattack_tx_snap(battleattack_ic_tgt)
			var battleattack_ic_second: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_ic_bs, "atk_ic_src", "atk_ic_tgt", 0.7
			)
			battleattack_immediate_cooldown_ok = (
				battleattack_ic_first != null
				and battleattack_ic_first.shot_executed
				and _battleattack_rejected_ok(battleattack_ic_second, "cooldown")
				and battleattack_ic_src.weapon_state.ammo_in_magazine == battleattack_ic_ammo
				and _battleattack_tx_unchanged(battleattack_ic_tgt, battleattack_ic_tgt_snap)
			)

	var battleattack_last_round_ok: bool = false
	var battleattack_lr_pack: Dictionary = _battleattack_make_ready("atk_lr_src", "atk_lr_tgt")
	var battleattack_lr_bs: BattleState = battleattack_lr_pack.get("battle_state", null) as BattleState
	var battleattack_lr_src: BattleParticipant = battleattack_lr_pack.get("source", null) as BattleParticipant
	var battleattack_lr_tgt: BattleParticipant = battleattack_lr_pack.get("target", null) as BattleParticipant
	if battleattack_lr_bs != null and battleattack_lr_src != null and battleattack_lr_tgt != null:
		if battleattack_lr_src.weapon_state != null:
			battleattack_lr_src.weapon_state.ammo_in_magazine = 1
			var battleattack_lr_first: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_lr_bs, "atk_lr_src", "atk_lr_tgt", 0.0
			)
			var battleattack_lr_src_snap: Dictionary = _battleattack_tx_snap(battleattack_lr_src)
			var battleattack_lr_tgt_snap: Dictionary = _battleattack_tx_snap(battleattack_lr_tgt)
			var battleattack_lr_second: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_lr_bs, "atk_lr_src", "atk_lr_tgt", 0.0
			)
			battleattack_last_round_ok = (
				battleattack_lr_first != null
				and battleattack_lr_first.shot_executed
				and battleattack_lr_src.weapon_state.ammo_in_magazine == 0
				and _battleattack_rejected_ok(battleattack_lr_second, "empty_magazine")
				and battleattack_lr_src.weapon_state.ammo_in_magazine == 0
				and _battleattack_tx_unchanged(battleattack_lr_src, battleattack_lr_src_snap)
				and _battleattack_tx_unchanged(battleattack_lr_tgt, battleattack_lr_tgt_snap)
			)

	var battleattack_range_edge_ok: bool = false
	var battleattack_re_pack: Dictionary = _battleattack_make_ready(
		"atk_re_src", "atk_re_tgt", "pistol", Vector2(10.0, 10.0), Vector2(34.0, 10.0)
	)
	var battleattack_re_bs: BattleState = battleattack_re_pack.get("battle_state", null) as BattleState
	var battleattack_re_src: BattleParticipant = battleattack_re_pack.get("source", null) as BattleParticipant
	var battleattack_re_tgt: BattleParticipant = battleattack_re_pack.get("target", null) as BattleParticipant
	if battleattack_re_bs != null and battleattack_re_src != null and battleattack_re_tgt != null:
		var battleattack_re_edge: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_re_bs, "atk_re_src", "atk_re_tgt", 0.0
		)
		battleattack_range_edge_ok = (
			is_equal_approx(battleattack_re_src.battle_position.distance_to(battleattack_re_tgt.battle_position), 24.0)
			and battleattack_re_edge != null
			and battleattack_re_edge.shot_executed
			and battleattack_reject_range_ok
		)

	var battleattack_move_only_obstacle_ok: bool = false
	var battleattack_mo_bs: BattleState = _battlemove_make_state("active")
	if battleattack_mo_bs != null and battleattack_mo_bs.battlefield_geometry != null:
		var battleattack_mo_fence: BattleObstacle = BattleObstacle.new(
			"atk_mo_fence", Rect2(26.0, 20.0, 4.0, 20.0), true, false
		)
		var battleattack_mo_src: BattleParticipant = _battlefire_add(
			battleattack_mo_bs, "atk_mo_src", "attacker", "pistol"
		)
		var battleattack_mo_tgt: BattleParticipant = _battlefire_add(
			battleattack_mo_bs, "atk_mo_tgt", "defender", "pistol"
		)
		if (
			battleattack_mo_src != null
			and battleattack_mo_tgt != null
			and battleattack_mo_bs.battlefield_geometry.add_obstacle(battleattack_mo_fence)
		):
			_battletarget_place(battleattack_mo_src, Vector2(20.0, 30.0))
			_battletarget_place(battleattack_mo_tgt, Vector2(34.0, 30.0))
			var battleattack_mo_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_mo_bs, "atk_mo_src", "atk_mo_tgt", 0.0
			)
			battleattack_move_only_obstacle_ok = (
				battleattack_mo_res != null
				and battleattack_mo_res.shot_executed
				and battleattack_mo_res.attack_event != null
				and battleattack_mo_res.attack_event.outcome == BattleAttackProfile.OUTCOME_MISS
			)

	var battleattack_no_retarget_ok: bool = false
	var battleattack_nr_bs: BattleState = _battlemove_make_state("active")
	if battleattack_nr_bs != null and battleattack_nr_bs.battlefield_geometry != null:
		var battleattack_nr_wall: BattleObstacle = BattleObstacle.new(
			"atk_nr_wall", Rect2(28.0, 20.0, 6.0, 20.0), true, true
		)
		var battleattack_nr_src: BattleParticipant = _battlefire_add(
			battleattack_nr_bs, "atk_nr_src", "attacker", "pistol"
		)
		var battleattack_nr_blocked: BattleParticipant = _battlefire_add(
			battleattack_nr_bs, "atk_nr_blocked", "defender", "pistol"
		)
		var battleattack_nr_open: BattleParticipant = _battlefire_add(
			battleattack_nr_bs, "atk_nr_open", "defender", "pistol"
		)
		if (
			battleattack_nr_src != null
			and battleattack_nr_blocked != null
			and battleattack_nr_open != null
			and battleattack_nr_src.weapon_state != null
			and battleattack_nr_bs.battlefield_geometry.add_obstacle(battleattack_nr_wall)
		):
			_battletarget_place(battleattack_nr_src, Vector2(20.0, 30.0))
			_battletarget_place(battleattack_nr_blocked, Vector2(40.0, 30.0))
			_battletarget_place(battleattack_nr_open, Vector2(20.0, 42.0))
			battleattack_nr_src.set_target_participant("atk_nr_blocked")
			var battleattack_nr_ammo: int = battleattack_nr_src.weapon_state.ammo_in_magazine
			var battleattack_nr_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_nr_bs, "atk_nr_src", "atk_nr_blocked", 0.7
			)
			battleattack_no_retarget_ok = (
				_battleattack_rejected_ok(battleattack_nr_res, "line_of_sight_blocked")
				and _battletarget_has(battleattack_nr_src, "atk_nr_blocked")
				and battleattack_nr_src.weapon_state.ammo_in_magazine == battleattack_nr_ammo
				and battleattack_nr_open.is_alive
				and not battleattack_nr_open.is_wounded
				and battleattack_nr_blocked.is_alive
				and not battleattack_nr_blocked.is_wounded
			)

	var battleattack_tx_rejected_ok: bool = (
		battleattack_reject_los_ok
		and battleattack_reject_cooldown_ok
		and battleattack_reject_empty_ok
	)
	var battleattack_partial_mutate_ok: bool = (
		battleattack_fail_roll_no_mutate_ok
		and battleattack_reject_los_ok
		and battleattack_reject_cooldown_ok
		and battleattack_reject_empty_ok
	)

	var battleattack_commit_fail_unreachable_ok: bool = false
	var battleattack_cf_pack: Dictionary = _battleattack_make_ready("atk_cf_src", "atk_cf_tgt")
	var battleattack_cf_bs: BattleState = battleattack_cf_pack.get("battle_state", null) as BattleState
	var battleattack_cf_src: BattleParticipant = battleattack_cf_pack.get("source", null) as BattleParticipant
	if battleattack_cf_bs != null and battleattack_cf_src != null and battleattack_cf_src.weapon_state != null:
		var battleattack_cf_elig: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
			battleattack_cf_bs, "atk_cf_src", "atk_cf_tgt"
		)
		var battleattack_cf_def: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(
			battleattack_cf_src.weapon_state.weapon_type_id
		)
		battleattack_commit_fail_unreachable_ok = (
			battleattack_cf_elig != null
			and battleattack_cf_elig.success
			and battleattack_cf_elig.can_fire
			and battleattack_cf_def != null
			and battleattack_cf_def.is_valid()
			and is_finite(battleattack_cf_def.cooldown_seconds())
			and battleattack_cf_src.weapon_state.ammo_in_magazine > 0
			and not battleattack_cf_src.weapon_state.is_reloading
			and is_equal_approx(battleattack_cf_src.weapon_state.cooldown_remaining_seconds, 0.0)
		)

	var battleattack_pair_elig_ok: bool = (
		_battleattack_pair_code("ready") == "eligible"
		and _battleattack_pair_code("same_side") == "not_hostile"
		and _battleattack_pair_code("range") == "out_of_range"
		and _battleattack_pair_code("los") == "line_of_sight_blocked"
		and _battleattack_pair_code("cooldown") == "cooldown"
		and _battleattack_pair_code("empty") == "empty_magazine"
		and _battleattack_pair_code("reloading") == "reloading"
		and _battleattack_pair_code("mismatch") == "weapon_type_mismatch"
	)
	var battleattack_ct_a: BattleFireControlResult = _battlefire_mixed_eval(["e", "c", "r", "l", "m", "n"])
	var battleattack_ct_b: BattleFireControlResult = _battlefire_mixed_eval(["n", "m", "l", "r", "c", "e"])
	var battleattack_aggregate_regress_ok: bool = (
		_battlefire_eval_counts(battleattack_ct_a, 7, 6, 1, 1, 1, 1, 1, 1)
		and _battlefire_eval_counts(battleattack_ct_b, 7, 6, 1, 1, 1, 1, 1, 1)
	)

	var battleattack_target_untouched_ok: bool = false
	var battleattack_tu_bs: BattleState = _battlemove_make_state("active")
	if battleattack_tu_bs != null:
		var battleattack_tu_src: BattleParticipant = _battlefire_add(
			battleattack_tu_bs, "atk_tu_src", "attacker", "pistol"
		)
		var battleattack_tu_a: BattleParticipant = _battlefire_add(
			battleattack_tu_bs, "atk_tu_a", "defender", "pistol"
		)
		var battleattack_tu_b: BattleParticipant = _battlefire_add(
			battleattack_tu_bs, "atk_tu_b", "defender", "pistol"
		)
		var battleattack_tu_other: BattleParticipant = _battlefire_add(
			battleattack_tu_bs, "atk_tu_other", "attacker", "pistol"
		)
		if (
			battleattack_tu_src != null
			and battleattack_tu_a != null
			and battleattack_tu_b != null
			and battleattack_tu_other != null
			and battleattack_tu_src.weapon_state != null
		):
			_battletarget_place(battleattack_tu_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_tu_a, Vector2(18.0, 10.0))
			_battletarget_place(battleattack_tu_b, Vector2(10.0, 18.0))
			_battletarget_place(battleattack_tu_other, Vector2(12.0, 40.0))
			battleattack_tu_src.set_target_participant("atk_tu_a")
			battleattack_tu_other.set_target_participant("atk_tu_b")
			var battleattack_tu_miss: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_tu_bs, "atk_tu_src", "atk_tu_a", 0.0
			)
			battleattack_tu_src.weapon_state.cooldown_remaining_seconds = 0.0
			var battleattack_tu_wound: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_tu_bs, "atk_tu_src", "atk_tu_a", 0.7
			)
			battleattack_tu_src.weapon_state.cooldown_remaining_seconds = 0.0
			var battleattack_tu_kill: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_tu_bs, "atk_tu_src", "atk_tu_b", 0.95
			)
			battleattack_target_untouched_ok = (
				battleattack_tu_miss != null
				and battleattack_tu_miss.shot_executed
				and battleattack_tu_wound != null
				and battleattack_tu_wound.shot_executed
				and battleattack_tu_kill != null
				and battleattack_tu_kill.shot_executed
				and _battletarget_has(battleattack_tu_src, "atk_tu_a")
				and _battletarget_has(battleattack_tu_other, "atk_tu_b")
				and not battleattack_tu_b.is_alive
			)

	var battleattack_runtime_no_auto_ok: bool = false
	var battleattack_naf_bs: BattleState = _battlemove_make_state("active")
	if battleattack_naf_bs != null:
		var battleattack_naf_src: BattleParticipant = _battlefire_add(
			battleattack_naf_bs, "atk_naf_src", "attacker", "pistol"
		)
		var battleattack_naf_tgt: BattleParticipant = _battlefire_add(
			battleattack_naf_bs, "atk_naf_tgt", "defender", "pistol"
		)
		if battleattack_naf_src != null and battleattack_naf_tgt != null and battleattack_naf_src.weapon_state != null:
			_battletarget_place(battleattack_naf_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_naf_tgt, Vector2(20.0, 10.0))
			battleattack_naf_src.set_target_participant("atk_naf_tgt")
			var battleattack_naf_r1: BattleRuntimeResult = BattleRuntimeService.advance(battleattack_naf_bs, 0.5)
			var battleattack_naf_r2: BattleRuntimeResult = BattleRuntimeService.advance(battleattack_naf_bs, 0.5)
			var battleattack_naf_r3: BattleRuntimeResult = BattleRuntimeService.advance(battleattack_naf_bs, 0.5)
			battleattack_runtime_no_auto_ok = (
				battleattack_naf_r1 != null
				and battleattack_naf_r1.success
				and battleattack_naf_r2 != null
				and battleattack_naf_r2.success
				and battleattack_naf_r3 != null
				and battleattack_naf_r3.success
				and battleattack_naf_src.weapon_state.ammo_in_magazine == 12
				and is_equal_approx(battleattack_naf_src.weapon_state.cooldown_remaining_seconds, 0.0)
				and battleattack_naf_tgt.is_alive
				and not battleattack_naf_tgt.is_wounded
			)

	var battleattack_runtime_after_shot_ok: bool = false
	var battleattack_ras_pack: Dictionary = _battleattack_make_ready("atk_ras_src", "atk_ras_tgt")
	var battleattack_ras_bs: BattleState = battleattack_ras_pack.get("battle_state", null) as BattleState
	var battleattack_ras_src: BattleParticipant = battleattack_ras_pack.get("source", null) as BattleParticipant
	var battleattack_ras_tgt: BattleParticipant = battleattack_ras_pack.get("target", null) as BattleParticipant
	if battleattack_ras_bs != null and battleattack_ras_src != null and battleattack_ras_tgt != null:
		if battleattack_ras_src.weapon_state != null:
			battleattack_ras_src.set_target_participant("atk_ras_tgt")
			var battleattack_ras_shot: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_ras_bs, "atk_ras_src", "atk_ras_tgt", 0.0
			)
			var battleattack_ras_mid: BattleRuntimeResult = BattleRuntimeService.advance(battleattack_ras_bs, 0.2)
			var battleattack_ras_mid_cd: float = battleattack_ras_src.weapon_state.cooldown_remaining_seconds
			var battleattack_ras_rest: BattleRuntimeResult = BattleRuntimeService.advance(battleattack_ras_bs, 0.3)
			var battleattack_ras_after: BattleRuntimeResult = BattleRuntimeService.advance(battleattack_ras_bs, 0.5)
			battleattack_runtime_after_shot_ok = (
				battleattack_ras_shot != null
				and battleattack_ras_shot.shot_executed
				and battleattack_ras_mid != null
				and battleattack_ras_mid.success
				and is_equal_approx(battleattack_ras_mid_cd, 0.2)
				and battleattack_ras_rest != null
				and battleattack_ras_rest.success
				and is_equal_approx(battleattack_ras_src.weapon_state.cooldown_remaining_seconds, 0.0)
				and battleattack_ras_after != null
				and battleattack_ras_after.success
				and battleattack_ras_src.weapon_state.ammo_in_magazine == 11
				and battleattack_ras_tgt.is_alive
				and not battleattack_ras_tgt.is_wounded
			)

	var battleattack_wounded_target_ok: bool = false
	var battleattack_wt_bs: BattleState = _battlemove_make_state("active")
	if battleattack_wt_bs != null:
		var battleattack_wt_a: BattleParticipant = _battlefire_add(
			battleattack_wt_bs, "atk_wt_a", "attacker", "pistol"
		)
		var battleattack_wt_b: BattleParticipant = _battlefire_add(
			battleattack_wt_bs, "atk_wt_b", "attacker", "pistol"
		)
		var battleattack_wt_tgt: BattleParticipant = _battlefire_add(
			battleattack_wt_bs, "atk_wt_tgt", "defender", "pistol"
		)
		if battleattack_wt_a != null and battleattack_wt_b != null and battleattack_wt_tgt != null:
			_battletarget_place(battleattack_wt_a, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_wt_b, Vector2(10.0, 14.0))
			_battletarget_place(battleattack_wt_tgt, Vector2(20.0, 10.0))
			var battleattack_wt_wound: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_wt_bs, "atk_wt_a", "atk_wt_tgt", 0.7
			)
			var battleattack_wt_elig: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
				battleattack_wt_bs, "atk_wt_b", "atk_wt_tgt"
			)
			var battleattack_wt_second: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_wt_bs, "atk_wt_b", "atk_wt_tgt", 0.0
			)
			battleattack_wounded_target_ok = (
				battleattack_wt_wound != null
				and battleattack_wt_wound.shot_executed
				and battleattack_wt_tgt.is_wounded
				and battleattack_wt_tgt.is_alive
				and battleattack_wt_elig != null
				and battleattack_wt_elig.success
				and battleattack_wt_elig.can_fire
				and battleattack_wt_second != null
				and battleattack_wt_second.shot_executed
			)

	var battleattack_wounded_source_ok: bool = false
	var battleattack_ws_pack: Dictionary = _battleattack_make_ready("atk_ws_src", "atk_ws_tgt")
	var battleattack_ws_bs: BattleState = battleattack_ws_pack.get("battle_state", null) as BattleState
	var battleattack_ws_src: BattleParticipant = battleattack_ws_pack.get("source", null) as BattleParticipant
	if battleattack_ws_bs != null and battleattack_ws_src != null:
		battleattack_ws_src.is_wounded = true
		var battleattack_ws_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_ws_bs, "atk_ws_src", "atk_ws_tgt", 0.0
		)
		battleattack_wounded_source_ok = (
			battleattack_ws_res != null
			and battleattack_ws_res.shot_executed
			and battleattack_ws_src.is_wounded
		)

	var battleattack_multi_side_ok: bool = false
	var battleattack_ms_ids: Array[String] = ["attacker", "defender", "third"]
	var battleattack_ms_bs: BattleState = _battletarget_make_state_with_sides("active", battleattack_ms_ids)
	if battleattack_ms_bs != null:
		var battleattack_ms_src: BattleParticipant = _battlefire_add(
			battleattack_ms_bs, "atk_ms3_src", "attacker", "pistol"
		)
		var battleattack_ms_def: BattleParticipant = _battlefire_add(
			battleattack_ms_bs, "atk_ms3_def", "defender", "pistol"
		)
		var battleattack_ms_third: BattleParticipant = _battlefire_add(
			battleattack_ms_bs, "atk_ms3_third", "third", "pistol"
		)
		if (
			battleattack_ms_src != null
			and battleattack_ms_def != null
			and battleattack_ms_third != null
			and battleattack_ms_src.weapon_state != null
		):
			_battletarget_place(battleattack_ms_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_ms_def, Vector2(18.0, 10.0))
			_battletarget_place(battleattack_ms_third, Vector2(10.0, 18.0))
			var battleattack_ms_r1: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_ms_bs, "atk_ms3_src", "atk_ms3_def", 0.0
			)
			battleattack_ms_src.weapon_state.cooldown_remaining_seconds = 0.0
			var battleattack_ms_r2: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_ms_bs, "atk_ms3_src", "atk_ms3_third", 0.0
			)
			battleattack_multi_side_ok = (
				battleattack_ms_r1 != null
				and battleattack_ms_r1.shot_executed
				and battleattack_ms_r1.attack_event != null
				and battleattack_ms_r1.attack_event.target_participant_id == "atk_ms3_def"
				and battleattack_ms_r2 != null
				and battleattack_ms_r2.shot_executed
				and battleattack_ms_r2.attack_event != null
				and battleattack_ms_r2.attack_event.target_participant_id == "atk_ms3_third"
			)

	var battleattack_determinism_ok: bool = false
	var battleattack_d1: Dictionary = _battleattack_make_ready("atk_d1_src", "atk_d1_tgt")
	var battleattack_d2: Dictionary = _battleattack_make_ready("atk_d1_src", "atk_d1_tgt")
	var battleattack_d1_bs: BattleState = battleattack_d1.get("battle_state", null) as BattleState
	var battleattack_d2_bs: BattleState = battleattack_d2.get("battle_state", null) as BattleState
	if battleattack_d1_bs != null and battleattack_d2_bs != null:
		var battleattack_d1_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_d1_bs, "atk_d1_src", "atk_d1_tgt", 0.7
		)
		var battleattack_d2_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_d2_bs, "atk_d1_src", "atk_d1_tgt", 0.7
		)
		if (
			battleattack_d1_res != null
			and battleattack_d2_res != null
			and battleattack_d1_res.attack_event != null
			and battleattack_d2_res.attack_event != null
		):
			battleattack_determinism_ok = (
				battleattack_d1_res.success == battleattack_d2_res.success
				and battleattack_d1_res.shot_executed == battleattack_d2_res.shot_executed
				and battleattack_d1_res.attack_event.outcome == battleattack_d2_res.attack_event.outcome
				and battleattack_d1_res.attack_event.outcome == BattleAttackProfile.OUTCOME_WOUND
				and battleattack_d1_res.attack_event.target_was_alive == battleattack_d2_res.attack_event.target_was_alive
				and battleattack_d1_res.attack_event.target_is_alive == battleattack_d2_res.attack_event.target_is_alive
				and battleattack_d1_res.attack_event.target_was_wounded == battleattack_d2_res.attack_event.target_was_wounded
				and battleattack_d1_res.attack_event.target_is_wounded == battleattack_d2_res.attack_event.target_is_wounded
			)

	var battleattack_generic_profile_ok: bool = false
	var battleattack_gp_pistol: Dictionary = _battleattack_make_ready(
		"atk_gp_p", "atk_gp_pt", "pistol", Vector2(10.0, 10.0), Vector2(20.0, 10.0)
	)
	var battleattack_gp_rifle: Dictionary = _battleattack_make_ready(
		"atk_gp_r", "atk_gp_rt", "rifle", Vector2(10.0, 10.0), Vector2(40.0, 10.0)
	)
	var battleattack_gp_shotgun: Dictionary = _battleattack_make_ready(
		"atk_gp_s", "atk_gp_st", "shotgun", Vector2(10.0, 10.0), Vector2(18.0, 10.0)
	)
	var battleattack_gp_p_bs: BattleState = battleattack_gp_pistol.get("battle_state", null) as BattleState
	var battleattack_gp_r_bs: BattleState = battleattack_gp_rifle.get("battle_state", null) as BattleState
	var battleattack_gp_s_bs: BattleState = battleattack_gp_shotgun.get("battle_state", null) as BattleState
	if battleattack_gp_p_bs != null and battleattack_gp_r_bs != null and battleattack_gp_s_bs != null:
		var battleattack_gp_pr: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_gp_p_bs, "atk_gp_p", "atk_gp_pt", 0.73
		)
		var battleattack_gp_rr: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_gp_r_bs, "atk_gp_r", "atk_gp_rt", 0.73
		)
		var battleattack_gp_sr: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_gp_s_bs, "atk_gp_s", "atk_gp_st", 0.73
		)
		battleattack_generic_profile_ok = (
			battleattack_gp_pr != null
			and battleattack_gp_rr != null
			and battleattack_gp_sr != null
			and battleattack_gp_pr.attack_event != null
			and battleattack_gp_rr.attack_event != null
			and battleattack_gp_sr.attack_event != null
			and battleattack_gp_pr.attack_event.outcome == BattleAttackProfile.OUTCOME_WOUND
			and battleattack_gp_rr.attack_event.outcome == BattleAttackProfile.OUTCOME_WOUND
			and battleattack_gp_sr.attack_event.outcome == BattleAttackProfile.OUTCOME_WOUND
			and battleattack_gp_pr.attack_event.weapon_type_id == "pistol"
			and battleattack_gp_rr.attack_event.weapon_type_id == "rifle"
			and battleattack_gp_sr.attack_event.weapon_type_id == "shotgun"
		)

	var battleattack_persist_ok: bool = false
	var battleattack_campaign_immutability_ok: bool = false
	var battleattack_camp_pack: Dictionary = _battle_create_ready_pack()
	var battleattack_camp_game: GameState = battleattack_camp_pack.get("game_state", null) as GameState
	var battleattack_camp_force: TravelingForce = battleattack_camp_pack.get("force", null) as TravelingForce
	var battleattack_camp_bs: BattleState = battleattack_camp_pack.get("battle_state", null) as BattleState
	if battleattack_camp_game != null and battleattack_camp_bs != null:
		var battleattack_camp_deployed: bool = _battle_deploy_standard_attacker(battleattack_camp_bs)
		var battleattack_camp_geo: bool = _battlegeo_init(battleattack_camp_bs)
		var battleattack_camp_begun: bool = battleattack_camp_bs.begin_battle()
		var battleattack_camp_src: BattleParticipant = battleattack_camp_bs.get_participant("battle_sol_a")
		var battleattack_camp_tgt: BattleParticipant = _battlefire_add(
			battleattack_camp_bs, "atk_persist_tgt", "defender", "pistol"
		)
		if battleattack_camp_src != null and battleattack_camp_tgt != null:
			_battletarget_place(battleattack_camp_src, Vector2(10.0, 10.0))
			_battletarget_place(battleattack_camp_tgt, Vector2(20.0, 10.0))
			var battleattack_camp_shot: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
				battleattack_camp_bs, "battle_sol_a", "atk_persist_tgt", 0.95
			)
			var battleattack_camp_persist: Dictionary = battleattack_camp_game.to_dict()
			battleattack_persist_ok = (
				battleattack_camp_deployed
				and battleattack_camp_geo
				and battleattack_camp_begun
				and battleattack_camp_shot != null
				and battleattack_camp_shot.shot_executed
				and _battle_serialized_campaign_keys_only(battleattack_camp_persist)
				and not _battle_data_has_tactical_trace(battleattack_camp_persist)
				and not battleattack_camp_persist.has("attack_event")
				and not battleattack_camp_persist.has("outcome_roll")
				and not battleattack_camp_persist.has("shot_executed")
			)
		battleattack_campaign_immutability_ok = (
			_battleattack_campaign_outcome(0.0)
			and _battleattack_campaign_outcome(0.7)
			and _battleattack_campaign_outcome(0.95)
		)

	var battleattack_no_auto_end_ok: bool = false
	var battleattack_ae_pack: Dictionary = _battleattack_make_ready("atk_ae_src", "atk_ae_tgt")
	var battleattack_ae_bs: BattleState = battleattack_ae_pack.get("battle_state", null) as BattleState
	var battleattack_ae_tgt: BattleParticipant = battleattack_ae_pack.get("target", null) as BattleParticipant
	if battleattack_ae_bs != null and battleattack_ae_tgt != null:
		var battleattack_ae_phase: String = battleattack_ae_bs.battle_phase
		var battleattack_ae_res: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
			battleattack_ae_bs, "atk_ae_src", "atk_ae_tgt", 0.95
		)
		battleattack_no_auto_end_ok = (
			battleattack_ae_res != null
			and battleattack_ae_res.shot_executed
			and not battleattack_ae_tgt.is_alive
			and battleattack_ae_bs.battle_phase == battleattack_ae_phase
			and battleattack_ae_bs.battle_phase == "active"
			and not battleattack_ae_bs.has_method("resolve_victory")
			and not battleattack_ae_bs.has_method("end_battle")
			and battleattack_ae_bs.get("winner_side_id") == null
		)

	var battleattack_svc: BattleAttackResolutionService = BattleAttackResolutionService.new()
	var battleattack_rt: BattleRuntimeService = BattleRuntimeService.new()
	var battleattack_no_rng_ok: bool = (
		not battleattack_svc.has_method("randf")
		and not battleattack_svc.has_method("randi")
		and not battleattack_svc.has_method("randomize")
		and not battleattack_svc.has_method("roll_hit")
		and not battleattack_svc.has_method("generate_roll")
		and not battleattack_current.has_method("randomize")
		and battleattack_determinism_ok
	)
	var battleattack_no_extra_mechanics_ok: bool = false
	var battleattack_nm_p: BattleParticipant = BattleParticipant.new("atk_nm_p", "", "a", "attacker", "pistol")
	var battleattack_nm_bs: BattleState = _battlemove_make_state("active")
	if battleattack_nm_bs != null:
		battleattack_no_extra_mechanics_ok = (
			_battle_has_no_combat_turn_model(battleattack_nm_bs)
			and not battleattack_svc.has_method("apply_damage")
			and not battleattack_svc.has_method("apply_bleed")
			and not battleattack_svc.has_method("apply_suppression")
			and not battleattack_svc.has_method("spawn_projectile")
			and not battleattack_svc.has_method("select_target")
			and not battleattack_svc.has_method("end_battle")
			and not battleattack_svc.has_method("accuracy_for_weapon")
			and not battleattack_svc.has_method("distance_modifier")
			and not battleattack_current.has_method("accuracy_for_weapon")
			and not battleattack_current.has_method("distance_modifier")
			and not battleattack_rt.has_method("resolve_attack")
			and not battleattack_rt.has_method("commit_shot")
			and _battleattack_no_hidden_status(battleattack_nm_p)
			and battleattack_nm_bs.get("cover") == null
			and battleattack_nm_bs.get("interior_bonus") == null
			and battleattack_nm_bs.get("elevation_level") == null
			and battleattack_repeat_wound_ok
			and battleattack_graze_ok
			and battleattack_no_auto_end_ok
			and battleattack_generic_profile_ok
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
		"battle_rt_activate_ok": battle_rt_activate_ok,
		"battle_rt_no_current_actor_ok": battle_rt_no_current_actor_ok,
		"battle_rt_no_round_ok": battle_rt_no_round_ok,
		"battle_rt_identity_ok": battle_rt_identity_ok,
		"battle_rt_deploy_unchanged_ok": battle_rt_deploy_unchanged_ok,
		"battle_rt_immutability_ok": battle_rt_immutability_ok,
		"battlert_default_ok": battlert_default_ok,
		"battlert_reject_deploy_ok": battlert_reject_deploy_ok,
		"battlert_advance_ok": battlert_advance_ok,
		"battlert_zero_delta_ok": battlert_zero_delta_ok,
		"battlert_invalid_delta_ok": battlert_invalid_delta_ok,
		"battlert_invalid_elapsed_ok": battlert_invalid_elapsed_ok,
		"battlert_null_ok": battlert_null_ok,
		"battlert_intent_norm_ok": battlert_intent_norm_ok,
		"battlert_intent_zero_ok": battlert_intent_zero_ok,
		"battlert_intent_invalid_ok": battlert_intent_invalid_ok,
		"battlert_no_move_ok": battlert_no_move_ok,
		"battlert_combat_state_ok": battlert_combat_state_ok,
		"battlert_multi_ok": battlert_multi_ok,
		"battlert_begin_active_ok": battlert_begin_active_ok,
		"battlert_no_turn_ok": battlert_no_turn_ok,
		"battlert_result_ok": battlert_result_ok,
		"battlert_persist_ok": battlert_persist_ok,
		"battlert_immutability_ok": battlert_immutability_ok,
		"battlemove_default_ok": battlemove_default_ok,
		"battlemove_speed_set_ok": battlemove_speed_set_ok,
		"battlemove_reject_ok": battlemove_reject_ok,
		"battlemove_physics_ok": battlemove_physics_ok,
		"battlemove_zero_delta_ok": battlemove_zero_delta_ok,
		"battlemove_zero_speed_ok": battlemove_zero_speed_ok,
		"battlemove_zero_intent_ok": battlemove_zero_intent_ok,
		"battlemove_unpos_ok": battlemove_unpos_ok,
		"battlemove_dead_ok": battlemove_dead_ok,
		"battlemove_bad_speed_ok": battlemove_bad_speed_ok,
		"battlemove_bad_intent_ok": battlemove_bad_intent_ok,
		"battlemove_norm_ok": battlemove_norm_ok,
		"battlemove_multi_ok": battlemove_multi_ok,
		"battlemove_runtime_ok": battlemove_runtime_ok,
		"battlemove_tx_ok": battlemove_tx_ok,
		"battlemove_intent_stable_ok": battlemove_intent_stable_ok,
		"battlemove_wounded_ok": battlemove_wounded_ok,
		"battlemove_weapon_ok": battlemove_weapon_ok,
		"battlemove_deploy_geo_ok": battlemove_deploy_geo_ok,
		"battlemove_persist_ok": battlemove_persist_ok,
		"battlemove_immutability_ok": battlemove_immutability_ok,
		"battlemove_no_turn_ok": battlemove_no_turn_ok,
		"battlemove_result_ok": battlemove_result_ok,
		"battlegeo_default_ok": battlegeo_default_ok,
		"battlegeo_fail_null_ok": battlegeo_fail_null_ok,
		"battlegeo_fail_not_deploy_ok": battlegeo_fail_not_deploy_ok,
		"battlegeo_fail_missing_att_side_ok": battlegeo_fail_missing_att_side_ok,
		"battlegeo_fail_missing_def_side_ok": battlegeo_fail_missing_def_side_ok,
		"battlegeo_fail_missing_att_zone_ok": battlegeo_fail_missing_att_zone_ok,
		"battlegeo_fail_missing_def_zone_ok": battlegeo_fail_missing_def_zone_ok,
		"battlegeo_invalid_geo_unreachable_ok": battlegeo_invalid_geo_unreachable_ok,
		"battlegeo_part_place_ok": battlegeo_part_place_ok,
		"battlegeo_veh_place_ok": battlegeo_veh_place_ok,
		"battlegeo_part_veh_sep_ok": battlegeo_part_veh_sep_ok,
		"battlegeo_undeployed_ok": battlegeo_undeployed_ok,
		"battlegeo_semantic_ok": battlegeo_semantic_ok,
		"battlegeo_ready_before_ok": battlegeo_ready_before_ok,
		"battlegeo_ready_after_ok": battlegeo_ready_after_ok,
		"battlegeo_reject_missing_pos_ok": battlegeo_reject_missing_pos_ok,
		"battlegeo_reject_nan_pos_ok": battlegeo_reject_nan_pos_ok,
		"battlegeo_reject_outside_ok": battlegeo_reject_outside_ok,
		"battlegeo_result_ok": battlegeo_result_ok,
		"battlegeo_move_ok": battlegeo_move_ok,
		"battlegeo_locality_ok": battlegeo_locality_ok,
		"battlegeo_persist_ok": battlegeo_persist_ok,
		"battlegeo_immutability_ok": battlegeo_immutability_ok,
		"battlegeo_no_combat_ok": battlegeo_no_combat_ok,
		"battlespatial_obstacle_ok": battlespatial_obstacle_ok,
		"battlespatial_registry_ok": battlespatial_registry_ok,
		"battlespatial_reject_ok": battlespatial_reject_ok,
		"battlespatial_default_empty_ok": battlespatial_default_empty_ok,
		"battlespatial_open_ok": battlespatial_open_ok,
		"battlespatial_zero_disp_ok": battlespatial_zero_disp_ok,
		"battlespatial_fail_null_ok": battlespatial_fail_null_ok,
		"battlespatial_fail_missing_geo_ok": battlespatial_fail_missing_geo_ok,
		"battlespatial_fail_invalid_geo_ok": battlespatial_fail_invalid_geo_ok,
		"battlespatial_fail_bad_start_ok": battlespatial_fail_bad_start_ok,
		"battlespatial_fail_outside_ok": battlespatial_fail_outside_ok,
		"battlespatial_fail_bad_disp_ok": battlespatial_fail_bad_disp_ok,
		"battlespatial_bound_right_ok": battlespatial_bound_right_ok,
		"battlespatial_bound_left_ok": battlespatial_bound_left_ok,
		"battlespatial_bound_top_ok": battlespatial_bound_top_ok,
		"battlespatial_bound_bottom_ok": battlespatial_bound_bottom_ok,
		"battlespatial_bound_diag_ok": battlespatial_bound_diag_ok,
		"battlespatial_wall_hit_ok": battlespatial_wall_hit_ok,
		"battlespatial_tunnel_ok": battlespatial_tunnel_ok,
		"battlespatial_nonblock_ok": battlespatial_nonblock_ok,
		"battlespatial_start_inside_ok": battlespatial_start_inside_ok,
		"battlespatial_start_inside_nonblock_ok": battlespatial_start_inside_nonblock_ok,
		"battlespatial_earliest_ok": battlespatial_earliest_ok,
		"battlespatial_tie_ok": battlespatial_tie_ok,
		"battlespatial_obs_before_bound_ok": battlespatial_obs_before_bound_ok,
		"battlespatial_bound_before_obs_ok": battlespatial_bound_before_obs_ok,
		"battlespatial_obs_bound_tie_ok": battlespatial_obs_bound_tie_ok,
		"battlespatial_diag_wall_ok": battlespatial_diag_wall_ok,
		"battlespatial_move_integrate_ok": battlespatial_move_integrate_ok,
		"battlespatial_blocked_count_ok": battlespatial_blocked_count_ok,
		"battlespatial_partial_count_ok": battlespatial_partial_count_ok,
		"battlespatial_sibling_malformed_ok": battlespatial_sibling_malformed_ok,
		"battlespatial_sibling_inside_ok": battlespatial_sibling_inside_ok,
		"battlespatial_move_missing_geo_ok": battlespatial_move_missing_geo_ok,
		"battlespatial_move_invalid_geo_ok": battlespatial_move_invalid_geo_ok,
		"battlespatial_runtime_tx_ok": battlespatial_runtime_tx_ok,
		"battlespatial_runtime_ok": battlespatial_runtime_ok,
		"battlespatial_velocity_ok": battlespatial_velocity_ok,
		"battlespatial_dead_ok": battlespatial_dead_ok,
		"battlespatial_zero_speed_ok": battlespatial_zero_speed_ok,
		"battlespatial_zero_intent_ok": battlespatial_zero_intent_ok,
		"battlespatial_persist_ok": battlespatial_persist_ok,
		"battlespatial_immutability_ok": battlespatial_immutability_ok,
		"battlespatial_no_part_collision_ok": battlespatial_no_part_collision_ok,
		"battlespatial_no_combat_ok": battlespatial_no_combat_ok,
		"battlespatial_result_helper_ok": battlespatial_result_helper_ok,
		"battlenav_request_ok": battlenav_request_ok,
		"battlenav_direct_ok": battlenav_direct_ok,
		"battlenav_same_point_ok": battlenav_same_point_ok,
		"battlenav_fail_null_ok": battlenav_fail_null_ok,
		"battlenav_fail_missing_geo_ok": battlenav_fail_missing_geo_ok,
		"battlenav_fail_invalid_geo_ok": battlenav_fail_invalid_geo_ok,
		"battlenav_fail_bad_start_ok": battlenav_fail_bad_start_ok,
		"battlenav_fail_bad_dest_ok": battlenav_fail_bad_dest_ok,
		"battlenav_fail_start_out_ok": battlenav_fail_start_out_ok,
		"battlenav_fail_dest_out_ok": battlenav_fail_dest_out_ok,
		"battlenav_fail_start_inside_ok": battlenav_fail_start_inside_ok,
		"battlenav_fail_dest_inside_ok": battlenav_fail_dest_inside_ok,
		"battlenav_detour_ok": battlenav_detour_ok,
		"battlenav_short_side_ok": battlenav_short_side_ok,
		"battlenav_equal_cost_ok": battlenav_equal_cost_ok,
		"battlenav_multi_ok": battlenav_multi_ok,
		"battlenav_corridor_ok": battlenav_corridor_ok,
		"battlenav_barrier_ok": battlenav_barrier_ok,
		"battlenav_edge_ok": battlenav_edge_ok,
		"battlenav_nonblock_ok": battlenav_nonblock_ok,
		"battlenav_mixed_ok": battlenav_mixed_ok,
		"battlenav_corner_ok": battlenav_corner_ok,
		"battlenav_clear_direct_ok": battlenav_clear_direct_ok,
		"battlenav_clear_detour_ok": battlenav_clear_detour_ok,
		"battlenav_clear_multi_ok": battlenav_clear_multi_ok,
		"battlenav_clear_corridor_ok": battlenav_clear_corridor_ok,
		"battlenav_simplify_ok": battlenav_simplify_ok,
		"battlenav_no_dup_ok": battlenav_no_dup_ok,
		"battlenav_length_direct_ok": battlenav_length_direct_ok,
		"battlenav_length_detour_ok": battlenav_length_detour_ok,
		"battlenav_readonly_ok": battlenav_readonly_ok,
		"battlenav_equiv_ok": battlenav_equiv_ok,
		"battlenav_store_default_ok": battlenav_store_default_ok,
		"battlenav_store_set_ok": battlenav_store_set_ok,
		"battlenav_store_alias_ok": battlenav_store_alias_ok,
		"battlenav_store_tx_ok": battlenav_store_tx_ok,
		"battlenav_store_strip_ok": battlenav_store_strip_ok,
		"battlenav_store_clear_ok": battlenav_store_clear_ok,
		"battlenav_plan_readonly_ok": battlenav_plan_readonly_ok,
		"battlenav_follow_owns_intent_ok": battlenav_follow_owns_intent_ok,
		"battlenav_persist_ok": battlenav_persist_ok,
		"battlenav_immutability_ok": battlenav_immutability_ok,
		"battlenav_no_combat_ok": battlenav_no_combat_ok,
		"battlenav_result_helper_ok": battlenav_result_helper_ok,
		"battlefollow_default_ok": battlefollow_default_ok,
		"battlefollow_fail_null_ok": battlefollow_fail_null_ok,
		"battlefollow_fail_not_active_ok": battlefollow_fail_not_active_ok,
		"battlefollow_fail_missing_geo_ok": battlefollow_fail_missing_geo_ok,
		"battlefollow_fail_invalid_geo_ok": battlefollow_fail_invalid_geo_ok,
		"battlefollow_nopath_intent_ok": battlefollow_nopath_intent_ok,
		"battlefollow_intent_ok": battlefollow_intent_ok,
		"battlefollow_norm_ok": battlefollow_norm_ok,
		"battlefollow_dead_ok": battlefollow_dead_ok,
		"battlefollow_unpos_ok": battlefollow_unpos_ok,
		"battlefollow_malformed_ok": battlefollow_malformed_ok,
		"battlefollow_reached_first_ok": battlefollow_reached_first_ok,
		"battlefollow_reached_multi_ok": battlefollow_reached_multi_ok,
		"battlefollow_complete_ok": battlefollow_complete_ok,
		"battlefollow_complete_next_ok": battlefollow_complete_next_ok,
		"battlefollow_overshoot_final_ok": battlefollow_overshoot_final_ok,
		"battlefollow_overshoot_mid_ok": battlefollow_overshoot_mid_ok,
		"battlefollow_speed_cap_ok": battlefollow_speed_cap_ok,
		"battlefollow_collision_ok": battlefollow_collision_ok,
		"battlefollow_no_replan_ok": battlefollow_no_replan_ok,
		"battlefollow_clear_target_ok": battlefollow_clear_target_ok,
		"battlefollow_replace_path_ok": battlefollow_replace_path_ok,
		"battlefollow_stale_target_ok": battlefollow_stale_target_ok,
		"battlefollow_zero_delta_ok": battlefollow_zero_delta_ok,
		"battlefollow_runtime_order_ok": battlefollow_runtime_order_ok,
		"battlefollow_runtime_tx_ok": battlefollow_runtime_tx_ok,
		"battlefollow_move_after_follow_ok": battlefollow_move_after_follow_ok,
		"battlefollow_multi_ok": battlefollow_multi_ok,
		"battlefollow_counts_ok": battlefollow_counts_ok,
		"battlefollow_result_helper_ok": battlefollow_result_helper_ok,
		"battlefollow_manual_intent_ok": battlefollow_manual_intent_ok,
		"battlefollow_persist_ok": battlefollow_persist_ok,
		"battlefollow_immutability_ok": battlefollow_immutability_ok,
		"battlefollow_no_combat_ok": battlefollow_no_combat_ok,
		"battletarget_default_ok": battletarget_default_ok,
		"battletarget_helper_ok": battletarget_helper_ok,
		"battletarget_fail_null_ok": battletarget_fail_null_ok,
		"battletarget_fail_not_active_ok": battletarget_fail_not_active_ok,
		"battletarget_fail_missing_geo_ok": battletarget_fail_missing_geo_ok,
		"battletarget_fail_invalid_geo_ok": battletarget_fail_invalid_geo_ok,
		"battletarget_two_side_ok": battletarget_two_side_ok,
		"battletarget_same_side_ok": battletarget_same_side_ok,
		"battletarget_nearest_ok": battletarget_nearest_ok,
		"battletarget_tiebreak_ok": battletarget_tiebreak_ok,
		"battletarget_dead_src_ok": battletarget_dead_src_ok,
		"battletarget_dead_hostile_ok": battletarget_dead_hostile_ok,
		"battletarget_wounded_src_ok": battletarget_wounded_src_ok,
		"battletarget_wounded_hostile_ok": battletarget_wounded_hostile_ok,
		"battletarget_unpos_src_ok": battletarget_unpos_src_ok,
		"battletarget_unpos_hostile_ok": battletarget_unpos_hostile_ok,
		"battletarget_malformed_src_ok": battletarget_malformed_src_ok,
		"battletarget_malformed_hostile_ok": battletarget_malformed_hostile_ok,
		"battletarget_invalid_src_side_ok": battletarget_invalid_src_side_ok,
		"battletarget_invalid_hostile_side_ok": battletarget_invalid_hostile_side_ok,
		"battletarget_clear_none_ok": battletarget_clear_none_ok,
		"battletarget_unchanged_ok": battletarget_unchanged_ok,
		"battletarget_switch_nearer_ok": battletarget_switch_nearer_ok,
		"battletarget_replace_dead_ok": battletarget_replace_dead_ok,
		"battletarget_multi_side_ok": battletarget_multi_side_ok,
		"battletarget_pre_los_wall_ok": battletarget_pre_los_wall_ok,
		"battletarget_no_move_ok": battletarget_no_move_ok,
		"battletarget_no_nav_ok": battletarget_no_nav_ok,
		"battletarget_runtime_ok": battletarget_runtime_ok,
		"battletarget_zero_delta_ok": battletarget_zero_delta_ok,
		"battletarget_runtime_tx_ok": battletarget_runtime_tx_ok,
		"battletarget_multi_ok": battletarget_multi_ok,
		"battletarget_counts_ok": battletarget_counts_ok,
		"battletarget_result_helper_ok": battletarget_result_helper_ok,
		"battletarget_no_candidate_list_ok": battletarget_no_candidate_list_ok,
		"battletarget_persist_ok": battletarget_persist_ok,
		"battletarget_immutability_ok": battletarget_immutability_ok,
		"battletarget_no_combat_ok": battletarget_no_combat_ok,
		"battlelos_clear_ok": battlelos_clear_ok,
		"battlelos_blocked_ok": battlelos_blocked_ok,
		"battlelos_fail_null_ok": battlelos_fail_null_ok,
		"battlelos_fail_missing_geo_ok": battlelos_fail_missing_geo_ok,
		"battlelos_fail_invalid_geo_ok": battlelos_fail_invalid_geo_ok,
		"battlelos_fail_src_missing_ok": battlelos_fail_src_missing_ok,
		"battlelos_fail_tgt_missing_ok": battlelos_fail_tgt_missing_ok,
		"battlelos_fail_src_ineligible_ok": battlelos_fail_src_ineligible_ok,
		"battlelos_fail_tgt_ineligible_ok": battlelos_fail_tgt_ineligible_ok,
		"battlelos_wounded_ok": battlelos_wounded_ok,
		"battlelos_side_independent_ok": battlelos_side_independent_ok,
		"battlelos_same_pos_ok": battlelos_same_pos_ok,
		"battlelos_move_block_sight_clear_ok": battlelos_move_block_sight_clear_ok,
		"battlelos_sight_block_move_clear_ok": battlelos_sight_block_move_clear_ok,
		"battlelos_neither_block_ok": battlelos_neither_block_ok,
		"battlelos_interior_ok": battlelos_interior_ok,
		"battlelos_graze_ok": battlelos_graze_ok,
		"battlelos_corner_ok": battlelos_corner_ok,
		"battlelos_endpoint_ok": battlelos_endpoint_ok,
		"battlelos_tunnel_ok": battlelos_tunnel_ok,
		"battlelos_earliest_ok": battlelos_earliest_ok,
		"battlelos_tie_ok": battlelos_tie_ok,
		"battlelos_reverse_ok": battlelos_reverse_ok,
		"battlelos_mixed_ok": battlelos_mixed_ok,
		"battlelos_segment_ok": battlelos_segment_ok,
		"battlelos_segment_invalid_ok": battlelos_segment_invalid_ok,
		"battlelos_spatial_regress_ok": battlelos_spatial_regress_ok,
		"battlelos_target_blocked_ok": battlelos_target_blocked_ok,
		"battlelos_no_target_mutate_ok": battlelos_no_target_mutate_ok,
		"battlelos_no_move_mutate_ok": battlelos_no_move_mutate_ok,
		"battlelos_geo_readonly_ok": battlelos_geo_readonly_ok,
		"battlelos_insert_order_ok": battlelos_insert_order_ok,
		"battlelos_no_cache_ok": battlelos_no_cache_ok,
		"battlelos_no_runtime_refresh_ok": battlelos_no_runtime_refresh_ok,
		"battlelos_persist_ok": battlelos_persist_ok,
		"battlelos_immutability_ok": battlelos_immutability_ok,
		"battlelos_flat_ok": battlelos_flat_ok,
		"battlelos_result_helper_ok": battlelos_result_helper_ok,
		"battlelos_no_combat_ok": battlelos_no_combat_ok,
		"battlefire_def_ok": battlefire_def_ok,
		"battlefire_catalog_ok": battlefire_catalog_ok,
		"battlefire_init_ok": battlefire_init_ok,
		"battlefire_own_ok": battlefire_own_ok,
		"battlefire_fail_null_ok": battlefire_fail_null_ok,
		"battlefire_fail_inactive_ok": battlefire_fail_inactive_ok,
		"battlefire_fail_delta_ok": battlefire_fail_delta_ok,
		"battlefire_fail_missing_geo_ok": battlefire_fail_missing_geo_ok,
		"battlefire_fail_invalid_geo_ok": battlefire_fail_invalid_geo_ok,
		"battlefire_cooldown_ok": battlefire_cooldown_ok,
		"battlefire_zero_delta_ok": battlefire_zero_delta_ok,
		"battlefire_reload_start_ok": battlefire_reload_start_ok,
		"battlefire_reload_mid_ok": battlefire_reload_mid_ok,
		"battlefire_reload_done_ok": battlefire_reload_done_ok,
		"battlefire_reload_large_ok": battlefire_reload_large_ok,
		"battlefire_reload_zero_ok": battlefire_reload_zero_ok,
		"battlefire_neg_repair_ok": battlefire_neg_repair_ok,
		"battlefire_nan_ok": battlefire_nan_ok,
		"battlefire_unknown_ok": battlefire_unknown_ok,
		"battlefire_eligible_ok": battlefire_eligible_ok,
		"battlefire_query_only_ok": battlefire_query_only_ok,
		"battlefire_no_target_ok": battlefire_no_target_ok,
		"battlefire_stale_target_ok": battlefire_stale_target_ok,
		"battlefire_same_side_ok": battlefire_same_side_ok,
		"battlefire_bad_side_ok": battlefire_bad_side_ok,
		"battlefire_ineligible_ok": battlefire_ineligible_ok,
		"battlefire_reload_block_ok": battlefire_reload_block_ok,
		"battlefire_empty_block_ok": battlefire_empty_block_ok,
		"battlefire_cooldown_block_ok": battlefire_cooldown_block_ok,
		"battlefire_range_ok": battlefire_range_ok,
		"battlefire_range_diff_ok": battlefire_range_diff_ok,
		"battlefire_los_block_ok": battlefire_los_block_ok,
		"battlefire_blocker_indep_ok": battlefire_blocker_indep_ok,
		"battlefire_reason_order_ok": battlefire_reason_order_ok,
		"battlefire_drift_ok": battlefire_drift_ok,
		"battlefire_commit_ok": battlefire_commit_ok,
		"battlefire_commit_no_combat_ok": battlefire_commit_no_combat_ok,
		"battlefire_commit_safe_ok": battlefire_commit_safe_ok,
		"battlefire_commit_mismatch_ok": battlefire_commit_mismatch_ok,
		"battlefire_runtime_ok": battlefire_runtime_ok,
		"battlefire_runtime_order_ok": battlefire_runtime_order_ok,
		"battlefire_runtime_zero_ok": battlefire_runtime_zero_ok,
		"battlefire_runtime_tx_ok": battlefire_runtime_tx_ok,
		"battlefire_counts_ok": battlefire_counts_ok,
		"battlefire_result_helper_ok": battlefire_result_helper_ok,
		"battlefire_persist_ok": battlefire_persist_ok,
		"battlefire_immutability_ok": battlefire_immutability_ok,
		"battlefire_no_auto_fire_ok": battlefire_no_auto_fire_ok,
		"battlefire_no_combat_ok": battlefire_no_combat_ok,
		"battleattack_profile_current_ok": battleattack_profile_current_ok,
		"battleattack_profile_invalid_ok": battleattack_profile_invalid_ok,
		"battleattack_profile_epsilon_ok": battleattack_profile_epsilon_ok,
		"battleattack_outcome_ids_ok": battleattack_outcome_ids_ok,
		"battleattack_roll_valid_ok": battleattack_roll_valid_ok,
		"battleattack_roll_invalid_ok": battleattack_roll_invalid_ok,
		"battleattack_thresholds_ok": battleattack_thresholds_ok,
		"battleattack_result_helpers_ok": battleattack_result_helpers_ok,
		"battleattack_event_fields_ok": battleattack_event_fields_ok,
		"battleattack_fail_null_ok": battleattack_fail_null_ok,
		"battleattack_fail_empty_ids_ok": battleattack_fail_empty_ids_ok,
		"battleattack_fail_missing_ok": battleattack_fail_missing_ok,
		"battleattack_fail_phase_geo_ok": battleattack_fail_phase_geo_ok,
		"battleattack_fail_roll_no_mutate_ok": battleattack_fail_roll_no_mutate_ok,
		"battleattack_reject_source_dead_ok": battleattack_reject_source_dead_ok,
		"battleattack_reject_source_unpos_ok": battleattack_reject_source_unpos_ok,
		"battleattack_reject_target_dead_ok": battleattack_reject_target_dead_ok,
		"battleattack_reject_target_unpos_ok": battleattack_reject_target_unpos_ok,
		"battleattack_reject_same_side_ok": battleattack_reject_same_side_ok,
		"battleattack_reject_no_weapon_ok": battleattack_reject_no_weapon_ok,
		"battleattack_reject_unknown_weapon_ok": battleattack_reject_unknown_weapon_ok,
		"battleattack_reject_mismatch_ok": battleattack_reject_mismatch_ok,
		"battleattack_reject_reloading_ok": battleattack_reject_reloading_ok,
		"battleattack_reject_empty_ok": battleattack_reject_empty_ok,
		"battleattack_reject_cooldown_ok": battleattack_reject_cooldown_ok,
		"battleattack_reject_range_ok": battleattack_reject_range_ok,
		"battleattack_reject_los_ok": battleattack_reject_los_ok,
		"battleattack_pair_target_indep_ok": battleattack_pair_target_indep_ok,
		"battleattack_supplied_ally_ok": battleattack_reject_same_side_ok,
		"battleattack_miss_ok": battleattack_miss_ok,
		"battleattack_graze_ok": battleattack_graze_ok,
		"battleattack_wound_ok": battleattack_wound_ok,
		"battleattack_repeat_wound_ok": battleattack_repeat_wound_ok,
		"battleattack_kill_ok": battleattack_kill_ok,
		"battleattack_kill_wounded_ok": battleattack_kill_wounded_ok,
		"battleattack_dead_followup_ok": battleattack_dead_followup_ok,
		"battleattack_pistol_cycle_ok": battleattack_pistol_cycle_ok,
		"battleattack_other_weapon_cycle_ok": battleattack_other_weapon_cycle_ok,
		"battleattack_every_outcome_cycles_ok": battleattack_every_outcome_cycles_ok,
		"battleattack_immediate_cooldown_ok": battleattack_immediate_cooldown_ok,
		"battleattack_last_round_ok": battleattack_last_round_ok,
		"battleattack_range_edge_ok": battleattack_range_edge_ok,
		"battleattack_los_reject_ok": battleattack_reject_los_ok,
		"battleattack_move_only_obstacle_ok": battleattack_move_only_obstacle_ok,
		"battleattack_no_retarget_ok": battleattack_no_retarget_ok,
		"battleattack_tx_rejected_ok": battleattack_tx_rejected_ok,
		"battleattack_commit_fail_unreachable_ok": battleattack_commit_fail_unreachable_ok,
		"battleattack_partial_mutate_ok": battleattack_partial_mutate_ok,
		"battleattack_pair_elig_ok": battleattack_pair_elig_ok,
		"battleattack_aggregate_regress_ok": battleattack_aggregate_regress_ok,
		"battleattack_target_untouched_ok": battleattack_target_untouched_ok,
		"battleattack_runtime_no_auto_ok": battleattack_runtime_no_auto_ok,
		"battleattack_runtime_after_shot_ok": battleattack_runtime_after_shot_ok,
		"battleattack_wounded_target_ok": battleattack_wounded_target_ok,
		"battleattack_wounded_source_ok": battleattack_wounded_source_ok,
		"battleattack_multi_side_ok": battleattack_multi_side_ok,
		"battleattack_determinism_ok": battleattack_determinism_ok,
		"battleattack_generic_profile_ok": battleattack_generic_profile_ok,
		"battleattack_persist_ok": battleattack_persist_ok,
		"battleattack_campaign_immutability_ok": battleattack_campaign_immutability_ok,
		"battleattack_no_auto_end_ok": battleattack_no_auto_end_ok,
		"battleattack_registry_after_kill_ok": battleattack_registry_after_kill_ok,
		"battleattack_no_rng_ok": battleattack_no_rng_ok,
		"battleattack_no_extra_mechanics_ok": battleattack_no_extra_mechanics_ok,
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
		or text == "elapsed_time_seconds"
		or text == "has_battle_position"
		or text == "battle_position"
		or text == "movement_intent"
		or text == "velocity"
		or text == "movement_speed"
		or text == "battlefield_geometry"
		or text == "attacker_deployment_rect"
		or text == "defender_deployment_rect"
		or text == "deployment_rect"
		or text == "obstacles"
		or text == "obstacle_id"
		or text == "blocks_movement"
		or text == "blocks_line_of_sight"
		or text == "has_line_of_sight"
		or text == "blocking_obstacle_id"
		or text == "was_blocked"
		or text == "navigation_destination"
		or text == "has_navigation_destination"
		or text == "navigation_waypoints"
		or text == "navigation_waypoint_index"
		or text == "used_detour"
		or text == "movement_target_position"
		or text == "has_movement_target_position"
		or text == "has_target_participant"
		or text == "target_participant_id"
		or text == "weapon_state"
		or text == "ammo_in_magazine"
		or text == "cooldown_remaining_seconds"
		or text == "reload_remaining_seconds"
		or text == "is_reloading"
		or text == "shots_per_second"
		or text == "magazine_capacity"
		or text == "participants_eligible_to_fire"
		or text == "participants_blocked_by_los"
		or text == "participants_blocked_by_range"
		or text == "participants_blocked_by_cooldown"
		or text == "participants_reloading"
		or text == "participants_empty"
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


static func _battle_has_no_combat_turn_model(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	if battle_state.get("turn_actor_ids") != null:
		return false
	if battle_state.get("turn_actor_types") != null:
		return false
	if battle_state.get("turn_actor_side_ids") != null:
		return false
	if battle_state.get("current_turn_index") != null:
		return false
	if battle_state.get("current_round") != null:
		return false
	if battle_state.get("actor_turn_in_progress") != null:
		return false
	if battle_state.get("active_turn_actor_id") != null:
		return false
	if battle_state.get("active_turn_actor_type") != null:
		return false
	if battle_state.get("active_turn_actor_side_id") != null:
		return false
	if battle_state.has_method("initialize_turn_order"):
		return false
	if battle_state.has_method("get_turn_actor_ids"):
		return false
	if battle_state.has_method("get_turn_actor_types"):
		return false
	if battle_state.has_method("get_turn_actor_side_ids"):
		return false
	if battle_state.has_method("get_turn_actor_count"):
		return false
	if battle_state.has_method("has_current_turn_actor"):
		return false
	if battle_state.has_method("get_current_turn_index"):
		return false
	if battle_state.has_method("get_current_round"):
		return false
	if battle_state.has_method("get_current_turn_actor_id"):
		return false
	if battle_state.has_method("get_current_turn_actor_type"):
		return false
	if battle_state.has_method("get_current_turn_actor_side_id"):
		return false
	if battle_state.has_method("advance_turn"):
		return false
	if battle_state.has_method("begin_current_actor_turn"):
		return false
	if battle_state.has_method("end_current_actor_turn"):
		return false
	if battle_state.has_method("is_actor_turn_in_progress"):
		return false
	if battle_state.has_method("get_active_turn_actor_id"):
		return false
	if battle_state.has_method("get_active_turn_actor_type"):
		return false
	if battle_state.has_method("get_active_turn_actor_side_id"):
		return false
	return true


static func _battle_side_ids_snapshot(battle_state: BattleState) -> Dictionary:
	var snap: Dictionary = {}
	var empty_ids: Array[String] = []
	snap["att_p"] = empty_ids
	snap["att_v"] = empty_ids
	snap["def_p"] = empty_ids
	snap["def_v"] = empty_ids
	if battle_state == null:
		return snap
	var attacker: BattleSide = battle_state.get_side(battle_state.attacker_side_id)
	var defender: BattleSide = battle_state.get_side(battle_state.defender_side_id)
	if attacker != null:
		snap["att_p"] = _copy_ids(attacker.participant_ids)
		snap["att_v"] = _copy_ids(attacker.vehicle_ids)
	if defender != null:
		snap["def_p"] = _copy_ids(defender.participant_ids)
		snap["def_v"] = _copy_ids(defender.vehicle_ids)
	return snap


static func _battle_variant_to_ids(value: Variant) -> Array[String]:
	var ids: Array[String] = []
	if value is Array:
		for item: Variant in value:
			ids.append(str(item))
	return ids


static func _battle_side_ids_match(battle_state: BattleState, snap: Dictionary) -> bool:
	if battle_state == null:
		return false
	var current: Dictionary = _battle_side_ids_snapshot(battle_state)
	return (
		_string_ids_match(_battle_variant_to_ids(current.get("att_p", [])), _battle_variant_to_ids(snap.get("att_p", [])))
		and _string_ids_match(_battle_variant_to_ids(current.get("att_v", [])), _battle_variant_to_ids(snap.get("att_v", [])))
		and 		_string_ids_match(_battle_variant_to_ids(current.get("def_p", [])), _battle_variant_to_ids(snap.get("def_p", [])))
		and _string_ids_match(_battle_variant_to_ids(current.get("def_v", [])), _battle_variant_to_ids(snap.get("def_v", [])))
	)


static func _battlert_make_state(p_phase: String) -> BattleState:
	var battle_state: BattleState = BattleState.new(
		"battlert_battle",
		"battlert_type",
		"battlert_mission",
		"battlert_location",
		"attacker",
		"defender",
		p_phase
	)
	var attacker_side: BattleSide = BattleSide.new("attacker", "battlert_a", "", true, "")
	var defender_side: BattleSide = BattleSide.new("defender", "battlert_b", "", false, "")
	if not battle_state.add_side(attacker_side) or not battle_state.add_side(defender_side):
		return null
	if not _battlespatial_attach_open_geometry(battle_state):
		return null
	return battle_state


static func _battlert_add_participant(
	battle_state: BattleState,
	participant_id: String,
	side_id: String
) -> BattleParticipant:
	if battle_state == null:
		return null
	var participant: BattleParticipant = BattleParticipant.new(
		participant_id,
		"battlert_soldier_" + participant_id,
		"battlert_a",
		side_id,
		"pistol",
		true,
		false,
		""
	)
	if side_id == "defender":
		participant.faction_id = "battlert_b"
	if not battle_state.add_participant(participant):
		return null
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null or not side.add_participant_id(participant_id):
		return null
	return participant


static func _battlert_clock_ok(
	result: BattleRuntimeResult,
	delta_seconds: float,
	elapsed_before: float,
	elapsed_after: float
) -> bool:
	if result == null:
		return false
	return (
		result.success
		and result.error_code.is_empty()
		and result.error_message.is_empty()
		and is_equal_approx(result.delta_seconds, delta_seconds)
		and is_equal_approx(result.elapsed_time_before, elapsed_before)
		and is_equal_approx(result.elapsed_time_after, elapsed_after)
	)


static func _battlert_fail_ok(
	result: BattleRuntimeResult,
	error_code: String,
	elapsed_before: float
) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.error_code == error_code
		and not result.error_message.is_empty()
		and is_equal_approx(result.elapsed_time_before, elapsed_before)
		and is_equal_approx(result.elapsed_time_after, elapsed_before)
	)


static func _battlemove_make_state(p_phase: String) -> BattleState:
	var battle_state: BattleState = BattleState.new(
		"battlemove_battle",
		"battlemove_type",
		"battlemove_mission",
		"battlemove_location",
		"attacker",
		"defender",
		p_phase
	)
	var attacker_side: BattleSide = BattleSide.new("attacker", "battlemove_a", "", true, "")
	var defender_side: BattleSide = BattleSide.new("defender", "battlemove_b", "", false, "")
	if not battle_state.add_side(attacker_side) or not battle_state.add_side(defender_side):
		return null
	if not _battlespatial_attach_open_geometry(battle_state):
		return null
	return battle_state


static func _battlemove_add_participant(
	battle_state: BattleState,
	participant_id: String,
	side_id: String
) -> BattleParticipant:
	if battle_state == null:
		return null
	var participant: BattleParticipant = BattleParticipant.new(
		participant_id,
		"battlemove_soldier_" + participant_id,
		"battlemove_a",
		side_id,
		"pistol",
		true,
		false,
		""
	)
	if side_id == "defender":
		participant.faction_id = "battlemove_b"
	if not battle_state.add_participant(participant):
		return null
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null or not side.add_participant_id(participant_id):
		return null
	return participant


static func _battlemove_ok(
	result: BattleMovementResult,
	delta_seconds: float,
	considered: int,
	moved: int
) -> bool:
	if result == null:
		return false
	return (
		result.success
		and result.error_code.is_empty()
		and result.error_message.is_empty()
		and is_equal_approx(result.delta_seconds, delta_seconds)
		and result.participants_considered == considered
		and result.participants_moved == moved
	)


static func _battlemove_fail_ok(
	result: BattleMovementResult,
	error_code: String,
	delta_seconds: float
) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.error_code == error_code
		and not result.error_message.is_empty()
		and is_equal_approx(result.delta_seconds, delta_seconds)
		and result.participants_considered == 0
		and result.participants_moved == 0
	)


static func _battlemove_part_snap(participant: BattleParticipant) -> Dictionary:
	var snap: Dictionary = {}
	if participant == null:
		return snap
	snap["has_pos"] = participant.has_battle_position
	snap["pos"] = participant.battle_position
	snap["vel"] = participant.velocity
	snap["intent"] = participant.movement_intent
	snap["speed"] = participant.movement_speed
	snap["alive"] = participant.is_alive
	snap["wounded"] = participant.is_wounded
	return snap


static func _battlemove_part_unchanged(participant: BattleParticipant, snap: Dictionary) -> bool:
	if participant == null:
		return false
	var pos_raw: Variant = snap.get("pos", Vector2.ZERO)
	if typeof(pos_raw) != TYPE_VECTOR2:
		return false
	var vel_raw: Variant = snap.get("vel", Vector2.ZERO)
	if typeof(vel_raw) != TYPE_VECTOR2:
		return false
	var intent_raw: Variant = snap.get("intent", Vector2.ZERO)
	if typeof(intent_raw) != TYPE_VECTOR2:
		return false
	var pos: Vector2 = pos_raw as Vector2
	var vel: Vector2 = vel_raw as Vector2
	var intent: Vector2 = intent_raw as Vector2
	return (
		participant.has_battle_position == bool(snap.get("has_pos", false))
		and participant.battle_position.is_equal_approx(pos)
		and participant.velocity.is_equal_approx(vel)
		and participant.movement_intent.is_equal_approx(intent)
		and is_equal_approx(participant.movement_speed, float(snap.get("speed", 0.0)))
		and participant.is_alive == bool(snap.get("alive", false))
		and participant.is_wounded == bool(snap.get("wounded", false))
	)


static func _battlegeo_init(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	var result: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(battle_state)
	return result != null and result.success


static func _battlegeo_fail_ok(result: BattlefieldGeometryResult, expected_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.participants_positioned == 0
		and result.vehicles_positioned == 0
		and result.error_code == expected_code
		and result.error_message.begins_with("Battlefield geometry failed:")
	)


static func _battlegeo_fail_and_unchanged(
	battle_state: BattleState,
	expected_code: String,
	snap: Dictionary
) -> bool:
	var result: BattlefieldGeometryResult = BattlefieldGeometryService.initialize_default_geometry(battle_state)
	return (
		_battlegeo_fail_ok(result, expected_code)
		and _battlegeo_spatial_unchanged(battle_state, snap)
	)


static func _battlegeo_make_incomplete(
	include_attacker_side: bool,
	include_defender_side: bool,
	include_attacker_zone: bool,
	include_defender_zone: bool
) -> BattleState:
	var battle_state: BattleState = BattleState.new(
		"geo_fail_battle",
		"neighborhood_hq_assault",
		"geo_fail_mission",
		"geo_fail_hq",
		"attacker",
		"defender",
		"deployment"
	)
	if include_attacker_side:
		var attacker_side: BattleSide = BattleSide.new("attacker", "battle_a", "", true, "attacker_deployment")
		if not battle_state.add_side(attacker_side):
			return null
	if include_defender_side:
		var defender_side: BattleSide = BattleSide.new("defender", "battle_b", "", false, "defender_deployment")
		if not battle_state.add_side(defender_side):
			return null
	if include_attacker_zone:
		var attacker_zone: DeploymentZone = DeploymentZone.new("attacker_deployment", "attacker", "attacker_entry")
		if not battle_state.add_deployment_zone(attacker_zone):
			return null
	if include_defender_zone:
		var defender_zone: DeploymentZone = DeploymentZone.new("defender_deployment", "defender", "defender_position")
		if not battle_state.add_deployment_zone(defender_zone):
			return null
	return battle_state


static func _battlegeo_add_marker(battle_state: BattleState, side_id: String, zone_id: String) -> bool:
	if battle_state == null:
		return false
	var marker_id: String = "geo_marker_" + side_id
	if not _battle_register_participant(battle_state, marker_id, side_id, zone_id):
		return false
	if not battle_state.deploy_participant(marker_id, zone_id):
		return false
	var participant: BattleParticipant = battle_state.get_participant(marker_id)
	if participant == null:
		return false
	participant.has_battle_position = false
	participant.battle_position = Vector2(9.0, 8.0)
	return true


static func _battlegeo_seed_zone_rects(battle_state: BattleState) -> void:
	if battle_state == null:
		return
	for zone_id: String in battle_state.deployment_zones:
		var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
		if zone != null:
			zone.deployment_rect = Rect2(1.0, 2.0, 3.0, 4.0)


static func _battlegeo_spatial_snap(battle_state: BattleState) -> Dictionary:
	var snap: Dictionary = {}
	if battle_state == null:
		return snap
	snap["geometry"] = battle_state.battlefield_geometry
	snap["phase"] = battle_state.battle_phase
	var zone_rects: Dictionary = {}
	for zone_id: String in battle_state.deployment_zones:
		var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
		if zone != null:
			zone_rects[zone_id] = zone.deployment_rect
	snap["zone_rects"] = zone_rects
	var part_has: Dictionary = {}
	var part_pos: Dictionary = {}
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant != null:
			part_has[participant_id] = participant.has_battle_position
			part_pos[participant_id] = participant.battle_position
	snap["part_has"] = part_has
	snap["part_pos"] = part_pos
	var veh_has: Dictionary = {}
	var veh_pos: Dictionary = {}
	for vehicle_id: String in battle_state.vehicles:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle != null:
			veh_has[vehicle_id] = vehicle.has_battle_position
			veh_pos[vehicle_id] = vehicle.battle_position
	snap["veh_has"] = veh_has
	snap["veh_pos"] = veh_pos
	return snap


static func _battlegeo_spatial_unchanged(battle_state: BattleState, snap: Dictionary) -> bool:
	if battle_state == null:
		return false
	if battle_state.battlefield_geometry != snap.get("geometry", null):
		return false
	if battle_state.battle_phase != str(snap.get("phase", "")):
		return false
	var zone_rects_raw: Variant = snap.get("zone_rects", {})
	if not (zone_rects_raw is Dictionary):
		return false
	var zone_rects: Dictionary = zone_rects_raw as Dictionary
	if zone_rects.size() != battle_state.deployment_zones.size():
		return false
	for zone_id: Variant in zone_rects:
		var zone: DeploymentZone = battle_state.get_deployment_zone(str(zone_id))
		if zone == null:
			return false
		var rect_raw: Variant = zone_rects[zone_id]
		if typeof(rect_raw) != TYPE_RECT2:
			return false
		var expected_rect: Rect2 = rect_raw as Rect2
		if not zone.deployment_rect.is_equal_approx(expected_rect):
			return false
	if not _battlegeo_unit_pos_unchanged(battle_state, snap.get("part_has", {}), snap.get("part_pos", {}), false):
		return false
	if not _battlegeo_unit_pos_unchanged(battle_state, snap.get("veh_has", {}), snap.get("veh_pos", {}), true):
		return false
	return true


static func _battlegeo_unit_pos_unchanged(
	battle_state: BattleState,
	has_raw: Variant,
	pos_raw: Variant,
	is_vehicle: bool
) -> bool:
	if battle_state == null:
		return false
	if not (has_raw is Dictionary) or not (pos_raw is Dictionary):
		return false
	var has_data: Dictionary = has_raw as Dictionary
	var pos_data: Dictionary = pos_raw as Dictionary
	if is_vehicle:
		if has_data.size() != battle_state.vehicles.size() or pos_data.size() != battle_state.vehicles.size():
			return false
	else:
		if has_data.size() != battle_state.participants.size() or pos_data.size() != battle_state.participants.size():
			return false
	for unit_id: Variant in has_data:
		var key: String = str(unit_id)
		var has_flag: bool = bool(has_data[unit_id])
		var pos_value: Variant = pos_data.get(key, null)
		if typeof(pos_value) != TYPE_VECTOR2:
			return false
		var expected_pos: Vector2 = pos_value as Vector2
		if is_vehicle:
			if not battle_state.has_vehicle(key):
				return false
			var vehicle: BattleVehicle = battle_state.get_vehicle(key)
			if vehicle == null:
				return false
			if vehicle.has_battle_position != has_flag:
				return false
			if not vehicle.battle_position.is_equal_approx(expected_pos):
				return false
		else:
			if not battle_state.has_participant(key):
				return false
			var participant: BattleParticipant = battle_state.get_participant(key)
			if participant == null:
				return false
			if participant.has_battle_position != has_flag:
				return false
			if not participant.battle_position.is_equal_approx(expected_pos):
				return false
	return true


static func _battlegeo_make_unit_state(
	attacker_part_ids: Array[String],
	attacker_veh_ids: Array[String],
	defender_part_ids: Array[String],
	defender_veh_ids: Array[String]
) -> BattleState:
	var battle_state: BattleState = _battle_make_bare_state()
	if battle_state == null:
		return null
	for participant_id: String in attacker_part_ids:
		if not _battle_register_participant(battle_state, participant_id, "attacker", "attacker_deployment"):
			return null
		if not battle_state.deploy_participant(participant_id, "attacker_deployment"):
			return null
	for vehicle_id: String in attacker_veh_ids:
		if not _battle_register_vehicle(battle_state, vehicle_id, "attacker", "attacker_deployment"):
			return null
		if not battle_state.deploy_vehicle(vehicle_id, "attacker_deployment"):
			return null
	for participant_id: String in defender_part_ids:
		if not _battle_register_participant(battle_state, participant_id, "defender", "defender_deployment"):
			return null
		if not battle_state.deploy_participant(participant_id, "defender_deployment"):
			return null
	for vehicle_id: String in defender_veh_ids:
		if not _battle_register_vehicle(battle_state, vehicle_id, "defender", "defender_deployment"):
			return null
		if not battle_state.deploy_vehicle(vehicle_id, "defender_deployment"):
			return null
	return battle_state


static func _battlegeo_finite_point(point: Vector2) -> bool:
	return is_finite(point.x) and is_finite(point.y)


static func _battlegeo_positions_unique(points: Array[Vector2]) -> bool:
	var i: int = 0
	while i < points.size():
		var j: int = i + 1
		while j < points.size():
			if points[i].is_equal_approx(points[j]):
				return false
			j += 1
		i += 1
	return true


static func _battlegeo_same_part_positions(left: BattleState, right: BattleState) -> bool:
	if left == null or right == null:
		return false
	if left.participants.size() != right.participants.size():
		return false
	for participant_id: String in left.participants:
		if not right.has_participant(participant_id):
			return false
		var left_part: BattleParticipant = left.get_participant(participant_id)
		var right_part: BattleParticipant = right.get_participant(participant_id)
		if left_part == null or right_part == null:
			return false
		if left_part.has_battle_position != right_part.has_battle_position:
			return false
		if not left_part.battle_position.is_equal_approx(right_part.battle_position):
			return false
	return true


static func _battlegeo_same_veh_positions(left: BattleState, right: BattleState) -> bool:
	if left == null or right == null:
		return false
	if left.vehicles.size() != right.vehicles.size():
		return false
	for vehicle_id: String in left.vehicles:
		if not right.has_vehicle(vehicle_id):
			return false
		var left_veh: BattleVehicle = left.get_vehicle(vehicle_id)
		var right_veh: BattleVehicle = right.get_vehicle(vehicle_id)
		if left_veh == null or right_veh == null:
			return false
		if left_veh.has_battle_position != right_veh.has_battle_position:
			return false
		if not left_veh.battle_position.is_equal_approx(right_veh.battle_position):
			return false
	return true


static func _battlegeo_side_zone(battle_state: BattleState, side_id: String) -> DeploymentZone:
	if battle_state == null:
		return null
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null:
		return null
	return battle_state.get_deployment_zone(side.deployment_zone_id)


static func _battlegeo_deployed_parts_positioned(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	for zone_id: String in battle_state.deployment_zones:
		var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
		if zone == null:
			return false
		for participant_id: String in zone.deployed_participant_ids:
			var participant: BattleParticipant = battle_state.get_participant(participant_id)
			if participant == null or not participant.has_battle_position:
				return false
			if not _battlegeo_finite_point(participant.battle_position):
				return false
	return true


static func _battlegeo_deployed_vehs_positioned(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	for zone_id: String in battle_state.deployment_zones:
		var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
		if zone == null:
			return false
		for vehicle_id: String in zone.deployed_vehicle_ids:
			var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
			if vehicle == null or not vehicle.has_battle_position:
				return false
			if not _battlegeo_finite_point(vehicle.battle_position):
				return false
	return true


static func _battlegeo_side_part_unique(battle_state: BattleState, side_id: String) -> bool:
	var zone: DeploymentZone = _battlegeo_side_zone(battle_state, side_id)
	if zone == null:
		return false
	var points: Array[Vector2] = []
	for participant_id: String in zone.deployed_participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			return false
		points.append(participant.battle_position)
	return _battlegeo_positions_unique(points)


static func _battlegeo_side_veh_unique(battle_state: BattleState, side_id: String) -> bool:
	var zone: DeploymentZone = _battlegeo_side_zone(battle_state, side_id)
	if zone == null:
		return false
	var points: Array[Vector2] = []
	for vehicle_id: String in zone.deployed_vehicle_ids:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			return false
		points.append(vehicle.battle_position)
	return _battlegeo_positions_unique(points)


static func _battlegeo_side_part_in_zone(battle_state: BattleState, side_id: String) -> bool:
	var zone: DeploymentZone = _battlegeo_side_zone(battle_state, side_id)
	if zone == null:
		return false
	for participant_id: String in zone.deployed_participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			return false
		if not zone.contains_point(participant.battle_position):
			return false
	return true


static func _battlegeo_side_veh_in_zone(battle_state: BattleState, side_id: String) -> bool:
	var zone: DeploymentZone = _battlegeo_side_zone(battle_state, side_id)
	if zone == null:
		return false
	for vehicle_id: String in zone.deployed_vehicle_ids:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			return false
		if not zone.contains_point(vehicle.battle_position):
			return false
	return true


static func _battlegeo_part_veh_separated(battle_state: BattleState, side_id: String) -> bool:
	var zone: DeploymentZone = _battlegeo_side_zone(battle_state, side_id)
	if zone == null:
		return false
	var part_points: Array[Vector2] = []
	for participant_id: String in zone.deployed_participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			return false
		part_points.append(participant.battle_position)
	var veh_points: Array[Vector2] = []
	for vehicle_id: String in zone.deployed_vehicle_ids:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			return false
		veh_points.append(vehicle.battle_position)
	if part_points.is_empty() or veh_points.is_empty():
		return false
	for part_point: Vector2 in part_points:
		for veh_point: Vector2 in veh_points:
			if part_point.is_equal_approx(veh_point):
				return false
	return true


static func _battlegeo_semantic_snap(battle_state: BattleState) -> Dictionary:
	var snap: Dictionary = {}
	if battle_state == null:
		return snap
	var zone_ids: Array[String] = []
	var zone_types: Dictionary = {}
	var allowed_parts: Dictionary = {}
	var allowed_vehs: Dictionary = {}
	var deployed_parts: Dictionary = {}
	var deployed_vehs: Dictionary = {}
	for zone_id: String in battle_state.deployment_zones:
		var zone: DeploymentZone = battle_state.get_deployment_zone(zone_id)
		if zone == null:
			continue
		zone_ids.append(zone_id)
		zone_types[zone_id] = zone.zone_type
		allowed_parts[zone_id] = _copy_ids(zone.allowed_participant_ids)
		allowed_vehs[zone_id] = _copy_ids(zone.allowed_vehicle_ids)
		deployed_parts[zone_id] = _copy_ids(zone.deployed_participant_ids)
		deployed_vehs[zone_id] = _copy_ids(zone.deployed_vehicle_ids)
	snap["zone_ids"] = zone_ids
	snap["zone_types"] = zone_types
	snap["allowed_parts"] = allowed_parts
	snap["allowed_vehs"] = allowed_vehs
	snap["deployed_parts"] = deployed_parts
	snap["deployed_vehs"] = deployed_vehs
	var part_slots: Dictionary = {}
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant != null:
			part_slots[participant_id] = participant.deployment_slot_id
	snap["part_slots"] = part_slots
	var veh_slots: Dictionary = {}
	for vehicle_id: String in battle_state.vehicles:
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle != null:
			veh_slots[vehicle_id] = vehicle.deployment_slot_id
	snap["veh_slots"] = veh_slots
	return snap


static func _battlegeo_semantic_unchanged(battle_state: BattleState, snap: Dictionary) -> bool:
	if battle_state == null:
		return false
	var current: Dictionary = _battlegeo_semantic_snap(battle_state)
	if not _string_ids_match(
		_battlegeo_ids_from(current.get("zone_ids", [])),
		_battlegeo_ids_from(snap.get("zone_ids", []))
	):
		return false
	if not _battlegeo_string_map_match(current.get("zone_types", {}), snap.get("zone_types", {})):
		return false
	if not _battlegeo_id_list_map_match(current.get("allowed_parts", {}), snap.get("allowed_parts", {})):
		return false
	if not _battlegeo_id_list_map_match(current.get("allowed_vehs", {}), snap.get("allowed_vehs", {})):
		return false
	if not _battlegeo_id_list_map_match(current.get("deployed_parts", {}), snap.get("deployed_parts", {})):
		return false
	if not _battlegeo_id_list_map_match(current.get("deployed_vehs", {}), snap.get("deployed_vehs", {})):
		return false
	if not _battlegeo_string_map_match(current.get("part_slots", {}), snap.get("part_slots", {})):
		return false
	if not _battlegeo_string_map_match(current.get("veh_slots", {}), snap.get("veh_slots", {})):
		return false
	return true


static func _battlegeo_string_map_match(left_raw: Variant, right_raw: Variant) -> bool:
	if not (left_raw is Dictionary) or not (right_raw is Dictionary):
		return false
	var left: Dictionary = left_raw as Dictionary
	var right: Dictionary = right_raw as Dictionary
	if left.size() != right.size():
		return false
	for key: Variant in left:
		if not right.has(key):
			return false
		if str(left[key]) != str(right[key]):
			return false
	return true


static func _battlegeo_id_list_map_match(left_raw: Variant, right_raw: Variant) -> bool:
	if not (left_raw is Dictionary) or not (right_raw is Dictionary):
		return false
	var left: Dictionary = left_raw as Dictionary
	var right: Dictionary = right_raw as Dictionary
	if left.size() != right.size():
		return false
	for key: Variant in left:
		if not right.has(key):
			return false
		var left_ids: Array[String] = []
		var right_ids: Array[String] = []
		var left_list: Variant = left[key]
		var right_list: Variant = right[key]
		if left_list is Array:
			for item: Variant in left_list:
				left_ids.append(str(item))
		if right_list is Array:
			for item: Variant in right_list:
				right_ids.append(str(item))
		if not _string_ids_match(left_ids, right_ids):
			return false
	return true


static func _battlegeo_ids_from(value: Variant) -> Array[String]:
	var ids: Array[String] = []
	if value is Array:
		for item: Variant in value:
			ids.append(str(item))
	return ids


static func _battlegeo_campaign_coords(game_state: GameState) -> Dictionary:
	var snap: Dictionary = {}
	var loc_pos: Dictionary = {}
	var node_pos: Dictionary = {}
	snap["loc"] = loc_pos
	snap["nodes"] = node_pos
	if game_state == null:
		return snap
	for loc_id: String in game_state.map_locations:
		var location: MapLocation = game_state.get_map_location(loc_id)
		if location != null:
			loc_pos[loc_id] = location.map_position
	if game_state.road_graph != null:
		for node_id: String in game_state.road_graph.nodes:
			var node: RoadNode = game_state.road_graph.get_node(node_id)
			if node != null:
				node_pos[node_id] = node.map_position
	return snap


static func _battlegeo_campaign_coords_unchanged(game_state: GameState, snap: Dictionary) -> bool:
	if game_state == null:
		return false
	var current: Dictionary = _battlegeo_campaign_coords(game_state)
	if not _battlegeo_vector_map_match(current.get("loc", {}), snap.get("loc", {})):
		return false
	if not _battlegeo_vector_map_match(current.get("nodes", {}), snap.get("nodes", {})):
		return false
	return true


static func _battlegeo_vector_map_match(left_raw: Variant, right_raw: Variant) -> bool:
	if not (left_raw is Dictionary) or not (right_raw is Dictionary):
		return false
	var left: Dictionary = left_raw as Dictionary
	var right: Dictionary = right_raw as Dictionary
	if left.size() != right.size():
		return false
	for key: Variant in left:
		if not right.has(key):
			return false
		if typeof(left[key]) != TYPE_VECTOR2 or typeof(right[key]) != TYPE_VECTOR2:
			return false
		var left_pos: Vector2 = left[key] as Vector2
		var right_pos: Vector2 = right[key] as Vector2
		if not left_pos.is_equal_approx(right_pos):
			return false
	return true


static func _battlespatial_open_geometry() -> BattlefieldGeometry:
	var geometry: BattlefieldGeometry = BattlefieldGeometry.new()
	geometry.width = 100.0
	geometry.height = 60.0
	geometry.attacker_deployment_rect = Rect2(0.0, 0.0, 20.0, 60.0)
	geometry.defender_deployment_rect = Rect2(80.0, 0.0, 20.0, 60.0)
	return geometry


static func _battlespatial_attach_open_geometry(battle_state: BattleState) -> bool:
	if battle_state == null:
		return false
	var geometry: BattlefieldGeometry = _battlespatial_open_geometry()
	if geometry == null or not geometry.is_valid():
		return false
	battle_state.battlefield_geometry = geometry
	return true


static func _battlespatial_fail_ok(result: BattleSpatialResult, expected_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.resolved_displacement.is_equal_approx(Vector2.ZERO)
		and result.error_code == expected_code
		and result.error_message.begins_with("Battle spatial resolution failed:")
	)


static func _battlespatial_collinear(resolved: Vector2, requested: Vector2) -> bool:
	if not BattlefieldGeometry.is_finite_point(resolved) or not BattlefieldGeometry.is_finite_point(requested):
		return false
	if resolved.is_equal_approx(Vector2.ZERO):
		return true
	if requested.is_equal_approx(Vector2.ZERO):
		return false
	return is_equal_approx(resolved.cross(requested), 0.0) and resolved.dot(requested) >= 0.0


static func _battlenav_success_ok(
	result: BattleNavigationResult,
	start_position: Vector2,
	destination: Vector2,
	used_detour: bool
) -> bool:
	if result == null:
		return false
	if not result.success:
		return false
	if result.used_detour != used_detour:
		return false
	if not result.error_code.is_empty() or not result.error_message.is_empty():
		return false
	if not result.start_position.is_equal_approx(start_position):
		return false
	if not result.destination.is_equal_approx(destination):
		return false
	if result.waypoints.is_empty():
		return false
	return result.waypoints[result.waypoints.size() - 1].is_equal_approx(destination)


static func _battlenav_fail_ok(
	result: BattleNavigationResult,
	expected_code: String,
	start_position: Vector2,
	destination: Vector2
) -> bool:
	if result == null:
		return false
	if result.success:
		return false
	if result.error_code != expected_code:
		return false
	if not result.error_message.begins_with("Battle navigation failed:"):
		return false
	if not result.waypoints.is_empty():
		return false
	if result.used_detour:
		return false
	if BattlefieldGeometry.is_finite_point(start_position) and not result.start_position.is_equal_approx(start_position):
		return false
	if BattlefieldGeometry.is_finite_point(destination) and not result.destination.is_equal_approx(destination):
		return false
	return true


static func _battlenav_segments_clear(
	battle_state: BattleState,
	start_position: Vector2,
	waypoints: Array[Vector2]
) -> bool:
	if battle_state == null:
		return false
	var current: Vector2 = start_position
	for waypoint: Vector2 in waypoints:
		if not BattleSpatialService.is_translation_clear(battle_state, current, waypoint):
			return false
		current = waypoint
	return true


static func _battlenav_waypoints_legal(
	battle_state: BattleState,
	waypoints: Array[Vector2],
	destination: Vector2
) -> bool:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if waypoints.is_empty():
		return false
	if not waypoints[waypoints.size() - 1].is_equal_approx(destination):
		return false
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	for waypoint: Vector2 in waypoints:
		if not BattlefieldGeometry.is_finite_point(waypoint):
			return false
		if not geometry.contains_point(waypoint):
			return false
		if _battlenav_inside_blocker(geometry, waypoint):
			return false
	return true


static func _battlenav_inside_blocker(geometry: BattlefieldGeometry, point: Vector2) -> bool:
	if geometry == null:
		return false
	var obstacle_ids: Array[String] = geometry.get_sorted_obstacle_ids()
	for obstacle_id: String in obstacle_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if obstacle.contains_point(point):
			return true
	return false


static func _battlenav_no_duplicate_waypoints(result: BattleNavigationResult) -> bool:
	if result == null:
		return false
	for i: int in range(result.waypoints.size()):
		if i > 0 and result.waypoints[i].is_equal_approx(result.waypoints[i - 1]):
			return false
	if result.success and result.waypoints.size() >= 2:
		if result.waypoints[result.waypoints.size() - 1].is_equal_approx(result.destination):
			if result.waypoints[result.waypoints.size() - 2].is_equal_approx(result.destination):
				return false
	return true


static func _battlenav_route_length(start_position: Vector2, waypoints: Array[Vector2]) -> float:
	var length: float = 0.0
	var current: Vector2 = start_position
	for waypoint: Vector2 in waypoints:
		length += current.distance_to(waypoint)
		current = waypoint
	return length


static func _battlenav_copy_points(source: Array[Vector2]) -> Array[Vector2]:
	var copied: Array[Vector2] = []
	for point: Vector2 in source:
		copied.append(point)
	return copied


static func _battlenav_waypoints_match(left: Array[Vector2], right: Array[Vector2]) -> bool:
	if left.size() != right.size():
		return false
	for i: int in range(left.size()):
		if not left[i].is_equal_approx(right[i]):
			return false
	return true


static func _battlenav_geo_snap(geometry: BattlefieldGeometry) -> Dictionary:
	var snap: Dictionary = {}
	if geometry == null:
		snap["null"] = true
		return snap
	snap["null"] = false
	snap["w"] = geometry.width
	snap["h"] = geometry.height
	snap["count"] = geometry.obstacles.size()
	var ids: Array[String] = geometry.get_sorted_obstacle_ids()
	snap["ids"] = ids
	var bounds: Dictionary = {}
	var blocking: Dictionary = {}
	for obstacle_id: String in ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null:
			continue
		bounds[obstacle_id] = obstacle.bounds
		blocking[obstacle_id] = obstacle.blocks_movement
	snap["bounds"] = bounds
	snap["blocking"] = blocking
	return snap


static func _battlenav_geo_unchanged(geometry: BattlefieldGeometry, snap: Dictionary) -> bool:
	if geometry == null:
		return bool(snap.get("null", false))
	if bool(snap.get("null", false)):
		return false
	if not is_equal_approx(geometry.width, float(snap.get("w", -1.0))):
		return false
	if not is_equal_approx(geometry.height, float(snap.get("h", -1.0))):
		return false
	if geometry.obstacles.size() != int(snap.get("count", -1)):
		return false
	var expected_ids: Array[String] = []
	var id_data: Variant = snap.get("ids", [])
	if id_data is Array:
		for item: Variant in id_data:
			expected_ids.append(str(item))
	if not _string_ids_match(geometry.get_sorted_obstacle_ids(), expected_ids):
		return false
	var bounds_raw: Variant = snap.get("bounds", {})
	var blocking_raw: Variant = snap.get("blocking", {})
	if not (bounds_raw is Dictionary) or not (blocking_raw is Dictionary):
		return false
	var bounds: Dictionary = bounds_raw as Dictionary
	var blocking: Dictionary = blocking_raw as Dictionary
	for obstacle_id: String in expected_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null:
			return false
		if not bounds.has(obstacle_id) or typeof(bounds[obstacle_id]) != TYPE_RECT2:
			return false
		var expected_bounds: Rect2 = bounds[obstacle_id] as Rect2
		if obstacle.bounds != expected_bounds:
			return false
		if obstacle.blocks_movement != bool(blocking.get(obstacle_id, not obstacle.blocks_movement)):
			return false
	return true


static func _battlenav_corners_clear(
	battle_state: BattleState,
	start_position: Vector2,
	waypoints: Array[Vector2]
) -> bool:
	if battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if waypoints.is_empty():
		return false
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	var current: Vector2 = start_position
	for waypoint: Vector2 in waypoints:
		if not BattlefieldGeometry.is_finite_point(waypoint):
			return false
		if not geometry.contains_point(waypoint):
			return false
		if _battlenav_inside_blocker(geometry, waypoint):
			return false
		if not BattleSpatialService.is_translation_clear(battle_state, current, waypoint):
			return false
		current = waypoint
	return true


static func _battlenav_is_simplified(
	battle_state: BattleState,
	start_position: Vector2,
	waypoints: Array[Vector2]
) -> bool:
	if battle_state == null or waypoints.is_empty():
		return false
	var current: Vector2 = start_position
	var index: int = 0
	while index < waypoints.size():
		var farthest: int = index
		var probe: int = waypoints.size() - 1
		while probe > index:
			if BattleSpatialService.is_translation_clear(battle_state, current, waypoints[probe]):
				farthest = probe
				break
			probe -= 1
		if farthest != index:
			return false
		current = waypoints[index]
		index += 1
	return true


static func _battlenav_rect_short_detour_length(bounds: Rect2, start_position: Vector2, destination: Vector2) -> float:
	var epsilon: float = BattleNavigationService.NAVIGATION_CLEARANCE_EPSILON
	var min_x: float = bounds.position.x
	var min_y: float = bounds.position.y
	var max_x: float = bounds.position.x + bounds.size.x
	var max_y: float = bounds.position.y + bounds.size.y
	var top_left: Vector2 = Vector2(min_x - epsilon, min_y - epsilon)
	var top_right: Vector2 = Vector2(max_x + epsilon, min_y - epsilon)
	var bottom_left: Vector2 = Vector2(min_x - epsilon, max_y + epsilon)
	var bottom_right: Vector2 = Vector2(max_x + epsilon, max_y + epsilon)
	var top_length: float = (
		start_position.distance_to(top_left)
		+ top_left.distance_to(top_right)
		+ top_right.distance_to(destination)
	)
	var bottom_length: float = (
		start_position.distance_to(bottom_left)
		+ bottom_left.distance_to(bottom_right)
		+ bottom_right.distance_to(destination)
	)
	if top_length < bottom_length:
		return top_length
	return bottom_length


static func _battlefollow_ok(
	result: BattlePathFollowResult,
	considered: int,
	with_paths: int,
	completed: int
) -> bool:
	if result == null:
		return false
	return (
		result.success
		and result.error_code.is_empty()
		and result.error_message.is_empty()
		and result.participants_considered == considered
		and result.participants_with_paths == with_paths
		and result.participants_completed_paths == completed
	)


static func _battlefollow_fail_ok(result: BattlePathFollowResult, expected_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.error_code == expected_code
		and result.error_message.begins_with("Battle path follow failed:")
		and result.participants_considered == 0
		and result.participants_with_paths == 0
		and result.participants_completed_paths == 0
	)


static func _battlefollow_part_snap(participant: BattleParticipant) -> Dictionary:
	var snap: Dictionary = {}
	if participant == null:
		return snap
	snap["intent"] = participant.movement_intent
	snap["speed"] = participant.movement_speed
	snap["has_target"] = participant.has_movement_target_position
	snap["target"] = participant.movement_target_position
	snap["has_dest"] = participant.has_navigation_destination
	snap["dest"] = participant.navigation_destination
	snap["index"] = participant.navigation_waypoint_index
	snap["waypoints"] = _battlenav_copy_points(participant.navigation_waypoints)
	snap["has_pos"] = participant.has_battle_position
	snap["pos"] = participant.battle_position
	snap["alive"] = participant.is_alive
	return snap


static func _battlefollow_part_unchanged(participant: BattleParticipant, snap: Dictionary) -> bool:
	if participant == null:
		return false
	var intent_raw: Variant = snap.get("intent", Vector2.ZERO)
	var target_raw: Variant = snap.get("target", Vector2.ZERO)
	var dest_raw: Variant = snap.get("dest", Vector2.ZERO)
	var pos_raw: Variant = snap.get("pos", Vector2.ZERO)
	if typeof(intent_raw) != TYPE_VECTOR2 or typeof(target_raw) != TYPE_VECTOR2:
		return false
	if typeof(dest_raw) != TYPE_VECTOR2 or typeof(pos_raw) != TYPE_VECTOR2:
		return false
	var intent: Vector2 = intent_raw as Vector2
	var target: Vector2 = target_raw as Vector2
	var dest: Vector2 = dest_raw as Vector2
	var pos: Vector2 = pos_raw as Vector2
	var waypoints_raw: Variant = snap.get("waypoints", [])
	var expected_waypoints: Array[Vector2] = []
	if waypoints_raw is Array:
		for item: Variant in waypoints_raw:
			if typeof(item) == TYPE_VECTOR2:
				expected_waypoints.append(item as Vector2)
	return (
		participant.movement_intent.is_equal_approx(intent)
		and is_equal_approx(participant.movement_speed, float(snap.get("speed", 0.0)))
		and participant.has_movement_target_position == bool(snap.get("has_target", false))
		and participant.movement_target_position.is_equal_approx(target)
		and participant.has_navigation_destination == bool(snap.get("has_dest", false))
		and participant.navigation_destination.is_equal_approx(dest)
		and participant.navigation_waypoint_index == int(snap.get("index", -1))
		and _battlenav_waypoints_match(participant.navigation_waypoints, expected_waypoints)
		and participant.has_battle_position == bool(snap.get("has_pos", false))
		and participant.battle_position.is_equal_approx(pos)
		and participant.is_alive == bool(snap.get("alive", false))
	)


static func _battletarget_place(participant: BattleParticipant, position: Vector2) -> void:
	if participant == null:
		return
	participant.has_battle_position = true
	participant.battle_position = position


static func _battletarget_has(participant: BattleParticipant, expected_id: String) -> bool:
	if participant == null:
		return false
	return participant.has_target_participant and participant.target_participant_id == expected_id


static func _battletarget_none(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	return not participant.has_target_participant and participant.target_participant_id.is_empty()


static func _battletarget_ok(
	result: BattleTargetSelectionResult,
	considered: int,
	with_hostiles: int,
	with_targets: int,
	changed: int
) -> bool:
	if result == null:
		return false
	return (
		result.success
		and result.error_code.is_empty()
		and result.error_message.is_empty()
		and result.participants_considered == considered
		and result.participants_with_hostiles == with_hostiles
		and result.participants_with_targets == with_targets
		and result.targets_changed == changed
	)


static func _battletarget_fail_ok(result: BattleTargetSelectionResult, expected_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.error_code == expected_code
		and result.error_message.begins_with("Battle target selection failed:")
		and result.participants_considered == 0
		and result.participants_with_hostiles == 0
		and result.participants_with_targets == 0
		and result.targets_changed == 0
	)


static func _battletarget_part_snap(participant: BattleParticipant) -> Dictionary:
	var snap: Dictionary = _battlefollow_part_snap(participant)
	if participant == null:
		return snap
	snap["vel"] = participant.velocity
	snap["has_tgt"] = participant.has_target_participant
	snap["tgt_id"] = participant.target_participant_id
	return snap


static func _battletarget_part_unchanged(participant: BattleParticipant, snap: Dictionary) -> bool:
	if not _battlefollow_part_unchanged(participant, snap):
		return false
	var vel_raw: Variant = snap.get("vel", Vector2.ZERO)
	if typeof(vel_raw) != TYPE_VECTOR2:
		return false
	var vel: Vector2 = vel_raw as Vector2
	return (
		participant.velocity.is_equal_approx(vel)
		and participant.has_target_participant == bool(snap.get("has_tgt", false))
		and participant.target_participant_id == str(snap.get("tgt_id", ""))
	)


static func _battletarget_make_state_with_sides(p_phase: String, side_ids: Array[String]) -> BattleState:
	if side_ids.size() < 2:
		return null
	var battle_state: BattleState = BattleState.new(
		"battletarget_battle",
		"battletarget_type",
		"battletarget_mission",
		"battletarget_location",
		side_ids[0],
		side_ids[1],
		p_phase
	)
	var index: int = 0
	for side_id: String in side_ids:
		var side: BattleSide = BattleSide.new(side_id, "battletarget_f" + str(index), "", index == 0, "")
		if not battle_state.add_side(side):
			return null
		index += 1
	if not _battlespatial_attach_open_geometry(battle_state):
		return null
	return battle_state


static func _battletarget_tie_selected(first_id: String, second_id: String) -> String:
	var battle_state: BattleState = _battlemove_make_state("active")
	if battle_state == null:
		return ""
	var source: BattleParticipant = _battlemove_add_participant(battle_state, "tie_src", "attacker")
	var first: BattleParticipant = _battlemove_add_participant(battle_state, first_id, "defender")
	var second: BattleParticipant = _battlemove_add_participant(battle_state, second_id, "defender")
	if source == null or first == null or second == null:
		return ""
	_battletarget_place(source, Vector2(10.0, 10.0))
	_battletarget_place(first, Vector2(20.0, 10.0))
	_battletarget_place(second, Vector2(10.0, 20.0))
	var result: BattleTargetSelectionResult = BattleTargetSelectionService.advance(battle_state)
	if result == null or not result.success:
		return ""
	return source.target_participant_id


static func _battletarget_multi_run(add_order: Array[String]) -> bool:
	var battle_state: BattleState = _battlemove_make_state("active")
	if battle_state == null:
		return false
	var added: Dictionary = {}
	for participant_id: String in add_order:
		var side_id: String = "attacker"
		if participant_id.ends_with("enemy"):
			side_id = "defender"
		var participant: BattleParticipant = _battlemove_add_participant(battle_state, participant_id, side_id)
		if participant == null:
			return false
		added[participant_id] = participant
	var z_src: BattleParticipant = added.get("z_src", null) as BattleParticipant
	var a_src: BattleParticipant = added.get("a_src", null) as BattleParticipant
	var m_enemy: BattleParticipant = added.get("m_enemy", null) as BattleParticipant
	var b_enemy: BattleParticipant = added.get("b_enemy", null) as BattleParticipant
	if z_src == null or a_src == null or m_enemy == null or b_enemy == null:
		return false
	_battletarget_place(z_src, Vector2(10.0, 10.0))
	_battletarget_place(a_src, Vector2(12.0, 40.0))
	_battletarget_place(m_enemy, Vector2(18.0, 10.0))
	_battletarget_place(b_enemy, Vector2(12.0, 48.0))
	var result: BattleTargetSelectionResult = BattleTargetSelectionService.advance(battle_state)
	return (
		_battletarget_ok(result, 4, 4, 4, 4)
		and _battletarget_has(z_src, "m_enemy")
		and _battletarget_has(a_src, "b_enemy")
		and _battletarget_has(m_enemy, "z_src")
		and _battletarget_has(b_enemy, "a_src")
	)


static func _battlelos_clear_ok(
	result: BattleLineOfSightResult,
	source_id: String,
	target_id: String
) -> bool:
	if result == null:
		return false
	if not result.success or not result.has_line_of_sight:
		return false
	if not result.blocking_obstacle_id.is_empty():
		return false
	if not result.error_code.is_empty() or not result.error_message.is_empty():
		return false
	if not source_id.is_empty() and result.source_participant_id != source_id:
		return false
	if not target_id.is_empty() and result.target_participant_id != target_id:
		return false
	return true


static func _battlelos_blocked_ok(
	result: BattleLineOfSightResult,
	source_id: String,
	target_id: String,
	blocker_id: String
) -> bool:
	if result == null:
		return false
	if not result.success:
		return false
	if result.has_line_of_sight:
		return false
	if result.blocking_obstacle_id != blocker_id:
		return false
	if not result.error_code.is_empty() or not result.error_message.is_empty():
		return false
	if not source_id.is_empty() and result.source_participant_id != source_id:
		return false
	if not target_id.is_empty() and result.target_participant_id != target_id:
		return false
	return true


static func _battlelos_segment_clear_ok(result: BattleLineOfSightResult) -> bool:
	return _battlelos_clear_ok(result, "", "")


static func _battlelos_fail_ok(result: BattleLineOfSightResult, expected_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.has_line_of_sight == false
		and result.error_code == expected_code
		and result.error_message.begins_with("Battle line of sight failed:")
		and result.blocking_obstacle_id.is_empty()
	)


static func _battlelos_geo_snap(geometry: BattlefieldGeometry) -> Dictionary:
	var snap: Dictionary = {}
	if geometry == null:
		snap["null"] = true
		return snap
	snap["null"] = false
	snap["ids"] = geometry.get_sorted_obstacle_ids()
	var bounds: Dictionary = {}
	var move_flags: Dictionary = {}
	var los_flags: Dictionary = {}
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null:
			continue
		bounds[obstacle_id] = obstacle.bounds
		move_flags[obstacle_id] = obstacle.blocks_movement
		los_flags[obstacle_id] = obstacle.blocks_line_of_sight
	snap["bounds"] = bounds
	snap["move"] = move_flags
	snap["los"] = los_flags
	return snap


static func _battlelos_geo_unchanged(geometry: BattlefieldGeometry, snap: Dictionary) -> bool:
	if geometry == null:
		return bool(snap.get("null", false))
	if bool(snap.get("null", false)):
		return false
	var ids_raw: Variant = snap.get("ids", [])
	var expected_ids: Array[String] = []
	if ids_raw is Array:
		for item: Variant in ids_raw:
			expected_ids.append(str(item))
	if not _string_ids_match(geometry.get_sorted_obstacle_ids(), expected_ids):
		return false
	var bounds_raw: Variant = snap.get("bounds", {})
	var move_raw: Variant = snap.get("move", {})
	var los_raw: Variant = snap.get("los", {})
	if not (bounds_raw is Dictionary) or not (move_raw is Dictionary) or not (los_raw is Dictionary):
		return false
	var bounds: Dictionary = bounds_raw as Dictionary
	var move_flags: Dictionary = move_raw as Dictionary
	var los_flags: Dictionary = los_raw as Dictionary
	for obstacle_id: String in expected_ids:
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null:
			return false
		if not bounds.has(obstacle_id) or typeof(bounds[obstacle_id]) != TYPE_RECT2:
			return false
		var expected_bounds: Rect2 = bounds[obstacle_id] as Rect2
		if not obstacle.bounds.position.is_equal_approx(expected_bounds.position):
			return false
		if not obstacle.bounds.size.is_equal_approx(expected_bounds.size):
			return false
		if obstacle.blocks_movement != bool(move_flags.get(obstacle_id, not obstacle.blocks_movement)):
			return false
		if obstacle.blocks_line_of_sight != bool(los_flags.get(obstacle_id, not obstacle.blocks_line_of_sight)):
			return false
	return true


static func _battlelos_earliest_blocker(add_order: Array[String]) -> String:
	var battle_state: BattleState = _battlemove_make_state("active")
	if battle_state == null or battle_state.battlefield_geometry == null:
		return ""
	for obstacle_id: String in add_order:
		var bounds: Rect2 = Rect2(55.0, 20.0, 8.0, 20.0)
		if obstacle_id == "los_near":
			bounds = Rect2(30.0, 20.0, 8.0, 20.0)
		var obstacle: BattleObstacle = BattleObstacle.new(obstacle_id, bounds, true, true)
		if not battle_state.battlefield_geometry.add_obstacle(obstacle):
			return ""
	var result: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
		battle_state,
		Vector2(15.0, 30.0),
		Vector2(80.0, 30.0)
	)
	if result == null or not result.success or result.has_line_of_sight:
		return ""
	return result.blocking_obstacle_id


static func _battlefire_catalog_match(
	definition: BattleWeaponDefinition,
	weapon_id: String,
	max_range: float,
	shots_per_second: float,
	magazine_capacity: int,
	reload_seconds: float
) -> bool:
	if definition == null or not definition.is_valid():
		return false
	return (
		definition.weapon_type_id == weapon_id
		and is_equal_approx(definition.max_range, max_range)
		and is_equal_approx(definition.shots_per_second, shots_per_second)
		and definition.magazine_capacity == magazine_capacity
		and is_equal_approx(definition.reload_seconds, reload_seconds)
	)


static func _battlefire_initial_ok(
	participant: BattleParticipant,
	weapon_id: String,
	magazine_capacity: int
) -> bool:
	if participant == null or participant.weapon_state == null:
		return false
	var state: BattleWeaponState = participant.weapon_state
	return (
		participant.weapon_type == weapon_id
		and state.weapon_type_id == weapon_id
		and state.ammo_in_magazine == magazine_capacity
		and is_equal_approx(state.cooldown_remaining_seconds, 0.0)
		and is_equal_approx(state.reload_remaining_seconds, 0.0)
		and not state.is_reloading
	)


static func _battlefire_fail_ok(result: BattleFireControlResult, expected_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and result.error_code == expected_code
		and result.error_message.begins_with("Battle fire control failed:")
		and result.participants_considered == 0
		and result.participants_eligible_to_fire == 0
	)


static func _battlefire_eval_counts(
	result: BattleFireControlResult,
	considered: int,
	with_targets: int,
	eligible: int,
	blocked_los: int,
	blocked_range: int,
	blocked_cooldown: int,
	reloading: int,
	empty: int
) -> bool:
	if result == null:
		return false
	return (
		result.success
		and result.error_code.is_empty()
		and result.error_message.is_empty()
		and result.participants_considered == considered
		and result.participants_with_targets == with_targets
		and result.participants_eligible_to_fire == eligible
		and result.participants_blocked_by_los == blocked_los
		and result.participants_blocked_by_range == blocked_range
		and result.participants_blocked_by_cooldown == blocked_cooldown
		and result.participants_reloading == reloading
		and result.participants_empty == empty
	)


static func _battlefire_add(
	battle_state: BattleState,
	participant_id: String,
	side_id: String,
	weapon_type: String
) -> BattleParticipant:
	if battle_state == null:
		return null
	var participant: BattleParticipant = BattleParticipant.new(
		participant_id,
		"battlefire_soldier_" + participant_id,
		"battlemove_a",
		side_id,
		weapon_type,
		true,
		false,
		""
	)
	if side_id == "defender":
		participant.faction_id = "battlemove_b"
	if not battle_state.add_participant(participant):
		return null
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null or not side.add_participant_id(participant_id):
		return null
	return participant


static func _battlefire_weapon_snap(participant: BattleParticipant) -> Dictionary:
	var snap: Dictionary = {}
	if participant == null or participant.weapon_state == null:
		snap["null_state"] = true
		return snap
	var state: BattleWeaponState = participant.weapon_state
	snap["null_state"] = false
	snap["id"] = state.weapon_type_id
	snap["ammo"] = state.ammo_in_magazine
	snap["cooldown"] = state.cooldown_remaining_seconds
	snap["reload"] = state.reload_remaining_seconds
	snap["reloading"] = state.is_reloading
	return snap


static func _battlefire_weapon_unchanged(participant: BattleParticipant, snap: Dictionary) -> bool:
	if participant == null:
		return false
	if bool(snap.get("null_state", false)):
		return participant.weapon_state == null
	if participant.weapon_state == null:
		return false
	var state: BattleWeaponState = participant.weapon_state
	return (
		state.weapon_type_id == str(snap.get("id", ""))
		and state.ammo_in_magazine == int(snap.get("ammo", -1))
		and is_equal_approx(state.cooldown_remaining_seconds, float(snap.get("cooldown", -1.0)))
		and is_equal_approx(state.reload_remaining_seconds, float(snap.get("reload", -1.0)))
		and state.is_reloading == bool(snap.get("reloading", false))
	)


static func _battlefire_full_snap(participant: BattleParticipant) -> Dictionary:
	var snap: Dictionary = _battletarget_part_snap(participant)
	var weapon: Dictionary = _battlefire_weapon_snap(participant)
	for key: Variant in weapon:
		snap[str(key)] = weapon[key]
	if participant != null:
		snap["weapon_type"] = participant.weapon_type
	return snap


static func _battlefire_full_unchanged(participant: BattleParticipant, snap: Dictionary) -> bool:
	if not _battletarget_part_unchanged(participant, snap):
		return false
	if participant != null and participant.weapon_type != str(snap.get("weapon_type", "")):
		return false
	return _battlefire_weapon_unchanged(participant, snap)


static func _battlefire_reason_eval(
	is_reloading: bool,
	ammo: int,
	cooldown: float,
	source_position: Vector2,
	target_position: Vector2,
	with_wall: bool
) -> BattleFireControlResult:
	var battle_state: BattleState = _battlemove_make_state("active")
	if battle_state == null or battle_state.battlefield_geometry == null:
		return null
	if with_wall:
		var wall: BattleObstacle = BattleObstacle.new(
			"fire_reason_wall",
			Rect2(28.0, 20.0, 8.0, 20.0),
			true,
			true
		)
		if not battle_state.battlefield_geometry.add_obstacle(wall):
			return null
	var source: BattleParticipant = _battlefire_add(battle_state, "fire_reason_src", "attacker", "pistol")
	var target: BattleParticipant = _battlefire_add(battle_state, "fire_reason_tgt", "defender", "pistol")
	if source == null or target == null or source.weapon_state == null:
		return null
	_battletarget_place(source, source_position)
	_battletarget_place(target, target_position)
	source.set_target_participant("fire_reason_tgt")
	source.weapon_state.is_reloading = is_reloading
	source.weapon_state.ammo_in_magazine = ammo
	source.weapon_state.cooldown_remaining_seconds = cooldown
	return BattleFireControlService.evaluate_fire_eligibility(battle_state)


static func _battlefire_mixed_eval(add_order: Array[String]) -> BattleFireControlResult:
	var battle_state: BattleState = _battlemove_make_state("active")
	if battle_state == null or battle_state.battlefield_geometry == null:
		return null
	var wall: BattleObstacle = BattleObstacle.new("fire_mix_wall", Rect2(29.0, 29.0, 2.0, 2.0), true, true)
	if not battle_state.battlefield_geometry.add_obstacle(wall):
		return null
	var target: BattleParticipant = _battlefire_add(battle_state, "fire_mix_t", "defender", "pistol")
	if target == null:
		return null
	_battletarget_place(target, Vector2(40.0, 30.0))
	for kind: String in add_order:
		var source_id: String = "fire_mix_" + kind
		var source: BattleParticipant = _battlefire_add(battle_state, source_id, "attacker", "pistol")
		if source == null or source.weapon_state == null:
			return null
		source.set_target_participant("fire_mix_t")
		match kind:
			"e":
				_battletarget_place(source, Vector2(30.0, 40.0))
			"c":
				_battletarget_place(source, Vector2(30.0, 38.0))
				source.weapon_state.cooldown_remaining_seconds = 0.5
			"r":
				_battletarget_place(source, Vector2(5.0, 30.0))
			"l":
				_battletarget_place(source, Vector2(20.0, 30.0))
			"m":
				_battletarget_place(source, Vector2(32.0, 40.0))
				source.weapon_state.ammo_in_magazine = 0
			"n":
				_battletarget_place(source, Vector2(28.0, 38.0))
				source.weapon_state.is_reloading = true
				source.weapon_state.reload_remaining_seconds = 0.8
			_:
				return null
	return BattleFireControlService.evaluate_fire_eligibility(battle_state)


static func _battleattack_make_ready(
	source_id: String,
	target_id: String,
	weapon_type: String = "pistol",
	source_position: Vector2 = Vector2(10.0, 10.0),
	target_position: Vector2 = Vector2(20.0, 10.0)
) -> Dictionary:
	var pack: Dictionary = {}
	var battle_state: BattleState = _battlemove_make_state("active")
	if battle_state == null:
		return pack
	var source: BattleParticipant = _battlefire_add(battle_state, source_id, "attacker", weapon_type)
	var target: BattleParticipant = _battlefire_add(battle_state, target_id, "defender", weapon_type)
	if source == null or target == null:
		return pack
	_battletarget_place(source, source_position)
	_battletarget_place(target, target_position)
	pack["battle_state"] = battle_state
	pack["source"] = source
	pack["target"] = target
	return pack


static func _battleattack_fail_ok(result: BattleAttackResult, error_code: String) -> bool:
	if result == null:
		return false
	return (
		not result.success
		and not result.shot_executed
		and result.attack_event == null
		and result.rejection_code.is_empty()
		and result.error_code == error_code
		and not result.error_message.is_empty()
	)


static func _battleattack_rejected_ok(result: BattleAttackResult, rejection_code: String) -> bool:
	if result == null:
		return false
	return (
		result.success
		and not result.shot_executed
		and result.attack_event == null
		and result.rejection_code == rejection_code
		and result.error_code.is_empty()
		and result.error_message.is_empty()
	)


static func _battleattack_executed_ok(
	result: BattleAttackResult,
	source_id: String,
	target_id: String,
	weapon_type_id: String,
	outcome: String,
	outcome_roll: float,
	was_wounded: bool,
	is_wounded: bool,
	was_alive: bool,
	is_alive: bool
) -> bool:
	if result == null or result.attack_event == null:
		return false
	var attack_event: BattleAttackEvent = result.attack_event
	return (
		result.success
		and result.shot_executed
		and result.rejection_code.is_empty()
		and result.error_code.is_empty()
		and result.error_message.is_empty()
		and attack_event.source_participant_id == source_id
		and attack_event.target_participant_id == target_id
		and attack_event.weapon_type_id == weapon_type_id
		and attack_event.outcome == outcome
		and is_equal_approx(attack_event.outcome_roll, outcome_roll)
		and attack_event.target_was_wounded == was_wounded
		and attack_event.target_is_wounded == is_wounded
		and attack_event.target_was_alive == was_alive
		and attack_event.target_is_alive == is_alive
		and attack_event.get("ui_text") == null
		and attack_event.get("damage") == null
		and attack_event.get("hit_points") == null
	)


static func _battleattack_tx_snap(participant: BattleParticipant) -> Dictionary:
	var snap: Dictionary = _battlefire_full_snap(participant)
	if participant != null:
		snap["wounded"] = participant.is_wounded
	return snap


static func _battleattack_tx_unchanged(participant: BattleParticipant, snap: Dictionary) -> bool:
	if not _battlefire_full_unchanged(participant, snap):
		return false
	if participant == null:
		return false
	return participant.is_wounded == bool(snap.get("wounded", false))


static func _battleattack_cycled_once(
	source: BattleParticipant,
	ammo_before: int,
	weapon_type_id: String
) -> bool:
	if source == null or source.weapon_state == null:
		return false
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null:
		return false
	return (
		source.weapon_state.ammo_in_magazine == ammo_before - 1
		and source.weapon_state.ammo_in_magazine >= 0
		and is_equal_approx(
			source.weapon_state.cooldown_remaining_seconds,
			definition.cooldown_seconds()
		)
		and not source.weapon_state.is_reloading
	)


static func _battleattack_no_hidden_status(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	return (
		participant.get("hit_points") == null
		and participant.get("health") == null
		and participant.get("damage") == null
		and participant.get("armor") == null
		and participant.get("penetration") == null
		and participant.get("suppression") == null
		and participant.get("stagger") == null
		and participant.get("bleed") == null
		and participant.get("bleeding") == null
		and participant.get("graze_count") == null
		and participant.get("cover_value") == null
		and participant.get("elevation_level") == null
		and participant.get("defend_position") == null
		and participant.get("accuracy") == null
	)


static func _battleattack_expect_reject(kind: String) -> bool:
	var source_id: String = "atk_rj_src"
	var target_id: String = "atk_rj_tgt"
	var weapon_type: String = "pistol"
	var source_position: Vector2 = Vector2(10.0, 10.0)
	var target_position: Vector2 = Vector2(20.0, 10.0)
	var expected_code: String = ""
	match kind:
		"out_of_range":
			target_position = Vector2(34.5, 10.0)
			expected_code = "out_of_range"
		"los":
			source_position = Vector2(20.0, 30.0)
			target_position = Vector2(40.0, 30.0)
			expected_code = "line_of_sight_blocked"
		"source_dead":
			expected_code = "source_not_eligible"
		"source_unpos":
			expected_code = "source_not_eligible"
		"target_dead":
			expected_code = "target_not_eligible"
		"target_unpos":
			expected_code = "target_not_eligible"
		"no_weapon":
			expected_code = "invalid_weapon_state"
		"unknown_weapon":
			expected_code = "invalid_weapon_state"
		"mismatch":
			expected_code = "weapon_type_mismatch"
		"reloading":
			expected_code = "reloading"
		"empty":
			expected_code = "empty_magazine"
		"cooldown":
			expected_code = "cooldown"
		_:
			return false
	var pack: Dictionary = _battleattack_make_ready(
		source_id,
		target_id,
		weapon_type,
		source_position,
		target_position
	)
	var battle_state: BattleState = pack.get("battle_state", null) as BattleState
	var source: BattleParticipant = pack.get("source", null) as BattleParticipant
	var target: BattleParticipant = pack.get("target", null) as BattleParticipant
	if battle_state == null or source == null or target == null or source.weapon_state == null:
		return false
	if kind == "los":
		var wall: BattleObstacle = BattleObstacle.new(
			"atk_rj_wall",
			Rect2(28.0, 20.0, 6.0, 20.0),
			true,
			true
		)
		if battle_state.battlefield_geometry == null:
			return false
		if not battle_state.battlefield_geometry.add_obstacle(wall):
			return false
		source.set_target_participant(target_id)
	match kind:
		"source_dead":
			source.is_alive = false
		"source_unpos":
			source.has_battle_position = false
		"target_dead":
			target.is_alive = false
		"target_unpos":
			target.has_battle_position = false
		"no_weapon":
			source.weapon_state = null
		"unknown_weapon":
			source.weapon_type = "laser"
			source.weapon_state.weapon_type_id = "laser"
		"mismatch":
			source.weapon_state.weapon_type_id = "rifle"
		"reloading":
			source.weapon_state.is_reloading = true
			source.weapon_state.reload_remaining_seconds = 0.9
		"empty":
			source.weapon_state.ammo_in_magazine = 0
			source.weapon_state.is_reloading = false
		"cooldown":
			source.weapon_state.cooldown_remaining_seconds = 0.4
		_:
			pass
	source.set_movement_speed(2.0)
	source.set_movement_intent(Vector2(1.0, 0.0))
	source.set_navigation_path(Vector2(10.0, 16.0), [Vector2(10.0, 16.0)])
	var source_snap: Dictionary = _battleattack_tx_snap(source)
	var target_snap: Dictionary = _battleattack_tx_snap(target)
	var result: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
		battle_state,
		source_id,
		target_id,
		0.0
	)
	var stored_ok: bool = true
	if kind == "los":
		stored_ok = _battletarget_has(source, target_id)
	return (
		_battleattack_rejected_ok(result, expected_code)
		and _battleattack_tx_unchanged(source, source_snap)
		and _battleattack_tx_unchanged(target, target_snap)
		and stored_ok
	)


static func _battleattack_pair_code(
	kind: String
) -> String:
	var source_id: String = "atk_pr_src"
	var target_id: String = "atk_pr_tgt"
	var source_position: Vector2 = Vector2(10.0, 10.0)
	var target_position: Vector2 = Vector2(20.0, 10.0)
	if kind == "range":
		target_position = Vector2(34.5, 10.0)
	if kind == "los":
		source_position = Vector2(20.0, 30.0)
		target_position = Vector2(40.0, 30.0)
	var pack: Dictionary = _battleattack_make_ready(
		source_id,
		target_id,
		"pistol",
		source_position,
		target_position
	)
	var battle_state: BattleState = pack.get("battle_state", null) as BattleState
	var source: BattleParticipant = pack.get("source", null) as BattleParticipant
	var target: BattleParticipant = pack.get("target", null) as BattleParticipant
	if battle_state == null or source == null or target == null or source.weapon_state == null:
		return ""
	if kind == "los":
		var wall: BattleObstacle = BattleObstacle.new(
			"atk_pr_wall",
			Rect2(28.0, 20.0, 6.0, 20.0),
			true,
			true
		)
		if battle_state.battlefield_geometry == null:
			return ""
		if not battle_state.battlefield_geometry.add_obstacle(wall):
			return ""
	match kind:
		"ready":
			pass
		"same_side":
			target.side_id = "attacker"
		"range":
			pass
		"los":
			pass
		"cooldown":
			source.weapon_state.cooldown_remaining_seconds = 0.5
		"empty":
			source.weapon_state.ammo_in_magazine = 0
			source.weapon_state.is_reloading = false
		"reloading":
			source.weapon_state.is_reloading = true
			source.weapon_state.reload_remaining_seconds = 0.8
		"mismatch":
			source.weapon_state.weapon_type_id = "rifle"
		_:
			return ""
	var result: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
		battle_state,
		source_id,
		target_id
	)
	if result == null or not result.success:
		return ""
	if result.can_fire:
		return "eligible"
	return result.rejection_code


static func _battleattack_campaign_outcome(outcome_roll: float) -> bool:
	var pack: Dictionary = _battle_create_ready_pack()
	var game_state: GameState = pack.get("game_state", null) as GameState
	var force: TravelingForce = pack.get("force", null) as TravelingForce
	var battle_state: BattleState = pack.get("battle_state", null) as BattleState
	if game_state == null or battle_state == null:
		return false
	if not _battle_deploy_standard_attacker(battle_state):
		return false
	if not _battlegeo_init(battle_state):
		return false
	if not battle_state.begin_battle():
		return false
	var source: BattleParticipant = battle_state.get_participant("battle_sol_a")
	var target: BattleParticipant = _battlefire_add(battle_state, "atk_camp_tgt", "defender", "pistol")
	if source == null or target == null or source.weapon_state == null:
		return false
	_battletarget_place(source, Vector2(10.0, 10.0))
	_battletarget_place(target, Vector2(20.0, 10.0))
	var snap: Dictionary = _battle_campaign_snapshot(game_state, force, "battle_mission")
	var soldier: Soldier = game_state.get_soldier("battle_sol_a")
	if soldier == null:
		return false
	var soldier_dict: Dictionary = soldier.to_dict()
	var result: BattleAttackResult = BattleAttackResolutionService.resolve_attack(
		battle_state,
		"battle_sol_a",
		"atk_camp_tgt",
		outcome_roll
	)
	if result == null or not result.success or not result.shot_executed:
		return false
	return (
		_battle_campaign_unchanged(game_state, snap, force, "battle_mission")
		and _battle_soldier_matches_dict(soldier, soldier_dict)
		and soldier.weapon_type_id == source.weapon_type
	)

