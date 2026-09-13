extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Runtime=preload("res://tools/bridge_map/profile_runtime.gd")
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
 var label="before";var n=8
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--label="):label=arg.trim_prefix("--label=")
  if arg.begins_with("--side="):n=int(arg.trim_prefix("--side="))
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 var c=Cases.make(n,n,["aegis","vigil"] if n==8 else ["aegis","vigil","aegis"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor"] if n==8 else ["bulwark","interceptor","bulwark"]
 await scene.start_battle(false,c);scene.set_process(false)
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
 view.battle_presentation.skip_to_ready();await create_timer(1.).timeout
 var paused_fps=Engine.get_frames_per_second()
 var begin=load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
 if begin==null or not begin.success:printerr("BENCH_BEGIN_FAILED");quit(1);return
 for id in b.get_sorted_tactical_force_ids():
  if b.get_tactical_force(id).side_id==b.attacker_side_id:load("res://battle/core/battle_force_command_service.gd").set_command(b,id,"push")
 var costs=[];var checkpoints=[];var positions={};var health=0.;var started=Time.get_ticks_msec()
 Runtime.timings.clear();Runtime.timing_counts.clear()
 for p in b.participants.values():positions[p.participant_id]=p.battle_position;health+=p.vitality
 for i in range(600):
  var t=Time.get_ticks_usec();var step=Runtime.advance(b,.05);costs.append((Time.get_ticks_usec()-t)/1000.)
  if step==null or not step.success:printerr("BENCH_STEP_FAILED ",i);quit(2);return
  await process_frame
  if (i+1)%120==0:
   var mean=0.;for v in costs.slice(i-119,i+1):mean+=v/120.
   checkpoints.append({"sim_seconds":b.elapsed_time_seconds,"mean_update_ms":mean,"fps_snapshot":Engine.get_frames_per_second()})
   print("BENCH_PROGRESS ",label," ",checkpoints.back())
  if b.battle_phase!="active" or Time.get_ticks_msec()-started>90000:break
 var moved=0;var end_health=0.;var living=0;var occupied=0
 for p in b.participants.values():
  if p.battle_position.distance_to(positions[p.participant_id])>.5:moved+=1
  end_health+=p.vitality
  if p.is_alive:living+=1
  if not p.occupied_cover_slot_id.is_empty():occupied+=1
 var sum=0.;for v in costs:sum+=v
 costs.sort()
 var report={"label":label,"units":b.participants.size(),"rendered":view.actor_presenter._unit_nodes.size(),"steps":costs.size(),"sim_seconds":b.elapsed_time_seconds,"mean_ms":sum/costs.size(),"p95_ms":costs[int(costs.size()*.95)-1],"max_ms":costs.back(),"paused_fps":paused_fps,"checkpoints":checkpoints,"damage":health-end_health,"moved":moved,"living":living,"occupied":occupied,"phase":b.battle_phase,"stages_ms":Runtime.timings.duplicate()}
 FileAccess.open("res://tools/bridge_perf/"+label+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("BENCH_DONE ",JSON.stringify(report));scene.queue_free();await process_frame;quit()
