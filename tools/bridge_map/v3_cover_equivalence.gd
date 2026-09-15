extends SceneTree
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Before=preload("res://tools/bridge_map/v3_cover_oracle.gd")
const After=preload("res://battle/combat/battle_combat_cover_evaluation_service.gd")
var errors=[]
var checks=0
class View extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
func _initialize():call_deferred("run")
func ids(rows):
 var values=[]
 for row in rows:values.append(row.slot_id)
 return values
func run():
 var r=load("res://gameplay/gameplay_runtime.gd").new();r.game_state=load("res://gameplay/starter_world_service.gd").create()
 r.game_flow_controller=load("res://core/game_flow_controller.gd").create(r.game_state).controller
 var v=View.new();v.name="TacticalBattleView";r.add_child(v)
 var c=Cases.make(8,8,["aegis","vigil"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor"]
 var setup=Fixture.setup(r,c,false,734,true)
 if not setup.has("battle"):printerr(setup);quit(1);return
 var b=setup.battle;var units=b.participants.values();var p=units[0];var enemy=units.back()
 b.begin_geometry_validation_scope()
 for origin in [Vector2(35,18),Vector2(78,27),Vector2(115,38)]:
  p.battle_position=origin
  for radius in [0.,8.,28.,INF]:
   for kind in ["pistol","smg","shotgun","rifle","sniper"]:
    var a=Before.rank_healthy_role(b,p,enemy,kind,false,radius);var z=After.rank_healthy_role(b,p,enemy,kind,false,radius)
    checks+=1
    if ids(a)!=ids(z):errors.append("healthy %s %s %s"%[origin,radius,kind])
   for method in ["rank_closing_cover","rank_short_range_out_of_range_staging"]:
    var a=Before.new().call(method,b,p,enemy,"smg",radius);var z=After.new().call(method,b,p,enemy,"smg",radius)
    checks+=1
    if ids(a)!=ids(z):errors.append(method+str(origin)+str(radius))
   for require_range in [false,true]:
    var a=Before.rank_combat_usable(b,p,enemy,require_range,radius);var z=After.rank_combat_usable(b,p,enemy,require_range,radius)
    checks+=1
    if ids(a)!=ids(z):errors.append("usable "+str(origin)+str(radius))
 b.end_geometry_validation_scope();r.free()
 print("COVER_EQUIVALENCE ",checks," ",errors)
 quit(0 if errors.is_empty() else 1)
