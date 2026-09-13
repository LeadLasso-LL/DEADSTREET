extends RefCounted
## First authored river crossing. The shared layout is reusable by later campaign encounters.
const Base=preload("res://battle/geometry/harold_street_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const ID="river_suspension_bridge_v1"
const SIZE=Vector2(180,58)
const ARRIVAL=Rect2(1,10,42,38)
const DEFENDERS=Rect2(140,10,39,38)
const LANES=[15.5,22.,35.,41.5]
const TRAFFIC_SCALE=1.6
const TOWERS=[60.,132.]
const MEDIAN_SEGMENTS=[[46.,56.],[65.,77.],[83.,95.],[101.,112.],[118.,127.],[137.,142.]]
static var _props: Array=[]
static func props() -> Array:
 if not _props.is_empty():return _props
 var rows=[]
 for x in TOWERS:
  for y in [10.3,28.,47.7]:
   rows.append(["tower_%d_%d"%[x,y],Rect2(x-1.7,y-1.65,3.4,3.3),"tower",""])
 var choices=["civicline","bayou","crossway","aurelia","workhorse","rattleback","mistral","blackwater","courier","mesa","regent","shuttle","kensei","rancher","specter","shortbox"]
 # Upper carriageway runs west; lower runs east. Cars between the two
 # stoppages were abandoned when the attackers arrived, including cars which
 # had already passed the eastern checkpoint. These are stationary props.
 var xs=[[49.,59.,70.,80.,92.,102.,114.,124.,137.],[46.,56.,67.,78.,88.5,100.,111.,121.,135.],[48.,58.,68.5,81.,92.,102.,115.,126.,137.],[46.,58.,70.,80.,91.,104.,115.,127.,138.]]
 var previous={}
 for lane in range(4):
  for index in range(xs[lane].size()):
   var key=choices[(index*3+lane*5)%choices.size()]
   var at=Vector2(xs[lane][index],float(LANES[lane])+[-.34,.18,.38,-.18][(index+lane)%4])
   var facing=Vector2.LEFT if lane<2 else Vector2.RIGHT
   # A few clear abandoned swerves, not every vehicle rotated identically.
   if [Vector2i(0,5),Vector2i(1,3),Vector2i(2,5),Vector2i(3,2),Vector2i(3,7)].has(Vector2i(lane,index)):
    key="civicline" if index%2==0 else "mistral"
    facing=Vector2(-1,1).normalized() if lane<2 else Vector2(1,-1).normalized()
   var m=Models.model(key)
   # Bumper contacts make continuous longer cover: two upper-lane pileups
   # and a rear-end collision on the eastbound carriageway.
   if [Vector2i(0,3),Vector2i(1,7),Vector2i(2,3)].has(Vector2i(lane,index)):
    var front=previous[lane];var fm=Models.model(front[3])
    at=front[1].get_center()+Vector2((float(m.length)+float(fm.length))*TRAFFIC_SCALE*.5-.12,0)
   var open=1. if (index+lane)%3!=0 else .5
   var row=["traffic_%d_%d"%[lane,index],traffic_bounds(at,key,facing),"traffic",key,facing,open]
   rows.append(row);previous[lane]=row
 # Westbound queue BEHIND the checkpoint, still facing left. The midspan
 # vehicles are therefore distinct from the original stopped inbound queue.
 for spec in [[161.,15.5,"bayou"],[174.,15.5,"civicline"],[168.,22.,"crossway"]]:
  var at=Vector2(spec[0],spec[1])
  rows.append(["traffic_east_%d"%spec[0],traffic_bounds(at,spec[2],Vector2.LEFT),"traffic",spec[2],Vector2.LEFT,1.])
 for x in [45.,87.,113.,145.]:
  rows.append(["median_cabinet_%d"%x,Rect2(x,27.,1.6,1.6),"cabinet",""])
 # Segmented concrete median: common render, collision and cover footprints.
 for i in range(MEDIAN_SEGMENTS.size()):
  var span=MEDIAN_SEGMENTS[i]
  rows.append(["median_divider_%d"%i,Rect2(span[0],29.,span[1]-span[0],1.),"divider",""])
 # The road is visibly closed at the eastern defending position. Infantry gaps
 # remain between staggered concrete sections; selected defender vehicles sit behind.
 for spec in [[12.,16.8],[20.,25.],[31.,35.8],[39.,44.]]:
  rows.append(["checkpoint_block_%d"%spec[0],Rect2(146.,spec[0],1.3,spec[1]-spec[0]),"barrier",""])
 rows.append(["checkpoint_sign",Rect2(147.7,25.5,1.2,1.3),"checkpoint_sign",""])
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
  var footprints=traffic_footprints(row) if row[2]=="traffic" else [row[1]]
  for part in range(footprints.size()):
   var obstacle_id=row[0] if part==0 else row[0]+"_body_"+str(part)
   d.obstacles.append(Base.Obstacle.new(obstacle_id,footprints[part],true,tall,row[2]))
 for row in props():
  var box: Rect2=row[1];var id="cover_"+row[0];d.cover_objects.append(Base.Cover.new(id,row[0]))
  var c=box.get_center()
  var points=[[Vector2(c.x,box.position.y-.85),Vector2.DOWN],[Vector2(c.x,box.end.y+.85),Vector2.UP],[Vector2(box.position.x-.85,c.y),Vector2.RIGHT],[Vector2(box.end.x+.85,c.y),Vector2.LEFT]]
  if row[2]=="traffic":
   var facing: Vector2=row[4];var side=Vector2(-facing.y,facing.x);var m=Models.model(row[3])
   points=[[c+side*(float(m.width)*TRAFFIC_SCALE*.5+.85),-side],[c-side*(float(m.width)*TRAFFIC_SCALE*.5+.85),side],[c+facing*(float(m.length)*TRAFFIC_SCALE*.5+.85),-facing],[c-facing*(float(m.length)*TRAFFIC_SCALE*.5+.85),facing]]
  if row[2]=="divider":
   # Multiple firing positions along the long faces, with end cover at each gap.
   for x in range(int(box.position.x)+2,int(box.end.x)-1,3):
    points.append([Vector2(x,box.position.y-.85),Vector2.DOWN])
    points.append([Vector2(x,box.end.y+.85),Vector2.UP])
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

static func traffic_bounds(at: Vector2,key: String,facing: Vector2) -> Rect2:
 var m=Models.model(key);var side=Vector2(-facing.y,facing.x)
 var extent=facing.abs()*float(m.length)*TRAFFIC_SCALE*.5+side.abs()*float(m.width)*TRAFFIC_SCALE*.5
 return Rect2(at-extent,extent*2.)

static func traffic_footprints(row: Array) -> Array:
 var f: Vector2=row[4]
 if is_zero_approx(f.y):return [row[1]]
 var m=Models.model(row[3]);var at: Vector2=row[1].get_center();var side=Vector2(-f.y,f.x)
 var span=float(m.length)*TRAFFIC_SCALE/4.;var extent=f.abs()*span*.5+side.abs()*float(m.width)*TRAFFIC_SCALE*.5
 var boxes=[]
 for i in range(4):
  var center=at+f*(-float(m.length)*TRAFFIC_SCALE*.5+span*(i+.5))
  boxes.append(Rect2(center-extent,extent*2.))
 return boxes
