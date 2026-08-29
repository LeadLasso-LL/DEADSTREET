class_name BattleWeaponCatalog
extends RefCounted

const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleWeaponState := preload("res://battle/combat/battle_weapon_state.gd")

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


static func get_definition(weapon_type_id: String) -> BattleWeaponDefinition:
	var definition: BattleWeaponDefinition = _make_definition(weapon_type_id)
	if definition == null or not definition.is_valid():
		return null
	return definition


static func has_definition(weapon_type_id: String) -> bool:
	return get_definition(weapon_type_id) != null


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
				PISTOL_RELOAD_SECONDS
			)
		WEAPON_SHOTGUN:
			return BattleWeaponDefinition.new(
				WEAPON_SHOTGUN,
				SHOTGUN_MAX_RANGE,
				SHOTGUN_SHOTS_PER_SECOND,
				SHOTGUN_MAGAZINE_CAPACITY,
				SHOTGUN_RELOAD_SECONDS
			)
		WEAPON_SMG:
			return BattleWeaponDefinition.new(
				WEAPON_SMG,
				SMG_MAX_RANGE,
				SMG_SHOTS_PER_SECOND,
				SMG_MAGAZINE_CAPACITY,
				SMG_RELOAD_SECONDS
			)
		WEAPON_RIFLE:
			return BattleWeaponDefinition.new(
				WEAPON_RIFLE,
				RIFLE_MAX_RANGE,
				RIFLE_SHOTS_PER_SECOND,
				RIFLE_MAGAZINE_CAPACITY,
				RIFLE_RELOAD_SECONDS
			)
		WEAPON_SNIPER:
			return BattleWeaponDefinition.new(
				WEAPON_SNIPER,
				SNIPER_MAX_RANGE,
				SNIPER_SHOTS_PER_SECOND,
				SNIPER_MAGAZINE_CAPACITY,
				SNIPER_RELOAD_SECONDS
			)
		_:
			return null
