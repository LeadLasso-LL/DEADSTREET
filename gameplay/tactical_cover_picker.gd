extends Node2D
## A presentation-time gesture. The controller still owns every actual cover order.
const Navigation = preload("res://battle/navigation/battle_navigation_service.gd")
const HOLD_SECONDS := 0.25
const SLOT_INK := Color(0.86, 0.89, 0.92)
var host: Node2D
var active := false
var cover_id := ""
var owner_id := ""
var choices: Array = []
var chosen: Dictionary = {}
var confirmation: Dictionary = {}
var _press := Vector2.ZERO
var _mouse := Vector2.ZERO
var _held := 0.0
var _refresh := 0.0
var _sequence := 0
var _additive := false
var _consume_release := false
var _faded_art: CanvasItem
var _original_alpha := 1.0

func _ready() -> void:
	var ink_material := CanvasItemMaterial.new()
	ink_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = ink_material # Keep the silverish white consistent under night lighting.

func controller():
	return host.orders_controller

func _input(event: InputEvent) -> void:
	# Finish an owned gesture even when a GUI panel would consume its release.
	if cover_id.is_empty():
		return
	if event is InputEventMouseButton and (not event.pressed or event.button_index == MOUSE_BUTTON_RIGHT):
		if handle_input(event):
			get_viewport().set_input_as_handled()
	elif active and event is InputEventMouseMotion:
		handle_input(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if handle_input(event):
			get_viewport().set_input_as_handled()

func valid_owner() -> bool:
	var c = controller()
	if c == null or c.selected_participant_ids.size() != 1 or c.selected_participant_id != owner_id or c.feedback_sequence != _sequence or not c.pending_command_id.is_empty():
		return false
	var p = c._controllable_selected()
	return p != null and not p.is_wounded

func handle_input(event: InputEvent) -> bool:
	if not cover_id.is_empty() and not valid_owner():
		cancel()
	if not cover_id.is_empty():
		if (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
			cancel()
			controller().feedback = "Order cancelled"
			return true
		if event is InputEventMouseMotion:
			_mouse = event.position
			if not active and _press.distance_to(_mouse) > 8.0:
				# Dragging before the hold threshold remains ordinary box selection.
				var c = controller()
				c.dragging = true
				c.drag_start = _press
				c.drag_end = _mouse
				c.drag_additive = _additive
				cancel()
				_consume_release = false
				return false
			if active:
				choose_nearest()
			return true
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return false
	if not event.pressed:
		if not cover_id.is_empty():
			_mouse = event.position
			if host.command_feedback_layer.pointer_is_over_ui(_mouse):
				cancel()
			elif active:
				# Revalidate this exact candidate; never silently switch to a new one.
				var selected_id: String = "" if chosen.is_empty() else chosen.slot.cover_slot_id
				var selected_position: Vector2 = Vector2.ZERO if chosen.is_empty() else chosen.slot.position
				var id := cover_id
				var unit_id := owner_id
				cancel()
				var result = controller().issue_cover_slot(id, selected_id)
				if result.success:
					confirmation = {"at":selected_position, "id":unit_id, "age":0.0}
			else:
				var id := cover_id
				cancel()
				controller().issue_cover(id)
			_consume_release = false
			queue_redraw()
			return true
		if _consume_release:
			_consume_release = false
			return true
		return false
	_consume_release = false
	var c = controller()
	if c.selected_participant_ids.size() != 1 or not c.pending_command_id.is_empty() or event.shift_pressed:
		return false
	var p = c._controllable_selected()
	if p == null or p.is_wounded or host.command_feedback_layer.pointer_is_over_ui(event.position):
		return false
	if not host.hit_test_pointer_unit(event.position).is_empty():
		return false # Badges and bodies keep priority over the cover behind them.
	var id: String = host.hit_test_cover_object(host.viewport_to_local_position(event.position))
	if id.is_empty():
		return false
	cover_id = id
	owner_id = c.selected_participant_id
	_sequence = c.feedback_sequence
	_press = event.position
	_mouse = event.position
	_additive = event.shift_pressed
	_held = 0.0
	c.dragging = false
	confirmation.clear()
	return true

func tick(delta: float) -> void:
	if not confirmation.is_empty():
		confirmation.age += delta
		if confirmation.age >= 0.75 or not controller().is_selected(confirmation.id):
			confirmation.clear()
	if not cover_id.is_empty():
		if not valid_owner():
			cancel()
		else:
			_held += delta
			if not active and _held >= HOLD_SECONDS:
				choices = controller().cover_choices(cover_id)
				active = true
				choose_nearest()
				if choices.is_empty():
					controller().feedback = "No available cover positions"
			if active:
				_refresh += delta
				# Reservations may change during a live fight; don't repeatedly pathfind every slot.
				choices = choices.filter(func(row): return slot_available(row.slot))
				if not chosen.is_empty() and not slot_available(chosen.slot):
					chosen = {}
				if _refresh >= 0.2:
					_refresh = 0.0
					refresh_route()
	queue_redraw()

func slot_available(slot) -> bool:
	return slot != null and slot.is_valid() and (slot.occupied_by_participant_id.is_empty() or slot.occupied_by_participant_id == owner_id) and (slot.reserved_by_participant_id.is_empty() or slot.reserved_by_participant_id == owner_id)

func choose_nearest() -> void:
	var best: Dictionary = {}
	var distance := INF
	if not host.command_feedback_layer.pointer_is_over_ui(_mouse):
		for row in choices:
			if not slot_available(row.slot):
				continue
			var screen: Vector2 = host.get_global_transform_with_canvas() * host._to_view(row.slot.position)
			var d: float = screen.distance_squared_to(_mouse)
			if d < distance:
				distance = d
				best = row
	var old_id: String = "" if chosen.is_empty() else chosen.slot.cover_slot_id
	chosen = best
	if not chosen.is_empty() and old_id != chosen.slot.cover_slot_id:
		refresh_route()
	queue_redraw()

func refresh_route() -> void:
	if chosen.is_empty() or not valid_owner():
		return
	var route = Navigation.find_path(host._battle_state(), controller()._controllable_selected().battle_position, chosen.slot.position)
	if route == null or not route.success:
		choices.erase(chosen)
		chosen = {}
	else:
		chosen.route = route

func preview_path() -> Dictionary:
	if not active or chosen.is_empty() or not valid_owner():
		return {}
	var points := PackedVector2Array([controller()._controllable_selected().battle_position])
	points.append_array(chosen.route.waypoints)
	return {"id":owner_id, "kind":"move", "points":points, "destination":chosen.slot.position}

func fade_cover() -> void:
	if not active or is_instance_valid(_faded_art):
		return
	_faded_art = host.command_feedback_layer.cover_visual(cover_id)
	if is_instance_valid(_faded_art):
		_original_alpha = _faded_art.modulate.a
		# Leave the map's self_modulate occlusion logic and child colors intact.
		_faded_art.modulate.a = _original_alpha * 0.38

func cancel() -> void:
	if not cover_id.is_empty():
		_consume_release = true
	if is_instance_valid(_faded_art):
		_faded_art.modulate.a = _original_alpha
	_faded_art = null
	active = false
	cover_id = ""
	owner_id = ""
	choices.clear()
	chosen = {}
	_held = 0.0
	_refresh = 0.0
	queue_redraw()

func _draw() -> void:
	var pixel := 1.0 / maxf(get_global_transform_with_canvas().x.length(), 0.1)
	if active:
		for row in choices:
			var selected: bool = not chosen.is_empty() and row.slot.cover_slot_id == chosen.slot.cover_slot_id
			draw_slot(host._to_view(row.slot.position), pixel, selected, 1.0)
	if not confirmation.is_empty():
		var opacity: float = 1.0 - clampf((confirmation.age - 0.5) / 0.25, 0.0, 1.0)
		draw_slot(host._to_view(confirmation.at), pixel, true, opacity)

func draw_slot(at: Vector2, pixel: float, selected: bool, opacity: float) -> void:
	var radius: float = (7.0 if selected else 5.0) * pixel
	var ink := Color(SLOT_INK, opacity * (1.0 if selected else 0.72))
	draw_circle(at, radius + 2.0 * pixel, Color(0.04, 0.06, 0.07, opacity * 0.6))
	draw_circle(at, radius, Color(ink, opacity * (0.3 if selected else 0.1)))
	if selected:
		draw_arc(at, radius, 0.0, TAU, 32, Color(ink, opacity * 0.18), 5.0 * pixel, true)
	draw_arc(at, radius, 0.0, TAU, 32, ink, (1.5 if selected else 1.0) * pixel, true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		cancel()

func _exit_tree() -> void:
	cancel()
