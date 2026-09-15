extends SceneTree
const Scenario=preload("res://gameplay/doble_ocho_scenario.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 await scene.start_battle(false,Scenario.config());scene.set_process(false)
 var b=scene.battle
 if b==null:push_error(scene.note.text);quit(1);return
 scene.runtime.get_node("TacticalBattleView").battle_presentation.skip_to_ready()
 if not Fixture.begin_review(scene.runtime,b).success:quit(1);return
 var frames=[];var last=Time.get_ticks_usec();var start=last
 while Time.get_ticks_usec()-start<15000000:
  await process_frame
  var now=Time.get_ticks_usec();var dt=(now-last)/1000000.;last=now
  frames.append(dt*1000.)
  if b.battle_phase=="active":Runtime.advance(b,minf(dt,.1))
 var seconds=(Time.get_ticks_usec()-start)/1000000.;frames.sort()
 var report={"resolution":"1280x720","seconds":seconds,"frames":frames.size(),"average_fps":frames.size()/seconds,"median_frame_ms":frames[int(frames.size()*.5)],"p95_frame_ms":frames[int(frames.size()*.95)],"initial_units":14,"note":"Native wall-clock sample, no fixed-FPS movie mode. Separate from visual acceptance and not an expansion-headroom certification."}
 FileAccess.open("res://tools/yard_revision_20260915/native_perf.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"));print("NATIVE_PERF ",JSON.stringify(report));quit()
