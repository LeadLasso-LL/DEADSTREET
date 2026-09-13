extends SceneTree
const Eval=preload("res://battle/combat/battle_combat_cover_evaluation_service.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const OldRuntime=preload("res://tools/bridge_perf/cover_close/runtime_oracle.gd")
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
 var fixture=make_fixture(false)
 check(not fixture.is_empty(),"fixture")
 if fixture.is_empty():quit(1);return
 var b=fixture.battle
 var p=b.participants.values()[0]
 var hostile=b.participants.values().back()
 var original_position=hostile.battle_position
 b.begin_geometry_validation_scope()
 var slots=b.battlefield_geometry.get_sorted_cover_slot_ids()
 for id in slots:
  var slot=b.battlefield_geometry.get_cover_slot(id)
  var occupied=slot.occupied_by_participant_id
  var reserved=slot.reserved_by_participant_id
  for state in range(4):
   slot.occupied_by_participant_id=[occupied,"",p.participant_id,"other"][state]
   slot.reserved_by_participant_id=[reserved,"other","",""][state]
   for direction in [-1.,0.,1.]:
    hostile.battle_position=slot.position+slot.facing_direction*direction*12.
    var full=Eval.evaluate_slot(b,p,slot,hostile,false,false,INF)
    check(Eval.slot_is_legal_and_protective(p,slot,hostile)==(full.legal and full.has_useful_direction),"cover predicate "+id+str(state)+str(direction))
  slot.occupied_by_participant_id=occupied;slot.reserved_by_participant_id=reserved
 hostile.battle_position=original_position
 var slot=b.battlefield_geometry.get_cover_slot(slots[0])
 check(not Eval.slot_is_legal_and_protective(null,slot,hostile),"null source")
 check(not Eval.slot_is_legal_and_protective(p,null,hostile),"null slot")
 check(not Eval.slot_is_legal_and_protective(p,slot,null),"null threat")
 hostile.has_battle_position=false
 check(not Eval.slot_is_legal_and_protective(p,slot,hostile),"unpositioned threat")
 hostile.has_battle_position=true
 hostile.battle_position=Vector2(NAN,0.)
 check(not Eval.slot_is_legal_and_protective(p,slot,hostile),"invalid threat position")
 hostile.battle_position=original_position
 var started=Time.get_ticks_usec()
 for i in range(3000):Eval.evaluate_slot(b,p,slot,hostile,false,false,INF)
 var old_us=Time.get_ticks_usec()-started
 started=Time.get_ticks_usec()
 for i in range(3000):Eval.slot_is_legal_and_protective(p,slot,hostile)
 var new_us=Time.get_ticks_usec()-started
 b.end_geometry_validation_scope()
 fixture.runtime.free()
 var report={"checks":checks,"errors":errors,"full_query_ms":old_us/1000.,"predicate_ms":new_us/1000.}
 FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/bridge_perf/cover_close/predicate.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("COVER_CHECKS ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
