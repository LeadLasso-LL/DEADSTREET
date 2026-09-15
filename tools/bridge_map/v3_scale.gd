extends SceneTree
# Synthetic scale probe: adds ordinary combatants after standard sandbox setup.
# Does not change production roster limits, campaign data, art, or combat rules.
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Runtime=preload("res://tools/bridge_map/profile_runtime.gd")
const Participant=preload("res://battle/core/battle_participant.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
var reports=[]
func _initialize():call_deferred("run")
func add_units(b,total):
 for side_id in [b.attacker_side_id,b.defender_side_id]:
  var originals=[]
  for p in b.participants.values():
   if p.side_id==side_id:originals.append(p)
  var side=b.get_side(side_id);var force=b.get_tactical_force(originals[0].tactical_force_id)
  var points=[]
  # Fill the existing approaches, keeping every synthetic unit outside obstacles.
  for x in range(3,43,2):
   for y in range(11,48,2):
    var at=Vector2(x if side_id==b.attacker_side_id else 180-x,y)
    if not b.battlefield_geometry.get_movement_blocking_obstacle_id_at(at).is_empty() or not Body.blocking_vehicle_id_at(b,at).is_empty():continue
    var clear=true
    for existing in b.participants.values():
     if existing.has_battle_position and existing.battle_position.distance_to(at)<1.4:clear=false;break
    if clear:points.append(at)
  for i in range(originals.size(),total/2):
   if points.is_empty():return false
   var base=originals[i%originals.size()];var id="scale_%s_%03d"%[side_id,i]
   var p=Participant.new(id,id,base.faction_id,side_id,base.weapon_type,true,false,"",force.tactical_force_id)
   p.unit_tier=base.unit_tier;p.armor_id=base.armor_id;p.vitality=p.max_vitality
   p.identity=Identity.make(id,base.identity.gang_archetype_id,p.weapon_type)
   p.deployment_slot_id=base.deployment_slot_id;b.get_deployment_zone(p.deployment_slot_id).deployed_participant_ids.append(id)
   p.has_battle_position=true;p.battle_position=points.pop_front();p.defend_position=side_id==b.defender_side_id
   p.has_defend_position_anchor=p.defend_position;p.defend_position_anchor=p.battle_position
   b.add_participant(p);side.participant_ids.append(id)
   # Constructor supplies a valid default weapon for this ordinary class.
 return true
func run():
 root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
 for count in [16,64,128,256]:
  var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
  var c=Cases.make(8,8,["aegis","vigil"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor"]
  await scene.start_battle(false,c);scene.set_process(false)
  var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
  view.battle_presentation.skip_to_ready()
  var result=Fixture.begin_review(scene.runtime,b)
  if result==null or not result.success:printerr("SCALE_BEGIN_FAILED ",count);quit(1);return
  var added=add_units(b,count)
  if not added:printerr("SCALE_SETUP_FAILED ",count);quit(1);return
  view._dusk_zoom=.90;view._dusk_pan=Vector2(0,-150);view._frame_camera()
  await create_timer(2.).timeout
  var paused_fps=Engine.get_frames_per_second()
  for id in b.get_sorted_tactical_force_ids():
   if b.get_tactical_force(id).side_id==b.attacker_side_id:load("res://battle/core/battle_force_command_service.gd").set_command(b,id,"push")
  Runtime.timings.clear();Runtime.timing_counts.clear()
  var costs=[];var wall_start=Time.get_ticks_msec();var health=0.;var positions={}
  for p in b.participants.values():health+=p.vitality;positions[p.participant_id]=p.battle_position
  for i in range(120):
   var start=Time.get_ticks_usec();Runtime.advance(b,.05);costs.append((Time.get_ticks_usec()-start)/1000.)
   await process_frame
   if Time.get_ticks_msec()-wall_start>25000:break
  var elapsed=(Time.get_ticks_msec()-wall_start)/1000.;var moved=0;var end_health=0.;var living=0
  for p in b.participants.values():
   if p.battle_position.distance_to(positions[p.participant_id])>.5:moved+=1
   end_health+=p.vitality
   if p.is_alive:living+=1
  var sum=0.
  for cost in costs:sum+=cost
  costs.sort()
  var report={"units":b.participants.size(),"rendered_actors":view.actor_presenter._unit_nodes.size(),"living":living,"steps":costs.size(),"sim_seconds":costs.size()*.05,"wall_seconds":elapsed,"mean_update_ms":sum/costs.size(),"p95_update_ms":costs[int(costs.size()*.95)-1],"max_update_ms":costs.back(),"paused_fps":paused_fps,"loop_frames_per_second":costs.size()/elapsed,"moved_units":moved,"damage":health-end_health,"stages_ms":Runtime.timings.duplicate()}
  reports.append(report)
  DirAccess.make_dir_recursive_absolute("res://tools/bridge_map/v3_results")
  FileAccess.open("res://tools/bridge_map/v3_results/scale.json",FileAccess.WRITE).store_string(JSON.stringify(reports,"  "))
  print("BRIDGE_SCALE ",report)
  scene.queue_free();await process_frame;await process_frame
 quit()
