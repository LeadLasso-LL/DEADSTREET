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
