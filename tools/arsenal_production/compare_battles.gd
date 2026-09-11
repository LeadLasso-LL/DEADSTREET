extends SceneTree
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Orders=preload("res://battle/core/battle_force_command_service.gd")
const Move=preload("res://battle/runtime/battle_movement_service.gd")
var reports=[]
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func run():
 var quick=OS.get_cmdline_user_args().has("--quick")
 for sniper_test in ([false] if quick else [false,true]):
  for index in range(1 if quick else 6):
   var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
   await process_frame
   var loadouts={"attacker":{},"defender":{}}
   for kind in ["pistol","smg","rifle","shotgun","sniper"]:
    var ids=Weapons.models_for_class(kind)
    loadouts.attacker[kind]=ids[index];loadouts.defender[kind]=ids[(index+1)%6]
   var result=Fixture.setup(runtime,loadouts,sniper_test,4200+index)
   if not result.has("battle"):errors.append(result);runtime.queue_free();await process_frame;continue
   var b=result.battle
   for p in b.participants.values():
    checks+=1
    if not p.has_occupied_cover_slot():errors.append("Starting unit lacks cover "+p.participant_id)
   runtime.skip_battle_cinematics=true
   var begun=Fixture.begin_review(runtime, b)
   if begun==null or not begun.success:errors.append("begin "+str(begun));runtime.queue_free();await process_frame;continue
   for id in b.get_sorted_tactical_force_ids():
    if b.get_tactical_force(id).side_id==b.attacker_side_id:Orders.set_command(b,id,"push")
   var shots={};var seen={};var max_hustle=1.;var start=Time.get_ticks_msec();var moved_sniper_shots=0
   for tick in range(2400):
    if b.battle_phase!="active":break
    var advanced=Runtime.advance(b,.05)
    if not advanced.success:errors.append("advance "+advanced.error_code);break
    for p in b.participants.values():max_hustle=maxf(max_hustle,Move.cover_hustle_multiplier(b,p))
    for e in b.combat_feedback_events:
     if seen.has(e.sequence_id):continue
     seen[e.sequence_id]=true;var p=b.get_participant(e.source_participant_id)
     shots[p.weapon_model_id]=int(shots.get(p.weapon_model_id,0))+1
     # Event position vs the previous frame's move is tested at the fire gate separately.
   var alive={};var models={};var vitality={};var positions={}
   for p in b.participants.values():
    alive[p.side_id]=int(alive.get(p.side_id,0))+(1 if p.is_alive else 0)
    models[p.participant_id]=p.weapon_model_id;vitality[p.participant_id]=p.vitality;positions[p.participant_id]={"at":str(p.battle_position),"mode":p.combat_move_mode,"intent":p.player_tactical_intent,"target":p.target_participant_id}
   reports.append({"snipers":sniper_test,"pair":index,"seed":4200+index,"duration":b.elapsed_time_seconds,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"alive":alive,"models":models,"shots":shots,"vitality":vitality,"positions":positions,"cover_hustle":max_hustle,"wall_ms":Time.get_ticks_msec()-start})
   if seen.is_empty():errors.append("No shots in battle "+str(index))
   print("ARSENAL_BATTLE ",sniper_test," ",index," ",b.battle_phase," seconds=",b.elapsed_time_seconds," shots=",seen.size()," alive=",alive)
   runtime.queue_free();await process_frame;await process_frame
 FileAccess.open("res://tools/arsenal_production/battle_comparison.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors,"battles":reports},"  "))
 print("ARSENAL_BATTLES_COMPLETE errors=",errors)
 quit(0 if errors.is_empty() else 1)
