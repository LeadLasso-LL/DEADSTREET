extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 root.size=Vector2i(1440,900)
 await process_frame
 scene.show_class("sniper");scene.choose("awm");scene.clip="aim";scene.refresh()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/arsenal_production/arsenal_review.png")
 print("REVIEW_CAPTURED")
 if OS.get_cmdline_user_args().has("--hold"):return
 quit()
