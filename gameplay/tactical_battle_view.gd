class_name TacticalBattleView
extends Node2D

# Developer visualization only. Reads CampaignBattleSession / BattleState.
# Does not own tactical coordinates, deployment legality, geometry, or combat.
# TACTICAL_PIXELS_PER_UNIT is a view conversion, not a second spatial authority.

const CampaignBattleSession := preload("res://battle/session/campaign_battle_session.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const TacticalDeploymentController := preload("res://gameplay/tactical_deployment_controller.gd")

const TACTICAL_PIXELS_PER_UNIT := 8.0
const CAMERA_PADDING := 96.0
const PARTICIPANT_RADIUS := 7.0
const VEHICLE_SIZE := Vector2(16.0, 10.0)
const COVER_SLOT_RADIUS := 3.5
const ROSTER_ROW_HEIGHT := 16.0
const ROSTER_ROW_WIDTH := 520.0
const ROSTER_FONT_SIZE := 13

# Provisional visualization tints. Not Dead Street art direction or faction language.
const PROVISIONAL_BACKGROUND := Color(0.10, 0.10, 0.11, 1.0)
const PROVISIONAL_FIELD := Color(0.18, 0.19, 0.20, 1.0)
const PROVISIONAL_BOUNDS := Color(0.78, 0.78, 0.74, 1.0)
const PROVISIONAL_ATTACKER_ZONE := Color(0.28, 0.48, 0.72, 0.28)
const PROVISIONAL_ATTACKER_ZONE_LINE := Color(0.46, 0.70, 0.92, 0.95)
const PROVISIONAL_DEFENDER_ZONE := Color(0.72, 0.42, 0.24, 0.28)
const PROVISIONAL_DEFENDER_ZONE_LINE := Color(0.90, 0.64, 0.40, 0.95)
const PROVISIONAL_ATTACKER := Color(0.42, 0.70, 0.92, 1.0)
const PROVISIONAL_DEFENDER := Color(0.86, 0.64, 0.40, 1.0)
const PROVISIONAL_DEAD := Color(0.42, 0.42, 0.44, 1.0)
const PROVISIONAL_WOUNDED := Color(0.90, 0.78, 0.36, 1.0)
const PROVISIONAL_OBSTACLE_MOVE := Color(0.32, 0.26, 0.24, 0.92)
const PROVISIONAL_OBSTACLE_LOS := Color(0.24, 0.32, 0.34, 0.55)
const PROVISIONAL_OBSTACLE_BOTH := Color(0.28, 0.28, 0.30, 0.95)
const PROVISIONAL_LOS_LINE := Color(0.55, 0.78, 0.82, 1.0)
const PROVISIONAL_MOVE_LINE := Color(0.62, 0.46, 0.40, 1.0)
const PROVISIONAL_COVER := Color(0.72, 0.86, 0.58, 1.0)
const PROVISIONAL_LABEL := Color(0.92, 0.92, 0.90, 1.0)
const PROVISIONAL_LABEL_SHADOW := Color(0.05, 0.05, 0.06, 1.0)
const PROVISIONAL_OVERLAY := Color(0.88, 0.88, 0.86, 1.0)
const PROVISIONAL_SELECTED := Color(0.95, 0.86, 0.38, 0.38)
const PROVISIONAL_SELECTABLE := Color(0.72, 0.88, 1.0, 1.0)
const PROVISIONAL_STATUS := Color(0.95, 0.78, 0.42, 1.0)

# Reference only. This view never stores an independent BattleState.
var session: CampaignBattleSession = null
var deployment_controller: TacticalDeploymentController = null

var _camera: Camera2D = null
var _roster_hits: Array[Dictionary] = []


func _ready() -> void:
	_ensure_camera()
	if _camera != null:
		_camera.enabled = false


func bind_session(p_session: CampaignBattleSession) -> void:
	session = p_session
	_ensure_camera()
	_frame_camera()
	queue_redraw()


func bind_deployment_controller(p_controller: TacticalDeploymentController) -> void:
	deployment_controller = p_controller
	queue_redraw()


func screen_to_tactical_position(viewport_position: Vector2) -> Vector2:
	return viewport_to_local_position(viewport_position) / TACTICAL_PIXELS_PER_UNIT


func viewport_to_local_position(viewport_position: Vector2) -> Vector2:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return Vector2.ZERO
	var canvas_pos: Vector2 = viewport.get_canvas_transform().affine_inverse() * viewport_position
	return to_local(canvas_pos)


func hit_test_roster(local_position: Vector2) -> Dictionary:
	_rebuild_roster_hits()
	var hit: Dictionary = {}
	for row: Dictionary in _roster_hits:
		var rect: Rect2 = row.get("rect", Rect2())
		if rect.has_point(local_position):
			hit["kind"] = str(row.get("kind", ""))
			hit["id"] = str(row.get("id", ""))
			return hit
	return hit


func _overlay_row_rect(origin: Vector2, row_index: int) -> Rect2:
	var size: Vector2 = _roster_row_size()
	return Rect2(Vector2(origin.x, origin.y + float(row_index) * size.y), size)


func _roster_row_size() -> Vector2:
	var font: Font = ThemeDB.fallback_font
	var text_height: float = font.get_ascent(ROSTER_FONT_SIZE) + font.get_descent(ROSTER_FONT_SIZE)
	return Vector2(ROSTER_ROW_WIDTH, maxf(ROSTER_ROW_HEIGHT, text_height))


func _overlay_layout() -> Array[Dictionary]:
	var origin: Vector2 = _overlay_origin()
	var laid_out: Array[Dictionary] = []
	var row_index: int = 0
	for row: Dictionary in _overlay_rows():
		var laid: Dictionary = row.duplicate()
		laid["rect"] = _overlay_row_rect(origin, row_index)
		laid_out.append(laid)
		row_index += 1
	return laid_out


func _rebuild_roster_hits() -> void:
	_roster_hits.clear()
	for row: Dictionary in _overlay_layout():
		var kind: String = str(row.get("kind", ""))
		if kind != "participant" and kind != "vehicle":
			continue
		_roster_hits.append({
			"kind": kind,
			"id": str(row.get("id", "")),
			"rect": row.get("rect", Rect2()),
		})


func set_presentation_camera_enabled(enabled: bool) -> void:
	_ensure_camera()
	if _camera == null:
		return
	_camera.enabled = enabled
	if enabled:
		_frame_camera()
		_camera.make_current()


func _process(_delta: float) -> void:
	if not visible:
		return
	queue_redraw()


func _draw() -> void:
	_draw_background()
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		_draw_overlay()
		return
	_draw_battlefield(battle_state)
	_draw_deployment_zones(battle_state)
	_draw_obstacles(battle_state)
	_draw_cover(battle_state)
	_draw_vehicles(battle_state)
	_draw_participants(battle_state)
	_draw_overlay()


func _battle_state() -> BattleState:
	if session == null:
		return null
	return session.battle_state


func _geometry() -> BattlefieldGeometry:
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		return null
	return battle_state.battlefield_geometry


func _to_view(tactical_pos: Vector2) -> Vector2:
	return tactical_pos * TACTICAL_PIXELS_PER_UNIT


func _rect_to_view(tactical_rect: Rect2) -> Rect2:
	return Rect2(_to_view(tactical_rect.position), tactical_rect.size * TACTICAL_PIXELS_PER_UNIT)


func _ensure_camera() -> void:
	if _camera != null:
		return
	_camera = get_node_or_null("Camera2D") as Camera2D


func _frame_camera() -> void:
	_ensure_camera()
	if _camera == null:
		return
	var geometry: BattlefieldGeometry = _geometry()
	var bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(1.0, 1.0))
	if geometry != null and geometry.width > 0.0 and geometry.height > 0.0:
		bounds = geometry.bounds()
	var view_rect: Rect2 = _rect_to_view(bounds)
	view_rect = view_rect.grow(CAMERA_PADDING)
	_camera.position = view_rect.get_center()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		viewport_size = Vector2(1152.0, 648.0)
	var zoom_x: float = viewport_size.x / maxf(view_rect.size.x, 1.0)
	var zoom_y: float = viewport_size.y / maxf(view_rect.size.y, 1.0)
	var zoom: float = clampf(minf(zoom_x, zoom_y), 0.2, 2.5)
	_camera.zoom = Vector2(zoom, zoom)


func _draw_background() -> void:
	var origin: Vector2 = Vector2(-4000.0, -4000.0)
	draw_rect(Rect2(origin, Vector2(8000.0, 8000.0)), PROVISIONAL_BACKGROUND, true)


func _draw_battlefield(battle_state: BattleState) -> void:
	var field_rect: Rect2 = _authoritative_bounds(battle_state)
	if field_rect.size.x <= 0.0 or field_rect.size.y <= 0.0:
		return
	var view_rect: Rect2 = _rect_to_view(field_rect)
	draw_rect(view_rect, PROVISIONAL_FIELD, true)
	draw_rect(view_rect, PROVISIONAL_BOUNDS, false, 2.0)


func _draw_deployment_zones(battle_state: BattleState) -> void:
	var attacker_rect: Rect2 = _attacker_deployment_rect(battle_state)
	var defender_rect: Rect2 = _defender_deployment_rect(battle_state)
	if attacker_rect.size.x > 0.0 and attacker_rect.size.y > 0.0:
		var attacker_view: Rect2 = _rect_to_view(attacker_rect)
		draw_rect(attacker_view, PROVISIONAL_ATTACKER_ZONE, true)
		draw_rect(attacker_view, PROVISIONAL_ATTACKER_ZONE_LINE, false, 2.0)
		_draw_label_left(
			attacker_view.position + Vector2(6.0, 16.0),
			"ATTACKER DEPLOYMENT",
			12,
			PROVISIONAL_ATTACKER_ZONE_LINE
		)
	if defender_rect.size.x > 0.0 and defender_rect.size.y > 0.0:
		var defender_view: Rect2 = _rect_to_view(defender_rect)
		draw_rect(defender_view, PROVISIONAL_DEFENDER_ZONE, true)
		draw_rect(defender_view, PROVISIONAL_DEFENDER_ZONE_LINE, false, 2.0)
		_draw_label_left(
			defender_view.position + Vector2(6.0, 16.0),
			"DEFENDER DEPLOYMENT",
			12,
			PROVISIONAL_DEFENDER_ZONE_LINE
		)


func _draw_obstacles(battle_state: BattleState) -> void:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.bounds_are_usable():
			continue
		var view_rect: Rect2 = _rect_to_view(obstacle.bounds)
		var fill: Color = PROVISIONAL_OBSTACLE_BOTH
		var line: Color = PROVISIONAL_BOUNDS
		if obstacle.blocks_movement and not obstacle.blocks_line_of_sight:
			fill = PROVISIONAL_OBSTACLE_MOVE
			line = PROVISIONAL_MOVE_LINE
		elif obstacle.blocks_line_of_sight and not obstacle.blocks_movement:
			fill = PROVISIONAL_OBSTACLE_LOS
			line = PROVISIONAL_LOS_LINE
		elif obstacle.blocks_movement and obstacle.blocks_line_of_sight:
			fill = PROVISIONAL_OBSTACLE_BOTH
			line = PROVISIONAL_LOS_LINE
		draw_rect(view_rect, fill, true)
		draw_rect(view_rect, line, false, 1.5)


func _draw_cover(battle_state: BattleState) -> void:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	for cover_object_id: String in geometry.get_sorted_cover_object_ids():
		var cover_object: BattleCoverObject = geometry.get_cover_object(cover_object_id)
		if cover_object == null:
			continue
		var centroid: Vector2 = _cover_object_centroid(geometry, cover_object)
		if centroid.x >= 0.0:
			var object_view: Vector2 = _to_view(centroid)
			var marker: Rect2 = Rect2(object_view - Vector2(4.0, 4.0), Vector2(8.0, 8.0))
			draw_rect(marker, PROVISIONAL_COVER, false, 1.0)
	for cover_slot_id: String in geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = geometry.get_cover_slot(cover_slot_id)
		if slot == null:
			continue
		var slot_view: Vector2 = _to_view(slot.position)
		draw_circle(slot_view, COVER_SLOT_RADIUS, PROVISIONAL_COVER, false, 1.5, true)
		_draw_label(slot_view + Vector2(0.0, COVER_SLOT_RADIUS + 10.0), slot.cover_slot_id, 10)


func _draw_participants(battle_state: BattleState) -> void:
	for participant_id: String in _sorted_keys(battle_state.participants):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			continue
		var view_pos: Vector2 = _to_view(participant.battle_position)
		var fill: Color = _side_fill(battle_state, participant.side_id)
		if participant.is_wounded and participant.is_alive:
			fill = PROVISIONAL_WOUNDED
		if not participant.is_alive:
			draw_circle(view_pos, PARTICIPANT_RADIUS, PROVISIONAL_DEAD, false, 2.0, true)
		else:
			draw_circle(view_pos, PARTICIPANT_RADIUS, fill, true)
			draw_circle(view_pos, PARTICIPANT_RADIUS, Color(0.08, 0.08, 0.09, 1.0), false, 1.5, true)
		if _selected_participant_id() == participant.participant_id:
			draw_circle(view_pos, PARTICIPANT_RADIUS + 4.0, PROVISIONAL_SELECTABLE, false, 2.0, true)
		var weapon_abbrev: String = _weapon_abbrev(participant.weapon_type)
		_draw_label(view_pos + Vector2(0.0, -PARTICIPANT_RADIUS - 12.0), participant.participant_id, 11)
		if not weapon_abbrev.is_empty():
			_draw_label(view_pos + Vector2(0.0, PARTICIPANT_RADIUS + 12.0), weapon_abbrev, 10)


func _draw_vehicles(battle_state: BattleState) -> void:
	for vehicle_id: String in _sorted_keys(battle_state.vehicles):
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			continue
		var view_pos: Vector2 = _to_view(vehicle.battle_position)
		var fill: Color = _side_fill(battle_state, vehicle.side_id)
		var rect: Rect2 = Rect2(view_pos - VEHICLE_SIZE * 0.5, VEHICLE_SIZE)
		draw_rect(rect, fill, true)
		draw_rect(rect, Color(0.08, 0.08, 0.09, 1.0), false, 1.5)
		_draw_label(view_pos + Vector2(0.0, -VEHICLE_SIZE.y * 0.5 - 12.0), vehicle.battle_vehicle_id, 11)


func _draw_overlay() -> void:
	_roster_hits.clear()
	var selected_id: String = _selected_participant_id()
	for row: Dictionary in _overlay_layout():
		var text: String = str(row.get("text", ""))
		var kind: String = str(row.get("kind", ""))
		var row_id: String = str(row.get("id", ""))
		var row_rect: Rect2 = row.get("rect", Rect2())
		if kind == "participant" or kind == "vehicle":
			_roster_hits.append({
				"kind": kind,
				"id": row_id,
				"rect": row_rect,
			})
		if kind == "participant" and row_id == selected_id and not selected_id.is_empty():
			draw_rect(row_rect, PROVISIONAL_SELECTED, true)
		var color: Color = PROVISIONAL_OVERLAY
		if kind == "status":
			color = PROVISIONAL_STATUS
		elif kind == "participant" and bool(row.get("selectable", false)):
			color = PROVISIONAL_SELECTABLE
		_draw_overlay_row_label(row_rect, text, ROSTER_FONT_SIZE, color)


func _overlay_lines() -> Array[String]:
	var lines: Array[String] = []
	for row: Dictionary in _overlay_rows():
		lines.append(str(row.get("text", "")))
	return lines


func _overlay_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var battle_state: BattleState = _battle_state()
	if session == null or battle_state == null:
		rows.append(_overlay_row("tactical view: no session"))
		return rows
	var deployed_participants: int = 0
	var undeployed_participants: int = 0
	var deployed_vehicles: int = 0
	var undeployed_vehicles: int = 0
	for participant_id: String in _sorted_keys(battle_state.participants):
		if battle_state.is_participant_deployed(participant_id):
			deployed_participants += 1
		else:
			undeployed_participants += 1
	for vehicle_id: String in _sorted_keys(battle_state.vehicles):
		if battle_state.is_vehicle_deployed(vehicle_id):
			deployed_vehicles += 1
		else:
			undeployed_vehicles += 1
	rows.append(_overlay_row("type=%s  mission=%s" % [battle_state.battle_type_id, battle_state.mission_id]))
	rows.append(_overlay_row("phase=%s  session=%s" % [battle_state.battle_phase, session.session_state]))
	rows.append(
		_overlay_row(
			"attacker_side=%s  defender_side=%s"
			% [battle_state.attacker_side_id, battle_state.defender_side_id]
		)
	)
	rows.append(
		_overlay_row(
			"participants deployed=%s undeployed=%s  vehicles deployed=%s undeployed=%s"
			% [deployed_participants, undeployed_participants, deployed_vehicles, undeployed_vehicles]
		)
	)
	var attacker_committed: bool = battle_state.is_side_deployment_committed(battle_state.attacker_side_id)
	var defender_committed: bool = battle_state.is_side_deployment_committed(battle_state.defender_side_id)
	var deploy_subrole: String = ""
	var defender_posture: String = ""
	if deployment_controller != null:
		deploy_subrole = deployment_controller.subrole
		defender_posture = deployment_controller.last_defender_ai_posture
	rows.append(
		_overlay_row(
			"deploy_subrole=%s  attacker_committed=%s  defender_committed=%s"
			% [deploy_subrole, attacker_committed, defender_committed]
		)
	)
	if not attacker_committed:
		rows.append(_overlay_row("attacker placement active; C commits when all living attackers are placed"))
	elif not defender_committed:
		var fail_code: String = ""
		if deployment_controller != null:
			fail_code = deployment_controller.last_defender_ai_error
		if fail_code.is_empty():
			rows.append(_overlay_row("attacker committed; defender AI pending"))
		else:
			rows.append(_overlay_row("attacker committed; defender AI failed (%s)" % fail_code))
	else:
		rows.append(
			_overlay_row(
				"attacker committed; defender AI deployed; defender committed; deployment complete / battle waiting to start"
			)
		)
		if not defender_posture.is_empty():
			rows.append(_overlay_row("defender posture=%s" % defender_posture))
		for participant_id: String in _sorted_keys(battle_state.participants):
			var placed: BattleParticipant = battle_state.get_participant(participant_id)
			if placed == null or placed.side_id != battle_state.defender_side_id:
				continue
			if not placed.is_alive or not placed.has_battle_position:
				continue
			rows.append(
				_overlay_row(
					"defender AI pos %s=(%.2f, %.2f)"
					% [placed.participant_id, placed.battle_position.x, placed.battle_position.y]
				)
			)
	rows.append(_overlay_row("ROSTER"))
	for participant_id: String in _sorted_keys(battle_state.participants):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		var selectable: bool = _is_roster_selectable(battle_state, participant)
		var prefix: String = "  P"
		if selectable:
			prefix = "> P"
		rows.append(
			{
				"text": "%s %s  %s  %s  %s" % [
					prefix,
					participant.participant_id,
					_side_label(battle_state, participant.side_id),
					participant.weapon_type,
					_deployed_label(battle_state.is_participant_deployed(participant_id)),
				],
				"kind": "participant",
				"id": participant.participant_id,
				"selectable": selectable,
			}
		)
	for vehicle_id: String in _sorted_keys(battle_state.vehicles):
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null:
			continue
		rows.append(
			{
				"text": "  V %s  %s  %s  %s  (placement unavailable)" % [
					vehicle.battle_vehicle_id,
					_side_label(battle_state, vehicle.side_id),
					vehicle.vehicle_type_id,
					_deployed_label(battle_state.is_vehicle_deployed(vehicle_id)),
				],
				"kind": "vehicle",
				"id": vehicle.battle_vehicle_id,
				"selectable": false,
			}
		)
	if battle_state.participants.is_empty() and battle_state.vehicles.is_empty():
		rows.append(_overlay_row("  (none)"))
	var status: String = _status_text()
	if not status.is_empty():
		rows.append(
			{
				"text": status,
				"kind": "status",
				"id": "",
				"selectable": false,
			}
		)
	return rows


func _overlay_row(text: String) -> Dictionary:
	return {
		"text": text,
		"kind": "",
		"id": "",
		"selectable": false,
	}


func _selected_participant_id() -> String:
	if deployment_controller == null:
		return ""
	return deployment_controller.selected_participant_id


func _status_text() -> String:
	if deployment_controller == null:
		return ""
	return deployment_controller.status_text


func _is_roster_selectable(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if battle_state == null or participant == null:
		return false
	if battle_state.is_side_deployment_committed(battle_state.attacker_side_id):
		return false
	if participant.side_id != battle_state.attacker_side_id:
		return false
	if not participant.is_alive:
		return false
	if battle_state.is_participant_deployed(participant.participant_id):
		return false
	if participant.has_battle_position:
		return false
	return true


func _authoritative_bounds(battle_state: BattleState) -> Rect2:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry != null and geometry.width > 0.0 and geometry.height > 0.0:
		return geometry.bounds()
	return Rect2()


func _attacker_deployment_rect(battle_state: BattleState) -> Rect2:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry != null and BattlefieldGeometry.rect_is_usable(geometry.attacker_deployment_rect):
		return geometry.attacker_deployment_rect
	return _zone_rect_for_side(battle_state, battle_state.attacker_side_id)


func _defender_deployment_rect(battle_state: BattleState) -> Rect2:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry != null and BattlefieldGeometry.rect_is_usable(geometry.defender_deployment_rect):
		return geometry.defender_deployment_rect
	return _zone_rect_for_side(battle_state, battle_state.defender_side_id)


func _zone_rect_for_side(battle_state: BattleState, side_id: String) -> Rect2:
	if side_id.is_empty() or not battle_state.has_side(side_id):
		return Rect2()
	var side: BattleSide = battle_state.get_side(side_id)
	if side == null or side.deployment_zone_id.is_empty():
		return Rect2()
	var zone: DeploymentZone = battle_state.get_deployment_zone(side.deployment_zone_id)
	if zone == null:
		return Rect2()
	return zone.deployment_rect


func _cover_object_centroid(geometry: BattlefieldGeometry, cover_object: BattleCoverObject) -> Vector2:
	if cover_object == null or cover_object.slot_ids.is_empty():
		return Vector2(-1.0, -1.0)
	var sum: Vector2 = Vector2.ZERO
	var count: int = 0
	var slot_ids: Array[String] = []
	for slot_id: String in cover_object.slot_ids:
		slot_ids.append(slot_id)
	slot_ids.sort()
	for slot_id: String in slot_ids:
		var slot: BattleCoverSlot = geometry.get_cover_slot(slot_id)
		if slot == null:
			continue
		sum += slot.position
		count += 1
	if count <= 0:
		return Vector2(-1.0, -1.0)
	return sum / float(count)


func _side_fill(battle_state: BattleState, side_id: String) -> Color:
	if side_id == battle_state.attacker_side_id:
		return PROVISIONAL_ATTACKER
	if side_id == battle_state.defender_side_id:
		return PROVISIONAL_DEFENDER
	return Color(0.72, 0.72, 0.72, 1.0)


func _side_label(battle_state: BattleState, side_id: String) -> String:
	if side_id == battle_state.attacker_side_id:
		return "ATT"
	if side_id == battle_state.defender_side_id:
		return "DEF"
	return side_id


func _deployed_label(deployed: bool) -> String:
	if deployed:
		return "deployed"
	return "undeployed"


func _weapon_abbrev(weapon_type: String) -> String:
	match weapon_type:
		"pistol":
			return "PST"
		"shotgun":
			return "SHG"
		"smg":
			return "SMG"
		"rifle":
			return "RFL"
		"sniper":
			return "SNP"
		_:
			if weapon_type.length() <= 3:
				return weapon_type.to_upper()
			return weapon_type.substr(0, 3).to_upper()


func _draw_label(center: Vector2, text: String, font_size: int = 14) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var pos: Vector2 = center - Vector2(size.x * 0.5, 0.0)
	draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL_SHADOW)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL)


func _draw_label_left(pos: Vector2, text: String, font_size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL_SHADOW)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_overlay_row_label(row_rect: Rect2, text: String, font_size: int, color: Color) -> void:
	# draw_string origin is the text baseline, not the row-rect top-left.
	var font: Font = ThemeDB.fallback_font
	var ascent: float = font.get_ascent(font_size)
	var descent: float = font.get_descent(font_size)
	var baseline_y: float = row_rect.position.y + (row_rect.size.y - ascent - descent) * 0.5 + ascent
	var pos: Vector2 = Vector2(row_rect.position.x, baseline_y)
	draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL_SHADOW)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _overlay_origin() -> Vector2:
	_ensure_camera()
	if _camera == null:
		return Vector2(16.0, 24.0)
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		viewport_size = Vector2(1152.0, 648.0)
	var half: Vector2 = (viewport_size / _camera.zoom) * 0.5
	return _camera.position - half + Vector2(16.0, 28.0)


func _sorted_keys(collection: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in collection:
		ids.append(str(key))
	ids.sort()
	return ids
