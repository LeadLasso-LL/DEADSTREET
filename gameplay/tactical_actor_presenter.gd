class_name TacticalActorPresenter
extends RefCounted

# Retained dynamic actor visuals. Creates sprites once and syncs transforms.
# Does not own vehicle physics, cover, combat, or selection hit-testing.
#
# UNIT_VISUALS_ENABLED keeps the retained actor path available for a future
# accepted character set. No painted unit is bound today; unclaimed soldiers
# use the procedural TacticalBattleView fallback.
# Painted humans select directional clips; they are not continuously rotated.

const BattleVisualBinding := preload("res://battle/presentation/battle_visual_binding.gd")
const TacticalVisualCatalog := preload("res://battle/presentation/tactical_visual_catalog.gd")
const TacticalUnitAnimationCatalog := preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const TacticalParticipantVisual := preload("res://battle/presentation/tactical_participant_visual.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")

const UNIT_WOUNDED_MODULATE := Color(0.78, 0.62, 0.52, 0.92)
const UNIT_DEAD_MODULATE := Color(0.48, 0.46, 0.44, 0.82)
const UNIT_VISUALS_ENABLED := true

var root: Node2D = null
var unit_root: Node2D = null
var pixels_per_unit: float = 8.0
var spawn_count: int = 0
var unit_spawn_count: int = 0
var _sprites: Dictionary = {}
var _claimed: Dictionary = {}
var _unit_nodes: Dictionary = {}
var _claimed_participants: Dictionary = {}
var _unit_dirs: Dictionary = {}
var _unit_anims: Dictionary = {}
var _unit_clips: Dictionary = {}
var _unit_cooldowns: Dictionary = {}
var _motion: Dictionary = {}
var _muzzles: Dictionary = {}
var _abdomen: Dictionary = {}
var _blood_masks: Dictionary = {}
var blood_enabled := true
var blood_layer: Node2D


func shot_muzzle_position(id: String) -> Vector2:
	return _motion.get(id, {}).get("shot_muzzle", Vector2.INF)



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


func unit_direction_id(participant_id: String) -> String:
	return str(_unit_dirs.get(participant_id, ""))


func unit_animation_name(participant_id: String) -> String:
	return str(_unit_anims.get(participant_id, ""))


func unit_clip_id(participant_id: String) -> String:
	return str(_unit_clips.get(participant_id, ""))


func sync_dynamic(battle_state: BattleState) -> void:
	if unit_root != null and blood_layer == null:
		blood_layer=load("res://gameplay/tactical_blood_layer.gd").new()
		blood_layer.name="BloodPresentation"
		blood_layer.z_index=1
		unit_root.get_parent().add_child(blood_layer)
	if blood_layer != null:
		blood_layer.enabled=blood_enabled
		blood_layer.sync(battle_state)
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
		if not _ensure_unit_node(battle_state, participant):
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


func _ensure_unit_node(battle_state: BattleState, participant: BattleParticipant) -> bool:
	if OS.get_cmdline_user_args().has("--baseline-visuals"):
		return false
	if participant == null or not participant.has_identity():
		return false
	if not TacticalUnitAnimationCatalog.has_bound_frames(
		participant.participant_id,
		participant.identity.gang_archetype_id,
		participant.weapon_type, participant.weapon_model_id
	):
		return false
	var frames: SpriteFrames = TacticalUnitAnimationCatalog.frames_for(
		TacticalUnitAnimationCatalog.variant_for(participant.identity.gang_archetype_id, participant.weapon_type, participant.weapon_model_id)
	)
	if frames == null:
		return false
	if _unit_nodes.has(participant.participant_id):
		var existing: Node2D = _unit_nodes[participant.participant_id] as Node2D
		if existing != null and is_instance_valid(existing):
			var current := existing.get_node("body") as AnimatedSprite2D
			if current.sprite_frames != frames:
				current.sprite_frames = frames
				_motion.erase(participant.participant_id)
			return true
	var art_ppu: float = TacticalUnitAnimationCatalog.art_pixels_per_unit()
	if art_ppu <= 0.0 or pixels_per_unit <= 0.0:
		return false
	var node: Node2D = Node2D.new()
	node.name = "unit_%s" % participant.participant_id
	var body: AnimatedSprite2D = AnimatedSprite2D.new()
	body.name = "body"
	body.sprite_frames = frames
	body.centered = true
	body.offset = TacticalUnitAnimationCatalog.sprite_foot_offset()
	body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if battle_state.battlefield_geometry.authored_layout_id == "dead_street_dusk_v1":
		var finish := ShaderMaterial.new()
		finish.shader = load("res://assets/art/street_detail/unit_finish.gdshader")
		body.material = finish
	var view_scale: float = pixels_per_unit / art_ppu
	body.scale = Vector2(view_scale, view_scale)
	var shadow := Polygon2D.new()
	shadow.name = "foot_shadow"
	shadow.polygon = PackedVector2Array([Vector2(-4,0),Vector2(-2,-1),Vector2(3,-1),Vector2(5,0),Vector2(2,2),Vector2(-3,2)])
	shadow.color = Color(0.03,0.04,0.07,0.55)
	node.add_child(shadow)
	node.add_child(body)
	unit_root.add_child(node)
	_unit_nodes[participant.participant_id] = node
	unit_spawn_count += 1
	return true


func _apply_unit_transform(battle_state: BattleState, participant: BattleParticipant) -> void:
	if not _unit_nodes.has(participant.participant_id):
		return
	var node: Node2D = _unit_nodes[participant.participant_id] as Node2D
	if node == null:
		return
	node.position = TacticalParticipantVisual.view_origin(battle_state, participant, pixels_per_unit)
	node.rotation = 0.0
	node.scale = Vector2.ONE * (1.48 if battle_state.battlefield_geometry.authored_layout_id == "dead_street_dusk_v1" else 1.0)
	unit_root.y_sort_enabled = true
	if participant.is_wounded and participant.is_alive:
		node.modulate = Color.WHITE
	else:
		node.modulate = Color.WHITE
	var id: String = participant.participant_id
	var now: float = battle_state.elapsed_time_seconds
	var state: Dictionary = _motion.get(id, {"clip":"", "start":now, "time":now, "distance":0.0, "shot":-100.0, "sequence":0, "position":participant.battle_position})
	var dt: float = maxf(0.0, now - float(state["time"]))
	if not participant.is_alive and battle_state.battle_phase != "active":
		dt = node.get_process_delta_time()
	state["time"] = now
	state["distance"] = float(state["distance"]) + participant.battle_position.distance_to(state["position"])
	state["position"] = participant.battle_position
	for event in battle_state.combat_feedback_events:
		if event.source_participant_id == id and event.sequence_id > int(state["sequence"]):
			state["sequence"] = event.sequence_id
			state["shot"] = event.elapsed_time_seconds
	var shot_age: float = now - float(state["shot"])
	if battle_state.battle_phase != "active":
		shot_age = 100.0
	var face: Vector2 = TacticalParticipantVisual.presentation_facing(battle_state, participant)
	var previous_dir: String = str(_unit_dirs.get(id, ""))
	var dir_id: String = TacticalParticipantVisual.implemented_direction_id(face, previous_dir)
	if not participant.is_alive and not previous_dir.is_empty():
		dir_id = previous_dir
	_unit_dirs[id] = dir_id
	var clip: String = "idle"
	if not participant.is_alive:
		clip = "death"
		var sprite: AnimatedSprite2D=node.get_node("body")
		if absi(id.hash())%2==0 and sprite.sprite_frames.has_animation("death_back_"+dir_id):clip="death_back"
	elif participant.has_wound_reaction():
		clip = "hit"
	elif TacticalParticipantVisual.is_locomoting(participant):
		clip = "wounded_walk" if participant.is_wounded else "walk"
	elif participant.is_wounded:
		clip = "wounded_idle"
	elif participant.weapon_state != null and participant.weapon_state.is_reloading:
		clip = "reload"
	elif participant.has_occupied_cover_slot():
		if participant.cover_posture_phase == "exposing":
			clip = "cover_popout"
		elif participant.cover_posture_phase == "tucking":
			clip = "cover_tuck"
		elif participant.is_cover_exposed():
			clip = "cover_fire" if shot_age >= 0.0 and shot_age < 0.15 else "cover_exposed_idle"
		else:
			clip = "cover_tucked_idle"
	elif shot_age >= 0.0 and shot_age < 0.15:
		clip = "fire"
	elif participant.has_target_participant:
		clip = "aim"
	elif participant.is_wounded:
		clip = "wounded_idle"
	if state["clip"] != clip:
		state["clip"] = clip
		state["start"] = now
		state["age"] = 0.0
	state["age"] = float(state.get("age", 0.0)) + dt
	var age: float = float(state["age"])
	var body := node.get_node("body") as AnimatedSprite2D
	var anim: String = TacticalUnitAnimationCatalog.animation_name(clip, dir_id)
	if body.sprite_frames.has_animation(anim):
		body.animation = anim
		body.pause()
		var count: int = body.sprite_frames.get_frame_count(anim)
		var cursor: float = age * TacticalUnitAnimationCatalog.clip_fps(clip)
		if clip == "walk" or clip == "wounded_walk":
			# Match the authored contact travel to distance; wounded gait stays shorter.
			cursor = float(state["distance"]) / (2.7 if clip == "walk" else 2.5) * count
		elif clip == "fire" or clip == "cover_fire":
			cursor = shot_age * 20.0
		elif clip == "reload":
			var definition = load("res://battle/combat/battle_weapon_catalog.gd").for_participant(participant)
			if definition != null and definition.reload_seconds > 0.0:
				cursor = (1.0 - participant.weapon_state.reload_remaining_seconds / definition.reload_seconds) * (count - 1)
		if TacticalUnitAnimationCatalog.clip_loops(clip):
			cursor = fposmod(cursor, float(count))
		body.set_frame_and_progress(clampi(int(cursor), 0, count - 1), 0.0)
	if int(state.get("muzzle_sequence", -1)) != int(state["sequence"]):
		if _muzzles.is_empty():
			_muzzles = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/muzzles.json"))
			_merge_arsenal_anchors(_muzzles, "muzzles")
		var variant: String = TacticalUnitAnimationCatalog.variant_for(participant.identity.gang_archetype_id, participant.weapon_type, participant.weapon_model_id)
		var pose: String = "cover" if clip.begins_with("cover") else "open"
		if clip.begins_with("wounded"):
			pose = clip + "/" + str(body.frame)
		var point: Array = _muzzles.get(variant + "/" + dir_id + "/" + pose, [64.0, 64.0])
		state["shot_muzzle"] = node.position + (Vector2(float(point[0]), float(point[1])) - Vector2(64,110)) * (pixels_per_unit / TacticalUnitAnimationCatalog.art_pixels_per_unit()) * node.scale.x
		state["muzzle_sequence"] = state["sequence"]
	if body.material is ShaderMaterial:
		body.material.set_shader_parameter("blood_enabled",blood_enabled)
		body.material.set_shader_parameter("wounded_stain",participant.is_wounded and participant.is_alive and clip.begins_with("wounded"))
		if participant.is_wounded and clip.begins_with("wounded"):
			if _abdomen.is_empty():
				_abdomen=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/abdomen.json"))
				_merge_arsenal_anchors(_abdomen, "abdomen")
			var stain_variant: String=TacticalUnitAnimationCatalog.variant_for(participant.identity.gang_archetype_id,participant.weapon_type,participant.weapon_model_id)
			if not _blood_masks.has(stain_variant): _blood_masks[stain_variant]=load("res://assets/art/units/pixel_v1/blood_masks/"+TacticalUnitAnimationCatalog.base_variant(stain_variant)+".png")
			body.material.set_shader_parameter("clothing_mask",_blood_masks[stain_variant])
			var point: Array=_abdomen.get(stain_variant+"/"+dir_id+"/"+clip+"/"+str(body.frame),[64.0,64.0])
			body.material.set_shader_parameter("stain_center",Vector2(float(point[0]),float(point[1])))
	_motion[id] = state
	_unit_clips[id] = clip
	_unit_anims[id] = anim


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
		_unit_dirs.erase(id_str)
		_unit_anims.erase(id_str)
		_unit_clips.erase(id_str)
		_unit_cooldowns.erase(id_str)
		_motion.erase(id_str)
		if node != null and is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()


func _clear_all() -> void:
	_prune_unwanted({})
	_prune_unwanted_units({})
	_claimed.clear()
	_claimed_participants.clear()
func set_outline_width(width: float) -> void:
	for node in _unit_nodes.values():
		var body = node.get_node("body")
		if body.material is ShaderMaterial:
			body.material.set_shader_parameter("outline_width",width)


func _merge_arsenal_anchors(target: Dictionary, kind: String) -> void:
	var path: String = "res://assets/art/weapons/arsenal/"+kind+".json"
	if FileAccess.file_exists(path):
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if data is Dictionary: target.merge(data, true)
