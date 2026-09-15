extends SceneTree
## Native scripted orders only. No health, damage, RNG or victory overrides.
const Scenario=preload("res://gameplay/freight_exchange_scenario.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Force=preload("res://battle/core/battle_force_command_service.gd")
const Commands=preload("res://battle/combat/battle_player_command_service.gd")
const Setup=preload("res://gameplay/freight_exchange_setup.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const C=preload("res://battle/geometry/freight_exchange_catalog.gd")
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
var output="res://tools/freight_revision_20260915/"
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
 scene.seed_value=915523
 var config=Scenario.config()
 var Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
 var Config=preload("res://gameplay/sandbox_force_config.gd")
 config.attacker.units=[]
 for kind in ["rifle","rifle","rifle","rifle","rifle","rifle","smg","smg","sniper","sniper"]:
  var row=Config.unit(kind);row.tier=3;row.armor="reinforced_carrier"
  for model in Weapons.models_for_class(kind):
   if Weapons.get_model(model).tier>Weapons.get_model(row.weapon).tier:row.weapon=model
  config.attacker.units.append(row)
 for row in config.defender.units:row.armor="patrol_vest"
 await scene.start_battle(false,config);scene.set_process(false)
 if scene.battle==null:push_error(scene.note.text);quit(1);return
 b=scene.battle;view=scene.runtime.get_node("TacticalBattleView");presentation=view.battle_presentation
 view._dusk_zoom=1.10;view._dusk_pan=Vector2(0,-35);view._frame_camera()
 for v in b.vehicles.values():seat_manifest.append({"vehicle":v.vehicle_type_id,"count":v.get_meta("convoy_occupants",[]).size(),"passengers":v.get_meta("convoy_occupants",[])})
 first_frame=Engine.get_process_frames()
 while frame<30*210:
  await process_frame;frame+=1
  var stage=presentation.stage
  if not stage_frames.has(stage):stage_frames[stage]=frame
  if stage=="arrival":
   view._dusk_zoom=1.10
   view._dusk_pan=Vector2(0,-35);view._frame_camera()
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
   for at in [6,14,26,40,60]:
    if b.elapsed_time_seconds>=at and not flags.has("combat_%d"%at):await shot("combat_%d"%at)
   if b.elapsed_time_seconds>=150.:errors.append("Battle did not resolve by150 seconds");break
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
 var report={"seed":915523,"phase":b.battle_phase,"winner":b.get_winning_side_id(),"combat_seconds":b.elapsed_time_seconds,"frames":Engine.get_process_frames()-first_frame,"loop_frames":frame,"trim_frames":first_frame,"seconds":(Engine.get_process_frames()-first_frame)/30.,"survivors":survivors,"commands":commands,"arrival_errors":presentation.last_path_errors,"outro_errors":presentation.outro.errors,"errors":errors,"camera_violations":safety.violations if safety!=null else -1,"camera_frames":safety.checked_frames if safety!=null else 0,"manifest":seat_manifest,"results":presentation.result_snapshot,"audio":audio_sources,"advance":metrics,"stages":stage_frames}
 FileAccess.open(output+("record.json" if capture else "rehearsal.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("EASTEX_SHOWCASE ",JSON.stringify(report));quit(0 if errors.is_empty() and b.battle_phase=="resolved" and presentation.last_path_errors.is_empty() and presentation.outro.errors.is_empty() else 1)
func shot(name_value: String):
 flags[name_value]=true
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+name_value+".png")
func move(id: String,at: Vector2,label_value: String):
 var p=b.get_participant(id)
 if p==null or not p.is_alive or p.is_wounded:return
 var result=view.orders_controller._issue_move_one(p,at)
 commands.append({"time":b.elapsed_time_seconds,"action":label_value,"unit":id,"accepted":result.success,"destination":str(at)})
func command_group(ids: Array,kind: String,line: float,label_value: String):
 var result=Commands.issue(b,ids,kind,line)
 commands.append({"time":b.elapsed_time_seconds,"action":label_value,"accepted":result.accepted,"failed":result.failed})
func fighters(side: String,kinds: Array=[]) -> Array:
 var ids=[]
 for p in b.participants.values():
  if p.side_id==side and p.is_alive and not p.is_wounded and (kinds.is_empty() or p.weapon_type in kinds):ids.append(p.participant_id)
 return ids
func direct():
 var t=b.elapsed_time_seconds
 if t>=.8 and not flags.has("opening"):
  flags.opening=true
  command_group(fighters(b.attacker_side_id,["rifle","sniper"]),"push",80.,"Ashford-Crane fire teams occupy the central loading positions")
  command_group(fighters(b.attacker_side_id,["smg"]),"push",71.,"Close assault team advances behind the railcars")
 if t>=8. and not flags.has("counter"):
  flags.counter=true
  command_group(fighters(b.defender_side_id),"push",108.,"McAllister launches a counterattack across the eastern yard")
 if t>=18. and not flags.has("fix"):
  flags.fix=true
  command_group(fighters(b.attacker_side_id,["rifle","sniper"]),"hold",80.,"Ashford-Crane holds cover and pins the counterattack")
  command_group(fighters(b.attacker_side_id,["smg"]),"push",104.,"Assault team takes the eastern crossing")
 if t>=27. and not flags.has("commit"):
  flags.commit=true
  command_group(fighters(b.defender_side_id),"push",88.,"McAllister commits the remaining guards")
 if t>=36. and not flags.has("finish"):
  flags.finish=true
  command_group(fighters(b.attacker_side_id),"push",134.,"Ashford-Crane advances on dispatch")
 if t>=48. and not flags.has("release"):
  flags.release=true
  for p in b.participants.values():
   if p.is_alive and not p.is_wounded:p.clear_player_tactical_intent()
  for id in b.get_sorted_tactical_force_ids():Force.set_command(b,id,"push")
  commands.append({"time":t,"action":"Surviving fighters press the final engagement"})
