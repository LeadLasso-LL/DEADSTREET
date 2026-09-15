class_name BattleDeploymentPocket
extends RefCounted

# One polygonal deployment pocket. Query-only geometry.
# Not a visual overlay and not a second legality authority.

var pocket_id: String = ""
var polygon: PackedVector2Array = PackedVector2Array()


func _init(p_pocket_id: String = "", p_polygon: PackedVector2Array = PackedVector2Array()) -> void:
	pocket_id = p_pocket_id
	polygon = p_polygon


func is_valid() -> bool:
	if pocket_id.is_empty():
		return false
	if polygon.size() < 3:
		return false
	for point: Vector2 in polygon:
		if not is_finite(point.x) or not is_finite(point.y):
			return false
	return bounding_rect().size.x > 0.0 and bounding_rect().size.y > 0.0


func contains_point(point: Vector2) -> bool:
	if not is_finite(point.x) or not is_finite(point.y):
		return false
	if polygon.size() < 3:
		return false
	return Geometry2D.is_point_in_polygon(point, polygon)


func bounding_rect() -> Rect2:
	if polygon.size() < 1:
		return Rect2()
	var min_x: float = polygon[0].x
	var min_y: float = polygon[0].y
	var max_x: float = polygon[0].x
	var max_y: float = polygon[0].y
	var index: int = 1
	while index < polygon.size():
		var point: Vector2 = polygon[index]
		min_x = minf(min_x, point.x)
		min_y = minf(min_y, point.y)
		max_x = maxf(max_x, point.x)
		max_y = maxf(max_y, point.y)
		index += 1
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))


func centroid() -> Vector2:
	if polygon.size() < 1:
		return Vector2.ZERO
	var sum: Vector2 = Vector2.ZERO
	for point: Vector2 in polygon:
		sum += point
	return sum / float(polygon.size())
