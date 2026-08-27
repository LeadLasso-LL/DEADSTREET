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
