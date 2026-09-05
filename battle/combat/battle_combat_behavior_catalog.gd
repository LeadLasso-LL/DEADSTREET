class_name BattleCombatBehaviorCatalog
extends RefCounted

const BattleCombatBehaviorProfile := preload("res://battle/combat/battle_combat_behavior_profile.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")

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
# Survival-first v1: ~10% slower than the prior 4.0 healthy baseline.
const DEFAULT_COMBAT_MOVEMENT_SPEED := 3.6

# Provisional wounded limp speed for autonomous combat movement.
# Independent of wounded fire-rate, accuracy, and reaction delay.
# Keeps the prior 1:2 wounded-to-healthy relationship (was 2.0 vs 4.0).
const WOUNDED_COMBAT_MOVEMENT_SPEED := 1.8

# Provisional wounded combat-performance tuning. Not final balance.
# Same multipliers for every current weapon type.
const WOUNDED_FIRE_RATE_MULTIPLIER := 0.70
const WOUNDED_ACCURACY_MULTIPLIER := 0.70
const WOUNDED_REACTION_DELAY_SECONDS := 0.35

# Provisional healthy first-shot acquisition delay. Not a per-shot cadence.
# Armed only on a new spatial fire engagement. Wounded reaction is stricter.
const HEALTHY_FIRST_SHOT_REACTION_SECONDS := 0.25

# Sniper-only battle-local fire gates. Independent of healthy acquire.
# Initial aim arms on the first valid sniper target in an engagement.
# Target-change reacquisition arms when the valid sniper target ID changes.
# Same-target follow-up does not re-arm; cyclic cooldown remains the cadence.
# The stricter of sniper aim and generic acquire wins.
const SNIPER_INITIAL_AIM_SECONDS := 1.25
const SNIPER_TARGET_CHANGE_REACQUIRE_SECONDS := 3.00

# Provisional occupied-cover combat mitigation. Not final balance.
# At protection_factor 1.0, the pre-cover resolution roll is reduced by this amount.
# cover_multiplier = 1.0 - (MAX_COVER_ROLL_REDUCTION * protection_factor)
# Applies only while EXPOSED in cover. Tucked protection is a separate fire gate.
const MAX_COVER_ROLL_REDUCTION := 0.30

# Provisional occupied-cover posture cycle. Weapon-independent. Not final balance.
# Tucked soldiers cannot fire. Exposed soldiers use existing fire control.
const COVER_TUCK_TO_EXPOSE_SECONDS := 0.18
const COVER_EXPOSED_WINDOW_SECONDS := 0.55
const COVER_EXPOSE_TO_TUCK_SECONDS := 0.18

# Occupied tucked cover blocks a legal shot when protection_factor meets this.
# Same threshold as useful cover ranking. Flanks below this remain shootable.
const COVER_TUCKED_SHOT_BLOCK_FACTOR := 0.50

# Replan combat-owned paths when the tracked destination drifts this far.
const REPLAN_DISTANCE_EPSILON := 0.5

# Provisional Focus Left/Right lateral offset applied to role-safe approach destinations.
const FOCUS_LATERAL_OFFSET := 8.0

# Provisional Fall Back rearward displacement along force rear (-forward).
const FALL_BACK_DISTANCE := 10.0

# Provisional healthy weapon-role cover positioning. Not final balance.
# Every combat role values useful protective cover. Closing remains a separate
# staged-advance path for short-range weapons that are too far to engage.
const PISTOL_COVER_SEEK_RADIUS := 10.0
const PISTOL_COVER_REPLAN_DISTANCE := 3.0
const SMG_COVER_SEEK_RADIUS := 12.0
const SMG_COVER_REPLAN_DISTANCE := 3.0
const SHOTGUN_COVER_SEEK_RADIUS := 10.0
const SHOTGUN_COVER_REPLAN_DISTANCE := 3.0
const RIFLE_COVER_SEEK_RADIUS := 18.0
const RIFLE_COVER_REPLAN_DISTANCE := 4.0
const SNIPER_COVER_SEEK_RADIUS := 28.0
const SNIPER_COVER_REPLAN_DISTANCE := 6.0

# Occupied useful cover is abandoned only for a close unprotected threat.
const CLOSE_THREAT_UNSAFE_RANGE := 4.0

# Short-range closing. Separate from healthy rifle/pistol/sniper firing-cover seek.
# Cover is a means to close, not the objective. Ranking runs on decision/invalidation only.
const PISTOL_CLOSING_SEEK_RADIUS := 14.0
const SMG_CLOSING_SEEK_RADIUS := 18.0
const SHOTGUN_CLOSING_SEEK_RADIUS := 22.0
const CLOSING_PROGRESS_EPSILON := 2.0
const SMG_CLOSING_COMMIT_RANGE := 16.0
const SHOTGUN_CLOSING_COMMIT_RANGE := 9.0
# Healthy SMG/shotgun cover uses weapon max range, not preferred band.
# OUT_OF_RANGE closes cover-to-cover. IN_USEFUL_RANGE survives and fights.
const SHORT_RANGE_OUT_OF_RANGE := "OUT_OF_RANGE"
const SHORT_RANGE_IN_USEFUL_RANGE := "IN_USEFUL_RANGE"
# Occupied-cover settle / posture pacing only. Does not force vacate.
const CLOSING_COVER_MIN_SETTLE_SECONDS := 0.55

# Wounded retreat-to-cover stays local. Not a map-wide safest-refuge search.
# 30 is below half the 100-wide battlefield and still covers current local fixtures.
const WOUNDED_COVER_SEEK_RADIUS := 30.0
# Last-survivor deadlock only. Not a wounded camping timer for normal fights.
const WOUNDED_STALEMATE_SECONDS := 2.5

# Provisional local Defend Position radius. Not UI-exposed.
# Defenders may reposition inside this radius to restore a firing position.
const DEFEND_POSITION_RADIUS := 10.0
const DEFEND_POSITION_SAMPLE_DIRECTIONS := 16
const DEFEND_POSITION_SAMPLE_RADIUS_A := 2.5
const DEFEND_POSITION_SAMPLE_RADIUS_B := 5.0
const DEFEND_POSITION_SAMPLE_RADIUS_C := 7.5
const DEFEND_POSITION_SAMPLE_RADIUS_D := 10.0


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
		BattleWeaponCatalog.WEAPON_PISTOL, BattleWeaponCatalog.WEAPON_SMG, BattleWeaponCatalog.WEAPON_SHOTGUN, BattleWeaponCatalog.WEAPON_RIFLE, BattleWeaponCatalog.WEAPON_SNIPER:
			return true
		_:
			return false


static func healthy_cover_seek_radius(weapon_type_id: String) -> float:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return PISTOL_COVER_SEEK_RADIUS
		BattleWeaponCatalog.WEAPON_SMG:
			return SMG_COVER_SEEK_RADIUS
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return SHOTGUN_COVER_SEEK_RADIUS
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
		BattleWeaponCatalog.WEAPON_SMG:
			return SMG_COVER_REPLAN_DISTANCE
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return SHOTGUN_COVER_REPLAN_DISTANCE
		BattleWeaponCatalog.WEAPON_RIFLE:
			return RIFLE_COVER_REPLAN_DISTANCE
		BattleWeaponCatalog.WEAPON_SNIPER:
			return SNIPER_COVER_REPLAN_DISTANCE
		_:
			return 0.0


static func uses_short_range_closing(weapon_type_id: String) -> bool:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_PISTOL, BattleWeaponCatalog.WEAPON_SMG, BattleWeaponCatalog.WEAPON_SHOTGUN:
			return true
		_:
			return false


static func uses_short_range_range_state(weapon_type_id: String) -> bool:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_SMG, BattleWeaponCatalog.WEAPON_SHOTGUN:
			return true
		_:
			return false


static func is_in_useful_firing_range(weapon_type_id: String, range_distance: float) -> bool:
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null or not definition.is_valid() or not is_finite(range_distance):
		return false
	return range_distance < definition.max_range or is_equal_approx(range_distance, definition.max_range)


static func short_range_state(weapon_type_id: String, range_distance: float) -> String:
	if is_in_useful_firing_range(weapon_type_id, range_distance):
		return SHORT_RANGE_IN_USEFUL_RANGE
	return SHORT_RANGE_OUT_OF_RANGE


static func closing_cover_seek_radius(weapon_type_id: String) -> float:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return PISTOL_CLOSING_SEEK_RADIUS
		BattleWeaponCatalog.WEAPON_SMG:
			return SMG_CLOSING_SEEK_RADIUS
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return SHOTGUN_CLOSING_SEEK_RADIUS
		_:
			return 0.0


static func closing_commit_range(weapon_type_id: String) -> float:
	match weapon_type_id:
		BattleWeaponCatalog.WEAPON_SMG:
			return SMG_CLOSING_COMMIT_RANGE
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return SHOTGUN_CLOSING_COMMIT_RANGE
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
