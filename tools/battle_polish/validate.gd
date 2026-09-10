extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Arrival=preload("res://battle/vehicles/battle_arrival_service.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
var checks=0
var problems=[]
func _initialize():call_deferred("run")
func verify(ok,message):
 checks+=1
 if not ok:problems.append(message);push_error(message)
func run():
 for choice in ["close","medium","far"]:
  var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime);await process_frame
  var result=Scenario.setup(runtime,2002,true,choice)
  verify(result.has("battle"),"legal "+choice+" deployment: "+str(result.get("error","")))
  if result.has("battle"):
   var b=result.battle;var controller=runtime.tactical_deployment_controller
   verify(b.arrival_choice==choice,"choice retained")
   var before=b.elapsed_time_seconds
   verify(not controller.choose_arrival("invalid"),"invalid arrival rejected")
   verify(b.elapsed_time_seconds==before,"arrival rejection does not advance time")
   verify(not controller.choose_arrival("far" if choice!="far" else "close"),"committed arrival frozen")
   var count=0
   for v in b.vehicles.values():
    if v.side_id!=b.attacker_side_id:continue
    verify(v.battle_position==preload("res://battle/geometry/harold_street_catalog.gd").ARRIVAL_OPTIONS[choice].center,"car at selected anchor")
    for spec in Arrival.door_specs(v):
     var slot=b.battlefield_geometry.get_cover_slot(spec.id+"_cover")
     verify(slot!=null,"door is cover "+spec.id)
     if slot!=null:
      count+=1;verify(Nav.is_reachable(b,slot.position,Vector2(32,30)),"reachable door "+spec.id)
      verify(b.battlefield_geometry.get_movement_blocking_obstacle_id_at(slot.position).is_empty(),"door slot outside obstacles")
   verify(count==4,"four open door covers")
   for p in b.participants.values():
    if p.side_id==b.attacker_side_id:verify(p.has_occupied_cover_slot(),"attacker begins covered "+p.participant_id)
   var view=runtime.get_node("TacticalBattleView");view._sync_actor_presenter()
   view._sync_environment_presenter();await process_frame
   view._sync_environment_presenter()
   verify(not view._dusk_nodes.is_empty() and is_instance_valid(view._dusk_nodes[0]) and not view._dusk_nodes[0].is_queued_for_deletion(),"ground survives deployment geometry refresh")
   var director=view.battle_presentation;director.reset(b);director.begin_arrival()
   verify(director.last_path_errors.is_empty(),"arrival paths "+str(director.last_path_errors))
   for i in range(400):view._sync_actor_presenter();director._process(.05)
   verify(director.stage=="ready","arrival finishes ready")
   verify(b.elapsed_time_seconds==0.,"no firing before Start")
   verify(director.context.size.x==476.,"compact persistent header")
   verify(runtime.begin_current_battle().success,"selected deployment starts")
  runtime.queue_free();await process_frame;await process_frame
 DirAccess.make_dir_recursive_absolute("res://tools/battle_polish/results")
 FileAccess.open("res://tools/battle_polish/results/checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"problems":problems},"  "))
 print("POLISH_VALIDATION checks=",checks," problems=",problems);quit(0 if problems.is_empty() else 1)
