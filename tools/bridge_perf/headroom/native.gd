extends SceneTree
const Cases = preload("res://tools/sandbox_setup/scenarios.gd")
func _initialize(): call_deferred("run")
func run():
 var n=12;var label="native_scope";var duration=30.;var uncapped=false;var bulwarks=false
 for arg in OS.get_cmdline_user_args():
  if arg=="--uncapped":uncapped=true
  if arg=="--bulwarks":bulwarks=true
  if arg.begins_with("--side="):n=int(arg.trim_prefix("--side="))
  if arg.begins_with("--label="):label=arg.trim_prefix("--label=")
  if arg.begins_with("--duration="):duration=float(arg.trim_prefix("--duration="))
 root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
 if uncapped:
  DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 var setup_started=Time.get_ticks_usec()
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();scene.set_script(load("res://tools/bridge_perf/headroom/stress_scene.gd"));root.add_child(scene);await process_frame
 var c=Cases.make(n,n,["aegis","vigil","aegis"] if n<=12 and not bulwarks else ["bulwark","bulwark","bulwark"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor","bulwark"] if n<=12 and not bulwarks else ["bulwark","bulwark","bulwark"]
 await scene.start_battle(false,c);scene.set_process(false)
 var b=scene.battle
 if b==null:printerr("NATIVE_FIXTURE_FAILED");quit(4);return
 var view=scene.runtime.get_node("TacticalBattleView")
 view.battle_presentation.skip_to_ready();await create_timer(1.).timeout
 var begin=load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
 if begin==null or not begin.success:printerr("LIVE_BEGIN_FAILED");quit(1);return
 for id in b.get_sorted_tactical_force_ids():
  if b.get_tactical_force(id).side_id==b.attacker_side_id:load("res://battle/core/battle_force_command_service.gd").set_command(b,id,"push")
 if b.participants.size()!=n*2:printerr("WRONG_ROSTER_SIZE");quit(3);return
 scene.ready_started=true;scene.set_process(true)
 var setup_ms=(Time.get_ticks_usec()-setup_started)/1000.
 var started=Time.get_ticks_usec();var previous=started;var window_start=started
 var frames=[];var windows=[];var frame_count=0;var health=0.
 for p in b.participants.values():health+=p.vitality
 while Time.get_ticks_usec()-started<int(duration*1000000) and b.battle_phase=="active":
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
 var report={"units":b.participants.size(),"rendered":view.actor_presenter._unit_nodes.size(),"wall_seconds":wall,"sim_seconds":b.elapsed_time_seconds,"fps":frames.size()/wall,"p95_frame_ms":frames[int(frames.size()*.95)-1],"p99_frame_ms":frames[int(frames.size()*.99)-1],"over_33ms":frames.filter(func(v):return v>33.333).size(),"over_100ms":frames.filter(func(v):return v>100.).size(),"max_frame_ms":frames.back(),"windows":windows,"living":living,"damage":health-remaining}
 report["display"]={"vsync_mode":DisplayServer.window_get_vsync_mode(),"refresh_hz":DisplayServer.screen_get_refresh_rate(),"max_fps":Engine.max_fps}
 report["build"]={"debug":OS.has_feature("debug"),"editor":OS.has_feature("editor"),"version":Engine.get_version_info()}
 report["uncapped"]=uncapped;report["bulwarks"]=bulwarks or n>12;report["setup_ms"]=setup_ms
 report["los_cache_entries"]=b._los_cache.size()+b._los_cache_previous.size();report["nav_cache_entries"]=b._nav_cache.size()+b._nav_cache_previous.size()
 var pause_start=Time.get_ticks_usec();var pause_frames=0
 while Time.get_ticks_usec()-pause_start<5000000:
  await process_frame;pause_frames+=1
 report["late_paused_fps"]=pause_frames*1000000./(Time.get_ticks_usec()-pause_start)
 FileAccess.open("res://tools/bridge_perf/headroom/"+label+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("LIVE_DONE ",JSON.stringify(report));scene.queue_free();await process_frame;quit()
