class_name BattleRuntimeService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleRuntimeResult := preload("res://battle/runtime/battle_runtime_result.gd")
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
