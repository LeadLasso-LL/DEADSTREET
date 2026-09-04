class_name AuthoredBattlefieldService
extends RefCounted

# Applies an authored battlefield definition onto BattleState.
# Does not own combat, commands, or campaign geography.

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattlefieldGeometryResult := preload("res://battle/geometry/battlefield_geometry_result.gd")
const AuthoredBattlefieldDefinition := preload("res://battle/geometry/authored_battlefield_definition.gd")
const TacticalProvingGroundCatalog := preload("res://battle/geometry/tactical_proving_ground_catalog.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleSurfaceRegion := preload("res://battle/geometry/battle_surface_region.gd")
const BattlePresentationMarking := preload("res://battle/geometry/battle_presentation_marking.gd")
const BattleForceCommandService := preload("res://battle/core/battle_force_command_service.gd")

const LAYOUT_PROVING_GROUND := TacticalProvingGroundCatalog.LAYOUT_ID


static func initialize_proving_ground(battle_state: BattleState) -> BattlefieldGeometryResult:
	return apply_definition(battle_state, TacticalProvingGroundCatalog.west_east_commercial_block_v2())


static func apply_definition(
	battle_state: BattleState,
	definition: AuthoredBattlefieldDefinition
) -> BattlefieldGeometryResult:
	if battle_state == null:
		return BattlefieldGeometryResult.failed(
			"null_battle_state",
			"Authored battlefield failed: battle_state is null."
		)
	if battle_state.battle_phase != "deployment":
		return BattlefieldGeometryResult.failed(
			"battle_not_in_deployment",
			"Authored battlefield failed: battle phase is '%s', not deployment." % battle_state.battle_phase
		)
	if battle_state.attacker_side_id.is_empty() or not battle_state.has_side(battle_state.attacker_side_id):
		return BattlefieldGeometryResult.failed(
			"missing_attacker_side",
			"Authored battlefield failed: attacker side is missing."
		)
	if battle_state.defender_side_id.is_empty() or not battle_state.has_side(battle_state.defender_side_id):
		return BattlefieldGeometryResult.failed(
			"missing_defender_side",
			"Authored battlefield failed: defender side is missing."
		)
	var attacker_side: BattleSide = battle_state.get_side(battle_state.attacker_side_id)
	var defender_side: BattleSide = battle_state.get_side(battle_state.defender_side_id)
	var attacker_zone: DeploymentZone = _require_side_zone(
		battle_state,
		attacker_side,
		battle_state.attacker_side_id
	)
	if attacker_zone == null:
		return BattlefieldGeometryResult.failed(
			"missing_attacker_deployment_zone",
			"Authored battlefield failed: attacker deployment zone is missing."
		)
	var defender_zone: DeploymentZone = _require_side_zone(
		battle_state,
		defender_side,
		battle_state.defender_side_id
	)
	if defender_zone == null:
		return BattlefieldGeometryResult.failed(
			"missing_defender_deployment_zone",
			"Authored battlefield failed: defender deployment zone is missing."
		)
	if definition == null or not definition.is_valid():
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Authored battlefield failed: definition is invalid."
		)
	var geometry: BattlefieldGeometry = _build_geometry(definition)
	if geometry == null or not geometry.is_valid():
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Authored battlefield failed: generated geometry is invalid."
		)
	battle_state.battlefield_geometry = geometry
	attacker_zone.deployment_rect = geometry.attacker_deployment_rect
	defender_zone.deployment_rect = geometry.defender_deployment_rect
	BattleForceCommandService.initialize_assault_frames_from_geometry(battle_state)
	return BattlefieldGeometryResult.succeeded(0, 0)


static func _build_geometry(definition: AuthoredBattlefieldDefinition) -> BattlefieldGeometry:
	if definition == null:
		return null
	var geometry: BattlefieldGeometry = BattlefieldGeometry.new()
	geometry.authored_layout_id = definition.definition_id
	geometry.width = definition.width
	geometry.height = definition.height
	geometry.attacker_deployment_area = definition.attacker_deployment_area
	geometry.defender_deployment_area = definition.defender_deployment_area
	geometry.attacker_deployment_rect = definition.attacker_deployment_area.bounding_rect()
	geometry.defender_deployment_rect = definition.defender_deployment_area.bounding_rect()
	geometry.attacker_vehicle_placement_context = definition.attacker_vehicle_placement_context
	geometry.defender_vehicle_placement_context = definition.defender_vehicle_placement_context
	for surface: BattleSurfaceRegion in definition.surfaces:
		if surface == null or not geometry.add_surface_region(surface):
			return null
	for marking: BattlePresentationMarking in definition.presentation_markings:
		if marking == null or not geometry.add_presentation_marking(marking):
			return null
	for obstacle: BattleObstacle in definition.obstacles:
		if obstacle == null or not geometry.add_obstacle(obstacle):
			return null
	for cover_object: BattleCoverObject in definition.cover_objects:
		if cover_object == null or not geometry.add_cover_object(cover_object):
			return null
	for cover_slot: BattleCoverSlot in definition.cover_slots:
		if cover_slot == null or not geometry.add_cover_slot(cover_slot):
			return null
	return geometry


static func _require_side_zone(
	battle_state: BattleState,
	side: BattleSide,
	expected_side_id: String
) -> DeploymentZone:
	if battle_state == null or side == null:
		return null
	if side.deployment_zone_id.is_empty():
		return null
	if not battle_state.has_deployment_zone(side.deployment_zone_id):
		return null
	var zone: DeploymentZone = battle_state.get_deployment_zone(side.deployment_zone_id)
	if zone == null or zone.side_id != expected_side_id:
		return null
	return zone
