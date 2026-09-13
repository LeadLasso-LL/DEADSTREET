extends SceneTree
const Scenarios=preload("res://gameplay/vehicle_encounter_scenarios.gd")
const Service=preload("res://campaign/vehicles/vehicle_encounter_service.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Starter=preload("res://gameplay/starter_world_service.gd")
class HeadlessView extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var checks=0
var errors=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);printerr("BLOCKADE_FAIL ",message)
func run():
 var f=Scenarios.new();f.reset();var s=f.service
 check(s.blockade_strength("gate")=="light" and s.blockade_cover_count("gate")==0,"baseline light checkpoint")
 check(f.run(13).success,"Roadwarden station")
 check(is_equal_approx(s.vehicle("lab","roadwarden").movement_left,3.2),"deployment cost")
 check(s.blockade_strength("gate")=="fortified" and s.blockade_cover_count("gate")==2,"live fortification and cover")
 var before=s.to_dict();check(not s.travel_road("lab","roadwarden","exit").success and s.to_dict()==before,"posted truck cannot travel")
 var stop=f.run(13);check(not stop.success and stop.battle_required and stop.cover_barriers==2,"Leviathan requires battle")
 check(s.data.journeys.intruder.used.is_empty() and s.data.heat.is_empty(),"blocked breach consumes no charge or heat")
 check(f.battle_context(13).kind=="lockdown","lockdown battle available")
 var restored=Service.new();check(restored.from_dict(JSON.parse_string(JSON.stringify(s.to_dict()))),"save post")
 check(restored.blockade_strength("gate")=="fortified","save retains fortification")
 check(f.run(13,true).success,"withdraw truck")
 check(s.blockade_strength("gate")=="light" and s.blockade_cover_count("gate")==0,"withdraw removes both effects")
 check(f.battle_context(13).is_empty(),"withdraw removes battle cover launch")
 check(not s.can_move("lab","roadwarden"),"withdrawal ends movement")
 check(s.stop_at_blockade("intruder","intruder_truck","gate").success,"light blockade can be breached after withdrawal")
 s.advance_turn();check(s.travel_road("lab","roadwarden","exit").success,"withdraw resumes next turn")
 for change in ["owner","crew","position","inactive","lost","closed"]:
  f.reset();s=f.service;f.run(13)
  match change:
   "owner":s.data.blockades.gate.owner="enemy"
   "crew":s.vehicle("lab","roadwarden").occupants=["driver"]
   "position":s.vehicle("lab","roadwarden").road_node="exit"
   "inactive":s.data.blockades.gate.status="destroyed"
   "lost":s.vehicle("lab","roadwarden").available=false
   "closed":s.data.journeys.lab.closed=true
  check(s.blockade_cover_count("gate")==0 and s.blockade_strength("gate")!="fortified","lost support: "+change)
 f.reset();s=f.service
 for bad in ["foreign","uncrewed","remote","ordinary","budget"]:
  f.reset();s=f.service;var id="roadwarden"
  match bad:
   "foreign":s.data.blockades.gate.owner="enemy"
   "uncrewed":s.vehicle("lab",id).occupants=[]
   "remote":s.vehicle("lab",id).road_node="far"
   "ordinary":id="nocturne"
   "budget":s.vehicle("lab",id).movement_left=.5
  before=s.to_dict();check(not s.station_blockade("lab",id,"gate").success and s.to_dict()==before,"invalid station atomic: "+bad)
 f.reset();s=f.service;check(f.run(14).success,"Bloodhound station")
 check(s.blockade_strength("gate")=="light","Bloodhound does not fortify")
 before=s.to_dict();check(not f.run(14,true).success and before==s.to_dict(),"disconnected convoy rejected")
 var hit=f.run(14);check(hit.success and hit.battle_required and not hit.automatic_victory,"pursuit queues battle")
 var v=s.vehicle("lab","bloodhound");check(v.post=="" and v.road_node=="detour" and is_equal_approx(v.movement_left,4.1),"pursuit pays distance and leaves post")
 check(not s.can_move("lab","bloodhound") and not s.can_move("detour","detour_truck"),"both sides await battle")
 var e=s.data.blockade_encounters[hit.encounter_id];check(e.status=="pending" and e.winner=="" and e.loot.is_empty(),"no automatic victory or loot")
 check(e.attacker_crew.size()==5 and e.defender_crew.size()==5,"only actual convoy occupants in battle")
 restored=Service.new();check(restored.from_dict(JSON.parse_string(JSON.stringify(s.to_dict()))),"save pursuit")
 check(restored.data.blockade_encounters[hit.encounter_id].status=="pending" and not restored.can_move("lab","bloodhound"),"save retains pending battle")
 before=s.to_dict();check(not s.pursue_convoy("lab","bloodhound","detour").success and s.to_dict()==before,"no repeat interception")
 var survivors={"bloodhound":v.occupants.duplicate(),"detour_truck":s.vehicle("detour","detour_truck").occupants.duplicate()}
 before=s.to_dict();check(not s.finish_pursuit(hit.encounter_id,"player",{"bloodhound":["invented"]}).success and s.to_dict()==before,"bad battle result atomic")
 check(s.finish_pursuit(hit.encounter_id,"player",survivors).success,"explicit battle settlement")
 check(not s.can_move("lab","bloodhound"),"settlement grants no travel")
 before=s.to_dict();check(not s.finish_pursuit(hit.encounter_id,"player",survivors).success and s.to_dict()==before,"no double settlement")
 # Reposting/reloading cannot reset the per-vehicle turn charge.
 v.post="gate";v.road_node="checkpoint";v.ended_turn=-1
 check(not s.pursue_convoy("lab","bloodhound","detour").success,"turn charge survives repost")
 restored=Service.new();restored.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())))
 check(not restored.pursue_convoy("lab","bloodhound","detour").success,"turn charge survives reload")
 s.advance_turn();check(s.pursue_convoy("lab","bloodhound","detour").success,"fresh next-turn pursuit")
 for bad in ["friendly","no_road","too_far","pending","crew","split","negative"]:
  f.reset();s=f.service;f.run(14)
  match bad:
   "friendly":s.data.journeys.detour.owner="player"
   "no_road":s.data.roads=[]
   "too_far":s.data.roads[-2].distance=99.
   "pending":s.vehicle("detour","detour_truck").encounter="other_battle"
   "crew":s.vehicle("lab","bloodhound").occupants=["driver"]
   "split":s.data.journeys.detour.vehicles["split"]={"model":"bayou","occupants":["split_driver"],"road_node":"elsewhere","ended_turn":-1}
   "negative":s.data.roads[-2].distance=-1.
  before=s.to_dict();check(not s.pursue_convoy("lab","bloodhound","detour").success and s.to_dict()==before,"invalid pursuit atomic: "+bad)
 f.reset();var legacy=f.service.to_dict()
 for key in ["blockades","pursuit_uses","blockade_encounters"]:legacy.erase(key)
 check(Service.new().from_dict(legacy),"old snapshots migrate")
 var lab=load("res://gameplay/vehicle_encounter_lab.gd").new();root.add_child(lab);await process_frame
 for index in [13,14]:
  lab.scenarios.reset();lab.picker.select(index);lab.refresh();check(lab.play_button.disabled,"no premature battle button")
  lab.execute(false);lab.execute(false);check(not lab.play_button.disabled,"play battle enabled")
  var context=lab.scenarios.battle_context(index);var runtime=load("res://gameplay/gameplay_runtime.gd").new()
  runtime.game_state=Starter.create();runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
  var view=HeadlessView.new();view.name="TacticalBattleView";runtime.add_child(view)
  var loadouts={"attacker":{"faction":"kurgan","vehicles":context.attacker_models},"defender":{"faction":"trc"},"blockade_encounter":context}
  var result=Fixture.setup(runtime,loadouts,false,9635,true)
  check(result.has("battle"),"real battle setup: "+str(result.get("error","")))
  if result.has("battle"):
   var b=result.battle;check(b.participants.size()==10 and b.battlefield_geometry.is_valid(),"normal 5v5 geometry")
   check(b.battlefield_geometry.cover_objects.has("roadwarden_screen_0")== (index==13),"cover only for deployed Roadwarden")
   if index==13:check(b.has_vehicle("checkpoint_roadwarden"),"stationed Roadwarden rendered and physical")
   var director=load("res://gameplay/tactical_battle_presentation.gd").new();director.view=view;director.battle=b;view.deployment_controller=runtime.tactical_deployment_controller;director.begin_arrival()
   check(director.last_path_errors.is_empty(),"blockade battle arrival paths");director.free()
   var begun=Fixture.begin_review(runtime,b);check(begun!=null and begun.success,"normal battle starts")
  runtime.free();await process_frame
 lab.queue_free();await process_frame
 var report={"checks":checks,"errors":errors};var out=FileAccess.open("res://tools/vehicle_fleet/validation_blockades.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"  "));print("BLOCKADE_VALIDATION ",report);quit(0 if errors.is_empty() else 1)
