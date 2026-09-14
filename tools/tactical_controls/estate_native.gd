extends SceneTree
const Director=preload("res://tools/tactical_controls/estate_director.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
var scene
var view
var b
var director
var active=false
var frames=[]
var elapsed=0.
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate"
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.seed_value=9146
 await scene.start_battle(false,Director.config());scene.set_process(false)
 b=scene.battle
 if b==null:printerr("ESTATE_FAIL no battle");quit(1);return
 view=scene.runtime.get_node("TacticalBattleView")
 view._dusk_zoom=1.08;view._dusk_pan=Vector2(-45,-35);view._frame_camera()
 view.battle_presentation.audio_enabled=true;view.battle_presentation.skip_to_ready()
 for i in range(5):await process_frame
 var result=Fixture.begin_review(scene.runtime,b)
 if result==null or not result.success:printerr("ESTATE_FAIL begin");quit(1);return
 director=Director.new();director.setup(b,view.orders_controller)
 active=true
func _process(delta):
 if not active:return false
 elapsed+=delta
 director.tick()
 var step=Runtime.advance(b,minf(delta,.1))
 if not step.success:printerr("ESTATE_FAIL advance");quit(1);return false
 if elapsed>1.:frames.append(delta*1000.)
 if elapsed>=12.:
  active=false;finish()
 return false
func finish():
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/estate_combat.png")
 frames.sort();var sum=0.;var over=0
 for ms in frames:sum+=ms;over+=int(ms>16.667)
 var report={"native_render":true,"resolution":[1920,1080],"initial_units":32,"seconds":elapsed,"frames":frames.size(),"average_fps":frames.size()*1000./sum,"p95_frame_ms":frames[int(frames.size()*.95)],"frames_over_16_67ms":over,"route_errors":view.battle_presentation.last_path_errors}
 FileAccess.open(out+"/native.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ESTATE_NATIVE ",JSON.stringify(report));quit()
