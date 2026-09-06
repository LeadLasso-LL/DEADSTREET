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
const ARCHETYPE_ROOF_HVAC := "roof_hvac"
const ARCHETYPE_ROOF_VENT := "roof_vent"
const ARCHETYPE_ROOF_HATCH := "roof_hatch"
const ARCHETYPE_ROOF_EXHAUST := "roof_exhaust"
const ARCHETYPE_ROOF_PATCH := "roof_patch"
const ARCHETYPE_UTILITY_BOX := "utility_box"
const ARCHETYPE_AWNING := "awning"
const ARCHETYPE_SIGN_PLAQUE := "sign_plaque"
const ARCHETYPE_MANHOLE := "manhole"
const ARCHETYPE_ASPHALT_PATCH := "asphalt_patch"
const ARCHETYPE_OIL_STAIN := "oil_stain"
const ARCHETYPE_SIDEWALK_CRACK := "sidewalk_crack"
const ARCHETYPE_GRIME_STRIP := "grime_strip"
const ARCHETYPE_BUILDING_TACTICAL := "building_tactical"
const ARCHETYPE_SURFACE_TACTICAL := "surface_tactical"
const ARCHETYPE_ENVIRONMENT_BLOCK := "environment_block"

const VARIANT_TEST_01 := "test_01"
const VARIANT_CREAM_01 := "cream_01"
const VARIANT_BLUE_01 := "blue_01"
const VARIANT_GREEN_01 := "green_01"
const VARIANT_GRAY_01 := "gray_01"
const VARIANT_MAROON_01 := "maroon_01"
const VARIANT_WOOD_01 := "wood_01"
const VARIANT_OFFSET_01 := "offset_01"
const VARIANT_PAIR_01 := "pair_01"
const VARIANT_LARGE_01 := "large_01"
const VARIANT_SMALL_01 := "small_01"
const VARIANT_HQ_01 := "hq_01"
const VARIANT_SHOP_01 := "shop_01"
const VARIANT_FLAT_01 := "flat_01"
const VARIANT_PIPELINE_TEST := "pipeline_test"
const VARIANT_ASPHALT_01 := "asphalt_01"
const VARIANT_CALIBRATION_01 := "calibration_01"
const VARIANT_HQ_NORTH_01 := "hq_north_01"

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


static func is_pipeline_test(spec: Dictionary) -> bool:
	return bool(spec.get("pipeline_test", false))


static func should_claim_canvas(spec: Dictionary) -> bool:
	if spec.is_empty() or is_pipeline_test(spec):
		return false
	return texture_for(spec) != null


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
	_register(
		ARCHETYPE_ROOF_HVAC,
		VARIANT_LARGE_01,
		"res://assets/tactical/environment/hvac_large_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_ROOF_HVAC,
		VARIANT_SMALL_01,
		"res://assets/tactical/environment/hvac_small_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_ROOF_VENT,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/roof_vent_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_ROOF_HATCH,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/roof_hatch_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_ROOF_EXHAUST,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/roof_exhaust_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_ROOF_PATCH,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/roof_patch_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_UTILITY_BOX,
		VARIANT_GREEN_01,
		"res://assets/tactical/environment/utility_box_01.png",
		DEFAULT_PPU,
		"roof_dressing",
		{"suppress_canvas": "roof_props"}
	)
	_register(
		ARCHETYPE_AWNING,
		VARIANT_HQ_01,
		"res://assets/tactical/environment/awning_hq_01.png",
		DEFAULT_PPU,
		"hq_cues",
		{"suppress_canvas": "facade"}
	)
	_register(
		ARCHETYPE_AWNING,
		VARIANT_SHOP_01,
		"res://assets/tactical/environment/awning_shop_01.png",
		DEFAULT_PPU,
		"storefront",
		{"suppress_canvas": "facade"}
	)
	_register(
		ARCHETYPE_SIGN_PLAQUE,
		VARIANT_FLAT_01,
		"res://assets/tactical/environment/sign_plaque_01.png",
		DEFAULT_PPU,
		"hq_cues",
		{"suppress_canvas": "facade"}
	)
	_register(
		ARCHETYPE_MANHOLE,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/manhole_01.png",
		DEFAULT_PPU,
		"utility",
		{"suppress_canvas": "marking"}
	)
	_register(
		ARCHETYPE_ASPHALT_PATCH,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/asphalt_patch_01.png",
		DEFAULT_PPU,
		"patch",
		{"suppress_canvas": "marking"}
	)
	_register(
		ARCHETYPE_OIL_STAIN,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/oil_stain_01.png",
		DEFAULT_PPU,
		"stain",
		{"suppress_canvas": "marking"}
	)
	_register(
		ARCHETYPE_SIDEWALK_CRACK,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/sidewalk_crack_01.png",
		DEFAULT_PPU,
		"seam",
		{"suppress_canvas": "marking"}
	)
	_register(
		ARCHETYPE_GRIME_STRIP,
		VARIANT_GRAY_01,
		"res://assets/tactical/environment/grime_strip_01.png",
		DEFAULT_PPU,
		"stain",
		{"suppress_canvas": "marking"}
	)
	_register(
		ARCHETYPE_BUILDING_TACTICAL,
		VARIANT_PIPELINE_TEST,
		"res://assets/tactical/environment/building_pipeline_test.png",
		DEFAULT_PPU,
		"building",
		{"pipeline_test": true}
	)
	_register(
		ARCHETYPE_BUILDING_TACTICAL,
		VARIANT_HQ_01,
		"res://assets/tactical/environment/building_hq_01.png",
		DEFAULT_PPU,
		"building"
	)
	_register(
		ARCHETYPE_SURFACE_TACTICAL,
		VARIANT_PIPELINE_TEST,
		"res://assets/tactical/environment/surface_pipeline_test.png",
		DEFAULT_PPU,
		"surface",
		{"pipeline_test": true}
	)
	_register(
		ARCHETYPE_SURFACE_TACTICAL,
		VARIANT_ASPHALT_01,
		"res://assets/tactical/environment/surface_road_01.png",
		DEFAULT_PPU,
		"surface"
	)
	_register(
		ARCHETYPE_ENVIRONMENT_BLOCK,
		VARIANT_PIPELINE_TEST,
		"res://assets/tactical/environment/building_pipeline_test.png",
		DEFAULT_PPU,
		"building",
		{"pipeline_test": true}
	)
	_register(
		ARCHETYPE_ENVIRONMENT_BLOCK,
		VARIANT_HQ_NORTH_01,
		"res://assets/tactical/environment/block_hq_north_01.png",
		DEFAULT_PPU,
		"building"
	)
	_register(
		ARCHETYPE_ENVIRONMENT_BLOCK,
		VARIANT_CALIBRATION_01,
		"res://assets/tactical/environment/composition_calibration_01.png",
		DEFAULT_PPU,
		"building"
	)
	_register(
		ARCHETYPE_BUILDING_TACTICAL,
		VARIANT_CALIBRATION_01,
		"res://assets/tactical/environment/composition_calibration_01.png",
		DEFAULT_PPU,
		"building"
	)
	_register(
		ARCHETYPE_SURFACE_TACTICAL,
		VARIANT_CALIBRATION_01,
		"res://assets/tactical/environment/composition_calibration_01.png",
		DEFAULT_PPU,
		"surface"
	)


static func _register(
	archetype_id: String,
	variant_id: String,
	resource_path: String,
	art_pixels_per_unit: float,
	fallback_drawer_id: String,
	extra: Dictionary = {}
) -> void:
	var spec: Dictionary = {
		"archetype_id": archetype_id,
		"variant_id": variant_id,
		"resource_path": resource_path,
		"art_pixels_per_unit": art_pixels_per_unit,
		"centered": true,
		"fallback_drawer_id": fallback_drawer_id,
	}
	for key: Variant in extra:
		spec[str(key)] = extra[key]
	_spec_table[_spec_key(archetype_id, variant_id)] = spec
