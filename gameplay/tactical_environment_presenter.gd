class_name TacticalEnvironmentPresenter
extends RefCounted

# Retained static asset visuals. Rebuilds only when geometry stamp changes.
# Surfaces, buildings, optional decals, then cars/props.
# Does not own collision, cover, hit-testing, or navigation.

const BattleVisualBinding := preload("res://battle/presentation/battle_visual_binding.gd")
const TacticalVisualCatalog := preload("res://battle/presentation/tactical_visual_catalog.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleSurfaceRegion := preload("res://battle/geometry/battle_surface_region.gd")
const BattlePresentationMarking := preload("res://battle/geometry/battle_presentation_marking.gd")

var root: Node2D = null
var surface_root: Node2D = null
var building_root: Node2D = null
var detail_root: Node2D = null
var pixels_per_unit: float = 8.0
var rebuild_count: int = 0
var _stamp: String = ""
var _claimed: Dictionary = {}
var _claimed_buildings: Dictionary = {}
var _claimed_surfaces: Dictionary = {}
var _claimed_markings: Dictionary = {}
var _claimed_roof: Dictionary = {}
var _claimed_facade: Dictionary = {}


func bind_root(p_root: Node2D, p_pixels_per_unit: float) -> void:
	root = p_root
	pixels_per_unit = p_pixels_per_unit


func bind_surface_root(p_root: Node2D) -> void:
	surface_root = p_root


func bind_building_root(p_root: Node2D) -> void:
	building_root = p_root


func bind_detail_root(p_root: Node2D) -> void:
	detail_root = p_root


func claims_obstacle(obstacle_id: String) -> bool:
	return _claimed.has(obstacle_id)


func claims_building(obstacle_id: String) -> bool:
	return _claimed_buildings.has(obstacle_id)


func claims_surface(region_id: String) -> bool:
	return _claimed_surfaces.has(region_id)


func claims_marking(mark_id: String) -> bool:
	return _claimed_markings.has(mark_id)


func claims_roof_props(obstacle_id: String) -> bool:
	return _claimed_roof.has(obstacle_id)


func claims_facade(obstacle_id: String) -> bool:
	return _claimed_facade.has(obstacle_id)


func surface_child_count() -> int:
	if surface_root == null:
		return 0
	return surface_root.get_child_count()


func building_child_count() -> int:
	if building_root == null:
		return 0
	return building_root.get_child_count()


func detail_child_count() -> int:
	if detail_root == null:
		return 0
	return detail_root.get_child_count()


func sync_static(geometry: BattlefieldGeometry, stamp: String) -> void:
	if stamp == _stamp:
		return
	_rebuild(geometry, stamp)


func _rebuild(geometry: BattlefieldGeometry, stamp: String) -> void:
	_stamp = stamp
	rebuild_count += 1
	_claimed.clear()
	_claimed_buildings.clear()
	_claimed_surfaces.clear()
	_claimed_markings.clear()
	_claimed_roof.clear()
	_claimed_facade.clear()
	_clear_node(root)
	_clear_node(surface_root)
	_clear_node(building_root)
	_clear_node(detail_root)
	if geometry == null:
		return
	for binding: BattleVisualBinding in geometry.visual_bindings:
		if binding == null or not binding.is_valid():
			continue
		if binding.target_kind == BattleVisualBinding.KIND_OBSTACLE:
			if not _spawn_obstacle_visual(geometry, binding):
				continue
			_claimed[binding.target_id] = true
		elif binding.target_kind == BattleVisualBinding.KIND_SURFACE:
			_spawn_surface_visual(geometry, binding)
		elif binding.target_kind == BattleVisualBinding.KIND_BUILDING:
			_spawn_building_visual(geometry, binding)
		elif binding.target_kind == BattleVisualBinding.KIND_DECAL:
			_spawn_decal_visual(geometry, binding)


func _spawn_obstacle_visual(geometry: BattlefieldGeometry, binding: BattleVisualBinding) -> bool:
	var obstacle: BattleObstacle = geometry.get_obstacle(binding.target_id)
	if obstacle == null or not obstacle.bounds_are_usable():
		return false
	var spec: Dictionary = TacticalVisualCatalog.spec_for(binding.archetype_id, binding.variant_id)
	var texture: Texture2D = TacticalVisualCatalog.texture_for(spec)
	if texture == null:
		return false
	var sprite: Sprite2D = _make_sprite("obstacle_%s" % binding.target_id, texture, spec, binding)
	if sprite == null or root == null:
		return false
	var world_pos: Vector2 = obstacle.bounds.get_center() + binding.offset
	sprite.position = world_pos * pixels_per_unit
	root.add_child(sprite)
	return true


func _spawn_surface_visual(geometry: BattlefieldGeometry, binding: BattleVisualBinding) -> void:
	var surface: BattleSurfaceRegion = geometry.get_surface_region(binding.target_id)
	if surface == null or not surface.is_valid():
		return
	var spec: Dictionary = TacticalVisualCatalog.spec_for(binding.archetype_id, binding.variant_id)
	var texture: Texture2D = TacticalVisualCatalog.texture_for(spec)
	if texture == null:
		return
	var sprite: Sprite2D = _make_sprite("surface_%s" % binding.target_id, texture, spec, binding)
	if sprite == null or surface_root == null:
		return
	var world_pos: Vector2 = surface.bounds.get_center() + binding.offset
	sprite.position = world_pos * pixels_per_unit
	if TacticalVisualCatalog.is_pipeline_test(spec):
		sprite.visible = false
	surface_root.add_child(sprite)
	if TacticalVisualCatalog.should_claim_canvas(spec):
		_claimed_surfaces[binding.target_id] = true


func _spawn_building_visual(geometry: BattlefieldGeometry, binding: BattleVisualBinding) -> void:
	var obstacle: BattleObstacle = geometry.get_obstacle(binding.target_id)
	if obstacle == null or not obstacle.bounds_are_usable():
		return
	var spec: Dictionary = TacticalVisualCatalog.spec_for(binding.archetype_id, binding.variant_id)
	var texture: Texture2D = TacticalVisualCatalog.texture_for(spec)
	if texture == null:
		return
	var sprite: Sprite2D = _make_sprite("building_%s" % binding.target_id, texture, spec, binding)
	if sprite == null or building_root == null:
		return
	var world_pos: Vector2 = obstacle.bounds.get_center() + binding.offset
	sprite.position = world_pos * pixels_per_unit
	if TacticalVisualCatalog.is_pipeline_test(spec):
		sprite.visible = false
	building_root.add_child(sprite)
	if TacticalVisualCatalog.should_claim_canvas(spec):
		_claimed_buildings[binding.target_id] = true


func _spawn_decal_visual(geometry: BattlefieldGeometry, binding: BattleVisualBinding) -> void:
	var spec: Dictionary = TacticalVisualCatalog.spec_for(binding.archetype_id, binding.variant_id)
	var texture: Texture2D = TacticalVisualCatalog.texture_for(spec)
	if texture == null:
		return
	var sprite: Sprite2D = _make_sprite("decal_%s" % binding.target_id, texture, spec, binding)
	if sprite == null or detail_root == null:
		return
	var world_pos: Vector2 = binding.offset
	for marking: BattlePresentationMarking in geometry.presentation_markings:
		if marking == null or marking.mark_id != binding.target_id:
			continue
		world_pos = marking.bounds.get_center() + binding.offset
		break
	sprite.position = world_pos * pixels_per_unit
	if TacticalVisualCatalog.is_pipeline_test(spec):
		sprite.visible = false
	detail_root.add_child(sprite)
	if not TacticalVisualCatalog.should_claim_canvas(spec):
		return
	var suppress: String = str(spec.get("suppress_canvas", ""))
	var host_id: String = _host_obstacle_id(binding.target_id)
	if suppress == "marking":
		_claimed_markings[binding.target_id] = true
	if suppress == "roof_props" and not host_id.is_empty():
		_claimed_roof[host_id] = true
	if suppress == "facade" and not host_id.is_empty():
		_claimed_facade[host_id] = true


func _host_obstacle_id(target_id: String) -> String:
	var parts: PackedStringArray = target_id.split(":")
	if parts.size() >= 2 and (parts[0] == "roof" or parts[0] == "facade"):
		return parts[1]
	return ""


func _make_sprite(
	sprite_name: String,
	texture: Texture2D,
	spec: Dictionary,
	binding: BattleVisualBinding
) -> Sprite2D:
	var art_ppu: float = float(spec.get("art_pixels_per_unit", 0.0))
	if art_ppu <= 0.0 or pixels_per_unit <= 0.0:
		return null
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = bool(spec.get("centered", true))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.rotation = deg_to_rad(binding.rotation_deg)
	var view_scale: float = (pixels_per_unit / art_ppu) * binding.scale
	sprite.scale = Vector2(view_scale, view_scale)
	return sprite


func _clear_node(node: Node2D) -> void:
	if node == null:
		return
	for child: Node in node.get_children():
		node.remove_child(child)
		child.free()
