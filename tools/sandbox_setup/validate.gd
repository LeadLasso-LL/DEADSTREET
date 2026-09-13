extends SceneTree
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Starter=preload("res://gameplay/starter_world_service.gd")
class HeadlessView extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var errors=[]
var checks=0
var scenarios=[]
func _initialize():call_deferred("run")
func check(value: bool,label: String):
 checks+=1
 if not value:errors.append(label);printerr("FLEXIBLE_FAIL ",label)
func headless_runtime():
 var runtime=load("res://gameplay/gameplay_runtime.gd").new()
 runtime.game_state=Starter.create();runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
 var view=HeadlessView.new();view.name="TacticalBattleView";runtime.add_child(view);return runtime
func run():
 var config=Cases.make(7,3)
 for faction in Config.Factions.all_ids():
  var proposed=config.duplicate(true);proposed.attacker.faction=faction
  check(Config.validate(proposed).valid,"faction unrestricted "+faction)
 for bad in ["empty","too_many","class","weapon","tier","fraction","armor","faction","drivers","seats","model","malformed","units_type","specialist"]:
  var invalid=config.duplicate(true)
  match bad:
   "empty":invalid.defender.units=[]
   "too_many":invalid.attacker.units.resize(13)
   "class":invalid.attacker.units[0]["class"]="tank"
   "weapon":invalid.attacker.units[0].weapon="ak47"
   "tier":invalid.attacker.units[0].tier=4
   "fraction":invalid.attacker.units[0].tier=1.5
   "armor":invalid.attacker.units[0].armor="unknown"
   "faction":invalid.attacker.faction="unknown"
   "drivers":invalid.attacker.vehicles=["bayou","bayou","bayou","bayou","bayou","bayou","bayou","bayou"]
   "seats":invalid.attacker.vehicles=["bayou"]
   "model":invalid.attacker.vehicles=["unknown"]
   "malformed":invalid.attacker.units[0]=null
   "units_type":invalid.attacker.units="invalid"
   "specialist":invalid.attacker.units[0].specialist="mercer_dual_glock"
  var before=invalid.duplicate(true)
  check(not Config.validate(invalid).valid,"reject "+bad);check(before==invalid,"validation read-only "+bad)
 var runtime=headless_runtime();var state_before=runtime.game_state.to_dict();config.attacker.vehicles=[]
 check(not Fixture.setup(runtime,config,false,42,true).has("battle") and runtime.game_state.to_dict()==state_before,"invalid launch leaves state untouched");runtime.free()
 for sizes in [[1,1],[7,3],[12,12],[3,9]]:
  config=Cases.make(sizes[0],sizes[1]);var snapshot=config.duplicate(true)
  runtime=headless_runtime();var result=Fixture.setup(runtime,config,false,719,true)
  check(result.has("battle"),"battle setup %s: %s"%[sizes,str(result.get("error",""))])
  if result.has("battle"):
   var b=result.battle
   check(b.participants.size()==sizes[0]+sizes[1],"exact roster count "+str(sizes))
   check(b.battlefield_geometry.is_valid(),"valid geometry "+str(sizes))
   var assigned={};var seen={"attacker":0,"defender":0}
   for p in b.participants.values():
    var side=p.side_id;var index=int(p.participant_id.get_slice("_",3))-1
    # Participant IDs use sandbox_<side>_unit_<number>.
    var row=config[side].units[index];seen[side]+=1
    check(p.identity.gang_archetype_id==config[side].faction,"faction identity "+p.participant_id)
    check(p.weapon_type==row["class"] and p.weapon_model_id==row.weapon,"individual weapon "+p.participant_id)
    check(p.unit_tier==int(row.tier) and p.armor_id==row.armor and is_equal_approx(p.max_vitality,1.5*(1.+Config.Armor.bonus(row.armor))),"individual tier/armor "+p.participant_id)
    check(p.has_battle_position and b.get_deployment_position_error(side,p.battle_position).is_empty(),"legal deployed unit "+p.participant_id)
    if side=="attacker":assigned[p.transport_vehicle_id]=int(assigned.get(p.transport_vehicle_id,0))+1
   check(seen.attacker==sizes[0] and seen.defender==sizes[1],"no starter extras "+str(sizes))
   for id in b.vehicles:
    check(assigned.get(id,0)>0 and assigned[id]<=Config.Models.model(b.vehicles[id].vehicle_type_id).unit_capacity,"real driver and legal seats "+id)
   var view=runtime.get_node("TacticalBattleView");view.deployment_controller=runtime.tactical_deployment_controller
   var director=load("res://gameplay/tactical_battle_presentation.gd").new();director.view=view;director.battle=b;director.begin_arrival()
   check(director.routes.size()==sizes[0]+sizes[1] and director.last_path_errors.is_empty(),"complete unobstructed arrival routes "+str(sizes));director.free()
   var started=Fixture.begin_review(runtime,b);check(started!=null and started.success,"start battle "+str(sizes))
   for i in range(20):load("res://battle/runtime/battle_runtime_service.gd").advance(b,.1)
   check(b.battle_phase in ["active","resolved"],"battle advances "+str(sizes))
   scenarios.append({"attacker":sizes[0],"defender":sizes[1],"participants":b.participants.size(),"vehicles":b.vehicles.size()})
  check(config==snapshot,"launch does not edit selection "+str(sizes));runtime.free();await process_frame
 # Largest transport and one driver per bicycle exercise both seat extremes.
 for fleet in [["lastlight"],["yardbird","yardbird","yardbird","yardbird","yardbird","yardbird"]]:
  if not Config.Models.has_model(fleet[0]):continue
  config=Cases.make(12 if fleet.size()==1 else 6,4,fleet);runtime=headless_runtime();var result=Fixture.setup(runtime,config,false,722,true)
  check(result.has("battle"),"transport extreme "+str(fleet)+": "+str(result.get("error","")));runtime.free();await process_frame
 var report={"checks":checks,"errors":errors,"scenarios":scenarios}
 DirAccess.make_dir_recursive_absolute("res://tools/sandbox_setup/results")
 FileAccess.open("res://tools/sandbox_setup/results/validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("FLEXIBLE_VALIDATION ",report);quit(0 if errors.is_empty() else 1)
