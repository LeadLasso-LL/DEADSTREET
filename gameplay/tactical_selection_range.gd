extends Node2D
## Read-only weapon reach. A circle in tactical space, projected onto the ground.
## It does not claim line of sight, accuracy, or immediate firing readiness.
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
const RangeShader = preload("res://gameplay/tactical_selection_range.gdshader")
const FADE_IN_SECONDS := 0.12
const GroupShader = preload("res://gameplay/tactical_group_range.gdshader")
const MAX_GROUP_RANGES := 32 # Above current legal squad sizes; matches shader array.
var host: Node2D
var disc: Polygon2D
var selected_id := ""
var radius_units := 0.0
var projected_radii := Vector2.ZERO
var _fade := 0.0
var _softness := -1.0
var group_disc: Polygon2D
var group_ranges: Array = []
var _group_key := ""
var _group_bounds := Rect2()
var _group_rings := PackedVector4Array()
var _group_feathers := PackedFloat32Array()

func _ready() -> void:
	disc = Polygon2D.new()
	disc.name = "SoftRangeDisc"
	var ink := ShaderMaterial.new()
	ink.shader = RangeShader
	disc.material = ink
	add_child(disc)
	visible = false

static func describe(battle, ids: Array) -> Dictionary:
	if battle == null or battle.battle_phase != "active" or ids.size() != 1:
		return {}
	var p = battle.get_participant(str(ids[0]))
	if p == null or not p.is_alive or not p.has_battle_position:
		return {}
	if p.side_id != battle.attacker_side_id or not p.battle_position.is_finite():
		return {}
	var weapon = Weapons.for_participant(p)
	if weapon == null or not is_finite(weapon.max_range) or weapon.max_range <= 0.0:
		return {}
	return {"id": p.participant_id, "at": p.battle_position, "radius": weapon.max_range}

func _process(delta: float) -> void:
	if not is_instance_valid(host) or not host.is_visible_in_tree() or host.orders_controller == null:
		_clear()
		return
	if host.orders_controller.selection_is_all:
		_clear()
		return
	if host.orders_controller.selected_participant_ids.size() > 1:
		_process_group(delta, host.orders_controller.selected_participant_ids)
		return
	_group_key = ""
	group_ranges.clear()
	if group_disc != null:
		group_disc.hide()
	disc.show()
	var info := describe(host._battle_state(), host.orders_controller.selected_participant_ids)
	if info.is_empty():
		_clear()
		return
	if selected_id != info.id:
		selected_id = info.id
		_fade = 0.0
	radius_units = float(info.radius)
	position = host._to_view(info.at)
	var radii: Vector2 = host._to_view(Vector2.ONE * radius_units) - host._to_view(Vector2.ZERO)
	if radii != projected_radii:
		projected_radii = radii
		disc.polygon = PackedVector2Array([Vector2(-radii.x, -radii.y), Vector2(radii.x, -radii.y), radii, Vector2(-radii.x, radii.y)])
		disc.material.set_shader_parameter("radii", radii)
	# Keep the feather gentle at both inspection zoom and the wide battle view.
	var screen_minor := minf(get_global_transform_with_canvas().x.length() * radii.x, get_global_transform_with_canvas().y.length() * radii.y)
	var softness := clampf(2.4 / maxf(screen_minor, 1.0), 0.004, 0.045)
	if not is_equal_approx(softness, _softness):
		_softness = softness
		disc.material.set_shader_parameter("softness", softness)
	_fade = minf(1.0, _fade + delta / FADE_IN_SECONDS)
	modulate.a = smoothstep(0.0, 1.0, _fade)
	visible = true

func _clear() -> void:
	group_ranges.clear()
	_group_key = ""
	if group_disc != null:
		group_disc.hide()
	visible = false
	selected_id = ""
	radius_units = 0.0
	_fade = 0.0


static func describe_group(battle, ids: Array) -> Array:
	if ids.size() < 2 or ids.size() > MAX_GROUP_RANGES:
		return []
	var rows := []
	var seen := {}
	var weapon_class := ""
	for id in ids:
		if seen.has(id):
			continue
		seen[id] = true
		var info := describe(battle, [id])
		if info.is_empty():
			return []
		var current_class: String = battle.get_participant(str(id)).weapon_type
		if not weapon_class.is_empty() and current_class != weapon_class:
			return []
		weapon_class = current_class
		rows.append(info)
	return rows if rows.size() > 1 else []

func _process_group(delta: float, ids: Array) -> void:
	var rows := describe_group(host._battle_state(), ids)
	if rows.is_empty():
		_clear()
		return
	if group_disc == null:
		group_disc = Polygon2D.new()
		group_disc.name = "SoftClassRanges"
		var ink := ShaderMaterial.new()
		ink.shader = GroupShader
		group_disc.material = ink
		add_child(group_disc)
	var key := "|".join(ids)
	if key != _group_key:
		_group_key = key
		_fade = 0.0
	selected_id = ""
	radius_units = 0.0
	position = Vector2.ZERO
	disc.hide()
	group_disc.show()
	group_ranges = rows
	var rings := PackedVector4Array()
	var feathers := PackedFloat32Array()
	var bounds := Rect2()
	var transform := get_global_transform_with_canvas()
	for row in rows:
		var center: Vector2 = host._to_view(row.at)
		var radii: Vector2 = host._to_view(Vector2.ONE * float(row.radius)) - host._to_view(Vector2.ZERO)
		rings.append(Vector4(center.x, center.y, radii.x, radii.y))
		var minor := minf(transform.x.length() * radii.x, transform.y.length() * radii.y)
		feathers.append(clampf(2.4 / maxf(minor, 1.0), 0.004, 0.045))
		var area := Rect2(center - radii, radii * 2.0)
		bounds = area if rings.size() == 1 else bounds.merge(area)
	if bounds != _group_bounds:
		_group_bounds = bounds
		group_disc.polygon = PackedVector2Array([bounds.position, Vector2(bounds.end.x, bounds.position.y), bounds.end, Vector2(bounds.position.x, bounds.end.y)])
	if rings != _group_rings or feathers != _group_feathers:
		_group_rings = rings.duplicate()
		_group_feathers = feathers.duplicate()
		group_disc.material.set_shader_parameter("range_count", rings.size())
		rings.resize(MAX_GROUP_RANGES)
		feathers.resize(MAX_GROUP_RANGES)
		group_disc.material.set_shader_parameter("rings", rings)
		group_disc.material.set_shader_parameter("feathers", feathers)
	_fade = minf(1.0, _fade + delta / FADE_IN_SECONDS)
	modulate.a = smoothstep(0.0, 1.0, _fade)
	visible = true
