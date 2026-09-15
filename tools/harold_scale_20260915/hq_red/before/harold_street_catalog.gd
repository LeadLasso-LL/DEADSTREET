extends RefCounted
const Definition = preload("res://battle/geometry/authored_battlefield_definition.gd")
const Obstacle = preload("res://battle/geometry/battle_obstacle.gd")
const Cover = preload("res://battle/geometry/battle_cover_object.gd")
const Slot = preload("res://battle/geometry/battle_cover_slot.gd")
const Surface = preload("res://battle/geometry/battle_surface_region.gd")
const Pocket = preload("res://battle/geometry/battle_deployment_pocket.gd")
const VehicleContext = preload("res://battle/vehicles/battle_vehicle_placement_context.gd")
# Keep the existing runtime binding; location identity is explicit and reusable.
const ID = "dead_street_dusk_v1"
const Location = preload("res://world/harold_location.gd")
const NEIGHBORHOOD = Location.NEIGHBORHOOD
const STREET = Location.STREET
const OBJECTIVE = Location.OBJECTIVE
const STORE = Location.STORE
# The same scale controls parked traffic art and its physical cover footprint.
const VehicleModels = preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const ROAD = Rect2(0,23,64,20)
const SOUTH_SHIFT = ROAD.size.y-12.0
const VEHICLE_CLEARANCE = 0.95*VehicleModels.TACTICAL_SCALE
const SIZE = Vector2(64,46+SOUTH_SHIFT)
# Poor-neighborhood transport with one conspicuous Volta GT outside the HQ steps.
const PARKED_CARS = [["north_car_0", "rattleback", 1.0], ["north_car_1", "bayou", 8.8], ["north_car_2", "volta", 20.3], ["north_car_3", "rancher", 29.6], ["north_car_4", "bayou", 40.5], ["north_car_5", "courier", 54.0], ["south_car_0", "bayou", 1.8], ["south_car_1", "workhorse", 12.1], ["south_car_2", "rattleback", 22.4], ["south_car_3", "bayou", 32.7], ["south_car_4", "civicline", 43.0], ["south_car_5", "rattleback", 53.3]]
const ARRIVAL_BAND = Vector2(ROAD.position.y+1.0,ROAD.size.y-1.2)
const OBJECTIVE_ENTRANCE = Vector2(25,15)
const DEFENDER_ZONE = Rect2(1,15,29,19+SOUTH_SHIFT)
const ARRIVAL_CENTER = Vector2(49,ROAD.position.y+ROAD.size.y*.5)
# Shared lamp anchors keep the light pool and the post together, just inside each curb.
const STREET_LIGHTS = [[Vector2(6,22.4),1.1],[Vector2(29,22.4),1.0],[Vector2(54,22.4),1.1],[Vector2(17,35.6+SOUTH_SHIFT),.8],[Vector2(45,35.6+SOUTH_SHIFT),.8]]
# All arrival choices share the widened street center and legal road band.
const ARRIVAL_OPTIONS = {"close":{"center":Vector2(39,ROAD.position.y+ROAD.size.y*.5),"radius":5.5},"medium":{"center":Vector2(49,ROAD.position.y+ROAD.size.y*.5),"radius":6.5},"far":{"center":Vector2(57,ROAD.position.y+ROAD.size.y*.5),"radius":7.0}}
static func props() -> Array:
	var rows: Array = [
		["mercer_market",Rect2(0,0,17,15),"building",STORE],
		["harold_apartments",Rect2(17,0,16,15),"building",OBJECTIVE],
		["east_apartments",Rect2(39,0,25,15),"building",""],
		["south_west",Rect2(0,41+SOUTH_SHIFT,21,5),"building",""],
		["south_middle",Rect2(21,41+SOUTH_SHIFT,22,5),"building",""],
		["south_east",Rect2(43,41+SOUTH_SHIFT,21,5),"building",""],
		["stoop_west",Rect2(22,15,.9,4.5),"stoop_wall",""],
		["stoop_east",Rect2(27.1,15,.9,4.5),"stoop_wall",""],
		["east_stoop_west",Rect2(48.8,15,.8,3.9),"stoop_wall",""],
		["east_stoop_east",Rect2(53.2,15,.8,3.9),"stoop_wall",""],
		["alley_dumpster",Rect2(34,10,3.3,1.8),"dumpster",""],
		["service_cabinet",Rect2(39.3,16,1.5,1.5),"utility",""],
		["store_delivery",Rect2(1,16.4,2.3,1.7),"crate",""],
		["north_bin_west",Rect2(16.2,21.55,1.15,1.05),"trash_can",""],
		["north_bin_spilled",Rect2(18.8,21.05,1.65,.95),"trash_can_fallen",""],
		["north_bin_east",Rect2(40.5,21.55,1.15,1.05),"trash_can",""],
		["south_bin_west",Rect2(9.5,35.7+SOUTH_SHIFT,1.15,1.05),"trash_can",""],
		["south_bin_spilled",Rect2(12,36.5+SOUTH_SHIFT,1.65,.95),"trash_can_fallen",""],
		["south_bin_east",Rect2(38.9,36+SOUTH_SHIFT,1.15,1.05),"trash_can",""],
		["alley_extent",Rect2(33,0,6,8),"boundary",""]
	]
	for spec in PARKED_CARS:
		var model = VehicleModels.model(spec[1])
		var size = Vector2(float(model.length),float(model.width))*VehicleModels.TACTICAL_SCALE
		var north = str(spec[0]).begins_with("north")
		var y = ROAD.position.y+.7 if north else ROAD.end.y-.6-size.y
		rows.append([spec[0],Rect2(Vector2(spec[2],y),size),"car","",spec[1]])
	return rows
static func build():
	var d = Definition.new()
	d.definition_id=ID;d.width=SIZE.x;d.height=SIZE.y
	d.surfaces.append(Surface.new("main_road",Surface.KIND_ASPHALT,ROAD))
	d.surfaces.append(Surface.new("north_walk",Surface.KIND_SIDEWALK,Rect2(0,15,64,8)))
	d.surfaces.append(Surface.new("south_walk",Surface.KIND_SIDEWALK,Rect2(0,ROAD.end.y,64,6)))
	for row in props():
		var b: Rect2=row[1]
		var kind: String=row[2]
		d.obstacles.append(Obstacle.new(row[0],b,true,kind in ["building","utility","stoop_wall"],kind))
		if kind in ["building","boundary"]: continue
		var id: String="cover_"+row[0]
		d.cover_objects.append(Cover.new(id,row[0]))
		var center=b.get_center()
		var points=[[Vector2(center.x,b.position.y-.85),Vector2.DOWN],[Vector2(center.x,b.end.y+.85),Vector2.UP],[Vector2(b.position.x-.85,center.y),Vector2.RIGHT],[Vector2(b.end.x+.85,center.y),Vector2.LEFT]]
		if kind=="stoop_wall":
			# Tall wall side cover belongs at its open corners, where a unit can aim around the end.
			# Mid-wall slots imply the over-top firing available on low cover such as cars.
			points[2][0].y=b.end.y-.15
			points[3][0].y=b.end.y-.15
		for n in range(4):
			var point: Vector2=points[n][0]
			var blocked=false
			for other in props():
				if other[1].has_point(point): blocked=true;break
			if not blocked: d.cover_slots.append(Slot.new(id+"_"+str(n),id,point,points[n][1]))
	d.attacker_deployment_area.add_pocket(Pocket.new("arrival",rect_points(Rect2(31,ARRIVAL_BAND.x,33,ARRIVAL_BAND.y))))
	d.defender_deployment_area.add_pocket(Pocket.new("frontage",rect_points(DEFENDER_ZONE)))
	d.attacker_vehicle_placement_context=VehicleContext.new(true,ARRIVAL_CENTER,true,Vector2.LEFT)
	d.attacker_vehicle_placement_context.parking_clearance=VEHICLE_CLEARANCE
	return d
static func rect_points(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
