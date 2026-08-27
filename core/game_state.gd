class_name GameState
extends RefCounted

var current_turn: int = 1
var current_year: int = 2034
var current_month: int = 7
var factions: Dictionary[String, Faction] = {}
var stronghold_regions: Dictionary[String, StrongholdRegion] = {}
var police_regions: Dictionary[String, PoliceRegion] = {}
var neighborhoods: Dictionary[String, Neighborhood] = {}
var map_locations: Dictionary[String, MapLocation] = {}


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
	return {
		"current_turn": current_turn,
		"current_year": current_year,
		"current_month": current_month,
		"factions": faction_data,
		"neighborhoods": neighborhood_data,
		"stronghold_regions": stronghold_region_data,
		"police_regions": police_region_data,
		"map_locations": location_data,
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
	_restore_stronghold_regions(data.get("stronghold_regions", {}))
	_restore_police_regions(data.get("police_regions", {}))
	_restore_neighborhoods(data.get("neighborhoods", {}))
	map_locations.clear()
	var location_data: Variant = data.get("map_locations", {})
	if not (location_data is Dictionary):
		push_error("GameState.from_dict: map_locations is not a Dictionary; skipping map location restore.")
		return
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
