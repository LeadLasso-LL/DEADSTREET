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
const BattleSurfaceRegion := preload("res://battle/geometry/battle_surface_region.gd")
const BattlePresentationMarking := preload("res://battle/geometry/battle_presentation_marking.gd")
const BattleDeploymentArea := preload("res://battle/geometry/battle_deployment_area.gd")
const BattleDeploymentPocket := preload("res://battle/geometry/battle_deployment_pocket.gd")
const TacticalDeploymentController := preload("res://gameplay/tactical_deployment_controller.gd")
const BattleVehicleBodyService := preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")
const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")
const BattleVictoryResult := preload("res://battle/core/battle_victory_result.gd")
const BattleCombatPresentationQuery := preload("res://battle/combat/battle_combat_presentation_query.gd")
const TacticalStaticBattlefieldLayer := preload("res://gameplay/tactical_static_battlefield_layer.gd")
const TacticalDynamicBattlefieldLayer := preload("res://gameplay/tactical_dynamic_battlefield_layer.gd")
const TacticalShotPresentation := preload("res://gameplay/tactical_shot_presentation.gd")

const TACTICAL_PIXELS_PER_UNIT := 8.0
# Edge padding around the playable field. HUD uses a separate left gutter.
const CAMERA_EDGE_PADDING := 40.0
# Visual-only city continuation beyond authoritative bounds. Not playable.
const SURROUND_EXTENT_UNITS := 36.0
const PROP_VISUAL_GROW := 2.5
const PROP_SHADOW_OFFSET := Vector2(1.6, 1.6)
const PARTICIPANT_RADIUS := 7.0
const SOLDIER_GROUND_RADIUS := 6.2
const SOLDIER_SELECTION_RADIUS := 13.0
const SOLDIER_HEAD_RADIUS := 2.7
const SOLDIER_HAND_FORWARD := 3.6
# Presentation-only body scale. Does not change collision, nav, or hit model.
const SOLDIER_VISUAL_SCALE := 1.12
const COVER_SLOT_RADIUS := 3.5
const ROSTER_ROW_HEIGHT := 16.0
const ROSTER_ROW_WIDTH := 520.0
const ROSTER_FONT_SIZE := 13
const ROSTER_CAMERA_GUTTER_PAD := 24.0
const VEHICLE_OUTLINE_WIDTH := 3.5
const VEHICLE_FRONT_MARK := 6.0
const SHOT_FEEDBACK_SECONDS := 0.45
const IMPACT_RADIUS := 1.6
const COMPACT_STATE_FONT_SIZE := 8

# Provisional visualization tints. Not Dead Street art direction or faction language.
const PROVISIONAL_BACKGROUND := Color(0.14, 0.13, 0.12, 1.0)
const PROVISIONAL_SURROUND := Color(0.16, 0.145, 0.13, 1.0)
const PROVISIONAL_SURROUND_BLOCK := Color(0.19, 0.17, 0.15, 1.0)
const PROVISIONAL_SURROUND_PARCEL := Color(0.15, 0.14, 0.13, 1.0)
const PROVISIONAL_SURROUND_STUB := Color(0.13, 0.13, 0.135, 0.42)
const PROVISIONAL_FIELD := Color(0.21, 0.18, 0.16, 1.0)
const PROVISIONAL_ASPHALT := Color(0.10, 0.10, 0.11, 1.0)
const PROVISIONAL_ASPHALT_INTERSECTION := Color(0.15, 0.15, 0.155, 1.0)
const PROVISIONAL_SIDEWALK := Color(0.50, 0.47, 0.42, 1.0)
const PROVISIONAL_LOT := Color(0.28, 0.24, 0.20, 1.0)
const PROVISIONAL_ALLEY := Color(0.15, 0.135, 0.125, 1.0)
const PROVISIONAL_CURB := Color(0.62, 0.58, 0.50, 1.0)
const PROVISIONAL_CURB_EDGE := Color(0.16, 0.14, 0.12, 0.95)
const PROVISIONAL_APRON := Color(0.42, 0.37, 0.31, 1.0)
const PROVISIONAL_LANE := Color(0.78, 0.70, 0.40, 0.58)
const PROVISIONAL_PARKING := Color(0.84, 0.84, 0.78, 0.28)
const PROVISIONAL_LOADING := Color(0.74, 0.42, 0.16, 0.55)
const PROVISIONAL_SEAM := Color(0.20, 0.18, 0.16, 0.62)
const PROVISIONAL_BOLLARD := Color(0.20, 0.18, 0.16, 1.0)
const PROVISIONAL_UTILITY := Color(0.32, 0.34, 0.32, 1.0)
const PROVISIONAL_BUILDING := Color(0.27, 0.23, 0.21, 1.0)
const PROVISIONAL_BUILDING_HQ := Color(0.40, 0.22, 0.20, 1.0)
const PROVISIONAL_BUILDING_WAREHOUSE := Color(0.25, 0.24, 0.23, 1.0)
const PROVISIONAL_BUILDING_SHOP_A := Color(0.34, 0.23, 0.20, 1.0)
const PROVISIONAL_BUILDING_SHOP_B := Color(0.30, 0.22, 0.18, 1.0)
const PROVISIONAL_BUILDING_ROOF := Color(0.16, 0.145, 0.135, 1.0)
const PROVISIONAL_BUILDING_ROOF_HQ := Color(0.18, 0.12, 0.12, 1.0)
const PROVISIONAL_BUILDING_LINE := Color(0.07, 0.055, 0.05, 1.0)
const PROVISIONAL_BUILDING_ACCENT := Color(0.36, 0.13, 0.13, 1.0)
const PROVISIONAL_AWNING := Color(0.26, 0.16, 0.14, 1.0)
const PROVISIONAL_WINDOW := Color(0.11, 0.13, 0.15, 0.90)
const PROVISIONAL_DOOR := Color(0.14, 0.10, 0.09, 1.0)
const PROVISIONAL_FENCE := Color(0.38, 0.37, 0.34, 0.92)
const PROVISIONAL_PARKED_CAR := Color(0.28, 0.36, 0.44, 1.0)
const PROVISIONAL_PARKED_CAR_CABIN := Color(0.10, 0.13, 0.16, 1.0)
const PROVISIONAL_DUMPSTER := Color(0.20, 0.38, 0.24, 1.0)
const PROVISIONAL_CRATE := Color(0.46, 0.34, 0.20, 1.0)
const PROVISIONAL_LOW_WALL := Color(0.50, 0.47, 0.42, 1.0)
const PROVISIONAL_BARRIER := Color(0.58, 0.42, 0.28, 1.0)
const PROVISIONAL_PROP_SHADOW := Color(0.04, 0.03, 0.03, 0.42)
const PROVISIONAL_PROP_OUTLINE := Color(0.05, 0.04, 0.04, 1.0)
const PROVISIONAL_BOUNDS := Color(0.50, 0.46, 0.40, 0.88)
const PROVISIONAL_ATTACKER_ZONE := Color(0.28, 0.48, 0.72, 0.07)
const PROVISIONAL_ATTACKER_ZONE_LINE := Color(0.52, 0.74, 0.92, 0.55)
const PROVISIONAL_DEFENDER_ZONE := Color(0.72, 0.42, 0.24, 0.07)
const PROVISIONAL_DEFENDER_ZONE_LINE := Color(0.90, 0.66, 0.44, 0.55)
const PROVISIONAL_ATTACKER := Color(0.42, 0.70, 0.92, 1.0)
const PROVISIONAL_DEFENDER := Color(0.86, 0.64, 0.40, 1.0)
const PROVISIONAL_DEAD := Color(0.42, 0.42, 0.44, 1.0)
const PROVISIONAL_WOUNDED := Color(0.90, 0.78, 0.36, 1.0)
const PROVISIONAL_SOLDIER_BODY := Color(0.40, 0.36, 0.30, 1.0)
const PROVISIONAL_SOLDIER_BODY_WOUNDED := Color(0.28, 0.22, 0.18, 1.0)
const PROVISIONAL_SOLDIER_BODY_DEAD := Color(0.36, 0.34, 0.32, 1.0)
const PROVISIONAL_SOLDIER_HEAD := Color(0.46, 0.38, 0.32, 1.0)
const PROVISIONAL_SOLDIER_HEAD_DEAD := Color(0.40, 0.36, 0.33, 1.0)
const PROVISIONAL_SOLDIER_OUTLINE := Color(0.04, 0.03, 0.03, 1.0)
const PROVISIONAL_SOLDIER_WEAPON := Color(0.09, 0.09, 0.10, 1.0)
const PROVISIONAL_SOLDIER_WEAPON_STOCK := Color(0.16, 0.12, 0.09, 1.0)
const PROVISIONAL_INJURY_MARK := Color(0.70, 0.22, 0.16, 1.0)
const PROVISIONAL_COMPACT_STATE := Color(0.86, 0.84, 0.78, 0.92)
const PROVISIONAL_COMPACT_WND := Color(0.90, 0.74, 0.38, 0.94)
const PROVISIONAL_COMPACT_WAIT := Color(0.78, 0.82, 0.88, 0.92)
const PROVISIONAL_ATTACKER_ACCENT := Color(0.38, 0.58, 0.74, 1.0)
const PROVISIONAL_DEFENDER_ACCENT := Color(0.74, 0.48, 0.28, 1.0)
const PROVISIONAL_ATTACKER_FOOT := Color(0.28, 0.44, 0.58, 0.50)
const PROVISIONAL_DEFENDER_FOOT := Color(0.58, 0.38, 0.24, 0.50)
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
# Vehicle chrome is presentation only. Physical length/width stay on the catalog.
# Fill/outline follow the authoritative body; they must not read as a larger collider.
const PROVISIONAL_VEHICLE_FILL := Color(0.90, 0.74, 0.20, 1.0)
const PROVISIONAL_VEHICLE_CABIN := Color(0.16, 0.14, 0.10, 1.0)
const PROVISIONAL_VEHICLE_GLASS := Color(0.32, 0.40, 0.46, 0.88)
const PROVISIONAL_VEHICLE_OUTLINE := Color(0.08, 0.07, 0.05, 1.0)
const PROVISIONAL_VEHICLE_FACING := Color(0.08, 0.07, 0.05, 1.0)
const PROVISIONAL_MUZZLE := Color(1.0, 0.96, 0.72, 1.0)
const PROVISIONAL_MUZZLE_CORE := Color(1.0, 1.0, 0.94, 1.0)
const PROVISIONAL_PROJECTILE := Color(0.96, 0.96, 0.94, 1.0)
const PROVISIONAL_PROJECTILE_TAIL := Color(0.88, 0.88, 0.86, 1.0)
const PROVISIONAL_GRAZE_IMPACT := Color(0.95, 0.82, 0.38, 1.0)
const PROVISIONAL_HIT_IMPACT := Color(0.95, 0.58, 0.22, 1.0)
const PROVISIONAL_WOUND_IMPACT := Color(0.92, 0.38, 0.22, 1.0)
const PROVISIONAL_KILL_MARK := Color(0.92, 0.16, 0.14, 1.0)
const PROVISIONAL_RESULT := Color(0.98, 0.92, 0.42, 1.0)

# Reference only. This view never stores an independent BattleState.
var session: CampaignBattleSession = null
var deployment_controller: TacticalDeploymentController = null

var _camera: Camera2D = null
var _roster_hits: Array[Dictionary] = []
# Cached static presentation geometry — rebuilt only when battlefield definition changes.
var _cached_blocker_polys: Array[PackedVector2Array] = []
var _cached_attacker_clipped: Array[PackedVector2Array] = []
var _cached_defender_clipped: Array[PackedVector2Array] = []
var _cached_sorted_surfaces: Array = []
var _deployment_cache_valid: bool = false
var _surface_cache_valid: bool = false
var static_layer: TacticalStaticBattlefieldLayer = null
var dynamic_layer: TacticalDynamicBattlefieldLayer = null
var static_redraw_requests: int = 0
var dynamic_redraw_requests: int = 0
var _cached_static_stamp: String = ""
var _paint: CanvasItem = null


func _ready() -> void:
	_ensure_layers()
	_ensure_camera()
	if _camera != null:
		_camera.enabled = false


func bind_session(p_session: CampaignBattleSession) -> void:
	var session_changed: bool = session != p_session
	session = p_session
	_ensure_layers()
	_ensure_camera()
	_frame_camera()
	var stamp: String = _static_geometry_stamp()
	var stamp_changed: bool = stamp != _cached_static_stamp
	if session_changed or stamp_changed:
		_invalidate_presentation_caches()
		_cached_static_stamp = stamp
		request_static_redraw()
	request_dynamic_redraw()


func bind_deployment_controller(p_controller: TacticalDeploymentController) -> void:
	var controller_changed: bool = deployment_controller != p_controller
	deployment_controller = p_controller
	if controller_changed:
		request_dynamic_redraw()


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


func hit_test_placed_attacker_soldier(local_position: Vector2) -> String:
	var battle_state: BattleState = _battle_state()
	if battle_state == null or battle_state.battle_phase != "deployment":
		return ""
	if battle_state.is_side_deployment_committed(battle_state.attacker_side_id):
		return ""
	var pick_radius: float = SOLDIER_SELECTION_RADIUS * SOLDIER_VISUAL_SCALE
	var best_id: String = ""
	var best_distance: float = INF
	for participant_id: String in _sorted_keys(battle_state.participants):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		if participant.side_id != battle_state.attacker_side_id:
			continue
		if not participant.is_alive or not participant.has_battle_position:
			continue
		if not battle_state.is_participant_deployed(participant_id):
			continue
		var view_pos: Vector2 = _to_view(participant.battle_position)
		var distance: float = view_pos.distance_to(local_position)
		if not is_finite(distance):
			continue
		if distance > pick_radius and not is_equal_approx(distance, pick_radius):
			continue
		if best_id.is_empty() or distance < best_distance or (
			is_equal_approx(distance, best_distance) and participant_id < best_id
		):
			best_id = participant_id
			best_distance = distance
	return best_id


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
	var stamp: String = _static_geometry_stamp()
	if stamp != _cached_static_stamp:
		_cached_static_stamp = stamp
		_invalidate_presentation_caches()
		request_static_redraw()
	request_dynamic_redraw()


func _draw() -> void:
	# Static and dynamic presentation live on child CanvasItems.
	pass


func paint_static_battlefield(canvas: CanvasItem) -> void:
	_paint = canvas
	_draw_background()
	var battle_state: BattleState = _battle_state()
	if battle_state != null:
		_draw_surround(battle_state)
		_draw_battlefield(battle_state)
		_draw_surfaces(battle_state)
		_draw_presentation_markings(battle_state)
		_draw_obstacles(battle_state)
		_draw_field_bounds(battle_state)
	_paint = null


func paint_dynamic_battlefield(canvas: CanvasItem) -> void:
	_paint = canvas
	var battle_state: BattleState = _battle_state()
	if battle_state == null:
		_draw_overlay()
		_paint = null
		return
	# Dynamic order: cover → vehicles → soldiers/weapons → muzzle/projectile/impact → overlay.
	_draw_deployment_zones(battle_state)
	_draw_cover(battle_state)
	_draw_vehicles(battle_state)
	_draw_participants(battle_state)
	_draw_combat_feedback(battle_state)
	_draw_overlay()
	_paint = null


func request_static_redraw() -> void:
	_ensure_layers()
	static_redraw_requests += 1
	if static_layer != null:
		static_layer.queue_redraw()


func request_dynamic_redraw() -> void:
	_ensure_layers()
	dynamic_redraw_requests += 1
	if dynamic_layer != null:
		dynamic_layer.queue_redraw()


func _paint_canvas() -> CanvasItem:
	if _paint != null:
		return _paint
	return self


func _ensure_layers() -> void:
	if static_layer == null:
		static_layer = TacticalStaticBattlefieldLayer.new()
		static_layer.name = "StaticBattlefieldLayer"
		static_layer.host = self
		static_layer.z_index = 0
		add_child(static_layer)
	if dynamic_layer == null:
		dynamic_layer = TacticalDynamicBattlefieldLayer.new()
		dynamic_layer.name = "DynamicBattlefieldLayer"
		dynamic_layer.host = self
		dynamic_layer.z_index = 1
		add_child(dynamic_layer)


func _static_geometry_stamp() -> String:
	var geometry: BattlefieldGeometry = _geometry()
	if geometry == null:
		return ""
	return "%s:%s" % [geometry.get_instance_id(), geometry.content_revision]


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
	var hud_gutter: float = _hud_left_gutter()
	view_rect.position.x -= hud_gutter
	view_rect.size.x += hud_gutter + CAMERA_EDGE_PADDING
	view_rect.position.y -= CAMERA_EDGE_PADDING
	view_rect.size.y += CAMERA_EDGE_PADDING * 2.0
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
	_paint_canvas().draw_rect(Rect2(origin, Vector2(8000.0, 8000.0)), PROVISIONAL_BACKGROUND, true)


func _draw_surround(battle_state: BattleState) -> void:
	var field_rect: Rect2 = _authoritative_bounds(battle_state)
	if field_rect.size.x <= 0.0 or field_rect.size.y <= 0.0:
		return
	var pad: float = SURROUND_EXTENT_UNITS
	var surround: Rect2 = field_rect.grow(pad)
	_paint_canvas().draw_rect(_rect_to_view(surround), PROVISIONAL_SURROUND, true)
	_draw_surround_parcels(field_rect, pad)
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	for region_id: String in geometry.get_sorted_surface_region_ids():
		var surface: BattleSurfaceRegion = geometry.get_surface_region(region_id)
		if surface == null or not surface.is_valid():
			continue
		if (
			surface.region_kind != BattleSurfaceRegion.KIND_ASPHALT
			and surface.region_kind != BattleSurfaceRegion.KIND_ALLEY
		):
			continue
		var fill: Color = PROVISIONAL_SURROUND_STUB
		if surface.region_kind == BattleSurfaceRegion.KIND_ALLEY:
			fill = Color(
				PROVISIONAL_ALLEY.r,
				PROVISIONAL_ALLEY.g,
				PROVISIONAL_ALLEY.b,
				0.38
			)
		for stub: Rect2 in _outside_stubs(surface.bounds, field_rect, pad):
			_paint_canvas().draw_rect(_rect_to_view(stub), fill, true)


func _draw_surround_parcels(field_rect: Rect2, pad: float) -> void:
	var parcels: Array[Rect2] = [
		Rect2(field_rect.position + Vector2(-pad + 2.0, -pad + 3.0), Vector2(18.0, 14.0)),
		Rect2(field_rect.position + Vector2(22.0, -pad + 2.0), Vector2(24.0, 11.0)),
		Rect2(field_rect.position + Vector2(58.0, -pad + 4.0), Vector2(20.0, 10.0)),
		Rect2(Vector2(field_rect.end.x + 3.0, field_rect.position.y + 4.0), Vector2(14.0, 16.0)),
		Rect2(Vector2(field_rect.end.x + 2.0, field_rect.position.y + 28.0), Vector2(16.0, 18.0)),
		Rect2(Vector2(field_rect.position.x - pad + 3.0, field_rect.position.y + 8.0), Vector2(15.0, 20.0)),
		Rect2(Vector2(field_rect.position.x + 8.0, field_rect.end.y + 3.0), Vector2(22.0, 12.0)),
		Rect2(Vector2(field_rect.position.x + 48.0, field_rect.end.y + 2.0), Vector2(28.0, 14.0)),
		Rect2(Vector2(field_rect.end.x - 18.0, field_rect.end.y + 4.0), Vector2(16.0, 11.0)),
	]
	var i: int = 0
	for parcel: Rect2 in parcels:
		var fill: Color = PROVISIONAL_SURROUND_PARCEL
		if i % 2 == 0:
			fill = PROVISIONAL_SURROUND_BLOCK
		_paint_canvas().draw_rect(_rect_to_view(parcel), fill, true)
		i += 1


func _outside_stubs(bounds: Rect2, field: Rect2, pad: float) -> Array[Rect2]:
	var stubs: Array[Rect2] = []
	var field_end: Vector2 = field.position + field.size
	var bounds_end: Vector2 = bounds.position + bounds.size
	if bounds.position.x <= field.position.x + 0.01:
		stubs.append(
			Rect2(
				Vector2(field.position.x - pad, bounds.position.y),
				Vector2(pad, bounds.size.y)
			)
		)
	if bounds_end.x >= field_end.x - 0.01:
		stubs.append(
			Rect2(Vector2(field_end.x, bounds.position.y), Vector2(pad, bounds.size.y))
		)
	if bounds.position.y <= field.position.y + 0.01:
		stubs.append(
			Rect2(
				Vector2(bounds.position.x, field.position.y - pad),
				Vector2(bounds.size.x, pad)
			)
		)
	if bounds_end.y >= field_end.y - 0.01:
		stubs.append(
			Rect2(Vector2(bounds.position.x, field_end.y), Vector2(bounds.size.x, pad))
		)
	return stubs


func _draw_battlefield(battle_state: BattleState) -> void:
	var field_rect: Rect2 = _authoritative_bounds(battle_state)
	if field_rect.size.x <= 0.0 or field_rect.size.y <= 0.0:
		return
	_paint_canvas().draw_rect(_rect_to_view(field_rect), PROVISIONAL_FIELD, true)


func _draw_field_bounds(battle_state: BattleState) -> void:
	var field_rect: Rect2 = _authoritative_bounds(battle_state)
	if field_rect.size.x <= 0.0 or field_rect.size.y <= 0.0:
		return
	_paint_canvas().draw_rect(_rect_to_view(field_rect), PROVISIONAL_BOUNDS, false, 2.0)


func _draw_surfaces(battle_state: BattleState) -> void:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	_ensure_surface_cache(geometry)
	for surface: BattleSurfaceRegion in _cached_sorted_surfaces:
		_paint_canvas().draw_rect(_rect_to_view(surface.bounds), _surface_fill(surface), true)
	for surface: BattleSurfaceRegion in _cached_sorted_surfaces:
		if surface.region_kind == BattleSurfaceRegion.KIND_CURB:
			_draw_curb_edge(surface.bounds)


func _draw_curb_edge(bounds: Rect2) -> void:
	var view_rect: Rect2 = _rect_to_view(bounds)
	_paint_canvas().draw_rect(view_rect, PROVISIONAL_CURB_EDGE, false, 1.6)
	var highlight: Rect2 = view_rect
	if view_rect.size.x >= view_rect.size.y:
		highlight.size.y = minf(1.4, view_rect.size.y)
	else:
		highlight.size.x = minf(1.4, view_rect.size.x)
	_paint_canvas().draw_rect(highlight, Color(0.72, 0.68, 0.60, 0.55), true)


func _surface_draw_less(a: BattleSurfaceRegion, b: BattleSurfaceRegion) -> bool:
	var la: int = _surface_layer(a)
	var lb: int = _surface_layer(b)
	if la != lb:
		return la < lb
	return a.region_id < b.region_id


func _surface_layer(surface: BattleSurfaceRegion) -> int:
	if surface == null:
		return 1
	match surface.region_kind:
		BattleSurfaceRegion.KIND_LOT:
			return 0
		BattleSurfaceRegion.KIND_ALLEY:
			return 1
		BattleSurfaceRegion.KIND_ASPHALT:
			return 2
		BattleSurfaceRegion.KIND_APRON:
			return 4
		BattleSurfaceRegion.KIND_SIDEWALK:
			return 5
		BattleSurfaceRegion.KIND_CURB:
			return 6
		_:
			return 1


func _surface_fill(surface: BattleSurfaceRegion) -> Color:
	if surface == null:
		return PROVISIONAL_LOT
	match surface.region_kind:
		BattleSurfaceRegion.KIND_ASPHALT:
			return PROVISIONAL_ASPHALT
		BattleSurfaceRegion.KIND_SIDEWALK:
			return PROVISIONAL_SIDEWALK
		BattleSurfaceRegion.KIND_ALLEY:
			return PROVISIONAL_ALLEY
		BattleSurfaceRegion.KIND_CURB:
			return PROVISIONAL_CURB
		BattleSurfaceRegion.KIND_APRON:
			return PROVISIONAL_APRON
		_:
			return PROVISIONAL_LOT


func _draw_presentation_markings(battle_state: BattleState) -> void:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	for marking: BattlePresentationMarking in geometry.presentation_markings:
		if marking == null or not marking.is_valid():
			continue
		var view_rect: Rect2 = _rect_to_view(marking.bounds)
		match marking.mark_kind:
			BattlePresentationMarking.KIND_LANE:
				_draw_dashed_band(view_rect, PROVISIONAL_LANE)
			BattlePresentationMarking.KIND_PARKING, BattlePresentationMarking.KIND_SEAM:
				var paint: Color = PROVISIONAL_PARKING
				if marking.mark_kind == BattlePresentationMarking.KIND_SEAM:
					paint = PROVISIONAL_SEAM
				_paint_canvas().draw_rect(view_rect, paint, true)
			BattlePresentationMarking.KIND_LOADING, BattlePresentationMarking.KIND_STOP_BAR:
				_paint_canvas().draw_rect(view_rect, PROVISIONAL_LOADING, true)
			BattlePresentationMarking.KIND_BOLLARD:
				_paint_canvas().draw_circle(view_rect.get_center(), maxf(view_rect.size.x, view_rect.size.y) * 0.55, PROVISIONAL_BOLLARD, true)
				_paint_canvas().draw_circle(
					view_rect.get_center(),
					maxf(view_rect.size.x, view_rect.size.y) * 0.55,
					Color(0.08, 0.07, 0.06, 1.0),
					false,
					1.0,
					true
				)
			BattlePresentationMarking.KIND_UTILITY:
				_paint_canvas().draw_rect(view_rect, PROVISIONAL_UTILITY, true)
				_paint_canvas().draw_rect(view_rect, Color(0.10, 0.10, 0.10, 1.0), false, 1.0)
			_:
				_paint_canvas().draw_rect(view_rect, PROVISIONAL_SEAM, true)


func _draw_dashed_band(view_rect: Rect2, color: Color) -> void:
	var along_x: bool = view_rect.size.x >= view_rect.size.y
	var dash: float = 10.0
	var gap: float = 8.0
	if along_x:
		var x: float = view_rect.position.x
		var y: float = view_rect.position.y
		var h: float = maxf(view_rect.size.y, 1.0)
		var end_x: float = view_rect.position.x + view_rect.size.x
		while x < end_x:
			var w: float = minf(dash, end_x - x)
			_paint_canvas().draw_rect(Rect2(Vector2(x, y), Vector2(w, h)), color, true)
			x += dash + gap
		return
	var x0: float = view_rect.position.x
	var y: float = view_rect.position.y
	var w: float = maxf(view_rect.size.x, 1.0)
	var end_y: float = view_rect.position.y + view_rect.size.y
	while y < end_y:
		var h: float = minf(dash, end_y - y)
		_paint_canvas().draw_rect(Rect2(Vector2(x0, y), Vector2(w, h)), color, true)
		y += dash + gap


func _invalidate_presentation_caches() -> void:
	_deployment_cache_valid = false
	_surface_cache_valid = false
	_cached_blocker_polys.clear()
	_cached_attacker_clipped.clear()
	_cached_defender_clipped.clear()
	_cached_sorted_surfaces.clear()


func _ensure_deployment_cache(geometry: BattlefieldGeometry) -> void:
	if _deployment_cache_valid:
		return
	_cached_blocker_polys.clear()
	_cached_attacker_clipped.clear()
	_cached_defender_clipped.clear()
	if geometry == null:
		_deployment_cache_valid = true
		return
	_cached_blocker_polys = _movement_blocking_view_polygons(geometry)
	_cached_attacker_clipped = _build_clipped_pocket_polys(geometry, true)
	_cached_defender_clipped = _build_clipped_pocket_polys(geometry, false)
	_deployment_cache_valid = true


func _build_clipped_pocket_polys(
	geometry: BattlefieldGeometry,
	for_attacker: bool
) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	var area: BattleDeploymentArea = null
	if for_attacker:
		area = geometry.attacker_deployment_area
	else:
		area = geometry.defender_deployment_area
	if area == null or not area.has_pockets():
		return result
	for pocket: BattleDeploymentPocket in area.get_sorted_pockets():
		if pocket == null or pocket.polygon.size() < 3:
			continue
		var view_poly: PackedVector2Array = PackedVector2Array()
		for point: Vector2 in pocket.polygon:
			view_poly.append(_to_view(point))
		var clipped: Array[PackedVector2Array] = _clip_view_polygon_against_blockers(
			view_poly,
			_cached_blocker_polys
		)
		for piece: PackedVector2Array in clipped:
			if piece.size() >= 3:
				result.append(piece)
	return result


func _ensure_surface_cache(geometry: BattlefieldGeometry) -> void:
	if _surface_cache_valid:
		return
	_cached_sorted_surfaces.clear()
	if geometry == null:
		_surface_cache_valid = true
		return
	var layered: Array[BattleSurfaceRegion] = []
	for region_id: String in geometry.get_sorted_surface_region_ids():
		var surface: BattleSurfaceRegion = geometry.get_surface_region(region_id)
		if surface == null or not surface.is_valid():
			continue
		layered.append(surface)
	layered.sort_custom(_surface_draw_less)
	_cached_sorted_surfaces = layered
	_surface_cache_valid = true


func _draw_deployment_zones(battle_state: BattleState) -> void:
	if battle_state.battle_phase != "deployment":
		return
	var attacker_committed: bool = battle_state.is_side_deployment_committed(battle_state.attacker_side_id)
	var defender_committed: bool = battle_state.is_side_deployment_committed(battle_state.defender_side_id)
	var fade: float = 1.0
	if attacker_committed and defender_committed:
		fade = 0.28
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	_draw_deployment_area(
		geometry,
		true,
		Color(
			PROVISIONAL_ATTACKER_ZONE.r,
			PROVISIONAL_ATTACKER_ZONE.g,
			PROVISIONAL_ATTACKER_ZONE.b,
			PROVISIONAL_ATTACKER_ZONE.a * fade
		),
		Color(
			PROVISIONAL_ATTACKER_ZONE_LINE.r,
			PROVISIONAL_ATTACKER_ZONE_LINE.g,
			PROVISIONAL_ATTACKER_ZONE_LINE.b,
			PROVISIONAL_ATTACKER_ZONE_LINE.a * fade
		),
		"ATTACKER",
		_attacker_deployment_rect(battle_state)
	)
	_draw_deployment_area(
		geometry,
		false,
		Color(
			PROVISIONAL_DEFENDER_ZONE.r,
			PROVISIONAL_DEFENDER_ZONE.g,
			PROVISIONAL_DEFENDER_ZONE.b,
			PROVISIONAL_DEFENDER_ZONE.a * fade
		),
		Color(
			PROVISIONAL_DEFENDER_ZONE_LINE.r,
			PROVISIONAL_DEFENDER_ZONE_LINE.g,
			PROVISIONAL_DEFENDER_ZONE_LINE.b,
			PROVISIONAL_DEFENDER_ZONE_LINE.a * fade
		),
		"DEFENDER",
		_defender_deployment_rect(battle_state)
	)


func _draw_deployment_area(
	geometry: BattlefieldGeometry,
	for_attacker: bool,
	fill: Color,
	line: Color,
	label: String,
	fallback_rect: Rect2
) -> void:
	_ensure_deployment_cache(geometry)
	var cached: Array[PackedVector2Array] = _cached_attacker_clipped if for_attacker else _cached_defender_clipped
	if cached.size() > 0:
		var first_label: bool = true
		for piece: PackedVector2Array in cached:
			if piece.size() < 3:
				continue
			_paint_canvas().draw_colored_polygon(piece, fill)
			var outline: PackedVector2Array = piece.duplicate()
			outline.append(piece[0])
			_paint_canvas().draw_polyline(outline, Color(line.r, line.g, line.b, minf(line.a + 0.10, 1.0)), 1.6, true)
			if first_label:
				var centroid: Vector2 = Vector2.ZERO
				for pt: Vector2 in piece:
					centroid += pt
				centroid /= float(piece.size())
				_draw_label(centroid + Vector2(0.0, -6.0), label, 10)
				first_label = false
		return
	if fallback_rect.size.x <= 0.0 or fallback_rect.size.y <= 0.0:
		return
	var view_rect: Rect2 = _rect_to_view(fallback_rect)
	_paint_canvas().draw_rect(view_rect, fill, true)
	_paint_canvas().draw_rect(view_rect, line, false, 2.0)
	_draw_label_left(view_rect.position + Vector2(6.0, 16.0), label + " DEPLOYMENT", 12, line)


func _movement_blocking_view_polygons(geometry: BattlefieldGeometry) -> Array[PackedVector2Array]:
	var blockers: Array[PackedVector2Array] = []
	if geometry == null:
		return blockers
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.blocks_movement or not obstacle.bounds_are_usable():
			continue
		var rect: Rect2 = _rect_to_view(obstacle.bounds)
		blockers.append(
			PackedVector2Array(
				[
					rect.position,
					Vector2(rect.end.x, rect.position.y),
					rect.end,
					Vector2(rect.position.x, rect.end.y),
				]
			)
		)
	return blockers


func _clip_view_polygon_against_blockers(
	view_poly: PackedVector2Array,
	blockers: Array[PackedVector2Array]
) -> Array[PackedVector2Array]:
	var remaining: Array[PackedVector2Array] = []
	remaining.append(view_poly)
	for blocker: PackedVector2Array in blockers:
		if blocker.size() < 3:
			continue
		var next_remaining: Array[PackedVector2Array] = []
		for piece: PackedVector2Array in remaining:
			if piece.size() < 3:
				continue
			var clipped: Array = Geometry2D.clip_polygons(piece, blocker)
			for clipped_piece: Variant in clipped:
				if clipped_piece is PackedVector2Array and (clipped_piece as PackedVector2Array).size() >= 3:
					next_remaining.append(clipped_piece as PackedVector2Array)
		remaining = next_remaining
	return remaining


func _draw_obstacles(battle_state: BattleState) -> void:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	for obstacle_id: String in geometry.get_sorted_obstacle_ids():
		var obstacle: BattleObstacle = geometry.get_obstacle(obstacle_id)
		if obstacle == null or not obstacle.bounds_are_usable():
			continue
		var view_rect: Rect2 = _rect_to_view(obstacle.bounds)
		if obstacle.presentation_kind == "building" or (
			obstacle.blocks_movement and obstacle.blocks_line_of_sight
		):
			_draw_building(obstacle)
			continue
		_draw_soft_cover_prop(obstacle, view_rect)


func _draw_soft_cover_prop(obstacle: BattleObstacle, view_rect: Rect2) -> void:
	match obstacle.presentation_kind:
		"parked_car":
			_draw_parked_car(view_rect)
		"dumpster":
			_draw_dumpster(view_rect)
		"crates":
			_draw_crates(view_rect)
		"low_wall":
			_draw_low_wall(view_rect)
		"barrier":
			_draw_barrier(view_rect)
		"fence":
			_draw_fence(view_rect)
		_:
			var fill: Color = PROVISIONAL_OBSTACLE_BOTH
			var line: Color = PROVISIONAL_BOUNDS
			if obstacle.blocks_movement and not obstacle.blocks_line_of_sight:
				fill = PROVISIONAL_OBSTACLE_MOVE
				line = PROVISIONAL_MOVE_LINE
			elif obstacle.blocks_line_of_sight and not obstacle.blocks_movement:
				fill = PROVISIONAL_OBSTACLE_LOS
				line = PROVISIONAL_LOS_LINE
			_paint_canvas().draw_rect(view_rect, fill, true)
			_paint_canvas().draw_rect(view_rect, line, false, 1.5)


func _draw_parked_car(view_rect: Rect2) -> void:
	var body: Rect2 = view_rect.grow(PROP_VISUAL_GROW)
	_draw_prop_shadow(body)
	_paint_canvas().draw_rect(body, PROVISIONAL_PARKED_CAR, true)
	var cabin: Rect2 = _inset_view_rect(body, 3.5, 2.4)
	if body.size.x >= body.size.y:
		cabin.position.x += body.size.x * 0.10
		cabin.size.x *= 0.58
	else:
		cabin.position.y += body.size.y * 0.10
		cabin.size.y *= 0.58
	_paint_canvas().draw_rect(cabin, PROVISIONAL_PARKED_CAR_CABIN, true)
	var glass: Rect2 = _inset_view_rect(cabin, 1.6, 1.3)
	_paint_canvas().draw_rect(glass, Color(0.42, 0.52, 0.58, 0.78), true)
	_paint_canvas().draw_rect(body, PROVISIONAL_PROP_OUTLINE, false, 2.6)
	_draw_wheel_marks(body)


func _draw_wheel_marks(view_rect: Rect2) -> void:
	var along_x: bool = view_rect.size.x >= view_rect.size.y
	var wheel: float = 3.0
	var inset: float = 2.4
	var rubber: Color = Color(0.06, 0.06, 0.07, 1.0)
	if along_x:
		var y0: float = view_rect.position.y + 0.5
		var y1: float = view_rect.end.y - 1.4
		var x0: float = view_rect.position.x + inset
		var x1: float = view_rect.end.x - inset - wheel
		_paint_canvas().draw_rect(Rect2(Vector2(x0, y0), Vector2(wheel, 1.3)), rubber, true)
		_paint_canvas().draw_rect(Rect2(Vector2(x1, y0), Vector2(wheel, 1.3)), rubber, true)
		_paint_canvas().draw_rect(Rect2(Vector2(x0, y1), Vector2(wheel, 1.3)), rubber, true)
		_paint_canvas().draw_rect(Rect2(Vector2(x1, y1), Vector2(wheel, 1.3)), rubber, true)
		return
	var x0: float = view_rect.position.x + 0.5
	var x1: float = view_rect.end.x - 1.4
	var y0: float = view_rect.position.y + inset
	var y1: float = view_rect.end.y - inset - wheel
	_paint_canvas().draw_rect(Rect2(Vector2(x0, y0), Vector2(1.3, wheel)), rubber, true)
	_paint_canvas().draw_rect(Rect2(Vector2(x0, y1), Vector2(1.3, wheel)), rubber, true)
	_paint_canvas().draw_rect(Rect2(Vector2(x1, y0), Vector2(1.3, wheel)), rubber, true)
	_paint_canvas().draw_rect(Rect2(Vector2(x1, y1), Vector2(1.3, wheel)), rubber, true)


func _draw_dumpster(view_rect: Rect2) -> void:
	var body: Rect2 = view_rect.grow(PROP_VISUAL_GROW)
	_draw_prop_shadow(body)
	_paint_canvas().draw_rect(body, PROVISIONAL_DUMPSTER, true)
	var lid: Rect2 = Rect2(
		body.position,
		Vector2(body.size.x, maxf(body.size.y * 0.30, 3.0))
	)
	_paint_canvas().draw_rect(lid, Color(0.14, 0.28, 0.18, 1.0), true)
	var lid_lip: Rect2 = Rect2(
		body.position + Vector2(0.0, lid.size.y - 1.5),
		Vector2(body.size.x, 1.8)
	)
	_paint_canvas().draw_rect(lid_lip, Color(0.10, 0.18, 0.12, 1.0), true)
	_paint_canvas().draw_rect(body, PROVISIONAL_PROP_OUTLINE, false, 2.6)
	var bar: Rect2 = Rect2(
		body.position + Vector2(2.5, body.size.y * 0.48),
		Vector2(maxf(body.size.x - 5.0, 1.0), 2.0)
	)
	_paint_canvas().draw_rect(bar, Color(0.08, 0.12, 0.09, 1.0), true)


func _draw_crates(view_rect: Rect2) -> void:
	var body: Rect2 = view_rect.grow(PROP_VISUAL_GROW * 0.6)
	_draw_prop_shadow(body)
	var left: Rect2 = Rect2(
		body.position,
		Vector2(body.size.x * 0.58, body.size.y * 0.78)
	)
	left.position.y += body.size.y * 0.22
	var right: Rect2 = Rect2(
		body.position + Vector2(body.size.x * 0.38, 0.0),
		Vector2(body.size.x * 0.62, body.size.y * 0.62)
	)
	_paint_canvas().draw_rect(left, PROVISIONAL_CRATE, true)
	_paint_canvas().draw_rect(right, Color(0.40, 0.28, 0.16, 1.0), true)
	_paint_canvas().draw_rect(left, PROVISIONAL_PROP_OUTLINE, false, 1.8)
	_paint_canvas().draw_rect(right, PROVISIONAL_PROP_OUTLINE, false, 1.8)
	var strap: Rect2 = Rect2(
		left.position + Vector2(1.4, left.size.y * 0.42),
		Vector2(maxf(left.size.x - 2.8, 1.0), 1.4)
	)
	_paint_canvas().draw_rect(strap, Color(0.22, 0.16, 0.10, 1.0), true)


func _draw_low_wall(view_rect: Rect2) -> void:
	var body: Rect2 = view_rect.grow(PROP_VISUAL_GROW * 0.7)
	_draw_prop_shadow(body)
	_paint_canvas().draw_rect(body, PROVISIONAL_LOW_WALL, true)
	var cap: Rect2 = body
	if body.size.x >= body.size.y:
		cap.size.y = minf(3.0, body.size.y)
	else:
		cap.size.x = minf(3.0, body.size.x)
	_paint_canvas().draw_rect(cap, Color(0.62, 0.58, 0.52, 1.0), true)
	_paint_canvas().draw_rect(body, PROVISIONAL_PROP_OUTLINE, false, 2.4)


func _draw_barrier(view_rect: Rect2) -> void:
	var body: Rect2 = view_rect.grow(PROP_VISUAL_GROW * 0.7)
	_draw_prop_shadow(body)
	_paint_canvas().draw_rect(body, PROVISIONAL_BARRIER, true)
	var stripe: Rect2 = _inset_view_rect(body, 1.5, 1.2)
	if body.size.x >= body.size.y:
		stripe.size.y = minf(2.2, stripe.size.y)
		stripe.position.y = body.position.y + body.size.y * 0.35
	else:
		stripe.size.x = minf(2.2, stripe.size.x)
		stripe.position.x = body.position.x + body.size.x * 0.35
	_paint_canvas().draw_rect(stripe, Color(0.78, 0.72, 0.58, 1.0), true)
	_paint_canvas().draw_rect(body, PROVISIONAL_PROP_OUTLINE, false, 2.4)


func _draw_prop_shadow(view_rect: Rect2) -> void:
	_paint_canvas().draw_rect(Rect2(view_rect.position + PROP_SHADOW_OFFSET, view_rect.size), PROVISIONAL_PROP_SHADOW, true)


func _draw_fence(view_rect: Rect2) -> void:
	var body: Rect2 = view_rect.grow(1.2)
	_draw_prop_shadow(body)
	_paint_canvas().draw_rect(body, PROVISIONAL_FENCE, true)
	_paint_canvas().draw_rect(body, PROVISIONAL_PROP_OUTLINE, false, 1.6)
	var along_y: bool = view_rect.size.y >= view_rect.size.x
	var step: float = 6.0
	var t: float = 1.0
	if along_y:
		while t < view_rect.size.y - 1.0:
			_paint_canvas().draw_line(
				view_rect.position + Vector2(0.0, t),
				view_rect.position + Vector2(view_rect.size.x, t),
				Color(0.18, 0.17, 0.15, 0.8),
				1.0,
				true
			)
			t += step
		return
	while t < view_rect.size.x - 1.0:
		_paint_canvas().draw_line(
			view_rect.position + Vector2(t, 0.0),
			view_rect.position + Vector2(t, view_rect.size.y),
			Color(0.18, 0.17, 0.15, 0.8),
			1.0,
			true
		)
		t += step


func _draw_building(obstacle: BattleObstacle) -> void:
	var view_rect: Rect2 = _rect_to_view(obstacle.bounds)
	var fill: Color = PROVISIONAL_BUILDING
	var is_hq: bool = obstacle.obstacle_id == "building_hq"
	var is_warehouse: bool = obstacle.obstacle_id.find("warehouse") >= 0
	var is_shop: bool = (
		obstacle.obstacle_id.find("shop") >= 0
		or obstacle.obstacle_id.find("storefront") >= 0
		or obstacle.obstacle_id.find("south_mid") >= 0
		or obstacle.obstacle_id.find("sw_framing") >= 0
		or obstacle.obstacle_id.find("se_framing") >= 0
	)
	var roof_fill: Color = PROVISIONAL_BUILDING_ROOF
	if is_hq:
		fill = PROVISIONAL_BUILDING_HQ
		roof_fill = PROVISIONAL_BUILDING_ROOF_HQ
	elif is_warehouse:
		fill = PROVISIONAL_BUILDING_WAREHOUSE
	elif obstacle.obstacle_id.find("south_mid") >= 0 or obstacle.obstacle_id.find("east_shop") >= 0:
		fill = PROVISIONAL_BUILDING_SHOP_B
	elif is_shop:
		fill = PROVISIONAL_BUILDING_SHOP_A
	_paint_canvas().draw_rect(view_rect, fill, true)
	var roof: Rect2 = _inset_view_rect(view_rect, 4.0, 3.5)
	_paint_canvas().draw_rect(roof, roof_fill, true)
	var outline_w: float = 3.2 if is_hq else 2.4
	_paint_canvas().draw_rect(view_rect, PROVISIONAL_BUILDING_LINE, false, outline_w)
	if is_hq:
		_draw_hq_cues(view_rect)
	elif is_warehouse:
		_draw_warehouse_cues(view_rect)
	elif is_shop:
		_draw_storefront_cues(obstacle, view_rect)
	else:
		_draw_neighbor_facade(obstacle, view_rect)


func _draw_hq_cues(view_rect: Rect2) -> void:
	var frontage: Rect2 = Rect2(
		Vector2(view_rect.position.x + 3.0, view_rect.end.y - 10.0),
		Vector2(maxf(view_rect.size.x - 6.0, 8.0), 10.0)
	)
	_paint_canvas().draw_rect(frontage, Color(0.32, 0.16, 0.15, 0.55), true)
	_paint_canvas().draw_rect(
		Rect2(Vector2(view_rect.position.x, view_rect.end.y - 2.4), Vector2(view_rect.size.x, 2.4)),
		Color(0.22, 0.12, 0.10, 0.95),
		true
	)
	var door_w: float = 11.0
	var door_h: float = 13.0
	var door: Rect2 = Rect2(
		Vector2(view_rect.get_center().x - door_w * 0.5, view_rect.end.y - door_h),
		Vector2(door_w, door_h)
	)
	_paint_canvas().draw_rect(door, PROVISIONAL_DOOR, true)
	_paint_canvas().draw_rect(door, Color(0.08, 0.05, 0.04, 1.0), false, 1.4)
	var jamb: Rect2 = Rect2(
		Vector2(door.position.x + 1.6, door.position.y + 1.4),
		Vector2(maxf(door.size.x - 3.2, 2.0), maxf(door.size.y - 2.2, 2.0))
	)
	_paint_canvas().draw_rect(jamb, Color(0.20, 0.13, 0.11, 1.0), true)
	var window_w: float = 9.0
	var window_h: float = 8.0
	var window_y: float = view_rect.end.y - 18.0
	var left_window: Rect2 = Rect2(
		Vector2(view_rect.position.x + 18.0, window_y),
		Vector2(window_w, window_h)
	)
	var right_window: Rect2 = Rect2(
		Vector2(view_rect.end.x - 18.0 - window_w, window_y),
		Vector2(window_w, window_h)
	)
	_paint_canvas().draw_rect(left_window, PROVISIONAL_WINDOW, true)
	_paint_canvas().draw_rect(right_window, PROVISIONAL_WINDOW, true)
	_paint_canvas().draw_rect(left_window, Color(0.06, 0.05, 0.05, 1.0), false, 1.0)
	_paint_canvas().draw_rect(right_window, Color(0.06, 0.05, 0.05, 1.0), false, 1.0)
	var lintel: Rect2 = Rect2(
		Vector2(door.position.x - 2.0, door.position.y - 2.2),
		Vector2(door.size.x + 4.0, 2.2)
	)
	_paint_canvas().draw_rect(lintel, PROVISIONAL_BUILDING_ACCENT, true)


func _draw_neighbor_facade(obstacle: BattleObstacle, view_rect: Rect2) -> void:
	var street_south: bool = obstacle.obstacle_id.find("framing") >= 0
	var window_h: float = minf(11.0, view_rect.size.y * 0.28)
	var window_w: float = 8.0
	var window_y: float = view_rect.position.y + 8.0
	if street_south:
		window_y = view_rect.position.y + 5.0
	else:
		window_y = view_rect.end.y - window_h - 8.0
	var x: float = view_rect.position.x + 8.0
	var count: int = 0
	while x + window_w < view_rect.end.x - 8.0 and count < 4:
		var window: Rect2 = Rect2(Vector2(x, window_y), Vector2(window_w, window_h))
		_paint_canvas().draw_rect(window, PROVISIONAL_WINDOW, true)
		_paint_canvas().draw_rect(window, Color(0.06, 0.06, 0.07, 1.0), false, 1.0)
		x += window_w + 7.0
		count += 1
	var door_w: float = 6.5
	var door_h: float = 8.5
	var door_x: float = view_rect.position.x + view_rect.size.x * 0.42
	var door_y: float = view_rect.end.y - door_h
	if street_south:
		door_y = view_rect.position.y
	var door: Rect2 = Rect2(Vector2(door_x, door_y), Vector2(door_w, door_h))
	_paint_canvas().draw_rect(door, PROVISIONAL_DOOR, true)
	_paint_canvas().draw_rect(door, Color(0.08, 0.05, 0.04, 1.0), false, 1.0)


func _draw_warehouse_cues(view_rect: Rect2) -> void:
	var parapet: Rect2 = _inset_view_rect(view_rect, 2.0, 2.0)
	_paint_canvas().draw_rect(parapet, Color(0.28, 0.26, 0.24, 0.70), false, 2.2)
	var bay_y: float = view_rect.end.y - 11.0
	var bay_h: float = 8.5
	var bay_w: float = 22.0
	var gap: float = 8.0
	var x: float = view_rect.position.x + 18.0
	var count: int = 0
	while x + bay_w < view_rect.end.x - 12.0 and count < 3:
		var bay: Rect2 = Rect2(Vector2(x, bay_y), Vector2(bay_w, bay_h))
		_paint_canvas().draw_rect(bay, Color(0.10, 0.10, 0.11, 0.95), true)
		_paint_canvas().draw_rect(bay, Color(0.32, 0.30, 0.26, 1.0), false, 1.4)
		x += bay_w + gap
		count += 1
	var door: Rect2 = Rect2(
		Vector2(view_rect.position.x + 8.0, view_rect.end.y - 9.0),
		Vector2(7.0, 7.0)
	)
	_paint_canvas().draw_rect(door, Color(0.18, 0.16, 0.14, 1.0), true)


func _draw_storefront_cues(obstacle: BattleObstacle, view_rect: Rect2) -> void:
	var awning_h: float = 5.0
	var awning: Rect2 = Rect2(
		Vector2(view_rect.position.x + 2.0, view_rect.position.y - 2.5),
		Vector2(maxf(view_rect.size.x - 4.0, 4.0), awning_h)
	)
	_paint_canvas().draw_rect(awning, PROVISIONAL_AWNING, true)
	_paint_canvas().draw_rect(awning, Color(0.10, 0.06, 0.05, 1.0), false, 1.4)
	var window_y: float = view_rect.position.y + 8.0
	var window_h: float = minf(14.0, view_rect.size.y * 0.28)
	var window_w: float = 10.0
	var x: float = view_rect.position.x + 6.0
	var count: int = 0
	while x + window_w < view_rect.end.x - 6.0 and count < 4:
		var window: Rect2 = Rect2(Vector2(x, window_y), Vector2(window_w, window_h))
		_paint_canvas().draw_rect(window, PROVISIONAL_WINDOW, true)
		_paint_canvas().draw_rect(window, Color(0.06, 0.06, 0.07, 1.0), false, 1.0)
		x += window_w + 5.0
		count += 1
	var sign_w: float = minf(18.0, view_rect.size.x * 0.28)
	var sign: Rect2 = Rect2(
		Vector2(view_rect.end.x - sign_w - 5.0, view_rect.position.y + 4.0),
		Vector2(sign_w, 4.5)
	)
	var accent: Color = PROVISIONAL_BUILDING_ACCENT
	if obstacle.obstacle_id.find("east_shop") >= 0:
		accent = Color(0.22, 0.28, 0.34, 1.0)
	elif obstacle.obstacle_id.find("south_mid") >= 0:
		accent = Color(0.40, 0.28, 0.14, 1.0)
	_paint_canvas().draw_rect(sign, accent, true)


func _inset_view_rect(view_rect: Rect2, inset_x: float, inset_y: float) -> Rect2:
	return Rect2(
		view_rect.position + Vector2(inset_x, inset_y),
		Vector2(
			maxf(view_rect.size.x - inset_x * 2.0, 2.0),
			maxf(view_rect.size.y - inset_y * 2.0, 2.0)
		)
	)


func _draw_cover(battle_state: BattleState) -> void:
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	if geometry == null:
		return
	for cover_slot_id: String in geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = geometry.get_cover_slot(cover_slot_id)
		if slot == null:
			continue
		var slot_view: Vector2 = _to_view(slot.position)
		var fill: Color = PROVISIONAL_COVER
		if slot.is_occupied():
			fill = Color(0.90, 0.78, 0.36, 1.0)
		_paint_canvas().draw_circle(slot_view, COVER_SLOT_RADIUS, fill, false, 1.5, true)


func _draw_participants(battle_state: BattleState) -> void:
	var living: Array[BattleParticipant] = []
	var downed: Array[BattleParticipant] = []
	for participant_id: String in _sorted_keys(battle_state.participants):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			continue
		if participant.is_alive:
			living.append(participant)
		else:
			downed.append(participant)
	for participant: BattleParticipant in downed:
		_draw_soldier(battle_state, participant)
	for participant: BattleParticipant in living:
		_draw_soldier(battle_state, participant)


func _draw_soldier(battle_state: BattleState, participant: BattleParticipant) -> void:
	var view_pos: Vector2 = _to_view(participant.battle_position)
	var facing: Vector2 = _participant_view_facing(battle_state, participant)
	_draw_soldier_ground(view_pos, battle_state, participant)
	if _selected_participant_id() == participant.participant_id:
		_draw_soldier_selection(view_pos)
	if not participant.is_alive:
		_draw_soldier_downed(view_pos, facing, participant.weapon_type)
		_draw_compact_combat_state(battle_state, participant, view_pos)
		return
	_draw_soldier_standing(view_pos, facing, battle_state, participant)
	_draw_compact_combat_state(battle_state, participant, view_pos)


func _draw_soldier_ground(view_pos: Vector2, battle_state: BattleState, participant: BattleParticipant) -> void:
	var marker: Color = PROVISIONAL_ATTACKER_FOOT
	if participant.side_id == battle_state.defender_side_id:
		marker = PROVISIONAL_DEFENDER_FOOT
	if not participant.is_alive:
		marker = Color(0.18, 0.17, 0.16, 0.42)
	_paint_canvas().draw_circle(view_pos, SOLDIER_GROUND_RADIUS * SOLDIER_VISUAL_SCALE, marker, true)


func _draw_soldier_selection(view_pos: Vector2) -> void:
	_paint_canvas().draw_circle(view_pos, SOLDIER_SELECTION_RADIUS * SOLDIER_VISUAL_SCALE, PROVISIONAL_SELECTABLE, false, 2.0, true)
	_paint_canvas().draw_circle(view_pos, SOLDIER_SELECTION_RADIUS * SOLDIER_VISUAL_SCALE - 2.4, Color(0.08, 0.08, 0.07, 0.55), false, 1.0, true)


func _draw_soldier_standing(
	view_pos: Vector2,
	facing: Vector2,
	battle_state: BattleState,
	participant: BattleParticipant
) -> void:
	var wounded: bool = participant.is_wounded
	var tucked: bool = participant.is_cover_tucked()
	var body: Color = PROVISIONAL_SOLDIER_BODY
	if wounded:
		body = PROVISIONAL_SOLDIER_BODY_WOUNDED
	var accent: Color = _side_accent(battle_state, participant.side_id)
	var angle: float = facing.angle()
	if wounded:
		angle += 0.34
	var scale: Vector2 = Vector2.ONE
	if wounded:
		scale = Vector2(0.94, 0.82)
	if tucked:
		scale = Vector2(scale.x * 0.90, scale.y * 0.70)
	scale *= SOLDIER_VISUAL_SCALE
	_paint_canvas().draw_set_transform(view_pos, angle, scale)
	var leg_l: Rect2 = Rect2(Vector2(-5.4, -3.1), Vector2(4.2, 2.2))
	var leg_r: Rect2 = Rect2(Vector2(-5.4, 0.9), Vector2(4.2, 2.2))
	_paint_canvas().draw_rect(leg_l, body.darkened(0.18), true)
	_paint_canvas().draw_rect(leg_r, body.darkened(0.18), true)
	_paint_canvas().draw_rect(leg_l, PROVISIONAL_SOLDIER_OUTLINE, false, 1.0)
	_paint_canvas().draw_rect(leg_r, PROVISIONAL_SOLDIER_OUTLINE, false, 1.0)
	var torso: Rect2 = Rect2(Vector2(-3.6, -2.7), Vector2(8.0, 5.4))
	_paint_canvas().draw_rect(torso, body, true)
	_paint_canvas().draw_rect(torso, PROVISIONAL_SOLDIER_OUTLINE, false, 1.4)
	var shoulders: Rect2 = Rect2(Vector2(-1.4, -4.2), Vector2(4.0, 8.4))
	_paint_canvas().draw_rect(shoulders, body.lightened(0.06), true)
	_paint_canvas().draw_rect(shoulders, PROVISIONAL_SOLDIER_OUTLINE, false, 1.2)
	var accent_bar: Rect2 = Rect2(Vector2(-0.6, -3.8), Vector2(1.5, 7.6))
	_paint_canvas().draw_rect(accent_bar, accent, true)
	var arm_l: Rect2 = Rect2(Vector2(0.6, -4.8), Vector2(4.4, 1.5))
	var arm_r: Rect2 = Rect2(Vector2(1.2, 3.3), Vector2(4.8, 1.7))
	_paint_canvas().draw_rect(arm_l, body.darkened(0.08), true)
	_paint_canvas().draw_rect(arm_r, body.darkened(0.08), true)
	_paint_canvas().draw_rect(arm_l, PROVISIONAL_SOLDIER_OUTLINE, false, 1.0)
	_paint_canvas().draw_rect(arm_r, PROVISIONAL_SOLDIER_OUTLINE, false, 1.0)
	if tucked:
		var lowered: Rect2 = Rect2(Vector2(-1.2, 1.6), Vector2(3.2, 1.1))
		_paint_canvas().draw_rect(lowered, PROVISIONAL_SOLDIER_WEAPON, true)
	else:
		_draw_soldier_weapon(participant.weapon_type)
	_paint_canvas().draw_circle(Vector2(5.4, 0.0), SOLDIER_HEAD_RADIUS, PROVISIONAL_SOLDIER_HEAD, true)
	_paint_canvas().draw_circle(Vector2(5.4, 0.0), SOLDIER_HEAD_RADIUS, PROVISIONAL_SOLDIER_OUTLINE, false, 1.3, true)
	if wounded:
		_paint_canvas().draw_circle(Vector2(0.4, 1.4), 1.7, PROVISIONAL_INJURY_MARK, true)
		_paint_canvas().draw_circle(Vector2(0.4, 1.4), 1.7, PROVISIONAL_SOLDIER_OUTLINE, false, 0.8, true)
	_paint_canvas().draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_soldier_downed(view_pos: Vector2, facing: Vector2, weapon_type: String = "") -> void:
	_paint_canvas().draw_set_transform(view_pos, facing.angle() + 0.18, Vector2(SOLDIER_VISUAL_SCALE, SOLDIER_VISUAL_SCALE))
	var torso: Rect2 = Rect2(Vector2(-6.4, -2.1), Vector2(12.6, 4.2))
	_paint_canvas().draw_rect(torso, PROVISIONAL_SOLDIER_BODY_DEAD, true)
	_paint_canvas().draw_rect(torso, PROVISIONAL_SOLDIER_OUTLINE, false, 1.3)
	var leg_l: Rect2 = Rect2(Vector2(-11.2, -3.4), Vector2(5.4, 1.8))
	var leg_r: Rect2 = Rect2(Vector2(-10.6, 1.6), Vector2(5.0, 1.8))
	_paint_canvas().draw_rect(leg_l, PROVISIONAL_SOLDIER_BODY_DEAD.darkened(0.12), true)
	_paint_canvas().draw_rect(leg_r, PROVISIONAL_SOLDIER_BODY_DEAD.darkened(0.12), true)
	var arm_l: Rect2 = Rect2(Vector2(-1.2, -6.0), Vector2(5.2, 1.5))
	var arm_r: Rect2 = Rect2(Vector2(-0.4, 4.4), Vector2(4.8, 1.5))
	_paint_canvas().draw_rect(arm_l, PROVISIONAL_SOLDIER_BODY_DEAD.darkened(0.08), true)
	_paint_canvas().draw_rect(arm_r, PROVISIONAL_SOLDIER_BODY_DEAD.darkened(0.08), true)
	_paint_canvas().draw_circle(Vector2(7.4, 1.2), SOLDIER_HEAD_RADIUS, PROVISIONAL_SOLDIER_HEAD_DEAD, true)
	_paint_canvas().draw_circle(Vector2(7.4, 1.2), SOLDIER_HEAD_RADIUS, PROVISIONAL_SOLDIER_OUTLINE, false, 1.2, true)
	var dropped_len: float = maxf(TacticalShotPresentation.silhouette_length(weapon_type) * 0.55, 4.2)
	var dropped: Rect2 = Rect2(Vector2(1.0, 5.2), Vector2(dropped_len, 1.3))
	_paint_canvas().draw_rect(dropped, PROVISIONAL_SOLDIER_WEAPON, true)
	_paint_canvas().draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_soldier_weapon(weapon_type: String) -> void:
	var length: float = TacticalShotPresentation.silhouette_length(weapon_type)
	var width: float = TacticalShotPresentation.silhouette_width(weapon_type)
	var stock: float = TacticalShotPresentation.silhouette_stock(weapon_type)
	var hand: Vector2 = Vector2(SOLDIER_HAND_FORWARD, 2.3)
	if stock > 0.2:
		var stock_rect: Rect2 = Rect2(
			hand + Vector2(-stock + 0.4, width * -0.32),
			Vector2(stock, width * 0.64)
		)
		_paint_canvas().draw_rect(stock_rect, PROVISIONAL_SOLDIER_WEAPON_STOCK, true)
	var barrel: Rect2 = Rect2(hand + Vector2(0.0, width * -0.5), Vector2(length, width))
	_paint_canvas().draw_rect(barrel, PROVISIONAL_SOLDIER_WEAPON, true)
	_paint_canvas().draw_rect(barrel, PROVISIONAL_SOLDIER_OUTLINE, false, 0.9)
	match weapon_type:
		"pistol":
			var grip: Rect2 = Rect2(hand + Vector2(-0.15, width * 0.12), Vector2(1.55, 2.35))
			_paint_canvas().draw_rect(grip, PROVISIONAL_SOLDIER_WEAPON_STOCK, true)
			_paint_canvas().draw_rect(grip, PROVISIONAL_SOLDIER_OUTLINE, false, 0.7)
		"smg":
			var mag: Rect2 = Rect2(hand + Vector2(1.05, width * 0.28), Vector2(1.45, 2.15))
			_paint_canvas().draw_rect(mag, PROVISIONAL_SOLDIER_WEAPON, true)
			_paint_canvas().draw_rect(mag, PROVISIONAL_SOLDIER_OUTLINE, false, 0.7)
			var receiver: Rect2 = Rect2(hand + Vector2(0.2, width * -0.78), Vector2(2.8, width * 0.42))
			_paint_canvas().draw_rect(receiver, PROVISIONAL_SOLDIER_WEAPON.lightened(0.12), true)
		"shotgun":
			var sleeve: Rect2 = Rect2(hand + Vector2(2.1, width * -0.72), Vector2(2.8, width * 1.44))
			_paint_canvas().draw_rect(sleeve, PROVISIONAL_SOLDIER_WEAPON.lightened(0.16), true)
		"rifle":
			var mag: Rect2 = Rect2(hand + Vector2(1.6, width * 0.22), Vector2(1.7, 2.05))
			_paint_canvas().draw_rect(mag, PROVISIONAL_SOLDIER_WEAPON, true)
			var front: Rect2 = Rect2(hand + Vector2(length - 1.6, width * -0.95), Vector2(0.7, width * 0.38))
			_paint_canvas().draw_rect(front, PROVISIONAL_SOLDIER_WEAPON.lightened(0.10), true)
		"sniper":
			var optic: Rect2 = Rect2(hand + Vector2(length * 0.30, width * -1.55), Vector2(3.1, 1.05))
			_paint_canvas().draw_rect(optic, Color(0.12, 0.13, 0.14, 1.0), true)
			var barrel_tip: Rect2 = Rect2(
				hand + Vector2(length * 0.62, width * -0.22),
				Vector2(length * 0.38, width * 0.44)
			)
			_paint_canvas().draw_rect(barrel_tip, PROVISIONAL_SOLDIER_WEAPON.lightened(0.08), true)
		_:
			pass


func _weapon_presentation_length(weapon_type: String) -> float:
	return TacticalShotPresentation.silhouette_length(weapon_type)


func _weapon_presentation_width(weapon_type: String) -> float:
	return TacticalShotPresentation.silhouette_width(weapon_type)


func _weapon_presentation_stock(weapon_type: String) -> float:
	return TacticalShotPresentation.silhouette_stock(weapon_type)


func _weapon_tip_pixels(weapon_type: String) -> float:
	return (SOLDIER_HAND_FORWARD + _weapon_presentation_length(weapon_type)) * SOLDIER_VISUAL_SCALE


func _side_accent(battle_state: BattleState, side_id: String) -> Color:
	if side_id == battle_state.defender_side_id:
		return PROVISIONAL_DEFENDER_ACCENT
	return PROVISIONAL_ATTACKER_ACCENT


func _participant_view_facing(battle_state: BattleState, participant: BattleParticipant) -> Vector2:
	if participant == null:
		return Vector2.UP
	if participant.has_target_participant:
		var target: BattleParticipant = battle_state.get_participant(participant.target_participant_id)
		if target != null and target.has_battle_position:
			var to_target: Vector2 = target.battle_position - participant.battle_position
			if _view_facing_usable(to_target):
				return to_target.normalized()
	if _view_facing_usable(participant.velocity):
		return participant.velocity.normalized()
	if _view_facing_usable(participant.movement_intent):
		return participant.movement_intent.normalized()
	if participant.has_movement_target_position:
		var to_move: Vector2 = participant.movement_target_position - participant.battle_position
		if _view_facing_usable(to_move):
			return to_move.normalized()
	if participant.has_active_navigation_path():
		var to_waypoint: Vector2 = participant.get_current_navigation_waypoint() - participant.battle_position
		if _view_facing_usable(to_waypoint):
			return to_waypoint.normalized()
	if participant.has_occupied_cover_slot() and battle_state.battlefield_geometry != null:
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
			participant.occupied_cover_slot_id
		)
		if slot != null and _view_facing_usable(slot.facing_direction):
			return slot.facing_direction.normalized()
	var from_event: Vector2 = _latest_source_shot_facing(battle_state, participant)
	if _view_facing_usable(from_event):
		return from_event.normalized()
	if participant.side_id == battle_state.defender_side_id:
		return Vector2.DOWN
	return Vector2.UP


func _latest_source_shot_facing(battle_state: BattleState, participant: BattleParticipant) -> Vector2:
	if battle_state == null or participant == null:
		return Vector2.ZERO
	var events: Array = battle_state.combat_feedback_events
	var i: int = events.size() - 1
	while i >= 0:
		var event: BattleAttackEvent = events[i]
		i -= 1
		if event == null or event.source_participant_id != participant.participant_id:
			continue
		if not event.has_source_position or not event.has_target_position:
			continue
		var along: Vector2 = event.target_position - event.source_position
		if _view_facing_usable(along):
			return along
	return Vector2.ZERO


func _view_facing_usable(direction: Vector2) -> bool:
	if not is_finite(direction.x) or not is_finite(direction.y):
		return false
	return not direction.is_equal_approx(Vector2.ZERO)


func _draw_compact_combat_state(
	battle_state: BattleState,
	participant: BattleParticipant,
	view_pos: Vector2
) -> void:
	if battle_state == null or participant == null:
		return
	if battle_state.battle_phase != "active" and battle_state.battle_phase != "resolved":
		return
	if _participant_has_visible_shot(battle_state, participant):
		return
	var label: String = BattleCombatPresentationQuery.compact_state(battle_state, participant)
	if label.is_empty():
		return
	_draw_label(
		view_pos + Vector2(11.0, -10.0),
		label,
		COMPACT_STATE_FONT_SIZE,
		_compact_state_color(label)
	)


func _compact_state_color(label: String) -> Color:
	match label:
		BattleCombatPresentationQuery.STATE_WND:
			return PROVISIONAL_COMPACT_WND
		BattleCombatPresentationQuery.STATE_WAIT, BattleCombatPresentationQuery.STATE_AIM:
			return PROVISIONAL_COMPACT_WAIT
		BattleCombatPresentationQuery.STATE_HOLD, BattleCombatPresentationQuery.STATE_COVER:
			return PROVISIONAL_COMPACT_STATE
		BattleCombatPresentationQuery.STATE_DEAD:
			return PROVISIONAL_DEAD
		_:
			return PROVISIONAL_COMPACT_STATE


func _participant_has_visible_shot(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if battle_state == null or participant == null:
		return false
	var resolved_hold: bool = _is_resolved_presentation(battle_state)
	for event: BattleAttackEvent in battle_state.combat_feedback_events:
		if event == null:
			continue
		if event.source_participant_id != participant.participant_id:
			continue
		if _combat_event_visible(battle_state, event, resolved_hold):
			return true
	return false


func _draw_vehicles(battle_state: BattleState) -> void:
	for vehicle_id: String in _sorted_keys(battle_state.vehicles):
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null or not vehicle.has_battle_position:
			continue
		var corners: PackedVector2Array = BattleVehicleBodyService.world_corners(vehicle)
		if corners.size() != 4:
			continue
		var view_corners: PackedVector2Array = PackedVector2Array()
		var min_y: float = INF
		var max_y: float = -INF
		for corner: Vector2 in corners:
			var view_corner: Vector2 = _to_view(corner)
			view_corners.append(view_corner)
			if view_corner.y < min_y:
				min_y = view_corner.y
			if view_corner.y > max_y:
				max_y = view_corner.y
		var view_pos: Vector2 = _to_view(vehicle.battle_position)
		_paint_canvas().draw_colored_polygon(view_corners, PROVISIONAL_VEHICLE_FILL)
		var cabin: PackedVector2Array = PackedVector2Array(
			[
				view_corners[0].lerp(view_corners[3], 0.28),
				view_corners[1].lerp(view_corners[2], 0.28),
				view_corners[1].lerp(view_corners[2], 0.78),
				view_corners[0].lerp(view_corners[3], 0.78),
			]
		)
		_paint_canvas().draw_colored_polygon(cabin, PROVISIONAL_VEHICLE_CABIN)
		var glass: PackedVector2Array = PackedVector2Array(
			[
				view_corners[0].lerp(view_corners[3], 0.30),
				view_corners[1].lerp(view_corners[2], 0.30),
				view_corners[1].lerp(view_corners[2], 0.46),
				view_corners[0].lerp(view_corners[3], 0.46),
			]
		)
		_paint_canvas().draw_colored_polygon(glass, PROVISIONAL_VEHICLE_GLASS)
		var outline: PackedVector2Array = view_corners.duplicate()
		outline.append(view_corners[0])
		_paint_canvas().draw_polyline(outline, PROVISIONAL_VEHICLE_OUTLINE, VEHICLE_OUTLINE_WIDTH, true)
		_paint_canvas().draw_line(view_corners[0], view_corners[1], PROVISIONAL_VEHICLE_OUTLINE, VEHICLE_OUTLINE_WIDTH + 1.5, true)
		if vehicle.has_valid_orientation():
			var facing: Vector2 = vehicle.facing_direction
			var front_mid: Vector2 = (view_corners[0] + view_corners[1]) * 0.5
			var nose: Vector2 = front_mid + facing * VEHICLE_FRONT_MARK
			_paint_canvas().draw_line(front_mid, nose, PROVISIONAL_VEHICLE_FACING, 2.5, true)
			var side: Vector2 = Vector2(-facing.y, facing.x) * 4.0
			var chevron: PackedVector2Array = PackedVector2Array(
				[nose, nose - facing * 5.0 + side, nose - facing * 5.0 - side]
			)
			_paint_canvas().draw_colored_polygon(chevron, PROVISIONAL_VEHICLE_FACING)
		_draw_label(Vector2(view_pos.x, min_y - 12.0), "CAR", 11)
		_draw_label(Vector2(view_pos.x, max_y + 12.0), vehicle.battle_vehicle_id, 10)


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
			_paint_canvas().draw_rect(row_rect, PROVISIONAL_SELECTED, true)
		var color: Color = PROVISIONAL_OVERLAY
		if kind == "status" or kind == "result":
			color = PROVISIONAL_STATUS
		if kind == "result":
			color = PROVISIONAL_RESULT
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
	var playtest_line: String = _playtest_variety_overlay_line(battle_state)
	if not playtest_line.is_empty():
		rows.append(_overlay_row(playtest_line))
	rows.append(
		_overlay_row(
			"phase=%s  session=%s  elapsed=%.2f"
			% [battle_state.battle_phase, session.session_state, battle_state.elapsed_time_seconds]
		)
	)
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
	if _is_resolved_presentation(battle_state):
		var result_text: String = _result_banner_text(battle_state)
		if not result_text.is_empty():
			rows.append(_overlay_result_row(result_text))
		var casualty_line: String = _result_casualty_line(battle_state)
		if not casualty_line.is_empty():
			rows.append(_overlay_row(casualty_line))
	elif battle_state.battle_phase == "active":
		rows.append(_overlay_status_row("BATTLE ACTIVE"))
	elif not attacker_committed:
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
		rows.append(_overlay_status_row("SPACE: START BATTLE"))
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
				"text": "%s %s  %s  %s  %s%s" % [
					prefix,
					participant.participant_id,
					_side_label(battle_state, participant.side_id),
					participant.weapon_type,
					_deployed_label(battle_state.is_participant_deployed(participant_id)),
					_participant_condition_suffix(participant),
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
		var parked: String = "placement unavailable"
		if battle_state.is_vehicle_fully_deployed(vehicle.battle_vehicle_id):
			parked = "parked"
		rows.append(
			{
				"text": "  V %s  %s  %s  %s  (%s)" % [
					vehicle.battle_vehicle_id,
					_side_label(battle_state, vehicle.side_id),
					vehicle.vehicle_type_id,
					_deployed_label(battle_state.is_vehicle_deployed(vehicle_id)),
					parked,
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


func _playtest_variety_overlay_line(battle_state: BattleState) -> String:
	if session == null:
		return ""
	if session.manual_playtest_serial > 0:
		return "VAR #%d" % session.manual_playtest_serial
	if battle_state != null and battle_state.mission_id == "debug_hq_assault":
		return "REG"
	return ""


func _overlay_status_row(text: String) -> Dictionary:
	return {
		"text": text,
		"kind": "status",
		"id": "",
		"selectable": false,
	}


func _overlay_result_row(text: String) -> Dictionary:
	return {
		"text": text,
		"kind": "result",
		"id": "",
		"selectable": false,
	}


func _draw_combat_feedback(battle_state: BattleState) -> void:
	if battle_state == null:
		return
	var resolved_hold: bool = _is_resolved_presentation(battle_state)
	for event: BattleAttackEvent in battle_state.combat_feedback_events:
		_draw_shot_muzzle_flash(battle_state, event, resolved_hold)
	for event: BattleAttackEvent in battle_state.combat_feedback_events:
		_draw_shot_projectile(battle_state, event, resolved_hold)
	for event: BattleAttackEvent in battle_state.combat_feedback_events:
		_draw_shot_impact(battle_state, event, resolved_hold)


func _draw_shot_muzzle_flash(
	battle_state: BattleState,
	event: BattleAttackEvent,
	resolved_hold: bool
) -> void:
	if resolved_hold or event == null:
		return
	var age: float = _combat_event_age(battle_state, event)
	var flash_alpha: float = TacticalShotPresentation.muzzle_flash_alpha(age)
	if flash_alpha <= 0.0:
		return
	var segment: Dictionary = _shot_draw_segment(battle_state, event)
	if not bool(segment.get("ok", false)):
		return
	var muzzle: Vector2 = segment["muzzle"] as Vector2
	var along: Vector2 = segment["along"] as Vector2
	var weapon_type: String = _event_weapon_type(battle_state, event)
	var radius: float = TacticalShotPresentation.muzzle_flash_radius(weapon_type)
	var fill: Color = PROVISIONAL_MUZZLE
	fill.a = flash_alpha
	var core: Color = PROVISIONAL_MUZZLE_CORE
	core.a = flash_alpha
	if weapon_type == "sniper":
		var bloom: Color = core
		bloom.a = flash_alpha * 0.45
		_paint_canvas().draw_circle(muzzle, radius * 1.18, bloom, true)
	_paint_canvas().draw_circle(muzzle, radius, fill, true)
	_paint_canvas().draw_circle(muzzle, radius * 0.42, core, true)
	if weapon_type == "shotgun" and _view_facing_usable(along):
		var dir: Vector2 = along.normalized()
		var side: Vector2 = Vector2(-dir.y, dir.x)
		var lobe: Color = fill
		lobe.a = flash_alpha * 0.72
		_paint_canvas().draw_circle(muzzle + dir * radius * 0.35 + side * radius * 0.62, radius * 0.38, lobe, true)
		_paint_canvas().draw_circle(muzzle + dir * radius * 0.35 - side * radius * 0.62, radius * 0.38, lobe, true)


func _draw_shot_projectile(
	battle_state: BattleState,
	event: BattleAttackEvent,
	resolved_hold: bool
) -> void:
	if resolved_hold or event == null:
		return
	var age: float = _combat_event_age(battle_state, event)
	var segment: Dictionary = _shot_draw_segment(battle_state, event)
	if not bool(segment.get("ok", false)):
		return
	var muzzle: Vector2 = segment["muzzle"] as Vector2
	var endpoint: Vector2 = segment["endpoint"] as Vector2
	var along: Vector2 = segment["along"] as Vector2
	var path_pixels: float = along.length()
	var weapon_type: String = _event_weapon_type(battle_state, event)
	if not TacticalShotPresentation.projectile_visible(weapon_type, age, path_pixels):
		return
	var pos: Vector2 = TacticalShotPresentation.projectile_position(muzzle, endpoint, weapon_type, age)
	var tail_len: float = TacticalShotPresentation.tail_length_pixels(weapon_type, age, path_pixels)
	if tail_len > 0.05 and _view_facing_usable(along):
		_draw_projectile_tail(pos, along.normalized(), tail_len, weapon_type)
	var bullet: Color = PROVISIONAL_PROJECTILE
	if weapon_type == "sniper":
		bullet = Color(0.98, 0.98, 0.96, 1.0)
	_paint_canvas().draw_circle(pos, TacticalShotPresentation.projectile_radius(weapon_type), bullet, true)


func _draw_projectile_tail(tip: Vector2, direction: Vector2, tail_len: float, weapon_type: String) -> void:
	if not _view_facing_usable(direction) or tail_len <= 0.05:
		return
	var width: float = 1.05
	if weapon_type == "sniper":
		width = 0.85
	elif weapon_type == "smg":
		width = 0.95
	elif weapon_type == "shotgun":
		width = 1.15
	var back: Vector2 = -direction
	var segments: int = TacticalShotPresentation.TAIL_SEGMENTS
	var i: int = 0
	while i < segments:
		var t0: float = float(i) / float(segments)
		var t1: float = float(i + 1) / float(segments)
		var color: Color = PROVISIONAL_PROJECTILE_TAIL
		color.a = 0.58 * (1.0 - t0)
		_paint_canvas().draw_line(
			tip + back * (tail_len * t0),
			tip + back * (tail_len * t1),
			color,
			width,
			true
		)
		i += 1


func _draw_shot_impact(
	battle_state: BattleState,
	event: BattleAttackEvent,
	resolved_hold: bool
) -> void:
	if event == null:
		return
	var age: float = _combat_event_age(battle_state, event)
	var show_spark: bool = TacticalShotPresentation.impact_visible(age, resolved_hold)
	var show_label: bool = TacticalShotPresentation.outcome_label_visible(age, resolved_hold)
	if not show_spark and not show_label:
		return
	var segment: Dictionary = _shot_draw_segment(battle_state, event)
	if not bool(segment.get("ok", false)):
		return
	var endpoint: Vector2 = segment["endpoint"] as Vector2
	if show_spark:
		match event.outcome:
			BattleAttackProfile.OUTCOME_GRAZE:
				_paint_canvas().draw_circle(endpoint, IMPACT_RADIUS, PROVISIONAL_GRAZE_IMPACT, false, 1.2, true)
			BattleAttackProfile.OUTCOME_HIT:
				_paint_canvas().draw_circle(endpoint, IMPACT_RADIUS, PROVISIONAL_HIT_IMPACT, false, 1.3, true)
			BattleAttackProfile.OUTCOME_WOUNDED:
				_paint_canvas().draw_circle(endpoint, IMPACT_RADIUS + 0.4, PROVISIONAL_WOUND_IMPACT, false, 1.4, true)
			BattleAttackProfile.OUTCOME_KILLED:
				pass
			_:
				pass
	if not show_label:
		return
	match event.outcome:
		BattleAttackProfile.OUTCOME_WOUNDED:
			_draw_label(endpoint + Vector2(14.0, -8.0), "WND", 11)
		BattleAttackProfile.OUTCOME_KILLED:
			_draw_dead_mark(endpoint, PROVISIONAL_KILL_MARK)
			_draw_label(endpoint + Vector2(16.0, -8.0), "DEAD", 12)
		_:
			pass


func _shot_draw_segment(battle_state: BattleState, event: BattleAttackEvent) -> Dictionary:
	var source_pos: Vector2 = _event_source_view(battle_state, event)
	var target_pos: Vector2 = _event_target_view(battle_state, event)
	if source_pos == Vector2.INF or target_pos == Vector2.INF:
		return {"ok": false, "muzzle": Vector2.INF, "endpoint": Vector2.INF, "along": Vector2.ZERO}
	var offset: Vector2 = _combat_feedback_offset(source_pos, target_pos)
	var muzzle: Vector2 = _presentation_weapon_tip(battle_state, event, source_pos, target_pos) + offset
	var endpoint: Vector2 = target_pos + offset
	return {
		"ok": true,
		"muzzle": muzzle,
		"endpoint": endpoint,
		"along": endpoint - muzzle,
	}


func _event_weapon_type(battle_state: BattleState, event: BattleAttackEvent) -> String:
	var weapon_type: String = ""
	if event != null:
		weapon_type = event.weapon_type_id
	if battle_state != null and event != null:
		var source: BattleParticipant = battle_state.get_participant(event.source_participant_id)
		if source != null and not source.weapon_type.is_empty():
			weapon_type = source.weapon_type
	return weapon_type


func _combat_feedback_offset(source_view: Vector2, target_view: Vector2) -> Vector2:
	var along: Vector2 = target_view - source_view
	if not is_finite(along.x) or not is_finite(along.y) or along.is_equal_approx(Vector2.ZERO):
		return Vector2.ZERO
	var perp: Vector2 = Vector2(-along.y, along.x)
	if perp.is_equal_approx(Vector2.ZERO):
		return Vector2.ZERO
	return perp.normalized() * TacticalShotPresentation.SHOT_PAIR_OFFSET_PIXELS


func _combat_event_age(battle_state: BattleState, event: BattleAttackEvent) -> float:
	if battle_state == null or event == null:
		return INF
	var age: float = battle_state.elapsed_time_seconds - event.elapsed_time_seconds
	if not is_finite(age):
		return INF
	return age


func _combat_event_visible(
	battle_state: BattleState,
	event: BattleAttackEvent,
	resolved_hold: bool
) -> bool:
	if event == null or battle_state == null:
		return false
	var age: float = _combat_event_age(battle_state, event)
	var source_pos: Vector2 = _event_source_view(battle_state, event)
	var target_pos: Vector2 = _event_target_view(battle_state, event)
	var path_pixels: float = 0.0
	if source_pos != Vector2.INF and target_pos != Vector2.INF:
		path_pixels = (target_pos - source_pos).length()
	return TacticalShotPresentation.cue_visible(
		_event_weapon_type(battle_state, event),
		age,
		path_pixels,
		resolved_hold
	)


func _presentation_weapon_tip(
	battle_state: BattleState,
	event: BattleAttackEvent,
	source_view: Vector2,
	target_view: Vector2
) -> Vector2:
	var along: Vector2 = target_view - source_view
	if not _view_facing_usable(along):
		return source_view
	var weapon_type: String = ""
	if event != null:
		weapon_type = event.weapon_type_id
	if battle_state != null and event != null:
		var source: BattleParticipant = battle_state.get_participant(event.source_participant_id)
		if source != null and not source.weapon_type.is_empty():
			weapon_type = source.weapon_type
	return source_view + along.normalized() * _weapon_tip_pixels(weapon_type)


func _event_source_view(battle_state: BattleState, event: BattleAttackEvent) -> Vector2:
	if event != null and event.has_source_position:
		return _to_view(event.source_position)
	if battle_state == null or event == null:
		return Vector2.INF
	var source: BattleParticipant = battle_state.get_participant(event.source_participant_id)
	if source == null or not source.has_battle_position:
		return Vector2.INF
	return _to_view(source.battle_position)


func _event_target_view(battle_state: BattleState, event: BattleAttackEvent) -> Vector2:
	if event != null and event.has_target_position:
		return _to_view(event.target_position)
	if battle_state == null or event == null:
		return Vector2.INF
	var target: BattleParticipant = battle_state.get_participant(event.target_participant_id)
	if target == null or not target.has_battle_position:
		return Vector2.INF
	return _to_view(target.battle_position)


func _draw_dead_mark(view_pos: Vector2, color: Color) -> void:
	var mark: float = PARTICIPANT_RADIUS * SOLDIER_VISUAL_SCALE + 3.0
	_paint_canvas().draw_line(
		view_pos + Vector2(-mark, -mark),
		view_pos + Vector2(mark, mark),
		color,
		2.5,
		true
	)
	_paint_canvas().draw_line(
		view_pos + Vector2(mark, -mark),
		view_pos + Vector2(-mark, mark),
		color,
		2.5,
		true
	)


func _is_resolved_presentation(battle_state: BattleState) -> bool:
	if battle_state != null and battle_state.battle_phase == "resolved":
		return true
	if session != null and session.session_state == CampaignBattleSession.SESSION_RESOLVED_PENDING_HANDOFF:
		return true
	return false


func _result_banner_text(battle_state: BattleState) -> String:
	if battle_state == null:
		return "BATTLE RESOLVED"
	var tactical_result: BattleVictoryResult = battle_state.get_tactical_result()
	if tactical_result == null or not tactical_result.resolved:
		return "BATTLE RESOLVED"
	if tactical_result.result_kind == BattleVictoryResult.RESULT_DRAW:
		return "DRAW"
	if tactical_result.winning_side_id == battle_state.attacker_side_id:
		return "ATTACKER VICTORY"
	if tactical_result.winning_side_id == battle_state.defender_side_id:
		return "DEFENDER VICTORY"
	return "BATTLE RESOLVED"


func _result_casualty_line(battle_state: BattleState) -> String:
	if battle_state == null:
		return ""
	var last_kill: BattleAttackEvent = null
	for event: BattleAttackEvent in battle_state.combat_feedback_events:
		if event == null:
			continue
		if event.outcome == BattleAttackProfile.OUTCOME_KILLED:
			last_kill = event
	if last_kill != null and not last_kill.target_participant_id.is_empty():
		return "%s killed" % last_kill.target_participant_id
	for participant_id: String in _sorted_keys(battle_state.participants):
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant != null and not participant.is_alive:
			return "%s killed" % participant.participant_id
	return ""


func _participant_condition_suffix(participant: BattleParticipant) -> String:
	if participant == null:
		return ""
	if not participant.is_alive:
		return "  DEAD"
	if participant.is_wounded:
		return "  WND"
	return ""


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


func _draw_label(center: Vector2, text: String, font_size: int = 14, color: Color = PROVISIONAL_LABEL) -> void:
	var font: Font = ThemeDB.fallback_font
	var size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var pos: Vector2 = center - Vector2(size.x * 0.5, 0.0)
	_paint_canvas().draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL_SHADOW)
	_paint_canvas().draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_label_left(pos: Vector2, text: String, font_size: int, color: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	_paint_canvas().draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL_SHADOW)
	_paint_canvas().draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_overlay_row_label(row_rect: Rect2, text: String, font_size: int, color: Color) -> void:
	# draw_string origin is the text baseline, not the row-rect top-left.
	var font: Font = ThemeDB.fallback_font
	var ascent: float = font.get_ascent(font_size)
	var descent: float = font.get_descent(font_size)
	var baseline_y: float = row_rect.position.y + (row_rect.size.y - ascent - descent) * 0.5 + ascent
	var pos: Vector2 = Vector2(row_rect.position.x, baseline_y)
	_paint_canvas().draw_string(font, pos + Vector2(1.0, 1.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PROVISIONAL_LABEL_SHADOW)
	_paint_canvas().draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _hud_left_gutter() -> float:
	return ROSTER_ROW_WIDTH + ROSTER_CAMERA_GUTTER_PAD


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
