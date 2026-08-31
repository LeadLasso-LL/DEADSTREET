class_name GameplayRuntime
extends Node

const StarterWorldService := preload("res://gameplay/starter_world_service.gd")
const GameFlowController := preload("res://core/game_flow_controller.gd")
const GameFlowResult := preload("res://core/game_flow_result.gd")
const NeighborhoodHQAttackService := preload("res://campaign/missions/neighborhood_hq_attack_service.gd")
const NeighborhoodHQAttackResult := preload("res://campaign/missions/neighborhood_hq_attack_result.gd")
const MissionRequest := preload("res://campaign/missions/mission_request.gd")
const DeploymentRequest := preload("res://campaign/actions/deployment_request.gd")
const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")

var game_state: GameState = null
var game_flow_controller: GameFlowController = null

var _last_logged_mode: String = ""


func _ready() -> void:
	game_state = StarterWorldService.create()
	var create_result: GameFlowResult = GameFlowController.create(game_state)
	if create_result == null or not create_result.success or create_result.controller == null:
		var error_code: String = "controller_create_failed"
		var error_message: String = "GameplayRuntime failed: GameFlowController could not be created."
		if create_result != null:
			if not create_result.error_code.is_empty():
				error_code = create_result.error_code
			if not create_result.error_message.is_empty():
				error_message = create_result.error_message
		push_error("%s (%s)" % [error_message, error_code])
		game_flow_controller = null
		return
	game_flow_controller = create_result.controller
	_log_boot()
	_log_mode_if_changed()


func _process(delta: float) -> void:
	_log_mode_if_changed()
	if game_flow_controller == null:
		return
	if game_flow_controller.get_current_mode() != GameFlowController.MODE_TACTICAL_ACTIVE:
		return
	game_flow_controller.advance_tactical(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_T:
		advance_campaign_turn()
	elif key_event.keycode == KEY_H:
		debug_launch_test_hq_assault()


func get_current_mode() -> String:
	if game_flow_controller == null:
		return ""
	return game_flow_controller.get_current_mode()


func list_pending_battles() -> Array[String]:
	if game_flow_controller == null:
		var empty: Array[String] = []
		return empty
	return game_flow_controller.list_pending_battle_ids()


func get_current_session() -> CampaignBattleSession:
	if game_flow_controller == null:
		return null
	return game_flow_controller.current_session


func advance_campaign_turn() -> GameFlowResult:
	if game_flow_controller == null:
		return GameFlowResult.failed(
			"null_controller",
			"GameplayRuntime failed: GameFlowController is missing."
		)
	var result: GameFlowResult = game_flow_controller.advance_campaign_turn()
	_log_mode_if_changed()
	return result


func enter_battle(mission_id: String = "") -> GameFlowResult:
	if game_flow_controller == null:
		return GameFlowResult.failed(
			"null_controller",
			"GameplayRuntime failed: GameFlowController is missing."
		)
	var result: GameFlowResult = game_flow_controller.enter_pending_battle(mission_id)
	_log_mode_if_changed()
	return result


func begin_current_battle() -> GameFlowResult:
	if game_flow_controller == null:
		return GameFlowResult.failed(
			"null_controller",
			"GameplayRuntime failed: GameFlowController is missing."
		)
	var result: GameFlowResult = game_flow_controller.begin_current_battle()
	_log_mode_if_changed()
	return result


# Temporary debug path. Uses NeighborhoodHQAttackService; not a production order UI.
func debug_launch_test_hq_assault() -> NeighborhoodHQAttackResult:
	if game_state == null:
		return NeighborhoodHQAttackResult.failed(
			"null_game_state",
			"GameplayRuntime debug HQ assault failed: game_state is null."
		)
	var soldier_ids: Array[String] = []
	soldier_ids.append(StarterWorldService.SOLDIER_ID)
	var vehicle_ids: Array[String] = []
	vehicle_ids.append(StarterWorldService.VEHICLE_ID)
	var deployment: DeploymentRequest = DeploymentRequest.new(
		StarterWorldService.DEBUG_FORCE_ID,
		StarterWorldService.PLAYER_FACTION_ID,
		StarterWorldService.KEEP_ID,
		StarterWorldService.HQ_ID,
		soldier_ids,
		vehicle_ids,
		10.0
	)
	var request: MissionRequest = MissionRequest.new(
		StarterWorldService.DEBUG_MISSION_ID,
		"capture_neighborhood_hq",
		deployment
	)
	var result: NeighborhoodHQAttackResult = NeighborhoodHQAttackService.launch_from_stronghold(
		game_state,
		request
	)
	_log_mode_if_changed()
	if result != null and result.success:
		print(
			"GameplayRuntime: debug HQ assault launched mission=%s force=%s state=%s"
			% [result.mission_id, result.force_id, result.mission_state]
		)
	elif result != null:
		print(
			"GameplayRuntime: debug HQ assault failed code=%s"
			% result.error_code
		)
	return result


func _log_boot() -> void:
	var player_id: String = ""
	var turn: int = 0
	if game_flow_controller != null:
		player_id = game_flow_controller.player_faction_id
	if game_state != null:
		turn = game_state.current_turn
	var pending: PackedStringArray = PackedStringArray(list_pending_battles())
	print(
		"GameplayRuntime: booted mode=%s turn=%s player=%s pending=%s"
		% [get_current_mode(), turn, player_id, ",".join(pending)]
	)


func _log_mode_if_changed() -> void:
	var mode: String = get_current_mode()
	if mode == _last_logged_mode:
		return
	_last_logged_mode = mode
	var pending: PackedStringArray = PackedStringArray(list_pending_battles())
	print("GameplayRuntime: mode=%s pending=%s" % [mode, ",".join(pending)])
