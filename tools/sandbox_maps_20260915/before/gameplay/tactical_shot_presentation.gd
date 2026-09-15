class_name TacticalShotPresentation
extends RefCounted

# Presentation-only shot replay and weapon silhouettes.
# Does not own combat resolution, timing, hits, or projectile authority.

const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")

const MUZZLE_FLASH_SECONDS := 0.032
const IMPACT_SECONDS := 0.14
const OUTCOME_LABEL_SECONDS := 0.45
const MAX_TAIL_PATH_FRACTION := 0.22
const SHOT_PAIR_OFFSET_PIXELS := 2.4
const SHOTGUN_TRAVEL_PIXELS := 22.0
const MIN_TRAVEL_SECONDS := 0.028
const MAX_TRAVEL_SECONDS := 0.16
const TAIL_SEGMENTS := 3


static func silhouette_length(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 4.0
		BattleWeaponCatalog.WEAPON_SMG:
			return 6.6
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 10.0
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 13.4
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 17.6
		_:
			return 8.0


static func silhouette_width(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 1.32
		BattleWeaponCatalog.WEAPON_SMG:
			return 1.88
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 2.58
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 1.52
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 1.12
		_:
			return 1.6


static func silhouette_stock(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 0.0
		BattleWeaponCatalog.WEAPON_SMG:
			return 1.7
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 2.5
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 2.9
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 3.4
		_:
			return 1.6


static func muzzle_flash_seconds() -> float:
	return MUZZLE_FLASH_SECONDS


static func muzzle_flash_radius(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 1.15
		BattleWeaponCatalog.WEAPON_SMG:
			return 1.25
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 2.35
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 1.55
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 1.85
		_:
			return 1.35


static func muzzle_flash_alpha(age: float) -> float:
	if not is_finite(age) or age < 0.0 or age >= MUZZLE_FLASH_SECONDS:
		return 0.0
	var remaining: float = 1.0 - (age / MUZZLE_FLASH_SECONDS)
	return remaining * remaining


static func projectile_speed_pixels(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 960.0
		BattleWeaponCatalog.WEAPON_SMG:
			return 1180.0
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 720.0
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 1680.0
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 2300.0
		_:
			return 1100.0


static func projectile_radius(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 1.15
		BattleWeaponCatalog.WEAPON_SMG:
			return 1.05
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 0.90
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 1.00
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 0.85
		_:
			return 1.05


static func max_tail_pixels(weapon_type: String) -> float:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_PISTOL:
			return 11.0
		BattleWeaponCatalog.WEAPON_SMG:
			return 8.0
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return 7.0
		BattleWeaponCatalog.WEAPON_RIFLE:
			return 13.0
		BattleWeaponCatalog.WEAPON_SNIPER:
			return 14.0
		_:
			return 10.0


static func uses_short_shotgun_cue(weapon_type: String) -> bool:
	return weapon_type == BattleWeaponCatalog.WEAPON_SHOTGUN


static func visual_travel_pixels(weapon_type: String, path_pixels: float) -> float:
	if not is_finite(path_pixels) or path_pixels <= 0.0:
		return 0.0
	if uses_short_shotgun_cue(weapon_type):
		return minf(path_pixels, SHOTGUN_TRAVEL_PIXELS)
	return path_pixels


static func travel_seconds(weapon_type: String, path_pixels: float) -> float:
	var travel_pixels: float = visual_travel_pixels(weapon_type, path_pixels)
	if travel_pixels <= 0.0:
		return 0.0
	var speed: float = projectile_speed_pixels(weapon_type)
	if speed <= 0.0:
		return MAX_TRAVEL_SECONDS
	var seconds: float = travel_pixels / speed
	return clampf(seconds, MIN_TRAVEL_SECONDS, MAX_TRAVEL_SECONDS)


static func projectile_progress(weapon_type: String, age: float, path_pixels: float) -> float:
	if not is_finite(age) or age < 0.0:
		return 0.0
	var seconds: float = travel_seconds(weapon_type, path_pixels)
	if seconds <= 0.0:
		return 1.0
	if age >= seconds:
		return 1.0
	return clampf(age / seconds, 0.0, 1.0)


static func projectile_visible(weapon_type: String, age: float, path_pixels: float) -> bool:
	if not is_finite(age) or age < 0.0:
		return false
	var seconds: float = travel_seconds(weapon_type, path_pixels)
	if seconds <= 0.0:
		return false
	return age < seconds


static func traveled_pixels(weapon_type: String, age: float, path_pixels: float) -> float:
	return visual_travel_pixels(weapon_type, path_pixels) * projectile_progress(
		weapon_type,
		age,
		path_pixels
	)


static func projectile_position(
	origin: Vector2,
	endpoint: Vector2,
	weapon_type: String,
	age: float
) -> Vector2:
	var along: Vector2 = endpoint - origin
	var path_pixels: float = along.length()
	if path_pixels <= 0.0 or along.is_equal_approx(Vector2.ZERO):
		return origin
	var traveled: float = traveled_pixels(weapon_type, age, path_pixels)
	return origin + along.normalized() * traveled


static func tail_length_pixels(weapon_type: String, age: float, path_pixels: float) -> float:
	if not projectile_visible(weapon_type, age, path_pixels):
		return 0.0
	var traveled: float = traveled_pixels(weapon_type, age, path_pixels)
	var cap: float = max_tail_pixels(weapon_type)
	var fraction_cap: float = path_pixels * MAX_TAIL_PATH_FRACTION
	return minf(cap, minf(traveled, fraction_cap))


static func impact_visible(age: float, resolved_hold: bool) -> bool:
	if resolved_hold:
		return true
	if not is_finite(age) or age < 0.0:
		return false
	return age <= IMPACT_SECONDS


static func outcome_label_visible(age: float, resolved_hold: bool) -> bool:
	if resolved_hold:
		return true
	if not is_finite(age) or age < 0.0:
		return false
	return age <= OUTCOME_LABEL_SECONDS


static func cue_visible(weapon_type: String, age: float, path_pixels: float, resolved_hold: bool) -> bool:
	if resolved_hold:
		return true
	if muzzle_flash_alpha(age) > 0.0:
		return true
	if projectile_visible(weapon_type, age, path_pixels):
		return true
	if impact_visible(age, false):
		return true
	if outcome_label_visible(age, false):
		return true
	return false
