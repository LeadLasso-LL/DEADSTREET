extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
var scene
var errors=[]
var checks=0
var output="res://tools/bridge_map/results/"
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
 checks+=1
 if not ok:errors.append(label);printerr("BRIDGE_NATIVE_FAIL ",label)
func capture(name: String):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+name+".png")
func run():
 DirAccess.make_dir_recursive_absolute(output);root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 scene.custom_loadouts=Cases.make(8,8,["aegis","vigil"])
 scene.open_force_builder();await process_frame
 var panel=scene.surface.get_node("ForceBuilder");panel.choose_map("river_bridge")
 panel.config.defender.vehicles=["bulwark","interceptor"];panel.changed()
 check(not panel.start_button.disabled,"bridge setup ready")
 panel.open_fleet("defender");await process_frame
 check(panel.get_node("VehicleFleet").required_units==8,"defender convoy picker")
 panel.get_node("VehicleFleet").queue_free();await process_frame
 await capture("bridge_setup")
 var chosen=panel.config.duplicate(true)
 await scene.start_battle(false,chosen);scene.set_process(false)
 var view=scene.runtime.get_node("TacticalBattleView");var d=view.battle_presentation
 var deadline=Time.get_ticks_msec()+70000
 while Time.get_ticks_msec()<deadline and d.stage!="ready":await process_frame
 check(d.stage=="ready","bridge arrival reaches ready")
 check(d.last_path_errors.is_empty(),"physical dismount routes")
 var b=scene.battle
 check(b!=null and b.battlefield_geometry.authored_layout_id=="river_suspension_bridge_v1","bridge selected")
 check(view.actor_presenter._unit_nodes.size()==16,"sixteen faction actors")
 check(view._dusk_vehicle_nodes.size()==4,"both convoys rendered")
 check(not scene.runtime.armor_layer.visible,"campaign shop hidden in battle")
 for unit in b.participants.values():
  var actor=view.actor_presenter._unit_nodes[unit.participant_id]
  check(actor.position.distance_to(unit.battle_position*Vector2(8,6))<4.,"unit anchored to bridge "+unit.participant_id)
  check(actor.scale.is_equal_approx(Vector2(1.48,1.48)),"accepted unit scale")
 view._dusk_zoom=.90;view._dusk_pan=Vector2(0,-150);view._frame_camera();await capture("bridge_overview")
 view._dusk_zoom=2.25;view._dusk_pan=Vector2(-145,-70);view._frame_camera();await capture("bridge_traffic")
 view._dusk_zoom=2.35;view._dusk_pan=Vector2(535,-60);view._frame_camera();await capture("bridge_blockade")
 var before={}
 for p in b.participants.values():before[p.participant_id]=p.battle_position
 var begin=load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
 check(begin!=null and begin.success,"normal battle starts")
 scene.ready_started=true;scene.set_process(true)
 for id in b.get_sorted_tactical_force_ids():
  if b.get_tactical_force(id).side_id==b.attacker_side_id:load("res://battle/core/battle_force_command_service.gd").set_command(b,id,"push")
 await create_timer(12.).timeout
 var moved=0
 for p in b.participants.values():
  if p.battle_position.distance_to(before[p.participant_id])>1:moved+=1
 view._dusk_zoom=2.25;view._dusk_pan=Vector2(-145,-70);view._frame_camera();await capture("bridge_combat")
 check(moved>0,"attackers advance through traffic")
 var report={"checks":checks,"errors":errors,"moved":moved,"units":b.participants.size(),"vehicles":b.vehicles.size(),"phase":b.battle_phase,"fps":Engine.get_frames_per_second()}
 FileAccess.open(output+"review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("BRIDGE_NATIVE ",report);quit(0 if errors.is_empty() else 1)
