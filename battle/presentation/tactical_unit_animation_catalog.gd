class_name TacticalUnitAnimationCatalog
extends RefCounted

# Cached SpriteFrames for tactical people.
# Canonical 8-direction clip schema for a future accepted character set.
# Approved pixel outfits with equipment-independent cached atlases.
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
const CLIP_DEATH_BACK := "death_back"
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

const DEFAULT_ART_PPU := 38.0
const DEFAULT_FOOT_OFFSET_Y := -46.0

static var _texture_cache: Dictionary = {}
static var _frames_cache: Dictionary = {}


static func animation_name(clip_id: String, direction_id: String) -> String:
	return "%s_%s" % [clip_id, direction_id]


static func clip_loops(clip_id: String) -> bool:
	return bool(manifest().get("clips", {}).get(clip_id, {}).get("loop", false))


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
		CLIP_DEATH,
		CLIP_DEATH_BACK
	]


static var _manifest: Dictionary = {}

static func manifest() -> Dictionary:
	if _manifest.is_empty():
		var value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/manifest.json"))
		if value is Dictionary:
			_manifest = value
	return _manifest

static func variant_for(gang: String, weapon: String) -> String:
	var outfit: String = ""
	match gang:
		"local_street_gang": outfit = "0"
		"russian_organized_crime": outfit = "1"
		"italian_mob": outfit = "2"
	var gun: String = ""
	match weapon:
		"rifle": gun = "ak_rifle"
		"shotgun": gun = "pump_shotgun"
		"smg": gun = "uzi_smg"
		"pistol": gun = "pistol"
	if outfit.is_empty() or gun.is_empty():
		return ""
	return outfit + "_" + gun

static func bound_variant_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(manifest().get("variants", []))
	return result

static func bound_clip_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(manifest().get("clips", {}).keys())
	return result

static func has_bound_frames(_participant_id: String, gang: String, weapon: String) -> bool:
	return bound_variant_ids().has(variant_for(gang, weapon))

static func playback_clip_id(clip_id: String) -> String:
	return clip_id if bound_clip_ids().has(clip_id) else CLIP_IDLE

static func clip_frame_count(clip_id: String) -> int:
	return int(manifest().get("clips", {}).get(clip_id, {}).get("count", 0))

static func clip_fps(clip_id: String) -> float:
	return float(manifest().get("clips", {}).get(clip_id, {}).get("fps", 1.0))

static func frames_for(variant_id: String) -> SpriteFrames:
	if not bound_variant_ids().has(variant_id):
		return null
	if _frames_cache.has(variant_id):
		return _frames_cache[variant_id] as SpriteFrames
	var atlas: Texture2D = _texture("res://assets/art/units/pixel_v1/" + variant_id + ".png")
	if atlas == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var directions: Array = manifest()["directions"]
	var rows: int = int(manifest()["rows_per_direction"])
	for clip: String in bound_clip_ids():
		var spec: Dictionary = manifest()["clips"][clip]
		var clip_atlas: Texture2D=atlas
		if spec.get("atlas", "") in ["death_back","check_comrade"]:
			var extra_path="res://assets/art/units/pixel_v1/"+str(spec.atlas)+"/"+variant_id+".png"
			if not FileAccess.file_exists(extra_path):continue
			clip_atlas=_texture(extra_path)
		for d in range(directions.size()):
			var anim: String = animation_name(clip, str(directions[d]))
			frames.add_animation(anim)
			frames.set_animation_speed(anim, float(spec["fps"]))
			frames.set_animation_loop(anim, bool(spec["loop"]))
			for i in range(int(spec["count"])):
				var cell: int = int(spec["start"]) + i
				var tex := AtlasTexture.new()
				tex.atlas = clip_atlas
				tex.region = Rect2((cell % 32) * 128, (d * rows + cell / 32) * 128, 128, 128)
				if spec.get("atlas", "") in ["death_back","check_comrade"]:tex.region=Rect2(i*128,d*128,128,128)
				frames.add_frame(anim, tex)
	_frames_cache[variant_id] = frames
	return frames


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
