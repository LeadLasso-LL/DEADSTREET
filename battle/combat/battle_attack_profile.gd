class_name BattleAttackProfile
extends RefCounted

const TOTAL_EPSILON := 0.0001

const OUTCOME_MISS := "miss"
const OUTCOME_GRAZE := "graze"
const OUTCOME_WOUND := "wound"
const OUTCOME_KILL := "kill"

# Provisional generic attack profile. Not final combat balance.
# Not weapon-specific. Not modified by distance, cover, wounds, or environment.
const DEFAULT_MISS_PROBABILITY := 0.50
const DEFAULT_GRAZE_PROBABILITY := 0.20
const DEFAULT_WOUND_PROBABILITY := 0.25
const DEFAULT_KILL_PROBABILITY := 0.05

var miss_probability: float = 0.0
var graze_probability: float = 0.0
var wound_probability: float = 0.0
var kill_probability: float = 0.0


func _init(
	p_miss_probability: float = 0.0,
	p_graze_probability: float = 0.0,
	p_wound_probability: float = 0.0,
	p_kill_probability: float = 0.0
) -> void:
	miss_probability = p_miss_probability
	graze_probability = p_graze_probability
	wound_probability = p_wound_probability
	kill_probability = p_kill_probability


static func current() -> BattleAttackProfile:
	return new(
		DEFAULT_MISS_PROBABILITY,
		DEFAULT_GRAZE_PROBABILITY,
		DEFAULT_WOUND_PROBABILITY,
		DEFAULT_KILL_PROBABILITY
	)


func is_valid() -> bool:
	if not is_finite(miss_probability) or miss_probability < 0.0:
		return false
	if not is_finite(graze_probability) or graze_probability < 0.0:
		return false
	if not is_finite(wound_probability) or wound_probability < 0.0:
		return false
	if not is_finite(kill_probability) or kill_probability < 0.0:
		return false
	var total: float = miss_probability + graze_probability + wound_probability + kill_probability
	if not is_finite(total):
		return false
	return absf(total - 1.0) <= TOTAL_EPSILON


static func is_valid_outcome_roll(outcome_roll: float) -> bool:
	if not is_finite(outcome_roll):
		return false
	if outcome_roll < 0.0:
		return false
	if outcome_roll >= 1.0:
		return false
	return true


func resolve_outcome(outcome_roll: float) -> String:
	if not is_valid() or not is_valid_outcome_roll(outcome_roll):
		return ""
	var miss_end: float = miss_probability
	var graze_end: float = miss_end + graze_probability
	var wound_end: float = graze_end + wound_probability
	if outcome_roll < miss_end:
		return OUTCOME_MISS
	if outcome_roll < graze_end:
		return OUTCOME_GRAZE
	if outcome_roll < wound_end:
		return OUTCOME_WOUND
	return OUTCOME_KILL
