class_name TacticalOrdersController
extends RefCounted

# Canonical live-battle player selection and priority-order issuer.
# Holds selection only. Combat vitality, occupancy, and AI remain authoritative
# on BattleParticipant / BattleState. Does not rank cover from HUD hover.
# COVER click ranks legal slots on the clicked object only, using existing
# directional protection against the relevant hostile.

const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverResult := preload("res://battle/geometry/battle_cover_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleCombatCoverEvaluationService := preload(
	"res://battle/combat/battle_combat_cover_evaluation_service.gd"
)
const TacticalOrderResult := preload("res://gameplay/tactical_order_result.gd")

const ORDER_MOVE := "move"
const ORDER_TARGET := "target"
const ORDER_COVER := "cover"

var session: CampaignBattleSession = null
var selected_participant_id: String = ""
var selected_participant_ids: Array[String] = []
var pending_command_id: String = ""
var feedback: String = "Select units to give orders"
var dragging: bool = false
var drag_start: Vector2
var drag_end: Vector2
var drag_additive: bool = false



func bind_session(p_session: CampaignBattleSession) -> void:
	session = p_session
	clear_selection()
	sync_from_authority()


func sync_from_authority() -> void:
	_clear_invalid_selection()
	var b = _battle_state()
	if b != null and not b.tactical_paused:
		_clear_completed_player_move()
		_occupy_arrived_player_cover()


func clear_selection() -> void:
	selected_participant_id = ""
	selected_participant_ids.clear()
	pending_command_id = ""
	dragging = false
	feedback = "Select units to give orders"


func select_participant(participant_id: String, additive: bool = false) -> bool:
	sync_from_authority()
	if not can_control_participant(participant_id):
		return false
	if not additive:
		selected_participant_ids.clear()
	if additive and participant_id in selected_participant_ids:
		selected_participant_ids.erase(participant_id)
	else:
		selected_participant_ids.append(participant_id)
	selected_participant_id = "" if selected_participant_ids.is_empty() else selected_participant_ids[0]
	pending_command_id = ""
	feedback = "%d selected" % selected_participant_ids.size()
	return true


func is_selected(participant_id: String) -> bool:
	return participant_id in selected_participant_ids


func select_class(weapon_type: String = "", additive: bool = false) -> void:
	if not additive:
		clear_selection()
	var b = _battle_state()
	if b == null:
		return
	var ids = b.participants.keys()
	ids.sort()
	for id in ids:
		var p = _controllable_participant(id)
		if p != null and (weapon_type.is_empty() or p.weapon_type == weapon_type) and id not in selected_participant_ids:
			selected_participant_ids.append(id)
	selected_participant_id = "" if selected_participant_ids.is_empty() else selected_participant_ids[0]
	pending_command_id = ""
	feedback = "%d selected" % selected_participant_ids.size()


func can_control_participant(participant_id: String) -> bool:
	var participant: BattleParticipant = _controllable_participant(participant_id)
	return participant != null


func _issue_move_one(participant: BattleParticipant, destination: Vector2):
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
	participant.clear_player_group_command()
	participant.set_player_move_intent()
	_ensure_order_movement_speed(participant)
	return TacticalOrderResult.succeeded(participant.participant_id, ORDER_MOVE)


func _issue_target_one(participant: BattleParticipant, hostile_id: String):
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
	if not battle_state.tactical_paused and not participant.set_target_participant(hostile_id):
		return TacticalOrderResult.failed(
			"target_rejected",
			"Tactical order failed: target could not be set.",
			participant.participant_id,
			ORDER_TARGET,
			hostile_id
		)
	participant.set_player_target_intent(hostile_id)
	return TacticalOrderResult.succeeded(participant.participant_id, ORDER_TARGET, hostile_id)


func _issue_cover_one(participant: BattleParticipant, cover_object_id: String):
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
			participant.clear_player_group_command()
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
	participant.clear_player_group_command()
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
		participant.finish_player_move()


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
	var threat: BattleParticipant = BattleCombatCoverEvaluationService.relevant_cover_threat(
		battle_state,
		participant
	)
	var ranked: Array[BattleCoverSlot] = BattleCombatCoverEvaluationService.rank_legal_slots_on_cover_object(
		battle_state,
		participant,
		cover_object_id,
		threat
	)
	for slot: BattleCoverSlot in ranked:
		if slot == null or slot.cover_object_id != cover_object_id:
			continue
		if BattleCoverService.is_at_slot(participant, slot):
			return slot
		if slot.occupied_by_participant_id == participant.participant_id:
			return slot
		var navigation: BattleNavigationResult = BattleNavigationService.find_path(
			battle_state,
			participant.battle_position,
			slot.position
		)
		if navigation != null and navigation.success:
			return slot
	return null


func _clear_invalid_selection() -> void:
	# Keep a primary id for existing camera/inspection callers.
	if selected_participant_ids.is_empty() and can_control_participant(selected_participant_id):
		selected_participant_ids.append(selected_participant_id)
	for id in selected_participant_ids.duplicate():
		if not can_control_participant(id):
			selected_participant_ids.erase(id)
	selected_participant_id = "" if selected_participant_ids.is_empty() else selected_participant_ids[0]
	if selected_participant_ids.is_empty():
		pending_command_id = ""


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
	if not participant.is_alive:
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


func issue_move(destination: Vector2):
	return _issue_selected(ORDER_MOVE, destination)


func issue_cover(cover_object_id: String):
	return _issue_selected(ORDER_COVER, cover_object_id)


func issue_target(hostile_id: String):
	return _issue_selected(ORDER_TARGET, hostile_id)


func command_selected(command_id: String) -> void:
	sync_from_authority()
	if selected_participant_ids.is_empty():
		feedback = "Select units first"
		return
	if command_id in ["push", "fall_back"]:
		pending_command_id = command_id
		feedback = "Choose a %s destination or cover" % ("Push" if command_id == "push" else "Fall Back")
		return
	if command_id not in ["hold", "clear"]:
		return
	pending_command_id = ""
	var count = 0
	for id in selected_participant_ids:
		var p = _controllable_participant(id)
		if p == null:
			continue
		if command_id == "clear":
			p.clear_player_tactical_intent()
			p.clear_navigation_path()
			p.clear_movement_intent()
			p.velocity = Vector2.ZERO
			BattleCoverService.release_reservation(_battle_state(), id)
			p.player_order_feedback = "Orders cleared — automatic behavior"
			count += 1
		elif not p.is_wounded:
			BattleCoverService.release_reservation(_battle_state(), id)
			p.set_player_hold_intent()
			p.player_group_command_id = "hold"
			p.player_order_feedback = "Hold position"
			count += 1
	feedback = "%s · %d units" % ["Orders cleared" if command_id == "clear" else "Holding", count]
	if count < selected_participant_ids.size():
		feedback += " · wounded retain survival behavior"


func _issue_selected(kind: String, destination):
	sync_from_authority()
	var command = pending_command_id if kind != ORDER_TARGET else ""
	pending_command_id = ""
	var count = 0
	var failed = 0
	var last_error = "No living friendly selected"
	var ids = selected_participant_ids.duplicate()
	var columns = maxi(1, ceili(sqrt(float(ids.size()))))
	var rows = maxi(1, ceili(float(ids.size()) / columns))
	for index in range(ids.size()):
		var p = _controllable_participant(ids[index])
		if p == null:
			continue
		if p.is_wounded:
			failed += 1
			last_error = "Wounded units retain survival behavior"
			p.player_order_feedback = last_error
			continue
		var result
		if kind == ORDER_TARGET:
			result = _issue_target_one(p, str(destination))
		elif kind == ORDER_COVER:
			result = _issue_cover_one(p, str(destination))
		else:
			var point: Vector2 = destination
			if ids.size() > 1:
				point += Vector2(float(index % columns) - (columns - 1) * .5, float(index / columns) - (rows - 1) * .5) * 1.5
			if not command.is_empty():
				var nearby = _cover_near_destination(p, point)
				if not nearby.is_empty():
					result = _issue_cover_one(p, nearby)
			if result == null or not result.success:
				result = _issue_move_one(p, point)
		if result != null and result.success:
			count += 1
			if kind != ORDER_TARGET:
				p.player_group_command_id = command
			p.player_order_feedback = {"move":"Moving to assigned position", "cover":"Taking assigned cover", "target":"Priority target — fire when a shot is possible"}.get(kind, "Order assigned")
		else:
			failed += 1
			last_error = "Cover occupied or no reachable protective slot" if kind == ORDER_COVER else "No route to destination"
			if kind == ORDER_TARGET:
				last_error = "Target is no longer available"
			p.player_order_feedback = last_error
	feedback = "%s · %d units" % [command.replace("_", " ").capitalize() if not command.is_empty() else kind.capitalize(), count]
	if failed > 0 or count == 0:
		feedback += " · " + last_error
	if count == 0:
		return TacticalOrderResult.failed("order_unavailable", last_error, selected_participant_id, kind)
	return TacticalOrderResult.succeeded(selected_participant_id, kind)


func _cover_near_destination(p: BattleParticipant, destination: Vector2) -> String:
	var b = _battle_state()
	var candidates: Array = []
	var distances = {}
	for slot_id in b.battlefield_geometry.cover_slots:
		var slot = b.battlefield_geometry.get_cover_slot(slot_id)
		var distance = slot.position.distance_squared_to(destination)
		if distance <= 36.0:
			distances[slot.cover_object_id] = minf(distances.get(slot.cover_object_id, INF), distance)
	for id in distances:
		candidates.append([distances[id], id])
	candidates.sort_custom(func(a, z): return a[0] < z[0] if a[0] != z[0] else a[1] < z[1])
	for row in candidates:
		var slot = _resolve_cover_object_slot(b, p, row[1])
		if slot != null and slot.position.distance_squared_to(destination) <= 36.0:
			return row[1]
	return ""


func handle_input(view: Node, event: InputEvent) -> bool:
	var b = _battle_state()
	if b == null or b.battle_phase != "active":
		return false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			b.tactical_paused = not b.tactical_paused
			return true
		if event.keycode == KEY_A and event.ctrl_pressed:
			select_class()
			return true
		if event.keycode == KEY_ESCAPE:
			if not pending_command_id.is_empty():
				pending_command_id = ""
				feedback = "Order cancelled"
			else:
				clear_selection()
			return true
	if event is InputEventMouseMotion and dragging:
		drag_end = event.position
		return true
	if not event is InputEventMouseButton:
		return false
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if not pending_command_id.is_empty():
			pending_command_id = ""
			feedback = "Order cancelled"
		else:
			clear_selection()
		return true
	if event.button_index != MOUSE_BUTTON_LEFT:
		return false
	if event.pressed:
		dragging = true
		drag_start = event.position
		drag_end = event.position
		drag_additive = event.shift_pressed
		return true
	if not dragging:
		return false
	dragging = false
	drag_end = event.position
	if drag_start.distance_to(drag_end) > 8.0:
		select_box(view, Rect2(drag_start, drag_end - drag_start).abs(), drag_additive)
	else:
		click_world(view, event.position, event.shift_pressed)
	return true


func select_box(view: Node, rect: Rect2, additive: bool) -> void:
	if not additive:
		clear_selection()
	var b = _battle_state()
	for id in b.participants:
		var p = _controllable_participant(id)
		if p == null:
			continue
		var screen: Vector2 = view.get_global_transform_with_canvas() * view._to_view(p.battle_position)
		if rect.has_point(screen) and id not in selected_participant_ids:
			selected_participant_ids.append(id)
	selected_participant_id = "" if selected_participant_ids.is_empty() else selected_participant_ids[0]
	pending_command_id = ""
	feedback = "%d selected" % selected_participant_ids.size()


func click_world(view: Node, screen: Vector2, additive: bool = false) -> void:
	var local: Vector2 = view.viewport_to_local_position(screen)
	view.set_pointer_local_position(local)
	var friendly: String = view.hit_test_live_friendly_soldier(local)
	if friendly.is_empty():
		friendly = view.hit_test_inactive_friendly_soldier(local)
	if not friendly.is_empty():
		select_participant(friendly, additive)
		return
	if selected_participant_ids.is_empty():
		return
	var target: String = view.hit_test_hostile_soldier(local)
	if not target.is_empty() and pending_command_id.is_empty():
		issue_target(target)
		return
	var cover: String = view.hit_test_cover_object(local)
	if not cover.is_empty():
		issue_cover(cover)
		return
	issue_move(view.screen_to_tactical_position(screen))
