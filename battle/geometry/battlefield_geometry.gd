class_name BattlefieldGeometry
extends RefCounted

const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")

var width: float = 0.0
var height: float = 0.0
var attacker_deployment_rect: Rect2 = Rect2()
var defender_deployment_rect: Rect2 = Rect2()
var obstacles: Dictionary[String, BattleObstacle] = {}


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
	for obstacle_id: String in obstacles:
		var obstacle: BattleObstacle = obstacles[obstacle_id]
		if obstacle == null or obstacle.obstacle_id != obstacle_id:
			return false
		if not obstacle.is_valid():
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


func add_obstacle(obstacle: BattleObstacle) -> bool:
	if obstacle == null:
		push_error("BattlefieldGeometry.add_obstacle: obstacle is null.")
		return false
	if obstacle.obstacle_id.is_empty():
		push_error("BattlefieldGeometry.add_obstacle: obstacle id is empty.")
		return false
	if obstacles.has(obstacle.obstacle_id):
		push_error("BattlefieldGeometry.add_obstacle: duplicate obstacle id '%s'." % obstacle.obstacle_id)
		return false
	if not obstacle.bounds_are_usable():
		push_error("BattlefieldGeometry.add_obstacle: obstacle '%s' bounds are invalid." % obstacle.obstacle_id)
		return false
	obstacles[obstacle.obstacle_id] = obstacle
	return true


func has_obstacle(obstacle_id: String) -> bool:
	return obstacles.has(obstacle_id)


func get_obstacle(obstacle_id: String) -> BattleObstacle:
	if obstacles.has(obstacle_id):
		return obstacles[obstacle_id]
	return null


func get_sorted_obstacle_ids() -> Array[String]:
	var ids: Array[String] = []
	for obstacle_id: String in obstacles:
		ids.append(obstacle_id)
	ids.sort()
	return ids


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
