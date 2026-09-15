extends SceneTree
## Native scripted orders only. No health, damage, RNG or victory overrides.
const Scenario=preload("res://tools/yard_revision_20260915/ravicci/capture_config.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Force=preload("res://battle/core/battle_force_command_service.gd")
const Commands=preload("res://battle/combat/battle_player_command_service.gd")
const Setup=preload("res://gameplay/doble_ocho_setup.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const C=preload("res://battle/geometry/doble_ocho_catalog.gd")
var scene
var b
var view
var presentation
var frame=0
var first_frame=0
var started=false
var flags={}
var commands=[]
var errors=[]
var output="res://tools/yard_revision_20260915/ravicci/"
var advance_times=[]
var stage_frames={}
var seat_manifest=[]
var capture=false
func _initialize():call_deferred("run")
func run():
 capture="--record" in OS.get_cmdline_user_args()
 root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.seed_value=91517
 await scene.start_battle(false,Scenario.config());scene.set_process(false)
 if scene.battle==null:push_error(scene.note.text);quit(1);return
 b=scene.battle;view=scene.runtime.get_node("TacticalBattleView");presentation=view.battle_presentation
 view._dusk_zoom=1.;view._dusk_pan=Vector2(20,-50);view._frame_camera()
 for v in b.vehicles.values():seat_manifest.append({"vehicle":v.vehicle_type_id,"count":v.get_meta("convoy_occupants",[]).size(),"passengers":v.get_meta("convoy_occupants",[])})
 first_frame=Engine.get_process_frames()
 while frame<30*160:
  await process_frame;frame+=1
  var stage=presentation.stage
  if not stage_frames.has(stage):stage_frames[stage]=frame
  if stage=="arrival":
   view._dusk_zoom=lerpf(1.,1.55,smoothstep(3.8,8.0,presentation.clock))
   view._dusk_pan=Vector2(20,-50);view._frame_camera()
   if presentation.clock>=4.5 and not flags.has("arrival"):await shot("arrival")
  if stage=="ready" and presentation.ready_clock>.9 and not started:
   if not Fixture.begin_review(scene.runtime,b).success:errors.append("Unable to begin combat");break
   started=true
   for id in b.get_sorted_tactical_force_ids():Force.set_command(b,id,"hold")
   commands.append({"time":0.,"action":"Both forces hold opening cover"})
   await shot("opening_cover")
  if b.battle_phase=="active":
   direct()
   var tick=Time.get_ticks_usec();Runtime.advance(b,1./30.);advance_times.append((Time.get_ticks_usec()-tick)/1000.)
   for at in [6,14,26,40]:
    if b.elapsed_time_seconds>=at and not flags.has("combat_%d"%at):await shot("combat_%d"%at)
   if b.elapsed_time_seconds>=105.:errors.append("Battle did not resolve by105 seconds");break
  if stage=="ending":
   if presentation.end_clock>=2.2 and not flags.has("aftermath"):await shot("aftermath")
   if presentation.results_visible() and not flags.has("results"):await shot("results")
   if presentation.end_clock>=presentation.outro.duration+9.:break
 var safety
 for child in view.get_children():
  if child.get_script()!=null and str(child.get_script().resource_path).ends_with("tactical_camera_safety.gd"):safety=child
 advance_times.sort()
 var metrics={"median_ms":advance_times[int(advance_times.size()*.5)] if not advance_times.is_empty() else 0,"p95_ms":advance_times[int(advance_times.size()*.95)] if not advance_times.is_empty() else 0}
 var survivors={"attacker":0,"defender":0}
 for p in b.participants.values():
  if p.is_alive:survivors[p.side_id]+=1
 var audio_sources=[]
 for player in presentation.convoy_audio.sources.values():audio_sources.append({"faction":player.get_meta("faction_id",""),"track":player.get_meta("track_id",""),"playing":player.playing,"volume_db":player.volume_db})
 var report={"seed":91517,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"combat_seconds":b.elapsed_time_seconds,"frames":Engine.get_process_frames()-first_frame,"loop_frames":frame,"trim_frames":first_frame,"seconds":(Engine.get_process_frames()-first_frame)/30.,"survivors":survivors,"commands":commands,"arrival_errors":presentation.last_path_errors,"outro_errors":presentation.outro.errors,"errors":errors,"camera_violations":safety.violations if safety!=null else -1,"camera_frames":safety.checked_frames if safety!=null else 0,"manifest":seat_manifest,"results":presentation.result_snapshot,"audio":audio_sources,"advance":metrics,"stages":stage_frames}
 FileAccess.open(output+("record.json" if capture else "rehearsal.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("YARD_SHOWCASE ",JSON.stringify(report));quit(0 if errors.is_empty() and b.battle_phase=="resolved" and presentation.last_path_errors.is_empty() and presentation.outro.errors.is_empty() else 1)
func shot(name_value: String):
 flags[name_value]=true
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+name_value+".png")
func move(id: String,at: Vector2,label_value: String):
 var p=b.get_participant(id)
 if p==null or not p.is_alive or p.is_wounded:return
 var result=view.orders_controller._issue_move_one(p,at)
 commands.append({"time":b.elapsed_time_seconds,"action":label_value,"unit":id,"accepted":result.success,"destination":str(at)})
func direct():
 var t=b.elapsed_time_seconds
 if t>=1.2 and not flags.has("flank_move"):
  flags.flank_move=true
  move("sandbox_attacker_unit_05",Vector2(93.5,48),"Service team moves outside the fence")
  move("sandbox_attacker_unit_06",Vector2(97,49.5),"Service team takes the second gate")
  Commands.issue(b,["sandbox_attacker_unit_07"],"hold",89.)
 if t>=5.2 and not flags.has("gate_entry"):
  flags.gate_entry=true
  move("sandbox_attacker_unit_05",Vector2(93.5,37),"Flanker enters through the open service gate")
  move("sandbox_attacker_unit_06",Vector2(97.5,35.5),"SMG takes the service corner")
 if t>=7.5 and not flags.has("main_push"):
  flags.main_push=true
  var result=Commands.issue(b,["sandbox_attacker_unit_01","sandbox_attacker_unit_02","sandbox_attacker_unit_03","sandbox_attacker_unit_04"],"push",70.)
  commands.append({"time":t,"action":"Main team advances through yard cover","accepted":result.accepted,"failed":result.failed})
 if t>=16. and not flags.has("counter"):
  flags.counter=true
  var defenders=[]
  for p in b.participants.values():
   if p.side_id==b.defender_side_id and p.weapon_type in ["smg","shotgun"]:defenders.append(p.participant_id)
  var result=Commands.issue(b,defenders,"push",69.)
  commands.append({"time":t,"action":"Calle Ocho counterattack from the garage","accepted":result.accepted,"failed":result.failed})
 if t>=30. and not flags.has("release"):
  flags.release=true
  for p in b.participants.values():
   if p.is_alive and not p.is_wounded:p.clear_player_tactical_intent()
  for id in b.get_sorted_tactical_force_ids():Force.set_command(b,id,"push")
  commands.append({"time":t,"action":"Surviving teams press the advantage"})

