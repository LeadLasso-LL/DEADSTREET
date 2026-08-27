class_name CoreValidation
extends RefCounted


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
