class_name BattleAttackResolutionService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")
const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")
const BattleAttackEvent := preload("res://battle/combat/battle_attack_event.gd")
const BattleAttackResult := preload("res://battle/combat/battle_attack_result.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverProtectionService := preload("res://battle/geometry/battle_cover_protection_service.gd")
const BattleCoverProtectionResult := preload("res://battle/geometry/battle_cover_protection_result.gd")
const BattleCoverCombatEffectService := preload("res://battle/combat/battle_cover_combat_effect_service.gd")
const BattleCoverCombatEffectResult := preload("res://battle/combat/battle_cover_combat_effect_result.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")


static func resolve_attack(
	battle_state: BattleState,
	source_participant_id: String,
	target_participant_id: String,
	outcome_roll: float
) -> BattleAttackResult:
	if battle_state == null:
		return BattleAttackResult.failed(
			"null_battle_state",
			"Battle attack resolution failed: battle_state is null."
		)
	if battle_state.battle_phase != "active":
		return BattleAttackResult.failed(
			"battle_not_active",
			"Battle attack resolution failed: battle phase is '%s', not active." % battle_state.battle_phase
		)
	if battle_state.battlefield_geometry == null:
		return BattleAttackResult.failed(
			"missing_battlefield_geometry",
			"Battle attack resolution failed: battlefield geometry is missing."
		)
	if not battle_state.battlefield_geometry.is_valid():
		return BattleAttackResult.failed(
			"invalid_battlefield_geometry",
			"Battle attack resolution failed: battlefield geometry is invalid."
		)
	if source_participant_id.is_empty():
		return BattleAttackResult.failed(
			"empty_source_id",
			"Battle attack resolution failed: source participant id is empty."
		)
	if target_participant_id.is_empty():
		return BattleAttackResult.failed(
			"empty_target_id",
			"Battle attack resolution failed: target participant id is empty."
		)
	if not BattleAttackProfile.is_valid_outcome_roll(outcome_roll):
		return BattleAttackResult.failed(
			"invalid_outcome_roll",
			"Battle attack resolution failed: outcome_roll is invalid."
		)
	if not battle_state.has_participant(source_participant_id):
		return BattleAttackResult.failed(
			"source_not_found",
			"Battle attack resolution failed: source participant was not found."
		)
	if not battle_state.has_participant(target_participant_id):
		return BattleAttackResult.failed(
			"target_not_found",
			"Battle attack resolution failed: target participant was not found."
		)
	var eligibility: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
		battle_state,
		source_participant_id,
		target_participant_id
	)
	if eligibility == null or not eligibility.success:
		var error_code: String = "fire_eligibility_failed"
		var error_message: String = "Battle attack resolution failed: fire eligibility could not be evaluated."
		if eligibility != null:
			if not eligibility.error_code.is_empty():
				error_code = eligibility.error_code
			if not eligibility.error_message.is_empty():
				error_message = eligibility.error_message
		return BattleAttackResult.failed(error_code, error_message)
	if not eligibility.can_fire:
		return BattleAttackResult.rejected(eligibility.rejection_code)
	var source: BattleParticipant = battle_state.get_participant(source_participant_id)
	var target: BattleParticipant = battle_state.get_participant(target_participant_id)
	if source == null or target == null or source.weapon_state == null:
		return BattleAttackResult.failed(
			"invalid_weapon_state",
			"Battle attack resolution failed: participant weapon state is invalid."
		)
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(source.weapon_state.weapon_type_id)
	if definition == null:
		return BattleAttackResult.failed(
			"invalid_weapon_state",
			"Battle attack resolution failed: weapon definition is missing."
		)
	var profile: BattleAttackProfile = BattleAttackProfile.current()
	if profile == null or not profile.is_valid():
		return BattleAttackResult.failed(
			"invalid_attack_profile",
			"Battle attack resolution failed: attack profile is invalid."
		)
	var protection: BattleCoverProtectionResult = BattleCoverProtectionService.query_protection(
		battle_state.battlefield_geometry,
		target,
		source.battle_position
	)
	var protection_factor: float = 0.0
	if protection != null and protection.has_applicable_cover:
		protection_factor = protection.protection_factor
	var cover_effect: BattleCoverCombatEffectResult = BattleCoverCombatEffectService.apply(
		outcome_roll,
		protection_factor
	)
	var resolved_roll: float = outcome_roll
	if cover_effect != null:
		resolved_roll = cover_effect.post_cover_roll
	var outcome: String = profile.resolve_outcome(resolved_roll)
	if outcome.is_empty():
		return BattleAttackResult.failed(
			"invalid_attack_profile",
			"Battle attack resolution failed: outcome could not be resolved."
		)
	var fire_rate_multiplier: float = 1.0
	if source.is_wounded:
		fire_rate_multiplier = BattleCombatBehaviorCatalog.WOUNDED_FIRE_RATE_MULTIPLIER
	var target_was_wounded: bool = target.is_wounded
	var target_was_alive: bool = target.is_alive
	if not BattleFireControlService.commit_shot(source, definition, fire_rate_multiplier):
		return BattleAttackResult.failed(
			"shot_commit_failed",
			"Battle attack resolution failed: weapon cycling could not be committed."
		)
	_apply_outcome(battle_state, target, outcome)
	var attack_event: BattleAttackEvent = BattleAttackEvent.new(
		source.participant_id,
		target.participant_id,
		source.weapon_state.weapon_type_id,
		outcome,
		resolved_roll,
		target_was_wounded,
		target.is_wounded,
		target_was_alive,
		target.is_alive
	)
	attack_event.elapsed_time_seconds = battle_state.elapsed_time_seconds
	if source.has_battle_position:
		attack_event.source_position = source.battle_position
		attack_event.has_source_position = true
	if target.has_battle_position:
		attack_event.target_position = target.battle_position
		attack_event.has_target_position = true
	battle_state.record_combat_feedback_event(attack_event)
	return BattleAttackResult.executed(attack_event)


static func _apply_outcome(
	battle_state: BattleState,
	target: BattleParticipant,
	outcome: String
) -> void:
	if target == null:
		return
	match outcome:
		BattleAttackProfile.OUTCOME_WOUND:
			var newly_wounded: bool = not target.is_wounded
			target.is_wounded = true
			if newly_wounded:
				target.wound_reaction_remaining_seconds = (
					BattleCombatBehaviorCatalog.WOUNDED_REACTION_DELAY_SECONDS
				)
		BattleAttackProfile.OUTCOME_KILL:
			target.is_alive = false
			target.wound_reaction_remaining_seconds = 0.0
			BattleCoverService.release_all_for_participant(battle_state, target.participant_id)
		_:
			pass
