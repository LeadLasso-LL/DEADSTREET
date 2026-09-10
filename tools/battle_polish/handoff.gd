extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Bridge=preload("res://battle/core/battle_campaign_outcome_bridge_service.gd")
var checks=0
var problems=[]
func _initialize():call_deferred("run")
func verify(ok,message):
 checks+=1
 if not ok:problems.append(message)
func run():
 for attacker_wins in [false,true]:
  var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime);await process_frame
  var result=Scenario.setup(runtime,2002)
  verify(result.has("battle"),"handoff fixture setup")
  if result.has("battle"):
   var b=result.battle
   for p in b.participants.values():
    if (p.side_id==b.attacker_side_id)!=attacker_wins:p.is_alive=false;p.vitality=0.
   Runtime.advance(b,.01)
   verify(b.battle_phase=="resolved","fixture resolved")
   var applied=Bridge.apply(runtime.game_state,b)
   verify(applied.success,"existing outcome bridge accepts winner")
   var owner=runtime.game_state.get_map_location("rival_hq").owner_faction_id
   verify(owner==("player_gang" if attacker_wins else "rival_gang"),"HQ owner matches winner")
   verify(runtime.game_state.get_mission(b.mission_id).mission_state==("resolved_success" if attacker_wins else "resolved_failure"),"mission result matches winner")
   Bridge.apply(runtime.game_state,b)
   verify(runtime.game_state.get_map_location("rival_hq").owner_faction_id==owner,"repeat handoff preserves ownership")
  runtime.queue_free();await process_frame;await process_frame
 FileAccess.open("res://tools/battle_polish/results/handoff.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"problems":problems},"  "))
 print("HANDOFF_VALIDATION checks=",checks," problems=",problems);quit(0 if problems.is_empty() else 1)
