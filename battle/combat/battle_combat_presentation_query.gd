class_name BattleCombatPresentationQuery
extends RefCounted

# Query-only combat presentation. Reads authoritative battle data.
# Does not mutate simulation, fire control, or combat behavior.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleFireControlService := preload("res://battle/combat/battle_fire_control_service.gd")
const BattleFireControlResult := preload("res://battle/combat/battle_fire_control_result.gd")

const STATE_NONE := ""
const STATE_DEAD := "DEAD"
const STATE_WND := "WND"
const STATE_MOV := "MOV"
const STATE_COVER := "COVER"
const STATE_HOLD := "HOLD"
const STATE_RLD := "RLD"
const STATE_NO_LOS := "NO LOS"
const STATE_RANGE := "RANGE"
const STATE_AIM := "AIM"
const STATE_WAIT := "WAIT"

const MOVE_SEEK_COVER := "seek_cover"
const MOVE_SEEK_ROLE_COVER := "seek_role_cover"
const MOVE_CLOSE := "close"
const MOVE_DEFEND_REPOSITION := "defend_reposition"

const RELOCATING_SPEED_EPSILON := 0.05


static func compact_state(battle_state: BattleState, participant: BattleParticipant) -> String:
	if participant == null:
		return STATE_NONE
	if not participant.is_alive:
		return STATE_DEAD
	if _is_relocating(participant):
		if _is_seeking_cover(participant):
			return STATE_COVER
		return STATE_MOV
	if _is_reloading(participant):
		return STATE_RLD
	if participant.has_occupied_cover_slot():
		return STATE_HOLD
	var rejection: String = _fire_rejection(battle_state, participant)
	if rejection == "line_of_sight_blocked":
		return STATE_NO_LOS
	if rejection == "out_of_range":
		return STATE_RANGE
	if participant.has_acquire_reaction() or participant.has_sniper_aim():
		return STATE_AIM
	if participant.is_wounded:
		return STATE_WND
	if rejection == "cooldown" or _is_cooling_down(participant):
		return STATE_WAIT
	return STATE_NONE


static func _is_relocating(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if _is_usable_vector(participant.velocity) and participant.velocity.length() > RELOCATING_SPEED_EPSILON:
		return true
	if participant.has_active_navigation_path():
		return true
	return false


static func _is_seeking_cover(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	match participant.combat_move_mode:
		MOVE_SEEK_COVER, MOVE_SEEK_ROLE_COVER, MOVE_CLOSE, MOVE_DEFEND_REPOSITION:
			return true
		_:
			return false


static func _is_reloading(participant: BattleParticipant) -> bool:
	if participant == null or participant.weapon_state == null:
		return false
	if participant.weapon_state.is_reloading:
		return true
	return participant.weapon_state.ammo_in_magazine <= 0


static func _is_cooling_down(participant: BattleParticipant) -> bool:
	if participant == null or participant.weapon_state == null:
		return false
	return participant.weapon_state.is_cooling_down()


static func _fire_rejection(battle_state: BattleState, participant: BattleParticipant) -> String:
	if battle_state == null or participant == null:
		return ""
	if battle_state.battle_phase != "active":
		return ""
	if not participant.has_target_participant or participant.target_participant_id.is_empty():
		return ""
	var result: BattleFireControlResult = BattleFireControlService.evaluate_participant_target_eligibility(
		battle_state,
		participant.participant_id,
		participant.target_participant_id
	)
	if result == null or not result.success or result.can_fire:
		return ""
	return result.rejection_code


static func _is_usable_vector(value: Vector2) -> bool:
	return is_finite(value.x) and is_finite(value.y)
