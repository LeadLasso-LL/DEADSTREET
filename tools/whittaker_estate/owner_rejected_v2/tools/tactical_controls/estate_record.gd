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
var radio_gain_samples=[]
var horn_gain_samples=[]
var radio_sample_index=0
var victory_audio_samples=[]
var victory_sample_index=0
var summary_checks={}
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
 view._dusk_zoom=1.7;view._dusk_pan=Vector2(-475,92);view._frame_camera()
 view.battle_presentation.audio_enabled=true
 d=Director.new()
 trim_frames=Engine.get_process_frames()
 active=true
 print("RECORD_READY")
func _process(delta):
 if not active:return false
 frames+=1
 var presentation=view.battle_presentation
 var sample_times=[6.0,10.5,11.5,13.0,20.0]
 if radio_sample_index<sample_times.size() and float(frames)/30.>=float(sample_times[radio_sample_index]):
  for source in presentation.convoy_audio.sources.values():
   if bool(source.get_meta("is_radio",false)):
    radio_gain_samples.append({"movie_seconds":float(frames)/30.,"phase":presentation.stage,"arrival_clock":presentation.clock,"gain_db":source.volume_db,"battle_mix":presentation.convoy_radio_battle_mix()})
   elif bool(source.get_meta("is_trc_horn",false)):
    horn_gain_samples.append({"movie_seconds":float(frames)/30.,"phase":presentation.stage,"gain_db":source.volume_db,"playing":source.playing,"position":str(source.position),"range":source.max_distance,"attenuation":source.attenuation})
  radio_sample_index+=1
 if presentation.stage!=last_phase:
  last_phase=presentation.stage
  phase_changes.append({"frame":frames,"phase":last_phase,"battle_time":b.elapsed_time_seconds})
  print("RECORD_PHASE ",last_phase," FRAME ",frames)
 if not started:
  # Follow the TRC road turn and dismount, then reveal the estate defense.
  var reveal=smoothstep(6.7,11.5,presentation.clock)
  view._dusk_zoom=lerpf(1.7,1.04,reveal)
  view._dusk_pan=Vector2(-475,92).lerp(Vector2(0,-34),reveal);view._frame_camera()
  if presentation.clock>=1.5 and not snapshots.has("intro_full"):
   snapshots.intro_full=true;capture("intro_full")
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
   var target=Vector2((center-b.battlefield_geometry.width*.5)*8.,-30.)
   var zoom=1.04 if b.elapsed_time_seconds<4.0 else clampf(98.0/maxf(ex-ax+58.,68.),1.12,1.42)
   view._dusk_zoom=lerpf(view._dusk_zoom,zoom,.018)
   view._dusk_pan=view._dusk_pan.lerp(target,.018)
   view._frame_camera()
  for t in [12,30,60,100]:
   var key="combat_"+str(t)
   if b.elapsed_time_seconds>=t and not snapshots.has(key):snapshots[key]=true;capture(key)
  if frames%300==0:print("RECORD_PROGRESS ",frames/30.0," SIM ",b.elapsed_time_seconds," UNITS ",own.size()," / ",enemy.size())
  if b.elapsed_time_seconds>180.0:printerr("RECORD_ERROR unresolved cutoff");finish();return false
 else:
  view._dusk_zoom=lerpf(view._dusk_zoom,1.10,.018)
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
 var report={"radio_origin":"Original composition; no recordings or samples","radio_bpm":106,"horn_gain_samples":horn_gain_samples,"radio_gain_samples":radio_gain_samples,"victory_audio_samples":victory_audio_samples,"extra_victory_card_seconds":5,"showcase_loadout":Director.config(),"seed":9146,"trim_frames":trim_frames,"frames":frames,"seconds":frames/30.0,"combat_seconds":b.elapsed_time_seconds,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"commands":d.log,"phases":phase_changes,"arrival_route_errors":p.last_path_errors,"outro_kind":p.outro.kind,"outro_errors":p.outro.errors,"results":p.result_snapshot,"result_summaries":p.result_summaries,"result_summary_checks":summary_checks,"hud_weapon_models":hud_models,"audio_shots":p.sound.shots_played,"convoy_slots":3,"attacking_units":16,"defending_units":16,"ambient_emitters":p.convoy_audio.sources.size()}
 FileAccess.open(out+"/record.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("RECORD_COMPLETE ",JSON.stringify(report))
 scene.queue_free()
 await process_frame
 quit(0 if b.battle_phase=="resolved" else 1)
