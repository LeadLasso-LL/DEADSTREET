extends SceneTree
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Orders=preload("res://battle/core/battle_force_command_service.gd")
const Victory=preload("res://battle/core/battle_victory_service.gd")
var reports=[]
var errors=[]
var hand_totals=[0,0]
func _initialize():call_deferred("run")
func run():
 for snipers in [false,true]:
  var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
  await process_frame
  var loadouts={"attacker":{},"defender":{"specialist":"mercer_dual_glock"}}
  for kind in ["pistol","smg","rifle","shotgun","sniper"]:
   loadouts.attacker[kind]=Weapons.default_model(kind);loadouts.defender[kind]=Weapons.default_model(kind)
  var result=Fixture.setup(runtime,loadouts,snipers,6104 if snipers else 6103)
  if not result.has("battle"):errors.append(result);runtime.queue_free();await process_frame;continue
  var b=result.battle
  var specialists=0
  for p in b.participants.values():
   if not p.specialist_id.is_empty():
    specialists+=1
    if p.faction_id!="rival_gang" or p.weapon_state.ammo_in_magazine!=24:errors.append("invalid specialist setup")
  if specialists!=1:errors.append("fixture must contain exactly one selected specialist")
  runtime.skip_battle_cinematics=true
  var begun=Fixture.begin_review(runtime,b)
  if begun==null or not begun.success:errors.append("begin failed");runtime.queue_free();await process_frame;continue
  for time_value in [120.,3600.,86400.]:
   b.elapsed_time_seconds=time_value
   var terminal=Victory.resolve_if_terminal(b)
   if terminal.resolved or b.battle_phase!="active":errors.append("elapsed time resolved a living battle")
  b.elapsed_time_seconds=0.
  for id in b.get_sorted_tactical_force_ids():
   if b.get_tactical_force(id).side_id==b.attacker_side_id:Orders.set_command(b,id,"push")
  var seen={};var hands=[0,0];var shots=0
  # Diagnostic observation budget only; never force a winner at the cutoff.
  for tick in range(7200):
   if b.battle_phase!="active":break
   var advanced=Runtime.advance(b,.05)
   if not advanced.success:errors.append(advanced.error_code);break
   for event in b.combat_feedback_events:
    if seen.has(event.sequence_id):continue
    seen[event.sequence_id]=true;shots+=1
    if not b.get_participant(event.source_participant_id).specialist_id.is_empty():
     hands[event.weapon_hand]+=1;hand_totals[event.weapon_hand]+=1
   if tick%20==0:await process_frame
  reports.append({"snipers":snipers,"phase":b.battle_phase,"seconds":b.elapsed_time_seconds,"winner":b.get_winning_side_id(),"shots":shots,"specialist_hands":hands,"observation_cutoff":b.battle_phase=="active"})
  print("MERCER_BATTLE ",JSON.stringify(reports.back()))
  runtime.queue_free();await process_frame;await process_frame
 if hand_totals[0]==0 or hand_totals[1]==0:errors.append("live battles did not exercise both pistols")
 var report={"errors":errors,"battles":reports}
 FileAccess.open("res://tools/faction_design/mercer_battles.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("MERCER_BATTLES_COMPLETE ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
