class_name BattleCombatBehaviorResult
extends RefCounted

const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")

var success: bool = false
var participants_considered: int = 0
var shots_executed: int = 0
var misses: int = 0
var grazes: int = 0
var wounds: int = 0
var kills: int = 0
var participants_repositioning: int = 0
var participants_holding_defend_position: int = 0
var wounded_seeking_cover: int = 0
var wounded_holding_cover: int = 0
var wounded_threat_override: int = 0
var healthy_seeking_cover: int = 0
var healthy_holding_cover: int = 0
var force_command_hold: int = 0
var force_command_push: int = 0
var force_command_focus_left: int = 0
var force_command_focus_right: int = 0
var force_command_fall_back: int = 0
var pressure_aggression_suppressed: int = 0
var attack_events: Array[BattleAttackEvent] = []
var error_code: String = ""
var error_message: String = ""


static func succeeded(
	p_participants_considered: int,
	p_shots_executed: int = 0,
	p_misses: int = 0,
	p_grazes: int = 0,
	p_wounds: int = 0,
	p_kills: int = 0,
	p_participants_repositioning: int = 0,
	p_participants_holding_defend_position: int = 0,
	p_attack_events: Array = [],
	p_wounded_seeking_cover: int = 0,
	p_wounded_holding_cover: int = 0,
	p_wounded_threat_override: int = 0,
	p_healthy_seeking_cover: int = 0,
	p_healthy_holding_cover: int = 0,
	p_force_command_hold: int = 0,
	p_force_command_push: int = 0,
	p_force_command_focus_left: int = 0,
	p_force_command_focus_right: int = 0,
	p_force_command_fall_back: int = 0,
	p_pressure_aggression_suppressed: int = 0
) -> BattleCombatBehaviorResult:
	var result := new()
	result.success = true
	result.participants_considered = p_participants_considered
	result.shots_executed = p_shots_executed
	result.misses = p_misses
	result.grazes = p_grazes
	result.wounds = p_wounds
	result.kills = p_kills
	result.participants_repositioning = p_participants_repositioning
	result.participants_holding_defend_position = p_participants_holding_defend_position
	result.wounded_seeking_cover = p_wounded_seeking_cover
	result.wounded_holding_cover = p_wounded_holding_cover
	result.wounded_threat_override = p_wounded_threat_override
	result.healthy_seeking_cover = p_healthy_seeking_cover
	result.healthy_holding_cover = p_healthy_holding_cover
	result.force_command_hold = p_force_command_hold
	result.force_command_push = p_force_command_push
	result.force_command_focus_left = p_force_command_focus_left
	result.force_command_focus_right = p_force_command_focus_right
	result.force_command_fall_back = p_force_command_fall_back
	result.pressure_aggression_suppressed = p_pressure_aggression_suppressed
	result.attack_events = _copy_events(p_attack_events)
	result.error_code = ""
	result.error_message = ""
	return result


static func failed(p_error_code: String, p_error_message: String) -> BattleCombatBehaviorResult:
	var result := new()
	result.success = false
	result.participants_considered = 0
	result.shots_executed = 0
	result.misses = 0
	result.grazes = 0
	result.wounds = 0
	result.kills = 0
	result.participants_repositioning = 0
	result.participants_holding_defend_position = 0
	result.wounded_seeking_cover = 0
	result.wounded_holding_cover = 0
	result.wounded_threat_override = 0
	result.healthy_seeking_cover = 0
	result.healthy_holding_cover = 0
	result.force_command_hold = 0
	result.force_command_push = 0
	result.force_command_focus_left = 0
	result.force_command_focus_right = 0
	result.force_command_fall_back = 0
	result.pressure_aggression_suppressed = 0
	result.attack_events = []
	result.error_code = p_error_code
	result.error_message = p_error_message
	return result


static func _copy_events(source: Array) -> Array[BattleAttackEvent]:
	var copied: Array[BattleAttackEvent] = []
	for item: Variant in source:
		if item is BattleAttackEvent:
			copied.append(item as BattleAttackEvent)
	return copied
