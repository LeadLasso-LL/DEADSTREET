extends SceneTree
const Scenario=preload("res://gameplay/freight_exchange_scenario.gd")
const C=preload("res://battle/geometry/freight_exchange_catalog.gd")
const Setup=preload("res://gameplay/freight_exchange_setup.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Force=preload("res://battle/core/battle_force_command_service.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
var errors=[]
var checks=0
var out="res://tools/freight_revision_20260915/"
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);push_error(message)
func settle(n=8):
 for i in range(n):await process_frame
func shot(name_value: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+name_value+".png")
func run():
 root.size=Vector2i(1440,900);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await settle(2)
 scene.seed_value=915523
 var Maps=preload("res://gameplay/sandbox_map_catalog.gd")
 var preset=Maps.preset("freight_exchange")
 check(preset.attacker.units.size()==10 and preset.defender.units.size()==10,"map-picker 10v10 preset")
 check(Config.validate(preset).valid,"map-picker preset legal")
 check(Maps.texture("freight_exchange")!=null,"night thumbnail present")
 var config=Scenario.config()
 if "--capacity" in OS.get_cmdline_user_args():
  config=Scenario.config(16);config.attacker.vehicles=Config.auto_convoy(16,config.attacker.faction)
 await scene.start_battle(false,config);scene.set_process(false)
 if scene.battle==null:push_error(scene.note.text);quit(1);return
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");var presentation=view.battle_presentation
 presentation.reset(b);presentation.begin_arrival()
 check(b.participants.size()==config.attacker.units.size()*2,"selected participant count")
 check(b.battlefield_geometry.authored_layout_id==C.ID,"new map loaded")
 check(b.battlefield_geometry.is_valid(),"valid native geometry")
 var routes=[]
 for cross in C.CROSSINGS:
  var x: float=cross.get_center().x;var a=Vector2(x,20);var z=Vector2(x,54)
  var path=Nav.find_path(b,a,z);check(path.success,"crossing "+str(x));routes.append({"x":x,"success":path.success})
 for y in [20.,34.,54.,70.]:check(Nav.find_path(b,Vector2(25,y),Vector2(160,y)).success,"east-west lane "+str(y))
 for slot in b.battlefield_geometry.cover_slots.values():check(Nav.is_reachable(b,C.ENTRANCE,slot.position),"reachable "+slot.cover_slot_id)
 var positions=[];var manifest=[]
 for p in b.participants.values():
  check(p.has_battle_position and p.has_occupied_cover_slot(),"opening cover "+p.participant_id)
  positions.append({"id":p.participant_id,"position":str(p.battle_position),"slot":p.occupied_cover_slot_id})
  for q in b.participants.values():
   if p.participant_id<q.participant_id:check(p.battle_position.distance_to(q.battle_position)>=2.399,"body spacing "+p.participant_id+" / "+q.participant_id)
  if p.side_id==b.attacker_side_id:
   var route=Exit.route(b,b.get_vehicle(p.transport_vehicle_id),p.battle_position,bool(p.get_meta("transport_bed",false)))
   check(not route.is_empty() and route.path.success,"real transport exit "+p.participant_id)
 for v in b.vehicles.values():
  manifest.append({"id":v.battle_vehicle_id,"model":v.vehicle_type_id,"occupants":v.get_meta("convoy_occupants",[]),"position":str(v.battle_position)})
  var stop=presentation.vehicle_stop_time(v);var end=Setup.arrival_pose(v,stop,stop)
  check(end.position.is_equal_approx(v.battle_position),"arrival ends at real placement "+v.battle_vehicle_id)
 # Sample the animated physical hulls; parking and routes must clear actual props.
 var static_hits={};var convoy_hits={}
 for step in range(241):
  var clock=float(step)/20.;var hulls={}
  for v in b.vehicles.values():
   var pose=Setup.arrival_pose(v,clock,presentation.vehicle_stop_time(v))
   var hull=Body.corners_for_pose(pose.position,pose.facing,Body.profile_for_vehicle(v));hulls[v.battle_vehicle_id]=hull
   for row in C.props():
    var box: Rect2=row[1]
    var polygon=PackedVector2Array([box.position,Vector2(box.end.x,box.position.y),box.end,Vector2(box.position.x,box.end.y)])
    if not Geometry2D.intersect_polygons(hull,polygon).is_empty():static_hits[v.battle_vehicle_id+" / "+str(row[0])]=clock
  for id in hulls:
   for other in hulls:
    if id<other and not Geometry2D.intersect_polygons(hulls[id],hulls[other]).is_empty():convoy_hits[id+" / "+other]=clock
 check(static_hits.is_empty(),"animated vehicle hulls clear props: "+str(static_hits))
 check(convoy_hits.is_empty(),"animated vehicle hulls clear one another: "+str(convoy_hits))
 check(presentation.fixed_defenders(),"defenders stay deployed during arrival")
 presentation.set_process(false);presentation.stage="arrival";presentation.clock=5.;presentation.apply_poses();await settle();await shot("arrival")
 check(presentation.last_path_errors.is_empty(),"native arrival routes")
 presentation.skip_to_ready();check(Fixture.begin_review(scene.runtime,b).success,"normal battle starts")
 b.tactical_paused=true;await settle(14);await shot("opening_10v10" if config.attacker.units.size()==10 else "opening_16v16")
 var radios=[]
 for player in presentation.convoy_audio.sources.values():
  radios.append({"track":player.get_meta("track_id",""),"position":str(player.position),"faction":player.get_meta("faction_id","")})
  if player.get_meta("side_id","")==b.defender_side_id and player.get_meta("is_radio",false):check(player.get_meta("fixed_position")==C.ENTRANCE,"radio is inside dispatch office")
 var weather
 for node in view._dusk_nodes:
  if node.get_script()!=null and node.get_script().resource_path.ends_with("freight_exchange_weather.gd"):weather=node
 check(weather!=null,"map-specific night and weather loaded")
 if weather!=null:
  check(weather.lights.size()==9,"nine local yard lights")
  check(weather.rain.playing and weather.roof.playing,"both rain stems playing")
  check(weather.rain.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD and weather.roof.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD,"both rain stems looping")
  presentation.audio_enabled=false;await settle(2)
  check(weather.rain.stream_paused and weather.roof.stream_paused,"audio toggle mutes rain")
  presentation.audio_enabled=true;await settle(2)
  check(not weather.rain.stream_paused and not weather.roof.stream_paused,"audio toggle restores rain")
 # Exercise the simulation after deployment; no damage or victory overrides.
 b.tactical_paused=false
 for id in b.get_sorted_tactical_force_ids():Force.set_command(b,id,"push")
 var timings=[];var frame_times=[]
 for i in range(450 if config.attacker.units.size()==10 else 60):
  var frame_start=Time.get_ticks_usec();await process_frame
  var start=Time.get_ticks_usec();Runtime.advance(b,1./30.);timings.append((Time.get_ticks_usec()-start)/1000.)
  frame_times.append((Time.get_ticks_usec()-frame_start)/1000.)
  if b.battle_phase=="resolved":break
 b.tactical_paused=true;await settle(4);await shot("combat_check")
 for p in b.participants.values():
  if p.has_battle_position:check(Rect2(Vector2.ZERO,C.SIZE).has_point(p.battle_position),"participant inside map "+p.participant_id)
 timings.sort();frame_times.sort()
 var perf={"advance_median_ms":timings[int(timings.size()*.5)],"advance_p95_ms":timings[int(timings.size()*.95)],"frame_median_ms":frame_times[int(frame_times.size()*.5)],"frame_p95_ms":frame_times[int(frame_times.size()*.95)],"frames":timings.size()}
 var report={"checks":checks,"errors":errors,"routes":routes,"manifest":manifest,"positions":positions,"radios":radios,"performance":perf,"combat_seconds":b.elapsed_time_seconds,"phase":b.battle_phase}
 FileAccess.open(out+("capacity.json" if config.attacker.units.size()==16 else "validation.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"));print("FREIGHT_REVIEW ",JSON.stringify(report))
 quit(0 if errors.is_empty() else 1)
