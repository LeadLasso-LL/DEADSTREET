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
# Independent of wounded fire-rate, accuracy, and reaction delay.
const WOUNDED_COMBAT_MOVEMENT_SPEED := 2.0

# Provisional wounded combat-performance tuning. Not final balance.
# Same multipliers for every current weapon type.
const WOUNDED_FIRE_RATE_MULTIPLIER := 0.70
const WOUNDED_ACCURACY_MULTIPLIER := 0.70
const WOUNDED_REACTION_DELAY_SECONDS := 0.35

# Replan combat-owned paths when the tracked destination drifts this far.
const REPLAN_DISTANCE_EPSILON := 0.5

# Provisional healthy weapon-role cover positioning. Not final balance.
# Shotgun and SMG do not autonomously seek healthy cover in v1.
const PISTOL_COVER_SEEK_RADIUS := 10.0
const PISTOL_COVER_REPLAN_DISTANCE := 3.0
const RIFLE_COVER_SEEK_RADIUS := 18.0
const RIFLE_COVER_REPLAN_DISTANCE := 4.0
const SNIPER_COVER_SEEK_RADIUS := 28.0
const SNIPER_COVER_REPLAN_DISTANCE := 6.0


static func get_profile(weapon_type_id: String) -> BattleCombatBehaviorProfile:
	var profile: BattleCombatBehaviorProfile = _make_profile(weapon_type_id)
	if profile == null or not profile.is_valid():
		return null
	return profile


static func has_profile(weapon_type_id: String) -> bool:
	return get_profile(weapon_type_id) != null


# Deterministic wounded-accuracy mapping. One raw roll in, one effective roll out.
# effective_roll = raw_roll * WOUNDED_ACCURACY_MULTIPLIER
static func wounded_effective_outcome_roll(raw_roll: float) -> float:
	if not is_finite(raw_roll):
		return raw_roll
	return raw_roll * WOUNDED_ACCURACY_MULTIPLIER


static func uses_healthy_role_cover(weapon_type_id: String) -> bool:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_PISTOL, BattleWeaponCatalog.WEAPON_RIFLE, BattleWeaponCatalog.WEAPON_SNIPER:
			return true
		_:
			return false


static func healthy_cover_seek_radius(weapon_type_id: String) -> float:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return PISTOL_COVER_SEEK_RADIUS
		BattleWeaponCatalog.WEAPON_RIFLE:
			return RIFLE_COVER_SEEK_RADIUS
		BattleWeaponCatalog.WEAPON_SNIPER:
			return SNIPER_COVER_SEEK_RADIUS
		_:
			return 0.0


static func healthy_cover_replan_distance(weapon_type_id: String) -> float:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return PISTOL_COVER_REPLAN_DISTANCE
		BattleWeaponCatalog.WEAPON_RIFLE:
			return RIFLE_COVER_REPLAN_DISTANCE
		BattleWeaponCatalog.WEAPON_SNIPER:
			return SNIPER_COVER_REPLAN_DISTANCE
		_:
			return 0.0


# Distance from `range_distance` to the nearest point in the weapon preferred band.
# Zero means the distance is already in-band.
static func preferred_band_error(weapon_type_id: String, range_distance: float) -> float:
	var profile: BattleCombatBehaviorProfile = get_profile(weapon_type_id)
	if profile == null or not is_finite(range_distance):
		return INF
	if range_distance < profile.preferred_min_distance:
		return profile.preferred_min_distance - range_distance
	if range_distance > profile.preferred_max_distance:
		return range_distance - profile.preferred_max_distance
	return 0.0


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
