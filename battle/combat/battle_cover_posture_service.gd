class_name BattleCoverPostureService
extends RefCounted

# Battle-local occupied-cover posture. Combat authority, not presentation.
# Geometry LOS stays geometry LOS. Tucked protection is a fire-eligibility rule
# against the target's currently occupied cover slot and this shooter's direction.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverProtectionService := preload("res://battle/geometry/battle_cover_protection_service.gd")
const BattleCoverProtectionResult := preload("res://battle/geometry/battle_cover_protection_result.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")

const POSTURE_NONE := "none"
const POSTURE_TUCKED := "tucked"
const POSTURE_EXPOSED := "exposed"

const PHASE_IDLE := ""
const PHASE_EXPOSING := "exposing"
const PHASE_HOLDING := "holding"
const PHASE_TUCKING := "tucking"


static func clear(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.cover_posture = POSTURE_NONE
	participant.cover_posture_phase = PHASE_IDLE
	participant.cover_posture_timer_seconds = 0.0


static func enter_tucked(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.cover_posture = POSTURE_TUCKED
	participant.cover_posture_phase = PHASE_IDLE
	participant.cover_posture_timer_seconds = 0.0


static func ensure_occupied_posture(participant: BattleParticipant) -> void:
	if participant == null:
		return
	if participant.cover_posture == POSTURE_TUCKED or participant.cover_posture == POSTURE_EXPOSED:
		return
	enter_tucked(participant)


static func force_exposed(participant: BattleParticipant) -> void:
	if participant == null:
		return
	participant.cover_posture = POSTURE_EXPOSED
	participant.cover_posture_phase = PHASE_HOLDING
	participant.cover_posture_timer_seconds = BattleCombatBehaviorCatalog.COVER_EXPOSED_WINDOW_SECONDS


static func is_tucked(participant: BattleParticipant) -> bool:
	return participant != null and participant.cover_posture == POSTURE_TUCKED


static func is_exposed(participant: BattleParticipant) -> bool:
	return participant != null and participant.cover_posture == POSTURE_EXPOSED


static func is_source_blocked_by_tuck(participant: BattleParticipant) -> bool:
	return is_tucked(participant)


static func is_target_tucked_protected(
	battle_state: BattleState,
	source: BattleParticipant,
	target: BattleParticipant
) -> bool:
	if battle_state == null or source == null or target == null:
		return false
	if not is_tucked(target):
		return false
	if battle_state.battlefield_geometry == null:
		return false
	if not source.has_battle_position:
		return false
	var protection: BattleCoverProtectionResult = BattleCoverProtectionService.query_protection(
		battle_state.battlefield_geometry,
		target,
		source.battle_position
	)
	if protection == null or not protection.has_applicable_cover:
		return false
	if not is_finite(protection.protection_factor):
		return false
	return (
		protection.protection_factor
		>= BattleCombatBehaviorCatalog.COVER_TUCKED_SHOT_BLOCK_FACTOR
	)


static func update_for_combat(
	battle_state: BattleState,
	participant: BattleParticipant,
	delta_seconds: float,
	allow_begin_expose: bool
) -> void:
	if participant == null:
		return
	if not participant.is_alive or not _has_valid_occupancy(battle_state, participant):
		clear(participant)
		return
	ensure_occupied_posture(participant)
	if allow_begin_expose:
		_begin_expose_if_needed(battle_state, participant)
	_advance_timers(participant, delta_seconds)


static func _begin_expose_if_needed(
	battle_state: BattleState,
	participant: BattleParticipant
) -> void:
	if participant == null:
		return
	if participant.cover_posture != POSTURE_TUCKED:
		return
	if participant.cover_posture_phase != PHASE_IDLE:
		return
	if participant.has_acquire_reaction() or participant.has_sniper_aim():
		return
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		return
	if not BattleFireControlService.would_fire_if_source_cover_exposed(
		battle_state,
		participant.participant_id,
		participant.target_participant_id
	):
		return
	participant.cover_posture = POSTURE_TUCKED
	participant.cover_posture_phase = PHASE_EXPOSING
	participant.cover_posture_timer_seconds = BattleCombatBehaviorCatalog.COVER_TUCK_TO_EXPOSE_SECONDS


static func _advance_timers(participant: BattleParticipant, delta_seconds: float) -> void:
	if participant == null:
		return
	if not is_finite(participant.cover_posture_timer_seconds):
		participant.cover_posture_timer_seconds = 0.0
	if not is_finite(delta_seconds) or delta_seconds <= 0.0:
		return
	if participant.cover_posture_phase == PHASE_IDLE:
		return
	participant.cover_posture_timer_seconds = maxf(
		participant.cover_posture_timer_seconds - delta_seconds,
		0.0
	)
	if participant.cover_posture_timer_seconds > 0.0:
		return
	match participant.cover_posture_phase:
		PHASE_EXPOSING:
			participant.cover_posture = POSTURE_EXPOSED
			participant.cover_posture_phase = PHASE_HOLDING
			participant.cover_posture_timer_seconds = (
				BattleCombatBehaviorCatalog.COVER_EXPOSED_WINDOW_SECONDS
			)
		PHASE_HOLDING:
			participant.cover_posture = POSTURE_TUCKED
			participant.cover_posture_phase = PHASE_TUCKING
			participant.cover_posture_timer_seconds = (
				BattleCombatBehaviorCatalog.COVER_EXPOSE_TO_TUCK_SECONDS
			)
		PHASE_TUCKING:
			enter_tucked(participant)
		_:
			enter_tucked(participant)


static func _has_valid_occupancy(
	battle_state: BattleState,
	participant: BattleParticipant
) -> bool:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if participant.occupied_cover_slot_id.is_empty():
		return false
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
		participant.occupied_cover_slot_id
	)
	if slot == null or not slot.is_valid():
		return false
	return slot.occupied_by_participant_id == participant.participant_id
