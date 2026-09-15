extends RefCounted
## Doble Ocho: a working south-side garage, authored for six/seven a side.
const Base=preload("res://battle/geometry/harold_street_catalog.gd")
const Fleet=preload("res://battle/geometry/river_bridge_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const ID="doble_ocho_yard_v1"
const SIZE=Vector2(96,64)
const ENTRANCE=Vector2(76,22.2)
const ARRIVAL=Rect2(2,26,41,36)
const FLANK=Rect2(26,46,63,16)
const DEFENDERS=Rect2(43,19.5,50,24.5)
const STREET=Rect2(0,47,96,17)
static var _props: Array=[]
static func props() -> Array:
 if not _props.is_empty():return _props
 var rows=[
  ["main_garage",Rect2(62,5,34,16),"garage","DOBLE OCHO"],
  ["tire_shop",Rect2(30,5,23,14),"workshop","LLANTAS / SERVICIO"],
  ["north_fence",Rect2(26,5,70,.6),"fence",""],
  ["west_fence",Rect2(26,5,.7,21),"fence",""],
  ["west_gate_return",Rect2(26,40,.7,5),"fence",""],
  ["south_fence",Rect2(26,45,42,.7),"fence",""],
  ["south_fence_east",Rect2(82,45,14,.7),"fence",""],
  ["east_fence",Rect2(95.3,21,.7,24),"fence",""],
  ["main_gate_north_leaf",Rect2(26.7,25.2,6,.6),"gate",""],
  ["main_gate_south_leaf",Rect2(26.7,40,5.5,.6),"gate",""],
  ["service_gate_west_leaf",Rect2(67.4,45.7,.6,5),"gate",""],
  ["service_gate_east_leaf",Rect2(82,45.7,.6,5),"gate",""],
  ["parts_container",Rect2(49,25,4.4,10.5),"container","PARTS"],
  ["west_tires",Rect2(42,28,3.0,2.4),"tires",""],
  ["gate_tires",Rect2(32.5,24.7,3.2,2.6),"tires",""],
  ["service_tires",Rect2(65,40,3,2.6),"tires",""],
  ["north_compressor",Rect2(55.7,13,3.2,3.2),"compressor",""],
  ["north_parts",Rect2(57,20,2.8,2.5),"pallets",""],
  ["east_parts",Rect2(71,31,3.4,2.5),"pallets",""],
  ["shop_drums",Rect2(44.5,20.7,2.7,2.2),"drums",""],
  ["south_drums",Rect2(77,40,2.7,2.2),"drums",""],
  ["street_dumpster",Rect2(17,40.8,4.5,2.8),"dumpster",""],
  ["east_dumpster",Rect2(89,25.5,4.1,2.8),"dumpster",""],
  ["west_bollard",Rect2(23.5,24.7,.65,.65),"bollard",""],
  ["west_bollard_s",Rect2(23.5,41,.65,.65),"bollard",""],
 ]
 for spec in [[39.,21.8,"rattleback",Vector2.RIGHT],[59.,27.5,"courier",Vector2.LEFT],[79.,25.7,"cabrillo",Vector2.LEFT],[88.,38.,"workhorse",Vector2.UP],[39.,38.,"bayou",Vector2.RIGHT],[56.,40.5,"rattleback",Vector2.LEFT]]:
  var at=Vector2(spec[0],spec[1]);rows.append(["parked_%d_%d"%[spec[0],spec[1]],Fleet.traffic_bounds(at,spec[2],spec[3]),"traffic",spec[2],spec[3],0.])
 _props=rows;return rows
static func build():
 var d=Base.Definition.new();d.definition_id=ID;d.width=SIZE.x;d.height=SIZE.y
 d.surfaces.append(Base.Surface.new("southside_road",Base.Surface.KIND_ASPHALT,STREET))
 d.surfaces.append(Base.Surface.new("west_access",Base.Surface.KIND_ASPHALT,Rect2(2,0,22,47)))
 d.surfaces.append(Base.Surface.new("yard_concrete",Base.Surface.KIND_SIDEWALK,Rect2(27,5,68,40)))
 d.surfaces.append(Base.Surface.new("service_apron",Base.Surface.KIND_ALLEY,Rect2(68,42,14,7)))
 d.obstacles.append(Base.Obstacle.new("north_limit",Rect2(0,0,96,3),true,false,"boundary"))
 for row in props():
  var tall=row[2] in ["garage","workshop","container","compressor"]
  var boxes=Fleet.traffic_footprints(row) if row[2]=="traffic" else [row[1]]
  for i in range(boxes.size()):
   var box: Rect2=boxes[i].intersection(Rect2(Vector2.ZERO,SIZE))
   if box.has_area():d.obstacles.append(Base.Obstacle.new(row[0]+("_part_%d"%i if i else ""),box,true,tall,row[2]))
 for row in props():
  if row[2] in ["garage","workshop","north_fence","bollard","gate"] or row[0] in ["north_fence","east_fence"]:continue
  var box: Rect2=row[1];var c=box.get_center();var id="cover_"+row[0]
  var points=[];var stand=1.35
  if row[2] in ["container","compressor"]:
   # Solid cover is usable at exposed corners, never a blind midpoint firing rest.
   for y in [box.position.y-.35,box.end.y+.35]:
    points.append([Vector2(box.position.x-stand,y),Vector2.RIGHT])
    points.append([Vector2(box.end.x+stand,y),Vector2.LEFT])
  else:
   points=[[Vector2(c.x,box.position.y-stand),Vector2.DOWN],[Vector2(c.x,box.end.y+stand),Vector2.UP],[Vector2(box.position.x-stand,c.y),Vector2.RIGHT],[Vector2(box.end.x+stand,c.y),Vector2.LEFT]]
   if row[2]=="traffic":
    var f: Vector2=row[4];var side=Vector2(-f.y,f.x);var m=Models.model(row[3])
    points=[[c+side*(float(m.width)*Models.TACTICAL_SCALE*.5+stand),-side],[c-side*(float(m.width)*Models.TACTICAL_SCALE*.5+stand),side],[c+f*(float(m.length)*Models.TACTICAL_SCALE*.5+stand),-f],[c-f*(float(m.length)*Models.TACTICAL_SCALE*.5+stand),f]]
   if row[2]=="fence":
    if box.size.x>6:
     for x in range(int(box.position.x)+3,int(box.end.x)-1,5):
      points.append([Vector2(x,box.position.y-stand),Vector2.DOWN]);points.append([Vector2(x,box.end.y+stand),Vector2.UP])
    if box.size.y>6:
     for y in range(int(box.position.y)+3,int(box.end.y)-1,5):
      points.append([Vector2(box.position.x-stand,y),Vector2.RIGHT]);points.append([Vector2(box.end.x+stand,y),Vector2.LEFT])
  d.cover_objects.append(Base.Cover.new(id,row[0]))
  for i in range(points.size()):
   var at: Vector2=points[i][0];var valid=Rect2(Vector2(.6,3.6),SIZE-Vector2(1.2,4.2)).has_point(at)
   for obstacle in d.obstacles:
    if obstacle.bounds.grow(.45).has_point(at):valid=false;break
   for slot in d.cover_slots:
    if slot.position.distance_to(at)<2.4:valid=false;break
   if valid:d.cover_slots.append(Base.Slot.new(id+"_%d"%i,id,at,points[i][1]))
 d.attacker_deployment_area.add_pocket(Base.Pocket.new("main_gate_approach",Base.rect_points(ARRIVAL)))
 d.attacker_deployment_area.add_pocket(Base.Pocket.new("service_gate_approach",Base.rect_points(FLANK)))
 d.defender_deployment_area.add_pocket(Base.Pocket.new("garage_defense",Base.rect_points(DEFENDERS)))
 d.attacker_vehicle_placement_context=Base.VehicleContext.new(false,Vector2(27,36),true,Vector2.RIGHT)
 d.attacker_vehicle_placement_context.parking_clearance=1.52
 d.defender_vehicle_placement_context=Base.VehicleContext.new(false,Vector2(75,32),true,Vector2.LEFT)
 return d
