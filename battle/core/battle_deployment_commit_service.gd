class_name BattleDeploymentCommitService
extends RefCounted

# Authoritative side-local deployment commitment during battle_phase "deployment".
# Answers whether one side may commit its own deployment. Does not own assault order.
# Does not begin battle. Vehicles do not block commitment in v1; that exclusion is provisional.
# Commit eligibility is BattleState-owned; this service reports result objects.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleDeploymentCommitResult := preload("res://battle/core/battle_deployment_commit_result.gd")


static func commit_side_deployment(
	battle_state: BattleState,
	side_id: String
) -> BattleDeploymentCommitResult:
	var check: BattleDeploymentCommitResult = evaluate_side_deployment(battle_state, side_id)
	if check == null or not check.success:
		return check
	if not battle_state.commit_side_deployment(side_id):
		return BattleDeploymentCommitResult.failed(
			"commit_failed",
			"Deployment commit failed: BattleState rejected side '%s'." % side_id,
			side_id
		)
	return BattleDeploymentCommitResult.succeeded(side_id)


static func evaluate_side_deployment(
	battle_state: BattleState,
	side_id: String
) -> BattleDeploymentCommitResult:
	if battle_state == null:
		return BattleDeploymentCommitResult.failed(
			"null_battle_state",
			"Deployment commit failed: battle_state is null.",
			side_id
		)
	var error_code: String = battle_state.get_side_deployment_commit_error(side_id)
	if error_code.is_empty():
		return BattleDeploymentCommitResult.succeeded(side_id)
	return BattleDeploymentCommitResult.failed(
		error_code,
		_error_message(error_code, side_id, battle_state),
		side_id
	)


static func _error_message(error_code: String, side_id: String, battle_state: BattleState) -> String:
	match error_code:
		"battle_not_in_deployment":
			return "Deployment commit failed: battle phase is '%s', not deployment." % battle_state.battle_phase
		"unknown_side":
			return "Deployment commit failed: side '%s' does not exist." % side_id
		"missing_deployment_zone":
			return "Deployment commit failed: side '%s' has no deployment zone." % side_id
		"already_committed":
			return "Deployment commit failed: side '%s' is already committed." % side_id
		"unknown_participant":
			return "Deployment commit failed: a participant registered on side '%s' is missing." % side_id
		"undeployed_living_participant":
			return "Deployment commit failed: a living participant on side '%s' is not deployed." % side_id
		"missing_battle_position":
			return "Deployment commit failed: a living participant on side '%s' has no battle position." % side_id
		"invalid_position":
			return "Deployment commit failed: a living participant on side '%s' is not fully deployed." % side_id
		"no_living_participants":
			return "Deployment commit failed: side '%s' has no living participants." % side_id
		_:
			return "Deployment commit failed: side '%s' cannot commit (%s)." % [side_id, error_code]
