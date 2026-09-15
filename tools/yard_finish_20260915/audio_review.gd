extends SceneTree
const Scenario=preload("res://tools/yard_finish_20260915/capture_config.gd")
var errors=[]
var samples=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 if not ok:errors.append(message);push_error(message)
func run():
 root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 scene.seed_value=91517;await scene.start_battle(false,Scenario.config());scene.set_process(false)
 if scene.battle==null:push_error(scene.note.text);quit(1);return
 for i in range(12):await process_frame
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");view.set_process(false)
 var presentation=view.battle_presentation;presentation.set_process(false)
 var mixer=presentation.convoy_audio;mixer.rebuild(b)
 var taps={}
 for player in mixer.sources.values():
  var tap=AudioEffectCapture.new();tap.buffer_length=2.
  AudioServer.add_bus_effect(AudioServer.get_bus_index(player.bus),tap)
  taps[str(player.get_meta("side_id"))]=tap
 for clock in [2.5,4.5,7.0,9.5]:
  presentation.stage="arrival";presentation.clock=clock
  view._dusk_zoom=lerpf(1.,1.55,smoothstep(3.8,8.0,clock));view._dusk_pan=Vector2(20,-50);view._frame_camera()
  presentation.apply_poses()
  mixer.sync(b,presentation.visual_vehicle_poses,true,0.,0.,presentation.convoy_radio_battle_mix(),0.)
  for i in range(10):await process_frame
  for tap in taps.values():tap.clear_buffer()
  for i in range(35):await process_frame
  var rms={}
  for side in taps:
   var tap=taps[side];var buffer=tap.get_buffer(tap.get_frames_available());var energy=0.
   for v in buffer:energy+=v.length_squared()
   rms[side]=sqrt(energy/maxi(1,buffer.size()*2))
  var margin=linear_to_db(maxf(rms.attacker,.00000001)/maxf(rms.defender,.00000001))
  samples.append({"clock":clock,"rms":rms,"attacker_margin_db":margin})
  check(rms.attacker>.00001,"audible incoming radio at "+str(clock))
  var minimum=3. if presentation.convoy_radio_battle_mix()>0. else 6.
  check(margin>=minimum,"incoming radio must lead arrival / fade handoff at "+str(clock))
 mixer.sync(b,{},true,0.,0.,1.,0.)
 for player in mixer.sources.values():
  var expected=float(player.get_meta("base_gain"))-float(player.get_meta("battle_drop",14.))
  check(absf(player.volume_db-expected)<.001,"existing combat gain preserved")
  check(absf(player.max_distance-float(player.get_meta("range")))<.001,"combat range preserved")
  check(absf(player.attenuation-float(player.get_meta("attenuation")))<.001,"combat attenuation preserved")
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://tools/yard_finish_20260915/sidewalk_review.png")
 var result={"samples":samples,"errors":errors}
 FileAccess.open("res://tools/yard_finish_20260915/audio_review.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"));print("SPATIAL_AUDIO_REVIEW ",JSON.stringify(result));quit(0 if errors.is_empty() else 1)
