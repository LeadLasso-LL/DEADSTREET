extends Node2D
## Read-only order presentation and one shared pointer pick for hover/click.
const VehicleCover = preload("res://battle/vehicles/battle_vehicle_cover_service.gd")
const MOVE_INK := Color(0.94, 0.86, 0.57, 0.62)
const TARGET_INK := Color(0.93, 0.40, 0.37, 0.64)
var host: Node2D
var hovered_id := ""
var hovered_cover_id := ""
var paths: Array = []
var _hovered_body: CanvasItem
var _hovered_badge: Control
var _hovered_cover: CanvasItem
var _cover_modulate := Color.WHITE
var _body_modulate := Color.WHITE
var _images: Dictionary = {}
var _battle_id := 0

func _ready() -> void:
	process_priority = 100

func pointer_is_over_ui(screen: Vector2) -> bool:
	if not host.get_viewport_rect().has_point(screen):
		return true
	var layer = host.get_node_or_null("CommandHudLayer")
	if layer != null and layer.get_child_count() > 0:
		var hud = layer.get_child(0)
		if hud.is_visible_in_tree() and hud.surface != null:
			var local: Vector2 = hud.surface.get_global_transform_with_canvas().affine_inverse() * screen
			if Rect2(Vector2.ZERO, hud.surface.size).has_point(local):
				return true
	return false

func pick_unit(screen: Vector2) -> String:
	var battle = host._battle_state()
	if battle == null or battle.battle_phase != "active" or pointer_is_over_ui(screen):
		return ""
	# All visible badges outrank all unit silhouettes, props and ground.
	var presentation = host.battle_presentation
	if presentation != null:
		var ids: Array = presentation.markers.keys()
		ids.reverse()
		for id in ids:
			var p = battle.get_participant(str(id))
			var badge = presentation.markers[id]
			if p == null or not p.is_alive or not p.has_battle_position or not is_instance_valid(badge) or not badge.is_visible_in_tree():
				continue
			var point: Vector2 = badge.get_global_transform_with_canvas().affine_inverse() * screen
			if Rect2(Vector2.ZERO, badge.size).has_point(point):
				return str(id)
	if host.actor_presenter == null:
		return ""
	var best := ""
	var best_depth := -INF
	for id in host.actor_presenter._unit_nodes:
		var p = battle.get_participant(str(id))
		var node = host.actor_presenter._unit_nodes[id]
		if p == null or not p.is_alive or not p.has_battle_position or not is_instance_valid(node) or not node.is_visible_in_tree():
			continue
		var body = node.get_node_or_null("body") as AnimatedSprite2D
		if body == null or not body.is_visible_in_tree() or body.sprite_frames == null:
			continue
		var texture: Texture2D = body.sprite_frames.get_frame_texture(body.animation, body.frame)
		if texture == null:
			continue
		var point: Vector2 = body.get_global_transform_with_canvas().affine_inverse() * screen - body.offset
		if body.centered:
			point += texture.get_size() * 0.5
		if body.flip_h:
			point.x = texture.get_width() - 1 - point.x
		if body.flip_v:
			point.y = texture.get_height() - 1 - point.y
		if not Rect2(Vector2.ZERO, texture.get_size()).has_point(point):
			continue
		var key: int = texture.get_instance_id()
		if not _images.has(key):
			if _images.size() >= 96:
				_images.clear()
			var im: Image = texture.get_image()
			if im == null or im.is_empty():
				continue
			if im.is_compressed():
				im.decompress()
			_images[key] = {"texture": texture, "image": im}
		var image: Image = _images[key].image
		if image.get_pixel(int(point.x), int(point.y)).a < 0.15:
			continue
		var depth: float = node.global_position.y
		if best.is_empty() or depth >= best_depth:
			best = str(id)
			best_depth = depth
	return best

static func describe_orders(battle, ids: Array) -> Array:
	var result: Array = []
	if battle == null or battle.battle_phase != "active":
		return result
	for id in ids:
		var p = battle.get_participant(str(id))
		if p == null or not p.is_alive or p.is_wounded or not p.has_battle_position or p.side_id != battle.attacker_side_id:
			continue
		var intent: String = p.current_player_intent()
		if not intent.is_empty():
			var points := PackedVector2Array([p.battle_position])
			var has_destination := false
			var destination: Vector2 = p.battle_position
			if p.has_active_navigation_path():
				for index in range(p.navigation_waypoint_index, p.navigation_waypoints.size()):
					points.append(p.navigation_waypoints[index])
				destination = p.navigation_destination
				has_destination = true
			elif p.has_player_cover_intent() and battle.battlefield_geometry != null:
				var slot = battle.battlefield_geometry.get_cover_slot(p.player_cover_slot_id)
				if slot != null:
					destination = slot.position
					has_destination = true
			elif p.has_player_order_position:
				destination = p.player_order_position
				has_destination = true
			if has_destination:
				if points[-1].distance_to(destination) > 0.02:
					points.append(destination)
				result.append({"id": str(id), "kind": "move", "points": points, "destination": destination})
		if not p.player_priority_target_id.is_empty():
			var target = battle.get_participant(p.player_priority_target_id)
			if target != null and target.is_alive and target.has_battle_position and target.side_id != p.side_id:
				result.append({"id": str(id), "kind": "target", "points": PackedVector2Array([p.battle_position, target.battle_position]), "destination": target.battle_position})
	return result

func _process(_delta: float) -> void:
	if not is_instance_valid(host):
		return
	var battle = host._battle_state()
	var current_id: int = 0 if battle == null else battle.get_instance_id()
	if current_id != _battle_id:
		_clear_hover()
		_images.clear()
		_battle_id = current_id
	var active: bool = host.is_visible_in_tree() and battle != null and battle.battle_phase == "active" and host.orders_controller != null
	visible = active
	paths = describe_orders(battle, host.orders_controller.selected_participant_ids) if active else []
	if not active:
		_clear_hover()
		return
	var screen: Vector2 = get_viewport().get_mouse_position()
	var id := pick_unit(screen)
	var cover_id := ""
	if id.is_empty() and not pointer_is_over_ui(screen) and not host.orders_controller.selected_participant_ids.is_empty() and host.orders_controller.pending_command_id.is_empty():
		cover_id = host.hit_test_cover_object(host.viewport_to_local_position(screen))
	set_hover(id, cover_id)
	queue_redraw()

func set_hover(id: String, cover_id: String) -> void:
	if id == hovered_id and cover_id == hovered_cover_id:
		if (id.is_empty() or is_instance_valid(_hovered_body)) and (cover_id.is_empty() or is_instance_valid(_hovered_cover)):
			return
	_clear_hover()
	hovered_id = id
	hovered_cover_id = cover_id
	if not id.is_empty():
		var node = host.actor_presenter._unit_nodes.get(id)
		if is_instance_valid(node):
			_hovered_body = node.get_node_or_null("body")
			if is_instance_valid(_hovered_body):
				if _hovered_body.material is ShaderMaterial:
					_hovered_body.material.set_shader_parameter("hover_amount", 1.0)
				else:
					_body_modulate = _hovered_body.modulate
					_hovered_body.modulate = _body_modulate * Color(1.35, 1.29, 1.18, 1.0)
		if host.battle_presentation != null:
			_hovered_badge = host.battle_presentation.markers.get(id)
			if is_instance_valid(_hovered_badge):
				_hovered_badge.set_hovered(true)
	elif not cover_id.is_empty():
		_hovered_cover = cover_visual(cover_id)
		if is_instance_valid(_hovered_cover):
			# Tint the artwork itself; children inherit this without drawing a hit rectangle.
			_cover_modulate = _hovered_cover.modulate
			_hovered_cover.modulate = _cover_modulate * Color(1.45, 1.36, 1.18, 1.0)

func _clear_hover() -> void:
	if is_instance_valid(_hovered_body):
		if _hovered_body.material is ShaderMaterial:
			_hovered_body.material.set_shader_parameter("hover_amount", 0.0)
		else:
			_hovered_body.modulate = _body_modulate
	if is_instance_valid(_hovered_badge):
		_hovered_badge.set_hovered(false)
	if is_instance_valid(_hovered_cover):
		_hovered_cover.modulate = _cover_modulate
	_hovered_body = null
	_hovered_badge = null
	_hovered_cover = null
	hovered_id = ""
	hovered_cover_id = ""

func cover_visual(cover_id: String) -> CanvasItem:
	var battle = host._battle_state()
	if battle == null or battle.battlefield_geometry == null:
		return null
	var cover = battle.battlefield_geometry.get_cover_object(cover_id)
	if cover == null:
		return null
	for id in host._dusk_vehicle_nodes:
		if VehicleCover.body_cover_object_id(str(id)) == cover_id or cover_id.begins_with(str(id) + "__door_"):
			return host._dusk_vehicle_nodes[id]
	var obstacle_id: String = cover.associated_obstacle_id
	if obstacle_id.begins_with("fountain_body_"):
		obstacle_id = "fountain_visual"
	for node in host._dusk_nodes:
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var prop = node.get("prop")
		if prop is Array and not prop.is_empty() and str(prop[0]) == obstacle_id:
			return node
	if host._dusk_blockade_nodes.has(obstacle_id):
		return host._dusk_blockade_nodes[obstacle_id]
	if host.static_asset_root != null:
		return host.static_asset_root.get_node_or_null("obstacle_" + obstacle_id)
	return null

func _draw() -> void:
	var pixel := 1.0 / maxf(get_global_transform_with_canvas().x.length(), 0.1)
	for row in paths:
		var ink: Color = TARGET_INK if row.kind == "target" else MOVE_INK
		var points := PackedVector2Array()
		for point in row.points:
			var projected: Vector2 = host._to_view(point)
			if points.is_empty() or points[-1].distance_squared_to(projected) > 0.01:
				points.append(projected)
		if points.size() > 1:
			draw_polyline(points, Color(ink, 0.08), 4.5 * pixel, true)
			draw_polyline(points, Color(ink, 0.14), 2.7 * pixel, true)
			draw_polyline(points, ink, 1.1 * pixel, true)
		var end: Vector2 = host._to_view(row.destination)
		draw_arc(end, 4.0 * pixel, 0.0, TAU, 28, Color(ink, 0.12), 3.5 * pixel, true)
		draw_arc(end, 4.0 * pixel, 0.0, TAU, 28, ink, 1.0 * pixel, true)

func _exit_tree() -> void:
	_clear_hover()
