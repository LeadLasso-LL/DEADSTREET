class_name BattlefieldGeometry
extends RefCounted

var width: float = 0.0
var height: float = 0.0
var attacker_deployment_rect: Rect2 = Rect2()
var defender_deployment_rect: Rect2 = Rect2()


func is_valid() -> bool:
	if not is_finite(width) or not is_finite(height):
		return false
	if width <= 0.0 or height <= 0.0:
		return false
	if not rect_is_usable(attacker_deployment_rect):
		return false
	if not rect_is_usable(defender_deployment_rect):
		return false
	if not _rect_is_within_battlefield(attacker_deployment_rect):
		return false
	if not _rect_is_within_battlefield(defender_deployment_rect):
		return false
	return true


func contains_point(point: Vector2) -> bool:
	if not is_finite_point(point):
		return false
	return (
		point.x >= 0.0
		and point.y >= 0.0
		and point.x <= width
		and point.y <= height
	)


func attacker_deployment_contains(point: Vector2) -> bool:
	return rect_contains_point(attacker_deployment_rect, point)


func defender_deployment_contains(point: Vector2) -> bool:
	return rect_contains_point(defender_deployment_rect, point)


func bounds() -> Rect2:
	return Rect2(0.0, 0.0, width, height)


static func rect_contains_point(rect: Rect2, point: Vector2) -> bool:
	if not is_finite_point(point):
		return false
	if not rect_is_usable(rect):
		return false
	return (
		point.x >= rect.position.x
		and point.y >= rect.position.y
		and point.x <= rect.position.x + rect.size.x
		and point.y <= rect.position.y + rect.size.y
	)


static func is_finite_point(point: Vector2) -> bool:
	return is_finite(point.x) and is_finite(point.y)


static func rect_is_usable(rect: Rect2) -> bool:
	if not is_finite(rect.position.x) or not is_finite(rect.position.y):
		return false
	if not is_finite(rect.size.x) or not is_finite(rect.size.y):
		return false
	return rect.size.x > 0.0 and rect.size.y > 0.0


func _rect_is_within_battlefield(rect: Rect2) -> bool:
	if not rect_is_usable(rect):
		return false
	return (
		rect.position.x >= 0.0
		and rect.position.y >= 0.0
		and rect.position.x + rect.size.x <= width
		and rect.position.y + rect.size.y <= height
	)
