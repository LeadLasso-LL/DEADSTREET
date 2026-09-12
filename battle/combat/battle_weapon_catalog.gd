class_name BattleWeaponCatalog
extends RefCounted

const UnitTiers := preload("res://battle/combat/battle_unit_tier_catalog.gd")

const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")
const BattleWeaponState := preload("res://battle/combat/battle_weapon_state.gd")
const BattleAttackProfile := preload("res://battle/combat/battle_attack_profile.gd")

const Specialists = preload("res://battle/combat/battle_specialist_catalog.gd")

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
const SMG_SHOTS_PER_SECOND := 6.0
const SMG_MAGAZINE_CAPACITY := 30
const SMG_RELOAD_SECONDS := 2.0

const RIFLE_MAX_RANGE := 40.0
const RIFLE_SHOTS_PER_SECOND := 1.6
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
# Identities are unchanged. Baseline vitality is 1.5; wound is at 0.525 remaining.
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


# Class identity remains stable; model data is equipment, never a unit tier bonus.
static var _models: Dictionary = {}
static var _model_cache: Dictionary = {}
static var _legacy_tier_bases: Dictionary = {}

static func model_data() -> Dictionary:
	if _models.is_empty():
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/weapon_models.json"))
		if data is Dictionary: _models = data
	return _models

static func default_model(weapon_class: String) -> String:
	return str(model_data().get("defaults", {}).get(weapon_class, ""))

static func models_for_class(weapon_class: String) -> Array[String]:
	var result: Array[String] = []
	for id: String in model_data().get("models", {}):
		if str(model_data().models[id].weapon_class) == weapon_class: result.append(id)
	return result

static func get_model(id: String) -> BattleWeaponDefinition:
	if _model_cache.has(id): return _model_cache[id]
	var row: Dictionary = model_data().get("models", {}).get(id, {})
	if row.is_empty(): return null
	var d: BattleWeaponDefinition = _make_definition(str(row.weapon_class))
	if d == null: return null
	d.model_id = id
	d.display_name = str(row.name)
	d.tier = int(row.tier)
	for key: String in ["movement_multiplier", "max_range", "shots_per_second", "graze_trauma", "solid_trauma", "critical_trauma", "miss_probability", "graze_probability", "solid_probability", "critical_probability", "acquire_seconds", "reacquire_seconds", "recoil_per_shot", "recoil_recovery"]:
		d.set(key, float(row[key]))
	if not d.has_valid_combat_profile(): return null
	_model_cache[id] = d
	return d

static func for_participant(p) -> BattleWeaponDefinition:
	if p == null: return null
	var id: String = p.weapon_model_id
	if id.is_empty():
		if p.unit_tier <= 1: return get_definition(p.weapon_type)
		# Class-only legacy participants also need stable tier-profile cache keys.
		# Public get_definition() still returns an independent definition to callers.
		if not _legacy_tier_bases.has(p.weapon_type):
			_legacy_tier_bases[p.weapon_type] = get_definition(p.weapon_type)
		return UnitTiers.profile(_legacy_tier_bases[p.weapon_type], p.unit_tier)
	var d: BattleWeaponDefinition = get_model(id)
	if d == null or d.weapon_type_id != p.weapon_type: return null
	if not p.specialist_id.is_empty():
		if not Specialists.eligible(p.faction_id, p.weapon_type, id, p.specialist_id): return null
		d = Specialists.profile(d)
	return UnitTiers.profile(d, p.unit_tier)

static func state_for_participant(p) -> BattleWeaponState:
	var d = for_participant(p)
	return BattleWeaponState.new(d.weapon_type_id, d.magazine_capacity) if d != null else null

# Tactical loadout setup only. Campaign inventory transfers will call their own authority.
# Never equip during combat, change unit class, or use a swap as a free reload.
static func equip_for_setup(b, p, id: String) -> bool:
	if b == null or p == null or b.battle_phase == "active" or b.battle_phase == "resolved": return false
	if b.get_participant(p.participant_id) != p or not p.is_alive: return false
	var d: BattleWeaponDefinition = get_model(id)
	if d == null or d.weapon_type_id != p.weapon_type: return false
	if not p.specialist_id.is_empty() and not Specialists.eligible(p.faction_id, p.weapon_type, id, p.specialist_id): return false
	p.weapon_model_id = id
	p.weapon_recoil = 0.0
	p.weapon_state = state_for_participant(p)
	p.acquire_reaction_target_id = ""
	p.sniper_aim_target_id = ""
	p.sniper_aim_engagement_active = false
	return true
