extends SceneTree
const Director=preload("res://tools/tactical_controls/estate_director.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
var scene
var view
var b
var d
var started=false
var active=false
var frames=0
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate"
var snapshots={}
var phase_changes=[]
var last_phase=""
var trim_frames=0
var arrival_manifest=[]
var radio_gain_samples=[]
var horn_gain_samples=[]
var radio_sample_index=0
var victory_audio_samples=[]
var victory_sample_index=0
var summary_checks={}
var safety_checks=0
var safety_errors=[]
var entered_objective={}
var previous_nodes={}
var max_outro_jump=0.
var result_camera_jump=0.
var last_camera_position=Vector2.ZERO
var last_camera_zoom=Vector2.ONE
var cards_seen=false
var resized=false
var validation_mode=false
func _initialize():call_deferred("start")
func start():
 summary_checks=preload("res://tools/tactical_controls/result_summary_checks.gd").run()
 print("RESULT_SUMMARY_CHECKS ",summary_checks)
 if not summary_checks.errors.is_empty():printerr("RECORD_ERROR result summaries");quit(1);return
 root.size=Vector2i(1920,1080)
 DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.seed_value=9146
 await scene.start_battle(false,Director.config())
 scene.set_process(false)
 b=scene.battle
 if b==null:printerr("RECORD_ERROR no battle");quit(1);return
 view=scene.runtime.get_node("TacticalBattleView")
 view._dusk_zoom=2.0;view._dusk_pan=Vector2(-445,88);view._frame_camera()
 view.battle_presentation.audio_enabled=true
 d=Director.new()
 trim_frames=Engine.get_process_frames()
 active=true
 RenderingServer.frame_post_draw.connect(audit_frame)
 print("RECORD_READY")
func _process(delta):
 if not active:return false
 frames+=1
 if validation_mode and not resized and b.elapsed_time_seconds>10.:
  resized=true;root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
 var presentation=view.battle_presentation
 var sample_times=[6.0,10.5,11.5,13.0,20.0,25.0,30.0]
 if radio_sample_index<sample_times.size() and float(frames)/30.>=float(sample_times[radio_sample_index]):
  for source in presentation.convoy_audio.sources.values():
   if bool(source.get_meta("is_radio",false)):
    radio_gain_samples.append({"movie_seconds":float(frames)/30.,"phase":presentation.stage,"arrival_clock":presentation.clock,"gain_db":source.volume_db,"battle_mix":presentation.convoy_radio_battle_mix()})
   elif bool(source.get_meta("is_trc_siren",false)):
    horn_gain_samples.append({"movie_seconds":float(frames)/30.,"phase":presentation.stage,"gain_db":source.volume_db,"playing":source.playing,"position":str(source.position),"range":source.max_distance,"pitch_scale":source.pitch_scale,"attenuation":source.attenuation})
  radio_sample_index+=1
 if presentation.stage!=last_phase:
  last_phase=presentation.stage
  phase_changes.append({"frame":frames,"phase":last_phase,"battle_time":b.elapsed_time_seconds})
  print("RECORD_PHASE ",last_phase," FRAME ",frames)
 if not started:
  # Follow the TRC road turn and dismount, then reveal the estate defense.
  var reveal=smoothstep(6.7,11.5,presentation.clock)
  view._dusk_zoom=lerpf(2.0,1.55,reveal)
  view._dusk_pan=Vector2(-445,88).lerp(Vector2(-120,-20),reveal);view._frame_camera()
  if presentation.clock>=1.5 and not snapshots.has("intro_full"):
   snapshots.intro_full=true;capture("intro_full")
  if presentation.clock>=6.0 and not snapshots.has("arrival"):
   snapshots.arrival=true;capture("arrival")
  if presentation.stage=="ready" and presentation.ready_clock>.7:
   capture("opening_cover")
   for vehicle in b.vehicles.values():
    if vehicle.side_id!=b.attacker_side_id:continue
    var passengers=[]
    for unit in b.participants.values():
     if unit.transport_vehicle_id!=vehicle.battle_vehicle_id:continue
     var route=presentation.routes.get(unit.participant_id,{})
     if route.is_empty():printerr("RECORD_ERROR missing passenger dismount");quit(1);return false
     passengers.append({"id":unit.participant_id,"seat":unit.get_meta("transport_seat",-1),"route_start":str(route.points[0]),"route_end":str(route.points[-1]),"start_seconds":route.start,"covered":not unit.occupied_cover_slot_id.is_empty(),"flanker":unit.get_meta("estate_flanker",false)})
    arrival_manifest.append({"vehicle":vehicle.vehicle_type_id,"count":passengers.size(),"passengers":passengers})
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
   var target=Vector2((center-b.battlefield_geometry.width*.5)*8.,-30.)
   var zoom=clampf(130.0/maxf(ex-ax+42.,58.),1.55,1.95)
   view._dusk_zoom=lerpf(view._dusk_zoom,zoom,.018)
   view._dusk_pan=view._dusk_pan.lerp(target,.018)
   view._frame_camera()
  for t in [12,30,60,100]:
   var key="combat_"+str(t)
   if b.elapsed_time_seconds>=t and not snapshots.has(key):snapshots[key]=true;capture(key)
  if frames%300==0:print("RECORD_PROGRESS ",frames/30.0," SIM ",b.elapsed_time_seconds," UNITS ",own.size()," / ",enemy.size())
  if b.elapsed_time_seconds>180.0:printerr("RECORD_ERROR unresolved cutoff");finish();return false
 else:
  view._dusk_zoom=lerpf(view._dusk_zoom,1.65,.018)
  view._dusk_pan=view._dusk_pan.lerp(Vector2(210,-20),.018);view._frame_camera()
  var victory_times=[.1,2.,presentation.outro.duration+2.,presentation.outro.duration+9.]
  if presentation.stage=="ending" and victory_sample_index<victory_times.size() and presentation.end_clock>=float(victory_times[victory_sample_index]):
   var levels=[]
   for source in presentation.convoy_audio.sources.values():
    levels.append({"is_radio":bool(source.get_meta("is_radio",false)),"side":str(source.get_meta("side_id","")),"gain_db":source.volume_db,"foreground":source.get_meta("victory_foreground",0.),"attenuation":source.attenuation,"panning":source.panning_strength,"playing":source.playing})
   victory_audio_samples.append({"movie_seconds":float(frames)/30.,"end_clock":presentation.end_clock,"cards_visible":presentation.results_visible(),"levels":levels})
   victory_sample_index+=1
  if presentation.end_clock>3.0 and not snapshots.has("aftermath"):snapshots.aftermath=true;capture("aftermath")
  if presentation.results_visible() and presentation.end_clock>presentation.outro.duration+3.0 and not snapshots.has("results"):snapshots.results=true;capture("results")
  if presentation.end_clock>presentation.outro.duration+11.0:finish()
 return false
func audit_frame():
 if not active or view==null:return
 var p=view.battle_presentation
 var hud=view.get_node("CommandHudLayer").get_child(0)
 if p.results_visible() and not cards_seen:
  result_camera_jump=view._camera.position.distance_to(last_camera_position)*view._camera.zoom.x+(view._camera.zoom-last_camera_zoom).length()*root.size.y
 cards_seen=p.results_visible();last_camera_position=view._camera.position;last_camera_zoom=view._camera.zoom
 var boundary=hud.surface.get_global_transform_with_canvas().origin.y if hud.visible else root.size.y
 for id in view.actor_presenter._unit_nodes:
  var unit=b.get_participant(id);var node=view.actor_presenter._unit_nodes[id]
  if unit==null or not unit.is_alive:continue
  if p.stage=="ending" and not node.visible:
   var route=p.outro.routes.get(id,{})
   var valid_entry=route.get("action","")=="enter" and p.end_clock>=float(route.get("start",INF))+float(route.get("travel",INF))+.6 and node.position.distance_to(route.points[-1]*Vector2(8,6))<.1
   if valid_entry:entered_objective[id]=true
   elif safety_errors.size()<20:safety_errors.append("Hidden survivor "+id)
  if not node.visible:continue
  var body=node.get_node("body");var texture=body.sprite_frames.get_frame_texture(body.animation,body.frame)
  var size=texture.get_size();var box=body.get_global_transform_with_canvas()*Rect2(body.offset-size*.5,size)
  if hud.visible and box.end.y>boundary+.1 and safety_errors.size()<20:safety_errors.append("HUD overlap "+id+" "+str(box.end.y)+" > "+str(boundary))
  if p.stage=="ending" and previous_nodes.has(id):max_outro_jump=maxf(max_outro_jump,node.position.distance_to(previous_nodes[id]))
  previous_nodes[id]=node.position;safety_checks+=1
func capture(key: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/"+key+".png")
func finish():
 active=false
 var p=view.battle_presentation
 var hud_models=[]
 var hud=view.get_node("CommandHudLayer").get_child(0)
 for id in hud.cards:
  var unit=b.get_participant(id);var model=preload("res://battle/combat/battle_weapon_catalog.gd").for_participant(unit)
  var expected=model.display_name.to_upper() if model!=null else ""
  hud_models.append({"id":id,"class":unit.weapon_type,"model":hud.cards[id].weapon_model.text,"expected":expected,"matches":hud.cards[id].weapon_model.text==expected,"card_height":hud.cards[id].size.y})
 var report={"entered_objective":entered_objective.keys(),"arrival_manifest":arrival_manifest,"result_camera_jump_pixels":result_camera_jump,"faction_vocals_enabled":false,"max_simultaneous_voices":0,"faction_voice_events":[],"voice_clips_loaded":0,"voice_missing":[],"actor_frame_checks":safety_checks,"presentation_errors":safety_errors,"max_outro_jump_pixels":max_outro_jump,"camera_safety_frames":view.get_node("CameraSafety").checked_frames,"camera_safety_violations":view.get_node("CameraSafety").violations,"radio_origin":"Original composition; no recordings or samples","radio_bpm":106,"horn_gain_samples":horn_gain_samples,"radio_gain_samples":radio_gain_samples,"victory_audio_samples":victory_audio_samples,"extra_victory_card_seconds":5,"showcase_loadout":Director.config(),"seed":9146,"trim_frames":trim_frames,"frames":frames,"seconds":frames/30.0,"combat_seconds":b.elapsed_time_seconds,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"commands":d.log,"phases":phase_changes,"arrival_route_errors":p.last_path_errors,"outro_kind":p.outro.kind,"outro_errors":p.outro.errors,"results":p.result_snapshot,"result_summaries":p.result_summaries,"result_summary_checks":summary_checks,"hud_weapon_models":hud_models,"audio_shots":p.sound.shots_played,"convoy_slots":3,"attacking_units":16,"defending_units":16,"ambient_emitters":p.convoy_audio.sources.size()}
 FileAccess.open(out+"/record.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("RECORD_COMPLETE ",JSON.stringify(report))
 scene.queue_free()
 await process_frame
 quit(0 if b.battle_phase=="resolved" and safety_errors.is_empty() and report.outro_errors.is_empty() and report.arrival_route_errors.is_empty() else 1)
