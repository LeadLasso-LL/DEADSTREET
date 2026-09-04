class_name BattlePresentationMarking
extends RefCounted

# Catalog-authored visual dressing. Not collision, LOS, cover, or deployment.

const KIND_LANE := "lane"
const KIND_PARKING := "parking"
const KIND_LOADING := "loading"
const KIND_SEAM := "seam"
const KIND_STOP_BAR := "stop_bar"
const KIND_BOLLARD := "bollard"
const KIND_UTILITY := "utility"

var mark_id: String = ""
var mark_kind: String = ""
var bounds: Rect2 = Rect2()


func _init(
	p_mark_id: String = "",
	p_mark_kind: String = "",
	p_bounds: Rect2 = Rect2()
) -> void:
	mark_id = p_mark_id
	mark_kind = p_mark_kind
	bounds = p_bounds


func is_valid() -> bool:
	if mark_id.is_empty() or mark_kind.is_empty():
		return false
	if not is_finite(bounds.position.x) or not is_finite(bounds.position.y):
		return false
	if not is_finite(bounds.size.x) or not is_finite(bounds.size.y):
		return false
	return bounds.size.x > 0.0 and bounds.size.y > 0.0
