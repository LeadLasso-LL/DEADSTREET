class_name TacticalVisualCatalog
extends RefCounted

# Resolves presentation archetype/variant ids to external textures.
# Caches Texture2D by resource path. Does not own gameplay geometry.

const ARCHETYPE_CIVILIAN_SEDAN := "civilian_sedan"
const VARIANT_TEST_01 := "test_01"
const FALLBACK_CIVILIAN_CAR := "civilian_car"
const SEDAN_TEST_PATH := "res://assets/tactical/vehicles/civilian_sedan_test_01.png"
const SEDAN_TEST_PPU := 32.0

static var _texture_cache: Dictionary = {}


static func spec_for(archetype_id: String, variant_id: String) -> Dictionary:
	if archetype_id == ARCHETYPE_CIVILIAN_SEDAN and variant_id == VARIANT_TEST_01:
		return {
			"archetype_id": archetype_id,
			"variant_id": variant_id,
			"resource_path": SEDAN_TEST_PATH,
			"art_pixels_per_unit": SEDAN_TEST_PPU,
			"centered": true,
			"fallback_drawer_id": FALLBACK_CIVILIAN_CAR,
		}
	return {}


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


static func cache_size() -> int:
	return _texture_cache.size()
