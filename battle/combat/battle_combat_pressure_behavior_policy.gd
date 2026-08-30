class_name BattleCombatPressureBehaviorPolicy
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCombatPressureCatalog := preload("res://battle/combat/battle_combat_pressure_catalog.gd")
const BattleCombatPressureSnapshot := preload("res://battle/combat/battle_combat_pressure_snapshot.gd")
const BattleCombatPressureService := preload("res://battle/combat/battle_combat_pressure_service.gd")
const BattleCombatPressureBehaviorPolicyResult := preload(
	"res://battle/combat/battle_combat_pressure_behavior_policy_result.gd"
)

# Pressure-to-behavior policy. Does not mutate state, consume RNG, or refresh pressure.


static func evaluate(
	battle_state: BattleState,
	participant: BattleParticipant
) -> BattleCombatPressureBehaviorPolicyResult:
	var result: BattleCombatPressureBehaviorPolicyResult = BattleCombatPressureBehaviorPolicyResult.new()
	result.suppress_aggressive_autonomous_movement = false
	if battle_state == null or participant == null:
		return result
	if not participant.is_alive:
		return result
	if participant.is_wounded:
		return result
	var snapshot: BattleCombatPressureSnapshot = BattleCombatPressureService.get_snapshot(
		battle_state,
		participant.participant_id
	)
	if snapshot == null:
		return result
	if snapshot.participant_id != participant.participant_id:
		return result
	if not is_finite(snapshot.total_pressure):
		return result
	var threshold: float = BattleCombatPressureCatalog.HIGH_PRESSURE_AGGRESSION_THRESHOLD
	if not is_finite(threshold):
		return result
	if (
		snapshot.total_pressure > threshold
		or is_equal_approx(snapshot.total_pressure, threshold)
	):
		result.suppress_aggressive_autonomous_movement = true
	return result
