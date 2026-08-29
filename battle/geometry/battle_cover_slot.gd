class_name BattleCoverSlot
extends RefCounted

# Authored occupiable cover position. Metadata only; not a collision shape.
var cover_slot_id: String = ""
var cover_object_id: String = ""
var position: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var occupied_by_participant_id: String = ""
var reserved_by_participant_id: String = ""


func _init(
	p_cover_slot_id: String = "",
	p_cover_object_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_facing_direction: Vector2 = Vector2.ZERO
) -> void:
	cover_slot_id = p_cover_slot_id
	cover_object_id = p_cover_object_id
	position = p_position
	if is_finite(p_facing_direction.x) and is_finite(p_facing_direction.y) and not p_facing_direction.is_equal_approx(Vector2.ZERO):
		facing_direction = p_facing_direction.normalized()
	else:
		facing_direction = p_facing_direction


func set_facing_direction(direction: Vector2) -> bool:
	if not is_finite(direction.x) or not is_finite(direction.y):
		push_error("BattleCoverSlot.set_facing_direction: direction is not finite.")
		return false
	if direction.is_equal_approx(Vector2.ZERO):
		push_error("BattleCoverSlot.set_facing_direction: direction is zero.")
		return false
	facing_direction = direction.normalized()
	return true


func is_valid() -> bool:
	if cover_slot_id.is_empty() or cover_object_id.is_empty():
		return false
	if not is_finite(position.x) or not is_finite(position.y):
		return false
	if not is_finite(facing_direction.x) or not is_finite(facing_direction.y):
		return false
	if facing_direction.is_equal_approx(Vector2.ZERO):
		return false
	return is_equal_approx(facing_direction.length(), 1.0)


func is_occupied() -> bool:
	return not occupied_by_participant_id.is_empty()


func is_reserved() -> bool:
	return not reserved_by_participant_id.is_empty()


func is_available() -> bool:
	return not is_occupied() and not is_reserved()
