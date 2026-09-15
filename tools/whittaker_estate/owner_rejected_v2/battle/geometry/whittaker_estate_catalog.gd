extends RefCounted
## Authored estate: one footprint source for scenery, movement, fire and cover.
const Base=preload("res://battle/geometry/harold_street_catalog.gd")
const Fleet=preload("res://battle/geometry/river_bridge_catalog.gd")
const ID="whittaker_estate_v1"
const SIZE=Vector2(176,106)
const ARRIVAL=Rect2(19,36,26,51)
const DEFENDERS=Rect2(53,21,76,75)
const HOUSE=Rect2(139,33,31,49)
const ENTRANCE=Vector2(135.78,55.40)
const FOUNTAIN=Vector2(108,66)
static var _props: Array=[]
static func props() -> Array:
 if not _props.is_empty():return _props
 var rows=[]
 rows.append(["estate_house",HOUSE,"house",""])
 rows.append(["north_wing",Rect2(151,21,19,12),"wing",""])
 rows.append(["south_wing",Rect2(151,82,17,10),"wing",""])
 # West-facing porch: only columns and full-height step cheeks block movement.
 for y in [51.5,54.,62.,64.5]:
  rows.append(["porch_column_%d"%y,Rect2(128.5,y-.5,1.,1.),"column",""])
 for y in [53.,62.]:rows.append(["step_cheek_%d"%y,Rect2(122,y,6.5,1.1),"step_wall",""])
 rows.append(["gatehouse",Rect2(54,43,10,8),"gatehouse",""])
 rows.append(["carriage_house",Rect2(80,84,20,12),"garage",""])
 # Open gate and two purposeful pedestrian/service openings. Ironwork sits
 # on a low masonry plinth; it blocks movement but does not pretend to be opaque.
 for span in [[9.,24.],[32.,52.],[74.,86.],[95.,102.]]:
  rows.append(["front_fence_%d"%span[0],Rect2(49,span[0],.7,span[1]-span[0]),"fence",""])
 for y in [9.,24.,32.,52.,74.,86.,95.,102.]:
  rows.append(["gate_pier_%d"%y,Rect2(48.35,y-.65,2.,1.8),"pier",""])
 for spec in [[49.,9.,80.],[100.,102.,70.]]:
  rows.append(["boundary_fence_%d"%spec[1],Rect2(spec[0],spec[1],spec[2],.6),"fence",""])
 # The fountain is a series of fitted strips, not one oversized square collider.
 for i in range(6):
  var height=11./6.;var y=-5.5+i*height;var half=sqrt(maxf(0.,30.25-pow(absf(y+height*.5),2)))
  rows.append(["fountain_body_%d"%i,Rect2(FOUNTAIN.x-half,FOUNTAIN.y+y,half*2.,height),"fountain_body",""])
 rows.append(["fountain_visual",Rect2(102.5,60.5,11,11),"fountain",""])
 for spec in [[70.,37.,11.,1.8],[93.,34.,13.,1.8],[117.,40.,10.,1.8],[72.,75.,8.,1.7],[120.,86.,8.,1.7],[119.,33.,5.,1.7],[132.,78.,5.,1.7]]:
  rows.append(["planter_%d_%d"%[spec[0],spec[1]],Rect2(spec[0],spec[1],spec[2],spec[3]),"planter",""])
 # Prepared defense made from plausible estate materials, with openings for movement.
 for spec in [[58.,59.,1.8,5.8],[60.,70.,1.8,5.8],[78.,54.,1.8,6.],[87.,69.,6.,1.8],[121.,54.,1.8,5.],[126.,77.,1.8,5.5]]:
  rows.append(["sandbags_%d_%d"%[spec[0],spec[1]],Rect2(spec[0],spec[1],spec[2],spec[3]),"sandbags",""])
 rows.append(["tipped_table",Rect2(116,78,5,2),"table",""])
 rows.append(["garden_crates",Rect2(66,30,3.2,3.),"crates",""])
 rows.append(["service_crates",Rect2(74,89,3.4,3.),"crates",""])
 rows.append(["potting_bench",Rect2(115,24,7,2.),"table",""])
 # Tree trunks are physical; foliage is deliberately nonblocking to sight/fire.
 for spec in [[37.,25.],[39.,92.],[66.,20.],[85.,18.],[122.,16.],[64.,96.],[118.,98.],[157.,92.],[146.,83.]]:
  rows.append(["tree_%d_%d"%[spec[0],spec[1]],Rect2(spec[0]-.65,spec[1]-.65,1.3,1.3),"tree",""])
 # Established fleet artwork and physical scale. These parked cars are real cover.
 for spec in [[119.,46.,"regent",Vector2.RIGHT],[113.,92.,"rancher",Vector2.LEFT],[69.,93.,"workhorse",Vector2.RIGHT],[122.,29.,"aurelia",Vector2.LEFT]]:
  var at=Vector2(spec[0],spec[1]);rows.append(["parked_%d_%d"%[spec[0],spec[1]],Fleet.traffic_bounds(at,spec[2],spec[3]),"traffic",spec[2],spec[3],0.])
 _props=rows;return rows
static func architecture_point(at: Vector2) -> Vector2:
 var d=at-Vector2(139,33)
 return Vector2(127,33)+Vector2(24./31.,-12./31.)*d.x+Vector2(21./49.,42./49.)*d.y
static func architectural(row: Array) -> bool:return row[2] in ["house","wing","column","step_wall"]
static func physical_rects(row: Array) -> Array:
 if not architectural(row):return [row[1]]
 var b: Rect2=row[1]
 var polygon=[architecture_point(b.position),architecture_point(Vector2(b.end.x,b.position.y)),architecture_point(b.end),architecture_point(Vector2(b.position.x,b.end.y))]
 var top=INF;var bottom=-INF
 for p in polygon:top=minf(top,p.y);bottom=maxf(bottom,p.y)
 var result=[];var y=top
 # Conservative strips use the exact same plan projection as art. They keep
 # the existing rectangle-based collision system, with <=1 world-unit edge bias.
 while y<bottom-.001:
  var end=minf(bottom,y+2.);var left=INF;var right=-INF
  for yy in [y+.0001,end-.0001]:
   for i in range(4):
    var a: Vector2=polygon[i];var z: Vector2=polygon[(i+1)%4]
    if yy>=minf(a.y,z.y) and yy<=maxf(a.y,z.y) and absf(z.y-a.y)>.00001:
     var x=lerpf(a.x,z.x,(yy-a.y)/(z.y-a.y));left=minf(left,x);right=maxf(right,x)
  if right>left:result.append(Rect2(left,y,right-left,end-y))
  y=end
 return result
static func build():
 var d=Base.Definition.new();d.definition_id=ID;d.width=SIZE.x;d.height=SIZE.y
 d.surfaces.append(Base.Surface.new("public_road",Base.Surface.KIND_ASPHALT,Rect2(2,0,15,106)))
 d.surfaces.append(Base.Surface.new("estate_drive",Base.Surface.KIND_ASPHALT,Rect2(17,56,83,18)))
 d.surfaces.append(Base.Surface.new("fountain_court",Base.Surface.KIND_SIDEWALK,Rect2(82,43,48,44)))
 d.surfaces.append(Base.Surface.new("service_drive",Base.Surface.KIND_ALLEY,Rect2(50,87,79,8)))
 d.obstacles.append(Base.Obstacle.new("boundary_north",Rect2(0,0,176,5),true,false,"boundary"))
 d.obstacles.append(Base.Obstacle.new("boundary_south",Rect2(0,103,176,3),true,false,"boundary"))
 for row in props():
  if row[2]=="fountain":continue
  var tall=row[2] in ["house","wing","column","step_wall","gatehouse","garage","pier","crates"]
  var bounds=physical_rects(row)
  for i in range(bounds.size()):
   d.obstacles.append(Base.Obstacle.new(row[0]+("_%d"%i if architectural(row) else ""),bounds[i],true,tall,row[2]))
 for row in props():
  if row[2] in ["house","wing","column","step_wall","garage","fountain_body","pier"] or str(row[0]).begins_with("boundary_fence"):continue
  if row[2]=="tree" and (row[1].get_center().y<24 or row[1].get_center().x>130):continue
  var box: Rect2=row[1];var id="cover_"+row[0];var c=box.get_center()
  if row[2]=="fountain":
   # Logical cover linked to the corresponding physical strip.
   id="cover_fountain";d.cover_objects.append(Base.Cover.new(id,"fountain_body_3"))
  else:d.cover_objects.append(Base.Cover.new(id,row[0]))
  var points=[]
  if row[2]=="fountain":
   for a in range(8):
    var normal=Vector2.from_angle(float(a)*TAU/8.);points.append([FOUNTAIN+normal*6.7,-normal])
  else:
   points=[[Vector2(c.x,box.position.y-.85),Vector2.DOWN],[Vector2(c.x,box.end.y+.85),Vector2.UP],[Vector2(box.position.x-.85,c.y),Vector2.RIGHT],[Vector2(box.end.x+.85,c.y),Vector2.LEFT]]
   if row[2] in ["fence","sandbags","planter"]:
    if box.size.y>5:
     for y in range(int(box.position.y)+2,int(box.end.y)-1,6):
      points.append([Vector2(box.position.x-.9,y),Vector2.RIGHT]);points.append([Vector2(box.end.x+.9,y),Vector2.LEFT])
    if box.size.x>5:
     for x in range(int(box.position.x)+2,int(box.end.x)-1,6):
      points.append([Vector2(x,box.position.y-.9),Vector2.DOWN]);points.append([Vector2(x,box.end.y+.9),Vector2.UP])
   if row[2] in ["gatehouse","pier","crates"]:
    points[2][0].y=box.end.y+.15;points[3][0].y=box.position.y-.15
  for n in range(points.size()):
   var at: Vector2=points[n][0];var valid=true
   if not Rect2(Vector2(.5,5.5),SIZE-Vector2(1,9)).has_point(at):continue
   for obstacle in d.obstacles:
    if obstacle.bounds.grow(.36).has_point(at):valid=false;break
   if valid:d.cover_slots.append(Base.Slot.new(id+"_"+str(n),id,at,points[n][1]))
 d.attacker_deployment_area.add_pocket(Base.Pocket.new("estate_approach",Base.rect_points(ARRIVAL)))
 d.defender_deployment_area.add_pocket(Base.Pocket.new("estate_defense",Base.rect_points(DEFENDERS)))
 d.attacker_vehicle_placement_context=Base.VehicleContext.new(false,ARRIVAL.get_center(),true,Vector2.RIGHT)
 d.defender_vehicle_placement_context=Base.VehicleContext.new(false,DEFENDERS.get_center(),true,Vector2.LEFT)
 return d
