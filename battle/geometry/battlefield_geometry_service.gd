class_name BattlefieldGeometryService
extends RefCounted

const BattleState := preload("res://battle/core/battle_state.gd")
const BattleSide := preload("res://battle/core/battle_side.gd")
const BattleParticipant := preload("res://battle/core/battle_participant.gd")
const BattleVehicle := preload("res://battle/core/battle_vehicle.gd")
const DeploymentZone := preload("res://battle/core/deployment_zone.gd")
const BattlefieldGeometry := preload("res://battle/geometry/battlefield_geometry.gd")
const BattlefieldGeometryResult := preload("res://battle/geometry/battlefield_geometry_result.gd")

const PROVISIONAL_WIDTH := 100.0
const PROVISIONAL_HEIGHT := 60.0
const PROVISIONAL_DEPLOYMENT_BAND_WIDTH := 20.0
const PROVISIONAL_EDGE_MARGIN := 2.0
const PROVISIONAL_VEHICLE_STRIP_WIDTH := 8.0
const PROVISIONAL_CATEGORY_GAP := 2.0


static func initialize_default_geometry(battle_state: BattleState) -> BattlefieldGeometryResult:
	if battle_state == null:
		return BattlefieldGeometryResult.failed(
			"null_battle_state",
			"Battlefield geometry failed: battle_state is null."
		)
	if battle_state.battle_phase != "deployment":
		return BattlefieldGeometryResult.failed(
			"battle_not_in_deployment",
			"Battlefield geometry failed: battle phase is '%s', not deployment." % battle_state.battle_phase
		)
	if battle_state.attacker_side_id.is_empty() or not battle_state.has_side(battle_state.attacker_side_id):
		return BattlefieldGeometryResult.failed(
			"missing_attacker_side",
			"Battlefield geometry failed: attacker side is missing."
		)
	if battle_state.defender_side_id.is_empty() or not battle_state.has_side(battle_state.defender_side_id):
		return BattlefieldGeometryResult.failed(
			"missing_defender_side",
			"Battlefield geometry failed: defender side is missing."
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
			"Battlefield geometry failed: attacker deployment zone is missing."
		)
	var defender_zone: DeploymentZone = _require_side_zone(
		battle_state,
		defender_side,
		battle_state.defender_side_id
	)
	if defender_zone == null:
		return BattlefieldGeometryResult.failed(
			"missing_defender_deployment_zone",
			"Battlefield geometry failed: defender deployment zone is missing."
		)
	if not _provisional_constants_are_usable():
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	var geometry: BattlefieldGeometry = _make_default_geometry()
	if geometry == null or not geometry.is_valid():
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	var attacker_participant_ids: Array[String] = _sorted_copy(attacker_zone.deployed_participant_ids)
	var attacker_vehicle_ids: Array[String] = _sorted_copy(attacker_zone.deployed_vehicle_ids)
	var defender_participant_ids: Array[String] = _sorted_copy(defender_zone.deployed_participant_ids)
	var defender_vehicle_ids: Array[String] = _sorted_copy(defender_zone.deployed_vehicle_ids)
	var attacker_participant_points: Array[Vector2] = _layout_points(
		_inset_rect(_participant_body_rect(geometry.attacker_deployment_rect, true)),
		attacker_participant_ids.size()
	)
	var attacker_vehicle_points: Array[Vector2] = _layout_points(
		_inset_rect(_vehicle_strip_rect(geometry.attacker_deployment_rect, true)),
		attacker_vehicle_ids.size()
	)
	var defender_participant_points: Array[Vector2] = _layout_points(
		_inset_rect(_participant_body_rect(geometry.defender_deployment_rect, false)),
		defender_participant_ids.size()
	)
	var defender_vehicle_points: Array[Vector2] = _layout_points(
		_inset_rect(_vehicle_strip_rect(geometry.defender_deployment_rect, false)),
		defender_vehicle_ids.size()
	)
	if (
		attacker_participant_points.size() != attacker_participant_ids.size()
		or attacker_vehicle_points.size() != attacker_vehicle_ids.size()
		or defender_participant_points.size() != defender_participant_ids.size()
		or defender_vehicle_points.size() != defender_vehicle_ids.size()
	):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _points_are_unique(attacker_participant_points) or not _points_are_unique(attacker_vehicle_points):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _points_are_unique(defender_participant_points) or not _points_are_unique(defender_vehicle_points):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _all_points_in_rect(attacker_participant_points, geometry.attacker_deployment_rect):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _all_points_in_rect(attacker_vehicle_points, geometry.attacker_deployment_rect):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _all_points_in_rect(defender_participant_points, geometry.defender_deployment_rect):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _all_points_in_rect(defender_vehicle_points, geometry.defender_deployment_rect):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _deployed_participants_are_assignable(battle_state, attacker_zone, attacker_participant_ids):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _deployed_vehicles_are_assignable(battle_state, attacker_zone, attacker_vehicle_ids):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _deployed_participants_are_assignable(battle_state, defender_zone, defender_participant_ids):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	if not _deployed_vehicles_are_assignable(battle_state, defender_zone, defender_vehicle_ids):
		return BattlefieldGeometryResult.failed(
			"invalid_geometry",
			"Battlefield geometry failed: generated geometry is invalid."
		)
	battle_state.battlefield_geometry = geometry
	attacker_zone.deployment_rect = geometry.attacker_deployment_rect
	defender_zone.deployment_rect = geometry.defender_deployment_rect
	_apply_participant_positions(battle_state, attacker_participant_ids, attacker_participant_points)
	_apply_vehicle_positions(battle_state, attacker_vehicle_ids, attacker_vehicle_points)
	_apply_participant_positions(battle_state, defender_participant_ids, defender_participant_points)
	_apply_vehicle_positions(battle_state, defender_vehicle_ids, defender_vehicle_points)
	return BattlefieldGeometryResult.succeeded(
		attacker_participant_ids.size() + defender_participant_ids.size(),
		attacker_vehicle_ids.size() + defender_vehicle_ids.size()
	)


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


static func _provisional_constants_are_usable() -> bool:
	if not is_finite(PROVISIONAL_WIDTH) or not is_finite(PROVISIONAL_HEIGHT):
		return false
	if PROVISIONAL_WIDTH <= 0.0 or PROVISIONAL_HEIGHT <= 0.0:
		return false
	if not is_finite(PROVISIONAL_DEPLOYMENT_BAND_WIDTH) or PROVISIONAL_DEPLOYMENT_BAND_WIDTH <= 0.0:
		return false
	if PROVISIONAL_DEPLOYMENT_BAND_WIDTH * 2.0 > PROVISIONAL_WIDTH:
		return false
	if not is_finite(PROVISIONAL_EDGE_MARGIN) or PROVISIONAL_EDGE_MARGIN < 0.0:
		return false
	if not is_finite(PROVISIONAL_VEHICLE_STRIP_WIDTH) or PROVISIONAL_VEHICLE_STRIP_WIDTH <= 0.0:
		return false
	if not is_finite(PROVISIONAL_CATEGORY_GAP) or PROVISIONAL_CATEGORY_GAP < 0.0:
		return false
	if PROVISIONAL_VEHICLE_STRIP_WIDTH + PROVISIONAL_CATEGORY_GAP >= PROVISIONAL_DEPLOYMENT_BAND_WIDTH:
		return false
	var remaining_width: float = (
		PROVISIONAL_DEPLOYMENT_BAND_WIDTH - PROVISIONAL_VEHICLE_STRIP_WIDTH - PROVISIONAL_CATEGORY_GAP
	)
	if remaining_width - 2.0 * PROVISIONAL_EDGE_MARGIN <= 0.0:
		return false
	if PROVISIONAL_VEHICLE_STRIP_WIDTH - 2.0 * PROVISIONAL_EDGE_MARGIN <= 0.0:
		return false
	if PROVISIONAL_HEIGHT - 2.0 * PROVISIONAL_EDGE_MARGIN <= 0.0:
		return false
	return true


static func _make_default_geometry() -> BattlefieldGeometry:
	var geometry: BattlefieldGeometry = BattlefieldGeometry.new()
	geometry.width = PROVISIONAL_WIDTH
	geometry.height = PROVISIONAL_HEIGHT
	geometry.attacker_deployment_rect = Rect2(
		0.0,
		0.0,
		PROVISIONAL_DEPLOYMENT_BAND_WIDTH,
		PROVISIONAL_HEIGHT
	)
	geometry.defender_deployment_rect = Rect2(
		PROVISIONAL_WIDTH - PROVISIONAL_DEPLOYMENT_BAND_WIDTH,
		0.0,
		PROVISIONAL_DEPLOYMENT_BAND_WIDTH,
		PROVISIONAL_HEIGHT
	)
	return geometry


static func _vehicle_strip_rect(band: Rect2, is_attacker: bool) -> Rect2:
	if is_attacker:
		return Rect2(band.position.x, band.position.y, PROVISIONAL_VEHICLE_STRIP_WIDTH, band.size.y)
	return Rect2(
		band.position.x + band.size.x - PROVISIONAL_VEHICLE_STRIP_WIDTH,
		band.position.y,
		PROVISIONAL_VEHICLE_STRIP_WIDTH,
		band.size.y
	)


static func _participant_body_rect(band: Rect2, is_attacker: bool) -> Rect2:
	var remaining_width: float = (
		band.size.x - PROVISIONAL_VEHICLE_STRIP_WIDTH - PROVISIONAL_CATEGORY_GAP
	)
	if is_attacker:
		return Rect2(
			band.position.x + PROVISIONAL_VEHICLE_STRIP_WIDTH + PROVISIONAL_CATEGORY_GAP,
			band.position.y,
			remaining_width,
			band.size.y
		)
	return Rect2(band.position.x, band.position.y, remaining_width, band.size.y)


static func _inset_rect(rect: Rect2) -> Rect2:
	return Rect2(
		rect.position.x + PROVISIONAL_EDGE_MARGIN,
		rect.position.y + PROVISIONAL_EDGE_MARGIN,
		rect.size.x - 2.0 * PROVISIONAL_EDGE_MARGIN,
		rect.size.y - 2.0 * PROVISIONAL_EDGE_MARGIN
	)


static func _layout_points(area: Rect2, count: int) -> Array[Vector2]:
	var points: Array[Vector2] = []
	if count <= 0:
		return points
	if not BattlefieldGeometry.rect_is_usable(area):
		return points
	var aspect: float = area.size.x / area.size.y
	var cols: int = ceili(sqrt(float(count) * aspect))
	if cols < 1:
		cols = 1
	var rows: int = ceili(float(count) / float(cols))
	if rows < 1:
		rows = 1
	var cell_w: float = area.size.x / float(cols)
	var cell_h: float = area.size.y / float(rows)
	if cell_w <= 0.0 or cell_h <= 0.0:
		return points
	var index: int = 0
	while index < count:
		var col: int = index % cols
		var row: int = int(index / cols)
		points.append(
			Vector2(
				area.position.x + (float(col) + 0.5) * cell_w,
				area.position.y + (float(row) + 0.5) * cell_h
			)
		)
		index += 1
	return points


static func _sorted_copy(source: Array[String]) -> Array[String]:
	var copied: Array[String] = []
	for item_id: String in source:
		copied.append(item_id)
	copied.sort()
	return copied


static func _points_are_unique(points: Array[Vector2]) -> bool:
	var seen: Dictionary = {}
	for point: Vector2 in points:
		if not BattlefieldGeometry.is_finite_point(point):
			return false
		var key: String = "%s,%s" % [point.x, point.y]
		if seen.has(key):
			return false
		seen[key] = true
	return true


static func _all_points_in_rect(points: Array[Vector2], rect: Rect2) -> bool:
	for point: Vector2 in points:
		if not BattlefieldGeometry.rect_contains_point(rect, point):
			return false
	return true


static func _deployed_participants_are_assignable(
	battle_state: BattleState,
	zone: DeploymentZone,
	participant_ids: Array[String]
) -> bool:
	if battle_state == null or zone == null:
		return false
	for participant_id: String in participant_ids:
		if not battle_state.has_participant(participant_id):
			return false
		var participant: BattleParticipant = battle_state.get_participant(participant_id)
		if participant == null:
			return false
		if participant.side_id != zone.side_id:
			return false
		if participant.deployment_slot_id != zone.zone_id:
			return false
	return true


static func _deployed_vehicles_are_assignable(
	battle_state: BattleState,
	zone: DeploymentZone,
	vehicle_ids: Array[String]
) -> bool:
	if battle_state == null or zone == null:
		return false
	for vehicle_id: String in vehicle_ids:
		if not battle_state.has_vehicle(vehicle_id):
			return false
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_id)
		if vehicle == null:
			return false
		if vehicle.side_id != zone.side_id:
			return false
		if vehicle.deployment_slot_id != zone.zone_id:
			return false
	return true


static func _apply_participant_positions(
	battle_state: BattleState,
	participant_ids: Array[String],
	points: Array[Vector2]
) -> void:
	var index: int = 0
	while index < participant_ids.size() and index < points.size():
		var participant: BattleParticipant = battle_state.get_participant(participant_ids[index])
		if participant != null:
			participant.has_battle_position = true
			participant.battle_position = points[index]
		index += 1


static func _apply_vehicle_positions(
	battle_state: BattleState,
	vehicle_ids: Array[String],
	points: Array[Vector2]
) -> void:
	var index: int = 0
	while index < vehicle_ids.size() and index < points.size():
		var vehicle: BattleVehicle = battle_state.get_vehicle(vehicle_ids[index])
		if vehicle != null:
			vehicle.has_battle_position = true
			vehicle.battle_position = points[index]
		index += 1
