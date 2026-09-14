extends SceneTree
const Director=preload("res://tools/tactical_controls/estate_director.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
class View extends Node2D:
 var _dusk_zoom=1.0
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate"
func _initialize():call_deferred("run")
func run():
 var seed_value=9146
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--seed="):seed_value=int(arg.trim_prefix("--seed="))
 var r=load("res://gameplay/gameplay_runtime.gd").new()
 r.game_state=load("res://gameplay/starter_world_service.gd").create()
 r.game_flow_controller=load("res://core/game_flow_controller.gd").create(r.game_state).controller
 var view=View.new();view.name="TacticalBattleView";r.add_child(view)
 var result=Fixture.setup(r,Director.config(),false,seed_value,true)
 if not result.has("battle"):printerr("RECORD_ERROR ",result);quit(1);return
 var b=result.battle
 var begin=Fixture.begin_review(r,b)
 if begin==null or not begin.success:printerr("RECORD_ERROR begin");quit(1);return
 var c=load("res://gameplay/tactical_orders_controller.gd").new();c.bind_session(r.get_current_session())
 var d=Director.new();d.setup(b,c)
 var snapshots=[]
 for i in range(30*100):
  if b.battle_phase!="active":break
  d.tick()
  var step=Runtime.advance(b,1./30.)
  if not step.success:printerr("RECORD_ERROR runtime ",step);quit(1);return
  if i%300==0:
   var sample={"time":b.elapsed_time_seconds,"trc":d.healthy(b.attacker_side_id).size(),"whittaker":d.healthy(b.defender_side_id).size(),"events":d.seen.size()}
   snapshots.append(sample);print("PACE ",JSON.stringify(sample))
 var positions=[]
 for unit in b.participants.values():
  if unit.is_alive and not unit.is_wounded:positions.append({"id":unit.participant_id,"at":str(unit.battle_position),"target":unit.target_participant_id,"nav":unit.navigation_source,"order":unit.player_tactical_intent,"defend":unit.defend_position,"anchor":str(unit.defend_position_anchor),"slot":unit.occupied_cover_slot_id,"feedback":unit.player_order_feedback})
 var report={"survivor_positions":positions,"seed":seed_value,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"duration":b.elapsed_time_seconds,"commands":d.log,"snapshots":snapshots}
 DirAccess.make_dir_recursive_absolute(out)
 FileAccess.open(out+"/probe.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("PROBE ",JSON.stringify(report))
 r.free();quit()
