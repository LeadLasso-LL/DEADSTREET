extends RefCounted
## Stationary freight interchange. Ground-level crossings, no moving-train rules.
const Base=preload("res://battle/geometry/harold_street_catalog.gd")
const ID="freight_exchange_v1"
const SIZE=Vector2(164,76)
const ENTRANCE=Vector2(142,19.5)
const ARRIVAL=Rect2(2,4,45,68)
const DEFENDERS=Rect2(120,4,43,68)
const TRACKS=[26.,48.]
const CROSSINGS=[Rect2(33,19,8,35),Rect2(76,19,6,35),Rect2(113,19,5,35)]
static var _props: Array=[]
static func props() -> Array:
 if not _props.is_empty():return _props
 var rows=[
  ["dispatch",Rect2(126,4,35,14),"dispatch","EASTEX FREIGHT EXCHANGE"],
  ["west_store",Rect2(26,4,18,7),"shed","RECEIVING"],
  ["north_loading",Rect2(53,12,48,4),"platform","01"],
  ["south_loading",Rect2(58,57,46,4),"platform","02"],
  ["boxcar_01",Rect2(43,23.4,26,5.2),"boxcar","NBR 40821"],
  ["boxcar_02",Rect2(82,23.4,23,5.2),"boxcar","NBR 40736"],
  ["boxcar_03",Rect2(118,23.4,26,5.2),"boxcar","NBR 41008"],
  ["boxcar_04",Rect2(50,45.4,24,5.2),"boxcar","NBR 40519"],
  ["timber_05",Rect2(88,45.4,23,5.2),"timber_car","NBR 73204"],
  ["boxcar_06",Rect2(124,45.4,26,5.2),"boxcar","NBR 40192"],
 ]
 # Low cargo, reels and concrete stops create exposed firing positions in each lane.
 for spec in [[29,15,3.8,2.8,"crates"],[41,17,2.6,2.6,"reel"],[31,32,4,2.5,"barrier"],[42,37,3.8,2.8,"crates"],[30,46,2.6,2.6,"reel"],[40,53,3.8,2.8,"crates"],[29,63,4,2.5,"barrier"],[43,68,2.6,2.6,"reel"],[61,35,4,2.5,"barrier"],[94,37,3.8,2.8,"crates"],[110,11,2.6,2.6,"reel"],[107,63,4,2.5,"barrier"],[67,65,3.8,2.8,"crates"],[137,35,3.8,2.8,"crates"],[154,32,2.6,2.6,"reel"],[122,39,4,2.5,"barrier"],[151,55,3.8,2.8,"crates"],[136,63,4,2.5,"barrier"],[157,65,2.6,2.6,"reel"],[121,66,3.8,2.8,"crates"]]:
  rows.append(["cargo_%d_%d"%[spec[0],spec[1]],Rect2(spec[0],spec[1],spec[2],spec[3]),spec[4],""])
 _props=rows;return rows
static func build():
 var d=Base.Definition.new();d.definition_id=ID;d.width=SIZE.x;d.height=SIZE.y
 d.surfaces.append(Base.Surface.new("freight_concrete",Base.Surface.KIND_SIDEWALK,Rect2(Vector2.ZERO,SIZE)))
 d.surfaces.append(Base.Surface.new("west_service_road",Base.Surface.KIND_ASPHALT,Rect2(2,0,22,76)))
 d.surfaces.append(Base.Surface.new("south_service_road",Base.Surface.KIND_ASPHALT,Rect2(24,62,140,12)))
 for i in range(TRACKS.size()):d.surfaces.append(Base.Surface.new("ballast_%d"%i,Base.Surface.KIND_ALLEY,Rect2(24,TRACKS[i]-4,140,8)))
 for i in range(CROSSINGS.size()):d.surfaces.append(Base.Surface.new("crossing_%d"%i,Base.Surface.KIND_ASPHALT,CROSSINGS[i]))
 for row in props():
  d.obstacles.append(Base.Obstacle.new(row[0],row[1],true,row[2] in ["boxcar","timber_car","dispatch","shed"],row[2]))
 for row in props():
  if row[2] in ["dispatch","shed"]:continue
  var box: Rect2=row[1];var center=box.get_center();var cover_id="cover_"+str(row[0]);var points=[];var stand=1.35
  if row[2] in ["boxcar","timber_car"]:
   # Tall railcars only expose corner positions; no shooting through their bodies.
   for x in [box.position.x-.35,box.end.x+.35]:
    points.append([Vector2(x,box.position.y-stand),Vector2.DOWN]);points.append([Vector2(x,box.end.y+stand),Vector2.UP])
   for y in [box.position.y-.35,box.end.y+.35]:
    points.append([Vector2(box.position.x-stand,y),Vector2.RIGHT]);points.append([Vector2(box.end.x+stand,y),Vector2.LEFT])
  elif row[2]=="platform":
   for x in range(int(box.position.x)+3,int(box.end.x)-1,5):
    points.append([Vector2(x,box.position.y-stand),Vector2.DOWN]);points.append([Vector2(x,box.end.y+stand),Vector2.UP])
   points.append([Vector2(box.position.x-stand,center.y),Vector2.RIGHT]);points.append([Vector2(box.end.x+stand,center.y),Vector2.LEFT])
  else:
   points=[[Vector2(center.x,box.position.y-stand),Vector2.DOWN],[Vector2(center.x,box.end.y+stand),Vector2.UP],[Vector2(box.position.x-stand,center.y),Vector2.RIGHT],[Vector2(box.end.x+stand,center.y),Vector2.LEFT]]
  d.cover_objects.append(Base.Cover.new(cover_id,row[0]))
  for i in range(points.size()):
   var at: Vector2=points[i][0];var valid=Rect2(Vector2(.6,.6),SIZE-Vector2(1.2,1.2)).has_point(at)
   for obstacle in d.obstacles:
    if obstacle.bounds.grow(.45).has_point(at):valid=false;break
   for slot in d.cover_slots:
    if slot.position.distance_to(at)<2.4:valid=false;break
   if valid:d.cover_slots.append(Base.Slot.new(cover_id+"_%d"%i,cover_id,at,points[i][1]))
 d.attacker_deployment_area.add_pocket(Base.Pocket.new("west_receiving",Base.rect_points(ARRIVAL)))
 d.defender_deployment_area.add_pocket(Base.Pocket.new("east_dispatch",Base.rect_points(DEFENDERS)))
 d.attacker_vehicle_placement_context=Base.VehicleContext.new(false,Vector2(13,39),true,Vector2.UP)
 d.attacker_vehicle_placement_context.parking_clearance=1.52
 d.defender_vehicle_placement_context=Base.VehicleContext.new(false,Vector2(151,37),true,Vector2.LEFT)
 return d
