class_name TacticalDeploymentController
extends RefCounted

# Interaction owner for v1 attacker soldier placement.
# Holds selection only. Does not own positions, geometry, or legality.

const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleDeploymentPlacementService := preload("res://battle/core/battle_deployment_placement_service.gd")
const BattleDeploymentPlacementResult := preload("res://battle/core/battle_deployment_placement_result.gd")

const SUBROLE_ATTACKER_PLACEMENT := "attacker_placement"

var session: CampaignBattleSession = null
var selected_participant_id: String = ""
var status_text: String = ""
var subrole: String = SUBROLE_ATTACKER_PLACEMENT


func bind_session(p_session: CampaignBattleSession) -> void:
	session = p_session
	selected_participant_id = ""
	status_text = ""
	subrole = SUBROLE_ATTACKER_PLACEMENT


func clear_selection() -> void:
	selected_participant_id = ""
	if status_text == "INVALID DEPLOYMENT" or status_text.begins_with("SELECTED "):
		status_text = ""


func select_participant(participant_id: String) -> bool:
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


func _battle_state() -> BattleState:
	if session == null:
		return null
	return session.battle_state


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
