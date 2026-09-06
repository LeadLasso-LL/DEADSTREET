class_name TacticalOrdersController
extends RefCounted

# Canonical live-battle player selection and priority-order issuer.
# Holds selection only. Combat vitality, occupancy, and AI remain authoritative
# on BattleParticipant / BattleState. Does not rank cover from HUD hover.

const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverResult := preload("res://battle/geometry/battle_cover_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const TacticalOrderResult := preload("res://gameplay/tactical_order_result.gd")

const ORDER_MOVE := "move"
const ORDER_TARGET := "target"
const ORDER_COVER := "cover"

var session: CampaignBattleSession = null
var selected_participant_id: String = ""


func bind_session(p_session: CampaignBattleSession) -> void:
	session = p_session
	selected_participant_id = ""
	sync_from_authority()


func sync_from_authority() -> void:
	_clear_completed_player_move()
	_clear_invalid_selection()
	_occupy_arrived_player_cover()


func clear_selection() -> void:
	selected_participant_id = ""


func select_participant(participant_id: String) -> bool:
	sync_from_authority()
	if not can_control_participant(participant_id):
		return false
	selected_participant_id = participant_id
	return true


func can_control_participant(participant_id: String) -> bool:
	var participant: BattleParticipant = _controllable_participant(participant_id)
	return participant != null


func issue_move(destination: Vector2):
	sync_from_authority()
	var participant: BattleParticipant = _controllable_selected()
	if participant == null:
		return TacticalOrderResult.failed(
			"no_selection",
			"Tactical order failed: no healthy living friendly is selected.",
			selected_participant_id,
			ORDER_MOVE
		)
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return TacticalOrderResult.failed(
			"null_battle_state",
			"Tactical order failed: battle_state is null.",
			participant.participant_id,
			ORDER_MOVE
		)
	if not BattlefieldGeometry.is_finite_point(destination):
		return TacticalOrderResult.failed(
			"invalid_destination",
			"Tactical order failed: move destination is invalid.",
			participant.participant_id,
			ORDER_MOVE
		)
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		destination
	)
	if navigation == null or not navigation.success:
		var error_code: String = "path_failed"
		var error_message: String = "Tactical order failed: no path to move destination."
		if navigation != null:
			if not navigation.error_code.is_empty():
				error_code = navigation.error_code
			if not navigation.error_message.is_empty():
				error_message = navigation.error_message
		return TacticalOrderResult.failed(
			error_code,
			error_message,
			participant.participant_id,
			ORDER_MOVE
		)
	BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
	if not participant.set_navigation_path(
		navigation.destination,
		navigation.waypoints,
		BattleParticipant.NAVIGATION_SOURCE_EXTERNAL
	):
		return TacticalOrderResult.failed(
			"navigation_rejected",
			"Tactical order failed: navigation path was rejected.",
			participant.participant_id,
			ORDER_MOVE
		)
	participant.set_player_move_intent()
	_ensure_order_movement_speed(participant)
	return TacticalOrderResult.succeeded(participant.participant_id, ORDER_MOVE)


func issue_target(hostile_id: String):
	sync_from_authority()
	var participant: BattleParticipant = _controllable_selected()
	if participant == null:
		return TacticalOrderResult.failed(
			"no_selection",
			"Tactical order failed: no healthy living friendly is selected.",
			selected_participant_id,
			ORDER_TARGET,
			hostile_id
		)
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return TacticalOrderResult.failed(
			"null_battle_state",
			"Tactical order failed: battle_state is null.",
			participant.participant_id,
			ORDER_TARGET,
			hostile_id
		)
	var hostile: BattleParticipant = battle_state.get_participant(hostile_id)
	if hostile == null or not hostile.is_alive:
		return TacticalOrderResult.failed(
			"invalid_hostile",
			"Tactical order failed: hostile '%s' is not a living participant." % hostile_id,
			participant.participant_id,
			ORDER_TARGET,
			hostile_id
		)
	if hostile.side_id == participant.side_id:
		return TacticalOrderResult.failed(
			"not_hostile",
			"Tactical order failed: '%s' is not hostile." % hostile_id,
			participant.participant_id,
			ORDER_TARGET,
			hostile_id
		)
	if not hostile.has_battle_position:
		return TacticalOrderResult.failed(
			"hostile_unpositioned",
			"Tactical order failed: hostile '%s' has no battle position." % hostile_id,
			participant.participant_id,
			ORDER_TARGET,
			hostile_id
		)
	if not participant.set_target_participant(hostile_id):
		return TacticalOrderResult.failed(
			"target_rejected",
			"Tactical order failed: target could not be set.",
			participant.participant_id,
			ORDER_TARGET,
			hostile_id
		)
	participant.set_player_target_intent(hostile_id)
	return TacticalOrderResult.succeeded(participant.participant_id, ORDER_TARGET, hostile_id)


func issue_cover(cover_object_id: String):
	sync_from_authority()
	var participant: BattleParticipant = _controllable_selected()
	if participant == null:
		return TacticalOrderResult.failed(
			"no_selection",
			"Tactical order failed: no healthy living friendly is selected.",
			selected_participant_id,
			ORDER_COVER,
			cover_object_id
		)
	var battle_state: BattleState = _battle_state()
	if battle_state == null or battle_state.battlefield_geometry == null:
		return TacticalOrderResult.failed(
			"null_battle_state",
			"Tactical order failed: battle geometry is missing.",
			participant.participant_id,
			ORDER_COVER,
			cover_object_id
		)
	var slot: BattleCoverSlot = _resolve_cover_object_slot(
		battle_state,
		participant,
		cover_object_id
	)
	if slot == null:
		return TacticalOrderResult.failed(
			"cover_unavailable",
			"Tactical order failed: cover object '%s' has no usable slot." % cover_object_id,
			participant.participant_id,
			ORDER_COVER,
			cover_object_id
		)
	if BattleCoverService.is_at_slot(participant, slot):
		var occupy_here: BattleCoverResult = BattleCoverService.occupy_slot(
			battle_state,
			participant.participant_id,
			slot.cover_slot_id
		)
		if occupy_here != null and occupy_here.success:
			participant.clear_navigation_path()
			participant.set_player_cover_intent(cover_object_id, slot.cover_slot_id)
			return TacticalOrderResult.succeeded(
				participant.participant_id,
				ORDER_COVER,
				cover_object_id
			)
	if participant.occupied_cover_slot_id != slot.cover_slot_id:
		BattleCoverService.release_all_for_participant(battle_state, participant.participant_id)
	var reserved: BattleCoverResult = BattleCoverService.reserve_slot(
		battle_state,
		participant.participant_id,
		slot.cover_slot_id
	)
	if reserved == null or not reserved.success:
		var reserve_code: String = "cover_reserve_failed"
		var reserve_message: String = "Tactical order failed: cover slot could not be reserved."
		if reserved != null:
			if not reserved.error_code.is_empty():
				reserve_code = reserved.error_code
			if not reserved.error_message.is_empty():
				reserve_message = reserved.error_message
		return TacticalOrderResult.failed(
			reserve_code,
			reserve_message,
			participant.participant_id,
			ORDER_COVER,
			cover_object_id
		)
	var navigation: BattleNavigationResult = BattleNavigationService.find_path(
		battle_state,
		participant.battle_position,
		slot.position
	)
	if navigation == null or not navigation.success:
		BattleCoverService.release_reservation(battle_state, participant.participant_id)
		var error_code: String = "path_failed"
		var error_message: String = "Tactical order failed: no path to cover slot."
		if navigation != null:
			if not navigation.error_code.is_empty():
				error_code = navigation.error_code
			if not navigation.error_message.is_empty():
				error_message = navigation.error_message
		return TacticalOrderResult.failed(
			error_code,
			error_message,
			participant.participant_id,
			ORDER_COVER,
			cover_object_id
		)
	if not participant.set_navigation_path(
		navigation.destination,
		navigation.waypoints,
		BattleParticipant.NAVIGATION_SOURCE_EXTERNAL
	):
		BattleCoverService.release_reservation(battle_state, participant.participant_id)
		return TacticalOrderResult.failed(
			"navigation_rejected",
			"Tactical order failed: cover navigation path was rejected.",
			participant.participant_id,
			ORDER_COVER,
			cover_object_id
		)
	participant.set_player_cover_intent(cover_object_id, slot.cover_slot_id)
	_ensure_order_movement_speed(participant)
	return TacticalOrderResult.succeeded(participant.participant_id, ORDER_COVER, cover_object_id)


func selected_has_player_cover() -> bool:
	var participant: BattleParticipant = _controllable_selected()
	if participant == null:
		return false
	return participant.has_player_cover_intent()


func release_cover():
	sync_from_authority()
	var participant: BattleParticipant = _controllable_selected()
	if participant == null:
		return TacticalOrderResult.failed(
			"no_selection",
			"Tactical cover release failed: no healthy living friendly is selected.",
			selected_participant_id,
			ORDER_COVER
		)
	if not participant.has_player_cover_intent():
		return TacticalOrderResult.failed(
			"no_player_cover",
			"Tactical cover release failed: selected unit has no player COVER ownership.",
			participant.participant_id,
			ORDER_COVER
		)
	if participant.navigation_source == BattleParticipant.NAVIGATION_SOURCE_EXTERNAL:
		participant.clear_navigation_path()
	participant.clear_player_cover_intent()
	return TacticalOrderResult.succeeded(participant.participant_id, "release")


func _clear_completed_player_move() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		if participant.current_player_intent() != BattleParticipant.PLAYER_INTENT_MOVE:
			continue
		if participant.has_active_navigation_path():
			continue
		if participant.navigation_source == BattleParticipant.NAVIGATION_SOURCE_EXTERNAL:
			continue
		participant.clear_player_tactical_intent()


func _occupy_arrived_player_cover() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.is_alive:
			continue
		if not participant.has_player_cover_intent():
			continue
		if participant.reserved_cover_slot_id.is_empty() and participant.occupied_cover_slot_id.is_empty():
			continue
		var slot_id: String = participant.reserved_cover_slot_id
		if slot_id.is_empty():
			slot_id = participant.occupied_cover_slot_id
		var slot: BattleCoverSlot = null
		if battle_state.battlefield_geometry != null:
			slot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot == null:
			continue
		if not BattleCoverService.is_at_slot(participant, slot):
			continue
		var occupied: BattleCoverResult = BattleCoverService.occupy_slot(
			battle_state,
			participant.participant_id,
			slot.cover_slot_id
		)
		if occupied != null and occupied.success:
			participant.clear_navigation_path()
			participant.set_player_cover_intent(participant.player_cover_object_id, slot.cover_slot_id)


func _resolve_cover_object_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	cover_object_id: String
) -> BattleCoverSlot:
	if battle_state == null or participant == null or cover_object_id.is_empty():
		return null
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null or not geometry.has_cover_object(cover_object_id):
		return null
	var cover_object: BattleCoverObject = geometry.get_cover_object(cover_object_id)
	if cover_object == null:
		return null
	var slot_ids: Array[String] = []
	for slot_id: String in cover_object.slot_ids:
		slot_ids.append(slot_id)
	slot_ids.sort()
	var best: BattleCoverSlot = null
	var best_distance: float = INF
	for slot_id: String in slot_ids:
		var slot: BattleCoverSlot = geometry.get_cover_slot(slot_id)
		if slot == null or not slot.is_valid():
			continue
		if slot.occupied_by_participant_id == participant.participant_id:
			return slot
		if slot.is_occupied():
			continue
		if slot.is_reserved() and slot.reserved_by_participant_id != participant.participant_id:
			continue
		if BattleCoverService.is_at_slot(participant, slot):
			return slot
		var navigation: BattleNavigationResult = BattleNavigationService.find_path(
			battle_state,
			participant.battle_position,
			slot.position
		)
		if navigation == null or not navigation.success:
			continue
		var distance: float = participant.battle_position.distance_squared_to(slot.position)
		if not is_finite(distance):
			continue
		if best == null or distance < best_distance:
			best = slot
			best_distance = distance
	return best


func _clear_invalid_selection() -> void:
	if selected_participant_id.is_empty():
		return
	if not can_control_participant(selected_participant_id):
		selected_participant_id = ""


func _controllable_selected() -> BattleParticipant:
	return _controllable_participant(selected_participant_id)


func _controllable_participant(participant_id: String) -> BattleParticipant:
	var battle_state: BattleState = _battle_state()
	if battle_state == null or battle_state.battle_phase != "active":
		return null
	if participant_id.is_empty() or not battle_state.has_participant(participant_id):
		return null
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return null
	if participant.side_id != battle_state.attacker_side_id:
		return null
	if not participant.is_alive or participant.is_wounded:
		return null
	if not participant.has_battle_position:
		return null
	return participant


func _ensure_order_movement_speed(participant: BattleParticipant) -> void:
	if participant == null:
		return
	if is_finite(participant.movement_speed) and participant.movement_speed > 0.0:
		return
	participant.set_movement_speed(BattleCombatBehaviorCatalog.DEFAULT_COMBAT_MOVEMENT_SPEED)


func _battle_state() -> BattleState:
	if session == null:
		return null
	return session.battle_state
