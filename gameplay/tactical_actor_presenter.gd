class_name TacticalActorPresenter
extends RefCounted

# Retained dynamic actor visuals. Creates sprites once and syncs transforms.
# Does not own vehicle physics, cover, combat, or selection hit-testing.
#
# UNIT_VISUALS_ENABLED stays false until M7B calibration art is approved.
# The unit_root / claims_participant extension remains; rejected M7 sprites
# must not be claimed.

const BattleVisualBinding := preload("res://battle/presentation/battle_visual_binding.gd")
const TacticalVisualCatalog := preload("res://battle/presentation/tactical_visual_catalog.gd")
const TacticalParticipantVisual := preload("res://battle/presentation/tactical_participant_visual.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")

const UNIT_WOUNDED_MODULATE := Color(0.78, 0.62, 0.52, 0.92)
const UNIT_DEAD_MODULATE := Color(0.48, 0.46, 0.44, 0.82)
const UNIT_VISUALS_ENABLED := false

var root: Node2D = null
var unit_root: Node2D = null
var pixels_per_unit: float = 8.0
var spawn_count: int = 0
var unit_spawn_count: int = 0
var _sprites: Dictionary = {}
var _claimed: Dictionary = {}
var _unit_nodes: Dictionary = {}
var _claimed_participants: Dictionary = {}


func bind_root(p_root: Node2D, p_pixels_per_unit: float) -> void:
	root = p_root
	pixels_per_unit = p_pixels_per_unit


func bind_unit_root(p_unit_root: Node2D) -> void:
	unit_root = p_unit_root


func claims_vehicle(vehicle_id: String) -> bool:
	return _claimed.has(vehicle_id)


func claims_participant(participant_id: String) -> bool:
	return _claimed_participants.has(participant_id)


func sprite_instance_id(vehicle_id: String) -> int:
	if not _sprites.has(vehicle_id):
		return 0
	var sprite: Sprite2D = _sprites[vehicle_id] as Sprite2D
	if sprite == null:
		return 0
	return sprite.get_instance_id()


func unit_node_instance_id(participant_id: String) -> int:
	if not _unit_nodes.has(participant_id):
		return 0
	var node: Node2D = _unit_nodes[participant_id] as Node2D
	if node == null:
		return 0
	return node.get_instance_id()


func unit_view_position(participant_id: String) -> Vector2:
	if not _unit_nodes.has(participant_id):
		return Vector2.ZERO
	var node: Node2D = _unit_nodes[participant_id] as Node2D
	if node == null:
		return Vector2.ZERO
	return node.position


func sync_dynamic(battle_state: BattleState) -> void:
	_claimed.clear()
	_claimed_participants.clear()
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
	_sync_units(battle_state)


func _sync_units(battle_state: BattleState) -> void:
	var wanted_units: Dictionary = {}
	if (not UNIT_VISUALS_ENABLED) or unit_root == null:
		_prune_unwanted_units(wanted_units)
		return
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or not participant.has_battle_position:
			continue
		if not participant.has_identity():
			continue
		if not _ensure_unit_node(participant):
			continue
		wanted_units[participant.participant_id] = true
		_claimed_participants[participant.participant_id] = true
		_apply_unit_transform(battle_state, participant)
	_prune_unwanted_units(wanted_units)


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


func _ensure_unit_node(_participant: BattleParticipant) -> bool:
	# Rejected M7 static body + side-profile weapon overlays must not spawn.
	# M7B will construct retained directional animation nodes here.
	return false


func _apply_unit_transform(battle_state: BattleState, participant: BattleParticipant) -> void:
	if not _unit_nodes.has(participant.participant_id):
		return
	var node: Node2D = _unit_nodes[participant.participant_id] as Node2D
	if node == null:
		return
	node.position = TacticalParticipantVisual.view_origin(battle_state, participant, pixels_per_unit)
	if not participant.is_alive:
		node.modulate = UNIT_DEAD_MODULATE
	elif participant.is_wounded:
		node.modulate = UNIT_WOUNDED_MODULATE
	else:
		node.modulate = Color.WHITE
	# Painted faux-depth humans must not continuously rotate. M7B selects
	# directional animation from TacticalParticipantVisual.facing instead.
	node.rotation = 0.0
	node.scale = Vector2.ONE


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


func _prune_unwanted_units(wanted: Dictionary) -> void:
	var stale: Array[String] = []
	for participant_id: Variant in _unit_nodes.keys():
		var id_str: String = str(participant_id)
		if wanted.has(id_str):
			continue
		stale.append(id_str)
	for id_str: String in stale:
		var node: Node2D = _unit_nodes[id_str] as Node2D
		_unit_nodes.erase(id_str)
		_claimed_participants.erase(id_str)
		if node != null and is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()


func _clear_all() -> void:
	_prune_unwanted({})
	_prune_unwanted_units({})
	_claimed.clear()
	_claimed_participants.clear()
