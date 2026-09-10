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
const SIZE = Vector2(64,46)
const OBJECTIVE_ENTRANCE = Vector2(25,15)
const DEFENDER_ZONE = Rect2(1,15,29,19)
const ARRIVAL_CENTER = Vector2(49,28)
# Authored positions for the following deployment milestone; not selectable yet.
const ARRIVAL_OPTIONS = {"close":{"center":Vector2(39,28),"radius":5.5},"medium":{"center":Vector2(49,28),"radius":6.5},"far":{"center":Vector2(57,28),"radius":7.0}}
static func props() -> Array:
	var rows: Array = [
		["mercer_market",Rect2(0,0,17,15),"building",STORE],
		["harold_apartments",Rect2(17,0,16,15),"building",OBJECTIVE],
		["east_apartments",Rect2(39,0,25,15),"building",""],
		["south_west",Rect2(0,41,21,5),"building",""],
		["south_middle",Rect2(21,41,22,5),"building",""],
		["south_east",Rect2(43,41,21,5),"building",""],
		["stoop_west",Rect2(22,15.4,.9,4.1),"stoop_wall",""],
		["stoop_east",Rect2(27.1,15.4,.9,4.1),"stoop_wall",""],
		["east_stoop_west",Rect2(48.8,15.4,.8,3.5),"stoop_wall",""],
		["east_stoop_east",Rect2(53.2,15.4,.8,3.5),"stoop_wall",""],
		["alley_dumpster",Rect2(34,10,3.3,1.8),"dumpster",""],
		["service_cabinet",Rect2(39.3,16,1.5,1.5),"utility",""],
		["store_delivery",Rect2(1,16.4,2.3,1.7),"crate",""],
		["alley_extent",Rect2(33,0,6,8),"boundary",""]
	]
	for i in range(6):
		var x: float = [2.,10.,19.,27.,43.,54.][i]
		rows.append(["north_car_"+str(i),Rect2(x,23.7,5.0+(i%3)*.15,2.1),"car",""])
	for i in range(6):
		var x: float = [3.,13.,23.,34.,44.,55.][i]
		rows.append(["south_car_"+str(i),Rect2(x,32.3,5.0+(i%3)*.15,2.1),"car",""])
	return rows
static func build():
	var d = Definition.new()
	d.definition_id=ID;d.width=SIZE.x;d.height=SIZE.y
	d.surfaces.append(Surface.new("main_road",Surface.KIND_ASPHALT,Rect2(0,23,64,12)))
	d.surfaces.append(Surface.new("north_walk",Surface.KIND_SIDEWALK,Rect2(0,15,64,8)))
	d.surfaces.append(Surface.new("south_walk",Surface.KIND_SIDEWALK,Rect2(0,35,64,6)))
	for row in props():
		var b: Rect2=row[1]
		var kind: String=row[2]
		d.obstacles.append(Obstacle.new(row[0],b,true,kind=="building" or kind=="utility",kind))
		if kind in ["building","boundary"]: continue
		var id: String="cover_"+row[0]
		d.cover_objects.append(Cover.new(id,row[0]))
		var center=b.get_center()
		var points=[[Vector2(center.x,b.position.y-.85),Vector2.DOWN],[Vector2(center.x,b.end.y+.85),Vector2.UP],[Vector2(b.position.x-.85,center.y),Vector2.RIGHT],[Vector2(b.end.x+.85,center.y),Vector2.LEFT]]
		for n in range(4):
			var point: Vector2=points[n][0]
			var blocked=false
			for other in props():
				if other[1].has_point(point): blocked=true;break
			if not blocked: d.cover_slots.append(Slot.new(id+"_"+str(n),id,point,points[n][1]))
	d.attacker_deployment_area.add_pocket(Pocket.new("arrival",rect_points(Rect2(41,24,20,10.8))))
	d.defender_deployment_area.add_pocket(Pocket.new("frontage",rect_points(DEFENDER_ZONE)))
	d.attacker_vehicle_placement_context=VehicleContext.new(true,ARRIVAL_CENTER,true,Vector2.LEFT)
	return d
static func rect_points(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
