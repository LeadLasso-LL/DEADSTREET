class_name TacticalUnitAnimationCatalog
extends RefCounted

const Factions := preload("res://battle/identity/faction_unit_catalog.gd")
const Weapons := preload("res://battle/combat/battle_weapon_catalog.gd")

# Cached SpriteFrames for tactical people.
# Accepted regular outfits share the same eight-direction clip schema.
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
static var _variant_lru: Array[String] = []
const MAX_CACHED_VARIANTS := 12


static func animation_name(clip_id: String, direction_id: String) -> String:
	return "%s_%s" % [clip_id, direction_id]


static func clip_loops(clip_id: String) -> bool:
	return bool(clip_specs().get(clip_id, {}).get("loop", false))


static func implemented_clip_ids() -> Array[String]:
	return bound_clip_ids()



static var _manifest: Dictionary = {}

static func manifest() -> Dictionary:
	if _manifest.is_empty():
		var value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/manifest.json"))
		if value is Dictionary:
			_manifest = value
	return _manifest

static func variant_for(gang: String, weapon: String, model_id: String = "", specialist_id: String = "") -> String:
	var faction_id: String = Factions.canonical_id(gang)
	if not faction_id.is_empty():
		var model: String = Weapons.default_model(weapon) if model_id.is_empty() else model_id
		var definition = Weapons.get_model(model)
		if definition == null or definition.weapon_type_id != weapon: return ""
		if faction_id == "mercer" and specialist_id == "mercer_dual_glock" and model == "glock_17": return "mercer_dual_glock"
		var bound: String = str(faction_manifest().get("models", {}).get(faction_id+":"+model, ""))
		if not bound.is_empty(): return bound
		# Legacy entry points still work before a roster asset build is installed.
		if not gang in ["local_street_gang", "russian_organized_crime"]: return ""
	var outfit: String = ""
	match gang:
		"local_street_gang": outfit = "0"
		"russian_organized_crime": outfit = "1"
		"italian_mob": outfit = "2"
	if outfit == "0":
		if specialist_id == "mercer_dual_glock" and model_id == "glock_17": return "mercer_dual_glock"
		var mercer_variant: String = str(mercer_manifest().get("models", {}).get(outfit+"_"+model_id, ""))
		if not mercer_variant.is_empty(): return mercer_variant
	if not model_id.is_empty():
		var model_variant: String = str(arsenal_manifest().get("models", {}).get(outfit+"_"+model_id, ""))
		if not model_variant.is_empty(): return model_variant
	var gun: String = ""
	match weapon:
		"rifle": gun = "ak_rifle"
		"shotgun": gun = "pump_shotgun"
		"smg": gun = "uzi_smg"
		"pistol": gun = "pistol"
		"sniper": gun = "ak_rifle"
	if outfit.is_empty() or gun.is_empty():
		return ""
	return outfit + "_" + gun

static func bound_variant_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(manifest().get("variants", []))
	result.append_array(arsenal_manifest().get("variants", {}).keys())
	result.append_array(mercer_manifest().get("variants", {}).keys())
	result.append_array(faction_manifest().get("variants", {}).keys())
	return result

static func bound_clip_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(clip_specs().keys())
	return result

static func has_bound_frames(_participant_id: String, gang: String, weapon: String, model_id: String = "", specialist_id: String = "") -> bool:
	return is_bound_variant(variant_for(gang, weapon, model_id, specialist_id))

static func playback_clip_id(clip_id: String) -> String:
	return clip_id if bound_clip_ids().has(clip_id) else CLIP_IDLE

static func clip_frame_count(clip_id: String) -> int:
	return int(clip_specs().get(clip_id, {}).get("count", 0))

static func clip_fps(clip_id: String) -> float:
	return float(clip_specs().get(clip_id, {}).get("fps", 1.0))

static func frames_for(variant_id: String) -> SpriteFrames:
	if not is_bound_variant(variant_id):
		return null
	if _frames_cache.has(variant_id):
		_touch_variant(variant_id)
		return _frames_cache[variant_id] as SpriteFrames
	var atlas: Texture2D = _texture(atlas_path(variant_id, "units"))
	if atlas == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var directions: Array = manifest()["directions"]
	var rows: int = int(manifest()["rows_per_direction"])
	for clip: String in bound_clip_ids():
		var spec: Dictionary = clip_specs()[clip]
		var clip_atlas: Texture2D=atlas
		if spec.get("atlas", "") in ["death_back","check_comrade","fire_left","cover_fire_left"]:
			var extra_path=atlas_path(variant_id, str(spec.atlas))
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
				if spec.get("atlas", "") in ["death_back","check_comrade","fire_left","cover_fire_left"]:tex.region=Rect2(i*128,d*128,128,128)
				frames.add_frame(anim, tex)
	_frames_cache[variant_id] = frames
	_touch_variant(variant_id)
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


static var _arsenal: Dictionary = {}
static func arsenal_manifest() -> Dictionary:
	if _arsenal.is_empty():
		var path: String = "res://assets/art/weapons/arsenal/manifest.json"
		if FileAccess.file_exists(path):
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			if data is Dictionary: _arsenal = data
	return _arsenal

static func base_variant(variant: String) -> String:
	if faction_manifest().get("variants", {}).has(variant): return str(faction_manifest().variants[variant].base)
	if mercer_manifest().get("variants", {}).has(variant): return str(mercer_manifest().variants[variant].base)
	return str(arsenal_manifest().get("variants", {}).get(variant, {}).get("base", variant))

static func atlas_path(variant: String, folder: String) -> String:
	if faction_manifest().get("variants", {}).has(variant): return "res://assets/art/units/factions/"+folder+"/"+variant+".png"
	if mercer_manifest().get("variants", {}).has(variant): return "res://assets/art/units/mercer/"+folder+"/"+variant+".png"
	var row: Dictionary = arsenal_manifest().get("variants", {}).get(variant, {})
	if not row.is_empty():
		return "res://assets/art/weapons/arsenal/"+folder+"/"+str(row.file)+".png"
	return "res://assets/art/units/pixel_v1/"+("" if folder=="units" else folder+"/")+variant+".png"


# Browsing the arsenal must not retain dozens of 4096x6144 atlases indefinitely.
# Active sprites own their frames independently, so eviction cannot blank a living unit.
static func _touch_variant(variant: String) -> void:
	_variant_lru.erase(variant)
	_variant_lru.append(variant)
	while _variant_lru.size() > MAX_CACHED_VARIANTS:
		var old: String = _variant_lru.pop_front()
		_frames_cache.erase(old)
		for folder: String in ["units", "death_back", "check_comrade", "fire_left", "cover_fire_left"]:
			_texture_cache.erase(atlas_path(old, folder))

static var _mercer: Dictionary = {}
static func mercer_manifest() -> Dictionary:
	if _mercer.is_empty():
		var path = "res://assets/art/units/mercer/manifest.json"
		if FileAccess.file_exists(path):
			var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			if data is Dictionary: _mercer = data
	return _mercer

static func clip_specs() -> Dictionary:
	var clips: Dictionary = manifest().get("clips", {}).duplicate()
	clips.merge(mercer_manifest().get("clips", {}), true)
	return clips

static func foot_anchor(variant: String) -> Vector2:
	return Vector2(64,104 if variant.begins_with("mercer_") or variant.begins_with("faction_") else 110)

static func blood_mask_path(variant: String) -> String:
	if variant.begins_with("mercer_") or variant.begins_with("faction_"): return atlas_path(variant, "blood_masks")
	return "res://assets/art/units/pixel_v1/blood_masks/"+base_variant(variant)+".png"


static var _factions: Dictionary = {}
static func faction_manifest() -> Dictionary:
	if _factions.is_empty():
		var path := "res://assets/art/units/factions/manifest.json"
		if FileAccess.file_exists(path):
			var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			if value is Dictionary: _factions = value
	return _factions

static func is_bound_variant(variant: String) -> bool:
	return faction_manifest().get("variants", {}).has(variant) or arsenal_manifest().get("variants", {}).has(variant) or mercer_manifest().get("variants", {}).has(variant) or manifest().get("variants", []).has(variant)
