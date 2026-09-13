extends SceneTree
const C=preload("res://battle/geometry/river_bridge_catalog.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const OldNav=preload("res://tools/bridge_perf/old_nav.gd")
const Spatial=preload("res://battle/geometry/battle_spatial_service.gd")
const OldSpatial=preload("res://tools/bridge_perf/old_spatial.gd")
const LOS=preload("res://battle/combat/battle_line_of_sight_service.gd")
const OldLOS=preload("res://tools/bridge_perf/old_los.gd")
class View extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var errors=[];var checks=0
func check(ok,label):
 checks+=1
 if not ok:errors.append(label);printerr("PERF_CHECK_FAIL ",label)
func length_of(points):
 var value=0.
 for i in range(1,points.size()):value+=points[i-1].distance_to(points[i])
 return value
func _initialize():call_deferred("run")
func run():
 var r=load("res://gameplay/gameplay_runtime.gd").new();r.game_state=load("res://gameplay/starter_world_service.gd").create()
 r.game_flow_controller=load("res://core/game_flow_controller.gd").create(r.game_state).controller
 var view=View.new();view.name="TacticalBattleView";r.add_child(view)
 var c=Cases.make(8,8,["aegis","vigil"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor"]
 var setup=Fixture.setup(r,c,false,734,true)
 check(setup.has("battle"),"fixture")
 if not setup.has("battle"):quit(1);return
 var b=setup.battle;var g=b.battlefield_geometry

 var Body=load("res://battle/vehicles/battle_vehicle_body_service.gd")
 var OldBody=load("res://tools/bridge_perf/next_pass/oracle_body.gd")
 var report={}
 for round_index in range(3):
  for label in (["old","new"] if round_index%2==0 else ["new","old"]):
   var service=OldBody if label=="old" else Body
   var begun=Time.get_ticks_usec();var hits=0
   for i in range(1000):
    var point=Vector2(3.+float((i*29)%174),7.+float((i*13)%44))
    for vehicle in b.vehicles.values():
     if service.contains_point(vehicle,point):hits+=1
     if not is_inf(service.segment_entry_t(vehicle,point,Vector2(.5,.1))):hits+=1
   report[label+str(round_index)]={"ms":(Time.get_ticks_usec()-begun)/1000.,"hits":hits}
 print("MICRO_BODY ",JSON.stringify(report))
 var ids=[]
 for unit in b.participants.values():ids.append([unit.weapon_type,unit.weapon_model_id,unit.unit_tier])
 print("LOADOUTS ",JSON.stringify(ids))
 FileAccess.open("res://tools/bridge_perf/next_pass/micro.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 r.free();quit()
