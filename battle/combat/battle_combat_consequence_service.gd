class_name BattleCombatConsequenceService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleCombatConsequenceResult := preload("res://battle/combat/battle_combat_consequence_result.gd")

# Hidden tactical vitality. Not a player-facing HP value.
# Survival-first v1 provisional baseline is 1.5× the prior 1.0 max.
# Wound remains at 35% of baseline remaining: 0.525 of 1.5.
# vitality > 0.525 → Healthy; vitality <= 0.525 and > 0 → Wounded; vitality == 0 → Dead.
const BASELINE_VITALITY := 1.5
const WOUNDED_VITALITY_FRACTION := 0.35
const WOUNDED_VITALITY_THRESHOLD := BASELINE_VITALITY * WOUNDED_VITALITY_FRACTION


static func clamp_vitality(value: float) -> float:
	if not is_finite(value):
		return 0.0
	return clampf(value, 0.0, BASELINE_VITALITY)


static func is_dead_vitality(vitality: float) -> bool:
	var clamped: float = clamp_vitality(vitality)
	return clamped <= 0.0


static func is_wounded_vitality(vitality: float) -> bool:
	var clamped: float = clamp_vitality(vitality)
	if is_dead_vitality(clamped):
		return false
	return clamped <= WOUNDED_VITALITY_THRESHOLD


static func apply_trauma(
	battle_state: BattleState,
	target: BattleParticipant,
	trauma: float
) -> BattleCombatConsequenceResult:
	if target == null:
		return BattleCombatConsequenceResult.failed(
			"null_target",
			"Battle combat consequence failed: target is null."
		)
	var applied_trauma: float = trauma
	if not is_finite(applied_trauma) or applied_trauma < 0.0:
		applied_trauma = 0.0
	var vitality_before: float = clamp_vitality(target.vitality)
	target.vitality = vitality_before
	var was_wounded: bool = target.is_wounded
	var was_alive: bool = target.is_alive
	if not was_alive:
		target.vitality = 0.0
		return BattleCombatConsequenceResult.applied(
			applied_trauma,
			vitality_before,
			0.0,
			was_wounded,
			target.is_wounded,
			false,
			false,
			false,
			false
		)
	var vitality_after: float = clamp_vitality(vitality_before - applied_trauma)
	target.vitality = vitality_after
	if is_dead_vitality(vitality_after):
		target.vitality = 0.0
		target.is_alive = false
		target.wound_reaction_remaining_seconds = 0.0
		target.acquire_reaction_remaining_seconds = 0.0
		target.acquire_reaction_target_id = ""
		target.sniper_aim_remaining_seconds = 0.0
		target.sniper_aim_target_id = ""
		target.sniper_aim_engagement_active = false
		BattleCoverService.release_all_for_participant(battle_state, target.participant_id)
		return BattleCombatConsequenceResult.applied(
			applied_trauma,
			vitality_before,
			0.0,
			was_wounded,
			target.is_wounded,
			true,
			false,
			false,
			true
		)
	var wound_transitioned: bool = false
	if is_wounded_vitality(vitality_after) and not was_wounded:
		target.is_wounded = true
		wound_transitioned = true
		target.wound_reaction_remaining_seconds = (
			BattleCombatBehaviorCatalog.WOUNDED_REACTION_DELAY_SECONDS
		)
		target.acquire_reaction_remaining_seconds = 0.0
		target.sniper_aim_remaining_seconds = 0.0
	return BattleCombatConsequenceResult.applied(
		applied_trauma,
		vitality_before,
		vitality_after,
		was_wounded,
		target.is_wounded,
		true,
		true,
		wound_transitioned,
		false
	)
