class_name BusinessEconomyDefinition
extends RefCounted

const BusinessLevelOutput := preload("res://campaign/economy/business_level_output.gd")

var business_type_id: String = ""
var _level_outputs: Dictionary = {}


func _init(p_business_type_id: String = "") -> void:
	business_type_id = p_business_type_id


func set_level_output(level: int, output: BusinessLevelOutput) -> bool:
	if business_type_id.is_empty():
		push_error("BusinessEconomyDefinition.set_level_output: business_type_id is empty.")
		return false
	if level < 1:
		push_error(
			"BusinessEconomyDefinition.set_level_output: level must be >= 1 (business_type_id='%s', level=%s)."
			% [business_type_id, level]
		)
		return false
	if output == null:
		push_error(
			"BusinessEconomyDefinition.set_level_output: output is null (business_type_id='%s', level=%s)."
			% [business_type_id, level]
		)
		return false
	_level_outputs[level] = output
	return true


func get_level_output(level: int) -> BusinessLevelOutput:
	if not has_level_output(level):
		return null
	return _level_outputs[level] as BusinessLevelOutput


func has_level_output(level: int) -> bool:
	return _level_outputs.has(level)
