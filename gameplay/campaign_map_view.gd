class_name CampaignMapView
extends Node2D

# Developer visualization only. Reads GameState; does not own campaign simulation.
# World coordinates come from RoadNode.map_position / derived TravelingForce progress.
# PIXELS_PER_UNIT is a view conversion, not a second spatial authority.

const GameFlowController := preload("res://core/game_flow_controller.gd")

const PIXELS_PER_UNIT := 64.0
const ROAD_WIDTH := 6.0
const LOCATION_HALF := 18.0
const FORCE_RADIUS := 10.0
const CAMERA_PADDING := 180.0

# Provisional visualization tints. Not Dead Street art direction.
const PROVISIONAL_BACKGROUND := Color(0.14, 0.14, 0.15, 1.0)
const PROVISIONAL_ROAD := Color(0.62, 0.62, 0.64, 1.0)
const PROVISIONAL_PLAYER_TINT := Color(0.42, 0.70, 0.92, 1.0)
const PROVISIONAL_OTHER_TINT := Color(0.86, 0.64, 0.40, 1.0)
const PROVISIONAL_NEUTRAL_TINT := Color(0.72, 0.72, 0.72, 1.0)
const PROVISIONAL_FORCE_FILL := Color(0.95, 0.92, 0.55, 1.0)
const PROVISIONAL_LABEL := Color(0.92, 0.92, 0.92, 1.0)
const PROVISIONAL_LABEL_SHADOW := Color(0.05, 0.05, 0.06, 1.0)
const PROVISIONAL_OVERLAY := Color(0.88, 0.88, 0.86, 1.0)

var game_state: GameState = null
var game_flow_controller: GameFlowController = null

var _camera: Camera2D = null
var _last_force_log: Dictionary = {}


func _ready() -> void:
	_ensure_camera()
	if _camera != null:
		_camera.enabled = true
		_camera.make_current()


func bind_campaign(p_game_state: GameState, p_controller: GameFlowController) -> void:
	game_state = p_game_state
	game_flow_controller = p_controller
	_ensure_camera()
	_frame_camera()
	queue_redraw()


func set_presentation_camera_enabled(enabled: bool) -> void:
	_ensure_camera()
	if _camera == null:
		return
	_camera.enabled = enabled
	if enabled:
		_frame_camera()
		_camera.make_current()


func _process(_delta: float) -> void:
	if not visible or game_state == null:
		return
	_log_force_positions_if_changed()
	queue_redraw()


func _draw() -> void:
	_draw_background()
	if game_state == null:
		return
	_draw_roads()
	_draw_locations()
	_draw_forces()
	_draw_overlay()


static func campaign_position_of_force(force: TravelingForce, graph: RoadGraph) -> Vector2:
	if force == null or graph == null or force.route_node_ids.is_empty():
		return Vector2.ZERO
	if force.travel_state == "at_destination" or force.route_node_ids.size() == 1:
		return _node_map_position(graph, force.route_node_ids[force.route_node_ids.size() - 1])
	var segment_index: int = force.route_segment_index
	if segment_index < 0:
		segment_index = 0
	if segment_index >= force.route_node_ids.size() - 1:
		return _node_map_position(graph, force.route_node_ids[force.route_node_ids.size() - 1])
	var from_id: String = force.route_node_ids[segment_index]
	var to_id: String = force.route_node_ids[segment_index + 1]
	var from_pos: Vector2 = _node_map_position(graph, from_id)
	var to_pos: Vector2 = _node_map_position(graph, to_id)
	var segment: RoadSegment = graph.get_open_segment_between(from_id, to_id)
	var segment_distance: float = 0.0
	if segment != null:
		segment_distance = segment.distance
	if segment_distance <= 0.0:
		return from_pos
	var t: float = clampf(force.distance_into_segment / segment_distance, 0.0, 1.0)
	return from_pos.lerp(to_pos, t)


static func _node_map_position(graph: RoadGraph, node_id: String) -> Vector2:
	if graph == null or node_id.is_empty():
		return Vector2.ZERO
	var node: RoadNode = graph.get_node(node_id)
	if node == null:
		return Vector2.ZERO
	return node.map_position


func _to_view(campaign_pos: Vector2) -> Vector2:
	return campaign_pos * PIXELS_PER_UNIT


func _ensure_camera() -> void:
	if _camera != null:
		return
	_camera = get_node_or_null("Camera2D") as Camera2D


func _frame_camera() -> void:
	_ensure_camera()
	if _camera == null or game_state == null or game_state.road_graph == null:
		return
	var graph: RoadGraph = game_state.road_graph
	var first: bool = true
	var bounds: Rect2 = Rect2()
	var node_ids: Array[String] = _sorted_keys(graph.nodes)
	for node_id: String in node_ids:
		var node: RoadNode = graph.get_node(node_id)
		if node == null:
			continue
		var view_pos: Vector2 = _to_view(node.map_position)
		if first:
			bounds = Rect2(view_pos, Vector2.ZERO)
			first = false
		else:
			bounds = bounds.expand(view_pos)
	if first:
		return
	bounds = bounds.grow(CAMERA_PADDING)
	_camera.position = bounds.get_center()
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		viewport_size = Vector2(1152.0, 648.0)
	var zoom_x: float = viewport_size.x / maxf(bounds.size.x, 1.0)
	var zoom_y: float = viewport_size.y / maxf(bounds.size.y, 1.0)
	var zoom: float = clampf(minf(zoom_x, zoom_y), 0.2, 2.5)
	_camera.zoom = Vector2(zoom, zoom)


func _draw_background() -> void:
	var origin: Vector2 = Vector2(-4000.0, -4000.0)
	draw_rect(Rect2(origin, Vector2(8000.0, 8000.0)), PROVISIONAL_BACKGROUND, true)


func _draw_roads() -> void:
	var graph: RoadGraph = game_state.road_graph
	if graph == null:
		return
	var segment_ids: Array[String] = _sorted_keys(graph.segments)
	for segment_id: String in segment_ids:
		var segment: RoadSegment = graph.get_segment(segment_id)
		if segment == null:
			continue
		var a: RoadNode = graph.get_node(segment.node_a_id)
		var b: RoadNode = graph.get_node(segment.node_b_id)
		if a == null or b == null:
			continue
		draw_line(_to_view(a.map_position), _to_view(b.map_position), PROVISIONAL_ROAD, ROAD_WIDTH, true)


func _draw_locations() -> void:
	var location_ids: Array[String] = _sorted_keys(game_state.map_locations)
	for location_id: String in location_ids:
		var location: MapLocation = game_state.get_map_location(location_id)
		if location == null:
			continue
		var campaign_pos: Vector2 = _location_campaign_position(location)
		var view_pos: Vector2 = _to_view(campaign_pos)
		var owner_id: String = ""
		if location is Building:
			owner_id = (location as Building).owner_faction_id
		var tint: Color = _faction_tint(owner_id)
		if location is Stronghold:
			_draw_keep_marker(view_pos, tint)
			_draw_label(view_pos + Vector2(0.0, LOCATION_HALF + 6.0), "PLAYER STRONGHOLD")
			_draw_label(view_pos + Vector2(0.0, LOCATION_HALF + 22.0), "%s  owner=%s" % [location.id, owner_id], 12)
		elif location is NeighborhoodHQ:
			_draw_hq_marker(view_pos, tint)
			_draw_label(view_pos + Vector2(0.0, LOCATION_HALF + 6.0), "RIVAL HQ")
			_draw_label(view_pos + Vector2(0.0, LOCATION_HALF + 22.0), "%s  owner=%s" % [location.id, owner_id], 12)
		else:
			draw_circle(view_pos, 8.0, tint, true)
			_draw_label(view_pos + Vector2(0.0, 14.0), location.id, 12)


func _draw_forces() -> void:
	var graph: RoadGraph = game_state.road_graph
	var force_ids: Array[String] = _sorted_keys(game_state.traveling_forces)
	for force_id: String in force_ids:
		var force: TravelingForce = game_state.get_traveling_force(force_id)
		if force == null:
			continue
		var view_pos: Vector2 = _to_view(campaign_position_of_force(force, graph))
		var ring: Color = _faction_tint(force.faction_id)
		draw_circle(view_pos, FORCE_RADIUS + 3.0, ring, false, 2.0, true)
		draw_circle(view_pos, FORCE_RADIUS, PROVISIONAL_FORCE_FILL, true)
		_draw_label(view_pos + Vector2(0.0, -FORCE_RADIUS - 18.0), force.id)
		_draw_label(view_pos + Vector2(0.0, -FORCE_RADIUS - 4.0), force.faction_id, 12)


func _draw_overlay() -> void:
	var mode: String = ""
	var pending: PackedStringArray = PackedStringArray()
	if game_flow_controller != null:
		mode = game_flow_controller.get_current_mode()
		pending = PackedStringArray(game_flow_controller.list_pending_battle_ids())
	var turn: int = 0
	if game_state != null:
		turn = game_state.current_turn
	var origin: Vector2 = _overlay_origin()
	_draw_label_left(origin, "mode=%s  turn=%s" % [mode, turn], 16, PROVISIONAL_OVERLAY)
	_draw_label_left(origin + Vector2(0.0, 20.0), "pending=%s" % ",".join(pending), 14, PROVISIONAL_OVERLAY)


func _draw_keep_marker(view_pos: Vector2, tint: Color) -> void:
	var size: Vector2 = Vector2(LOCATION_HALF * 2.0, LOCATION_HALF * 2.0)
	var rect: Rect2 = Rect2(view_pos - size * 0.5, size)
	draw_rect(rect, tint, true)
	draw_rect(rect, Color(0.08, 0.08, 0.09, 1.0), false, 2.0)


func _draw_hq_marker(view_pos: Vector2, tint: Color) -> void:
	var s: float = LOCATION_HALF
	var points: PackedVector2Array = PackedVector2Array(
		[
			view_pos + Vector2(0.0, -s),
			view_pos + Vector2(s, 0.0),
			view_pos + Vector2(0.0, s),
			view_pos + Vector2(-s, 0.0),
		]
	)
	draw_colored_polygon(points, tint)
	draw_polyline(points, Color(0.08, 0.08, 0.09, 1.0), 2.0, true)
	draw_line(points[points.size() - 1], points[0], Color(0.08, 0.08, 0.09, 1.0), 2.0, true)


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


func _overlay_origin() -> Vector2:
	if _camera == null:
		return Vector2(16.0, 24.0)
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		viewport_size = Vector2(1152.0, 648.0)
	var half: Vector2 = (viewport_size / _camera.zoom) * 0.5
	return _camera.position - half + Vector2(16.0, 28.0)


func _location_campaign_position(location: MapLocation) -> Vector2:
	if location == null:
		return Vector2.ZERO
	if game_state != null and game_state.road_graph != null and not location.road_node_id.is_empty():
		var node: RoadNode = game_state.road_graph.get_node(location.road_node_id)
		if node != null:
			return node.map_position
	return location.map_position


func _faction_tint(faction_id: String) -> Color:
	if faction_id.is_empty() or game_state == null:
		return PROVISIONAL_NEUTRAL_TINT
	var faction: Faction = game_state.get_faction(faction_id)
	if faction is MajorGang and (faction as MajorGang).controller_type == "player":
		return PROVISIONAL_PLAYER_TINT
	return PROVISIONAL_OTHER_TINT


func _log_force_positions_if_changed() -> void:
	if game_state == null:
		return
	var graph: RoadGraph = game_state.road_graph
	var seen: Dictionary = {}
	var force_ids: Array[String] = _sorted_keys(game_state.traveling_forces)
	for force_id: String in force_ids:
		var force: TravelingForce = game_state.get_traveling_force(force_id)
		if force == null:
			continue
		var pos: Vector2 = campaign_position_of_force(force, graph)
		var signature: String = "%s|%s|%s|%s|%s" % [
			pos.x,
			pos.y,
			force.travel_state,
			force.route_segment_index,
			force.distance_into_segment,
		]
		seen[force_id] = signature
		if str(_last_force_log.get(force_id, "")) == signature:
			continue
		print(
			"CampaignMapView: force=%s faction=%s state=%s campaign_pos=(%s, %s) segment=%s into=%s"
			% [
				force.id,
				force.faction_id,
				force.travel_state,
				pos.x,
				pos.y,
				force.route_segment_index,
				force.distance_into_segment,
			]
		)
	_last_force_log = seen


func _sorted_keys(collection: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in collection:
		ids.append(str(key))
	ids.sort()
	return ids
