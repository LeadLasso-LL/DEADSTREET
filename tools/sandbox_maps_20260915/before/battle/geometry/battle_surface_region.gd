class_name BattleSurfaceRegion
extends RefCounted

# Presentation pavement / lot / road region. Not collision, LOS, or cover.

const KIND_ASPHALT := "asphalt"
const KIND_SIDEWALK := "sidewalk"
const KIND_LOT := "lot"
const KIND_ALLEY := "alley"
const KIND_CURB := "curb"
const KIND_APRON := "apron"

var region_id: String = ""
var region_kind: String = ""
var bounds: Rect2 = Rect2()


func _init(
	p_region_id: String = "",
	p_region_kind: String = "",
	p_bounds: Rect2 = Rect2()
) -> void:
	region_id = p_region_id
	region_kind = p_region_kind
	bounds = p_bounds


func is_valid() -> bool:
	if region_id.is_empty() or region_kind.is_empty():
		return false
	if not is_finite(bounds.position.x) or not is_finite(bounds.position.y):
		return false
	if not is_finite(bounds.size.x) or not is_finite(bounds.size.y):
		return false
	return bounds.size.x > 0.0 and bounds.size.y > 0.0
