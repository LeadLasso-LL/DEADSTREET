class_name TacticalDeploymentController
extends RefCounted

# Interaction owner for v1 attacker soldier placement, attacker-side commit,
# standard-assault attacker vehicle auto-parking, and defender AI invocation.
# Holds selection only. Does not own positions, geometry, legality, commitment
# truth, vehicle pose, or AI scoring.

const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleDeploymentPlacementService := preload("res://battle/core/battle_deployment_placement_service.gd")
const BattleDeploymentPlacementResult := preload("res://battle/core/battle_deployment_placement_result.gd")
const BattleDeploymentCommitService := preload("res://battle/core/battle_deployment_commit_service.gd")
const BattleDeploymentCommitResult := preload("res://battle/core/battle_deployment_commit_result.gd")
const BattleDeploymentAiService := preload("res://battle/ai/battle_deployment_ai_service.gd")
const BattleDeploymentAiResult := preload("res://battle/ai/battle_deployment_ai_result.gd")
const BattleDeploymentPlanner := preload("res://battle/ai/battle_deployment_planner.gd")
const BattleVehicleDeploymentService := preload("res://battle/vehicles/battle_vehicle_deployment_service.gd")
const BattleVehicleDeploymentResult := preload("res://battle/vehicles/battle_vehicle_deployment_result.gd")
const BattleVehiclePlacementContext := preload("res://battle/vehicles/battle_vehicle_placement_context.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverResult := preload("res://battle/geometry/battle_cover_result.gd")
const StarterWorldService := preload("res://gameplay/starter_world_service.gd")

const SUBROLE_ATTACKER_PLACEMENT := "attacker_placement"
const SUBROLE_DEFENDER_PLACEMENT := "defender" + "_placement"
const SUBROLE_DEPLOYMENT_COMPLETE := "deployment_complete"

var session: CampaignBattleSession = null
var selected_participant_id: String = ""
var status_text: String = ""
var subrole: String = SUBROLE_ATTACKER_PLACEMENT
var last_defender_ai_posture: String = ""
var last_defender_ai_error: String = ""


func bind_session(p_session: CampaignBattleSession) -> void:
	session = p_session
	selected_participant_id = ""
	status_text = ""
	last_defender_ai_posture = ""
	last_defender_ai_error = ""
	_ensure_attacker_vehicles()
	_sync_subrole_from_authority()


func sync_from_authority() -> void:
	_ensure_attacker_vehicles()
	_sync_subrole_from_authority()


func clear_selection() -> void:
	selected_participant_id = ""
	if status_text == "INVALID DEPLOYMENT" or status_text.begins_with("SELECTED "):
		status_text = ""


func select_participant(participant_id: String) -> bool:
	_sync_subrole_from_authority()
	var battle_state: BattleState = _battle_state()
	if battle_state == null or participant_id.is_empty():
		return false
	if not _is_attacker_soldier_selectable(battle_state, participant_id):
		if _is_defender_participant(battle_state, participant_id):
			status_text = "defender deployment not available"
		elif battle_state.has_participant(participant_id) and battle_state.is_side_deployment_committed(battle_state.attacker_side_id):
			status_text = ""
		else:
			status_text = ""
		return false
	selected_participant_id = participant_id
	status_text = "SELECTED %s" % participant_id
	return true


func notify_vehicle_not_available(_vehicle_id: String = "") -> void:
	status_text = "vehicle deployment not available"


func try_place_selected(position: Vector2) -> BattleDeploymentPlacementResult:
	_sync_subrole_from_authority()
	if selected_participant_id.is_empty():
		return BattleDeploymentPlacementResult.failed(
			"no_selection",
			"Deployment placement failed: no participant is selected."
		)
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return BattleDeploymentPlacementResult.failed(
			"null_battle_state",
			"Deployment placement failed: battle_state is null.",
			selected_participant_id,
			position
		)
	if not _is_attacker_soldier_selectable(battle_state, selected_participant_id):
		return BattleDeploymentPlacementResult.failed(
			"not_eligible",
			"Deployment placement failed: selected participant is not an eligible attacker soldier.",
			selected_participant_id,
			position
		)
	var result: BattleDeploymentPlacementResult = BattleDeploymentPlacementService.place_participant(
		battle_state,
		selected_participant_id,
		position
	)
	if result != null and result.success:
		_clear_deployment_cover_assignment(battle_state, selected_participant_id)
		print(
			"TacticalDeploymentController: deployed %s at (%s, %s)"
			% [result.participant_id, result.position.x, result.position.y]
		)
		status_text = "DEPLOYED %s" % result.participant_id
		return result
	var error_code: String = "invalid_placement"
	if result != null and not result.error_code.is_empty():
		error_code = result.error_code
	status_text = "INVALID DEPLOYMENT"
	print("TacticalDeploymentController: invalid placement code=%s" % error_code)
	return result


func try_place_selected_cover(cover_object_id: String) -> BattleDeploymentPlacementResult:
	_sync_subrole_from_authority()
	if selected_participant_id.is_empty():
		return BattleDeploymentPlacementResult.failed(
			"no_selection",
			"Deployment cover placement failed: no participant is selected."
		)
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return BattleDeploymentPlacementResult.failed(
			"null_battle_state",
			"Deployment cover placement failed: battle_state is null.",
			selected_participant_id
		)
	if not _is_attacker_soldier_selectable(battle_state, selected_participant_id):
		return BattleDeploymentPlacementResult.failed(
			"not_eligible",
			"Deployment cover placement failed: selected participant is not an eligible attacker soldier.",
			selected_participant_id
		)
	var slot: BattleCoverSlot = resolve_deployment_cover_slot(
		battle_state,
		selected_participant_id,
		cover_object_id
	)
	if slot == null:
		status_text = "INVALID DEPLOYMENT"
		print(
			"TacticalDeploymentController: invalid cover object %s for %s"
			% [cover_object_id, selected_participant_id]
		)
		return BattleDeploymentPlacementResult.failed(
			"cover_unavailable",
			"Deployment cover placement failed: cover object '%s' has no legal deployment slot." % cover_object_id,
			selected_participant_id
		)
	var result: BattleDeploymentPlacementResult = BattleDeploymentPlacementService.place_participant(
		battle_state,
		selected_participant_id,
		slot.position
	)
	if result == null or not result.success:
		var error_code: String = "invalid_placement"
		if result != null and not result.error_code.is_empty():
			error_code = result.error_code
		status_text = "INVALID DEPLOYMENT"
		print("TacticalDeploymentController: invalid cover placement code=%s" % error_code)
		return result
	_assign_deployment_cover(
		battle_state,
		selected_participant_id,
		cover_object_id,
		slot.cover_slot_id
	)
	print(
		"TacticalDeploymentController: deployed %s to cover %s slot %s"
		% [selected_participant_id, cover_object_id, slot.cover_slot_id]
	)
	status_text = "DEPLOYED %s" % selected_participant_id
	return result


func resolve_deployment_cover_slot(
	battle_state: BattleState,
	participant_id: String,
	cover_object_id: String
) -> BattleCoverSlot:
	if battle_state == null or participant_id.is_empty() or cover_object_id.is_empty():
		return null
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
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
	var legal: Array[BattleCoverSlot] = []
	for slot_id: String in slot_ids:
		var slot: BattleCoverSlot = geometry.get_cover_slot(slot_id)
		if slot == null or not slot.is_valid():
			continue
		if slot.cover_object_id != cover_object_id:
			continue
		if slot.occupied_by_participant_id == participant_id:
			return slot
		if slot.is_occupied():
			continue
		if slot.is_reserved() and slot.reserved_by_participant_id != participant_id:
			continue
		if not battle_state.get_deployment_position_error(participant.side_id, slot.position).is_empty():
			continue
		if BattleCoverService.is_at_slot(participant, slot):
			return slot
		legal.append(slot)
	if legal.is_empty():
		return null
	if not participant.has_battle_position:
		return legal[0]
	var best: BattleCoverSlot = legal[0]
	var best_distance: float = participant.battle_position.distance_squared_to(best.position)
	for i in range(1, legal.size()):
		var candidate: BattleCoverSlot = legal[i]
		var distance: float = participant.battle_position.distance_squared_to(candidate.position)
		if not is_finite(distance):
			continue
		if distance < best_distance:
			best = candidate
			best_distance = distance
	return best


func apply_pending_cover_to_live() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		if not participant.has_pending_deployment_cover():
			continue
		var object_id: String = participant.pending_deployment_cover_object_id
		var slot_id: String = participant.pending_deployment_cover_slot_id
		if participant.occupied_cover_slot_id != slot_id:
			var occupied: BattleCoverResult = BattleCoverService.occupy_slot(
				battle_state,
				participant_id,
				slot_id
			)
			if occupied == null or not occupied.success:
				var reserved: BattleCoverResult = BattleCoverService.reserve_slot(
					battle_state,
					participant_id,
					slot_id
				)
				if reserved != null and reserved.success:
					BattleCoverService.occupy_slot(battle_state, participant_id, slot_id)
		participant.set_player_cover_intent(object_id, slot_id)
		participant.clear_pending_deployment_cover()


func _clear_deployment_cover_assignment(battle_state: BattleState, participant_id: String) -> void:
	if battle_state == null or participant_id.is_empty():
		return
	BattleCoverService.release_all_for_participant(battle_state, participant_id)
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return
	participant.clear_pending_deployment_cover()
	if participant.current_player_intent() == BattleParticipant.PLAYER_INTENT_COVER:
		participant.clear_player_tactical_intent()


func _assign_deployment_cover(
	battle_state: BattleState,
	participant_id: String,
	cover_object_id: String,
	cover_slot_id: String
) -> void:
	if battle_state == null or participant_id.is_empty():
		return
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return
	if (
		participant.occupied_cover_slot_id != cover_slot_id
		and participant.reserved_cover_slot_id != cover_slot_id
	):
		BattleCoverService.release_all_for_participant(battle_state, participant_id)
	var occupied: BattleCoverResult = BattleCoverService.occupy_slot(
		battle_state,
		participant_id,
		cover_slot_id
	)
	if occupied == null or not occupied.success:
		var reserved: BattleCoverResult = BattleCoverService.reserve_slot(
			battle_state,
			participant_id,
			cover_slot_id
		)
		if reserved != null and reserved.success:
			occupied = BattleCoverService.occupy_slot(battle_state, participant_id, cover_slot_id)
	if occupied != null and occupied.success:
		participant.set_pending_deployment_cover(cover_object_id, cover_slot_id)
		return
	participant.clear_pending_deployment_cover()


func try_commit_attacker() -> BattleDeploymentCommitResult:
	_sync_subrole_from_authority()
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return BattleDeploymentCommitResult.failed(
			"null_battle_state",
			"Deployment commit failed: battle_state is null."
		)
	if battle_state.battle_phase != "deployment":
		return BattleDeploymentCommitResult.failed(
			"battle_not_in_deployment",
			"Deployment commit failed: battle phase is '%s', not deployment." % battle_state.battle_phase,
			battle_state.attacker_side_id
		)
	var attacker_side_id: String = battle_state.attacker_side_id
	if battle_state.is_side_deployment_committed(attacker_side_id):
		_sync_subrole_from_authority()
		return BattleDeploymentCommitResult.failed(
			"already_committed",
			"Deployment commit failed: attacker side '%s' is already committed." % attacker_side_id,
			attacker_side_id
		)
	if subrole != SUBROLE_ATTACKER_PLACEMENT:
		return BattleDeploymentCommitResult.failed(
			"wrong_subrole",
			"Deployment commit failed: controller subrole is '%s', not attacker placement." % subrole,
			attacker_side_id
		)
	_fill_unplaced_debug_attackers()
	var result: BattleDeploymentCommitResult = BattleDeploymentCommitService.commit_side_deployment(
		battle_state,
		attacker_side_id
	)
	if result != null and result.success:
		selected_participant_id = ""
		_sync_subrole_from_authority()
		print("TacticalDeploymentController: attacker side %s committed" % attacker_side_id)
		_invoke_standard_assault_defender_ai()
		_sync_subrole_from_authority()
		return result
	var error_code: String = "commit_failed"
	if result != null and not result.error_code.is_empty():
		error_code = result.error_code
	if (
		error_code == "undeployed_living_participant"
		or error_code == "missing_battle_position"
		or error_code == "invalid_position"
		or error_code == "no_living_participants"
		or error_code == "undeployed_vehicle"
		or error_code == "missing_vehicle_position"
		or error_code == "invalid_vehicle_pose"
	):
		status_text = "attacker deployment incomplete"
	print("TacticalDeploymentController: attacker commit failed code=%s" % error_code)
	return result


func _battle_state() -> BattleState:
	if session == null:
		return null
	return session.battle_state


func _ensure_attacker_vehicles() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return
	if battle_state.battle_phase != "deployment":
		return
	if battle_state.is_side_deployment_committed(battle_state.attacker_side_id):
		return
	var context: BattleVehiclePlacementContext = null
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry != null:
		context = geometry.attacker_vehicle_placement_context
	var result: BattleVehicleDeploymentResult = BattleVehicleDeploymentService.apply_side(
		battle_state,
		battle_state.attacker_side_id,
		battle_state.defender_side_id,
		context
	)
	if result != null and result.success:
		if battle_state.battlefield_geometry.authored_layout_id == "dead_street_dusk_v1":
			for v in battle_state.vehicles.values():
				if v.side_id == battle_state.attacker_side_id:preload("res://battle/vehicles/battle_arrival_service.gd").ensure_doors(battle_state,v)
		if result.placed_count > 0:
			print(
				"TacticalDeploymentController: auto-placed %s attacker vehicle(s)"
				% result.placed_count
			)
		return
	var error_code: String = "vehicle_place_failed"
	if result != null and not result.error_code.is_empty():
		error_code = result.error_code
	status_text = "attacker vehicle placement failed (%s)" % error_code
	print("TacticalDeploymentController: attacker vehicle auto-placement failed code=%s" % error_code)


func _sync_subrole_from_authority() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		subrole = SUBROLE_ATTACKER_PLACEMENT
		last_defender_ai_posture = ""
		return
	var attacker_committed: bool = battle_state.is_side_deployment_committed(battle_state.attacker_side_id)
	var defender_committed: bool = battle_state.is_side_deployment_committed(battle_state.defender_side_id)
	if attacker_committed and defender_committed:
		subrole = SUBROLE_DEPLOYMENT_COMPLETE
		if last_defender_ai_posture.is_empty():
			last_defender_ai_posture = BattleDeploymentPlanner.relative_posture(
				battle_state,
				battle_state.defender_side_id,
				battle_state.attacker_side_id
			)
		return
	if attacker_committed:
		subrole = SUBROLE_DEFENDER_PLACEMENT
		return
	subrole = SUBROLE_ATTACKER_PLACEMENT


func _invoke_standard_assault_defender_ai() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return
	if not battle_state.is_side_deployment_committed(battle_state.attacker_side_id):
		return
	if battle_state.is_side_deployment_committed(battle_state.defender_side_id):
		return
	if _side_living_soldiers_all_placed(battle_state, battle_state.defender_side_id):
		var commit: BattleDeploymentCommitResult = BattleDeploymentCommitService.commit_side_deployment(
			battle_state,
			battle_state.defender_side_id
		)
		if commit != null and commit.success:
			last_defender_ai_error = ""
			last_defender_ai_posture = BattleDeploymentPlanner.relative_posture(
				battle_state,
				battle_state.defender_side_id,
				battle_state.attacker_side_id
			)
			status_text = "attacker committed; defender AI deployed; defender committed; deployment complete"
			print(
				"TacticalDeploymentController: defender already placed; committed side %s posture=%s"
				% [battle_state.defender_side_id, last_defender_ai_posture]
			)
			return
	var ai_result: BattleDeploymentAiResult = BattleDeploymentAiService.apply_and_commit_side(
		battle_state,
		battle_state.defender_side_id,
		battle_state.attacker_side_id
	)
	if ai_result != null and ai_result.success:
		last_defender_ai_error = ""
		if ai_result.plan != null and not ai_result.plan.posture.is_empty():
			last_defender_ai_posture = ai_result.plan.posture
		else:
			last_defender_ai_posture = BattleDeploymentPlanner.relative_posture(
				battle_state,
				battle_state.defender_side_id,
				battle_state.attacker_side_id
			)
		status_text = "attacker committed; defender AI deployed; defender committed; deployment complete"
		print(
			"TacticalDeploymentController: defender AI deployed and committed side %s posture=%s"
			% [battle_state.defender_side_id, last_defender_ai_posture]
		)
		return
	var error_code: String = "plan_failed"
	if ai_result != null and not ai_result.error_code.is_empty():
		error_code = ai_result.error_code
	last_defender_ai_error = error_code
	if ai_result != null and ai_result.plan != null and not ai_result.plan.posture.is_empty():
		last_defender_ai_posture = ai_result.plan.posture
	status_text = "attacker committed; defender AI failed (%s)" % error_code
	print("TacticalDeploymentController: defender AI failed code=%s" % error_code)


func _fill_unplaced_debug_attackers() -> void:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return
	if battle_state.mission_id != StarterWorldService.DEBUG_MISSION_ID:
		return
	if battle_state.battle_phase != "deployment":
		return
	var placed_any: bool = false
	var unplaced: Array[String] = []
	for participant_id: String in StarterWorldService.debug_attacker_soldier_ids():
		if not battle_state.has_participant(participant_id):
			continue
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.is_alive:
			continue
		if battle_state.is_participant_deployed(participant_id) or participant.has_battle_position:
			placed_any = true
		else:
			unplaced.append(participant_id)
	if not placed_any or unplaced.is_empty():
		return
	for participant_id: String in unplaced:
		var start: Vector2 = StarterWorldService.debug_start_position(participant_id)
		if start == Vector2.INF:
			continue
		BattleDeploymentPlacementService.place_participant(battle_state, participant_id, start)


func _side_living_soldiers_all_placed(battle_state: BattleState, side_id: String) -> bool:
	if battle_state == null or side_id.is_empty() or not battle_state.has_side(side_id):
		return false
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null:
		return false
	var living: int = 0
	for participant_id: String in side.participant_ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.is_alive:
			continue
		living += 1
		if not battle_state.is_participant_deployed(participant_id) or not participant.has_battle_position:
			return false
	return living > 0


func _is_defender_participant(battle_state: BattleState, participant_id: String) -> bool:
	if battle_state == null or not battle_state.has_participant(participant_id):
		return false
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return false
	return participant.side_id == battle_state.defender_side_id


func _is_attacker_soldier_selectable(battle_state: BattleState, participant_id: String) -> bool:
	if battle_state == null or battle_state.battle_phase != "deployment":
		return false
	if battle_state.is_side_deployment_committed(battle_state.attacker_side_id):
		return false
	if subrole != SUBROLE_ATTACKER_PLACEMENT:
		return false
	if participant_id.is_empty() or not battle_state.has_participant(participant_id):
		return false
	var participant: BattleParticipant = battle_state.get_participant(participant_id)
	if participant == null:
		return false
	if participant.side_id != battle_state.attacker_side_id:
		return false
	if not participant.is_alive:
		return false
	return true


func choose_arrival(choice: String) -> bool:
	var b=_battle_state()
	if not preload("res://battle/vehicles/battle_arrival_service.gd").choose(b,choice):return false
	clear_selection()
	status_text="%s ARRIVAL — PLACE YOUR UNITS" % choice.to_upper()
	return true

func place_unplaced_in_cover() -> bool:
	var b=_battle_state()
	if b==null or b.battle_phase!="deployment" or b.is_side_deployment_committed(b.attacker_side_id):return false
	var objects=b.battlefield_geometry.cover_objects.keys()
	objects.sort_custom(func(a,c):
		var ad="__door_" in a;var cd="__door_" in c
		return ad if ad!=cd else a<c
	)
	var ids=b.participants.keys();ids.sort()
	for id in ids:
		var p=b.get_participant(id)
		if p.side_id!=b.attacker_side_id or not p.is_alive or p.has_battle_position:continue
		select_participant(id)
		var placed=false
		for object in objects:
			if resolve_deployment_cover_slot(b,id,object)==null:continue
			if try_place_selected_cover(object).success:placed=true;break
		if not placed:status_text="No free arrival cover for every unit.";return false
	clear_selection();return true
