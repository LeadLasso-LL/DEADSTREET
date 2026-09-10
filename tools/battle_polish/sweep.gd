extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
var runtime
var b
var tests=[{"seed":2002,"order":"push"},{"seed":2003,"order":"push"},{"seed":2005,"order":"focus_right"},{"seed":2011,"order":"hold"}]
var index=0
var reports=[]
var active=false
var seen={}
var samples=[]
var last_shot=0.
var max_quiet=0.
func _initialize():call_deferred("start")
func start():
 runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime);await process_frame
 var result=Scenario.setup(runtime,tests[index].seed)
 if not result.has("battle"):push_error(str(result));quit(1);return
 b=result.battle
 for p in b.participants.values():
  if p.side_id==b.attacker_side_id:p.clear_player_tactical_intent()
 Scenario.command(b,b.attacker_side_id,tests[index].order)
 seen={};samples=[];last_shot=0.;max_quiet=0.;active=true
func _process(_dt):
 if not active:return false
 for i in range(20):
  Runtime.advance(b,1./30.)
  for e in b.combat_feedback_events:
   if not seen.has(e.sequence_id):
    max_quiet=maxf(max_quiet,b.elapsed_time_seconds-last_shot);last_shot=b.elapsed_time_seconds;seen[e.sequence_id]=true
  if samples.size()<=int(b.elapsed_time_seconds/15.):
   var units=[]
   for p in b.participants.values():
    units.append({"id":p.participant_id,"alive":p.is_alive,"wounded":p.is_wounded,"hp":p.vitality,"pos":str(p.battle_position),"cover":p.occupied_cover_slot_id,"intent":p.player_tactical_intent,"target":p.target_participant_id,"fire":str(preload("res://battle/combat/battle_fire_control_service.gd").evaluate_participant_target_eligibility(b,p.participant_id,p.target_participant_id).rejection_code) if p.is_alive and not p.target_participant_id.is_empty() else "", "mode":p.combat_move_mode,"decision":p.combat_decision_key,"defend":p.defend_position})
   samples.append({"time":b.elapsed_time_seconds,"units":units})
  if b.battle_phase=="resolved" or b.elapsed_time_seconds>=180.:
   active=false;call_deferred("finish");break
 return false
func finish():
 var r={"seed":tests[index].seed,"order":tests[index].order,"time":b.elapsed_time_seconds,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"shots":seen.size(),"max_quiet":maxf(max_quiet,b.elapsed_time_seconds-last_shot),"decisions":b.strength_events,"samples":samples}
 reports.append(r);print("SWEEP ",JSON.stringify(r))
 runtime.queue_free();await process_frame;await process_frame
 index+=1
 if index<tests.size():start()
 else:
  DirAccess.make_dir_recursive_absolute("res://tools/battle_polish/results")
  FileAccess.open("res://tools/battle_polish/results/sweep.json",FileAccess.WRITE).store_string(JSON.stringify(reports,"  "));quit()
