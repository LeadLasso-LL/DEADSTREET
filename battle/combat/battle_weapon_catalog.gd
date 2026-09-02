class_name BattleWeaponCatalog
extends RefCounted

const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleWeaponState := preload("res://battle/combat/battle_weapon_state.gd")
const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")

const WEAPON_PISTOL := "pistol"
const WEAPON_SHOTGUN := "shotgun"
const WEAPON_SMG := "smg"
const WEAPON_RIFLE := "rifle"
const WEAPON_SNIPER := "sniper"

# Provisional tactical tuning only. Not final balance.
# Battlefield geometry is currently 100 x 60 tactical units.
const PISTOL_MAX_RANGE := 24.0
const PISTOL_SHOTS_PER_SECOND := 2.5
const PISTOL_MAGAZINE_CAPACITY := 12
const PISTOL_RELOAD_SECONDS := 1.5

const SHOTGUN_MAX_RANGE := 12.0
const SHOTGUN_SHOTS_PER_SECOND := 1.0
const SHOTGUN_MAGAZINE_CAPACITY := 6
const SHOTGUN_RELOAD_SECONDS := 2.5

const SMG_MAX_RANGE := 20.0
const SMG_SHOTS_PER_SECOND := 8.0
const SMG_MAGAZINE_CAPACITY := 30
const SMG_RELOAD_SECONDS := 2.0

const RIFLE_MAX_RANGE := 40.0
const RIFLE_SHOTS_PER_SECOND := 2.0
const RIFLE_MAGAZINE_CAPACITY := 20
const RIFLE_RELOAD_SECONDS := 2.2

const SNIPER_MAX_RANGE := 70.0
const SNIPER_SHOTS_PER_SECOND := 0.5
const SNIPER_MAGAZINE_CAPACITY := 5
const SNIPER_RELOAD_SECONDS := 3.0

# Provisional hit-quality bands. Not final combat balance. Sums are exact 1.0.
# These select miss/graze/solid/critical. They do not select wounded/dead.
const PISTOL_MISS_PROBABILITY := 0.30
const PISTOL_GRAZE_PROBABILITY := 0.30
const PISTOL_SOLID_PROBABILITY := 0.35
const PISTOL_CRITICAL_PROBABILITY := 0.05

const SMG_MISS_PROBABILITY := 0.42
const SMG_GRAZE_PROBABILITY := 0.30
const SMG_SOLID_PROBABILITY := 0.26
const SMG_CRITICAL_PROBABILITY := 0.02

const RIFLE_MISS_PROBABILITY := 0.25
const RIFLE_GRAZE_PROBABILITY := 0.22
const RIFLE_SOLID_PROBABILITY := 0.45
const RIFLE_CRITICAL_PROBABILITY := 0.08

const SHOTGUN_MISS_PROBABILITY := 0.36
const SHOTGUN_GRAZE_PROBABILITY := 0.14
const SHOTGUN_SOLID_PROBABILITY := 0.35
const SHOTGUN_CRITICAL_PROBABILITY := 0.15

const SNIPER_MISS_PROBABILITY := 0.20
const SNIPER_GRAZE_PROBABILITY := 0.15
const SNIPER_SOLID_PROBABILITY := 0.45
const SNIPER_CRITICAL_PROBABILITY := 0.20

# Provisional trauma in vitality units. Miss trauma is 0.
# Pistol solid is below the 0.65 drop needed to wound from 1.0.
const PISTOL_GRAZE_TRAUMA := 0.10
const PISTOL_SOLID_TRAUMA := 0.28
const PISTOL_CRITICAL_TRAUMA := 0.70

const SMG_GRAZE_TRAUMA := 0.06
const SMG_SOLID_TRAUMA := 0.16
const SMG_CRITICAL_TRAUMA := 0.45

const RIFLE_GRAZE_TRAUMA := 0.12
const RIFLE_SOLID_TRAUMA := 0.42
const RIFLE_CRITICAL_TRAUMA := 0.85

const SHOTGUN_GRAZE_TRAUMA := 0.18
const SHOTGUN_SOLID_TRAUMA := 0.70
const SHOTGUN_CRITICAL_TRAUMA := 1.20

const SNIPER_GRAZE_TRAUMA := 0.15
const SNIPER_SOLID_TRAUMA := 0.55
const SNIPER_CRITICAL_TRAUMA := 1.50


static func get_definition(weapon_type_id: String) -> BattleWeaponDefinition:
	var definition: BattleWeaponDefinition = _make_definition(weapon_type_id)
	if definition == null or not definition.has_valid_combat_profile():
		return null
	return definition


static func has_definition(weapon_type_id: String) -> bool:
	return get_definition(weapon_type_id) != null


static func get_attack_profile(weapon_type_id: String) -> BattleAttackProfile:
	var definition: BattleWeaponDefinition = get_definition(weapon_type_id)
	if definition == null:
		return null
	return definition.attack_profile()


static func create_initial_state(weapon_type_id: String) -> BattleWeaponState:
	var definition: BattleWeaponDefinition = get_definition(weapon_type_id)
	if definition == null:
		return null
	return BattleWeaponState.new(
		definition.weapon_type_id,
		definition.magazine_capacity,
		0.0,
		0.0,
		false
	)


static func _make_definition(weapon_type_id: String) -> BattleWeaponDefinition:
	match weapon_type_id:
		WEAPON_PISTOL:
			return BattleWeaponDefinition.new(
				WEAPON_PISTOL,
				PISTOL_MAX_RANGE,
				PISTOL_SHOTS_PER_SECOND,
				PISTOL_MAGAZINE_CAPACITY,
				PISTOL_RELOAD_SECONDS,
				PISTOL_MISS_PROBABILITY,
				PISTOL_GRAZE_PROBABILITY,
				PISTOL_SOLID_PROBABILITY,
				PISTOL_CRITICAL_PROBABILITY,
				PISTOL_GRAZE_TRAUMA,
				PISTOL_SOLID_TRAUMA,
				PISTOL_CRITICAL_TRAUMA
			)
		WEAPON_SHOTGUN:
			return BattleWeaponDefinition.new(
				WEAPON_SHOTGUN,
				SHOTGUN_MAX_RANGE,
				SHOTGUN_SHOTS_PER_SECOND,
				SHOTGUN_MAGAZINE_CAPACITY,
				SHOTGUN_RELOAD_SECONDS,
				SHOTGUN_MISS_PROBABILITY,
				SHOTGUN_GRAZE_PROBABILITY,
				SHOTGUN_SOLID_PROBABILITY,
				SHOTGUN_CRITICAL_PROBABILITY,
				SHOTGUN_GRAZE_TRAUMA,
				SHOTGUN_SOLID_TRAUMA,
				SHOTGUN_CRITICAL_TRAUMA
			)
		WEAPON_SMG:
			return BattleWeaponDefinition.new(
				WEAPON_SMG,
				SMG_MAX_RANGE,
				SMG_SHOTS_PER_SECOND,
				SMG_MAGAZINE_CAPACITY,
				SMG_RELOAD_SECONDS,
				SMG_MISS_PROBABILITY,
				SMG_GRAZE_PROBABILITY,
				SMG_SOLID_PROBABILITY,
				SMG_CRITICAL_PROBABILITY,
				SMG_GRAZE_TRAUMA,
				SMG_SOLID_TRAUMA,
				SMG_CRITICAL_TRAUMA
			)
		WEAPON_RIFLE:
			return BattleWeaponDefinition.new(
				WEAPON_RIFLE,
				RIFLE_MAX_RANGE,
				RIFLE_SHOTS_PER_SECOND,
				RIFLE_MAGAZINE_CAPACITY,
				RIFLE_RELOAD_SECONDS,
				RIFLE_MISS_PROBABILITY,
				RIFLE_GRAZE_PROBABILITY,
				RIFLE_SOLID_PROBABILITY,
				RIFLE_CRITICAL_PROBABILITY,
				RIFLE_GRAZE_TRAUMA,
				RIFLE_SOLID_TRAUMA,
				RIFLE_CRITICAL_TRAUMA
			)
		WEAPON_SNIPER:
			return BattleWeaponDefinition.new(
				WEAPON_SNIPER,
				SNIPER_MAX_RANGE,
				SNIPER_SHOTS_PER_SECOND,
				SNIPER_MAGAZINE_CAPACITY,
				SNIPER_RELOAD_SECONDS,
				SNIPER_MISS_PROBABILITY,
				SNIPER_GRAZE_PROBABILITY,
				SNIPER_SOLID_PROBABILITY,
				SNIPER_CRITICAL_PROBABILITY,
				SNIPER_GRAZE_TRAUMA,
				SNIPER_SOLID_TRAUMA,
				SNIPER_CRITICAL_TRAUMA
			)
		_:
			return null
