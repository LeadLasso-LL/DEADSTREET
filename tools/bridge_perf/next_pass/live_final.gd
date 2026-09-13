extends SceneTree
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
func _initialize(): call_deferred("run")
func run():
 root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 var c=Cases.make(12,12,["aegis","vigil","aegis"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor","bulwark"]
 await scene.start_battle(false,c);scene.set_process(false)
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
 view.battle_presentation.skip_to_ready();await create_timer(1.).timeout
 var begin=load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
 if begin==null or not begin.success:printerr("LIVE_BEGIN_FAILED");quit(1);return
 for id in b.get_sorted_tactical_force_ids():
  if b.get_tactical_force(id).side_id==b.attacker_side_id:load("res://battle/core/battle_force_command_service.gd").set_command(b,id,"push")
 scene.ready_started=true;scene.set_process(true)
 var started=Time.get_ticks_usec();var previous=started;var window_start=started
 var frames=[];var windows=[];var frame_count=0;var health=0.
 for p in b.participants.values():health+=p.vitality
 while Time.get_ticks_usec()-started<30000000 and b.battle_phase=="active":
  await process_frame
  var now=Time.get_ticks_usec();frames.append((now-previous)/1000.);previous=now;frame_count+=1
  if now-window_start>=5000000:
   windows.append({"wall_seconds":(now-started)/1000000.,"fps":frame_count*1000000./(now-window_start),"sim_seconds":b.elapsed_time_seconds})
   print("LIVE_WINDOW ",windows.back());window_start=now;frame_count=0
 scene.set_process(false)
 var wall=(Time.get_ticks_usec()-started)/1000000.;var living=0;var remaining=0.
 for p in b.participants.values():
  remaining+=p.vitality
  if p.is_alive:living+=1
 frames.sort()
 var report={"units":24,"rendered":view.actor_presenter._unit_nodes.size(),"wall_seconds":wall,"sim_seconds":b.elapsed_time_seconds,"fps":frames.size()/wall,"p95_frame_ms":frames[int(frames.size()*.95)-1],"max_frame_ms":frames.back(),"windows":windows,"living":living,"damage":health-remaining}
 var pause_start=Time.get_ticks_usec();var pause_frames=0
 while Time.get_ticks_usec()-pause_start<5000000:
  await process_frame;pause_frames+=1
 report["late_paused_fps"]=pause_frames*1000000./(Time.get_ticks_usec()-pause_start)
 FileAccess.open("res://tools/bridge_perf/next_pass/live_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("LIVE_DONE ",JSON.stringify(report));scene.queue_free();await process_frame;quit()
