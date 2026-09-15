extends SceneTree
const Scenario=preload("res://gameplay/freight_exchange_scenario.gd")
var out="res://tools/freight_exchange_20260915/"
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,800);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 scene.seed_value=915523
 await scene.start_battle(false,Scenario.config());scene.set_process(false)
 if scene.battle==null:push_error(scene.note.text);quit(1);return
 var view=scene.runtime.get_node("TacticalBattleView")
 var p=view.battle_presentation
 var first=Engine.get_process_frames()
 while Engine.get_process_frames()-first<900:
  await process_frame
  if p.stage=="ready" and p.ready_clock>=5.:break
  if p.stage=="arrival" and p.clock>4.4:
   # Gentle move from the whole yard toward the arriving force, then settle wide.
   var u=smoothstep(4.4,9.,p.clock)*(1.-smoothstep(15.,21.,p.clock))
   view._dusk_zoom=1.05+u*.08;view._dusk_pan=Vector2(-30.*u,-30);view._frame_camera()
  if p.stage=="ready":view._dusk_zoom=1.05;view._dusk_pan=Vector2(0,-30);view._frame_camera()
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"freight_exchange_final.png")
 FileAccess.open(out+"movie.json",FileAccess.WRITE).store_string(JSON.stringify({"trim_frames":first,"frames":Engine.get_process_frames(),"stage":p.stage,"arrival_errors":p.last_path_errors,"intro_duration":p.intro_duration}))
 quit(0 if p.last_path_errors.is_empty() else 1)
