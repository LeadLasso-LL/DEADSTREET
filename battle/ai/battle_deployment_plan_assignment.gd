class_name BattleDeploymentPlanAssignment
extends RefCounted

# Query-only intended placement. Not BattleState mutation.

var participant_id: String = ""
var position: Vector2 = Vector2.ZERO
var score: float = 0.0
var reason: String = ""


func _init(
	p_participant_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_score: float = 0.0,
	p_reason: String = ""
) -> void:
	participant_id = p_participant_id
	position = p_position
	score = p_score
	reason = p_reason
