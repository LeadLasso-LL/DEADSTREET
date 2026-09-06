class_name TacticalVisualPlacement
extends RefCounted

# Native-proportion environment placement. Presentation only.
# A gameplay Rect2 is an anchor frame, not an art stretch target.

const BattleVisualBinding := preload("res://battle/presentation/battle_visual_binding.gd")

const ANCHOR_CENTER := "center"
const ANCHOR_NORTH := "north"
const ANCHOR_SOUTH := "south"
const ANCHOR_FRONTAGE := "frontage"
const ANCHOR_CUSTOM := "custom"

const MODE_NATIVE := "native"
const MODE_TILE := "tile"


static func is_known_anchor(mode: String) -> bool:
	return (
		mode == ANCHOR_CENTER
		or mode == ANCHOR_NORTH
		or mode == ANCHOR_SOUTH
		or mode == ANCHOR_FRONTAGE
		or mode == ANCHOR_CUSTOM
	)


static func is_known_placement_mode(mode: String) -> bool:
	return mode == MODE_NATIVE or mode == MODE_TILE


static func native_world_size(texture: Texture2D, art_ppu: float) -> Vector2:
	if texture == null or art_ppu <= 0.0:
		return Vector2.ZERO
	var px_w: float = float(texture.get_width())
	var px_h: float = float(texture.get_height())
	if px_w <= 0.0 or px_h <= 0.0:
		return Vector2.ZERO
	return Vector2(px_w / art_ppu, px_h / art_ppu)


static func visual_uv(anchor_mode: String, custom_uv: Vector2) -> Vector2:
	if anchor_mode == ANCHOR_NORTH:
		return Vector2(0.5, 0.0)
	if anchor_mode == ANCHOR_SOUTH or anchor_mode == ANCHOR_FRONTAGE:
		return Vector2(0.5, 1.0)
	if anchor_mode == ANCHOR_CUSTOM:
		return custom_uv
	return Vector2(0.5, 0.5)


static func gameplay_anchor_point(bounds: Rect2, anchor_mode: String) -> Vector2:
	if anchor_mode == ANCHOR_NORTH:
		return Vector2(bounds.get_center().x, bounds.position.y)
	if anchor_mode == ANCHOR_SOUTH or anchor_mode == ANCHOR_FRONTAGE:
		return Vector2(bounds.get_center().x, bounds.position.y + bounds.size.y)
	return bounds.get_center()


static func world_sprite_center(anchor_world: Vector2, world_size: Vector2, uv: Vector2) -> Vector2:
	return Vector2(
		anchor_world.x + (0.5 - uv.x) * world_size.x,
		anchor_world.y + (0.5 - uv.y) * world_size.y
	)


static func resolved_world_size(
	texture: Texture2D,
	art_ppu: float,
	binding: BattleVisualBinding,
	gameplay_bounds: Rect2,
	use_gameplay_bounds: bool
) -> Vector2:
	if binding == null:
		return Vector2.ZERO
	if binding.placement_mode == MODE_TILE:
		if binding.visual_world_size.x > 0.0 and binding.visual_world_size.y > 0.0:
			return binding.visual_world_size * binding.scale
		if use_gameplay_bounds:
			return gameplay_bounds.size * binding.scale
		return Vector2.ZERO
	var native: Vector2 = native_world_size(texture, art_ppu)
	if native.x <= 0.0 or native.y <= 0.0:
		return Vector2.ZERO
	var size: Vector2 = native
	if binding.visual_world_size.x > 0.0:
		size = native * (binding.visual_world_size.x / native.x)
	elif binding.visual_world_size.y > 0.0:
		size = native * (binding.visual_world_size.y / native.y)
	return size * binding.scale


static func compute(
	texture: Texture2D,
	spec: Dictionary,
	binding: BattleVisualBinding,
	view_ppu: float,
	gameplay_bounds: Rect2,
	use_gameplay_bounds: bool
) -> Dictionary:
	var empty: Dictionary = {}
	if texture == null or binding == null or spec.is_empty():
		return empty
	if view_ppu <= 0.0:
		return empty
	var art_ppu: float = float(spec.get("art_pixels_per_unit", 0.0))
	if art_ppu <= 0.0:
		return empty
	if not is_known_anchor(binding.anchor_mode):
		return empty
	if not is_known_placement_mode(binding.placement_mode):
		return empty
	var world_size: Vector2 = resolved_world_size(
		texture,
		art_ppu,
		binding,
		gameplay_bounds,
		use_gameplay_bounds
	)
	if world_size.x <= 0.0 or world_size.y <= 0.0:
		return empty
	var uv: Vector2 = visual_uv(binding.anchor_mode, binding.anchor_uv)
	if not is_finite(uv.x) or not is_finite(uv.y):
		return empty
	var anchor_world: Vector2 = binding.offset
	if use_gameplay_bounds:
		anchor_world = gameplay_anchor_point(gameplay_bounds, binding.anchor_mode) + binding.offset
	var world_center: Vector2 = world_sprite_center(anchor_world, world_size, uv)
	var view_scale: float = 0.0
	var region_enabled: bool = binding.placement_mode == MODE_TILE
	var region_rect: Rect2 = Rect2()
	if region_enabled:
		region_rect = Rect2(Vector2.ZERO, world_size * art_ppu)
		view_scale = view_ppu / art_ppu
	else:
		var px_w: float = float(texture.get_width())
		if px_w <= 0.0:
			return empty
		view_scale = (world_size.x * view_ppu) / px_w
	if view_scale <= 0.0 or not is_finite(view_scale):
		return empty
	var world_rect: Rect2 = Rect2(world_center - world_size * 0.5, world_size)
	return {
		"world_center": world_center,
		"world_size": world_size,
		"world_rect": world_rect,
		"view_position": world_center * view_ppu,
		"view_scale": view_scale,
		"uniform": true,
		"region_enabled": region_enabled,
		"region_rect": region_rect,
		"texture_repeat": region_enabled,
	}
