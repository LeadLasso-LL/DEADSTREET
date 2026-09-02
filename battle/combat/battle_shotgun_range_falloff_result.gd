class_name BattleShotgunRangeFalloffResult
extends RefCounted

const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")

# Effective shotgun quality and trauma after range interpolation.
# Presentation-facing events still use hit_quality and trauma_applied only.
var miss_probability: float = 0.0
var graze_probability: float = 0.0
var solid_probability: float = 0.0
var critical_probability: float = 0.0
var graze_trauma: float = 0.0
var solid_trauma: float = 0.0
var critical_trauma: float = 0.0


func attack_profile() -> BattleAttackProfile:
	return BattleAttackProfile.new(
		miss_probability,
		graze_probability,
		solid_probability,
		critical_probability
	)


func trauma_for_hit_quality(hit_quality: String) -> float:
	match hit_quality:
		BattleAttackProfile.QUALITY_GRAZE:
			return graze_trauma
		BattleAttackProfile.QUALITY_SOLID:
			return solid_trauma
		BattleAttackProfile.QUALITY_CRITICAL:
			return critical_trauma
		_:
			return 0.0
