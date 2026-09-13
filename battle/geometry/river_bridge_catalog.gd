extends RefCounted
## First authored river crossing. The shared layout is reusable by later campaign encounters.
const Base=preload("res://battle/geometry/harold_street_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const ID="river_suspension_bridge_v1"
const SIZE=Vector2(180,58)
const ARRIVAL=Rect2(1,10,42,38)
const DEFENDERS=Rect2(140,10,39,38)
const LANES=[15.5,22.,35.,41.5]
const TOWERS=[60.,132.]
static var _props: Array=[]
static func props() -> Array:
 if not _props.is_empty():return _props
 var rows=[]
 for x in TOWERS:
  for y in [10.3,28.,47.7]:
   rows.append(["tower_%d_%d"%[x,y],Rect2(x-1.7,y-1.65,3.4,3.3),"tower",""])
 var choices=["civicline","bayou","crossway","aurelia","workhorse","rattleback","mistral","blackwater","courier","mesa","regent","shuttle","kensei","rancher","specter","shortbox"]
 # Queues follow their lanes, with staggered stopping gaps and occasional abandoned turns.
 var xs=[[49.,59.,70.,79.5,92.,102.,114.,124.,137.],[46.,56.,67.,78.,88.5,100.,111.,121.,135.],[48.,58.,68.5,81.,92.,102.,115.,126.,137.],[46.,58.,70.,80.,91.,104.,115.,127.,138.]]
 for lane in range(4):
  for index in range(xs[lane].size()):
   var key=choices[(index*3+lane*5)%choices.size()];var m=Models.model(key)
   var at=Vector2(xs[lane][index],float(LANES[lane])+[-.34,.18,.38,-.18][(index+lane)%4])
   var bounds=Rect2(at-Vector2(m.length,m.width)*.5,Vector2(m.length,m.width))
   rows.append(["traffic_%d_%d"%[lane,index],bounds,"traffic",key,Vector2.LEFT if lane<2 else Vector2.RIGHT])
 for x in [45.,87.,113.,145.]:
  rows.append(["median_cabinet_%d"%x,Rect2(x,27.,1.6,1.6),"cabinet",""])
 # Plain concrete traffic-control blocks supplement the defending convoy; pedestrians can pass.
 for y in [12.2,43.5]:rows.append(["checkpoint_block_%d"%y,Rect2(143.5,y,1.,2.4),"barrier",""])
 _props=rows
 return rows
static func build():
 var d=Base.Definition.new();d.definition_id=ID;d.width=SIZE.x;d.height=SIZE.y
 d.surfaces.append(Base.Surface.new("north_carriageway",Base.Surface.KIND_ASPHALT,Rect2(0,12,180,13)))
 d.surfaces.append(Base.Surface.new("south_carriageway",Base.Surface.KIND_ASPHALT,Rect2(0,31,180,13)))
 for spec in [["north_walk",Rect2(0,9,180,3)],["median_walk",Rect2(0,25,180,6)],["south_walk",Rect2(0,44,180,5)]]:
  d.surfaces.append(Base.Surface.new(spec[0],Base.Surface.KIND_SIDEWALK,spec[1]))
 d.obstacles.append(Base.Obstacle.new("river_north",Rect2(0,0,180,9),true,false,"boundary"))
 d.obstacles.append(Base.Obstacle.new("river_south",Rect2(0,49,180,9),true,false,"boundary"))
 for row in props():
  var tall=row[2] in ["tower","cabinet"] or (row[2]=="traffic" and float(Models.model(row[3]).height)>2.1)
  d.obstacles.append(Base.Obstacle.new(row[0],row[1],true,tall,row[2]))
 for row in props():
  var box: Rect2=row[1];var id="cover_"+row[0];d.cover_objects.append(Base.Cover.new(id,row[0]))
  var c=box.get_center()
  var points=[[Vector2(c.x,box.position.y-.85),Vector2.DOWN],[Vector2(c.x,box.end.y+.85),Vector2.UP],[Vector2(box.position.x-.85,c.y),Vector2.RIGHT],[Vector2(box.end.x+.85,c.y),Vector2.LEFT]]
  # Tall objects are used at corners, never as a waist-high firing rest.
  if row[2] in ["tower","cabinet"]:
   points[2][0].y=box.end.y-.1;points[3][0].y=box.position.y+.1
  for n in range(points.size()):
   var at: Vector2=points[n][0];var valid=true
   for obstacle in d.obstacles:
    if obstacle.bounds.grow(.32).has_point(at):valid=false;break
   if valid:d.cover_slots.append(Base.Slot.new(id+"_"+str(n),id,at,points[n][1]))
 d.attacker_deployment_area.add_pocket(Base.Pocket.new("west_approach",Base.rect_points(ARRIVAL)))
 d.defender_deployment_area.add_pocket(Base.Pocket.new("east_blockade",Base.rect_points(DEFENDERS)))
 d.attacker_vehicle_placement_context=Base.VehicleContext.new(false,ARRIVAL.get_center(),true,Vector2.RIGHT)
 d.defender_vehicle_placement_context=Base.VehicleContext.new(false,DEFENDERS.get_center(),true,Vector2.DOWN)
 return d
