extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const OldRuntime=preload("res://tools/bridge_perf/slow_frames/runtime_oracle.gd")
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
func run():
 var cases=[]
 for close_case in [false,true]:
  var a=make_fixture(close_case);var z=make_fixture(close_case)
  check(not a.is_empty() and not z.is_empty(),"fixtures created")
  if a.is_empty() or z.is_empty():quit(1);return
  var steps=0;var old_us=0;var new_us=0
  for i in range(600 if not close_case else 200):
   var t=Time.get_ticks_usec();var old_result=OldRuntime.advance(z.battle,.05);old_us+=Time.get_ticks_usec()-t
   t=Time.get_ticks_usec();var new_result=Runtime.advance(a.battle,.05);new_us+=Time.get_ticks_usec()-t
   check(old_result.success and new_result.success,"runtime success "+str(i))
   check(snapshot(a.battle)==snapshot(z.battle),"exact battle state "+str(close_case)+":"+str(i))
   steps+=1
   if not errors.is_empty() or a.battle.battle_phase!="active":break
  if close_case:check(a.battle.battle_phase=="resolved","terminal battle resolved")
  cases.append({"terminal_fixture":close_case,"steps":steps,"phase":a.battle.battle_phase,"old_runtime_ms":old_us/1000.,"new_runtime_ms":new_us/1000.})
  a.runtime.free();z.runtime.free()
 var report={"checks":checks,"errors":errors,"cases":cases}
 FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/bridge_perf/slow_frames/target_exact_replay.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("REPLAY_RESULT ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
