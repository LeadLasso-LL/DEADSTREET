class_name TacticalIdentityFactory
extends RefCounted

# Deterministic debug/battle identity snapshots.
# Campaign personnel remains the long-term owner; this factory fills the
# proving-ground gap without inventing identity inside TacticalBattleView.
# Names are intentionally not generated.

const TacticalIdentitySnapshot := preload("res://battle/identity/tactical_identity_snapshot.gd")
const GangArchetypeCatalog := preload("res://battle/identity/gang_archetype_catalog.gd")
const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")


static func make(
	participant_id: String,
	gang_archetype_id: String,
	weapon_type: String,
	appearance_variant_id: String = ""
) -> TacticalIdentitySnapshot:
	var snapshot: TacticalIdentitySnapshot = TacticalIdentitySnapshot.new()
	if participant_id.is_empty() or not GangArchetypeCatalog.is_known(gang_archetype_id):
		return snapshot
	var variants: Array[String] = GangArchetypeCatalog.appearance_variants(gang_archetype_id)
	if variants.is_empty():
		return snapshot
	var seed: int = _stable_seed(participant_id)
	var chosen_variant: String = appearance_variant_id
	if chosen_variant.is_empty() or not variants.has(chosen_variant):
		chosen_variant = variants[_stable_index(participant_id + "|look", variants.size())]
	snapshot.gang_archetype_id = gang_archetype_id
	snapshot.appearance_variant_id = chosen_variant
	snapshot.appearance_seed = seed
	snapshot.firearm_visual_id = _firearm_visual_id(weapon_type)
	return snapshot


static func apply_debug_hq_identities(battle_state: BattleState) -> void:
	if battle_state == null:
		return
	if battle_state.battlefield_geometry != null and battle_state.battlefield_geometry.authored_layout_id == "dead_street_dusk_v1":
		_apply_side(battle_state, battle_state.attacker_side_id, GangArchetypeCatalog.ARCHETYPE_RUSSIAN_ORGANIZED_CRIME)
		_apply_side(battle_state, battle_state.defender_side_id, GangArchetypeCatalog.ARCHETYPE_LOCAL_STREET_GANG)
		return
	_apply_side(
		battle_state,
		"attacker",
		GangArchetypeCatalog.ARCHETYPE_LOCAL_STREET_GANG
	)
	_apply_side(
		battle_state,
		"defender",
		GangArchetypeCatalog.ARCHETYPE_RUSSIAN_ORGANIZED_CRIME
	)


static func _apply_side(battle_state: BattleState, side_id: String, archetype_id: String) -> void:
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null or participant.side_id != side_id:
			continue
		ids.append(participant_id)
	ids.sort()
	var variants: Array[String] = GangArchetypeCatalog.appearance_variants(archetype_id)
	var i: int = 0
	for participant_id: String in ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		var variant_id: String = ""
		if not variants.is_empty():
			variant_id = variants[i % variants.size()]
		participant.identity = make(
			participant_id,
			archetype_id,
			participant.weapon_type,
			variant_id
		)
		i += 1


static func _firearm_visual_id(weapon_type: String) -> String:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_RIFLE:
			return "rifle"
		BattleWeaponCatalog.WEAPON_SMG:
			return "smg"
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return "shotgun"
		BattleWeaponCatalog.WEAPON_PISTOL:
			return "pistol"
		BattleWeaponCatalog.WEAPON_SNIPER:
			return "rifle"
		_:
			return ""


static func _stable_seed(text: String) -> int:
	return _stable_hash(text)


static func _stable_index(text: String, modulo: int) -> int:
	if modulo <= 0:
		return 0
	return _stable_hash(text) % modulo


static func _stable_hash(text: String) -> int:
	var h: int = 2166136261
	var bytes: PackedByteArray = text.to_utf8_buffer()
	for b: int in bytes:
		h = int((h ^ b) * 16777619)
		h = h & 0x7fffffff
	return h
