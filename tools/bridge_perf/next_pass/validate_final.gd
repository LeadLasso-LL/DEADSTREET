extends SceneTree
const C=preload("res://battle/geometry/river_bridge_catalog.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const OldNav=preload("res://tools/bridge_perf/old_nav.gd")
const Spatial=preload("res://battle/geometry/battle_spatial_service.gd")
const OldSpatial=preload("res://tools/bridge_perf/old_spatial.gd")
const LOS=preload("res://battle/combat/battle_line_of_sight_service.gd")
const OldLOS=preload("res://tools/bridge_perf/old_los.gd")
class View extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var errors=[];var checks=0
func check(ok,label):
 checks+=1
 if not ok:errors.append(label);printerr("PERF_CHECK_FAIL ",label)
func length_of(points):
 var value=0.
 for i in range(1,points.size()):value+=points[i-1].distance_to(points[i])
 return value
func _initialize():call_deferred("run")
func run():
 var r=load("res://gameplay/gameplay_runtime.gd").new();r.game_state=load("res://gameplay/starter_world_service.gd").create()
 r.game_flow_controller=load("res://core/game_flow_controller.gd").create(r.game_state).controller
 var view=View.new();view.name="TacticalBattleView";r.add_child(view)
 var c=Cases.make(8,8,["aegis","vigil"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor"]
 var setup=Fixture.setup(r,c,false,734,true)
 check(setup.has("battle"),"fixture")
 if not setup.has("battle"):quit(1);return
 var b=setup.battle;var g=b.battlefield_geometry
 b.begin_geometry_validation_scope()
 var points=[]
 for i in range(240):
  var a=Vector2(3.+(i*29)%174,7.+(i*13)%44);var z=Vector2(3.+(i*43+31)%174,7.+(i*17+19)%44)
  var x=Spatial.resolve_translation(b,a,z-a);var y=OldSpatial.resolve_translation(b,a,z-a)
  check(x.success==y.success and x.final_position.is_equal_approx(y.final_position) and x.blocking_obstacle_id==y.blocking_obstacle_id,"movement "+str(i))
  b.clear_los_cache();var v=LOS.check_segment(b,a,z);b.clear_los_cache();var w=OldLOS.check_segment(b,a,z)
  check(v.success==w.success and v.has_line_of_sight==w.has_line_of_sight and v.blocking_obstacle_id==w.blocking_obstacle_id,"visibility "+str(i))
  if OldNav._is_legal_candidate(b,a):points.append(a)
 for obstacle in g.obstacles.values():
  for point in [obstacle.bounds.position,obstacle.bounds.end,obstacle.bounds.position+Vector2(obstacle.bounds.size.x,0),obstacle.bounds.position+Vector2(0,obstacle.bounds.size.y)]:
   check(g.get_movement_blocking_obstacle_id_at(point)==OldNav._blocking_obstacle_id(g,point),"indexed inclusive boundary")
 var graph=Nav._ensure_static_graph(b)
 for i in range(32):
  var a=points[i%points.size()];var z=points[(i*7+9)%points.size()]
  var x=Nav.find_path(b,a,z);var y=OldNav.find_path(b,a,z)
  check(x.success==y.success,"path success "+str(i))
  if x.success:
   var prev=a
   for p in x.waypoints:
    check(OldSpatial.is_translation_clear(b,prev,p),"path clearance "+str(i));prev=p
  if not a.is_equal_approx(z) and not OldSpatial.is_translation_clear(b,a,z):
   var xn=Nav._query_shortest_route(b,graph,a,z);var yn=OldNav._query_shortest_route(b,graph,a,z)
   check(xn.is_empty()==yn.is_empty(),"route connectivity "+str(i))
   if not xn.is_empty():check(length_of(xn)<=length_of(yn)+.02,"route distance "+str(i))
 var count=b.get_static_nav_build_count();var vehicle=b.vehicles.values()[0];var original=vehicle.battle_position
 vehicle.battle_position+=Vector2(.5,0);Nav.prewarm(b)
 check(b.get_static_nav_build_count()==count+1,"vehicle topology invalidates cache")
 vehicle.battle_position=original;Nav.prewarm(b)
 count=b.get_static_nav_build_count();g.content_revision+=1;Nav.prewarm(b)
 check(b.get_static_nav_build_count()==count+1,"geometry invalidates cache")
 b.clear_los_cache();b.prepare_los_cache_for_tick()
 LOS.check_segment(b,Vector2(42,27.8),Vector2(141,27.8))
 var cached_entries=b._los_cache.size()
 b.prepare_los_cache_for_tick()
 check(cached_entries>0 and b._los_cache.size()==cached_entries,"stationary visibility reused")
 LOS.check_segment(b,Vector2(43,27.8),Vector2(141,27.8))
 check(b._los_cache.size()>cached_entries,"moving endpoint uses separate cache key")
 var trace_obstacle=g.obstacles.values()[0];var saved_bounds=trace_obstacle.bounds
 trace_obstacle.bounds.position+=Vector2(.25,0)
 b.prepare_los_cache_for_tick()
 check(b._los_cache.is_empty(),"direct obstacle edit invalidates visibility")
 trace_obstacle.bounds=saved_bounds;b.prepare_los_cache_for_tick()
 LOS.check_segment(b,Vector2(42,27.8),Vector2(141,27.8))
 g.content_revision+=1;b.prepare_los_cache_for_tick()
 check(b._los_cache.is_empty(),"authored revision invalidates visibility")
 b.end_geometry_validation_scope()
 var Combat=load("res://battle/combat/battle_combat_behavior_service.gd")
 var Commands=load("res://battle/core/battle_force_command_service.gd")
 var start=Fixture.begin_review(r,b)
 check(start!=null and start.success,"combat begins for defender timing checks")
 var defender=null;var target=null
 for unit in b.participants.values():
  if unit.side_id==b.defender_side_id:defender=unit
  else:target=unit
 Commands.set_command(b,defender.tactical_force_id,"hold")
 check(Combat._defender_search_due(b,defender,target,false),"first defensive search")
 check(not Combat._defender_search_due(b,defender,target,false),"unchanged hold skips repeated search")
 b.elapsed_time_seconds+=.5
 check(Combat._defender_search_due(b,defender,target,false),"periodic search resumes")
 check(Combat._defender_search_due(b,defender,target,true),"new exposure triggers immediate search")
 target.battle_position+=Vector2(0,4)
 check(Combat._defender_search_due(b,defender,target,true),"threat movement triggers search")
 g.content_revision+=1
 check(Combat._defender_search_due(b,defender,target,true),"geometry change triggers search")
 Commands.set_command(b,defender.tactical_force_id,"push")
 check(Combat._defender_search_due(b,defender,target,true) and Combat._defender_search_due(b,defender,target,true),"push bypasses defensive pacing")
 # Full validation still observes direct, unversioned edits between calls.
 var slot=g.cover_slots.values()[0];var original_slot=slot.position
 slot.position=g.obstacles.values()[0].bounds.position
 check(not g.is_valid(),"validation detects cover inside live obstacle")
 slot.position=original_slot
 check(g.is_valid(),"valid geometry restored")
 # Short segments exercise grid buckets rather than the long-query fallback.
 b.begin_geometry_validation_scope()
 for i in range(160):
  var a=Vector2(4.+(i*11)%170,8.+(i*7)%42);var z=a+Vector2(float(i%7)-3.,float(i%5)-2.)
  var x=Spatial.resolve_translation(b,a,z-a);var y=OldSpatial.resolve_translation(b,a,z-a)
  check(x.success==y.success and x.final_position.is_equal_approx(y.final_position) and x.blocking_obstacle_id==y.blocking_obstacle_id,"local segment "+str(i))
  b.clear_los_cache();var v=LOS.check_segment(b,a,z);b.clear_los_cache();var w=OldLOS.check_segment(b,a,z)
  check(v.success==w.success and v.has_line_of_sight==w.has_line_of_sight and v.blocking_obstacle_id==w.blocking_obstacle_id,"local visibility "+str(i))
 var Targets=load("res://battle/combat/battle_target_selection_service.gd")
 var OldTargets=load("res://tools/bridge_perf/old_targets.gd")
 for unit in b.participants.values():
  var ids=Targets._sorted_eligible_hostile_ids(b,unit)
  for retained in ["",ids[0],ids.back()]:
   var previous=unit.target_participant_id;unit.target_participant_id=retained
   check(Targets._assault_target(b,unit,ids)==OldTargets._assault_target(b,unit,ids),"same assault target "+unit.participant_id+retained)
   unit.target_participant_id=previous
 b.end_geometry_validation_scope()

 var Body=load("res://battle/vehicles/battle_vehicle_body_service.gd")
 var OldBody=load("res://tools/bridge_perf/next_pass/oracle_body.gd")
 var Physical=load("res://battle/vehicles/battle_vehicle_physical_catalog.gd")
 var Models=load("res://campaign/vehicles/vehicle_model_catalog.gd")
 for type_id in Models.all_ids()+["car","unknown_test_type",""]:
  var original_profile=Physical.get_profile(str(type_id))
  var shared_profile=Physical._get_collision_profile(str(type_id))
  check((original_profile==null)==(shared_profile==null),"profile presence "+str(type_id))
  if original_profile!=null:
   check(original_profile.vehicle_type_id==shared_profile.vehicle_type_id and original_profile.length==shared_profile.length and original_profile.width==shared_profile.width,"profile dimensions "+str(type_id))
   var saved_length=original_profile.length;original_profile.length+=1.
   check(Physical._get_collision_profile(str(type_id)).length==saved_length,"public profiles remain independent "+str(type_id))
 var model=Models.model("aegis");var saved_length=float(model.length);var saved_width=float(model.width)
 model.length=saved_length+1.
 check(Physical._get_collision_profile("aegis").length==saved_length+1.,"live catalog length edit")
 model.width=0.
 check(Physical._get_collision_profile("aegis")==null,"invalid live catalog dimensions")
 model.length=saved_length;model.width=saved_width
 check(Physical._get_collision_profile("aegis").length==saved_length and Physical._get_collision_profile("aegis").width==saved_width,"catalog dimensions restored")
 var v=b.vehicles.values()[0];var saved_type=v.vehicle_type_id;var saved_pos=v.battle_position;var saved_facing=v.facing_direction;var saved_deployed=v.has_battle_position
 var rng=RandomNumberGenerator.new();rng.seed=81093
 for i in range(320):
  v.vehicle_type_id=["aegis","bulwark","car","unknown_test_type"][i%4]
  v.battle_position=Vector2(15.+float(i%7),20.+float(i%11));v.facing_direction=Vector2.RIGHT.rotated(float(i%16)*PI/8.);v.has_battle_position=i%23!=0
  var a=v.battle_position+Vector2(rng.randf_range(-12.,12.),rng.randf_range(-12.,12.))
  var z=v.battle_position+Vector2(rng.randf_range(-12.,12.),rng.randf_range(-12.,12.))
  if i%5==0:a=v.battle_position
  if i%7==0:z=a
  check(Body.contains_point(v,a)==OldBody.contains_point(v,a),"body point "+str(i))
  var x=Body.segment_entry_t(v,a,z-a);var y=OldBody.segment_entry_t(v,a,z-a)
  check((is_inf(x) and is_inf(y)) or x==y,"body segment exact "+str(i))
  if v.has_battle_position:
   for corner in OldBody.world_corners(v):
    check(Body.contains_point(v,corner)==OldBody.contains_point(v,corner),"body inclusive corner")
    var sx=Body.segment_entry_t(v,corner,Vector2.ZERO);var sy=OldBody.segment_entry_t(v,corner,Vector2.ZERO)
    check((is_inf(sx) and is_inf(sy)) or sx==sy,"body stationary boundary")
 v.vehicle_type_id=saved_type;v.battle_position=saved_pos;v.facing_direction=saved_facing;v.has_battle_position=saved_deployed
 var OldComponents=load("res://tools/bridge_perf/next_pass/oracle_nav.gd")
 b.begin_geometry_validation_scope()
 var current_graph=Nav._ensure_static_graph(b);var labels=Nav._component_labels(current_graph)
 for point in points.slice(0,32):
  var expected=OldComponents._point_components(b,current_graph,labels,point)
  check(Nav._point_components(b,current_graph,labels,point)==expected,"connectivity miss")
  check(Nav._point_components(b,current_graph,labels,point)==expected,"connectivity reuse")
 var old_graph=current_graph;v.battle_position+=Vector2(.5,0)
 current_graph=Nav._ensure_static_graph(b)
 check(current_graph!=old_graph and not current_graph.has_meta("point_components"),"vehicle change discards component cache")
 v.battle_position=saved_pos
 old_graph=Nav._ensure_static_graph(b);g.content_revision+=1;current_graph=Nav._ensure_static_graph(b)
 check(current_graph!=old_graph and not current_graph.has_meta("point_components"),"geometry change discards component cache")
 b.end_geometry_validation_scope()

 # Empty grid buckets must return a typed empty array without script errors.
 b.begin_geometry_validation_scope()
 check(g.get_obstacle_ids_at_point(Vector2(-1000.,-1000.)).is_empty(),"empty obstacle cell")
 check(g.get_obstacle_ids_in_rect(Rect2(-1000.,-1000.,1.,1.)).is_empty(),"empty obstacle rectangle")
 b.end_geometry_validation_scope()
 var Pressure=load("res://battle/combat/battle_combat_pressure_service.gd")
 var OldPressure=load("res://tools/bridge_perf/next_pass/oracle_pressure.gd")
 var fields=["participant_id","nearby_dead_allies","nearby_wounded_allies","nearby_living_allies","nearby_hostiles","casualty_pressure","wounded_pressure","hostile_pressure","isolation_pressure","multi_direction_pressure","friendly_support","total_pressure"]
 var changing=b.participants.values()[0];var remembered=[changing.battle_position,changing.is_alive,changing.is_wounded,changing.side_id,changing.has_battle_position]
 for mode in range(6):
  changing.battle_position=remembered[0]+Vector2(float(mode)*2.,0.);changing.is_alive=mode!=1;changing.is_wounded=mode==2;changing.side_id="" if mode==3 else remembered[3];changing.has_battle_position=mode!=4
  Pressure.refresh(b);var optimized=b.combat_pressure_snapshots.duplicate()
  OldPressure.refresh(b);var original_pressure=b.combat_pressure_snapshots
  check(optimized.keys()==original_pressure.keys(),"same pressure subjects "+str(mode))
  for id in optimized:
   for field in fields:check(optimized[id].get(field)==original_pressure[id].get(field),"same pressure "+str(mode)+id+field)
 changing.battle_position=remembered[0];changing.is_alive=remembered[1];changing.is_wounded=remembered[2];changing.side_id=remembered[3];changing.has_battle_position=remembered[4]
 var pressure_times={}
 for trial in range(3):
  for label in (["old","new"] if trial%2==0 else ["new","old"]):
   var service=OldPressure if label=="old" else Pressure
   var timer=Time.get_ticks_usec()
   for repetition in range(100):service.refresh(b)
   pressure_times[label+str(trial)]=(Time.get_ticks_usec()-timer)/1000.
 FileAccess.open("res://tools/bridge_perf/next_pass/pressure_micro.json",FileAccess.WRITE).store_string(JSON.stringify(pressure_times,"  "))

 r.free()
 var report={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/bridge_perf/next_pass/checks_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("PERF_CHECKS ",report);quit(0 if errors.is_empty() else 1)
