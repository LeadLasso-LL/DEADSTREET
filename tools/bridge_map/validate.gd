extends SceneTree
const C=preload("res://battle/geometry/river_bridge_catalog.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
class View extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var errors=[]
var checks=0
var scenarios=[]
func check(ok: bool,label: String):
 checks+=1
 if not ok:errors.append(label);printerr("BRIDGE_FAIL ",label)
func runtime():
 var r=load("res://gameplay/gameplay_runtime.gd").new();r.game_state=load("res://gameplay/starter_world_service.gd").create()
 r.game_flow_controller=load("res://core/game_flow_controller.gd").create(r.game_state).controller
 var v=View.new();v.name="TacticalBattleView";r.add_child(v);return r
func _initialize():call_deferred("run")
func run():
 check(C.build().is_valid(),"valid definition")
 for spec in [[5,5,["bayou","bayou"],["interceptor","warden"]],[12,12,["lastlight"],["bulwark","warden"]],[1,1,["yardbird"],["yardbird"]],[12,12,["yardbird","yardbird","yardbird","yardbird","yardbird","yardbird","yardbird","yardbird","yardbird","yardbird","yardbird","yardbird"],["bayou","bayou","bayou"]]]:
  var config=Cases.make(spec[0],spec[1],spec[2]);config.map_id="river_bridge";config.defender.vehicles=spec[3]
  var original=config.duplicate(true);check(Config.validate(config).valid,"config "+str(spec[0]))
  var r=runtime();var setup=Fixture.setup(r,config,false,734,true)
  check(setup.has("battle"),"setup "+str(spec)+" "+str(setup.get("error","")))
  if setup.has("battle"):
   var b=setup.battle;var g=b.battlefield_geometry
   check(g.is_valid() and g.authored_layout_id==C.ID,"geometry")
   check(b.participants.size()==spec[0]+spec[1],"exact force size")
   check(b.vehicles.size()==spec[2].size()+spec[3].size(),"both selected convoys")
   check(b.arrival_choice=="west_approach","map-specific arrival")
   for v in b.vehicles.values():
    check(v.has_battle_position,"parked "+v.battle_vehicle_id)
    var expected=Vector2.RIGHT if v.side_id==b.attacker_side_id else Vector2.DOWN
    check(v.facing_direction.is_equal_approx(expected),"vehicle facing")
   for p in b.participants.values():
    check(p.has_battle_position and g.get_movement_blocking_obstacle_id_at(p.battle_position).is_empty() and Body.blocking_vehicle_id_at(b,p.battle_position).is_empty(),"unit placement "+p.participant_id)
    if p.side_id==b.attacker_side_id:
     var v=b.get_vehicle(p.transport_vehicle_id);var route=load("res://battle/vehicles/battle_vehicle_exit_service.gd").route(b,v,p.battle_position)
     check(not route.is_empty() and route.path.success,"arrival path "+p.participant_id)
   if spec[0]==5:
    for i in range(40):
     var from=Vector2(5+(i*29)%173,4+(i*7)%52);var to=Vector2(5+(i*43+60)%173,4+(i*11+13)%52)
     check(Nav.is_reachable(b,from,to)==Nav.find_path(b,from,to).success,"reachability matches full route "+str(i))
   # Each parallel infantry route connects the arrival to the roadblock.
   for y in [10.,18.5,27.8,38.,47.]:check(Nav.find_path(b,Vector2(42,y),Vector2(141,y)).success,"crossing route "+str(y))
   check(not Nav.find_path(b,Vector2(42,18),Vector2(80,3)).success,"river excluded")
   g.width=-1
   check(not Nav.find_path(b,Vector2(42,18),Vector2(80,18)).success,"direct geometry edit revalidated between queries")
   g.width=C.SIZE.x
   check(not load("res://battle/vehicles/battle_arrival_service.gd").choose(b,"close"),"no Harold arrival on bridge")
   var start=Fixture.begin_review(r,b);check(start!=null and start.success,"normal combat begins")
   check(config==original,"setup read-only")
   scenarios.append({"units":b.participants.size(),"vehicles":b.vehicles.size(),"covers":g.cover_slots.size()})
  r.free()
 DirAccess.make_dir_recursive_absolute("res://tools/bridge_map/results")
 FileAccess.open("res://tools/bridge_map/results/validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors,"scenarios":scenarios},"  "))
 print("BRIDGE_VALIDATION ",checks," ",errors);quit(0 if errors.is_empty() else 1)
