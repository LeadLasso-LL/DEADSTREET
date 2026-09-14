extends SceneTree
const Director=preload("res://tools/tactical_controls/raiders_director.gd")
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
var scene
var view
var b
var ready=false
var captures={}
var errors=[]
var checks=0
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/raiders_recording"
func check(value: bool,message: String):
 checks+=1
 if not value:errors.append(message);printerr("CONVOY_FAIL ",message)
func _initialize():call_deferred("start")
func start():
 var cfg=Director.config()
 check(Formation.slots(cfg.attacker.vehicles,"stateline").size()==3,"Raiders seven vehicles occupy three slots")
 check(Formation.slots(cfg.attacker.vehicles,"nbpd").size()==7,"Other factions do not inherit Raiders packing")
 check(Formation.slots(["yardbird","yardbird","yardbird"],"stateline").size()==3,"Bicycles do not count as motorcycles")
 check(Formation.slots(["ironhorse","ironhorse","ironhorse","ironhorse"],"stateline").size()==2,"Fourth bike starts a new slot")
 check(not Formation.manifest(["ironhorse"],3).valid,"Capacity remains two per bike")
 check(not Formation.manifest(["mesa"],6).valid,"Mesa capacity remains five")
 check(not Formation.manifest(["ironhorse","ironhorse"],1).valid,"Every bike needs a driver")
 check(not Formation.manifest(["mesa"],5,[{"units":5,"bed":5}]).valid,"Cannot put driver in bed")
 check(not Formation.manifest(["ironhorse"],2,[{"units":2,"bed":1}]).valid,"No pickup-bed seats on a bike")
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 scene.seed_value=9141;await scene.start_battle(false,cfg);scene.set_process(false)
 b=scene.battle
 if b==null:check(false,"Native battle setup");finish();return
 view=scene.runtime.get_node("TacticalBattleView")
 view._dusk_zoom=2.8;view._dusk_pan=Vector2(-550,-22);view._frame_camera()
 var counts=[];var occupants={};var beds=0
 for id in b.vehicles:
  var v=b.vehicles[id]
  if v.side_id!=b.attacker_side_id:continue
  var n=0
  for p in b.participants.values():
   if p.transport_vehicle_id==id:
    n+=1;check(not occupants.has(p.participant_id),"Each unit is assigned exactly once");occupants[p.participant_id]=true
    if p.get_meta("transport_bed",false):beds+=1
  counts.append(n);check(v.has_battle_position,"Vehicle has legal placement")
  check(v.facing_direction.is_equal_approx(Vector2.RIGHT),"West approach faces east")
  for corner in preload("res://battle/vehicles/battle_vehicle_body_service.gd").world_corners(v):
   check(corner.y>=31. and corner.y<=44.,"Entire arriving body stays in eastbound carriageway")
 check(counts==[2,1,1,5,1,1,1],"Seven bike occupants and five Mesa occupants")
 check(beds==2,"Two actual units in pickup bed");check(occupants.size()==12,"All 12 actual units accounted for")
 ready=true
func _process(delta):
 if not ready:return false
 var p=view.battle_presentation
 for t in [4.,6.4,7.3,9.2,12.]:
  var key="arrival_%02d"%roundi(t*10)
  if p.clock>=t and not captures.has(key):captures[key]=true;capture(key)
 if p.stage=="ready":
  ready=false
  check(p.last_path_errors.is_empty(),"Every dismount has a legal cover route")
  check(p.convoy_riders.size()==9,"Seven bike riders and two pickup-bed riders rendered")
  check(p.convoy_audio.sources.size()==3,"One radio and two localized sirens")
  for rider in p.convoy_riders.values():check(not rider.visible,"Seated rider disappears after dismount")
  for node in view.actor_presenter._unit_nodes.values():check(node.visible,"All actors visible after arrival")
  await process_frame
  finish()
 if p.clock>40.:ready=false;check(false,"Arrival did not finish in time");finish()
 return false
func capture(key: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/"+key+".png")
func finish():
 var report={"checks":checks,"errors":errors,"captures":captures.keys()}
 FileAccess.open(out+"/convoy_native.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("CONVOY_NATIVE ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
