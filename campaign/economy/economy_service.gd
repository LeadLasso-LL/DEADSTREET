class_name EconomyService
extends RefCounted

const BusinessEconomyCatalog := preload("res://campaign/economy/business_economy_catalog.gd")
const BusinessEconomyDefinition := preload("res://campaign/economy/business_economy_definition.gd")
const BusinessLevelOutput := preload("res://campaign/economy/business_level_output.gd")
const BusinessProductionResult := preload("res://campaign/economy/business_production_result.gd")
const FactionEconomyResult := preload("res://campaign/economy/faction_economy_result.gd")
const EconomyTurnResult := preload("res://campaign/economy/economy_turn_result.gd")


static func process_turn_start(game_state: GameState, catalog: BusinessEconomyCatalog) -> EconomyTurnResult:
	if game_state == null:
		return EconomyTurnResult.failed("null_game_state", "Economy processing failed: game_state is null.")
	if catalog == null:
		return EconomyTurnResult.failed(
			"null_business_catalog",
			"Economy processing failed: business catalog is null."
		)

	var cash_before_by_faction: Dictionary[String, float] = {}
	_snapshot_major_gang_cash(game_state, cash_before_by_faction)
	var income_by_faction: Dictionary[String, float] = {}
	var business_results: Array[BusinessProductionResult] = _process_business_production(
		game_state,
		catalog,
		income_by_faction
	)
	var faction_results: Array[FactionEconomyResult] = _process_faction_upkeep(
		game_state,
		cash_before_by_faction,
		income_by_faction
	)
	return EconomyTurnResult.succeeded(business_results, faction_results)


static func _process_business_production(
	game_state: GameState,
	catalog: BusinessEconomyCatalog,
	income_by_faction: Dictionary[String, float]
) -> Array[BusinessProductionResult]:
	var results: Array[BusinessProductionResult] = []
	var location_ids: Array[String] = _sorted_ids(game_state.map_locations)
	for location_id: String in location_ids:
		var location: MapLocation = game_state.get_map_location(location_id)
		if location == null or not (location is Business):
			continue
		var business: Business = location as Business
		results.append(_process_one_business(game_state, catalog, business, income_by_faction))
	return results


static func _process_one_business(
	game_state: GameState,
	catalog: BusinessEconomyCatalog,
	business: Business,
	income_by_faction: Dictionary[String, float]
) -> BusinessProductionResult:
	if not business.is_open:
		return BusinessProductionResult.skipped(business.id, business.owner_faction_id)
	if business.owner_faction_id.is_empty():
		return BusinessProductionResult.skipped(business.id, "")
	if not game_state.has_faction(business.owner_faction_id):
		return BusinessProductionResult.failed(
			"invalid_owner_faction",
			"Business production failed: owner faction '%s' does not exist (business='%s')."
			% [business.owner_faction_id, business.id],
			business.id,
			business.owner_faction_id
		)
	var owner: Faction = game_state.get_faction(business.owner_faction_id)
	if not (owner is MajorGang):
		return BusinessProductionResult.failed(
			"owner_not_major_gang",
			"Business production failed: owner '%s' is not a MajorGang (business='%s')."
			% [business.owner_faction_id, business.id],
			business.id,
			business.owner_faction_id
		)
	if business.business_type_id.is_empty():
		return BusinessProductionResult.failed(
			"empty_business_type",
			"Business production failed: business_type_id is empty (business='%s')." % business.id,
			business.id,
			business.owner_faction_id
		)
	if not catalog.has_definition(business.business_type_id):
		return BusinessProductionResult.failed(
			"missing_business_definition",
			"Business production failed: no economy definition for type '%s' (business='%s')."
			% [business.business_type_id, business.id],
			business.id,
			business.owner_faction_id
		)
	var definition: BusinessEconomyDefinition = catalog.get_definition(business.business_type_id)
	if definition == null or not definition.has_level_output(business.level):
		return BusinessProductionResult.failed(
			"missing_level_output",
			"Business production failed: no output for type '%s' level %s (business='%s')."
			% [business.business_type_id, business.level, business.id],
			business.id,
			business.owner_faction_id
		)
	var output: BusinessLevelOutput = definition.get_level_output(business.level)
	if not _is_output_safe(output):
		return BusinessProductionResult.failed(
			"invalid_level_output",
			"Business production failed: malformed level output for type '%s' level %s (business='%s')."
			% [business.business_type_id, business.level, business.id],
			business.id,
			business.owner_faction_id
		)

	var gang: MajorGang = owner as MajorGang
	var cash_produced: float = output.cash_per_turn
	var resources_produced: Dictionary[String, float] = _copy_resources(output.resources_per_turn)
	gang.money = gang.money + cash_produced
	var resource_ids: Array[String] = _sorted_resource_ids(resources_produced)
	for resource_id: String in resource_ids:
		gang.resources.add(resource_id, resources_produced[resource_id])
	if not income_by_faction.has(gang.id):
		income_by_faction[gang.id] = 0.0
	income_by_faction[gang.id] = income_by_faction[gang.id] + cash_produced
	return BusinessProductionResult.succeeded(
		business.id,
		gang.id,
		cash_produced,
		resources_produced
	)


static func _process_faction_upkeep(
	game_state: GameState,
	cash_before_by_faction: Dictionary[String, float],
	income_by_faction: Dictionary[String, float]
) -> Array[FactionEconomyResult]:
	var results: Array[FactionEconomyResult] = []
	var faction_ids: Array[String] = _sorted_ids(game_state.factions)
	for faction_id: String in faction_ids:
		var faction: Faction = game_state.get_faction(faction_id)
		if faction == null or not (faction is MajorGang):
			continue
		var gang: MajorGang = faction as MajorGang
		results.append(_process_one_gang_upkeep(game_state, gang, cash_before_by_faction, income_by_faction))
	return results


static func _process_one_gang_upkeep(
	game_state: GameState,
	gang: MajorGang,
	cash_before_by_faction: Dictionary[String, float],
	income_by_faction: Dictionary[String, float]
) -> FactionEconomyResult:
	gang.upkeep_shortfall = 0.0
	var soldier_upkeep_due: float = _sum_soldier_upkeep(game_state, gang.id)
	var vehicle_upkeep_due: float = _sum_vehicle_upkeep(game_state, gang.id)
	var stronghold_upkeep_due: float = _sum_stronghold_upkeep(game_state, gang.id)
	var total_upkeep_due: float = soldier_upkeep_due + vehicle_upkeep_due + stronghold_upkeep_due
	if total_upkeep_due < 0.0:
		total_upkeep_due = 0.0
	var available_cash: float = gang.money
	if available_cash < 0.0:
		available_cash = 0.0
		gang.money = 0.0
	var upkeep_paid: float = minf(available_cash, total_upkeep_due)
	if upkeep_paid < 0.0:
		upkeep_paid = 0.0
	gang.money = gang.money - upkeep_paid
	if gang.money < 0.0 or is_equal_approx(gang.money, 0.0):
		gang.money = 0.0
	var shortfall: float = total_upkeep_due - upkeep_paid
	if shortfall < 0.0 or is_equal_approx(shortfall, 0.0):
		shortfall = 0.0
	gang.upkeep_shortfall = shortfall
	var result: FactionEconomyResult = FactionEconomyResult.new()
	result.faction_id = gang.id
	result.cash_before = float(cash_before_by_faction.get(gang.id, 0.0))
	result.business_cash_income = float(income_by_faction.get(gang.id, 0.0))
	result.soldier_upkeep_due = soldier_upkeep_due
	result.vehicle_upkeep_due = vehicle_upkeep_due
	result.stronghold_upkeep_due = stronghold_upkeep_due
	result.total_upkeep_due = total_upkeep_due
	result.upkeep_paid = upkeep_paid
	result.upkeep_shortfall = gang.upkeep_shortfall
	result.cash_after = gang.money
	return result


static func _sum_soldier_upkeep(game_state: GameState, faction_id: String) -> float:
	var total: float = 0.0
	var soldier_ids: Array[String] = _sorted_ids(game_state.soldiers)
	for soldier_id: String in soldier_ids:
		var soldier: Soldier = game_state.get_soldier(soldier_id)
		if soldier == null or soldier.faction_id != faction_id:
			continue
		total += soldier.upkeep_per_turn
	return total


static func _sum_vehicle_upkeep(game_state: GameState, faction_id: String) -> float:
	var total: float = 0.0
	var vehicle_ids: Array[String] = _sorted_ids(game_state.vehicles)
	for vehicle_id: String in vehicle_ids:
		var vehicle: Vehicle = game_state.get_vehicle(vehicle_id)
		if vehicle == null or vehicle.faction_id != faction_id:
			continue
		total += vehicle.upkeep_per_turn
	return total


static func _sum_stronghold_upkeep(game_state: GameState, faction_id: String) -> float:
	var total: float = 0.0
	var location_ids: Array[String] = _sorted_ids(game_state.map_locations)
	for location_id: String in location_ids:
		var location: MapLocation = game_state.get_map_location(location_id)
		if location == null or not (location is Stronghold):
			continue
		var stronghold: Stronghold = location as Stronghold
		if stronghold.owner_faction_id != faction_id:
			continue
		total += stronghold.upkeep_per_turn
	return total


static func _snapshot_major_gang_cash(game_state: GameState, cash_before_by_faction: Dictionary[String, float]) -> void:
	var faction_ids: Array[String] = _sorted_ids(game_state.factions)
	for faction_id: String in faction_ids:
		var faction: Faction = game_state.get_faction(faction_id)
		if faction == null or not (faction is MajorGang):
			continue
		var gang: MajorGang = faction as MajorGang
		cash_before_by_faction[gang.id] = gang.money


static func _is_output_safe(output: BusinessLevelOutput) -> bool:
	if output == null:
		return false
	if output.cash_per_turn < 0.0:
		return false
	for resource_id: Variant in output.resources_per_turn:
		var key: String = str(resource_id)
		if key.is_empty():
			return false
		if float(output.resources_per_turn[resource_id]) < 0.0:
			return false
	return true


static func _copy_resources(source: Dictionary) -> Dictionary[String, float]:
	var copied: Dictionary[String, float] = {}
	for resource_id: Variant in source:
		copied[str(resource_id)] = float(source[resource_id])
	return copied


static func _sorted_resource_ids(resources: Dictionary[String, float]) -> Array[String]:
	var resource_ids: Array[String] = []
	for resource_id: String in resources:
		resource_ids.append(resource_id)
	resource_ids.sort()
	return resource_ids


static func _sorted_ids(source: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for item_id: Variant in source:
		ids.append(str(item_id))
	ids.sort()
	return ids
