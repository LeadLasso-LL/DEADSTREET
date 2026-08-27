class_name CoreValidation
extends RefCounted

const Vehicle := preload("res://campaign/vehicles/vehicle.gd")
const VehicleGroup := preload("res://campaign/vehicles/vehicle_group.gd")
const Soldier := preload("res://campaign/units/soldier.gd")
const SoldierGroup := preload("res://campaign/units/soldier_group.gd")
const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")
const DeploymentResult := preload("res://campaign/actions/deployment_result.gd")
const DeploymentService := preload("res://campaign/actions/deployment_service.gd")


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
	var restored_seg_ab: RoadSegment = restored_graph.get_segment("seg_ab")
	var restored_seg_bc: RoadSegment = restored_graph.get_segment("seg_bc")
	var restored_seg_cd: RoadSegment = restored_graph.get_segment("seg_cd")
	var restored_seg_be: RoadSegment = restored_graph.get_segment("seg_be")
	var restored_seg_ed: RoadSegment = restored_graph.get_segment("seg_ed")

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
