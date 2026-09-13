extends SceneTree
func _initialize():call_deferred("run")
func run():
 var vp=SubViewport.new();vp.size=Vector2i(3072,1536);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;vp.transparent_bg=false;root.add_child(vp)
 var art=load("res://gameplay/river_bridge_art.gd").new();art.bake_mode=true;art.position=Vector2(768,512);vp.add_child(art)
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 DirAccess.make_dir_recursive_absolute("res://assets/art/bridge")
 var result=vp.get_texture().get_image().save_png("res://assets/art/bridge/river_ground.png")
 print("BRIDGE_GROUND_BAKED ",result," 3072x1536");quit(result)
