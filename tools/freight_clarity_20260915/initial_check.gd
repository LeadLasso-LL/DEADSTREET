extends SceneTree
const Scenario=preload("res://gameplay/freight_exchange_scenario.gd")
const RadioFilter=preload("res://gameplay/tactical_radio_filter.gd")
var out="res://tools/freight_clarity_20260915/"
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);push_error(message)
func settle(n=8):
 for i in range(n):await process_frame
func shot(name_value: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+name_value+".png")
func level(player,filter,capture):
 player.play(8.)
 await create_timer(.25).timeout
 capture.clear_buffer()
 await create_timer(1.0).timeout
 var samples=capture.get_buffer(capture.get_frames_available());var power=0.;var peak=0.
 for sample in samples:
  power+=sample.x*sample.x+sample.y*sample.y;peak=maxf(peak,maxf(absf(sample.x),absf(sample.y)))
 return {"rms":sqrt(power/maxi(1,samples.size()*2)),"peak":peak,"frames":samples.size(),"cutoff":filter.cutoff_hz,"volume_db":player.volume_db}
func run():
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await settle(2)
 scene.seed_value=915523
 await scene.start_battle(false,Scenario.config());scene.set_process(false)
 check(scene.battle!=null,"scenario starts")
 if scene.battle==null:quit(1);return
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");var p=view.battle_presentation
 p.reset(b);p.begin_arrival();p.set_process(false);p.stage="arrival";p.clock=8.;p.apply_poses();p.update_markers()
 var player=p.convoy_audio.sources["sandbox_transport_00"]
 var filter=player.get_meta(RadioFilter.EFFECT_META)
 var capture=AudioEffectCapture.new();capture.buffer_length=3.
 AudioServer.add_bus_effect(AudioServer.get_bus_index(player.bus),capture)
 # Compare the same source passage, at the same vehicle position, through the old mix.
 player.volume_db=-18.+3.+linear_to_db(1.10);player.max_distance=2600.;player.attenuation=.35;RadioFilter.update(player,0.)
 var old=await level(player,filter,capture)
 p.apply_poses();var arrival=await level(player,filter,capture)
 var gain=linear_to_db(arrival.rms/maxf(.000001,old.rms))
 check(gain>8.,"arrival source audibly lifted by more than8dB")
 check(arrival.peak<.90,"arrival radio keeps headroom")
 check(filter.cutoff_hz>3600. and filter.cutoff_hz<4500.,"arrival interior filter opens moderately")
 await shot("arrival_audio")
 p.skip_to_ready();p.stage="active";p.apply_poses();p.update_markers();await settle(12)
 var combat=await level(player,filter,capture)
 check(combat.volume_db<=-32.,"combat radio remains quiet")
 check(filter.cutoff_hz==2400.,"combat vehicle returns to interior filter")
 var marker_rows=[]
 for badge in p.markers.values():
  var box=badge.get_global_rect();var native_size=badge.emblem.texture.get_size()
  check(box.size.is_equal_approx(Vector2(36,36)),"36px badge at1080p")
  check(box.position.distance_to(box.position.round())<.01,"badge lands on output pixels")
  check(native_size==box.size,"one texture pixel per screen pixel")
  marker_rows.append({"size":str(box.size),"position":str(box.position),"texture":str(native_size)})
 check(marker_rows.size()==20,"all20 actors have emblem markers")
 for node in view.actor_presenter._unit_nodes.values():check(node.get_node("body").texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"unit keeps crisp sampling")
 p.identifiers_enabled=false;p.update_markers()
 for badge in p.markers.values():check(not badge.visible,"emblem toggle hides marker")
 p.identifiers_enabled=true;p.update_markers();await settle(3);await shot("sharp_units_1080")
 root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size);p.set_process(true);await settle(8);p.set_process(false);p.skip_to_ready();p.update_markers();await settle(3);await shot("sharp_units_720")
 for badge in p.markers.values():check(badge.get_global_rect().size.is_equal_approx(Vector2(24,24)),"24px badge at720p")
 var report={"checks":checks,"errors":errors,"before":old,"arrival":arrival,"combat":combat,"arrival_gain_db":gain,"markers":marker_rows,"arrival_errors":p.last_path_errors}
 FileAccess.open(out+"validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"));print("CLARITY_CHECK ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
