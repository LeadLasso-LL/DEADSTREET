class_name DiplomacyService
extends RefCounted

const FactionRelationship := preload("res://campaign/diplomacy/faction_relationship.gd")
const DiplomacyResult := preload("res://campaign/diplomacy/diplomacy_result.gd")


static func are_at_war(
	game_state: GameState,
	faction_one_id: String,
	faction_two_id: String
) -> bool:
	if game_state == null:
		return false
	if faction_one_id.is_empty() or faction_two_id.is_empty():
		return false
	if faction_one_id == faction_two_id:
		return false
	var relationship: FactionRelationship = game_state.get_relationship_between(
		faction_one_id,
		faction_two_id
	)
	if relationship == null:
		return false
	return relationship.is_at_war


static func declare_war(
	game_state: GameState,
	faction_one_id: String,
	faction_two_id: String
) -> DiplomacyResult:
	if game_state == null:
		return DiplomacyResult.failed(
			"null_game_state",
			"Declare war failed: game_state is null."
		)
	if faction_one_id.is_empty():
		return DiplomacyResult.failed(
			"empty_faction_a",
			"Declare war failed: first faction id is empty.",
			faction_one_id,
			faction_two_id
		)
	if faction_two_id.is_empty():
		return DiplomacyResult.failed(
			"empty_faction_b",
			"Declare war failed: second faction id is empty.",
			faction_one_id,
			faction_two_id
		)
	if faction_one_id == faction_two_id:
		return DiplomacyResult.failed(
			"same_faction",
			"Declare war failed: a faction cannot declare war on itself.",
			faction_one_id,
			faction_two_id
		)
	if not game_state.has_faction(faction_one_id):
		return DiplomacyResult.failed(
			"invalid_faction_a",
			"Declare war failed: faction '%s' does not exist." % faction_one_id,
			faction_one_id,
			faction_two_id
		)
	if not game_state.has_faction(faction_two_id):
		return DiplomacyResult.failed(
			"invalid_faction_b",
			"Declare war failed: faction '%s' does not exist." % faction_two_id,
			faction_one_id,
			faction_two_id
		)
	var faction_a: Faction = game_state.get_faction(faction_one_id)
	var faction_b: Faction = game_state.get_faction(faction_two_id)
	if not (faction_a is MajorGang):
		return DiplomacyResult.failed(
			"faction_a_not_major_gang",
			"Declare war failed: faction '%s' is not a MajorGang." % faction_one_id,
			faction_one_id,
			faction_two_id
		)
	if not (faction_b is MajorGang):
		return DiplomacyResult.failed(
			"faction_b_not_major_gang",
			"Declare war failed: faction '%s' is not a MajorGang." % faction_two_id,
			faction_one_id,
			faction_two_id
		)

	var relationship: FactionRelationship = game_state.get_relationship_between(
		faction_one_id,
		faction_two_id
	)
	if relationship == null:
		relationship = FactionRelationship.new(faction_one_id, faction_two_id, true)
		if not game_state.add_relationship(relationship):
			push_error(
				"DiplomacyService.declare_war: failed to add relationship between '%s' and '%s'."
				% [faction_one_id, faction_two_id]
			)
			return DiplomacyResult.failed(
				"relationship_insert_failed",
				"Declare war failed: could not add relationship between '%s' and '%s'."
				% [faction_one_id, faction_two_id],
				faction_one_id,
				faction_two_id
			)
	else:
		relationship.is_at_war = true

	return DiplomacyResult.succeeded(
		relationship.faction_a_id,
		relationship.faction_b_id,
		true
	)
