class_name BusinessRaidResolver
extends RefCounted

const BusinessRaidLoot := preload("res://campaign/missions/resolvers/business_raid_loot.gd")
const BusinessRaidResult := preload("res://campaign/missions/resolvers/business_raid_result.gd")
const CampaignMission := preload("res://campaign/missions/campaign_mission.gd")
const MissionService := preload("res://campaign/missions/mission_service.gd")
const MissionResult := preload("res://campaign/missions/mission_result.gd")


static func resolve_success(game_state: GameState, mission_id: String, loot: BusinessRaidLoot) -> BusinessRaidResult:
	if game_state == null:
		return BusinessRaidResult.failed("null_game_state", "Business raid failed: game_state is null.")
	if mission_id.is_empty():
		return BusinessRaidResult.failed("empty_mission_id", "Business raid failed: mission_id is empty.")
	if not game_state.has_mission(mission_id):
		return BusinessRaidResult.failed("invalid_mission", "Business raid failed: mission '%s' does not exist." % mission_id, mission_id)
	var mission: CampaignMission = game_state.get_mission(mission_id)
	if mission.mission_type_id != "raid_business":
		return BusinessRaidResult.failed(
			"wrong_mission_type",
			"Business raid failed: mission '%s' type is '%s', not raid_business." % [mission.id, mission.mission_type_id],
			mission.id
		)
	if mission.mission_state != "awaiting_resolution":
		return BusinessRaidResult.failed(
			"mission_not_awaiting_resolution",
			"Business raid failed: mission '%s' is '%s', not awaiting_resolution." % [mission.id, mission.mission_state],
			mission.id
		)
	if mission.force_id.is_empty() or not game_state.has_traveling_force(mission.force_id):
		return BusinessRaidResult.failed(
			"invalid_force",
			"Business raid failed: linked force '%s' does not exist." % mission.force_id,
			mission.id
		)
	var force: TravelingForce = game_state.get_traveling_force(mission.force_id)
	if force.travel_state != "at_destination":
		return BusinessRaidResult.failed(
			"force_not_at_destination",
			"Business raid failed: force '%s' is '%s', not at_destination." % [force.id, force.travel_state],
			mission.id
		)
	if mission.target_location_id.is_empty() or not game_state.has_map_location(mission.target_location_id):
		return BusinessRaidResult.failed(
			"invalid_target",
			"Business raid failed: target '%s' does not exist." % mission.target_location_id,
			mission.id
		)
	var target_location: MapLocation = game_state.get_map_location(mission.target_location_id)
	if not (target_location is Business):
		return BusinessRaidResult.failed(
			"target_not_business",
			"Business raid failed: target '%s' is not a Business." % mission.target_location_id,
			mission.id,
			mission.target_location_id
		)
	var business: Business = target_location as Business
	if force.destination_location_id != mission.target_location_id:
		return BusinessRaidResult.failed(
			"force_target_mismatch",
			"Business raid failed: force '%s' destination '%s' does not match mission target '%s'." % [force.id, force.destination_location_id, mission.target_location_id],
			mission.id,
			business.id
		)
	if force.faction_id != mission.faction_id:
		return BusinessRaidResult.failed(
			"force_faction_mismatch",
			"Business raid failed: force '%s' faction '%s' does not match mission faction '%s'." % [force.id, force.faction_id, mission.faction_id],
			mission.id,
			business.id
		)
	if mission.faction_id.is_empty() or not game_state.has_faction(mission.faction_id):
		return BusinessRaidResult.failed(
			"invalid_faction",
			"Business raid failed: faction '%s' does not exist." % mission.faction_id,
			mission.id,
			business.id
		)
	var faction: Faction = game_state.get_faction(mission.faction_id)
	if not (faction is MajorGang):
		return BusinessRaidResult.failed(
			"faction_not_major_gang",
			"Business raid failed: faction '%s' is not a MajorGang." % mission.faction_id,
			mission.id,
			business.id
		)
	var gang: MajorGang = faction as MajorGang
	if loot == null:
		return BusinessRaidResult.failed(
			"null_loot",
			"Business raid failed: loot is null.",
			mission.id,
			business.id
		)
	if loot.cash < 0.0:
		return BusinessRaidResult.failed(
			"invalid_cash_loot",
			"Business raid failed: loot cash is negative.",
			mission.id,
			business.id
		)
	for resource_id: String in loot.resources:
		if resource_id.is_empty():
			return BusinessRaidResult.failed(
				"invalid_resource_id",
				"Business raid failed: loot resource_id is empty.",
				mission.id,
				business.id
			)
		var loot_amount: float = loot.get_resource_amount(resource_id)
		if loot_amount < 0.0:
			return BusinessRaidResult.failed(
				"invalid_resource_amount",
				"Business raid failed: loot amount for '%s' is negative." % resource_id,
				mission.id,
				business.id
			)

	var level_before: int = business.level
	var open_before: bool = business.is_open
	var money_before: float = gang.money
	var resource_balances_before: Dictionary[String, float] = {}
	for resource_id: String in loot.resources:
		resource_balances_before[resource_id] = gang.resources.get_amount(resource_id)

	gang.money = money_before + loot.cash
	for resource_id: String in loot.resources:
		gang.resources.add(resource_id, loot.get_resource_amount(resource_id))
	if business.level > 1:
		business.level = business.level - 1
	business.is_open = false

	var mission_result: MissionResult = MissionService.resolve(game_state, mission_id, true, "business_raided")
	if not mission_result.success:
		gang.money = money_before
		for resource_id: String in resource_balances_before:
			gang.resources.set_amount(resource_id, resource_balances_before[resource_id])
		business.level = level_before
		business.is_open = open_before
		push_error(
			"BusinessRaidResolver.resolve_success: MissionService.resolve failed for mission '%s' after raid mutations; rolled back. error_code='%s' error_message='%s'."
			% [mission_id, mission_result.error_code, mission_result.error_message]
		)
		return BusinessRaidResult.failed(
			"mission_resolution_failed",
			"Business raid failed: mission resolution failed after applying raid effects.",
			mission.id,
			business.id
		)

	return BusinessRaidResult.succeeded(
		mission.id,
		business.id,
		loot.cash,
		loot.resources,
		level_before,
		business.level
	)
