extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Strength=preload("res://battle/ai/battle_relative_strength.gd")
const Tactics=preload("res://battle/ai/battle_adaptive_tactics.gd")
const Commands=preload("res://battle/core/battle_force_command_service.gd")
var checks=0
var problems=[]
func check(ok: bool,message: String):
 checks+=1
 if not ok:problems.append(message)
func _initialize():call_deferred("run")
func run():
 var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime);await process_frame
 var result=Scenario.setup(runtime,2002)
 check(result.has("battle"),"legal 4v4 setup")
 if not result.has("battle"):print(result);quit(1);return
 var b=result.battle
 var p=b.get_participant("player_soldier")
 var initial=Strength.unit_power(p)
 p.vitality*=.5;check(Strength.unit_power(p)<initial,"health loss lowers strength")
 p.is_wounded=true;check(Strength.unit_power(p)<initial*.6,"wounds lower capability")
 p.is_alive=false;check(Strength.unit_power(p)==0.,"dead units contribute zero")
 p.is_alive=true;p.is_wounded=false;p.vitality=1.5
 p.weapon_state.is_reloading=true;check(Strength.unit_power(p)<initial,"reload reduces readiness")
 p.weapon_state.is_reloading=false
 var s=Strength.evaluate(b)
 check(absf(float(s.shares.attacker)+float(s.shares.defender)-1.)<.00001,"complementary meter")
 check(s==Strength.evaluate(b),"deterministic observation")
 var enemy_force
 for f in b.tactical_forces.values():
  if f.side_id==b.defender_side_id:enemy_force=f
 check(enemy_force!=null,"defender force found")
 var player_command=""
 for f in b.tactical_forces.values():
  if f.side_id==b.attacker_side_id:player_command=f.command_id
 # Same scene, casualty changes only: time alone never selects the counterattack.
 for i in range(8):b.elapsed_time_seconds=float(i)*.5;Tactics.advance(b,.5)
 check(enemy_force.command_id=="hold","balanced battle holds")
 var n=0
 for q in b.participants.values():
  if q.side_id==b.attacker_side_id:
   if n<2:q.is_alive=false;q.vitality=0.
   n+=1
 b.elapsed_time_seconds=4.;Tactics.advance(b,.5)
 check(enemy_force.command_id=="hold","advantage requires confirmation")
 for i in range(1,8):b.elapsed_time_seconds=4.+i*.5;Tactics.advance(b,.5)
 check(enemy_force.command_id=="push","sustained casualty advantage selects Push")
 check(not b.strength_events.is_empty(),"decision has evidence record")
 for f in b.tactical_forces.values():
  if f.side_id==b.attacker_side_id:check(f.command_id==player_command,"player group command preserved")
 var defender=b.get_participant("rival_soldier_shotgun")
 b.strength_snapshot.local[defender.participant_id]=.2
 check(not Tactics.may_advance(b,defender),"local disadvantage blocks reckless advance")
 b.strength_snapshot.local[defender.participant_id]=.8;b.strength_snapshot.support[defender.participant_id]=0
 check(not Tactics.may_advance(b,defender),"isolated unit does not rush two enemies")
 Commands.set_command(b,enemy_force.tactical_force_id,"hold")
 for i in range(10):b.elapsed_time_seconds=10.+i*.5;Tactics.advance(b,.5)
 check(enemy_force.command_id=="hold" and enemy_force.has_explicit_command,"explicit Hold overrides adaptive advantage")
 Commands.set_command(b,enemy_force.tactical_force_id,"push")
 check(enemy_force.has_explicit_command,"explicit identical command retains authority")
 # A heavily outmatched AI selects tactical Fall Back, not a campaign withdrawal.
 enemy_force.has_explicit_command=false;enemy_force.command_id="hold";b.strength_memory.clear()
 for q in b.participants.values():q.is_alive=true;q.vitality=1.5;q.is_wounded=false
 n=0
 for q in b.participants.values():
  if q.side_id==b.defender_side_id:
   if n<3:q.is_alive=false;q.vitality=0.
   n+=1
 for i in range(10):b.elapsed_time_seconds=20.+i*.5;Tactics.advance(b,.5)
 check(enemy_force.command_id=="fall_back","severe disadvantage selects tactical fallback")
 var count=b.strength_events.size();Tactics.advance(b,0.);check(b.strength_events.size()==count,"zero delta never advances decisions")
 print("STRENGTH_VALIDATION checks=",checks," problems=",problems)
 DirAccess.make_dir_recursive_absolute("res://tools/strength_review/results")
 FileAccess.open("res://tools/strength_review/results/validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"problems":problems},"  "))
 runtime.queue_free();await process_frame;await process_frame;quit(0 if problems.is_empty() else 1)
