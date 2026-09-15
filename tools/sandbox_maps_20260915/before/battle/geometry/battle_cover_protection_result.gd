class_name BattleCoverProtectionResult
extends RefCounted

# Geometry-only cover angle query. Not a combat modifier.
var has_applicable_cover: bool = false
var cover_slot_id: String = ""
var protection_factor: float = 0.0
var alignment_dot: float = 0.0


static func none_applicable() -> BattleCoverProtectionResult:
	var result := new()
	result.has_applicable_cover = false
	result.cover_slot_id = ""
	result.protection_factor = 0.0
	result.alignment_dot = 0.0
	return result


static func from_occupied_slot(
	p_cover_slot_id: String,
	p_protection_factor: float,
	p_alignment_dot: float
) -> BattleCoverProtectionResult:
	var result := new()
	result.has_applicable_cover = true
	result.cover_slot_id = p_cover_slot_id
	result.protection_factor = _clamped_factor(p_protection_factor)
	if is_finite(p_alignment_dot):
		result.alignment_dot = p_alignment_dot
	else:
		result.alignment_dot = 0.0
	return result


static func _clamped_factor(value: float) -> float:
	if not is_finite(value):
		return 0.0
	return clampf(value, 0.0, 1.0)
