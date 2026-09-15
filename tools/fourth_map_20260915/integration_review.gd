extends SceneTree
const Scenario=preload("res://gameplay/doble_ocho_scenario.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const SelectionRange=preload("res://gameplay/tactical_selection_range.gd")
const Exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
var checks=0
var errors=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);push_error(message)
func settle(n=5):
 for i in range(n):await process_frame
func run():
 root.size=Vector2i(1440,900);DisplayServer.window_set_size(root.size)
 var builder=preload("res://gameplay/sandbox_force_builder.gd").new();root.add_child(builder);await settle()
 builder.map_option.select(3);builder.map_option.item_selected.emit(3)
 check(builder.yard_preset_button.visible,"preset offered on selected map")
 builder.yard_preset_button.pressed.emit();await settle()
 check(Config.validate(builder.config).valid,"actual sandbox preset validates")
 check(builder.config==Scenario.config(),"button loads exact seven versus seven preset")
 check(not builder.start_button.disabled,"actual Start button enabled")
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://tools/fourth_map_20260915/preset.png")
 builder.queue_free();await settle()
 for map_id in ["doble_ocho","harold","river_bridge","whittaker_estate"]:
  var cfg=Scenario.config(6) if map_id=="doble_ocho" else Config.from_legacy({})
  cfg.map_id=map_id
  if map_id=="river_bridge":cfg.defender.vehicles=["bayou","bayou"]
  var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await settle(2)
  await scene.start_battle(false,cfg);scene.set_process(false)
  check(scene.battle!=null,map_id+" ordinary setup succeeds")
  if scene.battle!=null:
   var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
   check(b.has_valid_geometry(),map_id+" valid geometry")
   view.battle_presentation.skip_to_ready()
   check(Fixture.begin_review(scene.runtime,b).success,map_id+" begins through ordinary runtime")
   b.tactical_paused=true
   if map_id=="doble_ocho":
    check(b.participants.size()==12,"six versus six roster")
    var total=0
    for v in b.vehicles.values():total+=v.get_meta("convoy_occupants",[]).size()
    check(total==6,"six passengers transported exactly once")
    var rifles=[];var mixed=[]
    for p in b.participants.values():
     check(p.has_occupied_cover_slot(),"six-versus-six real opening cover "+p.participant_id)
     if p.side_id==b.attacker_side_id:
      var route=Exit.route(b,b.get_vehicle(p.transport_vehicle_id),p.battle_position)
      check(not route.is_empty() and route.path.success,"six-versus-six clear exit "+p.participant_id)
      mixed.append(p.participant_id)
      if p.weapon_type=="rifle":rifles.append(p.participant_id)
    check(not SelectionRange.describe(b,[mixed[0]]).is_empty(),"individual reach works")
    check(SelectionRange.describe_group(b,rifles).size()==rifles.size(),"same-class ranges work")
    check(SelectionRange.describe_group(b,mixed).is_empty(),"mixed selection keeps map uncluttered")
   await settle(8)
  scene.queue_free();await settle(8)
 var report={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/fourth_map_20260915/integration_review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("INTEGRATION_REVIEW ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
