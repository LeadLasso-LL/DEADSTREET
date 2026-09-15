extends SceneTree
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
var out="res://tools/sandbox_maps_20260915/"
func _initialize():call_deferred("run")
func hide_layers(node: Node):
 if node is CanvasLayer:node.hide()
 for c in node.get_children():hide_layers(c)
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame;scene.set_process(false)
 DirAccess.make_dir_recursive_absolute("res://assets/menu/maps")
 for id in Maps.IDS:
  await scene.start_battle(false,Maps.preset(id))
  if scene.battle==null:push_error("Preview launch failed "+id);quit(1);return
  for i in range(14):await process_frame
  root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
  var view=scene.runtime.get_node("TacticalBattleView")
  view.process_mode=Node.PROCESS_MODE_DISABLED
  var presentation=view.battle_presentation
  presentation.stage="ready";presentation.clock=presentation.intro_duration;presentation.apply_poses()
  hide_layers(scene.runtime)
  # Capture real native scenery; controls/markers and transient actors are omitted.
  for actor in view.actor_presenter._unit_nodes.values():actor.hide()
  var b=scene.battle
  var centers={"harold":Vector2(270,100),"river_bridge":Vector2(728,74),"whittaker_estate":Vector2(662,348),"doble_ocho":Vector2(554,166)}
  var zooms={"harold":1.55,"river_bridge":.82,"whittaker_estate":1.03,"doble_ocho":1.15}
  view._camera.position=centers[id];view._camera.zoom=Vector2.ONE*zooms[id];view._camera.reset_smoothing();view._camera.force_update_scroll()
  for i in range(3):await process_frame
  await RenderingServer.frame_post_draw
  var path="res://assets/menu/maps/"+id+".png";root.get_texture().get_image().save_png(path)
  print("MAP_PREVIEW ",id)
  scene.return_to_setup();await process_frame
 scene.queue_free();await process_frame
 Maps.textures.clear()
 var opening=load("res://gameplay/sandbox_opening.tscn").instantiate();root.add_child(opening)
 for i in range(12):await process_frame
 opening.phase="title";opening.elapsed=28.;opening.open_sandbox()
 await create_timer(5.5).timeout
 var sandbox=opening.sandbox;var builder=sandbox.menu_panels.builder
 for dims in [Vector2i(1920,1080),Vector2i(1280,720),Vector2i(1920,1200),Vector2i(2560,1080)]:
  root.size=dims;DisplayServer.window_set_size(dims)
  builder.choose_map("river_bridge")
  for i in range(5):await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(out+"setup_%dx%d.png"%[dims.x,dims.y])
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 builder.choose_map("doble_ocho")
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"setup_yard.png")
 builder.open_fleet()
 var fleet=sandbox.menu_panels.get_node("VehicleFleet")
 fleet.required_units=16;fleet.faction_id="trc";fleet.selected=["roadwarden","roadwarden","roadwarden"];fleet.selected_class="heavy_transports";fleet.refresh_models();fleet.refresh_convoy()
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"convoy_locked.png")
 fleet.selected=["outrider","interceptor","outrider","outrider"];fleet.required_units=12;fleet.selected_class="utility_vehicles";fleet.refresh_models();fleet.refresh_convoy()
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"convoy_bikes.png")
 print("NATIVE_PREVIEWS_DONE");quit()
