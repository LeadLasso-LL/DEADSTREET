extends SceneTree
const OldBody=preload("res://tools/bridge_perf/headroom/oracle/battle/vehicles/battle_vehicle_body_service.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const LOS=preload("res://battle/combat/battle_line_of_sight_service.gd")
const OldLOS=preload("res://tools/bridge_perf/headroom/oracle/battle/combat/battle_line_of_sight_service.gd")
const Roles=preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const OldNav=preload("res://tools/bridge_perf/headroom/oracle/battle/navigation/battle_navigation_service.gd")
const Targets=preload("res://battle/combat/battle_target_selection_service.gd")
const OldTargets=preload("res://tools/bridge_perf/headroom/oracle/battle/combat/battle_target_selection_service.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Tiers=preload("res://battle/combat/battle_unit_tier_catalog.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const OldRuntime=preload("res://tools/bridge_perf/headroom/oracle/battle/runtime/battle_runtime_service.gd")
const Commands=preload("res://battle/core/battle_force_command_service.gd")
const Cover=preload("res://battle/geometry/battle_cover_service.gd")
class View extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var errors=[];var checks=0
func check(ok,label):
 checks+=1
 if not ok:errors.append(label);printerr("REPLAY_FAIL ",label)
func make_fixture(close_case):
 var r=load("res://gameplay/gameplay_runtime.gd").new();r.game_state=load("res://gameplay/starter_world_service.gd").create()
 r.game_flow_controller=load("res://core/game_flow_controller.gd").create(r.game_state).controller
 var view=View.new();view.name="TacticalBattleView";r.add_child(view)
 var c=Cases.make(2 if close_case else 12,1 if close_case else 12,["aegis"] if close_case else ["aegis","vigil","aegis"])
 c.map_id="river_bridge";c.defender.vehicles=["bulwark"] if close_case else ["bulwark","interceptor","bulwark"]
 var setup=Fixture.setup(r,c,false,734,true)
 if not setup.has("battle"):return {}
 var b=setup.battle
 var begin=Fixture.begin_review(r,b)
 if begin==null or not begin.success:return {}
 for id in b.get_sorted_tactical_force_ids():
  if b.get_tactical_force(id).side_id==b.attacker_side_id:Commands.set_command(b,id,"push")
 if close_case:
  var index=0
  for p in b.participants.values():
   Cover.release_all_for_participant(b,p.participant_id)
   p.defend_position=false;p.battle_position=Vector2(42.+float(index)*1.5,27.8)
   if p.side_id==b.defender_side_id:p.vitality=0.001
   index+=1
 return {"runtime":r,"battle":b}
func snapshot(b):
 var rows=[b.battle_phase,b.elapsed_time_seconds,b.combat_random.snapshot_state()]
 var ids=b.participants.keys();ids.sort()
 for id in ids:
  var p=b.participants[id]
  rows.append([id,p.is_alive,p.is_wounded,p.vitality,p.battle_position,p.velocity,p.target_participant_id,p.occupied_cover_slot_id,p.reserved_cover_slot_id,p.combat_move_mode,p.weapon_state.ammo_in_magazine,p.weapon_state.cooldown_remaining_seconds,p.weapon_state.reload_remaining_seconds])
 return rows
func _initialize():call_deferred("run")

func target_snapshot(b):
 var rows=[]
 for id in b.participants:
  var p=b.participants[id]
  rows.append([id,p.has_target_participant,p.target_participant_id,p.player_priority_target_id])
 return rows
func profile_snapshot(d):
 if d==null:return []
 var values=[]
 for field in Tiers.FIELDS:values.append(d.get(field))
 return values
func run():
 var a=make_fixture(false);var z=make_fixture(false)
 check(not a.is_empty() and not z.is_empty(),"fixtures")
 if a.is_empty() or z.is_empty():quit(1);return
 var b=a.battle;var graph=Nav._ensure_static_graph(b)
 var random=RandomNumberGenerator.new();random.seed=915134
 b.begin_geometry_validation_scope()
 var collision_scope=Body.begin_runtime_collision_scope(b)
 for i in range(3500):
  var start=Vector2(random.randf_range(0.,180.),random.randf_range(0.,58.))
  var end=Vector2(random.randf_range(0.,180.),random.randf_range(0.,58.))
  if i<graph.blocking_rects.size():
   var rect=graph.blocking_rects[i]
   start=rect.position;end=Vector2(rect.end.x,rect.position.y)
  check(Nav._segment_open(b,graph.blocking_rects,start,end,graph.blocker_tree)==OldNav._segment_open(b,graph.blocking_rects,start,end),"exact segment "+str(i))
 for vehicle in b.vehicles.values():
  for point in Body.cleared_corners(vehicle,0.):
   check(Body.contains_point(vehicle,point)==OldBody.contains_point(vehicle,point),"cached body corner")
  for i in range(80):
   var point=vehicle.battle_position+Vector2(random.randf_range(-8.,8.),random.randf_range(-8.,8.))
   check(Body.contains_point(vehicle,point)==OldBody.contains_point(vehicle,point),"cached body containment")
 for i in range(4000):
  var start=Vector2(random.randf_range(-1.,181.),random.randf_range(-1.,59.))
  var finish=Vector2(random.randf_range(-1.,181.),random.randf_range(-1.,59.))
  if i%4==0:finish.x=start.x+0.000001
  if i%4==1:finish.y=start.y+0.000001
  if i<graph.blocking_rects.size():start=graph.blocking_rects[i].position;finish=graph.blocking_rects[i].end
  var current=LOS._trace_segment(b.battlefield_geometry,start,finish,"source","target")
  var reference=OldLOS._trace_segment(b.battlefield_geometry,start,finish,"source","target")
  check(current.success==reference.success and current.has_line_of_sight==reference.has_line_of_sight and current.blocking_obstacle_id==reference.blocking_obstacle_id,"exact indexed LOS "+str(i))
 Body.end_runtime_collision_scope(collision_scope)
 check(Body._runtime_poses.is_empty(),"collision scope released")
 b.end_geometry_validation_scope()
 # Compare uncached bounded queries against the original full graph attachment.
 for i in range(100):
  var start=Vector2(random.randf_range(4.,176.),random.randf_range(14.,43.))
  var finish=Vector2(random.randf_range(4.,176.),random.randf_range(14.,43.))
  if i<10:start=graph.nodes[i];finish=graph.nodes[graph.nodes.size()-1-i]
  if not Nav._is_legal_candidate(b,start) or not Nav._is_legal_candidate(b,finish):continue
  graph.set_meta("endpoint_connections",{});graph.set_meta("endpoint_visibility",{})
  var current=Nav.find_path(b,start,finish)
  var reference=OldNav.find_path(b,start,finish)
  for property in current.get_property_list():
   if int(property.usage)&PROPERTY_USAGE_SCRIPT_VARIABLE:
    check(current.get(property.name)==reference.get(property.name),"exact route "+str(i)+":"+property.name)
 # Existing geometry revision invalidates the indexed topology.
 var old_graph=graph
 b.battlefield_geometry.content_revision+=1
 graph=Nav._ensure_static_graph(b)
 check(graph!=old_graph and not graph.blocker_tree.is_empty(),"topology invalidation")
 var side_ids=b.sides.keys()
 for step in range(120):
  for id in b.participants:
   var p=b.participants[id];var q=z.battle.participants[id]
   var position=Vector2(random.randf_range(35.,155.),random.randf_range(14.,43.))
   var alive=random.randf()>.1
   p.battle_position=position;q.battle_position=position;p.is_alive=alive;q.is_alive=alive
   p.has_battle_position=step%13!=0;q.has_battle_position=p.has_battle_position
   p.side_id=side_ids[random.randi_range(0,1)];q.side_id=p.side_id
   if step%17==0:p.side_id="";q.side_id=""
   if step%19==0:p.battle_position=Vector2(NAN,1.);q.battle_position=p.battle_position
   if step%7==0:
    p.player_priority_target_id=b.participants.keys()[random.randi_range(0,b.participants.size()-1)]
    q.player_priority_target_id=p.player_priority_target_id
  b.begin_geometry_validation_scope();z.battle.begin_geometry_validation_scope()
  var first=Targets.advance(b);var second=OldTargets.advance(z.battle)
  b.end_geometry_validation_scope();z.battle.end_geometry_validation_scope()
  check(first.success==second.success and target_snapshot(b)==target_snapshot(z.battle),"targets and priority "+str(step))
 var unit=b.participants.values()[0]
 unit.is_alive=true
 var baseline=profile_snapshot(Weapons.for_participant(unit))
 var outer=Weapons.begin_runtime_profile_scope(b.participants)
 check(profile_snapshot(Weapons.for_participant(unit))==baseline,"scoped profile")
 var inner=Weapons.begin_runtime_profile_scope(z.battle.participants)
 Weapons.end_runtime_profile_scope(inner)
 check(profile_snapshot(Weapons.for_participant(unit))==baseline,"nested profile scope")
 Weapons.end_runtime_profile_scope(outer)
 check(Weapons._runtime_profiles.is_empty(),"scope released")
 for tier in [1,2,3]:
  unit.unit_tier=tier
  var expected=profile_snapshot(Weapons.for_participant(unit))
  var previous=Weapons.begin_runtime_profile_scope(b.participants)
  check(profile_snapshot(Weapons.for_participant(unit))==expected,"live tier refresh "+str(tier))
  Weapons.end_runtime_profile_scope(previous)
 check(Weapons.get_definition("rifle")!=Weapons.get_definition("rifle"),"public definition ownership")
 var role=Roles.for_participant(unit)
 var role_scope=Roles.begin_runtime_profile_scope(b.participants)
 var nested_roles=Roles.begin_runtime_profile_scope(z.battle.participants)
 Roles.end_runtime_profile_scope(nested_roles)
 var prepared_role=Roles.for_participant(unit)
 check(role.preferred_min_distance==prepared_role.preferred_min_distance and role.preferred_max_distance==prepared_role.preferred_max_distance,"nested role profile")
 Roles.end_runtime_profile_scope(role_scope)
 check(Roles._runtime_profiles.is_empty() and Roles.for_participant(unit)!=Roles.for_participant(unit),"role scope ownership")
 var stamp=b.navigation_topology_stamp()
 var ready=b.begin_runtime_readiness_scope()
 check(b.navigation_topology_stamp()==stamp,"prepared vehicle stamp")
 b.end_runtime_readiness_scope(ready)
 var vehicle=b.vehicles.values()[0];var position=vehicle.battle_position
 vehicle.battle_position+=Vector2(1.,0.)
 check(b.navigation_topology_stamp()!=stamp,"live vehicle stamp after scope")
 vehicle.battle_position=position
 var cache_b=BattleState.new()
 for i in range(17000):
  var point=Vector2(float(i),2.)
  cache_b.los_cache_store(point,Vector2.ZERO,true,"")
  cache_b.nav_cache_store(point,Vector2.ZERO,i%2==0)
 check(cache_b._los_cache.size()+cache_b._los_cache_previous.size()<=16384,"bounded LOS cache")
 check(cache_b._nav_cache.size()+cache_b._nav_cache_previous.size()<=8192,"bounded navigation cache")
 check(cache_b.los_cache_lookup(Vector2(13000.,2.),Vector2.ZERO)!=null and cache_b.nav_cache_lookup(Vector2(13000.,2.),Vector2.ZERO)==1,"previous generation promotion")
 check(cache_b.los_cache_lookup(Vector2(16998.,2.),Vector2.ZERO)!=null and cache_b.nav_cache_lookup(Vector2(16998.,2.),Vector2.ZERO)==1,"cache rollover values")
 cache_b.battlefield_geometry=b.battlefield_geometry
 check(cache_b.los_cache_lookup(Vector2(16998.,2.),Vector2.ZERO)==null and cache_b.nav_cache_lookup(Vector2(16998.,2.),Vector2.ZERO)==-1,"topology clears both cache generations")
 a.runtime.free();z.runtime.free()
 var report={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/bridge_perf/headroom/focused.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("FOCUSED_DONE ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
