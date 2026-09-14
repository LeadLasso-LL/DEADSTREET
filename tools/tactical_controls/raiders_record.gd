extends SceneTree
const Director=preload("res://tools/tactical_controls/raiders_director.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
var scene
var view
var b
var d
var started=false
var active=false
var frames=0
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/raiders_recording"
var snapshots={}
var phase_changes=[]
var last_phase=""
var trim_frames=0
func _initialize():call_deferred("start")
func start():
 root.size=Vector2i(1920,1080)
 DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.seed_value=9141
 await scene.start_battle(false,Director.config())
 scene.set_process(false)
 b=scene.battle
 if b==null:printerr("RECORD_ERROR no battle");quit(1);return
 view=scene.runtime.get_node("TacticalBattleView")
 view._dusk_zoom=2.55;view._dusk_pan=Vector2(-552,-55);view._frame_camera()
 view.battle_presentation.audio_enabled=true
 d=Director.new()
 trim_frames=Engine.get_process_frames()
 active=true
 print("RECORD_READY")
func _process(delta):
 if not active:return false
 frames+=1
 var presentation=view.battle_presentation
 if presentation.stage!=last_phase:
  last_phase=presentation.stage
  phase_changes.append({"frame":frames,"phase":last_phase,"battle_time":b.elapsed_time_seconds})
  print("RECORD_PHASE ",last_phase," FRAME ",frames)
 if not started:
  # Keep the complete bike/truck/bike arrival and dismounts readable, then
  # pull back to reveal the police blockade before the first orders.
  var reveal=smoothstep(10.5,15.0,presentation.clock)
  view._dusk_zoom=lerpf(2.55,1.18,reveal)
  view._dusk_pan=Vector2(-552,-55).lerp(Vector2(-95,-18),reveal);view._frame_camera()
  if presentation.clock>=6.0 and not snapshots.has("arrival"):
   snapshots.arrival=true;capture("arrival")
  if presentation.stage=="ready" and presentation.ready_clock>.7:
   var result=Fixture.begin_review(scene.runtime,b)
   if result==null or not result.success:printerr("RECORD_ERROR begin");quit(1);return false
   d.setup(b,view.orders_controller);started=true
  return false
 if b.battle_phase=="active":
  d.tick()
  var result=Runtime.advance(b,1./30.)
  if not result.success:printerr("RECORD_ERROR runtime");finish();return false
  # Smoothly frame both living fronts rather than cutting around individual shots.
  var own=d.healthy(b.attacker_side_id);var enemy=d.healthy(b.defender_side_id)
  if not own.is_empty() and not enemy.is_empty():
   var ax=0.0;var ex=0.0
   for p in own:ax+=p.battle_position.x
   for p in enemy:ex+=p.battle_position.x
   ax/=own.size();ex/=enemy.size()
   var center=(ax+ex)*.5
   var target=Vector2((center-b.battlefield_geometry.width*.5)*8.,-18.)
   var zoom=1.18 if b.elapsed_time_seconds<4.0 else clampf(100.0/maxf(ex-ax+50.,60.),1.25,1.65)
   view._dusk_zoom=lerpf(view._dusk_zoom,zoom,.018)
   view._dusk_pan=view._dusk_pan.lerp(target,.018)
   view._frame_camera()
  for t in [12,30,60,100]:
   var key="combat_"+str(t)
   if b.elapsed_time_seconds>=t and not snapshots.has(key):snapshots[key]=true;capture(key)
  if frames%300==0:print("RECORD_PROGRESS ",frames/30.0," SIM ",b.elapsed_time_seconds," UNITS ",own.size()," / ",enemy.size())
  if b.elapsed_time_seconds>240.0:printerr("RECORD_ERROR unresolved cutoff");finish();return false
 else:
  if presentation.end_clock>3.0 and not snapshots.has("aftermath"):snapshots.aftermath=true;capture("aftermath")
  if presentation.results_visible() and presentation.end_clock>presentation.outro.duration+3.0 and not snapshots.has("results"):snapshots.results=true;capture("results")
  if presentation.end_clock>presentation.outro.duration+6.0:finish()
 return false
func capture(key: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/"+key+".png")
func finish():
 active=false
 var p=view.battle_presentation
 var report={"seed":9141,"trim_frames":trim_frames,"frames":frames,"seconds":frames/30.0,"combat_seconds":b.elapsed_time_seconds,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"commands":d.log,"phases":phase_changes,"arrival_route_errors":p.last_path_errors,"outro_kind":p.outro.kind,"outro_errors":p.outro.errors,"results":p.result_snapshot,"audio_shots":p.sound.shots_played,"convoy_slots":3,"motorcycles":6,"motorcycle_occupants":7,"pickup_occupants":5,"pickup_bed_occupants":2,"ambient_emitters":p.convoy_audio.sources.size()}
 FileAccess.open(out+"/record.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("RECORD_COMPLETE ",JSON.stringify(report))
 scene.queue_free()
 await process_frame
 quit(0 if b.battle_phase=="resolved" else 1)
