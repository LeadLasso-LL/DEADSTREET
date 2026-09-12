class_name BattleUnitTierCatalog
extends RefCounted

# Provisional training balance. Unit tier is independent of equipment tier.
# Tier 1 preserves the existing combat profile exactly. No health/damage buffs.
const Definition := preload("res://battle/combat/battle_weapon_definition.gd")
const NAMES: Array[String] = ["Regular", "Experienced", "Veteran"]
const FIELDS: Array[String] = [
	"weapon_type_id", "model_id", "display_name", "tier", "movement_multiplier",
	"acquire_seconds", "reacquire_seconds", "recoil_per_shot", "recoil_recovery",
	"max_range", "shots_per_second", "magazine_capacity", "reload_seconds",
	"miss_probability", "graze_probability", "solid_probability", "critical_probability",
	"graze_trauma", "solid_trauma", "critical_trauma"
]
static var _profiles: Dictionary = {}

static func label_for(tier: int) -> String:
	return NAMES[clampi(tier, 1, 3)-1]

static func profile(base: Definition, tier: int) -> Definition:
	if base == null or tier <= 1:
		return base
	var rank: int = clampi(tier, 1, 3)-1
	var key := "%s:%d" % [base.get_instance_id(), rank]
	if _profiles.has(key):
		return _profiles[key]
	var result := Definition.new()
	for field: String in FIELDS:
		result.set(field, base.get(field))
	var hit_gain: float = base.miss_probability * 0.10 * rank
	result.miss_probability -= hit_gain
	result.solid_probability += hit_gain
	result.acquire_seconds *= 1.0-0.10*rank
	result.reacquire_seconds *= 1.0-0.10*rank
	result.reload_seconds *= 1.0-0.05*rank
	result.recoil_per_shot *= 1.0-0.10*rank
	result.recoil_recovery *= 1.0+0.10*rank
	assert(result.has_valid_combat_profile())
	_profiles[key] = result
	return result

static func set_for_setup(battle, participant, tier: int) -> bool:
	if battle == null or participant == null or tier < 1 or tier > 3:
		return false
	if battle.battle_phase in ["active", "resolved"] or not participant.is_alive:
		return false
	if battle.get_participant(participant.participant_id) != participant:
		return false
	participant.unit_tier = tier
	participant.acquire_reaction_remaining_seconds = 0.0
	participant.acquire_reaction_target_id = ""
	participant.sniper_aim_remaining_seconds = 0.0
	participant.sniper_aim_target_id = ""
	participant.sniper_aim_engagement_active = false
	return true
