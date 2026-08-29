class_name BattleCombatBehaviorCatalog
extends RefCounted

const BattleCombatBehaviorProfile := preload("res://battle/combat/battle_combat_behavior_profile.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")

# Provisional autonomous engagement bands. Not final combat balance.
# Separate from weapon ballistic max range.
const SHOTGUN_PREFERRED_MIN := 0.0
const SHOTGUN_PREFERRED_MAX := 7.0
const SMG_PREFERRED_MIN := 5.0
const SMG_PREFERRED_MAX := 14.0
const PISTOL_PREFERRED_MIN := 8.0
const PISTOL_PREFERRED_MAX := 18.0
const RIFLE_PREFERRED_MIN := 16.0
const RIFLE_PREFERRED_MAX := 32.0
const SNIPER_PREFERRED_MIN := 32.0
const SNIPER_PREFERRED_MAX := 60.0

# Used only when a mobile combat participant has no usable movement speed yet.
const DEFAULT_COMBAT_MOVEMENT_SPEED := 4.0

# Provisional wounded limp speed for autonomous combat movement.
# Not a fire-rate, accuracy, or reaction penalty.
const WOUNDED_COMBAT_MOVEMENT_SPEED := 2.0

# Replan combat-owned paths when the tracked destination drifts this far.
const REPLAN_DISTANCE_EPSILON := 0.5


static func get_profile(weapon_type_id: String) -> BattleCombatBehaviorProfile:
	var profile: BattleCombatBehaviorProfile = _make_profile(weapon_type_id)
	if profile == null or not profile.is_valid():
		return null
	return profile


static func has_profile(weapon_type_id: String) -> bool:
	return get_profile(weapon_type_id) != null


static func _make_profile(weapon_type_id: String) -> BattleCombatBehaviorProfile:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return BattleCombatBehaviorProfile.new(
				BattleWeaponCatalog.WEAPON_SHOTGUN,
				SHOTGUN_PREFERRED_MIN,
				SHOTGUN_PREFERRED_MAX
			)
		BattleWeaponCatalog.WEAPON_SMG:
			return BattleCombatBehaviorProfile.new(
				BattleWeaponCatalog.WEAPON_SMG,
				SMG_PREFERRED_MIN,
				SMG_PREFERRED_MAX
			)
		BattleWeaponCatalog.WEAPON_PISTOL:
			return BattleCombatBehaviorProfile.new(
				BattleWeaponCatalog.WEAPON_PISTOL,
				PISTOL_PREFERRED_MIN,
				PISTOL_PREFERRED_MAX
			)
		BattleWeaponCatalog.WEAPON_RIFLE:
			return BattleCombatBehaviorProfile.new(
				BattleWeaponCatalog.WEAPON_RIFLE,
				RIFLE_PREFERRED_MIN,
				RIFLE_PREFERRED_MAX
			)
		BattleWeaponCatalog.WEAPON_SNIPER:
			return BattleCombatBehaviorProfile.new(
				BattleWeaponCatalog.WEAPON_SNIPER,
				SNIPER_PREFERRED_MIN,
				SNIPER_PREFERRED_MAX
			)
		_:
			return null
