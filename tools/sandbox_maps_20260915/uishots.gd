extends SceneTree
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
var out="res://tools/sandbox_maps_20260915/"
func _initialize():call_deferred("run")
func hide_layers(node: Node):
 if node is CanvasLayer:node.hide()
 for c in node.get_children():hide_layers(c)
func run():
 var opening=load("res://gameplay/sandbox_opening.tscn").instantiate();root.add_child(opening)
 for i in range(12):await process_frame
 opening.phase="title";opening.elapsed=28.;opening.open_sandbox()
 await create_timer(5.5).timeout
 var sandbox=opening.sandbox;var builder=sandbox.menu_panels.builder
 for dims in [Vector2i(1920,1080),Vector2i(1280,720),Vector2i(1920,1200),Vector2i(2560,1080)]:
  root.size=dims;DisplayServer.window_set_size(dims)
  builder.choose_map("river_bridge")
  for i in range(5):await process_frame
  for choice in builder.map_selector.choices.values():
   assert(Rect2(Vector2.ZERO,builder.map_selector.size).encloses(Rect2(choice.button.position,choice.button.size)),"Map choice escapes selector")
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
