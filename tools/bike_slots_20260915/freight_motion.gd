extends SceneTree
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Estate=preload("res://gameplay/freight_exchange_setup.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
var errors=[]
var runs=[]
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame;scene.set_process(false)
 var legacy=GDScript.new();legacy.source_code=FileAccess.get_file_as_string("res://tools/bike_slots_20260915/freight_before.gd")
 assert(legacy.reload()==OK)
 for count in [0,2,4,12]:
  var c=Maps.preset("freight_exchange");c.attacker.faction="mercer" if count==2 else "stateline";c.attacker.units=[];c.attacker.vehicles=[];c.attacker.erase("vehicle_occupants")
  for i in range(16):c.attacker.units.append(Config.unit(Config.CLASSES[i%5]))
  for i in range(count):c.attacker.vehicles.append("ironhorse")
  if count<12:c.attacker.vehicles.append_array(["bayou","shuttle"])
  await scene.start_battle(false,c)
  if scene.battle==null:errors.append("Launch "+str(count)+" "+scene.note.text);continue
  for i in range(12):await process_frame
  var view=scene.runtime.get_node("TacticalBattleView");var vehicles=[];var pairs=0;var overlaps=[]
  for v in scene.battle.vehicles.values():
   if v.side_id==scene.battle.attacker_side_id:
    vehicles.append(v)
    if not v.has_battle_position:errors.append("Unplaced vehicle "+str(count)+" "+v.battle_vehicle_id+" "+scene.note.text)
  if not view.battle_presentation.last_path_errors.is_empty():errors.append("Dismount paths "+str(count))
  var static_polys=[]
  for row in preload("res://battle/geometry/freight_exchange_catalog.gd").props():
   var box: Rect2=row[1]
   static_polys.append([row[0],PackedVector2Array([box.position,Vector2(box.end.x,box.position.y),box.end,Vector2(box.position.x,box.end.y)])])
  for frame in range(30,541):
   var clock=frame/30.;var polys=[]
   for v in vehicles:
    var stop=view.battle_presentation.vehicle_stop_time(v);var pose=Estate.arrival_pose(v,clock,stop)
    polys.append(Body.corners_for_pose(pose.position,pose.facing,Body.profile_for_vehicle(v)))
    if count==0 and pose!=legacy.arrival_pose(v,clock,stop):errors.append("Non-bike arrival changed at "+str(clock))
   for obstacle in static_polys:
    for i in range(polys.size()):
     var area=intersection_area(Geometry2D.intersect_polygons(polys[i],obstacle[1]))
     if area>.02 and overlaps.size()<12:overlaps.append({"time":clock,"vehicle":i,"obstacle":obstacle[0],"area":area})
   for i in range(vehicles.size()):
    for j in range(i+1,vehicles.size()):
     pairs+=1
     var hits=Geometry2D.intersect_polygons(polys[i],polys[j])
     if not hits.is_empty():
      var area=0.
      for polygon in hits:
       var a=0.
       for k in range(polygon.size()):a+=polygon[k].cross(polygon[(k+1)%polygon.size()])
       area+=absf(a)*.5
      if area>.02 and overlaps.size()<12:overlaps.append({"time":clock,"pair":[i,j],"area":area})
  if not overlaps.is_empty():errors.append("Arrival overlap: "+str(count)+" bikes")
  runs.append({"bikes":count,"pair_samples":pairs,"overlaps":overlaps})
  scene.return_to_setup();await process_frame
 var result={"errors":errors,"runs":runs}
 FileAccess.open("res://tools/bike_slots_20260915/freight_motion.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"));print("BIKE_MOTION_CHECK ",JSON.stringify(result));quit(0 if errors.is_empty() else 1)

func intersection_area(hits: Array) -> float:
 var area=0.
 for polygon in hits:
  var a=0.
  for k in range(polygon.size()):a+=polygon[k].cross(polygon[(k+1)%polygon.size()])
  area+=absf(a)*.5
 return area
