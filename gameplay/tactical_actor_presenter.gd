class_name TacticalActorPresenter
extends RefCounted

# Retained dynamic actor visuals. Creates sprites once and syncs transforms.
# Does not own vehicle physics, cover, or combat.

const BattleVisualBinding := preload("res://battle/presentation/battle_visual_binding.gd")
const TacticalVisualCatalog := preload("res://battle/presentation/tactical_visual_catalog.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")

var root: Node2D = null
var pixels_per_unit: float = 8.0
var spawn_count: int = 0
var _sprites: Dictionary = {}
var _claimed: Dictionary = {}


func bind_root(p_root: Node2D, p_pixels_per_unit: float) -> void:
	root = p_root
	pixels_per_unit = p_pixels_per_unit


func claims_vehicle(vehicle_id: String) -> bool:
	return _claimed.has(vehicle_id)


func sprite_instance_id(vehicle_id: String) -> int:
	if not _sprites.has(vehicle_id):
		return 0
	var sprite: Sprite2D = _sprites[vehicle_id] as Sprite2D
	if sprite == null:
		return 0
	return sprite.get_instance_id()


func sync_dynamic(battle_state: BattleState) -> void:
	_claimed.clear()
	if root == null or battle_state == null or battle_state.battlefield_geometry == null:
		_clear_all()
		return
	var geometry: BattlefieldGeometry = battle_state.battlefield_geometry
	var wanted: Dictionary = {}
	for binding: BattleVisualBinding in geometry.visual_bindings:
		if binding == null or not binding.is_valid():
			continue
		if binding.target_kind != BattleVisualBinding.KIND_VEHICLE:
			continue
		var vehicle: BattleVehicle = battle_state.get_vehicle(binding.target_id)
		if vehicle == null or not vehicle.has_battle_position:
			continue
		if not _ensure_vehicle_sprite(vehicle, binding):
			continue
		wanted[binding.target_id] = true
		_claimed[binding.target_id] = true
		_apply_vehicle_transform(vehicle, binding)
	_prune_unwanted(wanted)


func _ensure_vehicle_sprite(vehicle: BattleVehicle, binding: BattleVisualBinding) -> bool:
	if _sprites.has(vehicle.battle_vehicle_id):
		var existing: Sprite2D = _sprites[vehicle.battle_vehicle_id] as Sprite2D
		if existing != null and is_instance_valid(existing):
			return true
	var spec: Dictionary = TacticalVisualCatalog.spec_for(binding.archetype_id, binding.variant_id)
	var texture: Texture2D = TacticalVisualCatalog.texture_for(spec)
	if texture == null:
		return false
	var art_ppu: float = float(spec.get("art_pixels_per_unit", 0.0))
	if art_ppu <= 0.0 or pixels_per_unit <= 0.0:
		return false
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "vehicle_%s" % vehicle.battle_vehicle_id
	sprite.texture = texture
	sprite.centered = bool(spec.get("centered", true))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var view_scale: float = (pixels_per_unit / art_ppu) * binding.scale
	sprite.scale = Vector2(view_scale, view_scale)
	root.add_child(sprite)
	_sprites[vehicle.battle_vehicle_id] = sprite
	spawn_count += 1
	return true


func _apply_vehicle_transform(vehicle: BattleVehicle, binding: BattleVisualBinding) -> void:
	if not _sprites.has(vehicle.battle_vehicle_id):
		return
	var sprite: Sprite2D = _sprites[vehicle.battle_vehicle_id] as Sprite2D
	if sprite == null:
		return
	var world_pos: Vector2 = vehicle.battle_position + binding.offset
	sprite.position = world_pos * pixels_per_unit
	if vehicle.has_valid_orientation():
		sprite.rotation = vehicle.facing_direction.angle()
	else:
		sprite.rotation = deg_to_rad(binding.rotation_deg)


func _prune_unwanted(wanted: Dictionary) -> void:
	var stale: Array[String] = []
	for vehicle_id: Variant in _sprites.keys():
		var id_str: String = str(vehicle_id)
		if wanted.has(id_str):
			continue
		stale.append(id_str)
	for id_str: String in stale:
		var sprite: Sprite2D = _sprites[id_str] as Sprite2D
		_sprites.erase(id_str)
		if sprite != null and is_instance_valid(sprite):
			if sprite.get_parent() != null:
				sprite.get_parent().remove_child(sprite)
			sprite.free()


func _clear_all() -> void:
	_prune_unwanted({})
	_claimed.clear()
