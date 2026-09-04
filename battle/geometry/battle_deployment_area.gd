class_name BattleDeploymentArea
extends RefCounted

# Side deployment area as one or more polygonal pockets.
# Empty pockets mean the legacy axis-aligned rect is the authority.
# Point-in-area is the legality query; bounding_rect is a coarse envelope only.

const BattleDeploymentPocket := preload("res://battle/geometry/battle_deployment_pocket.gd")

var pockets: Array[BattleDeploymentPocket] = []


func has_pockets() -> bool:
	return not pockets.is_empty()


func is_valid() -> bool:
	if pockets.is_empty():
		return true
	var seen: Dictionary = {}
	for pocket: BattleDeploymentPocket in pockets:
		if pocket == null or not pocket.is_valid():
			return false
		if seen.has(pocket.pocket_id):
			return false
		seen[pocket.pocket_id] = true
	return _rect_is_usable(bounding_rect())


func add_pocket(pocket: BattleDeploymentPocket) -> bool:
	if pocket == null or not pocket.is_valid():
		return false
	for existing: BattleDeploymentPocket in pockets:
		if existing != null and existing.pocket_id == pocket.pocket_id:
			return false
	pockets.append(pocket)
	return true


func contains_point(point: Vector2) -> bool:
	if not has_pockets():
		return false
	for pocket: BattleDeploymentPocket in pockets:
		if pocket != null and pocket.contains_point(point):
			return true
	return false


func bounding_rect() -> Rect2:
	var first: bool = true
	var min_x: float = 0.0
	var min_y: float = 0.0
	var max_x: float = 0.0
	var max_y: float = 0.0
	for pocket: BattleDeploymentPocket in pockets:
		if pocket == null:
			continue
		var rect: Rect2 = pocket.bounding_rect()
		if not _rect_is_usable(rect):
			continue
		if first:
			min_x = rect.position.x
			min_y = rect.position.y
			max_x = rect.position.x + rect.size.x
			max_y = rect.position.y + rect.size.y
			first = false
			continue
		min_x = minf(min_x, rect.position.x)
		min_y = minf(min_y, rect.position.y)
		max_x = maxf(max_x, rect.position.x + rect.size.x)
		max_y = maxf(max_y, rect.position.y + rect.size.y)
	if first:
		return Rect2()
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))


func centroid() -> Vector2:
	if pockets.is_empty():
		return Vector2.ZERO
	var sum: Vector2 = Vector2.ZERO
	var count: int = 0
	for pocket: BattleDeploymentPocket in pockets:
		if pocket == null or pocket.polygon.size() < 3:
			continue
		sum += pocket.centroid()
		count += 1
	if count <= 0:
		return Vector2.ZERO
	return sum / float(count)


func get_sorted_pockets() -> Array[BattleDeploymentPocket]:
	var copied: Array[BattleDeploymentPocket] = []
	for pocket: BattleDeploymentPocket in pockets:
		copied.append(pocket)
	copied.sort_custom(_sort_pockets)
	return copied


func pocket_bounding_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for pocket: BattleDeploymentPocket in get_sorted_pockets():
		if pocket == null:
			continue
		var rect: Rect2 = pocket.bounding_rect()
		if _rect_is_usable(rect):
			rects.append(rect)
	return rects


static func _rect_is_usable(rect: Rect2) -> bool:
	if not is_finite(rect.position.x) or not is_finite(rect.position.y):
		return false
	if not is_finite(rect.size.x) or not is_finite(rect.size.y):
		return false
	return rect.size.x > 0.0 and rect.size.y > 0.0


static func _sort_pockets(left: BattleDeploymentPocket, right: BattleDeploymentPocket) -> bool:
	var left_id: String = ""
	var right_id: String = ""
	if left != null:
		left_id = left.pocket_id
	if right != null:
		right_id = right.pocket_id
	return left_id < right_id
