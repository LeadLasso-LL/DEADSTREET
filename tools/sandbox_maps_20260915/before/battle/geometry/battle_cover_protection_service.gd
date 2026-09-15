class_name BattleCoverProtectionService
extends RefCounted

const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCoverProtectionResult := preload("res://battle/geometry/battle_cover_protection_result.gd")

# Query-only angular cover quality. Does not mutate state or apply combat mitigation.
# Facing convention: slot.facing_direction points toward the protected approach.
# protection_factor = clampf(facing.dot(normalize(attacker_position - slot.position)), 0.0, 1.0)


static func query_protection(
	geometry: BattlefieldGeometry,
	defender: BattleParticipant,
	attacker_position: Vector2
) -> BattleCoverProtectionResult:
	return query_slot_protection(_applicable_occupied_slot(geometry, defender), attacker_position)


static func query_slot_protection(
	slot: BattleCoverSlot,
	attacker_position: Vector2
) -> BattleCoverProtectionResult:
	if slot == null or not slot.is_valid():
		return BattleCoverProtectionResult.none_applicable()
	if not BattlefieldGeometry.is_finite_point(slot.position):
		return BattleCoverProtectionResult.none_applicable()
	if not _facing_is_usable(slot.facing_direction):
		return BattleCoverProtectionResult.none_applicable()
	if not BattlefieldGeometry.is_finite_point(attacker_position):
		return BattleCoverProtectionResult.none_applicable()
	var to_attacker: Vector2 = attacker_position - slot.position
	if not BattlefieldGeometry.is_finite_point(to_attacker):
		return BattleCoverProtectionResult.from_occupied_slot(slot.cover_slot_id, 0.0, 0.0)
	if to_attacker.is_equal_approx(Vector2.ZERO):
		return BattleCoverProtectionResult.from_occupied_slot(slot.cover_slot_id, 0.0, 0.0)
	var direction_to_attacker: Vector2 = to_attacker.normalized()
	if (
		not BattlefieldGeometry.is_finite_point(direction_to_attacker)
		or direction_to_attacker.is_equal_approx(Vector2.ZERO)
	):
		return BattleCoverProtectionResult.from_occupied_slot(slot.cover_slot_id, 0.0, 0.0)
	var facing: Vector2 = slot.facing_direction.normalized()
	if not BattlefieldGeometry.is_finite_point(facing) or facing.is_equal_approx(Vector2.ZERO):
		return BattleCoverProtectionResult.none_applicable()
	var alignment_dot: float = facing.dot(direction_to_attacker)
	if not is_finite(alignment_dot):
		return BattleCoverProtectionResult.from_occupied_slot(slot.cover_slot_id, 0.0, 0.0)
	var protection_factor: float = clampf(alignment_dot, 0.0, 1.0)
	return BattleCoverProtectionResult.from_occupied_slot(
		slot.cover_slot_id,
		protection_factor,
		alignment_dot
	)


static func _applicable_occupied_slot(
	geometry: BattlefieldGeometry,
	defender: BattleParticipant
) -> BattleCoverSlot:
	if geometry == null or defender == null:
		return null
	if defender.participant_id.is_empty():
		return null
	if not defender.is_alive:
		return null
	if not defender.has_battle_position:
		return null
	if not BattlefieldGeometry.is_finite_point(defender.battle_position):
		return null
	if defender.occupied_cover_slot_id.is_empty():
		return null
	var slot: BattleCoverSlot = geometry.get_cover_slot(defender.occupied_cover_slot_id)
	if slot == null:
		return null
	if slot.occupied_by_participant_id != defender.participant_id:
		return null
	if not BattlefieldGeometry.is_finite_point(slot.position):
		return null
	if not _facing_is_usable(slot.facing_direction):
		return null
	return slot


static func _facing_is_usable(facing: Vector2) -> bool:
	if not BattlefieldGeometry.is_finite_point(facing):
		return false
	if facing.is_equal_approx(Vector2.ZERO):
		return false
	var normalized: Vector2 = facing.normalized()
	if not BattlefieldGeometry.is_finite_point(normalized):
		return false
	return not normalized.is_equal_approx(Vector2.ZERO)
