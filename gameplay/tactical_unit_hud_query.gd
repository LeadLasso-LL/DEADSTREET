class_name TacticalUnitHudQuery
extends RefCounted

# Read-only friendly unit-card descriptors for the tactical HUD.
# Derives vitality / wounded / dead from canonical BattleParticipant.
# Does not store combat state.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleCombatConsequenceService := preload("res://battle/combat/battle_combat_consequence_service.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")

const CARD_STATE_HEALTHY := "healthy"
const CARD_STATE_WOUNDED := "wounded"
const CARD_STATE_DEAD := "dead"


static func friendly_cards(
	battle_state: BattleState,
	selected_participant_id: String
) -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	if battle_state == null:
		return cards
	var side_id: String = battle_state.attacker_side_id
	if side_id.is_empty():
		return cards
	var ids: Array[String] = []
	for participant_id: String in battle_state.participants:
		ids.append(participant_id)
	ids.sort()
	for participant_id: String in ids:
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			continue
		if participant.side_id != side_id:
			continue
		cards.append(card_for(participant, selected_participant_id))
	return cards


static func card_for(participant: BattleParticipant, selected_participant_id: String) -> Dictionary:
	var card: Dictionary = {
		"participant_id": "",
		"weapon_type": "",
		"role_label": "",
		"display_name": "",
		"firearm_label": "",
		"vitality": 0.0,
		"vitality_ratio": 0.0,
		"vitality_percent": 0,
		"is_alive": false,
		"is_wounded": false,
		"is_selected": false,
		"can_select": false,
		"card_state": CARD_STATE_DEAD,
	}
	if participant == null:
		return card
	var current_vitality: float = BattleCombatConsequenceService.clamp_vitality(participant.vitality)
	if not participant.is_alive:
		current_vitality = 0.0
	var ratio: float = 0.0
	if participant.is_alive and BattleCombatConsequenceService.BASELINE_VITALITY > 0.0:
		ratio = clampf(current_vitality / BattleCombatConsequenceService.BASELINE_VITALITY, 0.0, 1.0)
	var state: String = CARD_STATE_HEALTHY
	var can_select: bool = false
	if not participant.is_alive:
		state = CARD_STATE_DEAD
	elif participant.is_wounded:
		state = CARD_STATE_WOUNDED
	else:
		can_select = true
	card["participant_id"] = participant.participant_id
	card["weapon_type"] = participant.weapon_type
	card["role_label"] = role_label_for(participant.weapon_type)
	card["display_name"] = ""
	card["firearm_label"] = ""
	card["vitality"] = current_vitality
	card["vitality_ratio"] = ratio
	card["vitality_percent"] = int(round(ratio * 100.0))
	card["is_alive"] = participant.is_alive
	card["is_wounded"] = participant.is_wounded
	card["is_selected"] = (
		can_select
		and not selected_participant_id.is_empty()
		and selected_participant_id == participant.participant_id
	)
	card["can_select"] = can_select
	card["card_state"] = state
	return card


static func role_label_for(weapon_type: String) -> String:
	match weapon_type:
		BattleWeaponCatalog.WEAPON_RIFLE:
			return "RIFLE"
		BattleWeaponCatalog.WEAPON_SMG:
			return "SMG"
		BattleWeaponCatalog.WEAPON_SHOTGUN:
			return "SHOTGUN"
		BattleWeaponCatalog.WEAPON_PISTOL:
			return "PISTOL"
		BattleWeaponCatalog.WEAPON_SNIPER:
			return "SNIPER"
		_:
			if weapon_type.is_empty():
				return ""
			return weapon_type.to_upper()
