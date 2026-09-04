class_name TacticalProvingGroundCatalog
extends RefCounted

# Authored west-to-east commercial / light-industrial proving ground.
# Testing environment, not campaign-map localization.
# Coordinates are tactical battlefield units on a 100 x 60 field.

const AuthoredBattlefieldDefinition := preload("res://battle/geometry/authored_battlefield_definition.gd")
const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleSurfaceRegion := preload("res://battle/geometry/battle_surface_region.gd")
const BattlePresentationMarking := preload("res://battle/geometry/battle_presentation_marking.gd")
const BattleDeploymentPocket := preload("res://battle/geometry/battle_deployment_pocket.gd")
const BattleVehiclePlacementContext := preload("res://battle/vehicles/battle_vehicle_placement_context.gd")

const LAYOUT_ID := "west_east_commercial_block_v2"
const WIDTH := 100.0
const HEIGHT := 60.0

const MAIN_ROAD := Rect2(0.0, 24.0, 100.0, 12.0)
const NORTH_SIDEWALK := Rect2(0.0, 20.0, 100.0, 4.0)
const SOUTH_SIDEWALK := Rect2(0.0, 36.0, 100.0, 4.0)
const ALLEY_MOUTH := Rect2(52.0, 36.0, 8.0, 4.0)
const ALLEY_SURFACE := Rect2(48.0, 40.0, 26.0, 20.0)
const NW_SHOP_BOUNDS := Rect2(1.0, 1.0, 16.0, 18.0)
const MID_NORTH_SHOP_BOUNDS := Rect2(30.0, 1.0, 20.0, 18.0)
const WAREHOUSE_BOUNDS := Rect2(66.0, 1.0, 32.0, 18.0)
const SW_SHOP_BOUNDS := Rect2(1.0, 42.0, 15.0, 17.0)
const SOUTH_MID_BOUNDS := Rect2(28.0, 44.0, 20.0, 15.0)
const EAST_SHOP_BOUNDS := Rect2(74.0, 42.0, 24.0, 17.0)

const ATTACKER_VEHICLE_ANCHOR := Vector2(8.0, 27.2)
const ATTACKER_VEHICLE_HEADING := Vector2.RIGHT


static func west_east_commercial_block_v2() -> AuthoredBattlefieldDefinition:
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
		BattleSurfaceRegion.new("lot_west_north", BattleSurfaceRegion.KIND_LOT, Rect2(17.0, 0.0, 13.0, 20.0))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("lot_east_north", BattleSurfaceRegion.KIND_LOT, Rect2(50.0, 0.0, 16.0, 20.0))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("lot_west_south", BattleSurfaceRegion.KIND_LOT, Rect2(16.0, 40.0, 12.0, 20.0))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("lot_east_south", BattleSurfaceRegion.KIND_LOT, Rect2(74.0, 40.0, 26.0, 2.0))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("alley_service", BattleSurfaceRegion.KIND_ALLEY, ALLEY_SURFACE)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("road_main", BattleSurfaceRegion.KIND_ASPHALT, MAIN_ROAD)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("road_alley_mouth", BattleSurfaceRegion.KIND_ASPHALT, ALLEY_MOUTH)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("sidewalk_north", BattleSurfaceRegion.KIND_SIDEWALK, NORTH_SIDEWALK)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("sidewalk_south", BattleSurfaceRegion.KIND_SIDEWALK, SOUTH_SIDEWALK)
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("curb_north", BattleSurfaceRegion.KIND_CURB, Rect2(0.0, 23.5, 100.0, 0.5))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("curb_south_west", BattleSurfaceRegion.KIND_CURB, Rect2(0.0, 36.0, 52.0, 0.5))
	)
	definition.surfaces.append(
		BattleSurfaceRegion.new("curb_south_east", BattleSurfaceRegion.KIND_CURB, Rect2(60.0, 36.0, 40.0, 0.5))
	)


static func _add_presentation_markings(definition: AuthoredBattlefieldDefinition) -> void:
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"lane_main",
			BattlePresentationMarking.KIND_LANE,
			Rect2(2.0, 29.86, 96.0, 0.28)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"stop_bar_alley",
			BattlePresentationMarking.KIND_STOP_BAR,
			Rect2(52.2, 36.05, 7.6, 0.32)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"parking_east_lot_a",
			BattlePresentationMarking.KIND_PARKING,
			Rect2(52.0, 6.0, 10.0, 0.16)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"parking_east_lot_b",
			BattlePresentationMarking.KIND_PARKING,
			Rect2(52.0, 8.4, 10.0, 0.16)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"parking_west_lot_a",
			BattlePresentationMarking.KIND_PARKING,
			Rect2(18.0, 6.0, 8.0, 0.16)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"loading_warehouse",
			BattlePresentationMarking.KIND_LOADING,
			Rect2(72.0, 19.15, 14.0, 0.28)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"loading_delivery_north",
			BattlePresentationMarking.KIND_LOADING,
			Rect2(51.6, 23.85, 6.2, 0.22)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"seam_south_west",
			BattlePresentationMarking.KIND_SEAM,
			Rect2(8.0, 36.15, 0.12, 3.7)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"bollard_alley_west",
			BattlePresentationMarking.KIND_BOLLARD,
			Rect2(51.7, 35.7, 0.28, 0.28)
		)
	)
	definition.presentation_markings.append(
		BattlePresentationMarking.new(
			"bollard_alley_east",
			BattlePresentationMarking.KIND_BOLLARD,
			Rect2(59.95, 35.7, 0.28, 0.28)
		)
	)


static func _add_hard_structures(definition: AuthoredBattlefieldDefinition) -> void:
	definition.obstacles.append(
		BattleObstacle.new("building_nw_shop", NW_SHOP_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_mid_north_shop", MID_NORTH_SHOP_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_warehouse", WAREHOUSE_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_sw_shop", SW_SHOP_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_south_mid", SOUTH_MID_BOUNDS, true, true, "building")
	)
	definition.obstacles.append(
		BattleObstacle.new("building_east_shop", EAST_SHOP_BOUNDS, true, true, "building")
	)


static func _add_soft_cover(definition: AuthoredBattlefieldDefinition) -> void:
	definition.obstacles.append(
		BattleObstacle.new("parked_car_west_north", Rect2(22.0, 21.8, 4.2, 1.8), true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_mid_south", Rect2(42.0, 36.4, 4.2, 1.8), true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_car_east_north", Rect2(78.0, 21.8, 4.2, 1.8), true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("parked_van_east_street", Rect2(88.0, 25.2, 1.8, 4.2), true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("dumpster_north_lot", Rect2(56.5, 11.5, 2.2, 1.6), true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("dumpster_alley", Rect2(58.0, 48.0, 2.2, 1.6), true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("corner_stub_warehouse", Rect2(65.4, 19.0, 0.7, 4.2), true, false, "low_wall")
	)
	definition.obstacles.append(
		BattleObstacle.new("barrier_street_north_lane", Rect2(38.0, 26.6, 0.8, 3.0), true, false, "barrier")
	)
	definition.obstacles.append(
		BattleObstacle.new("delivery_van_mid_north", Rect2(52.1, 21.6, 5.4, 2.1), true, false, "parked_car")
	)
	definition.obstacles.append(
		BattleObstacle.new("dumpster_south_curb", Rect2(70.3, 36.35, 2.2, 1.65), true, false, "dumpster")
	)
	definition.obstacles.append(
		BattleObstacle.new("barrier_street_south_close", Rect2(77.4, 32.0, 0.85, 2.4), true, false, "barrier")
	)
	_add_cover_object(
		definition,
		"cover_parked_car_west_north",
		"parked_car_west_north",
		[
			["cover_parked_car_west_north_west", Vector2(21.2, 22.7), Vector2.RIGHT],
			["cover_parked_car_west_north_east", Vector2(27.0, 22.7), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_mid_south",
		"parked_car_mid_south",
		[
			["cover_parked_car_mid_south_west", Vector2(41.2, 37.3), Vector2.RIGHT],
			["cover_parked_car_mid_south_east", Vector2(47.0, 37.3), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_car_east_north",
		"parked_car_east_north",
		[
			["cover_parked_car_east_north_east", Vector2(83.0, 22.7), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_parked_van_east_street",
		"parked_van_east_street",
		[
			["cover_parked_van_east_street_east", Vector2(91.0, 27.5), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_dumpster_north_lot",
		"dumpster_north_lot",
		[
			["cover_dumpster_north_lot_east", Vector2(59.5, 12.3), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_dumpster_alley",
		"dumpster_alley",
		[
			["cover_dumpster_alley_east", Vector2(61.0, 48.8), Vector2.LEFT],
			["cover_dumpster_alley_north", Vector2(59.1, 46.8), Vector2.UP],
		]
	)
	_add_cover_object(
		definition,
		"cover_corner_stub_warehouse",
		"corner_stub_warehouse",
		[
			["cover_corner_stub_warehouse_west", Vector2(64.6, 21.4), Vector2.RIGHT],
			["cover_corner_stub_warehouse_east", Vector2(67.2, 21.4), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_barrier_street_north_lane",
		"barrier_street_north_lane",
		[
			["cover_barrier_street_north_lane_west", Vector2(36.6, 28.2), Vector2.RIGHT],
			["cover_barrier_street_north_lane_east", Vector2(39.6, 28.2), Vector2.LEFT],
		]
	)
	_add_cover_object(
		definition,
		"cover_delivery_van_mid_north",
		"delivery_van_mid_north",
		[
			["cover_delivery_van_mid_north_west", Vector2(51.3, 22.65), Vector2.RIGHT],
		]
	)
	_add_cover_object(
		definition,
		"cover_dumpster_south_curb",
		"dumpster_south_curb",
		[
			["cover_dumpster_south_curb_west", Vector2(69.5, 37.15), Vector2.RIGHT],
		]
	)
	_add_cover_object(
		definition,
		"cover_barrier_street_south_close",
		"barrier_street_south_close",
		[
			["cover_barrier_street_south_close_west", Vector2(76.55, 33.2), Vector2.RIGHT],
		]
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
	# West street mouth. Includes the existing HTTB legal point (7.25, 31.5).
	definition.attacker_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"attacker_street_mouth",
			PackedVector2Array(
				[
					Vector2(0.0, 24.0),
					Vector2(16.0, 24.0),
					Vector2(16.0, 36.0),
					Vector2(0.0, 36.0),
				]
			)
		)
	)
	definition.attacker_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"attacker_north_sidewalk",
			PackedVector2Array(
				[
					Vector2(0.0, 20.0),
					Vector2(18.5, 20.0),
					Vector2(18.5, 24.25),
					Vector2(0.0, 24.25),
				]
			)
		)
	)
	definition.attacker_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"attacker_south_sidewalk",
			PackedVector2Array(
				[
					Vector2(0.0, 36.0),
					Vector2(18.0, 36.0),
					Vector2(18.0, 41.5),
					Vector2(0.0, 41.5),
				]
			)
		)
	)


static func _add_defender_pockets(definition: AuthoredBattlefieldDefinition) -> void:
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_street_mouth",
			PackedVector2Array(
				[
					Vector2(82.0, 24.0),
					Vector2(100.0, 24.0),
					Vector2(100.0, 36.0),
					Vector2(82.0, 36.0),
				]
			)
		)
	)
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_north_sidewalk",
			PackedVector2Array(
				[
					Vector2(66.0, 19.4),
					Vector2(92.0, 19.4),
					Vector2(92.0, 24.0),
					Vector2(66.0, 24.0),
				]
			)
		)
	)
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_north_lot",
			PackedVector2Array(
				[
					Vector2(51.0, 4.0),
					Vector2(65.5, 4.0),
					Vector2(65.5, 19.0),
					Vector2(51.0, 19.0),
				]
			)
		)
	)
	definition.defender_deployment_area.add_pocket(
		BattleDeploymentPocket.new(
			"defender_alley",
			PackedVector2Array(
				[
					Vector2(49.0, 40.5),
					Vector2(72.0, 40.5),
					Vector2(72.0, 58.0),
					Vector2(49.0, 58.0),
				]
			)
		)
	)
