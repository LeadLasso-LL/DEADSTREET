class_name BattleCombatCoverEvaluationService
extends RefCounted

# Shared combat-cover usefulness query. Healthy and wounded selection consume this.
# Does not mutate battle state, occupancy, or cover mitigation math.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleCoverService := preload("res://battle/geometry/battle_cover_service.gd")
const BattleCoverProtectionService := preload("res://battle/geometry/battle_cover_protection_service.gd")
const BattleCoverProtectionResult := preload("res://battle/geometry/battle_cover_protection_result.gd")
const BattleLineOfSightService := preload("res://battle/combat/battle_line_of_sight_service.gd")
const BattleLineOfSightResult := preload("res://battle/combat/battle_line_of_sight_result.gd")
const BattleNavigationService := preload("res://battle/navigation/battle_navigation_service.gd")
const BattleNavigationResult := preload("res://battle/navigation/battle_navigation_result.gd")
const BattleCombatCoverEvaluation := preload("res://battle/combat/battle_combat_cover_evaluation.gd")
const BattleCombatBehaviorCatalog := preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const BattleWeaponCatalog := preload("res://battle/combat/battle_weapon_catalog.gd")
const BattleWeaponDefinition := preload("res://battle/combat/battle_weapon_definition.gd")

# AI usefulness only. Does not change cover mitigation.
const USEFUL_PROTECTION_FACTOR := 0.50


static func is_useful_protection_factor(protection_factor: float) -> bool:
	if not is_finite(protection_factor):
		return false
	return protection_factor > USEFUL_PROTECTION_FACTOR or is_equal_approx(
		protection_factor,
		USEFUL_PROTECTION_FACTOR
	)


static func occupied_cover_is_suitable(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	require_weapon_range: bool = false
) -> bool:
	if participant == null or battle_state == null or battle_state.battlefield_geometry == null:
		return false
	if participant.occupied_cover_slot_id.is_empty():
		return false
	var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(
		participant.occupied_cover_slot_id
	)
	if slot == null or slot.occupied_by_participant_id != participant.participant_id:
		return false
	if hostile == null or not hostile.is_alive:
		return true
	if not _is_positioned(hostile):
		return true
	var evaluation: BattleCombatCoverEvaluation = evaluate_slot(
		battle_state,
		participant,
		slot,
		hostile,
		false,
		require_weapon_range,
		INF
	)
	if evaluation == null:
		return false
	if not evaluation.legal:
		return false
	if not evaluation.has_line_of_sight:
		return false
	if not evaluation.has_useful_direction:
		return false
	if require_weapon_range and not evaluation.in_weapon_max_range:
		return false
	return true


static func select_best_combat_usable_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	require_weapon_range: bool,
	max_move_distance: float = INF
) -> BattleCoverSlot:
	var ranked: Array[BattleCombatCoverEvaluation] = rank_combat_usable(
		battle_state,
		participant,
		hostile,
		require_weapon_range,
		max_move_distance
	)
	return first_reachable_ranked_slot(battle_state, participant, ranked, false)


static func rank_combat_usable_within_radius(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	require_weapon_range: bool,
	origin: Vector2,
	radius: float
) -> Array[BattleCombatCoverEvaluation]:
	var ranked: Array[BattleCombatCoverEvaluation] = []
	if not BattlefieldGeometry.is_finite_point(origin) or not is_finite(radius) or radius < 0.0:
		return ranked
	if battle_state == null or participant == null or battle_state.battlefield_geometry == null:
		return ranked
	for slot_id: String in battle_state.battlefield_geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot == null or not slot.is_valid():
			continue
		var distance: float = slot.position.distance_to(origin)
		if not is_finite(distance):
			continue
		if distance > radius and not is_equal_approx(distance, radius):
			continue
		var evaluation: BattleCombatCoverEvaluation = evaluate_slot(
			battle_state,
			participant,
			slot,
			hostile,
			false,
			require_weapon_range,
			INF
		)
		if evaluation == null or not evaluation.combat_usable:
			continue
		_insert_ranked(ranked, evaluation, false)
	return ranked


static func rank_combat_usable(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	require_weapon_range: bool,
	max_move_distance: float = INF
) -> Array[BattleCombatCoverEvaluation]:
	var ranked: Array[BattleCombatCoverEvaluation] = []
	for evaluation: BattleCombatCoverEvaluation in evaluate_all(
		battle_state,
		participant,
		hostile,
		false,
		require_weapon_range,
		max_move_distance
	):
		if evaluation == null or not evaluation.combat_usable:
			continue
		_insert_ranked(ranked, evaluation, false)
	return ranked


static func rank_healthy_role(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	weapon_type_id: String,
	require_weapon_range: bool,
	max_move_distance: float
) -> Array[BattleCombatCoverEvaluation]:
	var prefer_band: bool = (
		weapon_type_id == BattleWeaponCatalog.WEAPON_RIFLE
		or weapon_type_id == BattleWeaponCatalog.WEAPON_SNIPER
	)
	var ranked: Array[BattleCombatCoverEvaluation] = []
	for evaluation: BattleCombatCoverEvaluation in evaluate_all(
		battle_state,
		participant,
		hostile,
		false,
		require_weapon_range,
		max_move_distance
	):
		if evaluation == null or not evaluation.combat_usable:
			continue
		if prefer_band:
			var slot_range: float = INF
			if hostile != null and _is_positioned(hostile):
				var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(evaluation.slot_id)
				if slot != null:
					slot_range = slot.position.distance_to(hostile.battle_position)
			evaluation.band_error = BattleCombatBehaviorCatalog.preferred_band_error(
				weapon_type_id,
				slot_range
			)
			if not is_finite(evaluation.band_error):
				continue
			evaluation.in_band = is_equal_approx(evaluation.band_error, 0.0)
		_insert_ranked(ranked, evaluation, prefer_band)
	return ranked


static func evaluate_all(
	battle_state: BattleState,
	participant: BattleParticipant,
	hostile: BattleParticipant,
	require_reachable: bool,
	require_weapon_range: bool,
	max_move_distance: float = INF
) -> Array[BattleCombatCoverEvaluation]:
	var evaluations: Array[BattleCombatCoverEvaluation] = []
	if battle_state == null or participant == null or battle_state.battlefield_geometry == null:
		return evaluations
	for slot_id: String in battle_state.battlefield_geometry.get_sorted_cover_slot_ids():
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(slot_id)
		if slot == null:
			continue
		evaluations.append(
			evaluate_slot(
				battle_state,
				participant,
				slot,
				hostile,
				require_reachable,
				require_weapon_range,
				max_move_distance
			)
		)
	return evaluations


static func evaluate_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot,
	hostile: BattleParticipant,
	require_reachable: bool,
	require_weapon_range: bool,
	max_move_distance: float = INF
) -> BattleCombatCoverEvaluation:
	var evaluation: BattleCombatCoverEvaluation = BattleCombatCoverEvaluation.new()
	if slot != null:
		evaluation.slot_id = slot.cover_slot_id
	if participant == null or slot == null or not slot.is_valid():
		return evaluation
	evaluation.legal = _slot_is_legal_for_participant(participant, slot)
	evaluation.move_distance = INF
	if _is_positioned(participant) and BattlefieldGeometry.is_finite_point(slot.position):
		evaluation.move_distance = participant.battle_position.distance_to(slot.position)
	var within_seek: bool = true
	if is_finite(max_move_distance):
		within_seek = (
			is_finite(evaluation.move_distance)
			and (
				evaluation.move_distance < max_move_distance
				or is_equal_approx(evaluation.move_distance, max_move_distance)
			)
		)
	if hostile != null and _is_positioned(hostile):
		var protection: BattleCoverProtectionResult = BattleCoverProtectionService.query_slot_protection(
			slot,
			hostile.battle_position
		)
		if protection != null and protection.has_applicable_cover:
			evaluation.protection_factor = protection.protection_factor
			evaluation.alignment_dot = protection.alignment_dot
	evaluation.has_useful_direction = is_useful_protection_factor(evaluation.protection_factor)
	if hostile != null and _is_positioned(hostile) and battle_state != null:
		var los: BattleLineOfSightResult = BattleLineOfSightService.check_segment(
			battle_state,
			slot.position,
			hostile.battle_position
		)
		if los != null and los.success:
			evaluation.has_line_of_sight = los.has_line_of_sight
			evaluation.blocking_obstacle_id = los.blocking_obstacle_id
		evaluation.in_weapon_max_range = _slot_is_within_weapon_max_range(
			slot,
			hostile,
			_participant_weapon_type_id(participant)
		)
	var cheap_usable: bool = (
		evaluation.legal
		and within_seek
		and evaluation.has_useful_direction
		and evaluation.has_line_of_sight
		and (evaluation.in_weapon_max_range if require_weapon_range else true)
	)
	evaluation.reachable = false
	if cheap_usable:
		if (
			is_finite(evaluation.move_distance)
			and evaluation.move_distance <= BattleCoverService.COVER_OCCUPANCY_EPSILON
		):
			evaluation.reachable = true
		elif require_reachable:
			evaluation.reachable = _slot_is_reachable(battle_state, participant, slot)
		else:
			evaluation.reachable = true
	evaluation.combat_usable = cheap_usable and evaluation.reachable
	return evaluation


static func first_reachable_ranked_slot(
	battle_state: BattleState,
	participant: BattleParticipant,
	ranked: Array[BattleCombatCoverEvaluation],
	skip_self_occupied: bool
) -> BattleCoverSlot:
	if battle_state == null or participant == null or battle_state.battlefield_geometry == null:
		return null
	for evaluation: BattleCombatCoverEvaluation in ranked:
		if evaluation == null or evaluation.slot_id.is_empty():
			continue
		var slot: BattleCoverSlot = battle_state.battlefield_geometry.get_cover_slot(evaluation.slot_id)
		if slot == null or not slot.is_valid():
			continue
		if skip_self_occupied and slot.occupied_by_participant_id == participant.participant_id:
			continue
		if _slot_is_reachable(battle_state, participant, slot):
			return slot
	return null


static func _insert_ranked(
	ranked: Array[BattleCombatCoverEvaluation],
	candidate: BattleCombatCoverEvaluation,
	prefer_band: bool
) -> void:
	var index: int = 0
	while index < ranked.size() and not _rank_less(candidate, ranked[index], prefer_band):
		index += 1
	ranked.insert(index, candidate)


static func _rank_less(
	left: BattleCombatCoverEvaluation,
	right: BattleCombatCoverEvaluation,
	prefer_band: bool
) -> bool:
	if prefer_band:
		if left.in_band != right.in_band:
			return left.in_band and not right.in_band
		if not is_equal_approx(left.band_error, right.band_error):
			return left.band_error < right.band_error
	if not is_equal_approx(left.protection_factor, right.protection_factor):
		return left.protection_factor > right.protection_factor
	if not is_equal_approx(left.move_distance, right.move_distance):
		return left.move_distance < right.move_distance
	return left.slot_id < right.slot_id


static func _slot_is_legal_for_participant(participant: BattleParticipant, slot: BattleCoverSlot) -> bool:
	if participant == null or slot == null or not slot.is_valid():
		return false
	if slot.occupied_by_participant_id != "" and slot.occupied_by_participant_id != participant.participant_id:
		return false
	if slot.occupied_by_participant_id == participant.participant_id:
		return true
	if slot.reserved_by_participant_id != "" and slot.reserved_by_participant_id != participant.participant_id:
		return false
	return true


static func _slot_is_reachable(
	battle_state: BattleState,
	participant: BattleParticipant,
	slot: BattleCoverSlot
) -> bool:
	if participant == null or slot == null or battle_state == null:
		return false
	if not _is_positioned(participant):
		return false
	if participant.battle_position.distance_to(slot.position) <= BattleCoverService.COVER_OCCUPANCY_EPSILON:
		return true
	return BattleNavigationService.is_reachable(
		battle_state,
		participant.battle_position,
		slot.position
	)


static func _slot_is_within_weapon_max_range(
	slot: BattleCoverSlot,
	hostile: BattleParticipant,
	weapon_type_id: String
) -> bool:
	if slot == null or not slot.is_valid() or hostile == null or not _is_positioned(hostile):
		return false
	var definition: BattleWeaponDefinition = BattleWeaponCatalog.get_definition(weapon_type_id)
	if definition == null or not definition.is_valid():
		return false
	var slot_range: float = slot.position.distance_to(hostile.battle_position)
	if not is_finite(slot_range):
		return false
	return slot_range <= definition.max_range or is_equal_approx(slot_range, definition.max_range)


static func _participant_weapon_type_id(participant: BattleParticipant) -> String:
	if participant == null:
		return ""
	if participant.weapon_state != null and not participant.weapon_state.weapon_type_id.is_empty():
		return participant.weapon_state.weapon_type_id
	return participant.weapon_type


static func _is_positioned(participant: BattleParticipant) -> bool:
	if participant == null:
		return false
	if not participant.has_battle_position:
		return false
	return BattlefieldGeometry.is_finite_point(participant.battle_position)
