extends SceneTree
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
var output=""
var map_id="harold"
var scene
var errors=[]
func _initialize():call_deferred("run")
func stats(values: Array) -> Dictionary:
 if values.is_empty():return {}
 var sorted=values.duplicate();sorted.sort()
 var total=0.;var slow=0.;var over33=0;var over100=0
 for v in values:
  total+=v
  if v>33.333:over33+=1
  if v>100.:over100+=1
 var low_count=maxi(1,int(ceil(values.size()*.01)))
 for i in range(low_count):slow+=sorted[sorted.size()-1-i]
 return {"frames":values.size(),"seconds":total/1000.,"fps":values.size()*1000./total,"p95_ms":sorted[mini(sorted.size()-1,int(sorted.size()*.95))],"p99_ms":sorted[mini(sorted.size()-1,int(sorted.size()*.99))],"one_percent_low_fps":1000.*low_count/slow,"max_ms":sorted.back(),"over_33ms":over33,"over_100ms":over100}
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--map="):map_id=arg.trim_prefix("--map=")
  if arg.begins_with("--out="):output=arg.trim_prefix("--out=")
 if output.is_empty():quit(2);return
 root.gui_disable_input=true
 var c=Maps.preset(map_id)
 for side in ["attacker","defender"]:
  c[side].units=[];c[side].erase("vehicle_occupants")
  var kinds=["rifle","smg","shotgun","rifle","pistol","smg","rifle","sniper"]
  for i in range(16):c[side].units.append(Config.unit(kinds[i%8]))
  if side=="attacker" or map_id=="river_bridge":c[side].vehicles=Config.auto_convoy(16,c[side].faction)
 if not Config.validate(c).valid:printerr("PERF_INVALID_CONFIG");quit(3);return
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 await scene.start_battle(false,c)
 if scene.battle==null:printerr("PERF_LAUNCH_FAILED ",scene.note.text);quit(4);return
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");var presentation=view.battle_presentation
 if b.participants.size()!=32:errors.append("Expected32 participants")
 var side_counts={};var initial_covered=0
 for p in b.participants.values():
  side_counts[p.side_id]=int(side_counts.get(p.side_id,0))+1
  if not p.has_battle_position:errors.append("Unplaced "+p.participant_id)
  if p.has_occupied_cover_slot():initial_covered+=1
 var arrival=[];var combat=[];var opening=[];var windows=[];var window=[]
 var phase_start=Time.get_ticks_usec();var previous=phase_start;var frames=[]
 while b.battle_phase!="active" and Time.get_ticks_usec()-phase_start<120000000:
  await process_frame
  var now=Time.get_ticks_usec();arrival.append((now-previous)/1000.);previous=now
 if b.battle_phase!="active":errors.append("Arrival did not reach active combat")
 var started=Time.get_ticks_usec();previous=started;var window_start=started
 print("PERF_COMBAT_BEGIN ",map_id," units=",b.participants.size()," GPU=",RenderingServer.get_video_adapter_name())
 while b.battle_phase=="active" and Time.get_ticks_usec()-started<600000000:
  await process_frame
  var now=Time.get_ticks_usec();var ms=(now-previous)/1000.;previous=now
  combat.append(ms);window.append(ms);frames.append([now-started,ms,b.elapsed_time_seconds])
  if now-started<30000000:opening.append(ms)
  if now-window_start>=5000000:
   var alive=0
   for p in b.participants.values():
    if p.is_alive:alive+=1
   var row=stats(window);row["elapsed"]=(now-started)/1000000.;row["alive"]=alive
   windows.append(row);window=[];window_start=now
   print("PERF_WINDOW ",map_id," ",JSON.stringify(row))
 if not window.is_empty():windows.append(stats(window))
 var resolved=b.battle_phase=="resolved";var winner=b.get_winning_side_id();var alive_by_side={}
 for p in b.participants.values():
  if p.is_alive:alive_by_side[p.side_id]=int(alive_by_side.get(p.side_id,0))+1
 if not resolved:errors.append("Combat reached600s observation limit without resolution")
 var combat_stats=stats(combat);var finish=Time.get_ticks_usec();previous=finish;var outro=[]
 while resolved and Time.get_ticks_usec()-finish<60000000:
  await process_frame
  var now=Time.get_ticks_usec();outro.append((now-previous)/1000.);previous=now
  if presentation.results_visible() and not presentation.continue_button.disabled:break
 if resolved and not presentation.results_visible():errors.append("No final result card")
 if not presentation.last_path_errors.is_empty():errors.append({"arrival_paths":presentation.last_path_errors})
 if not presentation.outro.errors.is_empty():errors.append({"outro_paths":presentation.outro.errors})
 var report={"map":map_id,"name":Maps.info(map_id).name,"status":"PASS" if errors.is_empty() else "FAIL","errors":errors,"units":b.participants.size(),"side_counts":side_counts,"initial_covered":initial_covered,"configuration":c,"seed":4101,"resolved":resolved,"winner":winner,"alive_by_side":alive_by_side,"combat_sim_seconds":b.elapsed_time_seconds,"combat":combat_stats,"first_30_seconds":stats(opening),"arrival":stats(arrival),"outro":stats(outro),"windows":windows,"shots_played":presentation.sound.shots_played,"outro_kind":presentation.outro.kind,"build":{"debug":OS.has_feature("debug"),"editor":OS.has_feature("editor"),"version":Engine.get_version_info()},"display":{"viewport":root.size,"window":DisplayServer.window_get_size(),"screen":DisplayServer.screen_get_size(),"refresh_hz":DisplayServer.screen_get_refresh_rate(),"vsync":DisplayServer.window_get_vsync_mode(),"max_fps":Engine.max_fps,"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name()}}
 FileAccess.open(output,FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 FileAccess.open(output.trim_suffix(".json")+"_frames.json",FileAccess.WRITE).store_string(JSON.stringify(frames))
 print("PERF_DONE ",JSON.stringify(report))
 quit(0 if errors.is_empty() else 5)
