class_name TacticalVisualCatalog
extends RefCounted

# Resolves presentation archetype/variant ids to external textures.
# Caches Texture2D by resource path. Does not own gameplay geometry.

const ARCHETYPE_CIVILIAN_SEDAN := "civilian_sedan"
const ARCHETYPE_CIVILIAN_COMPACT := "civilian_compact"
const ARCHETYPE_CIVILIAN_SUV := "civilian_suv"
const ARCHETYPE_CIVILIAN_VAN := "civilian_van"
const ARCHETYPE_CIVILIAN_PICKUP := "civilian_pickup"
const ARCHETYPE_DUMPSTER := "dumpster"
const ARCHETYPE_TRASH_BIN := "trash_bin"
const ARCHETYPE_TRASH_PILE := "trash_pile"
const ARCHETYPE_CRATE_WOOD := "crate_wood"
const ARCHETYPE_CRATES_STACKED := "crates_stacked"
const ARCHETYPE_TABLE_UTILITY := "table_utility"

const VARIANT_TEST_01 := "test_01"
const VARIANT_CREAM_01 := "cream_01"
const VARIANT_BLUE_01 := "blue_01"
const VARIANT_GREEN_01 := "green_01"
const VARIANT_GRAY_01 := "gray_01"
const VARIANT_MAROON_01 := "maroon_01"
const VARIANT_WOOD_01 := "wood_01"
const VARIANT_OFFSET_01 := "offset_01"
const VARIANT_PAIR_01 := "pair_01"

const FALLBACK_CIVILIAN_CAR := "civilian_car"
const DEFAULT_PPU := 32.0

const SEDAN_TEST_PATH := "res://assets/tactical/vehicles/civilian_sedan_test_01.png"
const SEDAN_TEST_PPU := 32.0

static var _texture_cache: Dictionary = {}
static var _spec_table: Dictionary = {}


static func spec_for(archetype_id: String, variant_id: String) -> Dictionary:
	_ensure_specs()
	var key: String = _spec_key(archetype_id, variant_id)
	if not _spec_table.has(key):
		return {}
	var spec: Dictionary = _spec_table[key]
	return spec.duplicate()


static func has_spec(archetype_id: String, variant_id: String) -> bool:
	return not spec_for(archetype_id, variant_id).is_empty()


static func texture_for(spec: Dictionary) -> Texture2D:
	if spec.is_empty():
		return null
	var path: String = str(spec.get("resource_path", ""))
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


static func cache_size() -> int:
	return _texture_cache.size()


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


static func _spec_key(archetype_id: String, variant_id: String) -> String:
	return "%s|%s" % [archetype_id, variant_id]


static func _ensure_specs() -> void:
	if not _spec_table.is_empty():
		return
	_register(
		ARCHETYPE_CIVILIAN_SEDAN,
		VARIANT_TEST_01,
		SEDAN_TEST_PATH,
		SEDAN_TEST_PPU,
		FALLBACK_CIVILIAN_CAR
	)
	_register(
		ARCHETYPE_CIVILIAN_COMPACT,
		VARIANT_CREAM_01,
		"res://assets/tactical/vehicles/civilian_compact_cream_01.png",
		DEFAULT_PPU,
		FALLBACK_CIVILIAN_CAR
	)
	_register(
		ARCHETYPE_CIVILIAN_SEDAN,
		VARIANT_BLUE_01,
		"res://assets/tactical/vehicles/civilian_sedan_blue_01.png",
		DEFAULT_PPU,
		FALLBACK_CIVILIAN_CAR
	)
	_register(
		ARCHETYPE_CIVILIAN_SUV,
		VARIANT_GREEN_01,
		"res://assets/tactical/vehicles/civilian_suv_green_01.png",
		DEFAULT_PPU,
		FALLBACK_CIVILIAN_CAR
	)
	_register(
		ARCHETYPE_CIVILIAN_VAN,
		VARIANT_GRAY_01,
		"res://assets/tactical/vehicles/civilian_van_gray_01.png",
		DEFAULT_PPU,
		FALLBACK_CIVILIAN_CAR
	)
	_register(
		ARCHETYPE_CIVILIAN_PICKUP,
		VARIANT_MAROON_01,
		"res://assets/tactical/vehicles/civilian_pickup_maroon_01.png",
		DEFAULT_PPU,
		FALLBACK_CIVILIAN_CAR
	)
	_register(
		ARCHETYPE_DUMPSTER,
		VARIANT_GREEN_01,
		"res://assets/tactical/props/dumpster_green_01.png",
		DEFAULT_PPU,
		"dumpster"
	)
	_register(
		ARCHETYPE_DUMPSTER,
		VARIANT_BLUE_01,
		"res://assets/tactical/props/dumpster_blue_01.png",
		DEFAULT_PPU,
		"dumpster"
	)
	_register(
		ARCHETYPE_TRASH_BIN,
		VARIANT_GREEN_01,
		"res://assets/tactical/props/trash_bin_01.png",
		DEFAULT_PPU,
		"trash"
	)
	_register(
		ARCHETYPE_TRASH_PILE,
		VARIANT_GRAY_01,
		"res://assets/tactical/props/trash_pile_01.png",
		DEFAULT_PPU,
		"trash"
	)
	_register(
		ARCHETYPE_CRATE_WOOD,
		VARIANT_WOOD_01,
		"res://assets/tactical/props/crate_wood_01.png",
		DEFAULT_PPU,
		"crates"
	)
	_register(
		ARCHETYPE_CRATES_STACKED,
		VARIANT_OFFSET_01,
		"res://assets/tactical/props/crates_stacked_01.png",
		DEFAULT_PPU,
		"crates"
	)
	_register(
		ARCHETYPE_CRATES_STACKED,
		VARIANT_PAIR_01,
		"res://assets/tactical/props/crates_pair_01.png",
		DEFAULT_PPU,
		"crates"
	)
	_register(
		ARCHETYPE_TABLE_UTILITY,
		VARIANT_WOOD_01,
		"res://assets/tactical/props/table_utility_01.png",
		DEFAULT_PPU,
		"table"
	)


static func _register(
	archetype_id: String,
	variant_id: String,
	resource_path: String,
	art_pixels_per_unit: float,
	fallback_drawer_id: String
) -> void:
	_spec_table[_spec_key(archetype_id, variant_id)] = {
		"archetype_id": archetype_id,
		"variant_id": variant_id,
		"resource_path": resource_path,
		"art_pixels_per_unit": art_pixels_per_unit,
		"centered": true,
		"fallback_drawer_id": fallback_drawer_id,
	}
