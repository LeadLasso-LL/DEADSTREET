extends SceneTree
const Actor=preload("res://gameplay/tactical_actor_presenter.gd")
const OldActor=preload("res://tools/bridge_perf/headroom/oracle_actor.gd")
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

func actor_snapshot(actor):
 var rows=[]
 for id in actor._unit_nodes:
  var node=actor._unit_nodes[id];var body=node.get_node("body")
  var motion=actor._motion[id]
  rows.append([id,node.position,node.scale,node.modulate,body.animation,body.frame,motion["sequence"],motion["shot"],motion.get("shot_muzzle"),body.material.get_shader_parameter("wounded_stain") if body.material!=null else false])
 return rows
func bind_actor(actor):
 var container=Node2D.new();root.add_child(container)
 var bodies=Node2D.new();container.add_child(bodies)
 var units=Node2D.new();container.add_child(units)
 actor.bind_root(bodies,8.);actor.bind_unit_root(units)
 return container
func run():
 var fixture=make_fixture(false)
 check(not fixture.is_empty(),"visual fixture")
 if fixture.is_empty():quit(1);return
 var b=fixture.battle
 var current=Actor.new();var original=OldActor.new()
 var current_root=bind_actor(current);var original_root=bind_actor(original)
 current.sync_dynamic(b);original.sync_dynamic(b)
 check(actor_snapshot(current)==actor_snapshot(original),"initial visual state")
 var observed={}
 for i in range(600):
  var result=Runtime.advance(b,.05)
  check(result.success,"visual replay runtime")
  current.sync_dynamic(b);original.sync_dynamic(b)
  check(actor_snapshot(current)==actor_snapshot(original),"animation, transforms and muzzle "+str(i))
  for clip in current._unit_clips.values():observed[clip]=true
  if not errors.is_empty() or b.battle_phase!="active":break
 var report={"checks":checks,"errors":errors,"clips_observed":observed.keys(),"actors":current._unit_nodes.size(),"prepared_masks":current._blood_masks.size()}
 FileAccess.open("res://tools/bridge_perf/headroom/visual_checks.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 current_root.free();original_root.free();fixture.runtime.free()
 print("VISUAL_CHECKS ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
