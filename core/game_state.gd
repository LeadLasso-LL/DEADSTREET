class_name GameState
extends RefCounted

const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const FactionRelationship := preload("res://campaign/diplomacy/faction_relationship.gd")

var current_turn: int = 1
var current_year: int = 2034
var current_month: int = 7
var factions: Dictionary[String, Faction] = {}
var stronghold_regions: Dictionary[String, StrongholdRegion] = {}
var police_regions: Dictionary[String, PoliceRegion] = {}
var neighborhoods: Dictionary[String, Neighborhood] = {}
var road_graph: RoadGraph = RoadGraph.new()
var map_locations: Dictionary[String, MapLocation] = {}
var vehicles: Dictionary[String, Vehicle] = {}
var soldiers: Dictionary[String, Soldier] = {}
var traveling_forces: Dictionary[String, TravelingForce] = {}
var missions: Dictionary[String, CampaignMission] = {}
var relationships: Dictionary[String, FactionRelationship] = {}


func add_faction(faction: Faction) -> void:
	if faction == null:
		push_error("GameState.add_faction: faction is null.")
		return
	if faction.id.is_empty():
		push_error("GameState.add_faction: faction id is empty.")
		return
	if factions.has(faction.id):
		push_error("GameState.add_faction: duplicate faction id '%s'." % faction.id)
		return
	factions[faction.id] = faction


func get_faction(faction_id: String) -> Faction:
	if factions.has(faction_id):
		return factions[faction_id]
	return null


func has_faction(faction_id: String) -> bool:
	return factions.has(faction_id)


func add_stronghold_region(region: StrongholdRegion) -> void:
	if region == null:
		push_error("GameState.add_stronghold_region: region is null.")
		return
	if region.id.is_empty():
		push_error("GameState.add_stronghold_region: region id is empty.")
		return
	if stronghold_regions.has(region.id):
		push_error("GameState.add_stronghold_region: duplicate region id '%s'." % region.id)
		return
	stronghold_regions[region.id] = region


func get_stronghold_region(region_id: String) -> StrongholdRegion:
	if stronghold_regions.has(region_id):
		return stronghold_regions[region_id]
	return null


func has_stronghold_region(region_id: String) -> bool:
	return stronghold_regions.has(region_id)


func add_police_region(region: PoliceRegion) -> void:
	if region == null:
		push_error("GameState.add_police_region: region is null.")
		return
	if region.id.is_empty():
		push_error("GameState.add_police_region: region id is empty.")
		return
	if police_regions.has(region.id):
		push_error("GameState.add_police_region: duplicate region id '%s'." % region.id)
		return
	police_regions[region.id] = region


func get_police_region(region_id: String) -> PoliceRegion:
	if police_regions.has(region_id):
		return police_regions[region_id]
	return null


func has_police_region(region_id: String) -> bool:
	return police_regions.has(region_id)


func add_neighborhood(neighborhood: Neighborhood) -> void:
	if neighborhood == null:
		push_error("GameState.add_neighborhood: neighborhood is null.")
		return
	if neighborhood.id.is_empty():
		push_error("GameState.add_neighborhood: neighborhood id is empty.")
		return
	if neighborhoods.has(neighborhood.id):
		push_error("GameState.add_neighborhood: duplicate neighborhood id '%s'." % neighborhood.id)
		return
	neighborhoods[neighborhood.id] = neighborhood


func get_neighborhood(neighborhood_id: String) -> Neighborhood:
	if neighborhoods.has(neighborhood_id):
		return neighborhoods[neighborhood_id]
	return null


func has_neighborhood(neighborhood_id: String) -> bool:
	return neighborhoods.has(neighborhood_id)


func get_neighborhoods_in_stronghold_region(region_id: String) -> Array[Neighborhood]:
	if region_id.is_empty():
		var empty: Array[Neighborhood] = []
		return empty
	var matching_ids: Array[String] = []
	for neighborhood_id: String in neighborhoods:
		if neighborhoods[neighborhood_id].stronghold_region_id == region_id:
			matching_ids.append(neighborhood_id)
	return _neighborhoods_sorted_by_id(matching_ids)


func get_neighborhoods_in_police_region(region_id: String) -> Array[Neighborhood]:
	if region_id.is_empty():
		var empty: Array[Neighborhood] = []
		return empty
	var matching_ids: Array[String] = []
	for neighborhood_id: String in neighborhoods:
		if neighborhoods[neighborhood_id].police_region_id == region_id:
			matching_ids.append(neighborhood_id)
	return _neighborhoods_sorted_by_id(matching_ids)


func add_map_location(location: MapLocation) -> void:
	if location == null:
		push_error("GameState.add_map_location: location is null.")
		return
	if location.id.is_empty():
		push_error("GameState.add_map_location: location id is empty.")
		return
	if map_locations.has(location.id):
		push_error("GameState.add_map_location: duplicate location id '%s'." % location.id)
		return
	map_locations[location.id] = location


func get_map_location(location_id: String) -> MapLocation:
	if map_locations.has(location_id):
		return map_locations[location_id]
	return null


func has_map_location(location_id: String) -> bool:
	return map_locations.has(location_id)


func add_vehicle(vehicle: Vehicle) -> void:
	if vehicle == null:
		push_error("GameState.add_vehicle: vehicle is null.")
		return
	if vehicle.id.is_empty():
		push_error("GameState.add_vehicle: vehicle id is empty.")
		return
	if vehicles.has(vehicle.id):
		push_error("GameState.add_vehicle: duplicate vehicle id '%s'." % vehicle.id)
		return
	vehicles[vehicle.id] = vehicle


func get_vehicle(vehicle_id: String) -> Vehicle:
	if vehicles.has(vehicle_id):
		return vehicles[vehicle_id]
	return null


func has_vehicle(vehicle_id: String) -> bool:
	return vehicles.has(vehicle_id)


func remove_vehicle(vehicle_id: String) -> bool:
	if not vehicles.has(vehicle_id):
		return false
	vehicles.erase(vehicle_id)
	return true


func assign_vehicle_to_stronghold(vehicle_id: String, stronghold_id: String) -> bool:
	if not has_vehicle(vehicle_id):
		push_error("GameState.assign_vehicle_to_stronghold: vehicle '%s' does not exist." % vehicle_id)
		return false
	var vehicle: Vehicle = get_vehicle(vehicle_id)
	var location: MapLocation = get_map_location(stronghold_id)
	if location == null:
		push_error("GameState.assign_vehicle_to_stronghold: location '%s' does not exist." % stronghold_id)
		return false
	if not (location is Stronghold):
		push_error("GameState.assign_vehicle_to_stronghold: location '%s' is not a Stronghold." % stronghold_id)
		return false
	var target: Stronghold = location as Stronghold
	if vehicle.faction_id != target.owner_faction_id:
		push_error("GameState.assign_vehicle_to_stronghold: vehicle '%s' faction does not match Stronghold '%s' owner." % [vehicle_id, stronghold_id])
		return false
	if vehicle.home_stronghold_id == stronghold_id:
		if not target.has_vehicle_id(vehicle_id):
			target.add_vehicle_id(vehicle_id)
		return true
	var old_stronghold: Stronghold = null
	if not vehicle.home_stronghold_id.is_empty():
		var old_location: MapLocation = get_map_location(vehicle.home_stronghold_id)
		if old_location == null:
			push_error("GameState.assign_vehicle_to_stronghold: vehicle '%s' has stale home Stronghold '%s'." % [vehicle_id, vehicle.home_stronghold_id])
			return false
		if not (old_location is Stronghold):
			push_error("GameState.assign_vehicle_to_stronghold: vehicle '%s' home '%s' is not a Stronghold." % [vehicle_id, vehicle.home_stronghold_id])
			return false
		old_stronghold = old_location as Stronghold
	if old_stronghold != null:
		old_stronghold.remove_vehicle_id(vehicle_id)
	vehicle.home_stronghold_id = stronghold_id
	if not target.has_vehicle_id(vehicle_id):
		target.add_vehicle_id(vehicle_id)
	return true


func unassign_vehicle_from_stronghold(vehicle_id: String) -> bool:
	if not has_vehicle(vehicle_id):
		push_error("GameState.unassign_vehicle_from_stronghold: vehicle '%s' does not exist." % vehicle_id)
		return false
	var vehicle: Vehicle = get_vehicle(vehicle_id)
	if vehicle.home_stronghold_id.is_empty():
		return true
	var old_id: String = vehicle.home_stronghold_id
	var old_location: MapLocation = get_map_location(old_id)
	var removed_cleanly := true
	if old_location != null and old_location is Stronghold:
		var old_stronghold: Stronghold = old_location as Stronghold
		old_stronghold.remove_vehicle_id(vehicle_id)
	else:
		push_error("GameState.unassign_vehicle_from_stronghold: vehicle '%s' referenced missing or invalid Stronghold '%s'." % [vehicle_id, old_id])
		removed_cleanly = false
	vehicle.home_stronghold_id = ""
	return removed_cleanly


func add_soldier(soldier: Soldier) -> void:
	if soldier == null:
		push_error("GameState.add_soldier: soldier is null.")
		return
	if soldier.id.is_empty():
		push_error("GameState.add_soldier: soldier id is empty.")
		return
	if soldiers.has(soldier.id):
		push_error("GameState.add_soldier: duplicate soldier id '%s'." % soldier.id)
		return
	soldiers[soldier.id] = soldier


func get_soldier(soldier_id: String) -> Soldier:
	if soldiers.has(soldier_id):
		return soldiers[soldier_id]
	return null


func has_soldier(soldier_id: String) -> bool:
	return soldiers.has(soldier_id)


func remove_soldier(soldier_id: String) -> bool:
	if not soldiers.has(soldier_id):
		return false
	soldiers.erase(soldier_id)
	return true


func assign_soldier_to_stronghold(soldier_id: String, stronghold_id: String) -> bool:
	if not has_soldier(soldier_id):
		push_error("GameState.assign_soldier_to_stronghold: soldier '%s' does not exist." % soldier_id)
		return false
	var soldier: Soldier = get_soldier(soldier_id)
	var location: MapLocation = get_map_location(stronghold_id)
	if location == null:
		push_error("GameState.assign_soldier_to_stronghold: location '%s' does not exist." % stronghold_id)
		return false
	if not (location is Stronghold):
		push_error("GameState.assign_soldier_to_stronghold: location '%s' is not a Stronghold." % stronghold_id)
		return false
	var target: Stronghold = location as Stronghold
	if soldier.faction_id != target.owner_faction_id:
		push_error("GameState.assign_soldier_to_stronghold: soldier '%s' faction does not match Stronghold '%s' owner." % [soldier_id, stronghold_id])
		return false
	if soldier.home_stronghold_id == stronghold_id:
		if not target.has_soldier_id(soldier_id):
			target.add_soldier_id(soldier_id)
		return true
	var old_stronghold: Stronghold = null
	if not soldier.home_stronghold_id.is_empty():
		var old_location: MapLocation = get_map_location(soldier.home_stronghold_id)
		if old_location == null:
			push_error("GameState.assign_soldier_to_stronghold: soldier '%s' has stale home Stronghold '%s'." % [soldier_id, soldier.home_stronghold_id])
			return false
		if not (old_location is Stronghold):
			push_error("GameState.assign_soldier_to_stronghold: soldier '%s' home '%s' is not a Stronghold." % [soldier_id, soldier.home_stronghold_id])
			return false
		old_stronghold = old_location as Stronghold
	if old_stronghold != null:
		old_stronghold.remove_soldier_id(soldier_id)
	soldier.home_stronghold_id = stronghold_id
	if not target.has_soldier_id(soldier_id):
		target.add_soldier_id(soldier_id)
	return true


func unassign_soldier_from_stronghold(soldier_id: String) -> bool:
	if not has_soldier(soldier_id):
		push_error("GameState.unassign_soldier_from_stronghold: soldier '%s' does not exist." % soldier_id)
		return false
	var soldier: Soldier = get_soldier(soldier_id)
	if soldier.home_stronghold_id.is_empty():
		return true
	var old_id: String = soldier.home_stronghold_id
	var old_location: MapLocation = get_map_location(old_id)
	var removed_cleanly := true
	if old_location != null and old_location is Stronghold:
		var old_stronghold: Stronghold = old_location as Stronghold
		old_stronghold.remove_soldier_id(soldier_id)
	else:
		push_error("GameState.unassign_soldier_from_stronghold: soldier '%s' referenced missing or invalid Stronghold '%s'." % [soldier_id, old_id])
		removed_cleanly = false
	soldier.home_stronghold_id = ""
	return removed_cleanly


func is_traveling_force_active(force: TravelingForce) -> bool:
	if force == null:
		return false
	return force.travel_state != "complete"


func is_soldier_in_active_traveling_force(soldier_id: String) -> bool:
	if soldier_id.is_empty():
		return false
	for force_id: String in traveling_forces:
		var force: TravelingForce = get_traveling_force(force_id)
		if not is_traveling_force_active(force):
			continue
		if force.soldier_group != null and force.soldier_group.has_soldier_id(soldier_id):
			return true
	return false


func assign_soldier_to_neighborhood_hq(soldier_id: String, hq_id: String) -> bool:
	if not has_soldier(soldier_id):
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: soldier '%s' does not exist." % soldier_id
		)
		return false
	var soldier: Soldier = get_soldier(soldier_id)
	var location: MapLocation = get_map_location(hq_id)
	if location == null:
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: location '%s' does not exist." % hq_id
		)
		return false
	if not (location is NeighborhoodHQ):
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: location '%s' is not a NeighborhoodHQ."
			% hq_id
		)
		return false
	var hq: NeighborhoodHQ = location as NeighborhoodHQ
	if hq.owner_faction_id.is_empty():
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: NeighborhoodHQ '%s' is unowned." % hq_id
		)
		return false
	if soldier.faction_id != hq.owner_faction_id:
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: soldier '%s' faction does not match NeighborhoodHQ '%s' owner."
			% [soldier_id, hq_id]
		)
		return false
	if is_soldier_in_active_traveling_force(soldier_id):
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: soldier '%s' is deployed in an active traveling force."
			% soldier_id
		)
		return false
	if not soldier.garrison_hq_id.is_empty() and soldier.garrison_hq_id != hq_id:
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: soldier '%s' is already garrisoned at NeighborhoodHQ '%s'."
			% [soldier_id, soldier.garrison_hq_id]
		)
		return false
	if soldier.garrison_hq_id == hq_id:
		if hq.has_garrison_soldier_id(soldier_id):
			return true
		if not hq.has_garrison_capacity():
			push_error(
				"GameState.assign_soldier_to_neighborhood_hq: garrison is full (%s/%s) (hq='%s')."
				% [hq.get_garrison_count(), hq.garrison_capacity, hq_id]
			)
			return false
		return hq.add_garrison_soldier_id(soldier_id)
	if not hq.has_garrison_capacity():
		push_error(
			"GameState.assign_soldier_to_neighborhood_hq: garrison is full (%s/%s) (hq='%s')."
			% [hq.get_garrison_count(), hq.garrison_capacity, hq_id]
		)
		return false
	if not hq.add_garrison_soldier_id(soldier_id):
		return false
	soldier.garrison_hq_id = hq_id
	return true


func unassign_soldier_from_neighborhood_hq(soldier_id: String) -> bool:
	if not has_soldier(soldier_id):
		push_error(
			"GameState.unassign_soldier_from_neighborhood_hq: soldier '%s' does not exist."
			% soldier_id
		)
		return false
	var soldier: Soldier = get_soldier(soldier_id)
	if soldier.garrison_hq_id.is_empty():
		push_error(
			"GameState.unassign_soldier_from_neighborhood_hq: soldier '%s' is not garrisoned at a NeighborhoodHQ."
			% soldier_id
		)
		return false
	var old_id: String = soldier.garrison_hq_id
	var location: MapLocation = get_map_location(old_id)
	var removed_cleanly := true
	if location != null and location is NeighborhoodHQ:
		var hq: NeighborhoodHQ = location as NeighborhoodHQ
		if not hq.remove_garrison_soldier_id(soldier_id):
			push_error(
				"GameState.unassign_soldier_from_neighborhood_hq: soldier '%s' was not on NeighborhoodHQ '%s' garrison list."
				% [soldier_id, old_id]
			)
			removed_cleanly = false
	else:
		push_error(
			"GameState.unassign_soldier_from_neighborhood_hq: soldier '%s' referenced missing or invalid NeighborhoodHQ '%s'."
			% [soldier_id, old_id]
		)
		removed_cleanly = false
	soldier.garrison_hq_id = ""
	return removed_cleanly


func add_traveling_force(force: TravelingForce) -> void:
	if force == null:
		push_error("GameState.add_traveling_force: force is null.")
		return
	if force.id.is_empty():
		push_error("GameState.add_traveling_force: force id is empty.")
		return
	if traveling_forces.has(force.id):
		push_error("GameState.add_traveling_force: duplicate force id '%s'." % force.id)
		return
	traveling_forces[force.id] = force


func get_traveling_force(force_id: String) -> TravelingForce:
	if traveling_forces.has(force_id):
		return traveling_forces[force_id]
	return null


func has_traveling_force(force_id: String) -> bool:
	return traveling_forces.has(force_id)


func remove_traveling_force(force_id: String) -> bool:
	if not traveling_forces.has(force_id):
		return false
	traveling_forces.erase(force_id)
	return true


func add_mission(mission: CampaignMission) -> void:
	if mission == null:
		push_error("GameState.add_mission: mission is null.")
		return
	if mission.id.is_empty():
		push_error("GameState.add_mission: mission id is empty.")
		return
	if missions.has(mission.id):
		push_error("GameState.add_mission: duplicate mission id '%s'." % mission.id)
		return
	missions[mission.id] = mission


func get_mission(mission_id: String) -> CampaignMission:
	if missions.has(mission_id):
		return missions[mission_id]
	return null


func has_mission(mission_id: String) -> bool:
	return missions.has(mission_id)


func remove_mission(mission_id: String) -> bool:
	if not missions.has(mission_id):
		return false
	missions.erase(mission_id)
	return true


func add_relationship(relationship: FactionRelationship) -> bool:
	if relationship == null:
		push_error("GameState.add_relationship: relationship is null.")
		return false
	relationship.canonicalize()
	var key: String = FactionRelationship.make_key(relationship.faction_a_id, relationship.faction_b_id)
	if key.is_empty():
		push_error("GameState.add_relationship: faction pair is empty or the same faction.")
		return false
	if not has_faction(relationship.faction_a_id):
		push_error(
			"GameState.add_relationship: faction '%s' does not exist."
			% relationship.faction_a_id
		)
		return false
	if not has_faction(relationship.faction_b_id):
		push_error(
			"GameState.add_relationship: faction '%s' does not exist."
			% relationship.faction_b_id
		)
		return false
	if relationships.has(key):
		push_error("GameState.add_relationship: duplicate relationship '%s'." % key)
		return false
	relationships[key] = relationship
	return true


func has_relationship_between(faction_one_id: String, faction_two_id: String) -> bool:
	var key: String = FactionRelationship.make_key(faction_one_id, faction_two_id)
	if key.is_empty():
		return false
	return relationships.has(key)


func get_relationship_between(faction_one_id: String, faction_two_id: String) -> FactionRelationship:
	var key: String = FactionRelationship.make_key(faction_one_id, faction_two_id)
	if key.is_empty():
		return null
	if relationships.has(key):
		return relationships[key]
	return null


func remove_relationship_between(faction_one_id: String, faction_two_id: String) -> bool:
	var key: String = FactionRelationship.make_key(faction_one_id, faction_two_id)
	if key.is_empty():
		return false
	if not relationships.has(key):
		return false
	relationships.erase(key)
	return true


func to_dict() -> Dictionary:
	var faction_data := {}
	for faction_id: String in factions:
		faction_data[faction_id] = factions[faction_id].to_dict()
	var neighborhood_data := {}
	for neighborhood_id: String in neighborhoods:
		neighborhood_data[neighborhood_id] = neighborhoods[neighborhood_id].to_dict()
	var stronghold_region_data := {}
	for region_id: String in stronghold_regions:
		stronghold_region_data[region_id] = stronghold_regions[region_id].to_dict()
	var police_region_data := {}
	for region_id: String in police_regions:
		police_region_data[region_id] = police_regions[region_id].to_dict()
	var location_data := {}
	for location_id: String in map_locations:
		location_data[location_id] = map_locations[location_id].to_dict()
	var vehicle_data := {}
	for vehicle_id: String in vehicles:
		vehicle_data[vehicle_id] = vehicles[vehicle_id].to_dict()
	var soldier_data := {}
	for soldier_id: String in soldiers:
		soldier_data[soldier_id] = soldiers[soldier_id].to_dict()
	var traveling_force_data := {}
	for force_id: String in traveling_forces:
		traveling_force_data[force_id] = traveling_forces[force_id].to_dict()
	var mission_data := {}
	for mission_id: String in missions:
		mission_data[mission_id] = missions[mission_id].to_dict()
	var relationship_data := {}
	var relationship_keys: Array[String] = []
	for relationship_key: String in relationships:
		relationship_keys.append(relationship_key)
	relationship_keys.sort()
	for relationship_key: String in relationship_keys:
		relationship_data[relationship_key] = relationships[relationship_key].to_dict()
	return {
		"current_turn": current_turn,
		"current_year": current_year,
		"current_month": current_month,
		"factions": faction_data,
		"relationships": relationship_data,
		"neighborhoods": neighborhood_data,
		"stronghold_regions": stronghold_region_data,
		"police_regions": police_region_data,
		"road_graph": road_graph.to_dict(),
		"map_locations": location_data,
		"vehicles": vehicle_data,
		"soldiers": soldier_data,
		"traveling_forces": traveling_force_data,
		"missions": mission_data,
	}


func from_dict(data: Dictionary) -> void:
	current_turn = int(data.get("current_turn", 1))
	current_year = int(data.get("current_year", 2034))
	current_month = int(data.get("current_month", 7))
	factions.clear()
	var faction_data: Variant = data.get("factions", {})
	if faction_data is Dictionary:
		for faction_id: Variant in faction_data:
			var record: Variant = faction_data[faction_id]
			if not (record is Dictionary):
				continue
			var faction := _create_faction_from_dict(record)
			if faction == null:
				continue
			if faction.id.is_empty():
				faction.id = str(faction_id)
			add_faction(faction)
	_restore_relationships(data.get("relationships", {}))
	_restore_stronghold_regions(data.get("stronghold_regions", {}))
	_restore_police_regions(data.get("police_regions", {}))
	_restore_neighborhoods(data.get("neighborhoods", {}))
	road_graph = RoadGraph.new()
	var graph_data: Variant = data.get("road_graph", {})
	if graph_data is Dictionary:
		road_graph.from_dict(graph_data)
	map_locations.clear()
	var location_data: Variant = data.get("map_locations", {})
	if location_data is Dictionary:
		for location_id: Variant in location_data:
			var record: Variant = location_data[location_id]
			if not (record is Dictionary):
				push_error("GameState.from_dict: map location record '%s' is not a Dictionary; skipping." % str(location_id))
				continue
			var location := _create_map_location_from_dict(record)
			if location == null:
				continue
			if location.id.is_empty():
				location.id = str(location_id)
			add_map_location(location)
	elif data.has("map_locations"):
		push_error("GameState.from_dict: map_locations is not a Dictionary; skipping map location restore.")
	_restore_vehicles(data.get("vehicles", {}))
	_restore_soldiers(data.get("soldiers", {}))
	_restore_traveling_forces(data.get("traveling_forces", {}))
	_restore_missions(data.get("missions", {}))


func _create_faction_from_dict(data: Dictionary) -> Faction:
	var type_id := str(data.get("faction_type", ""))
	var faction: Faction
	match type_id:
		"major_gang":
			faction = MajorGang.new()
		_:
			push_error("GameState: unrecognized faction_type '%s' (id='%s'); skipping faction record." % [type_id, str(data.get("id", ""))])
			return null
	faction.from_dict(data)
	return faction


func _create_map_location_from_dict(data: Dictionary) -> MapLocation:
	var type_id := str(data.get("location_type", ""))
	var location: MapLocation
	match type_id:
		"business":
			location = Business.new()
		"stronghold":
			location = Stronghold.new()
		"neighborhood_hq":
			location = NeighborhoodHQ.new()
		_:
			push_error("GameState: unrecognized location_type '%s' (id='%s'); skipping map location record." % [type_id, str(data.get("id", ""))])
			return null
	location.from_dict(data)
	return location


func _restore_stronghold_regions(region_data: Variant) -> void:
	stronghold_regions.clear()
	if not (region_data is Dictionary):
		return
	for region_id: Variant in region_data:
		var record: Variant = region_data[region_id]
		if not (record is Dictionary):
			continue
		var region := StrongholdRegion.new()
		region.from_dict(record)
		if region.id.is_empty():
			region.id = str(region_id)
		add_stronghold_region(region)


func _restore_police_regions(region_data: Variant) -> void:
	police_regions.clear()
	if not (region_data is Dictionary):
		return
	for region_id: Variant in region_data:
		var record: Variant = region_data[region_id]
		if not (record is Dictionary):
			continue
		var region := PoliceRegion.new()
		region.from_dict(record)
		if region.id.is_empty():
			region.id = str(region_id)
		add_police_region(region)


func _restore_neighborhoods(neighborhood_data: Variant) -> void:
	neighborhoods.clear()
	if not (neighborhood_data is Dictionary):
		return
	for neighborhood_id: Variant in neighborhood_data:
		var record: Variant = neighborhood_data[neighborhood_id]
		if not (record is Dictionary):
			continue
		var neighborhood := Neighborhood.new()
		neighborhood.from_dict(record)
		if neighborhood.id.is_empty():
			neighborhood.id = str(neighborhood_id)
		add_neighborhood(neighborhood)


func _neighborhoods_sorted_by_id(matching_ids: Array[String]) -> Array[Neighborhood]:
	matching_ids.sort()
	var result: Array[Neighborhood] = []
	for neighborhood_id in matching_ids:
		result.append(neighborhoods[neighborhood_id])
	return result


func _restore_vehicles(vehicle_data: Variant) -> void:
	vehicles.clear()
	if not (vehicle_data is Dictionary):
		push_error("GameState.from_dict: vehicles is not a Dictionary; skipping vehicle restore.")
		return
	for vehicle_id: Variant in vehicle_data:
		var record: Variant = vehicle_data[vehicle_id]
		if not (record is Dictionary):
			push_error("GameState.from_dict: vehicle record '%s' is not a Dictionary; skipping." % str(vehicle_id))
			continue
		var vehicle: Vehicle = Vehicle.new()
		vehicle.from_dict(record)
		if vehicle.id.is_empty():
			vehicle.id = str(vehicle_id)
		if vehicle.id.is_empty():
			push_error("GameState.from_dict: vehicle record is missing an id; skipping.")
			continue
		add_vehicle(vehicle)


func _restore_soldiers(soldier_data: Variant) -> void:
	soldiers.clear()
	if not (soldier_data is Dictionary):
		push_error("GameState.from_dict: soldiers is not a Dictionary; skipping soldier restore.")
		return
	for soldier_id: Variant in soldier_data:
		var record: Variant = soldier_data[soldier_id]
		if not (record is Dictionary):
			push_error("GameState.from_dict: soldier record '%s' is not a Dictionary; skipping." % str(soldier_id))
			continue
		var soldier: Soldier = Soldier.new()
		soldier.from_dict(record)
		if soldier.id.is_empty():
			soldier.id = str(soldier_id)
		if soldier.id.is_empty():
			push_error("GameState.from_dict: soldier record is missing an id; skipping.")
			continue
		add_soldier(soldier)


func _restore_traveling_forces(force_data: Variant) -> void:
	traveling_forces.clear()
	if not (force_data is Dictionary):
		return
	for force_id: Variant in force_data:
		var record: Variant = force_data[force_id]
		if not (record is Dictionary):
			push_error("GameState.from_dict: traveling force record '%s' is not a Dictionary; skipping." % str(force_id))
			continue
		var force := TravelingForce.new()
		force.from_dict(record)
		if force.id.is_empty():
			force.id = str(force_id)
		if force.id.is_empty():
			push_error("GameState.from_dict: traveling force record is missing an id; skipping.")
			continue
		add_traveling_force(force)


func _restore_missions(mission_data: Variant) -> void:
	missions.clear()
	if not (mission_data is Dictionary):
		push_error("GameState.from_dict: missions is not a Dictionary; skipping mission restore.")
		return
	for mission_id: Variant in mission_data:
		var record: Variant = mission_data[mission_id]
		if not (record is Dictionary):
			push_error("GameState.from_dict: mission record '%s' is not a Dictionary; skipping." % str(mission_id))
			continue
		var mission: CampaignMission = CampaignMission.new()
		mission.from_dict(record)
		if mission.id.is_empty():
			mission.id = str(mission_id)
		if mission.id.is_empty():
			push_error("GameState.from_dict: mission record is missing an id; skipping.")
			continue
		add_mission(mission)


func _restore_relationships(relationship_data: Variant) -> void:
	relationships.clear()
	if not (relationship_data is Dictionary):
		return
	var relationship_keys: Array[String] = []
	for relationship_key: Variant in relationship_data:
		relationship_keys.append(str(relationship_key))
	relationship_keys.sort()
	for relationship_key: String in relationship_keys:
		var record: Variant = relationship_data[relationship_key]
		if not (record is Dictionary):
			push_error(
				"GameState.from_dict: relationship record '%s' is not a Dictionary; skipping."
				% relationship_key
			)
			continue
		var relationship: FactionRelationship = FactionRelationship.new()
		relationship.from_dict(record)
		if FactionRelationship.make_key(relationship.faction_a_id, relationship.faction_b_id).is_empty():
			push_error(
				"GameState.from_dict: relationship record '%s' has an invalid faction pair; skipping."
				% relationship_key
			)
			continue
		if not add_relationship(relationship):
			push_error(
				"GameState.from_dict: failed to restore relationship '%s'; skipping."
				% relationship_key
			)
