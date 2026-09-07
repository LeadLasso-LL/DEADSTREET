class_name TacticalUnitAnimationCatalog
extends RefCounted

# Cached SpriteFrames for tactical people.
# Canonical 8-direction clip schema for a future accepted character set.
# No painted character is bound. Runtime uses procedural fallback until a
# product-accepted variant is registered here.
# Does not own combat or TacticalBattleView.

const DIR_N := "n"
const DIR_NE := "ne"
const DIR_E := "e"
const DIR_SE := "se"
const DIR_S := "s"
const DIR_SW := "sw"
const DIR_W := "w"
const DIR_NW := "nw"

const DIRECTION_IDS_8: Array[String] = [
	DIR_N, DIR_NE, DIR_E, DIR_SE, DIR_S, DIR_SW, DIR_W, DIR_NW
]
const IMPLEMENTED_DIRECTION_IDS: Array[String] = [
	DIR_N, DIR_NE, DIR_E, DIR_SE, DIR_S, DIR_SW, DIR_W, DIR_NW
]

const CLIP_IDLE := "idle"
const CLIP_WALK := "walk"
const CLIP_AIM := "aim"
const CLIP_FIRE := "fire"
const CLIP_RELOAD := "reload"
const CLIP_COVER_EXPOSED_IDLE := "cover_exposed_idle"
const CLIP_COVER_TUCKED_IDLE := "cover_tucked_idle"
const CLIP_COVER_POPOUT := "cover_popout"
const CLIP_COVER_FIRE := "cover_fire"
const CLIP_WOUNDED_IDLE := "wounded_idle"
const CLIP_DEATH := "death"
const CLIP_COVER_TUCKED := CLIP_COVER_TUCKED_IDLE
const CLIP_COVER_EXPOSED := CLIP_COVER_EXPOSED_IDLE
const CLIP_WOUNDED := CLIP_WOUNDED_IDLE
const CLIP_HIT := "hit"
const CLIP_WOUNDED_WALK := "wounded_walk"

const IDLE_FRAME_COUNT := 6
const WALK_FRAME_COUNT := 16
const AIM_FRAME_COUNT := 2
const FIRE_FRAME_COUNT := 3
const RELOAD_FRAME_COUNT := 2
const COVER_IDLE_FRAME_COUNT := 2
const COVER_POPOUT_FRAME_COUNT := 2
const COVER_FIRE_FRAME_COUNT := 2
const WOUNDED_FRAME_COUNT := 2
const DEATH_FRAME_COUNT := 2

const IDLE_FPS := 4.0
const WALK_FPS := 12.0
const AIM_FPS := 4.0
const FIRE_FPS := 12.0
const RELOAD_FPS := 3.0
const COVER_IDLE_FPS := 3.5
const COVER_POPOUT_FPS := 12.0
const COVER_FIRE_FPS := 12.0
const WOUNDED_FPS := 3.0
const DEATH_FPS := 8.0

const DEFAULT_ART_PPU := 50.0
const DEFAULT_FOOT_OFFSET_Y := 0.0

static var _texture_cache: Dictionary = {}
static var _frames_cache: Dictionary = {}


static func animation_name(clip_id: String, direction_id: String) -> String:
	return "%s_%s" % [clip_id, direction_id]


static func clip_loops(clip_id: String) -> bool:
	return not (
		clip_id == CLIP_FIRE
		or clip_id == CLIP_COVER_FIRE
		or clip_id == CLIP_COVER_POPOUT
		or clip_id == CLIP_DEATH
	)


static func implemented_clip_ids() -> Array[String]:
	return [
		CLIP_IDLE,
		CLIP_WALK,
		CLIP_AIM,
		CLIP_FIRE,
		CLIP_RELOAD,
		CLIP_COVER_EXPOSED_IDLE,
		CLIP_COVER_TUCKED_IDLE,
		CLIP_COVER_POPOUT,
		CLIP_COVER_FIRE,
		CLIP_WOUNDED_IDLE,
		CLIP_DEATH
	]


static func bound_variant_ids() -> Array[String]:
	return []


static func bound_clip_ids() -> Array[String]:
	return []


static func has_bound_frames(
	_participant_id: String,
	_gang_archetype_id: String,
	_firearm_visual_id: String
) -> bool:
	return false


static func playback_clip_id(clip_id: String) -> String:
	if bound_clip_ids().is_empty():
		return clip_id
	if bound_clip_ids().has(clip_id):
		return clip_id
	return CLIP_IDLE


static func clip_frame_count(clip_id: String) -> int:
	match clip_id:
		CLIP_IDLE:
			return IDLE_FRAME_COUNT
		CLIP_WALK:
			return WALK_FRAME_COUNT
		CLIP_AIM:
			return AIM_FRAME_COUNT
		CLIP_FIRE:
			return FIRE_FRAME_COUNT
		CLIP_RELOAD:
			return RELOAD_FRAME_COUNT
		CLIP_COVER_EXPOSED_IDLE, CLIP_COVER_TUCKED_IDLE:
			return COVER_IDLE_FRAME_COUNT
		CLIP_COVER_POPOUT:
			return COVER_POPOUT_FRAME_COUNT
		CLIP_COVER_FIRE:
			return COVER_FIRE_FRAME_COUNT
		CLIP_WOUNDED_IDLE:
			return WOUNDED_FRAME_COUNT
		CLIP_DEATH:
			return DEATH_FRAME_COUNT
		_:
			return 0


static func clip_fps(clip_id: String) -> float:
	match clip_id:
		CLIP_IDLE:
			return IDLE_FPS
		CLIP_WALK:
			return WALK_FPS
		CLIP_AIM:
			return AIM_FPS
		CLIP_FIRE:
			return FIRE_FPS
		CLIP_RELOAD:
			return RELOAD_FPS
		CLIP_COVER_EXPOSED_IDLE, CLIP_COVER_TUCKED_IDLE:
			return COVER_IDLE_FPS
		CLIP_COVER_POPOUT:
			return COVER_POPOUT_FPS
		CLIP_COVER_FIRE:
			return COVER_FIRE_FPS
		CLIP_WOUNDED_IDLE:
			return WOUNDED_FPS
		CLIP_DEATH:
			return DEATH_FPS
		_:
			return 1.0


static func frames_for(variant_id: String) -> SpriteFrames:
	if variant_id.is_empty():
		return null
	if not bound_variant_ids().has(variant_id):
		return null
	if _frames_cache.has(variant_id):
		var cached: Variant = _frames_cache[variant_id]
		if cached is SpriteFrames:
			return cached as SpriteFrames
	return null


static func texture_cache_size() -> int:
	return _texture_cache.size()


static func frames_cache_size() -> int:
	return _frames_cache.size()


static func art_pixels_per_unit() -> float:
	return DEFAULT_ART_PPU


static func sprite_foot_offset() -> Vector2:
	return Vector2(0.0, DEFAULT_FOOT_OFFSET_Y)


static func _texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if _texture_cache.has(path):
		var cached: Variant = _texture_cache[path]
		if cached is Texture2D:
			return cached as Texture2D
	var texture: Texture2D = _load_texture(path)
	if texture == null:
		return null
	_texture_cache[path] = texture
	return texture


static func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var loaded: Resource = ResourceLoader.load(path, "Texture2D")
		if loaded is Texture2D:
			return loaded as Texture2D
	if not FileAccess.file_exists(path):
		return null
	var image: Image = Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)
