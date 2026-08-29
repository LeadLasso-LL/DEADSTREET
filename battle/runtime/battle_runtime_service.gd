class_name BattleRuntimeService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleRuntimeResult := preload("res://battle/runtime/battle_runtime_result.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")
const BattleTargetSelectionService := preload("res://battle/combat/battle_target_selection_service.gd")
const BattleTargetSelectionResult := preload("res://battle/combat/battle_target_selection_result.gd")
const BattleCombatBehaviorService := preload("res://battle/combat/battle_combat_behavior_service.gd")
const BattleCombatBehaviorResult := preload("res://battle/combat/battle_combat_behavior_result.gd")
const BattlePathFollowService := preload("res://battle/navigation/battle_path_follow_service.gd")
const BattlePathFollowResult := preload("res://battle/navigation/battle_path_follow_result.gd")
const BattleMovementService := preload("res://battle/runtime/battle_movement_service.gd")
const BattleMovementResult := preload("res://battle/runtime/battle_movement_result.gd")


static func advance(battle_state: BattleState, delta_seconds: float) -> BattleRuntimeResult:
	if battle_state == null:
		return BattleRuntimeResult.failed(
			"null_battle_state",
			"Battle runtime failed: battle_state is null.",
			delta_seconds,
			0.0
		)
	var elapsed_before: float = battle_state.elapsed_time_seconds
	if battle_state.battle_phase != "active":
		return BattleRuntimeResult.failed(
			"battle_not_active",
			"Battle runtime failed: battle phase is '%s', not active." % battle_state.battle_phase,
			delta_seconds,
			elapsed_before
		)
	if not is_finite(delta_seconds) or delta_seconds < 0.0:
		return BattleRuntimeResult.failed(
			"invalid_delta",
			"Battle runtime failed: delta_seconds is invalid.",
			delta_seconds,
			elapsed_before
		)
	if not is_finite(elapsed_before) or elapsed_before < 0.0:
		return BattleRuntimeResult.failed(
			"invalid_elapsed_time",
			"Battle runtime failed: elapsed_time_seconds is invalid.",
			delta_seconds,
			elapsed_before
		)
	var weapon_result: BattleFireControlResult = BattleFireControlService.advance_weapon_state(
		battle_state,
		delta_seconds
	)
	if weapon_result == null or not weapon_result.success:
		var weapon_error_code: String = "invalid_delta"
		var weapon_error_message: String = "Battle runtime failed: weapon state advancement failed."
		if weapon_result != null:
			if not weapon_result.error_code.is_empty():
				weapon_error_code = weapon_result.error_code
			if not weapon_result.error_message.is_empty():
				weapon_error_message = weapon_result.error_message
		return BattleRuntimeResult.failed(
			weapon_error_code,
			weapon_error_message,
			delta_seconds,
			elapsed_before
		)
	var target_result: BattleTargetSelectionResult = BattleTargetSelectionService.advance(battle_state)
	if target_result == null or not target_result.success:
		var target_error_code: String = "invalid_delta"
		var target_error_message: String = "Battle runtime failed: target selection failed."
		if target_result != null:
			if not target_result.error_code.is_empty():
				target_error_code = target_result.error_code
			if not target_result.error_message.is_empty():
				target_error_message = target_result.error_message
		return BattleRuntimeResult.failed(
			target_error_code,
			target_error_message,
			delta_seconds,
			elapsed_before
		)
	var combat_result: BattleCombatBehaviorResult = BattleCombatBehaviorService.advance(
		battle_state,
		delta_seconds
	)
	if combat_result == null or not combat_result.success:
		var combat_error_code: String = "invalid_delta"
		var combat_error_message: String = "Battle runtime failed: combat behavior failed."
		if combat_result != null:
			if not combat_result.error_code.is_empty():
				combat_error_code = combat_result.error_code
			if not combat_result.error_message.is_empty():
				combat_error_message = combat_result.error_message
		return BattleRuntimeResult.failed(
			combat_error_code,
			combat_error_message,
			delta_seconds,
			elapsed_before
		)
	var path_follow_result: BattlePathFollowResult = BattlePathFollowService.advance(battle_state)
	if path_follow_result == null or not path_follow_result.success:
		var follow_error_code: String = "invalid_delta"
		var follow_error_message: String = "Battle runtime failed: path following failed."
		if path_follow_result != null:
			if not path_follow_result.error_code.is_empty():
				follow_error_code = path_follow_result.error_code
			if not path_follow_result.error_message.is_empty():
				follow_error_message = path_follow_result.error_message
		return BattleRuntimeResult.failed(
			follow_error_code,
			follow_error_message,
			delta_seconds,
			elapsed_before
		)
	var movement_result: BattleMovementResult = BattleMovementService.advance(battle_state, delta_seconds)
	if movement_result == null or not movement_result.success:
		var error_code: String = "invalid_delta"
		var error_message: String = "Battle runtime failed: movement advancement failed."
		if movement_result != null:
			if not movement_result.error_code.is_empty():
				error_code = movement_result.error_code
			if not movement_result.error_message.is_empty():
				error_message = movement_result.error_message
		return BattleRuntimeResult.failed(
			error_code,
			error_message,
			delta_seconds,
			elapsed_before
		)
	if delta_seconds == 0.0:
		return BattleRuntimeResult.succeeded(delta_seconds, elapsed_before, elapsed_before)
	battle_state.elapsed_time_seconds = elapsed_before + delta_seconds
	return BattleRuntimeResult.succeeded(
		delta_seconds,
		elapsed_before,
		battle_state.elapsed_time_seconds
	)
