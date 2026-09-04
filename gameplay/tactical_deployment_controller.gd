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
		elif battle_state.has_participant(participant_id) and battle_state.is_participant_deployed(participant_id):
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
		print(
			"TacticalDeploymentController: deployed %s at (%s, %s)"
			% [result.participant_id, result.position.x, result.position.y]
		)
		selected_participant_id = ""
		status_text = "DEPLOYED %s" % result.participant_id
		return result
	var error_code: String = "invalid_placement"
	if result != null and not result.error_code.is_empty():
		error_code = result.error_code
	status_text = "INVALID DEPLOYMENT"
	print("TacticalDeploymentController: invalid placement code=%s" % error_code)
	return result


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
	if battle_state.is_participant_deployed(participant_id):
		return false
	if participant.has_battle_position:
		return false
	return true
