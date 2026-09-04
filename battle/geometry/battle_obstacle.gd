class_name BattleObstacle
extends RefCounted

var obstacle_id: String = ""
var bounds: Rect2 = Rect2()
var blocks_movement: bool = true
var blocks_line_of_sight: bool = true
var presentation_kind: String = ""


func _init(
	p_obstacle_id: String = "",
	p_bounds: Rect2 = Rect2(),
	p_blocks_movement: bool = true,
	p_blocks_line_of_sight: bool = true,
	p_presentation_kind: String = ""
) -> void:
	obstacle_id = p_obstacle_id
	bounds = p_bounds
	blocks_movement = p_blocks_movement
	blocks_line_of_sight = p_blocks_line_of_sight
	presentation_kind = p_presentation_kind


func is_valid() -> bool:
	if obstacle_id.is_empty():
		return false
	return bounds_are_usable()


func bounds_are_usable() -> bool:
	if not is_finite(bounds.position.x) or not is_finite(bounds.position.y):
		return false
	if not is_finite(bounds.size.x) or not is_finite(bounds.size.y):
		return false
	return bounds.size.x > 0.0 and bounds.size.y > 0.0


func contains_point(point: Vector2) -> bool:
	if not is_finite(point.x) or not is_finite(point.y):
		return false
	if not bounds_are_usable():
		return false
	return (
		point.x >= bounds.position.x
		and point.y >= bounds.position.y
		and point.x <= bounds.position.x + bounds.size.x
		and point.y <= bounds.position.y + bounds.size.y
	)
