class_name BattleAttackProfile
extends RefCounted

const TOTAL_EPSILON := 0.0001

const QUALITY_MISS := "miss"
const QUALITY_GRAZE := "graze"
const QUALITY_SOLID := "solid"
const QUALITY_CRITICAL := "critical"

const OUTCOME_MISS := "miss"
const OUTCOME_GRAZE := "graze"
const OUTCOME_HIT := "hit"
const OUTCOME_WOUNDED := "wounded"
const OUTCOME_KILLED := "killed"

# Legacy condition-lottery names. Not live combat authority.
const OUTCOME_WOUND := "wound"
const OUTCOME_KILL := "kill"

# Provisional generic hit-quality helper. Not final combat balance.
# Live weapon quality bands live on BattleWeaponDefinition / BattleWeaponCatalog.
# current() is not the live combat authority.
const DEFAULT_MISS_PROBABILITY := 0.50
const DEFAULT_GRAZE_PROBABILITY := 0.20
const DEFAULT_SOLID_PROBABILITY := 0.25
const DEFAULT_CRITICAL_PROBABILITY := 0.05
const DEFAULT_WOUND_PROBABILITY := DEFAULT_SOLID_PROBABILITY
const DEFAULT_KILL_PROBABILITY := DEFAULT_CRITICAL_PROBABILITY

var miss_probability: float = 0.0
var graze_probability: float = 0.0
var solid_probability: float = 0.0
var critical_probability: float = 0.0
var wound_probability: float:
	get:
		return solid_probability
	set(value):
		solid_probability = value
var kill_probability: float:
	get:
		return critical_probability
	set(value):
		critical_probability = value


func _init(
	p_miss_probability: float = 0.0,
	p_graze_probability: float = 0.0,
	p_solid_probability: float = 0.0,
	p_critical_probability: float = 0.0
) -> void:
	miss_probability = p_miss_probability
	graze_probability = p_graze_probability
	solid_probability = p_solid_probability
	critical_probability = p_critical_probability


static func current() -> BattleAttackProfile:
	return new(
		DEFAULT_MISS_PROBABILITY,
		DEFAULT_GRAZE_PROBABILITY,
		DEFAULT_SOLID_PROBABILITY,
		DEFAULT_CRITICAL_PROBABILITY
	)


func is_valid() -> bool:
	if not is_finite(miss_probability) or miss_probability < 0.0:
		return false
	if not is_finite(graze_probability) or graze_probability < 0.0:
		return false
	if not is_finite(solid_probability) or solid_probability < 0.0:
		return false
	if not is_finite(critical_probability) or critical_probability < 0.0:
		return false
	var total: float = (
		miss_probability + graze_probability + solid_probability + critical_probability
	)
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


func resolve_hit_quality(outcome_roll: float) -> String:
	if not is_valid() or not is_valid_outcome_roll(outcome_roll):
		return ""
	var miss_end: float = miss_probability
	var graze_end: float = miss_end + graze_probability
	var solid_end: float = graze_end + solid_probability
	if outcome_roll < miss_end:
		return QUALITY_MISS
	if outcome_roll < graze_end:
		return QUALITY_GRAZE
	if outcome_roll < solid_end:
		return QUALITY_SOLID
	return QUALITY_CRITICAL


func resolve_outcome(outcome_roll: float) -> String:
	return resolve_hit_quality(outcome_roll)


static func derive_presentation_outcome(
	hit_quality: String,
	was_alive: bool,
	is_alive: bool,
	was_wounded: bool,
	is_wounded: bool
) -> String:
	if hit_quality == QUALITY_MISS:
		return OUTCOME_MISS
	if was_alive and not is_alive:
		return OUTCOME_KILLED
	if not was_wounded and is_wounded:
		return OUTCOME_WOUNDED
	if hit_quality == QUALITY_GRAZE:
		return OUTCOME_GRAZE
	return OUTCOME_HIT
