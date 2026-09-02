class_name BattleAttackEvent
extends RefCounted

var source_participant_id: String = ""
var target_participant_id: String = ""
var weapon_type_id: String = ""
var outcome: String = ""
var hit_quality: String = ""
var trauma_applied: float = 0.0
var outcome_roll: float = 0.0
var target_was_wounded: bool = false
var target_is_wounded: bool = false
var target_was_alive: bool = false
var target_is_alive: bool = false
var sequence_id: int = 0
var elapsed_time_seconds: float = 0.0
var source_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var has_source_position: bool = false
var has_target_position: bool = false


func _init(
	p_source_participant_id: String = "",
	p_target_participant_id: String = "",
	p_weapon_type_id: String = "",
	p_outcome: String = "",
	p_outcome_roll: float = 0.0,
	p_target_was_wounded: bool = false,
	p_target_is_wounded: bool = false,
	p_target_was_alive: bool = false,
	p_target_is_alive: bool = false
) -> void:
	source_participant_id = p_source_participant_id
	target_participant_id = p_target_participant_id
	weapon_type_id = p_weapon_type_id
	outcome = p_outcome
	outcome_roll = p_outcome_roll
	target_was_wounded = p_target_was_wounded
	target_is_wounded = p_target_is_wounded
	target_was_alive = p_target_was_alive
	target_is_alive = p_target_is_alive
