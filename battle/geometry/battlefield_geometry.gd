class_name BattlefieldGeometry
extends RefCounted

const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")

var width: float = 0.0
var height: float = 0.0
var attacker_deployment_rect: Rect2 = Rect2()
var defender_deployment_rect: Rect2 = Rect2()
var obstacles: Dictionary[String, BattleObstacle] = {}
var cover_objects: Dictionary[String, BattleCoverObject] = {}
var cover_slots: Dictionary[String, BattleCoverSlot] = {}


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
	for cover_object_id: String in cover_objects:
		var cover_object: BattleCoverObject = cover_objects[cover_object_id]
		if cover_object == null or cover_object.cover_object_id != cover_object_id:
			return false
		if not cover_object.is_valid():
			return false
		for slot_id: String in cover_object.slot_ids:
			if not cover_slots.has(slot_id):
				return false
			var owned_slot: BattleCoverSlot = cover_slots[slot_id]
			if owned_slot == null or owned_slot.cover_object_id != cover_object_id:
				return false
	for cover_slot_id: String in cover_slots:
		var cover_slot: BattleCoverSlot = cover_slots[cover_slot_id]
		if cover_slot == null or cover_slot.cover_slot_id != cover_slot_id:
			return false
		if not cover_slot.is_valid():
			return false
		if not cover_objects.has(cover_slot.cover_object_id):
			return false
		if not _cover_slot_position_is_legal(cover_slot.position):
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


func add_cover_object(cover_object: BattleCoverObject) -> bool:
	if cover_object == null:
		push_error("BattlefieldGeometry.add_cover_object: cover object is null.")
		return false
	if cover_object.cover_object_id.is_empty():
		push_error("BattlefieldGeometry.add_cover_object: cover object id is empty.")
		return false
	if cover_objects.has(cover_object.cover_object_id):
		push_error(
			"BattlefieldGeometry.add_cover_object: duplicate cover object id '%s'."
			% cover_object.cover_object_id
		)
		return false
	if not cover_object.slot_ids.is_empty():
		push_error(
			"BattlefieldGeometry.add_cover_object: cover object '%s' must be added before its slots."
			% cover_object.cover_object_id
		)
		return false
	cover_objects[cover_object.cover_object_id] = cover_object
	return true


func has_cover_object(cover_object_id: String) -> bool:
	return cover_objects.has(cover_object_id)


func get_cover_object(cover_object_id: String) -> BattleCoverObject:
	if cover_objects.has(cover_object_id):
		return cover_objects[cover_object_id]
	return null


func get_sorted_cover_object_ids() -> Array[String]:
	var ids: Array[String] = []
	for cover_object_id: String in cover_objects:
		ids.append(cover_object_id)
	ids.sort()
	return ids


func remove_cover_object(cover_object_id: String) -> bool:
	if not cover_objects.has(cover_object_id):
		push_error("BattlefieldGeometry.remove_cover_object: unknown cover object id '%s'." % cover_object_id)
		return false
	var cover_object: BattleCoverObject = cover_objects[cover_object_id]
	if cover_object != null:
		for slot_id: String in cover_object.slot_ids:
			var slot: BattleCoverSlot = get_cover_slot(slot_id)
			if slot != null and (slot.is_occupied() or slot.is_reserved()):
				push_error(
					"BattlefieldGeometry.remove_cover_object: cover object '%s' still has owned slots."
					% cover_object_id
				)
				return false
		var slot_ids: Array[String] = []
		for slot_id: String in cover_object.slot_ids:
			slot_ids.append(slot_id)
		for slot_id: String in slot_ids:
			if not remove_cover_slot(slot_id):
				return false
	cover_objects.erase(cover_object_id)
	return true


func add_cover_slot(cover_slot: BattleCoverSlot) -> bool:
	if cover_slot == null:
		push_error("BattlefieldGeometry.add_cover_slot: cover slot is null.")
		return false
	if cover_slot.cover_slot_id.is_empty():
		push_error("BattlefieldGeometry.add_cover_slot: cover slot id is empty.")
		return false
	if cover_slots.has(cover_slot.cover_slot_id):
		push_error(
			"BattlefieldGeometry.add_cover_slot: duplicate cover slot id '%s'." % cover_slot.cover_slot_id
		)
		return false
	if not cover_slot.is_valid():
		push_error(
			"BattlefieldGeometry.add_cover_slot: cover slot '%s' is invalid." % cover_slot.cover_slot_id
		)
		return false
	if not cover_objects.has(cover_slot.cover_object_id):
		push_error(
			"BattlefieldGeometry.add_cover_slot: cover object '%s' does not exist."
			% cover_slot.cover_object_id
		)
		return false
	if not _cover_slot_position_is_legal(cover_slot.position):
		push_error(
			"BattlefieldGeometry.add_cover_slot: cover slot '%s' position is illegal."
			% cover_slot.cover_slot_id
		)
		return false
	var cover_object: BattleCoverObject = cover_objects[cover_slot.cover_object_id]
	if cover_object.slot_ids.has(cover_slot.cover_slot_id):
		push_error(
			"BattlefieldGeometry.add_cover_slot: cover object '%s' already lists slot '%s'."
			% [cover_object.cover_object_id, cover_slot.cover_slot_id]
		)
		return false
	cover_slots[cover_slot.cover_slot_id] = cover_slot
	cover_object.slot_ids.append(cover_slot.cover_slot_id)
	return true


func has_cover_slot(cover_slot_id: String) -> bool:
	return cover_slots.has(cover_slot_id)


func get_cover_slot(cover_slot_id: String) -> BattleCoverSlot:
	if cover_slots.has(cover_slot_id):
		return cover_slots[cover_slot_id]
	return null


func get_sorted_cover_slot_ids() -> Array[String]:
	var ids: Array[String] = []
	for cover_slot_id: String in cover_slots:
		ids.append(cover_slot_id)
	ids.sort()
	return ids


func remove_cover_slot(cover_slot_id: String) -> bool:
	if not cover_slots.has(cover_slot_id):
		push_error("BattlefieldGeometry.remove_cover_slot: unknown cover slot id '%s'." % cover_slot_id)
		return false
	var cover_slot: BattleCoverSlot = cover_slots[cover_slot_id]
	if cover_slot != null and (cover_slot.is_occupied() or cover_slot.is_reserved()):
		push_error(
			"BattlefieldGeometry.remove_cover_slot: cover slot '%s' is still owned." % cover_slot_id
		)
		return false
	if cover_slot != null and cover_objects.has(cover_slot.cover_object_id):
		var cover_object: BattleCoverObject = cover_objects[cover_slot.cover_object_id]
		var remaining: Array[String] = []
		for owned_id: String in cover_object.slot_ids:
			if owned_id != cover_slot_id:
				remaining.append(owned_id)
		cover_object.slot_ids = remaining
	cover_slots.erase(cover_slot_id)
	return true


func _cover_slot_position_is_legal(point: Vector2) -> bool:
	if not is_finite_point(point):
		return false
	if not contains_point(point):
		return false
	for obstacle_id: String in obstacles:
		var obstacle: BattleObstacle = obstacles[obstacle_id]
		if obstacle == null or not obstacle.blocks_movement:
			continue
		if obstacle.contains_point(point):
			return false
	return true


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
