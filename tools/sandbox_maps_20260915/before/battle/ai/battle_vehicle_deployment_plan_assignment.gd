class_name BattleVehicleDeploymentPlanAssignment
extends RefCounted

# Query-only intended vehicle pose. Not BattleState mutation.

var vehicle_id: String = ""
var position: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO


func _init(
	p_vehicle_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_facing_direction: Vector2 = Vector2.ZERO
) -> void:
	vehicle_id = p_vehicle_id
	position = p_position
	facing_direction = p_facing_direction
