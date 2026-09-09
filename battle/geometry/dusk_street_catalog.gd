extends RefCounted
const Definition = preload("res://battle/geometry/authored_battlefield_definition.gd")
const Obstacle = preload("res://battle/geometry/battle_obstacle.gd")
const Cover = preload("res://battle/geometry/battle_cover_object.gd")
const Slot = preload("res://battle/geometry/battle_cover_slot.gd")
const Surface = preload("res://battle/geometry/battle_surface_region.gd")
const Pocket = preload("res://battle/geometry/battle_deployment_pocket.gd")
const VehicleContext = preload("res://battle/vehicles/battle_vehicle_placement_context.gd")
const ID = "dead_street_dusk_v1"
const SIZE = Vector2(64,46)
# The same footprint data drives collision, cover and the painted scene.
static func props() -> Array:
	return [
		["pawn",Rect2(1,8.5,15,6.5),"building","PAWN & LOAN"],
		["club",Rect2(22,7,18,7),"building","THE SOCIAL CLUB"],
		["laundry",Rect2(48,8.5,15,6.5),"building","LAUNDROMAT"],
		["south_shop",Rect2(1,41,15,5),"building","AUTO REPAIR"],
		["south_shop2",Rect2(49,41,14,5),"building","NO VACANCY"],
		["club_wall_w",Rect2(23,17.6,6,0.7),"wall",""],
		["club_wall_e",Rect2(33,17.6,6,0.7),"wall",""],
		["defender_sedan",Rect2(39,21,5.5,2.5),"car",""],
		["pawn_dumpster",Rect2(12,19,3.3,1.7),"dumpster",""],
		["laundry_bins",Rect2(51,18,3.4,1.8),"dumpster",""],
		["west_sedan",Rect2(16,26,5.8,2.6),"car",""],
		["threshold_sedan",Rect2(28,32,5.8,2.6),"car",""],
		["delivery_van",Rect2(35,32.5,6,2.5),"van",""],
		["east_sedan",Rect2(44,29,5.8,2.6),"car",""],
		["west_pallets",Rect2(7,36,3.4,1.7),"crate",""],
		["east_pallets",Rect2(55,37,3.4,1.7),"crate",""],
		["west_service",Rect2(17.7,18,1.6,3),"utility",""],
		["east_service",Rect2(43,17,1.6,3),"utility",""],
		["alley_bins",Rect2(43,8,2.8,1.6),"dumpster",""],
		["arrival_planter",Rect2(22,38,3.4,0.9),"wall",""],
		["east_planter",Rect2(42,37.5,3.4,0.9),"wall",""]
	]
static func build():
	var d = Definition.new()
	d.definition_id = ID
	d.width = SIZE.x
	d.height = SIZE.y
	d.surfaces.append(Surface.new("main_road",Surface.KIND_ASPHALT,Rect2(0,23,64,12)))
	d.surfaces.append(Surface.new("north_walk",Surface.KIND_SIDEWALK,Rect2(0,15,64,8)))
	d.surfaces.append(Surface.new("south_walk",Surface.KIND_SIDEWALK,Rect2(0,35,64,6)))
	for row in props():
		var box: Rect2 = row[1]
		var hard: bool = row[2] == "building" or row[2] == "utility" or row[2] == "van"
		d.obstacles.append(Obstacle.new(row[0],box,true,hard,row[2]))
		if row[2] == "building": continue
		var cover_id: String = "cover_"+row[0]
		d.cover_objects.append(Cover.new(cover_id,row[0]))
		var center = box.get_center()
		var points = [
			[Vector2(center.x,box.position.y-0.85),Vector2.DOWN],
			[Vector2(center.x,box.end.y+0.85),Vector2.UP],
			[Vector2(box.position.x-0.85,center.y),Vector2.RIGHT],
			[Vector2(box.end.x+0.85,center.y),Vector2.LEFT]]
		for n in range(points.size()):
			d.cover_slots.append(Slot.new(cover_id+"_"+str(n),cover_id,points[n][0],points[n][1]))
	d.attacker_deployment_area.add_pocket(Pocket.new("arrival",rect_points(Rect2(19,36,28,7))))
	d.defender_deployment_area.add_pocket(Pocket.new("frontage",rect_points(Rect2(20,15,26,8))))
	d.defender_deployment_area.add_pocket(Pocket.new("east_watch",rect_points(Rect2(48,16,9,6))))
	d.attacker_vehicle_placement_context = VehicleContext.new(true,Vector2(35,39),true,Vector2.LEFT)
	return d
static func rect_points(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
