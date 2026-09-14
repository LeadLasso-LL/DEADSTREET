extends SceneTree
const Director=preload("res://tools/tactical_controls/estate_director.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
class View extends Node2D:
 var _dusk_zoom=1.
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
func _initialize():call_deferred("run")
func run():
 var runtime=load("res://gameplay/gameplay_runtime.gd").new()
 runtime.game_state=load("res://gameplay/starter_world_service.gd").create()
 runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
 var view=View.new();view.name="TacticalBattleView";runtime.add_child(view)
 var fixture=Fixture.setup(runtime,Director.config(),false,Director.SEED,true)
 if not fixture.has("battle"):printerr("ESTATE_FAIL ",fixture);quit(1);return
 var b=fixture.battle;var errors=[];var checks=[]
 for route in [["main gate",Vector2(45,68),Vector2(54,68)],["approach to court",Vector2(45,68),Vector2(96,66)],["north garden",Vector2(37,28),Vector2(73,28)],["south service",Vector2(42,99),Vector2(75,99)],["front steps",Vector2(95,78),preload("res://battle/geometry/whittaker_estate_catalog.gd").ENTRANCE]]:
  var path=Nav.find_path(b,route[1],route[2])
  checks.append({"route":route[0],"reachable":path!=null and path.success,"error":path.error_message if path!=null else "null result"})
  if path==null or not path.success:errors.append(route[0])
 var deployments=0
 for p in b.participants.values():
  if not p.has_battle_position:errors.append("Unplaced "+p.participant_id)
  elif not b.get_deployment_position_error(p.side_id,p.battle_position).is_empty():errors.append("Illegal spawn "+p.participant_id)
  else:deployments+=1
 var report={"route_checks":checks,"placed_units":deployments,"cover_slots":b.battlefield_geometry.cover_slots.size(),"errors":errors}
 FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate/geometry.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ESTATE_GEOMETRY ",JSON.stringify(report));runtime.free();quit(0 if errors.is_empty() else 1)
