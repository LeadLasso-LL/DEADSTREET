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
const CampaignMapView := preload("res://gameplay/campaign_map_view.gd")
const TacticalBattleView := preload("res://gameplay/tactical_battle_view.gd")
const TacticalDeploymentController := preload("res://gameplay/tactical_deployment_controller.gd")
const BattleState := preload("res://battle/core/battle_state.gd")

var game_state: GameState = null
var game_flow_controller: GameFlowController = null
var tactical_deployment_controller: TacticalDeploymentController = null

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
	_bind_campaign_map_view()
	_sync_presentation_views()
	_log_boot()
	_log_mode_if_changed()


func _process(delta: float) -> void:
	_log_mode_if_changed()
	if game_flow_controller == null:
		return
	var mode: String = game_flow_controller.get_current_mode()
	if (
		mode != GameFlowController.MODE_TACTICAL_ACTIVE
		and mode != GameFlowController.MODE_TACTICAL_PENDING_HANDOFF
	):
		return
	game_flow_controller.advance_tactical(delta)
	_log_mode_if_changed()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if key_event.keycode == KEY_T:
			advance_campaign_turn()
			return
		if key_event.keycode == KEY_H:
			debug_launch_test_hq_assault()
			return
		if key_event.keycode == KEY_B:
			_debug_enter_pending_battle()
			return
		if key_event.keycode == KEY_C:
			_route_tactical_deployment_commit()
			return
		if key_event.keycode == KEY_SPACE:
			_debug_request_tactical_active()
			return
		if key_event.keycode == KEY_ESCAPE:
			_route_tactical_deployment_escape()
			return
	_route_tactical_deployment_input(event)


func _bind_campaign_map_view() -> void:
	var map_view: CampaignMapView = get_node_or_null("CampaignMapView") as CampaignMapView
	if map_view == null:
		return
	map_view.bind_campaign(game_state, game_flow_controller)


func _sync_presentation_views() -> void:
	var mode: String = get_current_mode()
	var show_tactical: bool = (
		mode == GameFlowController.MODE_TACTICAL_DEPLOYMENT
		or mode == GameFlowController.MODE_TACTICAL_ACTIVE
		or mode == GameFlowController.MODE_TACTICAL_PENDING_HANDOFF
	)
	var map_view: CampaignMapView = get_node_or_null("CampaignMapView") as CampaignMapView
	var tactical_view: TacticalBattleView = get_node_or_null("TacticalBattleView") as TacticalBattleView
	if map_view != null:
		map_view.visible = not show_tactical
		map_view.set_presentation_camera_enabled(not show_tactical)
	if tactical_view != null:
		tactical_view.visible = show_tactical
		if show_tactical:
			tactical_view.bind_session(get_current_session())
		else:
			tactical_view.bind_session(null)
		tactical_view.set_presentation_camera_enabled(show_tactical)
	_sync_tactical_deployment_controller(mode, tactical_view)


func _sync_tactical_deployment_controller(mode: String, tactical_view: TacticalBattleView) -> void:
	var in_deployment: bool = mode == GameFlowController.MODE_TACTICAL_DEPLOYMENT
	if in_deployment:
		if tactical_deployment_controller == null:
			tactical_deployment_controller = TacticalDeploymentController.new()
		if tactical_deployment_controller.session != get_current_session():
			tactical_deployment_controller.bind_session(get_current_session())
		else:
			tactical_deployment_controller.sync_from_authority()
		if tactical_view != null:
			tactical_view.bind_deployment_controller(tactical_deployment_controller)
		return
	if tactical_deployment_controller != null:
		tactical_deployment_controller.clear_selection()
		tactical_deployment_controller.bind_session(null)
	if tactical_view != null:
		tactical_view.bind_deployment_controller(null)


func _route_tactical_deployment_escape() -> void:
	if get_current_mode() != GameFlowController.MODE_TACTICAL_DEPLOYMENT:
		return
	if tactical_deployment_controller == null:
		return
	tactical_deployment_controller.clear_selection()


func _route_tactical_deployment_commit() -> void:
	if get_current_mode() != GameFlowController.MODE_TACTICAL_DEPLOYMENT:
		return
	if tactical_deployment_controller == null:
		return
	tactical_deployment_controller.try_commit_attacker()


func _route_tactical_deployment_input(event: InputEvent) -> void:
	if get_current_mode() != GameFlowController.MODE_TACTICAL_DEPLOYMENT:
		return
	if tactical_deployment_controller == null:
		return
	if not (event is InputEventMouseButton):
		return
	var mouse: InputEventMouseButton = event as InputEventMouseButton
	if not mouse.pressed:
		return
	if mouse.button_index == MOUSE_BUTTON_RIGHT:
		tactical_deployment_controller.clear_selection()
		return
	if mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	var tactical_view: TacticalBattleView = get_node_or_null("TacticalBattleView") as TacticalBattleView
	if tactical_view == null:
		return
	var local_pos: Vector2 = tactical_view.viewport_to_local_position(mouse.position)
	var hit: Dictionary = tactical_view.hit_test_roster(local_pos)
	var kind: String = str(hit.get("kind", ""))
	var hit_id: String = str(hit.get("id", ""))
	if kind == "participant":
		tactical_deployment_controller.select_participant(hit_id)
		return
	if kind == "vehicle":
		tactical_deployment_controller.notify_vehicle_not_available(hit_id)
		return
	var tactical_pos: Vector2 = tactical_view.screen_to_tactical_position(mouse.position)
	tactical_deployment_controller.try_place_selected(tactical_pos)


func _debug_request_tactical_active() -> void:
	var result: GameFlowResult = begin_current_battle()
	if result != null and result.success:
		print(
			"GameplayRuntime: begin_current_battle success mode=%s"
			% get_current_mode()
		)
		_log_tactical_snapshot()
		return
	if result != null:
		print("GameplayRuntime: begin_current_battle failed code=%s" % result.error_code)
		return
	print("GameplayRuntime: begin_current_battle failed")


func _debug_enter_pending_battle() -> void:
	var result: GameFlowResult = enter_battle()
	if result != null and result.success:
		print(
			"GameplayRuntime: enter_battle success mission=%s mode=%s"
			% [result.entered_mission_id, get_current_mode()]
		)
		_log_tactical_snapshot()
	elif result != null:
		print("GameplayRuntime: enter_battle failed code=%s" % result.error_code)
	else:
		print("GameplayRuntime: enter_battle failed")


func _log_tactical_snapshot() -> void:
	var session: CampaignBattleSession = get_current_session()
	if session == null or session.battle_state == null:
		print("GameplayRuntime: tactical snapshot session=absent")
		return
	var battle_state: BattleState = session.battle_state
	var deployed_participants: int = 0
	var undeployed_participants: int = 0
	for participant_id: String in battle_state.participants:
		if battle_state.is_participant_deployed(participant_id):
			deployed_participants += 1
		else:
			undeployed_participants += 1
	var deployed_vehicles: int = 0
	var undeployed_vehicles: int = 0
	for vehicle_id: String in battle_state.vehicles:
		if battle_state.is_vehicle_deployed(vehicle_id):
			deployed_vehicles += 1
		else:
			undeployed_vehicles += 1
	var geo_w: float = 0.0
	var geo_h: float = 0.0
	if battle_state.battlefield_geometry != null:
		geo_w = battle_state.battlefield_geometry.width
		geo_h = battle_state.battlefield_geometry.height
	print(
		"GameplayRuntime: tactical snapshot type=%s mission=%s phase=%s session=%s elapsed=%s geo=%sx%s participants deployed=%s undeployed=%s vehicles deployed=%s undeployed=%s"
		% [
			battle_state.battle_type_id,
			battle_state.mission_id,
			battle_state.battle_phase,
			session.session_state,
			battle_state.elapsed_time_seconds,
			geo_w,
			geo_h,
			deployed_participants,
			undeployed_participants,
			deployed_vehicles,
			undeployed_vehicles,
		]
	)


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
	_log_debug_force_campaign_position("after_turn")
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
	_log_debug_force_campaign_position("after_launch")
	return result


func _log_debug_force_campaign_position(reason: String) -> void:
	if game_state == null:
		return
	var force: TravelingForce = game_state.get_traveling_force(StarterWorldService.DEBUG_FORCE_ID)
	if force == null:
		print("GameplayRuntime: %s force=absent pending=%s" % [reason, ",".join(PackedStringArray(list_pending_battles()))])
		return
	var pos: Vector2 = CampaignMapView.campaign_position_of_force(force, game_state.road_graph)
	print(
		"GameplayRuntime: %s force=%s state=%s campaign_pos=(%s, %s) segment=%s into=%s pending=%s"
		% [
			reason,
			force.id,
			force.travel_state,
			pos.x,
			pos.y,
			force.route_segment_index,
			force.distance_into_segment,
			",".join(PackedStringArray(list_pending_battles())),
		]
	)


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
	_sync_presentation_views()
	var pending: PackedStringArray = PackedStringArray(list_pending_battles())
	print("GameplayRuntime: mode=%s pending=%s" % [mode, ",".join(pending)])
