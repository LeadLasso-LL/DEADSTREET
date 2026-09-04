class_name TacticalProvingGroundCatalog
extends RefCounted

# Authored south-to-north Neighborhood HQ frontage assault.
# Testing environment, not campaign-map localization.
# North row: left neighbor → HQ → HQ-side alley → right neighbor → FAR-RIGHT ALLEY → east edge.
# Rear strip north of the right building connects the two alleys into a wrap route.
# Visual dressing stays presentation-only.

const AuthoredBattlefieldDefinition := preload("res://battle/geometry/authored_battlefield_definition.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleSurfaceRegion := preload("res://battle/geometry/battle_surface_region.gd")
const BattlePresentationMarking := preload("res://battle/geometry/battle_presentation_marking.gd")
const BattleDeploymentPocket := preload("res://battle/geometry/battle_deployment_pocket.gd")
const BattleVehiclePlacementContext := preload("res://battle/vehicles/battle_vehicle_placement_context.gd")

const LAYOUT_ID := "hq_frontage_assault_v1"
const WIDTH := 86.0
const HEIGHT := 58.0

const MAIN_ROAD := Rect2(0.0, 26.8, 86.0, 15.2)
const NORTH_SIDEWALK := Rect2(0.0, 22.4, 77.0, 4.4)
const SOUTH_SIDEWALK := Rect2(0.0, 42.0, 86.0, 4.4)
const ALLEY_SURFACE := Rect2(77.0, 0.6, 9.0, 26.2)
const HQ_SIDE_ALLEY := Rect2(53.0, 0.6, 5.0, 22.2)
const REAR_SPACE := Rect2(53.0, 0.6, 33.0, 3.8)
const PORCH_APRON := Rect2(17.0, 18.2, 36.0, 4.2)
const STAIRS_BOUNDS := Rect2(32.2, 18.3, 5.6, 4.0)

const HQ_BOUNDS := Rect2(17.0, 0.6, 36.0, 17.6)
const WEST_NEIGHBOR_BOUNDS := Rect2(0.5, 0.6, 14.6, 19.4)
const EAST_NEIGHBOR_BOUNDS := Rect2(58.0, 4.4, 19.0, 16.4)
const SW_FRAMING_BOUNDS := Rect2(0.5, 50.4, 17.5, 7.2)
const SOUTH_MID_FRAMING_BOUNDS := Rect2(30.5, 51.0, 15.5, 6.6)
const SE_FRAMING_BOUNDS := Rect2(58.0, 50.4, 16.0, 7.2)

const ATTACKER_VEHICLE_ANCHOR := Vector2(46.5, 35.2)
# Blueprint heading (-0.50, -0.87) is not unit-length; vehicle facing requires a unit vector.
const ATTACKER_VEHICLE_HEADING := Vector2(-0.498283875853458, -0.867013943985018)
const ATTACKER_PLACE_POINT := Vector2(47.2, 37.2)
const ATTACKER_ALLEY_APPROACH_POINT := Vector2(83.0, 25.8)
const ALLEY_DEEP_POINT := Vector2(81.5, 10.0)
const ALLEY_MOUTH_POINT := Vector2(83.0, 25.8)
const FAR_RIGHT_ALLEY_NORTH_POINT := Vector2(81.5, 2.4)
const RIGHT_NEIGHBOR_REAR_POINT := Vector2(67.5, 2.4)
const RIGHT_NEIGHBOR_SE_POINT := Vector2(77.8, 21.4)
const HQ_SIDE_ALLEY_FRONT_POINT := Vector2(56.0, 21.6)
const HQ_SIDE_ALLEY_MID_POINT := Vector2(55.4, 12.0)
const HQ_SIDE_ALLEY_REAR_POINT := Vector2(54.6, 5.6)
const DEFENDER_FRONTAGE_WEST_POINT := Vector2(19.2, 24.4)
const DEFENDER_FRONTAGE_CENTER_POINT := Vector2(35.0, 24.4)
const DEFENDER_FRONTAGE_EAST_POINT := Vector2(49.6, 25.6)
const DEFENDER_STREET_WEST_POINT := Vector2(24.8, 29.4)

const COVER_SLOT_OFFSET := 0.8


static func hq_frontage_assault_v1() -> AuthoredBattlefieldDefinition:
	var definition: AuthoredBattlefieldDefinition = AuthoredBattlefieldDefinition.new()
	definition.definition_id = LAYOUT_ID
	definition.width = WIDTH
	definition.height = HEIGHT
	_add_surfaces(definition)
	_add_presentation_markings(definition)
	_add_hard_structures(definition)
	_add_soft_cover(definition)
	_add_attacker_pockets(definition)
	_add_defender_pockets(definition)
	definition.attacker_vehicle_placement_context = BattleVehiclePlacementContext.new(
		true,
		ATTACKER_VEHICLE_ANCHOR,
		true,
		ATTACKER_VEHICLE_HEADING
	)
	return definition


static func _add_surfaces(definition: AuthoredBattlefieldDefinition) -> void:
	definition.surfaces.append(
		BattleSurfaceRegion.new("road_main", BattleSurfaceRegion.KIND_ASPHALT, MAIN_ROAD)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("sidewalk_north", BattleSurfaceRegion.KIND_SIDEWALK, NORTH_SIDEWALK)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("sidewalk_south", BattleSurfaceRegion.KIND_SIDEWALK, SOUTH_SIDEWALK)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("alley_hq_east", BattleSurfaceRegion.KIND_ALLEY, ALLEY_SURFACE)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("alley_hq_side", BattleSurfaceRegion.KIND_ALLEY, HQ_SIDE_ALLEY)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("alley_right_rear", BattleSurfaceRegion.KIND_ALLEY, REAR_SPACE)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("apron_hq_porch", BattleSurfaceRegion.KIND_APRON, PORCH_APRON)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("curb_north", BattleSurfaceRegion.KIND_CURB, Rect2(0.0, 26.6, 86.0, 0.4))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("curb_south", BattleSurfaceRegion.KIND_CURB, Rect2(0.0, 41.8, 86.0, 0.4))
	)


static func _add_presentation_markings(definition: AuthoredBattlefieldDefinition) -> void:
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"lane_main",
			BattlePresentationMarking.KIND_LANE,
			Rect2(2.0, 34.3, 82.0, 0.26)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"lane_edge_north",
			BattlePresentationMarking.KIND_PARKING,
			Rect2(1.5, 28.2, 83.0, 0.10)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"lane_edge_south",
			BattlePresentationMarking.KIND_PARKING,
			Rect2(1.5, 40.4, 83.0, 0.10)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"sidewalk_joint_north",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(0.0, 22.35, 77.0, 0.12)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"sidewalk_joint_south",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(0.0, 46.28, 86.0, 0.12)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stairs_hq_center",
			BattlePresentationMarking.KIND_LOADING,
			STAIRS_BOUNDS
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stairs_step_a",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(32.4, 19.3, 5.2, 0.16)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stairs_step_b",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(32.4, 20.4, 5.2, 0.16)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stairs_step_c",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(32.4, 21.5, 5.2, 0.16)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stairs_riser",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(34.9, 18.4, 0.14, 3.7)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stop_bar_alley",
			BattlePresentationMarking.KIND_STOP_BAR,
			Rect2(77.2, 26.45, 8.6, 0.28)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"bollard_alley_west",
			BattlePresentationMarking.KIND_BOLLARD,
			Rect2(77.15, 26.05, 0.28, 0.28)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"bollard_alley_east",
			BattlePresentationMarking.KIND_BOLLARD,
			Rect2(85.45, 26.05, 0.28, 0.28)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"alley_edge_west",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(77.0, 0.7, 0.14, 26.0)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"alley_edge_east",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(85.86, 0.7, 0.14, 26.0)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"hq_side_alley_edge_west",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(53.0, 0.7, 0.14, 21.8)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"hq_side_alley_edge_east",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(57.86, 0.7, 0.14, 21.8)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"rear_connector_seam",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(53.2, 4.32, 23.6, 0.14)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"porch_seam_west",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(17.2, 18.25, 14.8, 0.14)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"porch_seam_east",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(38.0, 18.25, 14.8, 0.14)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"porch_front_edge",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(17.1, 22.28, 35.8, 0.14)
		)
	)


static func _add_hard_structures(definition: AuthoredBattlefieldDefinition) -> void:
	definition.obstacles.append(
		BattleObstacle.new("building_hq", HQ_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_west_neighbor", WEST_NEIGHBOR_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_east_neighbor", EAST_NEIGHBOR_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_sw_framing", SW_FRAMING_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_south_mid_framing", SOUTH_MID_FRAMING_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_se_framing", SE_FRAMING_BOUNDS, true, true, "building")
	)


static func _add_soft_cover(definition: AuthoredBattlefieldDefinition) -> void:
	var dumpster_frontage_west := Rect2(20.2, 23.2, 2.3, 1.7)
	var table_frontage_west := Rect2(26.6, 23.6, 1.9, 1.1)
	var trash_frontage_east := Rect2(42.6, 23.3, 1.8, 1.5)
	var crates_frontage_east := Rect2(48.4, 23.5, 2.1, 1.3)
	var dumpster_alley := Rect2(83.2, 11.2, 2.0, 2.4)
	var dumpster_hq_alley_front := Rect2(53.2, 20.8, 1.7, 1.9)
	var crates_hq_alley_rear := Rect2(56.2, 4.6, 1.6, 1.8)
	var porch_stub_west := Rect2(31.4, 19.0, 0.8, 2.6)
	var porch_stub_east := Rect2(38.0, 19.0, 0.8, 2.6)
	var parked_car_attack_west := Rect2(31.6, 39.4, 4.3, 1.8)
	var parked_car_attack_mid := Rect2(40.4, 38.6, 4.1, 1.75)
	var parked_car_attack_east := Rect2(58.8, 37.2, 4.3, 1.8)
	var parked_car_attack_alley := Rect2(71.8, 33.8, 4.2, 1.85)
	var trash_street_approach := Rect2(48.4, 30.4, 1.6, 1.3)
	var parked_car_north_west := Rect2(21.8, 27.6, 4.5, 1.7)
	var parked_car_north_offset := Rect2(39.9, 28.9, 3.6, 1.85)

	definition.obstacles.append(
		BattleObstacle.new("dumpster_frontage_west", dumpster_frontage_west, true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("table_frontage_west", table_frontage_west, true, false, "barrier")
	)
	definition.obstacles.append(
		BattleObstacle.new("trash_frontage_east", trash_frontage_east, true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("crates_frontage_east", crates_frontage_east, true, false, "crates")
	)
	definition.obstacles.append(
		BattleObstacle.new("dumpster_alley", dumpster_alley, true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("dumpster_hq_alley_front", dumpster_hq_alley_front, true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("crates_hq_alley_rear", crates_hq_alley_rear, true, false, "crates")
	)
	definition.obstacles.append(
		BattleObstacle.new("porch_stub_west", porch_stub_west, true, false, "low_wall")
	)
	definition.obstacles.append(
		BattleObstacle.new("porch_stub_east", porch_stub_east, true, false, "low_wall")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_attack_west", parked_car_attack_west, true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_attack_mid", parked_car_attack_mid, true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_attack_east", parked_car_attack_east, true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_attack_alley", parked_car_attack_alley, true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("trash_street_approach", trash_street_approach, true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_north_west", parked_car_north_west, true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_north_offset", parked_car_north_offset, true, false, "parked_car")
	)

	_add_cover_object(
		definition,
		"cover_dumpster_frontage_west",
		"dumpster_frontage_west",
		[
			["cover_dumpster_frontage_west_north", _slot_north(dumpster_frontage_west), Vector2.DOWN],
			["cover_dumpster_frontage_west_east", _slot_east(dumpster_frontage_west), Vector2.LEFT],
			["cover_dumpster_frontage_west_west", _slot_west(dumpster_frontage_west), Vector2.RIGHT],
		]
	)
	_add_cover_object(
		definition,
		"cover_table_frontage_west",
		"table_frontage_west",
		[
			["cover_table_frontage_west_north", _slot_north(table_frontage_west), Vector2.DOWN],
		]
	)
	_add_cover_object(
		definition,
		"cover_trash_frontage_east",
		"trash_frontage_east",
		[
			["cover_trash_frontage_east_north", _slot_north(trash_frontage_east), Vector2.DOWN],
			["cover_trash_frontage_east_east", _slot_east(trash_frontage_east), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_crates_frontage_east",
		"crates_frontage_east",
		[
			["cover_crates_frontage_east_north", _slot_north(crates_frontage_east), Vector2.DOWN],
			["cover_crates_frontage_east_west", _slot_west(crates_frontage_east), Vector2.RIGHT],
		]
	)
	_add_cover_object(
		definition,
		"cover_dumpster_alley",
		"dumpster_alley",
		[
			["cover_dumpster_alley_west", _slot_west(dumpster_alley), Vector2.RIGHT],
			["cover_dumpster_alley_south", _slot_south(dumpster_alley), Vector2.UP],
		]
	)
	_add_cover_object(
		definition,
		"cover_dumpster_hq_alley_front",
		"dumpster_hq_alley_front",
		[
			["cover_dumpster_hq_alley_front_east", _slot_east(dumpster_hq_alley_front), Vector2.LEFT],
			["cover_dumpster_hq_alley_front_south", _slot_south(dumpster_hq_alley_front), Vector2.UP],
		]
	)
	_add_cover_object(
		definition,
		"cover_crates_hq_alley_rear",
		"crates_hq_alley_rear",
		[
			["cover_crates_hq_alley_rear_west", _slot_west(crates_hq_alley_rear), Vector2.RIGHT],
			["cover_crates_hq_alley_rear_north", _slot_north(crates_hq_alley_rear), Vector2.DOWN],
		]
	)
	_add_cover_object(
		definition,
		"cover_porch_stub_west",
		"porch_stub_west",
		[
			["cover_porch_stub_west_east", _slot_east(porch_stub_west), Vector2.LEFT],
			["cover_porch_stub_west_south", _slot_south(porch_stub_west), Vector2.UP],
		]
	)
	_add_cover_object(
		definition,
		"cover_porch_stub_east",
		"porch_stub_east",
		[
			["cover_porch_stub_east_west", _slot_west(porch_stub_east), Vector2.RIGHT],
			["cover_porch_stub_east_south", _slot_south(porch_stub_east), Vector2.UP],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_attack_west",
		"parked_car_attack_west",
		[
			["cover_parked_car_attack_west_south", _slot_south(parked_car_attack_west), Vector2.UP],
			["cover_parked_car_attack_west_east", _slot_east(parked_car_attack_west), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_attack_mid",
		"parked_car_attack_mid",
		[
			["cover_parked_car_attack_mid_south", _slot_south(parked_car_attack_mid), Vector2.UP],
			["cover_parked_car_attack_mid_east", _slot_east(parked_car_attack_mid), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_attack_east",
		"parked_car_attack_east",
		[
			["cover_parked_car_attack_east_south", _slot_south(parked_car_attack_east), Vector2.UP],
			["cover_parked_car_attack_east_west", _slot_west(parked_car_attack_east), Vector2.RIGHT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_attack_alley",
		"parked_car_attack_alley",
		[
			["cover_parked_car_attack_alley_west", _slot_west(parked_car_attack_alley), Vector2.RIGHT],
			["cover_parked_car_attack_alley_south", _slot_south(parked_car_attack_alley), Vector2.UP],
		]
	)
	_add_cover_object(
		definition,
		"cover_trash_street_approach",
		"trash_street_approach",
		[
			["cover_trash_street_approach_south", _slot_south(trash_street_approach), Vector2.UP],
			["cover_trash_street_approach_north", _slot_north(trash_street_approach), Vector2.DOWN],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_north_west",
		"parked_car_north_west",
		[
			["cover_parked_car_north_west_north", _slot_north(parked_car_north_west), Vector2.DOWN],
			["cover_parked_car_north_west_south", _slot_south(parked_car_north_west), Vector2.UP],
			["cover_parked_car_north_west_east", _slot_east(parked_car_north_west), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_north_offset",
		"parked_car_north_offset",
		[
			["cover_parked_car_north_offset_west", _slot_west(parked_car_north_offset), Vector2.RIGHT],
			["cover_parked_car_north_offset_east", _slot_east(parked_car_north_offset), Vector2.LEFT],
			["cover_parked_car_north_offset_south", _slot_south(parked_car_north_offset), Vector2.UP],
			["cover_parked_car_north_offset_north", _slot_north(parked_car_north_offset), Vector2.DOWN],
		]
	)


static func _slot_west(bounds: Rect2) -> Vector2:
	return Vector2(bounds.position.x - COVER_SLOT_OFFSET, bounds.position.y + bounds.size.y * 0.5)


static func _slot_east(bounds: Rect2) -> Vector2:
	return Vector2(
		bounds.position.x + bounds.size.x + COVER_SLOT_OFFSET,
		bounds.position.y + bounds.size.y * 0.5
	)


static func _slot_north(bounds: Rect2) -> Vector2:
	return Vector2(bounds.position.x + bounds.size.x * 0.5, bounds.position.y - COVER_SLOT_OFFSET)


static func _slot_south(bounds: Rect2) -> Vector2:
	return Vector2(
		bounds.position.x + bounds.size.x * 0.5,
		bounds.position.y + bounds.size.y + COVER_SLOT_OFFSET
	)


static func _add_cover_object(
	definition: AuthoredBattlefieldDefinition,
	object_id: String,
	associated_obstacle_id: String,
	slots: Array
) -> void:
	definition.cover_objects.append(BattleCoverObject.new(object_id, associated_obstacle_id))
	for slot_row: Variant in slots:
		if not (slot_row is Array):
			continue
		var row: Array = slot_row as Array
		if row.size() < 3:
			continue
		definition.cover_slots.append(
			BattleCoverSlot.new(str(row[0]), object_id, row[1] as Vector2, row[2] as Vector2)
		)


static func _add_attacker_pockets(definition: AuthoredBattlefieldDefinition) -> void:
	definition.attacker_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"attacker_east_sweep",
			PackedVector2Array(
				[
					Vector2(38.0, 37.2),
					Vector2(39.6, 33.0),
					Vector2(46.8, 32.2),
					Vector2(54.0, 32.8),
					Vector2(64.0, 30.6),
					Vector2(72.5, 28.0),
					Vector2(77.2, 25.4),
					Vector2(86.0, 24.6),
					Vector2(86.0, 46.4),
					Vector2(52.0, 46.4),
					Vector2(38.4, 45.8),
					Vector2(37.0, 41.2),
				]
			)
		)
	)


static func _add_defender_pockets(definition: AuthoredBattlefieldDefinition) -> void:
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_hq_frontage",
			PackedVector2Array(
				[
					Vector2(17.0, 18.4),
					Vector2(53.0, 18.4),
					Vector2(53.0, 27.0),
					Vector2(17.0, 27.0),
				]
			)
		)
	)
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_west_wrap",
			PackedVector2Array(
				[
					Vector2(15.2, 16.0),
					Vector2(17.2, 16.0),
					Vector2(17.2, 27.0),
					Vector2(15.2, 27.0),
				]
			)
		)
	)
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_street_front",
			PackedVector2Array(
				[
					Vector2(18.5, 26.6),
					Vector2(50.5, 26.6),
					Vector2(50.5, 31.2),
					Vector2(18.5, 31.2),
				]
			)
		)
	)
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_hq_side_alley",
			PackedVector2Array(
				[
					Vector2(53.15, 4.5),
					Vector2(57.75, 4.5),
					Vector2(57.75, 26.6),
					Vector2(53.15, 26.6),
				]
			)
		)
	)
