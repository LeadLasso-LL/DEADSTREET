class_name BattleDeploymentAiService
extends RefCounted

# Authoritative application of a query-only deployment plan.
# Places through BattleDeploymentPlacementService, then commits through
# BattleDeploymentCommitService. Does not write participant fields directly.
# Does not begin battle.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleDeploymentPlanner := preload("res://battle/ai/battle_deployment_planner.gd")
const BattleDeploymentPlan := preload("res://battle/ai/battle_deployment_plan.gd")
const BattleDeploymentPlanAssignment := preload("res://battle/ai/battle_deployment_plan_assignment.gd")
const BattleDeploymentPlacementService := preload("res://battle/core/battle_deployment_placement_service.gd")
const BattleDeploymentPlacementResult := preload("res://battle/core/battle_deployment_placement_result.gd")
const BattleDeploymentCommitService := preload("res://battle/core/battle_deployment_commit_service.gd")
const BattleDeploymentCommitResult := preload("res://battle/core/battle_deployment_commit_result.gd")
const BattleDeploymentAiResult := preload("res://battle/ai/battle_deployment_ai_result.gd")

# Invariant: after a complete prevalidated plan, placement of each assignment
# cannot fail under unchanged BattleState. Current soldier placement legality is
# independent (no spacing rule), and get_deployment_position_error is the same
# authority used by BattleDeploymentPlacementService. This service therefore
# does not add speculative rollback. If application still fails partway, the
# side is left uncommitted and already-applied placements remain.


static func apply_and_commit_side(
	battle_state: BattleState,
	side_id: String,
	opposing_side_id: String
) -> BattleDeploymentAiResult:
	var plan: BattleDeploymentPlan = BattleDeploymentPlanner.plan_side_deployment(
		battle_state,
		side_id,
		opposing_side_id
	)
	if plan == null or not plan.success:
		var error_code: String = "plan_failed"
		var error_message: String = "Deployment AI failed: planner did not produce a valid plan."
		if plan != null:
			if not plan.error_code.is_empty():
				error_code = plan.error_code
			if not plan.error_message.is_empty():
				error_message = plan.error_message
		return BattleDeploymentAiResult.failed(
			error_code,
			error_message,
			side_id,
			opposing_side_id,
			plan
		)
	var precheck: BattleDeploymentAiResult = _prevalidate_plan(battle_state, plan)
	if precheck != null:
		return precheck
	for assignment: BattleDeploymentPlanAssignment in plan.assignments:
		var placed: BattleDeploymentPlacementResult = BattleDeploymentPlacementService.place_participant(
			battle_state,
			assignment.participant_id,
			assignment.position
		)
		if placed == null or not placed.success:
			var place_code: String = "place_failed"
			var place_message: String = (
				"Deployment AI failed: authoritative placement rejected '%s'."
				% assignment.participant_id
			)
			if placed != null:
				if not placed.error_code.is_empty():
					place_code = placed.error_code
				if not placed.error_message.is_empty():
					place_message = placed.error_message
			return BattleDeploymentAiResult.failed(
				place_code,
				place_message,
				side_id,
				opposing_side_id,
				plan
			)
	var committed: BattleDeploymentCommitResult = BattleDeploymentCommitService.commit_side_deployment(
		battle_state,
		side_id
	)
	if committed == null or not committed.success:
		var commit_code: String = "commit_failed"
		var commit_message: String = (
			"Deployment AI failed: authoritative commit rejected side '%s'." % side_id
		)
		if committed != null:
			if not committed.error_code.is_empty():
				commit_code = committed.error_code
			if not committed.error_message.is_empty():
				commit_message = committed.error_message
		return BattleDeploymentAiResult.failed(
			commit_code,
			commit_message,
			side_id,
			opposing_side_id,
			plan
		)
	return BattleDeploymentAiResult.succeeded(side_id, opposing_side_id, plan)


static func _prevalidate_plan(
	battle_state: BattleState,
	plan: BattleDeploymentPlan
) -> BattleDeploymentAiResult:
	var eligible_ids: Array[String] = BattleDeploymentPlanner.collect_eligible_participant_ids(
		battle_state,
		plan.side_id
	)
	if plan.assignments.is_empty():
		return BattleDeploymentAiResult.failed(
			"empty_plan",
			"Deployment AI failed: plan contained no assignments.",
			plan.side_id,
			plan.opposing_side_id,
			plan
		)
	if plan.assignments.size() != eligible_ids.size():
		return BattleDeploymentAiResult.failed(
			"plan_participant_mismatch",
			"Deployment AI failed: plan does not cover every eligible participant exactly once.",
			plan.side_id,
			plan.opposing_side_id,
			plan
		)
	var seen: Dictionary = {}
	for assignment: BattleDeploymentPlanAssignment in plan.assignments:
		if assignment == null or assignment.participant_id.is_empty():
			return BattleDeploymentAiResult.failed(
				"invalid_assignment",
				"Deployment AI failed: plan contains an invalid assignment.",
				plan.side_id,
				plan.opposing_side_id,
				plan
			)
		if seen.has(assignment.participant_id):
			return BattleDeploymentAiResult.failed(
				"duplicate_assignment",
				"Deployment AI failed: participant '%s' appears more than once." % assignment.participant_id,
				plan.side_id,
				plan.opposing_side_id,
				plan
			)
		seen[assignment.participant_id] = true
		if not eligible_ids.has(assignment.participant_id):
			return BattleDeploymentAiResult.failed(
				"ineligible_participant",
				"Deployment AI failed: participant '%s' is not eligible." % assignment.participant_id,
				plan.side_id,
				plan.opposing_side_id,
				plan
			)
		var participant: BattleParticipant = battle_state.get_participant(assignment.participant_id)
		if participant == null or not participant.is_alive:
			return BattleDeploymentAiResult.failed(
				"ineligible_participant",
				"Deployment AI failed: participant '%s' is not a living undeployed member." % assignment.participant_id,
				plan.side_id,
				plan.opposing_side_id,
				plan
			)
		var legality: String = battle_state.get_deployment_position_error(
			plan.side_id,
			assignment.position
		)
		if not legality.is_empty():
			return BattleDeploymentAiResult.failed(
				legality,
				"Deployment AI failed: planned position for '%s' is not legal." % assignment.participant_id,
				plan.side_id,
				plan.opposing_side_id,
				plan
			)
	for eligible_id: String in eligible_ids:
		if not seen.has(eligible_id):
			return BattleDeploymentAiResult.failed(
				"plan_participant_mismatch",
				"Deployment AI failed: eligible participant '%s' is missing from the plan." % eligible_id,
				plan.side_id,
				plan.opposing_side_id,
				plan
			)
	return null
