class_name BattleVisualBinding
extends RefCounted

# Presentation-only link from a gameplay entity to an art identity.
# Does not affect collision, LOS, cover, navigation, or deployment.

const KIND_OBSTACLE := "obstacle"
const KIND_VEHICLE := "vehicle"
const KIND_BUILDING := "building"
const KIND_SURFACE := "surface"
const KIND_DECAL := "decal"

var target_kind: String = ""
var target_id: String = ""
var archetype_id: String = ""
var variant_id: String = ""
var rotation_deg: float = 0.0
var offset: Vector2 = Vector2.ZERO
var scale: float = 1.0


func _init(
	p_target_kind: String = "",
	p_target_id: String = "",
	p_archetype_id: String = "",
	p_variant_id: String = "",
	p_rotation_deg: float = 0.0,
	p_offset: Vector2 = Vector2.ZERO,
	p_scale: float = 1.0
) -> void:
	target_kind = p_target_kind
	target_id = p_target_id
	archetype_id = p_archetype_id
	variant_id = p_variant_id
	rotation_deg = p_rotation_deg
	offset = p_offset
	scale = p_scale


func is_valid() -> bool:
	if target_kind.is_empty() or target_id.is_empty():
		return false
	if archetype_id.is_empty() or variant_id.is_empty():
		return false
	if not is_finite(rotation_deg):
		return false
	if not is_finite(offset.x) or not is_finite(offset.y):
		return false
	if not is_finite(scale) or scale <= 0.0:
		return false
	return true
