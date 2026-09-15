extends SceneTree
const Director=preload("res://tools/tactical_controls/estate_director.gd")
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate"
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.seed_value=9146
 await scene.start_battle(false,Director.config())
 scene.set_process(false)
 if scene.battle==null:printerr("ESTATE_FAIL no battle");quit(1);return
 var view=scene.runtime.get_node("TacticalBattleView")
 view._dusk_zoom=1.02;view._dusk_pan=Vector2(0,-38);view._frame_camera()
 var presentation=view.battle_presentation
 presentation.audio_enabled=false
 presentation.skip_to_ready()
 for i in range(5):await process_frame
 var begin=preload("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,scene.battle)
 if begin==null or not begin.success:printerr("ESTATE_FAIL begin");quit(1);return
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/estate_overview.png")
 view._dusk_zoom=1.75;view._dusk_pan=Vector2(460,-20);view._frame_camera()
 for i in range(4):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/estate_house_detail.png")
 print("ESTATE_PREVIEW ",scene.battle.participants.size()," units / route errors ",presentation.last_path_errors)
 quit()
