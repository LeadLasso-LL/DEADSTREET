extends Node2D
## Read-only weapon reach. A circle in tactical space, projected onto the ground.
## It does not claim line of sight, accuracy, or immediate firing readiness.
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
const RangeShader = preload("res://gameplay/tactical_selection_range.gdshader")
const FADE_IN_SECONDS := 0.12
var host: Node2D
var disc: Polygon2D
var selected_id := ""
var radius_units := 0.0
var projected_radii := Vector2.ZERO
var _fade := 0.0
var _softness := -1.0

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
	visible = false
	selected_id = ""
	radius_units = 0.0
	_fade = 0.0
