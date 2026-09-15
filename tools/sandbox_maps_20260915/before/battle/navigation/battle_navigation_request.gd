class_name BattleNavigationRequest
extends RefCounted

var start_position: Vector2 = Vector2.ZERO
var destination: Vector2 = Vector2.ZERO


func _init(
	p_start_position: Vector2 = Vector2.ZERO,
	p_destination: Vector2 = Vector2.ZERO
) -> void:
	start_position = p_start_position
	destination = p_destination


func is_valid() -> bool:
	if not is_finite(start_position.x) or not is_finite(start_position.y):
		return false
	if not is_finite(destination.x) or not is_finite(destination.y):
		return false
	return true
