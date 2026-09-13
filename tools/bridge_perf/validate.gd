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

 r.free()
 var report={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/bridge_perf/checks.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("PERF_CHECKS ",report);quit(0 if errors.is_empty() else 1)
