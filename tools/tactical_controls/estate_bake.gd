extends SceneTree
func _initialize():call_deferred("run")
func run():
 var vp=SubViewport.new();vp.size=Vector2i(4096,2304);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;vp.transparent_bg=false;root.add_child(vp)
 var art=load("res://gameplay/whittaker_estate_art.gd").new();art.bake_mode=true;art.position=Vector2(1200,900);vp.add_child(art)
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 DirAccess.make_dir_recursive_absolute("C:/Users/brand/OneDrive/Documents/dead-street/assets/art/whittaker_estate")
 var result=vp.get_texture().get_image().save_png("C:/Users/brand/OneDrive/Documents/dead-street/assets/art/whittaker_estate/ground.png")
 print("ESTATE_GROUND_BAKED ",result," 4096x2304");quit(result)
