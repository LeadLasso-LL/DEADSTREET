class_name BattleTacticalForce
extends RefCounted

const BattleForceCommandCatalog := preload("res://battle/core/battle_force_command_catalog.gd")

var tactical_force_id: String = ""
var side_id: String = ""
var command_id: String = BattleForceCommandCatalog.DEFAULT_COMMAND
# Stable battle-local facing toward the opposing deployment / objective.
# Not a live aim vector and not persisted to campaign objects.
var forward_direction: Vector2 = Vector2.ZERO


func _init(
	p_tactical_force_id: String = "",
	p_side_id: String = "",
	p_command_id: String = ""
) -> void:
	tactical_force_id = p_tactical_force_id
	side_id = p_side_id
	if p_command_id.is_empty():
		command_id = BattleForceCommandCatalog.DEFAULT_COMMAND
	else:
		command_id = p_command_id


static func is_valid_forward_direction(direction: Vector2) -> bool:
	if not is_finite(direction.x) or not is_finite(direction.y):
		return false
	if direction.is_equal_approx(Vector2.ZERO):
		return false
	return is_equal_approx(direction.length_squared(), 1.0)


func has_valid_forward_direction() -> bool:
	return is_valid_forward_direction(forward_direction)


func set_forward_direction(direction: Vector2) -> bool:
	if not is_finite(direction.x) or not is_finite(direction.y):
		return false
	if direction.is_equal_approx(Vector2.ZERO):
		return false
	var normalized: Vector2 = direction.normalized()
	if not is_valid_forward_direction(normalized):
		return false
	forward_direction = normalized
	return true


# Force-relative right in Godot 2D: 90 degrees via (-forward.y, forward.x).
func right_direction() -> Vector2:
	if not has_valid_forward_direction():
		return Vector2.ZERO
	return Vector2(-forward_direction.y, forward_direction.x)


func left_direction() -> Vector2:
	var right: Vector2 = right_direction()
	if right.is_equal_approx(Vector2.ZERO):
		return Vector2.ZERO
	return -right


func rear_direction() -> Vector2:
	if not has_valid_forward_direction():
		return Vector2.ZERO
	return -forward_direction
