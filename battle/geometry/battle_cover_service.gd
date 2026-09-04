class_name BattleCoverService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverResult := preload("res://battle/geometry/battle_cover_result.gd")
const BattleCoverQueryResult := preload("res://battle/geometry/battle_cover_query_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleCoverPostureService := preload("res://battle/combat/battle_cover_posture_service.gd")

# Participant must be this close to a slot to occupy it. Reservation has no range.
const COVER_OCCUPANCY_EPSILON := 0.5


static func reserve_slot(
	battle_state: BattleState,
	participant_id: String,
	cover_slot_id: String
) -> BattleCoverResult:
	var prepared: Dictionary = _prepare_command(battle_state, participant_id, cover_slot_id)
	if prepared.has("failure"):
		return prepared["failure"] as BattleCoverResult
	var participant: BattleParticipant = prepared["participant"] as BattleParticipant
	var slot: BattleCoverSlot = prepared["slot"] as BattleCoverSlot
	if slot.is_occupied():
		return BattleCoverResult.failed(
			"cover_slot_occupied",
			"Battle cover failed: cover slot '%s' is occupied." % cover_slot_id,
			cover_slot_id,
			participant_id
		)
	if slot.reserved_by_participant_id == participant_id:
		return BattleCoverResult.succeeded(cover_slot_id, participant_id)
	if slot.is_reserved():
		return BattleCoverResult.failed(
			"cover_slot_reserved",
			"Battle cover failed: cover slot '%s' is reserved." % cover_slot_id,
			cover_slot_id,
			participant_id
		)
	_clear_reservation(battle_state, participant)
	slot.reserved_by_participant_id = participant_id
	participant.reserved_cover_slot_id = cover_slot_id
	return BattleCoverResult.succeeded(cover_slot_id, participant_id)


static func release_reservation(
	battle_state: BattleState,
	participant_id: String
) -> BattleCoverResult:
	var prepared: Dictionary = _prepare_participant(battle_state, participant_id)
	if prepared.has("failure"):
		return prepared["failure"] as BattleCoverResult
	var participant: BattleParticipant = prepared["participant"] as BattleParticipant
	var slot_id: String = participant.reserved_cover_slot_id
	if slot_id.is_empty():
		return BattleCoverResult.failed(
			"cover_slot_not_found",
			"Battle cover failed: participant '%s' has no cover reservation." % participant_id,
			"",
			participant_id
		)
	_clear_reservation(battle_state, participant)
	return BattleCoverResult.succeeded(slot_id, participant_id)


static func occupy_slot(
	battle_state: BattleState,
	participant_id: String,
	cover_slot_id: String
) -> BattleCoverResult:
	var prepared: Dictionary = _prepare_command(battle_state, participant_id, cover_slot_id)
	if prepared.has("failure"):
		return prepared["failure"] as BattleCoverResult
	var participant: BattleParticipant = prepared["participant"] as BattleParticipant
	var slot: BattleCoverSlot = prepared["slot"] as BattleCoverSlot
	if slot.occupied_by_participant_id == participant_id:
		if slot.reserved_by_participant_id == participant_id:
			slot.reserved_by_participant_id = ""
			if participant.reserved_cover_slot_id == cover_slot_id:
				participant.reserved_cover_slot_id = ""
		participant.occupied_cover_slot_id = cover_slot_id
		BattleCoverPostureService.ensure_occupied_posture(participant)
		return BattleCoverResult.succeeded(cover_slot_id, participant_id)
	if slot.is_occupied():
		return BattleCoverResult.failed(
			"cover_slot_occupied",
			"Battle cover failed: cover slot '%s' is occupied." % cover_slot_id,
			cover_slot_id,
			participant_id
		)
	if slot.is_reserved() and slot.reserved_by_participant_id != participant_id:
		return BattleCoverResult.failed(
			"cover_slot_reserved",
			"Battle cover failed: cover slot '%s' is reserved." % cover_slot_id,
			cover_slot_id,
			participant_id
		)
	if participant.battle_position.distance_to(slot.position) > COVER_OCCUPANCY_EPSILON:
		return BattleCoverResult.failed(
			"participant_not_at_slot",
			"Battle cover failed: participant '%s' is not at cover slot '%s'." % [participant_id, cover_slot_id],
			cover_slot_id,
			participant_id
		)
	_clear_occupancy(battle_state, participant)
	if slot.reserved_by_participant_id == participant_id:
		slot.reserved_by_participant_id = ""
		if participant.reserved_cover_slot_id == cover_slot_id:
			participant.reserved_cover_slot_id = ""
	slot.occupied_by_participant_id = participant_id
	participant.occupied_cover_slot_id = cover_slot_id
	BattleCoverPostureService.enter_tucked(participant)
	return BattleCoverResult.succeeded(cover_slot_id, participant_id)


static func vacate_slot(
	battle_state: BattleState,
	participant_id: String
) -> BattleCoverResult:
	var prepared: Dictionary = _prepare_participant(battle_state, participant_id)
	if prepared.has("failure"):
		return prepared["failure"] as BattleCoverResult
	var participant: BattleParticipant = prepared["participant"] as BattleParticipant
	var slot_id: String = participant.occupied_cover_slot_id
	if slot_id.is_empty():
		return BattleCoverResult.failed(
			"cover_slot_not_found",
			"Battle cover failed: participant '%s' has no cover occupancy." % participant_id,
			"",
			participant_id
		)
	_clear_occupancy(battle_state, participant)
	return BattleCoverResult.succeeded(slot_id, participant_id)


static func release_all_for_participant(
	battle_state: BattleState,
	participant_id: String
) -> BattleCoverResult:
	var prepared: Dictionary = _prepare_participant(battle_state, participant_id, false)
	if prepared.has("failure"):
		return prepared["failure"] as BattleCoverResult
	var participant: BattleParticipant = prepared["participant"] as BattleParticipant
	var occupied_id: String = participant.occupied_cover_slot_id
	var reserved_id: String = participant.reserved_cover_slot_id
	_clear_occupancy(battle_state, participant)
	_clear_reservation(battle_state, participant)
	var reported_id: String = occupied_id
	if reported_id.is_empty():
		reported_id = reserved_id
	return BattleCoverResult.succeeded(reported_id, participant_id)


static func get_available_slots(battle_state: BattleState) -> BattleCoverQueryResult:
	var geometry_result: Dictionary = _require_geometry(battle_state)
	if geometry_result.has("failure"):
		return geometry_result["failure"] as BattleCoverQueryResult
	var geometry: BattlefieldGeometry = geometry_result["geometry"] as BattlefieldGeometry
	var available: Array[String] = []
	for slot_id: String in geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = geometry.get_cover_slot(slot_id)
		if slot != null and slot.is_available():
			available.append(slot_id)
	return BattleCoverQueryResult.succeeded(available)


static func find_nearest_available_slot(
	battle_state: BattleState,
	participant_id: String,
	require_reachable: bool = false
) -> BattleCoverQueryResult:
	var prepared: Dictionary = _prepare_participant(battle_state, participant_id)
	if prepared.has("failure"):
		var command_failure: BattleCoverResult = prepared["failure"] as BattleCoverResult
		return BattleCoverQueryResult.failed(command_failure.error_code, command_failure.error_message)
	var participant: BattleParticipant = prepared["participant"] as BattleParticipant
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	var best_id: String = ""
	var best_distance: float = INF
	for slot_id: String in geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = geometry.get_cover_slot(slot_id)
		if slot == null or not slot.is_available():
			continue
		if require_reachable and not _slot_is_reachable(battle_state, participant, slot):
			continue
		var distance: float = participant.battle_position.distance_squared_to(slot.position)
		if not is_finite(distance):
			continue
		if best_id.is_empty() or distance < best_distance:
			best_id = slot_id
			best_distance = distance
	if best_id.is_empty():
		return BattleCoverQueryResult.succeeded()
	var ids: Array[String] = [best_id]
	return BattleCoverQueryResult.succeeded(ids, best_id)


static func _slot_is_reachable(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot
) -> bool:
	if participant == null or slot == null:
		return false
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		slot.position
	)
	return navigation != null and navigation.success


static func _prepare_command(
	battle_state: BattleState,
	participant_id: String,
	cover_slot_id: String
) -> Dictionary:
	var prepared: Dictionary = _prepare_participant(battle_state, participant_id)
	if prepared.has("failure"):
		return prepared
	if cover_slot_id.is_empty():
		prepared["failure"] = BattleCoverResult.failed(
			"cover_slot_not_found",
			"Battle cover failed: cover slot id is empty.",
			"",
			participant_id
		)
		return prepared
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	var slot: BattleCoverSlot = geometry.get_cover_slot(cover_slot_id)
	if slot == null or not slot.is_valid():
		prepared["failure"] = BattleCoverResult.failed(
			"cover_slot_not_found" if slot == null else "invalid_cover_slot",
			"Battle cover failed: cover slot '%s' is %s." % [
				cover_slot_id,
				"missing" if slot == null else "invalid"
			],
			cover_slot_id,
			participant_id
		)
		return prepared
	prepared["slot"] = slot
	return prepared


static func _prepare_participant(
	battle_state: BattleState,
	participant_id: String,
	require_eligible: bool = true
) -> Dictionary:
	var prepared: Dictionary = {}
	var geometry_result: Dictionary = _require_geometry(battle_state)
	if geometry_result.has("failure"):
		var query_failure: BattleCoverQueryResult = geometry_result["failure"] as BattleCoverQueryResult
		prepared["failure"] = BattleCoverResult.failed(
			query_failure.error_code,
			query_failure.error_message,
			"",
			participant_id
		)
		return prepared
	if participant_id.is_empty() or battle_state.get_participant(participant_id) == null:
		prepared["failure"] = BattleCoverResult.failed(
			"participant_not_found",
			"Battle cover failed: participant '%s' was not found." % participant_id,
			"",
			participant_id
		)
		return prepared
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if require_eligible and not _participant_is_eligible(participant):
		prepared["failure"] = BattleCoverResult.failed(
			"participant_not_eligible",
			"Battle cover failed: participant '%s' is not eligible to use cover." % participant_id,
			"",
			participant_id
		)
		return prepared
	prepared["participant"] = participant
	return prepared


static func _require_geometry(battle_state: BattleState) -> Dictionary:
	var prepared: Dictionary = {}
	if battle_state == null:
		prepared["failure"] = BattleCoverQueryResult.failed(
			"null_battle_state",
			"Battle cover failed: battle_state is null."
		)
		return prepared
	if battle_state.battlefield_geometry == null:
		prepared["failure"] = BattleCoverQueryResult.failed(
			"missing_battlefield_geometry",
			"Battle cover failed: battlefield geometry is missing."
		)
		return prepared
	if not battle_state.battlefield_geometry.is_valid():
		prepared["failure"] = BattleCoverQueryResult.failed(
			"invalid_battlefield_geometry",
			"Battle cover failed: battlefield geometry is invalid."
		)
		return prepared
	prepared["geometry"] = battle_state.battlefield_geometry
	return prepared


static func _participant_is_eligible(participant: BattleParticipant) -> bool:
	if participant == null or not participant.is_alive:
		return false
	if not participant.has_battle_position:
		return false
	return is_finite(participant.battle_position.x) and is_finite(participant.battle_position.y)


static func _clear_reservation(battle_state: BattleState, participant: BattleParticipant) -> void:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return
	var slot_id: String = participant.reserved_cover_slot_id
	var freed: bool = false
	if not slot_id.is_empty():
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot != null and slot.reserved_by_participant_id == participant.participant_id:
			slot.reserved_by_participant_id = ""
			freed = true
	participant.reserved_cover_slot_id = ""
	if freed:
		_bump_cover_occupancy_revision(battle_state)


static func _clear_occupancy(battle_state: BattleState, participant: BattleParticipant) -> void:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return
	var slot_id: String = participant.occupied_cover_slot_id
	var freed: bool = false
	if not slot_id.is_empty():
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot != null and slot.occupied_by_participant_id == participant.participant_id:
			slot.occupied_by_participant_id = ""
			freed = true
	participant.occupied_cover_slot_id = ""
	BattleCoverPostureService.clear(participant)
	if freed:
		_bump_cover_occupancy_revision(battle_state)


static func _bump_cover_occupancy_revision(battle_state: BattleState) -> void:
	if battle_state == null:
		return
	battle_state.cover_occupancy_revision += 1
