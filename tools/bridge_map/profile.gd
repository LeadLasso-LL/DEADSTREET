extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Runtime=preload("res://tools/bridge_map/profile_runtime.gd")
func _initialize():call_deferred("run")
func stats():return {"fps":Engine.get_frames_per_second(),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000.}
func run():
 root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 var c=Cases.make(8,8,["aegis","vigil"]);c.map_id="river_bridge";c.defender.vehicles=["bulwark","interceptor"]
 await scene.start_battle(false,c);scene.set_process(false)
 var view=scene.runtime.get_node("TacticalBattleView");var b=scene.battle;view.battle_presentation.skip_to_ready()
 await create_timer(3.).timeout
 var report={"paused":stats()}
 view.static_surface_root.visible=false;view.dynamic_unit_root.visible=false
 await create_timer(3.).timeout;report["hidden_art"]=stats()
 view.static_surface_root.visible=true;view.dynamic_unit_root.visible=true
 load("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
 for id in b.get_sorted_tactical_force_ids():
  if b.get_tactical_force(id).side_id==b.attacker_side_id:load("res://battle/core/battle_force_command_service.gd").set_command(b,id,"push")
 var costs=[]
 for i in range(60):
  var start=Time.get_ticks_usec();Runtime.advance(b,.05);costs.append((Time.get_ticks_usec()-start)/1000.);await process_frame
 var total=0.
 for value in costs:total+=value
 costs.sort();report["runtime_mean_ms"]=total/costs.size();report["runtime_p95_ms"]=costs[56];report["runtime_max_ms"]=costs.back();report["active"]=stats()
 report["stage_totals_ms"]=Runtime.timings;report["stage_counts"]=Runtime.timing_counts
 FileAccess.open("res://tools/bridge_map/results/profile.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "));print("BRIDGE_PROFILE ",report);quit()
