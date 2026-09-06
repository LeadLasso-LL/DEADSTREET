class_name TacticalEnvironmentPresenter
extends RefCounted

# Retained static asset visuals. Rebuilds only when geometry stamp changes.
# Does not own collision, cover, hit-testing, or navigation.

const BattleVisualBinding := preload("res://battle/presentation/battle_visual_binding.gd")
const TacticalVisualCatalog := preload("res://battle/presentation/tactical_visual_catalog.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")

var root: Node2D = null
var pixels_per_unit: float = 8.0
var rebuild_count: int = 0
var _stamp: String = ""
var _claimed: Dictionary = {}


func bind_root(p_root: Node2D, p_pixels_per_unit: float) -> void:
	root = p_root
	pixels_per_unit = p_pixels_per_unit


func claims_obstacle(obstacle_id: String) -> bool:
	return _claimed.has(obstacle_id)


func sync_static(geometry: BattlefieldGeometry, stamp: String) -> void:
	if stamp == _stamp:
		return
	_rebuild(geometry, stamp)


func _rebuild(geometry: BattlefieldGeometry, stamp: String) -> void:
	_stamp = stamp
	rebuild_count += 1
	_claimed.clear()
	_clear_root()
	if root == null or geometry == null:
		return
	for binding: BattleVisualBinding in geometry.visual_bindings:
		if binding == null or not binding.is_valid():
			continue
		if binding.target_kind != BattleVisualBinding.KIND_OBSTACLE:
			continue
		if not _spawn_obstacle_visual(geometry, binding):
			continue
		_claimed[binding.target_id] = true


func _spawn_obstacle_visual(geometry: BattlefieldGeometry, binding: BattleVisualBinding) -> bool:
	var obstacle: BattleObstacle = geometry.get_obstacle(binding.target_id)
	if obstacle == null or not obstacle.bounds_are_usable():
		return false
	var spec: Dictionary = TacticalVisualCatalog.spec_for(binding.archetype_id, binding.variant_id)
	var texture: Texture2D = TacticalVisualCatalog.texture_for(spec)
	if texture == null:
		return false
	var art_ppu: float = float(spec.get("art_pixels_per_unit", 0.0))
	if art_ppu <= 0.0 or pixels_per_unit <= 0.0:
		return false
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "obstacle_%s" % binding.target_id
	sprite.texture = texture
	sprite.centered = bool(spec.get("centered", true))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var world_pos: Vector2 = obstacle.bounds.get_center() + binding.offset
	sprite.position = world_pos * pixels_per_unit
	sprite.rotation = deg_to_rad(binding.rotation_deg)
	var view_scale: float = (pixels_per_unit / art_ppu) * binding.scale
	sprite.scale = Vector2(view_scale, view_scale)
	root.add_child(sprite)
	return true


func _clear_root() -> void:
	if root == null:
		return
	for child: Node in root.get_children():
		root.remove_child(child)
		child.free()
